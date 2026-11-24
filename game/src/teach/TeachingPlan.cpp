// game/src/teach/TeachingPlan.cpp — see TeachingPlan.hpp. The queries mirror
// backend/src/models/TacticPlans.cpp (planFrame, restartLaws, plan), so the room solves
// exactly what the board draws.

#include "teach/TeachingPlan.hpp"

#include <pqxx/pqxx>

#include <cstdio>

namespace fh::game::teach {

namespace tg = fh::tactics;

const PlanState* Plan::next(const PlanState* from, int n) const {
    const PlanState* r = root();
    if (!r) return nullptr;
    if (from)
        for (const auto& s : states) if (s.parent == from->id && s.ball_with == n) return &s;
    for (const auto& s : states) if (s.parent == r->id && s.ball_with == n) return &s;
    if (r->ball_with == n) return r;
    return nullptr;
}

namespace {

std::optional<double> optNum(const pqxx::field& f) {
    if (f.is_null()) return std::nullopt;
    return f.as<double>();
}

// A formation as the board numbers it: formation_slot_roles.number, else positions_json's
// position_id (the shirt number in every formation since mig 611).
std::optional<ai::FormationSpec> loadShape(pqxx::work& tx, const std::string& code) {
    const auto rows = tx.exec_params(
        "SELECT (p->>'x')::int, (p->>'y')::int, p->>'label', "
        "       COALESCE(r.number, (p->>'position_id')::int, 0), COALESCE(r.role, '') "
        "  FROM formations f CROSS JOIN LATERAL jsonb_array_elements(f.positions_json) p "
        "  LEFT JOIN formation_slot_roles r ON r.formation_code = f.code AND r.slot = (p->>'slot')::int "
        " WHERE f.code = $1 ORDER BY (p->>'slot')::int",
        code);
    if (rows.size() != 11) return std::nullopt;
    ai::FormationSpec spec;
    bool keeper = false;
    for (const auto& row : rows) {
        const bool gk = row[2].as<std::string>() == "GK";
        keeper = keeper || gk;
        spec.positions.push_back(persistence::mapClubPosition(row[0].as<int>(), row[1].as<int>(), gk));
        spec.positions.back().number = static_cast<std::int16_t>(row[3].as<int>());
        spec.positions.back().role = row[4].as<std::string>();
    }
    if (!keeper) return std::nullopt;
    return spec;
}

}  // namespace

std::optional<Plan> loadPlan(const persistence::DbConfig& cfg, int plan_id) {
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        const auto head = tx.exec_params(
            "SELECT p.formation_id, f.code, o.code, p.block_height "
            "  FROM tactic_plans p JOIN formations f ON f.id = p.formation_id "
            "  JOIN formations o ON o.id = p.opponent_formation_id WHERE p.id = $1",
            plan_id);
        if (head.empty()) return std::nullopt;
        Plan plan;
        plan.id = plan_id;
        const int formation_id = head[0][0].as<int>();
        plan.us_code = head[0][1].as<std::string>();
        plan.them_code = head[0][2].as<std::string>();
        plan.block = head[0][3].as<std::string>();

        auto us = loadShape(tx, plan.us_code);
        auto them = loadShape(tx, plan.them_code);
        if (!us || !them) {
            std::fprintf(stderr, "fh-game: teaching plan %d: formation '%s' or '%s' can't be fielded\n", plan_id,
                         plan.us_code.c_str(), plan.them_code.c_str());
            return std::nullopt;
        }
        plan.us = std::move(*us);
        plan.them = std::move(*them);

        for (const auto& r : tx.exec(
                 "SELECT k.code, k.rule, k.dist_m::float8, k.press_m::float8, k.lane_t::float8, c.id, c.name, c.title "
                 "  FROM tactic_job_kinds k JOIN game_concepts c ON c.id = k.concept_id")) {
            const std::string code = r[0].as<std::string>();
            plan.frame.kinds[code] = {code, r[1].as<std::string>(), r[2].as<double>(), optNum(r[3]), optNum(r[4])};
            plan.concepts[code] = {r[5].as<int>(), r[6].as<std::string>(), r[7].as<std::string>()};
        }
        if (tx.exec("SELECT to_regclass('game_engine_behaviours') IS NOT NULL")[0][0].as<bool>())
            for (const auto& r : tx.exec("SELECT b.code, c.id, c.name, c.title FROM game_engine_behaviours b "
                                         "JOIN game_concepts c ON c.id = b.concept_id"))
                plan.behaviours[r[0].as<std::string>()] = {r[1].as<int>(), r[2].as<std::string>(), r[3].as<std::string>()};
        for (const auto& r : tx.exec_params(
                 "SELECT DISTINCT ON (num) num, x, y FROM ("
                 "  SELECT COALESCE(r.number, (p->>'position_id')::int) AS num, (p->>'slot')::int AS slot, "
                 "         (p->>'x')::float8 AS x, (p->>'y')::float8 AS y "
                 "    FROM formations f CROSS JOIN LATERAL jsonb_array_elements(f.positions_json) p "
                 "    LEFT JOIN formation_slot_roles r ON r.formation_code = f.code AND r.slot = (p->>'slot')::int "
                 "   WHERE f.id = $1) s WHERE num BETWEEN 1 AND 11 ORDER BY num, slot",
                 formation_id))
            plan.frame.home[r[0].as<int>()] = {r[1].as<double>(), r[2].as<double>()};
        const auto bh = tx.exec_params(
            "SELECT gk_y::float8, back_y::float8, front_y::float8 FROM tactic_block_heights WHERE code = $1", plan.block);
        if (!bh.empty()) {
            plan.frame.gkY = optNum(bh[0][0]);
            plan.frame.backY = optNum(bh[0][1]);
            plan.frame.frontY = optNum(bh[0][2]);
        }
        std::map<std::string, tg::RestartLaw> laws;
        for (const auto& r : tx.exec("SELECT code, our_max_y::float8, zone_min_x::float8, zone_max_x::float8, "
                                     "       zone_min_y::float8 FROM tactic_restarts"))
            laws[r[0].as<std::string>()] = {optNum(r[1]), optNum(r[2]), optNum(r[3]), optNum(r[4])};

        // The plan's own steps; a 📋 copied frame is a picture, not a step.
        std::map<int, std::size_t> at;
        for (const auto& r : tx.exec_params(
                 "SELECT id, COALESCE(parent_state_id, 0), ball_with, restart FROM tactic_states "
                 " WHERE plan_id = $1 AND copied_from IS NULL ORDER BY parent_state_id NULLS FIRST, id",
                 plan_id)) {
            PlanState s;
            s.id = r[0].as<int>();
            s.parent = r[1].as<int>();
            s.ball_with = r[2].as<int>();
            if (!r[3].is_null())
                if (const auto it = laws.find(r[3].as<std::string>()); it != laws.end()) s.law = it->second;
            at[s.id] = plan.states.size();
            plan.states.push_back(std::move(s));
        }
        if (plan.states.empty() || plan.states.front().parent != 0) return std::nullopt;
        std::map<std::pair<int, int>, std::vector<int>> targets;
        for (const auto& r : tx.exec_params(
                 "SELECT t.state_id, t.position_id, t.number FROM tactic_job_targets t "
                 "  JOIN tactic_states s ON s.id = t.state_id WHERE s.plan_id = $1 ORDER BY t.ord, t.number",
                 plan_id))
            targets[{r[0].as<int>(), r[1].as<int>()}].push_back(r[2].as<int>());
        for (const auto& r : tx.exec_params(
                 "SELECT j.state_id, j.position_id, j.kind, j.target_b, j.partner_position_id, j.stance "
                 "  FROM tactic_jobs j JOIN tactic_states s ON s.id = j.state_id WHERE s.plan_id = $1",
                 plan_id)) {
            const auto it = at.find(r[0].as<int>());
            if (it == at.end()) continue;
            tg::Job j;
            j.position = r[1].as<int>();
            j.kind = r[2].as<std::string>();
            if (!r[3].is_null()) j.targetB = r[3].as<int>();
            if (!r[4].is_null()) j.partner = r[4].as<int>();
            j.stance = r[5].as<std::string>();
            j.targets = targets[{r[0].as<int>(), j.position}];
            plan.states[it->second].jobs.push_back(std::move(j));
        }
        return plan;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: teaching plan %d load failed: %s\n", plan_id, e.what());
        return std::nullopt;
    }
}

}  // namespace fh::game::teach
