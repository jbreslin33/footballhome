#include "DashboardController.h"

#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <map>
#include <set>
#include <vector>

#include "../database/Database.h"
#include "../models/PaymentsOverview.h"
#include "../models/RsvpBoard.h"
#include "../models/WelcomeLog.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
int envIntOr(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); } catch (const std::exception&) { return fallback; }
}
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

// The RSVP cells: one per board section, the Girls lens folded into Boys
// (girls play on the boys teams — club_sections.schedule_section_id — so
// a Girls pass would count the same practice twice).  `key` is what
// #rsvps takes as its section param.
struct RsvpSection { const char* code; const char* key; };
const RsvpSection kRsvpSections[] = {{"M", "mens"}, {"W", "womens"}, {"B", "boys"}};

// Every released, still-open event of the section's week, each event
// once (a shared practice is one tile per team on the board), with how
// many players still owe an answer.  The trouble spots are the events
// with the most of their roster unanswered.
json rsvpSection(RsvpBoard& board, const RsvpSection& sec) {
    json events = board.weekEvents(sec.code, {});
    std::map<long long, json> byEvent;
    std::map<long long, std::vector<std::string>> teams;
    for (const auto& ev : events) {
        if (!ev.value("released", false)) continue;
        const long long id = ev["fh_event_id"].get<long long>();
        teams[id].push_back(ev.value("team_label", ""));
        if (byEvent.count(id)) continue;
        const long long expected = ev["all_expected"].get<long long>();
        const long long unanswered = ev["all_unanswered"].get<long long>();
        byEvent[id] = {{"fh_event_id", id}, {"kind", ev.value("kind", "")}, {"opponent", ev.value("opponent", "")},
                       {"is_home", ev.contains("is_home") ? ev["is_home"] : json(nullptr)},
                       {"starts_at", ev.value("starts_at", "")}, {"when_text", ev.value("when_text", "")}, {"day", ev.value("day", "")},
                       {"expected", expected}, {"yes", ev["all_yes"].get<long long>() + ev["all_yes_ineligible"].get<long long>()},
                       {"no", ev["all_no"].get<long long>()}, {"unanswered", unanswered}};
    }
    long long games = 0, practices = 0, expected = 0, unanswered = 0;
    std::vector<json> list;
    for (auto& [id, ev] : byEvent) {
        std::string label;
        for (const auto& t : teams[id]) { if (!label.empty()) label += " · "; label += t; }
        ev["teams"] = label;
        const std::string kind = ev["kind"].get<std::string>();
        if (kind == "practice") ++practices; else ++games;
        expected += ev["expected"].get<long long>();
        unanswered += ev["unanswered"].get<long long>();
        list.push_back(ev);
    }
    // Trouble first: the largest unanswered share, then the soonest.
    std::sort(list.begin(), list.end(), [](const json& a, const json& b) {
        const double sa = a["expected"].get<double>() > 0 ? a["unanswered"].get<double>() / a["expected"].get<double>() : 0;
        const double sb = b["expected"].get<double>() > 0 ? b["unanswered"].get<double>() / b["expected"].get<double>() : 0;
        if (sa != sb) return sa > sb;
        return a["starts_at"].get<std::string>() < b["starts_at"].get<std::string>();
    });
    json trouble = json::array();
    for (const auto& ev : list) { if (ev["unanswered"].get<long long>() <= 0 || trouble.size() >= 3) break; trouble.push_back(ev); }
    // Soonest first for the full list.
    std::sort(list.begin(), list.end(), [](const json& a, const json& b) { return a["starts_at"].get<std::string>() < b["starts_at"].get<std::string>(); });
    return {{"code", sec.code}, {"key", sec.key}, {"events", (long long)list.size()}, {"games", games}, {"practices", practices},
            {"expected", expected}, {"answered", expected - unanswered}, {"unanswered", unanswered},
            {"trouble", trouble}, {"list", list}};
}
} // namespace

DashboardController::DashboardController()
    : mensProgramId_  (envIntOr("LEAGUEAPPS_MENS_PROGRAM_ID",       5039300)),
      womensProgramId_(envIntOr("LEAGUEAPPS_WOMENS_PROGRAM_ID",     5039340)),
      boysProgramId_  (envIntOr("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",  5039252)),
      girlsProgramId_ (envIntOr("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID", 5039357)) {}

bool DashboardController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "The dashboard is for club admins.");
    return false;
}

void DashboardController::registerRoutes(Router& router, const std::string& prefix) {
    // The payments cell reads membership state (PaymentsOverview →
    // person_la_memberships), so the four membership programs sync first
    // (LA → DB → render), exactly as #payments and #finances do.
    laGet(router, prefix, {mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_},
        [this](const Request& r, const LaSyncMap&) { return handleGet(r); });
}

Response DashboardController::handleGet(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        auto* db = Database::getInstance();
        json out;

        // ── RSVPs ──────────────────────────────────────────────────────
        {
            RsvpBoard board;
            json sections = json::array();
            long long expected = 0, unanswered = 0;
            for (const auto& sec : kRsvpSections) {
                json s = rsvpSection(board, sec);
                expected += s["expected"].get<long long>();
                unanswered += s["unanswered"].get<long long>();
                sections.push_back(s);
            }
            out["rsvps"] = {{"sections", sections}, {"expected", expected}, {"answered", expected - unanswered}, {"unanswered", unanswered}};
        }

        // ── Payments ───────────────────────────────────────────────────
        {
            json overview = PaymentsOverview::build(WelcomeLog::kLighthouseClubId);
            json pay = overview["all"];
            pay["sections"] = overview["sections"];
            // Collected this month: every LeagueApps payment row (Charge /
            // Bank / Offline Payment) dated this club-local month, refunds
            // taken off, by the program's section.
            json bySection = json::array();
            double total = 0;
            std::string monthLabel;
            for (const auto& r : db->query(R"SQL(
                SELECT COALESCE(lp.category, 'other') AS category,
                       SUM(CASE WHEN pp.txn_type IN ('Refund','Partial Refund') THEN -pp.amount ELSE pp.amount END) AS collected,
                       COUNT(*) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS payments,
                       to_char(date_trunc('month', now() AT TIME ZONE 'America/New_York'), 'FMMonth YYYY') AS month_label
                  FROM person_payments pp
                  LEFT JOIN leagueapps_programs lp ON lp.program_id = pp.la_program_id
                 WHERE (pp.paid_at AT TIME ZONE 'America/New_York') >= date_trunc('month', now() AT TIME ZONE 'America/New_York')
                 GROUP BY 1
                 ORDER BY CASE COALESCE(lp.category,'other') WHEN 'men' THEN 1 WHEN 'women' THEN 2 WHEN 'boys' THEN 3 WHEN 'girls' THEN 4 ELSE 9 END)SQL")) {
                const double c = r["collected"].as<double>();
                total += c;
                monthLabel = str(r, "month_label");
                bySection.push_back({{"category", str(r, "category")}, {"collected", c}, {"payments", r["payments"].as<long long>()}});
            }
            if (monthLabel.empty()) {
                auto m = db->query("SELECT to_char(date_trunc('month', now() AT TIME ZONE 'America/New_York'), 'FMMonth YYYY') AS l");
                if (!m.empty()) monthLabel = str(m[0], "l");
            }
            pay["collected"] = {{"month_label", monthLabel}, {"total", total}, {"by_section", bySection}};
            out["payments"] = pay;
        }

        // ── Rosters ────────────────────────────────────────────────────
        {
            json teams = json::array();
            long long cappedPlayers = 0, cappedMax = 0, fullTeams = 0, players = 0;
            for (const auto& r : db->query(R"SQL(
                SELECT t.id, COALESCE(t.label, t.name) AS label, cs.code AS section, t.max_roster,
                       (SELECT count(DISTINCT tp.person_id) FROM team_persons tp
                         WHERE tp.team_id = t.id AND tp.removed_at IS NULL) AS players
                  FROM teams t
                  LEFT JOIN club_sections cs ON cs.id = t.club_section_id
                 WHERE t.is_active AND t.board_sort_order IS NOT NULL
                 ORDER BY cs.sort_order NULLS LAST, t.board_sort_order, t.name)SQL")) {
                const long long n = r["players"].as<long long>();
                const bool capped = !r["max_roster"].is_null() && r["max_roster"].as<long long>() > 0;
                const long long mx = capped ? r["max_roster"].as<long long>() : 0;
                const bool full = capped && n >= mx;
                players += n;
                if (capped) { cappedPlayers += n; cappedMax += mx; if (full) ++fullTeams; }
                teams.push_back({{"id", r["id"].as<long long>()}, {"label", str(r, "label")}, {"section", str(r, "section")},
                                 {"players", n}, {"max", capped ? json(mx) : json(nullptr)}, {"full", full}});
            }
            out["rosters"] = {{"teams", teams}, {"players", players}, {"capped_players", cappedPlayers}, {"capped_max", cappedMax}, {"full_teams", fullTeams}};
        }

        // ── Kit ────────────────────────────────────────────────────────
        {
            // Everyone on an active board team, once per section, with
            // whether they wear a number in the team's uniform set (the
            // same join the #kit roster uses).
            json sections = json::array();
            long long players = 0, numbered = 0;
            for (const auto& r : db->query(R"SQL(
                WITH on_team AS (
                  SELECT DISTINCT cs.code AS section, cs.sort_order, tp.person_id,
                         EXISTS (SELECT 1 FROM person_uniform_numbers n
                                  WHERE n.uniform_set_id = team_uniform_set_id(t.id) AND n.person_id = tp.person_id) AS numbered
                    FROM team_persons tp
                    JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL
                    LEFT JOIN club_sections cs ON cs.id = t.club_section_id
                   WHERE tp.removed_at IS NULL)
                SELECT section, count(DISTINCT person_id) AS players,
                       count(DISTINCT person_id) FILTER (WHERE numbered) AS numbered
                  FROM on_team
                 GROUP BY section, sort_order
                 ORDER BY sort_order NULLS LAST)SQL")) {
                const long long p = r["players"].as<long long>(), n = r["numbered"].as<long long>();
                players += p; numbered += n;
                sections.push_back({{"code", str(r, "section")}, {"players", p}, {"numbered", n}});
            }
            out["kit"] = {{"players", players}, {"numbered", numbered}, {"sections", sections}};
        }

        // ── Leads ──────────────────────────────────────────────────────
        {
            // The same status #leads derives (Lead.cpp): an override wins,
            // else dead › signed up › responded (any contact logged) › new.
            // "On a running ad" = the lead's form is in lead_forms, the set
            // #leads refreshes from Meta on every open.
            auto rows = db->query(R"SQL(
                WITH s AS (
                  SELECT l.id, l.created_at, l.form_id,
                         COALESCE(l.status_override, CASE
                           WHEN l.dead_at IS NOT NULL THEN 'dead'
                           WHEN l.converted_at IS NOT NULL THEN 'signedup'
                           WHEN EXISTS (SELECT 1 FROM lead_contacts lc WHERE lc.lead_id = l.id) THEN 'responded'
                           ELSE 'new' END) AS status,
                         (l.converted_at IS NULL AND l.dead_at IS NULL
                          AND (SELECT max(lc.sent_at) FROM lead_contacts lc WHERE lc.lead_id = l.id) < now() - interval '3 days') AS needs_followup,
                         EXISTS (SELECT 1 FROM lead_forms f WHERE f.form_id = l.form_id) AS on_active
                    FROM leads l)
                SELECT count(*) FILTER (WHERE status = 'new') AS new_total,
                       count(*) FILTER (WHERE status = 'new' AND on_active) AS new_on_active,
                       count(*) FILTER (WHERE status = 'new' AND created_at >= now() - interval '7 days') AS new_this_week,
                       COALESCE(EXTRACT(EPOCH FROM (now() - min(created_at) FILTER (WHERE status = 'new' AND on_active))) / 3600, 0)::int AS oldest_active_hours,
                       count(*) FILTER (WHERE needs_followup) AS needs_followup,
                       count(*) FILTER (WHERE status = 'responded') AS responded,
                       count(*) FILTER (WHERE status = 'signedup') AS signedup
                  FROM s)SQL");
            const auto& r = rows[0];
            out["leads"] = {{"new_total", r["new_total"].as<long long>()}, {"new_on_active", r["new_on_active"].as<long long>()},
                            {"new_this_week", r["new_this_week"].as<long long>()}, {"oldest_active_hours", r["oldest_active_hours"].as<long long>()},
                            {"needs_followup", r["needs_followup"].as<long long>()}, {"responded", r["responded"].as<long long>()},
                            {"signedup", r["signedup"].as<long long>()}};
        }

        // ── Home games ─────────────────────────────────────────────────
        {
            // Owner 2026-10-09: "add in upcoming home games because i always
            // need to be aware to line fields and make sure i can be there".
            // Every home game on the calendar in the next 28 days, with the
            // format (teams.field_size — what to line) and the facility.
            json games = json::array();
            for (const auto& r : db->query(R"SQL(
                SELECT fe.id AS fh_event_id, fe.match_id,
                       to_char(ge.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at,
                       to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS day,
                       to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS day_text,
                       to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') AS time_text,
                       COALESCE(NULLIF(BTRIM(fe.opponent), ''), 'TBD') AS opponent,
                       split_part(COALESCE(ge.location, ''), ',', 1) AS facility,
                       string_agg(COALESCE(t.label, t.name), ' · ' ORDER BY t.board_sort_order) AS teams,
                       string_agg(DISTINCT CASE WHEN t.field_size IS NOT NULL THEN t.field_size || 'v' || t.field_size END, '/') AS format
                  FROM fh_events fe
                  JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                  LEFT JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
                  LEFT JOIN teams t ON t.id = fet.team_id AND t.is_active
                 WHERE fe.kind = 'match' AND fe.is_home
                   AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
                   AND ge.ends_at > now() AND ge.starts_at < now() + interval '28 days'
                 GROUP BY fe.id, fe.match_id, ge.starts_at, fe.opponent, ge.location
                 ORDER BY ge.starts_at)SQL")) {
                games.push_back({{"fh_event_id", r["fh_event_id"].as<long long>()},
                                 {"match_id", r["match_id"].is_null() ? json(nullptr) : json(r["match_id"].as<long long>())},
                                 {"starts_at", str(r, "starts_at")}, {"day", str(r, "day")}, {"day_text", str(r, "day_text")},
                                 {"time_text", str(r, "time_text")}, {"opponent", str(r, "opponent")}, {"facility", str(r, "facility")},
                                 {"teams", str(r, "teams")}, {"format", str(r, "format")}});
            }
            out["home_games"] = {{"days", 28}, {"games", games}};
        }

        // ── Game Center ────────────────────────────────────────────────
        {
            // Owner 2026-10-09: "we need game center dash item. like showing
            // number of possible starters and subs … and if starters have
            // been filled out. i know we auto fill the kids".  This week's
            // games (next 7 days) with the same starter rule Game Center's
            // Practice Criteria pill applies (EligibilityController):
            // going = yes + dues-eligible; can_start = going with enough
            // window practices attended and no late game RSVP where that
            // costs the start; on_track = going who get there with the
            // upcoming window practices they said yes to; lineup = the
            // match_lineups rows (kids' teams auto-fill: everyone_plays).
            json games = json::array();
            for (const auto& r : db->query(R"SQL(
WITH g AS (
  SELECT fe.id AS fh_event_id, fe.match_id, ge.starts_at, fe.is_home, fe.league,
         COALESCE(NULLIF(BTRIM(fe.opponent), ''), 'TBD') AS opponent,
         to_char(ge.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at_iso,
         to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy FMHH12:MI AM') AS when_text,
         to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS day,
         COALESCE((SELECT array_agg(DISTINCT fet.team_id) FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id),
                  (SELECT array_remove(ARRAY[m.home_team_id, m.away_team_id], NULL) FROM matches m WHERE m.id = fe.match_id)) AS team_ids
    FROM fh_events fe
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE fe.kind = 'match' AND fe.match_id IS NOT NULL
     AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
     AND ge.ends_at > now() AND ge.starts_at < now() + interval '7 days'
), t AS (
  SELECT g.*, tm.field_size, tm.everyone_plays, tm.teams, nd.needed, nd.week_mode,
         (SELECT array_agg(w.fh_event_id) FROM fh_starter_window(g.team_ids, g.starts_at, g.match_id) w WHERE w.starts_at <  now()) AS past_win,
         (SELECT array_agg(w.fh_event_id) FROM fh_starter_window(g.team_ids, g.starts_at, g.match_id) w WHERE w.starts_at >= now()) AS future_win,
         (SELECT i.deadline FROM fh_rsvp_deadline_info(g.fh_event_id) i WHERE i.blocks_start) AS deadline
    FROM g
    -- mig 562: needed per game from fh_starter_needed — the men's week rule
    -- lowers it one per typical practice day that didn't happen this week.
    CROSS JOIN LATERAL fh_starter_needed(g.team_ids, g.starts_at, g.match_id) nd
    CROSS JOIN LATERAL (
      SELECT max(t.field_size) AS field_size, COALESCE(bool_or(t.lineup_everyone_plays), false) AS everyone_plays,
             string_agg(COALESCE(t.label, t.name), ' · ' ORDER BY t.board_sort_order) AS teams
        FROM teams t WHERE t.id = ANY(g.team_ids) AND t.is_active) tm
   WHERE EXISTS (SELECT 1 FROM teams t WHERE t.id = ANY(g.team_ids) AND t.is_active AND t.board_sort_order IS NOT NULL)
), per AS (
  SELECT t.fh_event_id, tp.person_id,
         (SELECT r.response FROM fh_event_rsvps r WHERE r.fh_event_id = t.fh_event_id AND r.person_id = tp.person_id) AS rsvp,
         fh_dues_eligible(tp.person_id) AS dues_ok,
         -- Week mode (mig 562) counts DAYS, not sessions — same as the
         -- Game Center's Practice Criteria pill.
         (CASE WHEN t.week_mode THEN
            (SELECT count(DISTINCT (w.starts_at AT TIME ZONE 'America/New_York')::date)
               FROM fh_starter_window(t.team_ids, t.starts_at, t.match_id) w
              WHERE w.starts_at < now()
                AND EXISTS (SELECT 1 FROM fh_event_attendance a
                             WHERE a.person_id = tp.person_id AND a.fh_event_id = w.fh_event_id
                               AND a.status IN ('present','late','excused')))
          ELSE
            (SELECT count(*) FROM fh_event_attendance a
              WHERE a.person_id = tp.person_id AND a.status IN ('present','late','excused') AND a.fh_event_id = ANY(COALESCE(t.past_win, '{}')))
          END) AS attended,
         (CASE WHEN t.week_mode THEN
            (SELECT count(DISTINCT (w.starts_at AT TIME ZONE 'America/New_York')::date)
               FROM fh_starter_window(t.team_ids, t.starts_at, t.match_id) w
              WHERE w.starts_at >= now()
                AND EXISTS (SELECT 1 FROM fh_event_rsvps r
                             WHERE r.person_id = tp.person_id AND r.fh_event_id = w.fh_event_id
                               AND r.response = 'yes'))
          ELSE
            (SELECT count(*) FROM fh_event_rsvps r
              WHERE r.person_id = tp.person_id AND r.response = 'yes' AND r.fh_event_id = ANY(COALESCE(t.future_win, '{}')))
          END) AS projected,
         t.needed, tp.is_callup,
         CASE WHEN t.deadline IS NULL OR now() < t.deadline THEN false
              WHEN EXISTS (SELECT 1 FROM fh_event_rsvp_first_answers fa WHERE fa.fh_event_id = t.fh_event_id AND fa.person_id = tp.person_id AND fa.first_responded_at < t.deadline) THEN false
              WHEN (SELECT min(x.joined_at) FROM team_persons x WHERE x.person_id = tp.person_id AND x.team_id = ANY(t.team_ids) AND x.removed_at IS NULL) >= t.deadline THEN false
              ELSE true END AS late
    FROM t
    -- Roster + OPEN call-up invites (mig 604, owner 2026-10-19: "if we
    -- invted 6 call ups then 6 of 18 right?") — an invitee joins the pool
    -- the moment the invite is sent, answered or not; uninvited potential
    -- call-ups count nowhere.
    JOIN LATERAL (
      SELECT x.person_id, false AS is_callup
        FROM (SELECT DISTINCT person_id FROM team_persons
               WHERE removed_at IS NULL AND team_id = ANY(t.team_ids)) x
      UNION
      SELECT i.person_id, true
        FROM fh_event_invites i
       WHERE i.fh_event_id = t.fh_event_id AND i.revoked_at IS NULL
         AND NOT EXISTS (SELECT 1 FROM team_persons z
                          WHERE z.person_id = i.person_id AND z.removed_at IS NULL
                            AND z.team_id = ANY(t.team_ids))
    ) tp ON true
), c AS (
  SELECT fh_event_id,
         count(DISTINCT person_id) AS roster,
         count(DISTINCT person_id) FILTER (WHERE is_callup) AS callups,
         count(DISTINCT person_id) FILTER (WHERE rsvp = 'yes' AND dues_ok) AS going,
         -- A Going call-up is always eligible to start (the 2026-10-16
         -- lineup rule) — the practice window and deadline are the
         -- roster's criteria, not theirs.
         count(DISTINCT person_id) FILTER (WHERE rsvp = 'yes' AND dues_ok AND (is_callup OR (attended >= needed AND NOT late))) AS can_start,
         count(DISTINCT person_id) FILTER (WHERE NOT is_callup AND rsvp = 'yes' AND dues_ok AND attended < needed AND attended + projected >= needed AND NOT late) AS on_track,
         count(DISTINCT person_id) FILTER (WHERE rsvp = 'no') AS not_going
    FROM per GROUP BY fh_event_id
)
SELECT t.match_id, t.fh_event_id, t.starts_at_iso, t.day, t.when_text, t.teams, t.opponent, t.is_home, t.field_size, t.everyone_plays, t.needed,
       c.roster, c.callups, c.going, c.can_start, c.on_track, c.not_going,
       (SELECT count(*) FROM match_lineups ml WHERE ml.match_id = t.match_id AND ml.is_starter) AS starters_set,
       (SELECT count(*) FROM match_lineups ml WHERE ml.match_id = t.match_id AND NOT ml.is_starter) AS bench_set,
       (SELECT count(*) FROM match_lineups ml JOIN players pl ON pl.id = ml.player_id
         WHERE ml.match_id = t.match_id
           AND COALESCE((SELECT r.response FROM fh_event_rsvps r WHERE r.fh_event_id = t.fh_event_id AND r.person_id = pl.person_id), '') <> 'yes') AS lineup_not_going,
       -- The opponent's people (owner 2026-10-09: "show opponent contact
       -- info … for each game"): the club through fh_opponent_club (mig
       -- 555), its contacts for this game's league first, two at most.
       (SELECT c.name FROM clubs c WHERE c.id = fh_opponent_club(t.opponent)) AS opponent_club,
       (SELECT json_agg(json_build_object('name', cc.name, 'role', cc.role, 'phone', cc.phone, 'email', cc.email)
                        ORDER BY (k.league_label ILIKE t.league) DESC NULLS LAST, cc.competition_id NULLS LAST, cc.id)
          FROM (SELECT * FROM club_contacts x
                 WHERE x.club_id = fh_opponent_club(t.opponent) AND x.is_active
                 ORDER BY (SELECT k2.league_label ILIKE t.league FROM club_competitions k2 WHERE k2.id = x.competition_id) DESC NULLS LAST,
                          x.competition_id NULLS LAST, x.id
                 LIMIT 2) cc
          LEFT JOIN club_competitions k ON k.id = cc.competition_id) AS contacts,
       -- Our own coaches for the game's teams, with phone/email for the
       -- 💬/✉ links (owner 2026-10-16: "text email for opponent coaches
       -- and our coaches! to message them").
       (SELECT json_agg(json_build_object('name', x.cname, 'role', x.crole, 'phone', x.cphone, 'email', x.cemail) ORDER BY x.cname)
          FROM (SELECT DISTINCT ON (co.person_id)
                       COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'') AS cname,
                       cr.name AS crole,
                       (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id ORDER BY ph.is_primary DESC NULLS LAST, ph.id LIMIT 1) AS cphone,
                       (SELECT em.email FROM person_emails em WHERE em.person_id = p.id ORDER BY em.is_primary DESC NULLS LAST, em.id LIMIT 1) AS cemail
                  FROM team_coaches tc
                  JOIN coaches co ON co.id = tc.coach_id
                  JOIN persons p ON p.id = co.person_id
                  LEFT JOIN coach_roles cr ON cr.id = tc.coach_role_id
                 WHERE tc.team_id = ANY(t.team_ids) AND tc.ended_at IS NULL
                 ORDER BY co.person_id, tc.started_at) x) AS our_coaches,
       -- Players still to answer, right on the cell with the same tracked
       -- REMIND buttons Game Center has (owner 2026-10-16: "text email
       -- reminder buttons for every player that shows on home page").
       (SELECT json_agg(json_build_object('person_id', pp.id,
                                          'name', COALESCE(pp.first_name,'') || ' ' || COALESCE(pp.last_name,''),
                                          'has_phone', EXISTS (SELECT 1 FROM fh_message_recipients(pp.id) m WHERE fh_recipient_phone(m.recipient_person_id, pp.id) IS NOT NULL),
                                          'has_email', EXISTS (SELECT 1 FROM fh_message_recipients(pp.id) m WHERE fh_recipient_email(m.recipient_person_id, pp.id) IS NOT NULL))
                        ORDER BY pp.last_name, pp.first_name)
          FROM (SELECT DISTINCT p2.person_id FROM per p2 WHERE p2.fh_event_id = t.fh_event_id AND p2.rsvp IS NULL) pr
          JOIN persons pp ON pp.id = pr.person_id) AS pending
  FROM t JOIN c ON c.fh_event_id = t.fh_event_id
 ORDER BY t.starts_at
            )SQL")) {
                games.push_back({{"match_id", r["match_id"].as<long long>()}, {"fh_event_id", r["fh_event_id"].as<long long>()},
                                 {"starts_at", str(r, "starts_at_iso")}, {"day", str(r, "day")}, {"when_text", str(r, "when_text")},
                                 {"teams", str(r, "teams")}, {"opponent", str(r, "opponent")},
                                 {"is_home", r["is_home"].is_null() ? json(nullptr) : json(r["is_home"].as<bool>())},
                                 {"field_size", r["field_size"].is_null() ? json(nullptr) : json(r["field_size"].as<int>())},
                                 {"everyone_plays", r["everyone_plays"].as<bool>()}, {"needed", r["needed"].as<int>()},
                                 {"roster", r["roster"].as<long long>()}, {"callups", r["callups"].as<long long>()},
                                 {"going", r["going"].as<long long>()},
                                 {"can_start", r["can_start"].as<long long>()}, {"on_track", r["on_track"].as<long long>()},
                                 {"not_going", r["not_going"].as<long long>()},
                                 {"starters_set", r["starters_set"].as<long long>()}, {"bench_set", r["bench_set"].as<long long>()},
                                 {"lineup_not_going", r["lineup_not_going"].as<long long>()},
                                 {"opponent_club", r["opponent_club"].is_null() ? json(nullptr) : json(str(r, "opponent_club"))},
                                 {"contacts", r["contacts"].is_null() ? json::array() : json::parse(str(r, "contacts"))},
                                 {"our_coaches", r["our_coaches"].is_null() ? json::array() : json::parse(str(r, "our_coaches"))},
                                 {"pending", r["pending"].is_null() ? json::array() : json::parse(str(r, "pending"))}});
            }
            out["game_center"] = {{"days", 7}, {"games", games}};
        }

        // ── Texts ──────────────────────────────────────────────────────
        {
            // Owner 2026-10-09: "add a texts dash cell for who has opted
            // in".  Rostered players per section by the #texts board's own
            // test: consent for the player or the parent (fh_sms_consented_at,
            // mig 537); the rest split by whether there is a phone to nudge.
            json sections = json::array();
            long long players = 0, optedIn = 0, notYet = 0, noPhone = 0, nudged = 0;
            for (const auto& r : db->query(R"SQL(
WITH pl AS (
  SELECT DISTINCT cs.code AS section, cs.sort_order, tp.person_id,
         (fh_sms_consented_at(tp.person_id) IS NOT NULL
          OR EXISTS (SELECT 1 FROM person_guardians g WHERE g.child_person_id = p.id
                        AND fh_sms_consented_at(g.guardian_person_id) IS NOT NULL)) AS opted_in,   -- any parent (mig 682)
         EXISTS (SELECT 1 FROM fh_message_recipients(p.id) m WHERE fh_recipient_phone(m.recipient_person_id, p.id) IS NOT NULL) AS has_phone,
         EXISTS (SELECT 1 FROM sms_opt_in_nudges n WHERE n.person_id = tp.person_id) AS nudged
    FROM team_persons tp
    JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.board_sort_order IS NOT NULL
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN club_sections cs ON cs.id = t.club_section_id
   WHERE tp.removed_at IS NULL)
SELECT section, count(*) AS players, count(*) FILTER (WHERE opted_in) AS opted_in,
       count(*) FILTER (WHERE NOT opted_in AND has_phone) AS not_yet,
       count(*) FILTER (WHERE NOT opted_in AND NOT has_phone) AS no_phone,
       count(*) FILTER (WHERE NOT opted_in AND nudged) AS nudged
  FROM pl GROUP BY section, sort_order ORDER BY sort_order NULLS LAST
            )SQL")) {
                const long long p = r["players"].as<long long>(), i = r["opted_in"].as<long long>(), n = r["not_yet"].as<long long>(),
                                np = r["no_phone"].as<long long>(), nd = r["nudged"].as<long long>();
                players += p; optedIn += i; notYet += n; noPhone += np; nudged += nd;
                sections.push_back({{"code", str(r, "section")}, {"players", p}, {"opted_in", i}, {"not_yet", n}, {"no_phone", np}, {"nudged", nd}});
            }
            out["texts"] = {{"players", players}, {"opted_in", optedIn}, {"not_yet", notYet}, {"no_phone", noPhone}, {"nudged", nudged}, {"sections", sections}};
        }

        auto now = db->query("SELECT to_char(now() AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS t");
        out["generated_at"] = now.empty() ? "" : str(now[0], "t");
        return jsonOut(HttpStatus::OK, out);
    } catch (const std::exception& e) {
        std::cerr << "[dashboard] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
