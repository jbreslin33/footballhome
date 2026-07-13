// footballhome sim — end-to-end match-lifecycle persistence assertion
//
// Closes §16.5 exit criterion "Every match played end-to-end has:
//   (a) a sim_matches row with ended_at set,
//   (b) sim_match_inputs rows for every accepted input,
//   (c) sim_match_events rows for MatchStart + all Connect/Disconnect/
//       SlotClaim/SlotRelease + MatchEnd with canonical snapshot hash,
//   (d) sim_matches.result populated with the same hash."
//
// The prior state was `[~]` — the wiring existed but no automated test
// asserted the full row-set. This test mirrors sim/src/main.cpp's
// lifecycle exactly against InMemoryPgClient (which implements the same
// IPgClient contract as PgClient) and asserts every claim above.
//
// Why not spin up real Postgres? The row-set claim is a wiring claim —
// which code path pushes which row to which table via IPgClient. That
// wiring is identical whether the concrete IPgClient is libpqxx-backed
// or in-memory. Every method on the interface has a paired test in
// test_in_memory_pg_client.cpp that asserts semantic equivalence with
// the DB. Bringing a real Postgres into this test would only test
// libpqxx, which is already covered by test_pg_client.cpp against a
// live DB in the container build.
//
// Socket / JWT / frame helpers are duplicated from test_sim_server.cpp
// on purpose — the codebase convention is to keep each test self-
// contained so removing one doesn't break another (see comment at top
// of test_sim_server.cpp).

#include "auth/JwtVerifier.hpp"
#include "match/CanonicalHash.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "net/BinaryV1Serializer.hpp"
#include "net/InputFrame.hpp"
#include "net/LeCodec.hpp"
#include "net/WebSocketFrame.hpp"
#include "net/WebSocketTransport.hpp"
#include "net/WireFormat.hpp"
#include "persistence/EventLog.hpp"
#include "persistence/EventTypes.hpp"
#include "persistence/IPgClient.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "persistence/InputLog.hpp"
#include "persistence/ProfileStore.hpp"
#include "physics/StubPhysics.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "server/SimServer.hpp"
#include "test_harness.hpp"

#include <openssl/hmac.h>

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>

#include <array>
#include <bit>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <memory>
#include <span>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

using fh::sim::MatchId;
using fh::sim::auth::JwtVerifier;
using fh::sim::match::canonicalMatchHash;
using fh::sim::match::hashToBytesBE;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::net::BinaryV1Serializer;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kHelloAckFrameBytes;
using fh::sim::net::kInputFlagWantsSprint;
using fh::sim::net::kInputFrameBytes;
using fh::sim::net::kInputPayloadBytes;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::ws::Opcode;
using fh::sim::net::ws::WebSocketTransport;
using fh::sim::persistence::EventLog;
using fh::sim::persistence::EventRow;
using fh::sim::persistence::EventType;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::InputLog;
using fh::sim::persistence::InputRow;
using fh::sim::persistence::MatchRow;
using fh::sim::persistence::ProfileStore;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::EmptyPitchScenario;
using fh::sim::server::SimServer;

// ---------------------------------------------------------------------------
// JWT minter (identical to test_sim_server.cpp — kept standalone so
// removing that test doesn't break this one).
// ---------------------------------------------------------------------------
namespace {

constexpr char kB64UrlAlpha[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

std::string b64url(std::string_view in) {
    std::string out;
    out.reserve(((in.size() + 2) / 3) * 4);
    std::uint32_t buf = 0;
    unsigned bits = 0;
    for (unsigned char c : in) {
        buf = (buf << 8) | c;
        bits += 8;
        while (bits >= 6) {
            bits -= 6;
            out.push_back(kB64UrlAlpha[(buf >> bits) & 0x3Fu]);
        }
    }
    if (bits > 0) {
        out.push_back(kB64UrlAlpha[(buf << (6 - bits)) & 0x3Fu]);
    }
    return out;
}

std::string hmacSha256(std::string_view key, std::string_view data) {
    std::array<unsigned char, EVP_MAX_MD_SIZE> out{};
    unsigned int out_len = 0;
    HMAC(EVP_sha256(),
         key.data(), static_cast<int>(key.size()),
         reinterpret_cast<const unsigned char*>(data.data()), data.size(),
         out.data(), &out_len);
    return std::string(reinterpret_cast<const char*>(out.data()), out_len);
}

std::string mintJwt(std::int64_t person_id, std::int64_t exp,
                    std::string_view secret) {
    const std::string header  = R"({"alg":"HS256","typ":"JWT"})";
    const std::string payload =
        std::string("{\"person_id\":") + std::to_string(person_id)
        + ",\"iat\":100,\"exp\":" + std::to_string(exp) + "}";
    const std::string h = b64url(header);
    const std::string p = b64url(payload);
    const std::string s = b64url(hmacSha256(secret, h + "." + p));
    return h + "." + p + "." + s;
}

constexpr std::string_view kSecret = "super-secret-shared-with-backend-32bytes!";

std::unique_ptr<JwtVerifier> makeVerifier() {
    return std::make_unique<JwtVerifier>(
        std::string(kSecret),
        []() -> std::int64_t { return 1000; });
}

// ---------------------------------------------------------------------------
// Socket / WebSocket helpers (same-shape as test_sim_server.cpp).
// ---------------------------------------------------------------------------
int connectLoopback(std::uint16_t port) {
    const int fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) { return -1; }
    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);
    ::inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
    if (::connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
        ::close(fd);
        return -1;
    }
    return fd;
}

bool sendAll(int fd, std::string_view bytes) {
    std::size_t off = 0;
    while (off < bytes.size()) {
        const ssize_t w = ::send(fd, bytes.data() + off, bytes.size() - off,
                                 MSG_NOSIGNAL);
        if (w < 0) {
            if (errno == EINTR) { continue; }
            return false;
        }
        off += static_cast<std::size_t>(w);
    }
    return true;
}

void driveServer(SimServer& srv, int timeout_ms) {
    const auto deadline =
        std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);
    for (;;) {
        srv.pollTransport(5);
        if (std::chrono::steady_clock::now() >= deadline) { break; }
    }
}

std::vector<std::uint8_t> pumpUntil(SimServer& srv, int fd,
                                    std::size_t min_bytes, int timeout_ms) {
    std::vector<std::uint8_t> out;
    const auto deadline =
        std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);
    std::uint8_t buf[4096];
    bool eof = false;
    for (;;) {
        srv.pollTransport(5);
        pollfd pfd{fd, POLLIN, 0};
        const int r = ::poll(&pfd, 1, 5);
        if (r > 0 && (pfd.revents & (POLLIN | POLLHUP))) {
            for (;;) {
                const ssize_t n = ::recv(fd, buf, sizeof(buf), MSG_DONTWAIT);
                if (n > 0) {
                    out.insert(out.end(), buf, buf + n);
                    continue;
                }
                if (n == 0) { eof = true; break; }
                if (errno == EAGAIN || errno == EWOULDBLOCK) { break; }
                eof = true;
                break;
            }
        }
        if (out.size() >= min_bytes && !(r > 0 && (pfd.revents & POLLIN))) {
            break;
        }
        if (eof) { break; }
        if (std::chrono::steady_clock::now() >= deadline) { break; }
    }
    return out;
}

std::vector<std::uint8_t> maskedClientFrame(Opcode op,
                                            const std::vector<std::uint8_t>& payload,
                                            std::uint32_t mask_key = 0xA5B4C3D2u)
{
    std::vector<std::uint8_t> out;
    const std::size_t n = payload.size();
    out.push_back(static_cast<std::uint8_t>(0x80u | (static_cast<std::uint8_t>(op) & 0x0Fu)));
    if (n <= 125) {
        out.push_back(static_cast<std::uint8_t>(0x80u | static_cast<std::uint8_t>(n)));
    } else if (n <= 0xFFFFu) {
        out.push_back(static_cast<std::uint8_t>(0x80u | 126u));
        out.push_back(static_cast<std::uint8_t>((n >> 8) & 0xFFu));
        out.push_back(static_cast<std::uint8_t>(n & 0xFFu));
    } else {
        out.push_back(static_cast<std::uint8_t>(0x80u | 127u));
        for (int i = 7; i >= 0; --i) {
            out.push_back(static_cast<std::uint8_t>((n >> (i * 8)) & 0xFFu));
        }
    }
    const std::uint8_t k[4] = {
        static_cast<std::uint8_t>((mask_key >> 24) & 0xFFu),
        static_cast<std::uint8_t>((mask_key >> 16) & 0xFFu),
        static_cast<std::uint8_t>((mask_key >>  8) & 0xFFu),
        static_cast<std::uint8_t>((mask_key      ) & 0xFFu),
    };
    for (int i = 0; i < 4; ++i) { out.push_back(k[i]); }
    for (std::size_t i = 0; i < n; ++i) {
        out.push_back(static_cast<std::uint8_t>(payload[i] ^ k[i & 3u]));
    }
    return out;
}

std::string handshakeRequest(std::string_view jwt) {
    std::string r;
    r.append("GET /sim HTTP/1.1\r\n");
    r.append("Host: 127.0.0.1\r\n");
    r.append("Upgrade: websocket\r\n");
    r.append("Connection: Upgrade\r\n");
    r.append("Sec-WebSocket-Version: 13\r\n");
    r.append("Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n");
    r.append("Sec-WebSocket-Protocol: fh-sim.v1.bearer.");
    r.append(jwt);
    r.append("\r\n\r\n");
    return r;
}

bool bytesContain(const std::vector<std::uint8_t>& haystack, std::string_view needle) {
    if (needle.empty() || haystack.size() < needle.size()) { return false; }
    for (std::size_t i = 0; i + needle.size() <= haystack.size(); ++i) {
        if (std::memcmp(haystack.data() + i, needle.data(), needle.size()) == 0) {
            return true;
        }
    }
    return false;
}

std::vector<std::uint8_t> buildInputFramePayload(std::uint32_t client_tick,
                                                 float dir_x, float dir_y,
                                                 std::uint8_t flags)
{
    std::vector<std::uint8_t> out(kInputFrameBytes);
    out[0] = kWireVersionV1;
    out[1] = static_cast<std::uint8_t>(MsgType::Input);
    out[2] = static_cast<std::uint8_t>(kInputPayloadBytes & 0xFFu);
    out[3] = static_cast<std::uint8_t>((kInputPayloadBytes >> 8) & 0xFFu);
    out[4] = static_cast<std::uint8_t>(client_tick & 0xFFu);
    out[5] = static_cast<std::uint8_t>((client_tick >> 8) & 0xFFu);
    out[6] = static_cast<std::uint8_t>((client_tick >> 16) & 0xFFu);
    out[7] = static_cast<std::uint8_t>((client_tick >> 24) & 0xFFu);
    const std::uint32_t dx = std::bit_cast<std::uint32_t>(dir_x);
    const std::uint32_t dy = std::bit_cast<std::uint32_t>(dir_y);
    out[8]  = static_cast<std::uint8_t>(dx & 0xFFu);
    out[9]  = static_cast<std::uint8_t>((dx >> 8) & 0xFFu);
    out[10] = static_cast<std::uint8_t>((dx >> 16) & 0xFFu);
    out[11] = static_cast<std::uint8_t>((dx >> 24) & 0xFFu);
    out[12] = static_cast<std::uint8_t>(dy & 0xFFu);
    out[13] = static_cast<std::uint8_t>((dy >> 8) & 0xFFu);
    out[14] = static_cast<std::uint8_t>((dy >> 16) & 0xFFu);
    out[15] = static_cast<std::uint8_t>((dy >> 24) & 0xFFu);
    out[16] = flags;
    out[17] = out[18] = out[19] = 0;
    return out;
}

std::size_t findHeaderEnd(const std::vector<std::uint8_t>& bytes) {
    for (std::size_t i = 3; i < bytes.size(); ++i) {
        if (bytes[i - 3] == '\r' && bytes[i - 2] == '\n'
            && bytes[i - 1] == '\r' && bytes[i] == '\n') {
            return i + 1;
        }
    }
    return bytes.size();
}

// Count events of a given type for the target match.
std::size_t countEvents(const std::vector<EventRow>& events,
                        MatchId id,
                        EventType type)
{
    std::size_t n = 0;
    for (const auto& e : events) {
        if (e.match_id == id && e.event_type == type) { ++n; }
    }
    return n;
}

} // namespace

// ===========================================================================
// The lifecycle test
// ===========================================================================
//
// Mirrors sim/src/main.cpp step-for-step:
//   1. upsertMatch(match_id, scenario_id=0, seed, tick_hz=20)
//   2. insertEvent(MatchStart, tick=0)
//   3. build SimServer with InputLog + EventLog wired to db.insertInputBatch
//      / db.insertEventBatch
//   4. real client: handshake (SlotClaim + ClientConnect fire), send INPUT
//      (input_log.push fires), one tick, close socket
//      (SlotRelease + ClientDisconnect fire)
//   5. input_log.stop() + event_log.stop() (drains to db)
//   6. insertEvent(MatchEnd, payload = canonical hash bytes)
//   7. updateMatchEnded(match_id, hash_bytes)
// Then asserts the full DB row-set is coherent.
// ---------------------------------------------------------------------------
FH_TEST(scripted_match_writes_full_lifecycle_row_set) {
    // --- Boot the persistence layer + logs ---------------------------
    InMemoryPgClient db;

    constexpr MatchId kMatchId  = MatchId{42};
    constexpr std::uint64_t kSeed = 7;

    MatchRow mrow;
    mrow.id             = kMatchId;
    mrow.scenario_id    = 0;
    mrow.seed           = kSeed;
    mrow.tick_hz        = 20;
    mrow.server_version = "test-lifecycle";
    db.upsertMatch(mrow);

    EventRow start_ev;
    start_ev.match_id   = kMatchId;
    start_ev.tick_num   = 0;
    start_ev.event_type = EventType::MatchStart;
    db.insertEvent(start_ev);

    ProfileStore profile_store(db);

    // Async logs — sinks call the same insertBatch entry points that
    // main.cpp uses in production.
    InputLog input_log(
        [&db](std::span<const InputRow> rows) { db.insertInputBatch(rows); });
    EventLog event_log(
        [&db](std::span<const EventRow> rows) { db.insertEventBatch(rows); });

    // --- Build the SimServer + transport -----------------------------
    auto verifier = makeVerifier();

    WebSocketTransport::Config tx_cfg;
    tx_cfg.bind_address = "127.0.0.1";
    tx_cfg.port         = 0;
    auto transport = std::make_unique<WebSocketTransport>(tx_cfg, verifier.get());
    WebSocketTransport* transport_raw = transport.get();
    FH_EXPECT(transport_raw->start());
    const std::uint16_t port = transport_raw->boundPort();

    MatchConfig mcfg;
    mcfg.id             = kMatchId;
    mcfg.seed           = kSeed;
    mcfg.server_version = "test-lifecycle";
    mcfg.physics  = std::make_unique<StubPhysics>();
    mcfg.scenario = std::make_unique<EmptyPitchScenario>();
    mcfg.clock    = std::make_unique<RealtimeClock>(20);
    auto match_ = std::make_unique<Match>(std::move(mcfg));

    SimServer::Config scfg;
    scfg.tick_hz  = 20;
    scfg.match_id = kMatchId;

    SimServer server(scfg,
                     std::move(transport),
                     std::make_unique<BinaryV1Serializer>(),
                     std::move(match_),
                     &profile_store,
                     &input_log,
                     &event_log);

    // --- Client connect (fires ClientConnect + SlotClaim) ------------
    const int cfd = connectLoopback(port);
    FH_EXPECT(cfd >= 0);

    const std::string jwt = mintJwt(/*person_id=*/501, /*exp=*/2000, kSecret);
    FH_EXPECT(sendAll(cfd, handshakeRequest(jwt)));
    const auto hs_bytes = pumpUntil(server, cfd,
                                    150 + 2 + kHelloAckFrameBytes, 1500);
    FH_EXPECT(bytesContain(hs_bytes, "101 Switching Protocols"));
    const std::size_t hdr_end = findHeaderEnd(hs_bytes);
    FH_EXPECT(hdr_end < hs_bytes.size());
    FH_EXPECT_EQ(server.activeClientCount(), 1u);

    // --- Client sends INPUT (fires input_log.push) -------------------
    const auto input_payload = buildInputFramePayload(
        /*client_tick=*/1, /*dir_x=*/1.0F, /*dir_y=*/0.0F,
        static_cast<std::uint8_t>(kInputFlagWantsSprint));
    const auto ws_frame = maskedClientFrame(Opcode::Binary, input_payload);
    FH_EXPECT(sendAll(cfd, std::string_view(
        reinterpret_cast<const char*>(ws_frame.data()), ws_frame.size())));

    driveServer(server, 150);
    server.tickOnceForTest();

    // --- Client disconnect (fires SlotRelease + ClientDisconnect) ----
    ::close(cfd);
    driveServer(server, 300);
    FH_EXPECT_EQ(server.activeClientCount(), 0u);

    // --- Shutdown log drains BEFORE writing MatchEnd (main.cpp order)
    input_log.stop();
    event_log.stop();
    FH_EXPECT_EQ(input_log.dropped(), 0u);
    FH_EXPECT_EQ(event_log.dropped(), 0u);

    // --- Write MatchEnd + updateMatchEnded ---------------------------
    const std::uint64_t hash_u64 = canonicalMatchHash(server.match());
    const auto hash_bytes = hashToBytesBE(hash_u64);
    std::vector<std::byte> payload(hash_bytes.begin(), hash_bytes.end());

    EventRow end_ev;
    end_ev.match_id   = kMatchId;
    end_ev.tick_num   = server.match().tick_num();
    end_ev.event_type = EventType::MatchEnd;
    end_ev.payload    = std::move(payload);
    db.insertEvent(end_ev);

    db.updateMatchEnded(kMatchId, std::span<const std::byte>{hash_bytes});

    // =================================================================
    // Assertions — the full §16.5 row-set claim.
    // =================================================================

    // (a) sim_matches row exists with ended_at set + result populated.
    const auto row = db.getMatch(kMatchId);
    FH_EXPECT(row.has_value());
    FH_EXPECT_EQ(row->id, kMatchId);
    FH_EXPECT_EQ(row->seed, kSeed);
    FH_EXPECT(db.matchEnded(kMatchId));

    const auto result_bytes = db.matchResult(kMatchId);
    FH_EXPECT(result_bytes.has_value());
    FH_EXPECT_EQ(result_bytes->size(), 8u);
    for (std::size_t i = 0; i < 8; ++i) {
        FH_EXPECT_EQ((*result_bytes)[i], hash_bytes[i]);
    }

    // (b) at least one sim_match_inputs row (the sprint INPUT we sent).
    const auto inputs = db.inputsForMatch(kMatchId);
    FH_EXPECT_GT(inputs.size(), 0u);
    for (const auto& in : inputs) {
        FH_EXPECT_EQ(in.match_id, kMatchId);
        FH_EXPECT_EQ(in.payload.size(), kInputFrameBytes);
    }

    // (c) sim_match_events contains the full lifecycle set.
    const auto events = db.eventsForMatch(kMatchId);
    FH_EXPECT_EQ(countEvents(events, kMatchId, EventType::MatchStart),      1u);
    FH_EXPECT_GT(countEvents(events, kMatchId, EventType::ClientConnect),   0u);
    FH_EXPECT_GT(countEvents(events, kMatchId, EventType::SlotClaim),       0u);
    FH_EXPECT_GT(countEvents(events, kMatchId, EventType::SlotRelease),     0u);
    FH_EXPECT_GT(countEvents(events, kMatchId, EventType::ClientDisconnect), 0u);
    FH_EXPECT_EQ(countEvents(events, kMatchId, EventType::MatchEnd),        1u);

    // MatchEnd must carry the same 8-byte hash we wrote via updateMatchEnded.
    bool saw_hashed_end = false;
    for (const auto& e : events) {
        if (e.event_type != EventType::MatchEnd) { continue; }
        FH_EXPECT(e.payload.has_value());
        FH_EXPECT_EQ(e.payload->size(), 8u);
        bool eq = true;
        for (std::size_t i = 0; i < 8; ++i) {
            if ((*e.payload)[i] != hash_bytes[i]) { eq = false; break; }
        }
        FH_EXPECT(eq);
        saw_hashed_end = true;
    }
    FH_EXPECT(saw_hashed_end);

    // MatchStart must precede every other event (event ordering claim
    // in main.cpp's comment "any ORDER BY tick_num, event_type observer
    // sees a coherent 'row exists, then it began'").
    FH_EXPECT_EQ(events.front().event_type, EventType::MatchStart);
    FH_EXPECT_EQ(events.back().event_type,  EventType::MatchEnd);
}

FH_TEST_MAIN()
