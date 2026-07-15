// footballhome sim - SimServer integration test
//
// End-to-end: real WebSocketTransport on loopback + real Match with
// StubPhysics + EmptyPitchScenario + real BinaryV1Serializer, wrapped
// by SimServer. A test client connects with a valid JWT, verifies:
//   * HELLO_ACK arrives with the assigned slot
//   * INPUT is applied (next snapshot reflects the intent by way of
//     match state)
//   * SNAPSHOTs are broadcast on tickOnceForTest()
//   * disconnect releases the slot

#include "auth/JwtVerifier.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "net/BinaryV1Serializer.hpp"
#include "net/InputFrame.hpp"
#include "net/LeCodec.hpp"
#include "net/ScenarioMetaFrame.hpp"
#include "net/WebSocketFrame.hpp"
#include "net/WebSocketTransport.hpp"
#include "net/WireFormat.hpp"
#include "persistence/InMemoryPgClient.hpp"
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

using fh::sim::auth::JwtClaims;
using fh::sim::auth::JwtVerifier;
using fh::sim::ClientId;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::net::BinaryV1Serializer;
using fh::sim::net::decodeScenarioMetaFrame;
using fh::sim::net::kFrameHeaderBytes;
using fh::sim::net::kHelloAckFrameBytes;
using fh::sim::net::kHelloAckPayloadBytes;
using fh::sim::net::kInputFlagWantsSprint;
using fh::sim::net::kInputFrameBytes;
using fh::sim::net::kInputPayloadBytes;
using fh::sim::net::kScenarioModeAdvisory;
using fh::sim::net::kWireCapScenarioMeta;
using fh::sim::net::kWireCapSnapshotBallTrailer;
using fh::sim::net::kWireVersionV1;
using fh::sim::net::MsgType;
using fh::sim::net::read_u16_le;
using fh::sim::net::read_u32_le;
using fh::sim::net::read_u64_le;
using fh::sim::net::ws::Opcode;
using fh::sim::net::ws::WebSocketTransport;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::ProfileStore;
using fh::sim::physics::StubPhysics;
using fh::sim::scenario::EmptyPitchScenario;
using fh::sim::server::SimServer;

// ---------------------------------------------------------------------------
// Test-only JWT minter (kept standalone so removing test_jwt_verifier or
// test_websocket_transport doesn't break this one).
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
// Socket helpers (duplicated from test_websocket_transport — same rationale)
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

// Interleaved: drive server polling while waiting for `min_bytes` on `fd`.
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

// After the handshake response, everything the server sends is a series
// of WebSocket binary frames. Server frames are FIN|Binary (0x82) with
// an unmasked payload. Extract every complete binary payload starting
// from `search_start`.
std::vector<std::vector<std::uint8_t>> extractBinaryPayloads(
    const std::vector<std::uint8_t>& bytes, std::size_t search_start)
{
    std::vector<std::vector<std::uint8_t>> frames;
    std::size_t i = search_start;
    while (i + 2 <= bytes.size()) {
        const std::uint8_t b0 = bytes[i];
        const std::uint8_t b1 = bytes[i + 1];
        // Skip non-binary frames (Pong, Close, etc.).
        const bool is_binary  = (b0 & 0x0Fu) == static_cast<std::uint8_t>(Opcode::Binary);
        const bool masked     = (b1 & 0x80u) != 0;
        if (masked) { return frames; }   // server frames are never masked
        std::size_t hdr = 2;
        std::size_t plen = b1 & 0x7Fu;
        if (plen == 126u) {
            if (i + 4 > bytes.size()) { break; }
            plen = (static_cast<std::size_t>(bytes[i + 2]) << 8)
                 |  static_cast<std::size_t>(bytes[i + 3]);
            hdr = 4;
        } else if (plen == 127u) {
            if (i + 10 > bytes.size()) { break; }
            plen = 0;
            for (int k = 0; k < 8; ++k) {
                plen = (plen << 8) | static_cast<std::size_t>(bytes[i + 2 + k]);
            }
            hdr = 10;
        }
        if (i + hdr + plen > bytes.size()) { break; }
        if (is_binary) {
            frames.emplace_back(bytes.begin() + static_cast<std::ptrdiff_t>(i + hdr),
                                bytes.begin() + static_cast<std::ptrdiff_t>(i + hdr + plen));
        }
        i += hdr + plen;
    }
    return frames;
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
    // client_tick
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

// ---------------------------------------------------------------------------
// Fixture: builds a SimServer bound to loopback:0 and a matching test
// client socket. `handshake()` performs the upgrade and swallows the 101
// response bytes. Everything after that is server-to-client wire data.
// ---------------------------------------------------------------------------
struct Fixture {
    std::unique_ptr<JwtVerifier>       verifier;
    WebSocketTransport*                transport_raw{nullptr};
    std::unique_ptr<InMemoryPgClient>  db;
    std::unique_ptr<ProfileStore>      profile_store;
    std::unique_ptr<SimServer>         server;

    Fixture() {
        verifier = makeVerifier();

        WebSocketTransport::Config tx_cfg;
        tx_cfg.bind_address = "127.0.0.1";
        tx_cfg.port         = 0;
        auto transport = std::make_unique<WebSocketTransport>(tx_cfg, verifier.get());
        transport_raw = transport.get();
        const bool started = transport_raw->start();
        FH_EXPECT(started);

        MatchConfig mcfg;
        mcfg.id       = 42;
        mcfg.seed     = 7;
        mcfg.physics  = std::make_unique<StubPhysics>();
        mcfg.scenario = std::make_unique<EmptyPitchScenario>();
        mcfg.clock    = std::make_unique<RealtimeClock>(20);
        auto match_ = std::make_unique<Match>(std::move(mcfg));

        // In-memory persistence: ProfileStore::loadOrCreate will
        // materialize a default M0 profile on first-touch and upsert it
        // back — round-trippable within the fixture without touching
        // real Postgres.
        db            = std::make_unique<InMemoryPgClient>();
        profile_store = std::make_unique<ProfileStore>(*db);

        SimServer::Config scfg;
        scfg.tick_hz  = 20;
        scfg.match_id = 42;

        server = std::make_unique<SimServer>(
            scfg,
            std::move(transport),
            std::make_unique<BinaryV1Serializer>(),
            std::move(match_),
            profile_store.get());
    }

    std::uint16_t port() const noexcept { return transport_raw->boundPort(); }
};

// Perform the WebSocket upgrade and read at least `extra_bytes` beyond
// the end of the 101 response headers. Returns the entire byte stream
// received and the offset of the first post-header byte (start of the
// first WebSocket frame). All subsequent server data lives at
// `bytes[header_end..]` — pass that offset to extractBinaryPayloads.
struct HandshakeRead {
    std::vector<std::uint8_t> bytes;
    std::size_t               header_end{0};
};

HandshakeRead handshake(Fixture& fx, int cfd, std::int64_t person_id,
                        std::size_t extra_bytes = 0) {
    const std::string jwt = mintJwt(person_id, 2000, kSecret);
    FH_EXPECT(sendAll(cfd, handshakeRequest(jwt)));
    // 101 response headers run ~150 bytes; pull at least that plus the
    // requested tail so the caller can find the first WS frame.
    const auto bytes = pumpUntil(*fx.server, cfd, 150 + extra_bytes, 1500);
    FH_EXPECT(bytesContain(bytes, "101 Switching Protocols"));
    std::size_t hdr_end = bytes.size();
    for (std::size_t i = 3; i < bytes.size(); ++i) {
        if (bytes[i - 3] == '\r' && bytes[i - 2] == '\n'
            && bytes[i - 1] == '\r' && bytes[i] == '\n') {
            hdr_end = i + 1;
            break;
        }
    }
    return HandshakeRead{bytes, hdr_end};
}

} // namespace

// ===========================================================================
// Tests
// ===========================================================================

FH_TEST(hello_ack_sent_on_connect_with_slot_zero_indexed) {
    Fixture fx;
    const int cfd = connectLoopback(fx.port());
    FH_EXPECT(cfd >= 0);

    // Handshake response + HELLO_ACK arrive back-to-back; request enough
    // extra bytes to guarantee the ACK frame is captured too (2-byte WS
    // header + 18-byte payload = 20 bytes).
    auto hs = handshake(fx, cfd, /*person_id=*/101, /*extra_bytes=*/64);
    // Keep reading until we have at least one binary frame after headers.
    if (hs.bytes.size() < hs.header_end + 2 + kHelloAckFrameBytes) {
        const auto more = pumpUntil(*fx.server, cfd,
                                    hs.header_end + 2 + kHelloAckFrameBytes,
                                    1000);
        hs.bytes = more;
    }
    const auto frames = extractBinaryPayloads(hs.bytes, hs.header_end);
    FH_EXPECT(!frames.empty());
    const auto& ack = frames.front();
    FH_EXPECT_EQ(ack.size(), kHelloAckFrameBytes);
    FH_EXPECT_EQ(ack[0], kWireVersionV1);
    FH_EXPECT_EQ(ack[1], static_cast<std::uint8_t>(MsgType::HelloAck));
    FH_EXPECT_EQ(read_u16_le(ack.data() + 2), kHelloAckPayloadBytes);
    // Payload
    const std::uint64_t match_id = read_u64_le(ack.data() + kFrameHeaderBytes + 0);
    const std::uint16_t slot     = read_u16_le(ack.data() + kFrameHeaderBytes + 8);
    const std::uint32_t tick_hz  = read_u32_le(ack.data() + kFrameHeaderBytes + 10);
    FH_EXPECT_EQ(match_id, 42u);
    FH_EXPECT_EQ(tick_hz,  20u);
    // EmptyPitchScenario slot ids are 1..12; the first free one is slot 1.
    FH_EXPECT(slot >= 1u && slot <= 12u);

    FH_EXPECT_EQ(fx.server->activeClientCount(), 1u);
    // Verify the corresponding match slot is now human-owned.
    bool found_owned = false;
    for (const auto& s : fx.server->match().slots()) {
        if (s.slot_id == slot) {
            FH_EXPECT(s.owner.has_value());
            found_owned = true;
        }
    }
    FH_EXPECT(found_owned);

    ::close(cfd);
    driveServer(*fx.server, 200);
}

FH_TEST(two_clients_get_distinct_slots) {
    Fixture fx;
    const int c1 = connectLoopback(fx.port());
    FH_EXPECT(c1 >= 0);
    auto hs1 = handshake(fx, c1, 201, 64);
    if (hs1.bytes.size() < hs1.header_end + 2 + kHelloAckFrameBytes) {
        hs1.bytes = pumpUntil(*fx.server, c1,
                              hs1.header_end + 2 + kHelloAckFrameBytes, 1000);
    }
    const auto f1 = extractBinaryPayloads(hs1.bytes, hs1.header_end);
    FH_EXPECT(!f1.empty());
    const std::uint16_t slot1 = read_u16_le(f1.front().data() + kFrameHeaderBytes + 8);

    const int c2 = connectLoopback(fx.port());
    FH_EXPECT(c2 >= 0);
    auto hs2 = handshake(fx, c2, 202, 64);
    if (hs2.bytes.size() < hs2.header_end + 2 + kHelloAckFrameBytes) {
        hs2.bytes = pumpUntil(*fx.server, c2,
                              hs2.header_end + 2 + kHelloAckFrameBytes, 1000);
    }
    const auto f2 = extractBinaryPayloads(hs2.bytes, hs2.header_end);
    FH_EXPECT(!f2.empty());
    const std::uint16_t slot2 = read_u16_le(f2.front().data() + kFrameHeaderBytes + 8);

    FH_EXPECT(slot1 != slot2);
    FH_EXPECT_EQ(fx.server->activeClientCount(), 2u);

    ::close(c1);
    ::close(c2);
    driveServer(*fx.server, 200);
}

FH_TEST(input_message_is_applied_to_match) {
    Fixture fx;
    const int cfd = connectLoopback(fx.port());
    auto hs = handshake(fx, cfd, 301, 64);
    if (hs.bytes.size() < hs.header_end + 2 + kHelloAckFrameBytes) {
        hs.bytes = pumpUntil(*fx.server, cfd,
                             hs.header_end + 2 + kHelloAckFrameBytes, 1000);
    }
    const auto acks = extractBinaryPayloads(hs.bytes, hs.header_end);
    FH_EXPECT(!acks.empty());
    const std::uint16_t slot = read_u16_le(acks.front().data() + kFrameHeaderBytes + 8);

    // Send an INPUT frame requesting forward sprint.
    const auto input_payload = buildInputFramePayload(
        7, 1.0F, 0.0F,
        static_cast<std::uint8_t>(kInputFlagWantsSprint));
    const auto ws_frame = maskedClientFrame(Opcode::Binary, input_payload);
    FH_EXPECT(sendAll(cfd, std::string_view(
        reinterpret_cast<const char*>(ws_frame.data()), ws_frame.size())));

    // Let the transport deliver the message.
    driveServer(*fx.server, 100);

    // Tick and check the entity for that slot now has non-zero velocity.
    fx.server->tickOnceForTest();

    bool moved = false;
    for (const auto& e : fx.server->match().snapshot().entities) {
        if (e.state.slot_id == slot) {
            if (e.state.velocity.x != fh::sim::math::Fixed64::zero()
                || e.state.velocity.y != fh::sim::math::Fixed64::zero()) {
                moved = true;
            }
        }
    }
    FH_EXPECT(moved);

    ::close(cfd);
    driveServer(*fx.server, 200);
}

FH_TEST(snapshot_broadcast_delivers_bytes_to_client) {
    Fixture fx;
    const int cfd = connectLoopback(fx.port());
    auto hs = handshake(fx, cfd, 401, 64);
    // Drain HELLO_ACK
    (void)pumpUntil(*fx.server, cfd,
                    hs.header_end + 2 + kHelloAckFrameBytes, 1000);

    // Broadcast a snapshot manually.
    fx.server->tickOnceForTest();

    // 12-entity SNAPSHOT payload = 4+10+12*30 = 374 bytes; plus WS
    // extended-length header (4 bytes) → ~378 bytes on the wire.
    const auto bytes = pumpUntil(*fx.server, cfd, 380, 1500);
    const auto frames = extractBinaryPayloads(bytes, 0);
    // Look for a SNAPSHOT frame (there may be a leftover HELLO_ACK too).
    bool saw_snapshot = false;
    for (const auto& fr : frames) {
        if (fr.size() >= kFrameHeaderBytes
            && fr[0] == kWireVersionV1
            && fr[1] == static_cast<std::uint8_t>(MsgType::Snapshot)) {
            saw_snapshot = true;
        }
    }
    FH_EXPECT(saw_snapshot);

    ::close(cfd);
    driveServer(*fx.server, 200);
}

FH_TEST(client_disconnect_releases_slot) {
    Fixture fx;
    const int cfd = connectLoopback(fx.port());
    (void)handshake(fx, cfd, 501, 64);
    FH_EXPECT_EQ(fx.server->activeClientCount(), 1u);

    // Count owned slots before.
    std::size_t owned_before = 0;
    for (const auto& s : fx.server->match().slots()) {
        if (s.owner.has_value()) { ++owned_before; }
    }
    FH_EXPECT_EQ(owned_before, 1u);

    ::close(cfd);
    driveServer(*fx.server, 300);

    FH_EXPECT_EQ(fx.server->activeClientCount(), 0u);
    std::size_t owned_after = 0;
    for (const auto& s : fx.server->match().slots()) {
        if (s.owner.has_value()) { ++owned_after; }
    }
    FH_EXPECT_EQ(owned_after, 0u);
}

// Slice 17.7a: HELLO_ACK is followed immediately by SCENARIO_META. The
// server MUST advertise kWireCapScenarioMeta in the HELLO_ACK payload,
// then send exactly one SCENARIO_META frame. Fixture uses
// EmptyPitchScenario (Advisory + empty polygon) so the payload is the
// minimum 3 bytes: [mode=Advisory][num_vertices=0].
FH_TEST(scenario_meta_sent_immediately_after_hello_ack) {
    Fixture fx;
    const int cfd = connectLoopback(fx.port());
    FH_EXPECT(cfd >= 0);

    // Both frames should arrive well within 128 extra bytes: HELLO_ACK
    // = 22 wire bytes, SCENARIO_META = 9 wire bytes (WS header + 7-byte
    // payload). handshake()'s 1500 ms pump already drains both.
    auto hs = handshake(fx, cfd, /*person_id=*/151, /*extra_bytes=*/128);
    const auto frames = extractBinaryPayloads(hs.bytes, hs.header_end);
    FH_EXPECT(frames.size() >= 2u);

    // Frame 0 = HELLO_ACK. Cap bits must include the ScenarioMeta bit
    // (and the pre-existing SnapshotBallTrailer bit — Slice 15.4).
    const auto& ack = frames[0];
    FH_EXPECT_EQ(ack.size(), kHelloAckFrameBytes);
    FH_EXPECT_EQ(ack[1], static_cast<std::uint8_t>(MsgType::HelloAck));
    const std::uint16_t caps =
        read_u16_le(ack.data() + kFrameHeaderBytes + 14);
    FH_EXPECT((caps & kWireCapScenarioMeta) != 0u);
    FH_EXPECT((caps & kWireCapSnapshotBallTrailer) != 0u);

    // Frame 1 = SCENARIO_META. Fixture is EmptyPitchScenario → Advisory
    // + empty polygon.
    const auto& meta = frames[1];
    FH_EXPECT_EQ(meta[1],
                 static_cast<std::uint8_t>(MsgType::ScenarioMeta));
    const auto decoded = decodeScenarioMetaFrame(
        std::span<const std::uint8_t>(meta.data(), meta.size()));
    FH_EXPECT(decoded.has_value());
    FH_EXPECT_EQ(decoded->mode, kScenarioModeAdvisory);
    FH_EXPECT(decoded->vertices.empty());

    ::close(cfd);
    driveServer(*fx.server, 200);
}

// §21.7 item 2 diagnostic (2026-07-14): tickOnceForTest() must advance
// the ticksExecuted() observable so operators can consume the counter
// as a monotonic tick count from any thread. catchUpSkips() stays 0 in
// this test because tickOnceForTest bypasses the fixed-cadence branch
// where skips are counted; the skip counter's behavior is verified
// live via /admin/tick_stats against a real daemon under load.
FH_TEST(ticks_executed_counter_advances_on_each_tick)
{
    Fixture fx;
    FH_EXPECT_EQ(fx.server->ticksExecuted(), static_cast<std::uint64_t>(0));
    FH_EXPECT_EQ(fx.server->catchUpSkips(),  static_cast<std::uint32_t>(0));

    fx.server->tickOnceForTest();
    FH_EXPECT_EQ(fx.server->ticksExecuted(), static_cast<std::uint64_t>(1));

    for (int i = 0; i < 9; ++i) { fx.server->tickOnceForTest(); }
    FH_EXPECT_EQ(fx.server->ticksExecuted(), static_cast<std::uint64_t>(10));
    FH_EXPECT_EQ(fx.server->catchUpSkips(),  static_cast<std::uint32_t>(0));
}

FH_TEST_MAIN()
