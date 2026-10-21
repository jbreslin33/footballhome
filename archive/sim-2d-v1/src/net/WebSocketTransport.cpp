// footballhome sim - WebSocket transport (POSIX sockets + poll)

#include "net/WebSocketTransport.hpp"

#include "net/WebSocketFrame.hpp"
#include "net/WebSocketHandshake.hpp"

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
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <span>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace fh::sim::net::ws {

namespace {

// ---------------------------------------------------------------------------
// Socket helpers. All errno-driven; no throws.
// ---------------------------------------------------------------------------
bool setNonBlocking(int fd) noexcept {
    const int flags = ::fcntl(fd, F_GETFL, 0);
    if (flags < 0) { return false; }
    return ::fcntl(fd, F_SETFL, flags | O_NONBLOCK) == 0;
}

void setNoDelay(int fd) noexcept {
    // TCP_NODELAY off Nagle — snapshot frames are 374 bytes at 20 Hz and
    // we don't want them coalesced with the next tick's data.
    const int one = 1;
    (void)::setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
}

void setReuseAddr(int fd) noexcept {
    const int one = 1;
    (void)::setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
}

// A short read/write that got interrupted or would block is not fatal.
bool wouldBlock(int e) noexcept {
    return e == EAGAIN || e == EWOULDBLOCK || e == EINTR;
}

} // namespace

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------
WebSocketTransport::WebSocketTransport(Config cfg, auth::JwtVerifier* verifier)
    : config_(std::move(cfg))
    , verifier_(verifier)
{}

WebSocketTransport::~WebSocketTransport() {
    stop();
}

bool WebSocketTransport::start() {
    if (listen_fd_ >= 0) { return false; }   // already started
    if (verifier_ == nullptr) { return false; }
    return bindAndListen();
}

void WebSocketTransport::stop() {
    // Snapshot fds so callback re-entrancy can't mutate under us.
    std::vector<int> fds;
    fds.reserve(clients_.size());
    for (const auto& kv : clients_) { fds.push_back(kv.first); }
    for (const int fd : fds) { closeClient(fd, /*fire_disconnect=*/true); }

    if (listen_fd_ >= 0) {
        ::close(listen_fd_);
        listen_fd_ = -1;
    }
    bound_port_ = 0;
    pending_close_.clear();
}

bool WebSocketTransport::bindAndListen() {
    const int fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) { return false; }

    setReuseAddr(fd);
    if (!setNonBlocking(fd)) { ::close(fd); return false; }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(config_.port);
    if (::inet_pton(AF_INET, config_.bind_address.c_str(), &addr.sin_addr) != 1) {
        ::close(fd);
        return false;
    }

    if (::bind(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
        ::close(fd);
        return false;
    }
    if (::listen(fd, config_.backlog) != 0) {
        ::close(fd);
        return false;
    }

    // Read back the actual bound port (needed when Config::port == 0).
    sockaddr_in bound{};
    socklen_t bound_len = sizeof(bound);
    if (::getsockname(fd, reinterpret_cast<sockaddr*>(&bound), &bound_len) == 0) {
        bound_port_ = ntohs(bound.sin_port);
    } else {
        bound_port_ = config_.port;
    }

    listen_fd_ = fd;
    return true;
}

// ---------------------------------------------------------------------------
// Event loop
// ---------------------------------------------------------------------------
void WebSocketTransport::poll(int timeout_ms) {
    if (listen_fd_ < 0) { return; }

    // Build pollfds: listener first, then every client. `POLLOUT` only
    // if the client has data to flush — avoids spinning on ready-to-write
    // sockets with nothing to send.
    std::vector<pollfd> pfds;
    pfds.reserve(clients_.size() + 1u);
    pfds.push_back({listen_fd_, POLLIN, 0});
    for (const auto& kv : clients_) {
        short events = POLLIN;
        const auto& st = kv.second;
        if (st.outbound_pos < st.outbound.size()) { events |= POLLOUT; }
        pfds.push_back({kv.first, events, 0});
    }

    const int n = ::poll(pfds.data(), pfds.size(), timeout_ms);
    // n < 0 (EINTR / EBADF), n == 0 (no I/O ready). Either way we STILL
    // need to drain pending_close_ below — a queueClose() from a caller
    // (e.g. disconnect(cid)) must fire onDisconnect even on an idle loop.
    if (n > 0) {
        for (const auto& pfd : pfds) {
            if (pfd.revents == 0) { continue; }

            if (pfd.fd == listen_fd_) {
                if (pfd.revents & POLLIN) { acceptNewConnections(); }
                continue;
            }

            // Client fd. Handle read before write so we react to Close/Ping
            // in the same pass.
            if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) {
                queueClose(pfd.fd);
                continue;
            }
            if (pfd.revents & POLLIN)  { handleRead(pfd.fd); }
            if (pfd.revents & POLLOUT) { handleWrite(pfd.fd); }
        }
    }

    // Deferred closes so we never invalidate `clients_` during iteration.
    if (!pending_close_.empty()) {
        // Copy & clear first: a callback triggered by closeClient could
        // enqueue further closes; those should be processed next poll.
        std::vector<int> to_close;
        to_close.swap(pending_close_);
        for (const int fd : to_close) {
            closeClient(fd, /*fire_disconnect=*/true);
        }
    }
}

void WebSocketTransport::acceptNewConnections() {
    for (;;) {
        sockaddr_in peer{};
        socklen_t   peer_len = sizeof(peer);
        const int   cfd = ::accept(listen_fd_,
                                   reinterpret_cast<sockaddr*>(&peer), &peer_len);
        if (cfd < 0) {
            // EAGAIN → drained the accept queue; anything else → ignore.
            return;
        }
        if (!setNonBlocking(cfd)) { ::close(cfd); continue; }
        setNoDelay(cfd);

        ClientState st{};
        st.id    = next_client_id_++;
        st.fd    = cfd;
        st.phase = Phase::Handshaking;
        st.inbound.reserve(1024);
        clients_.emplace(cfd, std::move(st));
        id_to_fd_.emplace(clients_.at(cfd).id, cfd);
    }
}

void WebSocketTransport::handleRead(int fd) {
    auto it = clients_.find(fd);
    if (it == clients_.end()) { return; }
    ClientState& c = it->second;

    // Drain the socket until EAGAIN. Bounded per-call by max_inbound so
    // one hyperactive client can't starve the loop.
    std::uint8_t buf[4096];
    for (;;) {
        const ssize_t r = ::recv(fd, buf, sizeof(buf), 0);
        if (r > 0) {
            if (c.inbound.size() + static_cast<std::size_t>(r)
                > config_.max_inbound_buffer_bytes) {
                queueClose(fd);
                return;
            }
            c.inbound.insert(c.inbound.end(), buf, buf + r);
            continue;
        }
        if (r == 0) {
            // Peer closed cleanly.
            queueClose(fd);
            return;
        }
        // r < 0
        if (wouldBlock(errno)) { break; }
        queueClose(fd);
        return;
    }

    // Advance the state machine on whatever we buffered.
    if (c.phase == Phase::Handshaking) {
        advanceHandshake(c);
    }
    // Frames are only meaningful while the connection is fully Open.
    // If the handshake failed we're now in Closing with the HTTP error
    // response in outbound; treating leftover request bytes as frames
    // would misfire the strict frame validator.
    if (c.phase == Phase::Open) {
        advanceFrames(c);
    }
}

void WebSocketTransport::handleWrite(int fd) {
    auto it = clients_.find(fd);
    if (it == clients_.end()) { return; }
    ClientState& c = it->second;

    while (c.outbound_pos < c.outbound.size()) {
        const std::size_t remaining = c.outbound.size() - c.outbound_pos;
        const ssize_t w = ::send(fd,
                                 c.outbound.data() + c.outbound_pos,
                                 remaining,
                                 MSG_NOSIGNAL);
        if (w > 0) {
            c.outbound_pos += static_cast<std::size_t>(w);
            continue;
        }
        if (w < 0 && wouldBlock(errno)) { return; }
        // Fatal write error.
        queueClose(fd);
        return;
    }

    // Fully drained — reset the buffer to avoid unbounded growth.
    c.outbound.clear();
    c.outbound_pos = 0;

    // If we were Closing and the outbound drained, we can close now.
    if (c.phase == Phase::Closing) { queueClose(fd); }
}

void WebSocketTransport::queueClose(int fd) {
    // Idempotent — duplicate enqueues are fine; closeClient guards.
    pending_close_.push_back(fd);
}

void WebSocketTransport::closeClient(int fd, bool fire_disconnect) {
    auto it = clients_.find(fd);
    if (it == clients_.end()) { return; }
    const ClientId cid            = it->second.id;
    const bool     was_authenticated = it->second.authenticated;
    clients_.erase(it);
    id_to_fd_.erase(cid);
    // shutdown(SHUT_WR) sends a proper FIN with all queued data intact.
    // close() alone can send RST if there's any unread data still buffered
    // on either side. We rely on the peer noticing EOF and closing back.
    ::shutdown(fd, SHUT_WR);
    ::close(fd);

    // Only fire onDisconnect if the client ever completed authentication.
    // Symmetric with onConnect: rejected handshakes trigger neither callback.
    if (fire_disconnect && was_authenticated && on_disconnect_) {
        on_disconnect_(cid);
    }
}

// ---------------------------------------------------------------------------
// Handshake
// ---------------------------------------------------------------------------
void WebSocketTransport::advanceHandshake(ClientState& c) {
    const std::string_view view(reinterpret_cast<const char*>(c.inbound.data()),
                                c.inbound.size());
    const ParseResult pr = parseHandshakeRequest(view);

    if (pr.status == ParseResult::Status::NeedMore) { return; }

    if (pr.status == ParseResult::Status::Malformed
     || pr.status == ParseResult::Status::Rejected) {
        // 400 covers both cases: a malformed HTTP request and a request
        // that was syntactically OK but violated a WebSocket policy.
        const std::string resp = formatErrorResponse(400, pr.reject_reason);
        queueOutbound(c, std::span<const std::uint8_t>(
            reinterpret_cast<const std::uint8_t*>(resp.data()), resp.size()));
        // Drain outbound, then close. Discard leftover inbound — anything
        // there was HTTP-adjacent junk we’re not going to interpret.
        c.inbound.clear();
        c.phase = Phase::Closing;
        return;
    }

    // Ok: verify the JWT.
    const auto claims_opt = verifier_->verify(pr.request.bearer_token);
    if (!claims_opt.has_value()) {
        const std::string resp = formatErrorResponse(401, "invalid bearer token");
        queueOutbound(c, std::span<const std::uint8_t>(
            reinterpret_cast<const std::uint8_t*>(resp.data()), resp.size()));
        c.inbound.clear();
        c.phase = Phase::Closing;
        return;
    }

    // Send 101 Switching Protocols + move to Open.
    const std::string resp = formatHandshakeResponse(pr.request);
    if (resp.empty()) {
        // Should be impossible on a valid parse. Treat as fatal.
        queueClose(c.fd);
        return;
    }
    queueOutbound(c, std::span<const std::uint8_t>(
        reinterpret_cast<const std::uint8_t*>(resp.data()), resp.size()));
    c.claims        = *claims_opt;
    c.authenticated = true;
    c.phase         = Phase::Open;

    // Consume the request bytes from the inbound buffer. Any trailing
    // bytes are the first client frame — advanceFrames will pick them up.
    c.inbound.erase(c.inbound.begin(),
                    c.inbound.begin()
                    + static_cast<std::ptrdiff_t>(pr.bytes_consumed));

    if (on_connect_) { on_connect_(c.id, c.claims); }
}

// ---------------------------------------------------------------------------
// Frame dispatch
// ---------------------------------------------------------------------------
void WebSocketTransport::advanceFrames(ClientState& c) {
    for (;;) {
        if (c.inbound.empty()) { return; }
        const std::span<const std::uint8_t> view(c.inbound.data(), c.inbound.size());
        const DecodedFrame f = decodeClientFrame(view);

        if (f.status == DecodedFrame::Status::NeedMore) { return; }
        if (f.status == DecodedFrame::Status::Error) {
            // RFC 6455 §7.4 — 1002 protocol error. Just close hard; the
            // client already violated protocol so we don't owe them a
            // graceful Close.
            queueClose(c.fd);
            return;
        }

        // Ok — consume header + payload from inbound.
        c.inbound.erase(c.inbound.begin(),
                        c.inbound.begin()
                        + static_cast<std::ptrdiff_t>(f.bytes_consumed));

        switch (f.opcode) {
            case Opcode::Binary: {
                if (c.phase == Phase::Open && on_message_) {
                    on_message_(c.id, std::span<const std::uint8_t>(
                        f.payload.data(), f.payload.size()));
                }
                break;
            }
            case Opcode::Ping: {
                // RFC §5.5.2 — reply Pong with identical payload.
                const auto reply = encodeServerFrame(Opcode::Pong, f.payload);
                queueOutbound(c, reply);
                break;
            }
            case Opcode::Pong: {
                // Ignore — we don't send Pings yet (heartbeats are a
                // future concern).
                break;
            }
            case Opcode::Close: {
                // Echo Close and shut down.
                queueClosingFrame(c);
                return;
            }
            default: {
                // Text / Continuation / reserved — decodeClientFrame already
                // rejected these, but belt-and-suspenders:
                queueClose(c.fd);
                return;
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Outbound helpers
// ---------------------------------------------------------------------------
void WebSocketTransport::queueOutbound(ClientState& c,
                                       std::span<const std::uint8_t> bytes) {
    if (bytes.empty()) { return; }
    // If backlog + new payload exceeds cap → treat client as dead.
    const std::size_t pending = c.outbound.size() - c.outbound_pos;
    if (pending + bytes.size() > config_.max_outbound_buffer_bytes) {
        queueClose(c.fd);
        return;
    }

    // Compact the buffer if the write position drifted far enough that
    // trailing capacity would be wasted.
    if (c.outbound_pos > 0
     && (c.outbound.size() - c.outbound_pos) < c.outbound_pos) {
        c.outbound.erase(c.outbound.begin(),
                         c.outbound.begin()
                         + static_cast<std::ptrdiff_t>(c.outbound_pos));
        c.outbound_pos = 0;
    }
    c.outbound.insert(c.outbound.end(), bytes.begin(), bytes.end());
}

void WebSocketTransport::queueClosingFrame(ClientState& c) {
    // Empty Close body — some clients require a status code. RFC allows
    // empty; if browsers get picky we can add {0x03, 0xE8} for 1000.
    const auto close_frame = encodeServerFrame(Opcode::Close,
                                               std::span<const std::uint8_t>{});
    queueOutbound(c, close_frame);
    c.phase = Phase::Closing;
}

// ---------------------------------------------------------------------------
// INetworkTransport public API
// ---------------------------------------------------------------------------
bool WebSocketTransport::send(ClientId cid, std::span<const std::uint8_t> payload) {
    const auto it = id_to_fd_.find(cid);
    if (it == id_to_fd_.end()) { return false; }
    auto cit = clients_.find(it->second);
    if (cit == clients_.end()) { return false; }
    ClientState& c = cit->second;
    if (c.phase != Phase::Open) { return false; }

    const auto frame = encodeServerBinary(payload);
    if (frame.empty()) { return false; }   // oversize or encoder failure
    queueOutbound(c, frame);
    return true;
}

void WebSocketTransport::disconnect(ClientId cid) {
    const auto it = id_to_fd_.find(cid);
    if (it == id_to_fd_.end()) { return; }
    queueClose(it->second);
}

std::size_t WebSocketTransport::clientCount() const {
    return clients_.size();
}

} // namespace fh::sim::net::ws
