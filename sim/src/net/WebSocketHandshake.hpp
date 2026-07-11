// footballhome sim - RFC 6455 WebSocket opening handshake (bytes only)
//
// Parses the client's HTTP Upgrade request, validates it against the
// spec, extracts the bearer JWT from the subprotocol header, and
// produces the 101 response bytes. No I/O, no threading — the transport
// in slice 8b hands us the request buffer and copies out the response.
//
// Handshake contract (see DESIGN.md §7, §13):
//   Request MUST include:
//     - HTTP/1.1 GET on any path (the sim server exposes /sim, but the
//       path check is the transport's job; the parser only validates
//       WebSocket-level fields).
//     - Host: <anything>
//     - Upgrade: websocket
//     - Connection: contains "Upgrade" (case-insensitive)
//     - Sec-WebSocket-Version: 13
//     - Sec-WebSocket-Key: <16 base64 bytes>
//     - Sec-WebSocket-Protocol: fh-sim.v1.bearer.<JWT>
//
//   Response is HTTP/1.1 101 with:
//     - Upgrade: websocket
//     - Connection: Upgrade
//     - Sec-WebSocket-Accept: base64(SHA1(key + magic))
//     - Sec-WebSocket-Protocol: fh-sim.v1.bearer.<JWT>  (echo the full offered token verbatim; RFC 6455 §4.2.2, required by browsers)

#pragma once

#include <cstddef>
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace fh::sim::net::ws {

// -----------------------------------------------------------------------
// Parsed handshake outcome — nothing here is authenticated yet; JWT is a
// raw string that the transport must feed to JwtVerifier.
// -----------------------------------------------------------------------
struct HandshakeRequest {
    std::string request_path;         // e.g. "/sim"
    std::string sec_websocket_key;    // raw base64 value from header
    std::string bearer_token;         // extracted after "fh-sim.v1.bearer."
    std::string chosen_subprotocol;   // full "fh-sim.v1.bearer.<JWT>" (echoed verbatim per RFC 6455 §4.2.2)
};

struct ParseResult {
    enum class Status : std::uint8_t {
        Ok,
        NeedMore,   // headers not yet terminated by "\r\n\r\n"
        Malformed,  // syntactically wrong HTTP
        Rejected,   // syntactically OK but violates a policy field
    };

    Status                          status = Status::NeedMore;
    HandshakeRequest                request;
    std::size_t                     bytes_consumed = 0;
    std::string                     reject_reason; // populated on Rejected/Malformed
};

// Hard cap on how much request text we'll buffer before declaring the
// client's request malformed. 8 KiB is 4× a typical browser handshake.
inline constexpr std::size_t kMaxRequestBytes = 8u * 1024u;

// Application subprotocol prefix. Wire ID matches BinaryV1Serializer::wireId(),
// with ".bearer." separating protocol from token.
inline constexpr std::string_view kSubprotocolPrefix = "fh-sim.v1.bearer";

// -----------------------------------------------------------------------
// Parse an HTTP Upgrade request from a byte buffer. Returns NeedMore
// until the full header block is present. NEVER writes to `buffer`.
// -----------------------------------------------------------------------
ParseResult parseHandshakeRequest(std::string_view buffer);

// -----------------------------------------------------------------------
// Format the 101 Switching Protocols response for a parsed request.
// Returns empty on any internal error (should be impossible if the
// input is the output of parseHandshakeRequest).
// -----------------------------------------------------------------------
std::string formatHandshakeResponse(const HandshakeRequest& req);

// -----------------------------------------------------------------------
// Format a plain HTTP error response (used when parseHandshakeRequest
// returns Malformed/Rejected). Body is the reason string.
// -----------------------------------------------------------------------
std::string formatErrorResponse(int status_code, std::string_view reason);

// -----------------------------------------------------------------------
// Compute the Sec-WebSocket-Accept value per RFC 6455 §4.2.2:
//   base64(SHA1(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
// Exposed so tests can lock the exact string.
// -----------------------------------------------------------------------
std::string computeAcceptToken(std::string_view sec_websocket_key);

} // namespace fh::sim::net::ws
