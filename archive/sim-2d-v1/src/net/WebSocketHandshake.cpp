// footballhome sim - RFC 6455 opening handshake implementation.

#include "net/WebSocketHandshake.hpp"

#include <openssl/sha.h>

#include <array>
#include <cctype>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <span>
#include <string>
#include <string_view>

namespace fh::sim::net::ws {

namespace {

// ---------------------------------------------------------------------------
// RFC 6455 §4.2.2 magic GUID
// ---------------------------------------------------------------------------
constexpr std::string_view kAcceptMagic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

// ---------------------------------------------------------------------------
// Standard base64 (with padding) — used ONLY for the Sec-WebSocket-Accept
// header value, which per spec MUST use the classic alphabet + '='.
// ---------------------------------------------------------------------------
constexpr char kB64Alpha[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

std::string base64EncodePadded(std::span<const std::uint8_t> in) {
    std::string out;
    out.reserve(((in.size() + 2) / 3) * 4);
    std::uint32_t buf = 0;
    int bits = 0;
    for (const std::uint8_t c : in) {
        buf = (buf << 8) | c;
        bits += 8;
        while (bits >= 6) {
            bits -= 6;
            out.push_back(kB64Alpha[(buf >> bits) & 0x3Fu]);
        }
    }
    if (bits > 0) {
        out.push_back(kB64Alpha[(buf << (6 - bits)) & 0x3Fu]);
    }
    while (out.size() % 4 != 0) { out.push_back('='); }
    return out;
}

// ---------------------------------------------------------------------------
// Case-insensitive helpers. RFC 7230 §3.2: header field names are ASCII,
// case-insensitive.
// ---------------------------------------------------------------------------
char asciiLower(char c) noexcept {
    return (c >= 'A' && c <= 'Z') ? static_cast<char>(c + 32) : c;
}

bool ieq(std::string_view a, std::string_view b) noexcept {
    if (a.size() != b.size()) { return false; }
    for (std::size_t i = 0; i < a.size(); ++i) {
        if (asciiLower(a[i]) != asciiLower(b[i])) { return false; }
    }
    return true;
}

bool icontains(std::string_view haystack, std::string_view needle) noexcept {
    if (needle.empty() || needle.size() > haystack.size()) { return false; }
    for (std::size_t i = 0; i + needle.size() <= haystack.size(); ++i) {
        bool ok = true;
        for (std::size_t j = 0; j < needle.size(); ++j) {
            if (asciiLower(haystack[i + j]) != asciiLower(needle[j])) { ok = false; break; }
        }
        if (ok) { return true; }
    }
    return false;
}

std::string_view trim(std::string_view s) noexcept {
    std::size_t start = 0;
    while (start < s.size()
           && (s[start] == ' ' || s[start] == '\t')) { ++start; }
    std::size_t end = s.size();
    while (end > start
           && (s[end - 1] == ' ' || s[end - 1] == '\t')) { --end; }
    return s.substr(start, end - start);
}

// ---------------------------------------------------------------------------
// Header line splitter. Returns false only if the line lacks a ':'.
// ---------------------------------------------------------------------------
bool splitHeader(std::string_view line, std::string_view& name, std::string_view& value) noexcept {
    const std::size_t colon = line.find(':');
    if (colon == std::string_view::npos) { return false; }
    name  = trim(line.substr(0, colon));
    value = trim(line.substr(colon + 1));
    return true;
}

} // namespace

// ---------------------------------------------------------------------------
// computeAcceptToken (public)
// ---------------------------------------------------------------------------
std::string computeAcceptToken(std::string_view sec_websocket_key)
{
    // SHA1(key + magic)
    std::string concat;
    concat.reserve(sec_websocket_key.size() + kAcceptMagic.size());
    concat.append(sec_websocket_key);
    concat.append(kAcceptMagic);

    std::array<std::uint8_t, SHA_DIGEST_LENGTH> digest{};
    SHA1(reinterpret_cast<const unsigned char*>(concat.data()),
         concat.size(),
         digest.data());
    return base64EncodePadded(digest);
}

// ---------------------------------------------------------------------------
// parseHandshakeRequest
// ---------------------------------------------------------------------------
ParseResult parseHandshakeRequest(std::string_view buffer)
{
    ParseResult r;

    // Find the end-of-headers marker. If it's not present yet, ask for
    // more bytes — but only up to the sanity cap.
    const std::size_t end = buffer.find("\r\n\r\n");
    if (end == std::string_view::npos) {
        if (buffer.size() >= kMaxRequestBytes) {
            r.status = ParseResult::Status::Malformed;
            r.reject_reason = "request headers exceed max size";
            return r;
        }
        r.status = ParseResult::Status::NeedMore;
        return r;
    }
    r.bytes_consumed = end + 4;

    // Split header block into lines. Any \n without \r is malformed.
    std::string_view block = buffer.substr(0, end);

    // --- Request line: METHOD PATH HTTP/1.1 -------------------------------
    const std::size_t line1_end = block.find("\r\n");
    if (line1_end == std::string_view::npos) {
        // block itself has no lines — malformed.
        r.status = ParseResult::Status::Malformed;
        r.reject_reason = "no request line";
        return r;
    }
    std::string_view request_line = block.substr(0, line1_end);
    const std::size_t sp1 = request_line.find(' ');
    if (sp1 == std::string_view::npos) {
        r.status = ParseResult::Status::Malformed;
        r.reject_reason = "malformed request line";
        return r;
    }
    const std::size_t sp2 = request_line.find(' ', sp1 + 1);
    if (sp2 == std::string_view::npos) {
        r.status = ParseResult::Status::Malformed;
        r.reject_reason = "malformed request line";
        return r;
    }
    const std::string_view method  = request_line.substr(0, sp1);
    const std::string_view path    = request_line.substr(sp1 + 1, sp2 - sp1 - 1);
    const std::string_view version = request_line.substr(sp2 + 1);

    if (!ieq(method, "GET")) {
        r.status = ParseResult::Status::Rejected;
        r.reject_reason = "method must be GET";
        return r;
    }
    if (!ieq(version, "HTTP/1.1")) {
        r.status = ParseResult::Status::Rejected;
        r.reject_reason = "HTTP/1.1 required";
        return r;
    }
    r.request.request_path.assign(path.data(), path.size());

    // --- Header lines -----------------------------------------------------
    std::string upgrade_hdr;
    std::string connection_hdr;
    std::string ws_version_hdr;
    std::string ws_key_hdr;
    std::string ws_protocol_hdr;
    bool saw_host = false;

    std::size_t p = line1_end + 2;
    while (p < block.size()) {
        std::size_t nl = block.find("\r\n", p);
        if (nl == std::string_view::npos) { nl = block.size(); }
        std::string_view line = block.substr(p, nl - p);
        p = nl + 2;
        if (line.empty()) { continue; }

        std::string_view name;
        std::string_view value;
        if (!splitHeader(line, name, value)) {
            r.status = ParseResult::Status::Malformed;
            r.reject_reason = "malformed header";
            return r;
        }
        if      (ieq(name, "Host"))                    { saw_host = true; }
        else if (ieq(name, "Upgrade"))                 { upgrade_hdr.assign(value); }
        else if (ieq(name, "Connection"))              { connection_hdr.assign(value); }
        else if (ieq(name, "Sec-WebSocket-Version"))   { ws_version_hdr.assign(value); }
        else if (ieq(name, "Sec-WebSocket-Key"))       { ws_key_hdr.assign(value); }
        else if (ieq(name, "Sec-WebSocket-Protocol"))  { ws_protocol_hdr.assign(value); }
        // Ignore unknown headers (spec-compliant: proxies add lots).
    }

    if (!saw_host)                          { r.status = ParseResult::Status::Rejected; r.reject_reason = "missing Host";                     return r; }
    if (!ieq(upgrade_hdr, "websocket"))     { r.status = ParseResult::Status::Rejected; r.reject_reason = "Upgrade must be websocket";         return r; }
    if (!icontains(connection_hdr, "upgrade")) {
        r.status = ParseResult::Status::Rejected; r.reject_reason = "Connection must include Upgrade"; return r;
    }
    if (!ieq(ws_version_hdr, "13"))         { r.status = ParseResult::Status::Rejected; r.reject_reason = "Sec-WebSocket-Version must be 13";  return r; }
    if (ws_key_hdr.empty())                 { r.status = ParseResult::Status::Rejected; r.reject_reason = "missing Sec-WebSocket-Key";        return r; }
    if (ws_protocol_hdr.empty())            { r.status = ParseResult::Status::Rejected; r.reject_reason = "missing Sec-WebSocket-Protocol";   return r; }

    r.request.sec_websocket_key = std::move(ws_key_hdr);

    // --- Extract bearer token from subprotocol ---------------------------
    //
    // The Sec-WebSocket-Protocol header value can be a comma-separated
    // list of offered subprotocols. We pick the first one that starts
    // with the fh-sim.v1.bearer prefix.
    //
    //   Sec-WebSocket-Protocol: fh-sim.v1.bearer.<JWT>[, other-proto]
    //
    // Per RFC 6455 §4.2.2 the server MUST select one of the client's
    // OFFERED subprotocol tokens verbatim; browsers (Chrome/Firefox)
    // abort the connection with close 1006 if the echoed token does
    // not appear in the offered list. We therefore keep the whole
    // "fh-sim.v1.bearer.<JWT>" as the chosen subprotocol string, and
    // extract the token separately for the auth layer.
    {
        std::string_view offered = ws_protocol_hdr;
        while (!offered.empty()) {
            std::size_t comma = offered.find(',');
            std::string_view one = (comma == std::string_view::npos)
                ? offered
                : offered.substr(0, comma);
            one = trim(one);
            if (one.size() > kSubprotocolPrefix.size()
                && one.substr(0, kSubprotocolPrefix.size()) == kSubprotocolPrefix
                && one[kSubprotocolPrefix.size()] == '.') {
                std::string_view token = one.substr(kSubprotocolPrefix.size() + 1);
                if (token.empty()) {
                    r.status = ParseResult::Status::Rejected;
                    r.reject_reason = "empty bearer token in subprotocol";
                    return r;
                }
                r.request.bearer_token.assign(token.data(), token.size());
                // Echo the FULL offered token back — required by browsers.
                r.request.chosen_subprotocol.assign(one.data(), one.size());
                break;
            }
            if (comma == std::string_view::npos) { break; }
            offered = offered.substr(comma + 1);
        }
    }

    if (r.request.bearer_token.empty()) {
        r.status = ParseResult::Status::Rejected;
        r.reject_reason = "no fh-sim.v1.bearer.<token> subprotocol offered";
        return r;
    }

    r.status = ParseResult::Status::Ok;
    return r;
}

// ---------------------------------------------------------------------------
// formatHandshakeResponse
// ---------------------------------------------------------------------------
std::string formatHandshakeResponse(const HandshakeRequest& req)
{
    if (req.sec_websocket_key.empty() || req.chosen_subprotocol.empty()) {
        return {};
    }
    const std::string accept = computeAcceptToken(req.sec_websocket_key);
    std::string out;
    out.reserve(160 + accept.size() + req.chosen_subprotocol.size());
    out.append("HTTP/1.1 101 Switching Protocols\r\n");
    out.append("Upgrade: websocket\r\n");
    out.append("Connection: Upgrade\r\n");
    out.append("Sec-WebSocket-Accept: ");
    out.append(accept);
    out.append("\r\n");
    out.append("Sec-WebSocket-Protocol: ");
    out.append(req.chosen_subprotocol);
    out.append("\r\n\r\n");
    return out;
}

// ---------------------------------------------------------------------------
// formatErrorResponse
// ---------------------------------------------------------------------------
std::string formatErrorResponse(int status_code, std::string_view reason)
{
    // Keep it minimal — no HTML, no HSTS, no CORS. This is the WebSocket
    // upgrade endpoint; anything not a WS request gets a terse error and
    // the transport closes the socket.
    const char* status_text = "Bad Request";
    switch (status_code) {
        case 400: status_text = "Bad Request";       break;
        case 401: status_text = "Unauthorized";      break;
        case 403: status_text = "Forbidden";         break;
        case 404: status_text = "Not Found";         break;
        case 405: status_text = "Method Not Allowed";break;
        case 426: status_text = "Upgrade Required";  break;
        case 500: status_text = "Internal Error";    break;
        default:  status_text = "Bad Request";       break;
    }

    std::string body(reason);
    if (!body.empty() && body.back() != '\n') { body.push_back('\n'); }

    std::string out;
    out.reserve(96 + body.size());
    out.append("HTTP/1.1 ");
    out.append(std::to_string(status_code));
    out.push_back(' ');
    out.append(status_text);
    out.append("\r\nContent-Type: text/plain; charset=utf-8\r\n"
               "Content-Length: ");
    out.append(std::to_string(body.size()));
    out.append("\r\nConnection: close\r\n\r\n");
    out.append(body);
    return out;
}

} // namespace fh::sim::net::ws
