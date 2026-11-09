#include "TacticPlans.h"

#include "../database/Database.h"

#include <tactics/TacticGeometry.hpp>   // shared/ — the same rules the game engine plays

#include <stdexcept>

using nlohmann::json;

namespace {

// A slot's number is formation_slot_roles.number — what the game engine
// reads — else positions_json's position_id (the shirt number in every
// formation since mig 611; the old seed rows carry role ids there, which
// repeat).  One row per number.
constexpr const char* kSlotsSql =
    "SELECT DISTINCT ON (num) num AS pid, x, y FROM ("
    "  SELECT COALESCE(r.number, (p->>'position_id')::int) AS num, (p->>'slot')::int AS slot, "
    "         (p->>'x')::float8 AS x, (p->>'y')::float8 AS y "
    "    FROM formations f CROSS JOIN LATERAL jsonb_array_elements(f.positions_json) p "
    "    LEFT JOIN formation_slot_roles r ON r.formation_code = f.code AND r.slot = (p->>'slot')::int "
    "   WHERE f.id = $1::int) s "
    " WHERE num BETWEEN 1 AND 11 ORDER BY num, slot";

// A formation's slots as {position_id, x, y} (club scheme, y up from our goal).
json formationSpots(Database* db, long long formationId) {
    json out = json::array();
    for (const auto& r : db->query(kSlotsSql, {std::to_string(formationId)}))
        out.push_back({{"position_id", r["pid"].as<int>()}, {"x", r["x"].as<double>()}, {"y", r["y"].as<double>()}});
    return out;
}

// Theirs attack down the pitch: mirror both axes (their right = our left).
json mirrored(const json& spots) {
    json out = json::array();
    for (const auto& s : spots)
        out.push_back({{"number", s["position_id"]}, {"x", 100.0 - s["x"].get<double>()}, {"y", 100.0 - s["y"].get<double>()}});
    return out;
}

// ── Shared geometry (shared/tactics/TacticGeometry.hpp) ────────────────
// The backend's only job here is filling the library's plain structs from
// the plan's rows; the rules themselves are the library's.
namespace tg = fh::tactics;

std::optional<double> optNum(const pqxx::field& f) {
    if (f.is_null()) return std::nullopt;
    return f.as<double>();
}

// Kinds, our formation spots and the block's keeper depth.
tg::PlanFrame planFrame(Database* db, long long formationId, const std::string& block) {
    tg::PlanFrame f;
    for (const auto& r : db->query(
             "SELECT code, rule, dist_m::float8 AS dist_m, press_m::float8 AS press_m, lane_t::float8 AS lane_t FROM tactic_job_kinds"))
        f.kinds[r["code"].as<std::string>()] = {r["code"].as<std::string>(), r["rule"].as<std::string>(),
                                                r["dist_m"].as<double>(), optNum(r["press_m"]), optNum(r["lane_t"])};
    for (const auto& r : db->query(kSlotsSql, {std::to_string(formationId)}))
        f.home[r["pid"].as<int>()] = {r["x"].as<double>(), r["y"].as<double>()};
    auto gk = db->query("SELECT gk_y::float8 AS gk_y, back_y::float8 AS back_y, front_y::float8 AS front_y "
                        "FROM tactic_block_heights WHERE code = $1", {block});
    if (!gk.empty()) {
        f.gkY = gk[0]["gk_y"].as<double>();
        f.backY = optNum(gk[0]["back_y"]);    // the block's depth band (mig 1185)
        f.frontY = optNum(gk[0]["front_y"]);
    }
    return f;
}

std::map<std::string, tg::RestartLaw> restartLaws(Database* db) {
    std::map<std::string, tg::RestartLaw> out;
    for (const auto& r : db->query(
             "SELECT code, our_max_y::float8 AS our_max_y, zone_min_x::float8 AS zone_min_x, "
             "       zone_max_x::float8 AS zone_max_x, zone_min_y::float8 AS zone_min_y FROM tactic_restarts"))
        out[r["code"].as<std::string>()] = {optNum(r["our_max_y"]), optNum(r["zone_min_x"]), optNum(r["zone_max_x"]), optNum(r["zone_min_y"])};
    return out;
}

// A state as the API carries it: { ball_with, restart, opponents: [{number,x,y}],
// jobs: [{position_id,kind,targets,target_b,partner_position_id,stance}] }.
tg::State stateFromJson(const json& st, const std::map<std::string, tg::RestartLaw>& laws) {
    tg::State s;
    s.ballWith = st.value("ball_with", 1);
    if (st.contains("restart") && st["restart"].is_string()) {
        const auto it = laws.find(st["restart"].get<std::string>());
        if (it != laws.end()) s.law = it->second;
    }
    for (const auto& o : st.value("opponents", json::array()))
        s.opponents.push_back({o.at("number").get<int>(), {o.at("x").get<double>(), o.at("y").get<double>()}});
    for (const auto& j : st.value("jobs", json::array())) {
        tg::Job job;
        job.position = j.at("position_id").get<int>();
        job.kind = j.at("kind").get<std::string>();
        for (const auto& t : j.value("targets", json::array())) job.targets.push_back(t.get<int>());
        if (j.contains("target_b") && j["target_b"].is_number_integer()) job.targetB = j["target_b"].get<int>();
        if (j.contains("partner_position_id") && j["partner_position_id"].is_number_integer()) job.partner = j["partner_position_id"].get<int>();
        if (j.contains("stance") && j["stance"].is_string()) job.stance = j["stance"].get<std::string>();
        s.jobs.push_back(std::move(job));
    }
    return s;
}

// { ball: {x,y}, players: [{position_id,x,y}], free: [n], doubled: [n] }
json solutionJson(const tg::Solution& sol) {
    json out = {{"ball", {{"x", sol.ball.x}, {"y", sol.ball.y}}}, {"players", json::array()},
                {"free", sol.freeMen}, {"doubled", sol.doubledMen}};
    for (const auto& p : sol.players)
        out["players"].push_back({{"position_id", p.position}, {"x", p.at.x}, {"y", p.at.y}});
    return out;
}

}  // namespace

json TacticPlans::lookups() {
    auto* db = Database::getInstance();
    json out = {{"moments", json::array()}, {"blocks", json::array()}, {"kinds", json::array()}, {"stances", json::array()}};
    out["restarts"] = json::array();
    // Law zones (mig 1145, game session): the box opponents are kept out of.
    const auto num = [](const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.as<double>()); };
    for (const auto& r : db->query(
             "SELECT code, label, law, our_max_y::float8 AS our_max_y, zone, zone_min_x::float8 AS zone_min_x, "
             "       zone_max_x::float8 AS zone_max_x, zone_min_y::float8 AS zone_min_y FROM tactic_restarts ORDER BY code"))
        out["restarts"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                   {"law", r["law"].as<std::string>()}, {"our_max_y", num(r["our_max_y"])},
                                   {"zone", r["zone"].is_null() ? json(nullptr) : json(r["zone"].as<std::string>())},
                                   {"zone_min_x", num(r["zone_min_x"])}, {"zone_max_x", num(r["zone_max_x"])},
                                   {"zone_min_y", num(r["zone_min_y"])}});
    out["shortcuts"] = shortcuts();
    for (const auto& r : db->query("SELECT code, label FROM tactic_job_stances ORDER BY sort_order"))
        out["stances"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, title FROM game_moments ORDER BY sort_order"))
        out["moments"].push_back({{"code", r["code"].as<std::string>()}, {"title", r["title"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, label, gk_y::float8 AS gk_y FROM tactic_block_heights ORDER BY sort_order"))
        out["blocks"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                 {"gk_y", r["gk_y"].as<double>()}});
    for (const auto& r : db->query(
             "SELECT k.code, k.concept_id, c.name AS concept, c.title AS concept_title, c.cue_answer, c.family, c.moment, k.rule, "
             "       k.label, k.target_a_label, k.target_b_label, k.partner_label, "
             "       k.dist_m::float8 AS dist_m, k.press_m::float8 AS press_m, k.multi_a, k.lane_t::float8 AS lane_t "
             "  FROM tactic_job_kinds k JOIN game_concepts c ON c.id = k.concept_id ORDER BY k.sort_order")) {
        out["kinds"].push_back({{"code", r["code"].as<std::string>()},
                                {"concept_id", r["concept_id"].as<int>()},
                                {"concept", r["concept"].as<std::string>()},
                                {"concept_title", r["concept_title"].as<std::string>()},
                                {"cue", r["cue_answer"].as<std::string>()},
                                {"label", r["label"].as<std::string>()},
                                {"target_a_label", r["target_a_label"].is_null() ? json(nullptr) : json(r["target_a_label"].as<std::string>())},
                                {"rule", r["rule"].as<std::string>()},
                                {"family", r["family"].as<std::string>()},
                                {"moment", r["moment"].as<std::string>()},
                                {"target_b_label", r["target_b_label"].is_null() ? json(nullptr) : json(r["target_b_label"].as<std::string>())},
                                {"partner_label", r["partner_label"].is_null() ? json(nullptr) : json(r["partner_label"].as<std::string>())},
                                {"dist_m", r["dist_m"].as<double>()},
                                {"press_m", r["press_m"].is_null() ? json(nullptr) : json(r["press_m"].as<double>())},
                                {"multi_a", r["multi_a"].as<bool>()},
                                {"lane_t", r["lane_t"].is_null() ? json(nullptr) : json(r["lane_t"].as<double>())}});
    }
    return out;
}

json TacticPlans::shortcuts() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
             "SELECT s.kind FROM tactic_job_shortcuts s JOIN tactic_job_kinds k ON k.code = s.kind "
             " WHERE s.on_list ORDER BY k.sort_order, s.kind"))
        out.push_back(r["kind"].as<std::string>());
    return out;
}

bool TacticPlans::setShortcut(const std::string& kind, bool on, long long byUserId) {
    auto* db = Database::getInstance();
    if (db->query("SELECT 1 FROM tactic_job_kinds WHERE code = $1", {kind}).empty()) return false;
    db->query("INSERT INTO tactic_job_shortcuts (kind, on_list, changed_by_user_id, changed_at) VALUES ($1, $2::boolean, NULLIF($3, '0')::int, now()) "
              "ON CONFLICT (kind) DO UPDATE SET on_list = EXCLUDED.on_list, changed_by_user_id = EXCLUDED.changed_by_user_id, changed_at = now()",
              {kind, on ? "true" : "false", std::to_string(byUserId)});
    return true;
}

json TacticPlans::find(long long formationId, long long opponentFormationId,
                       const std::string& moment, const std::string& block) {
    auto* db = Database::getInstance();
    json out = {{"plan", nullptr}, {"states", json::array()},
                {"our_positions", formationSpots(db, formationId)},
                {"opponent_base", mirrored(formationSpots(db, opponentFormationId))}};
    auto plan = db->query(
        "SELECT id FROM tactic_plans WHERE formation_id = $1::int AND opponent_formation_id = $2::int "
        "   AND moment = $3 AND block_height = $4",
        {std::to_string(formationId), std::to_string(opponentFormationId), moment, block});
    if (plan.empty()) return out;
    const std::string planId = plan[0]["id"].as<std::string>();
    out["plan"] = {{"id", plan[0]["id"].as<long long>()}};

    const tg::PlanFrame frame = planFrame(db, formationId, block);
    const auto laws = restartLaws(db);
    const json opponentBase = out["opponent_base"];
    for (const auto& s : db->query(
             "SELECT id, parent_state_id, ball_with, restart, (copied_from->'source')::text AS copied FROM tactic_states WHERE plan_id = $1::int "
             " ORDER BY parent_state_id IS NOT NULL, id", {planId})) {
        const std::string sid = s["id"].as<std::string>();
        json st = {{"id", s["id"].as<long long>()},
                   {"parent_state_id", s["parent_state_id"].is_null() ? json(nullptr) : json(s["parent_state_id"].as<long long>())},
                   {"ball_with", s["ball_with"].as<int>()},
                   {"restart", s["restart"].is_null() ? json(nullptr) : json(s["restart"].as<std::string>())},
                   {"copied_from", s["copied"].is_null() ? json(nullptr) : json::parse(s["copied"].as<std::string>())},
                   {"opponents", json::array()}, {"jobs", json::array()}};
        for (const auto& o : db->query(
                 "SELECT number, x::float8 AS x, y::float8 AS y FROM tactic_state_opponents WHERE state_id = $1::int ORDER BY number", {sid}))
            st["opponents"].push_back({{"number", o["number"].as<int>()}, {"x", o["x"].as<double>()}, {"y", o["y"].as<double>()}});
        for (const auto& j : db->query(
                 "SELECT j.position_id, j.kind, j.target_b, j.partner_position_id, j.stance, "
                 "       COALESCE((SELECT json_agg(t.number ORDER BY t.ord, t.number) FROM tactic_job_targets t "
                 "                  WHERE t.state_id = j.state_id AND t.position_id = j.position_id)::text, '[]') AS targets "
                 "  FROM tactic_jobs j WHERE j.state_id = $1::int ORDER BY j.position_id", {sid}))
            st["jobs"].push_back({{"position_id", j["position_id"].as<int>()}, {"kind", j["kind"].as<std::string>()},
                                  {"targets", json::parse(j["targets"].as<std::string>())},
                                  {"stance", j["stance"].as<std::string>()},
                                  {"target_b", j["target_b"].is_null() ? json(nullptr) : json(j["target_b"].as<int>())},
                                  {"partner_position_id", j["partner_position_id"].is_null() ? json(nullptr) : json(j["partner_position_id"].as<int>())}});
        // A state with no stored men plays against their formation mirrored.
        json asSolved = st;
        if (asSolved["opponents"].empty()) asSolved["opponents"] = opponentBase;
        st["solved"] = solutionJson(tg::Solver().solve(stateFromJson(asSolved, laws), frame));
        out["states"].push_back(std::move(st));
    }
    return out;
}

json TacticPlans::solve(long long formationId, const std::string& block, const json& state) {
    auto* db = Database::getInstance();
    return solutionJson(tg::Solver().solve(stateFromJson(state, restartLaws(db)), planFrame(db, formationId, block)));
}

long long TacticPlans::create(long long formationId, long long opponentFormationId,
                              const std::string& moment, const std::string& block, long long byUserId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto ok = tx->exec_params(
            "SELECT EXISTS (SELECT 1 FROM formations WHERE id = $1::int) "
            "   AND EXISTS (SELECT 1 FROM formations WHERE id = $2::int) "
            "   AND EXISTS (SELECT 1 FROM game_moments WHERE code = $3::text) "
            "   AND EXISTS (SELECT 1 FROM tactic_block_heights WHERE code = $4::text) AS ok",
            formationId, opponentFormationId, moment, block);
        if (!ok[0]["ok"].as<bool>()) { db->rollback(tx); return 0; }
        auto ins = tx->exec_params(
            "INSERT INTO tactic_plans (formation_id, opponent_formation_id, moment, block_height, created_by_user_id) "
            "VALUES ($1, $2, $3, $4, $5) ON CONFLICT (formation_id, opponent_formation_id, moment, block_height) DO NOTHING RETURNING id",
            formationId, opponentFormationId, moment, block, byUserId);
        if (ins.empty()) {
            auto ex = tx->exec_params(
                "SELECT id FROM tactic_plans WHERE formation_id = $1 AND opponent_formation_id = $2 AND moment = $3 AND block_height = $4",
                formationId, opponentFormationId, moment, block);
            db->commit(tx);
            return ex[0]["id"].as<long long>();
        }
        const long long planId = ins[0]["id"].as<long long>();
        // Out of possession the root is their keeper placing the ball: a goal
        // kick (Law 16, tactic_restarts — mig 1142).
        auto st = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, ball_with, restart) "
            "VALUES ($1, 1, CASE WHEN $2::text = 'out_of_possession' THEN 'goal_kick' END) RETURNING id", planId, moment);
        const long long rootId = st[0]["id"].as<long long>();
        // Out of possession, their GK on the ball = their build-out from a
        // goal kick (tactic_buildout_shapes, mig 1129: CBs split inside the
        // box, full-backs high and wide).  Otherwise, or with no shape for
        // that formation, their formation mirrored: their right on our left.
        auto shaped = moment == "out_of_possession"
            ? tx->exec_params(
                  "INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                  "SELECT $1, number, x, y FROM tactic_buildout_shapes WHERE formation_id = $2 RETURNING number",
                  rootId, opponentFormationId)
            : pqxx::result{};
        if (shaped.empty())
            tx->exec_params(
                std::string("INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                            "SELECT $2::int, pid, 100 - x, 100 - y FROM (") + kSlotsSql + ") q "
                "ON CONFLICT DO NOTHING",
                opponentFormationId, rootId);
        db->commit(tx);
        return planId;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

long long TacticPlans::addState(long long parentStateId, int ballWith) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto parent = tx->exec_params("SELECT plan_id FROM tactic_states WHERE id = $1", parentStateId);
        if (parent.empty()) { db->rollback(tx); return 0; }
        const long long planId = parent[0]["plan_id"].as<long long>();
        auto ins = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, parent_state_id, ball_with) VALUES ($1, $2, $3) "
            "ON CONFLICT (plan_id, parent_state_id, ball_with) WHERE copied_from IS NULL DO NOTHING RETURNING id",
            planId, parentStateId, ballWith);
        long long id;
        if (ins.empty()) {
            id = tx->exec_params("SELECT id FROM tactic_states WHERE plan_id = $1 AND parent_state_id = $2 AND ball_with = $3 AND copied_from IS NULL",
                                 planId, parentStateId, ballWith)[0]["id"].as<long long>();
        } else {
            id = ins[0]["id"].as<long long>();
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) "
                            "SELECT $1, number, x, y FROM tactic_state_opponents WHERE state_id = $2", id, parentStateId);
            tx->exec_params("INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance) "
                            "SELECT $1, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = $2", id, parentStateId);
            tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) "
                            "SELECT $1, position_id, number, ord FROM tactic_job_targets WHERE state_id = $2", id, parentStateId);
            tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", planId);
        }
        db->commit(tx);
        return id;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

bool TacticPlans::putState(long long stateId, const json& body) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto st = tx->exec_params("SELECT plan_id FROM tactic_states WHERE id = $1", stateId);
        if (st.empty()) { db->rollback(tx); return false; }
        tx->exec_params("DELETE FROM tactic_state_opponents WHERE state_id = $1", stateId);
        tx->exec_params("DELETE FROM tactic_jobs WHERE state_id = $1", stateId);
        for (const auto& o : body.at("opponents"))
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) VALUES ($1, $2, $3, $4)",
                            stateId, o.at("number").get<int>(), o.at("x").get<double>(), o.at("y").get<double>());
        for (const auto& j : body.at("jobs")) {
            const bool hasB = j.contains("target_b") && j["target_b"].is_number_integer();
            const bool hasP = j.contains("partner_position_id") && j["partner_position_id"].is_number_integer();
            const std::string kind = j.at("kind").get<std::string>();
            const auto& targets = j.at("targets");
            auto k = tx->exec_params("SELECT multi_a, target_a_label IS NULL AS names_nobody FROM tactic_job_kinds WHERE code = $1", kind);
            if (k.empty()) throw std::runtime_error("unknown job kind: " + kind);
            // A kind with no target label (line-hold, compact-block, the 'home'
            // rule) names nobody; every other kind needs at least one man.
            if (targets.empty() && !k[0]["names_nobody"].as<bool>())
                throw std::runtime_error("job " + kind + " needs one of their men");
            if (!k[0]["multi_a"].as<bool>() && targets.size() > 1)
                throw std::runtime_error("job " + kind + " takes one man");
            const int pid = j.at("position_id").get<int>();
            tx->exec_params(
                "INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance) "
                "VALUES ($1, $2, $3, CASE WHEN $4::boolean THEN $5::smallint END, CASE WHEN $6::boolean THEN $7::smallint END, $8)",
                stateId, pid, kind, hasB, hasB ? j["target_b"].get<int>() : 0,
                hasP, hasP ? j["partner_position_id"].get<int>() : 0, j.value("stance", std::string("goal_side")));
            int ord = 1;
            for (const auto& t : targets)
                tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES ($1, $2, $3, $4)",
                                stateId, pid, t.get<int>(), ord++);
        }
        tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", st[0]["plan_id"].as<long long>());
        db->commit(tx);
        return true;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

json TacticPlans::copyFromGame(const json& b, long long byUserId) {
    auto* db = Database::getInstance();
    auto formationOf = [&](const std::string& team) -> long long {
        auto r = db->query("SELECT f.id FROM game_demo_teams t JOIN formations f ON f.code = t.formation_code "
                           " WHERE t.name = $1 LIMIT 1", {team});
        return r.empty() ? 0 : r[0]["id"].as<long long>();
    };
    const std::string usTeam = b.value("us_team", std::string()), themTeam = b.value("them_team", std::string());
    const long long us = formationOf(usTeam), them = formationOf(themTeam);
    if (!us) return {{"error", "No formation for team: " + usTeam}};
    if (!them) return {{"error", "No formation for team: " + themTeam}};
    const std::string moment = b.value("moment", std::string("out_of_possession"));
    // The block from where the ball is, in our frame (y 0 = our goal line):
    // in their third we're pressing high, in ours we're in a low block.
    const double ballY = b.at("ball").at("y").get<double>();
    const std::string block = ballY >= 66.7 ? "high" : ballY >= 33.3 ? "mid" : "low";
    const long long planId = create(us, them, moment, block, byUserId);
    if (!planId) return {{"error", "Unknown formation, moment or block."}};

    // Their man on the ball, else the one nearest it.
    int ballWith = b.contains("ball_with") && b["ball_with"].is_number_integer() ? b["ball_with"].get<int>() : 0;
    if (ballWith < 1 || ballWith > 11) {
        const double bx = b["ball"]["x"].get<double>() * 0.68, by = ballY * 1.05;
        double best = 1e18;
        for (const auto& o : b.at("opponents")) {
            const double dx = o["x"].get<double>() * 0.68 - bx, dy = o["y"].get<double>() * 1.05 - by, d = dx * dx + dy * dy;
            if (d < best) { best = d; ballWith = o["number"].get<int>(); }
        }
    }

    auto tx = db->beginTransaction();
    try {
        auto root = tx->exec_params("SELECT id FROM tactic_states WHERE plan_id = $1 AND parent_state_id IS NULL", planId);
        if (root.empty()) { db->rollback(tx); return {{"error", "Plan has no root."}}; }
        const long long rootId = root[0]["id"].as<long long>();
        const json copied = {{"source", b.value("source", json::object())}, {"ball", b["ball"]},
                             {"ours", b.value("ours", json::array())}, {"by_user_id", byUserId}};
        auto st = tx->exec_params(
            "INSERT INTO tactic_states (plan_id, parent_state_id, ball_with, copied_from) "
            "VALUES ($1, $2, $3, $4::jsonb || jsonb_build_object('at', now())) RETURNING id",
            planId, rootId, ballWith, copied.dump());
        const long long stateId = st[0]["id"].as<long long>();
        for (const auto& o : b.at("opponents"))
            tx->exec_params("INSERT INTO tactic_state_opponents (state_id, number, x, y) VALUES ($1, $2, $3, $4)",
                            stateId, o.at("number").get<int>(), o.at("x").get<double>(), o.at("y").get<double>());
        int jobs = 0;
        json skipped = json::array();
        for (const auto& m : b.value("ours", json::array())) {
            const int pid = m.value("position_id", 0);
            if (pid < 2 || pid > 11 || !m.contains("concept_id") || !m["concept_id"].is_number_integer()) continue;
            bool hasTarget = m.contains("target") && m["target"].is_number_integer() &&
                             m["target"].get<int>() >= 1 && m["target"].get<int>() <= 11;
            int target = hasTarget ? m["target"].get<int>() : 0;
            // The concept's kind that fits: one naming nobody when there is no
            // target, one taking a man when there is.
            auto k = tx->exec_params(
                "SELECT code FROM tactic_job_kinds WHERE concept_id = $1 AND (target_a_label IS NULL) = $2 "
                " ORDER BY sort_order, code LIMIT 1", m["concept_id"].get<int>(), !hasTarget);
            // A press with no man named presses the man on the ball.
            if (k.empty() && !hasTarget) {
                k = tx->exec_params("SELECT code FROM tactic_job_kinds WHERE concept_id = $1 AND rule = 'press' "
                                    " ORDER BY sort_order, code LIMIT 1", m["concept_id"].get<int>());
                if (!k.empty()) { hasTarget = true; target = ballWith; }
            }
            if (k.empty()) { skipped.push_back({{"position_id", pid}, {"concept_id", m["concept_id"]}}); continue; }
            tx->exec_params("INSERT INTO tactic_jobs (state_id, position_id, kind) VALUES ($1, $2, $3)",
                            stateId, pid, k[0]["code"].as<std::string>());
            if (hasTarget)
                tx->exec_params("INSERT INTO tactic_job_targets (state_id, position_id, number, ord) VALUES ($1, $2, $3, 1)",
                                stateId, pid, target);
            ++jobs;
        }
        tx->exec_params("UPDATE tactic_plans SET updated_at = now() WHERE id = $1", planId);
        db->commit(tx);
        auto codes = db->query("SELECT (SELECT code FROM formations WHERE id = $1::int) AS us, "
                               "       (SELECT code FROM formations WHERE id = $2::int) AS them",
                               {std::to_string(us), std::to_string(them)});
        return {{"plan_id", planId}, {"state_id", stateId}, {"us", codes[0]["us"].as<std::string>()},
                {"them", codes[0]["them"].as<std::string>()}, {"block", block}, {"ball_with", ballWith},
                {"jobs", jobs}, {"skipped", skipped}};
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

bool TacticPlans::deleteState(long long stateId) {
    auto* db = Database::getInstance();
    auto r = db->query("DELETE FROM tactic_states WHERE id = $1::int AND parent_state_id IS NOT NULL RETURNING id",
                       {std::to_string(stateId)});
    return !r.empty();
}
