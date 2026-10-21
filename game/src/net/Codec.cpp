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

}  // namespace fh::game::net
