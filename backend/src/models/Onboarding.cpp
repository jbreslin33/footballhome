#include "Onboarding.h"

#include <map>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {

// Every person on the path × every active step, with its state.  $1 = one
// person, or 0 for everyone.
const char* kStepsSql = R"SQL(
    SELECT po.person_id, po.track, po.note AS path_note,
           TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
           s.code, s.stage, s.label, s.how, s.cost_usd, s.link_url, s.link_label, s.renew_months,
           ps.sent_at, ps.verified_at, ps.note,
           CASE WHEN ps.verified_at IS NOT NULL AND s.renew_months IS NOT NULL
                THEN ps.verified_at + make_interval(months => s.renew_months) END AS expires_at,
           CASE WHEN ps.verified_at IS NOT NULL
                 AND (s.renew_months IS NULL
                      OR ps.verified_at + make_interval(months => s.renew_months) - interval '60 days' > now())
                  THEN 'done'
                WHEN ps.verified_at IS NOT NULL THEN 'renew'
                WHEN ps.sent_at IS NOT NULL THEN 'sent'
                ELSE 'todo' END AS state,
           (s.stage = 'volunteer' OR po.track = 'paid') AS required
      FROM person_onboarding po
      JOIN persons p ON p.id = po.person_id
     CROSS JOIN onboarding_steps s
      LEFT JOIN person_onboarding_steps ps ON ps.person_id = po.person_id AND ps.step_code = s.code
     WHERE s.is_active AND ($1::int = 0 OR po.person_id = $1::int)
     ORDER BY p.first_name, p.last_name, po.person_id, s.sort_order, s.code
)SQL";

json textOrNull(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.c_str()); }

json stepJson(const pqxx::row& r) {
    return {
        {"code",        r["code"].c_str()},
        {"stage",       r["stage"].c_str()},
        {"label",       r["label"].c_str()},
        {"how",         r["how"].c_str()},
        {"cost_usd",    r["cost_usd"].is_null() ? json(nullptr) : json(r["cost_usd"].as<double>())},
        {"link_url",    textOrNull(r["link_url"])},
        {"link_label",  textOrNull(r["link_label"])},
        {"sent_at",     textOrNull(r["sent_at"])},
        {"verified_at", textOrNull(r["verified_at"])},
        {"expires_at",  textOrNull(r["expires_at"])},
        {"note",        textOrNull(r["note"])},
        {"state",       r["state"].c_str()},
        {"required",    r["required"].as<bool>()},
    };
}

// Fold a person's step rows into {…, steps, left, done, total}.
void tally(json& person) {
    int left = 0, done = 0, total = 0;
    for (const auto& s : person["steps"]) {
        if (!s.value("required", false)) continue;
        ++total;
        const std::string st = s.value("state", "");
        if (st == "done") ++done;
        if (st == "todo" || st == "renew") ++left;
    }
    person["left"] = left;
    person["done"] = done;
    person["total"] = total;
}

bool stepExists(Database* db, const std::string& code) {
    return !db->query("SELECT 1 FROM onboarding_steps WHERE code = $1 AND is_active", {code}).empty();
}
bool onPath(Database* db, long long personId) {
    return !db->query("SELECT 1 FROM person_onboarding WHERE person_id = $1::int", {std::to_string(personId)}).empty();
}

}  // namespace

json Onboarding::mine(long long personId) {
    if (personId <= 0) return nullptr;
    auto* db = Database::getInstance();
    auto rows = db->query(kStepsSql, {std::to_string(personId)});
    if (rows.empty()) return nullptr;
    json out = {{"person_id", personId}, {"track", rows[0]["track"].c_str()}, {"steps", json::array()}};
    for (const auto& r : rows) out["steps"].push_back(stepJson(r));
    tally(out);
    return out;
}

json Onboarding::board() {
    auto* db = Database::getInstance();
    json steps = json::array();
    for (const auto& r : db->query(
             "SELECT code, stage, label, how, cost_usd, link_url, link_label, renew_months "
             "  FROM onboarding_steps WHERE is_active ORDER BY sort_order, code")) {
        steps.push_back({{"code", r["code"].c_str()}, {"stage", r["stage"].c_str()}, {"label", r["label"].c_str()},
                         {"how", r["how"].c_str()},
                         {"cost_usd", r["cost_usd"].is_null() ? json(nullptr) : json(r["cost_usd"].as<double>())},
                         {"link_url", textOrNull(r["link_url"])}, {"link_label", textOrNull(r["link_label"])},
                         {"renew_months", r["renew_months"].is_null() ? json(nullptr) : json(r["renew_months"].as<int>())}});
    }
    json people = json::array();
    std::map<long long, size_t> at;
    for (const auto& r : db->query(kStepsSql, std::vector<std::string>{"0"})) {
        const long long pid = r["person_id"].as<long long>();
        auto it = at.find(pid);
        if (it == at.end()) {
            people.push_back({{"person_id", pid}, {"name", r["name"].c_str()}, {"track", r["track"].c_str()},
                              {"note", textOrNull(r["path_note"])}, {"steps", json::array()}});
            it = at.emplace(pid, people.size() - 1).first;
        }
        people[it->second]["steps"].push_back(stepJson(r));
    }
    for (auto& p : people) tally(p);
    // Not on the path yet: the volunteer list, then current coaches.
    json candidates = json::array();
    for (const auto& r : db->query(R"SQL(
        SELECT p.id, TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
               bool_or(x.why = 'volunteer') AS volunteer
          FROM (SELECT person_id, 'volunteer' AS why FROM club_volunteers
                UNION ALL
                SELECT c.person_id, 'coach' FROM coaches c
                  JOIN team_coaches tc ON tc.coach_id = c.id AND tc.ended_at IS NULL) x
          JOIN persons p ON p.id = x.person_id
         WHERE NOT EXISTS (SELECT 1 FROM person_onboarding po WHERE po.person_id = p.id)
         GROUP BY p.id, p.first_name, p.last_name
         ORDER BY bool_or(x.why = 'volunteer') DESC, p.first_name, p.last_name
    )SQL")) {
        candidates.push_back({{"person_id", r["id"].as<long long>()}, {"name", r["name"].c_str()},
                              {"why", r["volunteer"].as<bool>() ? "volunteer" : "coach"}});
    }
    return {{"steps", steps}, {"people", people}, {"candidates", candidates}};
}

std::string Onboarding::markSent(long long personId, const std::string& code, bool sent) {
    auto* db = Database::getInstance();
    if (!onPath(db, personId)) return "You are not on the onboarding path.";
    if (!stepExists(db, code)) return "Unknown step.";
    const std::string pid = std::to_string(personId);
    auto cur = db->query("SELECT verified_at FROM person_onboarding_steps WHERE person_id = $1::int AND step_code = $2",
                         {pid, code});
    if (!cur.empty() && !cur[0]["verified_at"].is_null()) {
        // A verified step can still be re-sent once it needs renewing.
        auto renew = db->query(R"SQL(
            SELECT 1 FROM person_onboarding_steps ps JOIN onboarding_steps s ON s.code = ps.step_code
             WHERE ps.person_id = $1::int AND ps.step_code = $2 AND s.renew_months IS NOT NULL
               AND ps.verified_at + make_interval(months => s.renew_months) - interval '60 days' <= now()
        )SQL", {pid, code});
        if (renew.empty()) return "The club has already checked that one.";
        if (sent) {
            db->query("UPDATE person_onboarding_steps SET sent_at = now(), verified_at = NULL, verified_by = NULL, "
                      "       note = NULL, updated_at = now() WHERE person_id = $1::int AND step_code = $2", {pid, code});
            return "";
        }
        return "";
    }
    db->query(R"SQL(
        INSERT INTO person_onboarding_steps (person_id, step_code, sent_at, updated_at)
        VALUES ($1::int, $2, CASE WHEN $3::boolean THEN now() END, now())
        ON CONFLICT (person_id, step_code)
        DO UPDATE SET sent_at = CASE WHEN $3::boolean THEN now() END,
                      note = CASE WHEN $3::boolean THEN NULL ELSE person_onboarding_steps.note END,
                      updated_at = now()
    )SQL", {pid, code, sent ? "true" : "false"});
    return "";
}

std::string Onboarding::review(long long personId, const std::string& code, const std::string& action,
                               const std::string& note, long long userId) {
    auto* db = Database::getInstance();
    if (!onPath(db, personId)) return "That person is not on the onboarding path.";
    if (!stepExists(db, code)) return "Unknown step.";
    const std::string pid = std::to_string(personId);
    const std::string uid = userId > 0 ? std::to_string(userId) : std::string();
    if (action == "verified") {
        db->query("INSERT INTO person_onboarding_steps (person_id, step_code, sent_at, verified_at, verified_by, note, updated_at) "
                  "VALUES ($1::int, $2, now(), now(), NULLIF($3, '')::int, NULLIF($4, ''), now()) "
                  "ON CONFLICT (person_id, step_code) DO UPDATE SET "
                  "  sent_at = COALESCE(person_onboarding_steps.sent_at, now()), verified_at = now(), "
                  "  verified_by = NULLIF($3, '')::int, note = NULLIF($4, ''), updated_at = now()",
                  {pid, code, uid, note});
    } else if (action == "redo") {
        db->query("INSERT INTO person_onboarding_steps (person_id, step_code, verified_by, note, updated_at) "
                  "VALUES ($1::int, $2, NULLIF($3, '')::int, NULLIF($4, ''), now()) "
                  "ON CONFLICT (person_id, step_code) DO UPDATE SET "
                  "  sent_at = NULL, verified_at = NULL, verified_by = NULLIF($3, '')::int, note = NULLIF($4, ''), updated_at = now()",
                  {pid, code, uid, note});
    } else if (action == "sent") {
        db->query("INSERT INTO person_onboarding_steps (person_id, step_code, sent_at, note, updated_at) "
                  "VALUES ($1::int, $2, now(), NULLIF($3, ''), now()) "
                  "ON CONFLICT (person_id, step_code) DO UPDATE SET "
                  "  sent_at = now(), verified_at = NULL, verified_by = NULL, note = NULLIF($3, ''), updated_at = now()",
                  {pid, code, note});
    } else if (action == "clear") {
        db->query("DELETE FROM person_onboarding_steps WHERE person_id = $1::int AND step_code = $2", {pid, code});
    } else {
        return "action must be verified, redo, sent or clear.";
    }
    return "";
}

std::string Onboarding::setTrack(long long personId, const std::string& track, long long userId) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    if (db->query("SELECT 1 FROM persons WHERE id = $1::int", {pid}).empty()) return "Person not found.";
    if (track.empty()) {
        // Off the path: the ticks go too (start again = a fresh checklist).
        db->query("DELETE FROM person_onboarding_steps WHERE person_id = $1::int", {pid});
        db->query("DELETE FROM person_onboarding WHERE person_id = $1::int", {pid});
        return "";
    }
    if (track != "volunteer" && track != "paid") return "track must be volunteer or paid.";
    db->query("INSERT INTO person_onboarding (person_id, track, started_by) VALUES ($1::int, $2, NULLIF($3, '')::int) "
              "ON CONFLICT (person_id) DO UPDATE SET track = EXCLUDED.track",
              {pid, track, userId > 0 ? std::to_string(userId) : std::string()});
    return "";
}
