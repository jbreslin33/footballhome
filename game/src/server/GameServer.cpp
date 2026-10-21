// game/src/server/GameServer.cpp

#include "server/GameServer.hpp"

#include "net/Wire.hpp"

namespace fh::game::server {

using math::Fixed64;
using namespace net;

GameServer::GameServer(Config cfg, INetworkTransport& transport)
    : cfg_{cfg},
      transport_{transport},
      world_{cfg.slot_count, Fixed64::fromInt(cfg.max_speed_mps),
             Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg.pitch_half_y),
             cfg.half_length_ticks},
      brain_{ai::TeamSetup::splitHalves(cfg.slot_count),
             Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg.pitch_half_y),
             cfg.formation_home, cfg.formation_away} {
    world_.setLevel(0, cfg.level_home);
    world_.setLevel(1, cfg.level_away);
    world_.setMatchSeed(cfg.match_seed);
    brain_.setLevels(cfg.level_home, cfg.level_away, cfg.match_seed);
    transport_.setOnConnect(
        [this](ClientId id, const auth::JwtClaims& c) { onConnect(id, c); });
    transport_.setOnDisconnect([this](ClientId id) { onDisconnect(id); });
    transport_.setOnMessage(
        [this](ClientId id, std::span<const std::uint8_t> b) {
            onMessage(id, b);
        });

    // G0 spawn: two facing 11-column lines, home (first half of slots) in
    // the west half, away mirrored east — enough to see and pick every
    // player. Real formation anchoring replaces this in G2 [HELIOS].
    const auto n = cfg_.slot_count;
    const std::uint8_t per_team = n / 2;
    for (std::uint8_t i = 0; i < n; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        // y spreads players across the width: -25..+25 m.
        const Fixed64 y = per_team > 1
            ? Fixed64::fromInt(-25) +
                  Fixed64::fromInt(50) * Fixed64::fromFraction(k, per_team - 1)
            : Fixed64::zero();
        const Fixed64 x = Fixed64::fromInt(home ? -15 : 15);
        // Face the opponent goal: home attacks +x, away attacks -x.
        const math::Vec2 face{home ? Fixed64::one() : -Fixed64::one(),
                              Fixed64::zero()};
        world_.placePlayer(i, math::Vec3{x, y, Fixed64::zero()}, face);
        world_.setTeam(i, home ? 0 : 1);
    }
}

void GameServer::onConnect(ClientId id, const auth::JwtClaims& /*claims*/) {
    // G0: everyone is player+spectator. Capability differentiation (manager,
    // admin) keys off claims + match config from G5 (PROTOCOL.md §3).
    HelloFrame hello;
    hello.match_id = cfg_.match_id;
    hello.tick_rate = static_cast<std::uint8_t>(core::kTickRate);
    hello.capabilities = kCapPlayer | kCapSpectator;
    hello.slot_count = cfg_.slot_count;
    hello.pitch_half_x = Fixed64::fromFraction(105, 2);  // 52.5 m
    hello.pitch_half_y = Fixed64::fromInt(cfg_.pitch_half_y);

    const Bytes frame = encodeFrame(FrameType::Hello, encodeHello(hello));
    transport_.send(id, frame);
    clients_.emplace(id, true);
}

void GameServer::onDisconnect(ClientId id) {
    clients_.erase(id);
    // Release every slot the departing client held; those players revert to
    // idle (AI controllers take them over from G2 on).
    for (auto it = slot_owner_.begin(); it != slot_owner_.end();) {
        if (it->second == id) it = slot_owner_.erase(it);
        else ++it;
    }
}

void GameServer::onMessage(ClientId id, std::span<const std::uint8_t> bytes) {
    // One WebSocket message may carry several fh-game frames back to back.
    std::size_t at = 0;
    while (at < bytes.size()) {
        std::size_t consumed = 0;
        auto frame = decodeFrame(bytes.data() + at, bytes.size() - at,
                                 consumed);
        if (!frame) return;  // malformed/truncated tail: drop the rest
        handleFrame(id, *frame);
        at += consumed;
    }
}

void GameServer::handleFrame(ClientId id, const DecodedFrame& frame) {
    switch (frame.type) {
        case FrameType::Claim: {
            const auto c = decodeClaim(frame.payload);
            if (!c || c->slot >= cfg_.slot_count) return;
            if (c->claim) {
                // First claimant wins; re-claim by the same client is a no-op.
                slot_owner_.try_emplace(c->slot, id);
            } else {
                auto it = slot_owner_.find(c->slot);
                if (it != slot_owner_.end() && it->second == id)
                    slot_owner_.erase(it);
            }
            return;
        }
        case FrameType::PlayerIntent: {
            const auto p = decodePlayerIntent(frame.payload);
            if (!p) return;
            // Only the slot's owner may drive it — the frame's slot field
            // is a request, never a fact.
            auto it = slot_owner_.find(p->slot);
            if (it == slot_owner_.end() || it->second != id) return;
            core::MoveIntent intent;
            intent.move = math::Vec2{p->move_x, p->move_y};
            world_.setIntent(p->slot, intent);
            if (p->action != 0) {
                world_.setAction(p->slot,
                                 static_cast<core::Action>(p->action));
            }
            return;
        }
        default:
            return;  // unknown/unexpected types ignored (PROTOCOL.md §9)
    }
}

net::Bytes GameServer::buildSnapshotFrame() const {
    SnapshotFrame s;
    s.tick = world_.tickCount();
    s.players.reserve(cfg_.slot_count);
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        const core::PlayerState& p = world_.player(i);
        PlayerSnap snap;
        snap.pos_x = p.pos.x;
        snap.pos_y = p.pos.y;
        snap.vel_x = p.vel.x;
        snap.vel_y = p.vel.y;
        snap.flags = slot_owner_.count(i) ? 1 : 0;
        s.players.push_back(snap);
    }
    const core::BallState& b = world_.ball();
    s.ball.pos_x = b.pos.x;
    s.ball.pos_y = b.pos.y;
    s.ball.pos_z = b.pos.z;
    s.ball.owner = b.owner ? *b.owner : 0xFF;
    s.score0 = world_.score(0);
    s.score1 = world_.score(1);
    s.period = world_.period();
    s.clock_ticks = world_.matchClockTicks();
    s.restart_team = world_.restartTeam();
    return encodeFrame(FrameType::Snapshot, encodeSnapshot(s));
}

void GameServer::tickOnce() {
    // AI drives every slot no human holds (claims always override; a
    // released slot reverts to its brain next tick).
    for (std::uint8_t slot = 0; slot < cfg_.slot_count; ++slot) {
        if (slot_owner_.count(slot)) continue;
        const ai::Orders o = brain_.ordersFor(slot, world_);
        world_.setIntent(slot, o.move);
        if (o.action != core::Action::None) world_.setAction(slot, o.action);
    }

    const auto match_events = world_.tick();
    if (clients_.empty()) return;  // headless idle: nothing to fan out

    for (const core::MatchEvent& e : match_events) {
        EventFrame ev;
        ev.event_type = static_cast<std::uint8_t>(e.type);
        ev.team = e.team;
        ev.tick = world_.tickCount();
        const Bytes frame = encodeFrame(FrameType::Event, encodeEvent(ev));
        for (const auto& [id, _] : clients_) transport_.send(id, frame);
    }

    const Bytes frame = buildSnapshotFrame();
    for (const auto& [id, _] : clients_) transport_.send(id, frame);
}

bool GameServer::slotClaimedBy(std::uint8_t slot, ClientId client) const {
    auto it = slot_owner_.find(slot);
    return it != slot_owner_.end() && it->second == client;
}

}  // namespace fh::game::server
