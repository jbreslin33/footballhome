// game/src/tools/concept_clips_main.cpp — fh-concept-clips: build one concept's clips ahead of time.
//
// Owner 11/25: "would it be better to run the sim and grab the examples ahead of time for each concept
// since it does not take long. think of it like compiling a c++ program. we can have multiple
// 'executables' for them to view? we focus now on the 'stay in pressing distance'" · "one concept at a
// time" · "yes go ahead and we can focus on the 'presentation' of the concept once we have multiple 'exe'".
//
// The build: N whole matches, headless, each with a RECORDER attached as one more client watching the
// brains — so a clip is exactly the bytes the viewer would have been sent (Viewer = game: the same
// GameServer, the same frames). The concept's dials are on, as in the concept's room
// (game_concept_dials). Each moment the concept is TESTED is scored, cut out with a few seconds either
// side, and sorted good or bad; the best of each are the concept's clips.
//
// Stay in pressing distance (game_concepts 164) — its test is a pass to the man a defender has:
//   at the kick       was his man inside his reach (ai/concepts/PressingDistance — the engine's own read)?
//   as it arrives     how far is he from his man?
//   the next 4 s      did his man's side get forward with it (10 m+ toward his goal, or a goal), or did
//                     it go nowhere / come back, or did his side win it?
//   GOAL SIDE         was he between his man and his own goal (PressReach::goal_side)? Owner 11/25: "being able to
//                     press but the player can dribble to our goal lol is bad as we are 'chasing'" · "to be correct
//                     fully we need to prevent forward progress right?" — yes: the concept is done when the man
//                     gets no forward progress.
//   GOOD   in reach AND goal side at the kick, within 3 m as it arrives, and the man got nowhere (or we won it).
//   BAD    the man's side got forward, and he was either out of reach (4-12 m as it arrives; further than 12 m he
//          was never near his man — a different lesson) or in reach on the WRONG side (chasing).
// The thresholds are [FH] coaching values for picking clear examples — they pick clips, they never
// touch the sim.
//
// Output (a build output like an executable, not source — frontend/game-clips/ is git-ignored):
//   <out>/index.json      the build: engine, matches, fixtures, the SET (what a player is shown) and the
//                         POOL (every kept clip, best first) with who, when and what happened
//   <out>/<id>.fhclip     "FHCLIP1\n", u32 LE json length, the clip's json, then the wire messages
//                         [u32 LE length][bytes]: first the ones a viewer needs once (HELLO, legends,
//                         teams, roster), then every tick's frames from the clip's first tick to its last
// The new build is written beside the old and swapped in at the end: a viewer never sees a half build.
//
// Re-kit a build (mig 1923, owner 11/25 "the colors of the teams in sim always need to be distinct"):
//   fh-concept-clips --rekit DIR   rewrites ONLY each clip's TEAMS message with the kits the server would
//                                  choose now (server/Kits) — the same clips, the same frames, new shirts.
//                                  A build is the examples we focus on; a kit change never swaps them.
//
//   POSTGRES_HOST=localhost POSTGRES_PASSWORD=… fh-concept-clips --out DIR [--concept 164] [--matches 8]
//        [--jobs 4] [--seed 5000] [--good 5] [--bad 3] [--pool 30] [--engine <git sha>]

#include "net/Codec.hpp"
#include "net/INetworkTransport.hpp"
#include "persistence/FormationStore.hpp"
#include "server/GameServer.hpp"
#include "server/Kits.hpp"
#include "server/MatchSetup.hpp"

#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <deque>
#include <filesystem>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace fh::game;
namespace fs = std::filesystem;

namespace {

const char* envOr(const char* k, const char* d) {
    const char* v = std::getenv(k);
    return v && *v ? v : d;
}

constexpr ClientId kRecorder = 1;
constexpr int kHz = 30;   // core::kTickRate
constexpr std::size_t kRingTicks = 22 * kHz;   // the frames kept behind the newest tick

using Msg = std::vector<std::uint8_t>;

// The recorder: one client that keeps what it is sent. Frames sent outside a tick (HELLO, the legends,
// teams, roster) are the clip's head — the latest of each type; frames inside a tick go to that tick.
class Recorder final : public net::INetworkTransport {
public:
    void setOnConnect(OnConnectFn f) override { on_connect = std::move(f); }
    void setOnDisconnect(OnDisconnectFn) override {}
    void setOnMessage(OnMessageFn f) override { on_message = std::move(f); }
    bool send(ClientId, std::span<const std::uint8_t> b) override {
        Msg m(b.begin(), b.end());
        std::size_t used = 0;
        const auto f = net::decodeFrame(m.data(), m.size(), used);
        const int type = f ? static_cast<int>(f->type) : -1;
        const bool head_type = type == static_cast<int>(net::FrameType::Roster) || type == static_cast<int>(net::FrameType::Teams);
        if (!in_tick || head_type) {
            bool put = false;
            for (auto& [t, bytes] : head) if (t == type) { bytes = m; put = true; }
            if (!put) head.emplace_back(type, m);
        }
        if (in_tick) tick_msgs.push_back(std::move(m));
        return true;
    }
    void disconnect(ClientId) override {}
    std::size_t clientCount() const override { return 1; }
    void poll(int) override {}

    OnConnectFn on_connect;
    OnMessageFn on_message;
    bool in_tick = false;
    std::vector<std::pair<int, Msg>> head;
    std::vector<Msg> tick_msgs;
};

// What the build reads each tick, per slot (the engine's own reads, nothing recomputed).
struct SlotRec {
    std::uint8_t pd = 0;      // the pressing-distance machine's state
    std::int16_t man = -1;    // the man it is about
    bool in = false;          // his man inside his reach (PressReach)
    bool gs = false;          // he is goal side of his man (PressReach::goal_side)
    double gap = 0, reach = 0, x = 0, y = 0;
};
struct TickRec {
    std::uint64_t tick = 0;
    std::vector<Msg> msgs;
    SlotRec s[22];
    int owner = -1;
    double bx = 0, by = 0;
};

struct Who { int slot = -1, number = 0; std::string name, label, role; };

struct Clip {
    std::string kind;          // "good" / "bad"
    double score = 0;
    int match = 0;
    std::string fixture;
    Who def, man;
    double gap_kick = 0, reach_kick = 0, gap_recv = 0, progress = 0;
    bool in_kick = false, gs_kick = false;
    std::string outcome;       // won / held / forward / goal
    std::uint64_t t_kick = 0, t_recv = 0, t_end = 0, t_from = 0, t_to = 0;
    std::vector<std::uint8_t> bytes;   // the .fhclip body (head + ticks), json added at write
    std::string file;          // set when written
};

std::string jstr(const std::string& s) {
    std::string o = "\"";
    for (const char c : s) {
        if (c == '"' || c == '\\') { o += '\\'; o += c; }
        else if (static_cast<unsigned char>(c) < 0x20) { char b[8]; std::snprintf(b, sizeof b, "\\u%04x", c); o += b; }
        else o += c;
    }
    return o + "\"";
}
std::string jnum(double v, int dp = 1) { char b[32]; std::snprintf(b, sizeof b, "%.*f", dp, v); return b; }
std::string jwho(const Who& w) {
    return "{\"slot\":" + std::to_string(w.slot) + ",\"number\":" + std::to_string(w.number) + ",\"name\":" + jstr(w.name) +
           ",\"label\":" + jstr(w.label) + ",\"role\":" + jstr(w.role) + "}";
}
std::string clipJson(const Clip& c, const std::string& id) {
    std::ostringstream o;
    o << "{\"id\":" << jstr(id) << ",\"kind\":" << jstr(c.kind) << ",\"score\":" << jnum(c.score, 2) << ",\"match\":" << c.match
      << ",\"fixture\":" << jstr(c.fixture) << ",\"defender\":" << jwho(c.def) << ",\"man\":" << jwho(c.man)
      << ",\"in_reach_at_kick\":" << (c.in_kick ? "true" : "false") << ",\"goal_side_at_kick\":" << (c.gs_kick ? "true" : "false") << ",\"gap_at_kick_m\":" << jnum(c.gap_kick)
      << ",\"reach_at_kick_m\":" << jnum(c.reach_kick) << ",\"gap_at_arrival_m\":" << jnum(c.gap_recv)
      << ",\"forward_m\":" << jnum(c.progress) << ",\"outcome\":" << jstr(c.outcome) << ",\"t_from\":" << c.t_from
      << ",\"t_kick\":" << c.t_kick << ",\"t_recv\":" << c.t_recv << ",\"t_end\":" << c.t_end << ",\"t_to\":" << c.t_to
      << ",\"minute\":" << c.t_recv / (60 * kHz) << ",\"file\":" << jstr(id + ".fhclip") << "}";
    return o.str();
}
void putU32(std::vector<std::uint8_t>& b, std::uint32_t v) { for (int i = 0; i < 4; ++i) b.push_back(static_cast<std::uint8_t>(v >> (8 * i))); }
void putMsg(std::vector<std::uint8_t>& b, const Msg& m) { putU32(b, static_cast<std::uint32_t>(m.size())); b.insert(b.end(), m.begin(), m.end()); }

void writeClip(const fs::path& path, const Clip& c, const std::string& id) {
    const std::string js = clipJson(c, id);
    std::vector<std::uint8_t> out{'F', 'H', 'C', 'L', 'I', 'P', '1', '\n'};
    putU32(out, static_cast<std::uint32_t>(js.size()));
    out.insert(out.end(), js.begin(), js.end());
    out.insert(out.end(), c.bytes.begin(), c.bytes.end());
    std::ofstream f(path, std::ios::binary);
    f.write(reinterpret_cast<const char*>(out.data()), static_cast<std::streamsize>(out.size()));
}

struct Build {
    int concept_id = 164, matches = 8, jobs = 4, good = 5, bad = 3, pool = 30;
    std::uint64_t seed = 5000;
    std::string out, engine = "unknown", rekit;
    // Sides left out of the fixtures: the club's own teaching sides, copies of West Ham's roster.
    std::string skip = "Lighthouse,Westtown FC";
};

// A pass to a man a defender has: open while the next 4 s are watched.
struct Test {
    int d = -1, m = -1;
    std::uint64_t k0 = 0, kr = 0, until = 0;
    bool in_k = false, gs_k = false;
    double gap_k = 0, reach_k = 0, gap_r = 0, x_r = 0, best = 0;
    std::string outcome;
    bool done = false;
    std::uint64_t t_end = 0;
};

// One match: every test, scored; the best `keep` of each kind returned with their bytes.
std::vector<Clip> playMatch(const server::GameServer::Config& cfg, int match_no, const std::string& fixture, int keep) {
    Recorder rec;
    server::GameServer s{cfg, rec};
    auth::JwtClaims claims;
    claims.person_id = 0;
    if (rec.on_connect) rec.on_connect(kRecorder, claims);
    {
        const Msg w = net::encodeFrame(net::FrameType::BrainWatch, net::encodeBrainWatch(net::BrainWatchFrame{1}));
        if (rec.on_message) rec.on_message(kRecorder, w);
    }
    const auto& W = s.world();
    const std::uint8_t N = std::min<std::uint8_t>(W.playerCount(), 22);
    const ai::FormationSpec* spec[2] = {&cfg.formation_home, &cfg.formation_away};
    const persistence::DemoTeam* team[2] = {&cfg.roster_home, &cfg.roster_away};
    auto who = [&](int slot) {
        Who w;
        w.slot = slot;
        w.number = s.brain().numberOf(static_cast<core::SlotIndex>(slot));
        const int t = slot < N / 2 ? 0 : 1, k = slot - t * (N / 2);
        if (k < static_cast<int>(team[t]->players.size())) w.name = team[t]->players[k].name;
        if (k < static_cast<int>(spec[t]->positions.size())) { w.label = spec[t]->positions[k].label; w.role = spec[t]->positions[k].role; }
        return w;
    };
    auto teamOf = [&](int slot) { return slot < N / 2 ? 0 : 1; };

    std::deque<TickRec> ring;
    std::vector<Test> open;
    std::vector<Clip> good, bad;
    int last_owner = -1, prev_owner = -1;
    std::uint64_t left_tick = 0;
    const std::uint64_t cap = static_cast<std::uint64_t>(cfg.half_length_ticks) * 2 + 20 * 60 * kHz;

    auto recAt = [&](std::uint64_t t) -> const TickRec* {
        if (ring.empty() || t < ring.front().tick || t > ring.back().tick) return nullptr;
        const std::size_t i = static_cast<std::size_t>(t - ring.front().tick);
        if (i < ring.size() && ring[i].tick == t) return &ring[i];
        for (const auto& r : ring) if (r.tick == t) return &r;
        return nullptr;
    };
    auto cut = [&](const Test& T) {
        Clip c;
        const bool fwd = T.outcome == "forward" || T.outcome == "goal";
        const bool is_good = T.in_k && T.gs_k && T.gap_r <= 3.0 && (T.outcome == "won" || T.outcome == "held");
        const bool is_bad = fwd && T.gap_r <= 12.0 && T.gap_k <= 15.0 &&
                            ((!T.in_k && T.gap_r >= 4.0) || (T.in_k && !T.gs_k));   // too far, or near but chasing
        if (!is_good && !is_bad) return;
        c.kind = is_good ? "good" : "bad";
        c.score = is_good ? (T.outcome == "won" ? 3.0 : 1.0) + (3.0 - T.gap_r)
                          : T.gap_r / 2.0 + T.best / 10.0 + (T.outcome == "goal" ? 3.0 : 0.0);
        c.match = match_no; c.fixture = fixture;
        c.def = who(T.d); c.man = who(T.m);
        c.in_kick = T.in_k; c.gs_kick = T.gs_k; c.gap_kick = T.gap_k; c.reach_kick = T.reach_k; c.gap_recv = T.gap_r; c.progress = T.best;
        c.outcome = T.outcome;
        c.t_kick = T.k0; c.t_recv = T.kr; c.t_end = T.t_end;
        c.t_from = std::max<std::uint64_t>(ring.front().tick, T.k0 > 4 * kHz ? T.k0 - 4 * kHz : 0);
        c.t_to = std::min<std::uint64_t>(ring.back().tick, T.t_end + 3 * kHz / 2);
        for (const auto& [_, m] : rec.head) putMsg(c.bytes, m);
        for (std::uint64_t t = c.t_from; t <= c.t_to; ++t)
            if (const TickRec* r = recAt(t)) for (const auto& m : r->msgs) putMsg(c.bytes, m);
        auto& into = is_good ? good : bad;
        into.push_back(std::move(c));
        std::sort(into.begin(), into.end(), [](const Clip& a, const Clip& b) { return a.score > b.score; });
        if (static_cast<int>(into.size()) > keep) into.pop_back();
    };

    bool over = false;
    for (std::uint64_t k = 0; k < cap && !over; ++k) {
        rec.in_tick = true;
        rec.tick_msgs.clear();
        s.tickOnce();
        rec.in_tick = false;
        const std::uint64_t now = W.tickCount();
        TickRec tr;
        tr.tick = now;
        tr.msgs = std::move(rec.tick_msgs);
        rec.tick_msgs = {};
        for (std::uint8_t i = 0; i < N; ++i) {
            const auto& ms = s.brain().machineOf(i, ai::concepts::MachineId::PressingDistance);
            const auto& pr = s.brain().pressReach(i);
            tr.s[i].pd = ms.state;
            tr.s[i].man = ms.other >= 0 ? ms.other : static_cast<std::int16_t>(pr.man);
            tr.s[i].in = pr.in;
            tr.s[i].gs = pr.goal_side;
            tr.s[i].gap = pr.gap_m.toDouble();
            tr.s[i].reach = pr.reach_m.toDouble();
            tr.s[i].x = W.player(i).pos.x.toDouble();
            tr.s[i].y = W.player(i).pos.y.toDouble();
        }
        const auto& b = W.ball();
        tr.owner = b.owner ? static_cast<int>(*b.owner) : -1;
        tr.bx = b.pos.x.toDouble();
        tr.by = b.pos.y.toDouble();
        ring.push_back(std::move(tr));
        while (ring.size() > kRingTicks) ring.pop_front();
        const TickRec& R = ring.back();

        bool goal_for[2] = {false, false}, stop = false;
        for (const auto& e : s.lastEvents()) {
            if (e.type == core::MatchEventType::FullTime) over = true;
            if (e.type == core::MatchEventType::Goal && e.team < 2) goal_for[e.team] = true;
        }
        stop = W.restartTeam() != 0xFF;

        // A new owner out of a loose ball: the pass that found him, if it was a mate's.
        if (R.owner >= 0 && R.owner != last_owner) {
            const int m = R.owner;
            if (last_owner < 0 && prev_owner >= 0 && prev_owner != m && teamOf(prev_owner) == teamOf(m) && !stop &&
                left_tick > 0 && now - left_tick <= 4 * kHz) {
                const std::uint64_t k0 = left_tick;
                if (const TickRec* K = recAt(k0)) {
                    int d = -1;
                    double dist = 1e9;
                    for (int i = 0; i < N; ++i) {
                        if (teamOf(i) == teamOf(m) || K->s[i].pd == 0 || K->s[i].man != m) continue;
                        if (K->s[i].gap < dist) { dist = K->s[i].gap; d = i; }
                    }
                    if (d >= 0) {
                        Test T;
                        T.d = d; T.m = m; T.k0 = k0; T.kr = now; T.until = now + 4 * kHz;
                        T.in_k = K->s[d].in; T.gs_k = K->s[d].gs; T.gap_k = K->s[d].gap; T.reach_k = K->s[d].reach;
                        T.gap_r = std::hypot(R.s[d].x - R.s[m].x, R.s[d].y - R.s[m].y);
                        T.x_r = R.bx;
                        open.push_back(T);
                    }
                }
            }
        }
        if (R.owner >= 0) last_owner = R.owner;
        else if (last_owner >= 0) { prev_owner = last_owner; left_tick = now - 1; last_owner = -1; }   // it left him: the kick

        // Watch the open tests.
        for (auto& T : open) {
            if (T.done) continue;
            const int dt = teamOf(T.d), mt = 1 - dt;
            const double fwd = dt == 0 ? T.x_r - R.bx : R.bx - T.x_r;   // toward HIS goal (home defends -x)
            if (R.owner < 0 || teamOf(R.owner) == mt) T.best = std::max(T.best, fwd);
            if (goal_for[mt]) { T.outcome = "goal"; T.done = true; }
            else if (R.owner >= 0 && teamOf(R.owner) == dt) { T.outcome = "won"; T.done = true; }
            else if (stop) { T.outcome = W.restartTeam() == dt ? "won" : (T.best >= 10.0 ? "forward" : "held"); T.done = true; }
            else if (now >= T.until) { T.outcome = T.best >= 10.0 ? "forward" : "held"; T.done = true; }
            if (T.done) T.t_end = now;
        }
        // Cut the finished ones once their tail is recorded.
        for (auto it = open.begin(); it != open.end();) {
            if (it->done && now >= it->t_end + 3 * kHz / 2) { cut(*it); it = open.erase(it); }
            else ++it;
        }
    }
    std::vector<Clip> all;
    for (auto& c : good) all.push_back(std::move(c));
    for (auto& c : bad) all.push_back(std::move(c));
    return all;
}

std::vector<std::string> split(const std::string& s, char sep) {
    std::vector<std::string> o;
    std::string cur;
    for (const char c : s) { if (c == sep) { o.push_back(cur); cur.clear(); } else cur += c; }
    o.push_back(cur);
    return o;
}

// --rekit: each clip's TEAMS message re-encoded with today's kit choice for the same two sides.
int rekit(const fs::path& dir, const persistence::DbConfig& db) {
    std::map<std::string, std::vector<persistence::Kit>> kits;   // team name → its kits, loaded once
    // A side that does not load (no DB, a renamed team) leaves its clip exactly as it was.
    const auto kitsOf = [&](const std::string& name) -> const std::vector<persistence::Kit>* {
        auto it = kits.find(name);
        if (it == kits.end()) {
            auto t = persistence::loadDemoTeam(db, name);
            if (!t || t->kits.empty()) return nullptr;
            it = kits.emplace(name, t->kits).first;
        }
        return &it->second;
    };
    const auto u32 = [](const std::vector<std::uint8_t>& b, std::size_t at) {
        return static_cast<std::uint32_t>(b[at]) | (static_cast<std::uint32_t>(b[at + 1]) << 8) |
               (static_cast<std::uint32_t>(b[at + 2]) << 16) | (static_cast<std::uint32_t>(b[at + 3]) << 24);
    };
    int files = 0, changed = 0;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (e.path().extension() != ".fhclip") continue;
        std::ifstream in(e.path(), std::ios::binary);
        std::vector<std::uint8_t> b((std::istreambuf_iterator<char>(in)), {});
        if (b.size() < 12 || std::memcmp(b.data(), "FHCLIP1\n", 8) != 0) { std::fprintf(stderr, "%s: not a clip\n", e.path().c_str()); continue; }
        std::size_t p = 12 + u32(b, 8);
        std::vector<std::uint8_t> out(b.begin(), b.begin() + static_cast<std::ptrdiff_t>(p));
        bool did = false;
        while (p + 4 <= b.size()) {
            const std::uint32_t len = u32(b, p);
            if (p + 4 + len > b.size()) break;
            Msg m(b.begin() + static_cast<std::ptrdiff_t>(p + 4), b.begin() + static_cast<std::ptrdiff_t>(p + 4 + len));
            p += 4 + len;
            std::size_t used = 0;
            if (const auto f = net::decodeFrame(m.data(), m.size(), used); f && f->type == net::FrameType::Teams && used == m.size())
                if (auto tf = net::decodeTeams(f->payload)) {
                    const auto* hk = kitsOf(tf->home);
                    const auto* ak = kitsOf(tf->away);
                    if (!hk || !ak) {
                        std::fprintf(stderr, "%s: %s v %s not loaded — left as it was\n", e.path().filename().c_str(),
                                     tf->home.c_str(), tf->away.c_str());
                        did = false;
                        out.clear();
                        break;
                    }
                    const auto worn = server::chooseKits(*hk, *ak);
                    const persistence::Kit* kk[2] = {&worn.home, &worn.away};
                    for (int t = 0; t < 2; ++t) {
                        tf->kit[t][0] = kk[t]->shirt; tf->kit[t][1] = kk[t]->shorts;
                        tf->kit[t][2] = kk[t]->socks; tf->kit[t][3] = kk[t]->trim;
                    }
                    Msg n = net::encodeFrame(net::FrameType::Teams, net::encodeTeams(*tf));
                    if (n != m) did = true;
                    m = std::move(n);
                    std::printf("%s: %s v %s — home kit %d, away kit %d\n", e.path().filename().c_str(),
                                tf->home.c_str(), tf->away.c_str(), worn.home_index, worn.away_index);
                }
            putMsg(out, m);
        }
        ++files;
        if (!did || out.empty()) continue;
        const fs::path tmp = e.path().string() + ".rekit";
        { std::ofstream o(tmp, std::ios::binary); o.write(reinterpret_cast<const char*>(out.data()), static_cast<std::streamsize>(out.size())); }
        fs::rename(tmp, e.path());
        ++changed;
    }
    std::printf("rekit: %d clip(s), %d re-kitted\n", files, changed);
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    Build B;
    for (int i = 1; i + 1 < argc; i += 2) {
        const std::string k = argv[i], v = argv[i + 1];
        if (k == "--out") B.out = v;
        else if (k == "--concept") B.concept_id = std::atoi(v.c_str());
        else if (k == "--matches") B.matches = std::atoi(v.c_str());
        else if (k == "--jobs") B.jobs = std::max(1, std::min(4, std::atoi(v.c_str())));   // ≤4 on the prod host
        else if (k == "--seed") B.seed = std::strtoull(v.c_str(), nullptr, 10);
        else if (k == "--good") B.good = std::atoi(v.c_str());
        else if (k == "--bad") B.bad = std::atoi(v.c_str());
        else if (k == "--pool") B.pool = std::atoi(v.c_str());
        else if (k == "--engine") B.engine = v;
        else if (k == "--skip") B.skip = v;
        else if (k == "--rekit") B.rekit = v;
    }
    if (!B.rekit.empty()) {
        persistence::DbConfig db;
        db.host = envOr("POSTGRES_HOST", "localhost");
        db.dbname = envOr("POSTGRES_DB", "footballhome");
        db.user = envOr("POSTGRES_USER", "footballhome_user");
        db.password = envOr("POSTGRES_PASSWORD", "");
        return rekit(B.rekit, db);
    }
    if (B.out.empty()) { std::fprintf(stderr, "usage: fh-concept-clips --out DIR [--concept 164] [--matches 8] [--jobs 4] …\n"); return 2; }
    if (B.concept_id != 164) { std::fprintf(stderr, "only stay in pressing distance (164) has a test so far\n"); return 2; }

    persistence::DbConfig db;
    db.host = envOr("POSTGRES_HOST", "localhost");
    db.dbname = envOr("POSTGRES_DB", "footballhome");
    db.user = envOr("POSTGRES_USER", "footballhome_user");
    db.password = envOr("POSTGRES_PASSWORD", "");
    server::GameServer::Config base{};
    base.match_id = 1;
    base.slot_count = 22;
    server::MatchNames names;
    server::loadMatchFromDb(base, db, names, false);
    base.half_length_ticks = 45 * 60 * kHz;
    const auto dials = persistence::loadConceptDials(db, B.concept_id);
    for (const auto& [key, milli] : dials) base.model_params.setMilli(key, milli);
    std::printf("concept %d: %zu dial(s) on\n", B.concept_id, dials.size());

    // The fixtures: a round robin over every side, as fh-game-match rotates them.
    struct Side { persistence::DemoTeam team; ai::FormationSpec spec; };
    std::vector<Side> sides;
    const auto skip = split(B.skip, ',');
    for (const auto& n : base.team_names) {
        if (std::find(skip.begin(), skip.end(), n) != skip.end()) continue;
        auto t = persistence::loadDemoTeam(db, n);
        if (!t) continue;
        Side sd{std::move(*t), base.formation_home};
        if (!sd.team.formation_code.empty())
            if (auto f = persistence::loadFormation(db, sd.team.formation_code)) sd.spec = std::move(*f);
        sides.push_back(std::move(sd));
    }
    if (sides.size() % 2) sides.pop_back();
    if (sides.size() < 2) { std::fprintf(stderr, "no teams loaded\n"); return 1; }
    auto fixtureOf = [&](int m, server::GameServer::Config& cfg) {
        const int n = static_cast<int>(sides.size()), rounds = n - 1, per = n / 2;
        const int r = (m / per) % rounds, g = m % per;
        auto at = [&](int k) { return k == 0 ? 0 : 1 + (k - 1 + r) % (n - 1); };
        int a = at(g), b = at(n - 1 - g);
        if (r % 2) std::swap(a, b);
        cfg.roster_home = sides[a].team; cfg.formation_home = sides[a].spec;
        cfg.roster_away = sides[b].team; cfg.formation_away = sides[b].spec;
        return sides[a].team.name + " v " + sides[b].team.name;
    };

    const fs::path out = fs::absolute(B.out);
    const fs::path next = out.string() + ".building";
    const fs::path work = next / ".work";
    fs::remove_all(next);
    fs::create_directories(work);
    const std::time_t started = std::time(nullptr);

    // The jobs: forked processes, each its share of the matches; each writes its kept clips + a list.
    std::vector<pid_t> kids;
    for (int j = 0; j < B.jobs; ++j) {
        std::fflush(stdout);   // or each child prints the parent's buffer again
        const pid_t pid = fork();
        if (pid < 0) { std::perror("fork"); return 1; }
        if (pid == 0) {
            std::ofstream list(work / ("job" + std::to_string(j) + ".tsv"));
            for (int m = j; m < B.matches; m += B.jobs) {
                server::GameServer::Config cfg = base;
                cfg.match_seed = B.seed + static_cast<std::uint64_t>(m);
                const std::string fx = fixtureOf(m, cfg);
                auto clips = playMatch(cfg, m + 1, fx, B.pool);
                int n = 0;
                for (auto& c : clips) {
                    const std::string id = "m" + std::to_string(m + 1) + "_" + std::to_string(n++);
                    writeClip(work / (id + ".fhclip"), c, id);
                    list << c.kind << '\t' << jnum(c.score, 3) << '\t' << id << '\t' << c.def.role << '\t' << clipJson(c, id) << '\n';
                }
                list.flush();
                std::printf("match %d (%s): %zu clip(s) kept\n", m + 1, fx.c_str(), clips.size());
                std::fflush(stdout);
            }
            _exit(0);
        }
        kids.push_back(pid);
    }
    bool ok = true;
    for (const pid_t p : kids) { int st = 0; waitpid(p, &st, 0); ok = ok && WIFEXITED(st) && WEXITSTATUS(st) == 0; }
    if (!ok) { std::fprintf(stderr, "a job failed; the old build stays\n"); return 1; }

    // Merge: the pool, best first, per kind; the SET picks across positions (roles) so a centre-back and a
    // midfielder both see their own.
    struct Row { std::string kind, id, role, json; double score; };
    std::vector<Row> rows;
    for (int j = 0; j < B.jobs; ++j) {
        std::ifstream in(work / ("job" + std::to_string(j) + ".tsv"));
        std::string line;
        while (std::getline(in, line)) {
            auto f = split(line, '\t');
            if (f.size() < 5) continue;
            rows.push_back({f[0], f[2], f[3], f[4], std::atof(f[1].c_str())});
        }
    }
    std::sort(rows.begin(), rows.end(), [](const Row& a, const Row& b) { return a.score > b.score; });
    std::vector<std::string> pool_json, set_ids;
    std::map<std::string, int> kept;
    for (const auto* kind : {"good", "bad"}) {
        std::vector<const Row*> mine;
        for (const auto& r : rows) if (r.kind == kind && static_cast<int>(mine.size()) < B.pool) mine.push_back(&r);
        for (const auto* r : mine) {
            fs::rename(work / (r->id + ".fhclip"), next / (r->id + ".fhclip"));
            pool_json.push_back(r->json);
        }
        kept[kind] = static_cast<int>(mine.size());
        const int want = std::string(kind) == "good" ? B.good : B.bad;
        // Round by round: the best of each position first, then a second of each, …
        std::vector<bool> used(mine.size(), false);
        std::map<std::string, int> per_role;
        int have = 0;
        for (int round = 0; have < want && round < 11; ++round)
            for (std::size_t i = 0; i < mine.size() && have < want; ++i) {
                if (used[i] || per_role[mine[i]->role] > round) continue;
                used[i] = true; ++per_role[mine[i]->role]; set_ids.push_back(mine[i]->id); ++have;
            }
    }
    fs::remove_all(work);
    {
        std::ofstream idx(next / "index.json");
        char when[32];
        std::strftime(when, sizeof when, "%Y-%m-%dT%H:%M:%SZ", std::gmtime(&started));
        idx << "{\"concept_id\":" << B.concept_id << ",\"engine\":" << jstr(B.engine) << ",\"built_at\":" << jstr(when)
            << ",\"build_s\":" << (std::time(nullptr) - started) << ",\"matches\":" << B.matches << ",\"seed\":" << B.seed
            << ",\"want\":{\"good\":" << B.good << ",\"bad\":" << B.bad << ",\"pool\":" << B.pool << "},\"set\":[";
        for (std::size_t i = 0; i < set_ids.size(); ++i) idx << (i ? "," : "") << jstr(set_ids[i]);
        idx << "],\"pool\":[\n";
        for (std::size_t i = 0; i < pool_json.size(); ++i) idx << (i ? ",\n" : "") << pool_json[i];
        idx << "\n]}\n";
    }
    // Swap it in: the old build stays until the new one is whole.
    const fs::path old = out.string() + ".old";
    fs::remove_all(old);
    if (fs::exists(out)) fs::rename(out, old);
    fs::rename(next, out);
    fs::remove_all(old);
    std::printf("built %s: %d good, %d bad in the pool, %zu in the set, %lds\n", out.c_str(), kept["good"], kept["bad"],
                set_ids.size(), static_cast<long>(std::time(nullptr) - started));
    return 0;
}
