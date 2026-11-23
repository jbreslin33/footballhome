#include "LeagueEntry.h"

#include <cctype>
#include <map>
#include <set>

#include "../core/Mail.h"
#include "../database/Database.h"

using json = nlohmann::json;

namespace {

std::string s(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

// A person as a form wants them: name, phone, email, address.
json personJson(Database* db, const std::string& pid) {
    if (pid.empty()) return nullptr;
    auto r = db->query(R"SQL(
        SELECT p.id, TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
               (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id ORDER BY ph.is_primary DESC, ph.id LIMIT 1) AS phone,
               (SELECT e.email FROM person_emails e WHERE e.person_id = p.id ORDER BY e.is_primary DESC, e.id LIMIT 1) AS email,
               a.address1, a.city, a.state, a.zip
          FROM persons p
          LEFT JOIN LATERAL (SELECT * FROM person_addresses x WHERE x.person_id = p.id ORDER BY x.is_primary DESC, x.id LIMIT 1) a ON true
         WHERE p.id = $1::int)SQL", {pid});
    if (r.empty()) return nullptr;
    return {{"person_id", r[0]["id"].as<long long>()}, {"name", s(r[0], "name")}, {"phone", s(r[0], "phone")}, {"email", s(r[0], "email")},
            {"address", s(r[0], "address1")}, {"city", s(r[0], "city")}, {"state", s(r[0], "state")}, {"zip", s(r[0], "zip")}};
}

std::string unhex(const std::string& h) {
    std::string out;
    size_t i = (h.size() >= 2 && h[0] == '\\' && h[1] == 'x') ? 2 : 0;
    auto v = [](char c) -> int { return c <= '9' ? c - '0' : (c | 0x20) - 'a' + 10; };
    for (; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>((v(h[i]) << 4) | v(h[i + 1])));
    return out;
}

std::string fill(std::string text, const std::map<std::string, std::string>& tokens) {
    for (const auto& [k, v] : tokens) {
        const std::string key = "{" + k + "}";
        for (size_t pos = text.find(key); pos != std::string::npos; pos = text.find(key, pos + v.size())) text.replace(pos, key.size(), v);
    }
    return text;
}

const std::set<std::string> kTeamText = {"age_group", "team_name", "coach_address", "coach_city", "coach_state", "coach_zip",
    "assistant_address", "assistant_city", "assistant_state", "assistant_zip", "home_court", "court_availability",
    "unavailable_1", "unavailable_2", "unavailable_3", "unavailable_4", "prev_age_group", "prev_record"};

}  // namespace

json LeagueEntry::board() {
    auto* db = Database::getInstance();
    json entries = json::array();
    for (const auto& e : db->query(R"SQL(
            SELECT e.id, e.title, e.season_label, e.director_person_id, e.send_to_name, e.send_to_email, e.fee_returning_usd::float8 AS fr,
                   e.fee_new_usd::float8 AS fn, e.payable_to, e.note, e.sent_at, l.name AS league, c.name AS club
              FROM league_entries e JOIN leagues l ON l.id = e.league_id JOIN clubs c ON c.id = e.club_id
             WHERE e.is_active ORDER BY e.id DESC)SQL")) {
        const std::string eid = e["id"].c_str();
        json ej = {{"id", e["id"].as<long long>()}, {"title", s(e, "title")}, {"season_label", s(e, "season_label")}, {"league", s(e, "league")},
                   {"club", s(e, "club")}, {"send_to_name", s(e, "send_to_name")}, {"send_to_email", s(e, "send_to_email")},
                   {"fee_returning", e["fr"].as<double>()}, {"fee_new", e["fn"].as<double>()}, {"payable_to", s(e, "payable_to")},
                   {"note", s(e, "note")}, {"sent_at", e["sent_at"].is_null() ? json(nullptr) : json(e["sent_at"].c_str())},
                   {"director", personJson(db, s(e, "director_person_id"))}, {"teams", json::array()}, {"items", json::array()}};
        int returning = 0, fresh = 0;
        for (const auto& t : db->query(R"SQL(
                SELECT et.*, t.name AS fh_team FROM league_entry_teams et JOIN teams t ON t.id = et.team_id
                 WHERE et.entry_id = $1::int ORDER BY et.sort_order, et.id)SQL", {eid})) {
            json tj = {{"id", t["id"].as<long long>()}, {"team_id", t["team_id"].as<long long>()}, {"fh_team", s(t, "fh_team")},
                       {"gender", s(t, "gender")}, {"is_returning", t["is_returning"].as<bool>()}, {"max_roster", t["max_roster"].as<int>()},
                       {"coach", personJson(db, s(t, "coach_person_id"))}, {"assistant", personJson(db, s(t, "assistant_person_id"))},
                       {"coaches", json::array()}, {"roster", json::array()}};
            for (const auto& k : kTeamText) tj[k] = s(t, k.c_str());
            (t["is_returning"].as<bool>() ? returning : fresh)++;
            // who can be named coach: the team's coaches
            for (const auto& c : db->query(R"SQL(
                    SELECT DISTINCT p.id, TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name
                      FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id JOIN persons p ON p.id = c.person_id
                     WHERE tc.team_id = $1::int AND tc.ended_at IS NULL ORDER BY 2)SQL", {s(t, "team_id")}))
                tj["coaches"].push_back({{"person_id", c["id"].as<long long>()}, {"name", s(c, "name")}});
            // the official roster: the team's live players, a parent's phone each
            for (const auto& p : db->query(R"SQL(
                    SELECT p.id, TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
                           to_char(p.birth_date, 'MM/DD/YYYY') AS dob,
                           COALESCE((SELECT ph.phone_number FROM person_guardians g JOIN person_phones ph ON ph.person_id = g.guardian_person_id
                                      WHERE g.child_person_id = p.id ORDER BY g.is_primary DESC, ph.is_primary DESC, ph.id LIMIT 1),
                                    (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id ORDER BY ph.is_primary DESC, ph.id LIMIT 1)) AS phone
                      FROM team_persons tp JOIN persons p ON p.id = tp.person_id
                     WHERE tp.team_id = $1::int AND tp.removed_at IS NULL
                     ORDER BY p.last_name, p.first_name, p.id)SQL", {s(t, "team_id")}))
                tj["roster"].push_back({{"person_id", p["id"].as<long long>()}, {"name", s(p, "name")}, {"dob", s(p, "dob")}, {"phone", s(p, "phone")}});
            ej["teams"].push_back(tj);
        }
        ej["fees"] = {{"returning", returning}, {"new", fresh},
                      {"total", returning * e["fr"].as<double>() + fresh * e["fn"].as<double>()}};
        for (const auto& i : db->query(R"SQL(
                SELECT i.id, i.entry_team_id, i.kind, i.label, i.how, i.template_file_id, i.done_at, f.original_filename
                  FROM league_entry_items i LEFT JOIN club_files f ON f.id = i.template_file_id
                 WHERE i.entry_id = $1::int ORDER BY i.sort_order, i.id)SQL", {eid}))
            ej["items"].push_back({{"id", i["id"].as<long long>()}, {"entry_team_id", i["entry_team_id"].is_null() ? json(nullptr) : json(i["entry_team_id"].as<long long>())},
                                   {"kind", s(i, "kind")}, {"label", s(i, "label")}, {"how", s(i, "how")},
                                   {"template_file_id", i["template_file_id"].is_null() ? json(nullptr) : json(i["template_file_id"].as<long long>())},
                                   {"template_filename", s(i, "original_filename")},
                                   {"done_at", i["done_at"].is_null() ? json(nullptr) : json(i["done_at"].c_str())}});
        entries.push_back(ej);
    }
    return {{"entries", entries}};
}

std::string LeagueEntry::saveTeam(long long entryTeamId, const json& fields) {
    auto* db = Database::getInstance();
    const std::string id = std::to_string(entryTeamId);
    auto cur = db->query("SELECT team_id FROM league_entry_teams WHERE id = $1::int", {id});
    if (cur.empty()) return "Team not found.";
    if (!fields.is_object() || fields.empty()) return "What changes?";
    for (auto it = fields.begin(); it != fields.end(); ++it) {
        const std::string k = it.key();
        if (kTeamText.count(k)) {
            if (!it.value().is_string()) return k + " must be text.";
            std::string v = it.value().get<std::string>();
            if (v.size() > 200) v = v.substr(0, 200);
            db->query("UPDATE league_entry_teams SET " + k + " = $2 WHERE id = $1::int", {id, v});
        } else if (k == "coach_person_id" || k == "assistant_person_id") {
            const long long pid = it.value().is_number_integer() ? it.value().get<long long>() : 0;
            if (pid > 0 && db->query("SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
                                     " WHERE tc.team_id = $1::int AND tc.ended_at IS NULL AND c.person_id = $2::int",
                                     {s(cur[0], "team_id"), std::to_string(pid)}).empty())
                return "That is not a coach of this team.";
            db->query("UPDATE league_entry_teams SET " + k + " = NULLIF($2, '')::int WHERE id = $1::int",
                      {id, pid > 0 ? std::to_string(pid) : std::string()});
        } else if (k == "is_returning") {
            if (!it.value().is_boolean()) return "is_returning must be true or false.";
            db->query("UPDATE league_entry_teams SET is_returning = $2::boolean WHERE id = $1::int", {id, it.value().get<bool>() ? "true" : "false"});
        } else if (k == "gender") {
            const std::string v = it.value().is_string() ? it.value().get<std::string>() : "";
            if (v != "M" && v != "F") return "gender must be M or F.";
            db->query("UPDATE league_entry_teams SET gender = $2 WHERE id = $1::int", {id, v});
        } else {
            return "Unknown field " + k + ".";
        }
    }
    return "";
}

std::string LeagueEntry::saveEntry(long long entryId, const json& fields) {
    auto* db = Database::getInstance();
    const std::string id = std::to_string(entryId);
    if (db->query("SELECT 1 FROM league_entries WHERE id = $1::int", {id}).empty()) return "Entry not found.";
    if (!fields.is_object() || fields.empty()) return "What changes?";
    for (auto it = fields.begin(); it != fields.end(); ++it) {
        const std::string k = it.key();
        if (k != "send_to_name" && k != "send_to_email" && k != "note") return "Unknown field " + k + ".";
        if (!it.value().is_string()) return k + " must be text.";
        std::string v;
        for (char c : it.value().get<std::string>()) if (c != '\r' && (c != '\n' || k == "note")) v.push_back(c);
        if (k == "send_to_email" && !v.empty() && (v.find('@') == std::string::npos || v.find(' ') != std::string::npos)) return "That is not an email address.";
        db->query("UPDATE league_entries SET " + k + " = $2 WHERE id = $1::int", {id, v.substr(0, 400)});
    }
    return "";
}

std::string LeagueEntry::tick(long long itemId, bool done, long long userId) {
    auto* db = Database::getInstance();
    auto r = db->query("UPDATE league_entry_items SET done_at = CASE WHEN $2::boolean THEN now() END, "
                       "       done_by = CASE WHEN $2::boolean THEN NULLIF($3, '')::int END WHERE id = $1::int RETURNING id",
                       {std::to_string(itemId), done ? "true" : "false", userId > 0 ? std::to_string(userId) : std::string()});
    return r.empty() ? "Item not found." : "";
}

std::string LeagueEntry::send(long long entryId, const std::vector<File>& files, long long userId, int* sent) {
    *sent = 0;
    auto* db = Database::getInstance();
    const std::string id = std::to_string(entryId);
    auto e = db->query("SELECT e.title, e.send_to_name, e.send_to_email, e.director_person_id, c.name AS club "
                       "  FROM league_entries e JOIN clubs c ON c.id = e.club_id WHERE e.id = $1::int", {id});
    if (e.empty()) return "Entry not found.";
    const std::string to = s(e[0], "send_to_email");
    if (to.empty()) return "Fill in who it goes to first.";
    if (files.empty()) return "No forms to send.";
    if (files.size() > 12) return "Too many files.";
    auto admin = db->query(
        "SELECT TRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name, "
        "       (SELECT x.email FROM person_emails x WHERE x.person_id = p.id ORDER BY x.is_primary DESC, x.id LIMIT 1) AS email "
        "  FROM users u JOIN persons p ON p.id = u.person_id WHERE u.id = $1::int", {std::to_string(userId)});
    const std::string senderName = admin.empty() ? "" : s(admin[0], "name"), senderEmail = admin.empty() ? "" : s(admin[0], "email");

    fh::mail::Message m;
    m.to = to;
    if (!senderEmail.empty()) { m.cc.push_back(senderEmail); m.replyTo = senderEmail; }
    std::string list;
    long long total = 0;
    for (const auto& f : files) {
        std::string b64, name;
        const size_t comma = f.base64.rfind("base64,");
        for (size_t i = comma == std::string::npos ? 0 : comma + 7; i < f.base64.size(); ++i) {
            const char c = f.base64[i];
            if (std::isalnum(static_cast<unsigned char>(c)) || c == '+' || c == '/' || c == '=') b64.push_back(c);
        }
        for (char c : f.filename) if (c != '\r' && c != '\n' && c != '/' && c != '\\' && c != '"') name.push_back(c);
        if (b64.empty() || name.empty()) return "A form came through empty — try again.";
        auto bin = db->query("SELECT encode(decode($1, 'base64'), 'hex') AS h", {b64});
        std::string bytes = unhex(bin[0]["h"].c_str());
        // a Word file is a zip: "PK\x03\x04"
        if (bytes.size() < 4 || bytes.compare(0, 4, std::string("PK\x03\x04", 4)) != 0) return name + " is not a Word file.";
        total += static_cast<long long>(bytes.size());
        if (total > 8LL * 1024 * 1024) return "The forms are too big for one email.";
        list += "• " + name + "\n";
        m.attachments.push_back({name.substr(0, 120), "application/vnd.openxmlformats-officedocument.wordprocessingml.document", std::move(bytes)});
    }
    auto words = db->query("SELECT COALESCE(subject, '') AS s, body FROM message_templates "
                           " WHERE kind = 'league_entry' AND tier = 'email' AND is_active ORDER BY sort_order, id LIMIT 1");
    const std::string subjT = words.empty() || s(words[0], "s").empty() ? "{club} — {league_title} registration" : s(words[0], "s");
    const std::string bodyT = words.empty() ? "Hi {to_name},\n\nAttached are the registration forms for {club} for {league_title}:\n\n{list}\nThanks,\n{sender}" : s(words[0], "body");
    std::string toName = s(e[0], "send_to_name");
    if (const auto sp = toName.find(' '); sp != std::string::npos) toName = toName.substr(0, sp);
    const std::map<std::string, std::string> tok = {{"club", s(e[0], "club")}, {"league_title", s(e[0], "title")}, {"to_name", toName},
                                                    {"list", list}, {"sender", senderName}};
    m.subject = fill(subjT, tok);
    m.body = fill(bodyT, tok);
    if (!fh::mail::sendMessage(m)) return "The email did not go out — try again.";
    *sent = static_cast<int>(files.size());
    db->query("UPDATE league_entries SET sent_at = now(), sent_by = NULLIF($2, '')::int WHERE id = $1::int",
              {id, userId > 0 ? std::to_string(userId) : std::string()});
    return "";
}
