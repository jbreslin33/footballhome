#include "FilmSync.h"

#include <cctype>
#include <ctime>
#include <iostream>
#include <set>
#include <vector>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "LeagueFixtureSync.h"

namespace {

// Minimal CSV: quotes, embedded commas and newlines, CRLF.
std::vector<std::vector<std::string>> parseCsv(const std::string& body) {
    std::vector<std::vector<std::string>> rows;
    std::vector<std::string> row;
    std::string cell;
    bool quoted = false;
    for (size_t i = 0; i < body.size(); ++i) {
        const char c = body[i];
        if (quoted) {
            if (c == '"') {
                if (i + 1 < body.size() && body[i + 1] == '"') { cell += '"'; ++i; }
                else quoted = false;
            } else cell += c;
        } else if (c == '"') {
            quoted = true;
        } else if (c == ',') {
            row.push_back(cell); cell.clear();
        } else if (c == '\n' || c == '\r') {
            if (c == '\r' && i + 1 < body.size() && body[i + 1] == '\n') ++i;
            row.push_back(cell); cell.clear();
            rows.push_back(row); row.clear();
        } else cell += c;
    }
    if (!cell.empty() || !row.empty()) { row.push_back(cell); rows.push_back(row); }
    return rows;
}

std::string trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t");
    if (a == std::string::npos) return {};
    size_t b = s.find_last_not_of(" \t");
    return s.substr(a, b - a + 1);
}

std::string lower(std::string s) { for (auto& c : s) c = (char)std::tolower((unsigned char)c); return s; }

// "9/11 - 9/17" → ISO dates.  The sheet never states a year: a month from
// August on belongs to the season's first calendar year, anything earlier
// to the next (Fall seasons run Sep–Jul at the widest).
bool parseWindow(const std::string& text, std::string* fromIso, std::string* tillIso) {
    int m1 = 0, d1 = 0, m2 = 0, d2 = 0;
    if (std::sscanf(text.c_str(), " %d/%d - %d/%d", &m1, &d1, &m2, &d2) != 4) return false;
    if (m1 < 1 || m1 > 12 || m2 < 1 || m2 > 12 || d1 < 1 || d1 > 31 || d2 < 1 || d2 > 31) return false;
    std::time_t now = std::time(nullptr);
    std::tm lt{};
    localtime_r(&now, &lt);
    const int seasonStart = (lt.tm_mon + 1 >= 8) ? lt.tm_year + 1900 : lt.tm_year + 1899;
    char a[16], b[16];
    std::snprintf(a, sizeof a, "%04d-%02d-%02d", m1 >= 8 ? seasonStart : seasonStart + 1, m1, d1);
    std::snprintf(b, sizeof b, "%04d-%02d-%02d", m2 >= 8 ? seasonStart : seasonStart + 1, m2, d2);
    *fromIso = a; *tillIso = b;
    return true;
}

// A cell may carry several links joined with "||".
std::vector<std::string> splitLinks(const std::string& cell) {
    std::vector<std::string> out;
    size_t pos = 0;
    while (pos < cell.size()) {
        size_t sep = cell.find("||", pos);
        std::string piece = trim(sep == std::string::npos ? cell.substr(pos) : cell.substr(pos, sep - pos));
        if (piece.rfind("http", 0) == 0) out.push_back(piece);
        pos = (sep == std::string::npos) ? cell.size() : sep + 2;
    }
    return out;
}

} // namespace

void FilmSync::refreshIfStale(int maxAgeMinutes) {
    auto* db = Database::getInstance();
    try {
        auto due = db->query(
            "SELECT id, csv_url, league_label FROM film_sources WHERE is_active "
            "  AND (fetched_at IS NULL OR fetched_at < now() - make_interval(mins => $1::int))",
            {std::to_string(maxAgeMinutes)});
        for (const auto& r : due) run(r["id"].as<int>(), r["csv_url"].c_str());
        // The matcher needs the WHOLE division's fixtures, not just our own
        // feed (mig 607, owner 2026-10-19: "find who home team was playing
        // via fuzzy logic based on schedule") — the division-wide
        // teampass_json source carries them.  Re-pull the league's fixture
        // sources on the sheet's own staleness cadence.
        if (!due.empty()) {
            std::set<std::string> labels;
            for (const auto& r : due) labels.insert(r["league_label"].c_str());
            for (const auto& label : labels) LeagueFixtureSync::refreshLeague(label);
        }
    } catch (const std::exception& e) {
        std::cerr << "[film sync] " << e.what() << std::endl;
    }
}

void FilmSync::run(int sourceId, const std::string& csvUrl) {
    HttpClient http;
    http.setTotalTimeoutSec(15);
    auto res = http.get(csvUrl);
    if (!res.ok()) {
        std::cerr << "[film sync] source " << sourceId << " fetch failed: "
                  << (res.error.empty() ? std::to_string(res.status) : res.error) << std::endl;
        return;
    }
    auto* db = Database::getInstance();
    const std::string sid = std::to_string(sourceId);
    std::string matchday, winFrom, winTill;
    int upserts = 0;
    // The sweep boundary: rows not seen by THIS pass get removed_at.
    auto t0 = db->query("SELECT now()::text AS t")[0]["t"].as<std::string>();
    const auto rows = parseCsv(res.body);
    for (size_t i = 0; i < rows.size(); ++i) {
        const auto& row = rows[i];
        const std::string colA = trim(row.size() > 0 ? row[0] : "");
        const std::string colB = trim(row.size() > 1 ? row[1] : "");
        const std::string colC = trim(row.size() > 2 ? row[2] : "");
        if (lower(colA).rfind("matchday", 0) == 0) {
            // The MATCHDAY row itself often carries the first link; its
            // window sits on one of the NEXT rows, so look ahead for it
            // before this row's own cells are taken.
            matchday = colA; winFrom.clear(); winTill.clear();
            for (size_t j = i + 1; j < rows.size() && j <= i + 3; ++j) {
                const std::string a = trim(rows[j].size() > 0 ? rows[j][0] : "");
                std::string f, t;
                if (parseWindow(a, &f, &t)) { winFrom = f; winTill = t; break; }
                if (lower(a).rfind("matchday", 0) == 0) break;
            }
        } else if (!colA.empty()) { std::string f, t; if (parseWindow(colA, &f, &t)) { winFrom = f; winTill = t; } }
        if (colB.empty() || colC.empty() || winFrom.empty()) continue;
        for (const auto& url : splitLinks(colC)) {
            try {
                db->query(
                    "INSERT INTO film_links (source_id, matchday_label, window_start, window_end, home_team_text, url) "
                    "VALUES ($1::int, NULLIF($2,''), $3::date, $4::date, $5, $6) "
                    "ON CONFLICT (source_id, home_team_text, url) DO UPDATE SET "
                    "  matchday_label = EXCLUDED.matchday_label, window_start = EXCLUDED.window_start, "
                    "  window_end = EXCLUDED.window_end, last_seen_at = now(), removed_at = NULL",
                    {sid, matchday, winFrom, winTill, colB, url});
                upserts++;
            } catch (const std::exception& e) {
                std::cerr << "[film sync] upsert failed (" << colB << "): " << e.what() << std::endl;
            }
        }
    }
    try {
        // A row gone from the sheet goes soft here too (and heals on return).
        db->query("UPDATE film_links SET removed_at = now() WHERE source_id = $1::int AND removed_at IS NULL AND last_seen_at < $2::timestamptz",
                  {sid, t0});
        db->query("UPDATE film_sources SET fetched_at = now() WHERE id = $1::int", {sid});
    } catch (const std::exception& e) {
        std::cerr << "[film sync] sweep failed: " << e.what() << std::endl;
    }
    std::cout << "[film sync] source " << sourceId << ": " << upserts << " link(s)" << std::endl;
}
