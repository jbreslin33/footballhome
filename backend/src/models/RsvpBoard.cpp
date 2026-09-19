#include "RsvpBoard.h"

#include <sstream>

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
         AND ($1 NOT IN ('B','G')
              OR ($1 = 'G') = EXISTS (SELECT 1 FROM girl g WHERE g.person_id = tp.person_id))
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
    ), week_unanswered AS (
      -- Every event of the released week (Monday → release window end)
      -- the player owes an answer to and has none for.  still_open: they
      -- can still answer it; otherwise it already happened.  Both feed
      -- the reminder — a player below 100% for the week can be reminded
      -- even when nothing is left to answer (owner 2026-09-18: "resend
      -- reminder if a player is not 100% availablity set for week").
      -- The line is player-facing: kind label + opponent, never the gcal
      -- title.  A practice that carries notes is an unusual one (Barn
      -- Night counts as a practice — owner 2026-09-18), so its notes ride
      -- along in the reminder message while it can still be answered
      -- (message_notes; the board keeps the short line).  Game notes are
      -- kit lists and stay off the reminder.
      SELECT e.person_id, e.fh_event_id, e.starts_at,
             (e.ends_at > now()) AS still_open,
             to_char(e.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM')
               || ' — '
               || CASE e.kind WHEN 'match'      THEN 'Game' || COALESCE(' vs ' || NULLIF(BTRIM(e.opponent), ''), '')
                              WHEN 'intrasquad' THEN 'Intra Squad'
                              ELSE 'Practice' END AS line,
             CASE WHEN e.ends_at > now() AND e.kind NOT IN ('match','intrasquad')
                  THEN NULLIF(BTRIM(e.fh_notes), '') END AS message_notes
        FROM expected e
       WHERE e.starts_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York'
         AND NOT EXISTS (SELECT 1 FROM fh_event_rsvps rv
                          WHERE rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id)
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
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('fh_event_id', o.fh_event_id, 'line', o.line)
                                      ORDER BY o.starts_at), '[]'::jsonb)
              FROM open_events o WHERE o.person_id = p.id)::text AS open_events,
           (SELECT COALESCE(jsonb_agg(jsonb_build_object('fh_event_id', o.fh_event_id, 'line', o.line)
                                      ORDER BY o.starts_at), '[]'::jsonb)
              FROM missed_events o WHERE o.person_id = p.id)::text AS missed_events,
           to_char(lr.responded_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_rsvp_at, lr.created_via AS last_rsvp_via, lr.response AS last_rsvp_response,
           (SELECT to_char(max(rv.responded_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') FROM fh_event_rsvps rv
             WHERE rv.person_id = p.id AND rv.created_via = 'manual') AS last_manual_rsvp_at,
           du.months_overdue, du.la_payment_status, du.variant AS dues_variant,
           pay.amount AS last_payment_amount, to_char(pay.paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_payment_at,
           to_char(rem.sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_reminder_at, rem.channel AS last_reminder_channel,
           rem.sender AS last_reminder_by,
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
            SELECT rr.sent_at, rr.channel, COALESCE(sp.first_name, '') AS sender
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
            {"last_rsvp_at",        iso(row, "last_rsvp_at")},
            {"last_rsvp_via",       textOrNull(row, "last_rsvp_via")},
            {"last_rsvp_response",  textOrNull(row, "last_rsvp_response")},
            {"last_manual_rsvp_at", iso(row, "last_manual_rsvp_at")},
            {"months_overdue",    row["months_overdue"].is_null() ? json(nullptr) : json(row["months_overdue"].as<int>())},
            {"payment_status",    textOrNull(row, "la_payment_status")},
            {"dues_variant",      textOrNull(row, "dues_variant")},
            {"last_payment_amount", row["last_payment_amount"].is_null() ? json(nullptr)
                                        : json(row["last_payment_amount"].as<double>())},
            {"last_payment_at",   iso(row, "last_payment_at")},
            {"last_reminder", row["last_reminder_at"].is_null() ? json(nullptr) : json{
                {"sent_at", row["last_reminder_at"].c_str()},
                {"channel", row["last_reminder_channel"].c_str()},
                {"by",      row["last_reminder_by"].c_str()}}},
            {"has_phone",         !row["phone"].is_null()},
            {"has_email",         !row["email"].is_null()},
        };
        people.push_back(std::move(p));
    }
    return people;
}

json RsvpBoard::nextGames(const std::string& sectionCode,
                          const std::vector<long long>& scopeTeamIds) {
    auto* db = Database::getInstance();
    // $2 (window start) is '' here: an upcoming game is inside every window.
    const std::string sql = std::string("WITH ") + kBaseCtes + R"SQL(
    , ng AS (
      SELECT DISTINCT ON (tm.id)
             tm.id AS team_id, COALESCE(tm.label, tm.name) AS team_label, tm.board_sort_order,
             fe.id AS fh_event_id, fe.opponent, fe.is_home, ge.starts_at,
             (ge.starts_at < tm.window_end) AS released
        FROM tm
        JOIN fh_event_teams fet ON fet.team_id = tm.id
        JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
         AND ge.ends_at > now()
       ORDER BY tm.id, ge.starts_at
    )
    SELECT ng.team_id, ng.team_label, ng.fh_event_id, ng.is_home, ng.released,
           COALESCE(NULLIF(BTRIM(ng.opponent), ''), 'TBD') AS opponent,
           to_char(ng.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
           to_char(ng.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM') AS when_text,
           c.expected, c.yes, c.no
      FROM ng
      CROSS JOIN LATERAL (
            SELECT count(*) AS expected,
                   count(*) FILTER (WHERE rv.response = 'yes') AS yes,
                   count(*) FILTER (WHERE rv.response = 'no')  AS no
              FROM roster r
              JOIN expected e ON e.person_id = r.person_id AND e.fh_event_id = ng.fh_event_id
              LEFT JOIN fh_event_rsvps rv ON rv.fh_event_id = e.fh_event_id AND rv.person_id = e.person_id
             WHERE r.team_id = ng.team_id) c
     WHERE EXISTS (SELECT 1 FROM roster r WHERE r.team_id = ng.team_id)
     ORDER BY ng.starts_at, ng.board_sort_order
    )SQL";
    auto rows = db->query(sql, {sectionCode, "", pgIntArray(scopeTeamIds), "0", "all"});

    json games = json::array();
    for (const auto& row : rows) {
        const long long expected = row["expected"].as<long long>();
        const long long yes = row["yes"].as<long long>();
        const long long no  = row["no"].as<long long>();
        games.push_back({
            {"team_id",     row["team_id"].as<long long>()},
            {"team_label",  row["team_label"].c_str()},
            {"fh_event_id", row["fh_event_id"].as<long long>()},
            {"opponent",    row["opponent"].c_str()},
            {"is_home",     row["is_home"].is_null() ? json(nullptr) : json(row["is_home"].as<bool>())},
            {"starts_at",   row["starts_at"].c_str()},
            {"when_text",   row["when_text"].c_str()},
            {"released",    row["released"].as<bool>()},
            {"expected",    expected},
            {"yes",         yes},
            {"no",          no},
            {"unanswered",  expected - yes - no},
        });
    }
    return games;
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
               NULL::boolean AS still_open
          FROM roster r
        UNION ALL
        SELECT 'event', w.fh_event_id,
               w.line || COALESCE(E'\n  ' || w.message_notes, ''), w.starts_at, w.still_open
          FROM week_unanswered w
         ORDER BY what, starts_at)SQL";
    auto rows = db->query(sql, {"", "", "{}", std::to_string(personId), "all"});
    for (const auto& row : rows) {
        if (std::string(row["what"].c_str()) == "team") {
            ctx.teamIds.push_back(row["id"].as<long long>());
        } else {
            ctx.events.push_back({row["id"].as<long long>(), row["line"].c_str(),
                                  !row["still_open"].as<bool>()});
        }
    }
    return ctx;
}

json RsvpBoard::logReminder(long long personId, long long recipientPersonId,
                            const std::string& channel, const std::string& contact,
                            long long sentByUserId,
                            const std::vector<OpenEvent>& events) {
    auto* db = Database::getInstance();
    auto ins = db->query(
        "INSERT INTO rsvp_reminders (person_id, recipient_person_id, channel, contact, sent_by_user_id) "
        "VALUES ($1::int, $2::int, $3, $4, NULLIF($5::int, 0)) "
        "RETURNING id, to_char(sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS sent_at",
        {std::to_string(personId), std::to_string(recipientPersonId), channel, contact,
         std::to_string(sentByUserId)});
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
    return {{"sent_at", ins[0]["sent_at"].c_str()}, {"channel", channel}, {"by", by}};
}
