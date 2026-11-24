#include "GoogleSheetRoster.h"

#include <curl/curl.h>

#include <sstream>
#include <vector>

#include <cctype>
#include <iostream>

namespace {

constexpr const char* kSheetsBase = "https://docs.google.com/spreadsheets/d/";
constexpr const char* kUserAgent  = "footballhome-cpp/1.0 (official roster print)";
constexpr long kConnectTimeoutSec = 10;
constexpr long kTotalTimeoutSec   = 90;    // the export is built on request, headshots and all

size_t writeBody(void* contents, size_t size, size_t nmemb, void* userp) {
    static_cast<std::string*>(userp)->append(static_cast<char*>(contents), size * nmemb);
    return size * nmemb;
}

struct Reply { long status = 0; std::string body, error; bool ok() const { return error.empty() && status >= 200 && status < 300; } };

// HTTP/1.1 on purpose: the export of a large workbook aborts mid-stream
// over HTTP/2 (the same thing CasaRosterScraper.js works around).
Reply get(const std::string& url) {
    Reply r;
    CURL* curl = curl_easy_init();
    if (!curl) { r.error = "curl_easy_init failed"; return r; }
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERAGENT, kUserAgent);
    curl_easy_setopt(curl, CURLOPT_HTTP_VERSION, static_cast<long>(CURL_HTTP_VERSION_1_1));
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 5L);
    curl_easy_setopt(curl, CURLOPT_PROTOCOLS_STR, "https");
    curl_easy_setopt(curl, CURLOPT_REDIR_PROTOCOLS_STR, "https");
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, kConnectTimeoutSec);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, kTotalTimeoutSec);
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeBody);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &r.body);
    const CURLcode rc = curl_easy_perform(curl);
    if (rc != CURLE_OK) r.error = curl_easy_strerror(rc);
    else curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &r.status);
    curl_easy_cleanup(curl);
    return r;
}

std::string why(const Reply& r) { return r.error.empty() ? "HTTP " + std::to_string(r.status) : r.error; }

// Spreadsheet ids are URL-safe base64; anything else never reaches a URL.
bool validId(const std::string& id) {
    if (id.empty()) return false;
    for (unsigned char c : id) if (!std::isalnum(c) && c != '-' && c != '_') return false;
    return true;
}

// The htmlview page lists its tabs as
//   items.push({name: "Lighthouse Boys Club", pageUrl: "…gid=480494399", …
// → the gid of the tab with that exact name, or "".
std::string gidOfTab(const std::string& html, const std::string& tabName) {
    const std::string key = "name: \"" + tabName + "\"";
    const size_t at = html.find(key);
    if (at == std::string::npos) return {};
    const size_t end = html.find('}', at);
    const size_t g = html.find("gid=", at);
    if (g == std::string::npos || (end != std::string::npos && g > end)) return {};
    std::string gid;
    for (size_t i = g + 4; i < html.size() && std::isdigit(static_cast<unsigned char>(html[i])); i++) gid.push_back(html[i]);
    return gid;
}

} // namespace

GoogleSheetRoster::Result GoogleSheetRoster::fetch(const std::string& spreadsheetId, const std::string& tabName) {
    Result out;
    if (!validId(spreadsheetId) || tabName.empty()) { out.error = "the roster sheet is not set up correctly"; return out; }
    const std::string base = std::string(kSheetsBase) + spreadsheetId;

    auto tabs = get(base + "/htmlview");
    if (!tabs.ok()) { out.error = "the league's roster sheet did not open (" + why(tabs) + ")"; return out; }
    const std::string gid = gidOfTab(tabs.body, tabName);
    if (gid.empty()) { out.error = "the league's roster sheet has no tab named \"" + tabName + "\""; return out; }

    auto pdf = get(base + "/export?format=pdf&gid=" + gid);
    if (!pdf.ok()) { out.error = "the roster did not download (" + why(pdf) + ")"; return out; }
    if (pdf.body.rfind("%PDF", 0) != 0) { out.error = "the league's roster sheet sent something that is not a PDF"; return out; }

    // Player NAMES off the same tab as CSV (mig 620) — the sheet carries a
    // "First Name,Last Name,…" header, then one numbered row per player.
    // Best-effort: a parse failure never fails the pull (the PDF is the
    // deliverable); names just stay empty.
    if (auto csv = get(base + "/export?format=csv&gid=" + gid); csv.ok()) {
        auto fields = [](const std::string& line) {
            std::vector<std::string> f;
            std::string cur; bool q = false;
            for (char c : line) {
                if (c == '"') q = !q;
                else if (c == ',' && !q) { f.push_back(cur); cur.clear(); }
                else cur.push_back(c);
            }
            f.push_back(cur);
            return f;
        };
        std::istringstream in(csv.body);
        std::string line;
        int firstCol = -1, lastCol = -1;
        while (std::getline(in, line)) {
            if (!line.empty() && line.back() == '\r') line.pop_back();
            auto f = fields(line);
            if (firstCol < 0) {
                for (size_t i = 0; i < f.size(); i++) {
                    if (f[i] == "First Name") firstCol = static_cast<int>(i);
                    if (f[i] == "Last Name")  lastCol  = static_cast<int>(i);
                }
                continue;
            }
            if (static_cast<int>(f.size()) <= lastCol) continue;
            const std::string& fn = f[firstCol];
            const std::string& ln = f[lastCol];
            if (fn.empty() || ln.empty()) continue;
            out.names.push_back(fn + " " + ln);
        }
    }

    out.pdf = std::move(pdf.body);
    out.ok = true;
    std::cerr << "[GoogleSheetRoster] tab \"" << tabName << "\" (gid " << gid << "): " << out.pdf.size() << " bytes" << std::endl;
    return out;
}

// ── #dual-rostering (mig 1774) ─────────────────────────────────────────
// The htmlview page's tab list, every entry:
//   items.push({name: "F\x26M FC (Liga 1)", pageUrl: "…gid=682688852", …
// The name is a JavaScript string (\xNN, \uNNNN, \" escapes).
std::vector<GoogleSheetRoster::Tab> GoogleSheetRoster::tabs(const std::string& spreadsheetId, std::string& error) {
    std::vector<Tab> out;
    if (!validId(spreadsheetId)) { error = "the roster sheet is not set up correctly"; return out; }
    auto page = get(std::string(kSheetsBase) + spreadsheetId + "/htmlview");
    if (!page.ok()) { error = "the league's roster sheet did not open (" + why(page) + ")"; return out; }
    const std::string& s = page.body;
    const std::string key = "items.push({name: \"";
    auto utf8 = [](unsigned cp, std::string& to) {
        if (cp < 0x80) to.push_back(static_cast<char>(cp));
        else if (cp < 0x800) { to.push_back(static_cast<char>(0xC0 | (cp >> 6))); to.push_back(static_cast<char>(0x80 | (cp & 0x3F))); }
        else { to.push_back(static_cast<char>(0xE0 | (cp >> 12))); to.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F))); to.push_back(static_cast<char>(0x80 | (cp & 0x3F))); }
    };
    for (size_t p = 0; (p = s.find(key, p)) != std::string::npos;) {
        p += key.size();
        Tab tab;
        size_t i = p;
        for (; i < s.size() && s[i] != '"'; i++) {
            if (s[i] != '\\' || i + 1 >= s.size()) { tab.name.push_back(s[i]); continue; }
            const char e = s[++i];
            const size_t digits = e == 'x' ? 2 : e == 'u' ? 4 : 0;
            if (digits && i + digits < s.size()) {
                try { utf8(static_cast<unsigned>(std::stoul(s.substr(i + 1, digits), nullptr, 16)), tab.name); } catch (...) {}
                i += digits;
            } else tab.name.push_back(e);
        }
        const size_t end = s.find('}', i);
        const size_t g = s.find("gid=", i);
        if (g == std::string::npos || (end != std::string::npos && g > end)) continue;
        for (size_t k = g + 4; k < s.size() && std::isdigit(static_cast<unsigned char>(s[k])); k++) tab.gid.push_back(s[k]);
        if (!tab.name.empty() && !tab.gid.empty()) out.push_back(tab);
        p = i;
    }
    if (out.empty()) error = "the league's roster sheet lists no tabs";
    return out;
}

std::string GoogleSheetRoster::csv(const std::string& spreadsheetId, const std::string& gid, std::string& error) {
    if (!validId(spreadsheetId) || gid.empty() || gid.find_first_not_of("0123456789") != std::string::npos) { error = "the roster sheet is not set up correctly"; return {}; }
    auto r = get(std::string(kSheetsBase) + spreadsheetId + "/export?format=csv&gid=" + gid);
    if (!r.ok()) { error = "the tab did not download (" + why(r) + ")"; return {}; }
    if (r.body.rfind("<!DOCTYPE", 0) == 0 || r.body.rfind("<html", 0) == 0) { error = "the league's roster sheet is not shared by link any more"; return {}; }
    return r.body;
}
