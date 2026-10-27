// game/src/tools/match_main.cpp — fh-game-match (G4.43)
//
// James: "yes" to "a version that loads both real teams from the database".
// fh-game-calibrate measures ratings typed on its command line; this runs
// the REAL matchup through the same path the live daemon uses
// (server::loadMatchFromDb → GameServer with a no-op network): the squads,
// game models, qualities, attributes, hand edits, formations, settings and
// curriculum, as they are in the club DB right now.
//
//   fh-game-match [matches=30] [minutes=90] [home:concept=demand,...|-] [away:...|-]
//
// Overrides change a team's game-model DEMAND for one run (A/B a concept on
// the real matchup), e.g. "home:blind-side-run=0"; "home:!marking" drops
// the players' own ABILITY rows for that concept (they fall back to their
// quality); "home:~direct-ball" drops their TENDENCY rows for it (G4.47).
// The DB is never written. GAME_PARAMS="key=value,..." overrides
// game_model_params numbers for the run.
// Env: POSTGRES_HOST (localhost from the host), POSTGRES_DB, POSTGRES_USER,
// POSTGRES_PASSWORD, GAME_TEAM_HOME / GAME_TEAM_AWAY.
//
// Each match uses seed base+m, so N matches are a fixed sample: the same
// DB gives the same numbers, and any difference IS a change.
//
// Play-practice-play (G4.59, DESIGN §8.55): GAME_PHASE="code:team" turns
// the run into N EPISODES of that phase of play instead of matches (team 0
// = home in possession). Each episode sets the phase up, plays it, and ends
// at the first of: a goal, the other team owning the ball, a dead ball given
// to them, or GAME_PHASE_SECONDS (default 30) with the ball still ours.
// The report is the coach's: did the restart get played, did we get over
// halfway and into the final third, how long it took, did we shoot, and
// where we lost it. Episode 1 prints the set-up.

#include "ai/Brain.hpp"
#include "core/Clock.hpp"
#include "net/INetworkTransport.hpp"
#include "server/GameServer.hpp"
#include "server/MatchSetup.hpp"

#include <algorithm>
#include <map>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using namespace fh::game;

namespace {

const char* envOr(const char* name, const char* fallback) {
    const char* v = std::getenv(name);
    return v && *v ? v : fallback;
}

// No clients, no I/O: the server just plays.
class NullTransport : public net::INetworkTransport {
public:
    void setOnConnect(OnConnectFn) override {}
    void setOnDisconnect(OnDisconnectFn) override {}
    void setOnMessage(OnMessageFn) override {}
    bool send(ClientId, std::span<const std::uint8_t>) override { return true; }
    void disconnect(ClientId) override {}
    std::size_t clientCount() const override { return 0; }
    void poll(int) override {}
};

// "home:blind-side-run=0,pass-ladder=50" → demand overrides on that side's model.
void applyOverrides(server::GameServer::Config& cfg, const char* spec, bool home) {
    if (!spec || !std::strcmp(spec, "-")) return;
    std::string s = spec;
    const std::string prefix = home ? "home:" : "away:";
    if (s.rfind(prefix, 0) != 0) {
        std::fprintf(stderr, "override '%s' must start with %s\n", spec, prefix.c_str());
        std::exit(2);
    }
    s = s.substr(prefix.size());
    const std::string& model = home ? cfg.roster_home.game_model : cfg.roster_away.game_model;
    persistence::GameModel* gm = nullptr;
    for (auto& m : cfg.models)
        if (m.name == model) gm = &m;
    if (!gm) {
        std::fprintf(stderr, "the %s team plays no game model; nothing to override\n", home ? "home" : "away");
        std::exit(2);
    }
    std::size_t at = 0;
    while (at < s.size()) {
        std::size_t end = s.find(',', at);
        if (end == std::string::npos) end = s.size();
        const std::string item = s.substr(at, end - at);
        if (!item.empty() && item[0] == '~') {
            const int id = core::concepts().find(item.substr(1));
            if (id < 0) { std::fprintf(stderr, "unknown concept '%s'\n", item.c_str() + 1); std::exit(2); }
            auto& team = home ? cfg.roster_home : cfg.roster_away;
            int dropped = 0;
            for (auto& p : team.players)
                for (auto it = p.tendencies.begin(); it != p.tendencies.end();)
                    if (it->first == id) { it = p.tendencies.erase(it); ++dropped; } else ++it;
            std::printf("override: %s tendency rows for %s dropped (%d)\n", model.c_str(), item.c_str() + 1, dropped);
            at = end + 1;
            continue;
        }
        if (!item.empty() && item[0] == '!') {
            const int id = core::concepts().find(item.substr(1));
            if (id < 0) { std::fprintf(stderr, "unknown concept '%s'\n", item.c_str() + 1); std::exit(2); }
            auto& team = home ? cfg.roster_home : cfg.roster_away;
            int dropped = 0;
            for (auto& p : team.players)
                for (auto it = p.concepts.begin(); it != p.concepts.end();)
                    if (it->first == id) { it = p.concepts.erase(it); ++dropped; } else ++it;
            std::printf("override: %s ability rows for %s dropped (%d)\n", model.c_str(), item.c_str() + 1, dropped);
            at = end + 1;
            continue;
        }
        const std::size_t eq = item.find('=');
        const int id = core::concepts().find(item.substr(0, eq));
        if (eq == std::string::npos || id < 0) {
            std::fprintf(stderr, "unknown override '%s'\n", item.c_str());
            std::exit(2);
        }
        gm->overlay[id] = static_cast<std::int16_t>(std::atoi(item.c_str() + eq + 1));
        std::printf("override: %s %s demand = %d\n", model.c_str(), item.substr(0, eq).c_str(), gm->overlay[id]);
        at = end + 1;
    }
}

// Pass outcomes by the passer's reason (Orders::why): every kick is
// resolved at the next player to own the ball — his own team (and whether
// it was the man he picked), the other team, or a dead ball first.
struct PassTally {
    long kicks = 0, mate = 0, intended = 0, lost = 0, dead = 0, offside = 0;
};

double median(std::vector<double> v) {
    if (v.empty()) return 0.0;
    std::sort(v.begin(), v.end());
    return v[v.size() / 2];
}

// GAME_PHASE episodes: the phase's own scoreboard, from the possessing
// team's side. Distances are metres from that team's own goal line.
int runPhaseEpisodes(const server::GameServer::Config& base, const server::MatchNames& names,
                     const std::string& spec, int episodes) {
    const auto colon = spec.find(':');
    const std::string code = spec.substr(0, colon);
    const int team = colon == std::string::npos ? 0 : std::atoi(spec.c_str() + colon + 1);
    std::size_t phase = base.phases.size();
    for (std::size_t p = 0; p < base.phases.size(); ++p)
        if (base.phases[p].code == code) phase = p;
    if (phase == base.phases.size() || team < 0 || team > 1) {
        std::fprintf(stderr, "GAME_PHASE '%s': no such phase (or team not 0/1); phases:", spec.c_str());
        for (const auto& ph : base.phases) std::fprintf(stderr, " %s", ph.code.c_str());
        std::fprintf(stderr, "\n");
        return 2;
    }
    const long cap = std::atol(envOr("GAME_PHASE_SECONDS", "30")) * core::kTickRate;
    const int trace = std::atoi(envOr("GAME_PHASE_TRACE", "0"));
    const char* watch = envOr("GAME_PHASE_WATCH", "");
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    const std::string& us = team == 0 ? names.team_home : names.team_away;
    const std::string& them = team == 0 ? names.team_away : names.team_home;
    enum End { Goal, Conceded, LostOwn, LostMid, LostFinal, OutToThem, Kept, EndCount };
    const char* end_names[EndCount] = {"scored", "conceded (their counter)", "lost it in our third",
                                       "lost it in the middle third", "lost it in their third",
                                       "dead ball to them (out / offside)", "still ours at the cap"};
    long ends[EndCount] = {}, played = 0, halfway = 0, third = 0, shot = 0;
    long passes = 0;
    // Where their build-up goes (G4.64), by the receiver's position number:
    // full-back 2/3, centre-back 4/5, the middle 6/8/10, else. A full-back's
    // pass back to a centre-back is the return pass the 9 locks out.
    std::map<std::pair<int, int>, long> by_number;   // (passer, receiver) numbers
    long to_fb = 0, to_cb = 0, to_mid = 0, to_else = 0, fb_to_cb = 0, fb_rx = 0, lost_after_fb = 0;
    // How each loss happened: taken off the carrier's foot, or the last
    // kick we made (by its reason) going to them.
    long lost_carry = 0, lost_kick[ai::kWhyCount + 1] = {}, losses = 0;
    long kicks[ai::kWhyCount + 1] = {};
    std::vector<double> t_play, t_half, t_third, depth_max, lost_at, kept_s;
    // The defending side (G4.63): how close the nearest defender is on each
    // first touch, and seconds of each defender order per episode.
    std::vector<double> touch_gap, touch_gap_short;
    double kick_x = 0, kick_y = 0;
    long d_why[ai::kWhyCount] = {}, d_ticks = 0;
    // G4.70-71 calls, [0 = us, 1 = them][why]: man-ticks a call was due to a
    // talker / he made it / a listener heard one.
    long call_due[2][ai::kWhyCount] = {}, call_made[2][ai::kWhyCount] = {}, call_heard[2][ai::kWhyCount] = {};
    for (int m = 0; m < episodes; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        s.runPhase(static_cast<std::uint8_t>(team), phase);
        const double hx = s.world().pitchHalfX().toDouble();
        auto from_goal = [&](double x) { return team == 0 ? x + hx : hx - x; };
        if (m == 0)
            for (std::uint8_t i = 0; i < s.world().playerCount(); ++i) {
                const auto& pl = s.world().player(i);
                const double x = pl.pos.x.toDouble(), y = pl.pos.y.toDouble();
                const bool home = pl.team == 0;
                std::printf("  %s slot %2d: %5.1f m from own goal, %+5.1f m across\n",
                            home ? names.team_home.c_str() : names.team_away.c_str(), i,
                            home ? x + hx : hx - x, home ? y : -y);
            }
        // Dead-ball phases wait for the restart to be played; open play is live.
        bool live = s.world().restartTeam() == 0xFF;
        if (live) t_play.push_back(0.0);
        int end = Kept, shots = 0, ep_passes = 0, last_ours = -1, last_kick = -1;
        double deepest = 0.0, where = 0.0;
        bool got_half = false, got_third = false;
        long k = 0;
        long fb_tick = -1000;
        int last_toucher = s.world().ball().last_kicker;
        int tracked = -1;
        for (; k < cap; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            const double sec = (k + 1) / static_cast<double>(core::kTickRate);
            bool done = false;
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Goal) { end = e.team == team ? Goal : Conceded; done = true; }
            if (done) break;
            if (!live) {
                if (s.world().restartTeam() != 0xFF) continue;
                live = true;
                t_play.push_back(sec);
            } else if (s.world().restartTeam() != 0xFF) {
                if (s.world().restartTeam() != team) { end = OutToThem; where = from_goal(b.pos.x.toDouble()); break; }
                continue;   // our throw / corner: the phase goes on
            }
            if (before && !b.owner && b.last_kicker == *before && s.world().player(*before).team == team) {
                const ai::Orders& o = s.lastOrders()[*before];
                last_kick = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                kick_x = b.pos.x.toDouble(); kick_y = b.pos.y.toDouble();
                if (trace == m + 1 && o.other >= 0) {
                    const auto& r = s.world().player(static_cast<std::uint8_t>(o.other));
                    const double dx = r.pos.x.toDouble() - b.pos.x.toDouble(), dy = r.pos.y.toDouble() - b.pos.y.toDouble();
                    std::printf("  t=%4.2f KICK %s by slot %d to slot %d, %.1f m away (at %.1f m, %+.1f across), ball %.1f m/s\n", sec,
                                ai::kWhyNames[static_cast<int>(o.why)], *before, o.other, std::sqrt(dx * dx + dy * dy),
                                from_goal(r.pos.x.toDouble()), team == 0 ? r.pos.y.toDouble() : -r.pos.y.toDouble(),
                                std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()));
                    tracked = o.other;
                    // Their men at the kick: what each is doing, how far from the receiver.
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == team) continue;
                        const ai::Orders& dj = s.lastOrders()[j];
                        const double ex = d.pos.x.toDouble() - r.pos.x.toDouble(), ey = d.pos.y.toDouble() - r.pos.y.toDouble();
                        std::printf("           them slot %2d %-22s %5.1f m from the receiver%s\n", j, ai::kWhyNames[static_cast<int>(dj.why)],
                                    std::sqrt(ex * ex + ey * ey), dj.other >= 0 ? (" → slot " + std::to_string(dj.other)).c_str() : "");
                    }
                }
                ++kicks[last_kick];
                if (o.why == ai::Why::Shoot) ++shots;
            }
            // Traced: every touch that doesn't stick (a bobble / deflection).
            if (trace == m + 1 && !b.owner && before == b.owner && b.last_kicker != last_toucher)
                std::printf("  t=%4.2f TOUCH slot %d (%s) at %.1f m/s — didn't keep it\n", sec, b.last_kicker,
                            ai::kWhyNames[static_cast<int>(s.lastOrders()[b.last_kicker].why)],
                            std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()));
            last_toucher = b.last_kicker;
            // GAME_PHASE_TRACE=n: episode n, twice a second — who has it,
            // what he's doing, where, and how close the nearest opponent is.
            // GAME_PHASE_WATCH=9,7,11: the defending side's men with those
            // numbers on the traced episode — what each is doing, and where.
            if (trace == m + 1 && k % (core::kTickRate / 2) == 0 && watch[0]) {
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team == team) continue;
                    const int num = s.brain().numberOf(j);
                    bool want = false;
                    for (const char* q = watch; *q;) {
                        want = want || std::atoi(q) == num;
                        while (*q && *q != ',') ++q;
                        if (*q == ',') ++q;
                    }
                    if (want) {
                        const int o = s.lastOrders()[j].other;
                        std::printf("  t=%4.1f   watch #%d slot %d %-22s at %5.1f m, %+5.1f across", sec, num, j,
                                    ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)],
                                    from_goal(d.pos.x.toDouble()), team == 0 ? d.pos.y.toDouble() : -d.pos.y.toDouble());
                        if (o >= 0) std::printf(" → their #%d (slot %d)", s.brain().numberOf(static_cast<std::uint8_t>(o)), o);
                        std::printf("\n");
                    }
                }
            }
            if (trace == m + 1 && k % (core::kTickRate / 2) == 0) {
                if (b.owner) {
                    const auto& c = s.world().player(*b.owner);
                    double near = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == c.team) continue;
                        const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                    }
                    std::printf("  t=%4.1f slot %2d %-22s at %5.1f m, %+5.1f across, nearest opponent %.1f m\n", sec, *b.owner,
                                ai::kWhyNames[static_cast<int>(s.lastOrders()[*b.owner].why)],
                                from_goal(c.pos.x.toDouble()), team == 0 ? c.pos.y.toDouble() : -c.pos.y.toDouble(), near);
                } else {
                    // Loose: the nearest man of each side and what he's doing.
                    int nb[2] = {-1, -1};
                    double nd[2] = {1e9, 1e9};
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        const double dx = d.pos.x.toDouble() - b.pos.x.toDouble(), dy = d.pos.y.toDouble() - b.pos.y.toDouble();
                        const double dd = std::sqrt(dx * dx + dy * dy);
                        const int side = d.team == team ? 0 : 1;
                        if (dd < nd[side]) { nd[side] = dd; nb[side] = j; }
                    }
                    if (tracked >= 0) {
                        const auto& r = s.world().player(static_cast<std::uint8_t>(tracked));
                        const double dx = r.pos.x.toDouble() - b.pos.x.toDouble(), dy = r.pos.y.toDouble() - b.pos.y.toDouble();
                        std::printf("  t=%4.1f   receiver slot %d %.1f m from the ball, %s\n", sec, tracked, std::sqrt(dx * dx + dy * dy),
                                    ai::kWhyNames[static_cast<int>(s.lastOrders()[tracked].why)]);
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                        if (s.lastOrders()[j].why == ai::Why::JumpPass) {
                            const auto& d = s.world().player(j);
                            const auto& o = s.lastOrders()[j];
                            const auto& r = s.world().player(static_cast<std::uint8_t>(o.other));
                            const double ex = d.pos.x.toDouble() - r.pos.x.toDouble(), ey = d.pos.y.toDouble() - r.pos.y.toDouble();
                            const double tx = d.pos.x.toDouble() - o.target.x.toDouble(), ty = d.pos.y.toDouble() - o.target.y.toDouble();
                            std::printf("  t=%4.1f   JUMP slot %d on slot %d: %.1f m from him, %.1f m from his spot, %.1f m/s\n", sec, j, o.other,
                                        std::sqrt(ex * ex + ey * ey), std::sqrt(tx * tx + ty * ty),
                                        std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()));
                        }
                    std::printf("  t=%4.1f ball loose at %5.1f m, %+5.1f across, %.1f m/s | ours: slot %d %.1f m %s | theirs: slot %d %.1f m %s\n",
                                sec, from_goal(b.pos.x.toDouble()), team == 0 ? b.pos.y.toDouble() : -b.pos.y.toDouble(),
                                std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                                nb[0], nd[0], ai::kWhyNames[static_cast<int>(s.lastOrders()[nb[0]].why)],
                                nb[1], nd[1], ai::kWhyNames[static_cast<int>(s.lastOrders()[nb[1]].why)]);
                }
            }
            if (live)
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                    if (s.world().player(j).team != team && !s.world().isKeeper(j)) {
                        ++d_why[static_cast<int>(s.lastOrders()[j].why)];
                        ++d_ticks;
                    }
            if (live)
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const ai::Orders& o = s.lastOrders()[j];
                    const int side = s.world().player(j).team == team ? 0 : 1;
                    if (o.due != ai::Why::Hold) ++call_due[side][static_cast<int>(o.due)];
                    if (o.call_to >= 0) ++call_made[side][static_cast<int>(o.call)];
                    if (o.heard != ai::Why::Hold) ++call_heard[side][static_cast<int>(o.heard)];
                }
            if (!b.owner) continue;
            const auto& c = s.world().player(*b.owner);
            const double g = from_goal(b.pos.x.toDouble());
            if (c.team != team) {
                where = g;
                end = g < hx * 2 / 3 ? LostOwn : g < hx * 4 / 3 ? LostMid : LostFinal;
                ++losses;
                if (k - fb_tick <= 5 * core::kTickRate) ++lost_after_fb;
                if (before && s.world().player(*before).team == team) ++lost_carry;
                else if (last_kick >= 0) ++lost_kick[last_kick];
                break;
            }
            if (!before) {   // a first touch: how close is their nearest man?
                double near = 1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team == team) continue;
                    const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                    near = std::min(near, std::sqrt(dx * dx + dy * dy));
                }
                touch_gap.push_back(near);
                const double kx = c.pos.x.toDouble() - kick_x, ky = c.pos.y.toDouble() - kick_y;
                if (std::sqrt(kx * kx + ky * ky) <= 25.0) touch_gap_short.push_back(near);
            }
            last_kick = -1;   // ours again: the kick reached a mate
            if (last_ours >= 0 && *b.owner != last_ours) {
                ++ep_passes;
                const int rn = s.brain().numberOf(*b.owner), pn = s.brain().numberOf(static_cast<std::uint8_t>(last_ours));
                const bool fb = rn == 2 || rn == 3;
                ++by_number[{pn, rn}];
                if (fb) { ++to_fb; ++fb_rx; fb_tick = k; }
                else if (rn == 4 || rn == 5) { ++to_cb; if (pn == 2 || pn == 3) ++fb_to_cb; }
                else if (rn == 6 || rn == 8 || rn == 10) ++to_mid;
                else ++to_else;
            }
            last_ours = *b.owner;
            if (g > deepest) deepest = g;
            if (!got_half && g > hx) { got_half = true; t_half.push_back(sec); }
            if (!got_third && g > hx * 4 / 3) { got_third = true; t_third.push_back(sec); }
        }
        ++ends[end];
        played += live;
        halfway += got_half; third += got_third;
        shot += shots > 0;
        passes += ep_passes;
        depth_max.push_back(deepest);
        kept_s.push_back(k / static_cast<double>(core::kTickRate));
        if (end >= LostOwn && end <= OutToThem) lost_at.push_back(where);
        std::printf("episode %3d: %-34s %4.1f s | %2d passes | deepest %5.1f m", m + 1, end_names[end],
                    k / static_cast<double>(core::kTickRate), ep_passes, deepest);
        if (shots) std::printf(" | %d shot%s", shots, shots > 1 ? "s" : "");
        if (end >= LostOwn && end <= OutToThem) std::printf(" | lost at %.1f m", where);
        std::printf("\n");
    }
    const double n = episodes;
    std::printf("\nPhase '%s', %s in possession against %s: %d episodes, cap %ld s\n", code.c_str(),
                us.c_str(), them.c_str(), episodes, cap / core::kTickRate);
    std::printf("  restart played     %5.1f%%  (median %.1f s)\n", 100.0 * played / n, median(t_play));
    std::printf("  over halfway       %5.1f%%  (median %.1f s)\n", 100.0 * halfway / n, median(t_half));
    std::printf("  into final third   %5.1f%%  (median %.1f s)\n", 100.0 * third / n, median(t_third));
    std::printf("  got a shot         %5.1f%%\n", 100.0 * shot / n);
    std::printf("  kept the ball      %5.1f s (median episode)\n", median(kept_s));
    std::printf("  passes completed   %5.1f per episode; deepest ball %.1f m (median)\n", passes / n, median(depth_max));
    {
        const long all = to_fb + to_cb + to_mid + to_else;
        if (all)
            std::printf("  passes to: full-back %.0f%% · centre-back %.0f%% · the middle (6/8/10) %.0f%% · else %.0f%% (of %ld)\n"
                        "  full-back back to a centre-back: %.2f per episode; lost within 5 s of a pass to a full-back: %.0f%% (of %ld)\n",
                        100.0 * to_fb / all, 100.0 * to_cb / all, 100.0 * to_mid / all, 100.0 * to_else / all, all,
                        fb_to_cb / n, fb_rx ? 100.0 * lost_after_fb / fb_rx : 0.0, fb_rx);
        std::vector<std::pair<long, std::pair<int, int>>> top;
        for (const auto& [k2, v] : by_number) top.push_back({v, k2});
        std::sort(top.rbegin(), top.rend());
        if (!top.empty()) std::printf("  commonest passes (by number):");
        for (std::size_t i = 0; i < top.size() && i < 8; ++i)
            std::printf(" %d→%d %ld", top[i].second.first, top[i].second.second, top[i].first);
        if (!top.empty()) std::printf("\n");
    }
    std::printf("  how it ended:\n");
    for (int e = 0; e < EndCount; ++e)
        if (ends[e]) std::printf("    %-36s %5.1f%%\n", end_names[e], 100.0 * ends[e] / n);
    if (!lost_at.empty()) std::printf("  lost it %.1f m from our goal (median)\n", median(lost_at));
    if (losses) {
        std::printf("  how the ball was lost (of %ld): taken off the carrier %.0f%%", losses, 100.0 * lost_carry / losses);
        for (int w = 0; w <= ai::kWhyCount; ++w)
            if (lost_kick[w])
                std::printf(" · %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * lost_kick[w] / losses);
        std::printf("\n  kicks per episode:");
        for (int w = 0; w <= ai::kWhyCount; ++w)
            if (kicks[w]) std::printf(" %s %.2f", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], kicks[w] / n);
        std::printf("\n");
    }
    if (!touch_gap.empty()) {
        long tight = 0;
        for (double g : touch_gap) tight += g <= 2.0;
        std::printf("  %s on our first touch: nearest man %.1f m (median), within 2 m %.0f%% (of %zu)\n", them.c_str(),
                    median(touch_gap), 100.0 * tight / touch_gap.size(), touch_gap.size());
        tight = 0;
        for (double g : touch_gap_short) tight += g <= 2.0;
        if (!touch_gap_short.empty())
            std::printf("    after a pass of 25 m or less: nearest man %.1f m (median), within 2 m %.0f%% (of %zu)\n",
                        median(touch_gap_short), 100.0 * tight / touch_gap_short.size(), touch_gap_short.size());
    }
    if (d_ticks) {
        std::printf("  %s outfield orders (share of man-ticks):", them.c_str());
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (d_why[w] * 1000 >= d_ticks) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * d_why[w] / d_ticks);
            else if (d_why[w]) std::printf(" %s %.2f%%", ai::kWhyNames[w], 100.0 * d_why[w] / d_ticks);   // rare: still shown
        std::printf("\n");
    }
    for (int side = 0; side < 2; ++side) {
        bool head = false;
        for (int w = 0; w < ai::kWhyCount; ++w) {
            if (!call_due[side][w]) continue;
            if (!head) std::printf("  %s calls:", (side == 0 ? us : them).c_str());
            head = true;
            std::printf(" | %s: due %.1f s/ep, made %.0f%%, heard by %.2f per call", ai::kWhyNames[w] + 6,
                        call_due[side][w] / 30.0 / n, 100.0 * call_made[side][w] / call_due[side][w],
                        call_made[side][w] ? static_cast<double>(call_heard[side][w]) / call_made[side][w] : 0.0);
        }
        if (head) std::printf("\n");
    }
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    const int matches = argc > 1 ? std::atoi(argv[1]) : 30;
    const int minutes = argc > 2 ? std::atoi(argv[2]) : 90;

    server::GameServer::Config base{};
    base.match_id = 1;
    base.slot_count = 22;
    persistence::DbConfig db;
    db.host = envOr("POSTGRES_HOST", "localhost");
    db.dbname = envOr("POSTGRES_DB", "footballhome");
    db.user = envOr("POSTGRES_USER", "footballhome_user");
    db.password = envOr("POSTGRES_PASSWORD", "");
    server::MatchNames names;
    names.team_home = envOr("GAME_TEAM_HOME", names.team_home.c_str());
    names.team_away = envOr("GAME_TEAM_AWAY", names.team_away.c_str());
    server::loadMatchFromDb(base, db, names, true);
    // GAME_PARAMS="concept.meet-the-pass.keep_running_mps=99,..." — A/B a
    // game_model_params number (both teams) without touching the DB.
    if (const char* gp = std::getenv("GAME_PARAMS")) {
        std::string s = gp;
        std::size_t at = 0;
        while (at < s.size()) {
            std::size_t end = s.find(',', at);
            if (end == std::string::npos) end = s.size();
            const std::string item = s.substr(at, end - at);
            const std::size_t eq = item.find('=');
            if (eq != std::string::npos) {
                base.model_params.setMilli(item.substr(0, eq),
                                           std::llround(std::atof(item.c_str() + eq + 1) * 1000));
                std::printf("param: %s\n", item.c_str());
            }
            at = end + 1;
        }
    }
    applyOverrides(base, argc > 3 ? argv[3] : "-", true);
    applyOverrides(base, argc > 4 ? argv[4] : "-", false);

    if (const char* gp = std::getenv("GAME_PHASE"))
        return runPhaseEpisodes(base, names, gp, matches);

    const long ticks = static_cast<long>(minutes) * 60 * core::kTickRate;
    const std::uint64_t seed0 = std::strtoull(envOr("GAME_MATCH_SEED", "1000"), nullptr, 10);
    int w = 0, d = 0, l = 0;
    long gh = 0, ga = 0;
    std::vector<int> margins;
    PassTally tally[2][ai::kWhyCount + 1] = {};  // + rungs 1-2: the ball in behind
    // Goal anatomy: the reason of the last completed pass before each goal
    // (the "assist"), and how many were breakaways (no outfield defender
    // goal-side of the shooter when he shot).
    long assist[2][ai::kWhyCount + 2] = {};   // +1 = none (won it and went), +2 slot spare
    long breakaways[2] = {0, 0};
    // Escort attribution: every tick a team carries in the final third
    // (17.5 m past halfway), the nearest defender's reason and distance.
    long esc_ticks[2] = {0, 0}, esc_why[2][ai::kWhyCount] = {}, esc_near[2] = {0, 0};
    long entries[2] = {0, 0};
    // Line height (G4.55): every live tick a team is out of possession, its
    // back line (deepest outfielder) and front (most advanced) in metres
    // from its own goal, and the ball's. Real: the line ~35-45 m out, the
    // team ~30-35 m long, the line ~20-25 m behind the ball.
    double ln_sum[2] = {0, 0}, front_sum[2] = {0, 0}, ball_sum[2] = {0, 0};
    long ln_ticks[2] = {0, 0}, ln_deep[2] = {0, 0};
    long oop_why[2][ai::kWhyCount] = {}, oop_n[2] = {0, 0};   // outfielders' reasons out of possession
    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        int pend_team = -1, pend_why = 0, pend_other = -1;
        int last_assist[2] = {ai::kWhyCount + 1, ai::kWhyCount + 1};
        bool shot_breakaway[2] = {false, false};
        bool in_third[2] = {false, false};
        for (long k = 0; k < ticks; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            if (b.owner && s.world().restartTeam() == 0xFF) {
                const int dt = s.world().player(*b.owner).team ^ 1;   // defending team
                const double hx = 52.5;
                auto from_goal = [&](double x) { return dt == 0 ? x + hx : hx - x; };
                double deep = 1e9, front = -1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    const auto& d = s.world().player(j);
                    if (d.team != dt || s.world().isKeeper(j)) continue;
                    const double g = from_goal(d.pos.x.toDouble());
                    if (g < deep) deep = g;
                    if (g > front) front = g;
                    ++oop_why[dt][static_cast<int>(s.lastOrders()[j].why)];
                    ++oop_n[dt];
                }
                ln_sum[dt] += deep; front_sum[dt] += front - deep;
                ball_sum[dt] += from_goal(b.pos.x.toDouble()) - deep;
                ++ln_ticks[dt];
                if (deep < 20.0) ++ln_deep[dt];
            }
            if (b.owner) {
                const auto& c = s.world().player(*b.owner);
                const int ct = c.team;
                const bool third = (ct == 0 ? c.pos.x.toDouble() : -c.pos.x.toDouble()) > 17.5;
                if (third && !in_third[ct]) ++entries[ct];
                in_third[ct] = third;
                in_third[ct ^ 1] = false;
                if (third) {
                    double best = 1e9; int who = -1;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == ct || s.world().isKeeper(j)) continue;
                        const double dx = d.pos.x.toDouble() - c.pos.x.toDouble(), dy = d.pos.y.toDouble() - c.pos.y.toDouble();
                        if (dx * dx + dy * dy < best) { best = dx * dx + dy * dy; who = j; }
                    }
                    ++esc_ticks[ct];
                    if (who >= 0) ++esc_why[ct][static_cast<int>(s.lastOrders()[who].why)];
                    if (best < 1.8 * 1.8) ++esc_near[ct];
                }
            }
            for (const auto& e : s.lastEvents()) {
                if (e.type != core::MatchEventType::Goal) continue;
                ++assist[e.team][last_assist[e.team]];
                if (shot_breakaway[e.team]) ++breakaways[e.team];
            }
            if (b.owner) {  // a change of possession resets the move
                const int ot = s.world().player(*b.owner).team;
                if (before && s.world().player(*before).team != ot) last_assist[ot] = ai::kWhyCount + 1;
            }
            if (pend_team >= 0) {
                PassTally& t = tally[pend_team][pend_why];
                if (s.world().restartTeam() != 0xFF) {
                    ++t.dead;
                    for (const auto& e : s.lastEvents())
                        if (e.type == core::MatchEventType::Offside) ++t.offside;
                    pend_team = -1;
                } else if (b.owner) {
                    if (s.world().player(*b.owner).team == pend_team) {
                        if (pend_why != static_cast<int>(ai::Why::Shoot)) last_assist[pend_team] = pend_why;
                        ++t.mate;
                        if (*b.owner == pend_other) ++t.intended;
                    } else {
                        ++t.lost;
                    }
                    pend_team = -1;
                }
            }
            if (before && !b.owner && b.last_kicker == *before &&
                s.world().restartTeam() == 0xFF) {
                const ai::Orders& o = s.lastOrders()[*before];
                pend_team = s.world().player(*before).team;
                if (o.why == ai::Why::Shoot) {
                    const auto& sh = s.world().player(*before);
                    bool alone = true;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == sh.team || s.world().isKeeper(j)) continue;
                        if (sh.team == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) alone = false;
                    }
                    shot_breakaway[pend_team] = alone;
                }
                pend_why = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                pend_other = o.other;
                ++tally[pend_team][pend_why].kicks;
            }
        }
        const int h = s.world().score(0), a = s.world().score(1);
        gh += h; ga += a;
        margins.push_back(h - a);
        (h > a ? w : (h == a ? d : l))++;
        std::printf("match %2d: %s %d - %d %s\n", m + 1, names.team_home.c_str(), h, a, names.team_away.c_str());
    }
    double mean = 0, var = 0;
    for (int x : margins) mean += x;
    mean /= margins.size();
    for (int x : margins) var += (x - mean) * (x - mean);
    const double se = margins.size() > 1 ? std::sqrt(var / (margins.size() - 1) / margins.size()) : 0.0;
    std::printf("\n%s vs %s over %d matches: W%d D%d L%d | goals %.2f - %.2f | margin %+.2f ± %.2f (1 SE)\n",
                names.team_home.c_str(), names.team_away.c_str(), matches, w, d, l,
                static_cast<double>(gh) / matches, static_cast<double>(ga) / matches, mean, se);
    // Pass outcomes (Shoot/Clear/punts included: every kick from a carry).
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s kicks per match by reason: kicks | to a mate (the one he picked) | lost | dead (offside)\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str());
        for (int w = 0; w <= ai::kWhyCount; ++w) {
            const PassTally& t = tally[team][w];
            if (t.kicks == 0) continue;
            const double n = matches;
            std::printf("  %-28s %6.1f | %5.1f%% (%5.1f%%) | %5.1f%% | %5.1f%% (%4.1f%%)\n", w == ai::kWhyCount ? "in behind (rungs 1-2)" : ai::kWhyNames[w],
                        t.kicks / n, 100.0 * t.mate / t.kicks, 100.0 * t.intended / t.kicks,
                        100.0 * t.lost / t.kicks, 100.0 * t.dead / t.kicks, 100.0 * t.offside / t.kicks);
        }
    }
    for (int team = 0; team < 2; ++team)
        if (ln_ticks[team])
            std::printf("\n%s out of possession: back line %.1f m from own goal (inside 20 m %.0f%% of the time), team %.1f m long, ball %.1f m beyond the line\n",
                        team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                        ln_sum[team] / ln_ticks[team], 100.0 * ln_deep[team] / ln_ticks[team],
                        front_sum[team] / ln_ticks[team], ball_sum[team] / ln_ticks[team]);
    for (int team = 0; team < 2; ++team) {
        if (!oop_n[team]) continue;
        std::printf("%s outfielders out of possession are doing:", team == 0 ? names.team_home.c_str() : names.team_away.c_str());
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (oop_why[team][w] * 100 >= oop_n[team])   // 1%+
                std::printf(" %s %.0f%% ·", ai::kWhyNames[w], 100.0 * oop_why[team][w] / oop_n[team]);
        std::printf("\n");
    }
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s final-third entries %.1f/match, carrying %.0f s/match there, tight (<1.8 m) %.0f%%; nearest defender doing:\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                    static_cast<double>(entries[team]) / matches, esc_ticks[team] / 30.0 / matches,
                    esc_ticks[team] ? 100.0 * esc_near[team] / esc_ticks[team] : 0.0);
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (esc_why[team][w] * 100 >= esc_ticks[team] * 2)
                std::printf("  %-28s %4.0f%%\n", ai::kWhyNames[w], 100.0 * esc_why[team][w] / esc_ticks[team]);
    }
    for (int team = 0; team < 2; ++team) {
        std::printf("\n%s goals per match by the last pass before them (breakaways %.2f):\n",
                    team == 0 ? names.team_home.c_str() : names.team_away.c_str(),
                    static_cast<double>(breakaways[team]) / matches);
        for (int w = 0; w <= ai::kWhyCount + 1; ++w) {
            if (!assist[team][w]) continue;
            const char* n = w == ai::kWhyCount ? "in behind (rungs 1-2)"
                          : w == ai::kWhyCount + 1 ? "(no pass: won it / carried)" : ai::kWhyNames[w];
            std::printf("  %-28s %5.2f\n", n, static_cast<double>(assist[team][w]) / matches);
        }
    }
    return 0;
}
