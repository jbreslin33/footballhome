// footballhome sim - WebSocketHandshake parser tests

#include "net/WebSocketHandshake.hpp"
#include "test_harness.hpp"

#include <string>
#include <string_view>

using fh::sim::net::ws::computeAcceptToken;
using fh::sim::net::ws::formatErrorResponse;
using fh::sim::net::ws::formatHandshakeResponse;
using fh::sim::net::ws::HandshakeRequest;
using fh::sim::net::ws::kMaxRequestBytes;
using fh::sim::net::ws::parseHandshakeRequest;
using fh::sim::net::ws::ParseResult;

namespace {

// Build a full HTTP Upgrade request. All the defaults match a real
// browser handshake; tests override one field at a time to exercise
// specific rejection paths.
std::string buildRequest(std::string_view key   = "dGhlIHNhbXBsZSBub25jZQ==",
                         std::string_view proto = "fh-sim.v1.bearer.abc.def.ghi",
                         std::string_view path  = "/sim",
                         std::string_view host  = "sim.footballhome.com",
                         std::string_view version = "13",
                         std::string_view connection = "Upgrade")
{
    std::string r;
    r.reserve(256);
    r.append("GET ");
    r.append(path);
    r.append(" HTTP/1.1\r\nHost: ");
    r.append(host);
    r.append("\r\nUpgrade: websocket\r\nConnection: ");
    r.append(connection);
    r.append("\r\nSec-WebSocket-Version: ");
    r.append(version);
    r.append("\r\nSec-WebSocket-Key: ");
    r.append(key);
    r.append("\r\nSec-WebSocket-Protocol: ");
    r.append(proto);
    r.append("\r\n\r\n");
    return r;
}

} // namespace

// ---------------------------------------------------------------------------
// Happy-path parsing
// ---------------------------------------------------------------------------
FH_TEST(parses_valid_handshake) {
    const std::string req = buildRequest();
    const auto r = parseHandshakeRequest(req);
    FH_EXPECT(r.status == ParseResult::Status::Ok);
    FH_EXPECT(std::string_view{r.request.request_path} == "/sim");
    FH_EXPECT(std::string_view{r.request.sec_websocket_key} == "dGhlIHNhbXBsZSBub25jZQ==");
    FH_EXPECT(std::string_view{r.request.bearer_token} == "abc.def.ghi");
    // RFC 6455 §4.2.2: server echoes the offered subprotocol token
    // verbatim (including the JWT). Chrome/Firefox close 1006 otherwise.
    FH_EXPECT(std::string_view{r.request.chosen_subprotocol} == "fh-sim.v1.bearer.abc.def.ghi");
    FH_EXPECT_EQ(r.bytes_consumed, req.size());
}

// ---------------------------------------------------------------------------
// RFC 6455 §4.2.2 example — vector-locked
// ---------------------------------------------------------------------------
FH_TEST(compute_accept_matches_rfc_example) {
    // Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
    // → Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
    const std::string got = computeAcceptToken("dGhlIHNhbXBsZSBub25jZQ==");
    FH_EXPECT(got == "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=");
}

// ---------------------------------------------------------------------------
// Response formatting
// ---------------------------------------------------------------------------
FH_TEST(response_contains_all_required_headers) {
    HandshakeRequest req;
    req.sec_websocket_key   = "dGhlIHNhbXBsZSBub25jZQ==";
    req.chosen_subprotocol  = "fh-sim.v1.bearer.abc.def.ghi";
    const std::string resp = formatHandshakeResponse(req);

    FH_EXPECT(resp.find("HTTP/1.1 101 Switching Protocols\r\n") == 0);
    FH_EXPECT(resp.find("Upgrade: websocket\r\n")       != std::string::npos);
    FH_EXPECT(resp.find("Connection: Upgrade\r\n")      != std::string::npos);
    FH_EXPECT(resp.find("Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r\n")
                                                        != std::string::npos);
    FH_EXPECT(resp.find("Sec-WebSocket-Protocol: fh-sim.v1.bearer.abc.def.ghi\r\n")
                                                        != std::string::npos);
    // Ends with the empty terminator line.
    FH_EXPECT(resp.size() >= 4);
    FH_EXPECT(resp.compare(resp.size() - 4, 4, "\r\n\r\n") == 0);
}

FH_TEST(response_empty_when_key_missing) {
    HandshakeRequest req;
    req.chosen_subprotocol = "fh-sim.v1.bearer.abc.def.ghi";
    FH_EXPECT_EQ(formatHandshakeResponse(req).size(), 0u);
}

FH_TEST(error_response_has_status_and_reason) {
    const std::string r = formatErrorResponse(401, "bad token");
    FH_EXPECT(r.find("HTTP/1.1 401 Unauthorized\r\n") == 0);
    FH_EXPECT(r.find("Connection: close\r\n") != std::string::npos);
    FH_EXPECT(r.find("bad token")             != std::string::npos);
}

// ---------------------------------------------------------------------------
// Streaming behavior
// ---------------------------------------------------------------------------
FH_TEST(need_more_until_headers_complete) {
    const std::string full = buildRequest();
    // Feed everything except the final CRLF pair.
    const std::string partial = full.substr(0, full.size() - 2);
    const auto r = parseHandshakeRequest(partial);
    FH_EXPECT(r.status == ParseResult::Status::NeedMore);
    FH_EXPECT_EQ(r.bytes_consumed, 0u);
}

FH_TEST(oversize_request_without_terminator_is_malformed) {
    std::string junk(kMaxRequestBytes + 1, 'A');
    const auto r = parseHandshakeRequest(junk);
    FH_EXPECT(r.status == ParseResult::Status::Malformed);
}

// ---------------------------------------------------------------------------
// Field validation
// ---------------------------------------------------------------------------
FH_TEST(rejects_non_get_method) {
    std::string r = buildRequest();
    r.replace(0, 3, "PUT");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(rejects_wrong_http_version) {
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "fh-sim.v1.bearer.abc.def.ghi",
                                        "/sim",
                                        "host",
                                        "13",
                                        "Upgrade");
    // Downgrade HTTP version.
    std::string bad = r;
    const auto pos = bad.find("HTTP/1.1");
    FH_EXPECT(pos != std::string::npos);
    bad.replace(pos, 8, "HTTP/1.0");
    const auto p = parseHandshakeRequest(bad);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(rejects_wrong_ws_version) {
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "fh-sim.v1.bearer.tok",
                                        "/sim",
                                        "host",
                                        "8",
                                        "Upgrade");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(rejects_connection_without_upgrade) {
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "fh-sim.v1.bearer.tok",
                                        "/sim",
                                        "host",
                                        "13",
                                        "keep-alive");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(accepts_connection_with_upgrade_and_other_tokens) {
    // Real proxies often send: `Connection: keep-alive, Upgrade`.
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "fh-sim.v1.bearer.tok",
                                        "/sim",
                                        "host",
                                        "13",
                                        "keep-alive, Upgrade");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Ok);
}

FH_TEST(rejects_missing_bearer_subprotocol) {
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "chat, superchat",
                                        "/sim");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(rejects_empty_bearer_token) {
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "fh-sim.v1.bearer.",
                                        "/sim");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(picks_bearer_when_multiple_subprotocols_offered) {
    // Client offers three protocols, only one is ours. Server must pick
    // the fh-sim one regardless of position.
    const std::string r = buildRequest("dGhlIHNhbXBsZSBub25jZQ==",
                                        "chat, fh-sim.v1.bearer.MYTOKEN, superchat",
                                        "/sim");
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Ok);
    FH_EXPECT(std::string_view{p.request.bearer_token} == "MYTOKEN");
}

FH_TEST(header_names_are_case_insensitive) {
    // Weirdly-cased headers must still parse — RFC 7230 says names are
    // case-insensitive.
    std::string r =
        "GET /sim HTTP/1.1\r\n"
        "host: h\r\n"
        "upgrade: WebSocket\r\n"
        "CONNECTION: Upgrade\r\n"
        "sec-websocket-version: 13\r\n"
        "SEC-websocket-KEY: dGhlIHNhbXBsZSBub25jZQ==\r\n"
        "Sec-WebSocket-Protocol: fh-sim.v1.bearer.T\r\n"
        "\r\n";
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Ok);
    FH_EXPECT(std::string_view{p.request.bearer_token} == "T");
}

FH_TEST(rejects_missing_host) {
    std::string r =
        "GET /sim HTTP/1.1\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
        "Sec-WebSocket-Protocol: fh-sim.v1.bearer.T\r\n"
        "\r\n";
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Rejected);
}

FH_TEST(rejects_malformed_header_line) {
    std::string r =
        "GET /sim HTTP/1.1\r\n"
        "Host: h\r\n"
        "this-line-has-no-colon\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
        "Sec-WebSocket-Protocol: fh-sim.v1.bearer.T\r\n"
        "\r\n";
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Malformed);
}

FH_TEST(reports_correct_bytes_consumed_with_body_after_headers) {
    // The transport may deliver extra bytes after \r\n\r\n (first
    // frame arriving in the same TCP segment). Parser must report
    // ONLY the header block as consumed.
    std::string r = buildRequest();
    const std::size_t hdr_end = r.size();
    r.append(8, static_cast<char>(0xFF));   // trailing junk / early frame
    const auto p = parseHandshakeRequest(r);
    FH_EXPECT(p.status == ParseResult::Status::Ok);
    FH_EXPECT_EQ(p.bytes_consumed, hdr_end);
}

FH_TEST_MAIN()
