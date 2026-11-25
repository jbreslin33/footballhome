// game/src/server/GameServer.cpp
//
// G5.23 (DESIGN §8.121): the match daemon, slimmed to what the clean game is —
// claims, human intents, the brain overlay, an admin's roster reload and sim
// speed, the officials, snapshots and events. Gone with the old brain: levels
// and MATCH_SETTINGS, per-player ratings / attributes and their edits, game
// models, demands and params (PRESETS, CONCEPTS, DEMANDS, PARAMS frames),
// phases of play (RUN_PHASE) and the corner / phase shapes.

#include "server/GameServer.hpp"
#include "server/Kits.hpp"

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
    transport_.setOnConnect(
        [this](ClientId id, const auth::JwtClaims& c) { onConnect(id, c); });
    transport_.setOnDisconnect([this](ClientId id) { onDisconnect(id); });
    transport_.setOnMessage(
        [this](ClientId id, std::span<const std::uint8_t> b) {
            onMessage(id, b);
        });
    // Tactics trainer step 1: ai::Act codes → the game_concepts rows they play (mig 1199).
    for (auto& c : act_concept_) c = 255;
    for (const auto& a : cfg_.acts) {
        if (a.concept_id < 0 || a.concept_id > 254) continue;
        for (int i = 1; i < ai::kActCount; ++i)
            if (a.code == ai::kActCodes[i]) act_concept_[i] = static_cast<std::uint8_t>(a.concept_id);
        bool have = false;
        for (const auto& e : concept_legend_.entries) have = have || e.id == a.concept_id;
        if (!have) concept_legend_.entries.push_back({static_cast<std::uint8_t>(a.concept_id), a.name, a.title});
    }

    startMatch();
    if (cfg_.practice) practiceStart();
}

// G5.35: the match from cfg_ — a fresh World and Brain on its formations
// and rosters, everyone on the spawn lines. The constructor and NEW_MATCH.
void GameServer::startMatch() {
    world_ = core::World{cfg_.slot_count, Fixed64::fromInt(cfg_.max_speed_mps),
                         Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg_.pitch_half_y),
                         cfg_.half_length_ticks};
    brain_ = ai::Brain{ai::TeamSetup::splitHalves(cfg_.slot_count),
                       Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg_.pitch_half_y),
                       cfg_.formation_home, cfg_.formation_away};
    world_.setLocomotion(core::Locomotion(cfg_.model_params));   // G4.51
    world_.setFootsteps(core::Footsteps(cfg_.model_params));     // G5.77
    world_.setBallFlight(core::BallFlight(cfg_.model_params));   // G4.87
    brain_.setModelParams(cfg_.model_params);
    world_.setMatchSeed(cfg_.match_seed);
    brain_.setMatchSeed(cfg_.match_seed);
    {   // G5.23: every player's skill, league-wide (physics.skill.*)
        core::PlayerSkill k;
        k.configure(cfg_.model_params);
        world_.setSkillAll(k);
    }
    applyRosters();
    // The officials (G4.88): their own judgement numbers; body and speed the
    // default (6.4 m/s, the old 50-rated official's).
    world_.officials().configure(cfg_.model_params);
    world_.configureAerial(cfg_.model_params);   // G5.3
    world_.configureTempo(cfg_.model_params);    // G5.4
    world_.configureDribble(cfg_.model_params);  // G5.78
    world_.configureKicks(cfg_.model_params);    // G5.79
    world_.configureFouls(cfg_.model_params);    // G5.28
    for (const auto& m : cfg_.crew) {
        auto rating = [&](const char* code) -> std::int16_t {
            const auto it = m.ratings.find(code);
            return it == m.ratings.end() ? std::int16_t{-1} : static_cast<std::int16_t>(it->second);
        };
        core::OfficialRatings r;
        r.pace = rating("pace");
        r.acceleration = rating("acceleration");
        r.positioning = rating("positioning");
        r.offside_judgement = rating("offside_judgement");
        world_.officials().setOfficial(static_cast<core::OfficialRole>(m.role), r, core::Body{},
                                       Fixed64::fromFraction(640, 100));
    }
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
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const persistence::DemoTeam& team = home ? cfg_.roster_home : cfg_.roster_away;
        if (k < team.players.size()) {
            slot_names_[i] = team.players[k].name;
            if (team.players[k].max_speed_cms > 0)
                world_.setMaxSpeed(i, Fixed64::fromFraction(team.players[k].max_speed_cms, 100));
        } else {
            slot_names_[i] = (home ? "Home " : "Away ") + std::to_string(k + 1);
        }
    }
}

void GameServer::broadcastRoster() {
    RosterFrame rf;
    rf.slots.reserve(cfg_.slot_count);
    for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
        RosterEntry e;
        e.name = slot_names_[i];
        rf.slots.push_back(std::move(e));
        rf.numbers.push_back(static_cast<std::uint8_t>(brain_.numberOf(i)));   // 1.17
    }
    {   // 2.11: the formation each side plays and each man's place in it (label, role) — slot k of a
        // side is position k of its spec, as setupPlayers places them.
        const std::uint8_t per_team = cfg_.slot_count / 2;
        const ai::FormationSpec* sp[2] = {&cfg_.formation_home, &cfg_.formation_away};
        for (int t = 0; t < 2; ++t) rf.formation[t] = sp[t]->valid(per_team) ? sp[t]->code : std::string{};
        for (std::uint8_t i = 0; i < cfg_.slot_count; ++i) {
            const int t = i < per_team ? 0 : 1;
            const std::uint8_t k = t == 0 ? i : i - per_team;
            const bool ok = sp[t]->valid(per_team);
            rf.labels.push_back(ok ? sp[t]->positions[k].label : std::string{});
            rf.roles.push_back(ok ? sp[t]->positions[k].role : std::string{});
        }
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
    admin = admin || cfg_.practice;   // a practice room is its viewer's own (Rooms.hpp)
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
    // G4.61 (1.10): the sim speed, so a late joiner's clock runs at it.
    transport_.send(id, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{speed_pct_})));
    {  // G4.41 (1.7): the brain overlay's decision names, index = why code.
        NamesFrame lf;
        for (int i = 0; i < ai::kWhyCount; ++i) lf.names.push_back(ai::kWhyNames[i]);
        transport_.send(id, encodeFrame(FrameType::BrainLegend, encodeNames(lf)));
    }
    // 2.2: the trainer's labels — the concepts the BRAIN feed names (mig 1199).
    transport_.send(id, encodeFrame(FrameType::ConceptLegend, encodeConceptLegend(concept_legend_)));
    sendTeams(id);      // G4.30: which teams are playing
    {   // G5.35 (2.1): every team a match can be made of
        TeamListFrame tl;
        tl.names = cfg_.team_names;
        transport_.send(id, encodeFrame(FrameType::TeamList, encodeTeamList(tl)));
    }
    broadcastRoster();  // names + numbers for every client
}

namespace {
TeamsFrame teamsFrame(const persistence::DemoTeam& home, const persistence::DemoTeam& away) {
    TeamsFrame tf;
    tf.home = home.name;
    tf.away = away.name;
    // Mig 639 kits, chosen so the two sides never look alike (server/Kits, mig 1923).
    const WornKits worn = chooseKits(home.kits, away.kits);
    const persistence::Kit* kk[2] = {&worn.home, &worn.away};
    for (int t = 0; t < 2; ++t) {
        tf.kit[t][0] = kk[t]->shirt;
        tf.kit[t][1] = kk[t]->shorts;
        tf.kit[t][2] = kk[t]->socks;
        tf.kit[t][3] = kk[t]->trim;
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
            broadcastTeams();
            broadcastRoster();
            std::printf("fh-game: rosters reloaded from the club DB\n");
            return;
        }
        case FrameType::NewMatch: {
            // Admin-only (G5.35, 2.1): any two teams, kicked off fresh — each
            // plays its own formation (the PL sides their usual shape). Loaded
            // between ticks; an unknown or repeated name changes nothing.
            if (!admins_.count(id) || !cfg_.db) return;
            const auto nm = decodeTeams(frame.payload);
            if (!nm || nm->home.empty() || nm->away.empty() || nm->home == nm->away) return;
            auto home = persistence::loadDemoTeam(*cfg_.db, nm->home);
            auto away = persistence::loadDemoTeam(*cfg_.db, nm->away);
            if (!home || !away) return;
            for (auto [team, spec] : {std::pair{&*home, &cfg_.formation_home}, std::pair{&*away, &cfg_.formation_away}})
                if (!team->formation_code.empty())
                    if (auto f = persistence::loadFormation(*cfg_.db, team->formation_code)) *spec = std::move(*f);
            cfg_.roster_home = std::move(*home);
            cfg_.roster_away = std::move(*away);
            ++cfg_.match_seed;   // a new match, its own noise
            slot_owner_.clear();
            last_orders_.clear();
            last_events_.clear();
            startMatch();
            if (cfg_.practice) {   // a new practice match: its goal kick, paused
                practiceStart();
                const Bytes sp = encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{speed_pct_}));
                for (const auto& [cid, _] : clients_) transport_.send(cid, sp);
            }
            broadcastTeams();
            broadcastRoster();
            const Bytes snap = buildSnapshotFrame();
            for (const auto& [cid, _] : clients_) transport_.send(cid, snap);
            std::printf("fh-game: new match %s v %s (seed %llu)\n", cfg_.roster_home.name.c_str(),
                        cfg_.roster_away.name.c_str(), static_cast<unsigned long long>(cfg_.match_seed));
            std::fflush(stdout);
            return;
        }
        case FrameType::Step: {
            // Admin (2.2, trainer step 3): from the freeze, play the next pass.
            if (!admins_.count(id)) return;
            const auto st = decodeStep(frame.payload);
            if (!st || step_stage_) return;
            const auto& b = world_.ball();
            const bool dead = world_.restartTeam() != 0xFF || world_.outStage() != 0;
            step_owner_ = b.owner ? static_cast<int>(*b.owner) : -1;
            step_stage_ = (b.owner || dead) ? 1 : 2;
            step_cap_tick_ = world_.tickCount() + 20 * core::kTickRate;   // a step is at most 20 s
            setSpeedPct(st->pct);
            return;
        }
        case FrameType::Speed: {
            // Admin-only (G4.61): one match, one clock — everyone watching
            // runs at the speed the coach picks.
            if (!admins_.count(id)) return;
            const auto sp = decodeSpeed(frame.payload);
            if (sp) setSpeedPct(sp->pct);
            return;
        }
        default:
            onOtherFrame(id, frame);   // a child room's own frames; the match ignores the rest (incl. the frames G5.23 retired)
            return;
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
        // G4.53: the body's facing, apart from its velocity.
        snap.face_x = static_cast<std::int8_t>((p.face.x * Fixed64::fromInt(127)).raw >> Fixed64::FRAC_BITS);
        snap.face_y = static_cast<std::int8_t>((p.face.y * Fixed64::fromInt(127)).raw >> Fixed64::FRAC_BITS);
        // bit0 human-controlled; bit1 keeper (1.4 additive — clients
        // dress keepers in their own kit).
        // bit2 down in a tackle; bit3 dispossessed / off balance (G4.27,
        // so the client can animate slides and stumbles).
        snap.flags = static_cast<std::uint8_t>(
            (slot_owner_.count(i) ? 1 : 0) | (world_.isKeeper(i) ? 2 : 0) |
            (p.recovery_kind == 1 ? 4 : 0) | (p.recovery_kind == 2 ? 8 : 0) |
            (world_.takingThrow(i) ? 16 : 0) |   // bit4 (G5.2): ball in both hands, overhead
            (world_.lastKickFoot(i) ? 32 : 0) |  // bit5 (G5.79): his last kick was off foot 1 (his left)
            ((world_.lastKickKind(i) & 3) << 6)); // bits6-7 (G5.112): his last kick's kind
        {   // 2.3 (G5.77): his feet
            const core::FootState& ft = world_.feet(i);
            snap.feet_down = static_cast<std::uint8_t>((ft.down[0] ? 1 : 0) | (ft.down[1] ? 2 : 0));
            for (int k = 0; k < 2; ++k) {
                snap.foot_x[k] = static_cast<std::int16_t>((ft.plant[k].x * Fixed64::fromInt(100)).raw >> Fixed64::FRAC_BITS);
                snap.foot_y[k] = static_cast<std::int16_t>((ft.plant[k].y * Fixed64::fromInt(100)).raw >> Fixed64::FRAC_BITS);
                snap.foot_prog[k] = ft.prog[k];
            }
        }
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
    // 1.16 (G4.93): the officials, and the assistant's flag for
    // kFlagUpTicks after his offside call is whistled.
    const core::Officials& offs = world_.officials();
    for (int i = 0; i < core::kOfficialCount; ++i) {
        const core::OfficialState& o = offs.official(i);
        net::OfficialSnap os;
        os.pos_x = o.pos.x;
        os.pos_y = o.pos.y;
        os.face_x = static_cast<std::int8_t>((o.face.x * Fixed64::fromInt(127)).raw >> Fixed64::FRAC_BITS);
        os.face_y = static_cast<std::int8_t>((o.face.y * Fixed64::fromInt(127)).raw >> Fixed64::FRAC_BITS);
        os.flags = (flag_official_ == i && world_.tickCount() < flag_until_tick_) ? 1 : 0;
        // Bits 1-3 (G5.2): the signal for a ball out, the caller and the referee.
        if ((signal_official_ == i || (signal_official_ >= 0 && i == 0)) && world_.tickCount() < signal_until_tick_)
            os.flags |= static_cast<std::uint8_t>(signal_code_ << 1);
        s.officials.push_back(os);
    }
    return encodeFrame(FrameType::Snapshot, encodeSnapshot(s));
}

void GameServer::applyOrders(std::uint8_t slot, const ai::Orders& o) {
    world_.setIntent(slot, o.move);
    // The brain aims every kick at its order's target (G5.29); a tackle or a dive has none.
    const bool kick = o.action == core::Action::GroundKick || o.action == core::Action::ShortPass ||
                      o.action == core::Action::LoftedKick || o.action == core::Action::Shot;
    if (o.action != core::Action::None)
        world_.setAction(slot, o.action, o.carry_m, o.passTo(), o.first_time, kick ? &o.target : nullptr, o.aim_z, o.die);
}

// Tactics trainer step 2: a practice match starts from a goal kick (Law 16) — the ball
// in the kicking side's goal area, the taker's kick held practice_preroll_ticks (he walks
// to the ball; G5.69: holding all of him left the keeper on the spawn line) while every
// other man takes the engine's own shape for it, then paused: the coach sees the
// shape and plays it. Silent: nothing goes to clients until the room is shown.
void GameServer::practiceStart() {
    const std::uint8_t team = cfg_.goal_kick_team & 1;
    const Fixed64 gx = world_.pitchHalfX() - Fixed64::fromFraction(11, 2);   // the goal area's front edge
    world_.setDeadBall(core::MatchEventType::GoalKick, team, math::Vec3{team == 0 ? -gx : gx, Fixed64::zero(), Fixed64::zero()});
    last_orders_.assign(cfg_.slot_count, ai::Orders{});
    for (std::uint32_t t = 0; t < cfg_.practice_preroll_ticks; ++t) {
        const int taker = world_.restartTeam() == team ? brain_.restartTaker(world_, team) : -1;
        for (std::uint8_t slot = 0; slot < cfg_.slot_count; ++slot) {
            ai::Orders o = decide(slot);
            if (slot == taker) o.action = core::Action::None;   // he walks to the ball and waits for the coach: no kick
            last_orders_[slot] = o;
            applyOrders(slot, o);
        }
        last_events_ = world_.tick();
    }
    speed_pct_ = 0;
}

// Trainer step 3: a step ends when the pass is received (a man has it), the ball goes
// dead, or it is won off its man (a tackle), or after 20 s — then the freeze.
void GameServer::stepWatch() {
    const auto& b = world_.ball();
    const bool dead = world_.restartTeam() != 0xFF || world_.outStage() != 0;
    bool done = world_.tickCount() >= step_cap_tick_;
    if (step_stage_ == 1) {
        if (!dead && !b.owner) step_stage_ = 2;                                    // it's gone
        else if (b.owner && step_owner_ >= 0 && *b.owner != step_owner_) done = true;   // won off him
        else if (b.owner && step_owner_ < 0 && !dead) step_owner_ = *b.owner;          // the restart's taker has it
    } else if (b.owner || dead) {
        done = true;                                                               // received, or dead
    }
    if (!done) return;
    step_stage_ = 0;
    setSpeedPct(0);
}

void GameServer::tickOnce() {
    // AI drives every slot no human holds (claims always override; a
    // released slot reverts to its brain next tick).
    if (last_orders_.size() != cfg_.slot_count) last_orders_.assign(cfg_.slot_count, ai::Orders{});
    for (std::uint8_t slot = 0; slot < cfg_.slot_count; ++slot) {
        // G5.2: a held restart can't wait on a human who's walked away — past
        // kHumanRestartTicks the brain takes it for him.
        const bool stalled = world_.heldRestart() && world_.outStage() == 0 &&
                             world_.tickCount() > world_.restartReadyTick() + kHumanRestartTicks;
        if (slot_owner_.count(slot) && !stalled) {
            last_orders_[slot] = ai::Orders{};
            last_orders_[slot].why = ai::Why::Human;
            continue;
        }
        const ai::Orders o = decide(slot);
        last_orders_[slot] = o;
        applyOrders(slot, o);
    }

    last_events_ = world_.tick();
    if (step_stage_) stepWatch();
    if (world_.restartTeam() == 0xFF) {
        signal_until_tick_ = 0;       // and the arm comes down
    }
    const auto& match_events = last_events_;
    for (const core::MatchEvent& e : match_events)
        if (e.type == core::MatchEventType::Offside) {   // G4.93: his flag goes up
            flag_official_ = world_.lastOffsideCall().assistant;
            flag_until_tick_ = world_.tickCount() + kFlagUpTicks;
        } else if (e.type == core::MatchEventType::ThrowIn || e.type == core::MatchEventType::GoalKick ||
                   e.type == core::MatchEventType::Corner) {
            // G5.2: who called it, and his arm: 1/2 throw, attack toward +x /
            // -x; 3/4 goal kick, at the goal area on the +x / -x end; 5/6
            // corner, at the corner arc on the +x / -x end.
            signal_official_ = world_.lastOutCall().official;
            signal_until_tick_ = world_.tickCount() + kSignalTicks;
            const bool plus = e.type == core::MatchEventType::ThrowIn ? e.team == 0
                                                                     : world_.restartSpot().x.raw > 0;
            const std::uint8_t base = e.type == core::MatchEventType::ThrowIn ? 1
                                      : e.type == core::MatchEventType::GoalKick ? 3 : 5;
            signal_code_ = static_cast<std::uint8_t>(base + (plus ? 0 : 1));
        }
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
    afterTick();
}

void GameServer::setSpeedPct(std::uint16_t pct) {
    // 0 = paused; else 5 % (slow motion, ~1.5 ticks a second) .. 400 %.
    if (pct > 0 && pct < 5) pct = 5;
    if (pct > 400) pct = 400;
    if (pct == speed_pct_) return;
    speed_pct_ = pct;
    const Bytes frame = encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{speed_pct_}));
    for (const auto& [id, _] : clients_) transport_.send(id, frame);
}

void GameServer::heartbeat() {
    if (clients_.empty()) return;
    const Bytes frame = buildSnapshotFrame();
    for (const auto& [id, _] : clients_) transport_.send(id, frame);
    afterTick();
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
        {   // 2.2: the concept he's playing out of possession (tactics trainer step 1)
            const auto slot = static_cast<core::SlotIndex>(bf.slots.size());
            e.concept_id = conceptOf(slot, o);
        }
        bf.slots.push_back(e);
    }
    const Bytes frame = encodeFrame(FrameType::Brain, encodeBrain(bf));
    for (const auto& [id, _] : brain_watchers_) transport_.send(id, frame);
    {   // 2.5: who each man's direct opponent is (ai/concepts/DirectOpponent)
        Bytes pairs;
        pairs.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s) {
            // his man's slot (6 bits) and how the pair was made (2 bits: matchup 1, battle 2, nearest 3)
            const int o = brain_.directOpponent(s);
            const int how = static_cast<int>(brain_.directHow(s));
            pairs.push_back(o >= 0 && o < 63 ? static_cast<std::uint8_t>(o | (how << 6)) : std::uint8_t{255});
        }
        const Bytes pf = encodeFrame(FrameType::Pairs, pairs);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, pf);
        // 2.6: and whether each can reach his man while a pass to him travels (ai/concepts/PressingDistance)
        Bytes reach;
        reach.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s) {
            const auto& r = brain_.pressReach(s);
            const bool has = r.man >= 0 && !r.man_on_ball;
            const std::int64_t dmv = (r.reach_m * Fixed64::fromInt(10)).raw >> Fixed64::FRAC_BITS;
            const std::uint16_t v = !has ? 0xFFFF : static_cast<std::uint16_t>(dmv < 0 ? 0 : (dmv > 65000 ? 65000 : dmv));
            reach.push_back(static_cast<std::uint8_t>(v & 0xFF));
            reach.push_back(static_cast<std::uint8_t>(v >> 8));
            reach.push_back(static_cast<std::uint8_t>((r.in ? 1 : 0) | (r.man_on_ball ? 2 : 0) | (r.goal_side ? 4 : 0)));
            reach.push_back(r.help);
        }
        const Bytes rf = encodeFrame(FrameType::Reach, reach);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, rf);
        // 2.7: and who each man hides from the ball (ai/concepts/CoverShadow)
        Bytes sh;
        sh.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        sh.push_back(static_cast<std::uint8_t>((brain_.shadowBodyM() * Fixed64::fromInt(10)).raw >> Fixed64::FRAC_BITS));
        for (std::uint8_t t = 0; t < 2; ++t) {
            const int r = brain_.shadowScreen(t);
            sh.push_back(r >= 0 && r < 255 ? static_cast<std::uint8_t>(r) : std::uint8_t{255});
        }
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s) {
            const std::uint32_t m = brain_.hiddenBy(s);
            for (int b = 0; b < 4; ++b) sh.push_back(static_cast<std::uint8_t>((m >> (8 * b)) & 0xFF));
        }
        const Bytes sf = encodeFrame(FrameType::Shadow, sh);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, sf);
        // 2.8: each team's phase — the team machine every player's own state sits under
        const Bytes ph = encodeFrame(FrameType::Phase, Bytes{static_cast<std::uint8_t>(brain_.phaseOf(0)), static_cast<std::uint8_t>(brain_.phaseOf(1))});
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, ph);
        // 2.9: each man's own state — the state machine's real answer, not a guess from his order
        Bytes stf;
        stf.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s) {
            const ai::PlayerState* st = brain_.stateOf(s);
            std::string code = st ? st->name() : "";
            for (const auto& [name, c] : cfg_.state_codes) if (name == code) { code = c; break; }
            if (code.size() > 40) code.resize(40);
            stf.push_back(static_cast<std::uint8_t>(code.size()));
            stf.insert(stf.end(), code.begin(), code.end());
        }
        const Bytes sf2 = encodeFrame(FrameType::States, stf);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, sf2);
        // 2.10: the concept machines that are awake (asleep ones are not sent)
        Bytes mf;
        mf.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s) {
            const std::size_t at = mf.size();
            mf.push_back(0);
            for (int m = 1; m <= ai::concepts::kMachineCount; ++m) {
                const auto& ms = brain_.machineOf(s, static_cast<ai::concepts::MachineId>(m));
                if (ms.state == ai::concepts::kAsleep) continue;
                mf.push_back(static_cast<std::uint8_t>(m));
                mf.push_back(ms.state);
                mf.push_back(ms.other >= 0 && ms.other < 255 ? static_cast<std::uint8_t>(ms.other) : std::uint8_t{255});
                ++mf[at];
            }
        }
        const Bytes mfr = encodeFrame(FrameType::Machines, mf);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, mfr);
        // 2.12: who has the ball as each man reads it himself (his own phase; 0x80 = the ball has turned, he has not read it yet)
        Bytes pr;
        pr.push_back(static_cast<std::uint8_t>(cfg_.slot_count));
        for (std::uint8_t s = 0; s < cfg_.slot_count; ++s)
            pr.push_back(static_cast<std::uint8_t>(static_cast<std::uint8_t>(brain_.phaseOfPlayer(s)) | (brain_.readingTurn(s) ? 0x80 : 0)));
        const Bytes prf = encodeFrame(FrameType::PossRead, pr);
        for (const auto& [id, _] : brain_watchers_) transport_.send(id, prf);
    }
}

bool GameServer::slotClaimedBy(std::uint8_t slot, ClientId client) const {
    auto it = slot_owner_.find(slot);
    return it != slot_owner_.end() && it->second == client;
}

}  // namespace fh::game::server
