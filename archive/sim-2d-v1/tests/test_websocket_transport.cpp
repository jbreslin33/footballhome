// footballhome sim - WebSocketTransport integration test
//
// End-to-end: real loopback sockets talking to a real WebSocketTransport
// on a background-free single-threaded driver. Tests exercise:
//   * bind → boundPort() readback
//   * handshake accept/reject via JwtVerifier
//   * client Binary frame → onMessage
//   * transport.send() → server Binary frame on wire
//   * Ping → Pong reply
//   * Close frame → server Close reply + onDisconnect
//   * client TCP FIN → onDisconnect
//
// Uses OpenSSL to mint valid JWTs in-test (same pattern as
// test_jwt_verifier.cpp).

#include "auth/JwtVerifier.hpp"
#include "net/WebSocketFrame.hpp"
#include "net/WebSocketTransport.hpp"
#include "test_harness.hpp"

#include <openssl/hmac.h>

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>

#include <array>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <string>
#include <string_view>
#include <vector>

using fh::sim::auth::JwtClaims;
using fh::sim::auth::JwtVerifier;
using fh::sim::ClientId;
using fh::sim::net::ws::decodeClientFrame;
using fh::sim::net::ws::DecodedFrame;
using fh::sim::net::ws::Opcode;
using fh::sim::net::ws::WebSocketTransport;

// ---------------------------------------------------------------------------
// Test-only JWT minter (dupe from test_jwt_verifier.cpp; keeping tests
// standalone so removing one doesn't break the other).
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

JwtVerifier makeVerifier() {
    // Frozen clock at t=1000 — well before default exp of 2000.
    return JwtVerifier(std::string(kSecret), []() -> std::int64_t { return 1000; });
}

// ---------------------------------------------------------------------------
// Client socket helpers
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
    // Client side stays blocking; simpler to reason about.
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

// Read until we get at least `min_bytes` OR `timeout_ms` elapses.
// Uses poll for the wait; caller drives transport in between.
// Drive the transport for ~timeout_ms in short slices so callbacks get
// invoked while the test also has time to poll its own client socket.
void driveTransport(WebSocketTransport& tx, int timeout_ms) {
    const auto deadline =
        std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);
    for (;;) {
        tx.poll(5);
        if (std::chrono::steady_clock::now() >= deadline) { break; }
    }
}

// Interleaved: drive transport while also waiting for bytes on `fd`.
std::vector<std::uint8_t> pumpUntil(WebSocketTransport& tx, int fd,
                                    std::size_t min_bytes, int timeout_ms) {
    std::vector<std::uint8_t> out;
    const auto deadline =
        std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);
    std::uint8_t buf[4096];
    bool eof = false;
    for (;;) {
        tx.poll(5);   // drives the server side
        pollfd pfd{fd, POLLIN, 0};
        const int r = ::poll(&pfd, 1, 5);
        // On loopback the server may FIN right after the response; POLLHUP
        // arrives with (or just before) the trailing data, so read on any
        // readable-or-hangup revent.
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
            // Got enough and nothing more immediately queued.
            break;
        }
        if (eof) { break; }
        if (std::chrono::steady_clock::now() >= deadline) { break; }
    }
    return out;
}

// Frame builder duplicated from test_websocket_frame.cpp keeps this
// test standalone.
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

// Convenience: does `haystack` contain `needle` as a byte substring?
bool contains(const std::vector<std::uint8_t>& haystack, std::string_view needle) {
    if (needle.empty() || haystack.size() < needle.size()) { return false; }
    for (std::size_t i = 0; i + needle.size() <= haystack.size(); ++i) {
        if (std::memcmp(haystack.data() + i, needle.data(), needle.size()) == 0) {
            return true;
        }
    }
    return false;
}

// Starts a transport bound to an ephemeral loopback port. Returns the
// bound port so the test can connect.
WebSocketTransport::Config makeConfig() {
    WebSocketTransport::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.backlog      = 4;
    return cfg;
}

} // namespace

// ===========================================================================
// Tests
// ===========================================================================
FH_TEST(starts_and_reports_bound_port) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    FH_EXPECT(tx.start());
    FH_EXPECT(tx.boundPort() != 0);
    tx.stop();
    // Second start after stop should succeed.
    FH_EXPECT(tx.start());
    FH_EXPECT(tx.boundPort() != 0);
    tx.stop();
}

FH_TEST(start_without_verifier_fails) {
    WebSocketTransport tx(makeConfig(), nullptr);
    FH_EXPECT(!tx.start());
}

FH_TEST(rejects_invalid_jwt_with_401) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    int connect_count = 0;
    tx.setOnConnect([&](ClientId, const JwtClaims&) { ++connect_count; });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(cfd >= 0);

    const std::string req = handshakeRequest("bogus.jwt.token");
    FH_EXPECT(sendAll(cfd, req));

    const auto resp = pumpUntil(tx, cfd, 12, 500);
    FH_EXPECT(contains(resp, "401"));
    FH_EXPECT_EQ(connect_count, 0);
    ::close(cfd);
    tx.stop();
}

FH_TEST(accepts_valid_jwt_and_fires_onconnect) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    ClientId got_id = 0;
    std::int64_t got_person = 0;
    tx.setOnConnect([&](ClientId id, const JwtClaims& c) {
        got_id     = id;
        got_person = c.person_id;
    });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(cfd >= 0);

    const std::string jwt = mintJwt(42, 2000, kSecret);
    const std::string req = handshakeRequest(jwt);
    FH_EXPECT(sendAll(cfd, req));

    const auto resp = pumpUntil(tx, cfd, 64, 500);
    FH_EXPECT(contains(resp, "101 Switching Protocols"));
    FH_EXPECT(contains(resp, "Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo="));
    FH_EXPECT(contains(resp, "Sec-WebSocket-Protocol: fh-sim.v1.bearer"));
    FH_EXPECT(got_id != 0);
    FH_EXPECT_EQ(got_person, 42);
    FH_EXPECT_EQ(tx.clientCount(), 1u);

    ::close(cfd);
    driveTransport(tx, 100);   // let the FIN propagate through poll
    tx.stop();
}

FH_TEST(delivers_binary_frame_to_onmessage) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    std::vector<std::uint8_t> got;
    tx.setOnMessage([&](ClientId, std::span<const std::uint8_t> bytes) {
        got.assign(bytes.begin(), bytes.end());
    });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest(mintJwt(7, 2000, kSecret))));
    (void)pumpUntil(tx, cfd, 64, 500);   // wait for handshake response

    const std::vector<std::uint8_t> payload = {0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02};
    const auto frame = maskedClientFrame(Opcode::Binary, payload);
    FH_EXPECT(sendAll(cfd, std::string_view(
        reinterpret_cast<const char*>(frame.data()), frame.size())));

    driveTransport(tx, 200);
    FH_EXPECT_EQ(got.size(), payload.size());
    for (std::size_t i = 0; i < payload.size(); ++i) {
        FH_EXPECT_EQ(got[i], payload[i]);
    }

    ::close(cfd);
    driveTransport(tx, 100);
    tx.stop();
}

FH_TEST(send_delivers_binary_to_client) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    ClientId cid = 0;
    tx.setOnConnect([&](ClientId id, const JwtClaims&) { cid = id; });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest(mintJwt(3, 2000, kSecret))));
    (void)pumpUntil(tx, cfd, 64, 500);
    FH_EXPECT(cid != 0);

    const std::vector<std::uint8_t> payload = {'H', 'e', 'l', 'l', 'o'};
    FH_EXPECT(tx.send(cid, payload));

    // Server frame is 2-byte header + 5-byte payload = 7 bytes.
    const auto wire = pumpUntil(tx, cfd, 7, 500);
    FH_EXPECT(wire.size() >= 7u);
    FH_EXPECT_EQ(wire[0], 0x82u);   // FIN + Binary
    FH_EXPECT_EQ(wire[1], 0x05u);   // unmasked, len=5
    for (std::size_t i = 0; i < payload.size(); ++i) {
        FH_EXPECT_EQ(wire[2 + i], payload[i]);
    }

    ::close(cfd);
    driveTransport(tx, 100);
    tx.stop();
}

FH_TEST(ping_frame_gets_pong_reply) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest(mintJwt(9, 2000, kSecret))));
    (void)pumpUntil(tx, cfd, 64, 500);

    const std::vector<std::uint8_t> ping_payload = {0xAB, 0xCD};
    const auto ping = maskedClientFrame(Opcode::Ping, ping_payload);
    FH_EXPECT(sendAll(cfd, std::string_view(
        reinterpret_cast<const char*>(ping.data()), ping.size())));

    // Pong reply is 2-byte header + 2-byte payload = 4 bytes.
    const auto reply = pumpUntil(tx, cfd, 4, 500);
    FH_EXPECT(reply.size() >= 4u);
    FH_EXPECT_EQ(reply[0], 0x8Au);   // FIN + Pong
    FH_EXPECT_EQ(reply[1], 0x02u);
    FH_EXPECT_EQ(reply[2], 0xABu);
    FH_EXPECT_EQ(reply[3], 0xCDu);

    ::close(cfd);
    driveTransport(tx, 100);
    tx.stop();
}

FH_TEST(client_tcp_close_fires_ondisconnect) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    ClientId connected = 0;
    ClientId disconnected = 0;
    tx.setOnConnect   ([&](ClientId id, const JwtClaims&) { connected = id; });
    tx.setOnDisconnect([&](ClientId id)                   { disconnected = id; });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest(mintJwt(11, 2000, kSecret))));
    (void)pumpUntil(tx, cfd, 64, 500);
    FH_EXPECT(connected != 0);

    ::close(cfd);
    driveTransport(tx, 300);
    FH_EXPECT_EQ(disconnected, connected);
    FH_EXPECT_EQ(tx.clientCount(), 0u);

    tx.stop();
}

FH_TEST(server_disconnect_closes_client) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    ClientId cid = 0;
    int disc_count = 0;
    tx.setOnConnect   ([&](ClientId id, const JwtClaims&) { cid = id; });
    tx.setOnDisconnect([&](ClientId)                      { ++disc_count; });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest(mintJwt(13, 2000, kSecret))));
    (void)pumpUntil(tx, cfd, 64, 500);
    FH_EXPECT(cid != 0);

    tx.disconnect(cid);
    driveTransport(tx, 200);
    FH_EXPECT_EQ(disc_count, 1);
    FH_EXPECT_EQ(tx.clientCount(), 0u);

    ::close(cfd);
    tx.stop();
}

FH_TEST(rejected_handshake_does_not_fire_disconnect) {
    // Symmetric with onConnect: a client that never authenticated must
    // never trigger onDisconnect either.
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    int connects = 0, disconnects = 0;
    tx.setOnConnect   ([&](ClientId, const JwtClaims&) { ++connects; });
    tx.setOnDisconnect([&](ClientId)                   { ++disconnects; });
    FH_EXPECT(tx.start());

    const int cfd = connectLoopback(tx.boundPort());
    FH_EXPECT(sendAll(cfd, handshakeRequest("expired.token.bad")));
    driveTransport(tx, 200);
    ::close(cfd);
    driveTransport(tx, 200);

    FH_EXPECT_EQ(connects, 0);
    FH_EXPECT_EQ(disconnects, 0);
    tx.stop();
}

FH_TEST(supports_multiple_concurrent_clients) {
    JwtVerifier v = makeVerifier();
    WebSocketTransport tx(makeConfig(), &v);
    int on_conn = 0;
    tx.setOnConnect([&](ClientId, const JwtClaims&) { ++on_conn; });
    FH_EXPECT(tx.start());

    constexpr int kN = 3;
    int cfds[kN];
    for (int i = 0; i < kN; ++i) {
        cfds[i] = connectLoopback(tx.boundPort());
        FH_EXPECT(cfds[i] >= 0);
        FH_EXPECT(sendAll(cfds[i],
            handshakeRequest(mintJwt(100 + i, 2000, kSecret))));
    }
    // Drive until all three handshakes complete.
    const auto deadline =
        std::chrono::steady_clock::now() + std::chrono::milliseconds(1000);
    while (on_conn < kN
           && std::chrono::steady_clock::now() < deadline) {
        tx.poll(10);
    }
    FH_EXPECT_EQ(on_conn, kN);
    FH_EXPECT_EQ(tx.clientCount(), static_cast<std::size_t>(kN));

    for (int i = 0; i < kN; ++i) { ::close(cfds[i]); }
    driveTransport(tx, 200);
    tx.stop();
}

FH_TEST_MAIN()
