#include "RsvpBoard.h"

#include <algorithm>
#include <sstream>
#include <utility>

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string pgIntArray(const std::vector<long long>& ids) {
    std::ostringstream out;
    out << '{';
    for (size_t i = 0; i < ids.size(); ++i) { if (i) out << ','; out << ids[i]; }
    out << '}';
    return out.str();
}

json textOrNull(const pqxx::row& row, const char* col) {
    return row[col].is_null() ? json(nullptr) : json(std::string(row[col].c_str()));
}

// Shared CTEs.  $1 = section code ('' = any section), $2 = window start
// ('' = all time), $3 = int[] team scope ('{}' = every team), $4 = person
// filter (0 = everyone), $5 = kind bucket ('all' | 'games' | 'practices';
// intrasquads count as games, same as #reports).
//
//   tm       active board teams in the section, each with its release
//            window end (one function call per team, not per event).
//            A section with schedule_section_id set borrows that
//            section's teams — Girls play on the Boys teams (mig 361).
//   roster   (player, team) pairs.  Boys/Girls split on an active LA
//            membership in a girls programme, since the teams are shared.
//   expected (player, event) pairs the player owed an answer to.  The
//            floor is the first RSVP ever recorded, so "all time" does not
//            count events from before FH RSVPs existed.
const char* kBaseCtes = R"SQL(
    sec AS (
      SELECT cs.code, COALESCE(cs.schedule_section_id, cs.id) AS team_section_id
        FROM club_sections cs
       WHERE $1 = '' OR cs.code = $1
    ), epoch AS (
      SELECT COALESCE(min(responded_at), now()) AS t FROM fh_event_rsvps
    ), tm AS (
      SELECT DISTINCT t.id, t.name, t.label, t.board_sort_order,
             fh_schedule_window_end(t.club_id, t.club_section_id, now()) AS window_end
        FROM teams t
        JOIN sec ON sec.team_section_id = t.club_section_id
       WHERE t.is_active AND t.board_sort_order IS NOT NULL
         AND ($3::int[] = '{}' OR t.id = ANY($3::int[]))
    ), girl AS (
      SELECT DISTINCT plm.person_id
        FROM person_la_memberships plm
        JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
       WHERE plm.ended_at IS NULL AND lp.category = 'girls'
    ), roster AS (
      SELECT tp.person_id, tp.team_id, tp.joined_at
        FROM team_persons tp
        JOIN tm ON tm.id = tp.team_id
        LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
       WHERE tp.removed_at IS NULL
         AND COALESCE(rs.show_in_rsvp, true)
         AND ($4::int = 0 OR tp.person_id = $4::int)
         -- Girls play on boys teams (club_sections.schedule_section_id), so
         -- Boys is the whole team and Girls is a girls-only lens on it —
         -- the same split the #teams boards use.  Boys used to drop the
         -- girls, so a U8 Travel tile read 5/1/1 for an 11-player team
         -- (owner 2026-09-24: "there should be 11 players on team right?").
         AND ($1 <> 'G' OR EXISTS (SELECT 1 FROM girl g WHERE g.person_id = tp.person_id))
    ), expected AS (
      SELECT DISTINCT r.person_id, fe.id AS fh_event_id, fe.kind, fe.opponent,
             fe.fh_notes, ge.starts_at, ge.ends_at
        FROM roster r
        JOIN tm ON tm.id = r.team_id
        JOIN fh_event_teams fet ON fet.team_id = r.team_id
        JOIN fh_events fe ON fe.id = fet.fh_event_id
                         AND fe.kind IN ('practice','match','intrasquad')
                         AND ($5 = 'all' OR ($5 = 'games') = (fe.kind IN ('match','intrasquad')))
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
        CROSS JOIN epoch
       WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
         AND ge.starts_at >= GREATEST(r.joined_at, epoch.t,
                                      COALESCE(NULLIF($2,'')::timestamptz, '-infinity'))
         AND ge.starts_at <  tm.window_end
         AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                          WHERE s.person_id = r.person_id
                            AND (s.team_id IS NULL OR s.team_id = r.team_id)
                            AND s.starts_at <= ge.starts_at
                            AND (s.ends_at IS NULL OR s.ends_at > ge.starts_at))
    ), week_events AS (
      -- Every event of the released week (Monday → release window end)
      -- the player owes an answer to, with their answer if any (owner
      -- 2026-09-22: the card shows the whole week as a table "so i can see
      -- if missing all or some and which ones").  still_open: they can
      -- still answer it; otherwise it already happened.
      -- The line is player-facing: kind label + opponent, never the gcal
      -- title.  A practice that carries notes is an unusual one (Barn
      -- Night counts as a practice — owner 2026-09-18), so its notes ride
      -- along in the reminder message while it can still be answered
      -- (message_notes; the board keeps the short line).  Game notes are
      -- kit lists and stay off the reminder.
      SELECT e.person_id, e.fh_event_id, e.starts_at,
             (e.ends_at > now()) AS still_open,
             to_char(e.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM') AS "when",
             CASE e.kind WHEN 'match'      THEN 'Game' || COALESCE(' vs ' || NULLIF(BTRIM(e.opponent), ''), '')
                         WHEN 'intrasquad' THEN 'Intra Squad'
                         ELSE 'Practice' END AS what,
             to_char(e.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM')
               || ' — '
               || CASE e.kind WHEN 'match'      THEN 'Game' || COALESCE(' vs ' || NULLIF(BTRIM(e.opponent), ''), '')
                              WHEN 'intrasquad' THEN 'Intra Squad'
                              ELSE 'Practice' END AS line,
             CASE WHEN e.ends_at > now() AND e.kind NOT IN ('match','intrasquad')
                  THEN NULLIF(BTRIM(e.fh_notes), '') END AS message_notes,
             rv.response, rv.created_via, rv.responded_at
        FROM expected e
        LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id
       WHERE e.starts_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York'
    ), week_unanswered AS (
      -- The week's events with no answer.  The board card lists both open
      -- and missed; the reminder only lists the still-open ones — an event
      -- that already went by would just confuse the player (owner 2026-09-19).
      SELECT * FROM week_events WHERE response IS NULL
    ), open_events AS (
      SELECT * FROM week_unanswered WHERE still_open
    ), missed_events AS (
      SELECT * FROM week_unanswered WHERE NOT still_open
    )
)SQL";

}  // namespace

json RsvpBoard::list(const std::string& sectionCode,
                     const std::string& windowStart,
                     const std::string& kind,
                     const std::vector<long long>& scopeTeamIds) {
    auto* db = Database::getInstance();
    const std::string sql = std::string("WITH ") + kBaseCtes + R"SQL(
    , stats AS (
      SELECT e.person_id,
             count(*)                                                  AS expected,
             count(rv.id)                                              AS answered,
             count(rv.id) FILTER (WHERE rv.created_via = 'standing')   AS standing
        FROM expected e
        LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id
       GROUP BY e.person_id
    )
    SELECT p.id AS person_id,
           COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
           p.parent_person_id,
           COALESCE(par.first_name,'') AS parent_first_name,
           COALESCE(s.expected, 0) AS expected, COALESCE(s.answered, 0) AS answered,
           COALESCE(s.standing, 0) AS standing,
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('id', tm.id, 'label', COALESCE(tm.label, tm.name))
                                      ORDER BY tm.board_sort_order), '[]'::jsonb)
              FROM roster r JOIN tm ON tm.id = r.team_id WHERE r.person_id = p.id)::text AS teams,
           fh_dues_eligible(p.id) AS dues_eligible,
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('fh_event_id', o.fh_event_id, 'line', o.line,
                                                         'day', to_char(o.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD'))
                                      ORDER BY o.starts_at), '[]'::jsonb)
              FROM open_events o WHERE o.person_id = p.id)::text AS open_events,
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('fh_event_id', o.fh_event_id, 'line', o.line,
                                                         'day', to_char(o.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD'))
                                      ORDER BY o.starts_at), '[]'::jsonb)
              FROM missed_events o WHERE o.person_id = p.id)::text AS missed_events,
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('fh_event_id', w.fh_event_id, 'when', w."when", 'what', w.what,
                                                         'day', to_char(w.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD'),
                                                         'still_open', w.still_open, 'response', w.response, 'via', w.created_via)
                                      ORDER BY w.starts_at), '[]'::jsonb)
              FROM week_events w WHERE w.person_id = p.id)::text AS week_events,
           to_char(lr.responded_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_rsvp_at, lr.created_via AS last_rsvp_via, lr.response AS last_rsvp_response,
           (SELECT to_char(max(rv.responded_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') FROM fh_event_rsvps rv
             WHERE rv.person_id = p.id AND rv.created_via = 'manual') AS last_manual_rsvp_at,
           du.months_overdue, du.la_payment_status, du.variant AS dues_variant,
           pay.amount AS last_payment_amount, to_char(pay.paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_payment_at,
           to_char(rem.sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_reminder_at, rem.channel AS last_reminder_channel,
           rem.sender AS last_reminder_by, rem.is_group AS last_reminder_group,
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id) AS reminders_total,
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id
               AND t.sent_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York') AS reminders_week,
           -- Per channel (owner 2026-09-22): "I sent 2 emails and no
           -- response yet, let me try a text".
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id AND t.channel = 'sms')   AS reminders_total_sms,
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id AND t.channel = 'email') AS reminders_total_email,
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id AND t.channel = 'sms'
               AND t.sent_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York') AS reminders_week_sms,
           (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = p.id AND t.channel = 'email'
               AND t.sent_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York') AS reminders_week_email,
           ph.phone_number AS phone, em.email AS email
      FROM (SELECT DISTINCT person_id FROM roster) m
      JOIN persons p ON p.id = m.person_id
      LEFT JOIN persons par ON par.id = p.parent_person_id
      LEFT JOIN stats s ON s.person_id = p.id
      LEFT JOIN LATERAL (
            SELECT rv.responded_at, rv.created_via, rv.response FROM fh_event_rsvps rv
             WHERE rv.person_id = p.id ORDER BY rv.responded_at DESC LIMIT 1) lr ON true
      LEFT JOIN LATERAL (
            SELECT plm.months_overdue, plm.la_payment_status, lp.variant
              FROM person_la_memberships plm
              JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id
             WHERE plm.person_id = p.id AND plm.ended_at IS NULL
               AND lp.variant IN ('active', 'inactive')
             ORDER BY (lp.variant = 'active') DESC, plm.id DESC LIMIT 1) du ON true
      -- Youth dues are paid from the parent's LeagueApps account.
      LEFT JOIN LATERAL (
            SELECT pp.amount, pp.paid_at FROM person_payments pp
             WHERE pp.la_user_id IN (
                     CASE WHEN p.la_user_id   ~ '^[0-9]+$' THEN p.la_user_id::bigint   END,
                     CASE WHEN par.la_user_id ~ '^[0-9]+$' THEN par.la_user_id::bigint END)
               AND pp.txn_type IN ('Charge', 'Offline Payment', 'Bank')
               AND pp.amount > 0
             ORDER BY pp.paid_at DESC LIMIT 1) pay ON true
      LEFT JOIN LATERAL (
            SELECT rr.sent_at, rr.channel, rr.is_group, COALESCE(sp.first_name, '') AS sender
              FROM rsvp_reminders rr
              LEFT JOIN users su   ON su.id = rr.sent_by_user_id
              LEFT JOIN persons sp ON sp.id = su.person_id
             WHERE rr.person_id = p.id ORDER BY rr.sent_at DESC LIMIT 1) rem ON true
      -- Contact: the parent's for youth, falling back to the player's own.
      LEFT JOIN LATERAL (
            SELECT x.phone_number FROM person_phones x
             WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
               AND COALESCE(x.can_receive_sms, true)
             ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                      x.is_primary DESC NULLS LAST, x.id LIMIT 1) ph ON true
      LEFT JOIN LATERAL (
            SELECT x.email FROM person_emails x
             WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
             ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                      x.is_primary DESC NULLS LAST, x.id LIMIT 1) em ON true
     ORDER BY p.last_name, p.first_name
    )SQL";

    auto rows = db->query(sql, {sectionCode, windowStart, pgIntArray(scopeTeamIds), "0", kind});

    auto iso = [](const pqxx::row& row, const char* col) -> json {
        return row[col].is_null() ? json(nullptr) : json(std::string(row[col].c_str()));
    };

    json people = json::array();
    for (const auto& row : rows) {
        const long long expected = row["expected"].as<long long>();
        const long long answered = row["answered"].as<long long>();
        json p = {
            {"person_id",         row["person_id"].as<long long>()},
            {"first_name",        row["first_name"].c_str()},
            {"last_name",         row["last_name"].c_str()},
            {"youth",             !row["parent_person_id"].is_null()},
            {"parent_first_name", row["parent_first_name"].c_str()},
            {"teams",             json::parse(row["teams"].c_str())},
            {"expected",          expected},
            {"answered",          answered},
            {"standing",          row["standing"].as<long long>()},
            {"rsvp_pct",          expected > 0 ? json(static_cast<int>((answered * 100 + expected / 2) / expected))
                                               : json(nullptr)},
            {"open_events",       json::parse(row["open_events"].c_str())},
            {"missed_events",     json::parse(row["missed_events"].c_str())},
            {"week_events",       json::parse(row["week_events"].c_str())},
            {"last_rsvp_at",        iso(row, "last_rsvp_at")},
            {"last_rsvp_via",       textOrNull(row, "last_rsvp_via")},
            {"last_rsvp_response",  textOrNull(row, "last_rsvp_response")},
            {"last_manual_rsvp_at", iso(row, "last_manual_rsvp_at")},
            {"months_overdue",    row["months_overdue"].is_null() ? json(nullptr) : json(row["months_overdue"].as<int>())},
            {"dues_eligible",     row["dues_eligible"].is_null() ? true : row["dues_eligible"].as<bool>()},   // migration 416
            {"payment_status",    textOrNull(row, "la_payment_status")},
            {"dues_variant",      textOrNull(row, "dues_variant")},
            {"last_payment_amount", row["last_payment_amount"].is_null() ? json(nullptr)
                                        : json(row["last_payment_amount"].as<double>())},
            {"last_payment_at",   iso(row, "last_payment_at")},
            {"last_reminder", row["last_reminder_at"].is_null() ? json(nullptr) : json{
                {"sent_at", row["last_reminder_at"].c_str()},
                {"channel", row["last_reminder_channel"].c_str()},
                {"by",      row["last_reminder_by"].c_str()},
                {"group",   row["last_reminder_group"].as<bool>()}}},
            {"reminders_total",   row["reminders_total"].as<int>()},
            {"reminders_week",    row["reminders_week"].as<int>()},
            {"reminders_total_sms",   row["reminders_total_sms"].as<int>()},
            {"reminders_total_email", row["reminders_total_email"].as<int>()},
            {"reminders_week_sms",    row["reminders_week_sms"].as<int>()},
            {"reminders_week_email",  row["reminders_week_email"].as<int>()},
            {"has_phone",         !row["phone"].is_null()},
            {"has_email",         !row["email"].is_null()},
        };
        people.push_back(std::move(p));
    }
    return people;
}

json RsvpBoard::teamGroups() {
    json out = json::array();
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT g.id, g.label,
               COALESCE((SELECT json_agg(gt.team_id ORDER BY gt.team_id)::text
                           FROM rsvp_team_group_teams gt WHERE gt.group_id = g.id), '[]') AS team_ids
          FROM rsvp_team_groups g
         WHERE g.is_active
         ORDER BY g.sort_order, g.id
    )SQL");
    for (const auto& r : rows) {
        out.push_back({
            {"id",       r["id"].as<long long>()},
            {"label",    r["label"].c_str()},
            {"team_ids", json::parse(r["team_ids"].c_str())},
        });
    }
    return out;
}

json RsvpBoard::weekEvents(const std::string& sectionCode,
                           const std::vector<long long>& scopeTeamIds) {
    auto* db = Database::getInstance();
    // $2 (window start) is '' here: an upcoming event is inside every window.
    // Every still-answerable event of the released week, per team, plus
    // each team's next game when it lies beyond the release window (shown
    // as "not released yet").  The board filters these tiles by its day
    // and event pills (owner 2026-09-22: a snapshot of games AND practices;
    // "if we have today selected and no games should we even show games?").
    const std::string sql = std::string("WITH ") + kBaseCtes + R"SQL(
    , ng AS (
      SELECT DISTINCT ON (tm.id) tm.id AS team_id, fe.id AS fh_event_id
        FROM tm
        JOIN fh_event_teams fet ON fet.team_id = tm.id
        JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
         AND ge.ends_at > now()
       ORDER BY tm.id, ge.starts_at
    ), ev AS (
      SELECT tm.id AS team_id, COALESCE(tm.label, tm.name) AS team_label, tm.board_sort_order,
             fe.id AS fh_event_id, fe.kind, fe.opponent, fe.is_home, ge.starts_at,
             (ge.starts_at < tm.window_end) AS released
        FROM tm
        JOIN fh_event_teams fet ON fet.team_id = tm.id
        JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('practice','match','intrasquad')
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
         AND ge.ends_at > now()
         AND (ge.starts_at < tm.window_end
              OR EXISTS (SELECT 1 FROM ng WHERE ng.team_id = tm.id AND ng.fh_event_id = fe.id))
    )
    SELECT ev.team_id, ev.team_label, ev.fh_event_id, ev.kind, ev.is_home, ev.released,
           COALESCE(NULLIF(BTRIM(ev.opponent), ''), 'TBD') AS opponent,
           to_char(ev.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
           to_char(ev.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM') AS when_text,
           to_char(ev.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS day,
           c.expected, c.yes, c.yes_ineligible, c.no,
           t.expected AS all_expected, t.yes AS all_yes, t.yes_ineligible AS all_yes_ineligible, t.no AS all_no
      FROM ev
      -- A yes from someone over the dues line (migration 416) is kept but
      -- counted apart (owner 2026-09-23): `yes` is eligible yeses only,
      -- `yes_ineligible` the rest; unanswered = expected − both − no.
      CROSS JOIN LATERAL (
            SELECT count(*) AS expected,
                   count(*) FILTER (WHERE rv.response = 'yes' AND     fh_dues_eligible(e.person_id)) AS yes,
                   count(*) FILTER (WHERE rv.response = 'yes' AND NOT fh_dues_eligible(e.person_id)) AS yes_ineligible,
                   count(*) FILTER (WHERE rv.response = 'no')  AS no
              FROM roster r
              JOIN expected e ON e.person_id = r.person_id AND e.fh_event_id = ev.fh_event_id
              LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id
             WHERE r.team_id = ev.team_id) c
      -- Across every team on the event, each person once (owner
      -- 2026-09-22: APSL players are also on Liga 1, so per-team tiles
      -- double-count a shared practice; `expected` is already one row per
      -- person per event).
      CROSS JOIN LATERAL (
            SELECT count(*) AS expected,
                   count(*) FILTER (WHERE rv.response = 'yes' AND     fh_dues_eligible(e.person_id)) AS yes,
                   count(*) FILTER (WHERE rv.response = 'yes' AND NOT fh_dues_eligible(e.person_id)) AS yes_ineligible,
                   count(*) FILTER (WHERE rv.response = 'no')  AS no
              FROM expected e
              LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id
             WHERE e.fh_event_id = ev.fh_event_id) t
     WHERE EXISTS (SELECT 1 FROM roster r WHERE r.team_id = ev.team_id)
     ORDER BY ev.starts_at, ev.board_sort_order
    )SQL";
    auto rows = db->query(sql, {sectionCode, "", pgIntArray(scopeTeamIds), "0", "all"});

    json events = json::array();
    for (const auto& row : rows) {
        const long long expected = row["expected"].as<long long>();
        const long long yes = row["yes"].as<long long>();
        const long long yesIneligible = row["yes_ineligible"].as<long long>();
        const long long no  = row["no"].as<long long>();
        const long long allExpected = row["all_expected"].as<long long>();
        const long long allYes      = row["all_yes"].as<long long>();
        const long long allYesIneligible = row["all_yes_ineligible"].as<long long>();
        const long long allNo       = row["all_no"].as<long long>();
        events.push_back({
            {"team_id",     row["team_id"].as<long long>()},
            {"team_label",  row["team_label"].c_str()},
            {"fh_event_id", row["fh_event_id"].as<long long>()},
            {"kind",        row["kind"].c_str()},
            {"opponent",    row["opponent"].c_str()},
            {"is_home",     row["is_home"].is_null() ? json(nullptr) : json(row["is_home"].as<bool>())},
            {"starts_at",   row["starts_at"].c_str()},
            {"when_text",   row["when_text"].c_str()},
            {"day",         row["day"].c_str()},
            {"released",    row["released"].as<bool>()},
            {"expected",    expected},
            {"yes",         yes},
            {"yes_ineligible", yesIneligible},
            {"no",          no},
            {"unanswered",  expected - yes - yesIneligible - no},
            {"all_expected",   allExpected},
            {"all_yes",        allYes},
            {"all_yes_ineligible", allYesIneligible},
            {"all_no",         allNo},
            {"all_unanswered", allExpected - allYes - allYesIneligible - allNo},
        });
    }
    return events;
}

RsvpBoard::ReminderContext RsvpBoard::reminderContext(long long personId) {
    auto* db = Database::getInstance();
    ReminderContext ctx;

    auto who = db->query(R"SQL(
        SELECT COALESCE(p.first_name,'') AS fn, p.parent_person_id,
               COALESCE(par.first_name,'') AS parent_fn,
               (SELECT x.phone_number FROM person_phones x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                   AND COALESCE(x.can_receive_sms, true)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS phone,
               (SELECT x.email FROM person_emails x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS email
          FROM persons p LEFT JOIN persons par ON par.id = p.parent_person_id
         WHERE p.id = $1::int)SQL", {std::to_string(personId)});
    if (who.empty()) return ctx;
    ctx.found              = true;
    ctx.playerFirstName    = who[0]["fn"].c_str();
    ctx.youth              = !who[0]["parent_person_id"].is_null();
    ctx.recipientPersonId  = ctx.youth ? who[0]["parent_person_id"].as<long long>() : personId;
    ctx.recipientFirstName = ctx.youth ? who[0]["parent_fn"].c_str() : ctx.playerFirstName;
    if (!who[0]["phone"].is_null()) ctx.phone = who[0]["phone"].c_str();
    if (!who[0]["email"].is_null()) ctx.email = who[0]["email"].c_str();

    const std::string sql = std::string("WITH ") + kBaseCtes + R"SQL(
        SELECT 'team' AS what, r.team_id::bigint AS id, NULL::text AS line, NULL::timestamptz AS starts_at,
               NULL::text AS day
          FROM roster r
        UNION ALL
        SELECT 'event', o.fh_event_id,
               o.line || COALESCE(E'\n  ' || o.message_notes, ''), o.starts_at,
               to_char(o.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') FROM open_events o
         ORDER BY what, starts_at)SQL";
    auto rows = db->query(sql, {"", "", "{}", std::to_string(personId), "all"});
    for (const auto& row : rows) {
        if (std::string(row["what"].c_str()) == "team") {
            ctx.teamIds.push_back(row["id"].as<long long>());
        } else {
            ctx.openEvents.push_back({row["id"].as<long long>(), row["line"].c_str(),
                                      row["day"].is_null() ? std::string{} : row["day"].c_str()});
        }
    }
    return ctx;
}

RsvpBoard::GroupReminderContext RsvpBoard::groupReminderContext(
        const std::string& sectionCode, long long fhEventId, const std::vector<long long>& teamIds) {
    auto* db = Database::getInstance();
    GroupReminderContext ctx;
    const std::string sql = std::string("WITH ") + kBaseCtes + R"SQL(
        SELECT p.id AS person_id, COALESCE(p.parent_person_id, p.id) AS recipient_person_id,
               o.line || COALESCE(E'\n  ' || o.message_notes, '') AS line,
               ph.phone_number AS phone, em.email AS email,
               (SELECT jsonb_agg(jsonb_build_object(
                         'id', w.fh_event_id, 'line', w.line,
                         'at', to_char(w.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS'))
                       ORDER BY w.starts_at)
                  FROM open_events w WHERE w.person_id = p.id)::text AS week_events
          FROM open_events o
          JOIN persons p ON p.id = o.person_id
          LEFT JOIN LATERAL (
                SELECT x.phone_number FROM person_phones x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                   AND COALESCE(x.can_receive_sms, true)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) ph ON true
          LEFT JOIN LATERAL (
                SELECT x.email FROM person_emails x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) em ON true
         WHERE o.fh_event_id = $6::bigint
         ORDER BY p.last_name, p.first_name)SQL";
    auto rows = db->query(sql, {sectionCode, "", pgIntArray(teamIds), "0", "all", std::to_string(fhEventId)});
    std::vector<std::pair<std::string, OpenEvent>> week;   // (start, event), deduped
    for (const auto& row : rows) {
        if (ctx.line.empty()) ctx.line = row["line"].c_str();
        GroupRecipient r;
        r.personId          = row["person_id"].as<long long>();
        r.recipientPersonId = row["recipient_person_id"].as<long long>();
        if (!row["phone"].is_null()) r.phone = row["phone"].c_str();
        if (!row["email"].is_null()) r.email = row["email"].c_str();
        for (const auto& ev : json::parse(row["week_events"].c_str())) {
            r.weekEvents.push_back({ev["id"].get<long long>(), ev["line"].get<std::string>()});
            const std::string at = ev["at"].get<std::string>();
            const bool seen = std::any_of(week.begin(), week.end(), [&](const auto& w) {
                return w.second.fhEventId == r.weekEvents.back().fhEventId; });
            if (!seen) week.emplace_back(at, r.weekEvents.back());
        }
        ctx.recipients.push_back(std::move(r));
    }
    std::sort(week.begin(), week.end(), [](const auto& a, const auto& b) { return a.first < b.first; });
    for (auto& w : week) ctx.weekEvents.push_back(std::move(w.second));
    return ctx;
}

json RsvpBoard::logReminder(long long personId, long long recipientPersonId,
                            const std::string& channel, const std::string& contact,
                            long long sentByUserId,
                            const std::vector<OpenEvent>& events,
                            bool isGroup) {
    auto* db = Database::getInstance();
    auto ins = db->query(
        "INSERT INTO rsvp_reminders (person_id, recipient_person_id, channel, contact, sent_by_user_id, is_group) "
        "VALUES ($1::int, $2::int, $3, $4, NULLIF($5::int, 0), $6::boolean) "
        "RETURNING id, to_char(sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS sent_at",
        {std::to_string(personId), std::to_string(recipientPersonId), channel, contact,
         std::to_string(sentByUserId), isGroup ? "true" : "false"});
    const std::string reminderId = ins[0]["id"].c_str();
    for (const auto& ev : events) {
        db->query("INSERT INTO rsvp_reminder_events (rsvp_reminder_id, fh_event_id) "
                  "VALUES ($1::bigint, $2::bigint) ON CONFLICT DO NOTHING",
                  {reminderId, std::to_string(ev.fhEventId)});
    }
    std::string by;
    if (sentByUserId > 0) {
        auto s = db->query("SELECT COALESCE(p.first_name,'') AS fn FROM users u "
                           "JOIN persons p ON p.id = u.person_id WHERE u.id = $1::int",
                           {std::to_string(sentByUserId)});
        if (!s.empty()) by = s[0]["fn"].c_str();
    }
    auto tally = db->query(
        "WITH wk AS (SELECT date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' AS start) "
        "SELECT count(*) AS total, count(*) FILTER (WHERE sent_at >= wk.start) AS week, "
        "       count(*) FILTER (WHERE channel = 'sms')   AS total_sms, "
        "       count(*) FILTER (WHERE channel = 'email') AS total_email, "
        "       count(*) FILTER (WHERE channel = 'sms'   AND sent_at >= wk.start) AS week_sms, "
        "       count(*) FILTER (WHERE channel = 'email' AND sent_at >= wk.start) AS week_email "
        "  FROM rsvp_reminders, wk WHERE person_id = $1::int GROUP BY wk.start",
        {std::to_string(personId)});
    const auto& t = tally[0];
    return {{"sent_at", ins[0]["sent_at"].c_str()}, {"channel", channel}, {"by", by}, {"group", isGroup},
            {"total", t["total"].as<int>()}, {"week", t["week"].as<int>()},
            {"total_sms", t["total_sms"].as<int>()}, {"total_email", t["total_email"].as<int>()},
            {"week_sms", t["week_sms"].as<int>()},   {"week_email", t["week_email"].as<int>()}};
}

json RsvpBoard::remindersForEvent(long long fhEventId) {
    // A reminder lists the player's whole week, so it answers for every
    // game of that week, not only the ones it named (owner 2026-09-21:
    // "if we send remind for a person for apsl game it should grey out the
    // button for liga 1 too").  count = sends that week on the channel;
    // total = every reminder the player has ever needed.
    auto rows = Database::getInstance()->query(R"SQL(
        WITH wk AS (
          SELECT date_trunc('week', ge.starts_at AT TIME ZONE 'America/New_York') AS week_start
            FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
           WHERE fe.id = $1::bigint
        )
        SELECT rr.person_id, rr.channel, count(*) AS n,
               to_char(max(rr.sent_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS sent_at,
               (SELECT count(*) FROM rsvp_reminders t WHERE t.person_id = rr.person_id) AS total
          FROM rsvp_reminders rr, wk
         WHERE EXISTS (SELECT 1 FROM rsvp_reminder_events re
                         JOIN fh_events fe2   ON fe2.id = re.fh_event_id
                         JOIN gcal_events ge2 ON ge2.id = fe2.gcal_event_id
                        WHERE re.rsvp_reminder_id = rr.id
                          AND date_trunc('week', ge2.starts_at AT TIME ZONE 'America/New_York') = wk.week_start)
         GROUP BY rr.person_id, rr.channel)SQL",
        {std::to_string(fhEventId)});
    json out = json::object();
    for (const auto& row : rows) {
        out[row["person_id"].c_str()][row["channel"].c_str()] =
            {{"sent_at", row["sent_at"].c_str()}, {"count", row["n"].as<int>()}};
        out[row["person_id"].c_str()]["total"] = row["total"].as<int>();
    }
    return out;
}

RsvpBoard::SquadNoticeContext RsvpBoard::squadNoticeContext(long long matchId) {
    auto* db = Database::getInstance();
    SquadNoticeContext ctx;
    // Player-facing line, same shape as the reminders': kind label +
    // opponent, never the gcal title.
    auto ev = db->query(R"SQL(
        SELECT to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM')
                 || ' — '
                 || CASE fe.kind WHEN 'intrasquad' THEN 'Intra Squad'
                                 ELSE 'Game' || COALESCE(' vs ' || NULLIF(BTRIM(fe.opponent), ''), '') END AS line,
               COALESCE(NULLIF(BTRIM(ge.location), ''), '') AS location,
               COALESCE(to_char(fe.arrival_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'), '') AS arrival
          FROM fh_events fe
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE fe.match_id = $1::int
         ORDER BY fe.id LIMIT 1)SQL", {std::to_string(matchId)});
    if (ev.empty()) return ctx;
    ctx.found   = true;
    ctx.line    = ev[0]["line"].c_str();
    ctx.where   = ev[0]["location"].c_str();
    ctx.arrival = ev[0]["arrival"].c_str();

    auto rows = db->query(R"SQL(
        SELECT p.id AS person_id, COALESCE(p.parent_person_id, p.id) AS recipient_person_id,
               ml.zone, COALESCE(last.zone, '') AS told_zone,
               COALESCE(p.first_name, '') AS player_first,
               COALESCE(rp.first_name, '') AS recipient_first,
               ph.phone_number AS phone, em.email AS email
          FROM match_lineups ml
          JOIN players pl ON pl.id = ml.player_id
          JOIN persons p ON p.id = pl.person_id
          JOIN persons rp ON rp.id = COALESCE(p.parent_person_id, p.id)
          LEFT JOIN LATERAL (
                SELECT sn.zone FROM squad_notices sn
                 WHERE sn.match_id = ml.match_id AND sn.person_id = p.id
                 ORDER BY sn.sent_at DESC LIMIT 1) last ON true
          LEFT JOIN LATERAL (
                SELECT x.phone_number FROM person_phones x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                   AND COALESCE(x.can_receive_sms, true)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) ph ON true
          LEFT JOIN LATERAL (
                SELECT x.email FROM person_emails x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) em ON true
         WHERE ml.match_id = $1::int AND ml.zone IN ('starter', 'bench', 'alternate')
         ORDER BY p.last_name, p.first_name)SQL", {std::to_string(matchId)});
    for (const auto& row : rows) {
        SquadRecipient r;
        r.personId          = row["person_id"].as<long long>();
        r.recipientPersonId = row["recipient_person_id"].as<long long>();
        r.zone              = row["zone"].c_str();
        r.toldZone           = row["told_zone"].c_str();
        r.playerFirstName    = row["player_first"].c_str();
        r.recipientFirstName = row["recipient_first"].c_str();
        if (!row["phone"].is_null()) r.phone = row["phone"].c_str();
        if (!row["email"].is_null()) r.email = row["email"].c_str();
        ctx.recipients.push_back(std::move(r));
    }
    return ctx;
}

void RsvpBoard::logSquadNotice(long long matchId, const SquadRecipient& r, const std::string& channel,
                               const std::string& contact, long long sentByUserId) {
    Database::getInstance()->query(
        "INSERT INTO squad_notices (match_id, person_id, recipient_person_id, zone, channel, contact, sent_by_user_id) "
        "VALUES ($1::int, $2::int, $3::int, $4, $5, $6, NULLIF($7::int, 0))",
        {std::to_string(matchId), std::to_string(r.personId), std::to_string(r.recipientPersonId),
         r.zone, channel, contact, std::to_string(sentByUserId)});
}

json RsvpBoard::squadNoticeStatus(long long matchId) {
    auto* db = Database::getInstance();
    json out = json::object();
    auto counts = db->query(R"SQL(
        SELECT count(*) AS squad,
               count(*) FILTER (WHERE last.zone IS DISTINCT FROM ml.zone) AS untold
          FROM match_lineups ml
          JOIN players pl ON pl.id = ml.player_id
          LEFT JOIN LATERAL (
                SELECT sn.zone FROM squad_notices sn
                 WHERE sn.match_id = ml.match_id AND sn.person_id = pl.person_id
                 ORDER BY sn.sent_at DESC LIMIT 1) last ON true
         WHERE ml.match_id = $1::int AND ml.zone IN ('starter', 'bench', 'alternate'))SQL",
        {std::to_string(matchId)});
    out["squad"]  = counts[0]["squad"].as<int>();
    out["untold"] = counts[0]["untold"].as<int>();
    auto sent = db->query(
        "SELECT channel, to_char(max(sent_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS sent_at "
        "  FROM squad_notices WHERE match_id = $1::int GROUP BY channel",
        {std::to_string(matchId)});
    for (const auto& row : sent) out[row["channel"].c_str()] = {{"sent_at", row["sent_at"].c_str()}};

    json people = json::object();
    auto per = db->query(
        "SELECT person_id, channel, count(*) AS n, "
        "       to_char(max(sent_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS sent_at, "
        "       (array_agg(zone ORDER BY sent_at DESC))[1] AS zone "
        "  FROM squad_notices WHERE match_id = $1::int GROUP BY person_id, channel",
        {std::to_string(matchId)});
    for (const auto& row : per) {
        people[row["person_id"].c_str()][row["channel"].c_str()] =
            {{"sent_at", row["sent_at"].c_str()}, {"count", row["n"].as<int>()}};
    }
    auto told = db->query(
        "SELECT DISTINCT ON (person_id) person_id, zone FROM squad_notices "
        " WHERE match_id = $1::int ORDER BY person_id, sent_at DESC",
        {std::to_string(matchId)});
    for (const auto& row : told) people[row["person_id"].c_str()]["told_zone"] = row["zone"].c_str();
    out["people"] = std::move(people);
    return out;
}
