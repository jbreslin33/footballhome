#include "SimPool.h"

#include "SimOrchestrator.h"

#include <cstdlib>
#include <iostream>
#include <string>
#include <utility>

namespace fh::orchestration {

namespace {

// Env parsing helpers — local, mirror the shape used in
// SimOrchestrator.cpp so ops toggles feel consistent across the
// backend. Kept anon-namespace-scoped rather than exported because
// loadSimPoolConfigFromEnv is the only caller.
int envIntOrDefault(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try {
        return std::stoi(v);
    } catch (...) {
        return fallback;
    }
}

} // namespace

SimPoolConfig loadSimPoolConfigFromEnv() {
    SimPoolConfig cfg;
    cfg.target_size = envIntOrDefault("FH_SIM_POOL_SIZE", 0);
    if (cfg.target_size < 0) cfg.target_size = 0;

    int backoff_ms = envIntOrDefault("FH_SIM_POOL_REFILL_BACKOFF_MS", 2000);
    if (backoff_ms < 100) backoff_ms = 100;
    cfg.refill_backoff_on_error = std::chrono::milliseconds(backoff_ms);

    int wake_ms = envIntOrDefault("FH_SIM_POOL_REFILL_WAKE_MS", 30000);
    if (wake_ms < 100) wake_ms = 100;
    cfg.refill_wake_interval = std::chrono::milliseconds(wake_ms);

    return cfg;
}

SimPool::SimPool(SimPoolConfig cfg, SimOrchestrator& orch)
    : cfg_(std::move(cfg)), orch_(orch) {}

SimPool::~SimPool() {
    stop();
}

void SimPool::start() {
    // Idempotent — running_ flips true iff we successfully start.
    bool expected = false;
    if (!running_.compare_exchange_strong(expected, true)) {
        return;
    }
    shutdown_requested_.store(false, std::memory_order_relaxed);
    refill_thread_ = std::thread([this] { refillLoop(); });
}

void SimPool::stop() {
    if (!running_.load(std::memory_order_relaxed)) {
        return;
    }
    {
        std::lock_guard<std::mutex> lk(mtx_);
        shutdown_requested_.store(true, std::memory_order_relaxed);
    }
    cv_.notify_all();
    if (refill_thread_.joinable()) {
        refill_thread_.join();
    }
    running_.store(false, std::memory_order_relaxed);
}

std::optional<SimPoolSlot> SimPool::take() {
    std::optional<SimPoolSlot> out;
    {
        std::lock_guard<std::mutex> lk(mtx_);
        if (slots_.empty()) {
            return std::nullopt;
        }
        out = std::move(slots_.front());
        slots_.pop_front();
        ++total_taken_;
    }
    // Wake refill thread so it can start replacing the taken slot.
    cv_.notify_one();
    return out;
}

SimPoolMetrics SimPool::metrics() const {
    std::lock_guard<std::mutex> lk(mtx_);
    SimPoolMetrics m;
    m.available = slots_.size();
    m.total_spawned = total_spawned_;
    m.total_taken = total_taken_;
    m.total_spawn_failures = total_spawn_failures_;
    m.next_warm_id = next_warm_id_;
    return m;
}

void SimPool::refillLoop() {
    while (!shutdown_requested_.load(std::memory_order_relaxed)) {
        long long warm_id = 0;
        {
            std::unique_lock<std::mutex> lk(mtx_);
            // Wait until either shutdown, or the pool has room. The
            // wake_interval timeout is a self-heal safety net —
            // covers the case where a spawn failed and take() isn't
            // being called (so no notify) but we still want to
            // eventually retry.
            cv_.wait_for(lk, cfg_.refill_wake_interval, [this] {
                return shutdown_requested_.load(std::memory_order_relaxed) ||
                       static_cast<int>(slots_.size()) < cfg_.target_size;
            });
            if (shutdown_requested_.load(std::memory_order_relaxed)) {
                return;
            }
            if (static_cast<int>(slots_.size()) >= cfg_.target_size) {
                // Timeout wake with no room needed — loop and wait again.
                continue;
            }
            // Reserve a warm_id under lock so concurrent refill_now
            // (future) can't collide. Bumped BEFORE the spawn so a
            // failure doesn't cause retry with the same id — a
            // half-created container with that name would fail again.
            warm_id = next_warm_id_++;
        }

        // Spawn WITHOUT holding the mutex — podman round-trip is
        // ~500 ms and would block take() for that entire window.
        auto r = orch_.spawnWarm(warm_id);

        if (!r.ok) {
            {
                std::lock_guard<std::mutex> lk(mtx_);
                ++total_spawn_failures_;
            }
            std::cerr << "[sim-pool] spawnWarm(warm_id=" << warm_id
                      << ") failed: " << r.error
                      << " — backing off "
                      << cfg_.refill_backoff_on_error.count() << "ms"
                      << std::endl;
            // Interruptible sleep so a shutdown during backoff exits
            // quickly rather than waiting the full window.
            std::unique_lock<std::mutex> lk(mtx_);
            cv_.wait_for(lk, cfg_.refill_backoff_on_error, [this] {
                return shutdown_requested_.load(std::memory_order_relaxed);
            });
            continue;
        }

        {
            std::lock_guard<std::mutex> lk(mtx_);
            slots_.push_back({ warm_id, r.container_id, r.container_name });
            ++total_spawned_;
        }
    }
}

} // namespace fh::orchestration
