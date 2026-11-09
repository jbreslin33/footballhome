// game/src/net/Codec.cpp

#include "net/Codec.hpp"

#include <cassert>

namespace fh::game::net {

namespace {

// ── little-endian writer / reader ───────────────────────────────────────

struct Writer {
    Bytes out;

    void u8(std::uint8_t v)  { out.push_back(v); }
    void u16(std::uint16_t v) {
        out.push_back(static_cast<std::uint8_t>(v));
        out.push_back(static_cast<std::uint8_t>(v >> 8));
    }
    void u64(std::uint64_t v) {
        for (int i = 0; i < 8; ++i)
            out.push_back(static_cast<std::uint8_t>(v >> (i * 8)));
    }
    void fx(math::Fixed64 f) { u64(static_cast<std::uint64_t>(f.raw)); }
};

struct Reader {
    const std::uint8_t* p;
    std::size_t n;
    std::size_t at = 0;
    bool ok = true;

    bool need(std::size_t k) {
        if (at + k > n) { ok = false; return false; }
        return true;
    }
    std::size_t remaining() const { return at < n ? n - at : 0; }
    std::uint8_t u8() {
        if (!need(1)) return 0;
        return p[at++];
    }
    std::uint16_t u16() {
        if (!need(2)) return 0;
        std::uint16_t v = static_cast<std::uint16_t>(p[at])
                        | static_cast<std::uint16_t>(p[at + 1]) << 8;
        at += 2;
        return v;
    }
    std::uint64_t u64() {
        if (!need(8)) return 0;
        std::uint64_t v = 0;
        for (int i = 0; i < 8; ++i)
            v |= static_cast<std::uint64_t>(p[at + i]) << (i * 8);
        at += 8;
        return v;
    }
    math::Fixed64 fx() {
        return math::Fixed64::fromRaw(static_cast<std::int64_t>(u64()));
    }
};

}  // namespace

// ── Envelope ────────────────────────────────────────────────────────────

Bytes encodeFrame(FrameType type, const Bytes& payload) {
    assert(payload.size() <= 0xFFFF && "payload exceeds u16 envelope");
    if (payload.size() > 0xFFFF) return {};
    Writer w;
    w.u16(static_cast<std::uint16_t>(payload.size()));
    w.u8(static_cast<std::uint8_t>(type));
    w.u8(0);  // flags
    w.out.insert(w.out.end(), payload.begin(), payload.end());
    return std::move(w.out);
}

std::optional<DecodedFrame> decodeFrame(const std::uint8_t* data,
                                        std::size_t size,
                                        std::size_t& consumed) {
    if (size < kEnvelopeBytes) return std::nullopt;
    const std::uint16_t len = static_cast<std::uint16_t>(data[0])
                            | static_cast<std::uint16_t>(data[1]) << 8;
    if (size < kEnvelopeBytes + len) return std::nullopt;
    DecodedFrame f;
    f.type  = static_cast<FrameType>(data[2]);
    f.flags = data[3];
    f.payload.assign(data + kEnvelopeBytes, data + kEnvelopeBytes + len);
    consumed = kEnvelopeBytes + len;
    return f;
}

// ── HELLO ───────────────────────────────────────────────────────────────

Bytes encodeHello(const HelloFrame& f) {
    Writer w;
    w.u8(f.major); w.u8(f.minor); w.u8(f.patch);
    w.u64(f.match_id);
    w.u8(f.tick_rate);
    w.u8(f.capabilities);
    w.u8(f.slot_count);
    w.fx(f.pitch_half_x);
    w.fx(f.pitch_half_y);
    return std::move(w.out);
}

std::optional<HelloFrame> decodeHello(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    HelloFrame f;
    f.major = r.u8(); f.minor = r.u8(); f.patch = r.u8();
    f.match_id = r.u64();
    f.tick_rate = r.u8();
    f.capabilities = r.u8();
    f.slot_count = r.u8();
    f.pitch_half_x = r.fx();
    f.pitch_half_y = r.fx();
    if (!r.ok) return std::nullopt;
    return f;  // trailing bytes, if any, are deliberately ignored (§9)
}

// ── GOODBYE ─────────────────────────────────────────────────────────────

Bytes encodeGoodbye(const GoodbyeFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.reason));
    return std::move(w.out);
}

std::optional<GoodbyeFrame> decodeGoodbye(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    GoodbyeFrame f;
    f.reason = static_cast<GoodbyeReason>(r.u8());
    if (!r.ok) return std::nullopt;
    return f;
}

// ── PLAYER_INTENT ───────────────────────────────────────────────────────

Bytes encodePlayerIntent(const PlayerIntentFrame& f) {
    Writer w;
    w.u8(f.slot);
    w.fx(f.move_x);
    w.fx(f.move_y);
    w.u8(f.action);
    return std::move(w.out);
}

std::optional<PlayerIntentFrame> decodePlayerIntent(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    PlayerIntentFrame f;
    f.slot = r.u8();
    f.move_x = r.fx();
    f.move_y = r.fx();
    f.action = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

// ── SNAPSHOT ────────────────────────────────────────────────────────────

Bytes encodeSnapshot(const SnapshotFrame& f) {
    Writer w;
    w.u64(f.tick);
    w.u8(static_cast<std::uint8_t>(f.players.size()));
    for (const PlayerSnap& p : f.players) {
        w.fx(p.pos_x); w.fx(p.pos_y);
        w.fx(p.vel_x); w.fx(p.vel_y);
        w.u8(p.flags);
    }
    // Ball record, appended in 1.1 (additive — see header note).
    w.fx(f.ball.pos_x); w.fx(f.ball.pos_y); w.fx(f.ball.pos_z);
    w.u8(f.ball.owner);
    // Match structure, appended in 1.2.
    w.u8(f.score0); w.u8(f.score1); w.u8(f.period);
    w.u16(static_cast<std::uint16_t>(f.clock_ticks / 30));  // whole seconds
    w.u8(f.restart_team);
    // 1.8 tail: facing per player, i8 x | i8 y (unit ×127).
    for (const PlayerSnap& p : f.players) {
        w.u8(static_cast<std::uint8_t>(p.face_x));
        w.u8(static_cast<std::uint8_t>(p.face_y));
    }
    // 1.16 tail: u8 count | per official i64 x | i64 y | i8 face_x | i8 face_y | u8 flags.
    w.u8(static_cast<std::uint8_t>(f.officials.size()));
    for (const OfficialSnap& o : f.officials) {
        w.fx(o.pos_x); w.fx(o.pos_y);
        w.u8(static_cast<std::uint8_t>(o.face_x));
        w.u8(static_cast<std::uint8_t>(o.face_y));
        w.u8(o.flags);
    }
    return std::move(w.out);
}

std::optional<SnapshotFrame> decodeSnapshot(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    SnapshotFrame f;
    f.tick = r.u64();
    const std::uint8_t count = r.u8();
    f.players.reserve(count);
    for (std::uint8_t i = 0; i < count; ++i) {
        PlayerSnap p;
        p.pos_x = r.fx(); p.pos_y = r.fx();
        p.vel_x = r.fx(); p.vel_y = r.fx();
        p.flags = r.u8();
        f.players.push_back(p);
    }
    if (!r.ok) return std::nullopt;

    // Ball record (1.1). A 1.0 SNAPSHOT lacks it; decode as "free ball at
    // origin" rather than failing, since the record is additive.
    if (r.at + 25 <= payload.size()) {
        f.ball.pos_x = r.fx();
        f.ball.pos_y = r.fx();
        f.ball.pos_z = r.fx();
        f.ball.owner = r.u8();
    }
    // 1.2 tail: score/period/clock-seconds/restart (6 bytes).
    if (r.at + 6 <= payload.size()) {
        f.score0 = r.u8();
        f.score1 = r.u8();
        f.period = r.u8();
        f.clock_ticks = static_cast<std::uint32_t>(r.u16()) * 30;
        f.restart_team = r.u8();
    }
    if (r.at + 2 * f.players.size() <= payload.size()) {  // 1.8 tail: facing
        for (PlayerSnap& p : f.players) {
            p.face_x = static_cast<std::int8_t>(r.u8());
            p.face_y = static_cast<std::int8_t>(r.u8());
        }
    }
    if (r.at + 1 <= payload.size()) {  // 1.16 tail: the officials
        const std::uint8_t n = r.u8();
        if (r.at + std::size_t{19} * n <= payload.size()) {
            f.officials.reserve(n);
            for (std::uint8_t i = 0; i < n; ++i) {
                OfficialSnap o;
                o.pos_x = r.fx(); o.pos_y = r.fx();
                o.face_x = static_cast<std::int8_t>(r.u8());
                o.face_y = static_cast<std::int8_t>(r.u8());
                o.flags = r.u8();
                f.officials.push_back(o);
            }
        }
    }
    return f;
}

// ── EVENT ───────────────────────────────────────────────────────────────

Bytes encodeEvent(const EventFrame& f) {
    Writer w;
    w.u8(f.event_type);
    w.u8(f.team);
    w.u64(f.tick);
    return std::move(w.out);
}

std::optional<EventFrame> decodeEvent(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    EventFrame f;
    f.event_type = r.u8();
    f.team = r.u8();
    f.tick = r.u64();
    if (!r.ok) return std::nullopt;
    return f;
}

// ── MATCH_SETTINGS ──────────────────────────────────────────────────────

Bytes encodeRoster(const RosterFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const RosterEntry& e : f.slots) {
        const std::size_t len = e.name.size() > 40 ? 40 : e.name.size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i)
            w.u8(static_cast<std::uint8_t>(e.name[i]));
    }
    {
        w.u8(static_cast<std::uint8_t>(f.numbers.size()));
        for (std::uint8_t v : f.numbers) w.u8(v);
    }
    return std::move(w.out);
}

std::optional<RosterFrame> decodeRoster(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    RosterFrame f;
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        RosterEntry e;
        const std::uint8_t len = r.u8();
        for (std::uint8_t k = 0; k < len; ++k)
            e.name.push_back(static_cast<char>(r.u8()));
        f.slots.push_back(std::move(e));
    }
    if (r.ok) {
        const std::uint8_t c = r.u8();
        for (std::uint8_t k = 0; k < c && r.ok; ++k) f.numbers.push_back(r.u8());
    }
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeNames(const NamesFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.names.size()));
    for (const std::string& n : f.names) {
        const std::size_t len = n.size() > 40 ? 40 : n.size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i)
            w.u8(static_cast<std::uint8_t>(n[i]));
    }
    return std::move(w.out);
}

std::optional<NamesFrame> decodeNames(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    NamesFrame f;
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        std::string name;
        const std::uint8_t len = r.u8();
        for (std::uint8_t k = 0; k < len; ++k)
            name.push_back(static_cast<char>(r.u8()));
        f.names.push_back(std::move(name));
    }
    if (!r.ok) return std::nullopt;
    return f;
}

// ── MODEL_DEMANDS / SET_DEMAND (1.14, G4.74) ────────────────────────────

namespace {
void putStr(Writer& w, const std::string& s) {
    const std::size_t len = s.size() > 80 ? 80 : s.size();
    w.u8(static_cast<std::uint8_t>(len));
    for (std::size_t i = 0; i < len; ++i) w.u8(static_cast<std::uint8_t>(s[i]));
}
std::string getStr(Reader& r) {
    const std::uint8_t len = r.u8();
    std::string s;
    for (std::uint8_t i = 0; i < len && r.ok; ++i) s.push_back(static_cast<char>(r.u8()));
    return s;
}
void putI32(Writer& w, std::int32_t v) {
    const auto u = static_cast<std::uint32_t>(v);
    w.u16(static_cast<std::uint16_t>(u));
    w.u16(static_cast<std::uint16_t>(u >> 16));
}
std::int32_t getI32(Reader& r) {
    const std::uint32_t lo = r.u16(), hi = r.u16();
    return static_cast<std::int32_t>(lo | hi << 16);
}
}  // namespace

// ── CLAIM ───────────────────────────────────────────────────────────────

Bytes encodeClaim(const ClaimFrame& f) {
    Writer w;
    w.u8(f.slot);
    w.u8(f.claim);
    return std::move(w.out);
}

std::optional<ClaimFrame> decodeClaim(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    ClaimFrame f;
    f.slot = r.u8();
    f.claim = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeTeams(const TeamsFrame& f) {
    Writer w;
    for (const std::string* n : {&f.home, &f.away}) {
        const std::size_t len = n->size() > 60 ? 60 : n->size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i) w.u8(static_cast<std::uint8_t>((*n)[i]));
    }
    for (int t = 0; t < 2; ++t)
        for (int c = 0; c < 4; ++c) {
            const std::int32_t v = f.kit[t][c];
            w.u8(v < 0 ? 0 : 1);
            w.u8(static_cast<std::uint8_t>((v >> 16) & 0xff));
            w.u8(static_cast<std::uint8_t>((v >> 8) & 0xff));
            w.u8(static_cast<std::uint8_t>(v & 0xff));
        }
    return std::move(w.out);
}

std::optional<TeamsFrame> decodeTeams(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    TeamsFrame f;
    for (std::string* n : {&f.home, &f.away}) {
        const std::uint8_t len = r.u8();
        for (std::uint8_t k = 0; k < len && r.ok; ++k) n->push_back(static_cast<char>(r.u8()));
    }
    if (!r.ok) return std::nullopt;
    // Kits are optional trailing bytes (G4.31).
    if (r.remaining() >= 32) {
        for (int t = 0; t < 2; ++t)
            for (int c = 0; c < 4; ++c) {
                const std::uint8_t on = r.u8(), rr = r.u8(), gg = r.u8(), bb = r.u8();
                f.kit[t][c] = on ? (rr << 16) | (gg << 8) | bb : -1;
            }
    }
    return f;
}

// ── CONCEPT_LEGEND (2.2) ────────────────────────────────────────────────

Bytes encodeConceptLegend(const ConceptLegendFrame& f) {
    Writer w;
    const std::size_t n = f.entries.size() > 255 ? 255 : f.entries.size();
    w.u8(static_cast<std::uint8_t>(n));
    auto str = [&](const std::string& t) {
        const std::size_t len = t.size() > 255 ? 255 : t.size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i) w.u8(static_cast<std::uint8_t>(t[i]));
    };
    for (std::size_t i = 0; i < n; ++i) {
        w.u8(f.entries[i].id);
        str(f.entries[i].name);
        str(f.entries[i].title);
    }
    return std::move(w.out);
}

std::optional<ConceptLegendFrame> decodeConceptLegend(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    ConceptLegendFrame f;
    auto str = [&]() {
        std::string t;
        const std::uint8_t len = r.u8();
        for (std::uint8_t i = 0; i < len && r.ok; ++i) t.push_back(static_cast<char>(r.u8()));
        return t;
    };
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        ConceptLegendFrame::Entry e;
        e.id = r.u8();
        e.name = str();
        e.title = str();
        f.entries.push_back(std::move(e));
    }
    if (!r.ok) return std::nullopt;
    return f;
}

// ── BRAIN / BRAIN_WATCH (1.7, G4.41) ────────────────────────────────────

Bytes encodeBrain(const BrainFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const BrainEntry& e : f.slots) {
        w.u8(e.why);
        w.u16(static_cast<std::uint16_t>(e.target_dm_x));
        w.u16(static_cast<std::uint16_t>(e.target_dm_y));
        w.u8(e.other);
        w.u8(e.concept_id);
    }
    return std::move(w.out);
}

std::optional<BrainFrame> decodeBrain(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    BrainFrame f;
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        BrainEntry e;
        e.why = r.u8();
        e.target_dm_x = static_cast<std::int16_t>(r.u16());
        e.target_dm_y = static_cast<std::int16_t>(r.u16());
        e.other = r.u8();
        e.concept_id = r.u8();
        f.slots.push_back(e);
    }
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeBrainWatch(const BrainWatchFrame& f) {
    Writer w;
    w.u8(f.on);
    return std::move(w.out);
}

std::optional<BrainWatchFrame> decodeBrainWatch(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    BrainWatchFrame f;
    f.on = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeTeamList(const TeamListFrame& f) {
    Writer w;
    const std::size_t n = f.names.size() > 255 ? 255 : f.names.size();
    w.u8(static_cast<std::uint8_t>(n));
    for (std::size_t k = 0; k < n; ++k) {
        const std::string& s = f.names[k];
        const std::size_t len = s.size() > 60 ? 60 : s.size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i) w.u8(static_cast<std::uint8_t>(s[i]));
    }
    return std::move(w.out);
}

std::optional<TeamListFrame> decodeTeamList(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    TeamListFrame f;
    const std::uint8_t n = r.u8();
    for (std::uint8_t k = 0; k < n && r.ok; ++k) {
        std::string s;
        const std::uint8_t len = r.u8();
        for (std::uint8_t i = 0; i < len && r.ok; ++i) s.push_back(static_cast<char>(r.u8()));
        f.names.push_back(std::move(s));
    }
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeSpeed(const SpeedFrame& f) {
    Writer w;
    w.u16(f.pct);
    return std::move(w.out);
}

std::optional<SpeedFrame> decodeSpeed(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    SpeedFrame f;
    f.pct = r.u16();
    if (!r.ok) return std::nullopt;
    return f;
}

}  // namespace fh::game::net
