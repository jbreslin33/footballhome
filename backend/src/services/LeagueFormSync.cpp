#include "LeagueFormSync.h"

#include <cctype>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <mutex>
#include <stdexcept>
#include <string>

#include "../core/HttpClient.h"
#include "../core/JwtRS256.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

constexpr const char* kTokenUrl = "https://oauth2.googleapis.com/token";
constexpr const char* kScope    = "https://www.googleapis.com/auth/spreadsheets.readonly";

std::mutex runMutex;            // one sheet read at a time
std::mutex tokenMutex;
std::string tokenCache;
std::chrono::system_clock::time_point tokenExpiresAt{};

// Service-account access token (JWT bearer, RFC 7523) for the Sheets scope.
// The same account (GCAL_SA_JSON) the gcal sync uses.
std::string accessToken() {
    std::lock_guard<std::mutex> lk(tokenMutex);
    const auto now = std::chrono::system_clock::now();
    if (!tokenCache.empty() && tokenExpiresAt > now + std::chrono::seconds(60)) return tokenCache;

    const char* raw = std::getenv("GCAL_SA_JSON");
    if (!raw || !*raw) throw std::runtime_error("GCAL_SA_JSON not set");
    const json sa = json::parse(raw);
    const std::string email = sa.value("client_email", "");
    const std::string pem   = sa.value("private_key", "");
    if (email.empty() || pem.empty()) throw std::runtime_error("GCAL_SA_JSON lacks client_email / private_key");

    const long long iat = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
    const json claims = {{"iss", email}, {"scope", kScope}, {"aud", kTokenUrl},
                         {"iat", iat}, {"exp", iat + 3600}};
    const std::string body =
        "grant_type=" + HttpClient::urlEncode("urn:ietf:params:oauth:grant-type:jwt-bearer") +
        "&assertion=" + HttpClient::urlEncode(JwtRS256::sign(claims.dump(), pem));

    HttpClient http;
    http.setTotalTimeoutSec(15);
    const auto r = http.postForm(kTokenUrl, body);
    if (!r.ok()) throw std::runtime_error("token exchange " + std::to_string(r.status) + " " + r.error + " " + r.body.substr(0, 200));
    const json data = json::parse(r.body);
    tokenCache = data.value("access_token", "");
    if (tokenCache.empty()) throw std::runtime_error("token response lacks access_token");
    const int ttl = data.value("expires_in", 3600);
    tokenExpiresAt = now + std::chrono::seconds(ttl > 120 ? ttl - 60 : ttl);
    return tokenCache;
}

std::string lower(std::string s) { for (auto& c : s) c = (char)std::tolower((unsigned char)c); return s; }

// "9/1/2026 20:47:50" (the form's Timestamp, sheet-local) → "2026-09-01T20:47:50".
std::string isoFromSheet(const std::string& s) {
    int mo = 0, d = 0, y = 0, h = 0, mi = 0, se = 0;
    if (std::sscanf(s.c_str(), "%d/%d/%d %d:%d:%d", &mo, &d, &y, &h, &mi, &se) < 3) return {};
    if (mo < 1 || mo > 12 || d < 1 || d > 31 || y < 2000) return {};
    char buf[32];
    std::snprintf(buf, sizeof buf, "%04d-%02d-%02dT%02d:%02d:%02d", y, mo, d, h, mi, se);
    return buf;
}

void record(int sheetId, bool ok, const std::string& note) {
    try {
        Database::getInstance()->query(
            "UPDATE league_form_sheets SET last_tried_at = now(), last_fetch_ok = $2::boolean, "
            "  last_fetch_note = NULLIF($3, ''), "
            "  last_fetched_at = CASE WHEN $2::boolean THEN now() ELSE last_fetched_at END "
            " WHERE id = $1::int",
            {std::to_string(sheetId), ok ? "true" : "false", note.substr(0, 500)});
    } catch (const std::exception& e) {
        std::cerr << "[league form] record: " << e.what() << std::endl;
    }
}

} // namespace

void LeagueFormSync::refreshIfStale(int maxAgeMinutes) {
    std::unique_lock<std::mutex> lk(runMutex, std::try_to_lock);
    if (!lk.owns_lock()) return;
    try {
        auto due = Database::getInstance()->query(
            "SELECT id, spreadsheet_id, sheet_title FROM league_form_sheets "
            " WHERE is_active AND COALESCE(spreadsheet_id, '') <> '' "
            "   AND (last_tried_at IS NULL OR last_tried_at < now() - make_interval(mins => $1::int))",
            {std::to_string(maxAgeMinutes)});
        for (const auto& r : due) run(r["id"].as<int>(), r["spreadsheet_id"].c_str(), r["sheet_title"].c_str());
    } catch (const std::exception& e) {
        std::cerr << "[league form] " << e.what() << std::endl;
    }
}

void LeagueFormSync::run(int sheetId, const std::string& spreadsheetId, const std::string& sheetTitle) {
    try {
        const std::string url = "https://sheets.googleapis.com/v4/spreadsheets/" + HttpClient::urlEncode(spreadsheetId)
                              + "/values/" + HttpClient::urlEncode("'" + sheetTitle + "'!A1:C2000");
        HttpClient http;
        http.setTotalTimeoutSec(15);
        const auto res = http.get(url, {{"Authorization", "Bearer " + accessToken()}});
        if (!res.ok()) {
            const std::string why = res.status == 403 ? "not shared with the service account (403)"
                                  : res.status == 404 ? "sheet or tab not found (404)"
                                  : "HTTP " + std::to_string(res.status) + (res.error.empty() ? "" : " " + res.error);
            std::cerr << "[league form] sheet " << sheetId << ": " << why << std::endl;
            record(sheetId, false, why);
            return;
        }
        const json body = json::parse(res.body);
        const json values = body.value("values", json::array());
        if (values.empty() || !values[0].is_array()) { record(sheetId, false, "sheet is empty"); return; }

        // Columns by header, not position: the form can grow questions.
        int cAt = -1, cFirst = -1, cLast = -1;
        const auto& hdr = values[0];
        for (int i = 0; i < (int)hdr.size(); ++i) {
            if (!hdr[i].is_string()) continue;
            const std::string h = lower(hdr[i].get<std::string>());
            if (h == "timestamp") cAt = i;
            else if (h == "first name") cFirst = i;
            else if (h == "last name") cLast = i;
        }
        if (cFirst < 0 || cLast < 0) { record(sheetId, false, "no First Name / Last Name header"); return; }

        auto cell = [](const json& row, int i) -> std::string {
            return (i >= 0 && i < (int)row.size() && row[i].is_string()) ? row[i].get<std::string>() : std::string();
        };
        json rows = json::array();
        for (size_t r = 1; r < values.size(); ++r) {
            const auto& row = values[r];
            if (!row.is_array()) continue;
            rows.push_back({{"row", (int)r + 1}, {"at", isoFromSheet(cell(row, cAt))},
                            {"first", cell(row, cFirst)}, {"last", cell(row, cLast)}});
        }
        if (rows.empty()) { record(sheetId, false, "no responses parsed"); return; }

        auto n = Database::getInstance()->query("SELECT fh_league_form_load($1::int, $2::jsonb) AS n",
                                                {std::to_string(sheetId), rows.dump()});
        record(sheetId, true, "");
        std::cout << "[league form] sheet " << sheetId << ": " << n[0]["n"].as<int>() << " responses" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "[league form] sheet " << sheetId << ": " << e.what() << std::endl;
        record(sheetId, false, e.what());
    }
}
