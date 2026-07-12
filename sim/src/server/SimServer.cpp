// footballhome sim - SimServer implementation

#include "server/SimServer.hpp"

#include "controller/Intent.hpp"
#include "match/Slot.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"
#include "net/InputFrame.hpp"
#include "net/WireFormat.hpp"
#include "persistence/IPgClient.hpp"

#include <chrono>
#include <cstdio>
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
                     std::unique_ptr<match::Match>             match,
                     persistence::ProfileStore*                profile_store,
                     persistence::InputLog*                    input_log,
                     persistence::EventLog*                    event_log)
    : cfg_{cfg}
    , transport_{std::move(transport)}
    , serializer_{std::move(serializer)}
    , match_{std::move(match)}
    , profile_store_{profile_store}
    , input_log_{input_log}
    , event_log_{event_log}
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

void SimServer::handleConnect(ClientId cid, const auth::JwtClaims& claims)
{
    // Idempotent: if a stale entry exists for this client (shouldn't, but
    // protect against transport bugs) release the old slot first.
    const auto existing = client_slot_.find(cid);
    if (existing != client_slot_.end()) {
        if (existing->second != 0u) { match_->releaseSlot(existing->second); }
        client_slot_.erase(existing);
    }

    // Resolve identity + profile before touching the match. If the DB is
    // unreachable mid-match, this new client degrades to spectator (slot
    // 0) rather than crashing the whole match for other players. Boot-
    // time DB failures are caught in main() and abort the process; this
    // path handles transient mid-match blips only (§16.6, §22.12).
    const PersonId person = static_cast<PersonId>(claims.person_id);
    SlotId slot = 0;
    if (profile_store_ != nullptr) {
        try {
            auto profile = profile_store_->loadOrCreate(person);
            slot = assignFreeSlot(cid, person, std::move(profile));
        } catch (const persistence::PgError& e) {
            std::fprintf(stderr,
                         "sim: profile load failed for person=%llu (%s: %s); "
                         "degrading connection to spectator\n",
                         static_cast<unsigned long long>(person),
                         e.context().c_str(),
                         e.what());
            slot = 0;
        }
    }
    client_slot_.emplace(cid, slot);

    // Event log (§16.6 task 8): ClientConnect is unconditional; SlotClaim
    // only when a real slot (>0) was assigned. Both carry no payload in
    // M0 — the tick_num on the row + event_type + row order is enough
    // for replay tooling to reconstruct ownership. Payload versioning
    // (§21.1 outstanding ship-blocker) will land alongside the M1+ event
    // schema; safe to leave nullopt until then since M0 replay is
    // driven off sim_match_inputs.slot_id directly.
    if (event_log_ != nullptr) {
        persistence::EventRow ev;
        ev.match_id   = cfg_.match_id;
        ev.tick_num   = match_->tick_num();
        ev.event_type = persistence::EventType::ClientConnect;
        event_log_->push(std::move(ev));

        if (slot != 0u) {
            persistence::EventRow claim;
            claim.match_id   = cfg_.match_id;
            claim.tick_num   = match_->tick_num();
            claim.event_type = persistence::EventType::SlotClaim;
            event_log_->push(std::move(claim));
        }
    }

    const auto ack = net::encodeHelloAckFrame(cfg_.match_id, slot, cfg_.tick_hz);
    (void)transport_->send(cid, ack);
}

void SimServer::handleDisconnect(ClientId cid)
{
    const auto it = client_slot_.find(cid);
    if (it == client_slot_.end()) { return; }

    // Event log ordering (§16.6 task 8): SlotRelease (if any) BEFORE
    // ClientDisconnect so replay sees "slot freed, then peer left" —
    // matches the semantic causality even though both land in the same
    // tick.
    if (event_log_ != nullptr) {
        if (it->second != 0u) {
            persistence::EventRow rel;
            rel.match_id   = cfg_.match_id;
            rel.tick_num   = match_->tick_num();
            rel.event_type = persistence::EventType::SlotRelease;
            event_log_->push(std::move(rel));
        }
        persistence::EventRow dc;
        dc.match_id   = cfg_.match_id;
        dc.tick_num   = match_->tick_num();
        dc.event_type = persistence::EventType::ClientDisconnect;
        event_log_->push(std::move(dc));
    }

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

            // Input log (§16.6 task 8): record the accepted wire frame
            // for deterministic replay. Only mapped clients with a real
            // slot (>0) reach here in the intended path; spectator-only
            // clients would be rejected upstream by Match::applyInput
            // (findSlotByOwner miss) so a log row with slot=0 is
            // meaningless. Log the wire bytes verbatim — Match already
            // saw the same bytes translated to Intent, so replay's
            // Match sees the identical Intent after the same decode.
            if (input_log_ != nullptr) {
                const auto slot_it = client_slot_.find(cid);
                if (slot_it != client_slot_.end() && slot_it->second != 0u) {
                    persistence::InputRow row;
                    row.match_id = cfg_.match_id;
                    row.tick_num = match_->tick_num();
                    row.slot_id  = slot_it->second;
                    const auto byte_span = std::as_bytes(bytes);
                    row.payload.assign(byte_span.begin(), byte_span.end());
                    input_log_->push(std::move(row));
                }
            }
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

SlotId SimServer::assignFreeSlot(ClientId cid,
                                 PersonId person,
                                 profile::PlayerProfile profile)
{
    for (const auto& slot : match_->slots()) {
        if (!slot.owner.has_value()) {
            match_->claimSlot(slot.slot_id, cid, person, std::move(profile));
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
