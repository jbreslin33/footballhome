#include "BillingController.h"

#include <sstream>
#include <stdexcept>
#include <string>

#include "../models/BillingExpectations.h"
#include "../services/BillingProjector.h"
#include "../services/LeagueAppsService.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonErr(HttpStatus status, const std::string& msg) {
    json j = json::object();
    j["error"] = msg;
    return Response(status, j.dump());
}

json toJson(const BillingExpectations::Row& r, const std::string& todayIso) {
    json j = json::object();
    j["id"]              = r.id;
    j["leagueAppsUserId"] = r.leagueAppsUserId;
    j["laProgramId"]     = r.laProgramId;
    j["chargeDate"]      = r.chargeDate;
    j["kind"]            = r.kind;
    j["expectedAmount"]  = r.expectedAmount;
    j["invoiceAddedAt"]  = r.invoiceAddedAt.empty() ? json(nullptr) : json(r.invoiceAddedAt);
    j["paidAt"]          = r.paidAt.empty()         ? json(nullptr) : json(r.paidAt);
    j["waivedAt"]        = r.waivedAt.empty()       ? json(nullptr) : json(r.waivedAt);
    j["notes"]           = r.notes.empty()          ? json(nullptr) : json(r.notes);
    j["createdAt"]       = r.createdAt;
    j["updatedAt"]       = r.updatedAt;
    j["state"] = BillingExpectations::Row::stateName(r.state(todayIso));
    return j;
}

// Extract the "/…/expectations/<id>/<verb>" id.  Returns 0 on failure.
long long extractIdFromPath(const std::string& path,
                            const std::string& trailingVerb) {
    // path is like "/api/billing/expectations/1234/mark-paid"
    const std::string suffix = std::string("/") + trailingVerb;
    if (path.size() <= suffix.size()) return 0;
    if (path.compare(path.size() - suffix.size(), suffix.size(), suffix) != 0) {
        return 0;
    }
    const std::string withoutSuffix = path.substr(0, path.size() - suffix.size());
    const auto slash = withoutSuffix.find_last_of('/');
    if (slash == std::string::npos) return 0;
    try { return std::stoll(withoutSuffix.substr(slash + 1)); }
    catch (const std::exception&) { return 0; }
}

// Best-effort "note" field extraction from a JSON body.  Returns "" on
// missing/invalid — the model handlers accept empty and treat as "no
// note appended".
std::string readNote(const Request& req) {
    if (req.getBody().empty()) return {};
    try {
        json j = json::parse(req.getBody());
        if (j.is_object() && j.contains("note") && j["note"].is_string()) {
            return j["note"].get<std::string>();
        }
    } catch (const std::exception&) {}
    return {};
}

// UTC "today" is misleading around midnight NY; caller does the TZ math.
// This helper is used only for the state derivation on read responses.
std::string todayInNy() {
    // We rely on Postgres for TZ math elsewhere; here we approximate with
    // a client-side conversion so we don't need an extra DB round trip
    // per response.  If the resulting string is off by ±1 day near
    // midnight NY the only consequence is a "projected" vs "due" chip
    // flicker on the UI for a few minutes.  Acceptable.
    std::time_t t = std::time(nullptr);
    // America/New_York is UTC-5 (EST) or UTC-4 (EDT).  Use tzset+localtime_r
    // with TZ pinned to America/New_York; if the container doesn't have
    // the zoneinfo file, this falls back to UTC.
    const char* prevTz = std::getenv("TZ");
    setenv("TZ", "America/New_York", 1);
    tzset();
    struct tm buf;
    localtime_r(&t, &buf);
    char out[16];
    std::snprintf(out, sizeof(out), "%04d-%02d-%02d",
                  buf.tm_year + 1900, buf.tm_mon + 1, buf.tm_mday);
    if (prevTz) setenv("TZ", prevTz, 1); else unsetenv("TZ");
    tzset();
    return out;
}

} // namespace

BillingController::BillingController()
    : expectations_(std::make_unique<BillingExpectations>()),
      projector_   (std::make_unique<BillingProjector>()) {}

BillingController::~BillingController() = default;

void BillingController::registerRoutes(Router& router, const std::string& prefix) {
    router.post(prefix + "/projector/run", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleProjectorRun(r);
    });

    router.get(prefix + "/expectations", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetByUser(r);
    });

    router.get(prefix + "/queue", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetQueue(r);
    });

    router.post(prefix + "/expectations/:id/mark-invoice-added", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleMarkInvoice(r);
    });

    router.post(prefix + "/expectations/:id/mark-paid", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleMarkPaid(r);
    });

    router.post(prefix + "/expectations/:id/waive", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleWaive(r);
    });

    router.post(prefix + "/la-registration-dates/backfill", [this](const Request& r) {
        if (!requireBearer(r)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleLaRegBackfill(r);
    });
}

Response BillingController::handleProjectorRun(const Request& req) {
    int horizonDays  = BillingProjector::kDefaultHorizonDays;
    int backfillDays = BillingProjector::kDefaultBackfillDays;

    if (!req.getBody().empty()) {
        try {
            json b = json::parse(req.getBody());
            if (b.is_object()) {
                if (b.contains("horizonDays") && b["horizonDays"].is_number_integer()) {
                    horizonDays = b["horizonDays"].get<int>();
                }
                if (b.contains("backfillDays") && b["backfillDays"].is_number_integer()) {
                    backfillDays = b["backfillDays"].get<int>();
                }
            }
        } catch (const std::exception&) {
            // Ignore body-parse errors: run with defaults.
        }
    }

    // Clamp to sane bounds to avoid an operator typing 100000 by mistake.
    if (horizonDays  < 0)   horizonDays  = 0;
    if (horizonDays  > 400) horizonDays  = 400;
    if (backfillDays < 0)   backfillDays = 0;
    if (backfillDays > 400) backfillDays = 400;

    try {
        const auto s = projector_->run(horizonDays, backfillDays);
        json j = json::object();
        j["didRun"]           = s.didRun;
        j["activeMembers"]    = s.activeMembers;
        j["monthlyInserted"]  = s.monthlyInserted;
        j["prorateInserted"]  = s.prorateInserted;
        j["horizonStart"]     = s.horizonStart;
        j["horizonEnd"]       = s.horizonEnd;
        j["ranAt"]            = s.ranAt;
        j["skipReason"]       = s.skipReason.empty() ? json(nullptr) : json(s.skipReason);
        return Response(HttpStatus::OK, j.dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("projector failed: ") + e.what());
    }
}

Response BillingController::handleGetByUser(const Request& req) {
    const std::string uidStr = req.getQueryParam("user_id");
    if (uidStr.empty()) {
        return jsonErr(HttpStatus::BAD_REQUEST, "user_id required");
    }
    long long uid = 0;
    try { uid = std::stoll(uidStr); }
    catch (const std::exception&) {
        return jsonErr(HttpStatus::BAD_REQUEST, "user_id must be numeric");
    }

    long long programId = 0;
    const std::string progStr = req.getQueryParam("program_id");
    if (!progStr.empty()) {
        try { programId = std::stoll(progStr); }
        catch (const std::exception&) {
            return jsonErr(HttpStatus::BAD_REQUEST, "program_id must be numeric");
        }
    }

    const std::string today = todayInNy();

    try {
        const auto rows = expectations_->listByUser(uid, programId);
        json out = json::array();
        for (const auto& r : rows) out.push_back(toJson(r, today));

        json body = json::object();
        body["today"]        = today;
        body["expectations"] = std::move(out);
        return Response(HttpStatus::OK, body.dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("query failed: ") + e.what());
    }
}

Response BillingController::handleGetQueue(const Request& req) {
    long long programId = 0;
    const std::string progStr = req.getQueryParam("program_id");
    if (!progStr.empty()) {
        try { programId = std::stoll(progStr); }
        catch (const std::exception&) {
            return jsonErr(HttpStatus::BAD_REQUEST, "program_id must be numeric");
        }
    }

    // Optional cutoff — default is today America/NY.
    std::string cutoff = req.getQueryParam("date");
    if (cutoff.empty()) cutoff = todayInNy();

    try {
        const auto rows = expectations_->listOpenQueue(cutoff, programId);
        json out = json::array();
        for (const auto& r : rows) out.push_back(toJson(r, cutoff));

        json body = json::object();
        body["today"]        = cutoff;
        body["count"]        = static_cast<int>(rows.size());
        body["expectations"] = std::move(out);
        return Response(HttpStatus::OK, body.dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("query failed: ") + e.what());
    }
}

Response BillingController::handleMarkInvoice(const Request& req) {
    const long long id = extractIdFromPath(req.getPath(), "mark-invoice-added");
    if (id <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "id required");

    const std::string note = readNote(req);
    try {
        expectations_->markInvoiceAdded(id, note);
        const auto row = expectations_->findById(id);
        if (!row) return jsonErr(HttpStatus::NOT_FOUND, "expectation not found");
        return Response(HttpStatus::OK, toJson(*row, todayInNy()).dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("update failed: ") + e.what());
    }
}

Response BillingController::handleMarkPaid(const Request& req) {
    const long long id = extractIdFromPath(req.getPath(), "mark-paid");
    if (id <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "id required");

    const std::string note = readNote(req);
    try {
        expectations_->markPaid(id, note);
        const auto row = expectations_->findById(id);
        if (!row) return jsonErr(HttpStatus::NOT_FOUND, "expectation not found");
        return Response(HttpStatus::OK, toJson(*row, todayInNy()).dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("update failed: ") + e.what());
    }
}

Response BillingController::handleWaive(const Request& req) {
    const long long id = extractIdFromPath(req.getPath(), "waive");
    if (id <= 0) return jsonErr(HttpStatus::BAD_REQUEST, "id required");

    const std::string note = readNote(req);
    try {
        expectations_->markWaived(id, note);
        const auto row = expectations_->findById(id);
        if (!row) return jsonErr(HttpStatus::NOT_FOUND, "expectation not found");
        return Response(HttpStatus::OK, toJson(*row, todayInNy()).dump());
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("update failed: ") + e.what());
    }
}

// ── LA-registration-date backfill ──────────────────────────────────────────
//
// Extract a plausible "registered at" epoch/ISO from a raw LA record.
// LA's registrations-2 payload has been observed to carry one of several
// field names depending on program vintage / API version; this tries the
// common suspects in a defined priority order and normalises everything
// to an ISO timestamp string (UTC).  Returns "" when nothing matches.
namespace {

std::string extractRegisteredIso(const nlohmann::json& rec) {
    // Fields we've seen or expect in LA export payloads, in order of
    // preference.  Values may be epoch millis (number) or ISO strings.
    // `lastUpdated` is deliberately last-resort — for brand-new signups
    // it equals registrationDate, but for older regs it's stale.
    static const char* kCandidates[] = {
        "registrationDate",
        "registrationCreatedAt",
        "dateRegistered",
        "signupDate",
        "createdOn",
        "dateCreated",
        "created",
        "lastUpdated",
    };

    for (const char* key : kCandidates) {
        auto it = rec.find(key);
        if (it == rec.end() || it->is_null()) continue;

        if (it->is_number()) {
            // Interpret as epoch milliseconds.  Anything under 10^12 is
            // implausibly small (would be pre-1970 in millis) — treat as
            // "not the right field" and keep scanning.
            const double v = it->get<double>();
            if (v < 1'000'000'000'000.0) continue;
            const long long millis = static_cast<long long>(v);
            const std::time_t secs = static_cast<std::time_t>(millis / 1000);
            struct tm buf;
            gmtime_r(&secs, &buf);
            char out[32];
            std::snprintf(out, sizeof(out),
                          "%04d-%02d-%02dT%02d:%02d:%02dZ",
                          buf.tm_year + 1900, buf.tm_mon + 1, buf.tm_mday,
                          buf.tm_hour, buf.tm_min, buf.tm_sec);
            return out;
        }
        if (it->is_string()) {
            const std::string s = it->get<std::string>();
            if (s.size() < 10) continue;
            // Postgres TIMESTAMPTZ is forgiving with ISO strings; pass
            // through verbatim.  If a program uses an unrecognised
            // format we'll surface a parse error via the caller's catch.
            return s;
        }
    }
    return {};
}

// Extract LA userId (numeric or string) — mirrors LaProgramSync's helper.
std::string extractUserIdRegBackfill(const nlohmann::json& rec) {
    auto take = [&](const char* key) -> std::string {
        auto it = rec.find(key);
        if (it == rec.end() || it->is_null()) return {};
        if (it->is_string())               return it->get<std::string>();
        if (it->is_number_integer())       return std::to_string(it->get<long long>());
        if (it->is_number_unsigned())      return std::to_string(it->get<unsigned long long>());
        if (it->is_number_float())         return std::to_string(static_cast<long long>(it->get<double>()));
        return {};
    };
    std::string uid = take("userId");
    if (uid.empty()) uid = take("memberId");
    return uid;
}

} // namespace

Response BillingController::handleLaRegBackfill(const Request& req) {
    // Optional program filter from body.  When absent, iterate every
    // program row from leagueapps_programs.  A dry-run flag lets an
    // operator inspect what the extractor would find without writing.
    long long onlyProgramId = 0;
    bool      dryRun        = false;
    if (!req.getBody().empty()) {
        try {
            nlohmann::json b = nlohmann::json::parse(req.getBody());
            if (b.is_object()) {
                if (b.contains("programId")) {
                    const auto& v = b["programId"];
                    if      (v.is_number_integer())  onlyProgramId = v.get<long long>();
                    else if (v.is_number_unsigned()) onlyProgramId = static_cast<long long>(v.get<unsigned long long>());
                    else if (v.is_string()) {
                        try { onlyProgramId = std::stoll(v.get<std::string>()); }
                        catch (...) { /* ignore */ }
                    }
                }
                if (b.contains("dryRun") && b["dryRun"].is_boolean()) {
                    dryRun = b["dryRun"].get<bool>();
                }
            }
        } catch (const std::exception&) { /* ignore */ }
    }

    auto* db = Database::getInstance();

    // Load the program list.
    std::vector<long long> programIds;
    try {
        pqxx::result rows;
        if (onlyProgramId > 0) {
            rows = db->query(
                "SELECT program_id FROM leagueapps_programs WHERE program_id = $1::bigint",
                {std::to_string(onlyProgramId)});
        } else {
            rows = db->query("SELECT program_id FROM leagueapps_programs ORDER BY program_id");
        }
        for (const auto& r : rows) {
            if (!r["program_id"].is_null()) {
                programIds.push_back(r["program_id"].as<long long>());
            }
        }
    } catch (const std::exception& e) {
        return jsonErr(HttpStatus::INTERNAL_SERVER_ERROR,
                       std::string("failed to list programs: ") + e.what());
    }

    if (programIds.empty()) {
        return jsonErr(HttpStatus::NOT_FOUND, "no matching program(s)");
    }

    nlohmann::json programSummaries = nlohmann::json::array();
    int totalExamined = 0;
    int totalUpdated  = 0;
    int totalMissing  = 0;
    nlohmann::json fieldCounts = nlohmann::json::object();
    nlohmann::json sampleRecordKeys = nlohmann::json::array();
    bool tookSample = false;

    for (const auto pid : programIds) {
        nlohmann::json ps = nlohmann::json::object();
        ps["programId"] = pid;
        int examined = 0;
        int updated  = 0;
        int missing  = 0;
        std::string errorMsg;

        try {
            auto recs = LeagueAppsService::getInstance()
                            .fetchProgramRegistrations(static_cast<int>(pid));

            // Dump the top-level key set of the first record we ever see
            // this run — invaluable when the operator wants to know
            // which LA field actually carried the timestamp.
            if (!tookSample && !recs.empty() && recs[0].is_object()) {
                for (auto it = recs[0].begin(); it != recs[0].end(); ++it) {
                    sampleRecordKeys.push_back(it.key());
                }
                tookSample = true;
            }

            for (const auto& rec : recs) {
                ++examined;

                const std::string uid    = extractUserIdRegBackfill(rec);
                const std::string regIso = extractRegisteredIso(rec);

                if (uid.empty() || regIso.empty()) {
                    ++missing;
                    continue;
                }

                if (dryRun) {
                    ++updated;   // report what would be updated
                    continue;
                }

                // Update the open membership row.  We match by
                //   (external_person_aliases.external_user_id -> person_id)
                //   AND person_la_memberships.la_program_id = pid
                //   AND ended_at IS NULL
                // and ONLY fill NULL rows so subsequent runs are no-ops
                // (won't clobber later corrections).
                auto res = db->query(
                    "UPDATE person_la_memberships plm "
                    "   SET la_registered_at = $1::timestamptz, "
                    "       updated_at       = now() "
                    "  FROM external_person_aliases epa "
                    " WHERE epa.provider          = 'leagueapps' "
                    "   AND epa.external_user_id  = $2 "
                    "   AND plm.person_id         = epa.person_id "
                    "   AND plm.la_program_id     = $3::bigint "
                    "   AND plm.ended_at          IS NULL "
                    "   AND plm.la_registered_at  IS NULL "
                    "RETURNING plm.id",
                    {regIso, uid, std::to_string(pid)});
                if (!res.empty()) ++updated;
            }
        } catch (const std::exception& e) {
            errorMsg = e.what();
        }

        ps["examined"]    = examined;
        ps["updated"]     = updated;
        ps["missingDate"] = missing;
        if (!errorMsg.empty()) ps["error"] = errorMsg;
        programSummaries.push_back(std::move(ps));

        totalExamined += examined;
        totalUpdated  += updated;
        totalMissing  += missing;
    }

    nlohmann::json body = nlohmann::json::object();
    body["dryRun"]           = dryRun;
    body["totalExamined"]    = totalExamined;
    body["totalUpdated"]     = totalUpdated;
    body["totalMissingDate"] = totalMissing;
    body["sampleRecordKeys"] = std::move(sampleRecordKeys);
    body["programs"]         = std::move(programSummaries);
    return Response(HttpStatus::OK, body.dump());
}
