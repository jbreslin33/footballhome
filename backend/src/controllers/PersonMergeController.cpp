#include "PersonMergeController.h"
#include "../database/Database.h"
#include <cstdio>
#include <iostream>
#include <regex>
#include <sstream>
#include <stdexcept>

PersonMergeController::PersonMergeController()
    : model_(std::make_unique<PersonMerge>()) {}

void PersonMergeController::registerRoutes(Router& router, const std::string& prefix) {
    // POST /api/persons/merge
    router.post(prefix + "/merge", [this](const Request& request) {
        return this->handleMerge(request);
    });
    // POST /api/persons/unmerge/:mergeId
    router.post(prefix + "/unmerge/:mergeId", [this](const Request& request) {
        return this->handleUnmerge(request);
    });
    // POST /api/persons/link-scraped — admin-confirmed scraped → Lighthouse link
    router.post(prefix + "/link-scraped", [this](const Request& request) {
        return this->handleLinkScraped(request);
    });
    // GET  /api/persons/:personId/scraped-match-candidates
    router.get(prefix + "/:personId/scraped-match-candidates", [this](const Request& request) {
        return this->handleScrapedMatchCandidates(request);
    });
    // GET  /api/persons/:personId/merges
    router.get(prefix + "/:personId/merges", [this](const Request& request) {
        return this->handleListMerges(request);
    });
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/merge — { laPersonId, gmPersonId }
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleMerge(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int laPersonId = 0, gmPersonId = 0;
    if (!extractMergeBody(request.getBody(), laPersonId, gmPersonId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "laPersonId and gmPersonId are required integers");
    }

    try {
        auto r = model_->merge(laPersonId, gmPersonId, extractActingUserId(request));

        std::ostringstream json;
        json << "{"
             << "\"mergeId\":"          << r.mergeId
             << ",\"mergedAt\":\""      << jsonEscape(r.mergedAt) << "\""
             << ",\"kept\":"            << r.kept
             << ",\"dropped\":"         << r.dropped
             << ",\"reparented\":"      << renderCounts(r.reparented)
             << ",\"deletedConflicts\":"<< renderCounts(r.deletedConflicts)
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleMerge error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/unmerge/:mergeId
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleUnmerge(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int mergeId = 0;
    if (!extractMergeId(request.getPath(), mergeId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid mergeId");
    }

    try {
        auto r = model_->unmerge(mergeId, extractActingUserId(request));

        std::ostringstream json;
        json << "{"
             << "\"mergeId\":"     << r.mergeId
             << ",\"kept\":"       << r.kept
             << ",\"restored\":"   << r.restored
             << ",\"movedBack\":"  << renderCounts(r.movedBack)
             << ",\"reinserted\":" << renderCounts(r.reinserted)
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleUnmerge error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/:personId/merges
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleListMerges(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid personId");
    }

    try {
        auto rows = model_->listForPerson(personId);

        std::ostringstream json;
        json << "{\"personId\":" << personId << ",\"merges\":[";
        for (size_t i = 0; i < rows.size(); ++i) {
            if (i) json << ',';
            json << renderMergeRow(rows[i]);
        }
        json << "]}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleListMerges error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/:personId/scraped-match-candidates
//
// Name (± DOB) matches against scraped-only persons: they have a players
// row + current roster, and NO open person_la_memberships.  Never
// auto-links — Club Admin confirms via POST /link-scraped.
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleScrapedMatchCandidates(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractScrapedCandidatesPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST, "Invalid personId");
    }

    try {
        auto* db = Database::getInstance();
        auto rows = db->query(
            "WITH target AS ( "
            "  SELECT id, lower(trim(first_name)) AS fn, "
            "         lower(trim(last_name)) AS ln, birth_date "
            "    FROM persons WHERE id = $1 "
            ") "
            "SELECT pe.id AS person_id, pe.first_name, pe.last_name, "
            "       TO_CHAR(pe.birth_date, 'YYYY-MM-DD') AS dob, "
            "       pl.id AS player_id, "
            "       (pe.birth_date IS NOT DISTINCT FROM tg.birth_date) AS dob_match, "
            "       string_agg(DISTINCT t.name, ', ' ORDER BY t.name) AS team_names, "
            "       string_agg(DISTINCT COALESCE(c.name, ''), ', ' "
            "                  ORDER BY COALESCE(c.name, '')) AS club_names "
            "  FROM persons pe "
            "  JOIN target tg ON true "
            "  JOIN players pl ON pl.person_id = pe.id "
            "  JOIN rosters r ON r.player_id = pl.id AND r.left_at IS NULL "
            "  JOIN teams t ON t.id = r.team_id "
            "  LEFT JOIN clubs c ON c.id = t.club_id "
            " WHERE pe.id <> $1 "
            "   AND lower(trim(pe.first_name)) = tg.fn "
            "   AND lower(trim(pe.last_name))  = tg.ln "
            "   AND tg.fn <> '' AND tg.ln <> '' "
            "   AND (tg.birth_date IS NULL OR pe.birth_date IS NULL "
            "        OR pe.birth_date = tg.birth_date) "
            "   AND NOT EXISTS ( "
            "         SELECT 1 FROM person_la_memberships plm "
            "          WHERE plm.person_id = pe.id AND plm.ended_at IS NULL "
            "       ) "
            " GROUP BY pe.id, pe.first_name, pe.last_name, pe.birth_date, "
            "          pl.id, tg.birth_date "
            " ORDER BY (pe.birth_date IS NOT DISTINCT FROM tg.birth_date) DESC, "
            "          pe.last_name, pe.first_name "
            " LIMIT 20",
            { std::to_string(personId) });

        std::ostringstream out;
        out << "{\"personId\":" << personId << ",\"candidates\":[";
        bool first = true;
        for (const auto& row : rows) {
            if (!first) out << ",";
            first = false;
            const std::string fn = row["first_name"].is_null() ? "" : row["first_name"].c_str();
            const std::string ln = row["last_name"].is_null()  ? "" : row["last_name"].c_str();
            const std::string dob = row["dob"].is_null()       ? "" : row["dob"].c_str();
            const std::string teams = row["team_names"].is_null() ? "" : row["team_names"].c_str();
            const std::string clubs = row["club_names"].is_null() ? "" : row["club_names"].c_str();
            const bool dobMatch = !row["dob_match"].is_null() && row["dob_match"].as<bool>();
            out << "{"
                <<   "\"personId\":" << row["person_id"].as<int>()
                << ",\"playerId\":" << row["player_id"].as<int>()
                << ",\"firstName\":\"" << jsonEscape(fn) << "\""
                << ",\"lastName\":\""  << jsonEscape(ln) << "\""
                << ",\"dob\":\""       << jsonEscape(dob) << "\""
                << ",\"dobMatch\":"  << (dobMatch ? "true" : "false")
                << ",\"teamNames\":\"" << jsonEscape(teams) << "\""
                << ",\"clubNames\":\"" << jsonEscape(clubs) << "\""
                << "}";
        }
        out << "]}";
        return Response(HttpStatus::OK, out.str());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleScrapedMatchCandidates error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// POST /api/persons/link-scraped — { keepPersonId, scrapedPersonId }
//
// keepPersonId must be a current Lighthouse member (open LA membership).
// scrapedPersonId must NOT have an open LA membership.  Then merge
// (keep, drop=scraped) so scraped roster/player rows reparent onto the
// Lighthouse person.  Reversible via unmerge.
// ────────────────────────────────────────────────────────────────────────────
Response PersonMergeController::handleLinkScraped(const Request& request) {
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int keepId = 0, scrapedId = 0;
    if (!extractLinkScrapedBody(request.getBody(), keepId, scrapedId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "keepPersonId and scrapedPersonId are required integers");
    }
    if (keepId == scrapedId) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "keepPersonId and scrapedPersonId must differ");
    }

    try {
        auto* db = Database::getInstance();

        auto keepRows = db->query(
            "SELECT 1 FROM person_la_memberships "
            " WHERE person_id = $1 AND ended_at IS NULL LIMIT 1",
            { std::to_string(keepId) });
        if (keepRows.empty()) {
            return errorResponse(HttpStatus::BAD_REQUEST,
                "keepPersonId must be a current Lighthouse member");
        }

        auto scrapedMem = db->query(
            "SELECT 1 FROM person_la_memberships "
            " WHERE person_id = $1 AND ended_at IS NULL LIMIT 1",
            { std::to_string(scrapedId) });
        if (!scrapedMem.empty()) {
            return errorResponse(HttpStatus::BAD_REQUEST,
                "scrapedPersonId still has an open LA membership — use /merge instead");
        }

        auto scrapedPlayer = db->query(
            "SELECT 1 FROM players WHERE person_id = $1 LIMIT 1",
            { std::to_string(scrapedId) });
        if (scrapedPlayer.empty()) {
            return errorResponse(HttpStatus::BAD_REQUEST,
                "scrapedPersonId has no players row");
        }

        // Historical API names: laPersonId = keep, gmPersonId = drop.
        auto r = model_->merge(keepId, scrapedId, extractActingUserId(request));

        std::ostringstream json;
        json << "{"
             << "\"mergeId\":"          << r.mergeId
             << ",\"mergedAt\":\""      << jsonEscape(r.mergedAt) << "\""
             << ",\"kept\":"            << r.kept
             << ",\"dropped\":"         << r.dropped
             << ",\"reparented\":"      << renderCounts(r.reparented)
             << ",\"deletedConflicts\":"<< renderCounts(r.deletedConflicts)
             << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::invalid_argument& e) {
        return errorResponse(HttpStatus::BAD_REQUEST, e.what());
    } catch (const std::exception& e) {
        std::cerr << "PersonMergeController::handleLinkScraped error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Path / body parsing.
// ────────────────────────────────────────────────────────────────────────────
bool PersonMergeController::extractMergeId(const std::string& path,
                                           int& mergeId) const {
    static const std::regex re(R"(/api/persons/unmerge/(\d+))");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { mergeId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractPersonId(const std::string& path,
                                            int& personId) const {
    static const std::regex re(R"(/api/persons/(\d+)/merges)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { personId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractScrapedCandidatesPersonId(const std::string& path,
                                                             int& personId) const {
    static const std::regex re(R"(/api/persons/(\d+)/scraped-match-candidates)");
    std::smatch m;
    if (!std::regex_search(path, m, re)) return false;
    try { personId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractMergeBody(const std::string& body,
                                             int& laPersonId,
                                             int& gmPersonId) const {
    static const std::regex laRe(R"rx("laPersonId"\s*:\s*(\d+))rx");
    static const std::regex gmRe(R"rx("gmPersonId"\s*:\s*(\d+))rx");
    std::smatch m;
    if (!std::regex_search(body, m, laRe)) return false;
    try { laPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    if (!std::regex_search(body, m, gmRe)) return false;
    try { gmPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}

bool PersonMergeController::extractLinkScrapedBody(const std::string& body,
                                                   int& keepPersonId,
                                                   int& scrapedPersonId) const {
    static const std::regex keepRe(R"rx("keepPersonId"\s*:\s*(\d+))rx");
    static const std::regex scrapRe(R"rx("scrapedPersonId"\s*:\s*(\d+))rx");
    std::smatch m;
    if (!std::regex_search(body, m, keepRe)) return false;
    try { keepPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    if (!std::regex_search(body, m, scrapRe)) return false;
    try { scrapedPersonId = std::stoi(m[1].str()); }
    catch (const std::exception&) { return false; }
    return true;
}


std::optional<int>
PersonMergeController::extractActingUserId(const Request& request) const {
    std::string h = request.getHeader("X-User-Id");
    if (h.empty()) h = request.getHeader("x-user-id");
    if (h.empty()) return std::nullopt;
    try { return std::stoi(h); }
    catch (const std::exception&) { return std::nullopt; }
}

// ────────────────────────────────────────────────────────────────────────────
// JSON helpers.
// ────────────────────────────────────────────────────────────────────────────
std::string PersonMergeController::jsonEscape(const std::string& in) {
    std::string out;
    out.reserve(in.size() + 2);
    for (char c : in) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\b': out += "\\b";  break;
            case '\f': out += "\\f";  break;
            case '\n': out += "\\n";  break;
            case '\r': out += "\\r";  break;
            case '\t': out += "\\t";  break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x", c);
                    out += buf;
                } else {
                    out.push_back(c);
                }
        }
    }
    return out;
}

std::string PersonMergeController::jsonOrNull(const std::optional<std::string>& v) {
    if (!v.has_value()) return "null";
    return "\"" + jsonEscape(*v) + "\"";
}
std::string PersonMergeController::jsonOrNull(const std::optional<int>& v) {
    if (!v.has_value()) return "null";
    return std::to_string(*v);
}

// Render { "table_a": N, "table_b": M, ... } in iteration order.  An empty
// counts vector becomes "{}" so the JSON shape is stable (matches Node).
std::string PersonMergeController::renderCounts(const PersonMerge::TableCounts& counts) {
    std::ostringstream o;
    o << "{";
    for (size_t i = 0; i < counts.size(); ++i) {
        if (i) o << ',';
        o << "\"" << jsonEscape(counts[i].first) << "\":" << counts[i].second;
    }
    o << "}";
    return o.str();
}

std::string PersonMergeController::renderMergeRow(const PersonMerge::MergeRow& row) {
    std::ostringstream o;
    o << "{"
      << "\"id\":"                   << row.id
      << ",\"kept_person_id\":"      << row.keptPersonId
      << ",\"dropped_person_id\":"   << row.droppedPersonId
      << ",\"merged_at\":\""         << jsonEscape(row.mergedAt) << "\""
      << ",\"merged_by_user_id\":"   << jsonOrNull(row.mergedByUserId)
      << ",\"reversed_at\":"         << jsonOrNull(row.reversedAt)
      << ",\"reversed_by_user_id\":" << jsonOrNull(row.reversedByUserId)
      << ",\"dropped_first_name\":"  << jsonOrNull(row.droppedFirstName)
      << ",\"dropped_last_name\":"   << jsonOrNull(row.droppedLastName)
      << "}";
    return o.str();
}
