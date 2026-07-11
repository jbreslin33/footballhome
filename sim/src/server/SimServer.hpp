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

    // Ownership: SimServer takes over all three dependencies. Match must
    // already be constructed with a scenario (SimServer never spawns
    // scenarios itself; that's main.cpp / a factory).
    SimServer(Config cfg,
              std::unique_ptr<net::INetworkTransport>   transport,
              std::unique_ptr<net::ISnapshotSerializer> serializer,
              std::unique_ptr<match::Match>             match);

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

private:
    // Transport callbacks (bound in constructor).
    void handleConnect(ClientId cid, const auth::JwtClaims& claims);
    void handleDisconnect(ClientId cid);
    void handleMessage(ClientId cid, std::span<const std::uint8_t> bytes);

    // Assign the first unowned scenario slot to `cid`. Returns 0 if all
    // slots are taken (client stays connected as spectator).
    SlotId assignFreeSlot(ClientId cid);

    // Serialize match.snapshot() once and send the resulting bytes to
    // every mapped client.
    void broadcastSnapshot();

    Config                                       cfg_;
    std::unique_ptr<net::INetworkTransport>      transport_;
    std::unique_ptr<net::ISnapshotSerializer>    serializer_;
    std::unique_ptr<match::Match>                match_;

    // ClientId → SlotId. 0 = spectator (no slot assigned).
    std::unordered_map<ClientId, SlotId>         client_slot_;

    std::atomic<bool>                            running_{false};
};

} // namespace fh::sim::server
