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
    level_id_[0] = cfg.level_home_id;
    level_id_[1] = cfg.level_away_id;
    applyRosters();
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
        // Keeper flag from the formation spec (hands + angle play).
        const ai::FormationSpec& spec =
            home ? (cfg_.formation_home.valid(per_team) ? cfg_.formation_home
                                                        : ai::builtinFormation(per_team))
                 : (cfg_.formation_away.valid(per_team) ? cfg_.formation_away
                                                        : ai::builtinFormation(per_team));
        world_.setKeeper(i, spec.positions[k].keeper);
    }
}

void GameServer::applyRosters() {
    const std::uint8_t per_team = cfg_.slot_count / 2;
    slot_names_.assign(cfg_.slot_count, "");
    concept_ratings_.assign(cfg_.slot_count, core::ConceptRatings{});
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const persistence::DemoTeam& team =
            home ? cfg_.roster_home : cfg_.roster_away;
        const core::LevelParams& band =
            home ? cfg_.level_home : cfg_.level_away;
        core::ConceptRatings r = core::defaultRatings(band);
        if (k < team.players.size()) {
            const auto& p = team.players[k];
            slot_names_[i] = p.name;
            world_.setMaxSpeed(
                i, Fixed64::fromFraction(p.max_speed_cms, 100));
            // Legacy mask override → that player's known set at a strong
            // personal quality (85): Old Gio knows EVERYTHING well.
            if (p.concept_mask >= 0) {
                for (int c = 0; c < core::kConceptCount; ++c)
                    r[c] = (static_cast<std::uint32_t>(p.concept_mask) &
                            (1u << c))
                               ? 85
                               : 0;
            }
        } else {
            slot_names_[i] =
                (home ? "Home " : "Away ") + std::to_string(k + 1);
        }
        concept_ratings_[i] = r;
        brain_.setRatings(i, r);
    }
    // Teams WEAR their identity (mig 631): a roster naming a style preset
    // boots with it overlaid — Lighthouse XI plays the club game model
    // without an admin tapping it on.
    overlayTeamPreset(true);
    overlayTeamPreset(false);
}

void GameServer::overlayTeamPreset(bool home) {
    const persistence::DemoTeam& team =
        home ? cfg_.roster_home : cfg_.roster_away;
    if (team.style_preset.empty()) return;
    const persistence::StylePreset* preset = nullptr;
    for (const auto& p : cfg_.presets) {
        if (p.name == team.style_preset) { preset = &p; break; }
    }
    if (!preset) return;  // preset table missing the name: quietly none
    const std::uint8_t half = cfg_.slot_count / 2;
    const std::uint8_t from = home ? 0 : half;
    const std::uint8_t to = home ? half : cfg_.slot_count;
    for (std::uint8_t sl = from; sl < to; ++sl) {
        core::applyPresetOverlay(concept_ratings_[sl], preset->overlay);
        brain_.setRatings(sl, concept_ratings_[sl]);
    }
}

void GameServer::broadcastRoster() {
    RosterFrame rf;
    rf.slots.reserve(cfg_.slot_count);
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        RosterEntry e;
        e.name = slot_names_[i];
        e.ratings.assign(concept_ratings_[i].begin(),
                         concept_ratings_[i].end());
        rf.slots.push_back(std::move(e));
    }
    const Bytes frame = encodeFrame(FrameType::Roster, encodeRoster(rf));
    for (const auto& [cid, _] : clients_) transport_.send(cid, frame);
}

void GameServer::onConnect(ClientId id, const auth::JwtClaims& claims) {
    // Everyone plays + spectates; the club's admin-ish roles also get the
    // admin capability (live match settings). Same role set the club app's
    // role picker treats as admin.
    // Identity gate: the club mints role:"" into JWTs — real authz is the
    // users→admins chain, loaded at boot. The role-claim check remains as
    // a dev-token convenience.
    bool admin = false;
    for (const auto uid : cfg_.admin_user_ids) {
        if (uid == claims.person_id) { admin = true; break; }
    }
    admin = admin ||
        claims.role == "super" || claims.role == "admin" ||
        claims.role == "club" || claims.role == "system";
    if (admin) admins_.emplace(id, true);

    HelloFrame hello;
    hello.match_id = cfg_.match_id;
    hello.tick_rate = static_cast<std::uint8_t>(core::kTickRate);
    hello.capabilities = kCapPlayer | kCapSpectator |
                         (admin ? kCapAdmin : 0);
    hello.slot_count = cfg_.slot_count;
    hello.pitch_half_x = Fixed64::fromFraction(105, 2);  // 52.5 m
    hello.pitch_half_y = Fixed64::fromInt(cfg_.pitch_half_y);

    const Bytes frame = encodeFrame(FrameType::Hello, encodeHello(hello));
    transport_.send(id, frame);
    clients_.emplace(id, true);
    if (!cfg_.presets.empty()) {  // style-preset catalog (1.4, mig 630)
        PresetsFrame pf;
        for (const auto& p : cfg_.presets) pf.names.push_back(p.name);
        transport_.send(id, encodeFrame(FrameType::Presets,
                                        encodePresets(pf)));
    }
    broadcastRoster();  // names + knowledge for every client
}

void GameServer::onDisconnect(ClientId id) {
    clients_.erase(id);
    admins_.erase(id);
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
        case FrameType::MatchSettings: {
            // Admin-only: retune both teams' skill bands live. The world
            // and the brain update together; the seed stays, so the match
            // continues deterministically under the new config.
            if (!admins_.count(id)) return;
            const auto ms = decodeMatchSettings(frame.payload);
            if (!ms || ms->level_home >= core::kLevelCount ||
                ms->level_away >= core::kLevelCount)
                return;
            level_id_[0] = ms->level_home;
            level_id_[1] = ms->level_away;
            const auto home = core::levelParams(core::levelName(ms->level_home));
            const auto away = core::levelParams(core::levelName(ms->level_away));
            world_.setLevel(0, home);
            world_.setLevel(1, away);
            brain_.setLevels(home, away, world_.matchSeed());
            // Band change resets knowledge to the new bundles (names and
            // speeds stay — identity is the roster's, knowledge is the
            // band's unless re-edited).
            for (std::uint8_t sl = 0; sl < cfg_.slot_count; ++sl) {
                const core::LevelParams& b =
                    sl < cfg_.slot_count / 2 ? home : away;
                concept_ratings_[sl] = core::defaultRatings(b);
                brain_.setRatings(sl, concept_ratings_[sl]);
            }
            // A worn identity survives the band change (mig 631).
            overlayTeamPreset(true);
            overlayTeamPreset(false);
            broadcastRoster();
            return;
        }
        case FrameType::PlayerSettings: {
            // Admin-only: rewrite one player's knowledge live (the edit
            // screen). CONCEPTS.md bit ids; junk bits masked off.
            if (!admins_.count(id)) return;
            const auto ps = decodePlayerSettings(frame.payload);
            if (!ps || ps->slot >= cfg_.slot_count) return;
            core::ConceptRatings r{};
            for (std::size_t c = 0;
                 c < r.size() && c < ps->ratings.size(); ++c) {
                r[c] = ps->ratings[c] > 100 ? 100 : ps->ratings[c];
            }
            concept_ratings_[ps->slot] = r;
            brain_.setRatings(ps->slot, r);
            broadcastRoster();
            return;
        }
        case FrameType::ApplyPreset: {
            // Admin-only: paint one team's identity in one tap (mig 630).
            // The preset OVERLAYS only the dials it names onto every slot
            // of the team; unnamed concepts keep their current rating —
            // "Bielsa base + modifications" composes.
            if (!admins_.count(id)) return;
            const auto ap = decodeApplyPreset(frame.payload);
            if (!ap || ap->team > 1 || ap->preset_id >= cfg_.presets.size())
                return;
            const core::PresetOverlay& o =
                cfg_.presets[ap->preset_id].overlay;
            const std::uint8_t half = cfg_.slot_count / 2;
            const std::uint8_t from = ap->team == 0 ? 0 : half;
            const std::uint8_t to = ap->team == 0 ? half : cfg_.slot_count;
            for (std::uint8_t sl = from; sl < to; ++sl) {
                core::applyPresetOverlay(concept_ratings_[sl], o);
                brain_.setRatings(sl, concept_ratings_[sl]);
            }
            broadcastRoster();
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
    s.level_home = level_id_[0];
    s.level_away = level_id_[1];
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
