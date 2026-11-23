#include "Onboarding.h"

#include <cctype>
#include <map>
#include <iostream>
#include <vector>

#include "../core/Mail.h"

#include "../database/Database.h"

using json = nlohmann::json;

namespace {

// Every person on the path × every active step, with its state.  $1 = one
// person, or 0 for everyone.
const char* kStepsSql = R"SQL(
    SELECT po.person_id, po.track, po.note AS path_note,
           TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
           s.code, s.stage, s.label, COALESCE(s.short_label, s.label) AS short_label, s.how, s.cost_usd, s.link_url, s.link_label, s.renew_months, s.fill_form, ps.submitted_at,
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
           (s.stage IN ('player', 'volunteer') OR po.track = 'paid') AS required
      FROM onboarding_people po
      JOIN persons p ON p.id = po.person_id
     CROSS JOIN onboarding_steps s
      LEFT JOIN person_onboarding_steps ps ON ps.person_id = po.person_id AND ps.step_code = s.code
     WHERE s.is_active AND ($1::int = 0 OR po.person_id = $1::int)
       -- a 'player' step (SafeSport, mig 1740) is for players of a covered
       -- section, old enough; the staff steps for people on a staff track
       AND CASE WHEN s.stage = 'player'
                THEN po.is_player AND (s.min_age IS NULL OR p.birth_date IS NULL
                                       OR p.birth_date <= (now() AT TIME ZONE 'America/New_York')::date - make_interval(years => s.min_age))
                ELSE po.track <> 'player' END
     ORDER BY p.first_name, p.last_name, po.person_id, s.sort_order, s.code
)SQL";

json textOrNull(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.c_str()); }

json stepJson(const pqxx::row& r) {
    return {
        {"code",        r["code"].c_str()},
        {"stage",       r["stage"].c_str()},
        {"label",       r["label"].c_str()},
        {"short_label", r["short_label"].c_str()},
        {"how",         r["how"].c_str()},
        {"cost_usd",    r["cost_usd"].is_null() ? json(nullptr) : json(r["cost_usd"].as<double>())},
        {"link_url",    textOrNull(r["link_url"])},
        {"link_label",  textOrNull(r["link_label"])},
        {"sent_at",     textOrNull(r["sent_at"])},
        {"verified_at", textOrNull(r["verified_at"])},
        {"expires_at",  textOrNull(r["expires_at"])},
        {"note",        textOrNull(r["note"])},
        {"fill_form",   textOrNull(r["fill_form"])},
        {"submitted_at", textOrNull(r["submitted_at"])},
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
    // staff tracks + every player of a covered section (onboarding_people, mig 1740)
    return !db->query("SELECT 1 FROM onboarding_people WHERE person_id = $1::int", {std::to_string(personId)}).empty();
}

}  // namespace

namespace {
// Files per (person, step), newest last: {id, filename, mime, byte_size, uploaded_at, emailed_at}.
std::map<std::string, json> filesFor(Database* db, long long personId) {
    std::map<std::string, json> out;
    for (const auto& r : db->query(
             "SELECT id, person_id, step_code, filename, mime, byte_size, uploaded_at, emailed_at "
             "  FROM person_onboarding_files WHERE ($1::int = 0 OR person_id = $1::int) ORDER BY uploaded_at, id",
             {std::to_string(personId)})) {
        const std::string key = std::string(r["person_id"].c_str()) + "|" + r["step_code"].c_str();
        if (!out.count(key)) out[key] = json::array();
        out[key].push_back({{"id", r["id"].as<long long>()}, {"filename", r["filename"].c_str()},
                            {"mime", r["mime"].c_str()}, {"byte_size", r["byte_size"].as<long long>()},
                            {"uploaded_at", r["uploaded_at"].c_str()},
                            {"emailed_at", r["emailed_at"].is_null() ? json(nullptr) : json(r["emailed_at"].c_str())}});
    }
    return out;
}
void attachFiles(json& person, const std::map<std::string, json>& files) {
    const std::string pid = std::to_string(person["person_id"].get<long long>());
    for (auto& st : person["steps"]) {
        auto it = files.find(pid + "|" + st["code"].get<std::string>());
        st["files"] = it == files.end() ? json::array() : it->second;
    }
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
    attachFiles(out, filesFor(db, personId));
    // ✍️ What a fill-in form can start from (their own details only).
    auto pf = db->query(R"SQL(
        SELECT p.first_name, p.last_name, to_char(p.birth_date, 'MM/DD/YYYY') AS dob,
               (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC, e.id LIMIT 1) AS email,
               (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id ORDER BY ph.is_primary DESC, ph.id LIMIT 1) AS phone,
               a.address1, a.address2, a.city, a.state, a.zip
          FROM persons p
          LEFT JOIN LATERAL (SELECT * FROM person_addresses x WHERE x.person_id = p.id ORDER BY x.is_primary DESC, x.id LIMIT 1) a ON true
         WHERE p.id = $1::int
    )SQL", {std::to_string(personId)});
    if (!pf.empty()) {
        json f = json::object();
        for (const char* k : {"first_name", "last_name", "dob", "email", "phone", "address1", "address2", "city", "state", "zip"})
            f[k] = pf[0][k].is_null() ? json("") : json(pf[0][k].c_str());
        out["prefill"] = f;
    }
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
    purge();
    const auto files = filesFor(db, 0);
    for (auto& p : people) { tally(p); attachFiles(p, files); }
    for (const auto& r : db->query("SELECT person_id, emailed_at FROM person_onboarding WHERE emailed_at IS NOT NULL"))
        for (auto& p : people)
            if (p["person_id"].get<long long>() == r["person_id"].as<long long>()) p["emailed_at"] = r["emailed_at"].c_str();
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
    for (const auto& r : db->query("SELECT person_id, stage, emailed_at FROM person_onboarding_stage_sends"))
        for (auto& p : people)
            if (p["person_id"].get<long long>() == r["person_id"].as<long long>()) p["sends"][r["stage"].c_str()] = r["emailed_at"].c_str();
    json stages = json::array();
    for (const auto& r : db->query("SELECT stage, email_to, email_to_name FROM onboarding_stages ORDER BY sort_order"))
        stages.push_back({{"stage", r["stage"].c_str()}, {"email_to", r["email_to"].is_null() ? json(nullptr) : json(r["email_to"].c_str())},
                          {"email_to_name", r["email_to_name"].c_str()}});
    json policy = json::object();
    for (const auto& r : db->query("SELECT compliance_email, compliance_name, max_file_mb, purge_days FROM onboarding_policy WHERE id = 1"))
        policy = {{"compliance_email", r["compliance_email"].c_str()}, {"compliance_name", r["compliance_name"].c_str()},
                  {"max_file_mb", r["max_file_mb"].as<int>()}, {"purge_days", r["purge_days"].as<int>()}};
    return {{"steps", steps}, {"people", people}, {"candidates", candidates}, {"policy", policy}, {"stages", stages}};
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

// ── Documents (mig 1538) ────────────────────────────────────────────────

namespace {

std::string unhex(const std::string& h) {
    std::string out;
    size_t i = (h.size() >= 2 && h[0] == '\\' && h[1] == 'x') ? 2 : 0;
    out.reserve((h.size() - i) / 2);
    auto v = [](char c) -> int {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
        return 0;
    };
    for (; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>((v(h[i]) << 4) | v(h[i + 1])));
    return out;
}

// Mime + extension from the first bytes (hex), or "" when not allowed.
std::pair<std::string, std::string> sniff(const std::string& hex) {
    auto at = [&](size_t off, const char* sig) { return hex.compare(off * 2, std::string(sig).size(), sig) == 0; };
    if (at(0, "25504446")) return {"application/pdf", "pdf"};
    if (at(0, "ffd8ff"))   return {"image/jpeg", "jpg"};
    if (at(0, "89504e47")) return {"image/png", "png"};
    if (at(0, "52494646") && hex.size() >= 24 && at(8, "57454250")) return {"image/webp", "webp"};
    if (hex.size() >= 24 && at(4, "66747970")) return {"image/heic", "heic"};
    return {"", ""};
}

std::string fill(std::string text, const std::map<std::string, std::string>& tokens) {
    for (const auto& [k, v] : tokens) {
        const std::string key = "{" + k + "}";
        for (size_t pos = text.find(key); pos != std::string::npos; pos = text.find(key, pos + v.size()))
            text.replace(pos, key.size(), v);
    }
    return text;
}

// message_templates kind onboarding: {subject, body}, or the fallbacks.
std::pair<std::string, std::string> words(Database* db, const std::string& tier, const std::string& subj, const std::string& body) {
    auto r = db->query("SELECT COALESCE(subject, '') AS s, body FROM message_templates "
                       " WHERE kind = 'onboarding' AND tier = $1 AND is_active ORDER BY sort_order, id LIMIT 1", {tier});
    if (r.empty()) return {subj, body};
    return {std::string(r[0]["s"].c_str()).empty() ? subj : r[0]["s"].c_str(), r[0]["body"].c_str()};
}

}  // namespace

long long Onboarding::addFile(long long personId, const std::string& code, const std::string& filenameIn,
                              const std::string& base64In, long long userId, std::string* error) {
    auto* db = Database::getInstance();
    if (!onPath(db, personId)) { *error = "Not on the onboarding path."; return 0; }
    if (!stepExists(db, code)) { *error = "Unknown step."; return 0; }
    std::string b64;
    b64.reserve(base64In.size());
    const size_t comma = base64In.rfind("base64,");
    for (size_t i = comma == std::string::npos ? 0 : comma + 7; i < base64In.size(); ++i) {
        const char c = base64In[i];
        if (std::isalnum(static_cast<unsigned char>(c)) || c == '+' || c == '/' || c == '=') b64.push_back(c);
    }
    if (b64.empty()) { *error = "Empty file."; return 0; }
    const std::string pid = std::to_string(personId);
    auto info = db->query("SELECT octet_length(decode($1, 'base64')) AS n, "
                          "       encode(substring(decode($1, 'base64') from 1 for 16), 'hex') AS head, "
                          "       (SELECT max_file_mb FROM onboarding_policy WHERE id = 1) AS cap", {b64});
    const long long n = info[0]["n"].as<long long>();
    const int capMb = info[0]["cap"].is_null() ? 10 : info[0]["cap"].as<int>();
    if (n <= 0) { *error = "Empty file."; return 0; }
    if (n > static_cast<long long>(capMb) * 1024 * 1024) { *error = "File is over " + std::to_string(capMb) + " MB."; return 0; }
    const auto [mime, ext] = sniff(info[0]["head"].c_str());
    if (mime.empty()) { *error = "Upload a photo (JPG, PNG, HEIC) or a PDF."; return 0; }
    std::string filename;
    for (char c : filenameIn) if (c != '\r' && c != '\n' && c != '/' && c != '\\') filename.push_back(c);
    if (filename.empty()) filename = code + "." + ext;
    filename = filename.substr(0, 120);
    auto ins = db->query("INSERT INTO person_onboarding_files (person_id, step_code, filename, mime, byte_size, bytes, uploaded_by) "
                         "VALUES ($1::int, $2, $3, $4, $5::int, decode($6, 'base64'), NULLIF($7, '')::int) RETURNING id",
                         {pid, code, filename, mime, std::to_string(n), b64, userId > 0 ? std::to_string(userId) : std::string()});
    // An upload = sent (unless the club already checked it and it isn't due to renew).
    db->query(R"SQL(
        INSERT INTO person_onboarding_steps (person_id, step_code, sent_at, updated_at)
        VALUES ($1::int, $2, now(), now())
        ON CONFLICT (person_id, step_code) DO UPDATE
           SET sent_at = now(), note = NULL, updated_at = now(),
               verified_at = CASE WHEN person_onboarding_steps.verified_at IS NOT NULL
                                   AND NOT EXISTS (SELECT 1 FROM onboarding_steps s WHERE s.code = $2 AND s.renew_months IS NOT NULL
                                         AND person_onboarding_steps.verified_at + make_interval(months => s.renew_months) - interval '60 days' <= now())
                                  THEN person_onboarding_steps.verified_at END
    )SQL", {pid, code});
    return ins[0]["id"].as<long long>();
}

std::string Onboarding::removeFile(long long fileId, long long ownerPersonId) {
    auto* db = Database::getInstance();
    auto r = db->query("SELECT person_id, step_code, emailed_at FROM person_onboarding_files WHERE id = $1::bigint",
                       {std::to_string(fileId)});
    if (r.empty()) return "File not found.";
    const long long pid = r[0]["person_id"].as<long long>();
    if (ownerPersonId > 0) {
        if (pid != ownerPersonId) return "Not your file.";
        if (!r[0]["emailed_at"].is_null()) return "That file already went to the club's compliance director.";
    }
    const std::string code = r[0]["step_code"].c_str();
    db->query("DELETE FROM person_onboarding_files WHERE id = $1::bigint", {std::to_string(fileId)});
    // The person took back their last file on an unchecked step → back to to do.
    if (ownerPersonId > 0)
        db->query("UPDATE person_onboarding_steps SET sent_at = NULL, updated_at = now() "
                  " WHERE person_id = $1::int AND step_code = $2 AND verified_at IS NULL "
                  "   AND NOT EXISTS (SELECT 1 FROM person_onboarding_files f WHERE f.person_id = $1::int AND f.step_code = $2)",
                  {std::to_string(pid), code});
    return "";
}

bool Onboarding::fileBytes(long long fileId, std::string* filename, std::string* mime, std::string* bytes) {
    auto r = Database::getInstance()->query(
        "SELECT filename, mime, encode(bytes, 'hex') AS h FROM person_onboarding_files WHERE id = $1::bigint",
        {std::to_string(fileId)});
    if (r.empty()) return false;
    *filename = r[0]["filename"].c_str();
    *mime = r[0]["mime"].c_str();
    *bytes = unhex(r[0]["h"].c_str());
    return true;
}

void Onboarding::purge() {
    Database::getInstance()->query(
        "DELETE FROM person_onboarding_files f USING onboarding_policy p "
        " WHERE p.id = 1 AND f.emailed_at IS NOT NULL AND f.emailed_at < now() - make_interval(days => p.purge_days)");
}

std::string Onboarding::sendStage(long long personId, const std::string& stage, long long adminUserId, int* sentFiles) {
    *sentFiles = 0;
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    auto who = db->query(
        "SELECT TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name, po.track, "
        "       (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC, e.id LIMIT 1) AS email "
        "  FROM person_onboarding po JOIN persons p ON p.id = po.person_id WHERE po.person_id = $1::int", {pid});
    if (who.empty()) return "That person is not on the onboarding path.";
    if (stage != "volunteer" && stage != "paid") return "stage must be volunteer or paid.";
    // Who this stage's email goes to (onboarding_stages, mig 1545).
    auto pol = db->query("SELECT COALESCE(email_to, '') AS email_to, email_to_name FROM onboarding_stages WHERE stage = $1", {stage});
    if (pol.empty() || std::string(pol[0]["email_to"].c_str()).empty())
        return stage == "paid" ? "No HR email set yet for the finance paperwork." : "No compliance email set.";
    auto admin = db->query(
        "SELECT (SELECT e.email FROM person_emails e WHERE e.person_id = u.person_id ORDER BY e.is_primary DESC, e.id LIMIT 1) AS email "
        "  FROM users u WHERE u.id = $1::int", {std::to_string(adminUserId)});
    const std::string adminEmail = admin.empty() || admin[0]["email"].is_null() ? "" : admin[0]["email"].c_str();
    const std::string name = who[0]["name"].c_str();
    const std::string track = who[0]["track"].c_str();

    // Every stored file, in checklist order.
    auto files = db->query(
        "SELECT f.id, f.filename, f.mime, f.byte_size, encode(f.bytes, 'hex') AS h, s.label "
        "  FROM person_onboarding_files f JOIN onboarding_steps s ON s.code = f.step_code "
        " WHERE f.person_id = $1::int AND s.stage = $2 ORDER BY s.sort_order, f.uploaded_at, f.id", {pid, stage});
    if (files.empty()) return "No files uploaded yet for this stage.";

    // The checklist in the body: every step, ✅ / 🟡 / ⬜, with its files.
    std::string list;
    auto steps = db->query(kStepsSql, {pid});
    for (const auto& st : steps) {
        if (std::string(st["stage"].c_str()) != stage) continue;
        const std::string state = st["state"].c_str();
        const std::string mark = state == "done" ? "✅" : state == "sent" ? "📎" : "⬜";
        std::string names;
        for (const auto& f : files)
            if (std::string(f["label"].c_str()) == st["label"].c_str()) names += (names.empty() ? "" : ", ") + std::string(f["filename"].c_str());
        list += mark + " " + st["label"].c_str() + (names.empty() ? std::string(" — not uploaded") : " — attached: " + names) + "\n";
    }

    // Parts under ~9 MB of raw bytes (base64 adds a third; Postmark caps a message at 10 MB).
    const long long kPart = 7LL * 1024 * 1024;
    std::vector<std::vector<size_t>> parts(1);
    long long used = 0;
    for (size_t i = 0; i < files.size(); ++i) {
        const long long sz = files[i]["byte_size"].as<long long>();
        if (!parts.back().empty() && used + sz > kPart) { parts.emplace_back(); used = 0; }
        parts.back().push_back(i);
        used += sz;
    }
    const auto [subjT, bodyT] = stage == "paid"
        ? words(db, "email_paid", "Finance paperwork — {name}", "Hi {to_name},\n\nFinance paperwork for {name}, who is copied on this email.\n\n{list}\nThanks!")
        : words(db, "email_compliance", "Clearances — {name}", "Hi,\n\nClearances for {name} ({track}), who is copied on this email.\n\n{list}\nThanks!");
    std::string toName = pol[0]["email_to_name"].c_str();
    if (const auto paren = toName.find(" ("); paren != std::string::npos) toName = toName.substr(0, paren);
    const auto partT = words(db, "email_part", "", " (part {i} of {n})").second;
    const std::string trackWord = track == "paid" ? "paid" : "volunteer";
    for (size_t p = 0; p < parts.size(); ++p) {
        fh::mail::Message m;
        m.to = pol[0]["email_to"].c_str();
        if (!who[0]["email"].is_null()) m.cc.push_back(who[0]["email"].c_str());
        if (!adminEmail.empty()) { m.cc.push_back(adminEmail); m.replyTo = adminEmail; }
        const std::string part = parts.size() > 1
            ? fill(partT, {{"i", std::to_string(p + 1)}, {"n", std::to_string(parts.size())}}) : "";
        m.subject = fill(subjT, {{"name", name}, {"track", trackWord}}) + part;
        m.body = fill(bodyT, {{"name", name}, {"track", trackWord}, {"list", list}, {"to_name", toName}});
        for (size_t i : parts[p])
            m.attachments.push_back({files[i]["filename"].c_str(), files[i]["mime"].c_str(), unhex(files[i]["h"].c_str())});
        if (!fh::mail::sendMessage(m))
            return p == 0 ? "The email did not go out — try again." : "Part " + std::to_string(p + 1) + " did not go out — try again.";
        for (size_t i : parts[p]) {
            db->query("UPDATE person_onboarding_files SET emailed_at = now() WHERE id = $1::bigint",
                      {std::string(files[i]["id"].c_str())});
            ++*sentFiles;
        }
    }
    const std::string uid = adminUserId > 0 ? std::to_string(adminUserId) : std::string();
    db->query("UPDATE person_onboarding SET emailed_at = now(), emailed_by = NULLIF($2, '')::int WHERE person_id = $1::int", {pid, uid});
    db->query("INSERT INTO person_onboarding_stage_sends (person_id, stage, emailed_at, emailed_by) "
              "VALUES ($1::int, $2, now(), NULLIF($3, '')::int) "
              "ON CONFLICT (person_id, stage) DO UPDATE SET emailed_at = now(), emailed_by = EXCLUDED.emailed_by", {pid, stage, uid});
    return "";
}

std::string Onboarding::sendNsor(long long personId, const std::string& fileDataUrl, const std::string& lastNameIn,
                                 const std::string& fullNameIn, const std::string& emailIn) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    if (!onPath(db, personId)) return "You are not on the onboarding path.";
    auto recent = db->query("SELECT 1 FROM person_onboarding_steps WHERE person_id = $1::int AND step_code = 'nsor' "
                            "   AND submitted_at > now() - interval '24 hours'", {pid});
    if (!recent.empty()) return "Your NSOR form already went to the state today.";
    auto clean = [](const std::string& in, size_t max) {
        std::string o;
        for (char c : in) if (c != '\r' && c != '\n') o.push_back(c);
        return o.substr(0, max);
    };
    const std::string lastName = clean(lastNameIn, 60), fullName = clean(fullNameIn, 120), email = clean(emailIn, 160);
    if (lastName.empty() || fullName.empty()) return "Name required.";
    if (email.find('@') == std::string::npos) return "A valid email is required — the state sends your letter there.";
    std::string err;
    std::string fname;
    for (char c : lastName) if (std::isalnum(static_cast<unsigned char>(c)) || c == '-') fname.push_back(c);
    const long long fileId = addFile(personId, "nsor", "NSOR-application-" + (fname.empty() ? std::string("form") : fname) + ".pdf",
                                     fileDataUrl, 0, &err);
    if (fileId <= 0) return err;
    std::string fn, mime, bytes;
    if (!fileBytes(fileId, &fn, &mime, &bytes) || mime != "application/pdf") {
        removeFile(fileId, 0);
        return "The form did not come through as a PDF — try again.";
    }
    auto to = db->query("SELECT body FROM message_templates WHERE kind = 'onboarding' AND tier = 'nsor_to' AND is_active ORDER BY id LIMIT 1");
    const std::string toAddr = to.empty() ? "RA-PWNSOR@pa.gov" : to[0]["body"].c_str();
    const auto [subjT, bodyT] = words(db, "nsor_email", "NSOR Verification {last_name}",
        "Hello,\n\nAttached is the completed National Sex Offender Registry verification application for {full_name}. "
        "Please send the verification letter to {email}.\n\nThank you.");
    fh::mail::Message m;
    m.to = toAddr;
    m.cc.push_back(email);
    auto mine = db->query("SELECT e.email FROM person_emails e WHERE e.person_id = $1::int ORDER BY e.is_primary DESC, e.id LIMIT 1", {pid});
    if (!mine.empty()) m.cc.push_back(mine[0]["email"].c_str());
    m.replyTo = email;
    const std::map<std::string, std::string> tok = {{"last_name", lastName}, {"full_name", fullName}, {"email", email}};
    m.subject = fill(subjT, tok);
    m.body = fill(bodyT, tok);
    m.attachments.push_back({fn, mime, bytes});
    if (!fh::mail::sendMessage(m)) {
        removeFile(fileId, 0);
        return "The email to the state did not go out — try again.";
    }
    db->query("UPDATE person_onboarding_steps SET submitted_at = now(), updated_at = now() "
              " WHERE person_id = $1::int AND step_code = 'nsor'", {pid});
    return "";
}
