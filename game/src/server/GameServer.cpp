// game/src/server/GameServer.cpp

#include "server/GameServer.hpp"

#include "net/Wire.hpp"

#include <cstdio>

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
    skills_ = core::SkillSet(cfg.model_params);   // G4.33: DB numbers
    brain_.setModelParams(cfg.model_params);
    world_.setLevel(0, cfg.level_home);
    world_.setLevel(1, cfg.level_away);
    world_.setMatchSeed(cfg.match_seed);
    brain_.setLevels(cfg.level_home, cfg.level_away, cfg.match_seed);
    level_id_[0] = cfg.level_home_id;
    level_id_[1] = cfg.level_away_id;
    applyRosters();
    applySlotLevels();
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

void GameServer::applySlotLevels() {
    const std::uint8_t per_team = cfg_.slot_count / 2;
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const persistence::DemoTeam& team =
            home ? cfg_.roster_home : cfg_.roster_away;
        if (k >= team.players.size()) continue;
        const core::LevelParams lv = skills_.apply(
            world_.level(home ? 0 : 1), team.players[k].attrs);
        world_.setSlotLevel(i, lv);
        brain_.setSlotLevel(i, lv);
    }
}

void GameServer::applyRosters() {
    const std::uint8_t per_team = cfg_.slot_count / 2;
    slot_names_.assign(cfg_.slot_count, "");
    concept_ratings_.assign(cfg_.slot_count, core::ConceptRatings{});
    ability_.assign(cfg_.slot_count, core::ConceptRatings{});
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const persistence::DemoTeam& team =
            home ? cfg_.roster_home : cfg_.roster_away;
        if (k < team.players.size()) {
            const auto& p = team.players[k];
            slot_names_[i] = p.name;
            // Pace (mig 636) sets top speed when rated; else the row's
            // max_speed_cms as before.
            const std::int32_t cms = p.attrs.pace >= 0
                                         ? skills_.speedCms(p.attrs.pace)
                                         : p.max_speed_cms;
            world_.setMaxSpeed(i, Fixed64::fromFraction(cms, 100));
        } else {
            slot_names_[i] =
                (home ? "Home " : "Away ") + std::to_string(k + 1);
        }
        ability_[i] = buildAbility(i, home ? cfg_.level_home : cfg_.level_away);
    }
    // Teams PLAY their game model (mig 652; were worn presets, mig 631).
    for (int side = 0; side < 2; ++side) {
        const std::string& want = side == 0 ? cfg_.roster_home.game_model
                                            : cfg_.roster_away.game_model;
        team_model_[side] = -1;
        for (std::size_t m = 0; m < cfg_.models.size(); ++m)
            if (!want.empty() && cfg_.models[m].name == want) team_model_[side] = static_cast<int>(m);
    }
    recomputeKnowledge(true);
    recomputeKnowledge(false);
}

core::ConceptRatings GameServer::buildAbility(std::uint8_t sl, const core::LevelParams& band) const {
    const std::uint8_t per_team = cfg_.slot_count / 2;
    const bool home = sl < per_team;
    const std::uint8_t k = home ? sl : sl - per_team;
    const persistence::DemoTeam& team = home ? cfg_.roster_home : cfg_.roster_away;
    // Mig 656: his own quality, else his team's, else the band's.
    const int quality = k < team.players.size() && team.players[k].quality >= 0
                            ? team.players[k].quality : team.quality;
    core::ConceptRatings r = core::defaultAbility(band, quality);
    if (k >= team.players.size()) return r;
    const auto& p = team.players[k];
    // Legacy mask override → that player's known set at a strong personal
    // quality (85): Old Gio knows EVERYTHING well. (The mask only ever
    // covered ids 0-31.)
    if (p.concept_mask >= 0) {
        const int n = core::concepts().size();
        for (int c = 0; c < n; ++c)
            r[c] = (c < 32 && (static_cast<std::uint32_t>(p.concept_mask) & (1u << c))) ? 85 : 0;
    }
    // Mig 639: the player's own ability rows (his role: the free centre
    // back knows the libero's job; nobody else does).
    for (const auto& [idx, v] : p.concepts)
        if (idx >= 0 && idx < core::concepts().size()) r[idx] = v;
    return r;
}

void GameServer::recomputeKnowledge(bool home) {
    core::PresetOverlay none;
    none.fill(-1);
    const int m = team_model_[home ? 0 : 1];
    const core::PresetOverlay& demand = m >= 0 ? cfg_.models[m].overlay : none;
    const std::uint8_t half = cfg_.slot_count / 2;
    const std::uint8_t from = home ? 0 : half;
    const std::uint8_t to = home ? half : cfg_.slot_count;
    for (std::uint8_t sl = from; sl < to; ++sl) {
        concept_ratings_[sl] = core::effectiveRatings(ability_[sl], demand);
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
                         concept_ratings_[i].begin() + core::concepts().size());
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
    {  // G4.37 (1.6): the curriculum's names, index = concept id (a hole
       // is ""). Same name-list layout as PRESETS.
        PresetsFrame cf;
        const core::ConceptRegistry& reg = core::concepts();
        for (int i = 0; i < reg.size(); ++i) cf.names.push_back(reg.name(i));
        transport_.send(id, encodeFrame(FrameType::Concepts, encodePresets(cf)));
    }
    if (!cfg_.models.empty()) {  // game-model catalog (1.4 PRESETS frame)
        PresetsFrame pf;
        for (const auto& m : cfg_.models) pf.names.push_back(m.name);
        transport_.send(id, encodeFrame(FrameType::Presets,
                                        encodePresets(pf)));
    }
    {  // G4.41 (1.7): the brain overlay's decision names, index = why code.
        PresetsFrame lf;
        for (int i = 0; i < ai::kWhyCount; ++i) lf.names.push_back(ai::kWhyNames[i]);
        transport_.send(id, encodeFrame(FrameType::BrainLegend, encodePresets(lf)));
    }
    // G4.30: which teams are playing — the editor's key into the club API.
    sendTeams(id);
    broadcastRoster();  // names + knowledge for every client
}

namespace {
TeamsFrame teamsFrame(const persistence::DemoTeam& home, const persistence::DemoTeam& away) {
    TeamsFrame tf;
    tf.home = home.name;
    tf.away = away.name;
    const persistence::DemoTeam* tt[2] = {&home, &away};
    for (int t = 0; t < 2; ++t) {   // mig 639 kits
        tf.kit[t][0] = tt[t]->kit_shirt;
        tf.kit[t][1] = tt[t]->kit_shorts;
        tf.kit[t][2] = tt[t]->kit_socks;
        tf.kit[t][3] = tt[t]->kit_trim;
    }
    return tf;
}
}  // namespace

void GameServer::sendTeams(ClientId id) {
    transport_.send(id, encodeFrame(FrameType::Teams,
                                    encodeTeams(teamsFrame(cfg_.roster_home, cfg_.roster_away))));
}

void GameServer::broadcastTeams() {
    const Bytes frame = encodeFrame(FrameType::Teams,
                                    encodeTeams(teamsFrame(cfg_.roster_home, cfg_.roster_away)));
    for (const auto& [cid, _] : clients_) transport_.send(cid, frame);
}

void GameServer::onDisconnect(ClientId id) {
    clients_.erase(id);
    admins_.erase(id);
    brain_watchers_.erase(id);
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
            applySlotLevels();   // attributes bend the NEW band
            // Band change: every player's ABILITY follows the new band (his
            // own rows stay on top); the team keeps its game model.
            for (std::uint8_t sl = 0; sl < cfg_.slot_count; ++sl)
                ability_[sl] = buildAbility(sl, sl < cfg_.slot_count / 2 ? home : away);
            recomputeKnowledge(true);
            recomputeKnowledge(false);
            broadcastRoster();
            return;
        }
        case FrameType::PlayerSettings: {
            // Admin-only: rewrite one player's knowledge live (the edit
            // screen). Curriculum ids (game_concepts); extras ignored.
            if (!admins_.count(id)) return;
            const auto ps = decodePlayerSettings(frame.payload);
            if (!ps || ps->slot >= cfg_.slot_count) return;
            core::ConceptRatings r{};
            const std::size_t n = static_cast<std::size_t>(core::concepts().size());
            for (std::size_t c = 0;
                 c < n && c < ps->ratings.size(); ++c) {
                r[c] = ps->ratings[c] > 100 ? 100 : ps->ratings[c];
            }
            concept_ratings_[ps->slot] = r;
            brain_.setRatings(ps->slot, r);
            broadcastRoster();
            return;
        }
        case FrameType::PlayerAttributes: {
            // Admin-only (G4.30): one rostered player's attributes, live —
            // the editor saves them to the club DB (boot reads them there)
            // and sends them here so the running match uses them now.
            if (!admins_.count(id)) return;
            const auto pa = decodePlayerAttributes(frame.payload);
            if (!pa || pa->slot >= cfg_.slot_count) return;
            const std::uint8_t per_team = cfg_.slot_count / 2;
            const bool home = pa->slot < per_team;
            const std::uint8_t k = home ? pa->slot : pa->slot - per_team;
            persistence::DemoTeam& team = home ? cfg_.roster_home : cfg_.roster_away;
            if (k >= team.players.size()) return;
            core::PlayerAttributes& a = team.players[k].attrs;
            for (int i = 0; i < core::kAttributeCount &&
                            i < static_cast<int>(pa->ratings.size()); ++i) {
                const std::uint8_t v = pa->ratings[i];
                *core::attributeAt(a, i) =
                    v == 255 ? std::int16_t{-1} : std::int16_t(v > 100 ? 100 : v);
            }
            const std::int32_t cms = a.pace >= 0 ? skills_.speedCms(a.pace)
                                                 : team.players[k].max_speed_cms;
            world_.setMaxSpeed(pa->slot, Fixed64::fromFraction(cms, 100));
            const core::LevelParams lv =
                skills_.apply(world_.level(home ? 0 : 1), a);
            world_.setSlotLevel(pa->slot, lv);
            brain_.setSlotLevel(pa->slot, lv);
            return;
        }
        case FrameType::BrainWatch: {
            // G4.41: anyone may watch the brains — it's a teaching tool.
            const auto bw = decodeBrainWatch(frame.payload);
            if (!bw) return;
            if (bw->on) {
                brain_watchers_[id] = true;
                if (!last_orders_.empty()) sendBrain();
            } else {
                brain_watchers_.erase(id);
            }
            return;
        }
        case FrameType::ReloadRosters: {
            // Admin-only (G4.32): re-read both teams from the club DB —
            // the page saved a lineup / attributes / roles / kit there.
            // Config load between ticks, not sim-loop DB access: a failed
            // load keeps the team as it is. Formations stay (Brain shape).
            if (!admins_.count(id) || !cfg_.db) return;
            for (persistence::DemoTeam* team : {&cfg_.roster_home, &cfg_.roster_away}) {
                if (team->name.empty()) continue;
                if (auto t = persistence::loadDemoTeam(*cfg_.db, team->name)) {
                    t->formation_code = team->formation_code;
                    *team = std::move(*t);
                }
            }
            applyRosters();
            applySlotLevels();
            broadcastTeams();
            broadcastRoster();
            std::printf("fh-game: rosters reloaded from the club DB\n");
            return;
        }
        case FrameType::ApplyPreset: {
            // Admin-only: switch one team to another game model in one tap
            // (mig 652; the wire still calls it a preset). Players keep
            // their ability; the demand changes, so they play
            // min(new demand, ability).
            if (!admins_.count(id)) return;
            const auto ap = decodeApplyPreset(frame.payload);
            if (!ap || ap->team > 1 || ap->preset_id >= cfg_.models.size())
                return;
            // The team now plays that model: its demand, their ability.
            team_model_[ap->team] = ap->preset_id;
            recomputeKnowledge(ap->team == 0);
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
        // bit0 human-controlled; bit1 keeper (1.4 additive — clients
        // dress keepers in their own kit).
        // bit2 down in a tackle; bit3 dispossessed / off balance (G4.27,
        // so the client can animate slides and stumbles).
        snap.flags = static_cast<std::uint8_t>(
            (slot_owner_.count(i) ? 1 : 0) | (world_.isKeeper(i) ? 2 : 0) |
            (p.recovery_kind == 1 ? 4 : 0) | (p.recovery_kind == 2 ? 8 : 0));
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
    if (last_orders_.size() != cfg_.slot_count) last_orders_.assign(cfg_.slot_count, ai::Orders{});
    for (std::uint8_t slot = 0; slot < cfg_.slot_count; ++slot) {
        if (slot_owner_.count(slot)) {
            last_orders_[slot] = ai::Orders{};
            last_orders_[slot].why = ai::Why::Human;
            continue;
        }
        const ai::Orders o = brain_.ordersFor(slot, world_);
        last_orders_[slot] = o;
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
    // The brain overlay at ~5 Hz, only to clients that switched it on.
    if (!brain_watchers_.empty() && world_.tickCount() % 6 == 0) sendBrain();
}

void GameServer::sendBrain() {
    BrainFrame bf;
    bf.slots.reserve(last_orders_.size());
    auto dm = [](Fixed64 v) {
        const std::int64_t d = (v * Fixed64::fromInt(10)).raw >> Fixed64::FRAC_BITS;
        return static_cast<std::int16_t>(d < -32000 ? -32000 : (d > 32000 ? 32000 : d));
    };
    for (const ai::Orders& o : last_orders_) {
        BrainEntry e;
        e.why = static_cast<std::uint8_t>(o.why);
        e.target_dm_x = dm(o.target.x);
        e.target_dm_y = dm(o.target.y);
        e.other = o.other >= 0 && o.other < 255 ? static_cast<std::uint8_t>(o.other) : 255;
        e.rung = o.rung;
        bf.slots.push_back(e);
    }
    const Bytes frame = encodeFrame(FrameType::Brain, encodeBrain(bf));
    for (const auto& [id, _] : brain_watchers_) transport_.send(id, frame);
}

bool GameServer::slotClaimedBy(std::uint8_t slot, ClientId client) const {
    auto it = slot_owner_.find(slot);
    return it != slot_owner_.end() && it->second == client;
}

}  // namespace fh::game::server
