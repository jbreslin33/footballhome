#include "AdminLaBackfillController.h"

#include <chrono>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <sstream>
#include <vector>

#include "../database/Database.h"
#include "../models/PersonLinker.h"
#include "../services/LaProgramSync.h"
#include "../services/LeagueAppsService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

int envInt(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); } catch (const std::exception&) { return fallback; }
}

// Split "5039252,5039300" → {5039252, 5039300}.  Mirrors Node's
//   programs.split(',').map(parseInt).filter(Number.isFinite)
std::vector<int> parseProgramList(const std::string& s) {
    std::vector<int> out;
    size_t i = 0;
    while (i < s.size()) {
        size_t j = s.find(',', i);
        if (j == std::string::npos) j = s.size();
        std::string tok = s.substr(i, j - i);
        // trim
        size_t a = 0, b = tok.size();
        while (a < b && std::isspace(static_cast<unsigned char>(tok[a])))   ++a;
        while (b > a && std::isspace(static_cast<unsigned char>(tok[b-1]))) --b;
        const std::string t = tok.substr(a, b - a);
        if (!t.empty()) {
            try { out.push_back(std::stoi(t)); }
            catch (const std::exception&) { /* skip non-numeric, matches Number.isFinite filter */ }
        }
        i = j + 1;
    }
    return out;
}

// Mirrors the JS helper: "missing-name" or "dob-mismatch (...)".
// We classify a skip as a conflict iff its reason begins with "dob-mismatch".
bool isDobMismatch(const std::string& reason) {
    static const std::string prefix = "dob-mismatch";
    return reason.compare(0, prefix.size(), prefix) == 0;
}

bool isActiveRegistration(const json& rec) {
    if (!rec.contains("registrationStatus") || !rec["registrationStatus"].is_string()) return false;
    std::string s = rec["registrationStatus"].get<std::string>();
    for (auto& c : s) c = static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
    return s == "SPOT_RESERVED" || s == "SPOT_PENDING";
}

// Convert LA birthDate field (epoch ms OR ISO string) to YYYY-MM-DD for
// conflict logging.  Matches Node's `_laBirthDateIsoForLog`.
std::string laBirthDateIsoForLog(const json& rec) {
    if (!rec.contains("birthDate") || rec["birthDate"].is_null()) return {};
    const auto& v = rec["birthDate"];
    if (v.is_number()) {
        long long ms = static_cast<long long>(v.get<double>());
        std::time_t t = static_cast<std::time_t>(ms / 1000);
        std::tm tm{};
        if (gmtime_r(&t, &tm) == nullptr) return {};
        char buf[16];
        std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                      tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
        return buf;
    }
    if (v.is_string()) {
        std::string s = v.get<std::string>();
        return s.size() >= 10 ? s.substr(0, 10) : std::string{};
    }
    return {};
}

std::string jsonEscape(const std::string& s) { return json(s).dump(); }

// Minimal percent-decoder — the Router's getQueryParam returns the raw
// (still-encoded) value.  Only used by the debug probe endpoint.
std::string urlDecode(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (c == '+') { out.push_back(' '); continue; }
        if (c == '%' && i + 2 < s.size()) {
            auto hex = [](char h) -> int {
                if (h >= '0' && h <= '9') return h - '0';
                if (h >= 'a' && h <= 'f') return 10 + (h - 'a');
                if (h >= 'A' && h <= 'F') return 10 + (h - 'A');
                return -1;
            };
            int hi = hex(s[i+1]), lo = hex(s[i+2]);
            if (hi >= 0 && lo >= 0) {
                out.push_back(static_cast<char>((hi << 4) | lo));
                i += 2;
                continue;
            }
        }
        out.push_back(c);
    }
    return out;
}

Response internalErr(HttpStatus st, const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(st, body.str());
}

} // namespace

// Forward decls — these helpers are defined further down (near
// handleMembers/handleSyncMemberships) but the laGet(dynamic) resolver
// in registerRoutes calls them.  Signatures must match the definitions.
static std::string resolveVariant (const Request& request, const std::string& fallback);
static std::string resolveCategory(const Request& request);

AdminLaBackfillController::AdminLaBackfillController()
    : linker_(std::make_unique<PersonLinker>()),
      boysProgramId_ (envInt("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",  5039252)),
      girlsProgramId_(envInt("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID", 5039357)),
      mensProgramId_ (envInt("LEAGUEAPPS_MENS_PROGRAM_ID",       5039300)) {}

AdminLaBackfillController::~AdminLaBackfillController() = default;

void AdminLaBackfillController::registerRoutes(Router& router,
                                                 const std::string& prefix) {
    router.post(prefix + "/leagueapps-link/backfill", [this](const Request& req) {
        return this->handleBackfill(req);
    });
    router.get(prefix + "/la-probe", [this](const Request& req) {
        return this->handleProbe(req);
    });
    // GET /api/admin/members?variant=<active|paused>&category=<opt>
    // Reads person_la_memberships joined to leagueapps_programs — the
    // canonical Members-tile screen.  Registered through laGet(dynamic)
    // so every LA program matching the (variant, category) filter is
    // synced *before* the DB read, satisfying § Membership Data Flow.
    // The dynamic program resolver mirrors the same DB query the handler
    // uses to enumerate programs — keep them in sync if you change one.
    laGet(router, prefix + "/members",
          [](const Request& req) {
              std::vector<int> out;
              const std::string variant  = resolveVariant(req, "active");
              const std::string category = resolveCategory(req);
              try {
                  auto rows = Database::getInstance()->query(
                      "SELECT program_id FROM leagueapps_programs "
                      " WHERE ($1 = '' OR variant  = $1) "
                      "   AND ($2 = '' OR category = $2) "
                      " ORDER BY category, (variant <> 'active'), program_id",
                      { variant, category });
                  out.reserve(rows.size());
                  for (const auto& r : rows) {
                      if (!r["program_id"].is_null()) {
                          out.push_back(static_cast<int>(r["program_id"].as<long long>()));
                      }
                  }
              } catch (const std::exception& e) {
                  std::cerr << "[admin/members] program enumerate failed: "
                            << e.what() << std::endl;
              }
              return out;
          },
          [this](const Request& req, const LaSyncMap& sync) {
              return this->handleMembers(req, sync);
          });
    router.post(prefix + "/membership/sync", [this](const Request& req) {
        return this->handleSyncMemberships(req);
    });

    // GET /api/admin/people
    // One row per current Lighthouse person (open person_la_memberships).
    // Bundles the person graph Club Admin needs: account (users), player,
    // coach/admin roles, roster_assignments teams, RSVP eligibility, and
    // data-issue / duplicate signals.  DB-only — Membership sync is owned
    // by /api/admin/membership/sync + Members; this endpoint reads the
    // derived FH tables that hang off persons.
    router.get(prefix + "/people", [this](const Request& req) {
        return this->handlePeople(req);
    });
}

// TEMPORARY probe endpoint: GET /api/admin/la-probe?path=<la-path>
// Echoes the raw LA response (status + body) so we can sniff undocumented
// endpoints (transactions, payments, etc.) before wiring them into
// production models.  Remove after we've discovered the right shape.
Response AdminLaBackfillController::handleProbe(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    std::string path = urlDecode(request.getQueryParam("path"));
    if (path.empty()) {
        return internalErr(HttpStatus::BAD_REQUEST,
                           "Missing ?path=… (e.g. sites/41983/export/transactions)");
    }
    // Auto-substitute {site} placeholder for convenience.
    const std::string ph = "{site}";
    for (size_t p = path.find(ph); p != std::string::npos; p = path.find(ph, p)) {
        path.replace(p, ph.size(),
                     std::to_string(LeagueAppsService::getInstance().getSiteId()));
    }
    try {
        auto raw = LeagueAppsService::getInstance().rawGet(path);
        std::ostringstream body;
        body << "{"
             << "\"probedPath\":" << jsonEscape(path) << ","
             << "\"status\":" << raw.status << ","
             << "\"error\":"  << jsonEscape(raw.error) << ","
             << "\"body\":"   << jsonEscape(raw.body)
             << "}";
        Response r(HttpStatus::OK, body.str());
        r.setHeader("Content-Type", "application/json");
        return r;
    } catch (const std::exception& e) {
        return internalErr(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

Response AdminLaBackfillController::handleBackfill(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    const bool dryRun = (request.getQueryParam("dry") == "1");

    std::vector<int> programs;
    const std::string programsParam = request.getQueryParam("programs");
    if (!programsParam.empty()) {
        programs = parseProgramList(programsParam);
    }
    if (programs.empty()) {
        // Default source-of-truth is the leagueapps_programs registry
        // (migration 076).  Includes both active and paused sub-programs
        // for every category — paused registrations are still members and
        // must have their emails/phones ingested to suppress cold-email.
        // Fall back to the three legacy env-driven IDs only when the
        // registry is empty (fresh install).
        try {
            auto* db = Database::getInstance();
            auto rows = db->query(
                "SELECT program_id FROM leagueapps_programs "
                " ORDER BY category, variant");
            for (const auto& row : rows) {
                if (!row["program_id"].is_null()) {
                    programs.push_back(static_cast<int>(row["program_id"].as<long long>()));
                }
            }
        } catch (const std::exception& e) {
            std::cerr << "[la-backfill] leagueapps_programs read failed: "
                      << e.what() << " — falling back to env defaults." << std::endl;
        }
        if (programs.empty()) {
            programs = { boysProgramId_, girlsProgramId_, mensProgramId_ };
        }
    }

    try {
        // Per-program counters and bounded conflict/skipped samples — same
        // shape as the Node response (insertion order preserved by manual
        // JSON emission below).
        struct ProgramRow {
            int           programId;
            std::size_t   seen          = 0;
            std::size_t   alreadyLinked = 0;
            std::size_t   linkedExisting = 0;
            std::size_t   createdPerson = 0;
            std::size_t   skipped       = 0;
            std::size_t   conflicts     = 0;
        };
        std::vector<ProgramRow> progRows;
        progRows.reserve(programs.size());

        struct ConflictSample {
            std::string laUserId, name, laBirthDate, reason;
            int         conflictPersonId = 0;
        };
        struct SkippedSample {
            std::string laUserId, name, reason;
        };
        std::vector<ConflictSample> conflicts;
        std::vector<SkippedSample>  skippedSamples;
        const std::size_t SAMPLE_CAP = 20;

        std::size_t totalSeen      = 0;
        std::size_t totalAlready   = 0;
        std::size_t totalLinkedEx  = 0;
        std::size_t totalCreated   = 0;
        std::size_t totalSkipped   = 0;
        std::size_t totalConflicts = 0;

        auto& la = LeagueAppsService::getInstance();

        for (int pid : programs) {
            ProgramRow row;
            row.programId = pid;

            auto recs = la.fetchProgramRegistrations(pid);
            for (const auto& rec : recs) {
                if (!isActiveRegistration(rec)) continue;
                ++row.seen;
                ++totalSeen;

                auto result = linker_->linkLa(rec, dryRun);

                if (!result.skipReason.empty()) {
                    if (isDobMismatch(result.skipReason)) {
                        ++row.conflicts;
                        ++totalConflicts;
                        if (conflicts.size() < SAMPLE_CAP) {
                            ConflictSample c;
                            if (rec.contains("userId")) {
                                const auto& uv = rec["userId"];
                                if (uv.is_number())      c.laUserId = std::to_string(uv.get<long long>());
                                else if (uv.is_string()) c.laUserId = uv.get<std::string>();
                            }
                            const std::string fn = rec.value("firstName", std::string{});
                            const std::string ln = rec.value("lastName",  std::string{});
                            c.name             = fn + " " + ln;
                            c.laBirthDate      = laBirthDateIsoForLog(rec);
                            c.conflictPersonId = result.conflictPersonId;
                            c.reason           = result.skipReason;
                            conflicts.push_back(std::move(c));
                        }
                    } else {
                        ++row.skipped;
                        ++totalSkipped;
                        if (skippedSamples.size() < SAMPLE_CAP) {
                            SkippedSample s;
                            if (rec.contains("userId")) {
                                const auto& uv = rec["userId"];
                                if (uv.is_number())      s.laUserId = std::to_string(uv.get<long long>());
                                else if (uv.is_string()) s.laUserId = uv.get<std::string>();
                            }
                            const std::string fn = rec.value("firstName", std::string{});
                            const std::string ln = rec.value("lastName",  std::string{});
                            std::string nm = fn + " " + ln;
                            // trim
                            size_t a = 0, b = nm.size();
                            while (a < b && std::isspace(static_cast<unsigned char>(nm[a])))   ++a;
                            while (b > a && std::isspace(static_cast<unsigned char>(nm[b-1]))) --b;
                            s.name   = nm.substr(a, b - a);
                            s.reason = result.skipReason;
                            skippedSamples.push_back(std::move(s));
                        }
                    }
                } else if (dryRun && result.wouldCreatePerson) {
                    ++row.createdPerson;
                    ++totalCreated;
                } else if (dryRun && result.wouldCreateAlias) {
                    ++row.linkedExisting;
                    ++totalLinkedEx;
                } else if (result.created) {
                    ++row.createdPerson;
                    ++totalCreated;
                } else if (result.aliasCreated) {
                    ++row.linkedExisting;
                    ++totalLinkedEx;
                } else {
                    ++row.alreadyLinked;
                    ++totalAlready;
                }

                // Membership recording — runs on EVERY successful link (all
                // "already-linked", "linkedExisting", and "createdPerson"
                // buckets have result.personId set).  Records the person in
                // `person_la_memberships` for the current program (whether
                // active-variant or paused-variant sub-program), which is
                // how the club-admin "Paused Membership" viewer and the
                // roster/pool filters know who is currently paused.
                if (!dryRun && result.personId > 0) {
                    // Extract registrationId from the LA record so the
                    // membership row carries the correct join key back to
                    // person_payments (critical for youth, where the
                    // transaction's userId is the parent, not the child).
                    long long regId = 0;
                    if (rec.contains("registrationId") && !rec["registrationId"].is_null()) {
                        const auto& rv = rec["registrationId"];
                        if (rv.is_number_integer())       regId = rv.get<long long>();
                        else if (rv.is_number_unsigned()) regId = static_cast<long long>(rv.get<unsigned long long>());
                        else if (rv.is_number_float())    regId = static_cast<long long>(rv.get<double>());
                        else if (rv.is_string()) {
                            try { regId = std::stoll(rv.get<std::string>()); }
                            catch (...) { regId = 0; }
                        }
                    }
                    linker_->recordMembership(result.personId,
                                              static_cast<long long>(pid),
                                              regId);
                }
            }
            progRows.push_back(std::move(row));
        }

        // Emit JSON manually so key order matches Node's:
        // {dryRun, programs:[{programId, seen, results:{...}}], totals:{...},
        //  conflicts:[...], skipped:[...]}
        std::ostringstream out;
        out << "{";
        out << "\"dryRun\":" << (dryRun ? "true" : "false");
        out << ",\"programs\":[";
        for (size_t i = 0; i < progRows.size(); ++i) {
            const auto& r = progRows[i];
            if (i) out << ",";
            out << "{\"programId\":" << r.programId
                << ",\"seen\":"      << r.seen
                << ",\"results\":{"
                <<   "\"alreadyLinked\":"        << r.alreadyLinked
                << ",\"linkedExistingPerson\":"  << r.linkedExisting
                << ",\"createdPerson\":"         << r.createdPerson
                << ",\"skipped\":"               << r.skipped
                << ",\"conflicts\":"             << r.conflicts
                << "}}";
        }
        out << "],\"totals\":{"
            <<   "\"seen\":"                 << totalSeen
            << ",\"alreadyLinked\":"         << totalAlready
            << ",\"linkedExistingPerson\":"  << totalLinkedEx
            << ",\"createdPerson\":"         << totalCreated
            << ",\"skipped\":"               << totalSkipped
            << ",\"conflicts\":"             << totalConflicts
            << "}";
        out << ",\"conflicts\":[";
        for (size_t i = 0; i < conflicts.size(); ++i) {
            const auto& c = conflicts[i];
            if (i) out << ",";
            out << "{"
                <<   "\"laUserId\":"         << (c.laUserId.empty() ? "null" : c.laUserId)
                << ",\"name\":"              << jsonEscape(c.name)
                << ",\"laBirthDate\":"       << (c.laBirthDate.empty() ? "null" : jsonEscape(c.laBirthDate))
                << ",\"conflictPersonId\":"  << c.conflictPersonId
                << ",\"reason\":"            << jsonEscape(c.reason)
                << "}";
        }
        out << "],\"skipped\":[";
        for (size_t i = 0; i < skippedSamples.size(); ++i) {
            const auto& s = skippedSamples[i];
            if (i) out << ",";
            out << "{"
                <<   "\"laUserId\":" << (s.laUserId.empty() ? "null" : s.laUserId)
                << ",\"name\":"      << jsonEscape(s.name)
                << ",\"reason\":"    << jsonEscape(s.reason)
                << "}";
        }
        out << "]}";

        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "AdminLaBackfillController::handleBackfill error: "
                  << e.what() << std::endl;
        return internalErr(HttpStatus::BAD_GATEWAY, e.what());
    }
}


// ────────────────────────────────────────────────────────────────────────────
// GET /api/admin/members              — defaults to variant=active
// GET /api/admin/members?variant=active|paused    — explicit
//
// Returns every person currently on a sub-program of the requested variant,
// grouped by category (men / boys / girls / …).  Data source is the
// `person_la_memberships` junction table populated by PersonLinker; this
// endpoint never touches the LA API.
//
// Response shape:
//   {
//     "success": true,
//     "data": {
//       "variant": "active",
//       "groups": [
//         {
//           "category": "men",
//           "label": "Men",                 // or "Men Paused" when variant=paused
//           "program_id": 5039300,
//           "program_name": "Men's Club",
//           "members": [
//             { "person_id": 22248, "first_name": "Gabriel", ... }
//           ]
//         },
//         ...
//       ],
//       "total": 12
//     }
//   }
// ────────────────────────────────────────────────────────────────────────────
static Response respondMembers(const std::string& variant,
                                const std::string& category) {
    try {
        auto* db = Database::getInstance();

        // One flat query, ordered so we can group in a single pass.
        // Category label capitalisation: only "men", "boys", "girls" are
        // seeded today (matches memory notes 2026-07-01).  Any future
        // category (e.g. "women") is title-cased generically.
        //
        // $1 = variant ('active' | 'paused')
        // $2 = category ('men' | 'women' | 'boys' | 'girls' | '' for all).
        //     The `$2 = ''` short-circuit keeps the endpoint back-compat
        //     for callers that don't scope by category yet.
        auto rows = db->query(
            "WITH primary_email AS ( "
            // Prefer is_primary=true, else fall back to most-recent row.
            // The old `AND is_primary = true` join dropped 100% of the
            // rows in practice because LA-imported contacts leave the
            // flag unset — see admin/members smoke test 2026-07-03.
            "  SELECT DISTINCT ON (pem.person_id) pem.person_id, pem.email "
            "    FROM person_emails pem "
            "   ORDER BY pem.person_id, pem.is_primary DESC NULLS LAST, pem.created_at DESC NULLS LAST, pem.id DESC "
            "), primary_phone AS ( "
            "  SELECT DISTINCT ON (pph.person_id) "
            "         pph.person_id, pph.phone_number, pph.can_receive_sms, pph.can_receive_calls "
            "    FROM person_phones pph "
            "   ORDER BY pph.person_id, pph.is_primary DESC NULLS LAST, pph.created_at DESC NULLS LAST, pph.id DESC "
            "), pickup_membership AS ( "
            // (person, category) pairs that currently hold an open
            // pickup-variant LA membership.  Used to derive `has_pickup`
            // on every "active" row so the Members screen can flag
            // "active member NOT enrolled in pickup" — the manual
            // LA-console copy workflow the admin does by hand.
            "  SELECT DISTINCT plm2.person_id, lp2.category "
            "    FROM person_la_memberships plm2 "
            "    JOIN leagueapps_programs lp2 ON lp2.program_id = plm2.la_program_id "
            "   WHERE plm2.ended_at IS NULL AND lp2.variant = 'pickup' "
            "), active_membership AS ( "
            // Symmetric to pickup_membership: (person, category) pairs
            // that currently hold an open active-variant LA membership.
            // Used to derive `has_active` — shown on pickup-variant
            // cards so the admin can see at a glance whether a pickup
            // member is ALSO a full club member.
            "  SELECT DISTINCT plm3.person_id, lp3.category "
            "    FROM person_la_memberships plm3 "
            "    JOIN leagueapps_programs lp3 ON lp3.program_id = plm3.la_program_id "
            "   WHERE plm3.ended_at IS NULL AND lp3.variant = 'active' "
            ") "
            // Youth (boys/girls) rarely have their own contact info —
            // parent-managed LA imports put email/phone on the parent
            // persons row and hang the child off it via
            // parent_person_id.  Fall back to the parent when the child
            // has none, and flag it so the UI can label the contact as
            // via-parent.  See admin/members smoke test 2026-07-03:
            // 30 boys → 4 own email vs 26 parent email.
            "SELECT lp.category, lp.variant, lp.program_id, lp.program_name, "
            "       pe.id AS person_id, pe.first_name, pe.last_name, "
            "       TO_CHAR(pe.birth_date, 'YYYY-MM-DD') AS dob, "
            "       COALESCE(NULLIF(pem.email, ''), parent_pem.email, '') AS email, "
            "       (pem.email IS NULL OR pem.email = '') AND parent_pem.email IS NOT NULL AS email_via_parent, "
            "       COALESCE(NULLIF(pph.phone_number, ''), parent_pph.phone_number, '') AS phone, "
            "       (pph.phone_number IS NULL OR pph.phone_number = '') AND parent_pph.phone_number IS NOT NULL AS phone_via_parent, "
            "       CASE WHEN pph.phone_number IS NULL OR pph.phone_number = '' "
            "            THEN COALESCE(parent_pph.can_receive_sms, FALSE) "
            "            ELSE COALESCE(pph.can_receive_sms, FALSE) END AS phone_sms, "
            "       CASE WHEN pph.phone_number IS NULL OR pph.phone_number = '' "
            "            THEN COALESCE(parent_pph.can_receive_calls, FALSE) "
            "            ELSE COALESCE(pph.can_receive_calls, FALSE) END AS phone_call, "
            "       COALESCE(NULLIF(TRIM(CONCAT_WS(' ', parent.first_name, parent.last_name)), ''), '') AS parent_name, "
            "       pl.id AS player_id, "
            "       plm.joined_at, "
            // LA user_id lives on external_person_aliases (provider='leagueapps').
            // Needed by the RSVP-eligibility diagnostic screen to key into
            // player_rsvp_eligibility.  See memory footballhome.md 2026-07-11.
            "       epa.external_user_id AS leagueapps_user_id, "
            // Account + activity signals — powers the ⏰ dormancy chip
            // and inactivity sort on the Members screen.  A person has
            // AT MOST one row in `users` (users.person_id NOT NULL, 1:1),
            // so a scalar LEFT JOIN is safe.  `last_seen_at` is bumped
            // by Controller::requireBearer on every authenticated
            // request (see migration 114).  NULL === never logged in
            // OR pre-migration silence — the frontend renders '🚫 Never'
            // in either case.
            "       (u.id IS NOT NULL)              AS has_fh_account, "
            "       CASE WHEN u.last_seen_at IS NULL THEN NULL "
            "            ELSE GREATEST(0, "
            "                 EXTRACT(EPOCH FROM (NOW() - u.last_seen_at))::bigint / 86400) "
            "       END AS days_since_activity, "
            // has_pickup: does this person hold an OPEN pickup-variant
            // membership in the same category as the current row?  On
            // active-variant rows this powers the "missing pickup"
            // flag on the Members screen.  On pickup-variant rows it's
            // trivially true (self-match) — frontend ignores the field
            // outside the active tab.
            "       (pkm.person_id IS NOT NULL) AS has_pickup, "
            // has_active: symmetric — powers the "in club too" chip
            // on pickup-variant cards.
            "       (acm.person_id IS NOT NULL) AS has_active "
            "  FROM person_la_memberships plm "
            "  JOIN leagueapps_programs lp     ON lp.program_id = plm.la_program_id "
            "  JOIN persons pe                 ON pe.id         = plm.person_id "
            "  LEFT JOIN persons parent        ON parent.id     = pe.parent_person_id "
            "  LEFT JOIN players pl            ON pl.person_id  = pe.id "
            "  LEFT JOIN primary_email pem     ON pem.person_id = pe.id "
            "  LEFT JOIN primary_phone pph     ON pph.person_id = pe.id "
            "  LEFT JOIN primary_email parent_pem ON parent_pem.person_id = pe.parent_person_id "
            "  LEFT JOIN primary_phone parent_pph ON parent_pph.person_id = pe.parent_person_id "
            "  LEFT JOIN external_person_aliases epa "
            "         ON epa.person_id = pe.id "
            "        AND epa.provider  = 'leagueapps' "
            "        AND epa.external_user_id IS NOT NULL "
            "        AND epa.external_user_id <> '' "
            "  LEFT JOIN users u               ON u.person_id   = pe.id "
            "  LEFT JOIN pickup_membership pkm ON pkm.person_id = pe.id AND pkm.category = lp.category "
            "  LEFT JOIN active_membership acm ON acm.person_id = pe.id AND acm.category = lp.category "
            " WHERE plm.ended_at IS NULL "
            "   AND ($1 = '' OR lp.variant  = $1) "
            "   AND ($2 = '' OR lp.category = $2) "
            // Sort: active variants first within a category (so "Mens
            // Club" comes before "Mens Pickup Club" in the chip row),
            // then by program_id for stable ordering.
            " ORDER BY lp.category, (lp.variant <> 'active'), lp.program_id, pe.last_name, pe.first_name",
            { variant, category });

        // Group by (category, program_id) — one group per sub-program.
        std::ostringstream out;
        out << "{\"success\":true,\"data\":{"
            << "\"variant\":" << jsonEscape(variant) << ","
            << "\"category\":" << jsonEscape(category) << ","
            << "\"groups\":[";

        long long   curProgramId = -1;
        bool firstGroup     = true;
        bool firstInGroup   = true;
        std::size_t total   = 0;

        auto closeGroup = [&](std::ostringstream& o) {
            if (curProgramId < 0) return;
            o << "]}";
        };

        // "men" → "Mens Club Members", "boys" → "Boys Club Members", etc.
        // When the row's variant is `pickup` we swap in "Pickup Members"
        // so the frontend can show a flat chip row (one per sub-program)
        // alongside per-category aggregate chips ("All Men", "All Boys").
        // The label is derived from the row's own variant — NOT the
        // request-level variant — because the endpoint also serves
        // `variant=all`, which mixes both variants in one response.
        // Special-case "men" → "Mens" and "women" → "Womens" so we
        // don't emit "Men Club Members" / "Women Club Members"
        // (grammatically awkward).
        auto categoryLabel = [&](const std::string& cat, const std::string& rowVariant) -> std::string {
            std::string noun = cat;
            if      (cat == "men")   noun = "Mens";
            else if (cat == "women") noun = "Womens";
            else if (!noun.empty())  noun[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(noun[0])));
            const std::string suffix = (rowVariant == "pickup") ? " Pickup Members" : " Club Members";
            return noun + suffix;
        };

        for (const auto& row : rows) {
            const std::string category     = row["category"].is_null()     ? "" : row["category"].c_str();
            const std::string rowVariant   = row["variant"].is_null()      ? "" : row["variant"].c_str();
            const long long   programId    = row["program_id"].as<long long>();
            const std::string programName  = row["program_name"].is_null() ? "" : row["program_name"].c_str();

            if (programId != curProgramId) {
                if (curProgramId >= 0) {
                    closeGroup(out);
                }
                if (!firstGroup) out << ",";
                firstGroup = false;
                out << "{"
                    <<   "\"category\":"     << jsonEscape(category)
                    << ",\"variant\":"       << jsonEscape(rowVariant)
                    << ",\"label\":"         << jsonEscape(categoryLabel(category, rowVariant))
                    << ",\"program_id\":"    << programId
                    << ",\"program_name\":"  << jsonEscape(programName)
                    << ",\"members\":[";
                curProgramId    = programId;
                firstInGroup    = true;
            }

            if (!firstInGroup) out << ",";
            firstInGroup = false;
            ++total;

            const std::string firstName = row["first_name"].is_null() ? "" : row["first_name"].c_str();
            const std::string lastName  = row["last_name"].is_null()  ? "" : row["last_name"].c_str();
            const std::string dob       = row["dob"].is_null()        ? "" : row["dob"].c_str();
            const std::string email     = row["email"].c_str();
            const std::string phone     = row["phone"].c_str();
            const bool        phoneSms  = !row["phone_sms"].is_null()  && row["phone_sms"].as<bool>();
            const bool        phoneCall = !row["phone_call"].is_null() && row["phone_call"].as<bool>();
            const bool        emailViaParent = !row["email_via_parent"].is_null() && row["email_via_parent"].as<bool>();
            const bool        phoneViaParent = !row["phone_via_parent"].is_null() && row["phone_via_parent"].as<bool>();
            const std::string parentName = row["parent_name"].is_null() ? "" : row["parent_name"].c_str();
            const std::string joinedAt  = row["joined_at"].is_null() ? "" : row["joined_at"].c_str();
            const std::string laUserId  = row["leagueapps_user_id"].is_null() ? "" : row["leagueapps_user_id"].c_str();
            const bool        hasAccount  = !row["has_fh_account"].is_null() && row["has_fh_account"].as<bool>();
            const bool        hasPickup   = !row["has_pickup"].is_null()     && row["has_pickup"].as<bool>();
            const bool        hasActive   = !row["has_active"].is_null()     && row["has_active"].as<bool>();
            // `days_since_activity` is NULL when the user has never made
            // an authenticated request (or has no FH account at all).
            // We surface it as JSON `null` so the frontend can render a
            // dedicated "Never" pill instead of guessing from the number.
            const std::string daysStr =
                row["days_since_activity"].is_null()
                    ? std::string("null")
                    : std::to_string(row["days_since_activity"].as<long long>());

            out << "{"
                <<   "\"person_id\":"        << row["person_id"].as<int>()
                << ",\"first_name\":"        << jsonEscape(firstName)
                << ",\"last_name\":"         << jsonEscape(lastName)
                << ",\"dob\":"               << jsonEscape(dob)
                << ",\"email\":"             << jsonEscape(email)
                << ",\"email_via_parent\":"  << (emailViaParent ? "true" : "false")
                << ",\"phone\":"             << jsonEscape(phone)
                << ",\"phone_sms\":"         << (phoneSms  ? "true" : "false")
                << ",\"phone_call\":"        << (phoneCall ? "true" : "false")
                << ",\"phone_via_parent\":"  << (phoneViaParent ? "true" : "false")
                << ",\"parent_name\":"       << jsonEscape(parentName)
                << ",\"player_id\":"         << (row["player_id"].is_null() ? "null" : std::to_string(row["player_id"].as<int>()))
                << ",\"joined_at\":"         << jsonEscape(joinedAt)
                << ",\"leagueapps_user_id\":" << (laUserId.empty() ? std::string("null") : jsonEscape(laUserId))
                << ",\"has_fh_account\":"    << (hasAccount ? "true" : "false")
                << ",\"has_pickup\":"        << (hasPickup ? "true" : "false")
                << ",\"has_active\":"        << (hasActive ? "true" : "false")
                << ",\"days_since_activity\":" << daysStr
                << "}";
        }
        closeGroup(out);

        out << "],\"total\":" << total << "}}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "AdminLaBackfillController::respondMembers error: "
                  << e.what() << std::endl;
        return internalErr(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// Pick the requested variant: prefer explicit `?variant=` query param,
// otherwise fall back to the endpoint's built-in default.  Rejects
// unknown values to avoid arbitrary SQL parameter injection at the
// value-level (query params flow into a $1 placeholder so it's safe,
// but a bad value would return zero rows and mask a client typo).
//
// Accepted values:
//   "active" | "pickup" | "paused" (legacy alias for "pickup")
//     → filters lp.variant equal to that value.
//   "all" | ""  → no variant filter (returns groups from every
//     sub-program — the Members screen's flat club-chip layout).
// Returns the empty string for "all" so downstream SQL callers can
// pass it straight into the `($1 = '' OR lp.variant = $1)` predicate.
static std::string resolveVariant(const Request& request,
                                   const std::string& defaultVariant) {
    std::string v = request.getQueryParam("variant");
    if (v.empty()) v = defaultVariant;
    // Legacy alias: some older callers still send "paused", which was
    // the DB label before it was renamed to "pickup".  Map first so
    // the allowlist check below sees a canonical value.
    if (v == "paused") v = "pickup";
    if (v == "all") return "";
    if (v != "active" && v != "pickup") {
        // Fall back to the endpoint's default (also normalising it).
        v = (defaultVariant == "paused") ? "pickup" : defaultVariant;
        if (v == "all") return "";
    }
    return v;
}

// Optional `?category=` query param — narrows the enumeration to a
// single LA category.  Empty string = "all categories".  Values outside
// the allowlist collapse to empty so a client typo never returns zero
// rows silently.
static std::string resolveCategory(const Request& request) {
    std::string c = request.getQueryParam("category");
    if (c.empty()) return "";
    // Lowercase for case-insensitive compare.
    for (auto& ch : c) ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
    if (c == "men" || c == "women" || c == "boys" || c == "girls") return c;
    return "";
}

Response AdminLaBackfillController::handleMembers(const Request& request, const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laGet(); handler reads DB only.
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    return respondMembers(resolveVariant(request, "active"), resolveCategory(request));
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/admin/people
//
// Club Admin People Directory — one row per current Lighthouse person.
// A person is in scope iff they have an open person_la_memberships row
// (ended_at IS NULL).  Scraped league/opponent-only people are intentionally
// excluded; System Admin owns those until they are linked into LA membership.
//
// Optional filters (applied server-side so lens tiles stay cheap):
//   ?view=directory|accounts|players|staff|duplicates|data-issues
//   ?category=men|women|boys|girls
//   ?q=<search substring against name/email/phone>
//
// Response:
//   { success, data: { view, total, people: [ { person_id, … } ] } }
// ────────────────────────────────────────────────────────────────────────────
Response AdminLaBackfillController::handlePeople(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    std::string view = request.getQueryParam("view");
    for (auto& ch : view) ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));
    if (view.empty()) view = "directory";
    if (view != "directory" && view != "accounts" && view != "players" &&
        view != "staff" && view != "duplicates" && view != "data-issues") {
        view = "directory";
    }

    const std::string category = resolveCategory(request);
    std::string q = request.getQueryParam("q");
    // Bound search length; lowercased for ILIKE.
    if (q.size() > 80) q = q.substr(0, 80);
    for (auto& ch : q) ch = static_cast<char>(std::tolower(static_cast<unsigned char>(ch)));

    try {
        auto* db = Database::getInstance();

        // One flat query: Lighthouse persons + derived graph columns.
        // Roster / RSVP hang off leagueapps_user_id via external_person_aliases.
        // Staff roles hang off users → admins / coaches.person_id.
        auto rows = db->query(
            "WITH lighthouse AS ( "
            "  SELECT DISTINCT plm.person_id "
            "    FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "   WHERE plm.ended_at IS NULL "
            "     AND ($1 = '' OR lp.category = $1) "
            "), primary_email AS ( "
            "  SELECT DISTINCT ON (pem.person_id) pem.person_id, pem.email "
            "    FROM person_emails pem "
            "   ORDER BY pem.person_id, pem.is_primary DESC NULLS LAST, "
            "            pem.created_at DESC NULLS LAST, pem.id DESC "
            "), primary_phone AS ( "
            "  SELECT DISTINCT ON (pph.person_id) pph.person_id, pph.phone_number "
            "    FROM person_phones pph "
            "   ORDER BY pph.person_id, pph.is_primary DESC NULLS LAST, "
            "            pph.created_at DESC NULLS LAST, pph.id DESC "
            "), membership_summary AS ( "
            "  SELECT plm.person_id, "
            "         string_agg(DISTINCT lp.category, ',' ORDER BY lp.category) AS categories, "
            "         string_agg(DISTINCT lp.variant,  ',' ORDER BY lp.variant)  AS variants, "
            "         bool_or(lp.variant = 'active') AS has_active, "
            "         bool_or(lp.variant = 'pickup') AS has_pickup "
            "    FROM person_la_memberships plm "
            "    JOIN leagueapps_programs lp ON lp.program_id = plm.la_program_id "
            "   WHERE plm.ended_at IS NULL "
            "   GROUP BY plm.person_id "
            "), roster_summary AS ( "
            "  SELECT epa.person_id, "
            "         count(*)::int AS roster_count, "
            "         string_agg(t.name, ', ' ORDER BY t.name) AS roster_teams "
            "    FROM roster_assignments ra "
            "    JOIN external_person_aliases epa "
            "      ON epa.provider = 'leagueapps' "
            "     AND epa.external_user_id = ra.leagueapps_user_id::text "
            "    JOIN teams t ON t.id = ra.team_id "
            "   WHERE ra.removed_at IS NULL "
            "   GROUP BY epa.person_id "
            "), rsvp_summary AS ( "
            "  SELECT epa.person_id, "
            "         count(*)::int AS rsvp_count, "
            "         string_agg(t.name, ', ' ORDER BY t.name) AS rsvp_teams "
            "    FROM player_rsvp_eligibility pre "
            "    JOIN external_person_aliases epa "
            "      ON epa.provider = 'leagueapps' "
            "     AND epa.external_user_id = pre.leagueapps_user_id::text "
            "    JOIN teams t ON t.id = pre.team_id "
            "   GROUP BY epa.person_id "
            "), coach_flag AS ( "
            "  SELECT DISTINCT c.person_id "
            "    FROM coaches c "
            "    JOIN lighthouse lh ON lh.person_id = c.person_id "
            "), club_admin_flag AS ( "
            "  SELECT DISTINCT u.person_id "
            "    FROM club_admins ca "
            "    JOIN admins a ON a.id = ca.admin_id "
            "    JOIN users u ON u.id = a.user_id "
            "    JOIN lighthouse lh ON lh.person_id = u.person_id "
            "   WHERE ca.ended_at IS NULL "
            "), team_admin_flag AS ( "
            "  SELECT DISTINCT u.person_id "
            "    FROM team_admins ta "
            "    JOIN admins a ON a.id = ta.admin_id "
            "    JOIN users u ON u.id = a.user_id "
            "    JOIN lighthouse lh ON lh.person_id = u.person_id "
            "   WHERE ta.ended_at IS NULL "
            "), email_dupes AS ( "
            "  SELECT lower(pem.email) AS email_key "
            "    FROM person_emails pem "
            "    JOIN lighthouse lh ON lh.person_id = pem.person_id "
            "   WHERE pem.email IS NOT NULL AND pem.email <> '' "
            "   GROUP BY lower(pem.email) "
            "  HAVING count(DISTINCT pem.person_id) > 1 "
            "), name_dupes AS ( "
            "  SELECT lower(pe.first_name) AS fn, lower(pe.last_name) AS ln, "
            "         pe.birth_date AS dob "
            "    FROM persons pe "
            "    JOIN lighthouse lh ON lh.person_id = pe.id "
            "   WHERE pe.first_name IS NOT NULL AND pe.last_name IS NOT NULL "
            "     AND pe.birth_date IS NOT NULL "
            "   GROUP BY lower(pe.first_name), lower(pe.last_name), pe.birth_date "
            "  HAVING count(*) > 1 "
            "), merge_touch AS ( "
            "  SELECT DISTINCT x.person_id "
            "    FROM ( "
            "      SELECT kept_person_id AS person_id FROM person_merges "
            "       WHERE reversed_at IS NULL "
            "      UNION ALL "
            "      SELECT dropped_person_id FROM person_merges "
            "       WHERE reversed_at IS NULL "
            "    ) x "
            "    JOIN lighthouse lh ON lh.person_id = x.person_id "
            ") "
            "SELECT pe.id AS person_id, pe.first_name, pe.last_name, "
            "       TO_CHAR(pe.birth_date, 'YYYY-MM-DD') AS dob, "
            "       COALESCE(pem.email, '') AS email, "
            "       COALESCE(pph.phone_number, '') AS phone, "
            "       epa.external_user_id AS leagueapps_user_id, "
            "       u.id AS user_id, "
            "       (u.id IS NOT NULL) AS has_fh_account, "
            "       COALESCE(u.is_active, FALSE) AS account_active, "
            "       CASE WHEN u.last_seen_at IS NULL THEN NULL "
            "            ELSE GREATEST(0, "
            "                 EXTRACT(EPOCH FROM (NOW() - u.last_seen_at))::bigint / 86400) "
            "       END AS days_since_activity, "
            "       pl.id AS player_id, "
            "       (cf.person_id IS NOT NULL) AS is_coach, "
            "       (caf.person_id IS NOT NULL) AS is_club_admin, "
            "       (taf.person_id IS NOT NULL) AS is_team_admin, "
            "       COALESCE(ms.categories, '') AS membership_categories, "
            "       COALESCE(ms.variants, '') AS membership_variants, "
            "       COALESCE(ms.has_active, FALSE) AS has_active, "
            "       COALESCE(ms.has_pickup, FALSE) AS has_pickup, "
            "       COALESCE(rs.roster_count, 0) AS roster_count, "
            "       COALESCE(rs.roster_teams, '') AS roster_teams, "
            "       COALESCE(vs.rsvp_count, 0) AS rsvp_count, "
            "       COALESCE(vs.rsvp_teams, '') AS rsvp_teams, "
            "       (ed.email_key IS NOT NULL) AS email_duplicate, "
            "       (nd.fn IS NOT NULL) AS name_dob_duplicate, "
            "       (mt.person_id IS NOT NULL) AS has_merge_history "
            "  FROM lighthouse lh "
            "  JOIN persons pe ON pe.id = lh.person_id "
            "  LEFT JOIN primary_email pem ON pem.person_id = pe.id "
            "  LEFT JOIN primary_phone pph ON pph.person_id = pe.id "
            "  LEFT JOIN external_person_aliases epa "
            "         ON epa.person_id = pe.id "
            "        AND epa.provider = 'leagueapps' "
            "        AND epa.external_user_id IS NOT NULL "
            "        AND epa.external_user_id <> '' "
            "  LEFT JOIN users u ON u.person_id = pe.id "
            "  LEFT JOIN players pl ON pl.person_id = pe.id "
            "  LEFT JOIN membership_summary ms ON ms.person_id = pe.id "
            "  LEFT JOIN roster_summary rs ON rs.person_id = pe.id "
            "  LEFT JOIN rsvp_summary vs ON vs.person_id = pe.id "
            "  LEFT JOIN coach_flag cf ON cf.person_id = pe.id "
            "  LEFT JOIN club_admin_flag caf ON caf.person_id = pe.id "
            "  LEFT JOIN team_admin_flag taf ON taf.person_id = pe.id "
            "  LEFT JOIN email_dupes ed ON ed.email_key = lower(pem.email) "
            "  LEFT JOIN name_dupes nd "
            "         ON nd.fn = lower(pe.first_name) "
            "        AND nd.ln = lower(pe.last_name) "
            "        AND nd.dob IS NOT DISTINCT FROM pe.birth_date "
            "  LEFT JOIN merge_touch mt ON mt.person_id = pe.id "
            " WHERE ($2 = '' OR "
            "        lower(pe.first_name) LIKE '%' || $2 || '%' OR "
            "        lower(pe.last_name)  LIKE '%' || $2 || '%' OR "
            "        lower(COALESCE(pem.email, '')) LIKE '%' || $2 || '%' OR "
            "        COALESCE(pph.phone_number, '') LIKE '%' || $2 || '%') "
            " ORDER BY pe.last_name, pe.first_name",
            { category, q });

        std::ostringstream out;
        out << "{\"success\":true,\"data\":{"
            << "\"view\":" << jsonEscape(view) << ","
            << "\"category\":" << jsonEscape(category) << ","
            << "\"people\":[";

        bool first = true;
        std::size_t total = 0;
        std::size_t accounts = 0, players = 0, staff = 0, duplicates = 0, issues = 0;

        for (const auto& row : rows) {
            const bool hasAccount = !row["has_fh_account"].is_null() && row["has_fh_account"].as<bool>();
            const bool hasPlayer  = !row["player_id"].is_null();
            const bool isCoach    = !row["is_coach"].is_null() && row["is_coach"].as<bool>();
            const bool isClubAdm  = !row["is_club_admin"].is_null() && row["is_club_admin"].as<bool>();
            const bool isTeamAdm  = !row["is_team_admin"].is_null() && row["is_team_admin"].as<bool>();
            const bool isStaff    = isCoach || isClubAdm || isTeamAdm;
            const bool emailDup   = !row["email_duplicate"].is_null() && row["email_duplicate"].as<bool>();
            const bool nameDup    = !row["name_dob_duplicate"].is_null() && row["name_dob_duplicate"].as<bool>();
            const bool mergeHist  = !row["has_merge_history"].is_null() && row["has_merge_history"].as<bool>();
            const bool isDup      = emailDup || nameDup || mergeHist;

            const std::string email = row["email"].c_str();
            const std::string phone = row["phone"].c_str();
            const std::string laUid = row["leagueapps_user_id"].is_null()
                ? "" : row["leagueapps_user_id"].c_str();
            const int rosterCount = row["roster_count"].as<int>();
            const int rsvpCount   = row["rsvp_count"].as<int>();

            // Data-issue signals — missing contact/links that block clean
            // Club Admin workflows (onboarding, roster, RSVP).
            std::vector<std::string> issueList;
            if (email.empty()) issueList.push_back("missing_email");
            if (phone.empty()) issueList.push_back("missing_phone");
            if (laUid.empty()) issueList.push_back("missing_la_alias");
            if (!hasAccount) issueList.push_back("no_fh_account");
            if (!hasPlayer) issueList.push_back("no_player");
            if (!laUid.empty() && rosterCount == 0) issueList.push_back("no_roster");
            if (!laUid.empty() && rosterCount > 0 && rsvpCount == 0) {
                issueList.push_back("no_rsvp");
            }
            const bool hasIssues = !issueList.empty();

            if (hasAccount) ++accounts;
            if (hasPlayer)  ++players;
            if (isStaff)    ++staff;
            if (isDup)      ++duplicates;
            if (hasIssues)  ++issues;

            // Lens filter — keep totals for all rows above, then decide
            // whether this row belongs in the requested view.
            bool include = true;
            if (view == "accounts") include = hasAccount;
            else if (view == "players") include = hasPlayer;
            else if (view == "staff") include = isStaff;
            else if (view == "duplicates") include = isDup;
            else if (view == "data-issues") include = hasIssues;
            if (!include) continue;

            if (!first) out << ",";
            first = false;
            ++total;

            const std::string firstName = row["first_name"].is_null() ? "" : row["first_name"].c_str();
            const std::string lastName  = row["last_name"].is_null()  ? "" : row["last_name"].c_str();
            const std::string dob       = row["dob"].is_null()        ? "" : row["dob"].c_str();
            const std::string daysStr   = row["days_since_activity"].is_null()
                ? std::string("null")
                : std::to_string(row["days_since_activity"].as<long long>());
            const bool accountActive = !row["account_active"].is_null() && row["account_active"].as<bool>();
            const bool hasActive     = !row["has_active"].is_null() && row["has_active"].as<bool>();
            const bool hasPickup     = !row["has_pickup"].is_null() && row["has_pickup"].as<bool>();

            out << "{"
                <<   "\"person_id\":" << row["person_id"].as<int>()
                << ",\"first_name\":" << jsonEscape(firstName)
                << ",\"last_name\":"  << jsonEscape(lastName)
                << ",\"dob\":"        << jsonEscape(dob)
                << ",\"email\":"      << jsonEscape(email)
                << ",\"phone\":"      << jsonEscape(phone)
                << ",\"leagueapps_user_id\":" << (laUid.empty() ? std::string("null") : jsonEscape(laUid))
                << ",\"user_id\":" << (row["user_id"].is_null()
                    ? "null" : std::to_string(row["user_id"].as<int>()))
                << ",\"has_fh_account\":" << (hasAccount ? "true" : "false")
                << ",\"account_active\":" << (accountActive ? "true" : "false")
                << ",\"days_since_activity\":" << daysStr
                << ",\"player_id\":" << (row["player_id"].is_null()
                    ? "null" : std::to_string(row["player_id"].as<int>()))
                << ",\"is_coach\":" << (isCoach ? "true" : "false")
                << ",\"is_club_admin\":" << (isClubAdm ? "true" : "false")
                << ",\"is_team_admin\":" << (isTeamAdm ? "true" : "false")
                << ",\"membership_categories\":" << jsonEscape(row["membership_categories"].c_str())
                << ",\"membership_variants\":" << jsonEscape(row["membership_variants"].c_str())
                << ",\"has_active\":" << (hasActive ? "true" : "false")
                << ",\"has_pickup\":" << (hasPickup ? "true" : "false")
                << ",\"roster_count\":" << rosterCount
                << ",\"roster_teams\":" << jsonEscape(row["roster_teams"].c_str())
                << ",\"rsvp_count\":" << rsvpCount
                << ",\"rsvp_teams\":" << jsonEscape(row["rsvp_teams"].c_str())
                << ",\"email_duplicate\":" << (emailDup ? "true" : "false")
                << ",\"name_dob_duplicate\":" << (nameDup ? "true" : "false")
                << ",\"has_merge_history\":" << (mergeHist ? "true" : "false")
                << ",\"issues\":[";
            for (std::size_t i = 0; i < issueList.size(); ++i) {
                if (i) out << ",";
                out << jsonEscape(issueList[i]);
            }
            out << "]}";
        }

        out << "],\"total\":" << total
            << ",\"counts\":{"
            <<   "\"accounts\":" << accounts
            <<  ",\"players\":" << players
            <<  ",\"staff\":" << staff
            <<  ",\"duplicates\":" << duplicates
            <<  ",\"data_issues\":" << issues
            << "}}}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "AdminLaBackfillController::handlePeople error: "
                  << e.what() << std::endl;
        return internalErr(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/admin/membership/sync?variant=<active|paused>&category=<opt>
//
// The "click a Membership tile" refresh hook.  For every LA program in
// `leagueapps_programs` matching the (variant, category) filter, run
// LaProgramSync — which fetches the current LA registrations, upserts
// persons + external_person_aliases + emails + phones + person_la_memberships,
// and sets ended_at on rows LA has dropped.  Per-program failures are
// captured, not fatal; the response reports them so the client can
// show an amber "some programs failed" strip.
//
// After this returns, `GET /api/admin/members?...` reflects the fresh
// snapshot with zero additional LA traffic.
// ────────────────────────────────────────────────────────────────────────────
Response AdminLaBackfillController::handleSyncMemberships(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    const std::string variant  = resolveVariant(request, "active");
    const std::string category = resolveCategory(request);

    struct ProgramRow {
        long long   programId;
        std::string programName;
        std::string category;
        std::string variant;
    };
    std::vector<ProgramRow> programs;

    try {
        auto* db = Database::getInstance();
        auto rows = db->query(
            "SELECT program_id, program_name, category, variant "
            "  FROM leagueapps_programs "
            " WHERE ($1 = '' OR variant  = $1) "
            "   AND ($2 = '' OR category = $2) "
            " ORDER BY category, (variant <> 'active'), program_id",
            { variant, category });
        for (const auto& r : rows) {
            ProgramRow pr;
            pr.programId   = r["program_id"].as<long long>();
            pr.programName = r["program_name"].is_null() ? "" : r["program_name"].c_str();
            pr.category    = r["category"].is_null()     ? "" : r["category"].c_str();
            pr.variant     = r["variant"].is_null()      ? "" : r["variant"].c_str();
            programs.push_back(std::move(pr));
        }
    } catch (const std::exception& e) {
        std::cerr << "AdminLaBackfillController::handleSyncMemberships enumerate error: "
                  << e.what() << std::endl;
        return internalErr(HttpStatus::INTERNAL_SERVER_ERROR,
                           std::string("Failed to enumerate programs: ") + e.what());
    }

    const auto startAll = std::chrono::steady_clock::now();

    struct SyncOut {
        long long   programId;
        std::string programName;
        std::string category;
        std::string variant;
        bool        ok = false;
        std::size_t recordCount = 0;
        long long   elapsedMs = 0;
        std::string error;
    };
    std::vector<SyncOut> results;
    results.reserve(programs.size());

    int programsOk = 0;
    int programsFailed = 0;
    std::size_t totalRecords = 0;

    for (const auto& p : programs) {
        SyncOut o;
        o.programId   = p.programId;
        o.programName = p.programName;
        o.category    = p.category;
        o.variant     = p.variant;

        const auto t0 = std::chrono::steady_clock::now();
        try {
            LaProgramSync sync;
            auto res = sync.run(static_cast<int>(p.programId));
            o.ok = true;
            o.recordCount = res.recs.size();
            totalRecords += o.recordCount;
            ++programsOk;
        } catch (const std::exception& e) {
            o.ok = false;
            o.error = e.what();
            ++programsFailed;
            std::cerr << "[membership/sync program=" << p.programId
                      << "] LaProgramSync failed: " << e.what() << std::endl;
        }
        const auto t1 = std::chrono::steady_clock::now();
        o.elapsedMs = std::chrono::duration_cast<std::chrono::milliseconds>(t1 - t0).count();
        results.push_back(std::move(o));
    }

    const auto endAll   = std::chrono::steady_clock::now();
    const long long elapsedMs =
        std::chrono::duration_cast<std::chrono::milliseconds>(endAll - startAll).count();
    const long long syncedAtMs =
        std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()).count();

    std::ostringstream out;
    out << "{\"success\":true,\"data\":{"
        << "\"variant\":"  << jsonEscape(variant) << ","
        << "\"category\":" << jsonEscape(category) << ","
        << "\"programs\":[";
    for (std::size_t i = 0; i < results.size(); ++i) {
        const auto& o = results[i];
        if (i) out << ",";
        out << "{"
            << "\"programId\":"    << o.programId
            << ",\"programName\":" << jsonEscape(o.programName)
            << ",\"category\":"    << jsonEscape(o.category)
            << ",\"variant\":"     << jsonEscape(o.variant)
            << ",\"ok\":"          << (o.ok ? "true" : "false")
            << ",\"recordCount\":" << o.recordCount
            << ",\"elapsedMs\":"   << o.elapsedMs
            << ",\"error\":"       << jsonEscape(o.error)
            << "}";
    }
    out << "],"
        << "\"programsOk\":"     << programsOk << ","
        << "\"programsFailed\":" << programsFailed << ","
        << "\"totalRecords\":"   << totalRecords << ","
        << "\"elapsedMs\":"      << elapsedMs << ","
        << "\"syncedAtMs\":"     << syncedAtMs
        << "}}";

    Response r(HttpStatus::OK, out.str());
    r.setHeader("Content-Type", "application/json");
    return r;
}
