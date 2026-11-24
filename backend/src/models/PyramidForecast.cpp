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
    double day = -1;   // days since the epoch, -1 = no date (form weights, mig 1767)
};
struct Division { int id = 0; std::string name; std::vector<int> teams; std::vector<json> zones; };

// Poisson P(k; l)
double pois(int k, double l) { return std::exp(-l + k * std::log(std::max(l, 1e-12)) - std::lgamma(k + 1.0)); }

// The goals model's fit (Maher 1982): an attack and a defence rating per
// team, 1.00 = average, shrunk toward average by `prior` average games; the
// league's goals a side a game; a home edge (√ of home ÷ away goals, shrunk
// by ten average games each side).  Shared by the conference and its feeder.
//
// Form (mig 1767, owner 11/23 "why didn't the what happens next pick this
// up" — two 2-1 losses after 9-0 and 8-0): `w` weighs each game, 1 = in
// full; formWeights halves a game's weight every `halfLife` days before the
// latest game played (Dixon & Coles 1997 §4.4, exponential time weighting).
// Empty `w` = every game the same.
struct FitRes { int h, a, hs, as; };
std::vector<double> formWeights(const std::vector<double>& day, double halfLife) {
    if (halfLife <= 0) return {};
    double latest = -1;
    for (double d : day) latest = std::max(latest, d);
    std::vector<double> w(day.size(), 1.0);
    for (size_t i = 0; i < day.size(); ++i) if (day[i] >= 0) w[i] = std::pow(0.5, (latest - day[i]) / halfLife);   // no date = in full
    return w;
}
void fitMaher(int n, const std::vector<FitRes>& done, const std::vector<double>& w, double prior, double& avg, double& home,
              std::vector<double>& att, std::vector<double>& def) {
    att.assign(n, 1.0); def.assign(n, 1.0);
    const auto wt = [&](size_t i) { return i < w.size() ? w[i] : 1.0; };
    double goals = 0, homeGoals = 0, awayGoals = 0, count = 0;
    for (size_t i = 0; i < done.size(); ++i) { const auto& g = done[i]; goals += wt(i) * (g.hs + g.as); homeGoals += wt(i) * g.hs; awayGoals += wt(i) * g.as; count += wt(i); }
    avg = done.empty() ? 1.5 : goals / (2.0 * count);
    home = done.empty() ? 1.0 : std::sqrt((homeGoals + 10 * avg) / (awayGoals + 10 * avg));
    for (int it = 0; it < 200 && !done.empty(); ++it) {
        double moved = 0;
        for (int pass = 0; pass < 2; ++pass)
            for (int t = 0; t < n; ++t) {
                double got = 0, expd = 0;
                for (size_t i = 0; i < done.size(); ++i) {
                    const auto& g = done[i];
                    if (g.h != t && g.a != t) continue;
                    const bool isHome = g.h == t; const int o = isHome ? g.a : g.h;
                    const double edge = isHome ? home : 1.0 / home;
                    if (pass == 0) { got += wt(i) * (isHome ? g.hs : g.as); expd += wt(i) * avg * edge * def[o]; }
                    else { got += wt(i) * (isHome ? g.as : g.hs); expd += wt(i) * avg / edge * att[o]; }
                }
                const double v = (got + prior * avg) / (expd + prior * avg);
                double& slot = pass == 0 ? att[t] : def[t];
                moved = std::max(moved, std::fabs(v - slot)); slot = v;
            }
        if (moved < 1e-6) break;
    }
}

// 📉 The outlook (migs 1571, 1573): the conference's seasons (how many go
// down / come up) and its feeders (pyramid_links into it), played by the
// conference's promotion rules (pyramid_promotion_rules):
//   each feeder   its teams rated from their own games (1.00 = that league's
//                 average), the rest of its games drawn `sims` times, the
//                 table by points → goal difference → goals → lot;
//   eligible      reserves (the club has a side in an APSL conference, or a
//                 pyramid_promotion_exclusions row) and sides nearest another
//                 conference are skipped — the next team moves up;
//   champions     each feeder's top eligible side, a knockout between them
//                 (random draw, a bye when odd, neutral, a draw = penalties
//                 50/50); the winner goes up;
//   playoff       the champions who lost + places playoff_from..to of the
//                 eligible from each feeder, the same knockout; the winner
//                 then plays our group-playoff winner (feeder_stay_up_pct).
// The feeders' averages are taken as equal when they meet (no game links
// them).
json outlookJson(Database* db, const std::string& cid, int nTeams, int sims, double prior, double halfLife, double feederStayUpPct, std::mt19937_64& rng) {
    json out = {{"seasons", json::array()}, {"feeders", json::array()}};
    for (const auto& r : db->query(
            "SELECT season, teams, divisions, relegated::float8 AS relegated, promoted::float8 AS promoted, rules_label, auto_down, playoff_place FROM pyramid_relegation_outlook "
            " WHERE competition_id = $1::int ORDER BY sort_order, season", {cid})) {
        json sj = {{"season", str(r, "season")}, {"teams", r["teams"].as<int>()}, {"divisions", r["divisions"].as<int>()},
                   {"down", num(r, "relegated")}, {"up", num(r, "promoted")}, {"rules", str(r, "rules_label")}};
        if (!r["auto_down"].is_null()) sj["auto_down"] = r["auto_down"].as<int>();       // mig 1583
        if (!r["playoff_place"].is_null()) sj["playoff_place"] = r["playoff_place"].as<int>();
        out["seasons"].push_back(sj);
    }
    // mig 1575: no seasons of its own → its size this season decides
    // (pyramid_relegation_size_rules: that size, else the default row).
    if (out["seasons"].empty() && nTeams > 0) {
        auto r = db->query("SELECT relegated::float8 AS relegated, promoted::float8 AS promoted, rules_label FROM pyramid_relegation_size_rules "
                           " WHERE teams = $1::int OR teams IS NULL ORDER BY teams NULLS LAST LIMIT 1", {std::to_string(nTeams)});
        if (!r.empty())
            out["seasons"].push_back({{"season", nullptr}, {"teams", nTeams}, {"divisions", 1}, {"down", num(r[0], "relegated")},
                                      {"up", num(r[0], "promoted")}, {"rules", str(r[0], "rules_label")}, {"every", true}});
    }
    auto rr = db->query("SELECT champion_rank, playoff_from_rank, playoff_to_rank, champion_losers_to_playoff, playoff_winner_meets_survivor, "
                        "       skip_reserves, skip_other_conference, feeder_playoff_first FROM pyramid_promotion_rules WHERE competition_id = $1::int", {cid});
    if (rr.empty()) return out;
    const int champRank = rr[0]["champion_rank"].as<int>(), poFrom = rr[0]["playoff_from_rank"].as<int>(), poTo = rr[0]["playoff_to_rank"].as<int>();
    const bool losersIn = rr[0]["champion_losers_to_playoff"].as<bool>(), meets = rr[0]["playoff_winner_meets_survivor"].as<bool>();
    const bool skipRes = rr[0]["skip_reserves"].as<bool>(), skipConf = rr[0]["skip_other_conference"].as<bool>();
    const bool feederFirst = rr[0]["feeder_playoff_first"].as<bool>();   // mig 1574
    const double winSurvivor = meets ? (100.0 - feederStayUpPct) / 100.0 : 1.0;
    out["rules"] = {{"champion_rank", champRank}, {"playoff_from", poFrom}, {"playoff_to", poTo}, {"losers_in", losersIn},
                    {"meets_survivor", meets}, {"win_survivor", r3(winSurvivor)}, {"feeder_first", feederFirst}};

    struct FT { int id = 0; std::string ext, name, skip, skipArg; double att = 1, def = 1; int p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, pts = 0, left = 0; };
    struct Feeder { std::string label; int sourceId = 0; double avg = 1.5, home = 1.0; std::vector<FT> t; std::vector<FitRes> done; std::vector<std::pair<int, int>> left; int played = 0; };
    std::vector<Feeder> feeders;
    for (const auto& f : db->query(
            "SELECT l.lower_source_id, d.id AS div_id, split_part(d.external_id, ':', 1) AS ext, COALESCE(c.short_name, c.name) AS comp, d.name AS div "
            "  FROM pyramid_links l JOIN pyramid_sources s ON s.id = l.lower_source_id AND s.is_active "
            "  JOIN pyramid_competitions c ON c.id = s.competition_id "
            "  JOIN pyramid_divisions d ON d.source_id = l.lower_source_id AND d.name = l.lower_division AND d.removed_at IS NULL "
            " WHERE l.upper_competition_id = $1::int AND l.promotes ORDER BY c.sort_order, c.name", {cid})) {
        Feeder F; F.label = str(f, "comp") + " " + str(f, "div"); F.sourceId = f["lower_source_id"].as<int>();
        PyramidSync::refreshIfGameDue(F.sourceId);
        std::map<std::string, int> byExt;
        for (const auto& r : db->query(R"SQL(
                SELECT t.id, t.external_id, t.name,
                       EXISTS (SELECT 1 FROM pyramid_teams t2 JOIN pyramid_divisions d2 ON d2.id = t2.division_id AND d2.removed_at IS NULL
                                 JOIN pyramid_competitions c2 ON c2.id = d2.competition_id AND c2.kind = 'conference'
                                WHERE t2.pyramid_club_id = t.pyramid_club_id AND t2.removed_at IS NULL AND t2.id <> t.id) AS reserve,
                       (SELECT reason FROM pyramid_promotion_exclusions x WHERE x.competition_id = $2::int AND x.pyramid_club_id = t.pyramid_club_id) AS hand,
                       (SELECT COALESCE(oc.short_name, oc.name) FROM pyramid_team_nearest_conference n JOIN pyramid_competitions oc ON oc.id = n.conference_id
                         WHERE n.team_id = t.id AND n.conference_id <> $2::int LIMIT 1) AS other_conf
                  FROM pyramid_teams t WHERE t.division_id = $1::int AND t.removed_at IS NULL ORDER BY t.position, t.name)SQL",
                {std::to_string(f["div_id"].as<int>()), cid})) {
            FT t; t.id = r["id"].as<int>(); t.ext = str(r, "external_id"); t.name = str(r, "name");
            if (!r["hand"].is_null()) { t.skip = "hand"; t.skipArg = str(r, "hand"); }
            else if (skipRes && r["reserve"].as<bool>()) t.skip = "reserve";
            else if (skipConf && !r["other_conf"].is_null()) { t.skip = "conf"; t.skipArg = str(r, "other_conf"); }
            byExt[t.ext] = (int)F.t.size(); F.t.push_back(t);
        }
        std::vector<double> days;
        for (const auto& g : db->query(
                "SELECT home_ext, away_ext, complete, home_score, away_score, EXTRACT(EPOCH FROM starts_local) / 86400.0 AS day FROM pyramid_games "
                " WHERE source_id = $1::int AND division_ext = $2 AND removed_at IS NULL AND NOT cancelled", {std::to_string(F.sourceId), str(f, "ext")})) {
            auto h = byExt.find(str(g, "home_ext")), a = byExt.find(str(g, "away_ext"));
            if (h == byExt.end() || a == byExt.end() || h->second == a->second) continue;
            if (g["complete"].as<bool>() && !g["home_score"].is_null() && !g["away_score"].is_null()) {
                F.done.push_back({h->second, a->second, g["home_score"].as<int>(), g["away_score"].as<int>()});
                days.push_back(g["day"].is_null() ? -1.0 : g["day"].as<double>());
            } else { F.left.push_back({h->second, a->second}); F.t[h->second].left++; F.t[a->second].left++; }
        }
        if (F.t.empty()) continue;
        std::vector<double> att, def;
        fitMaher((int)F.t.size(), F.done, formWeights(days, halfLife), prior, F.avg, F.home, att, def);
        for (size_t i = 0; i < F.t.size(); ++i) { F.t[i].att = att[i]; F.t[i].def = def[i]; }
        F.played = (int)F.done.size();
        feeders.push_back(std::move(F));
    }
    if (feeders.empty()) return out;

    struct Row { int pts = 0, gd = 0, gf = 0; };
    auto rankOf = [&](const Feeder& F, const std::vector<FitRes>& rs, bool lot) {
        const int n = (int)F.t.size();
        std::vector<Row> t(n);
        for (const auto& r : rs) {
            t[r.h].gf += r.hs; t[r.a].gf += r.as; t[r.h].gd += r.hs - r.as; t[r.a].gd += r.as - r.hs;
            if (r.hs > r.as) t[r.h].pts += 3; else if (r.hs < r.as) t[r.a].pts += 3; else { t[r.h].pts++; t[r.a].pts++; }
        }
        std::vector<int> l(n); for (int i = 0; i < n; ++i) l[i] = i;
        if (lot) std::shuffle(l.begin(), l.end(), rng);
        std::stable_sort(l.begin(), l.end(), [&](int a, int b) {
            if (t[a].pts != t[b].pts) return t[a].pts > t[b].pts;
            if (t[a].gd != t[b].gd) return t[a].gd > t[b].gd;
            return t[a].gf > t[b].gf;
        });
        return l;
    };
    std::uniform_real_distribution<double> U(0.0, 1.0);
    using Side = std::pair<int, int>;   // feeder, team
    auto meet = [&](Side x, Side y) {   // neutral; a draw = penalties 50/50
        const Feeder& A = feeders[x.first]; const Feeder& B = feeders[y.first];
        const double base = std::sqrt(A.avg * B.avg);
        std::poisson_distribution<int> px(base * A.t[x.second].att * B.t[y.second].def), py(base * B.t[y.second].att * A.t[x.second].def);
        const int gx = px(rng), gy = py(rng);
        return gx > gy || (gx == gy && U(rng) < 0.5);
    };
    // knockout: random draw, a bye when odd; returns the winner and the losers
    auto knockout = [&](std::vector<Side> v, std::vector<Side>* losers) {
        std::shuffle(v.begin(), v.end(), rng);
        while (v.size() > 1) {
            std::vector<Side> next;
            size_t i = 0;
            if (v.size() % 2) next.push_back(v[i++]);
            for (; i + 1 < v.size(); i += 2) {
                const bool first = meet(v[i], v[i + 1]);
                next.push_back(first ? v[i] : v[i + 1]);
                if (losers) losers->push_back(first ? v[i + 1] : v[i]);
            }
            v = next;
        }
        return v.empty() ? Side{-1, -1} : v[0];
    };

    // mig 1574: a feeder's own playoff — seeded (list in seed order), best v
    // worst each round, the better seed at home, top seeds get the byes.
    auto seeded = [&](const std::vector<int>& seeds, int k) {
        const Feeder& F = feeders[k];
        std::vector<int> v = seeds;   // indexes into F.t, best seed first
        while (v.size() > 1) {
            size_t P = 1; while (P < v.size()) P <<= 1;
            const size_t byes = P - v.size();
            std::vector<int> next(v.begin(), v.begin() + byes);
            for (size_t i = byes, j = v.size() - 1; i < j; ++i, --j) {
                const int h = v[i], a = v[j];
                std::poisson_distribution<int> ph(F.avg * F.home * F.t[h].att * F.t[a].def), pa(F.avg / F.home * F.t[a].att * F.t[h].def);
                const int gh = ph(rng), ga = pa(rng);
                next.push_back(gh > ga || (gh == ga && U(rng) < 0.5) ? h : a);
            }
            std::sort(next.begin(), next.end(), [&](int x, int y) {
                return std::find(seeds.begin(), seeds.end(), x) < std::find(seeds.begin(), seeds.end(), y); });
            v = next;
        }
        return v.empty() ? -1 : v[0];
    };

    std::vector<std::vector<int>> champ(feeders.size()), autoUp(feeders.size()), inPo(feeders.size()), winPo(feeders.size()), fWin(feeders.size());
    std::vector<std::vector<double>> up(feeders.size());
    std::vector<std::vector<long>> ptsSum(feeders.size());
    for (size_t k = 0; k < feeders.size(); ++k) {
        const size_t n = feeders[k].t.size();
        champ[k].assign(n, 0); fWin[k].assign(n, 0); autoUp[k].assign(n, 0); inPo[k].assign(n, 0); winPo[k].assign(n, 0); up[k].assign(n, 0); ptsSum[k].assign(n, 0);
    }
    std::vector<std::vector<FitRes>> rs(feeders.size());
    for (int s = 0; s < sims; ++s) {
        std::vector<Side> champs, po;
        for (size_t k = 0; k < feeders.size(); ++k) {
            const Feeder& F = feeders[k];
            rs[k] = F.done;
            for (const auto& [h, a] : F.left) {
                std::poisson_distribution<int> ph(F.avg * F.home * F.t[h].att * F.t[a].def), pa(F.avg / F.home * F.t[a].att * F.t[h].def);
                rs[k].push_back({h, a, ph(rng), pa(rng)});
            }
            for (const auto& r : rs[k]) {
                ptsSum[k][r.h] += r.hs > r.as ? 3 : r.hs == r.as ? 1 : 0;
                ptsSum[k][r.a] += r.as > r.hs ? 3 : r.hs == r.as ? 1 : 0;
            }
            int rank = 0;
            std::vector<int> fpo;   // this feeder's playoff places, in seed order
            for (int x : rankOf(F, rs[k], true)) {
                if (!F.t[x].skip.empty()) continue;
                ++rank;
                if (rank == champRank) { champs.push_back({(int)k, x}); champ[k][x]++; }
                else if (rank >= poFrom && rank <= poTo) fpo.push_back(x);
            }
            if (feederFirst) {
                const int w = seeded(fpo, (int)k);
                if (w >= 0) { fWin[k][w]++; po.push_back({(int)k, w}); }
            } else for (int x : fpo) po.push_back({(int)k, x});
        }
        std::vector<Side> lost;
        const Side w = knockout(champs, &lost);
        if (w.first >= 0) { autoUp[w.first][w.second]++; up[w.first][w.second] += 1.0; }
        if (losersIn) po.insert(po.end(), lost.begin(), lost.end());
        for (const auto& x : po) inPo[x.first][x.second]++;
        const Side pw = knockout(po, nullptr);
        if (pw.first >= 0) { winPo[pw.first][pw.second]++; up[pw.first][pw.second] += winSurvivor; }
    }

    const double S = sims > 0 ? sims : 1;
    for (size_t k = 0; k < feeders.size(); ++k) {
        const Feeder& F = feeders[k];
        json tj = json::array();
        int elig = 0;
        for (int x : rankOf(F, F.done, false)) {
            const FT& t = F.t[x];
            int p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0;
            for (const auto& r : F.done) {
                if (r.h != x && r.a != x) continue;
                const int us = r.h == x ? r.hs : r.as, them = r.h == x ? r.as : r.hs;
                p++; gf += us; ga += them; if (us > them) w++; else if (us < them) l++; else d++;
            }
            json j = {{"name", t.name}, {"p", p}, {"w", w}, {"d", d}, {"l", l}, {"gf", gf}, {"ga", ga}, {"pts", 3 * w + d}, {"left", t.left},
                      {"att", r2(t.att)}, {"def", r2(t.def)}, {"rating", r2(t.att / t.def)}, {"xpts", r1(ptsSum[k][x] / S)},
                      {"champ", r3(champ[k][x] / S)}, {"feeder_po", r3(fWin[k][x] / S)}, {"auto", r3(autoUp[k][x] / S)}, {"in_playoff", r3(inPo[k][x] / S)},
                      {"win_playoff", r3(winPo[k][x] / S)}, {"up", r3(up[k][x] / S)}};
            if (t.skip.empty()) j["elig"] = ++elig;
            else { j["skip"] = t.skip; if (!t.skipArg.empty()) j["skip_arg"] = t.skipArg; }
            tj.push_back(j);
        }
        out["feeders"].push_back({{"label", F.label}, {"played", F.played}, {"left", (int)F.left.size()}, {"avg_goals", r2(F.avg)}, {"teams", tj}});
    }
    return out;
}

struct Cached { std::string stamp; std::chrono::steady_clock::time_point at; json body; };
std::mutex gMutex;
std::map<std::pair<int, int>, Cached> gCache;   // (conference, form half-life in days × 100; 0 = off)
}  // namespace

json PyramidForecast::build(int conferenceId, int whatIfTeam, double whatIfRating, double form) {
    const bool whatIf = whatIfTeam > 0 && whatIfRating > 0;
    auto* db = Database::getInstance();
    const std::string cid = std::to_string(conferenceId);

    // Form (mig 1767): the conference's own half-life unless the page asks
    // for another of the listed levels (pyramid_forecast_form_levels; 0 =
    // every game the same).  A number that isn't a level = the default.
    double halfLife = 0;
    json formOut;
    {
        auto p = db->query("SELECT form_half_life_days FROM pyramid_forecast_policies "
                           " WHERE competition_id = $1::int OR competition_id IS NULL ORDER BY competition_id NULLS LAST LIMIT 1", {cid});
        const double dflt = p.empty() || p[0]["form_half_life_days"].is_null() ? 0 : num(p[0], "form_half_life_days");
        halfLife = dflt;
        json levels = json::array();
        for (const auto& r : db->query("SELECT half_life_days, label, is_recommended FROM pyramid_forecast_form_levels ORDER BY sort_order, id")) {
            const double d = r["half_life_days"].is_null() ? 0 : num(r, "half_life_days");
            if (form >= 0 && std::fabs(d - form) < 0.005) halfLife = d;
            levels.push_back({{"days", d}, {"label", str(r, "label")}, {"recommended", r["is_recommended"].as<bool>()}});
        }
        formOut = {{"levels", levels}, {"current", halfLife}, {"default", dflt}};
    }
    const std::pair<int, int> cacheKey{conferenceId, (int)std::lround(halfLife * 100)};

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
        auto it = gCache.find(cacheKey);
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

    // mig 1575: a one-table conference the league marks no relegation places
    // for, with no seasons of its own, takes them from its size
    // (pyramid_relegation_size_rules): whole spots = the bottom places
    // relegated, a half = the place above them in a relegation playoff.
    bool zonesAssumed = false;
    // Two tables (Mid-Atlantic): 1 spot = the bottom of each group play off,
    // the loser goes down (the paired relegation playoff below); 2 = the
    // bottom of each group goes down.  Other splits stay unmarked.
    if (divs.size() == 2 && N > 0) {
        bool hasDown = false;
        for (const auto& d : divs) for (const auto& z : d.zones) if (z["kind"].get<std::string>().find("relegation") != std::string::npos) hasDown = true;
        auto own = db->query("SELECT 1 FROM pyramid_relegation_outlook WHERE competition_id = $1::int LIMIT 1", {cid});
        if (!hasDown && own.empty()) {
            auto r = db->query("SELECT relegated::float8 AS d FROM pyramid_relegation_size_rules WHERE teams = $1::int OR teams IS NULL ORDER BY teams NULLS LAST LIMIT 1",
                               {std::to_string(N)});
            const double down = r.empty() ? 0 : num(r[0], "d");
            const char* kind = std::fabs(down - 1) < 1e-9 ? "relegation_playoff" : std::fabs(down - 2) < 1e-9 ? "relegation" : nullptr;
            if (kind)
                for (auto& d : divs) {
                    const int n = (int)d.teams.size();
                    if (n > 0) d.zones.push_back({{"kind", kind}, {"from", n}, {"to", n}, {"assumed", true}});
                }
            zonesAssumed = kind != nullptr;
        }
    }
    if (divs.size() == 1 && N > 0) {
        bool hasDown = false;
        for (const auto& z : divs[0].zones) if (z["kind"].get<std::string>().find("relegation") != std::string::npos) hasDown = true;
        auto own = db->query("SELECT 1 FROM pyramid_relegation_outlook WHERE competition_id = $1::int LIMIT 1", {cid});
        if (!hasDown && own.empty()) {
            auto r = db->query("SELECT relegated::float8 AS d FROM pyramid_relegation_size_rules WHERE teams = $1::int OR teams IS NULL ORDER BY teams NULLS LAST LIMIT 1",
                               {std::to_string(N)});
            const double down = r.empty() ? 0 : num(r[0], "d");
            const int whole = (int)std::floor(down + 1e-9);
            const bool half = down - whole > 0.25;
            if (whole > 0) divs[0].zones.push_back({{"kind", "relegation"}, {"from", N - whole + 1}, {"to", N}, {"assumed", true}});
            if (half && N - whole >= 1) divs[0].zones.push_back({{"kind", "relegation_playoff"}, {"from", N - whole}, {"to", N - whole}, {"assumed", true}});
            zonesAssumed = whole > 0 || half;
        }
    }

    // Games: every listed one between two of these teams, not cancelled.
    std::vector<Game> games;
    std::string asOf;
    for (const auto& r : db->query(
            "SELECT external_id, home_ext, away_ext, to_char(starts_local, 'YYYY-MM-DD\"T\"HH24:MI') AS w, complete, home_score, away_score, "
            "       EXTRACT(EPOCH FROM starts_local) / 86400.0 AS day "
            "  FROM pyramid_games WHERE source_id = $1::int AND division_ext = ANY(string_to_array($2, ',')) "
            "   AND removed_at IS NULL AND NOT cancelled ORDER BY starts_local, external_id", {std::to_string(sourceId), extList})) {
        auto h = byExt.find(str(r, "home_ext")), a = byExt.find(str(r, "away_ext"));
        if (h == byExt.end() || a == byExt.end() || h->second == a->second) continue;
        Game g; g.id = std::stoll(str(r, "external_id")); g.h = h->second; g.a = a->second; g.when = str(r, "w");
        g.day = r["day"].is_null() ? -1.0 : r["day"].as<double>();
        g.done = r["complete"].as<bool>() && !r["home_score"].is_null() && !r["away_score"].is_null();
        if (g.done) { g.hs = r["home_score"].as<int>(); g.as = r["away_score"].as<int>(); if (g.when > asOf) asOf = g.when; }
        games.push_back(g);
    }

    // Policy: this conference's row, else the default.
    int sims = 10000; double prior = 3, feederPct = 50; bool pair = true; std::string feeder;
    int groupRounds = 0, crossRounds = 0;   // mig 1449: 0 = only the listed games
    {
        auto p = db->query("SELECT sims, prior_games, pair_relegation_playoffs, feeder_label, feeder_stay_up_pct, group_rounds, cross_group_rounds FROM pyramid_forecast_policies "
                           " WHERE competition_id = $1::int OR competition_id IS NULL ORDER BY competition_id NULLS LAST LIMIT 1", {cid});
        if (!p.empty()) {
            sims = p[0]["sims"].as<int>(); prior = num(p[0], "prior_games"); pair = p[0]["pair_relegation_playoffs"].as<bool>();
            feeder = str(p[0], "feeder_label"); feederPct = num(p[0], "feeder_stay_up_pct");
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
    std::vector<double> fitDays;
    for (const auto& g : games) if (g.done) { played++; fitDone.push_back({g.h, g.a, g.hs, g.as}); fitDays.push_back(g.day); }
    double avg = 1.5, home = 1.0;
    {
        std::vector<double> att, def;
        fitMaher(N, fitDone, formWeights(fitDays, halfLife), prior, avg, home, att, def);
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
    out["model"] = {{"avg_goals", r2(avg)}, {"home_edge", r2(home * home)}, {"prior_games", prior}, {"form_half_life_days", halfLife > 0 ? json(halfLife) : json(nullptr)}};
    out["policy"] = {{"paired", paired}, {"feeder", feeder.empty() ? json(nullptr) : json(feeder)}, {"feeder_stay_up_pct", feederPct}};
    out["form"] = formOut;
    out["tiebreak"] = tiebreak;
    if (zonesAssumed) out["zones_assumed"] = true;
    out["outlook"] = outlookJson(db, cid, N, sims, prior, halfLife, feederPct, rng);
    if (whatIf) { out["what_if"] = whatIfOut; return out; }
    {
        std::lock_guard<std::mutex> lock(gMutex);
        gCache[cacheKey] = {stamp, std::chrono::steady_clock::now(), out};
    }
    return out;
}
