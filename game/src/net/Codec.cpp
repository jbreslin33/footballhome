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
    // 1.3 tail: level bands.
    w.u8(f.level_home);
    w.u8(f.level_away);
    // 1.8 tail: facing per player, i8 x | i8 y (unit ×127).
    for (const PlayerSnap& p : f.players) {
        w.u8(static_cast<std::uint8_t>(p.face_x));
        w.u8(static_cast<std::uint8_t>(p.face_y));
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
    if (r.at + 2 <= payload.size()) {  // 1.3 tail
        f.level_home = r.u8();
        f.level_away = r.u8();
    }
    if (r.at + 2 * f.players.size() <= payload.size()) {  // 1.8 tail: facing
        for (PlayerSnap& p : f.players) {
            p.face_x = static_cast<std::int8_t>(r.u8());
            p.face_y = static_cast<std::int8_t>(r.u8());
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

Bytes encodeMatchSettings(const MatchSettingsFrame& f) {
    Writer w;
    w.u8(f.level_home);
    w.u8(f.level_away);
    return std::move(w.out);
}

std::optional<MatchSettingsFrame> decodeMatchSettings(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    MatchSettingsFrame f;
    f.level_home = r.u8();
    f.level_away = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodePlayerSettings(const PlayerSettingsFrame& f) {
    Writer w;
    w.u8(f.slot);
    w.u8(static_cast<std::uint8_t>(f.ratings.size()));
    for (std::uint8_t v : f.ratings) w.u8(v);
    return std::move(w.out);
}

std::optional<PlayerSettingsFrame> decodePlayerSettings(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    PlayerSettingsFrame f;
    f.slot = r.u8();
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) f.ratings.push_back(r.u8());
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodeRoster(const RosterFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const RosterEntry& e : f.slots) {
        w.u8(static_cast<std::uint8_t>(e.ratings.size()));
        for (std::uint8_t v : e.ratings) w.u8(v);
        const std::size_t len = e.name.size() > 40 ? 40 : e.name.size();
        w.u8(static_cast<std::uint8_t>(len));
        for (std::size_t i = 0; i < len; ++i)
            w.u8(static_cast<std::uint8_t>(e.name[i]));
    }
    return std::move(w.out);
}

std::optional<RosterFrame> decodeRoster(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    RosterFrame f;
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        RosterEntry e;
        const std::uint8_t rc = r.u8();
        for (std::uint8_t k = 0; k < rc && r.ok; ++k)
            e.ratings.push_back(r.u8());
        const std::uint8_t len = r.u8();
        for (std::uint8_t k = 0; k < len; ++k)
            e.name.push_back(static_cast<char>(r.u8()));
        f.slots.push_back(std::move(e));
    }
    if (!r.ok) return std::nullopt;
    return f;
}

Bytes encodePresets(const PresetsFrame& f) {
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

std::optional<PresetsFrame> decodePresets(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    PresetsFrame f;
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

Bytes encodeApplyPreset(const ApplyPresetFrame& f) {
    Writer w;
    w.u8(f.team);
    w.u8(f.preset_id);
    return std::move(w.out);
}

std::optional<ApplyPresetFrame> decodeApplyPreset(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    ApplyPresetFrame f;
    f.team = r.u8();
    f.preset_id = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

// ── MODEL_DEMANDS / SET_DEMAND (1.14, G4.74) ────────────────────────────

Bytes encodeModelDemands(const ModelDemandsFrame& f) {
    Writer w;
    w.u8(f.team);
    w.u8(f.model);
    w.u8(static_cast<std::uint8_t>(f.demand.size()));
    for (std::size_t i = 0; i < f.demand.size(); ++i) {
        w.u8(f.demand[i]);
        w.u8(i < f.source.size() ? f.source[i] : 0);
    }
    w.u8(f.parent);
    for (std::size_t i = 0; i < f.demand.size(); ++i)
        w.u8(i < f.origin.size() ? f.origin[i] : 255);
    for (std::size_t i = 0; i < f.demand.size(); ++i)
        w.u8(i < f.parent_demand.size() ? f.parent_demand[i] : 255);
    return std::move(w.out);
}

std::optional<ModelDemandsFrame> decodeModelDemands(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    ModelDemandsFrame f;
    f.team = r.u8();
    f.model = r.u8();
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) {
        f.demand.push_back(r.u8());
        f.source.push_back(r.u8());
    }
    if (!r.ok) return std::nullopt;
    if (r.remaining() > 0) {   // 1.15 trailer
        f.parent = r.u8();
        for (std::uint8_t i = 0; i < n && r.ok; ++i) f.origin.push_back(r.u8());
        if (!r.ok) return std::nullopt;
    }
    if (r.remaining() > 0) {   // G4.77 trailer
        for (std::uint8_t i = 0; i < n && r.ok; ++i) f.parent_demand.push_back(r.u8());
        if (!r.ok) return std::nullopt;
    }
    return f;
}

Bytes encodeSetDemand(const SetDemandFrame& f) {
    Writer w;
    w.u8(f.team);
    w.u8(f.concept_id);
    w.u8(f.demand);
    return std::move(w.out);
}

std::optional<SetDemandFrame> decodeSetDemand(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    SetDemandFrame f;
    f.team = r.u8();
    f.concept_id = r.u8();
    f.demand = r.u8();
    if (!r.ok) return std::nullopt;
    return f;
}

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

Bytes encodeModelParams(const ModelParamsFrame& f) {
    Writer w;
    w.u8(f.team);
    w.u16(static_cast<std::uint16_t>(f.entries.size()));
    for (const auto& e : f.entries) {
        putStr(w, e.key);
        putI32(w, e.milli);
        w.u8(e.source);
        w.u8(e.origin);
        putStr(w, e.unit);
    }
    for (std::size_t i = 0; i < f.entries.size(); ++i)
        putI32(w, i < f.parent_milli.size() ? f.parent_milli[i] : ModelParamsFrame::kNoParent);
    return std::move(w.out);
}

std::optional<ModelParamsFrame> decodeModelParams(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    ModelParamsFrame f;
    f.team = r.u8();
    const std::uint16_t n = r.u16();
    for (std::uint16_t i = 0; i < n && r.ok; ++i) {
        ModelParamEntry e;
        e.key = getStr(r);
        e.milli = getI32(r);
        e.source = r.u8();
        e.origin = r.u8();
        e.unit = getStr(r);
        f.entries.push_back(std::move(e));
    }
    if (!r.ok) return std::nullopt;
    if (r.remaining() > 0) {   // G4.77 trailer
        for (std::uint16_t i = 0; i < n && r.ok; ++i) f.parent_milli.push_back(getI32(r));
        if (!r.ok) return std::nullopt;
    }
    return f;
}

Bytes encodeSetParam(const SetParamFrame& f) {
    Writer w;
    w.u8(f.team);
    w.u8(f.op);
    putI32(w, f.milli);
    putStr(w, f.key);
    return std::move(w.out);
}

std::optional<SetParamFrame> decodeSetParam(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    SetParamFrame f;
    f.team = r.u8();
    f.op = r.u8();
    f.milli = getI32(r);
    f.key = getStr(r);
    if (!r.ok) return std::nullopt;
    return f;
}

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

Bytes encodePlayerAttributes(const PlayerAttributesFrame& f) {
    Writer w;
    w.u8(f.slot);
    w.u8(static_cast<std::uint8_t>(f.ratings.size()));
    for (std::uint8_t v : f.ratings) w.u8(v);
    return std::move(w.out);
}

std::optional<PlayerAttributesFrame> decodePlayerAttributes(const Bytes& payload) {
    Reader r{payload.data(), payload.size()};
    PlayerAttributesFrame f;
    f.slot = r.u8();
    const std::uint8_t n = r.u8();
    for (std::uint8_t i = 0; i < n && r.ok; ++i) f.ratings.push_back(r.u8());
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

// ── BRAIN / BRAIN_WATCH (1.7, G4.41) ────────────────────────────────────

Bytes encodeBrain(const BrainFrame& f) {
    Writer w;
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const BrainEntry& e : f.slots) {
        w.u8(e.why);
        w.u16(static_cast<std::uint16_t>(e.target_dm_x));
        w.u16(static_cast<std::uint16_t>(e.target_dm_y));
        w.u8(e.other);
        w.u8(e.rung);
    }
    // 1.11: the vision block trails the entries (old clients ignore it).
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const BrainEntry& e : f.slots) {
        w.u8(e.look_ds);
        w.u8(e.unseen);
    }
    // 1.12: the call block trails the vision block.
    w.u8(static_cast<std::uint8_t>(f.slots.size()));
    for (const BrainEntry& e : f.slots) {
        w.u8(e.call);
        w.u8(e.call_to);
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
        e.rung = r.u8();
        f.slots.push_back(e);
    }
    if (!r.ok) return std::nullopt;
    if (r.remaining() > 0) {   // 1.11 vision block
        const std::uint8_t m = r.u8();
        for (std::uint8_t i = 0; i < m && r.ok; ++i) {
            const std::uint8_t look = r.u8(), unseen = r.u8();
            if (r.ok && i < f.slots.size()) { f.slots[i].look_ds = look; f.slots[i].unseen = unseen; }
        }
        if (!r.ok) return std::nullopt;
    }
    if (r.remaining() > 0) {   // 1.12 call block
        const std::uint8_t m = r.u8();
        for (std::uint8_t i = 0; i < m && r.ok; ++i) {
            const std::uint8_t call = r.u8(), to = r.u8();
            if (r.ok && i < f.slots.size()) { f.slots[i].call = call; f.slots[i].call_to = to; }
        }
        if (!r.ok) return std::nullopt;
    }
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
