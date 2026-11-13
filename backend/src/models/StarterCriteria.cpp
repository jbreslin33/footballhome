#include "StarterCriteria.h"

#include <pqxx/pqxx>

#include "../database/Database.h"
#include "../third_party/json.hpp"

const std::string& StarterCriteria::statsSql() {
    static const std::string sql = R"SQL(
                WITH match_event AS (
                    SELECT fe.id AS fh_event_id, ge.starts_at
                    FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fe.match_id = $1::int
                    LIMIT 1
                ),
                -- needed comes from fh_starter_needed — the one place the
                -- rule lives: the policy number, or the men's week rule
                -- (Mon–Sat practice days − 3; 0 in a week with a weekday
                -- game — migs 562/804/805) — plus the reason it applied.
                pol AS (
                    SELECT n.needed, n.base_needed, n.typical_days, n.held_days, n.missed_days, n.week_mode, n.reason,
                           (SELECT COALESCE(p.lookback_count, 5) FROM fh_starter_policy($2::int[], $1::int) p) AS lookback
                    FROM match_event me
                    CROSS JOIN LATERAL fh_starter_needed($2::int[], me.starts_at, $1::int) n
                ),
                win AS (
                    SELECT w.fh_event_id, w.kind, w.starts_at, w.extended, w.cutoff,
                           ge.location, fe.arrival_at
                    FROM match_event me
                    CROSS JOIN LATERAL fh_starter_window($2::int[], me.starts_at, $1::int) w
                    JOIN fh_events fe ON fe.id = w.fh_event_id
                    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                ),
                -- Second criterion (mig 507): the game's own RSVP had to be
                -- in by its deadline — only where the policy says a late
                -- answer costs the start (Men, mig 508).  One row, deadline
                -- NULL = no such rule for this game.
                dl AS (
                    SELECT me.fh_event_id,
                           (SELECT i.deadline FROM fh_rsvp_deadline_info(me.fh_event_id) i WHERE i.blocks_start) AS deadline
                    FROM match_event me
                )
                SELECT DISTINCT ON (pl.id) pl.id AS player_id,
                       (SELECT needed FROM pol) AS needed,
                       (SELECT lookback FROM pol) AS lookback,
                       (SELECT week_mode FROM pol) AS week_mode,
                       (SELECT base_needed FROM pol) AS base_needed,
                       (SELECT typical_days FROM pol) AS typical_days,
                       (SELECT held_days FROM pol) AS held_days,
                       (SELECT missed_days FROM pol) AS missed_days,
                       (SELECT reason FROM pol) AS needed_reason,
                       (SELECT count(*) FROM win) AS window_total,
                       (SELECT count(*) FROM win WHERE win.starts_at < now()) AS recent_total,
                       -- Week mode counts DAYS, not sessions (mig 562): two
                       -- sessions on one Saturday are one day held/attended.
                       (SELECT CASE WHEN (SELECT week_mode FROM pol) THEN
                               (SELECT count(DISTINCT (w2.starts_at AT TIME ZONE 'America/New_York')::date) FROM win w2
                                 WHERE w2.starts_at < now()
                                   AND EXISTS (SELECT 1 FROM fh_event_attendance fea
                                                WHERE fea.person_id = pe.id AND fea.fh_event_id = w2.fh_event_id
                                                  AND fea.status IN ('present', 'late', 'excused')))
                          ELSE
                               (SELECT count(*) FROM fh_event_attendance fea
                                 WHERE fea.person_id = pe.id
                                   AND fea.fh_event_id IN (SELECT fh_event_id FROM win WHERE win.starts_at < now())
                                   AND fea.status IN ('present', 'late', 'excused'))
                          END) AS practices_attended,
                       (SELECT count(*) FROM win WHERE win.starts_at >= now()) AS upcoming_total,
                       (SELECT CASE WHEN (SELECT week_mode FROM pol) THEN
                               (SELECT count(DISTINCT (up.starts_at AT TIME ZONE 'America/New_York')::date) FROM win up
                                 WHERE up.starts_at >= now()
                                   AND (SELECT r.response FROM fh_event_rsvps r
                                          WHERE r.fh_event_id = up.fh_event_id AND r.person_id = pe.id) = 'yes')
                          ELSE
                               (SELECT count(*) FROM win up
                                 WHERE up.starts_at >= now()
                                   AND (SELECT r.response FROM fh_event_rsvps r
                                          WHERE r.fh_event_id = up.fh_event_id AND r.person_id = pe.id) = 'yes')
                          END) AS practices_projected,
                       COALESCE((SELECT bool_or(extended) FROM win), false) AS extended,
                       (SELECT to_char(min(cutoff) AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') FROM win) AS cutoff,
                       -- A coach who also plays and chose Coaching only (mig 688)
                       -- is not in the lineup pool: 'coaching', not 'yes'.
                       (SELECT CASE WHEN r.response = 'yes' AND r.role_choice = 'coach' THEN 'coaching' ELSE r.response END
                          FROM fh_event_rsvps r, match_event me
                         WHERE r.fh_event_id = me.fh_event_id AND r.person_id = pe.id) AS game_rsvp,
                       (SELECT me.fh_event_id FROM match_event me) AS game_fh_event_id,
                       (SELECT to_char((dl.deadline AT TIME ZONE 'America/New_York')::date - 1, 'YYYY-MM-DD') FROM dl) AS rsvp_deadline_day,
                       -- Dues alternate (mig 613): ANY balance where this
                       -- game's section policy says so (Men).  Sinks the
                       -- player to the bottom of the selection pool; the
                       -- controller blanks it on every row that is not the
                       -- viewer's own unless the viewer is the coach.
                       ((SELECT EXISTS (SELECT 1 FROM teams t
                                         WHERE t.id = ANY($2::int[]) AND t.club_section_id IS NOT NULL
                                           AND fh_dues_policy_alternates(t.club_id, t.club_section_id)))
                          AND COALESCE(fh_dues_balance_usd(pe.id), 0) > 0) AS dues_alternate,
                       COALESCE(fh_dues_balance_usd(pe.id), 0) AS dues_balance,
                       -- on_time: first answer before the deadline (a later
                       -- change keeps it — owner 2026-10-01); pending: not
                       -- answered, deadline still ahead; late: missed it.
                       -- NULL for someone rostered only after the deadline.
                       (SELECT CASE
                                 WHEN dl.deadline IS NULL THEN NULL
                                 -- Excused for this game (mig 1067).
                                 WHEN EXISTS (SELECT 1 FROM rsvp_deadline_person_waivers pw0
                                               WHERE pw0.fh_event_id = dl.fh_event_id AND pw0.person_id = pe.id) THEN 'on_time'
                                 WHEN EXISTS (SELECT 1 FROM fh_event_rsvp_first_answers fa
                                               WHERE fa.fh_event_id = dl.fh_event_id AND fa.person_id = pe.id
                                                 AND fa.first_responded_at < dl.deadline) THEN 'on_time'
                                 WHEN now() < dl.deadline THEN 'pending'
                                 WHEN (SELECT min(x.joined_at) FROM team_persons x
                                        WHERE x.person_id = pe.id AND x.team_id = ANY($2::int[])
                                          AND x.removed_at IS NULL) >= dl.deadline THEN NULL
                                 ELSE 'late' END
                          FROM dl) AS rsvp_timing,
                       (SELECT json_agg(json_build_object(
                                  'fhEventId', pw.fh_event_id,
                                  'kind', pw.kind,
                                  'date', to_char(pw.starts_at, 'YYYY-MM-DD"T"HH24:MI:SS'),
                                  'startsAt', to_char(pw.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
                                  'location', pw.location,
                                  'future', pw.starts_at >= now(),
                                  'rsvp', (SELECT r.response FROM fh_event_rsvps r
                                             WHERE r.fh_event_id = pw.fh_event_id AND r.person_id = pe.id),
                                  -- mig 563: 'excused' counts toward the
                                  -- criterion and the chip labels it so.
                                  'status', (SELECT fea.status FROM fh_event_attendance fea
                                               WHERE fea.fh_event_id = pw.fh_event_id AND fea.person_id = pe.id),
                                  'attended', CASE WHEN pw.starts_at >= now() THEN
                                      COALESCE(
                                          (SELECT r.response FROM fh_event_rsvps r
                                             WHERE r.fh_event_id = pw.fh_event_id AND r.person_id = pe.id
                                          ) = 'yes',
                                          false
                                      )
                                  ELSE
                                      EXISTS(
                                          SELECT 1 FROM fh_event_attendance fea
                                          WHERE fea.person_id = pe.id AND fea.fh_event_id = pw.fh_event_id
                                            AND fea.status IN ('present', 'late', 'excused'))
                                  END
                                ) ORDER BY pw.starts_at)
                          FROM win pw) AS practice_pills
                FROM team_persons tp
                JOIN persons pe ON pe.id = tp.person_id
                JOIN players pl ON pl.person_id = pe.id
                WHERE tp.team_id = ANY($2::int[]) AND tp.removed_at IS NULL
                  AND NOT tp.invite_only   -- 📄 paper spot (mig 619): no criteria rows
                  AND ($3 = '' OR pe.id = NULLIF($3, '')::int)
                ORDER BY pl.id
            )SQL";
    return sql;
}

std::optional<StarterCriteria::Result> StarterCriteria::forPerson(long long personId) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    // His next game: Going (and not Coaching only), within 8 days, not
    // cancelled.  Its roster teams = the lineup endpoint's set.
    const auto games = db->query(
        "SELECT fe.id AS fh_event_id, fe.match_id, COALESCE(NULLIF(BTRIM(fe.opponent), ''), '') AS opponent, "
        "       to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM') AS kickoff, "
        "       (SELECT array_agg(DISTINCT lt) FROM fh_event_list_team_ids(fe.id) lt)::text AS team_ids "
        "  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
        "  JOIN fh_event_rsvps r ON r.fh_event_id = fe.id AND r.person_id = $1::int "
        "       AND r.response = 'yes' AND r.role_choice IS DISTINCT FROM 'coach' "
        " WHERE fe.match_id IS NOT NULL AND ge.status <> 'cancelled' "
        "   AND ge.starts_at >= now() AND ge.starts_at < now() + interval '8 days' "
        " ORDER BY ge.starts_at",
        {pid});
    for (const auto& g : games) {
        if (g["team_ids"].is_null()) continue;
        const std::string matchId = g["match_id"].c_str();
        const auto rows = db->query(statsSql(), {matchId, std::string(g["team_ids"].c_str()), pid});
        if (rows.empty()) continue;   // Going but not rostered (a call-up): no criterion
        const auto& row = rows[0];
        Result out;
        out.matchId   = g["match_id"].as<long long>();
        out.fhEventId = g["fh_event_id"].as<long long>();
        out.game      = g["opponent"].c_str();
        out.when      = g["kickoff"].c_str();
        out.needed    = row["needed"].as<long long>();
        out.attended  = row["practices_attended"].as<long long>();
        out.projected = row["practices_projected"].as<long long>();
        bool anyFuture = false;
        if (!row["practice_pills"].is_null()) {
            const auto pills = nlohmann::json::parse(row["practice_pills"].c_str());
            for (const auto& p : pills) {
                Practice x;
                x.future  = p.value("future", false);
                x.rsvp    = p["rsvp"].is_string() ? p["rsvp"].get<std::string>() : "";
                x.status  = p["status"].is_string() ? p["status"].get<std::string>() : "";
                x.counted = p.value("attended", false);
                const std::string at = p.value("startsAt", "");
                if (!at.empty()) {
                    const auto w = db->query(
                        "SELECT to_char($1::timestamptz AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM')", {at});
                    if (!w.empty()) x.when = w[0][0].c_str();
                }
                anyFuture = anyFuture || x.future;
                out.practices.push_back(x);
            }
        }
        const long long n = out.needed, a = out.attended, pr = out.projected;
        out.state = a > n ? "exceeding"
                  : (a == n && pr > 0) ? "exceeding_projected"
                  : a >= n ? "met"
                  : a + pr >= n ? "projected"
                  : anyFuture ? "needs" : "not_met";
        return out;
    }
    return std::nullopt;
}
