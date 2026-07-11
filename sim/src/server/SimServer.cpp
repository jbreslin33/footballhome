// footballhome sim - SimServer implementation

#include "server/SimServer.hpp"

#include "controller/Intent.hpp"
#include "match/Slot.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "net/InputFrame.hpp"
#include "net/WireFormat.hpp"

#include <chrono>
#include <utility>

namespace fh::sim::server {

namespace {

std::int64_t steadyNowMsDefault() noexcept
{
    using namespace std::chrono;
    return duration_cast<milliseconds>(
        steady_clock::now().time_since_epoch()).count();
}

// Cast helper — hex here because -Wold-style-cast bans C casts and the
// value is a duration in milliseconds we only ever compare.
constexpr std::int64_t tickPeriodMs(std::uint32_t tick_hz) noexcept
{
    // tick_hz should be >= 1; callers enforce.
    return static_cast<std::int64_t>(1000u / (tick_hz == 0u ? 1u : tick_hz));
}

} // namespace

SimServer::SimServer(Config cfg,
                     std::unique_ptr<net::INetworkTransport>   transport,
                     std::unique_ptr<net::ISnapshotSerializer> serializer,
                     std::unique_ptr<match::Match>             match)
    : cfg_{cfg}
    , transport_{std::move(transport)}
    , serializer_{std::move(serializer)}
    , match_{std::move(match)}
{
    transport_->setOnConnect(
        [this](ClientId cid, const auth::JwtClaims& claims) {
            handleConnect(cid, claims);
        });
    transport_->setOnDisconnect(
        [this](ClientId cid) {
            handleDisconnect(cid);
        });
    transport_->setOnMessage(
        [this](ClientId cid, std::span<const std::uint8_t> bytes) {
            handleMessage(cid, bytes);
        });
}

void SimServer::run(std::function<std::int64_t()> steady_now_ms)
{
    if (!steady_now_ms) { steady_now_ms = &steadyNowMsDefault; }

    running_.store(true, std::memory_order_relaxed);

    const std::int64_t period_ms = tickPeriodMs(cfg_.tick_hz);
    std::int64_t       next_tick_at = steady_now_ms();

    while (running_.load(std::memory_order_relaxed)) {
        if (match_->ended()) { break; }

        const std::int64_t now = steady_now_ms();
        std::int64_t sleep_ms = next_tick_at - now;
        if (sleep_ms < 0) { sleep_ms = 0; }
        // poll() takes int; period_ms fits in int for any sane tick_hz.
        const int wait_ms = (sleep_ms > 1000) ? 1000 : static_cast<int>(sleep_ms);
        transport_->poll(wait_ms);

        if (steady_now_ms() < next_tick_at) { continue; }

        // Advance the sim and push the resulting snapshot to everyone.
        match_->tick();
        broadcastSnapshot();

        // Fixed-step: schedule the next tick strictly by cadence. If we
        // fell behind (a stall > 5 periods), jump forward instead of
        // trying to catch up in a tight loop — determinism matters more
        // than "never miss a tick" on M0.
        next_tick_at += period_ms;
        const std::int64_t after = steady_now_ms();
        if (next_tick_at + (period_ms * 5) < after) {
            next_tick_at = after;
        }
    }
}

void SimServer::tickOnceForTest()
{
    match_->tick();
    broadcastSnapshot();
}

// ---------------------------------------------------------------------------
// Transport callbacks
// ---------------------------------------------------------------------------

void SimServer::handleConnect(ClientId cid, const auth::JwtClaims& /*claims*/)
{
    // Idempotent: if a stale entry exists for this client (shouldn't, but
    // protect against transport bugs) release the old slot first.
    const auto existing = client_slot_.find(cid);
    if (existing != client_slot_.end()) {
        if (existing->second != 0u) { match_->releaseSlot(existing->second); }
        client_slot_.erase(existing);
    }

    const SlotId slot = assignFreeSlot(cid);   // 0 => spectator
    client_slot_.emplace(cid, slot);

    const auto ack = net::encodeHelloAckFrame(cfg_.match_id, slot, cfg_.tick_hz);
    (void)transport_->send(cid, ack);
}

void SimServer::handleDisconnect(ClientId cid)
{
    const auto it = client_slot_.find(cid);
    if (it == client_slot_.end()) { return; }

    if (it->second != 0u) {
        match_->releaseSlot(it->second);
    }
    client_slot_.erase(it);
}

void SimServer::handleMessage(ClientId cid, std::span<const std::uint8_t> bytes)
{
    // Peek at msg_type without doing a full decode; unknown types are
    // silently dropped per §7 (forward-compat for M1+).
    if (bytes.size() < net::kFrameHeaderBytes) { return; }
    if (bytes[0] != net::kWireVersionV1)       { return; }

    switch (static_cast<net::MsgType>(bytes[1])) {
        case net::MsgType::Input: {
            const auto di = net::decodeInputFrame(bytes);
            if (!di) { return; }                       // malformed → drop

            // f32 → Fixed64 conversion happens right here at the wire
            // boundary. Downstream (Match / mechanics / controller)
            // sees only fixed-point.
            controller::Intent intent;
            intent.desired_direction = math::Vec3{
                math::Fixed64::fromFloat(di->desired_dir_x),
                math::Fixed64::fromFloat(di->desired_dir_y),
                math::Fixed64::zero()
            };
            intent.wants_sprint = di->wants_sprint;
            intent.wants_walk   = di->wants_walk;
            match_->applyInput(cid, intent);
            return;
        }
        // Slot claim/release, hello, ping, pong: not yet wired for M0.
        // They arrive on the wire but SimServer ignores them; PING/PONG
        // are already handled inside the transport as WebSocket control
        // frames, so app-level 0x50/0x51 are unused in M0.
        default:
            return;
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SlotId SimServer::assignFreeSlot(ClientId cid)
{
    for (const auto& slot : match_->slots()) {
        if (!slot.owner.has_value()) {
            match_->claimSlot(slot.slot_id, cid);
            return slot.slot_id;
        }
    }
    return 0;   // no free slot; client stays as spectator
}

void SimServer::broadcastSnapshot()
{
    if (client_slot_.empty()) { return; }

    const auto bytes = serializer_->serialize(match_->snapshot());
    if (bytes.empty()) { return; }

    for (const auto& [cid, _slot] : client_slot_) {
        (void)transport_->send(cid, bytes);
    }
}

} // namespace fh::sim::server
