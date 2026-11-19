#include "PyramidForecast.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <functional>
#include <map>
#include <mutex>
#include <random>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

#include "../database/Database.h"
#include "../services/PyramidSync.h"

using nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
double r1(double v) { return std::round(v * 10.0) / 10.0; }
double r2(double v) { return std::round(v * 100.0) / 100.0; }
double r3(double v) { return std::round(v * 1000.0) / 1000.0; }

struct Team {
    int id = 0, clubId = 0, div = 0;   // pyramid_teams.id, club, index into divisions
    std::string ext, name;
    double att = 1, def = 1;
};
struct Game {
    long long id = 0; int h = -1, a = -1;   // team indexes
    std::string when; bool done = false;
    bool tbs = false, neutral = false;   // mig 1449: not scheduled by the league yet; no known ground
    int hs = 0, as = 0;
};
struct Division { int id = 0; std::string name; std::vector<int> teams; std::vector<json> zones; };

// Poisson P(k; l)
double pois(int k, double l) { return std::exp(-l + k * std::log(std::max(l, 1e-12)) - std::lgamma(k + 1.0)); }

// The goals model's fit (Maher 1982): an attack and a defence rating per
// team, 1.00 = average, shrunk toward average by `prior` average games; the
// league's goals a side a game; a home edge (√ of home ÷ away goals, shrunk
// by ten average games each side).  Shared by the conference and its feeder.
struct FitRes { int h, a, hs, as; };
void fitMaher(int n, const std::vector<FitRes>& done, double prior, double& avg, double& home,
              std::vector<double>& att, std::vector<double>& def) {
    att.assign(n, 1.0); def.assign(n, 1.0);
    double goals = 0, homeGoals = 0, awayGoals = 0;
    for (const auto& g : done) { goals += g.hs + g.as; homeGoals += g.hs; awayGoals += g.as; }
    avg = done.empty() ? 1.5 : goals / (2.0 * done.size());
    home = done.empty() ? 1.0 : std::sqrt((homeGoals + 10 * avg) / (awayGoals + 10 * avg));
    for (int it = 0; it < 200 && !done.empty(); ++it) {
        double moved = 0;
        for (int pass = 0; pass < 2; ++pass)
            for (int t = 0; t < n; ++t) {
                double got = 0, expd = 0;
                for (const auto& g : done) {
                    if (g.h != t && g.a != t) continue;
                    const bool isHome = g.h == t; const int o = isHome ? g.a : g.h;
                    const double edge = isHome ? home : 1.0 / home;
                    if (pass == 0) { got += isHome ? g.hs : g.as; expd += avg * edge * def[o]; }
                    else { got += isHome ? g.as : g.hs; expd += avg / edge * att[o]; }
                }
                const double v = (got + prior * avg) / (expd + prior * avg);
                double& slot = pass == 0 ? att[t] : def[t];
                moved = std::max(moved, std::fabs(v - slot)); slot = v;
            }
        if (moved < 1e-6) break;
    }
}

// 📉 The outlook (mig 1571): the conference's seasons (how many go down /
// come up) and each feeder league — its teams rated from their own games,
// the rest of their listed games played out `sims` times (points → goal
// difference → goals → lot), promotion = the top auto_places, plus the next
// playoff_places × the chance the feeder side beats our group-playoff winner.
json outlookJson(Database* db, const std::string& cid, int sims, double prior, double feederStayUpPct,
                 const std::string& ourPattern, std::mt19937_64& rng) {
    json out = {{"seasons", json::array()}, {"feeders", json::array()}};
    for (const auto& r : db->query(
            "SELECT season, teams, relegated::float8 AS relegated, promoted::float8 AS promoted, rules_label FROM pyramid_relegation_outlook "
            " WHERE competition_id = $1::int ORDER BY sort_order, season", {cid}))
        out["seasons"].push_back({{"season", str(r, "season")}, {"teams", r["teams"].as<int>()}, {"down", num(r, "relegated")},
                                  {"up", num(r, "promoted")}, {"rules", str(r, "rules_label")}});
    for (const auto& f : db->query(
            "SELECT fixture_source_id, division_label, label, auto_places, playoff_places FROM pyramid_feeder_sources "
            " WHERE competition_id = $1::int ORDER BY sort_order, id", {cid})) {
        std::vector<std::string> names; std::map<std::string, int> idx;
        std::vector<FitRes> done; std::vector<std::pair<int, int>> left;
        for (const auto& g : db->query(
                "SELECT home_name, away_name, home_score, away_score FROM league_fixtures "
                " WHERE source_id = $1::int AND division_label = $2 AND removed_at IS NULL AND status <> 'cancelled' ORDER BY starts_at",
                {std::to_string(f["fixture_source_id"].as<int>()), str(f, "division_label")})) {
            int ix[2];
            for (int k = 0; k < 2; ++k) {
                const std::string nm = str(g, k ? "away_name" : "home_name");
                auto it = idx.find(nm);
                if (it == idx.end()) { it = idx.emplace(nm, (int)names.size()).first; names.push_back(nm); }
                ix[k] = it->second;
            }
            if (ix[0] == ix[1]) continue;
            if (!g["home_score"].is_null() && !g["away_score"].is_null()) done.push_back({ix[0], ix[1], g["home_score"].as<int>(), g["away_score"].as<int>()});
            else left.push_back({ix[0], ix[1]});
        }
        const int n = (int)names.size();
        if (!n) continue;
        double avg = 1.5, home = 1.0; std::vector<double> att, def;
        fitMaher(n, done, prior, avg, home, att, def);
        struct Row { int p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, pts = 0; };
        auto tableOf = [&](const std::vector<FitRes>& rs) {
            std::vector<Row> t(n);
            for (const auto& r : rs) {
                Row& H = t[r.h]; Row& A = t[r.a];
                H.p++; A.p++; H.gf += r.hs; H.ga += r.as; A.gf += r.as; A.ga += r.hs;
                if (r.hs > r.as) { H.w++; A.l++; H.pts += 3; } else if (r.hs < r.as) { A.w++; H.l++; A.pts += 3; } else { H.d++; A.d++; H.pts++; A.pts++; }
            }
            return t;
        };
        auto ranked = [&](const std::vector<Row>& t, bool lot) {
            std::vector<int> l(n); for (int i = 0; i < n; ++i) l[i] = i;
            if (lot) std::shuffle(l.begin(), l.end(), rng);
            else std::sort(l.begin(), l.end(), [&](int a, int b) { return names[a] < names[b]; });
            std::stable_sort(l.begin(), l.end(), [&](int a, int b) {
                if (t[a].pts != t[b].pts) return t[a].pts > t[b].pts;
                if (t[a].gf - t[a].ga != t[b].gf - t[b].ga) return t[a].gf - t[a].ga > t[b].gf - t[b].ga;
                return t[a].gf > t[b].gf;
            });
            return l;
        };
        const int autoN = f["auto_places"].as<int>(), poN = f["playoff_places"].as<int>();
        const double winPo = (100.0 - feederStayUpPct) / 100.0;
        std::vector<int> first(n, 0), autoUp(n, 0), po(n, 0);
        std::vector<double> ptsSum(n, 0);
        std::vector<FitRes> rs = done;
        for (int s = 0; s < sims; ++s) {
            rs.resize(done.size());
            for (const auto& [h, a] : left) {
                std::poisson_distribution<int> ph(avg * home * att[h] * def[a]), pa(avg / home * att[a] * def[h]);
                rs.push_back({h, a, ph(rng), pa(rng)});
            }
            const auto t = tableOf(rs);
            const auto l = ranked(t, true);
            for (int i = 0; i < n; ++i) {
                const int x = l[i]; ptsSum[x] += t[x].pts;
                if (i == 0) first[x]++;
                if (i < autoN) autoUp[x]++; else if (i < autoN + poN) po[x]++;
            }
        }
        const double S = sims > 0 ? sims : 1;
        const auto now = tableOf(done);
        const auto order = ranked(now, false);
        json teamsJ = json::array();
        for (int i = 0; i < n; ++i) {
            const int x = order[i]; const Row& r = now[x];
            int gLeft = 0; for (const auto& [h, a] : left) if (h == x || a == x) gLeft++;
            json tj = {{"name", names[x]}, {"pos", i + 1}, {"p", r.p}, {"w", r.w}, {"d", r.d}, {"l", r.l}, {"gf", r.gf}, {"ga", r.ga},
                       {"pts", r.pts}, {"left", gLeft}, {"att", r2(att[x])}, {"def", r2(def[x])}, {"rating", r2(att[x] / def[x])},
                       {"xpts", r1(ptsSum[x] / S)}, {"first", r3(first[x] / S)}, {"playoff", r3(po[x] / S)},
                       {"up", r3((autoUp[x] + winPo * po[x]) / S)}};
            if (!ourPattern.empty()) {
                auto m = db->query("SELECT $1 ILIKE $2 AS m", {names[x], ourPattern});
                if (!m.empty() && m[0]["m"].as<bool>()) tj["ours"] = true;
            }
            teamsJ.push_back(tj);
        }
        out["feeders"].push_back({{"label", str(f, "label")}, {"auto", autoN}, {"playoff", poN}, {"win_playoff", r3(winPo)},
                                  {"played", (int)done.size()}, {"left", (int)left.size()}, {"avg_goals", r2(avg)}, {"teams", teamsJ}});
    }
    return out;
}

struct Cached { std::string stamp; std::chrono::steady_clock::time_point at; json body; };
std::mutex gMutex;
std::map<int, Cached> gCache;
}  // namespace

json PyramidForecast::build(int conferenceId, int whatIfTeam, double whatIfRating) {
    const bool whatIf = whatIfTeam > 0 && whatIfRating > 0;
    auto* db = Database::getInstance();
    const std::string cid = std::to_string(conferenceId);

    auto conf = db->query("SELECT id, name FROM pyramid_competitions WHERE id = $1::int AND kind = 'conference'", {cid});
    if (conf.empty()) throw std::invalid_argument("No such conference");

    // The conference's live tables and their feed division ids.
    std::vector<Division> divs;
    std::map<int, int> divIdx;
    int sourceId = 0;
    std::set<std::string> divExt;
    for (const auto& r : db->query(
            "SELECT d.id, d.name, d.source_id, split_part(d.external_id, ':', 1) AS ext FROM pyramid_divisions d "
            " WHERE d.competition_id = $1::int AND d.removed_at IS NULL "
            "   AND EXISTS (SELECT 1 FROM pyramid_teams t WHERE t.division_id = d.id AND t.removed_at IS NULL) "
            " ORDER BY d.sort_order, d.name", {cid})) {
        Division d; d.id = r["id"].as<int>(); d.name = str(r, "name");
        divIdx[d.id] = (int)divs.size(); divs.push_back(d);
        sourceId = r["source_id"].as<int>(); divExt.insert(str(r, "ext"));
    }
    json out = {{"conference", {{"id", conferenceId}, {"name", str(conf[0], "name")}}}, {"divisions", json::array()}, {"games", json::array()}};
    if (divs.empty() || !sourceId) { out["note"] = "no_tables"; return out; }
    std::string extList;
    for (const auto& e : divExt) extList += (extList.empty() ? "" : ",") + e;
    // A game finished since the feed was last read → read it now (mig 1455).
    PyramidSync::refreshIfGameDue(sourceId);

    // Cache stamp: the games' last read.
    auto stampRow = db->query(
        "SELECT COALESCE(max(last_seen_at)::text, '') || ':' || count(*) AS s FROM pyramid_games "
        " WHERE source_id = $1::int AND division_ext = ANY(string_to_array($2, ','))", {std::to_string(sourceId), extList});
    const std::string stamp = stampRow.empty() ? "" : str(stampRow[0], "s");
    if (!whatIf) {
        std::lock_guard<std::mutex> lock(gMutex);
        auto it = gCache.find(conferenceId);
        if (it != gCache.end() && it->second.stamp == stamp
            && std::chrono::steady_clock::now() - it->second.at < std::chrono::minutes(10)) return it->second.body;
    }

    // Teams (one row per team: a team sits in one table of its conference).
    std::vector<Team> teams;
    std::map<std::string, int> byExt;
    for (const auto& r : db->query(
            "SELECT t.id, t.external_id, t.name, t.pyramid_club_id, t.division_id FROM pyramid_teams t "
            "  JOIN pyramid_divisions d ON d.id = t.division_id "
            " WHERE d.competition_id = $1::int AND d.removed_at IS NULL AND t.removed_at IS NULL ORDER BY t.position, t.name", {cid})) {
        auto di = divIdx.find(r["division_id"].as<int>());
        if (di == divIdx.end()) continue;
        const std::string ext = str(r, "external_id");
        if (byExt.count(ext)) continue;
        Team t; t.id = r["id"].as<int>(); t.ext = ext; t.name = str(r, "name"); t.clubId = r["pyramid_club_id"].as<int>(); t.div = di->second;
        byExt[ext] = (int)teams.size(); divs[t.div].teams.push_back((int)teams.size()); teams.push_back(t);
    }
    const int N = (int)teams.size();

    // Zones (effective: the league's marks, defaults and overrides).
    for (auto& d : divs)
        for (const auto& r : db->query("SELECT kind, from_pos, to_pos FROM pyramid_zones_effective WHERE division_id = $1::int ORDER BY from_pos",
                                       {std::to_string(d.id)}))
            d.zones.push_back({{"kind", str(r, "kind")}, {"from", r["from_pos"].as<int>()}, {"to", r["to_pos"].as<int>()}});

    // Games: every listed one between two of these teams, not cancelled.
    std::vector<Game> games;
    std::string asOf;
    for (const auto& r : db->query(
            "SELECT external_id, home_ext, away_ext, to_char(starts_local, 'YYYY-MM-DD\"T\"HH24:MI') AS w, complete, home_score, away_score "
            "  FROM pyramid_games WHERE source_id = $1::int AND division_ext = ANY(string_to_array($2, ',')) "
            "   AND removed_at IS NULL AND NOT cancelled ORDER BY starts_local, external_id", {std::to_string(sourceId), extList})) {
        auto h = byExt.find(str(r, "home_ext")), a = byExt.find(str(r, "away_ext"));
        if (h == byExt.end() || a == byExt.end() || h->second == a->second) continue;
        Game g; g.id = std::stoll(str(r, "external_id")); g.h = h->second; g.a = a->second; g.when = str(r, "w");
        g.done = r["complete"].as<bool>() && !r["home_score"].is_null() && !r["away_score"].is_null();
        if (g.done) { g.hs = r["home_score"].as<int>(); g.as = r["away_score"].as<int>(); if (g.when > asOf) asOf = g.when; }
        games.push_back(g);
    }

    // Policy: this conference's row, else the default.
    int sims = 10000; double prior = 3, feederPct = 50; bool pair = true; std::string feeder, ourPattern;
    int groupRounds = 0, crossRounds = 0;   // mig 1449: 0 = only the listed games
    {
        auto p = db->query("SELECT sims, prior_games, pair_relegation_playoffs, feeder_label, feeder_stay_up_pct, group_rounds, cross_group_rounds, our_name_pattern FROM pyramid_forecast_policies "
                           " WHERE competition_id = $1::int OR competition_id IS NULL ORDER BY competition_id NULLS LAST LIMIT 1", {cid});
        if (!p.empty()) {
            sims = p[0]["sims"].as<int>(); prior = num(p[0], "prior_games"); pair = p[0]["pair_relegation_playoffs"].as<bool>();
            feeder = str(p[0], "feeder_label"); feederPct = num(p[0], "feeder_stay_up_pct"); ourPattern = str(p[0], "our_name_pattern");
            groupRounds = p[0]["group_rounds"].is_null() ? 0 : p[0]["group_rounds"].as<int>();
            crossRounds = p[0]["cross_group_rounds"].is_null() ? 0 : p[0]["cross_group_rounds"].as<int>();
        }
    }
    std::vector<std::string> tiebreak;
    {
        auto s = db->query("SELECT array_to_string(tiebreak, '|') AS t FROM pyramid_sources WHERE id = $1::int", {std::to_string(sourceId)});
        std::string t = s.empty() ? "" : str(s[0], "t");
        for (size_t p = 0; !t.empty();) { size_t c = t.find('|', p); tiebreak.push_back(t.substr(p, c == std::string::npos ? std::string::npos : c - p)); if (c == std::string::npos) break; p = c + 1; }
        if (tiebreak.empty()) tiebreak = {"Points desc", "PD desc", "PF desc"};
    }

    // ── the whole season (mig 1449, owner 11/17 "its a 22 game schedule …
    // you play your division 2x and the other division 1x"): every meeting
    // the feed doesn't list yet is added, not scheduled — a same-group
    // return leg at the other side's ground (alternating when neither is
    // listed), a cross-group meeting at no known ground.
    const int listed = (int)games.size();
    if (groupRounds > 0) {
        for (int a = 0; a < N; ++a) for (int b = a + 1; b < N; ++b) {
            const bool same = teams[a].div == teams[b].div;
            const int want = same ? groupRounds : crossRounds;
            int homeA = 0, homeB = 0;
            for (const auto& g : games) { if (g.h == a && g.a == b) homeA++; else if (g.h == b && g.a == a) homeB++; }
            for (int k = homeA + homeB; k < want; ++k) {
                Game g; g.id = -(long long)(games.size() + 1); g.tbs = true;
                if (same) { const bool aHosts = homeA <= homeB; g.h = aHosts ? a : b; g.a = aHosts ? b : a; (aHosts ? homeA : homeB)++; }
                else { g.h = a; g.a = b; g.neutral = true; }
                games.push_back(g);
            }
        }
    }
    const int added = (int)games.size() - listed;

    // ── the goals model ──
    int played = 0;
    std::vector<FitRes> fitDone;
    for (const auto& g : games) if (g.done) { played++; fitDone.push_back({g.h, g.a, g.hs, g.as}); }
    double avg = 1.5, home = 1.0;
    {
        std::vector<double> att, def;
        fitMaher(N, fitDone, prior, avg, home, att, def);
        for (int t = 0; t < N; ++t) { teams[t].att = att[t]; teams[t].def = def[t]; }
    }
    // What if: that team's strength moved to the slider's, split evenly
    // between attack (×√k) and defence (÷√k).
    json whatIfOut = nullptr;
    if (whatIf) {
        for (auto& t : teams) if (t.id == whatIfTeam) {
            const double r0 = t.att / t.def, k = std::sqrt(std::max(0.05, std::min(20.0, whatIfRating)) / r0);
            whatIfOut = {{"team", t.id}, {"rating", r2(whatIfRating)}, {"base_rating", r2(r0)}, {"base_att", r2(t.att)}, {"base_def", r2(t.def)}};
            t.att *= k; t.def /= k;
        }
    }
    auto lam = [&](int h, int a, bool neutral) {
        const double e = neutral ? 1.0 : home;
        return std::pair<double, double>{avg * e * teams[h].att * teams[a].def, avg / e * teams[a].att * teams[h].def};
    };

    // ── the table with the league's tie-breaks ──
    struct Res { int h, a, hs, as; };
    std::vector<Res> doneRes;
    std::vector<int> left;
    for (int i = 0; i < (int)games.size(); ++i) {
        if (games[i].done) doneRes.push_back({games[i].h, games[i].a, games[i].hs, games[i].as});
        else left.push_back(i);
    }
    struct Row { int p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, pts = 0; };
    auto tableOf = [&](const std::vector<Res>& rs) {
        std::vector<Row> t(N);
        for (const auto& r : rs) {
            Row& H = t[r.h]; Row& A = t[r.a];
            H.p++; A.p++; H.gf += r.hs; H.ga += r.as; A.gf += r.as; A.ga += r.hs;
            if (r.hs > r.as) { H.w++; A.l++; H.pts += 3; } else if (r.hs < r.as) { A.w++; H.l++; A.pts += 3; } else { H.d++; A.d++; H.pts++; A.pts++; }
        }
        return t;
    };
    std::mt19937_64 rng(std::hash<std::string>{}(stamp) ^ (unsigned long long)conferenceId);
    // order(list, key) — sort by tiebreak[key] (head-to-head keys measured
    // inside the tied group), recurse into each tie; past the last key, by
    // lot (or by name when `byName`, for today's table).
    std::function<void(std::vector<int>&, size_t, const std::vector<Row>&, const std::vector<Res>&, bool)> order;
    order = [&](std::vector<int>& list, size_t k, const std::vector<Row>& t, const std::vector<Res>& rs, bool byName) {
        if (list.size() <= 1) return;
        if (k >= tiebreak.size()) {
            if (byName) std::sort(list.begin(), list.end(), [&](int a, int b) { return teams[a].name < teams[b].name; });
            else std::shuffle(list.begin(), list.end(), rng);
            return;
        }
        std::string key = tiebreak[k];
        std::transform(key.begin(), key.end(), key.begin(), [](unsigned char c) { return (char)std::toupper(c); });
        std::map<int, long> val;
        const bool h2h = key.rfind("H2H", 0) == 0;
        if (h2h) {
            std::set<int> in(list.begin(), list.end());
            std::map<int, long> pts, gd;
            for (int x : list) { pts[x] = 0; gd[x] = 0; }
            for (const auto& r : rs) {
                if (!in.count(r.h) || !in.count(r.a)) continue;
                gd[r.h] += r.hs - r.as; gd[r.a] += r.as - r.hs;
                if (r.hs > r.as) pts[r.h] += 3; else if (r.hs < r.as) pts[r.a] += 3; else { pts[r.h]++; pts[r.a]++; }
            }
            for (int x : list) val[x] = key.find("PD") != std::string::npos ? gd[x] : key.find("PF") != std::string::npos ? 0 : pts[x];
        } else {
            for (int x : list) {
                const Row& r = t[x];
                val[x] = key.rfind("POINTS", 0) == 0 ? r.pts : key.rfind("PD", 0) == 0 ? r.gf - r.ga : key.rfind("PF", 0) == 0 ? r.gf
                       : key.rfind("PA", 0) == 0 ? -r.ga : key.rfind("W", 0) == 0 ? r.w : 0;
            }
        }
        std::stable_sort(list.begin(), list.end(), [&](int a, int b) { return val[a] > val[b]; });
        for (size_t i = 0; i < list.size();) {
            size_t j = i; while (j < list.size() && val[list[j]] == val[list[i]]) ++j;
            if (j - i > 1) { std::vector<int> sub(list.begin() + i, list.begin() + j); order(sub, k + 1, t, rs, byName); std::copy(sub.begin(), sub.end(), list.begin() + i); }
            i = j;
        }
    };
    auto zoneAt = [&](const Division& d, int pos) -> std::string {
        for (const auto& z : d.zones) if (pos >= z["from"].get<int>() && pos <= z["to"].get<int>()) return z["kind"].get<std::string>();
        return "";
    };

    // Today's table.
    const auto now = tableOf(doneRes);
    std::vector<int> nowPos(N, 0);
    for (auto& d : divs) { std::vector<int> l = d.teams; order(l, 0, now, doneRes, true); for (size_t i = 0; i < l.size(); ++i) nowPos[l[i]] = (int)i + 1; }

    // ── the season, `sims` times ──
    std::vector<std::vector<int>> posCount(N, std::vector<int>(32, 0));
    std::vector<std::map<std::string, int>> zoneCount(N);
    std::vector<int> playoffLost(N, 0), feederLost(N, 0), downAll(N, 0), relPlayoff(N, 0);
    std::vector<double> ptsSum(N, 0);
    // points each place finishes on (owner 11/17 "what is probable point
    // total of 6th place" → "give me % spread" → "put that on site too")
    std::vector<std::vector<std::map<int, int>>> placePts(divs.size());
    for (size_t di = 0; di < divs.size(); ++di) placePts[di].resize(divs[di].teams.size());
    // relegation playoff: paired when two tables each have one such place
    std::vector<int> rpDivs;
    for (int i = 0; i < (int)divs.size(); ++i) {
        int n = 0; for (const auto& z : divs[i].zones) if (z["kind"] == "relegation_playoff") n += z["to"].get<int>() - z["from"].get<int>() + 1;
        if (n == 1) rpDivs.push_back(i);
    }
    const bool paired = pair && rpDivs.size() == 2;
    std::vector<Res> rs = doneRes; rs.reserve(doneRes.size() + left.size());
    std::vector<std::pair<double, double>> lamLeft;
    for (int gi : left) lamLeft.push_back(lam(games[gi].h, games[gi].a, games[gi].neutral));
    std::uniform_real_distribution<double> U(0.0, 1.0);
    for (int s = 0; s < sims; ++s) {
        rs.resize(doneRes.size());
        for (size_t i = 0; i < left.size(); ++i) {
            std::poisson_distribution<int> ph(lamLeft[i].first), pa(lamLeft[i].second);
            rs.push_back({games[left[i]].h, games[left[i]].a, ph(rng), pa(rng)});
        }
        const auto t = tableOf(rs);
        std::vector<int> rpTeam(divs.size(), -1);
        std::vector<int> unpairedRp;
        for (size_t di = 0; di < divs.size(); ++di) {
            std::vector<int> l = divs[di].teams; order(l, 0, t, rs, false);
            for (size_t i = 0; i < l.size(); ++i) {
                const int x = l[i], pos = (int)i + 1;
                if (pos < 32) posCount[x][pos]++;
                placePts[di][i][t[x].pts]++;
                ptsSum[x] += t[x].pts;
                const std::string z = zoneAt(divs[di], pos);
                if (!z.empty()) zoneCount[x][z]++;
                if (z == "relegation" || z == "conditional_relegation") downAll[x]++;
                if (z == "relegation_playoff") { relPlayoff[x]++; if (paired) rpTeam[di] = x; else unpairedRp.push_back(x); }
            }
        }
        auto feederGame = [&](int x) { if (!feeder.empty() && U(rng) * 100.0 >= feederPct) { feederLost[x]++; downAll[x]++; } };
        if (paired && rpTeam[rpDivs[0]] >= 0 && rpTeam[rpDivs[1]] >= 0) {
            const int a = rpTeam[rpDivs[0]], b = rpTeam[rpDivs[1]];
            const auto l2 = lam(a, b, true);
            std::poisson_distribution<int> pa(l2.first), pb(l2.second);
            const int ga = pa(rng), gb = pb(rng);
            const bool aWins = ga > gb || (ga == gb && U(rng) < 0.5);
            const int lose = aWins ? b : a, win = aWins ? a : b;
            playoffLost[lose]++; downAll[lose]++;
            feederGame(win);
        }
        for (int x : unpairedRp) feederGame(x);
    }

    // ── one game: chances, scores, odds ──
    auto gameJson = [&](const Game& g) {
        json j = {{"id", g.id}, {"when", g.when}, {"home", teams[g.h].id}, {"away", teams[g.a].id}, {"done", g.done}};
        if (g.tbs) j["tbs"] = true;
        if (g.neutral) j["neutral"] = true;
        if (g.done) { j["hs"] = g.hs; j["as"] = g.as; }
        const auto l = lam(g.h, g.a, g.neutral);
        double ph = 0, pd = 0, pa = 0, over = 0, btts = 0;
        std::vector<std::tuple<double, int, int>> sc;
        for (int i = 0; i <= 25; ++i) for (int k = 0; k <= 25; ++k) {   // wide enough for a 9-goal side
            const double p = pois(i, l.first) * pois(k, l.second);
            if (i > k) ph += p; else if (i < k) pa += p; else pd += p;
            if (i + k >= 3) over += p;
            if (i > 0 && k > 0) btts += p;
            sc.emplace_back(p, i, k);
        }
        std::sort(sc.begin(), sc.end(), [](const auto& a, const auto& b) { return std::get<0>(a) > std::get<0>(b); });
        json top = json::array();
        for (size_t i = 0; i < 6 && i < sc.size(); ++i) top.push_back({{"h", std::get<1>(sc[i])}, {"a", std::get<2>(sc[i])}, {"p", r3(std::get<0>(sc[i]))}});
        const double tot = ph + pd + pa;
        j["xg"] = {r2(l.first), r2(l.second)};
        j["p"] = {r3(ph / tot), r3(pd / tot), r3(pa / tot)};
        for (auto& x : top) x["p"] = r3(x["p"].get<double>() / tot);
        j["over25"] = r3(over / tot); j["btts"] = r3(btts / tot); j["scores"] = top;
        return j;
    };

    const double S = sims > 0 ? sims : 1;
    for (const auto& d : divs) {
        json dj = {{"id", d.id}, {"name", d.name}, {"zones", d.zones}, {"teams", json::array()}};
        std::vector<int> l = d.teams;
        std::sort(l.begin(), l.end(), [&](int a, int b) { return nowPos[a] < nowPos[b]; });
        for (int x : l) {
            const Row& r = now[x];
            json pos = json::array();
            for (size_t i = 1; i <= d.teams.size(); ++i) pos.push_back(r3(posCount[x][i] / S));
            json zones = json::object();
            for (const auto& [k, v] : zoneCount[x]) zones[k] = r3(v / S);
            int gLeft = 0; for (int gi : left) if (games[gi].h == x || games[gi].a == x) gLeft++;
            dj["teams"].push_back({{"id", teams[x].id}, {"club_id", teams[x].clubId}, {"name", teams[x].name}, {"pos", nowPos[x]},
                                   {"p", r.p}, {"w", r.w}, {"d", r.d}, {"l", r.l}, {"gf", r.gf}, {"ga", r.ga}, {"pts", r.pts}, {"left", gLeft},
                                   {"att", r2(teams[x].att)}, {"def", r2(teams[x].def)}, {"rating", r2(teams[x].att / teams[x].def)},
                                   {"xpts", r1(ptsSum[x] / S)}, {"pos_pct", pos}, {"zones", zones},
                                   {"rel_playoff", r3(relPlayoff[x] / S)}, {"lost_playoff", r3(playoffLost[x] / S)},
                                   {"lost_feeder", r3(feederLost[x] / S)}, {"down", r3(downAll[x] / S)}});
        }
        // per place: median, 10th / 90th percentile, mean, and the spread
        json places = json::array();
        const auto& pp = placePts[&d - &divs[0]];
        for (size_t i = 0; i < pp.size(); ++i) {
            const auto& m = pp[i];
            long tot = 0; double sum = 0; for (const auto& [k, v] : m) { tot += v; sum += (double)k * v; }
            auto q = [&](double f) { long acc = 0; for (const auto& [k, v] : m) { acc += v; if (acc >= f * tot) return k; } return m.empty() ? 0 : m.rbegin()->first; };
            json spread = json::array();
            for (const auto& [k, v] : m) spread.push_back({k, r3((double)v / (tot ? tot : 1))});
            places.push_back({{"pos", (int)i + 1}, {"mean", r1(tot ? sum / tot : 0)}, {"p10", q(0.1)}, {"p50", q(0.5)}, {"p90", q(0.9)}, {"spread", spread}});
        }
        dj["places"] = places;
        out["divisions"].push_back(dj);
    }
    for (const auto& g : games) out["games"].push_back(gameJson(g));
    out["format"] = {{"group_rounds", groupRounds}, {"cross_group_rounds", crossRounds}, {"listed", listed}, {"added", added},
                     {"per_team", N ? 2 * (int)games.size() / N : 0}};
    out["as_of"] = asOf; out["sims"] = sims; out["played"] = played; out["left"] = (int)left.size();
    out["model"] = {{"avg_goals", r2(avg)}, {"home_edge", r2(home * home)}, {"prior_games", prior}};
    out["policy"] = {{"paired", paired}, {"feeder", feeder.empty() ? json(nullptr) : json(feeder)}, {"feeder_stay_up_pct", feederPct}};
    out["tiebreak"] = tiebreak;
    // our side here (mig 1571), for the outlook's "our road"
    if (!ourPattern.empty())
        for (const auto& t : teams) {
            auto m = db->query("SELECT $1 ILIKE $2 AS m", {t.name, ourPattern});
            if (!m.empty() && m[0]["m"].as<bool>()) { out["ours"] = t.id; break; }
        }
    out["outlook"] = outlookJson(db, cid, sims, prior, feederPct, ourPattern, rng);
    if (whatIf) { out["what_if"] = whatIfOut; return out; }
    {
        std::lock_guard<std::mutex> lock(gMutex);
        gCache[conferenceId] = {stamp, std::chrono::steady_clock::now(), out};
    }
    return out;
}
