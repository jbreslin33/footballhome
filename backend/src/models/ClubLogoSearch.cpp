#include "ClubLogoSearch.h"

#include "../database/Database.h"

using nlohmann::json;

ClubLogoSearch::ClubLogoSearch() : db_(Database::getInstance()) {}

bool ClubLogoSearch::alreadyKnown(const std::string& text) {
    return !db_->query("SELECT 1 FROM club_logo_searches WHERE LOWER(BTRIM(opponent_text)) = LOWER(BTRIM($1))",
                       {text}).empty();
}

long long ClubLogoSearch::enqueue(const std::string& text, long long personId, bool force) {
    auto rows = db_->query(R"SQL(
        INSERT INTO club_logo_searches (opponent_text, context, requested_by)
        VALUES (BTRIM($1), $2, NULLIF($3, '0')::int)
        ON CONFLICT (LOWER(BTRIM(opponent_text))) DO UPDATE
           SET status = CASE WHEN $4::boolean AND club_logo_searches.status IN ('none', 'failed')
                             THEN 'queued' ELSE club_logo_searches.status END,
               requested_by = COALESCE(NULLIF($3, '0')::int, club_logo_searches.requested_by),
               requested_at = CASE WHEN $4::boolean AND club_logo_searches.status IN ('none', 'failed')
                                   THEN now() ELSE club_logo_searches.requested_at END,
               context = COALESCE(NULLIF($2, ''), club_logo_searches.context)
        RETURNING id)SQL",
        {text, contextFor(text), std::to_string(personId), force ? "true" : "false"});
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

std::vector<ClubLogoSearch::Row> ClubLogoSearch::nextQueued(int limit) {
    std::vector<Row> out;
    for (const auto& r : db_->query(
             "SELECT id, opponent_text, COALESCE(context, '') AS context, status, attempts "
             "  FROM club_logo_searches WHERE status = 'queued' AND attempts < 3 "
             " ORDER BY requested_at LIMIT $1::int", {std::to_string(limit)})) {
        Row row;
        row.id = r["id"].as<long long>();
        row.opponentText = r["opponent_text"].c_str();
        row.context = r["context"].c_str();
        row.status = r["status"].c_str();
        row.attempts = r["attempts"].as<int>();
        out.push_back(row);
    }
    return out;
}

void ClubLogoSearch::markRunning(long long id) {
    db_->query("UPDATE club_logo_searches SET status = 'running', started_at = now(), attempts = attempts + 1, "
               "error = NULL WHERE id = $1::int", {std::to_string(id)});
}

void ClubLogoSearch::finish(long long id, const Result& r) {
    db_->query(R"SQL(
        UPDATE club_logo_searches
           SET status = $2, finished_at = now(), provider = NULLIF($3, ''), model = NULLIF($4, ''),
               club_name_found = NULLIF($5, ''), club_id = NULLIF($6, '0')::int, logo_id = NULLIF($7, '0')::int,
               image_url = NULLIF($8, ''), page_url = NULLIF($9, ''), confidence = $10::real,
               judge_note = NULLIF($11, ''), reason = NULLIF($12, ''), error = NULLIF($13, '')
         WHERE id = $1::int)SQL",
        {std::to_string(id), r.status, r.provider, r.model, r.clubNameFound, std::to_string(r.clubId),
         std::to_string(r.logoId), r.imageUrl, r.pageUrl, std::to_string(r.confidence), r.judgeNote,
         r.reason, r.error});
}

bool ClubLogoSearch::reject(long long id, long long personId) {
    auto rows = db_->query(
        "UPDATE club_logo_searches SET status = 'rejected', rejected_by = NULLIF($2, '0')::int, rejected_at = now() "
        " WHERE id = $1::int AND status = 'found' RETURNING club_id, logo_id",
        {std::to_string(id), std::to_string(personId)});
    if (rows.empty()) return false;
    if (!rows[0]["club_id"].is_null() && !rows[0]["logo_id"].is_null()) {
        // Fall back to the club's previous crest if it has one, else none.
        const std::string clubId = rows[0]["club_id"].c_str(), logoId = rows[0]["logo_id"].c_str();
        db_->query(R"SQL(
            UPDATE clubs c SET logo_id = prev.id, logo_url = prev.file_path, updated_at = now()
              FROM (SELECT l.id, l.file_path FROM club_logos l
                     WHERE l.club_id = ::int AND l.id <> ::int
                     ORDER BY l.created_at DESC LIMIT 1) prev
             WHERE c.id = ::int AND c.logo_id = ::int)SQL", {clubId, logoId});
        db_->query("UPDATE clubs SET logo_id = NULL, logo_url = '', updated_at = now() "
                   " WHERE id = ::int AND logo_id = ::int", {clubId, logoId});
        db_->query("DELETE FROM club_aliases WHERE club_id = $1::int AND notes = 'found online (search)' "
                   "  AND LOWER(BTRIM(alias)) = (SELECT LOWER(BTRIM(opponent_text)) FROM club_logo_searches WHERE id = $2::int)",
                   {rows[0]["club_id"].c_str(), std::to_string(id)});
    }
    return true;
}

std::string ClubLogoSearch::contextFor(const std::string& text) {
    auto rows = db_->query(R"SQL(
        SELECT string_agg(DISTINCT x, ' · ') AS ctx FROM (
            SELECT 'league ' || fe.league AS x FROM fh_events fe
             WHERE LOWER(BTRIM(fe.opponent)) = LOWER(BTRIM($1)) AND COALESCE(fe.league, '') <> ''
            UNION
            SELECT fe.category || ' section' FROM fh_events fe
             WHERE LOWER(BTRIM(fe.opponent)) = LOWER(BTRIM($1)) AND COALESCE(fe.category, '') <> ''
            UNION
            SELECT 'our team ' || t.name FROM fh_events fe
              JOIN fh_event_teams fet ON fet.fh_event_id = fe.id JOIN teams t ON t.id = fet.team_id
             WHERE LOWER(BTRIM(fe.opponent)) = LOWER(BTRIM($1))
        ) s)SQL", {text});
    if (rows.empty() || rows[0]["ctx"].is_null()) return "";
    return rows[0]["ctx"].c_str();
}

json ClubLogoSearch::recent(int limit) {
    json out = json::array();
    for (const auto& r : db_->query(R"SQL(
        SELECT s.id, s.opponent_text, s.status, s.attempts, s.club_name_found, s.club_id, s.image_url, s.page_url,
               s.confidence, s.judge_note, s.reason, s.error, s.requested_by IS NULL AS automatic,
               c.name AS club_name, COALESCE(c.logo_url, '') AS logo_url, (c.logo_id = s.logo_id) AS is_current,
               to_char(COALESCE(s.finished_at, s.requested_at) AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS when_label
          FROM club_logo_searches s
          LEFT JOIN clubs c ON c.id = s.club_id
         ORDER BY COALESCE(s.finished_at, s.requested_at) DESC
         LIMIT $1::int)SQL", {std::to_string(limit)})) {
        auto txt = [&](const char* k) { return r[k].is_null() ? json("") : json(r[k].c_str()); };
        out.push_back({
            {"id", r["id"].as<long long>()}, {"opponent", r["opponent_text"].c_str()},
            {"status", r["status"].c_str()}, {"attempts", r["attempts"].as<int>()},
            {"club_name_found", txt("club_name_found")}, {"club_name", txt("club_name")},
            {"club_id", r["club_id"].is_null() ? json(nullptr) : json(r["club_id"].as<long long>())},
            {"image_url", txt("image_url")}, {"page_url", txt("page_url")}, {"logo_url", txt("logo_url")},
            {"is_current", !r["is_current"].is_null() && r["is_current"].as<bool>()},
            {"confidence", r["confidence"].is_null() ? 0.0 : r["confidence"].as<double>()},
            {"judge_note", txt("judge_note")}, {"reason", txt("reason")}, {"error", txt("error")},
            {"automatic", r["automatic"].as<bool>()}, {"when_label", txt("when_label")},
        });
    }
    return out;
}
