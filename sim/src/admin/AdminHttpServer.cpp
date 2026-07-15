// footballhome sim — AdminHttpServer (implementation)
//
// See AdminHttpServer.hpp for the wire protocol, auth model, threading,
// and error contract. This file is the "just make it work" layer.
//
// Style notes:
//   * Every syscall gets its error checked. On failure we log to stderr
//     with the `[sim-admin]` prefix and either abort the connection or
//     the accept loop. No exceptions cross the loop boundary — the sim
//     tick thread must never be affected by an admin request.
//   * The HTTP parser is byte-safe: it never dereferences past the input
//     view, treats trailing garbage as malformed, and rejects any header
//     block larger than kMaxRequestBytes.
//   * The JSON parser is deliberately narrow: it accepts *exactly* the
//     three-field object shape documented in the header, in any field
//     order, with insignificant whitespace tolerated. Anything else is
//     a 400.

#include "admin/AdminHttpServer.hpp"

#include "match/CanonicalHash.hpp"
#include "tools/Replay.hpp"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <algorithm>
#include <cctype>
#include <cerrno>
#include <charconv>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <exception>
#include <iomanip>
#include <sstream>
#include <string>
#include <string_view>
#include <system_error>

namespace fh::sim::admin {

// ---------------------------------------------------------------------
// Small helpers (case-insensitive header matching, trim, hex format).
// ---------------------------------------------------------------------
namespace {

bool eqIgnoreCase(std::string_view a, std::string_view b) noexcept
{
    if (a.size() != b.size()) { return false; }
    for (std::size_t i = 0; i < a.size(); ++i) {
        const unsigned char ca = static_cast<unsigned char>(a[i]);
        const unsigned char cb = static_cast<unsigned char>(b[i]);
        if (std::tolower(ca) != std::tolower(cb)) { return false; }
    }
    return true;
}

std::string_view trim(std::string_view s) noexcept
{
    while (!s.empty()
        && (s.front() == ' ' || s.front() == '\t' ||
            s.front() == '\r' || s.front() == '\n')) { s.remove_prefix(1); }
    while (!s.empty()
        && (s.back()  == ' ' || s.back()  == '\t' ||
            s.back()  == '\r' || s.back()  == '\n')) { s.remove_suffix(1); }
    return s;
}

// Format a u64 hash as "0x016 hex chars".
std::string formatHashHex(std::uint64_t v)
{
    char buf[32];
    std::snprintf(buf, sizeof(buf), "0x%016lx", static_cast<unsigned long>(v));
    return std::string{buf};
}

// Convert a std::vector<std::byte> (canonical dump text) to std::string —
// canonical dumps are ASCII, so a byte-wise reinterpret is safe.
// (We keep this local rather than in a shared helper because it's the
// only place in sim that needs it.)
// NOTE: replayMatch already returns canonical_dump as std::string; this
// helper is here for symmetry with future opaque-bytes helpers.

// Set send/recv timeouts on an accepted client fd. 0 disables.
void setSocketTimeouts(int fd, int recv_ms, int send_ms) noexcept
{
    auto apply = [fd](int opt, int ms) {
        if (ms <= 0) { return; }
        struct timeval tv{};
        tv.tv_sec  = ms / 1000;
        tv.tv_usec = (ms % 1000) * 1000;
        ::setsockopt(fd, SOL_SOCKET, opt, &tv, sizeof(tv));
    };
    apply(SO_RCVTIMEO, recv_ms);
    apply(SO_SNDTIMEO, send_ms);
}

// Escape a JSON string value.
void jsonEscape(std::string& out, std::string_view v)
{
    out.push_back('"');
    for (char c : v) {
        switch (c) {
            case '"':  out.append("\\\""); break;
            case '\\': out.append("\\\\"); break;
            case '\b': out.append("\\b");  break;
            case '\f': out.append("\\f");  break;
            case '\n': out.append("\\n");  break;
            case '\r': out.append("\\r");  break;
            case '\t': out.append("\\t");  break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x",
                                  static_cast<unsigned int>(
                                      static_cast<unsigned char>(c)));
                    out.append(buf);
                } else {
                    out.push_back(c);
                }
        }
    }
    out.push_back('"');
}

// Compose a full HTTP response.
std::string makeHttpResponse(int status,
                             std::string_view status_text,
                             std::string_view json_body)
{
    std::string r;
    r.reserve(128 + json_body.size());
    r.append("HTTP/1.1 ").append(std::to_string(status)).push_back(' ');
    r.append(status_text).append("\r\n");
    r.append("Content-Type: application/json; charset=utf-8\r\n");
    r.append("Content-Length: ").append(std::to_string(json_body.size())).append("\r\n");
    r.append("Connection: close\r\n");
    r.append("\r\n");
    r.append(json_body);
    return r;
}

std::string errorJson(std::string_view code, std::string_view detail = {})
{
    std::string out;
    out.push_back('{');
    out.append("\"error\":");  jsonEscape(out, code);
    if (!detail.empty()) {
        out.append(",\"detail\":");
        jsonEscape(out, detail);
    }
    out.push_back('}');
    return out;
}

// Write the full buffer to `fd`, retrying on EINTR / short writes.
// Any error → false.
bool writeAll(int fd, std::string_view buf) noexcept
{
    const char*  p    = buf.data();
    std::size_t  left = buf.size();
    while (left > 0) {
        const ssize_t n = ::send(fd, p, left, MSG_NOSIGNAL);
        if (n < 0) {
            if (errno == EINTR) { continue; }
            return false;
        }
        if (n == 0) { return false; }
        p    += n;
        left -= static_cast<std::size_t>(n);
    }
    return true;
}

// One-line stderr access log entry.
void logAccess(std::string_view method,
               std::string_view path,
               int              status,
               std::size_t      body_bytes,
               long             elapsed_ms) noexcept
{
    std::fprintf(stderr,
                 "[sim-admin] %.*s %.*s -> %d (%zu bytes, %ld ms)\n",
                 static_cast<int>(method.size()), method.data(),
                 static_cast<int>(path.size()),   path.data(),
                 status,
                 body_bytes,
                 elapsed_ms);
}

// -----------------------------------------------------------------------
// JSON micro-parser — narrow-purpose, whitespace-tolerant, rejects
// anything outside the exact three-field object shape.
// -----------------------------------------------------------------------

void jskipWs(std::string_view& s) noexcept
{
    while (!s.empty()
        && (s.front() == ' ' || s.front() == '\t' ||
            s.front() == '\r' || s.front() == '\n')) { s.remove_prefix(1); }
}

// Parse a JSON string literal. Only supports ASCII printable + \" \\ \n \r \t
// (enough for our field names — we never call this for `emit_hex`
// values). Returns std::nullopt on any parse error.
std::optional<std::string> jparseString(std::string_view& s)
{
    jskipWs(s);
    if (s.empty() || s.front() != '"') { return std::nullopt; }
    s.remove_prefix(1);
    std::string out;
    while (!s.empty()) {
        const char c = s.front();
        s.remove_prefix(1);
        if (c == '"') { return out; }
        if (c == '\\') {
            if (s.empty()) { return std::nullopt; }
            const char esc = s.front();
            s.remove_prefix(1);
            switch (esc) {
                case '"':  out.push_back('"');  break;
                case '\\': out.push_back('\\'); break;
                case '/':  out.push_back('/');  break;
                case 'n':  out.push_back('\n'); break;
                case 'r':  out.push_back('\r'); break;
                case 't':  out.push_back('\t'); break;
                case 'b':  out.push_back('\b'); break;
                case 'f':  out.push_back('\f'); break;
                default:   return std::nullopt;  // \u escapes unsupported
            }
            continue;
        }
        out.push_back(c);
    }
    return std::nullopt;  // unterminated
}

// Parse an unsigned integer (u64 range). Consumes the digits it reads.
std::optional<std::uint64_t> jparseU64(std::string_view& s)
{
    jskipWs(s);
    if (s.empty() || s.front() < '0' || s.front() > '9') {
        return std::nullopt;
    }
    std::uint64_t v = 0;
    while (!s.empty() && s.front() >= '0' && s.front() <= '9') {
        const std::uint64_t d = static_cast<std::uint64_t>(s.front() - '0');
        // Overflow guard.
        if (v > (UINT64_MAX - d) / 10ull) { return std::nullopt; }
        v = v * 10ull + d;
        s.remove_prefix(1);
    }
    return v;
}

// Parse a JSON boolean literal.
std::optional<bool> jparseBool(std::string_view& s)
{
    jskipWs(s);
    if (s.substr(0, 4) == "true")  { s.remove_prefix(4); return true;  }
    if (s.substr(0, 5) == "false") { s.remove_prefix(5); return false; }
    return std::nullopt;
}

// Consume exactly the character `c` (with surrounding whitespace).
bool jexpect(std::string_view& s, char c) noexcept
{
    jskipWs(s);
    if (s.empty() || s.front() != c) { return false; }
    s.remove_prefix(1);
    return true;
}

} // namespace

// -----------------------------------------------------------------------
// Public: constantTimeEquals
// -----------------------------------------------------------------------
bool constantTimeEquals(std::string_view a, std::string_view b) noexcept
{
    if (a.size() != b.size()) { return false; }
    unsigned char acc = 0;
    for (std::size_t i = 0; i < a.size(); ++i) {
        // XOR of two `unsigned char` is promoted to `int`; cast the
        // result back down explicitly so -Wconversion stays clean.
        acc = static_cast<unsigned char>(
            acc | (static_cast<unsigned char>(a[i])
                 ^ static_cast<unsigned char>(b[i])));
    }
    return acc == 0;
}

// -----------------------------------------------------------------------
// Public: parseHttpRequest
//
// Rules (kept in sync with the header contract):
//   * request line: METHOD SP TARGET SP HTTP/1.1 CRLF
//   * header lines: NAME ":" [SP] VALUE CRLF
//   * empty line   : CRLF
//   * body         : exactly Content-Length bytes (0 if header absent)
// -----------------------------------------------------------------------
std::optional<ParsedRequest>
parseHttpRequest(std::string_view raw, std::string* reject_reason)
{
    auto reject = [&](std::string_view why) -> std::optional<ParsedRequest> {
        if (reject_reason) { reject_reason->assign(why); }
        return std::nullopt;
    };

    if (raw.size() > kMaxRequestBytes) {
        return reject("request too large");
    }

    const auto header_end = raw.find("\r\n\r\n");
    if (header_end == std::string_view::npos) {
        return reject("headers not terminated");
    }

    std::string_view head = raw.substr(0, header_end);
    std::string_view body = raw.substr(header_end + 4);

    // Request line.
    const auto crlf1 = head.find("\r\n");
    if (crlf1 == std::string_view::npos) { return reject("no request line"); }
    std::string_view req_line = head.substr(0, crlf1);
    head.remove_prefix(crlf1 + 2);

    const auto sp1 = req_line.find(' ');
    if (sp1 == std::string_view::npos) { return reject("malformed request line"); }
    const auto sp2 = req_line.find(' ', sp1 + 1);
    if (sp2 == std::string_view::npos) { return reject("malformed request line"); }

    ParsedRequest out;
    out.method = std::string{req_line.substr(0, sp1)};
    out.path   = std::string{req_line.substr(sp1 + 1, sp2 - sp1 - 1)};

    const std::string_view version = req_line.substr(sp2 + 1);
    if (version != "HTTP/1.1" && version != "HTTP/1.0") {
        return reject("unsupported HTTP version");
    }

    // Headers.
    std::optional<std::size_t> content_length;
    while (!head.empty()) {
        const auto crlf = head.find("\r\n");
        const std::string_view line =
            (crlf == std::string_view::npos) ? head : head.substr(0, crlf);
        if (line.empty()) { break; }

        const auto colon = line.find(':');
        if (colon == std::string_view::npos) { return reject("malformed header"); }
        const std::string_view name = line.substr(0, colon);
        const std::string_view val  = trim(line.substr(colon + 1));

        if (eqIgnoreCase(name, "Authorization")) {
            out.authorization.assign(val);
        } else if (eqIgnoreCase(name, "Content-Type")) {
            out.content_type.assign(val);
        } else if (eqIgnoreCase(name, "Content-Length")) {
            std::size_t   n = 0;
            const char*   b = val.data();
            const char*   e = val.data() + val.size();
            auto [ptr, ec]  = std::from_chars(b, e, n);
            if (ec != std::errc{} || ptr != e) {
                return reject("malformed Content-Length");
            }
            content_length = n;
        }

        if (crlf == std::string_view::npos) { break; }
        head.remove_prefix(crlf + 2);
    }

    const std::size_t declared = content_length.value_or(0);
    if (declared != body.size()) {
        return reject("Content-Length mismatch");
    }
    out.body.assign(body);
    return out;
}

// -----------------------------------------------------------------------
// Public: parseReplayJson
// -----------------------------------------------------------------------
std::optional<ReplayRequest>
parseReplayJson(std::string_view body, std::string* reject_reason)
{
    auto reject = [&](std::string_view why) -> std::optional<ReplayRequest> {
        if (reject_reason) { reject_reason->assign(why); }
        return std::nullopt;
    };

    std::string_view s = body;
    if (!jexpect(s, '{')) { return reject("expected '{'"); }

    ReplayRequest out;
    bool seen_match_id = false;
    bool first = true;
    jskipWs(s);
    while (!s.empty() && s.front() != '}') {
        if (!first) {
            if (!jexpect(s, ',')) { return reject("expected ','"); }
        }
        first = false;

        auto key = jparseString(s);
        if (!key)                { return reject("expected key"); }
        if (!jexpect(s, ':'))    { return reject("expected ':'"); }

        if (*key == "match_id") {
            auto v = jparseU64(s);
            if (!v) { return reject("match_id must be a positive integer"); }
            out.match_id = static_cast<MatchId>(*v);
            seen_match_id = true;
        } else if (*key == "up_to_tick") {
            auto v = jparseU64(s);
            if (!v)                 { return reject("up_to_tick must be a non-negative integer"); }
            if (*v > 0xFFFFFFFFull) { return reject("up_to_tick out of range"); }
            out.up_to_tick = static_cast<TickNum>(*v);
        } else if (*key == "emit_hex") {
            auto v = jparseBool(s);
            if (!v) { return reject("emit_hex must be true or false"); }
            out.emit_hex = *v;
        } else {
            return reject(std::string{"unknown field: "} + *key);
        }
        jskipWs(s);
    }
    if (!jexpect(s, '}')) { return reject("expected '}'"); }
    jskipWs(s);
    if (!s.empty()) { return reject("trailing garbage after JSON object"); }

    if (!seen_match_id) { return reject("match_id is required"); }
    if (out.match_id == 0u) { return reject("match_id must be > 0"); }
    return out;
}

// -----------------------------------------------------------------------
// Public: parseAssignMatchJson (§21.7 item 1 warm-daemon-pool
// scaffolding, 2026-07-15). Same narrow parser shape as
// parseReplayJson — three fields, any order, whitespace-tolerant, no
// unknown fields, no trailing garbage.
// -----------------------------------------------------------------------
std::optional<AssignMatchRequest>
parseAssignMatchJson(std::string_view body, std::string* reject_reason)
{
    auto reject = [&](std::string_view why) -> std::optional<AssignMatchRequest> {
        if (reject_reason) { reject_reason->assign(why); }
        return std::nullopt;
    };

    std::string_view s = body;
    if (!jexpect(s, '{')) { return reject("expected '{'"); }

    AssignMatchRequest out;
    bool seen_match_id    = false;
    bool seen_seed        = false;
    bool seen_scenario_id = false;
    bool first = true;
    jskipWs(s);
    while (!s.empty() && s.front() != '}') {
        if (!first) {
            if (!jexpect(s, ',')) { return reject("expected ','"); }
        }
        first = false;

        auto key = jparseString(s);
        if (!key)             { return reject("expected key"); }
        if (!jexpect(s, ':')) { return reject("expected ':'"); }

        if (*key == "match_id") {
            auto v = jparseU64(s);
            if (!v) { return reject("match_id must be a positive integer"); }
            out.match_id = static_cast<MatchId>(*v);
            seen_match_id = true;
        } else if (*key == "seed") {
            auto v = jparseU64(s);
            if (!v) { return reject("seed must be a non-negative integer"); }
            out.seed = *v;
            seen_seed = true;
        } else if (*key == "scenario_id") {
            auto v = jparseU64(s);
            if (!v) { return reject("scenario_id must be a non-negative integer"); }
            // Wire parser only enforces i16 range; the handler is
            // responsible for checking the value actually names a
            // scenario for the current milestone.
            if (*v > 32767ull) { return reject("scenario_id out of range"); }
            out.scenario_id = static_cast<std::int16_t>(*v);
            seen_scenario_id = true;
        } else {
            return reject(std::string{"unknown field: "} + *key);
        }
        jskipWs(s);
    }
    if (!jexpect(s, '}')) { return reject("expected '}'"); }
    jskipWs(s);
    if (!s.empty()) { return reject("trailing garbage after JSON object"); }

    if (!seen_match_id)    { return reject("match_id is required"); }
    if (!seen_seed)        { return reject("seed is required"); }
    if (!seen_scenario_id) { return reject("scenario_id is required"); }
    if (out.match_id == 0u) { return reject("match_id must be > 0"); }
    return out;
}

// -----------------------------------------------------------------------
// AdminHttpServer
// -----------------------------------------------------------------------

AdminHttpServer::AdminHttpServer(const Config& cfg,
                                 persistence::IPgClient& db)
    : cfg_(cfg), db_(db)
{}

AdminHttpServer::~AdminHttpServer()
{
    stop();
}

bool AdminHttpServer::start()
{
    if (running_.load(std::memory_order_acquire)) { return true; }

    if (cfg_.admin_token.empty()) {
        std::fprintf(stderr,
            "[sim-admin] refusing to start: FH_SIM_ADMIN_TOKEN is empty "
            "(set the env var to enable /admin/replay)\n");
        return false;
    }

    const int fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        std::fprintf(stderr,
            "[sim-admin] socket() failed: %s\n", std::strerror(errno));
        return false;
    }

    // Reuse address so restart-after-crash doesn't hit TIME_WAIT.
    int one = 1;
    ::setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(cfg_.port);
    if (::inet_pton(AF_INET, cfg_.bind_address.c_str(), &addr.sin_addr) != 1) {
        std::fprintf(stderr,
            "[sim-admin] invalid bind_address '%s'\n",
            cfg_.bind_address.c_str());
        ::close(fd);
        return false;
    }

    if (::bind(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) < 0) {
        std::fprintf(stderr,
            "[sim-admin] bind %s:%u failed: %s\n",
            cfg_.bind_address.c_str(),
            static_cast<unsigned>(cfg_.port),
            std::strerror(errno));
        ::close(fd);
        return false;
    }

    if (::listen(fd, cfg_.backlog) < 0) {
        std::fprintf(stderr,
            "[sim-admin] listen() failed: %s\n", std::strerror(errno));
        ::close(fd);
        return false;
    }

    // Read back the actual port (matters when cfg_.port == 0).
    sockaddr_in bound{};
    socklen_t   blen = sizeof(bound);
    if (::getsockname(fd,
                      reinterpret_cast<sockaddr*>(&bound),
                      &blen) == 0)
    {
        bound_port_ = ntohs(bound.sin_port);
    } else {
        bound_port_ = cfg_.port;
    }

    listen_fd_ = fd;
    stopping_.store(false, std::memory_order_release);
    running_.store(true, std::memory_order_release);
    worker_ = std::thread{&AdminHttpServer::acceptLoop, this};

    std::fprintf(stderr,
        "[sim-admin] listening on %s:%u  (POST /admin/replay%s%s)\n",
        cfg_.bind_address.c_str(),
        static_cast<unsigned>(bound_port_),
        cfg_.tick_stats_provider    ? ", GET /admin/tick_stats"    : "",
        cfg_.assign_match_handler   ? ", POST /admin/assign_match" : "");
    return true;
}

void AdminHttpServer::stop() noexcept
{
    if (!running_.load(std::memory_order_acquire)) { return; }
    stopping_.store(true, std::memory_order_release);
    // Shutdown + close the listen fd so accept() returns.
    if (listen_fd_ >= 0) {
        ::shutdown(listen_fd_, SHUT_RDWR);
        ::close(listen_fd_);
        listen_fd_ = -1;
    }
    if (worker_.joinable()) { worker_.join(); }
    running_.store(false, std::memory_order_release);
    bound_port_ = 0;
    std::fprintf(stderr, "[sim-admin] stopped\n");
}

void AdminHttpServer::acceptLoop()
{
    while (!stopping_.load(std::memory_order_acquire)) {
        sockaddr_in peer{};
        socklen_t   plen = sizeof(peer);
        const int client_fd =
            ::accept(listen_fd_,
                     reinterpret_cast<sockaddr*>(&peer),
                     &plen);
        if (client_fd < 0) {
            if (stopping_.load(std::memory_order_acquire)) { return; }
            if (errno == EINTR) { continue; }
            std::fprintf(stderr,
                "[sim-admin] accept() failed: %s\n", std::strerror(errno));
            continue;
        }

        setSocketTimeouts(client_fd,
                          cfg_.read_timeout_ms,
                          cfg_.write_timeout_ms);
        handleConnection(client_fd);
        ::close(client_fd);
    }
}

void AdminHttpServer::handleConnection(int client_fd) noexcept
{
    const auto t0 = std::chrono::steady_clock::now();

    // ------------------------------------------------------------------
    // Read the full request, respecting kMaxRequestBytes.
    // ------------------------------------------------------------------
    std::string buf;
    buf.reserve(1024);

    std::string method_dash = "-";
    std::string path_dash   = "-";

    auto sendAndLog = [&](int status,
                          std::string_view status_text,
                          std::string_view json_body) {
        const std::string resp = makeHttpResponse(status, status_text, json_body);
        (void)writeAll(client_fd, resp);
        const auto t1 = std::chrono::steady_clock::now();
        const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
            t1 - t0).count();
        logAccess(method_dash, path_dash, status, json_body.size(),
                  static_cast<long>(ms));
    };

    while (true) {
        char tmp[2048];
        const ssize_t n = ::recv(client_fd, tmp, sizeof(tmp), 0);
        if (n < 0) {
            if (errno == EINTR) { continue; }
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                sendAndLog(408, "Request Timeout",
                           errorJson("request timeout"));
                return;
            }
            return;  // hard read failure; abandon
        }
        if (n == 0) { break; }  // peer closed

        if (buf.size() + static_cast<std::size_t>(n) > kMaxRequestBytes) {
            sendAndLog(413, "Payload Too Large",
                       errorJson("payload too large"));
            return;
        }
        buf.append(tmp, static_cast<std::size_t>(n));

        // Fast exit as soon as we have headers + declared body length.
        const auto hend = buf.find("\r\n\r\n");
        if (hend != std::string::npos) {
            // Peek Content-Length so we don't wait forever on a slow client.
            std::size_t need_body = 0;
            {
                std::string_view head{buf.data(), hend};
                std::size_t pos = 0;
                while (pos < head.size()) {
                    const auto nl = head.find("\r\n", pos);
                    const std::string_view line = (nl == std::string_view::npos)
                        ? head.substr(pos)
                        : head.substr(pos, nl - pos);
                    const auto colon = line.find(':');
                    if (colon != std::string_view::npos) {
                        const auto name = line.substr(0, colon);
                        const auto val  = trim(line.substr(colon + 1));
                        if (eqIgnoreCase(name, "Content-Length")) {
                            const char* b = val.data();
                            const char* e = val.data() + val.size();
                            std::size_t v = 0;
                            auto [p, ec] = std::from_chars(b, e, v);
                            if (ec == std::errc{} && p == e) {
                                need_body = v;
                            }
                        }
                    }
                    if (nl == std::string_view::npos) { break; }
                    pos = nl + 2;
                }
            }
            if (buf.size() >= hend + 4 + need_body) { break; }
        }
    }

    // ------------------------------------------------------------------
    // Parse.
    // ------------------------------------------------------------------
    std::string why;
    auto parsed = parseHttpRequest(buf, &why);
    if (!parsed) {
        sendAndLog(400, "Bad Request", errorJson("bad request", why));
        return;
    }
    method_dash = parsed->method;
    path_dash   = parsed->path;

    // ------------------------------------------------------------------
    // Route. §21.7 item 2 (2026-07-14) added GET /admin/tick_stats
    // alongside the pre-existing POST /admin/replay. §21.7 item 1
    // (2026-07-15) added POST /admin/assign_match. When
    // Config::tick_stats_provider or Config::assign_match_handler is
    // unset the corresponding route is treated as if it didn't exist
    // (same 404 shape as any other unknown path) so unauthenticated
    // probes can't learn whether the surface was wired.
    // ------------------------------------------------------------------
    const bool is_replay =
        (parsed->method == "POST" && parsed->path == "/admin/replay");
    const bool is_tick_stats =
        (parsed->method == "GET"  && parsed->path == "/admin/tick_stats"
         && static_cast<bool>(cfg_.tick_stats_provider));
    const bool is_assign_match =
        (parsed->method == "POST" && parsed->path == "/admin/assign_match"
         && static_cast<bool>(cfg_.assign_match_handler));
    if (!is_replay && !is_tick_stats && !is_assign_match) {
        const bool known_path =
            (parsed->path == "/admin/replay")
         || (parsed->path == "/admin/tick_stats"
             && static_cast<bool>(cfg_.tick_stats_provider))
         || (parsed->path == "/admin/assign_match"
             && static_cast<bool>(cfg_.assign_match_handler));
        if (!known_path) {
            sendAndLog(404, "Not Found", errorJson("not found"));
        } else {
            sendAndLog(405, "Method Not Allowed",
                       errorJson("method not allowed"));
        }
        return;
    }

    // ------------------------------------------------------------------
    // Auth (both routes require the same bearer).
    // ------------------------------------------------------------------
    constexpr std::string_view kBearer = "Bearer ";
    if (parsed->authorization.size() <= kBearer.size()
        || parsed->authorization.substr(0, kBearer.size()) != kBearer)
    {
        sendAndLog(401, "Unauthorized", errorJson("unauthorized"));
        return;
    }
    const std::string_view token =
        std::string_view{parsed->authorization}.substr(kBearer.size());
    if (!constantTimeEquals(token, cfg_.admin_token)) {
        sendAndLog(403, "Forbidden", errorJson("forbidden"));
        return;
    }

    // ------------------------------------------------------------------
    // /admin/tick_stats handler (auth already passed).
    // ------------------------------------------------------------------
    if (is_tick_stats) {
        std::string body;
        try {
            body = cfg_.tick_stats_provider();
        } catch (const std::exception& e) {
            sendAndLog(500, "Internal Server Error",
                       errorJson("internal error", e.what()));
            return;
        }
        sendAndLog(200, "OK", body);
        return;
    }

    // ------------------------------------------------------------------
    // /admin/assign_match handler (auth already passed). §21.7 item 1
    // warm-daemon-pool scaffolding (2026-07-15).
    // ------------------------------------------------------------------
    if (is_assign_match) {
        auto req = parseAssignMatchJson(parsed->body, &why);
        if (!req) {
            sendAndLog(400, "Bad Request", errorJson("bad request", why));
            return;
        }
        AssignMatchResult res;
        try {
            res = cfg_.assign_match_handler(*req);
        } catch (const std::exception& e) {
            sendAndLog(500, "Internal Server Error",
                       errorJson("internal error", e.what()));
            return;
        }
        if (res.outcome == AssignMatchOutcome::kConflict) {
            // Canonical body — handler's body_json is intentionally
            // ignored on conflict so the wire shape is stable across
            // handlers.
            sendAndLog(409, "Conflict",
                       errorJson("already assigned"));
            return;
        }
        // kOk: handler's body_json used verbatim.
        sendAndLog(200, "OK", res.body_json);
        return;
    }

    // ------------------------------------------------------------------
    // Parse body.
    // ------------------------------------------------------------------
    auto req = parseReplayJson(parsed->body, &why);
    if (!req) {
        sendAndLog(400, "Bad Request", errorJson("bad request", why));
        return;
    }

    // ------------------------------------------------------------------
    // Run replay.
    // ------------------------------------------------------------------
    tools::ReplayOptions opts;
    opts.up_to_tick   = req->up_to_tick;
    opts.collect_dump = req->emit_hex;

    tools::ReplayResult result;
    try {
        result = tools::replayMatch(db_, req->match_id, opts);
    } catch (const std::exception& e) {
        // Map "match not found" vs generic DB/replay failure by prefix
        // — Replay throws std::runtime_error("replayMatch: match_id=…
        // not found in sim_matches") in that case.
        const std::string msg{e.what()};
        if (msg.find("not found") != std::string::npos) {
            std::string body;
            body.push_back('{');
            body.append("\"error\":\"match not found\",\"match_id\":");
            body.append(std::to_string(req->match_id));
            body.push_back('}');
            sendAndLog(404, "Not Found", body);
        } else {
            sendAndLog(500, "Internal Server Error",
                       errorJson("internal error", msg));
        }
        return;
    }

    // ------------------------------------------------------------------
    // Build success body.
    // ------------------------------------------------------------------
    std::string body;
    body.reserve(256 + result.canonical_dump.size());
    body.push_back('{');
    body.append("\"match_id\":");         body.append(std::to_string(req->match_id));
    body.append(",\"final_tick\":");      body.append(std::to_string(result.final_tick));
    body.append(",\"hash_hex\":");        jsonEscape(body, formatHashHex(result.canonical_hash));
    body.append(",\"hash_u64\":");        body.append(std::to_string(result.canonical_hash));
    body.append(",\"inputs_applied\":");  body.append(std::to_string(result.inputs_applied));
    body.append(",\"slots_synthesized\":"); body.append(std::to_string(result.slots_synthesized));
    if (req->emit_hex) {
        body.append(",\"canonical_hex\":");
        jsonEscape(body, result.canonical_dump);
    }
    body.push_back('}');

    sendAndLog(200, "OK", body);
}

} // namespace fh::sim::admin
