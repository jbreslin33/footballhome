#include "AdminLaBackfillController.h"

#include <cstdlib>
#include <ctime>
#include <iostream>
#include <sstream>
#include <vector>

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
        programs = { boysProgramId_, girlsProgramId_, mensProgramId_ };
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

bool AdminLaBackfillController::requireBearer(const Request& request) {
    const std::string h = request.getHeader("Authorization");
    return h.size() > 7 && h.compare(0, 7, "Bearer ") == 0;
}
