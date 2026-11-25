#include "LeagueTableReaders.h"

#include <chrono>
#include <map>
#include <vector>
#include <cstdlib>
#include <regex>
#include <algorithm>
#include <cctype>
#include <strings.h>
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
    if (feedSystem == "html_table")             return std::make_unique<HtmlTableReader>();
    if (feedSystem == "text_grid")              return std::make_unique<TextGridReader>();
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

// The locator is one article, or several pages joined by " ; " — a season whose standings live in
// templates of their own (MLS NEXT Pro: "Template:2026 MLS Next Pro Eastern Conference table ;
// Template:… Western Conference table").  A table with no section= is named from its page:
// "2026 MLS Next Pro Eastern Conference table" → "Eastern Conference".
json WikipediaSportsTableReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    if (locator.find(" ; ") != std::string::npos) {
        json all = json::array();
        size_t from = 0;
        for (;;) {
            const size_t cut = locator.find(" ; ", from);
            const std::string page = trim(locator.substr(from, cut == std::string::npos ? std::string::npos : cut - from));
            std::string title = std::regex_replace(page, std::regex("^Template:"), "");
            title = std::regex_replace(title, std::regex("^\\d{4}(-\\d{2,4})?\\s+"), "");
            title = std::regex_replace(title, std::regex("\\s+table$", std::regex::icase), "");
            if (title.size() > leagueName.size() && strncasecmp(title.c_str(), leagueName.c_str(), leagueName.size()) == 0) title = trim(title.substr(leagueName.size()));
            std::string pageNote;
            for (auto& t : read(page, title.empty() ? leagueName : title, pageNote)) all.push_back(t);
            if (!pageNote.empty()) note += (note.empty() ? "" : "; ") + pageNote;
            if (cut == std::string::npos) break;
            from = cut + 3;
        }
        if (!all.empty()) note.clear();
        return all;
    }
    const std::string text = wikitext(locator, note);
    if (text.empty()) return json::array();
    static const std::regex kSection("section\\s*=\\s*([^\\n|]+)");
    static const std::regex kOrder("team_order\\s*=\\s*([^\\n|]+)");
    static const std::regex kStat("\\|\\s*(win|draw|loss|gf|ga)_([A-Za-z0-9]+)\\s*=\\s*(-?\\d+)");
    // a name runs to the next | that is not inside [[ ]] or {{ }} — some tables put every name_X on one line
    static const std::regex kName("\\|\\s*name_([A-Za-z0-9]+)\\s*=\\s*((?:\\[\\[[^\\]]*\\]\\]|\\{\\{[^}]*\\}\\}|[^\\n|\\[{])*)");
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


// ── league sites with a plain table (Midwest PL, Mountain PL, Upstate PL) ──────────────

HtmlStandingsReader::Columns HtmlStandingsReader::columns(const std::vector<std::string>& head) {
    Columns c;
    for (int i = 0; i < static_cast<int>(head.size()); ++i) {
        std::string h;
        for (char ch : head[i]) if (!std::isspace(static_cast<unsigned char>(ch))) h.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(ch))));
        // "P" is the place when it heads the table (Mountain PL), the games played elsewhere (Midwest PL)
        if (c.pos < 0 && c.name < 0 && (h == "P" || h == "POS" || h == "#" || h == "RK" || h == "RANK" || h == "PL")) c.pos = i;
        else if (h == "TEAM" || h == "CLUB" || h == "TEAMS" || h == "CLUBS") c.name = i;
        else if (h == "GP" || h == "MP" || h == "P" || h == "PLD" || h == "PL" || h == "GAMES") c.played = i;
        else if (h == "W") c.w = i;
        else if (h == "D" || h == "T") c.d = i;
        else if (h == "L") c.l = i;
        else if (h == "W-D-L" || h == "W-T-L" || h == "W/D/L") c.wdl = i;
        else if (h == "GF" || h == "F") c.gf = i;
        else if (h == "GA" || h == "A") c.ga = i;
        else if (h == "GD" || h == "+/-") c.gd = i;
        else if (h == "PTS" || h == "PT" || h == "POINTS") c.pts = i;
    }
    return c;
}

json HtmlStandingsReader::team(const Columns& c, const std::vector<std::string>& cells) {
    auto cell = [&](int i) { return i >= 0 && i < static_cast<int>(cells.size()) ? trim(cells[i]) : std::string{}; };
    std::string name = cell(c.name);
    // a clinched / out marker in front of the name ("C - Spindles United FC", "X - Collar City FC")
    static const std::regex kMark("^[A-Za-z]{1,3}\\s+-\\s+");
    name = trim(std::regex_replace(name, kMark, ""));
    const std::string pts = cell(c.pts);
    if (name.empty() || pts.empty() || !std::isdigit(static_cast<unsigned char>(pts[0]))) return nullptr;
    int w = whole(cell(c.w)), d = whole(cell(c.d)), l = whole(cell(c.l));
    if (c.wdl >= 0) {   // "5-2-3"
        const std::string s = cell(c.wdl);
        const auto a = s.find('-'), b = a == std::string::npos ? a : s.find('-', a + 1);
        if (b != std::string::npos) { w = whole(s.substr(0, a)); d = whole(s.substr(a + 1, b - a - 1)); l = whole(s.substr(b + 1)); }
    }
    int gf = whole(cell(c.gf)), ga = whole(cell(c.ga));
    // a table that gives only the goal difference (Upstate PL): carried as goals for / against
    // so the difference shows right — the two figures themselves are not known
    if (c.gf < 0 && c.ga < 0 && c.gd >= 0) { const int gd = whole(cell(c.gd)); gf = gd > 0 ? gd : 0; ga = gd < 0 ? -gd : 0; }
    json t = {{"name", name}, {"played", c.played >= 0 ? whole(cell(c.played)) : w + d + l}, {"wins", w}, {"draws", d}, {"losses", l},
              {"goals_for", gf}, {"goals_against", ga}, {"points", whole(pts)}};
    if (c.pos >= 0 && !cell(c.pos).empty() && std::isdigit(static_cast<unsigned char>(cell(c.pos)[0]))) t["position"] = whole(cell(c.pos));
    return t;
}

std::string HtmlStandingsReader::text(const std::string& markup) {
    std::string out;
    bool tag = false;
    for (size_t i = 0; i < markup.size(); ++i) {
        // a script or style block is not text
        if (!tag && markup.compare(i, 7, "<script") == 0) { const auto e = markup.find("</script>", i); if (e == std::string::npos) break; i = e + 8; out.push_back(' '); continue; }
        if (!tag && markup.compare(i, 6, "<style") == 0)  { const auto e = markup.find("</style>", i);  if (e == std::string::npos) break; i = e + 7; out.push_back(' '); continue; }
        const char ch = markup[i];
        if (ch == '<') { tag = true; out.push_back(' '); }
        else if (ch == '>') tag = false;
        else if (!tag) out.push_back(ch);
    }
    out = unescape(out);
    std::string folded;
    for (char ch : out) {
        if (std::isspace(static_cast<unsigned char>(ch))) { if (!folded.empty() && folded.back() != ' ') folded.push_back(' '); }
        else folded.push_back(ch);
    }
    return trim(folded);
}

std::string HtmlStandingsReader::page(const std::string& locator, std::vector<std::string>& names, std::string& note) {
    std::vector<std::string> parts;
    for (size_t from = 0;;) {
        const size_t cut = locator.find(" ; ", from);
        parts.push_back(trim(locator.substr(from, cut == std::string::npos ? std::string::npos : cut - from)));
        if (cut == std::string::npos) break;
        from = cut + 3;
    }
    names.assign(parts.begin() + 1, parts.end());
    auto resp = get(parts[0], true, {{"Accept", "text/html"}});
    if (!resp.ok()) { note = httpNote(resp); return {}; }
    return resp.body;
}

json HtmlTableReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    std::vector<std::string> names;
    const std::string html = page(locator, names, note);
    if (html.empty()) return json::array();
    // every <table>…</table>, and the text since the table before it (its heading, when the page gives one)
    struct Found { std::string body, before; };
    std::vector<Found> found;
    for (size_t at = 0, prev = 0;;) {
        const size_t a = html.find("<table", at);
        if (a == std::string::npos) break;
        const size_t b = html.find("</table>", a);
        if (b == std::string::npos) break;
        found.push_back({html.substr(a, b - a), html.substr(prev, a - prev)});
        at = prev = b + 8;
    }
    json tables = json::array();
    for (size_t k = 0; k < found.size(); ++k) {
        // rows, then cells: <th> or <td>
        std::vector<std::vector<std::string>> rows;
        const std::string& t = found[k].body;
        for (size_t r = t.find("<tr"); r != std::string::npos; r = t.find("<tr", r + 3)) {
            const size_t re = t.find("</tr>", r);
            const std::string row = t.substr(r, (re == std::string::npos ? t.size() : re) - r);
            std::vector<std::string> cells;
            for (size_t c = 0;;) {
                const size_t th = row.find("<th", c), td = row.find("<td", c), o = std::min(th, td);
                if (o == std::string::npos) break;
                const size_t open = row.find('>', o);
                if (open == std::string::npos) break;
                // the cell runs to the next cell or the row's end
                const size_t nth = row.find("<th", open), ntd = row.find("<td", open), next = std::min({nth, ntd, row.size()});
                cells.push_back(text(row.substr(open + 1, next - open - 1)));
                c = next;
            }
            if (!cells.empty()) rows.push_back(cells);
        }
        if (rows.empty()) continue;
        const Columns cols = columns(rows[0]);
        if (!cols.ok()) continue;
        json teams = json::array();
        int pos = 0;
        for (size_t r = 1; r < rows.size(); ++r) {
            json tm = team(cols, rows[r]);
            if (tm.is_null()) continue;
            if (!tm.contains("position")) tm["position"] = pos + 1;
            ++pos;
            teams.push_back(tm);
        }
        // its name: the locator's, in page order; else the last words before it
        std::string name = k < names.size() ? names[k] : std::string{};
        if (name.empty()) {
            const std::string before = found[k].before;
            std::vector<std::string> bits;
            size_t from = 0;
            for (size_t lt = before.find('<'); lt != std::string::npos; lt = before.find('<', lt + 1)) {
                const std::string piece = text(before.substr(from, lt - from));
                if (!piece.empty()) bits.push_back(piece);
                const size_t gt = before.find('>', lt);
                if (gt == std::string::npos) break;
                if (before.compare(lt, 7, "<script") == 0) { const auto e = before.find("</script>", lt); lt = e == std::string::npos ? before.size() : e; }
                from = (before.compare(lt, 9, "</script>") == 0 ? lt + 9 : gt + 1);
            }
            if (!bits.empty() && bits.back().size() <= 60) name = bits.back();
        }
        if (teams.empty()) continue;
        tables.push_back({{"name", name.empty() ? leagueName : name}, {"teams", teams}});
    }
    if (tables.empty()) note = "no standings table on the page";
    return tables;
}

json TextGridReader::read(const std::string& locator, const std::string& leagueName, std::string& note) {
    std::vector<std::string> names;
    const std::string html = page(locator, names, note);
    if (html.empty()) return json::array();
    // the text boxes, in page order
    std::vector<std::string> boxes;
    const std::string open = "<div class=\"sqs-html-content\"";
    for (size_t at = html.find(open); at != std::string::npos; at = html.find(open, at + 1)) {
        const size_t a = html.find('>', at), b = a == std::string::npos ? a : html.find("</div>", a);
        if (b == std::string::npos) break;
        boxes.push_back(text(html.substr(a + 1, b - a - 1)));
    }
    json tables = json::array();
    size_t k = 0;
    for (size_t i = 0; i < boxes.size(); ++i) {
        // a heading run: consecutive boxes that are all column names, with a club and a points column
        size_t n = 0;
        std::vector<std::string> head;
        while (i + n < boxes.size()) {
            const Columns one = columns({boxes[i + n]});
            const bool known = one.pos >= 0 || one.name >= 0 || one.played >= 0 || one.w >= 0 || one.d >= 0 || one.l >= 0 || one.wdl >= 0 || one.gf >= 0 || one.ga >= 0 || one.gd >= 0 || one.pts >= 0;
            if (!known) break;
            head.push_back(boxes[i + n]);
            ++n;
        }
        const Columns cols = columns(head);
        if (n < 3 || !cols.ok()) continue;
        json teams = json::array();
        size_t r = i + n;
        for (; r + n <= boxes.size(); r += n) {
            std::vector<std::string> cells(boxes.begin() + static_cast<long>(r), boxes.begin() + static_cast<long>(r + n));
            json tm = team(cols, cells);
            if (tm.is_null()) break;   // the table has ended
            if (!tm.contains("position")) tm["position"] = static_cast<int>(teams.size()) + 1;
            teams.push_back(tm);
        }
        if (!teams.empty()) tables.push_back({{"name", k < names.size() && !names[k].empty() ? names[k] : leagueName}, {"teams", teams}});
        ++k;
        i = r > 0 ? r - 1 : r;
    }
    if (tables.empty()) note = "no standings grid on the page";
    return tables;
}
