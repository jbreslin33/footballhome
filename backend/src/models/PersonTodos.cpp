#include "PersonTodos.h"

#include <cctype>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {

json textOrNull(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(std::string(f.c_str())); }

// Midnight today, club time — a daily item ticked before it is due again.
const char* const TODAY = "(date_trunc('day', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York')";

std::string trimmed(const std::string& s) {
    const auto b = s.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return "";
    const auto e = s.find_last_not_of(" \t\r\n");
    return s.substr(b, e - b + 1);
}

}  // namespace

json PersonTodos::list(long long personId) {
    json out = {{"todos", json::array()}, {"due", 0}};
    if (personId <= 0) return out;
    auto* db = Database::getInstance();
    const std::string today = TODAY;
    auto rows = db->query(
        "WITH t AS ( "
        "  SELECT pt.*, "
        "         CASE WHEN pt.repeat = 'daily' AND pt.done_at < " + today + " THEN NULL ELSE pt.done_at END AS done_shown "
        "    FROM person_todos pt "
        "   WHERE pt.person_id = $1::int "
        "     AND (pt.repeat = 'daily' OR pt.done_at IS NULL OR pt.done_at > now() - INTERVAL '7 days')) "
        "SELECT t.id, t.body, t.repeat, to_char(t.due_on, 'YYYY-MM-DD') AS due_on, "
        "       to_char(t.remind_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS remind_at, "
        "       to_char(t.done_shown AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS done_at, "
        "       (t.done_shown IS NULL AND (t.remind_at IS NULL OR t.remind_at <= now())) AS due, "
        "       (t.assigned_by_person_id IS NULL OR t.assigned_by_person_id = t.person_id) AS mine, "
        "       NULLIF(TRIM(CONCAT_WS(' ', ap.first_name, ap.last_name)), '') AS from_name, "
        "       t.photo_proof, to_char(t.call_at, 'HH24:MI') AS call_at, t.guide_id, ph.id AS photo_id, "
        "       to_char(ph.uploaded_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS photo_at, "
        "       tc.id AS cat_id, tc.name AS cat_name, tc.icon AS cat_icon, tc.sort_order AS cat_sort "   // mig 2215
        "  FROM t LEFT JOIN persons ap ON ap.id = t.assigned_by_person_id AND ap.id <> t.person_id "
        "  LEFT JOIN todo_categories tc ON tc.id = t.category_id "
        "  LEFT JOIN LATERAL (SELECT x.id, x.uploaded_at FROM person_todo_photos x WHERE x.person_todo_id = t.id "
        "                        AND x.club_day = (now() AT TIME ZONE 'America/New_York')::date "
        "                      ORDER BY x.uploaded_at DESC LIMIT 1) ph ON true "
        " ORDER BY t.done_shown IS NOT NULL, t.done_shown DESC, t.due_on NULLS LAST, t.remind_at NULLS FIRST, t.id",
        {std::to_string(personId)});
    int due = 0;
    for (const auto& r : rows) {
        const bool isDue = r["due"].as<bool>();
        if (isDue) ++due;
        out["todos"].push_back({
            {"id",        r["id"].as<long long>()},
            {"body",      r["body"].c_str()},
            {"remind_at", textOrNull(r["remind_at"])},
            {"done_at",   textOrNull(r["done_at"])},
            {"due",       isDue},
            {"repeat",    textOrNull(r["repeat"])},
            {"due_on",    textOrNull(r["due_on"])},
            {"from",      textOrNull(r["from_name"])},
            {"mine",      r["mine"].as<bool>()},
            {"photo_proof", r["photo_proof"].as<bool>()},
            {"call_at",   textOrNull(r["call_at"])},
            {"guide_id",  r["guide_id"].is_null() ? json(nullptr) : json(r["guide_id"].as<long long>())},
            {"photo_id",  r["photo_id"].is_null() ? json(nullptr) : json(r["photo_id"].as<long long>())},
            {"photo_at",  textOrNull(r["photo_at"])},
            // one 🚦 band box per category (mig 2215); null = the plain To do box
            {"category",  r["cat_id"].is_null() ? json(nullptr)
                          : json{{"id", r["cat_id"].as<long long>()}, {"name", r["cat_name"].c_str()},
                                 {"icon", textOrNull(r["cat_icon"])}, {"sort", r["cat_sort"].as<long long>()}}},
        });
    }
    out["due"] = due;
    return out;
}

std::string PersonTodos::add(long long personId, const std::string& body, const std::string& remindAtIso,
                             long long categoryId) {
    if (personId <= 0) return "Sign in first";
    const auto b = body.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return "Type what to do";
    if (body.size() > 500) return "Keep it under 500 characters";
    auto* db = Database::getInstance();
    try {
        db->query(
            "INSERT INTO person_todos (person_id, body, remind_at, category_id) "
            "VALUES ($1::int, btrim($2), NULLIF($3, '')::timestamptz, "
            "        (SELECT id FROM todo_categories WHERE id = NULLIF($4::int, 0)))",
            {std::to_string(personId), body, remindAtIso, std::to_string(categoryId > 0 ? categoryId : 0)});
    } catch (const std::exception&) {
        return "That time didn't read — pick it again";
    }
    return "";
}

bool PersonTodos::setDone(long long personId, long long id, bool done) {
    auto* db = Database::getInstance();
    auto r = db->query(
        std::string("UPDATE person_todos SET done_at = ") + (done ? "now()" : "NULL") +
        " WHERE id = $1::bigint AND person_id = $2::int RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}

bool PersonTodos::remove(long long personId, long long id) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "DELETE FROM person_todos WHERE id = $1::bigint AND person_id = $2::int "
        "   AND (assigned_by_person_id IS NULL OR assigned_by_person_id = person_id) RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}

// ── Staff ───────────────────────────────────────────────────────────────

bool PersonTodos::canGive(long long viewerUserId, long long personId) {
    if (viewerUserId <= 0 || personId <= 0) return false;
    auto* db = Database::getInstance();
    auto r = db->query(
        "SELECT EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
        "                WHERE a.user_id = $1::int AND al.name IN ('club', 'super')) "
        "    OR EXISTS (SELECT 1 FROM team_persons tp "
        "                 JOIN team_coaches tc ON tc.team_id = tp.team_id AND tc.ended_at IS NULL "
        "                 JOIN coaches co ON co.id = tc.coach_id "
        "                 JOIN users u ON u.person_id = co.person_id AND u.id = $1::int "
        "                WHERE tp.person_id = $2::int AND tp.removed_at IS NULL) AS ok",
        {std::to_string(viewerUserId), std::to_string(personId)});
    return !r.empty() && r[0]["ok"].as<bool>();
}

json PersonTodos::sheet(long long personId, long long viewerUserId) {
    auto* db = Database::getInstance();
    const std::string p = std::to_string(personId), v = std::to_string(viewerUserId), today = TODAY;
    json out = {{"personId", personId}, {"canGive", canGive(viewerUserId, personId)},
                {"teams", json::array()}, {"todos", json::array()}};
    if (!out["canGive"].get<bool>()) return out;

    // His teams the viewer may give a whole-team item to.
    for (const auto& t : db->query(
             "SELECT t.id, COALESCE(t.short_label, t.label, t.name) AS label, "
             "       (SELECT count(*) FROM team_persons x WHERE x.team_id = t.id AND x.removed_at IS NULL) AS n "
             "  FROM team_persons tp "
             "  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL "
             " WHERE tp.person_id = $1::int AND tp.removed_at IS NULL "
             "   AND (EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
             "                 WHERE a.user_id = $2::int AND al.name IN ('club', 'super')) "
             "        OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
             "                     JOIN users u ON u.person_id = co.person_id "
             "                    WHERE u.id = $2::int AND tc.team_id = t.id AND tc.ended_at IS NULL)) "
             " ORDER BY t.board_sort_order, t.id", {p, v})) {
        out["teams"].push_back({{"teamId", t["id"].as<long long>()}, {"label", t["label"].c_str()},
                                {"n", t["n"].as<long long>()}});
    }

    for (const auto& r : db->query(
             "SELECT pt.id, pt.body, pt.repeat, pt.batch_id, "
             "       to_char(pt.due_on, 'YYYY-MM-DD') AS due_on, "
             "       to_char(pt.remind_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS remind_at, "
             "       to_char(pt.done_at    AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS done_at, "
             "       to_char(pt.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
             "       (pt.done_at >= " + today + ") AS done_today, "
             "       (pt.assigned_by_person_id IS NULL OR pt.assigned_by_person_id = pt.person_id) AS mine, "
             "       NULLIF(TRIM(CONCAT_WS(' ', ap.first_name, ap.last_name)), '') AS from_name, "
             "       (SELECT count(*) FROM person_todos b WHERE b.batch_id = pt.batch_id) AS batch_n, "
             "       pt.photo_proof, to_char(pt.call_at, 'HH24:MI') AS call_at, "
             "       (SELECT x.id FROM person_todo_photos x WHERE x.person_todo_id = pt.id "
             "           AND x.club_day = (now() AT TIME ZONE 'America/New_York')::date ORDER BY x.uploaded_at DESC LIMIT 1) AS photo_id, "
             "       (SELECT to_char(c.placed_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') FROM person_todo_calls c "
             "         WHERE c.person_todo_id = pt.id AND c.club_day = (now() AT TIME ZONE 'America/New_York')::date AND c.ok) AS called_at "
             "  FROM person_todos pt LEFT JOIN persons ap ON ap.id = pt.assigned_by_person_id "
             " WHERE pt.person_id = $1::int "
             "   AND (pt.repeat = 'daily' OR pt.done_at IS NULL OR pt.done_at > now() - INTERVAL '60 days') "
             " ORDER BY mine, (pt.repeat IS NULL AND pt.done_at IS NOT NULL), pt.due_on NULLS LAST, pt.created_at DESC",
             {p})) {
        out["todos"].push_back({
            {"id",         r["id"].as<long long>()},
            {"body",       r["body"].c_str()},
            {"repeat",     textOrNull(r["repeat"])},
            {"due_on",     textOrNull(r["due_on"])},
            {"remind_at",  textOrNull(r["remind_at"])},
            {"done_at",    textOrNull(r["done_at"])},
            {"done_today", !r["done_today"].is_null() && r["done_today"].as<bool>()},
            {"created_at", textOrNull(r["created_at"])},
            {"mine",       r["mine"].as<bool>()},
            {"from",       textOrNull(r["from_name"])},
            {"batch_id",   r["batch_id"].is_null() ? json(nullptr) : json(r["batch_id"].as<long long>())},
            {"batch_n",    r["batch_n"].as<long long>()},
            {"photo_proof", r["photo_proof"].as<bool>()},
            {"call_at",    textOrNull(r["call_at"])},
            {"photo_id",   r["photo_id"].is_null() ? json(nullptr) : json(r["photo_id"].as<long long>())},
            {"called_at",  textOrNull(r["called_at"])},
        });
    }
    return out;
}

int PersonTodos::give(long long viewerUserId, long long personId, long long teamId,
                      const std::string& body, const std::string& repeat,
                      const std::string& dueOn, std::string& err) {
    const std::string b = trimmed(body);
    if (b.empty()) { err = "Type what to do"; return 0; }
    if (b.size() > 500) { err = "Keep it under 500 characters"; return 0; }
    if (!repeat.empty() && repeat != "daily") { err = "Unknown repeat"; return 0; }
    auto* db = Database::getInstance();
    try {
        // One INSERT: the player, or everyone on the team.  A team add
        // carries one batch_id (a fresh id off the table's own sequence) so
        // the whole lot can be taken back together.
        auto r = db->query(
            "WITH who AS ( "
            "  SELECT DISTINCT tp.person_id FROM team_persons tp "
            "   WHERE $2::int > 0 AND tp.team_id = $2::int AND tp.removed_at IS NULL "
            "  UNION SELECT $1::int WHERE $2::int <= 0), "
            "batch AS (SELECT CASE WHEN $2::int > 0 THEN nextval('person_todos_id_seq') END AS id), "
            "ins AS ( "
            "  INSERT INTO person_todos (person_id, body, repeat, due_on, assigned_by_person_id, batch_id) "
            "  SELECT who.person_id, $3, NULLIF($4, ''), NULLIF($5, '')::date, "
            "         (SELECT u.person_id FROM users u WHERE u.id = $6::int), (SELECT id FROM batch) "
            "    FROM who RETURNING id) "
            "SELECT count(*) AS n FROM ins",
            {std::to_string(personId), std::to_string(teamId), b, repeat, dueOn, std::to_string(viewerUserId)});
        return r.empty() ? 0 : r[0]["n"].as<int>();
    } catch (const std::exception&) {
        err = "That date didn't read — pick it again";
        return 0;
    }
}

bool PersonTodos::take(long long personId, long long id, bool all) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "DELETE FROM person_todos d USING person_todos src "
        " WHERE src.id = $1::bigint AND src.person_id = $2::int "
        "   AND src.assigned_by_person_id IS NOT NULL AND src.assigned_by_person_id <> src.person_id "
        "   AND (d.id = src.id OR ($3::bool AND src.batch_id IS NOT NULL AND d.batch_id = src.batch_id)) "
        "RETURNING d.id",
        {std::to_string(id), std::to_string(personId), all ? "true" : "false"});
    return !r.empty();
}

// ── 📷 Photo proof / 📖 guide (mig 1944) ───────────────────────────────

namespace {

// The first bytes (hex) → mime; "" = not a photo we take.
std::string sniffPhoto(const std::string& hex) {
    if (hex.rfind("ffd8ff", 0) == 0) return "image/jpeg";
    if (hex.rfind("89504e47", 0) == 0) return "image/png";
    if (hex.size() >= 24 && hex.rfind("52494646", 0) == 0 && hex.substr(16, 8) == "57454250") return "image/webp";
    if (hex.size() >= 16 && hex.substr(8, 8) == "66747970") return "image/heic";   // ISO-BMFF "ftyp" (HEIC / HEIF)
    return "";
}

std::string unhex(const std::string& h) {
    auto v = [](char c) { return c <= '9' ? c - '0' : (c | 32) - 'a' + 10; };
    std::string out;
    out.reserve(h.size() / 2);
    for (size_t i = 0; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>(v(h[i]) * 16 + v(h[i + 1])));
    return out;
}

const char* const CLUB_DAY = "(now() AT TIME ZONE 'America/New_York')::date";

}  // namespace

std::string PersonTodos::addPhoto(long long personId, long long id, const std::string& dataUrl) {
    if (personId <= 0) return "Sign in first";
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId), tid = std::to_string(id);
    auto own = db->query("SELECT photo_proof FROM person_todos WHERE id = $1::bigint AND person_id = $2::int", {tid, pid});
    if (own.empty()) return "That item is gone";
    std::string b64;
    b64.reserve(dataUrl.size());
    const size_t comma = dataUrl.rfind("base64,");
    for (size_t i = comma == std::string::npos ? 0 : comma + 7; i < dataUrl.size(); ++i) {
        const char c = dataUrl[i];
        if (std::isalnum(static_cast<unsigned char>(c)) || c == '+' || c == '/' || c == '=') b64.push_back(c);
    }
    if (b64.empty()) return "No photo came through — try again";
    auto info = db->query("SELECT octet_length(decode($1, 'base64')) AS n, "
                          "       encode(substring(decode($1, 'base64') from 1 for 16), 'hex') AS head", {b64});
    const long long n = info[0]["n"].as<long long>();
    if (n <= 0) return "No photo came through — try again";
    if (n > 10LL * 1024 * 1024) return "That photo is over 10 MB";
    const std::string mime = sniffPhoto(info[0]["head"].c_str());
    if (mime.empty()) return "Upload a photo (JPG, PNG, HEIC)";
    db->query(std::string("INSERT INTO person_todo_photos (person_todo_id, club_day, mime, byte_size, bytes) "
                          "VALUES ($1::bigint, ") + CLUB_DAY + ", $2, $3::int, decode($4, 'base64'))",
              {tid, mime, std::to_string(n), b64});
    db->query("UPDATE person_todos SET done_at = now() WHERE id = $1::bigint", {tid});
    return "";
}

bool PersonTodos::photo(long long viewerPersonId, long long photoId, Photo& out) {
    if (viewerPersonId <= 0 || photoId <= 0) return false;
    auto* db = Database::getInstance();
    auto r = db->query("SELECT pt.person_id, ph.mime, encode(ph.bytes, 'hex') AS h "
                       "  FROM person_todo_photos ph JOIN person_todos pt ON pt.id = ph.person_todo_id "
                       " WHERE ph.id = $1::bigint", {std::to_string(photoId)});
    if (r.empty()) return false;
    const long long owner = r[0]["person_id"].as<long long>();
    if (owner != viewerPersonId) {
        bool staff = false;
        for (const auto& u : db->query("SELECT id FROM users WHERE person_id = $1::int", {std::to_string(viewerPersonId)}))
            if (canGive(u["id"].as<long long>(), owner)) { staff = true; break; }
        if (!staff) return false;
    }
    out.mime = r[0]["mime"].c_str();
    out.bytes = unhex(r[0]["h"].c_str());
    return true;
}

json PersonTodos::guide(long long guideId) {
    auto* db = Database::getInstance();
    auto g = db->query("SELECT id, slug, title, intro FROM todo_guides WHERE id = $1::int", {std::to_string(guideId)});
    if (g.empty()) return nullptr;
    json out = {{"id", g[0]["id"].as<long long>()}, {"slug", g[0]["slug"].c_str()}, {"title", g[0]["title"].c_str()},
                {"intro", g[0]["intro"].c_str()}, {"sections", json::array()}};
    long long cur = -1;
    for (const auto& r : db->query(
             "SELECT s.id AS sid, s.title, s.note, i.name, i.how, i.dose "
             "  FROM todo_guide_sections s LEFT JOIN todo_guide_items i ON i.section_id = s.id "
             " WHERE s.guide_id = $1::int ORDER BY s.sort, i.sort", {std::to_string(guideId)})) {
        const long long sid = r["sid"].as<long long>();
        if (sid != cur) {
            out["sections"].push_back({{"title", r["title"].c_str()}, {"note", r["note"].c_str()}, {"items", json::array()}});
            cur = sid;
        }
        if (!r["name"].is_null())
            out["sections"].back()["items"].push_back({{"name", r["name"].c_str()}, {"how", r["how"].c_str()}, {"dose", r["dose"].c_str()}});
    }
    return out;
}
