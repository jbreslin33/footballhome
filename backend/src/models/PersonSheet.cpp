#include "PersonSheet.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {
json textOrNull(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(std::string(f.c_str())); }
}  // namespace

json PersonSheet::card(long long personId, const std::string& laUserId, long long viewerUserId) {
    auto* db = Database::getInstance();
    const std::string viewer = std::to_string(viewerUserId);
    const auto who = db->query(
        "SELECT p.id, p.la_user_id, p.first_name, p.last_name, to_char(p.birth_date, 'YYYY-MM-DD') AS dob, "
        "       EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id "
        "                WHERE a.user_id = $3::int AND al.name IN ('club', 'super')) AS admin, "
        "       EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
        "                 JOIN users u ON u.person_id = co.person_id "
        "                WHERE u.id = $3::int AND tc.ended_at IS NULL) AS coach, "
        "       (SELECT to_char(v.created_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') "
        "          FROM club_volunteers v WHERE v.person_id = p.id) AS volunteer_since, "
        // His section for the 📇 list: an adult team wins (a U16 on the men's
        // side is contacted as a man), else his youth team's.
        "       (SELECT cs.name FROM team_persons tp JOIN teams t ON t.id = tp.team_id AND t.is_active "
        "          JOIN club_sections cs ON cs.id = t.club_section_id "
        "         WHERE tp.person_id = p.id AND tp.removed_at IS NULL "
        "         ORDER BY (cs.code IN ('M', 'W')) DESC, t.board_sort_order NULLS LAST, t.id LIMIT 1) AS section "
        "  FROM persons p "
        " WHERE CASE WHEN $1::int > 0 THEN p.id = $1::int "
        "            ELSE NULLIF($2, '') IS NOT NULL "
        "                 AND (p.la_user_id = $2 OR EXISTS (SELECT 1 FROM person_la_user_ids a "
        "                                                    WHERE a.person_id = p.id AND a.la_user_id = $2)) END "
        " ORDER BY p.id LIMIT 1",
        {std::to_string(personId), laUserId, viewer});
    if (who.empty()) return nullptr;
    const auto& w = who[0];
    const long long pid = w["id"].as<long long>();
    const bool admin = w["admin"].as<bool>();
    json out = {
        {"personId", pid},
        {"laUserId", textOrNull(w["la_user_id"])},
        {"firstName", textOrNull(w["first_name"])},
        {"lastName", textOrNull(w["last_name"])},
        {"dob", textOrNull(w["dob"])},
        {"section", textOrNull(w["section"])},
        {"canSee", admin || w["coach"].as<bool>()},
        {"canVolunteer", admin},
        {"volunteer", {{"on", !w["volunteer_since"].is_null()}, {"since", textOrNull(w["volunteer_since"])}}},
        {"recipients", json::array()},
        {"teams", json::array()},
    };
    if (!out["canSee"].get<bool>()) return out;

    const std::string p = std::to_string(pid);
    for (const auto& r : db->query(
             "SELECT r.recipient_person_id, r.is_guardian, "
             "       NULLIF(TRIM(CONCAT_WS(' ', rp.first_name, rp.last_name)), '') AS name, "
             "       fh_recipient_phone(r.recipient_person_id, $1::int) AS phone, "
             "       fh_recipient_email(r.recipient_person_id, $1::int) AS email "
             "  FROM fh_message_recipients($1::int) r "
             "  JOIN persons rp ON rp.id = r.recipient_person_id "
             " ORDER BY r.ord", {p})) {
        out["recipients"].push_back({
            {"personId", r["recipient_person_id"].as<long long>()},
            {"name", textOrNull(r["name"])},
            {"phone", textOrNull(r["phone"])},
            {"email", textOrNull(r["email"])},
            {"isGuardian", r["is_guardian"].as<bool>()},
        });
    }
    for (const auto& t : db->query(
             "SELECT t.id, COALESCE(t.label, t.name) AS label, COALESCE(t.short_label, t.label, t.name) AS short_label, "
             "       cs.code AS section, "
             "       COALESCE(ss.code, CASE WHEN tp.invite_only THEN 'inactive' ELSE 'plays' END) AS status, "
             "       ($2::bool OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id "
             "                              JOIN users u ON u.person_id = co.person_id "
             "                             WHERE u.id = $3::int AND tc.team_id = t.id AND tc.ended_at IS NULL)) AS can_manage "
             "  FROM team_persons tp "
             "  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL "
             "  LEFT JOIN club_sections cs ON cs.id = t.club_section_id "
             "  LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id "
             " WHERE tp.person_id = $1::int AND tp.removed_at IS NULL "
             " ORDER BY t.board_sort_order, t.id", {p, admin ? "true" : "false", viewer})) {
        out["teams"].push_back({
            {"teamId", t["id"].as<long long>()},
            {"label", t["label"].c_str()},
            {"short", t["short_label"].c_str()},
            {"section", textOrNull(t["section"])},
            {"status", t["status"].c_str()},
            {"canManage", t["can_manage"].as<bool>()},
        });
    }
    return out;
}

json PersonSheet::attendance(long long personId, long long viewerUserId, long long fhEventId) {
    auto* db = Database::getInstance();
    json events = json::array();
    // Dates first (the cheap cut), then who is on it, then who may mark.
    for (const auto& r : db->query(
             "WITH day AS (SELECT (date_trunc('day', now() AT TIME ZONE 'America/New_York') + interval '1 day') "
             "                    AT TIME ZONE 'America/New_York' AS ends), "
             "     ev AS (SELECT fe.id, fe.kind, fe.category, fe.opponent, ge.starts_at, "
             "                   ge.starts_at < (SELECT ends FROM day) AS open "
             "              FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
             "             WHERE ge.deleted_at IS NULL AND COALESCE(ge.status, '') <> 'cancelled' "
             "               AND ((ge.starts_at >= now() - interval '90 days' AND ge.starts_at < (SELECT ends FROM day)) "
             "                    OR fe.id = $3::bigint)) "
             "SELECT ev.id, ev.kind, ev.category, ev.opponent, ev.open, a.status, "
             "       to_char(ev.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS starts_at "
             "  FROM ev LEFT JOIN fh_event_attendance a ON a.fh_event_id = ev.id AND a.person_id = $1::int "
             " WHERE (EXISTS (SELECT 1 FROM fh_event_teams fet "
             "                  JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL "
             "                 WHERE fet.fh_event_id = ev.id AND tp.person_id = $1::int) "
             "        OR EXISTS (SELECT 1 FROM fh_event_teams fet "
             "                     JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL "
             "                     JOIN coaches co ON co.id = tc.coach_id "
             "                    WHERE fet.fh_event_id = ev.id AND co.person_id = $1::int) "
             "        OR fh_event_invited(ev.id, $1::int)) "
             "   AND fh_event_viewer_tier(ev.id, (SELECT u.person_id FROM users u WHERE u.id = $2::int)) <> 'player' "
             " ORDER BY (ev.id = $3::bigint) DESC, ev.starts_at DESC LIMIT 60",
             {std::to_string(personId), std::to_string(viewerUserId), std::to_string(fhEventId)})) {
        events.push_back({
            {"fhEventId", r["id"].as<long long>()},
            {"kind", textOrNull(r["kind"])},
            {"category", textOrNull(r["category"])},
            {"opponent", textOrNull(r["opponent"])},
            {"startsAt", textOrNull(r["starts_at"])},
            {"status", textOrNull(r["status"])},
            {"open", r["open"].as<bool>()},
        });
    }
    return {{"personId", personId}, {"events", events}};
}

void PersonSheet::setVolunteer(long long personId, bool on) {
    auto* db = Database::getInstance();
    if (on) {
        db->query("INSERT INTO club_volunteers (person_id) VALUES ($1::int) ON CONFLICT (person_id) DO NOTHING",
                  {std::to_string(personId)});
    } else {
        db->query("DELETE FROM club_volunteers WHERE person_id = $1::int", {std::to_string(personId)});
    }
}
