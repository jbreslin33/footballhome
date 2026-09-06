#pragma once
#include "Router.h"
#include "Request.h"
#include "Response.h"
#include "../services/LaProgramSync.h"
#include <functional>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

// Forward declaration to avoid circular dependency
class Router;

class Controller {
public:
    Controller() = default;
    virtual ~Controller() = default;
    
    // Pure virtual method that subclasses must implement
    virtual void registerRoutes(Router& router, const std::string& prefix) = 0;
    
protected:
    // ──────────────────────────────────────────────────────────────────────
    // LA-sync route primitives — MANDATE the "LA API → DB → render"
    // protocol before every LA-derived response.  See docs in
    // .github/copilot-instructions.md § Membership Data Flow (STRICT).
    //
    // Every route that renders anything derived from LA membership
    // (rosters, member lists, pool, lineups, payments, RSVP eligibility,
    // profile badges, everything) MUST be registered through laGet /
    // laPost / laPut / laDel — NOT via router.get(...) directly.
    //
    // The framework runs LaProgramSync::run() for each `programs[i]`
    // (in parallel via std::async when there is more than one) and
    // hands the aggregated result to `handler` before it touches the
    // DB.  Failed syncs are logged + omitted from the map; the handler
    // decides whether to serve stale DB state or surface an error.
    //
    // Routes that legitimately render no LA-derived data (health,
    // login, static config, admin backups) MAY keep calling router.get
    // directly, but scripts/enforce-la-sync.sh will flag any handler
    // that reads person_la_memberships / leagueapps_programs without
    // going through a la* wrapper.
    // ──────────────────────────────────────────────────────────────────────

    // Aggregated per-program sync result, keyed by programId, handed to
    // every laGet / laPost / laPut / laDel handler.  Programs whose sync
    // threw are absent from the map (the failure is already logged).
    using LaSyncMap = std::unordered_map<int, LaProgramSync::Result>;

    // Handler shape for la* routes.
    using LaHandler = std::function<Response(const Request&, const LaSyncMap&)>;

    // Compile-time program list — the common case (e.g. `laGet(router,
    // "/payments/mens/members", {mensProgramId_}, ...)`).
    void laGet (Router& router, const std::string& path, std::vector<int> programs, LaHandler handler);
    void laPost(Router& router, const std::string& path, std::vector<int> programs, LaHandler handler);
    void laPut (Router& router, const std::string& path, std::vector<int> programs, LaHandler handler);
    void laDel (Router& router, const std::string& path, std::vector<int> programs, LaHandler handler);

    // Dynamic program list — call site inspects the request (path
    // params, query string, JWT claims) to decide which programs to
    // sync.  Used by /admin/membership/sync (variant/category filters)
    // and /my/* (caller-specific memberships).
    using LaProgramsForRequest = std::function<std::vector<int>(const Request&)>;
    void laGet (Router& router, const std::string& path, LaProgramsForRequest programsForRequest, LaHandler handler);
    void laPost(Router& router, const std::string& path, LaProgramsForRequest programsForRequest, LaHandler handler);
    void laPut (Router& router, const std::string& path, LaProgramsForRequest programsForRequest, LaHandler handler);
    void laDel (Router& router, const std::string& path, LaProgramsForRequest programsForRequest, LaHandler handler);

    // Fan out LaProgramSync::run() across `programs` in parallel (single
    // program is short-circuited to a direct call).  Exposed protected
    // because a handful of legacy callers (webhooks, cron workers) run
    // outside the router but still need to obey the STRICT rule; new
    // code should always go through la* route helpers instead.
    static LaSyncMap syncPrograms(const std::vector<int>& programs);

    // Returns every program_id currently in leagueapps_programs (active
    // variants first, then paused/pickup by id) — the canonical "every
    // LA program that could possibly feed this response" list.  Used
    // with the dynamic laGet(…, LaProgramsForRequest, …) overload for
    // profile/roster/backfill endpoints that render memberships across
    // all categories at once.  DB errors are logged + swallowed
    // (returns empty) so a transient outage in the registry table
    // doesn't take down every LA-aware endpoint.
    static std::vector<int> allLaProgramIds();

    // Just the pickup-variant programs (men 5070075, boys 5064618, girls
    // 5064662, women 5064686 today). The roster boards sync these on top
    // of their own Members program so the "also a pickup member" flag on
    // a card is as fresh as the membership data beside it — the STRICT
    // Membership Data Flow rule applies to the flag too. Same
    // never-throws contract as allLaProgramIds().
    static std::vector<int> laPickupProgramIds();

    // Utility methods for controllers
    Response jsonResponse(const std::string& json);
    Response jsonResponse(HttpStatus status, const std::string& json);
    Response errorResponse(HttpStatus status, const std::string& message);
    Response successResponse(const std::string& message = "Success");
    
    // Request parsing helpers
    bool validateJsonRequest(const Request& request, Response& error_response);
    std::string extractJsonField(const std::string& json, const std::string& field);
    
    // Path parameter extraction (for future enhancement)
    std::string getPathParam(const Request& request, const std::string& param_name);

    // ──────────────────────────────────────────────────────────────────────
    // Shared helpers consolidated from per-controller duplicates.
    // Subclasses get these for free via inheritance; their old per-class
    // copies have been deleted.
    // ──────────────────────────────────────────────────────────────────────

    // Build the canonical `{success,message[,data]}` JSON envelope used by
    // most REST handlers.  `data` is inlined verbatim (assumed to be valid
    // JSON already) so callers can splice in pre-built objects/arrays.
    static std::string createJSONResponse(bool success,
                                          const std::string& message,
                                          const std::string& data = "");

    // Escape a string for embedding in a JSON value.  Escapes control
    // characters and the JSON metacharacters; high bytes (UTF-8 cont.
    // bytes) are passed through unchanged.
    static std::string escapeJson(const std::string& input);

    // Historical name aliases so legacy call sites compile unchanged.
    static std::string escapeJSON(const std::string& input)       { return escapeJson(input); }
    static std::string escapeJsonString(const std::string& input) { return escapeJson(input); }

    // Bearer-token presence gate.  Returns true iff the Authorization
    // header (case-insensitive) starts with "Bearer ".  Does NOT validate
    // the token — handlers that need claims still parse it themselves.
    static bool requireBearer(const Request& request);

    // users.id from a verified bearer JWT ("userId" claim), or 0 when the
    // header is missing/invalid.  For handlers that need to attribute a
    // write (sent_by_user_id) after the requireBearer() gate has passed.
    static long long bearerUserId(const Request& request);

    // Role gate: validates the bearer token (same JWT check as
    // requireBearer) AND requires the caller's admins.admin_level_id
    // (via admin_levels.name) to be one of `allowedLevels`. Levels are
    // NOT hierarchical in the DB — 'club'/'super' vs 'marketing' are
    // separate rows — so call sites list every level that should pass,
    // e.g. {"club","super"} for People/Billing/RSVP-eligibility,
    // {"club","super","marketing"} for Communications/Recruitment.
    // A user with no admins row (plain coach/player) always fails.
    static bool requireAdminLevel(const Request& request,
                                   const std::vector<std::string>& allowedLevels);

    // Team-assignment ownership gate (Teams screen coach scoping).
    // Validates the bearer token (same JWT check as requireBearer) AND
    // requires EITHER:
    //   - the caller has an admins row with admin_level 'club' or 'super'
    //     (full club-admin bypass — matches requireAdminLevel's levels), OR
    //   - the caller is a coach (team_coaches) of `teamId` specifically.
    // Returns false for a bad/missing token OR a valid-but-unauthorized
    // caller — write endpoints (assign/reorder/roster-status) should treat
    // false as 403, since a 401 has already been ruled out by the
    // requireBearer() call every handler makes first.
    static bool canManageTeam(const Request& request, int teamId);
};