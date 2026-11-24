#include "LeagueTableReaders.h"

#include <chrono>
#include <map>
#include <vector>
#include <cstdlib>
#include <regex>
#include <thread>

using json = nlohmann::json;

namespace {

// The scraper-VPN container's proxy — the same door TeamPass pages go through (PyramidSync).
std::string vpnProxy() {
    const char* env = std::getenv("TEAMPASS_PROXY_URL");
    return env && *env ? env : "http://footballhome_scraper:3128";
}

std::string trim(const std::string& s) {
    const auto a = s.find_first_not_of(" \t\r\n"), b = s.find_last_not_of(" \t\r\n");
    return a == std::string::npos ? std::string{} : s.substr(a, b - a + 1);
}

// &amp; &#39; &quot; and friends, as a club name carries them in markup.
std::string unescape(std::string s) {
    static const std::pair<const char*, const char*> kEntities[] = {
        {"&amp;", "&"}, {"&#39;", "'"}, {"&#039;", "'"}, {"&apos;", "'"}, {"&quot;", "\""}, {"&lt;", "<"}, {"&gt;", ">"}, {"&nbsp;", " "}};
    for (const auto& [from, to] : kEntities)
        for (size_t at = s.find(from); at != std::string::npos; at = s.find(from, at + 1)) s.replace(at, std::string(from).size(), to);
    return s;
}

int whole(const std::string& s) { try { return std::stoi(trim(s)); } catch (...) { return 0; } }

}  // namespace

// ── the base ───────────────────────────────────────────────────────────
HttpClient::Response LeagueTableReader::get(const std::string& url, bool viaVpn, const HttpClient::Headers& extra) {
    HttpClient http;
    http.setTotalTimeoutSec(25);
    if (viaVpn) http.setProxy(vpnProxy());
    HttpClient::Headers headers = {{"User-Agent", "Mozilla/5.0 (FootballHome)"}};
    headers.insert(headers.end(), extra.begin(), extra.end());
    return http.get(url, headers);
}

std::string LeagueTableReader::httpNote(const HttpClient::Response& r) {
    return "HTTP " + std::to_string(r.status) + (r.error.empty() ? "" : " " + r.error);
}

std::unique_ptr<LeagueTableReader> LeagueTableReader::forSystem(const std::string& feedSystem) {
    if (feedSystem == "espn")         return std::make_unique<EspnStandingsReader>();
    if (feedSystem == "espn_teams")   return std::make_unique<EspnTeamsReader>();
    if (feedSystem == "modular11")    return std::make_unique<Modular11Reader>();
    if (feedSystem == "google_sheet") return std::make_unique<GoogleSheetTableReader>();
    if (feedSystem == "wikipedia_sports_table") return std::make_unique<WikipediaSportsTableReader>();
    if (feedSystem == "wikipedia_club_list")    return std::make_unique<WikipediaClubListReader>();
    return nullptr;
}

// ── ESPN standings: a table per conference under `children`, or one at the top ──
json EspnStandingsReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    auto resp = get("https://site.api.espn.com/apis/v2/sports/soccer/" + HttpClient::urlEncode(locator) + "/standings", false, {{"Accept", "application/json"}});
    json body = resp.ok() ? json::parse(resp.body, nullptr, false) : json(json::value_t::discarded);
    json tables = json::array();
    auto readTable = [&](const json& node) {
        if (!node.is_object() || !node.contains("standings") || !node["standings"].contains("entries")) return;
        json teams = json::array();
        for (const auto& e : node["standings"]["entries"]) {
            if (!e.contains("team") || !e.contains("stats")) continue;
            json t = {{"name", e["team"].value("displayName", "")}};
            auto stat = [&](const char* espn, const char* ours) {
                for (const auto& st : e["stats"])
                    if (st.value("name", "") == espn && st.contains("value") && st["value"].is_number()) { t[ours] = static_cast<int>(st["value"].get<double>()); return; }
            };
            stat("rank", "position"); stat("gamesPlayed", "played"); stat("wins", "wins"); stat("ties", "draws");
            stat("losses", "losses"); stat("pointsFor", "goals_for"); stat("pointsAgainst", "goals_against"); stat("points", "points");
            if (!t["name"].get<std::string>().empty()) teams.push_back(t);
        }
        if (!teams.empty()) tables.push_back({{"name", node.value("name", leagueName)}, {"teams", teams}});
    };
    if (body.is_object()) {
        if (body.contains("children") && body["children"].is_array())
            for (const auto& c : body["children"]) readTable(c);
        if (tables.empty()) readTable(body);
    }
    if (tables.empty()) note = "no table in the feed (" + httpNote(resp) + ")";
    return tables;
}

// ── ESPN team list: a knockout cup's field for the season in play ──────
// One table named after the season, the clubs with no figures.  Between editions the
// feed still answers the last one played — the current field.
json EspnTeamsReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    auto resp = get("https://site.api.espn.com/apis/site/v2/sports/soccer/" + HttpClient::urlEncode(locator) + "/teams", false, {{"Accept", "application/json"}});
    json body = resp.ok() ? json::parse(resp.body, nullptr, false) : json(json::value_t::discarded);
    json clubs = json::array();
    std::string season;
    if (body.is_object() && body.contains("sports") && body["sports"].is_array() && !body["sports"].empty()
        && body["sports"][0].contains("leagues") && body["sports"][0]["leagues"].is_array() && !body["sports"][0]["leagues"].empty()) {
        const json& lg = body["sports"][0]["leagues"][0];
        if (lg.contains("season") && lg["season"].is_object()) season = lg["season"].value("displayName", "");
        if (lg.contains("teams") && lg["teams"].is_array())
            for (const auto& e : lg["teams"])
                if (e.contains("team") && e["team"].is_object() && !e["team"].value("displayName", "").empty())
                    clubs.push_back({{"name", e["team"].value("displayName", "")}});
    }
    if (clubs.empty()) { note = "no clubs in the feed (" + httpNote(resp) + ")"; return json::array(); }
    return json::array({{{"name", season.empty() ? leagueName : season}, {"teams", clubs}}});
}

// ── modular11: the league page, then one request per division ──────────
// Page:     https://www.modular11.com/league-standings/<locator>
//             <option value="68">Mid-Atlantic</option> …          the divisions
//             name="year" … value="44"   name="gender" … value="1"   tournament: 24
// Division: /public_schedule/league/get_teams?tournament_type=league&UID_age=&UID_gender=
//             &UID_event=&list_type=29&UID_group=<division>       (what the page's own script asks)
//             rows of <div class="form_row row main_row" …>: container-rank, <p data-title="club">,
//             then PTS PPM MP W L T GF GA GD.
json Modular11Reader::read(const std::string& locator, const std::string&, std::string& note) {
    const std::string page = "https://www.modular11.com/league-standings/" + HttpClient::urlEncode(locator);
    auto home = get(page, true);
    if (!home.ok()) { note = "league page: " + httpNote(home); return json::array(); }
    std::smatch m;
    auto hidden = [&](const std::string& name) {
        return std::regex_search(home.body, m, std::regex("name=\"" + name + "\"[^>]*value=\"(\\d+)\"")) ? m[1].str() : std::string{};
    };
    const std::string age = hidden("year"), gender = hidden("gender");
    const std::string event = std::regex_search(home.body, m, std::regex("tournament:\\s*(\\d+)")) ? m[1].str() : std::string{};
    if (age.empty() || gender.empty() || event.empty()) { note = "league page: season, gender or event id not found"; return json::array(); }

    std::vector<std::pair<std::string, std::string>> divisions;   // id, name
    static const std::regex kOption("<option[^>]*value=\"(\\d+)\"[^>]*>\\s*([^<]+?)\\s*<");
    for (auto it = std::sregex_iterator(home.body.begin(), home.body.end(), kOption); it != std::sregex_iterator(); ++it)
        divisions.emplace_back((*it)[1].str(), unescape(trim((*it)[2].str())));
    if (divisions.empty()) { note = "league page: no divisions listed"; return json::array(); }

    static const std::regex kRow("<div class=\"form_row row main_row\"");
    static const std::regex kRank("container-rank[^>]*>\\s*(\\d+)");
    static const std::regex kName("<p data-title=\"([^\"]*)\"");
    static const std::regex kCell("gap-right-mobile-(?:lg|sm)[^>]*>\\s*(-?[0-9.]+)\\s*</div>");
    json tables = json::array();
    int failed = 0;
    for (const auto& [id, name] : divisions) {
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));   // a visitor's pace, not a crawler's
        auto resp = get("https://www.modular11.com/public_schedule/league/get_teams?tournament_type=league&UID_age=" + age + "&UID_gender=" + gender
                            + "&UID_event=" + event + "&list_type=29&UID_group=" + id,
                        true, {{"X-Requested-With", "XMLHttpRequest"}, {"Referer", page}});
        if (!resp.ok()) { ++failed; continue; }
        // one chunk per club: from its main_row to the next
        std::vector<size_t> starts;
        for (auto it = std::sregex_iterator(resp.body.begin(), resp.body.end(), kRow); it != std::sregex_iterator(); ++it) starts.push_back(static_cast<size_t>(it->position()));
        json teams = json::array();
        for (size_t i = 0; i < starts.size(); ++i) {
            const std::string row = resp.body.substr(starts[i], (i + 1 < starts.size() ? starts[i + 1] : resp.body.size()) - starts[i]);
            std::smatch nm, rk;
            if (!std::regex_search(row, nm, kName)) continue;
            std::vector<std::string> cells;
            for (auto it = std::sregex_iterator(row.begin(), row.end(), kCell); it != std::sregex_iterator() && cells.size() < 9; ++it) cells.push_back((*it)[1].str());
            if (cells.size() < 9) continue;   // PTS PPM MP W L T GF GA GD
            json t = {{"name", unescape(trim(nm[1].str()))}, {"points", whole(cells[0])}, {"played", whole(cells[2])}, {"wins", whole(cells[3])},
                      {"losses", whole(cells[4])}, {"draws", whole(cells[5])}, {"goals_for", whole(cells[6])}, {"goals_against", whole(cells[7])}};
            if (std::regex_search(row, rk, kRank)) t["position"] = whole(rk[1].str());
            if (!t["name"].get<std::string>().empty()) teams.push_back(t);
        }
        if (!teams.empty()) tables.push_back({{"name", name}, {"teams", teams}});
    }
    if (tables.empty()) note = "no division table could be read (" + std::to_string(failed) + " of " + std::to_string(divisions.size()) + " requests failed)";
    return tables;
}

// ── a public Google Sheet's standings tab (gviz JSON) ──────────────────
json GoogleSheetTableReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    const auto slash = locator.find('/');
    if (slash == std::string::npos) { note = "locator must be <spreadsheet id>/<tab>"; return json::array(); }
    auto resp = get("https://docs.google.com/spreadsheets/d/" + HttpClient::urlEncode(locator.substr(0, slash)) + "/gviz/tq?tqx=out:json&headers=1&sheet="
                        + HttpClient::urlEncode(locator.substr(slash + 1)), false);   // Google's own host, read directly (a published sheet; the VPN proxy is for league sites)
    if (!resp.ok()) { note = httpNote(resp); return json::array(); }
    // google.visualization.Query.setResponse({...});
    const auto open = resp.body.find('{'), close = resp.body.rfind('}');
    json body = open == std::string::npos || close == std::string::npos ? json(json::value_t::discarded)
                                                                         : json::parse(resp.body.substr(open, close - open + 1), nullptr, false);
    if (!body.is_object() || !body.contains("table") || !body["table"].contains("rows")) { note = "not a sheet answer"; return json::array(); }
    auto cell = [](const json& row, size_t i) -> json {
        if (!row.contains("c") || !row["c"].is_array() || i >= row["c"].size() || !row["c"][i].is_object() || !row["c"][i].contains("v")) return nullptr;
        return row["c"][i]["v"];
    };
    auto num = [&](const json& row, size_t i) { const json v = cell(row, i); return v.is_number() ? static_cast<int>(v.get<double>()) : 0; };
    json tables = json::array();
    std::string title;
    json teams = json::array();
    auto close_table = [&]() {
        if (!teams.empty()) tables.push_back({{"name", title.empty() ? leagueName : title}, {"teams", teams}});
        teams = json::array();
    };
    for (const auto& row : body["table"]["rows"]) {
        const json rank = cell(row, 0), name = cell(row, 1);
        if (!name.is_string()) continue;
        std::string text = trim(name.get<std::string>());
        if (rank.is_number()) {   // rank, club, GP, W, D, L, GF, GA, GD, Pts
            teams.push_back({{"name", text}, {"position", static_cast<int>(rank.get<double>())}, {"played", num(row, 2)}, {"wins", num(row, 3)},
                             {"draws", num(row, 4)}, {"losses", num(row, 5)}, {"goals_for", num(row, 6)}, {"goals_against", num(row, 7)}, {"points", num(row, 9)}});
        } else if (text != "Club") {   // a title row opens the next table: "Region · Division · 2026" → "Region · Division"
            close_table();
            const std::string dot = " \xC2\xB7 ";
            std::vector<std::string> parts;
            for (size_t at = 0;;) {
                const auto next = text.find(dot, at);
                const std::string part = trim(text.substr(at, next == std::string::npos ? std::string::npos : next - at));
                if (!part.empty() && part != "\xC2\xB7") parts.push_back(part);   // " ·  · 2026": a block the sheet left unnamed
                if (next == std::string::npos) break;
                at = next + dot.size();
            }
            if (parts.size() > 1) parts.pop_back();   // the season
            title.clear();
            for (const auto& p : parts) title += (title.empty() ? "" : dot) + p;
            if (parts.size() == 1 && parts[0].find_first_not_of("0123456789") == std::string::npos) title.clear();   // only a year: unnamed
        }
    }
    close_table();
    if (tables.empty()) note = "no table in the sheet";
    return tables;
}

// ── Wikipedia ──────────────────────────────────────────────────────────
std::string WikipediaReader::wikitext(const std::string& page, std::string& note) {
    HttpClient http;
    http.setTotalTimeoutSec(30);
    // Wikimedia asks automated readers to say what they are.
    auto resp = http.get("https://en.wikipedia.org/w/api.php?action=parse&prop=wikitext&format=json&redirects=1&page=" + HttpClient::urlEncode(page),
                         {{"User-Agent", "FootballHome/1.0 (league standings mirror)"}, {"Accept", "application/json"}});
    if (!resp.ok()) { note = "Wikipedia: HTTP " + std::to_string(resp.status); return {}; }
    json body = json::parse(resp.body, nullptr, false);
    if (!body.is_object() || !body.contains("parse") || !body["parse"].contains("wikitext") || !body["parse"]["wikitext"].contains("*")) {
        note = "Wikipedia: no such article";
        return {};
    }
    return body["parse"]["wikitext"]["*"].get<std::string>();
}

std::string WikipediaReader::plain(std::string s) {
    static const std::regex kRef("<ref[^>]*/>|<ref[^>]*>[\\s\\S]*?</ref>");
    static const std::regex kWhite("\\{\\{white\\|([^}]*)\\}\\}");
    static const std::regex kPiped("\\[\\[[^\\]|]*\\|([^\\]]*)\\]\\]");
    static const std::regex kLink("\\[\\[([^\\]]*)\\]\\]");
    static const std::regex kTemplate("\\{\\{[^}]*\\}\\}");
    static const std::regex kQuotes("'{2,}");
    s = std::regex_replace(s, kRef, "");
    s = std::regex_replace(s, kWhite, "$1");
    s = std::regex_replace(s, kPiped, "$1");
    s = std::regex_replace(s, kLink, "$1");
    s = std::regex_replace(s, kTemplate, "");
    s = std::regex_replace(s, kQuotes, "");
    return trim(unescape(s));
}

json WikipediaSportsTableReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    const std::string text = wikitext(locator, note);
    if (text.empty()) return json::array();
    static const std::regex kSection("section\\s*=\\s*([^\\n|]+)");
    static const std::regex kOrder("team_order\\s*=\\s*([^\\n|]+)");
    static const std::regex kStat("\\|\\s*(win|draw|loss|gf|ga)_([A-Za-z0-9]+)\\s*=\\s*(-?\\d+)");
    static const std::regex kName("\\|\\s*name_([A-Za-z0-9]+)\\s*=\\s*([^\\n]*)");
    const std::string open = "{{#invoke:Sports table|main";
    json tables = json::array();
    for (size_t at = text.find(open); at != std::string::npos; at = text.find(open, at + 1)) {
        // the block runs to the }} that closes it
        size_t end = at;
        for (int depth = 0; end + 1 < text.size(); ++end) {
            if (text[end] == '{' && text[end + 1] == '{') { ++depth; ++end; }
            else if (text[end] == '}' && text[end + 1] == '}') { --depth; ++end; if (depth == 0) break; }
        }
        const std::string block = text.substr(at, end - at);
        std::smatch m;
        std::map<std::string, std::map<std::string, int>> stats;
        std::map<std::string, std::string> names;
        std::vector<std::string> order;
        for (auto it = std::sregex_iterator(block.begin(), block.end(), kStat); it != std::sregex_iterator(); ++it) stats[(*it)[2].str()][(*it)[1].str()] = whole((*it)[3].str());
        for (auto it = std::sregex_iterator(block.begin(), block.end(), kName); it != std::sregex_iterator(); ++it) {
            names[(*it)[1].str()] = plain((*it)[2].str());
            order.push_back((*it)[1].str());   // the fallback order: as defined
        }
        if (std::regex_search(block, m, kOrder)) {
            std::vector<std::string> ranked;
            std::string code;
            for (char c : m[1].str() + ",") {
                if (c == ',') { code = trim(code); if (names.count(code)) ranked.push_back(code); code.clear(); }
                else code.push_back(c);
            }
            if (ranked.size() == names.size()) order = ranked;
        }
        json teams = json::array();
        int pos = 0;
        for (const auto& code : order) {
            auto& st = stats[code];
            const int w = st["win"], d = st["draw"], l = st["loss"];
            if (names[code].empty()) continue;
            teams.push_back({{"name", names[code]}, {"position", ++pos}, {"played", w + d + l}, {"wins", w}, {"draws", d}, {"losses", l},
                             {"goals_for", st["gf"]}, {"goals_against", st["ga"]}, {"points", 3 * w + d}});
        }
        if (!teams.empty()) tables.push_back({{"name", std::regex_search(block, m, kSection) ? trim(m[1].str()) : leagueName}, {"teams", teams}});
    }
    if (tables.empty()) note = "no Sports table in the article";
    return tables;
}

json WikipediaClubListReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    const auto hash = locator.find('#');
    if (hash == std::string::npos) { note = "locator must be <article>#<section>"; return json::array(); }
    const std::string text = wikitext(locator.substr(0, hash), note), heading = locator.substr(hash + 1);
    if (text.empty()) return json::array();
    // the section: from its === heading === to the next heading
    std::smatch m;
    std::string rest;
    {
        const std::regex head("\\n=+\\s*" + std::regex_replace(heading, std::regex("[.^$|()\\[\\]{}*+?\\\\]"), "\\$&") + "\\s*=+\\s*\\n");
        if (!std::regex_search(text, m, head)) { note = "no section " + heading; return json::array(); }
        rest = text.substr(static_cast<size_t>(m.position() + m.length()));
        static const std::regex kNextHead("\\n==+[^=]");
        if (std::regex_search(rest, m, kNextHead)) rest = rest.substr(0, static_cast<size_t>(m.position()));
    }
    const auto a = rest.find("{|"), b = rest.find("\n|}", a == std::string::npos ? 0 : a);
    if (a == std::string::npos || b == std::string::npos) { note = "no table in section " + heading; return json::array(); }
    const std::string table = rest.substr(a, b - a);

    // rows are split by "|-"; cells start a line with | or !
    std::vector<std::string> rows;
    for (size_t at = 0;;) {
        const auto next = table.find("\n|-", at);
        rows.push_back(table.substr(at, next == std::string::npos ? std::string::npos : next - at));
        if (next == std::string::npos) break;
        at = next + 3;
    }
    static const std::regex kSpan("^\\s*rowspan\\s*=\\s*\"?(\\d+)\"?[^|]*\\|([\\s\\S]*)$");
    bool hasRegion = false;
    int regionLeft = 0;
    std::string region, conference;
    std::vector<std::string> order;
    std::map<std::string, json> clubs;
    for (size_t r = 1; r < rows.size(); ++r) {
        std::vector<std::string> cells;
        std::string cell;
        bool header = false;
        const std::string row = "\n" + rows[r];
        for (size_t i = 0; i < row.size(); ++i) {
            if (row[i] == '\n' && i + 1 < row.size() && (row[i + 1] == '|' || row[i + 1] == '!')) {
                if (!trim(cell).empty()) cells.push_back(cell);
                header = header || row[i + 1] == '!';
                cell.clear();
                ++i;
            } else cell.push_back(row[i]);
        }
        if (!trim(cell).empty()) cells.push_back(cell);
        if (header) { for (const auto& c : cells) hasRegion = hasRegion || c.find("Region") != std::string::npos; continue; }
        --regionLeft;
        std::string club;
        for (const auto& c : cells) {
            if (std::regex_match(c, m, kSpan)) {
                if (hasRegion && regionLeft <= 0) { region = plain(m[2].str()); regionLeft = whole(m[1].str()); conference.clear(); }
                else conference = plain(m[2].str());
            } else if (club.empty()) club = plain(c);
        }
        if (club.empty() || conference.empty()) continue;
        const std::string name = region.empty() ? conference : region + " \xC2\xB7 " + conference;
        if (!clubs.count(name)) { clubs[name] = json::array(); order.push_back(name); }
        clubs[name].push_back({{"name", club}});
    }
    json tables = json::array();
    for (const auto& name : order) tables.push_back({{"name", name}, {"teams", clubs[name]}});
    if (tables.empty()) note = "no clubs in section " + heading;
    (void)leagueName;
    return tables;
}
