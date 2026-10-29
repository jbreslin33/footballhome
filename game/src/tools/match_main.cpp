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
#include "persistence/FormationStore.hpp"
#include "server/MatchSetup.hpp"

#include <algorithm>
#include <array>
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
        gm->overlay[id] = gm->own[id] = static_cast<std::int16_t>(std::atoi(item.c_str() + eq + 1));
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
    // G4.80: the crowd (outfielders within 10 m of the ball, carrier
    // excluded) and the spread (outfield width x length), by team, with the
    // ball [0] and without [1]; overruns = player-ticks moving > 2.5 m/s
    // AWAY from his own target while within 2.5 m of it (ran past it).
    double crowd_sum[2][2] = {}, wide_sum[2][2] = {}, long_sum[2][2] = {};
    long crowd_ticks[2][2] = {}, overrun[2] = {0, 0}, overrun_why[2][ai::kWhyCount] = {};
    // Off his position: outfielder-ticks > 10 m from his ball-shifted
    // formation spot, by why, with [0] / without [1] the ball.
    long off_ticks[2][2] = {}, off_n[2][2] = {}, off_why[2][2][ai::kWhyCount] = {};
    double off_sum[2][2] = {};
    long ip_why[2][ai::kWhyCount] = {}, ip_n[2] = {0, 0};   // outfielders' reasons in possession (off the ball)
    // Possession spells (a team's ball, from winning it to losing it), and
    // a man holding shape's gap to the spot he holds, in the first 5 s of
    // his team's spell [0] or after [1] — lag behind a shape that moved.
    long spells = 0, spell_ticks = 0;
    // Shot anatomy (G4.81): each shot by the spell's age when it was hit
    // (transition < 10 s vs settled), the defending outfielders goal-side
    // of the ball, its distance, the nearest defender. Rest defence: at
    // each change of possession, the LOSING team's outfielders goal-side
    // of the ball. Real: most shots come from settled attacks against
    // 6-9 men behind the ball; a counter faces 3-4.
    long shot_age[2][4] = {}, shot_behind[2][4] = {}, shot_dist[2][4] = {}, shot_near[2][4] = {};
    long shot_n[2] = {0, 0}, rest_hist[2][12] = {}, rest_n[2] = {0, 0};
    // ...and the shooter's own touch: defenders goal-side of him when he GOT
    // it (beaten by the ball to him vs by his carry), the metres he carried,
    // where his team won the ball (m from the goal it attacks).
    long recv_behind[2][4] = {}, carry_m[2][4] = {}, won_at[2][4] = {};
    // How a team loses the ball within 35 m of its OWN goal: the why of its
    // last kick in that spell (+ kick metres, ball height), or dispossessed
    // on the ball (no kick), and how long it had held it.
    long own3_lost[2][ai::kWhyCount + 1] = {}, own3_n[2] = {0, 0}, own3_age[2][4] = {};
    double own3_kick_m[2] = {0, 0}; long own3_kicks[2] = {0, 0};
    long own3_rwhy[2][ai::kWhyCount] = {}, own3_rn[2] = {0, 0};
    double own3_rgap[2] = {0, 0}, own3_igap[2] = {0, 0};
    long own3_first[2][5] = {};
    // Every pass to a picked man (not shots/clears/punts), by how free he was
    // at the kick (his nearest opponent): played / to him / lost.
    long fr_n[2][4] = {}, fr_got[2][4] = {}, fr_lost[2][4] = {};
    // An own-third loss the winners shoot from — inside 10 s / that spell
    // (benchmark own_third_loss_shot_*), counted on the LOSING team.
    long own3_shot10[2] = {0, 0}, own3_shot_spell[2] = {0, 0};
    // How each spell ended (G4.82), by the LOSING team: 0 pass, 1 clear (or
    // punt), 2 shot, 3 bad touch, 4 on the ball (tackled / stolen).
    long end_cause[2][5] = {}, ends[2] = {0, 0};
    // A pass the other side took: cut out while still travelling (>= 3 m/s
    // the tick before — StatsBomb's Interception) or picked up slower (a
    // recovery), by the team that TOOK it; and every bobble (bad touch).
    long cut[2] = {0, 0}, picked[2] = {0, 0}, bobbles[2] = {0, 0};
    // ...each bad touch (G4.85): whose ball it was (the pass meant for him /
    // another of ours / theirs — a reaction touch) × its speed the tick before.
    long bt_kind[3][4] = {};
    // ...the defender's side of it (G4.86): every touch on THEIR moving ball
    // (3 m/s+), kept or off him, by his job and his own speed (<2 / 2-4 / 4-6
    // / 6+ m/s) — is the reaction touch a lunge or a man who was set?
    // The officials (G4.88): offsides whistled against each team; whistles for
    // an onside man and offside touches nobody flagged (World counters); men
    // flagged wrong / missed at each kick into their half; where the judging
    // assistant stood off level with the line (+ = beyond it).
    // Each offside whistle (G4.89): the kick it came off, was he the man it
    // was played to, his job at the kick, how far past the line he stood.
    long ow_n = 0, ow_why[ai::kWhyCount + 1] = {}, ow_intended = 0, ow_job[ai::kWhyCount] = {}, ow_depth[4] = {};
    // Men standing in an offside position at a kick (G4.91): by job, by how
    // far past, how long he has been there; and the kicks with one.
    long op_men = 0, op_kicks = 0, op_all_kicks = 0, op_job[ai::kWhyCount] = {}, op_depth[4] = {}, op_age[4] = {};
    long off_called[2] = {}, off_wrong = 0, off_missed = 0, flag_wrong = 0, flag_missed = 0, flag_kicks = 0;
    long ar_off[5] = {};
    double ar_off_sum = 0;
    long rt_n[2][ai::kWhyCount] = {}, rt_sp[2][4] = {}, rt_rel[2][4] = {};
    // ...balls in behind the read gave to THEM at the kick (G4.86): how far
    // the strike went off his aim, and where their man meets it — in the lane
    // before the spot, at it (±3 m), or after it ran on.
    long ib_n = 0, ib_err[4] = {}, ib_where[3] = {}, ib_all_read[2] = {}, ib_theirs_read[2] = {};
    bool kick_read = false;
    long ib_seen[2] = {}, ib_age[4] = {}, ib_loft_all[2] = {}, ib_loft_theirs[2] = {};   // read & theirs: their man in the passer's view at the kick; the passer's look age
    // ...each interception: how far the man moved from where he stood at the
    // kick (< 1 m = he was in the lane), how long the pass had flown, and
    // the pass's kind (by its why).
    long pred_all[3] = {}, pred_cut[3] = {}, pred_why[ai::kWhyCount + 1][3] = {};
    // Cut passes the flight read gave to US: was the cutter their predicted
    // first man; our predicted man's job 0.3 s in; the margin we had (ticks).
    long po_n = 0, po_cutter_pred = 0, po_us_why[ai::kWhyCount] = {}, po_margin[4] = {};   // passes (any kind) by the flight read at kick+1, and the cut ones
    long cut_moved[4] = {}, cut_time[4] = {}, cut_n = 0, cut_by_why[ai::kWhyCount + 1] = {}, cut_why_taker[ai::kWhyCount] = {};
    double hold_gap[2] = {0, 0};
    long hold_n[2] = {0, 0};
    for (int m = 0; m < matches; ++m) {
        server::GameServer::Config cfg = base;
        cfg.match_seed = seed0 + static_cast<std::uint64_t>(m);
        NullTransport t;
        server::GameServer s{cfg, t};
        int pend_team = -1, pend_why = 0, pend_other = -1;
        int last_assist[2] = {ai::kWhyCount + 1, ai::kWhyCount + 1};
        bool shot_breakaway[2] = {false, false};
        bool in_third[2] = {false, false};
        int spell_team = -1;
        long spell_start = 0;
        int rx_slot = -1, rx_behind = 0;
        int lk_to[2] = {-1, -1};
        double prev_ball_v = 0;
        int prev_ltt = -1, prev_pass_to = -1;
        double prev_bvx = 0, prev_bvy = 0;
        std::vector<std::array<double, 2>> prev_ov(64, {0.0, 0.0});   // everyone's velocity last tick
        std::vector<math::Vec2> kick_at;   // everyone's spot at the last kick
        long kick_tick = 0;
        math::Vec2 kick_aim{}, kick_from{};
        int kick_passer = -1;
        std::vector<long> off_since(64, 0);   // the tick each man last stood onside (G4.91)
        std::vector<int> kick_job;   // everyone's job at the last kick
        int kick_pred = -1;
        int pred_us = -1, pred_them = -1, pred_margin = 0, pred_us_why = -1;   // at kick+1 / +10
        // GAME_TRACE_FLIP=n: passes the read gave to us that they cut (match 1).
        static const int trace_flip = std::atoi(envOr("GAME_TRACE_FLIP", "0"));
        int flips = 0;
        std::vector<std::string> flip_lines;   // flight read one tick after the kick: 0 ours first, 1 theirs first, 2 nobody
        std::uint64_t prev_bad = 0;
        // GAME_TRACE_LOST=n: print the first n own-third lost kicks (match 1).
        static const int trace_lost = std::atoi(envOr("GAME_TRACE_LOST", "0"));
        int traced = 0;
        int lk_rwhy10[2] = {-1, -1}, lk_first10[2] = {-9, -9};
        int pf_bucket = -1;
        int o3_team = -1; long o3_tick = 0; bool o3_10 = false, o3_any = false;   // the spell an own-third loss started
        // GAME_TRACE_FREE=n: the first n passes to a man 10 m+ free that went
        // wrong (match 1): the kick, then who touched it.
        static const int trace_free = std::atoi(envOr("GAME_TRACE_FREE", "0"));
        int tf_done = 0; long tf_tick = -1; int tf_to = -1, tf_team = -1; double tf_len = 0;
        std::string tf_line;
        std::vector<std::string> tf_ticks;   // GAME_TRACE_FREE_TICKS=1: the flight, every 6 ticks
        static const bool tf_verbose = std::atoi(envOr("GAME_TRACE_FREE_TICKS", "0")) != 0;
        std::vector<math::Vec2> lk_snap[2];
        double lk_tx[2] = {0, 0}, lk_ty[2] = {0, 0}, lk_vx[2] = {0, 0}, lk_vy[2] = {0, 0};
        int lk_why[2] = {-1, -1}; long lk_tick[2] = {-1, -1}; double lk_x[2] = {0, 0}, lk_y[2] = {0, 0};
        double rx_x = 0, rx_y = 0, won_x = 0;
        auto goalSide = [&](int team, double x) {   // opponents of `team` goal-side of x
            int n = 0;
            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                const auto& d = s.world().player(j);
                if (d.team == team || s.world().isKeeper(j)) continue;
                if (team == 0 ? d.pos.x.toDouble() > x : d.pos.x.toDouble() < x) ++n;
            }
            return n;
        };
        for (long k = 0; k < ticks; ++k) {
            const auto before = s.world().ball().owner;
            s.tickOnce();
            const auto& b = s.world().ball();
            if (b.owner && (!before || *before != *b.owner)) {
                const auto& r = s.world().player(*b.owner);
                rx_slot = *b.owner; rx_x = r.pos.x.toDouble(); rx_y = r.pos.y.toDouble();
                rx_behind = goalSide(r.team, rx_x);
                lk_tick[r.team] = -1;   // a mate got it: the kick wasn't lost
            }
            if (tf_verbose && tf_tick >= 0 && (k - tf_tick) % 6 == 0) {
                const auto& w = s.world();
                auto who = [&](int j) {
                    char t[160];
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    std::snprintf(t, sizeof t, "#%d %.1fm v%.1f %s", j, std::sqrt(bx * bx + by * by),
                                  std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()),
                                  ai::kWhyNames[static_cast<int>(s.lastOrders()[j].why)]);
                    return std::string(t);
                };
                int nm = -1, no = -1; double dm = 1e9, dop = 1e9;
                for (std::uint8_t j = 0; j < w.playerCount(); ++j) {
                    if (j == tf_to) continue;
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    const double dd = bx * bx + by * by;
                    if (d.team == tf_team) { if (dd < dm) { dm = dd; nm = j; } }
                    else if (dd < dop) { dop = dd; no = j; }
                }
                char t[600];
                std::snprintf(t, sizeof t, "   +%.1fs ball %.0f,%.0f %.1f m/s | for %s | mate %s | opp %s", (k - tf_tick) / 30.0,
                              b.pos.x.toDouble(), b.pos.y.toDouble(),
                              std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                              who(tf_to).c_str(), nm >= 0 ? who(nm).c_str() : "-", no >= 0 ? who(no).c_str() : "-");
                tf_ticks.push_back(t);
            }
            for (int tm = 0; tm < 2; ++tm)
                if (lk_tick[tm] >= 0 && k - lk_tick[tm] == 10 && lk_to[tm] >= 0 && lk_to[tm] < s.world().playerCount())
                {
                    lk_rwhy10[tm] = static_cast<int>(s.lastOrders()[lk_to[tm]].why);
                    const auto& fr = s.brain().flightRead(s.world());
                    const int f = fr.live ? fr.first[tm] : -8;
                    lk_first10[tm] = f == lk_to[tm] ? 0 : f < 0 ? (f == -8 ? 4 : 1) : f == s.world().ball().last_kicker ? 2 : 3;
                }
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
            if (b.owner && s.world().restartTeam() == 0xFF) {
                const int ot = s.world().player(*b.owner).team;
                if (ot != spell_team) {
                    if (spell_team >= 0) {
                        int behind = 0;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            const auto& d = s.world().player(j);
                            if (d.team != spell_team || s.world().isKeeper(j)) continue;
                            if (spell_team == 0 ? d.pos.x < b.pos.x : d.pos.x > b.pos.x) ++behind;
                        }
                        ++rest_hist[spell_team][behind]; ++rest_n[spell_team];
                        const int lt = spell_team;
                        const double own_d = lt == 0 ? 52.5 + b.pos.x.toDouble() : 52.5 - b.pos.x.toDouble();
                        {
                            int c = 4;
                            if (lk_tick[lt] >= spell_start) {
                                const auto w = static_cast<ai::Why>(lk_why[lt]);
                                c = w == ai::Why::Shoot ? 2 : (w == ai::Why::Clear || w == ai::Why::KeeperPunt) ? 1 : 0;
                            } else if (s.world().badTouchSlot() < s.world().playerCount() &&
                                       s.world().player(s.world().badTouchSlot()).team == lt &&
                                       static_cast<long>(s.world().badTouchTick()) >= spell_start) {
                                c = 3;
                            }
                            ++end_cause[lt][c]; ++ends[lt];
                        }
                        o3_team = -1;
                        if (own_d < 35) {
                            o3_team = lt ^ 1; o3_tick = k; o3_10 = o3_any = false;
                            ++own3_n[lt];
                            const bool kicked = lk_tick[lt] >= spell_start;
                            ++own3_lost[lt][kicked ? lk_why[lt] : ai::kWhyCount];
                            const double age = (k - spell_start) / 30.0;
                            ++own3_age[lt][age < 1 ? 0 : age < 3 ? 1 : age < 8 ? 2 : 3];
                            if (kicked) {
                                const double dx = b.pos.x.toDouble() - lk_x[lt], dy = b.pos.y.toDouble() - lk_y[lt];
                                own3_kick_m[lt] += std::sqrt(dx * dx + dy * dy); ++own3_kicks[lt];
                                if (trace_lost && m == 0 && traced < trace_lost && !lk_snap[lt].empty()) {
                                    ++traced;
                                    const int ic = *b.owner;
                                    const double ax = lk_tx[lt] - lk_x[lt], ay = lk_ty[lt] - lk_y[lt];
                                    const double aim = std::atan2(ay, ax) * 57.3, went = std::atan2(lk_vy[lt], lk_vx[lt]) * 57.3;
                                    auto P = [&](int j) { return std::to_string(int(lk_snap[lt][j].x.toDouble())) + "," + std::to_string(int(lk_snap[lt][j].y.toDouble())); };
                                    std::printf("LOST t=%.1fs team%d %s from %d,%d aim %d,%d (%.0f m) | aimed %.0f° went %.0f° at %.1f m/s | taken after %.1f s at %d,%d | for #%d was at %s now %s (+0.3 s: %s) | taker #%d was at %s (%s)\n",
                                        k / 30.0, lt, ai::kWhyNames[lk_why[lt]], int(lk_x[lt]), int(lk_y[lt]), int(lk_tx[lt]), int(lk_ty[lt]), std::sqrt(ax * ax + ay * ay),
                                        aim, went, std::sqrt(lk_vx[lt] * lk_vx[lt] + lk_vy[lt] * lk_vy[lt]), (k - lk_tick[lt]) / 30.0,
                                        int(b.pos.x.toDouble()), int(b.pos.y.toDouble()),
                                        lk_to[lt], lk_to[lt] >= 0 ? P(lk_to[lt]).c_str() : "-",
                                        lk_to[lt] >= 0 ? (std::to_string(int(s.world().player(lk_to[lt]).pos.x.toDouble())) + "," + std::to_string(int(s.world().player(lk_to[lt]).pos.y.toDouble()))).c_str() : "-",
                                        lk_rwhy10[lt] >= 0 ? ai::kWhyNames[lk_rwhy10[lt]] : "-",
                                        ic, P(ic).c_str(), ai::kWhyNames[static_cast<int>(s.lastOrders()[ic].why)]);
                                }
                                if (lk_to[lt] >= 0 && lk_to[lt] < s.world().playerCount()) {
                                    const auto& rv = s.world().player(lk_to[lt]);
                                    if (rv.team == lt) {
                                        if (lk_rwhy10[lt] >= 0) { ++own3_rwhy[lt][lk_rwhy10[lt]]; ++own3_rn[lt]; ++own3_first[lt][lk_first10[lt]]; }
                                        const double rx = rv.pos.x.toDouble() - b.pos.x.toDouble(), ry = rv.pos.y.toDouble() - b.pos.y.toDouble();
                                        own3_rgap[lt] += std::sqrt(rx * rx + ry * ry);
                                        const double ix = rv.pos.x.toDouble() - lk_x[lt], iy = rv.pos.y.toDouble() - lk_y[lt];
                                        own3_igap[lt] += std::sqrt(ix * ix + iy * iy);
                                    }
                                }
                            }
                        }
                    }
                    if (spell_team >= 0) { ++spells; spell_ticks += k - spell_start; }
                    spell_team = ot;
                    spell_start = k;
                    won_x = ot == 0 ? 52.5 - b.pos.x.toDouble() : 52.5 + b.pos.x.toDouble();
                }
                for (int team = 0; team < 2; ++team) {
                    int near = 0;
                    double y0 = 1e9, y1 = -1e9, x0 = 1e9, x1 = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team != team || s.world().isKeeper(j)) continue;
                        const double x = d.pos.x.toDouble(), y = d.pos.y.toDouble();
                        y0 = std::min(y0, y); y1 = std::max(y1, y); x0 = std::min(x0, x); x1 = std::max(x1, x);
                        if (j == *b.owner) continue;
                        const double dx = x - b.pos.x.toDouble(), dy = y - b.pos.y.toDouble();
                        if (dx * dx + dy * dy < 100.0) ++near;
                    }
                    const int w = team == ot ? 0 : 1;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team != team || s.world().isKeeper(j) || j == *b.owner) continue;
                        // A man holding shape is measured against the spot he
                        // holds (width and balance included); the rest
                        // against the ball-shifted formation spot.
                        const ai::Orders& oj = s.lastOrders()[j];
                        const math::Vec2 an = oj.why == ai::Why::Hold ? oj.target : s.brain().shapeAnchor(j, s.world());
                        const double ax = an.x.toDouble() - d.pos.x.toDouble(), ay = an.y.toDouble() - d.pos.y.toDouble();
                        const double dd = std::sqrt(ax * ax + ay * ay);
                        off_sum[team][w] += dd; ++off_n[team][w];
                        if (w == 0) { ++ip_why[team][static_cast<int>(oj.why)]; ++ip_n[team]; }
                        if (oj.why == ai::Why::Hold) {
                            const int settled = k - spell_start >= 5 * 30 ? 1 : 0;
                            hold_gap[settled] += dd; ++hold_n[settled];
                        }
                        if (dd > 10.0) { ++off_ticks[team][w]; ++off_why[team][w][static_cast<int>(oj.why)]; }
                    }
                    crowd_sum[team][w] += near; wide_sum[team][w] += y1 - y0; long_sum[team][w] += x1 - x0;
                    ++crowd_ticks[team][w];
                }
            }
            for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                const auto& d = s.world().player(j);
                const ai::Orders& o = s.lastOrders()[j];
                const double tx = o.target.x.toDouble() - d.pos.x.toDouble(), ty = o.target.y.toDouble() - d.pos.y.toDouble();
                const double vx = d.vel.x.toDouble(), vy = d.vel.y.toDouble();
                if ((o.target.x.raw != 0 || o.target.y.raw != 0) && tx * tx + ty * ty < 6.25 &&
                    vx * vx + vy * vy > 6.25 && tx * vx + ty * vy < 0)
                    { ++overrun[d.team]; ++overrun_why[d.team][static_cast<int>(o.why)]; }
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
            for (const auto& e : s.lastEvents())
                if (e.type == core::MatchEventType::Offside) ++off_called[e.team ^ 1];
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
                    tf_tick = -1;
                    for (const auto& e : s.lastEvents()) {
                        if (e.type != core::MatchEventType::Offside) continue;
                        ++t.offside;
                        if (kick_at.size() != s.world().playerCount() || kick_job.size() != kick_at.size()) continue;
                        int who = -1; double bd = 1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().player(j).team != pend_team) continue;
                            const double dx = s.world().player(j).pos.x.toDouble() - b.pos.x.toDouble(), dy = s.world().player(j).pos.y.toDouble() - b.pos.y.toDouble();
                            if (dx * dx + dy * dy < bd) { bd = dx * dx + dy * dy; who = j; }
                        }
                        if (who < 0) continue;
                        // Their second-last man at the kick (keeper counts), in our attack direction.
                        const double sg = pend_team == 0 ? 1.0 : -1.0;
                        double l1 = -1e9, l2 = -1e9;
                        for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                            if (s.world().player(j).team == pend_team) continue;
                            const double x = kick_at[j].x.toDouble() * sg;
                            if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                        }
                        const double past = kick_at[who].x.toDouble() * sg - l2;
                        ++ow_n; ++ow_why[pend_why]; ow_intended += who == pend_other; ++ow_job[kick_job[who]];
                        ++ow_depth[past < 0 ? 0 : past < 1 ? 1 : past < 3 ? 2 : 3];
                    }
                    pend_team = -1;
                } else if (b.owner) {
                    if (s.world().player(*b.owner).team == pend_team) {
                        if (pend_why != static_cast<int>(ai::Why::Shoot)) last_assist[pend_team] = pend_why;
                        ++t.mate;
                        if (*b.owner == pend_other) ++t.intended;
                        if (pf_bucket >= 0 && *b.owner == pend_other) ++fr_got[pend_team][pf_bucket];
                        if (tf_tick >= 0 && *b.owner != pend_other) {
                            const auto& rv = s.world().player(tf_to);
                            const double gx = rv.pos.x.toDouble() - b.pos.x.toDouble(), gy = rv.pos.y.toDouble() - b.pos.y.toDouble();
                            std::printf("%s || MATE #%d took it after %.1f s; #%d %.1f m from it, doing %s\n", tf_line.c_str(), *b.owner, (k - tf_tick) / 30.0,
                                        tf_to, std::sqrt(gx * gx + gy * gy), ai::kWhyNames[static_cast<int>(s.lastOrders()[tf_to].why)]);
                            for (const auto& l : tf_ticks) std::printf("%s\n", l.c_str());
                            ++tf_done;
                        }
                        tf_tick = -1;
                    } else {
                        ++t.lost;
                        // StatsBomb's Interception (G4.85): an OUTFIELDER cutting
                        // out a pass — a blocked or saved shot is a Block /
                        // Goal Keeper event, a keeper's claim a Goal Keeper one.
                        // Counted with them, 23% of the "interceptions" were
                        // shots and a quarter keepers'.
                        const bool sb_int = pend_why != static_cast<int>(ai::Why::Shoot) && !s.world().isKeeper(*b.owner);
                        if (sb_int) ++(prev_ball_v >= 3.0 ? cut : picked)[pend_team ^ 1];
                        if (sb_int && prev_ball_v >= 3.0 && kick_at.size() == s.world().playerCount()) {
                            const int j = *b.owner;
                            {
                                const auto& d = s.world().player(j);
                                const double v = std::sqrt(prev_ov[j][0] * prev_ov[j][0] + prev_ov[j][1] * prev_ov[j][1]);
                                const double rx = prev_bvx - prev_ov[j][0], ry = prev_bvy - prev_ov[j][1], rel = std::sqrt(rx * rx + ry * ry);
                                (void)d;
                                ++rt_n[0][static_cast<int>(s.lastOrders()[j].why)];
                                ++rt_sp[0][v < 2 ? 0 : v < 4 ? 1 : v < 6 ? 2 : 3];
                                ++rt_rel[0][rel < 6 ? 0 : rel < 9 ? 1 : rel < 12 ? 2 : 3];
                            }
                            const double mx = s.world().player(j).pos.x.toDouble() - kick_at[j].x.toDouble(),
                                         my = s.world().player(j).pos.y.toDouble() - kick_at[j].y.toDouble();
                            const double mv = std::sqrt(mx * mx + my * my), ft = (k - kick_tick) / 30.0;
                            ++cut_moved[mv < 1 ? 0 : mv < 3 ? 1 : mv < 6 ? 2 : 3];
                            ++cut_time[ft < 0.5 ? 0 : ft < 1 ? 1 : ft < 2 ? 2 : 3];
                            if (kick_pred >= 0) ++pred_cut[kick_pred];
                            if (kick_pred == 0 && trace_flip && m == 0 && flips < trace_flip) {
                                ++flips;
                                std::printf("FLIP t=%.1fs team%d %s, predicted ours #%d by %.1f s; cut by #%d (their predicted #%d) after %.1f s\n",
                                            k / 30.0, pend_team, pend_why == ai::kWhyCount ? "in behind" : ai::kWhyNames[pend_why], pred_us,
                                            pred_margin / 30.0, j, pred_them, (k - kick_tick) / 30.0);
                                for (const auto& l : flip_lines) std::printf("%s\n", l.c_str());
                            }
                            if (kick_pred == 0) {
                                ++po_n;
                                po_cutter_pred += j == pred_them;
                                if (pred_us_why >= 0) ++po_us_why[pred_us_why];
                                ++po_margin[pred_margin < 6 ? 0 : pred_margin < 15 ? 1 : pred_margin < 30 ? 2 : 3];
                            }
                            ++cut_by_why[pend_why]; ++cut_why_taker[static_cast<int>(s.lastOrders()[j].why)]; ++cut_n;
                        }
                        if (pf_bucket >= 0) ++fr_lost[pend_team][pf_bucket];
                        if (tf_tick >= 0) {
                            const auto& rv = s.world().player(tf_to);
                            const double gx = rv.pos.x.toDouble() - b.pos.x.toDouble(), gy = rv.pos.y.toDouble() - b.pos.y.toDouble();
                            std::printf("%s || LOST to #%d after %.1f s; #%d %.1f m from it, doing %s\n", tf_line.c_str(), *b.owner, (k - tf_tick) / 30.0,
                                        tf_to, std::sqrt(gx * gx + gy * gy), ai::kWhyNames[static_cast<int>(s.lastOrders()[tf_to].why)]);
                            for (const auto& l : tf_ticks) std::printf("%s\n", l.c_str());
                            ++tf_done;
                        }
                        tf_tick = -1;
                    }
                    pend_team = -1;
                }
            }
            if (s.world().badTouchTick() != prev_bad && s.world().badTouchSlot() < s.world().playerCount()) {
                prev_bad = s.world().badTouchTick();
                ++bobbles[s.world().player(s.world().badTouchSlot()).team];
                const int bs = s.world().badTouchSlot();
                const int kind = prev_ltt != s.world().player(bs).team ? 2 : (prev_pass_to == bs ? 0 : 1);
                ++bt_kind[kind][prev_ball_v < 9 ? 0 : prev_ball_v < 12 ? 1 : prev_ball_v < 15 ? 2 : 3];
                if (kind == 2 && prev_ball_v >= 3.0) {
                    const auto& d = s.world().player(bs);
                    const double v = std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble());
                    const double rx = prev_bvx - d.vel.x.toDouble(), ry = prev_bvy - d.vel.y.toDouble(), rel = std::sqrt(rx * rx + ry * ry);
                    ++rt_n[1][static_cast<int>(s.lastOrders()[bs].why)];
                    ++rt_sp[1][v < 2 ? 0 : v < 4 ? 1 : v < 6 ? 2 : 3];
                    ++rt_rel[1][rel < 6 ? 0 : rel < 9 ? 1 : rel < 12 ? 2 : 3];
                }
            }
            if (pend_team >= 0 && k == kick_tick + 1) {
                const auto& fr = s.brain().flightRead(s.world());
                const int us = fr.first[pend_team], them = fr.first[pend_team ^ 1];
                kick_pred = !fr.live ? 2 : (them >= 0 && (us < 0 || fr.tick[them] < fr.tick[us])) ? 1 : (us >= 0 ? 0 : 2);
                pred_us = us; pred_them = them; pred_us_why = -1;
                pred_margin = (us >= 0 && them >= 0) ? fr.tick[them] - fr.tick[us] : 999;
                ++pred_all[kick_pred];
                ++pred_why[pend_why][kick_pred];
                if (pend_why == ai::kWhyCount) {
                    ++ib_all_read[kick_read];
                    if (kick_pred == 1) ++ib_theirs_read[kick_read];
                    if (kick_read) {
                        const bool loft = s.world().ball().pos.z.raw > 0 || s.world().ball().vel.z.raw != 0;
                        ++ib_loft_all[loft];
                        if (kick_pred == 1) ++ib_loft_theirs[loft];
                    }
                    if (kick_pred == 1 && kick_read && them >= 0 && kick_passer >= 0) {
                        ++ib_seen[s.brain().inView(static_cast<core::SlotIndex>(kick_passer), s.world(), static_cast<core::SlotIndex>(them)) ? 1 : 0];
                        const int a = s.brain().lookAge(static_cast<core::SlotIndex>(kick_passer), s.world());
                        ++ib_age[a <= 0 ? 0 : a < 15 ? 1 : a < 45 ? 2 : 3];
                    }
                }
                if (pend_why == ai::kWhyCount && kick_pred == 1 && fr.live) {
                    const double ax = kick_aim.x.toDouble() - kick_from.x.toDouble(), ay = kick_aim.y.toDouble() - kick_from.y.toDouble();
                    const double bvx = s.world().ball().vel.x.toDouble(), bvy = s.world().ball().vel.y.toDouble();
                    const double al = std::sqrt(ax * ax + ay * ay), bl = std::sqrt(bvx * bvx + bvy * bvy);
                    if (al > 1 && bl > 0.1) {
                        double c = (ax * bvx + ay * bvy) / (al * bl);
                        c = c > 1 ? 1 : (c < -1 ? -1 : c);
                        const double deg = std::acos(c) * 57.2958;
                        ++ib_n;
                        ++ib_err[deg < 2 ? 0 : deg < 5 ? 1 : deg < 10 ? 2 : 3];
                        const double mx = fr.at[them].x.toDouble() - kick_from.x.toDouble(), my = fr.at[them].y.toDouble() - kick_from.y.toDouble();
                        const double along = std::sqrt(mx * mx + my * my);
                        ++ib_where[along < al - 3 ? 0 : along <= al + 3 ? 1 : 2];
                    }
                }
            }
            if (trace_flip && m == 0 && flips < trace_flip && pend_team >= 0 && kick_pred == 0 && k > kick_tick && (k - kick_tick) % 6 == 1) {
                const auto& fr = s.brain().flightRead(s.world());
                const auto& w = s.world();
                auto who = [&](int j) {
                    if (j < 0) return std::string("-");
                    const auto& d = w.player(j);
                    const double bx = d.pos.x.toDouble() - b.pos.x.toDouble(), by = d.pos.y.toDouble() - b.pos.y.toDouble();
                    char t[200];
                    const ai::Orders& oj = s.lastOrders()[j];
                    const double tx = oj.target.x.toDouble() - d.pos.x.toDouble(), ty = oj.target.y.toDouble() - d.pos.y.toDouble();
                    const double ax = fr.live && fr.tick[j] >= 0 ? fr.at[j].x.toDouble() - b.pos.x.toDouble() : 0,
                                 ay = fr.live && fr.tick[j] >= 0 ? fr.at[j].y.toDouble() - b.pos.y.toDouble() : 0;
                    std::snprintf(t, sizeof t, "#%d %.1fm v%.1f [vel %.1f,%.1f wish %.2f,%.2f face %.2f,%.2f to target %.1f,%.1f] %s, read +%.1fs (target %.1fm off him, meet point %.1fm up the ball's path, wish %.2f)", j, std::sqrt(bx * bx + by * by),
                                  std::sqrt(d.vel.x.toDouble() * d.vel.x.toDouble() + d.vel.y.toDouble() * d.vel.y.toDouble()),
                                  d.vel.x.toDouble(), d.vel.y.toDouble(), oj.move.move.x.toDouble(), oj.move.move.y.toDouble(),
                                  d.face.x.toDouble(), d.face.y.toDouble(), tx, ty,
                                  ai::kWhyNames[static_cast<int>(oj.why)],
                                  fr.live && fr.tick[j] >= 0 ? fr.tick[j] / 30.0 : -1.0, std::sqrt(tx * tx + ty * ty), std::sqrt(ax * ax + ay * ay),
                                  std::sqrt(oj.move.move.x.toDouble() * oj.move.move.x.toDouble() + oj.move.move.y.toDouble() * oj.move.move.y.toDouble()));
                    return std::string(t);
                };
                char t[600];
                std::snprintf(t, sizeof t, "   +%.1fs ball %.1f m/s z%.1f | ours %s | their first %s", (k - kick_tick) / 30.0,
                              std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()), b.pos.z.toDouble(),
                              who(pred_us).c_str(), who(fr.live ? fr.first[pend_team ^ 1] : -1).c_str());
                flip_lines.push_back(t);
            }
            if (pend_team >= 0 && k == kick_tick + 1) flip_lines.clear();
            if (pend_team >= 0 && k == kick_tick + 10 && pred_us >= 0)
                pred_us_why = static_cast<int>(s.lastOrders()[pred_us].why);
            prev_ball_v = std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble());
            prev_ltt = s.world().lastTouchTeam();
            prev_bvx = b.vel.x.toDouble(); prev_bvy = b.vel.y.toDouble();
            for (std::uint8_t tm = 0; tm < 2; ++tm) {   // who stands offside right now, each side
                const double sg = tm == 0 ? 1.0 : -1.0;
                double l1 = -1e9, l2 = -1e9;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                    if (s.world().player(j).team == tm) continue;
                    const double x = s.world().player(j).pos.x.toDouble() * sg;
                    if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                }
                const double bx = b.pos.x.toDouble() * sg;
                for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j) {
                    if (s.world().player(j).team != tm) continue;
                    const double x = s.world().player(j).pos.x.toDouble() * sg;
                    if (!(x > l2 && x > bx && x > 0)) off_since[j] = k;
                }
            }
            for (std::uint8_t j = 0; j < s.world().playerCount() && j < 64; ++j)
                prev_ov[j] = {s.world().player(j).vel.x.toDouble(), s.world().player(j).vel.y.toDouble()};
            prev_pass_to = b.owner ? -1 : static_cast<int>(b.pass_to);
            if (before && !b.owner && b.last_kicker == *before &&
                s.world().restartTeam() == 0xFF) {
                const ai::Orders& o = s.lastOrders()[*before];
                pend_team = s.world().player(*before).team;
                lk_why[pend_team] = static_cast<int>(o.why); lk_tick[pend_team] = k; lk_to[pend_team] = o.other; lk_rwhy10[pend_team] = -1;
                lk_x[pend_team] = s.world().player(*before).pos.x.toDouble(); lk_y[pend_team] = s.world().player(*before).pos.y.toDouble();
                if (trace_lost && m == 0) {
                    lk_snap[pend_team].clear();
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                        lk_snap[pend_team].push_back(math::Vec2{s.world().player(j).pos.x, s.world().player(j).pos.y});
                    lk_tx[pend_team] = o.target.x.toDouble(); lk_ty[pend_team] = o.target.y.toDouble();
                    lk_vx[pend_team] = b.vel.x.toDouble(); lk_vy[pend_team] = b.vel.y.toDouble();
                }
                if (o.why == ai::Why::Shoot) {
                    const auto& sh = s.world().player(*before);
                    bool alone = true;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == sh.team || s.world().isKeeper(j)) continue;
                        if (sh.team == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) alone = false;
                    }
                    shot_breakaway[pend_team] = alone;
                    const int st = sh.team;
                    if (o3_team == st && spell_team == st) {
                        if (!o3_10 && k - o3_tick <= 300) { ++own3_shot10[st ^ 1]; o3_10 = true; }
                        if (!o3_any) { ++own3_shot_spell[st ^ 1]; o3_any = true; }
                    }
                    const double age = st == spell_team ? (k - spell_start) / 30.0 : 0.0;
                    int behind = 0;
                    double near = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == st || s.world().isKeeper(j)) continue;
                        if (st == 0 ? d.pos.x > sh.pos.x : d.pos.x < sh.pos.x) ++behind;
                        const double dx = d.pos.x.toDouble() - sh.pos.x.toDouble(), dy = d.pos.y.toDouble() - sh.pos.y.toDouble();
                        near = std::min(near, std::sqrt(dx * dx + dy * dy));
                    }
                    const double gx = (st == 0 ? 52.5 : -52.5) - sh.pos.x.toDouble(), gy = sh.pos.y.toDouble();
                    const double dist = std::sqrt(gx * gx + gy * gy);
                    ++shot_n[st];
                    ++shot_age[st][age < 5 ? 0 : age < 10 ? 1 : age < 20 ? 2 : 3];
                    ++shot_behind[st][behind <= 2 ? 0 : behind <= 4 ? 1 : behind <= 6 ? 2 : 3];
                    ++shot_dist[st][dist < 11 ? 0 : dist < 18 ? 1 : dist < 25 ? 2 : 3];
                    ++shot_near[st][near < 1.5 ? 0 : near < 3 ? 1 : near < 6 ? 2 : 3];
                    if (rx_slot == *before) {
                        const double cx = sh.pos.x.toDouble() - rx_x, cy = sh.pos.y.toDouble() - rx_y;
                        const double cm = std::sqrt(cx * cx + cy * cy);
                        ++recv_behind[st][rx_behind <= 2 ? 0 : rx_behind <= 4 ? 1 : rx_behind <= 6 ? 2 : 3];
                        ++carry_m[st][cm < 3 ? 0 : cm < 10 ? 1 : cm < 25 ? 2 : 3];
                    }
                    if (st == spell_team) ++won_at[st][won_x < 35 ? 0 : won_x < 52.5 ? 1 : won_x < 70 ? 2 : 3];
                }
                pend_why = o.rung >= 1 && o.rung <= 2 ? ai::kWhyCount : static_cast<int>(o.why);
                kick_passer = *before; kick_read = o.read; kick_aim = o.target; kick_from = math::Vec2{s.world().ball().pos.x, s.world().ball().pos.y};
                kick_at.clear(); kick_tick = k;
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j)
                    kick_at.push_back(math::Vec2{s.world().player(j).pos.x, s.world().player(j).pos.y});
                kick_job.assign(s.world().playerCount(), 0);
                for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) kick_job[j] = static_cast<int>(s.lastOrders()[j].why);
                pend_other = o.other;
                pf_bucket = -1;
                if (o.other >= 0 && o.other < s.world().playerCount() && o.why != ai::Why::Shoot &&
                    s.world().player(o.other).team == pend_team) {
                    const auto& rv = s.world().player(o.other);
                    double nd = 1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        const auto& d = s.world().player(j);
                        if (d.team == pend_team) continue;
                        const double dx = d.pos.x.toDouble() - rv.pos.x.toDouble(), dy = d.pos.y.toDouble() - rv.pos.y.toDouble();
                        nd = std::min(nd, std::sqrt(dx * dx + dy * dy));
                    }
                    pf_bucket = nd < 2 ? 0 : nd < 5 ? 1 : nd < 10 ? 2 : 3;
                    ++fr_n[pend_team][pf_bucket];
                    if (trace_free && m == 0 && pf_bucket == 3 && tf_done < trace_free) {
                        const auto& ps = s.world().player(*before);
                        const double ax = rv.pos.x.toDouble() - ps.pos.x.toDouble(), ay = rv.pos.y.toDouble() - ps.pos.y.toDouble();
                        const double tx = o.target.x.toDouble() - ps.pos.x.toDouble(), ty = o.target.y.toDouble() - ps.pos.y.toDouble();
                        char buf[400];
                        std::snprintf(buf, sizeof buf, "FREE t=%.1fs team%d %s #%d->#%d | man %.0f m away, aimed %.0f m, ball %.1f m/s z-vel %.1f | man moving %.1f,%.1f",
                                      k / 30.0, pend_team, ai::kWhyNames[static_cast<int>(o.why)], *before, o.other, std::sqrt(ax * ax + ay * ay),
                                      std::sqrt(tx * tx + ty * ty), std::sqrt(b.vel.x.toDouble() * b.vel.x.toDouble() + b.vel.y.toDouble() * b.vel.y.toDouble()),
                                      b.vel.z.toDouble(), rv.vel.x.toDouble(), rv.vel.y.toDouble());
                        tf_line = buf; tf_tick = k; tf_to = o.other; tf_team = pend_team; tf_len = std::sqrt(ax * ax + ay * ay);
                        tf_ticks.clear();
                    }
                }
                ++tally[pend_team][pend_why].kicks;
                const core::OffsideCall& oc = s.world().lastOffsideCall();
                ++op_all_kicks;
                if (oc.truth) {
                    ++op_kicks;
                    const double sg = pend_team == 0 ? 1.0 : -1.0;
                    double l1 = -1e9, l2 = -1e9;
                    for (std::uint8_t j = 0; j < s.world().playerCount(); ++j) {
                        if (s.world().player(j).team == pend_team) continue;
                        const double x = s.world().player(j).pos.x.toDouble() * sg;
                        if (x > l1) { l2 = l1; l1 = x; } else if (x > l2) l2 = x;
                    }
                    for (std::uint8_t j = 0; j < s.world().playerCount() && j < 32; ++j) {
                        if (!((oc.truth >> j) & 1u)) continue;
                        ++op_men;
                        ++op_job[static_cast<int>(s.lastOrders()[j].why)];
                        const double past = s.world().player(j).pos.x.toDouble() * sg - l2;
                        static int dbg = std::atoi(envOr("GAME_TRACE_OFFSIDE_MEN", "0"));
                        if (dbg > 0 && m == 0 && past >= 8) {
                            --dbg;
                            const auto& pj = s.world().player(j);
                            const auto& oj = s.lastOrders()[j];
                            std::printf("OFFMAN t=%.1fs team%d #%d %s past %.1f m | x %.1f line %.1f ball %.1f (owner %d) | target x %.1f | vel x %.1f | since onside %.1f s\n",
                                        k / 30.0, pend_team, j, ai::kWhyNames[static_cast<int>(oj.why)], past, pj.pos.x.toDouble() * sg, l2,
                                        b.pos.x.toDouble() * sg, b.owner ? static_cast<int>(*b.owner) : -1, oj.target.x.toDouble() * sg,
                                        pj.vel.x.toDouble() * sg, (k - off_since[j]) / 30.0);
                        }
                        ++op_depth[past < 1 ? 0 : past < 3 ? 1 : past < 8 ? 2 : 3];
                        const double age = (k - off_since[j]) / 30.0;
                        ++op_age[age < 1 ? 0 : age < 3 ? 1 : age < 8 ? 2 : 3];
                    }
                }
                if (oc.assistant >= 0 && (oc.called | oc.truth)) {
                    ++flag_kicks;
                    flag_wrong += __builtin_popcount(oc.called & ~oc.truth);
                    flag_missed += __builtin_popcount(oc.truth & ~oc.called);
                    const double off = oc.off_line_m.toDouble();
                    ar_off_sum += off;
                    ++ar_off[off < -3 ? 0 : off < -1 ? 1 : off <= 1 ? 2 : off <= 3 ? 3 : 4];
                }
            }
        }
        off_wrong += s.world().wrongOffsideWhistles();
        off_missed += s.world().missedOffsides();
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
    if (spells)
        std::printf("Possession spells: %.0f a match, %.1f s long on average; a man holding shape is %.1f m from his spot in a spell's first 5 s, %.1f m after (%.0f%% of holding ticks are in the first 5 s)\n",
                    double(spells) / matches, spell_ticks / 30.0 / spells,
                    hold_n[0] ? hold_gap[0] / hold_n[0] : 0.0, hold_n[1] ? hold_gap[1] / hold_n[1] : 0.0,
                    100.0 * hold_n[0] / std::max(1L, hold_n[0] + hold_n[1]));
    for (int team = 0; team < 2; ++team) {
        const char* tn = team == 0 ? names.team_home.c_str() : names.team_away.c_str();
        for (int w = 0; w < 2; ++w)
            if (crowd_ticks[team][w])
                std::printf("%s %s: %.2f outfielders within 10 m of the ball, outfield %.1f m wide x %.1f m long\n", tn,
                            w == 0 ? "with the ball" : "without it", crowd_sum[team][w] / crowd_ticks[team][w],
                            wide_sum[team][w] / crowd_ticks[team][w], long_sum[team][w] / crowd_ticks[team][w]);
        for (int w = 0; w < 2; ++w) {
            if (!off_n[team][w]) continue;
            std::printf("%s %s: %.1f m from his position on average, > 10 m off it %.0f%% of the time:", tn,
                        w == 0 ? "with the ball" : "without it", off_sum[team][w] / off_n[team][w],
                        100.0 * off_ticks[team][w] / off_n[team][w]);
            for (int k = 0; k < ai::kWhyCount; ++k)
                if (off_why[team][w][k] * 20 >= off_ticks[team][w] && off_ticks[team][w])
                    std::printf(" %s %.0f%%", ai::kWhyNames[k], 100.0 * off_why[team][w][k] / off_ticks[team][w]);
            std::printf("\n");
        }
        if (ip_n[team]) {
            std::printf("%s outfielders off the ball in possession are doing:", tn);
            for (int k = 0; k < ai::kWhyCount; ++k)
                if (ip_why[team][k] * 1000 >= ip_n[team])
                    std::printf(" %s %.1f%%", ai::kWhyNames[k], 100.0 * ip_why[team][k] / ip_n[team]);
            std::printf("\n");
        }
        std::printf("%s ran past his own target %.0f player-seconds a match:", tn, overrun[team] / 30.0 / matches);
        for (int w = 0; w < ai::kWhyCount; ++w)
            if (overrun_why[team][w] * 20 >= overrun[team] && overrun[team])
                std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * overrun_why[team][w] / overrun[team]);
        std::printf("\n");
    }
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
        if (!shot_n[team]) continue;
        const char* tn = team == 0 ? names.team_home.c_str() : names.team_away.c_str();
        auto pc = [&](const long* h, int i) { return 100.0 * h[i] / shot_n[team]; };
        std::printf("\n%s shots %.1f/match — spell age <5 s %.0f%% · 5-10 %.0f%% · 10-20 %.0f%% · 20+ %.0f%%\n", tn,
                    double(shot_n[team]) / matches, pc(shot_age[team], 0), pc(shot_age[team], 1), pc(shot_age[team], 2), pc(shot_age[team], 3));
        std::printf("  defenders goal-side of the shooter 0-2 %.0f%% · 3-4 %.0f%% · 5-6 %.0f%% · 7+ %.0f%%\n",
                    pc(shot_behind[team], 0), pc(shot_behind[team], 1), pc(shot_behind[team], 2), pc(shot_behind[team], 3));
        std::printf("  distance <11 m %.0f%% · 11-18 %.0f%% · 18-25 %.0f%% · 25+ %.0f%%; nearest defender <1.5 m %.0f%% · 1.5-3 %.0f%% · 3-6 %.0f%% · 6+ %.0f%%\n",
                    pc(shot_dist[team], 0), pc(shot_dist[team], 1), pc(shot_dist[team], 2), pc(shot_dist[team], 3),
                    pc(shot_near[team], 0), pc(shot_near[team], 1), pc(shot_near[team], 2), pc(shot_near[team], 3));
        std::printf("  defenders goal-side when the shooter GOT it 0-2 %.0f%% · 3-4 %.0f%% · 5-6 %.0f%% · 7+ %.0f%%; he carried <3 m %.0f%% · 3-10 %.0f%% · 10-25 %.0f%% · 25+ %.0f%%\n",
                    pc(recv_behind[team], 0), pc(recv_behind[team], 1), pc(recv_behind[team], 2), pc(recv_behind[team], 3),
                    pc(carry_m[team], 0), pc(carry_m[team], 1), pc(carry_m[team], 2), pc(carry_m[team], 3));
        std::printf("  the spell began <35 m from the goal it attacks %.0f%% · 35-52 %.0f%% · 52-70 %.0f%% · 70+ %.0f%%\n",
                    pc(won_at[team], 0), pc(won_at[team], 1), pc(won_at[team], 2), pc(won_at[team], 3));
        std::printf("  passes to a picked man by his nearest opponent at the kick — played/match, to him, lost:");
        { const char* bn[4] = {"<2 m", "2-5 m", "5-10 m", "10+ m"};
          for (int i = 0; i < 4; ++i) if (fr_n[team][i])
              std::printf(" | %s %.0f, %.0f%%, %.0f%%", bn[i], double(fr_n[team][i]) / matches, 100.0 * fr_got[team][i] / fr_n[team][i], 100.0 * fr_lost[team][i] / fr_n[team][i]); }
        std::printf("\n");
        if (own3_n[team]) {
            std::printf("  loses it within 35 m of its OWN goal %.1f/match (held <1 s %.0f%% · 1-3 %.0f%% · 3-8 %.0f%% · 8+ %.0f%%), kicks travel %.1f m before they take it:",
                        double(own3_n[team]) / matches, 100.0 * own3_age[team][0] / own3_n[team], 100.0 * own3_age[team][1] / own3_n[team],
                        100.0 * own3_age[team][2] / own3_n[team], 100.0 * own3_age[team][3] / own3_n[team],
                        own3_kicks[team] ? own3_kick_m[team] / own3_kicks[team] : 0.0);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (own3_lost[team][w] * 25 >= own3_n[team])
                    std::printf(" %s %.0f%%", w == ai::kWhyCount ? "(on the ball: dispossessed)" : ai::kWhyNames[w], 100.0 * own3_lost[team][w] / own3_n[team]);
            std::printf("\n");
            if (own3_rn[team]) {
                std::printf("    the man it was for: %.1f m from where they took it (%.1f m from the passer); 0.3 s after the kick he was doing:", own3_rgap[team] / own3_rn[team], own3_igap[team] / own3_rn[team]);
                for (int w = 0; w < ai::kWhyCount; ++w)
                    if (own3_rwhy[team][w] * 20 >= own3_rn[team])
                        std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * own3_rwhy[team][w] / own3_rn[team]);
                std::printf("\n      our first man to it (flight read, +0.3 s): the receiver %.0f%% · nobody %.0f%% · the passer %.0f%% · another mate %.0f%% · (not live) %.0f%%\n",
                    100.0 * own3_first[team][0] / own3_rn[team], 100.0 * own3_first[team][1] / own3_rn[team], 100.0 * own3_first[team][2] / own3_rn[team],
                    100.0 * own3_first[team][3] / own3_rn[team], 100.0 * own3_first[team][4] / own3_rn[team]);
            }
        }
        if (rest_n[team]) {
            std::printf("  when it LOSES the ball, outfielders goal-side of it:");
            for (int i = 0; i <= 10; ++i) std::printf(" %d:%.0f%%", i, 100.0 * rest_hist[team][i] / rest_n[team]);
            std::printf("\n");
        }
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
    // G4.81b: the pro reference (mig 782 — game_benchmarks, level 'pro') beside
    // the same measures here. Semi-pro sits on the worse side of pro.
    const auto bench = persistence::loadBenchmarks(db, "pro");
    if (!bench.empty()) {
        std::map<std::string, std::pair<double, double>> sim;   // per team (home, away); NaN = no line here
        const double nm = matches, nan = std::nan("");
        auto both = [&](const std::string& k, double h, double a) { sim[k] = {h, a}; };
        auto one = [&](const std::string& k, double v) { sim[k] = {v, nan}; };
        double pk[2] = {0, 0}, pm[2] = {0, 0};
        for (int team = 0; team < 2; ++team)
            for (int w = 0; w <= ai::kWhyCount; ++w) {
                if (w == static_cast<int>(ai::Why::Shoot) || w == static_cast<int>(ai::Why::Clear) ||
                    w == static_cast<int>(ai::Why::KeeperPunt)) continue;
                pk[team] += tally[team][w].kicks; pm[team] += tally[team][w].mate;
            }
        both("shots_per_team_match", shot_n[0] / nm, shot_n[1] / nm);
        both("offsides_per_team_match", off_called[0] / nm, off_called[1] / nm);   // G4.88
        both("shots_open_play_per_team_match", shot_n[0] / nm, shot_n[1] / nm);
        one("goals_per_match", (gh + ga) / nm);
        one("goals_open_play_per_match", (gh + ga) / nm);
        both("open_play_passes_per_team_match", pk[0] / nm, pk[1] / nm);
        both("open_play_pass_completion_pct", 100 * pm[0] / std::max(1.0, pk[0]), 100 * pm[1] / std::max(1.0, pk[1]));
        one("spells_per_match", spells / nm);
        one("spell_length_s", spells ? spell_ticks / 30.0 / spells : nan);
        both("final_third_entries_per_team_match", entries[0] / nm, entries[1] / nm);
        both("own_third_losses_per_team_match", own3_n[0] / nm, own3_n[1] / nm);
        both("own_third_loss_shot_10s_pct", 100.0 * own3_shot10[0] / std::max(1L, own3_n[0]), 100.0 * own3_shot10[1] / std::max(1L, own3_n[1]));
        both("own_third_loss_shot_spell_pct", 100.0 * own3_shot_spell[0] / std::max(1L, own3_n[0]), 100.0 * own3_shot_spell[1] / std::max(1L, own3_n[1]));
        const char* sfx[4][4] = {{"lt5s", "5_10s", "10_20s", "20s_plus"}, {"0_2", "3_4", "5_6", "7_plus"},
                                 {"lt11m", "11_18m", "18_25m", "25m_plus"}, {"lt1_5m", "1_5_3m", "3_6m", "6m_plus"}};
        const char* pre[4] = {"op_shot_age_", "op_shot_goalside_", "op_shot_dist_", "op_shot_near_"};
        const long (*hist[4])[4] = {shot_age, shot_behind, shot_dist, shot_near};
        for (int h = 0; h < 4; ++h)
            for (int i = 0; i < 4; ++i)
                both(std::string(pre[h]) + sfx[h][i] + "_pct", 100.0 * hist[h][0][i] / std::max(1L, shot_n[0]),
                     100.0 * hist[h][1][i] / std::max(1L, shot_n[1]));
        both("interceptions_kept_per_team_match", cut[0] / nm, cut[1] / nm);
        both("bad_touches_per_team_match", bobbles[0] / nm, bobbles[1] / nm);
        const char* endc[5] = {"pass", "clear", "shot", "bad_touch", "on_ball"};
        for (int i = 0; i < 5; ++i)
            both(std::string("spell_end_") + endc[i] + "_pct", 100.0 * end_cause[0][i] / std::max(1L, ends[0]),
                 100.0 * end_cause[1][i] / std::max(1L, ends[1]));
        const char* began[4] = {"lt35m", "35_52m", "52_70m", "70m_plus"};
        for (int i = 0; i < 4; ++i)
            both(std::string("op_shot_began_") + began[i] + "_pct", 100.0 * won_at[0][i] / std::max(1L, shot_n[0]),
                 100.0 * won_at[1][i] / std::max(1L, shot_n[1]));
        std::printf("\nPasses the other side took — cut out while travelling (interceptions) %.1f / %.1f, picked up slower %.1f / %.1f; bad touches %.1f / %.1f a team a match\n",
                    cut[0] / nm, cut[1] / nm, picked[0] / nm, picked[1] / nm, bobbles[0] / nm, bobbles[1] / nm);
        {
            const char* kn[3] = {"the pass meant for him", "another of ours", "theirs (a reaction touch)"};
            std::printf("  bad touches a match by whose ball, at <9 / 9-12 / 12-15 / 15+ m/s:");
            for (int q = 0; q < 3; ++q)
                std::printf(" %s %.1f / %.1f / %.1f / %.1f%s", kn[q], bt_kind[q][0] / nm, bt_kind[q][1] / nm,
                            bt_kind[q][2] / nm, bt_kind[q][3] / nm, q < 2 ? " ·" : "\n");
        }
        {
            const long calls = off_called[0] + off_called[1];
            std::printf("\nOfficials (the assistant's call stands): offsides %.1f / %.1f a team a match; whistles for an onside man %.1f a match (%.0f%% of the calls), offside touches nobody flagged %.1f a match\n",
                        off_called[0] / nm, off_called[1] / nm, off_wrong / nm, 100.0 * off_wrong / std::max(1L, calls), off_missed / nm);
            if (flag_kicks)
                std::printf("  kicks with a flag or a man offside: %.1f a match — men flagged wrongly %.1f, offside men missed %.1f a match; the assistant stood (vs level with the line) 3+ m short %.0f%% · 1-3 short %.0f%% · within 1 m %.0f%% · 1-3 beyond %.0f%% · 3+ beyond %.0f%%, mean %+.1f m\n",
                            flag_kicks / nm, flag_wrong / nm, flag_missed / nm,
                            100.0 * ar_off[0] / flag_kicks, 100.0 * ar_off[1] / flag_kicks, 100.0 * ar_off[2] / flag_kicks,
                            100.0 * ar_off[3] / flag_kicks, 100.0 * ar_off[4] / flag_kicks, ar_off_sum / flag_kicks);
        }
        if (ib_all_read[0] + ib_all_read[1])
            std::printf("  balls in behind by the passer's read: READ %.1f a match, theirs at the kick %.0f%% · NOT read %.1f, theirs %.0f%%\n",
                        ib_all_read[1] / nm, 100.0 * ib_theirs_read[1] / std::max(1L, ib_all_read[1]),
                        ib_all_read[0] / nm, 100.0 * ib_theirs_read[0] / std::max(1L, ib_all_read[0]));
        if (op_men) {
            std::printf("  men standing offside at a kick: %.1f a match on %.0f%% of kicks; past the line <1 / 1-3 / 3-8 / 8+ m %.0f / %.0f / %.0f / %.0f%%; there for <1 / 1-3 / 3-8 / 8+ s %.0f / %.0f / %.0f / %.0f%%\n    doing:",
                        op_men / nm, 100.0 * op_kicks / std::max(1L, op_all_kicks),
                        100.0 * op_depth[0] / op_men, 100.0 * op_depth[1] / op_men, 100.0 * op_depth[2] / op_men, 100.0 * op_depth[3] / op_men,
                        100.0 * op_age[0] / op_men, 100.0 * op_age[1] / op_men, 100.0 * op_age[2] / op_men, 100.0 * op_age[3] / op_men);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (op_job[w] * 25 >= op_men) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * op_job[w] / op_men);
            std::printf("\n");
        }
        if (ow_n) {
            std::printf("  each offside whistle (%.1f a match): the man it was played to %.0f%%; past their second-last man at the kick: not (onside) %.0f%% · <1 m %.0f%% · 1-3 m %.0f%% · 3+ m %.0f%%\n    off the kick:",
                        ow_n / nm, 100.0 * ow_intended / ow_n, 100.0 * ow_depth[0] / ow_n, 100.0 * ow_depth[1] / ow_n, 100.0 * ow_depth[2] / ow_n, 100.0 * ow_depth[3] / ow_n);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (ow_why[w] * 25 >= ow_n) std::printf(" %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * ow_why[w] / ow_n);
            std::printf("\n    he was doing at the kick:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (ow_job[w] * 25 >= ow_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * ow_job[w] / ow_n);
            std::printf("\n");
        }
        if (ib_loft_all[0] + ib_loft_all[1])
            std::printf("  read balls in behind: on the ground %.1f a match, theirs %.0f%% · lofted %.1f, theirs %.0f%%\n",
                        ib_loft_all[0] / nm, 100.0 * ib_loft_theirs[0] / std::max(1L, ib_loft_all[0]),
                        ib_loft_all[1] / nm, 100.0 * ib_loft_theirs[1] / std::max(1L, ib_loft_all[1]));
        if (ib_seen[0] + ib_seen[1]) {
            const double t = ib_seen[0] + ib_seen[1];
            std::printf("  read balls in behind theirs: their man IN the passer's view %.0f%% · behind him %.0f%%; passer's last look 0 / <0.5 / 0.5-1.5 / 1.5+ s ago %.0f / %.0f / %.0f / %.0f%%\n",
                        100 * ib_seen[1] / t, 100 * ib_seen[0] / t, 100 * ib_age[0] / t, 100 * ib_age[1] / t, 100 * ib_age[2] / t, 100 * ib_age[3] / t);
        }
        if (ib_n)
            std::printf("  balls in behind theirs at the kick: %.1f a match; strike off his aim <2 / 2-5 / 5-10 / 10+ deg %.0f / %.0f / %.0f / %.0f%%; their man meets it before the spot %.0f%% · at it (±3 m) %.0f%% · after it ran on %.0f%%\n",
                        ib_n / nm, 100.0 * ib_err[0] / ib_n, 100.0 * ib_err[1] / ib_n, 100.0 * ib_err[2] / ib_n, 100.0 * ib_err[3] / ib_n,
                        100.0 * ib_where[0] / ib_n, 100.0 * ib_where[1] / ib_n, 100.0 * ib_where[2] / ib_n);
        for (int q = 0; q < 2; ++q) {
            long tot = 0;
            for (int w = 0; w < ai::kWhyCount; ++w) tot += rt_n[q][w];
            if (!tot) continue;
            std::printf("  their moving ball %s: %.1f a match; his speed <2 / 2-4 / 4-6 / 6+ m/s %.0f / %.0f / %.0f / %.0f%%; ball speed relative to him <6 / 6-9 / 9-12 / 12+ %.0f / %.0f / %.0f / %.0f%%; doing:",
                        q ? "came off him" : "kept (clean)", tot / nm,
                        100.0 * rt_sp[q][0] / tot, 100.0 * rt_sp[q][1] / tot, 100.0 * rt_sp[q][2] / tot, 100.0 * rt_sp[q][3] / tot,
                        100.0 * rt_rel[q][0] / tot, 100.0 * rt_rel[q][1] / tot, 100.0 * rt_rel[q][2] / tot, 100.0 * rt_rel[q][3] / tot);
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (rt_n[q][w] * 25 >= tot) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * rt_n[q][w] / tot);
            std::printf("\n");
        }
        if (cut_n) {
            std::printf("  each interception: the man had moved <1 m %.0f%% · 1-3 %.0f%% · 3-6 %.0f%% · 6+ %.0f%% since the kick; the ball had flown <0.5 s %.0f%% · 0.5-1 %.0f%% · 1-2 %.0f%% · 2+ %.0f%%\n  the pass:",
                        100.0 * cut_moved[0] / cut_n, 100.0 * cut_moved[1] / cut_n, 100.0 * cut_moved[2] / cut_n, 100.0 * cut_moved[3] / cut_n,
                        100.0 * cut_time[0] / cut_n, 100.0 * cut_time[1] / cut_n, 100.0 * cut_time[2] / cut_n, 100.0 * cut_time[3] / cut_n);
            for (int w = 0; w <= ai::kWhyCount; ++w)
                if (cut_by_why[w] * 25 >= cut_n)
                    std::printf(" %s %.0f%%", w == ai::kWhyCount ? "in behind" : ai::kWhyNames[w], 100.0 * cut_by_why[w] / cut_n);
            std::printf("\n  the flight read one tick after the kick said: ours first %.0f%% · THEIRS first %.0f%% · nobody %.0f%% (all kicks: %.0f / %.0f / %.0f%%)",
                        100.0 * pred_cut[0] / cut_n, 100.0 * pred_cut[1] / cut_n, 100.0 * pred_cut[2] / cut_n,
                        100.0 * pred_all[0] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]),
                        100.0 * pred_all[1] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]),
                        100.0 * pred_all[2] / std::max(1L, pred_all[0] + pred_all[1] + pred_all[2]));
            if (po_n) {
                std::printf("\n  cut passes the read gave to US (%ld): the cutter was their predicted man %.0f%%; we were ahead by <0.2 s %.0f%% · 0.2-0.5 %.0f%% · 0.5-1 %.0f%% · 1+ / unchallenged %.0f%%; our man 0.3 s in:",
                            po_n, 100.0 * po_cutter_pred / po_n, 100.0 * po_margin[0] / po_n, 100.0 * po_margin[1] / po_n,
                            100.0 * po_margin[2] / po_n, 100.0 * po_margin[3] / po_n);
                for (int w = 0; w < ai::kWhyCount; ++w)
                    if (po_us_why[w] * 20 >= po_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * po_us_why[w] / po_n);
            }
            std::printf("\n  kicks the flight read gave to THEM at the kick, by kind (share of that kind, a team a match):");
            for (int w = 0; w <= ai::kWhyCount; ++w) {
                const long n = pred_why[w][0] + pred_why[w][1] + pred_why[w][2];
                if (n < 5 * matches || w == static_cast<int>(ai::Why::Shoot)) continue;
                std::printf("\n    %-28s %3.0f%%  %5.1f", w == ai::kWhyCount ? "in behind (rungs 1-2)" : ai::kWhyNames[w], 100.0 * pred_why[w][1] / n,
                            pred_why[w][1] / 2.0 / matches);
            }
            std::printf("\n  the man who took it was doing:");
            for (int w = 0; w < ai::kWhyCount; ++w)
                if (cut_why_taker[w] * 25 >= cut_n) std::printf(" %s %.0f%%", ai::kWhyNames[w], 100.0 * cut_why_taker[w] / cut_n);
            std::printf("\n");
        }
        std::printf("\nPRO REFERENCE — %s, %s %s, %d matches (semi-pro sits on the worse side of it)\n",
                    bench[0].source.c_str(), bench[0].competition.c_str(), bench[0].season.c_str(), bench[0].matches);
        std::printf("  %-76s %9s %9s %9s\n", "", names.team_home.substr(0, 9).c_str(), names.team_away.substr(0, 9).c_str(), "pro");
        for (const auto& b : bench) {
            const auto it = sim.find(b.metric);
            if (it == sim.end()) continue;
            const std::string lab = b.label + " (" + b.unit + ")";
            if (std::isnan(it->second.second))
                std::printf("  %-76s %9.1f %9s %9.1f\n", lab.c_str(), it->second.first, "", b.value);
            else
                std::printf("  %-76s %9.1f %9.1f %9.1f\n", lab.c_str(), it->second.first, it->second.second, b.value);
        }
    }
    return 0;
}
