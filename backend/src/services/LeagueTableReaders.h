#pragma once

// LeagueTableReaders — the standings of the leagues drawn AROUND the APSL pyramid
// on #apsl-pyramid (pro_leagues, migs 1833 / 1838 / 1839 / 1841): the pro divisions
// above it, the continental cup over those, and the national leagues beside it.
//
// One class per place a table can be read from, each a child of LeagueTableReader
// (owner 2026-11-24: "use oop like we do for apsl and casa for these other league so
// they can extend and do what is needed for acccess").  A child knows its own URL
// shape, headers, pacing and markup; all of them answer the same thing:
//
//     [ { "name": <table or division>, "teams": [ { "name", "position"?, "played"?,
//         "wins"?, "draws"?, "losses"?, "goals_for"?, "goals_against"?, "points"? } ] } ]
//
// which fh_pro_league_load() stores.  An empty array + a note = the read failed and
// the previous tables stay.
//
//   feed_system      class                    reads
//   'espn'           EspnStandingsReader      ESPN's public standings JSON (a table per conference)
//   'espn_teams'     EspnTeamsReader          ESPN's team list of a cup's season — clubs, no figures
//   'modular11'      Modular11Reader          modular11.com division tables (USL League Two)
//   'google_sheet'   GoogleSheetTableReader   a public Google Sheet's standings tab (The League for Clubs)
//   'wikipedia_sports_table'  WikipediaSportsTableReader  a season article's {{Sports table}} blocks (NPSL)
//   'wikipedia_club_list'     WikipediaClubListReader     an article section's club table — names, no figures (UPSL)
//
// Wikipedia stands in where the league's own tables cannot be read (owner 2026-11-24: "you
// can get upsl pyramind on wikipedia" · "same wiht npsl"): NPSL's are behind an API that
// answers 403, UPSL's behind a Cloudflare challenge.  The league's box links to the article.
//
// A league whose table cannot be read without getting round a block (UPSL: a
// Cloudflare challenge) gets no reader and no spot — never work around one.
// Readers that scrape a league's own pages go out through the scraper-VPN proxy,
// not the home address (owner: "dont' get ip banned lol use vpn").  The proxy lets through
// only the hosts in .docker/scraper/tinyproxy.filter — a new league site needs a line there.

#include <memory>
#include <string>

#include "../core/HttpClient.h"
#include <vector>
#include <string>
#include "../third_party/json.hpp"

class LeagueTableReader {
public:
    virtual ~LeagueTableReader() = default;
    // locator = pro_leagues.feed_locator; leagueName names a table the feed leaves unnamed.
    virtual nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) = 0;
    // The reader for a feed_system; nullptr when there is none.
    static std::unique_ptr<LeagueTableReader> forSystem(const std::string& feedSystem);

protected:
    // GET as a browser would; viaVpn sends it through the scraper-VPN proxy.
    static HttpClient::Response get(const std::string& url, bool viaVpn, const HttpClient::Headers& extra = {});
    static std::string httpNote(const HttpClient::Response& r);
};

class EspnStandingsReader : public LeagueTableReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

class EspnTeamsReader : public LeagueTableReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// locator = the league's page under modular11.com/league-standings/ ("league-two").
// The page names the divisions (its <option>s) and the season / gender / event ids;
// each division is then one request, a second apart.
class Modular11Reader : public LeagueTableReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// locator = "<spreadsheet id>/<tab>".  The tab is blocks of: a title row
// ("Region · Division · 2026"), a "Club" heading row, then rank, club, GP, W, D, L,
// GF, GA, GD, Pts.
class GoogleSheetTableReader : public LeagueTableReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// League sites that publish a plain standings table (owner 2026-11-24: "do midwest upstate and
// mountain").  Shared: reading a heading row (POS / TEAM or CLUB / GP or MP or P / W D L or W-D-L /
// GF or F / GA or A / GD / PTS, in any order) and turning a row into a team.  The locator is the
// page, then optionally the tables' names in page order: "<url> ; <name> ; <name> …" — names are
// data, given where the page does not name its tables near them.  Pages go through the VPN.
class HtmlStandingsReader : public LeagueTableReader {
protected:
    struct Columns { int pos = -1, name = -1, played = -1, w = -1, d = -1, l = -1, wdl = -1, gf = -1, ga = -1, gd = -1, pts = -1;
                     bool ok() const { return name >= 0 && pts >= 0; } };
    static Columns columns(const std::vector<std::string>& head);
    static nlohmann::json team(const Columns& c, const std::vector<std::string>& cells);   // null when the row is not a team
    static std::string text(const std::string& markup);   // tags dropped, entities read, spaces folded
    // the page (through the VPN) and the names after it; "" + note when it cannot be read
    static std::string page(const std::string& locator, std::vector<std::string>& names, std::string& note);
};

// locator = a page with one <table> per division (Midwest PL /standings, Mountain PL /standings).
// A table is named from the locator's names in order, else from the text just before it.
class HtmlTableReader : public HtmlStandingsReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// locator = a Squarespace page whose table is a grid of text boxes (Upstate PL /standings): the
// boxes in page order are the heading cells, then each club's cells, row after row.
class TextGridReader : public HtmlStandingsReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// Wikipedia readers share the fetch: the article's wikitext through the MediaWiki API.
class WikipediaReader : public LeagueTableReader {
protected:
    // "" + note when the article cannot be read.
    static std::string wikitext(const std::string& page, std::string& note);
    // [[Target|Shown]] → Shown, [[Target]] → Target, {{white|X}} → X; refs, templates and quote marks dropped.
    static std::string plain(std::string s);
};

// locator = the season article's title.  Every {{#invoke:Sports table|main|…}} block is a
// table: section= names it, team_order= ranks it, win_/draw_/loss_/gf_/ga_<CODE> are the
// figures, name_<CODE> the club.  Points = 3 a win, 1 a draw.
class WikipediaSportsTableReader : public WikipediaReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};

// locator = "<article title>#<section heading>".  The section's first wikitable lists the
// clubs under a rowspan cell per conference (and, when the heading row has a Region column,
// per region): one table per conference, named "Region · Conference", clubs without figures.
class WikipediaClubListReader : public WikipediaReader {
public:
    nlohmann::json read(const std::string& locator, const std::string& leagueName, std::string& note) override;
};
