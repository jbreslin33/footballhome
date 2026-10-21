// footballhome sim - AsyncPgLog<Row>
//
// Bounded, thread-safe queue drained by one dedicated background thread that
// hands each drained batch to a caller-supplied sink lambda. push() is
// nothrow: on a full queue it drops the row and bumps an atomic counter
// (visible via dropped()) instead of blocking the caller.
//
// Rationale (DESIGN.md §16.6 Slice 13 task 8):
//   * Gameplay thread MUST NOT block on Postgres. Any Pg blip that the sync
//     driver would translate into a multi-hundred-ms stall would ripple
//     straight into missed ticks. This class enforces that boundary.
//   * A single background drain thread is enough for M0 (one match, tens
//     of inputs per second peak). Multi-match orchestration is an explicit
//     §16.6 non-goal and this design does not preclude a per-match drain
//     later.
//   * Drop-on-full policy is deliberate: back-pressuring the game to protect
//     the log defeats the point. Sustained dropping surfaces via ops-visible
//     stderr logs from the sink error path and via mounting dropped()
//     counts, both of which are Slice 13 exit-criteria violations that
//     have to be fixed at the Pg or connection-pool layer, not by making
//     the gameplay thread wait.
//
// Sink exceptions are caught, logged, and swallowed: a Pg blip during a
// live match must not tear the drain thread down. See DESIGN.md §22.12
// (persistence-library ADR — error surface is throw-based; here at the
// async boundary we translate throw → dropped, since there is no caller
// left to catch on the gameplay thread).
//
// Templated so InputLog (= AsyncPgLog<InputRow>) and EventLog
// (= AsyncPgLog<EventRow>) share one implementation (§3 rule 4 — no
// duplication).

#pragma once

#include <atomic>
#include <condition_variable>
#include <cstddef>
#include <cstdio>
#include <exception>
#include <functional>
#include <mutex>
#include <span>
#include <thread>
#include <utility>
#include <vector>

namespace fh::sim::persistence {

template <typename Row>
class AsyncPgLog {
public:
    // Sink is invoked from the drain thread with a span whose lifetime
    // is bounded by the call. Persist-across-call requires a copy.
    using BatchSink = std::function<void(std::span<const Row>)>;

    // capacity = max queued rows before push starts dropping. 256 rows
    // is ~13 s of one-input-per-tick per slot at 20 Hz, giving Postgres
    // a long grace window before drops start (§16.6 spec).
    explicit AsyncPgLog(BatchSink sink, std::size_t capacity = 256);
    ~AsyncPgLog();

    AsyncPgLog(const AsyncPgLog&)            = delete;
    AsyncPgLog& operator=(const AsyncPgLog&) = delete;
    AsyncPgLog(AsyncPgLog&&)                 = delete;
    AsyncPgLog& operator=(AsyncPgLog&&)      = delete;

    // Enqueue one row. Nothrow: increments dropped() and returns on
    // a full queue or an allocation failure.
    void push(Row row) noexcept;

    // Signal drain to exit, join. Any queued rows are drained once more
    // before the thread returns (best-effort — sink errors during this
    // final drain are counted as drops, not raised). Idempotent; safe
    // to call from the destructor.
    void stop();

    std::size_t dropped() const noexcept
    { return dropped_.load(std::memory_order_relaxed); }

    // Test-only: how many rows the sink has been handed successfully.
    std::size_t flushed() const noexcept
    { return flushed_.load(std::memory_order_relaxed); }

private:
    void drainLoop();

    BatchSink                sink_;
    std::size_t              capacity_;
    std::mutex               mutex_;
    std::condition_variable  cv_;
    std::vector<Row>         queue_;
    std::atomic<std::size_t> dropped_{0};
    std::atomic<std::size_t> flushed_{0};
    std::atomic<bool>        stopping_{false};
    std::thread              thread_;
};

// ---------------------------------------------------------------------------
// Implementation (templated, kept in the header)
// ---------------------------------------------------------------------------

template <typename Row>
AsyncPgLog<Row>::AsyncPgLog(BatchSink sink, std::size_t capacity)
    : sink_(std::move(sink)), capacity_(capacity == 0 ? 1 : capacity)
{
    queue_.reserve(capacity_);
    thread_ = std::thread([this] { drainLoop(); });
}

template <typename Row>
AsyncPgLog<Row>::~AsyncPgLog()
{
    stop();
}

template <typename Row>
void AsyncPgLog<Row>::push(Row row) noexcept
{
    try {
        std::unique_lock<std::mutex> lk(mutex_);
        if (queue_.size() >= capacity_) {
            dropped_.fetch_add(1, std::memory_order_relaxed);
            return;
        }
        queue_.push_back(std::move(row));
        lk.unlock();
        cv_.notify_one();
    } catch (...) {
        // Any exception (allocation failure, lock throw): treat as drop
        // so the gameplay thread cannot ever fault at this call site.
        dropped_.fetch_add(1, std::memory_order_relaxed);
    }
}

template <typename Row>
void AsyncPgLog<Row>::stop()
{
    if (stopping_.exchange(true, std::memory_order_acq_rel)) {
        // Already stopped by an earlier call.
        return;
    }
    cv_.notify_all();
    if (thread_.joinable()) {
        thread_.join();
    }
}

template <typename Row>
void AsyncPgLog<Row>::drainLoop()
{
    std::vector<Row> local;
    local.reserve(capacity_);

    for (;;) {
        {
            std::unique_lock<std::mutex> lk(mutex_);
            cv_.wait(lk, [this] {
                return !queue_.empty()
                    || stopping_.load(std::memory_order_acquire);
            });
            local.swap(queue_);
        }

        if (!local.empty()) {
            try {
                sink_(std::span<const Row>(local.data(), local.size()));
                flushed_.fetch_add(local.size(), std::memory_order_relaxed);
            } catch (const std::exception& e) {
                std::fprintf(stderr,
                             "sim: AsyncPgLog sink threw (rows=%zu): %s - "
                             "batch dropped, drain continues\n",
                             local.size(), e.what());
                dropped_.fetch_add(local.size(), std::memory_order_relaxed);
            } catch (...) {
                std::fprintf(stderr,
                             "sim: AsyncPgLog sink threw unknown (rows=%zu) - "
                             "batch dropped, drain continues\n",
                             local.size());
                dropped_.fetch_add(local.size(), std::memory_order_relaxed);
            }
            local.clear();
        }

        if (stopping_.load(std::memory_order_acquire)) {
            // Final drain: catch any row a producer raced in between the
            // swap above and the stopping check.
            {
                std::unique_lock<std::mutex> lk(mutex_);
                local.swap(queue_);
            }
            if (!local.empty()) {
                try {
                    sink_(std::span<const Row>(local.data(), local.size()));
                    flushed_.fetch_add(local.size(),
                                       std::memory_order_relaxed);
                } catch (...) {
                    dropped_.fetch_add(local.size(),
                                       std::memory_order_relaxed);
                }
            }
            return;
        }
    }
}

} // namespace fh::sim::persistence
