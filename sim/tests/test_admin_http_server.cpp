// footballhome sim - AdminHttpServer tests (§16.6 sub-slice 8.1)
//
// Three layers:
//
//   1. parseHttpRequest — golden + negative cases for the tiny HTTP/1.1
//      parser (headers, Content-Length, oversized, malformed).
//   2. parseReplayJson — golden + negative cases for the hand-rolled
//      JSON parser (all three fields present, defaults, key ordering,
//      trailing garbage).
//   3. Full loopback end-to-end: start an AdminHttpServer on port 0
//      against an InMemoryPgClient seeded with a minimal MatchEnd
//      event (empty input log = trivial replay of tick 0), then
//      connect via a plain TCP socket, POST /admin/replay with the
//      shared token, and verify the response line + JSON body.
//
// The e2e layer proves that:
//   * bind + listen + accept work,
//   * the read loop assembles headers+body across recv() chunks,
//   * auth (bearer token) works both positively AND negatively,
//   * a match not found comes back as HTTP 404,
//   * a valid replay comes back as HTTP 200 with the expected hash.
//
// No POSIX-only feature beyond what SimServer/WebSocketTransport
// already use (poll/socket/getsockname) — same portability envelope.

#include "admin/AdminHttpServer.hpp"
#include "common/IdTypes.hpp"
#include "persistence/EventTypes.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "match/CanonicalHash.hpp"
#include "test_harness.hpp"

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <string>
#include <thread>
#include <vector>

using fh::sim::MatchId;
using fh::sim::admin::AdminHttpServer;
using fh::sim::admin::constantTimeEquals;
using fh::sim::admin::parseHttpRequest;
using fh::sim::admin::parseReplayJson;
using fh::sim::persistence::EventRow;
using fh::sim::persistence::EventType;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::MatchRow;

namespace {

// -----------------------------------------------------------------------
// A one-shot TCP client for the e2e tests: connect to 127.0.0.1:port,
// send `request`, read until EOF, return the raw response bytes.
// -----------------------------------------------------------------------
std::string tcpSendRecv(std::uint16_t port, const std::string& request)
{
    const int fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) { return {}; }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);
    ::inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

    if (::connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) < 0) {
        ::close(fd);
        return {};
    }

    // Send.
    const char* p    = request.data();
    std::size_t left = request.size();
    while (left > 0) {
        const ssize_t n = ::send(fd, p, left, MSG_NOSIGNAL);
        if (n <= 0) { ::close(fd); return {}; }
        p    += n;
        left -= static_cast<std::size_t>(n);
    }

    // Signal end-of-request so the server (which is Connection: close
    // but reads until Content-Length) can be extra sure. Not strictly
    // needed — our server keys on Content-Length — but harmless.
    ::shutdown(fd, SHUT_WR);

    // Recv until EOF.
    std::string out;
    char buf[2048];
    while (true) {
        const ssize_t n = ::recv(fd, buf, sizeof(buf), 0);
        if (n < 0) { if (errno == EINTR) continue; break; }
        if (n == 0) { break; }
        out.append(buf, static_cast<std::size_t>(n));
    }
    ::close(fd);
    return out;
}

// -----------------------------------------------------------------------
// Seed a bare-minimum MatchEnd event for match_id=1 so replayMatch()
// can resolve target_tick without any recorded inputs. The tick_num is
// 0, so replayMatch loops 0 times and returns a hash of the initial
// EmptyPitchScenario snapshot with seed=42.
// -----------------------------------------------------------------------
void seedTrivialMatch(InMemoryPgClient& db, MatchId id)
{
    MatchRow row;
    row.id             = id;
    row.scenario_id    = 0;
    row.seed           = 42;
    row.tick_hz        = 20;
    row.server_version = "test";
    row.visibility     = 0;
    db.upsertMatch(row);

    // Provide a MatchEnd event so up_to_tick defaults to 0 without
    // erroring out. Payload is any 8 bytes (unused when computing the
    // reply hash — we only compare in --verify mode, which isn't the
    // e2e test's concern).
    EventRow ev;
    ev.match_id   = id;
    ev.tick_num   = 0;
    ev.event_type = EventType::MatchEnd;
    ev.payload    = std::vector<std::byte>(8, std::byte{0});
    db.insertEvent(ev);
}

// -----------------------------------------------------------------------
// Little grep-in-response helper — returns true iff `needle` appears
// anywhere in `hay`.
// -----------------------------------------------------------------------
bool contains(const std::string& hay, const std::string& needle)
{
    return hay.find(needle) != std::string::npos;
}

} // namespace

// =======================================================================
// Layer 1: parseHttpRequest
// =======================================================================

FH_TEST(parse_http_valid_post_with_body)
{
    // Body {"match_id":1} is 14 bytes.
    const std::string raw =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim:9101\r\n"
        "Authorization: Bearer secret123\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: 14\r\n"
        "\r\n"
        "{\"match_id\":1}";
    auto p = parseHttpRequest(raw);
    FH_EXPECT(p.has_value());
    FH_EXPECT_EQ(p->method, std::string{"POST"});
    FH_EXPECT_EQ(p->path,   std::string{"/admin/replay"});
    FH_EXPECT_EQ(p->authorization, std::string{"Bearer secret123"});
    FH_EXPECT_EQ(p->content_type,  std::string{"application/json"});
    FH_EXPECT_EQ(p->body,          std::string{"{\"match_id\":1}"});
}

FH_TEST(parse_http_case_insensitive_headers)
{
    const std::string raw =
        "POST / HTTP/1.1\r\n"
        "AUTHORIZATION: Bearer x\r\n"
        "content-length: 0\r\n"
        "\r\n";
    auto p = parseHttpRequest(raw);
    FH_EXPECT(p.has_value());
    FH_EXPECT_EQ(p->authorization, std::string{"Bearer x"});
}

FH_TEST(parse_http_missing_terminator_returns_nullopt)
{
    const std::string raw = "POST / HTTP/1.1\r\nHost: x\r\n";
    FH_EXPECT(!parseHttpRequest(raw).has_value());
}

FH_TEST(parse_http_content_length_mismatch)
{
    const std::string raw =
        "POST / HTTP/1.1\r\n"
        "Content-Length: 99\r\n"
        "\r\n"
        "short";
    std::string why;
    FH_EXPECT(!parseHttpRequest(raw, &why).has_value());
    FH_EXPECT(contains(why, "Content-Length"));
}

FH_TEST(parse_http_oversized_request_rejected)
{
    std::string raw = "POST / HTTP/1.1\r\n";
    // Pad past kMaxRequestBytes.
    raw.append(fh::sim::admin::kMaxRequestBytes + 1, 'A');
    raw.append("\r\n\r\n");
    FH_EXPECT(!parseHttpRequest(raw).has_value());
}

// =======================================================================
// Layer 2: parseReplayJson
// =======================================================================

FH_TEST(parse_json_all_fields)
{
    const std::string body =
        R"({"match_id": 42, "up_to_tick": 100, "emit_hex": true})";
    auto r = parseReplayJson(body);
    FH_EXPECT(r.has_value());
    FH_EXPECT_EQ(r->match_id,     static_cast<MatchId>(42));
    FH_EXPECT(r->up_to_tick.has_value());
    FH_EXPECT_EQ(*r->up_to_tick,  static_cast<std::uint32_t>(100));
    FH_EXPECT_EQ(r->emit_hex,     true);
}

FH_TEST(parse_json_only_match_id)
{
    const std::string body = R"({"match_id":7})";
    auto r = parseReplayJson(body);
    FH_EXPECT(r.has_value());
    FH_EXPECT_EQ(r->match_id, static_cast<MatchId>(7));
    FH_EXPECT(!r->up_to_tick.has_value());
    FH_EXPECT_EQ(r->emit_hex, false);
}

FH_TEST(parse_json_key_order_agnostic)
{
    const std::string body =
        R"({"emit_hex":false,"up_to_tick":50,"match_id":3})";
    auto r = parseReplayJson(body);
    FH_EXPECT(r.has_value());
    FH_EXPECT_EQ(r->match_id,     static_cast<MatchId>(3));
    FH_EXPECT_EQ(*r->up_to_tick,  static_cast<std::uint32_t>(50));
    FH_EXPECT_EQ(r->emit_hex,     false);
}

FH_TEST(parse_json_missing_match_id_rejected)
{
    std::string why;
    auto r = parseReplayJson(R"({"emit_hex":true})", &why);
    FH_EXPECT(!r.has_value());
    FH_EXPECT(contains(why, "match_id"));
}

FH_TEST(parse_json_match_id_zero_rejected)
{
    auto r = parseReplayJson(R"({"match_id":0})");
    FH_EXPECT(!r.has_value());
}

FH_TEST(parse_json_unknown_field_rejected)
{
    std::string why;
    auto r = parseReplayJson(R"({"match_id":1,"nope":true})", &why);
    FH_EXPECT(!r.has_value());
    FH_EXPECT(contains(why, "unknown"));
}

FH_TEST(parse_json_trailing_garbage_rejected)
{
    auto r = parseReplayJson(R"({"match_id":1}garbage)");
    FH_EXPECT(!r.has_value());
}

FH_TEST(parse_json_up_to_tick_out_of_range)
{
    // Anything > 2^32 - 1 must be rejected.
    auto r = parseReplayJson(R"({"match_id":1,"up_to_tick":4294967296})");
    FH_EXPECT(!r.has_value());
}

// =======================================================================
// Constant-time equal
// =======================================================================

FH_TEST(constant_time_equal_matches)
{
    FH_EXPECT(constantTimeEquals("abc", "abc"));
    FH_EXPECT(!constantTimeEquals("abc", "abd"));
    FH_EXPECT(!constantTimeEquals("abc", "ab"));
    FH_EXPECT(!constantTimeEquals("", "x"));
    FH_EXPECT(constantTimeEquals("", ""));
}

// =======================================================================
// Layer 3: end-to-end over a real TCP loopback socket
// =======================================================================

FH_TEST(e2e_missing_bearer_yields_401)
{
    InMemoryPgClient db;
    seedTrivialMatch(db, /*id=*/1);

    AdminHttpServer::Config cfg;
    cfg.bind_address     = "127.0.0.1";
    cfg.port             = 0;  // ephemeral
    cfg.admin_token      = "unit-test-token";
    cfg.read_timeout_ms  = 1000;
    cfg.write_timeout_ms = 1000;

    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());
    FH_EXPECT_GT(srv.boundPort(), 0);

    const std::string req =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: 14\r\n"
        "\r\n"
        "{\"match_id\":1}";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 401"));
    FH_EXPECT(contains(resp, "\"unauthorized\""));
}

FH_TEST(e2e_wrong_token_yields_403)
{
    InMemoryPgClient db;
    seedTrivialMatch(db, 1);

    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "the-real-token";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    const std::string req =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "Authorization: Bearer WRONG\r\n"
        "Content-Length: 14\r\n"
        "\r\n"
        "{\"match_id\":1}";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 403"));
    FH_EXPECT(contains(resp, "\"forbidden\""));
}

FH_TEST(e2e_wrong_method_yields_405)
{
    InMemoryPgClient db;
    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    const std::string req =
        "GET /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "\r\n";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 405"));
}

FH_TEST(e2e_unknown_path_yields_404)
{
    InMemoryPgClient db;
    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    const std::string req =
        "GET /admin/health HTTP/1.1\r\n"
        "Host: sim\r\n"
        "\r\n";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 404"));
}

FH_TEST(e2e_match_not_found_yields_404)
{
    InMemoryPgClient db;  // no rows seeded
    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    // Body {"match_id":99} is 15 bytes.
    const std::string req =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "Authorization: Bearer T\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: 15\r\n"
        "\r\n"
        "{\"match_id\":99}";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 404"));
    FH_EXPECT(contains(resp, "match not found"));
    FH_EXPECT(contains(resp, "\"match_id\":99"));
}

FH_TEST(e2e_valid_replay_returns_hash)
{
    InMemoryPgClient db;
    seedTrivialMatch(db, 1);

    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    const std::string req =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "Authorization: Bearer T\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: 14\r\n"
        "\r\n"
        "{\"match_id\":1}";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 200"));
    FH_EXPECT(contains(resp, "\"match_id\":1"));
    FH_EXPECT(contains(resp, "\"final_tick\":0"));
    FH_EXPECT(contains(resp, "\"hash_hex\":\"0x"));
    FH_EXPECT(contains(resp, "\"inputs_applied\":0"));
    // emit_hex was NOT set → no canonical_hex field.
    FH_EXPECT(!contains(resp, "canonical_hex"));
}

FH_TEST(e2e_valid_replay_with_emit_hex_includes_dump)
{
    InMemoryPgClient db;
    seedTrivialMatch(db, 1);

    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());

    // Body {"match_id":1,"emit_hex":true} is 30 bytes.
    const std::string req =
        "POST /admin/replay HTTP/1.1\r\n"
        "Host: sim\r\n"
        "Authorization: Bearer T\r\n"
        "Content-Type: application/json\r\n"
        "Content-Length: 30\r\n"
        "\r\n"
        "{\"match_id\":1,\"emit_hex\":true}";
    const std::string resp = tcpSendRecv(srv.boundPort(), req);
    srv.stop();

    FH_EXPECT(contains(resp, "HTTP/1.1 200"));
    FH_EXPECT(contains(resp, "\"canonical_hex\":\""));
}

FH_TEST(e2e_refuses_to_start_without_token)
{
    InMemoryPgClient db;
    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "";  // deliberately empty
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(!srv.start());
    FH_EXPECT(!srv.running());
}

FH_TEST(e2e_stop_is_idempotent)
{
    InMemoryPgClient db;
    AdminHttpServer::Config cfg;
    cfg.bind_address = "127.0.0.1";
    cfg.port         = 0;
    cfg.admin_token  = "T";
    AdminHttpServer srv{cfg, db};
    FH_EXPECT(srv.start());
    srv.stop();
    srv.stop();  // must not crash
    FH_EXPECT(!srv.running());
}

FH_TEST_MAIN()
