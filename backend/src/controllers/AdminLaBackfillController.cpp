#include "AdminLaBackfillController.h"

#include <cstdlib>
#include <ctime>
#include <iostream>
#include <sstream>
#include <vector>

#include "../database/Database.h"
#include "../models/PersonLinker.h"
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
    router.get(prefix + "/paused-members", [this](const Request& req) {
        return this->handlePausedMembers(req);
    });
    router.get(prefix + "/members", [this](const Request& req) {
        return this->handleMembers(req);
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
// GET /api/admin/paused-members       — defaults to variant=paused
// GET /api/admin/members              — defaults to variant=active
// GET /api/admin/{paused-,}members?variant=active|paused    — explicit
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
static Response respondMembers(const std::string& variant) {
    try {
        auto* db = Database::getInstance();

        // One flat query, ordered so we can group in a single pass.
        // Category label capitalisation: only "men", "boys", "girls" are
        // seeded today (matches memory notes 2026-07-01).  Any future
        // category (e.g. "women") is title-cased generically.
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
            ") "
            // Youth (boys/girls) rarely have their own contact info —
            // parent-managed LA imports put email/phone on the parent
            // persons row and hang the child off it via
            // parent_person_id.  Fall back to the parent when the child
            // has none, and flag it so the UI can label the contact as
            // via-parent.  See admin/members smoke test 2026-07-03:
            // 30 boys → 4 own email vs 26 parent email.
            "SELECT lp.category, lp.program_id, lp.program_name, "
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
            "       plm.joined_at "
            "  FROM person_la_memberships plm "
            "  JOIN leagueapps_programs lp     ON lp.program_id = plm.la_program_id "
            "  JOIN persons pe                 ON pe.id         = plm.person_id "
            "  LEFT JOIN persons parent        ON parent.id     = pe.parent_person_id "
            "  LEFT JOIN players pl            ON pl.person_id  = pe.id "
            "  LEFT JOIN primary_email pem     ON pem.person_id = pe.id "
            "  LEFT JOIN primary_phone pph     ON pph.person_id = pe.id "
            "  LEFT JOIN primary_email parent_pem ON parent_pem.person_id = pe.parent_person_id "
            "  LEFT JOIN primary_phone parent_pph ON parent_pph.person_id = pe.parent_person_id "
            " WHERE plm.ended_at IS NULL AND lp.variant = $1 "
            " ORDER BY lp.category, lp.program_id, pe.last_name, pe.first_name",
            { variant });

        // Group by (category, program_id) — one group per sub-program.
        std::ostringstream out;
        out << "{\"success\":true,\"data\":{"
            << "\"variant\":" << jsonEscape(variant) << ","
            << "\"groups\":[";

        long long   curProgramId = -1;
        bool firstGroup     = true;
        bool firstInGroup   = true;
        std::size_t total   = 0;

        auto closeGroup = [&](std::ostringstream& o) {
            if (curProgramId < 0) return;
            o << "]}";
        };

        // "men" → "Men", "boys" → "Boys", etc. — title-case first character
        // only.  Append " Paused" when variant=paused so screens using the
        // label directly don't need extra logic.
        auto categoryLabel = [&](const std::string& cat) -> std::string {
            std::string label = cat;
            if (!label.empty()) label[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(label[0])));
            if (variant == "paused") label += " Paused";
            return label;
        };

        for (const auto& row : rows) {
            const std::string category     = row["category"].is_null()     ? "" : row["category"].c_str();
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
                    << ",\"label\":"         << jsonEscape(categoryLabel(category))
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
static std::string resolveVariant(const Request& request,
                                   const std::string& defaultVariant) {
    std::string v = request.getQueryParam("variant");
    if (v.empty()) v = defaultVariant;
    if (v != "active" && v != "paused") v = defaultVariant;
    return v;
}

Response AdminLaBackfillController::handlePausedMembers(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    return respondMembers(resolveVariant(request, "paused"));
}

Response AdminLaBackfillController::handleMembers(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }
    return respondMembers(resolveVariant(request, "active"));
}
