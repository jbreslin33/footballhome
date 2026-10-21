// footballhome sim - Network transport interface
//
// SimServer talks to the outside world exclusively through this. The M0
// production impl is WebSocketTransport (RFC 6455 over TCP). Tests use
// an in-memory FakeTransport that plays scripts against SimServer without
// touching sockets.
//
// Design notes:
//   * Handshake / authentication happens BEFORE onConnect fires. By the
//     time SimServer sees the callback, JWT is already verified and the
//     JwtClaims are attached. Downstream code never needs to think about
//     unauthenticated clients.
//   * Messages are opaque byte blobs — the transport doesn't know or
//     care about the SNAPSHOT/INPUT/etc. structure. That's the wire-
//     serializer's job (§7.1).
//   * Callbacks fire on the transport's own thread. Slice 9 will
//     define whether that's a single event loop or a pool; the interface
//     itself is agnostic. Implementations MUST NOT invoke a callback
//     that's currently executing (no re-entrancy).
//
// See DESIGN.md §5.5, §7, §13.

#pragma once

#include "auth/JwtVerifier.hpp"
#include "common/IdTypes.hpp"

#include <cstddef>
#include <cstdint>
#include <functional>
#include <span>

namespace fh::sim::net {

class INetworkTransport {
public:
    // Fires once per accepted client, AFTER JWT verification. The claims
    // are owned by the transport but stable for the callback duration —
    // callee should copy anything it wants to keep beyond the call.
    using OnConnectFn    = std::function<void(ClientId, const auth::JwtClaims&)>;
    using OnDisconnectFn = std::function<void(ClientId)>;
    using OnMessageFn    = std::function<void(ClientId, std::span<const std::uint8_t>)>;

    virtual ~INetworkTransport() = default;

    // All setters MUST be called before any I/O begins (constructor
    // completes → setters → run/serve). Post-hoc reconfiguration is
    // not supported by design; the concrete transport is free to
    // assert/abort if a setter is called after connections exist.
    virtual void setOnConnect(OnConnectFn)       = 0;
    virtual void setOnDisconnect(OnDisconnectFn) = 0;
    virtual void setOnMessage(OnMessageFn)       = 0;

    // Send an already-framed application payload (typically the output
    // of a Serializer::serialize call). Returns false only if the client
    // is already gone; a queued/flushed distinction is not exposed at
    // this layer.
    virtual bool send(ClientId, std::span<const std::uint8_t>) = 0;

    // Force-close a client. onDisconnect will fire.
    virtual void disconnect(ClientId) = 0;

    // Live client count. Useful for /health and shutdown draining.
    virtual std::size_t clientCount() const = 0;

    // Drive the transport's event loop for up to `timeout_ms`. Callbacks
    // (onConnect/onDisconnect/onMessage) fire synchronously from inside
    // this call. SimServer alternates poll() and Match::tick(). A
    // negative timeout blocks until at least one I/O event; 0 polls
    // without blocking; positive values are capped at the value passed.
    virtual void poll(int timeout_ms) = 0;
};

} // namespace fh::sim::net
