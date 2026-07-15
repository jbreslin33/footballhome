// footballhome sim - SimServer
//
// Owns one Match plus the network transport that drives it. Wires
// transport callbacks (onConnect / onDisconnect / onMessage) to Match
// slot lifecycle and INPUT application, and pushes a SNAPSHOT frame
// out to every connected client at the configured tick rate.
//
// Threading: single-threaded. `run()` alternates transport.poll(timeout)
// with match.tick() at a fixed cadence. `stop()` is signal-safe (only
// touches std::atomic<bool>).
//
// Client → Slot policy (M0): the first free (unowned) slot is auto-
// assigned to a new client at connect time. Explicit CLAIM_SLOT /
// RELEASE_SLOT wire messages are M1+.
//
// See DESIGN.md §5.9, §7, §16.1.

#pragma once

#include "auth/JwtVerifier.hpp"
#include "common/IdTypes.hpp"
#include "match/Match.hpp"
#include "net/INetworkTransport.hpp"
#include "net/ISnapshotSerializer.hpp"
#include "persistence/EventLog.hpp"
#include "persistence/InputLog.hpp"
#include "persistence/ProfileStore.hpp"
#include "profile/PlayerProfile.hpp"

#include <atomic>
#include <cstdint>
#include <functional>
#include <memory>
#include <span>
#include <unordered_map>

namespace fh::sim::server {

class SimServer {
public:
    struct Config {
        std::uint32_t tick_hz     = 20;    // sent in HELLO_ACK
        std::uint64_t match_id    = 1;     // sent in HELLO_ACK
    };

    // Ownership: SimServer takes over transport / serializer / match. The
    // ProfileStore is non-owning — main() keeps it alive alongside the
    // PgClient it wraps. `input_log` / `event_log` are also non-owning
    // and may be nullptr; when null, the corresponding logging path is
    // silently skipped (tests use this to run without a background
    // drain thread). Match must already be constructed with a
    // scenario (SimServer never spawns scenarios itself; that's
    // main.cpp / a factory).
    SimServer(Config cfg,
              std::unique_ptr<net::INetworkTransport>   transport,
              std::unique_ptr<net::ISnapshotSerializer> serializer,
              std::unique_ptr<match::Match>             match,
              persistence::ProfileStore*                profile_store,
              persistence::InputLog*                    input_log = nullptr,
              persistence::EventLog*                    event_log = nullptr);

    ~SimServer() = default;

    SimServer(const SimServer&)            = delete;
    SimServer& operator=(const SimServer&) = delete;

    // Blocking event loop. Returns after stop() is called or after
    // Match::ended() flips true.
    //
    // `steady_now_ms` returns monotonic milliseconds; a std::chrono-
    // backed default is used when the parameter is empty. Tests inject
    // a virtual clock for deterministic tick cadence.
    void run(std::function<std::int64_t()> steady_now_ms = {});

    // Ask run() to exit at the next loop boundary. Safe to call from a
    // signal handler (touches only an atomic<bool>). Idempotent.
    void stop() noexcept { running_.store(false, std::memory_order_relaxed); }

    // Test hooks --------------------------------------------------------
    // Drive the transport once without ticking the match. Used by tests
    // that want to interleave client I/O with hand-controlled ticks.
    void pollTransport(int timeout_ms)     { transport_->poll(timeout_ms); }

    // One deterministic step: tick the match, broadcast the resulting
    // snapshot to every mapped client. Does NOT drive the transport.
    void tickOnceForTest();

    // Observers ---------------------------------------------------------
    net::INetworkTransport& transport() noexcept { return *transport_; }
    match::Match&           match()     noexcept { return *match_; }
    std::size_t             activeClientCount() const noexcept { return client_slot_.size(); }

    // Tick loop instrumentation (§21.7 item 2 diagnostic — 2026-07-14).
    // `ticksExecuted()` counts every completed `match_->tick()` since
    // `run()` started. `catchUpSkips()` counts every time the fixed-
    // cadence scheduler in `run()` detected it was > 5 periods behind
    // and reset `next_tick_at = after` (silently dropping the intervening
    // ticks). A daemon reporting `catchUpSkips() == 0` at match-end is
    // hitting its full tick budget; anything > 0 explains a shortfall in
    // `MAX(sim_match_events.tick_num) / (ended_at - started_at)` vs the
    // configured tick_hz. Both are monotonically increasing across the
    // daemon's lifetime — safe to sample from any thread. See DESIGN.md
    // §21.7 item 2.
    std::uint64_t ticksExecuted()  const noexcept { return ticks_executed_.load(std::memory_order_relaxed); }
    std::uint32_t catchUpSkips()   const noexcept { return catch_up_skips_.load(std::memory_order_relaxed); }

    // Sub-skip jitter counters (§21.7 item 2 step-3 — 2026-07-14 landing
    // 49d8d4ae's follow-up). Attribute the effective-Hz deficit that
    // survives after the catch-up-skip counter proved zero under 20-way
    // load. Both bump per completed tick in `run()` and measure how far
    // the tick loop was behind cadence AT THE MOMENT the tick completed
    // (i.e. `max(0, after - next_tick_at)` after the tick executed and
    // `next_tick_at` advanced by period_ms — a value in [0, 5*period_ms)
    // because anything ≥ 5*period_ms is claimed by the skip branch and
    // resets `next_tick_at` before we could accumulate it). Diagnostic
    // math: `avg_stretch_ms = sumBehindMs() / ticksExecuted()` — the
    // average per-tick slippage; if `total_ticks * period_ms + sum_behind_ms`
    // approximates wall_ms then the loop's whole deficit is explained by
    // steady jitter, not by outlier ticks. `maxBehindMs()` bounds the
    // worst-case single-tick stall that stayed under the skip threshold.
    std::uint64_t sumBehindMs() const noexcept { return sum_behind_ms_.load(std::memory_order_relaxed); }
    std::uint32_t maxBehindMs() const noexcept { return max_behind_ms_.load(std::memory_order_relaxed); }

private:
    // Transport callbacks (bound in constructor).
    void handleConnect(ClientId cid, const auth::JwtClaims& claims);
    void handleDisconnect(ClientId cid);
    void handleMessage(ClientId cid, std::span<const std::uint8_t> bytes);

    // Assign the first unowned scenario slot to `cid`, seating them with
    // the supplied profile. Returns 0 if all slots are taken (client
    // stays connected as spectator).
    SlotId assignFreeSlot(ClientId cid,
                          PersonId person,
                          profile::PlayerProfile profile);

    // Serialize match.snapshot() once and send the resulting bytes to
    // every mapped client.
    void broadcastSnapshot();

    Config                                       cfg_;
    std::unique_ptr<net::INetworkTransport>      transport_;
    std::unique_ptr<net::ISnapshotSerializer>    serializer_;
    std::unique_ptr<match::Match>                match_;
    persistence::ProfileStore*                   profile_store_{nullptr};
    persistence::InputLog*                       input_log_{nullptr};
    persistence::EventLog*                       event_log_{nullptr};

    // ClientId → SlotId. 0 = spectator (no slot assigned).
    std::unordered_map<ClientId, SlotId>         client_slot_;

    // Tick loop instrumentation (§21.7 item 2). Written only by run() on
    // the tick thread; read from any thread via ticksExecuted() /
    // catchUpSkips().
    std::atomic<std::uint64_t>                   ticks_executed_{0};
    std::atomic<std::uint32_t>                   catch_up_skips_{0};

    // Sub-skip jitter (§21.7 item 2 step 3). Written only by run() on
    // the tick thread; `sum_behind_ms_` is fetch_add per tick,
    // `max_behind_ms_` is a CAS high-water mark. Both read from any
    // thread via sumBehindMs() / maxBehindMs().
    std::atomic<std::uint64_t>                   sum_behind_ms_{0};
    std::atomic<std::uint32_t>                   max_behind_ms_{0};

    std::atomic<bool>                            running_{false};
};

} // namespace fh::sim::server
