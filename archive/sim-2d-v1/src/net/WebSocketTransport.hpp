// footballhome sim - Concrete WebSocket transport (Berkeley sockets + poll)
//
// Slice 8b: wires the byte-only codec (WebSocketFrame) and handshake
// parser (WebSocketHandshake) to real POSIX sockets. Single-threaded,
// poll(2)-based event loop — the SimServer drives it by calling
// `poll(timeout_ms)` once per tick. No hidden threads, no exceptions,
// deterministic ordering (fd iteration order is stable per poll call).
//
// Contract:
//   * `start()` binds + listens; use port=0 to get an ephemeral port and
//     read it back via `boundPort()` (used by tests).
//   * `poll(timeout_ms)` does: accept new fds → read ready sockets
//     (advance handshake or decode frames) → flush pending outbound.
//   * Handshake completes → `JwtVerifier::verify()` runs → on success
//     `onConnect(client_id, claims)` fires; on failure we send an HTTP
//     401 + close (no callback for rejected clients).
//   * `send()` appends to the client's outbound buffer; actual write
//     happens on the next `poll()` when the socket is POLLOUT-ready.
//   * Ping frames auto-Pong. Close frames trigger a Close reply + fd
//     close. Any protocol violation or oversize buffer disconnects.
//
// Backpressure limits (Config):
//   * Inbound cap protects against a client trickling a giant fake
//     handshake to exhaust memory.
//   * Outbound cap protects against a slow reader hoarding server RAM.
//   * Exceeding either → disconnect.

#pragma once

#include "auth/JwtVerifier.hpp"
#include "common/IdTypes.hpp"
#include "net/INetworkTransport.hpp"

#include <cstddef>
#include <cstdint>
#include <memory>
#include <span>
#include <string>
#include <unordered_map>
#include <vector>

namespace fh::sim::net::ws {

class WebSocketTransport final : public INetworkTransport {
public:
    struct Config {
        std::string   bind_address              = "127.0.0.1";
        std::uint16_t port                      = 0;
        int           backlog                   = 32;
        std::size_t   max_inbound_buffer_bytes  = 64u * 1024u;   // handshake < 8K, frame ≤ 1M
        std::size_t   max_outbound_buffer_bytes = 4u * 1024u * 1024u;
    };

    // `verifier` must outlive this transport (raw pointer, no ownership).
    // The verifier owns its own Clock (see JwtVerifier), so tests can
    // freeze time by constructing the verifier with a fake clock.
    WebSocketTransport(Config cfg, auth::JwtVerifier* verifier);
    ~WebSocketTransport() override;

    WebSocketTransport(const WebSocketTransport&)            = delete;
    WebSocketTransport& operator=(const WebSocketTransport&) = delete;
    WebSocketTransport(WebSocketTransport&&)                 = delete;
    WebSocketTransport& operator=(WebSocketTransport&&)      = delete;

    // Bind + listen. Returns false on failure (port in use, invalid
    // address, permission denied). No throws.
    bool start();

    // Close listener + all clients. Idempotent. Fires onDisconnect for
    // every currently-connected client.
    void stop();

    // Drive one iteration of the event loop. `timeout_ms == 0` returns
    // immediately if nothing is ready; `-1` blocks indefinitely.
    void poll(int timeout_ms) override;

    // Actual bound port after start() (useful when Config::port == 0).
    std::uint16_t boundPort() const noexcept { return bound_port_; }

    // INetworkTransport
    void setOnConnect(OnConnectFn f)       override { on_connect_    = std::move(f); }
    void setOnDisconnect(OnDisconnectFn f) override { on_disconnect_ = std::move(f); }
    void setOnMessage(OnMessageFn f)       override { on_message_    = std::move(f); }
    bool        send(ClientId, std::span<const std::uint8_t>) override;
    void        disconnect(ClientId)                          override;
    std::size_t clientCount() const                           override;

private:
    enum class Phase : std::uint8_t {
        Handshaking,   // reading HTTP Upgrade request bytes
        Open,          // WebSocket framing in effect
        Closing,       // Close frame sent/received; drain outbound then shut
    };

    struct ClientState {
        ClientId                  id;
        int                       fd;
        Phase                     phase;
        bool                      authenticated = false;  // set true only after JWT verified
        std::vector<std::uint8_t> inbound;
        std::vector<std::uint8_t> outbound;
        std::size_t               outbound_pos = 0;   // bytes already flushed to socket
        auth::JwtClaims           claims;    // populated after successful handshake
    };

    // --- socket ops ---------------------------------------------------
    bool  bindAndListen();
    void  acceptNewConnections();
    void  handleRead(int fd);
    void  handleWrite(int fd);
    void  closeClient(int fd, bool fire_disconnect);
    void  queueClose(int fd);        // deferred close (safe during iteration)

    // --- protocol ops -------------------------------------------------
    void  advanceHandshake(ClientState& c);
    void  advanceFrames(ClientState& c);
    void  queueOutbound(ClientState& c, std::span<const std::uint8_t> bytes);
    void  queueClosingFrame(ClientState& c);   // send Close + move to Closing

    // --- callbacks ----------------------------------------------------
    OnConnectFn    on_connect_;
    OnDisconnectFn on_disconnect_;
    OnMessageFn    on_message_;

    // --- state --------------------------------------------------------
    Config                                        config_;
    auth::JwtVerifier*                            verifier_ = nullptr;
    int                                           listen_fd_  = -1;
    std::uint16_t                                 bound_port_ = 0;
    ClientId                                      next_client_id_ = 1;
    std::unordered_map<int, ClientState>          clients_;         // fd → state
    std::unordered_map<ClientId, int>             id_to_fd_;
    std::vector<int>                              pending_close_;   // process at end of poll
};

} // namespace fh::sim::net::ws
