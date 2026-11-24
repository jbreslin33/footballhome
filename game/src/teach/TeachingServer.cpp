// game/src/teach/TeachingServer.cpp — see TeachingServer.hpp.

#include "teach/TeachingServer.hpp"

#include "ai/Steering.hpp"
#include "ai/TeamPhase.hpp"
#include "net/Codec.hpp"
#include "core/Clock.hpp"
#include "core/PlayerSkill.hpp"

#include <cmath>
#include <cstdio>
#include <map>
#include <string>

namespace fh::game::teach {

namespace tg = fh::tactics;
using math::Fixed64;
using math::Vec2;

namespace {

server::GameServer::Config withShapes(server::GameServer::Config cfg, const Plan& plan, std::uint8_t us) {
    (us == 0 ? cfg.formation_home : cfg.formation_away) = plan.us;
    (us == 0 ? cfg.formation_away : cfg.formation_home) = plan.them;
    cfg.practice = true;
    cfg.goal_kick_team = static_cast<std::uint8_t>(1 - us);
    return cfg;
}

}  // namespace

TeachingServer::TeachingServer(Config cfg, net::INetworkTransport& transport, Plan plan, std::uint8_t us, bool zonal)
    : GameServer{withShapes(std::move(cfg), plan, us & 1), transport},
      plan_{std::move(plan)}, us_{static_cast<std::uint8_t>(us & 1)}, them_{static_cast<std::uint8_t>(1 - (us & 1))} {
    zonal_ = zonal;
    for (auto& o : other_) o = -1;
    for (auto& c : concept_) c = 255;
    for (auto& m : mind_man_) m = -1;
    // Each marking step's label is its behaviour's concept (game_engine_behaviours → game_concepts).
    for (int i = 0; i < ai::concepts::kMarkStepCount; ++i) {
        step_concept_[i] = 255;
        const auto it = plan_.behaviours.find(ai::concepts::kMarkStepCodes[i]);
        if (it == plan_.behaviours.end() || it->second.id < 0 || it->second.id > 254) continue;
        step_concept_[i] = static_cast<std::uint8_t>(it->second.id);
        bool have = false;
        for (const auto& e : concept_legend_.entries) have = have || e.id == it->second.id;
        if (!have) concept_legend_.entries.push_back({step_concept_[i], it->second.name, it->second.title});
    }
    // The labels: every job kind the plan uses, by the game concept the board names it with.
    for (const auto& s : plan_.states)
        for (const auto& j : s.jobs) {
            const auto it = plan_.concepts.find(j.kind);
            if (it == plan_.concepts.end() || it->second.id < 0 || it->second.id > 254) continue;
            bool have = false;
            for (const auto& e : concept_legend_.entries) have = have || e.id == it->second.id;
            if (!have)
                concept_legend_.entries.push_back({static_cast<std::uint8_t>(it->second.id), it->second.name, it->second.title});
        }
    // The base built its goal kick with the engine's own shape (a constructor can't reach a
    // child's decide). Again, with ours on their jobs.
    startMatch();
    practiceStart();
}

void TeachingServer::solve() {
    const std::uint64_t tick = world_.tickCount();
    if (tick == solved_tick_) return;
    if (solved_tick_ != ~0ull && tick < solved_tick_) {   // a new match in this room
        cur_ = nullptr; last_owner_ = receiver_ = -1;
    }
    solved_tick_ = tick;
    active_ = false;
    for (auto& h : has_) h = false;

    const auto& ball = world_.ball();
    const std::uint8_t n = cfg_.slot_count;
    int man = -1;
    if (ball.owner) {
        if (teamOf(*ball.owner) != them_) { last_owner_ = receiver_ = -1; return; }   // ours: the engine plays on
        man = *ball.owner;
        if (man != last_owner_) { last_owner_ = man; receiver_ = -1; }
    } else if (world_.restartTeam() == them_) {
        man = brain_.restartTaker(world_, them_);
        if (man >= 0) last_owner_ = man;                   // the taker: his kick is their ball too
    } else if (world_.restartTeam() == 0xFF && (receiver_ >= 0 || last_owner_ >= 0)) {
        // Their ball on its way (or loose off a touch — it is theirs until one of ours HAS it). A pass to a man: we move as it travels, on the step "ball to
        // him". A long ball that names nobody (a keeper's punt): the jobs stand — every mark
        // stays with his man — and the engine's own race for it still takes our nearest.
        man = receiver_ >= 0 ? receiver_ : last_owner_;
    }
    if (man < 0 || man >= n) return;
    const int number = brain_.numberOf(static_cast<core::SlotIndex>(man));
    if (number <= 0) return;

    if (!cur_) cur_ = plan_.root();
    if (!cur_) return;
    if (number != cur_->ball_with)
        if (const PlanState* nx = plan_.next(cur_, number)) cur_ = nx;   // no step drawn: the jobs stand

    // Which way we attack: off our keeper's end (the ends swap at half time).
    double sg = us_ == 0 ? 1.0 : -1.0;
    for (std::uint8_t i = 0; i < n; ++i)
        if (teamOf(i) == us_ && world_.isKeeper(i)) { sg = world_.player(i).pos.x.toDouble() < 0 ? 1.0 : -1.0; break; }
    attack_plus_ = sg > 0;
    const double hx = world_.pitchHalfX().toDouble(), hy = world_.pitchHalfY().toDouble();
    // The plan pitch (TacticGeometry.hpp): 0-100 from our view, y 0 = our goal line.
    const auto toPlan = [&](const math::Vec3& p) {
        return tg::Point{(hy + sg * p.y.toDouble()) / (2 * hy) * 100.0, (hx + sg * p.x.toDouble()) / (2 * hx) * 100.0};
    };

    tg::State st;
    st.ballWith = number;
    st.jobs = cur_->jobs;
    if (world_.restartTeam() == them_ && cur_->law) st.law = cur_->law;   // the Law, until it is played
    std::map<int, int> their_slot;
    for (std::uint8_t i = 0; i < n; ++i) {
        if (teamOf(i) != them_) continue;
        const int num = brain_.numberOf(i);
        if (num <= 0) continue;
        st.opponents.push_back({num, toPlan(world_.player(i).pos)});
        their_slot[num] = i;
    }
    const tg::Solution sol = tg::Solver{}.solve(st, plan_.frame);
    std::map<int, tg::Point> at;
    for (const auto& p : sol.players) at[p.position] = p.at;
    std::map<int, const tg::Job*> job;
    for (const auto& j : st.jobs) job[j.position] = &j;
    const std::map<int, tg::Point> home = tg::blockHome(plan_.frame);

    for (std::uint8_t i = 0; i < n; ++i) {
        if (teamOf(i) != us_ || world_.isKeeper(i)) continue;
        const int num = brain_.numberOf(i);
        const auto a = at.find(num);
        if (num <= 1 || a == at.end()) continue;
        has_[i] = true;
        spot_[i] = Vec2{Fixed64::fromDouble(sg * (a->second.y / 100.0 * 2 * hx - hx)),
                        Fixed64::fromDouble(sg * (a->second.x / 100.0 * 2 * hy - hy))};
        other_[i] = -1;
        concept_[i] = 255;
        if (const auto jt = job.find(num); jt != job.end()) {
            const tg::Job& j = *jt->second;
            if (!j.targets.empty())
                if (const auto ts = their_slot.find(j.targets.front()); ts != their_slot.end())
                    other_[i] = static_cast<std::int16_t>(ts->second);
            if (const auto c = plan_.concepts.find(j.kind); c != plan_.concepts.end() && c->second.id >= 0 && c->second.id <= 254)
                concept_[i] = static_cast<std::uint8_t>(c->second.id);
            // A mark job (the `mark` placement rule) on a man: the marking mind runs it. Its zone
            // is his own spot in the block.
            const auto k = plan_.frame.kinds.find(j.kind);
            mind_on_[i] = k != plan_.frame.kinds.end() && k->second.rule == "mark" && other_[i] >= 0;
            if (mind_on_[i]) {
                tg::Point hp = a->second;
                if (const auto h = home.find(num); h != home.end()) hp = h->second;
                const Vec2 hw{Fixed64::fromDouble(sg * (hp.y / 100.0 * 2 * hx - hx)), Fixed64::fromDouble(sg * (hp.x / 100.0 * 2 * hy - hy))};
                if (mind_man_[i] != other_[i]) {
                    mind_[i] = ai::concepts::MarkingMind{zonal_ ? ai::concepts::MarkKind::Zonal : ai::concepts::MarkKind::ManOriented,
                                                         static_cast<core::SlotIndex>(other_[i]), hw};
                    mind_man_[i] = other_[i];
                } else {
                    mind_[i].setHome(hw);
                }
            }
        } else {
            mind_on_[i] = false;
        }
    }
    active_ = true;
}

ai::Orders TeachingServer::decide(std::uint8_t slot) {
    ai::Orders o = GameServer::decide(slot);   // the engine's own answer, always asked first
    if (slot >= 32) return o;
    on_job_[slot] = false;
    if (teamOf(slot) == them_) {
        // Their pass: who it is for (the plan's next step is "ball to their #n").
        const bool kick = o.action == core::Action::GroundKick || o.action == core::Action::ShortPass ||
                          o.action == core::Action::LoftedKick;
        if (kick && o.passTo() != 0xFF) receiver_ = o.passTo();
        return o;
    }
    if (world_.isKeeper(slot)) return o;
    solve();
    if (!active_ || !has_[slot]) return o;
    // The engine keeps: a loose ball he is first to, a pass he can cut out, the Law's distance.
    if (o.why == ai::Why::Chase || o.why == ai::Why::MeetPass || o.why == ai::Why::LawDistance) return o;

    const auto& me = world_.player(slot);
    const auto& ball = world_.ball();
    ai::Orders p;
    p.why = ai::Why::Hold;
    p.target = spot_[slot];
    p.other = other_[slot];
    p.move.move = ai::seek(me.pos, p.target, Fixed64::fromInt(2));
    p.move.face = Vec2{ball.pos.x - me.pos.x, ball.pos.y - me.pos.y};
    if (mind_on_[slot]) {
        // Marking: his own eyes, memory and choice of step (ai/concepts/Marking). While their
        // ball is dead the Law keeps his plan spot; the mind still looks and thinks.
        const Fixed64 sg = attack_plus_ ? Fixed64::one() : -Fixed64::one();
        view_[slot] = mind_[slot].think(world_, slot, sg);
        if (world_.restartTeam() == 0xFF) {
            p.target = view_[slot].target;
            p.move.move = ai::seek(me.pos, p.target, view_[slot].full_pace ? Fixed64::fromFraction(1, 2) : Fixed64::fromInt(2));
        }
        p.move.face = view_[slot].face;
        p.why = ai::Why::Mark;
    }
    // On their carrier, in reach: he may dive in — the engine's own tackle rate (G5.25).
    if (ball.owner && teamOf(*ball.owner) == them_ && world_.restartTeam() == 0xFF &&
        ai::distSq(me.pos, ball.pos) < core::kTackleReach * core::kTackleReach) {
        const Fixed64 per_tick = brain_.block().params().tackle_per_s * core::kTickDt;
        const Fixed64 r = core::detNoise(world_.matchSeed(), world_.tickCount(), slot, 29);   // [-1, 1)
        if ((r + Fixed64::one()) * Fixed64::fromFraction(1, 2) < per_tick) {
            p.action = core::Action::Tackle;
            p.why = ai::Why::Press;
        }
    }
    on_job_[slot] = true;
    return p;
}

std::uint8_t TeachingServer::conceptOf(std::uint8_t slot, const ai::Orders& o) const {
    // A marker's label is the step he is on (track the runner, jump the pass …).
    if (slot < 32 && on_job_[slot] && mind_on_[slot]) {
        const std::uint8_t c = step_concept_[static_cast<int>(view_[slot].step)];
        if (c != 255) return c;
    }
    if (slot < 32 && on_job_[slot] && concept_[slot] != 255) return concept_[slot];
    return GameServer::conceptOf(slot, o);
}

// ── The one-player view: MIND_WATCH picks a player, MIND carries his mind ──────────────
void TeachingServer::onOtherFrame(ClientId id, const net::DecodedFrame& frame) {
    if (frame.type != net::FrameType::MindWatch || frame.payload.empty()) return;
    const std::uint8_t slot = frame.payload[0];
    if (slot >= cfg_.slot_count) { mind_watch_.erase(id); return; }
    mind_watch_[id] = slot;
    const std::string js = mindJson(slot);   // at once: a frozen room has no next tick
    transport_.send(id, net::encodeFrame(net::FrameType::Mind, net::Bytes(js.begin(), js.end())));
}

void TeachingServer::afterTick() {
    if (mind_watch_.empty() || world_.tickCount() % 3 != 0) return;   // 10 Hz
    for (const auto& [id, slot] : mind_watch_) {
        const std::string js = mindJson(slot);
        transport_.send(id, net::encodeFrame(net::FrameType::Mind, net::Bytes(js.begin(), js.end())));
    }
}

std::string TeachingServer::mindJson(std::uint8_t slot) const {
    namespace mk = ai::concepts;
    char buf[256];
    std::string js = "{\"slot\":" + std::to_string(slot) + ",\"tick\":" + std::to_string(world_.tickCount());
    js += std::string(",\"phase\":\"") + ai::kPhaseNames[static_cast<int>(brain_.phaseOf(teamOf(slot)))] + "\"";
    if (slot >= 32 || !mind_on_[slot] || !on_job_[slot]) return js + ",\"mind\":false}";
    const mk::MarkView& v = view_[slot];
    const mk::MarkMemory& m = mind_[slot].memory();
    const std::uint64_t now = world_.tickCount();
    const auto& me = world_.player(slot);
    const auto& man = world_.player(mind_[slot].man());
    const double speed = std::hypot(me.vel.x.toDouble(), me.vel.y.toDouble());
    js += ",\"mind\":true,\"concept\":\"marking\"";
    js += std::string(",\"kind\":\"") + mk::kMarkKindCodes[static_cast<int>(v.kind)] + "\"";
    js += std::string(",\"step\":\"") + mk::kMarkStepCodes[static_cast<int>(v.step)] + "\"";
    js += std::string(",\"wants\":\"") + mk::kMarkStepCodes[static_cast<int>(v.wants)] + "\"";
    js += std::string(",\"eyes\":\"") + mk::kEyesCodes[static_cast<int>(v.eyes)] + "\"";
    js += std::string(",\"sees_man\":") + (v.sees_man ? "true" : "false") + ",\"sees_ball\":" + (v.sees_ball ? "true" : "false");
    js += ",\"man\":" + std::to_string(mind_[slot].man());
    js += ",\"man_age\":" + std::to_string(m.man.ever ? now - m.man.tick : 0) + ",\"ball_age\":" + std::to_string(m.ball.ever ? now - m.ball.tick : 0);
    std::snprintf(buf, sizeof buf, ",\"man_seen\":[%.2f,%.2f],\"man_now\":[%.2f,%.2f],\"target\":[%.2f,%.2f],\"gaze\":[%.3f,%.3f],\"speed\":%.2f",
                  m.man.pos.x.toDouble(), m.man.pos.y.toDouble(), man.pos.x.toDouble(), man.pos.y.toDouble(),
                  v.target.x.toDouble(), v.target.y.toDouble(), v.face.x.toDouble(), v.face.y.toDouble(), speed);
    js += buf;
    js += std::string(",\"man_has_ball\":") + (m.man_has_ball ? "true" : "false") + ",\"back_to_goal\":" + (m.man_back_to_goal ? "true" : "false") +
          ",\"pass_to_man\":" + (m.pass_to_man ? "true" : "false");
    js += ",\"opts\":[";
    for (int i = 0; i < mk::kMarkStepCount; ++i) {
        const auto& o = v.options[i];
        js += std::string(i ? "," : "") + "{\"k\":\"" + mk::kMarkStepCodes[i] + "\",\"cue\":" + (o.cue ? "true" : "false") + ",\"score\":" + std::to_string(o.score) + "}";
    }
    return js + "]}";
}

}  // namespace fh::game::teach
