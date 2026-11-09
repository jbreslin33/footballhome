#pragma once
// fh::tactics — where our players stand from their jobs.
//
// ONE implementation shared by the club backend (Game Center 🎯 Tactics
// pill, /api/tactic-plans) and the game engine (the plan reader).  Owner
// 2026-11-07: "always share where we can, only differ when we have to …
// standard OOP parent child."  So the rules live here once:
//
//   JobRule                    parent: what every placement rule shares —
//     ├─ HomeRule              needs men? no job? which men it covers
//     ├─ MarkRule
//     ├─ PressRule
//     ├─ CoverShadowRule       each child overrides only place() and, when
//     ├─ LaneRule              it differs, covers() / needsMen()
//     ├─ HoldBetweenRule
//     ├─ StraddleRule
//     └─ CoverOverTopRule
//   RuleBook                   rule code (tactic_job_rules) → its JobRule
//   Solver                     a state → our eleven spots + who is free/doubled
//
// A consumer differs only in how it fills the plain structs below (the
// backend from Postgres rows, the engine from its loaded plan) — nothing
// here touches a database, JSON or the network.  Header-only, C++17.
//
// THE CONTRACT in words is game/DESIGN.md §8.137 (the game session's
// file).  A rule change lands here, and the section is amended with it.
//
// Units: plan coordinates 0–100 from OUR view (x left → right as we
// attack, y 0 = our goal line).  Lengths are metres on a 68 × 105 pitch,
// so points convert to metres before any distance is taken.

#include <algorithm>
#include <cmath>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <string>
#include <vector>

namespace fh::tactics {

struct Point { double x = 0, y = 0; };

// The 0–100 plan pitch ↔ metres.
struct Pitch {
    static constexpr double W = 68.0, L = 105.0;
    static constexpr Point OUR_GOAL{50, 0};
    static constexpr Point THEIR_GOAL{50, 100};

    static Point toM(Point p) { return {p.x * W / 100.0, p.y * L / 100.0}; }
    static Point toPct(Point m) {
        const auto clamp = [](double v) { return std::max(0.0, std::min(100.0, v)); };
        return {clamp(m.x * 100.0 / W), clamp(m.y * 100.0 / L)};
    }
    // from + (toward − from) normalised × metres, in plan %.
    static Point step(Point from, Point toward, double metres) {
        const Point a = toM(from), b = toM(toward);
        const double dx = b.x - a.x, dy = b.y - a.y;
        double len = std::hypot(dx, dy);
        if (len == 0) len = 1;
        return toPct({a.x + dx / len * metres, a.y + dy / len * metres});
    }
    static Point lerp(Point a, Point b, double t) { return {a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t}; }
    static Point mean(const std::vector<Point>& ps) {
        Point m;
        if (ps.empty()) return m;
        for (const auto& p : ps) { m.x += p.x; m.y += p.y; }
        return {m.x / ps.size(), m.y / ps.size()};
    }
};

// ── The plan's rows, as plain data ──────────────────────────────────────

// tactic_job_kinds: a game concept as a job, placed by its rule.
struct JobKind {
    std::string code;
    std::string rule;                 // tactic_job_rules.code
    double distM = 0;
    std::optional<double> pressM;
    std::optional<double> laneT;
};

// tactic_jobs + tactic_job_targets: one of ours, his job, his men.
struct Job {
    int position = 0;                 // our position id 2–11
    std::string kind;                 // JobKind::code
    std::vector<int> targets;         // their numbers; A = the first
    std::optional<int> targetB;
    std::optional<int> partner;       // our position id (straddle pair)
    std::string stance = "goal_side"; // tactic_job_stances: goal_side | intercept
};

struct Opponent { int number = 0; Point at; };

// tactic_restarts: where we stay until the ball is played.  The zone is the
// box the Law keeps us out of (Law 16 goal kick = their penalty area);
// our_max_y is the line nobody of ours passes, across the whole width (goal
// kick = their 18, owner 11/7: "on goal kicks no player on def can be past
// 18").  Both hold.
struct RestartLaw {
    std::optional<double> ourMaxY, zoneMinX, zoneMaxX, zoneMinY;

    Point cap(Point p) const {
        if (zoneMinY && zoneMinX && zoneMaxX && p.x >= *zoneMinX && p.x <= *zoneMaxX && p.y > *zoneMinY)
            p.y = *zoneMinY;
        if (ourMaxY && p.y > *ourMaxY) p.y = *ourMaxY;
        return p;
    }
};

// One tactic_states row: ball with their #ballWith, where they stand, our jobs.
struct State {
    int ballWith = 1;
    std::vector<Opponent> opponents;
    std::vector<Job> jobs;
    std::optional<RestartLaw> law;
};

// Everything a state is solved against that is the plan's, not the state's.
struct PlanFrame {
    std::map<std::string, JobKind> kinds;     // by code
    std::map<int, Point> home;                // our formation spots by position id 1–11
    std::optional<double> gkY;                // tactic_block_heights.gk_y
    // The block's depth band (tactic_block_heights.back_y / front_y, mig
    // 1185): our outfield spots, deepest to highest, squeezed linearly into
    // back..front.  Unset (the high block) = the formation as drawn.
    std::optional<double> backY;
    std::optional<double> frontY;
};

// Our outfield formation spots moved into the block's depth band: the
// deepest man to back_y, the highest to front_y, everyone between in
// proportion, x untouched.  The keeper is the block's gk_y (Solver).
inline std::map<int, Point> blockHome(const PlanFrame& f) {
    std::map<int, Point> out = f.home;
    if (!f.backY || !f.frontY) return out;
    double lo = 1e9, hi = -1e9;
    for (const auto& [pid, p] : f.home) if (pid != 1) { lo = std::min(lo, p.y); hi = std::max(hi, p.y); }
    if (hi <= lo) return out;
    const double k = (*f.frontY - *f.backY) / (hi - lo);
    for (auto& [pid, p] : out) if (pid != 1) p.y = *f.backY + (p.y - lo) * k;
    return out;
}

// ── Parent: a placement rule ────────────────────────────────────────────

// What one of ours sees when his rule places him.
struct Placement {
    const Job& job;
    const JobKind& kind;
    const PlanFrame& frame;
    Point ball;
    Point home;                               // his formation spot
    std::vector<Point> men;                   // his targets that are on the pitch, in order
    std::optional<Point> b;                   // target B, when on the pitch
    int ballWith;
};

class JobRule {
public:
    virtual ~JobRule() = default;
    virtual const char* code() const = 0;

    // His spot.  Shared: a rule that needs men and has none keeps him home.
    Point spot(const Placement& p) const {
        if (needsMen() && p.men.empty()) return p.home;
        return place(p);
    }

    // Their numbers this job takes care of (the free / doubled check).
    // Shared: his targets.  Children add target B or skip a pair's twin.
    virtual void covers(const Job& j, std::set<int>& out) const {
        out.insert(j.targets.begin(), j.targets.end());
    }

protected:
    virtual bool needsMen() const { return true; }
    virtual Point place(const Placement& p) const = 0;

    // His men without the one on the ball (within 0.5 m — the straddle's
    // threshold).  A lane or a shadow from the ball to the man who HAS it
    // is no lane: 3-R2 "ball to their 5", 7 on "deter 5 and 3" was drawn on
    // top of 5 (11/7).  The lane rules average over these instead.
    static std::vector<Point> offBall(const Placement& p) {
        std::vector<Point> out;
        const Point bm = Pitch::toM(p.ball);
        for (const auto& man : p.men) {
            const Point m = Pitch::toM(man);
            if (std::hypot(m.x - bm.x, m.y - bm.y) >= 0.5) out.push_back(man);
        }
        return out;
    }
    // Every man he watches has the ball → he presses it: press_m (else
    // 1.5 m) goal-side of the ball.
    static Point onTheBall(const Placement& p) {
        return Pitch::step(p.ball, Pitch::OUR_GOAL, p.kind.pressM.value_or(1.5));
    }
};

// No movement: the formation spot, the concept is his instruction.
class HomeRule : public JobRule {
public:
    const char* code() const override { return "home"; }
protected:
    bool needsMen() const override { return false; }
    Point place(const Placement& p) const override { return p.home; }
};

// dist_m goal-side of A toward our goal; stance 'intercept' = ball-side.
class MarkRule : public JobRule {
public:
    const char* code() const override { return "mark"; }
protected:
    Point place(const Placement& p) const override {
        return Pitch::step(p.men[0], p.job.stance == "intercept" ? p.ball : Pitch::OUR_GOAL, p.kind.distM);
    }
};

// Tight on A: dist_m goal-side (the press kinds carry 1 m).
class PressRule : public JobRule {
public:
    const char* code() const override { return "press"; }
protected:
    Point place(const Placement& p) const override {
        return Pitch::step(p.men[0], Pitch::OUR_GOAL, p.kind.distM);
    }
};

// B has the ball → press_m from the ball along the mean direction ball →
// each shadowed man (pressing with all of them behind him); otherwise the
// mean of dist_m off each man toward the ball (sitting in the lanes; the
// man on the ball is no lane — offBall).
class CoverShadowRule : public JobRule {
public:
    const char* code() const override { return "cover_shadow"; }
    void covers(const Job& j, std::set<int>& out) const override {
        JobRule::covers(j, out);
        if (j.targetB) out.insert(*j.targetB);
    }
protected:
    Point place(const Placement& p) const override {
        if (p.job.targetB && *p.job.targetB == p.ballWith && p.b) {
            const Point bm = Pitch::toM(p.ball);
            Point d;
            for (const auto& man : p.men) {
                const Point m = Pitch::toM(man);
                const double dx = m.x - bm.x, dy = m.y - bm.y;
                double l = std::hypot(dx, dy);
                if (l == 0) l = 1;
                d.x += dx / l; d.y += dy / l;
            }
            d.x /= p.men.size(); d.y /= p.men.size();
            double l = std::hypot(d.x, d.y);
            if (l == 0) l = 1;
            const double pm = p.kind.pressM.value_or(1.5);
            return Pitch::toPct({bm.x + d.x / l * pm, bm.y + d.y / l * pm});
        }
        const std::vector<Point> men = offBall(p);
        if (men.empty()) return onTheBall(p);
        std::vector<Point> spots;
        for (const auto& man : men) spots.push_back(Pitch::step(man, p.ball, p.kind.distM));
        return Pitch::mean(spots);
    }
};

// In the passing lanes: the mean over his men of lane_t of the way ball →
// man (deter nearer the passer, read nearer the receivers).  The man on
// the ball is skipped; if he is the only one, press him.
class LaneRule : public JobRule {
public:
    const char* code() const override { return "lane"; }
protected:
    Point place(const Placement& p) const override {
        if (!p.kind.laneT) return p.home;
        const std::vector<Point> men = offBall(p);
        if (men.empty()) return onTheBall(p);
        std::vector<Point> spots;
        for (const auto& man : men) spots.push_back(Pitch::lerp(p.ball, man, *p.kind.laneT));
        return Pitch::mean(spots);
    }
};

// The midpoint of A and B, dist_m goal-side.
class HoldBetweenRule : public JobRule {
public:
    const char* code() const override { return "hold_between"; }
    void covers(const Job& j, std::set<int>& out) const override {
        JobRule::covers(j, out);
        if (j.targetB) out.insert(*j.targetB);
    }
protected:
    Point place(const Placement& p) const override {
        if (!p.b) return p.home;
        const Point a = p.men[0];
        return Pitch::step({(a.x + p.b->x) / 2, (a.y + p.b->y) / 2}, Pitch::OUR_GOAL, p.kind.distM);
    }
};

// Two of ours bookend A: each dist_m to his side across the ball → A line,
// press_m ball-side.  The one whose formation spot is further left takes
// the left.  Ball within 0.5 m of A → "toward the ball" is toward the
// centre of their goal (agreed with the game session 11/6).
class StraddleRule : public JobRule {
public:
    const char* code() const override { return "straddle"; }
    // The pair covers its man once — counted on the lower position id.
    void covers(const Job& j, std::set<int>& out) const override {
        if (j.partner && *j.partner < j.position) return;
        JobRule::covers(j, out);
    }
protected:
    Point place(const Placement& p) const override {
        if (!p.job.partner) return p.home;
        const auto mate = p.frame.home.find(*p.job.partner);
        const bool left = mate == p.frame.home.end() || p.home.x <= mate->second.x;
        const Point am = Pitch::toM(p.men[0]);
        Point bm = Pitch::toM(p.ball);
        if (std::hypot(bm.x - am.x, bm.y - am.y) < 0.5) bm = Pitch::toM(Pitch::THEIR_GOAL);
        double ux = bm.x - am.x, uy = bm.y - am.y;
        double len = std::hypot(ux, uy);
        if (len == 0) len = 1;
        ux /= len; uy /= len;
        double px = -uy, py = ux;                                     // perpendicular
        if (px > 0 || (px == 0 && py > 0)) { px = -px; py = -py; }    // point it left
        const double side = left ? 1 : -1, d = p.kind.distM, f = p.kind.pressM.value_or(0);
        return Pitch::toPct({am.x + ux * f + px * d * side, am.y + uy * f + py * d * side});
    }
};

// Covers the presser from behind A (owner 11/7: "our 4 … does not have to
// initially be in tight coverage of their 11 but instead be back and in and
// cover the ball over the top of the 11 … also help with support coverage
// of the 9").  lane_t of the way from A toward B, then dist_m toward our
// goal: deep enough to win the ball played over A, close enough to back up
// whoever is on B.  No B → dist_m straight goal-side of A.
class CoverOverTopRule : public JobRule {
public:
    const char* code() const override { return "cover_over_top"; }
    void covers(const Job& j, std::set<int>& out) const override {
        JobRule::covers(j, out);
        if (j.targetB) out.insert(*j.targetB);
    }
protected:
    Point place(const Placement& p) const override {
        const Point a = p.men[0];
        const Point in = p.b ? Pitch::lerp(a, *p.b, p.kind.laneT.value_or(0.33)) : a;
        return Pitch::step(in, Pitch::OUR_GOAL, p.kind.distM);
    }
};

// ── The rule book: tactic_job_rules.code → its rule ─────────────────────
class RuleBook {
public:
    RuleBook() {
        add<HomeRule>(); add<MarkRule>(); add<PressRule>(); add<CoverShadowRule>();
        add<LaneRule>(); add<HoldBetweenRule>(); add<StraddleRule>(); add<CoverOverTopRule>();
    }
    // nullptr = a rule this build doesn't know (the man stays home).
    const JobRule* find(const std::string& code) const {
        const auto it = rules_.find(code);
        return it == rules_.end() ? nullptr : it->second.get();
    }
    static const RuleBook& instance() { static const RuleBook book; return book; }

private:
    template <class R> void add() { auto r = std::make_unique<R>(); const std::string c = r->code(); rules_[c] = std::move(r); }
    std::map<std::string, std::unique_ptr<JobRule>> rules_;
};

// ── Solver ──────────────────────────────────────────────────────────────
struct Spot { int position = 0; Point at; };

struct Solution {
    Point ball;
    std::vector<Spot> players;        // positions 1–11 in id order
    std::vector<int> freeMen;         // their numbers no job takes care of
    std::vector<int> doubledMen;      // their numbers two or more jobs take care of
};

class Solver {
public:
    explicit Solver(const RuleBook& book = RuleBook::instance()) : book_(book) {}

    Solution solve(const State& s, const PlanFrame& raw) const {
        // Every rule sees the block's home spots (blockHome), so a man with
        // no job, or a rule that falls back to home, sits in the block.
        PlanFrame f = raw;
        f.home = blockHome(raw);
        Solution out;
        std::map<int, Point> opp;
        for (const auto& o : s.opponents) opp[o.number] = o.at;
        const auto ballMan = opp.find(s.ballWith);
        out.ball = ballMan != opp.end() ? ballMan->second : Point{50, 95};

        std::map<int, const Job*> jobs;
        for (const auto& j : s.jobs) jobs[j.position] = &j;

        for (int pid = 1; pid <= 11; ++pid) {
            const auto h = f.home.find(pid);
            const Point home = h != f.home.end() ? h->second : Point{50, 30};
            Point spot = home;
            if (pid == 1) spot = {50, f.gkY.value_or(home.y)};
            const auto jt = jobs.find(pid);
            if (pid != 1 && jt != jobs.end()) {
                const Job& job = *jt->second;
                const auto kt = f.kinds.find(job.kind);
                const JobRule* rule = kt != f.kinds.end() ? book_.find(kt->second.rule) : nullptr;
                if (rule) {
                    std::vector<Point> men;
                    for (int n : job.targets) { const auto o = opp.find(n); if (o != opp.end()) men.push_back(o->second); }
                    std::optional<Point> b;
                    if (job.targetB) { const auto o = opp.find(*job.targetB); if (o != opp.end()) b = o->second; }
                    spot = rule->spot(Placement{job, kt->second, f, out.ball, home, std::move(men), b, s.ballWith});
                }
            }
            if (s.law && pid != 1) spot = s.law->cap(spot);
            out.players.push_back({pid, spot});
        }

        std::map<int, int> count;
        for (const auto& j : s.jobs) {
            const auto kt = f.kinds.find(j.kind);
            const JobRule* rule = kt != f.kinds.end() ? book_.find(kt->second.rule) : nullptr;
            std::set<int> men;
            if (rule) rule->covers(j, men);
            else men.insert(j.targets.begin(), j.targets.end());
            for (int n : men) ++count[n];
        }
        std::vector<int> nums;
        for (const auto& [n, _] : opp) nums.push_back(n);   // map → ascending
        for (int n : nums) {
            const auto c = count.find(n);
            if (c == count.end()) out.freeMen.push_back(n);
            else if (c->second > 1) out.doubledMen.push_back(n);
        }
        return out;
    }

private:
    const RuleBook& book_;
};

}  // namespace fh::tactics
