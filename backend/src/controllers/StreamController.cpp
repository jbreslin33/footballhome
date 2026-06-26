// =============================================================================
// StreamController  (Phase 13 — /api/stream)
// =============================================================================
#include "StreamController.h"

#include "../core/Router.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include "../services/LineupNotificationHub.h"

#include <sys/socket.h>
#include <unistd.h>

#include <cctype>
#include <cstdint>
#include <iostream>
#include <string>

#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {

// base64url → bytes.  Returns empty string on any malformed input.
// (Self-contained so StreamController doesn't depend on LeadsController.)
std::string b64UrlDecode(const std::string& in) {
    static const int8_t T[256] = {
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,
        52,53,54,55,56,57,58,59,60,61,-1,-1,-1, 0,-1,-1,
        -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,
        15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,
        -1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
        41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
    };
    std::string s = in;
    for (char& c : s) { if (c == '-') c = '+'; else if (c == '_') c = '/'; }
    while (s.size() % 4) s.push_back('=');

    std::string out;
    out.reserve((s.size() * 3) / 4);
    int val = 0, bits = -8;
    for (unsigned char c : s) {
        if (c == '=') break;
        int v = T[c];
        if (v < 0) return {};
        val = (val << 6) | v;
        bits += 6;
        if (bits >= 0) {
            out.push_back(static_cast<char>((val >> bits) & 0xFF));
            bits -= 8;
        }
    }
    return out;
}

// Extract `userId` from the payload segment of an alg:none JWT delivered as
// `?token=<jwt>`.  Returns 0 if the token is missing or unparseable; the
// caller treats 0 as "unauthorized" (matches Node: `if (!userId) return 401`).
int decodeUserIdFromQueryToken(const std::string& token) {
    if (token.empty()) return 0;
    auto first = token.find('.');
    if (first == std::string::npos) return 0;
    auto second = token.find('.', first + 1);
    std::string payload = (second == std::string::npos)
        ? token.substr(first + 1)
        : token.substr(first + 1, second - first - 1);

    std::string decoded = b64UrlDecode(payload);
    if (decoded.empty()) return 0;
    try {
        auto j = json::parse(decoded);
        if (!j.contains("userId")) return 0;
        const auto& u = j["userId"];
        if (u.is_number_integer())  return u.get<int>();
        if (u.is_number_unsigned()) return static_cast<int>(u.get<unsigned long long>());
        if (u.is_string()) {
            try { return std::stoi(u.get<std::string>()); }
            catch (const std::exception&) { return 0; }
        }
    } catch (const std::exception&) { return 0; }
    return 0;
}

// Write a fully-formed HTTP response (status line + headers + body) to fd
// and close it.  Used for the auth-failure path in the stream handler,
// where we need to short-circuit BEFORE the request thread returns control
// to the server (which would normally write a Response for us — but the
// stream takeover hook bypasses that).
void writeStatusAndClose(int fd, int status, const char* reason) {
    char buf[128];
    int n = std::snprintf(buf, sizeof(buf),
                          "HTTP/1.1 %d %s\r\nContent-Length: 0\r\n\r\n",
                          status, reason);
    if (n > 0) ::send(fd, buf, static_cast<size_t>(n), MSG_NOSIGNAL);
    ::close(fd);
}

}  // namespace

void StreamController::registerRoutes(Router& router, const std::string& prefix) {
    // Mounted at "/api" so this resolves to GET /api/stream.
    router.get(prefix + "/stream", [this](const Request& request) {
        return handleStream(request);
    });
}

Response StreamController::handleStream(const Request& request) {
    // Decode the alg:none JWT from ?token=.  EventSource can't set headers,
    // so the auth scheme moves to the query string here (the rest of the API
    // uses Authorization: Bearer).
    const std::string token  = request.getQueryParam("token");
    const int         userId = decodeUserIdFromQueryToken(token);

    Response resp(HttpStatus::OK);

    if (userId == 0) {
        // Take over the socket only to write 401 and close — we can't return
        // a normal Response from here because the route is meant to be
        // streaming, and dual-mode would clutter the server.  Doing it via
        // the stream handler keeps the takeover semantics uniform.
        resp.setStreamHandler([](int client_fd) {
            writeStatusAndClose(client_fd, 401, "Unauthorized");
        });
        return resp;
    }

    // Successful subscribe: write the SSE preamble + ": connected\n\n" and
    // hand the fd off to LineupNotificationHub.  Heartbeats and NOTIFY
    // payloads are then driven by the hub's listener thread.
    resp.setStreamHandler([](int client_fd) {
        static const char kPreamble[] =
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/event-stream\r\n"
            "Cache-Control: no-cache, no-transform\r\n"
            "Connection: keep-alive\r\n"
            "X-Accel-Buffering: no\r\n"
            "\r\n"
            ": connected\n\n";

        ssize_t n = ::send(client_fd, kPreamble, sizeof(kPreamble) - 1,
                           MSG_NOSIGNAL);
        if (n < 0) {
            // Client gave up between accept() and our first write.
            ::close(client_fd);
            return;
        }

        LineupNotificationHub::getInstance().subscribe(client_fd);
        // DO NOT close(fd) — the hub now owns it (and will close on the
        // next failed write).
    });
    return resp;
}
