#include "GoogleSheetRoster.h"

#include <curl/curl.h>

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

    out.pdf = std::move(pdf.body);
    out.ok = true;
    std::cerr << "[GoogleSheetRoster] tab \"" << tabName << "\" (gid " << gid << "): " << out.pdf.size() << " bytes" << std::endl;
    return out;
}
