#include "Contacts.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {
std::vector<std::string> pgTextArray(const std::string& lit) {
    // '{a,b,"c d"}' → [a, b, c d]  (values here hold no quotes/braces of their own)
    std::vector<std::string> out;
    if (lit.size() < 2) return out;
    std::string cur; bool inq = false;
    for (size_t i = 1; i + 1 < lit.size(); ++i) {
        const char c = lit[i];
        if (c == '"') { inq = !inq; continue; }
        if (c == '\\' && i + 2 < lit.size()) { cur.push_back(lit[++i]); continue; }
        if (c == ',' && !inq) { if (!cur.empty()) out.push_back(cur); cur.clear(); continue; }
        cur.push_back(c);
    }
    if (!cur.empty()) out.push_back(cur);
    return out;
}
}  // namespace

std::vector<Contacts::Row> Contacts::list(long long userId) {
    auto rows = Database::getInstance()->query(R"SQL(
        WITH board AS (
          SELECT t.id, BTRIM(regexp_replace(COALESCE(t.label, t.name), '^[^[:alnum:]]+', '')) AS label, t.board_sort_order
            FROM teams t WHERE t.is_active AND t.board_sort_order IS NOT NULL
        ), members AS (
          SELECT p.id AS person_id, 'members' AS grp,
                 string_agg(DISTINCT b.label, ', ') AS teams, NULL::text AS kids
            FROM team_persons tp JOIN board b ON b.id = tp.team_id JOIN persons p ON p.id = tp.person_id
           WHERE tp.removed_at IS NULL AND p.parent_person_id IS NULL
           GROUP BY p.id
        ), parents AS (
          SELECT par.id, 'parents', NULL,
                 string_agg(DISTINCT COALESCE(p.first_name, '') || ' (' || b.label || ')', ', ')
            FROM team_persons tp JOIN board b ON b.id = tp.team_id
            JOIN persons p ON p.id = tp.person_id JOIN persons par ON par.id = p.parent_person_id
           WHERE tp.removed_at IS NULL
           GROUP BY par.id
        ), coaches AS (
          SELECT c.person_id, 'coaches', string_agg(DISTINCT b.label, ', '), NULL
            FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id JOIN board b ON b.id = tc.team_id
           WHERE tc.ended_at IS NULL
           GROUP BY c.person_id
        ), staff AS (
          SELECT cs.person_id, 'staff', NULL, NULL FROM club_staff cs WHERE cs.ended_at IS NULL GROUP BY cs.person_id
        ), people AS (
          SELECT * FROM members UNION ALL SELECT * FROM parents UNION ALL SELECT * FROM coaches UNION ALL SELECT * FROM staff
        ), person_rows AS (
          SELECT 'person' AS kind, p.id::bigint AS ref_id,
                 array_agg(pe.grp ORDER BY CASE pe.grp WHEN 'members' THEN 1 WHEN 'coaches' THEN 2 WHEN 'staff' THEN 3 ELSE 4 END) AS groups,
                 COALESCE(p.first_name, '') AS first, COALESCE(p.last_name, '') AS last,
                 (SELECT string_agg(DISTINCT lbl, ', ' ORDER BY lbl)
                    FROM people pe2, unnest(string_to_array(pe2.teams, ', ')) lbl
                   WHERE pe2.person_id = p.id AND pe2.teams IS NOT NULL) AS teams,
                 string_agg(pe.kids, ', ')  FILTER (WHERE pe.kids  IS NOT NULL) AS kids,
                 NULL::text AS org, NULL::text AS role, NULL::text AS since,
                 COALESCE((SELECT array_agg(DISTINCT x.phone_number ORDER BY x.phone_number)
                             FROM person_phones x WHERE x.person_id = p.id AND COALESCE(x.phone_number, '') <> ''), '{}'::text[]) AS phones,
                 COALESCE((SELECT array_agg(DISTINCT lower(e.email) ORDER BY lower(e.email))
                             FROM person_emails e WHERE e.person_id = p.id AND COALESCE(e.email, '') <> ''), '{}'::text[]) AS emails
            FROM people pe JOIN persons p ON p.id = pe.person_id
           GROUP BY p.id, p.first_name, p.last_name
        ), lead_rows AS (
          SELECT 'lead', l.id::bigint, ARRAY['leads'],
                 split_part(BTRIM(l.name), ' ', 1),
                 NULLIF(BTRIM(substr(BTRIM(l.name), length(split_part(BTRIM(l.name), ' ', 1)) + 1)), ''),
                 NULL, NULL, NULL, NULL, to_char(l.created_at AT TIME ZONE 'America/New_York', 'Mon YYYY'),
                 CASE WHEN COALESCE(l.phone, '') <> '' THEN ARRAY[l.phone] ELSE '{}'::text[] END,
                 CASE WHEN COALESCE(l.email, '') <> '' THEN ARRAY[lower(l.email)] ELSE '{}'::text[] END
            FROM leads l WHERE l.dead_at IS NULL
        ), opp_rows AS (
          SELECT 'club_contact', cc.id::bigint, ARRAY['opponents'],
                 split_part(BTRIM(cc.name), ' ', 1),
                 NULLIF(BTRIM(substr(BTRIM(cc.name), length(split_part(BTRIM(cc.name), ' ', 1)) + 1)), ''),
                 NULL, NULL, c.name, cc.role, NULL,
                 CASE WHEN COALESCE(cc.phone, '') <> '' THEN ARRAY[cc.phone] ELSE '{}'::text[] END,
                 CASE WHEN COALESCE(cc.email, '') <> '' THEN ARRAY[lower(cc.email)] ELSE '{}'::text[] END
            FROM club_contacts cc JOIN clubs c ON c.id = cc.club_id WHERE cc.is_active
        ), all_rows AS (
          SELECT * FROM person_rows UNION ALL SELECT * FROM lead_rows UNION ALL SELECT * FROM opp_rows
        )
        SELECT r.kind, r.ref_id, r.groups::text AS groups, r.first, COALESCE(r.last, '') AS last,
               r.teams, r.kids, r.org, r.role, r.since,
               r.phones::text AS phones, r.emails::text AS emails,
               md5(array_to_string(r.phones, '|') || '#' || array_to_string(r.emails, '|')) AS fingerprint,
               CASE WHEN x.fingerprint IS NULL THEN 'new'
                    WHEN x.fingerprint <> md5(array_to_string(r.phones, '|') || '#' || array_to_string(r.emails, '|')) THEN 'changed'
                    ELSE 'done' END AS state
          FROM all_rows r
          LEFT JOIN LATERAL (SELECT ce.fingerprint FROM contact_exports ce
                              WHERE ce.exported_by_user_id = $1::int AND ce.kind = r.kind AND ce.ref_id = r.ref_id
                              ORDER BY ce.exported_at DESC LIMIT 1) x ON true
         WHERE cardinality(r.phones) + cardinality(r.emails) > 0
         ORDER BY r.last, r.first, r.kind, r.ref_id)SQL", {std::to_string(userId)});
    std::vector<Row> out;
    out.reserve(rows.size());
    for (const auto& r : rows) {
        Row row;
        row.kind   = r["kind"].c_str();
        row.refId  = r["ref_id"].as<long long>();
        row.groups = pgTextArray(r["groups"].c_str());
        row.first  = r["first"].c_str();
        row.last   = r["last"].c_str();
        auto str = [&](const char* k) { return r[k].is_null() ? std::string{} : std::string(r[k].c_str()); };
        row.teams = str("teams"); row.kids = str("kids"); row.org = str("org");
        row.role = str("role");   row.since = str("since");
        row.phones = pgTextArray(r["phones"].c_str());
        row.emails = pgTextArray(r["emails"].c_str());
        row.fingerprint = r["fingerprint"].c_str();
        row.state = r["state"].c_str();
        out.push_back(std::move(row));
    }
    return out;
}

void Contacts::logExport(long long userId, const std::vector<Row>& rows) {
    auto* db = Database::getInstance();
    for (const auto& r : rows) {
        db->query("INSERT INTO contact_exports (exported_by_user_id, kind, ref_id, fingerprint) VALUES ($1::int, $2, $3::bigint, $4)",
                  {std::to_string(userId), r.kind, std::to_string(r.refId), r.fingerprint});
    }
}

json Contacts::lastExport(long long userId) {
    auto r = Database::getInstance()->query(
        "SELECT to_char(max(exported_at) AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI AM') AS when_,"
        "       count(*) FILTER (WHERE exported_at >= (SELECT max(exported_at) - interval '1 minute' FROM contact_exports WHERE exported_by_user_id = $1::int)) AS n"
        "  FROM contact_exports WHERE exported_by_user_id = $1::int", {std::to_string(userId)});
    if (r.empty() || r[0]["when_"].is_null()) return nullptr;
    return {{"when", r[0]["when_"].c_str()}, {"n", r[0]["n"].as<long long>()}};
}
