// game/src/server/GameServer.cpp

#include "server/GameServer.hpp"

#include "core/PlayerSheet.hpp"

#include "net/Wire.hpp"

#include <cstdio>

namespace fh::game::server {

using math::Fixed64;
using namespace net;

namespace {
// G4.76: a 3-rule weight's key on the wire ("ladder.<zone>.<rung>").
std::string ladderKey(int z, int r) {
    static const char* const kZone[] = {"own", "middle", "their"};
    static const char* const kRung[] = {"intercept", "no_turn", "contain"};
    return std::string("ladder.") + kZone[z] + "." + kRung[r];
}
}  // namespace

GameServer::GameServer(Config cfg, INetworkTransport& transport)
    : cfg_{cfg},
      transport_{transport},
      world_{cfg.slot_count, Fixed64::fromInt(cfg.max_speed_mps),
             Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg.pitch_half_y),
             cfg.half_length_ticks},
      brain_{ai::TeamSetup::splitHalves(cfg.slot_count),
             Fixed64::fromFraction(105, 2), Fixed64::fromInt(cfg.pitch_half_y),
             cfg.formation_home, cfg.formation_away} {
    // G4.76: models built by hand (tests) come unresolved; loaded ones
    // already are (and the harness's overrides sit on top — keep them).
    bool unresolved = false;
    for (const auto& g : cfg_.models) unresolved = unresolved || !g.resolved;
    if (unresolved) persistence::resolveGameModels(cfg_.models);
    skills_ = core::SkillSet(cfg.model_params);   // G4.33: DB numbers
    world_.setLocomotion(core::Locomotion(cfg.model_params));   // G4.51
    world_.setBallFlight(core::BallFlight(cfg.model_params));   // G4.87
    brain_.setModelParams(cfg.model_params);
    brain_.setDirectPairs(cfg.direct_pairs);
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
            world_.setBody(i, skills_.body(p.attrs));   // G4.52: his own body
        } else {
            slot_names_[i] =
                (home ? "Home " : "Away ") + std::to_string(k + 1);
        }
        ability_[i] = buildAbility(i, home ? cfg_.level_home : cfg_.level_away);
        core::PresetOverlay likes;
        likes.fill(-1);
        if (k < team.players.size())
            for (const auto& [idx, v] : team.players[k].tendencies)
                if (idx >= 0 && idx < core::concepts().size()) likes[idx] = v;
        brain_.setTendencies(i, likes);
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
    // G4.83: a player with a sheet (mig 793) plays each concept he knows at
    // its mastery for HIM — his years on it since the age it's taught —
    // not one flat number: a u10 basic is near-automatic for a 25-year-old,
    // last season's idea lapses at his quality.
    if (p.age > 0 && p.start_age >= 0) {
        const core::SheetRules rules = core::SheetRules::fromParams(cfg_.model_params);
        const core::PlayerSheet sheet = core::PlayerSheet::restore(p.age, p.start_age, p.years_off, quality);
        const int n = core::concepts().size();
        for (int c = 0; c < n; ++c)
            if (r[c] > 0) r[c] = static_cast<std::uint8_t>(sheet.conceptAbility(core::concepts().taughtFrom(c), rules));
    }
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
    core::PresetOverlay demand = m >= 0 ? cfg_.models[m].overlay : none;
    for (int i = 0; i < core::kMaxConcepts; ++i)   // G4.74 live changes win
        if (live_demand_[home ? 0 : 1][i] >= 0) demand[i] = live_demand_[home ? 0 : 1][i];
    const std::uint8_t team = home ? 0 : 1;
    ai::Brain::Ladder ladder{};
    for (int z = 0; z < 3; ++z)
        for (int r = 0; r < 3; ++r) {
            int w = m >= 0 ? cfg_.models[m].ladder[z][r] : -1;
            const auto lv = live_params_[team].find(ladderKey(z, r));
            if (lv != live_params_[team].end()) w = static_cast<int>(lv->second / 1000);
            ladder[z][r] = static_cast<std::uint8_t>(w < 0 ? 100 : (w > 100 ? 100 : w));
        }
    brain_.setLadder(team, ladder);
    // G4.76: its concept numbers — the global rows, its model's, live.
    core::ModelParams p = cfg_.model_params;
    if (m >= 0)
        for (const auto& [key, v] : cfg_.models[m].params) p.setMilli(key, v);
    for (const auto& [key, v] : live_params_[team])
        if (key.rfind("concept.", 0) == 0) p.setMilli(key, v);
    brain_.setTeamModelParams(team, p);
    const std::uint8_t half = cfg_.slot_count / 2;
    const std::uint8_t from = home ? 0 : half;
    const std::uint8_t to = home ? half : cfg_.slot_count;
    for (std::uint8_t sl = from; sl < to; ++sl) {
        concept_ratings_[sl] = core::effectiveRatings(ability_[sl], demand);
        brain_.setRatings(sl, concept_ratings_[sl]);
        brain_.setHabits(sl, ability_[sl]);
    }
}

void GameServer::sendParams(std::uint8_t team, ClientId to, bool all) {
    if (team > 1) return;
    const int m = team_model_[team];
    const persistence::GameModel* g = m >= 0 ? &cfg_.models[m] : nullptr;
    ModelParamsFrame f;
    f.team = team;
    auto origin = [](int o) { return static_cast<std::uint8_t>(o >= 0 && o < 255 ? o : 255); };
    for (int z = 0; z < 3; ++z)
        for (int r = 0; r < 3; ++r) {
            ModelParamEntry e;
            e.key = ladderKey(z, r);
            e.unit = "%";
            const auto lv = live_params_[team].find(e.key);
            const int w = g ? g->ladder[z][r] : -1;
            const int o = g ? g->ladder_origin[z][r] : -1;
            if (lv != live_params_[team].end()) { e.milli = static_cast<std::int32_t>(lv->second); e.source = 2; }
            else { e.milli = (w < 0 ? 100 : w) * 1000; e.source = w < 0 ? 0 : (o == m ? 1 : 3); }
            e.origin = origin(o);
            f.entries.push_back(std::move(e));
        }
    // G4.77: what the parent plays, for the HUD's "own vs parent" read.
    const persistence::GameModel* par = nullptr;
    if (g && !g->parent.empty())
        for (const auto& x : cfg_.models)
            if (x.name == g->parent) par = &x;
    for (int z = 0; z < 3; ++z)
        for (int r = 0; r < 3; ++r) {
            const int w = par ? par->ladder[z][r] : -1;
            f.parent_milli.push_back(!par ? ModelParamsFrame::kNoParent : (w < 0 ? 100 : w) * 1000);
        }
    for (const auto& info : cfg_.param_info) {
        if (!par) { f.parent_milli.push_back(ModelParamsFrame::kNoParent); }
        else {
            const auto it = par->params.find(info.key);
            f.parent_milli.push_back(static_cast<std::int32_t>(
                it != par->params.end() ? it->second : cfg_.model_params.milli(info.key, 0)));
        }
        ModelParamEntry e;
        e.key = info.key;
        e.unit = info.unit;
        const auto lv = live_params_[team].find(e.key);
        const bool own = g && g->params.count(e.key);
        if (lv != live_params_[team].end()) {
            e.milli = static_cast<std::int32_t>(lv->second);
            e.source = 2;
        } else if (own) {
            e.milli = static_cast<std::int32_t>(g->params.at(e.key));
            const int o = g->param_origin.at(e.key);
            e.source = o == m ? 1 : 3;
            e.origin = origin(o);
        } else {
            e.milli = static_cast<std::int32_t>(cfg_.model_params.milli(e.key, 0));
        }
        f.entries.push_back(std::move(e));
    }
    const Bytes frame = encodeFrame(FrameType::ModelParams, encodeModelParams(f));
    if (!all) { transport_.send(to, frame); return; }
    for (const auto& [id, _] : admins_) transport_.send(id, frame);
}

void GameServer::sendDemands(std::uint8_t team, ClientId to, bool all) {
    if (team > 1) return;
    const core::ConceptRegistry& reg = core::concepts();
    const int m = team_model_[team];
    ModelDemandsFrame f;
    f.team = team;
    f.model = m >= 0 && m < 255 ? static_cast<std::uint8_t>(m) : 255;
    for (int i = 0; i < reg.size() && i < 255; ++i) {
        const int live = live_demand_[team][i];
        const int row = m >= 0 ? cfg_.models[m].overlay[i] : -1;
        const int d = live >= 0 ? live : (row >= 0 ? row : reg.defaultDemand(i));
        const int from = m >= 0 ? cfg_.models[m].origin[i] : -1;
        f.demand.push_back(static_cast<std::uint8_t>(d > 100 ? 100 : d));
        // 2 live, 1 its own row, 3 inherited from a parent (G4.76), 0 none.
        f.source.push_back(live >= 0 ? 2 : row < 0 ? 0 : from == m ? 1 : 3);
        f.origin.push_back(from >= 0 && from < 255 ? static_cast<std::uint8_t>(from) : 255);
    }
    if (m >= 0)
        for (std::size_t p = 0; p < cfg_.models.size() && p < 255; ++p)
            if (!cfg_.models[m].parent.empty() && cfg_.models[p].name == cfg_.models[m].parent)
                f.parent = static_cast<std::uint8_t>(p);
    for (int i = 0; i < reg.size() && i < 255; ++i) {
        const int pd = f.parent != 255 ? cfg_.models[f.parent].overlay[i] : -1;
        f.parent_demand.push_back(static_cast<std::uint8_t>(pd < 0 ? 255 : (pd > 100 ? 100 : pd)));
    }
    const Bytes frame = encodeFrame(FrameType::ModelDemands, encodeModelDemands(f));
    if (!all) { transport_.send(to, frame); return; }
    for (const auto& [id, _] : admins_) transport_.send(id, frame);
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
    if (!cfg_.phases.empty()) {  // G4.58 (1.9): the phase-of-play catalog
        PresetsFrame phf;
        for (const auto& ph : cfg_.phases) phf.names.push_back(ph.title);
        transport_.send(id, encodeFrame(FrameType::Phases, encodePresets(phf)));
    }
    // G4.61 (1.10): the sim speed, so a late joiner's clock runs at it.
    transport_.send(id, encodeFrame(FrameType::Speed, encodeSpeed(SpeedFrame{speed_pct_})));
    {  // G4.41 (1.7): the brain overlay's decision names, index = why code.
        PresetsFrame lf;
        for (int i = 0; i < ai::kWhyCount; ++i) lf.names.push_back(ai::kWhyNames[i]);
        transport_.send(id, encodeFrame(FrameType::BrainLegend, encodePresets(lf)));
    }
    // G4.30: which teams are playing — the editor's key into the club API.
    sendTeams(id);
    if (admin) {   // G4.74, G4.76
        sendDemands(0, id); sendDemands(1, id);
        sendParams(0, id); sendParams(1, id);
    }
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
            world_.setBody(pa->slot, skills_.body(a));
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
        case FrameType::Speed: {
            // Admin-only (G4.61): one match, one clock — everyone watching
            // runs at the speed the coach picks.
            if (!admins_.count(id)) return;
            const auto sp = decodeSpeed(frame.payload);
            if (sp) setSpeedPct(sp->pct);
            return;
        }
        case FrameType::RunPhase: {
            // Admin-only (G4.58): a coach's restart for everyone watching.
            // Same layout as APPLY_PRESET: u8 team | u8 phase.
            if (!admins_.count(id)) return;
            const auto rp = decodeApplyPreset(frame.payload);
            if (rp) runPhase(rp->team, rp->preset_id);
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
            live_demand_[ap->team].fill(-1);
            live_params_[ap->team].clear();
            recomputeKnowledge(ap->team == 0);
            broadcastRoster();
            sendDemands(ap->team, 0, true);
            sendParams(ap->team, 0, true);
            return;
        }
        case FrameType::SetDemand: {
            // Admin-only (G4.74): one concept's demand for one team, live,
            // on top of its model — James: "change mid game to see diff
            // behaviour". Not saved; 255 = back to the model / default.
            if (!admins_.count(id)) return;
            const auto sd = decodeSetDemand(frame.payload);
            if (!sd || sd->team > 1 || sd->concept_id >= core::concepts().size()) return;
            live_demand_[sd->team][sd->concept_id] =
                sd->demand == 255 ? std::int16_t{-1} : static_cast<std::int16_t>(sd->demand > 100 ? 100 : sd->demand);
            recomputeKnowledge(sd->team == 0);
            broadcastRoster();
            sendDemands(sd->team, 0, true);
            return;
        }
        case FrameType::SaveDemand: {
            // Admin-only (G4.76, mig 762): write one concept's demand into
            // the team's game model in the club DB — James: "editable in
            // hud". 255 = delete the model's own row (inherit from its
            // parent); a top-level model states every concept, so the DB
            // refuses that. Every model that inherits it moves too.
            if (!admins_.count(id) || !cfg_.db) return;
            const auto sd = decodeSetDemand(frame.payload);
            if (!sd || sd->team > 1 || sd->concept_id >= core::concepts().size()) return;
            const int m = team_model_[sd->team];
            if (m < 0) return;
            auto& g = cfg_.models[m];
            if (sd->demand == 255 && g.parent.empty()) return;
            const int d = sd->demand == 255 ? -1 : (sd->demand > 100 ? 100 : sd->demand);
            if (persistence::saveModelDemand(*cfg_.db, g.name, sd->concept_id, d)) {
                g.own[sd->concept_id] = static_cast<std::int16_t>(d);
                persistence::resolveGameModels(cfg_.models);
                live_demand_[sd->team][sd->concept_id] = -1;
            }
            for (int side = 0; side < 2; ++side) recomputeKnowledge(side == 0);
            broadcastRoster();
            sendDemands(0, 0, true);
            sendDemands(1, 0, true);
            return;
        }
        case FrameType::SetParam: {
            // Admin-only (G4.76): one concept number or 3-rule weight for one
            // team — live (op 0/1), or saved into its game model (op 2), or
            // the model's own row deleted so the parent's applies (op 3; the
            // DB refuses a top-level model's ladder cell).
            if (!admins_.count(id)) return;
            const auto sp = decodeSetParam(frame.payload);
            if (!sp || sp->team > 1) return;
            const bool ladder = sp->key.rfind("ladder.", 0) == 0;
            bool known = false;
            for (int z = 0; z < 3 && ladder; ++z)
                for (int r = 0; r < 3; ++r) known = known || sp->key == ladderKey(z, r);
            for (const auto& info : cfg_.param_info) known = known || info.key == sp->key;
            if (!known) return;
            const int m = team_model_[sp->team];
            if (sp->op == 0) live_params_[sp->team][sp->key] = sp->milli;
            else if (sp->op == 1) live_params_[sp->team].erase(sp->key);
            else if ((sp->op == 2 || sp->op == 3) && m >= 0 && cfg_.db) {
                auto& g = cfg_.models[m];
                const std::optional<std::int64_t> v = sp->op == 2 ? std::optional<std::int64_t>{sp->milli} : std::nullopt;
                if (persistence::saveModelParam(*cfg_.db, g.name, sp->key, v)) {
                    if (ladder) {
                        for (int z = 0; z < 3; ++z)
                            for (int r = 0; r < 3; ++r)
                                if (sp->key == ladderKey(z, r)) {
                                    const std::int64_t w = v ? (*v + 500) / 1000 : -1;
                                    g.own_ladder[z][r] = static_cast<std::int16_t>(w > 100 ? 100 : w);
                                }
                    } else if (v) {
                        g.own_params[sp->key] = *v;
                    } else {
                        g.own_params.erase(sp->key);
                    }
                    persistence::resolveGameModels(cfg_.models);
                    live_params_[sp->team].erase(sp->key);
                }
            }
            for (int side = 0; side < 2; ++side) recomputeKnowledge(side == 0);
            sendParams(0, 0, true);
            sendParams(1, 0, true);
            return;
        }
        default:
            return;  // unknown/unexpected types ignored (PROTOCOL.md §9)
    }
}

void GameServer::runPhase(std::uint8_t team, std::size_t id) {
    if (team > 1 || id >= cfg_.phases.size()) return;
    const persistence::Phase& ph = cfg_.phases[id];
    const std::uint8_t n = cfg_.slot_count, per_team = n / 2;
    const Fixed64 hx = world_.pitchHalfX(), hy = Fixed64::fromInt(cfg_.pitch_half_y);
    // The team in possession attacks +x (home) / −x (away).
    const Fixed64 sgn = team == 0 ? Fixed64::one() : -Fixed64::one();
    Fixed64 bx = (-hx + hx * Fixed64::fromFraction(ph.x_pct, 50)) * sgn;
    Fixed64 by = hy * Fixed64::fromFraction(ph.y_pct, 100) * sgn;
    if (ph.kind == "kickoff") { bx = Fixed64::zero(); by = Fixed64::zero(); }
    const math::Vec3 ball{bx, by, Fixed64::zero()};
    // Everyone into his shape for that ball, facing it.
    std::vector<math::Vec2> at(n);
    std::vector<bool> placed(n, false);
    for (std::uint8_t i = 0; i < n; ++i) {
        const bool home = i < per_team;
        const std::uint8_t k = home ? i : i - per_team;
        const ai::FormationSpec& spec =
            home ? (cfg_.formation_home.valid(per_team) ? cfg_.formation_home : ai::builtinFormation(per_team))
                 : (cfg_.formation_away.valid(per_team) ? cfg_.formation_away : ai::builtinFormation(per_team));
        const auto& pos = spec.positions[k];
        math::Vec2 a = ai::anchorFor(pos.base, home ? 1 : -1, ball, hx, hy, pos.keeper);
        // Kick-off: nobody over halfway.
        if (ph.kind == "kickoff") {
            if (home && a.x > -Fixed64::one()) a.x = -Fixed64::one();
            if (!home && a.x < Fixed64::one()) a.x = Fixed64::one();
        }
        // The restart shape (migs 697-698): each team stands where its
        // formation's rows for this phase say, by position number — side
        // 'in' for the team in possession, 'out' for the defenders. Depth is
        // from the team's OWN goal line, width + = left from its view.
        placed[i] = false;
        if (pos.number > 0) {
            const bool in = (home ? 0 : 1) == team;
            const Fixed64 own = home ? Fixed64::one() : -Fixed64::one();   // its attack direction
            const std::string& fcode = home ? cfg_.roster_home.formation_code : cfg_.roster_away.formation_code;
            for (const auto& pp : cfg_.phase_positions) {
                if (pp.phase != ph.code || pp.formation != fcode || pp.number != pos.number ||
                    pp.side != (in ? "in" : "out"))
                    continue;
                const Fixed64 depth = Fixed64::fromFraction(pp.depth_cm, 100);
                const Fixed64 width = Fixed64::fromFraction(pp.width_cm, 100);
                a = math::Vec2{(-hx + depth) * own, width * own};
                placed[i] = true;
                break;
            }
        }
        at[i] = a;
    }
    // How high the defending team starts (mig 696): its most advanced
    // outfield line slides to press_line_pct up from our goal line; the
    // rest of its shape comes with it; its keeper stays home.
    if (ph.press_line_pct >= 0) {
        const std::uint8_t def = team ^ 1;
        auto from_our_goal = [&](Fixed64 x) { return x * sgn + hx; };
        Fixed64 front = Fixed64::fromInt(1000);
        for (std::uint8_t i = 0; i < n; ++i)
            if ((i < per_team ? 0 : 1) == def && !world_.isKeeper(i) && !placed[i] && from_our_goal(at[i].x) < front)
                front = from_our_goal(at[i].x);
        const Fixed64 shift = hx * Fixed64::fromFraction(ph.press_line_pct, 50) - front;
        for (std::uint8_t i = 0; i < n; ++i) {
            if ((i < per_team ? 0 : 1) != def || world_.isKeeper(i) || placed[i]) continue;
            Fixed64 x = at[i].x + shift * sgn;
            const Fixed64 lim = hx - Fixed64::fromInt(2);
            if (x > lim) x = lim;
            if (x < -lim) x = -lim;
            at[i].x = x;
        }
    }
    // Every dead ball needs a taker (G4.59): the keeper for his goal kick,
    // else the team's nearest outfielder, stood just behind the ball — the
    // hold exempts whoever's mark is on the ball. Without one, a kick-off or
    // corner held all 22 on their marks for ever.
    if (ph.kind != "open") {
        int taker = -1;
        Fixed64 bd{};
        for (std::uint8_t i = 0; i < n; ++i) {
            if ((i < per_team ? 0 : 1) != team || world_.isKeeper(i) != (ph.kind == "keeper")) continue;
            const Fixed64 d = (at[i].x - bx) * (at[i].x - bx) + (at[i].y - by) * (at[i].y - by);
            if (taker < 0 || d < bd) { taker = i; bd = d; }
        }
        if (taker >= 0) at[taker] = math::Vec2{ball.x - sgn * Fixed64::fromFraction(1, 2), ball.y};
    }
    // Both teams hold their restart shapes until the ball is played.
    std::vector<std::pair<std::uint8_t, math::Vec2>> marks;
    for (std::uint8_t i = 0; i < n; ++i)
        if ((i < per_team ? 0 : 1) == team || placed[i]) marks.emplace_back(i, at[i]);
    if (ph.kind == "open") brain_.clearRestartShape(); else brain_.setRestartShape(team, std::move(marks));
    for (std::uint8_t i = 0; i < n; ++i) {
        const bool home = i < per_team;
        math::Vec2 face{ball.x - at[i].x, ball.y - at[i].y};
        if (face.x.raw == 0 && face.y.raw == 0) face = math::Vec2{home ? Fixed64::one() : -Fixed64::one(), Fixed64::zero()};
        world_.placePlayer(i, math::Vec3{at[i].x, at[i].y, Fixed64::zero()}, math::normalized(face));
    }
    if (ph.kind == "keeper") {
        world_.setDeadBall(core::MatchEventType::GoalKick, team, ball);
    } else if (ph.kind == "corner") {
        world_.setDeadBall(core::MatchEventType::Corner, team, ball);
    } else if (ph.kind == "kickoff") {
        world_.setDeadBall(core::MatchEventType::Kickoff, team, ball);
    } else {   // open play: the ball at the feet of our nearest outfielder
        int best = -1;
        Fixed64 bd{};
        for (std::uint8_t i = 0; i < n; ++i) {
            if ((i < per_team ? 0 : 1) != team || world_.isKeeper(i)) continue;
            const auto& p = world_.player(i);
            const Fixed64 d = (p.pos.x - bx) * (p.pos.x - bx) + (p.pos.y - by) * (p.pos.y - by);
            if (best < 0 || d < bd) { best = i; bd = d; }
        }
        if (best >= 0) {
            world_.placePlayer(static_cast<std::uint8_t>(best), ball,
                               math::Vec2{sgn, Fixed64::zero()});
            world_.giveBall(static_cast<std::uint8_t>(best));
        }
    }
    // A dead ball takes seconds (G4.63): the defending side's men who
    // pick up theirs on it (man-markers: their mark, then the one spot;
    // G4.64 the packed middle) start there — twice, so the lane each takes sees his teammates'.
    // Seconds to set up (a phase's defence is set too): everyone who knows
    // his job is on it (no roll).
    brain_.setDeadBallSetup(true);
    // Open play too: the phase starts with the defence already set (G4.64).
    for (int pass = 0; pass < 2; ++pass)
            for (std::uint8_t i = 0; i < n; ++i) {
                if ((i < per_team ? 0 : 1) == team || world_.isKeeper(i) || placed[i]) continue;
                const ai::Orders o = brain_.ordersFor(i, world_);
                if (o.why != ai::Why::Mark && o.why != ai::Why::MarkTight && o.why != ai::Why::ProtectMiddle &&
                    o.why != ai::Why::ShadowHelp && o.why != ai::Why::PackMiddle &&
                    o.why != ai::Why::LockDoor && o.why != ai::Why::PlayOff)
                    continue;
                math::Vec2 face{ball.x - o.target.x, ball.y - o.target.y};
                if (face.x.raw == 0 && face.y.raw == 0) face = math::Vec2{-sgn, Fixed64::zero()};
                world_.placePlayer(i, math::Vec3{o.target.x, o.target.y, Fixed64::zero()}, math::normalized(face));
            }
    brain_.setDeadBallSetup(false);
    // Their goal kick (Law 16): nobody of the defending side starts in the
    // kicker's penalty area — a shape or mark row inside it stands on the 18.
    if (ph.kind == "keeper") {
        const Fixed64 line = hx - Fixed64::fromFraction(35, 2), box_y = Fixed64::fromFraction(2116, 100);
        for (std::uint8_t i = 0; i < n; ++i) {
            if ((i < per_team ? 0 : 1) == team || world_.isKeeper(i)) continue;
            const auto& p = world_.player(i);
            if (-p.pos.x * sgn <= line || math::fx_abs(p.pos.y) >= box_y) continue;
            world_.placePlayer(i, math::Vec3{-line * sgn, p.pos.y, Fixed64::zero()}, p.face);
        }
    }
    std::fprintf(stderr, "fh-game: phase '%s' for %s\n", ph.code.c_str(), team == 0 ? "home" : "away");
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
        if (o.action != core::Action::None) world_.setAction(slot, o.action, o.carry_m, o.passTo());
    }

    last_events_ = world_.tick();
    if (world_.restartTeam() == 0xFF) brain_.clearRestartShape();   // played: shape released
    const auto& match_events = last_events_;
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
        e.look_ds = o.look_ds;
        e.unseen = o.unseen;
        if (o.call_to >= 0 && o.call_to < 255) {
            e.call = static_cast<std::uint8_t>(o.call);
            e.call_to = static_cast<std::uint8_t>(o.call_to);
        }
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
