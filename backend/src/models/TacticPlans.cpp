#include "TacticPlans.h"

#include "../database/Database.h"

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

}  // namespace

json TacticPlans::lookups() {
    auto* db = Database::getInstance();
    json out = {{"moments", json::array()}, {"blocks", json::array()}, {"kinds", json::array()}, {"stances", json::array()}};
    out["restarts"] = json::array();
    for (const auto& r : db->query("SELECT code, label, law, our_max_y::float8 AS our_max_y FROM tactic_restarts ORDER BY code"))
        out["restarts"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                   {"law", r["law"].as<std::string>()}, {"our_max_y", r["our_max_y"].as<double>()}});
    for (const auto& r : db->query("SELECT code, label FROM tactic_job_stances ORDER BY sort_order"))
        out["stances"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, title FROM game_moments ORDER BY sort_order"))
        out["moments"].push_back({{"code", r["code"].as<std::string>()}, {"title", r["title"].as<std::string>()}});
    for (const auto& r : db->query("SELECT code, label, gk_y::float8 AS gk_y FROM tactic_block_heights ORDER BY sort_order"))
        out["blocks"].push_back({{"code", r["code"].as<std::string>()}, {"label", r["label"].as<std::string>()},
                                 {"gk_y", r["gk_y"].as<double>()}});
    for (const auto& r : db->query(
             "SELECT k.code, k.concept_id, c.name AS concept, c.title AS concept_title, c.cue_answer, k.label, k.target_a_label, k.target_b_label, k.partner_label, "
             "       k.dist_m::float8 AS dist_m, k.press_m::float8 AS press_m, k.multi_a, k.lane_t::float8 AS lane_t "
             "  FROM tactic_job_kinds k JOIN game_concepts c ON c.id = k.concept_id ORDER BY k.sort_order")) {
        out["kinds"].push_back({{"code", r["code"].as<std::string>()},
                                {"concept_id", r["concept_id"].as<int>()},
                                {"concept", r["concept"].as<std::string>()},
                                {"concept_title", r["concept_title"].as<std::string>()},
                                {"cue", r["cue_answer"].as<std::string>()},
                                {"label", r["label"].as<std::string>()},
                                {"target_a_label", r["target_a_label"].as<std::string>()},
                                {"target_b_label", r["target_b_label"].is_null() ? json(nullptr) : json(r["target_b_label"].as<std::string>())},
                                {"partner_label", r["partner_label"].is_null() ? json(nullptr) : json(r["partner_label"].as<std::string>())},
                                {"dist_m", r["dist_m"].as<double>()},
                                {"press_m", r["press_m"].is_null() ? json(nullptr) : json(r["press_m"].as<double>())},
                                {"multi_a", r["multi_a"].as<bool>()},
                                {"lane_t", r["lane_t"].is_null() ? json(nullptr) : json(r["lane_t"].as<double>())}});
    }
    return out;
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

    for (const auto& s : db->query(
             "SELECT id, parent_state_id, ball_with, restart FROM tactic_states WHERE plan_id = $1::int "
             " ORDER BY parent_state_id IS NOT NULL, id", {planId})) {
        const std::string sid = s["id"].as<std::string>();
        json st = {{"id", s["id"].as<long long>()},
                   {"parent_state_id", s["parent_state_id"].is_null() ? json(nullptr) : json(s["parent_state_id"].as<long long>())},
                   {"ball_with", s["ball_with"].as<int>()},
                   {"restart", s["restart"].is_null() ? json(nullptr) : json(s["restart"].as<std::string>())},
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
        out["states"].push_back(std::move(st));
    }
    return out;
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
            "ON CONFLICT (plan_id, parent_state_id, ball_with) DO NOTHING RETURNING id",
            planId, parentStateId, ballWith);
        long long id;
        if (ins.empty()) {
            id = tx->exec_params("SELECT id FROM tactic_states WHERE plan_id = $1 AND parent_state_id = $2 AND ball_with = $3",
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
            auto k = tx->exec_params("SELECT multi_a FROM tactic_job_kinds WHERE code = $1", kind);
            if (k.empty()) throw std::runtime_error("unknown job kind: " + kind);
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

bool TacticPlans::deleteState(long long stateId) {
    auto* db = Database::getInstance();
    auto r = db->query("DELETE FROM tactic_states WHERE id = $1::int AND parent_state_id IS NOT NULL RETURNING id",
                       {std::to_string(stateId)});
    return !r.empty();
}
