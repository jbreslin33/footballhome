#include "JobsController.h"

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <vector>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

bool parseBody(const Request& request, json* body, Response* error) {
    try {
        *body = request.getBody().empty() ? json::object() : json::parse(request.getBody());
        if (!body->is_object()) *body = json::object();
        return true;
    } catch (const std::exception& e) {
        *error = jsonError(HttpStatus::BAD_REQUEST, std::string("Invalid JSON: ") + e.what());
        return false;
    }
}

long long intField(const json& body, const char* key) {
    if (!body.contains(key)) return 0;
    if (body[key].is_number()) return body[key].get<long long>();
    if (body[key].is_string()) { try { return std::stoll(body[key].get<std::string>()); } catch (...) {} }
    return 0;
}

// "/api/jobs/event/123/mark" → 123.
long long eventIdFromPath(const std::string& path) {
    const std::string marker = "/api/jobs/event/";
    const auto at = path.find(marker);
    if (at == std::string::npos) return 0;
    std::string rest = path.substr(at + marker.size());
    const auto cut = rest.find_first_of("/?");
    if (cut != std::string::npos) rest = rest.substr(0, cut);
    try { return std::stoll(rest); } catch (...) { return 0; }
}

std::string str(const pqxx::row& r, const char* k) { return r[k].is_null() ? "" : r[k].c_str(); }

// The event's going players — the assignment pool.  RSVP yes or marked
// present/late; marked absent/excused drops out even with a yes; the
// event teams' coaches never carry player jobs (house rule: coaches are
// never in player totals).
std::vector<std::pair<int, std::string>> goingPool(long long eventId) {
    auto* db = Database::getInstance();
    std::vector<std::pair<int, std::string>> pool;
    for (const auto& r : db->query(R"SQL(
        SELECT p.id AS person_id,
               BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name
          FROM persons p
         WHERE p.id IN (
                 SELECT person_id FROM fh_event_rsvps WHERE fh_event_id = $1::bigint AND response = 'yes'
                 UNION
                 SELECT person_id FROM fh_event_attendance WHERE fh_event_id = $1::bigint AND status IN ('present', 'late'))
           AND p.id NOT IN (
                 SELECT person_id FROM fh_event_attendance WHERE fh_event_id = $1::bigint AND status IN ('absent', 'excused'))
           AND NOT EXISTS (
                 SELECT 1 FROM team_coaches tc
                   JOIN coaches c ON c.id = tc.coach_id
                  WHERE c.person_id = p.id AND tc.ended_at IS NULL
                    AND tc.team_id IN (SELECT team_id FROM fh_event_teams WHERE fh_event_id = $1::bigint))
         ORDER BY p.last_name, p.first_name)SQL", {std::to_string(eventId)}))
        pool.push_back({r["person_id"].as<int>(), str(r, "name")});
    return pool;
}

struct Def { int id; std::string slug, title, description; int needed; bool toggleable; bool off; };

// The event's job set: its kind's definitions, league-scoped rows only
// for their league (the APSL game-day set), with per-event toggles.
std::vector<Def> defsFor(long long eventId, std::string* kindOut) {
    auto* db = Database::getInstance();
    auto ev = db->query("SELECT kind, COALESCE(league, '') AS league FROM fh_events WHERE id = $1::bigint",
                        {std::to_string(eventId)});
    std::vector<Def> defs;
    if (ev.empty()) return defs;
    const std::string kind = str(ev[0], "kind"), league = str(ev[0], "league");
    if (kindOut) *kindOut = kind;
    for (const auto& r : db->query(R"SQL(
        SELECT d.id, d.slug, d.title, d.description, d.needed_count, d.toggleable,
               EXISTS (SELECT 1 FROM event_job_offs o
                        WHERE o.fh_event_id = $1::bigint AND o.job_definition_id = d.id) AS off
          FROM job_definitions d
         WHERE d.is_active AND d.event_kind = $2
           AND (d.league_label IS NULL OR d.league_label = $3)
         ORDER BY d.sort_order, d.id)SQL",
        {std::to_string(eventId), kind, league}))
        defs.push_back({r["id"].as<int>(), str(r, "slug"), str(r, "title"), str(r, "description"),
                        r["needed_count"].as<int>(), r["toggleable"].as<bool>(), r["off"].as<bool>()});
    return defs;
}

}  // namespace

void JobsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",               [this](const Request& r) { return handleBoard(r); });
    router.get (prefix + "/event/:id",           [this](const Request& r) { return handleEvent(r); });
    router.post(prefix + "/event/:id/mark",      [this](const Request& r) { return handleMark(r); });
    router.post(prefix + "/event/:id/toggle",    [this](const Request& r) { return handleToggle(r); });
    router.post(prefix + "/event/:id/assign",    [this](const Request& r) { return handleAssign(r); });
    router.post(prefix + "/event/:id/unassign",  [this](const Request& r) { return handleUnassign(r); });
}

// Admins and active coaches — same audience as the attendance tools.
bool JobsController::gate(const Request& request, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    auto* db = Database::getInstance();
    const long long userId = bearerUserId(request);
    if (!db->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {std::to_string(userId)}).empty())
        return true;
    if (!db->query("SELECT 1 FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
                   "  JOIN users u ON u.person_id = c.person_id "
                   " WHERE u.id = $1::int AND tc.ended_at IS NULL LIMIT 1", {std::to_string(userId)}).empty())
        return true;
    // 403 (not 401) so the SPA never treats a signed-in non-staff as a
    // dead session.
    *error = jsonError(HttpStatus::FORBIDDEN, "The jobs board is for club admins and coaches.");
    return false;
}

// The auto-assigner — runs on every open of an event, so late RSVPs
// re-fill by themselves.  Owner's rules in order:
//   1. anyone no longer going loses their assignment (whatever source);
//   2. home-job holders in the pool get their job — never bumped;
//   3. gaps fill with (a) players without a job yet, done-this-before
//      first, then fewest jobs in the last 60 days; (b) if still short,
//      players already holding one job, same ranking;
//   4. a filled player with no home in this SET (kind+league) adopts the
//      job as their home — stickiness, cross-training only via absence.
void JobsController::ensureAssignments(long long eventId) {
    auto* db = Database::getInstance();
    std::string kind;
    auto defs = defsFor(eventId, &kind);
    if (defs.empty()) return;
    auto pool = goingPool(eventId);
    std::set<int> inPool;
    for (const auto& [pid, name] : pool) inPool.insert(pid);

    // 1. Not going → not assigned.
    for (const auto& r : db->query("SELECT id, person_id FROM job_assignments WHERE fh_event_id = $1::bigint",
                                   {std::to_string(eventId)}))
        if (!inPool.count(r["person_id"].as<int>()))
            db->query("DELETE FROM job_assignments WHERE id = $1::int", {r["id"].c_str()});
    // Toggled-off jobs carry nobody.
    db->query("DELETE FROM job_assignments ja USING event_job_offs o "
              " WHERE ja.fh_event_id = $1::bigint AND o.fh_event_id = ja.fh_event_id "
              "   AND o.job_definition_id = ja.job_definition_id", {std::to_string(eventId)});

    // "Sub cards: 1 guy who STARTS ON BENCH."  When this game has a
    // lineup with a bench and has not kicked off, the sub-cards job is
    // bench-only: a home/fill holder who ended up in the starting XI
    // (or out of the squad) releases it, home placement and gap-fill
    // prefer bench players, and the pass-on in
    // EligibilityController::handleSaveMatchLineup can then actually
    // fire once the game starts.  manual/pass sources are the coach's
    // call (or the game's own history) and are never released here.
    // Every other job stays zone-blind.
    std::set<int> benchPersons;
    bool subCardsBenchRule = false;
    {
        auto pre = db->query(
            "SELECT pl.person_id, (ge.starts_at > now()) AS pre_kickoff "
            "  FROM fh_events fe "
            "  JOIN gcal_events ge ON ge.id = fe.gcal_event_id "
            "  JOIN match_lineups ml ON ml.match_id = fe.match_id AND ml.zone = 'bench' "
            "  JOIN players pl ON pl.id = ml.player_id "
            " WHERE fe.id = $1::bigint", {std::to_string(eventId)});
        for (const auto& r : pre) {
            benchPersons.insert(r["person_id"].as<int>());
            subCardsBenchRule = r["pre_kickoff"].as<bool>();
        }
        if (subCardsBenchRule) {
            for (const auto& d : defs) {
                if (d.slug != "sub-cards") continue;
                for (const auto& r : db->query(
                        "SELECT id, person_id FROM job_assignments "
                        " WHERE fh_event_id = $1::bigint AND job_definition_id = $2::int "
                        "   AND source IN ('home', 'fill')",
                        {std::to_string(eventId), std::to_string(d.id)}))
                    if (!benchPersons.count(r["person_id"].as<int>()))
                        db->query("DELETE FROM job_assignments WHERE id = $1::int", {r["id"].c_str()});
            }
        }
    }

    // Everyone's history, once: done-this-job-before counts and the
    // last-60-days load, for the fairness ranking.
    std::map<int, std::map<int, int>> doneBefore;   // person → def → times
    std::map<int, int> recentLoad;                  // person → jobs in 60 days
    for (const auto& r : db->query(
            "SELECT person_id, job_definition_id, COUNT(*) AS n, "
            "       COUNT(*) FILTER (WHERE created_at > now() - interval '60 days') AS recent "
            "  FROM job_assignments WHERE fh_event_id <> $1::bigint "
            " GROUP BY person_id, job_definition_id", {std::to_string(eventId)})) {
        const int pid = r["person_id"].as<int>(), did = r["job_definition_id"].as<int>();
        doneBefore[pid][did] = r["n"].as<int>();
        recentLoad[pid] += r["recent"].as<int>();
    }

    // Current state after the cleanup.
    std::map<int, std::vector<int>> held;           // def → persons
    std::map<int, int> jobsHeld;                    // person → count this event
    for (const auto& r : db->query("SELECT job_definition_id, person_id FROM job_assignments WHERE fh_event_id = $1::bigint",
                                   {std::to_string(eventId)})) {
        held[r["job_definition_id"].as<int>()].push_back(r["person_id"].as<int>());
        jobsHeld[r["person_id"].as<int>()]++;
    }

    // Home holders per def (only those in the pool).
    std::map<int, std::vector<int>> homes;          // def → persons
    std::set<int> hasHomeInSet;                     // persons with a home in this set
    for (const auto& r : db->query(R"SQL(
        SELECT h.person_id, h.job_definition_id
          FROM job_homes h
          JOIN job_definitions d ON d.id = h.job_definition_id
          JOIN fh_events e ON e.id = $1::bigint
         WHERE d.event_kind = e.kind AND (d.league_label IS NULL OR d.league_label = COALESCE(e.league, ''))
         ORDER BY h.created_at)SQL", {std::to_string(eventId)})) {
        const int pid = r["person_id"].as<int>();
        if (!inPool.count(pid)) continue;
        homes[r["job_definition_id"].as<int>()].push_back(pid);
        hasHomeInSet.insert(pid);
    }

    auto assign = [&](int defId, int pid, const char* source) {
        db->query("INSERT INTO job_assignments (fh_event_id, job_definition_id, person_id, source) "
                  "VALUES ($1::bigint, $2::int, $3::int, $4) ON CONFLICT DO NOTHING",
                  {std::to_string(eventId), std::to_string(defId), std::to_string(pid), source});
        held[defId].push_back(pid);
        jobsHeld[pid]++;
    };

    // 2. Homes first, 3. then fills.
    for (const auto& d : defs) {
        if (d.off) continue;
        auto has = [&](int pid) {
            const auto& v = held[d.id];
            return std::find(v.begin(), v.end(), pid) != v.end();
        };
        const bool benchOnly = subCardsBenchRule && d.slug == "sub-cards";
        for (int pid : homes[d.id]) {
            if ((int)held[d.id].size() >= d.needed) break;
            if (benchOnly && !benchPersons.count(pid)) continue;   // a starting home holder sits this one out
            if (!has(pid)) assign(d.id, pid, "home");
        }
        for (int pass = 0; pass < 2 && (int)held[d.id].size() < d.needed; pass++) {
            // pass 0: players without any job yet; pass 1: second jobs.
            std::vector<int> cands;
            for (const auto& [pid, name] : pool) {
                if (has(pid)) continue;
                if (pass == 0 && jobsHeld[pid] > 0) continue;
                cands.push_back(pid);
            }
            std::stable_sort(cands.begin(), cands.end(), [&](int a, int b) {
                if (benchOnly) {                                // sub cards go to a bench player
                    const bool ba = benchPersons.count(a) > 0, bb2 = benchPersons.count(b) > 0;
                    if (ba != bb2) return ba;
                }
                const bool da = doneBefore[a][d.id] > 0, dbb = doneBefore[b][d.id] > 0;
                if (da != dbb) return da;                       // done it before first
                if (recentLoad[a] != recentLoad[b]) return recentLoad[a] < recentLoad[b];
                return a < b;
            });
            for (int pid : cands) {
                if ((int)held[d.id].size() >= d.needed) break;
                assign(d.id, pid, "fill");
                // 4. Stickiness: first job in this set becomes home.
                if (!hasHomeInSet.count(pid)) {
                    db->query("INSERT INTO job_homes (person_id, job_definition_id) VALUES ($1::int, $2::int) "
                              "ON CONFLICT DO NOTHING", {std::to_string(pid), std::to_string(d.id)});
                    hasHomeInSet.insert(pid);
                }
            }
        }
        // Shrunk needs: the NEWEST non-manual extras go (homes were
        // assigned first, so oldest-kept preserves them).
        db->query(R"SQL(
            DELETE FROM job_assignments WHERE id IN (
                SELECT id FROM job_assignments
                 WHERE fh_event_id = $1::bigint AND job_definition_id = $2::int AND source <> 'manual'
                 ORDER BY created_at ASC, id ASC
                OFFSET GREATEST($3::int - (SELECT COUNT(*) FROM job_assignments
                                            WHERE fh_event_id = $1::bigint AND job_definition_id = $2::int
                                              AND source = 'manual'), 0)))SQL",
            {std::to_string(eventId), std::to_string(d.id), std::to_string(d.needed)});
    }
}

// GET /api/jobs/board?from=YYYY-MM-DD&days=N — the window's games and
// practices with assigned/flagged counts (default: 3 days back, 10 wide).
Response JobsController::handleBoard(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    std::string from = request.getQueryParam("from");
    int days = 10;
    try { days = std::stoi(request.getQueryParam("days")); } catch (...) {}
    if (days < 1 || days > 60) days = 10;
    try {
        auto* db = Database::getInstance();
        json events = json::array();
        for (const auto& r : db->query(R"SQL(
            SELECT e.id, e.kind, COALESCE(e.league, '') AS league, COALESCE(e.opponent, '') AS opponent, e.is_home,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS on_date,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD') AS day_label,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI am') AS time_label,
                   COALESCE(NULLIF(BTRIM(g.summary), ''), '') AS summary,
                   (SELECT string_agg(t.name, ' + ' ORDER BY t.id) FROM fh_event_teams fet
                      JOIN teams t ON t.id = fet.team_id WHERE fet.fh_event_id = e.id) AS team_label,
                   (SELECT COUNT(*) FROM job_assignments ja WHERE ja.fh_event_id = e.id) AS assigned,
                   (SELECT COUNT(*) FROM job_assignments ja WHERE ja.fh_event_id = e.id AND ja.not_done) AS flagged
              FROM fh_events e
              JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL
                                AND g.status IS DISTINCT FROM 'cancelled'
             WHERE e.kind IN ('match', 'practice')
               AND (g.starts_at AT TIME ZONE 'America/New_York')::date
                   BETWEEN COALESCE(NULLIF($1, '')::date, CURRENT_DATE - 3)
                       AND COALESCE(NULLIF($1, '')::date, CURRENT_DATE - 3) + $2::int
             ORDER BY g.starts_at)SQL", {from, std::to_string(days)})) {
            events.push_back({{"id", r["id"].as<long long>()}, {"kind", str(r, "kind")}, {"league", str(r, "league")},
                              {"opponent", str(r, "opponent")},
                              {"is_home", r["is_home"].is_null() ? json(nullptr) : json(r["is_home"].as<bool>())},
                              {"date", str(r, "on_date")}, {"day_label", str(r, "day_label")},
                              {"time_label", str(r, "time_label")}, {"summary", str(r, "summary")},
                              {"team_label", str(r, "team_label")},
                              {"assigned", r["assigned"].as<int>()}, {"flagged", r["flagged"].as<int>()}});
        }
        return jsonOut(HttpStatus::OK, {{"events", events}});
    } catch (const std::exception& e) {
        std::cerr << "[jobs board] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// GET /api/jobs/event/:id — the jobs of one event, auto-assigned fresh.
Response JobsController::handleEvent(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = eventIdFromPath(request.getPath());
    if (id <= 0) return jsonError(HttpStatus::NOT_FOUND, "no such event");
    try {
        auto* db = Database::getInstance();
        ensureAssignments(id);

        auto ev = db->query(R"SQL(
            SELECT e.id, e.kind, COALESCE(e.league, '') AS league, COALESCE(e.opponent, '') AS opponent, e.is_home,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'Dy FMMM/FMDD') AS day_label,
                   to_char(g.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI am') AS time_label,
                   COALESCE(NULLIF(BTRIM(g.summary), ''), '') AS summary
              FROM fh_events e JOIN gcal_events g ON g.id = e.gcal_event_id
             WHERE e.id = $1::bigint)SQL", {std::to_string(id)});
        if (ev.empty()) return jsonError(HttpStatus::NOT_FOUND, "no such event");

        std::map<int, json> byDef;
        for (const auto& r : db->query(R"SQL(
            SELECT ja.id, ja.job_definition_id, ja.person_id, ja.source, ja.not_done,
                   BTRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name
              FROM job_assignments ja JOIN persons p ON p.id = ja.person_id
             WHERE ja.fh_event_id = $1::bigint
             ORDER BY ja.created_at)SQL", {std::to_string(id)}))
            byDef[r["job_definition_id"].as<int>()].push_back(
                {{"id", r["id"].as<long long>()}, {"person_id", r["person_id"].as<int>()},
                 {"name", str(r, "name")}, {"source", str(r, "source")}, {"not_done", r["not_done"].as<bool>()}});

        json jobs = json::array();
        for (const auto& d : defsFor(id, nullptr)) {
            json assignments = byDef.count(d.id) ? byDef[d.id] : json::array();
            jobs.push_back({{"id", d.id}, {"slug", d.slug}, {"title", d.title}, {"description", d.description},
                            {"needed", d.needed}, {"toggleable", d.toggleable}, {"off", d.off},
                            {"assignments", std::move(assignments)}});
        }

        std::set<int> assigned;
        for (const auto& [did, arr] : byDef) for (const auto& a : arr) assigned.insert(a["person_id"].get<int>());
        json pool = json::array();
        for (const auto& [pid, name] : goingPool(id))
            pool.push_back({{"person_id", pid}, {"name", name}, {"has_job", assigned.count(pid) > 0}});

        const auto& e0 = ev[0];
        json event = {{"id", id}, {"kind", str(e0, "kind")}, {"league", str(e0, "league")},
                      {"opponent", str(e0, "opponent")},
                      {"is_home", e0["is_home"].is_null() ? json(nullptr) : json(e0["is_home"].as<bool>())},
                      {"day_label", str(e0, "day_label")}, {"time_label", str(e0, "time_label")},
                      {"summary", str(e0, "summary")}};
        return jsonOut(HttpStatus::OK, {{"event", event}, {"jobs", jobs}, {"pool", pool}});
    } catch (const std::exception& e) {
        std::cerr << "[jobs event] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/jobs/event/:id/mark {assignment_id, not_done} — flag (or
// clear) the exception.  Done is the default and never stored.
Response JobsController::handleMark(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = eventIdFromPath(request.getPath());
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long aid = intField(body, "assignment_id");
    if (id <= 0 || aid <= 0) return jsonError(HttpStatus::BAD_REQUEST, "assignment_id required");
    const bool notDone = body.value("not_done", true);
    try {
        Database::getInstance()->query(
            "UPDATE job_assignments SET not_done = $3::bool WHERE id = $1::int AND fh_event_id = $2::bigint",
            {std::to_string(aid), std::to_string(id), notDone ? "true" : "false"});
        return handleEvent(request);
    } catch (const std::exception& e) {
        std::cerr << "[jobs mark] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/jobs/event/:id/toggle {job_definition_id, on} — the per-game
// toggle (tents).  Off frees its players; the re-run on response gives
// them other gaps.
Response JobsController::handleToggle(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = eventIdFromPath(request.getPath());
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long defId = intField(body, "job_definition_id");
    if (id <= 0 || defId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "job_definition_id required");
    const bool on = body.value("on", true);
    try {
        auto* db = Database::getInstance();
        if (on) db->query("DELETE FROM event_job_offs WHERE fh_event_id = $1::bigint AND job_definition_id = $2::int",
                          {std::to_string(id), std::to_string(defId)});
        else db->query("INSERT INTO event_job_offs (fh_event_id, job_definition_id) VALUES ($1::bigint, $2::int) "
                       "ON CONFLICT DO NOTHING", {std::to_string(id), std::to_string(defId)});
        return handleEvent(request);
    } catch (const std::exception& e) {
        std::cerr << "[jobs toggle] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/jobs/event/:id/assign {job_definition_id, person_id} — a
// manual pick (the sub-cards pass, a coach's call).  Manual assignments
// never become homes and never get auto-bumped.
Response JobsController::handleAssign(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = eventIdFromPath(request.getPath());
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long defId = intField(body, "job_definition_id"), pid = intField(body, "person_id");
    if (id <= 0 || defId <= 0 || pid <= 0) return jsonError(HttpStatus::BAD_REQUEST, "job_definition_id and person_id required");
    try {
        Database::getInstance()->query(
            "INSERT INTO job_assignments (fh_event_id, job_definition_id, person_id, source) "
            "VALUES ($1::bigint, $2::int, $3::int, 'manual') "
            "ON CONFLICT (fh_event_id, job_definition_id, person_id) DO UPDATE SET source = 'manual'",
            {std::to_string(id), std::to_string(defId), std::to_string(pid)});
        return handleEvent(request);
    } catch (const std::exception& e) {
        std::cerr << "[jobs assign] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// POST /api/jobs/event/:id/unassign {assignment_id} — take one person
// off a job.  The follow-up re-run refills the gap (possibly with the
// same person if the ranking says so — remove-and-replace is the manual
// assign endpoint's job).
Response JobsController::handleUnassign(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const long long id = eventIdFromPath(request.getPath());
    json body; Response bad; if (!parseBody(request, &body, &bad)) return bad;
    const long long aid = intField(body, "assignment_id");
    if (id <= 0 || aid <= 0) return jsonError(HttpStatus::BAD_REQUEST, "assignment_id required");
    try {
        Database::getInstance()->query(
            "DELETE FROM job_assignments WHERE id = $1::int AND fh_event_id = $2::bigint",
            {std::to_string(aid), std::to_string(id)});
        return handleEvent(request);
    } catch (const std::exception& e) {
        std::cerr << "[jobs unassign] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
