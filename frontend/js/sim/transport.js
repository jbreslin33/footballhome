// frontend/js/sim/transport.js
//
// Thin WebSocket wrapper for the fh-sim.v1 protocol. Handles:
//   * subprotocol handshake carrying the JWT
//   * binary framing + dispatch to callbacks (onHelloAck, onSnapshot,
//     onEvent, onOpen, onClose, onError)
//   * outbound INPUT throttling (a naive send-immediately is fine at
//     20-30 Hz; client.js gates the cadence)
//
// The transport does not care about game state — it just moves bytes.

'use strict';

class FhSimTransport {
    // opts:
    //   url:                  WebSocket URL (e.g. "wss://host/sim")
    //   jwt:                  signed JWT string
    //   onOpen():             connection open + subprotocol accepted
    //   onHelloAck(ack):      { matchId: BigInt, slot, tickHz,
    //                           wireCapabilityBits }
    //   onScenarioMeta(meta): { mode: 0|1|2, vertices: [{x,y},...] }
    //                         — Slice 17.7a; arrives once, right after
    //                           HELLO_ACK, when server advertises
    //                           WIRE_CAP.SCENARIO_META
    //   onSnapshot(snap):     { tick, matchTimeMs, entities: [...],
    //                           ball: null | {...} }
    //   onEvent(bytes):       raw EVENT payload (M1+ — kept as a hook)
    //   onClose(evt):         WebSocket CloseEvent
    //   onError(err):         transport-level error string
    constructor(opts) {
        this.url = opts.url;
        this.jwt = opts.jwt;
        this.onOpen         = opts.onOpen         || function () {};
        this.onHelloAck     = opts.onHelloAck     || function () {};
        this.onScenarioMeta = opts.onScenarioMeta || function () {};
        this.onSnapshot     = opts.onSnapshot     || function () {};
        this.onEvent        = opts.onEvent        || function () {};
        this.onClose        = opts.onClose        || function () {};
        this.onError        = opts.onError        || function () {};

        this.ws = null;
        this._closed = false;
    }

    connect() {
        // The fh-sim.v1 handshake carries the JWT inside the
        // Sec-WebSocket-Protocol header as `fh-sim.v1.bearer.<jwt>`.
        // Per RFC 6455 §4.2.2 the server MUST echo back one of the
        // offered subprotocol tokens verbatim, so it responds with
        // the SAME string (including the JWT). Browsers strictly
        // enforce this — mismatched echoes trigger close 1006.
        const proto = 'fh-sim.v1.bearer.' + this.jwt;
        this.ws = new WebSocket(this.url, [proto]);
        this.ws.binaryType = 'arraybuffer';

        this.ws.onopen = () => {
            if (!this.ws.protocol || !this.ws.protocol.startsWith('fh-sim.v1.bearer')) {
                this.onError('server rejected subprotocol: got "'
                             + this.ws.protocol + '"');
                this.close();
                return;
            }
            this.onOpen();
        };

        this.ws.onmessage = (evt) => this._handleMessage(evt.data);
        this.ws.onclose   = (evt) => {
            if (this._closed) return;
            this._closed = true;
            this.onClose(evt);
        };
        this.ws.onerror   = (err)  => this.onError('websocket error');
    }

    _handleMessage(data) {
        if (!(data instanceof ArrayBuffer)) return;   // text frames unused
        const dv = new DataView(data);
        const hdr = FhSimWire.peekFrameHeader(dv);
        if (!hdr) return;
        switch (hdr.msgType) {
            case FhSimWire.MSG.HELLO_ACK: {
                const ack = FhSimWire.decodeHelloAck(dv);
                if (ack) this.onHelloAck(ack);
                return;
            }
            case FhSimWire.MSG.SCENARIO_META: {
                const meta = FhSimWire.decodeScenarioMeta(dv);
                if (meta) this.onScenarioMeta(meta);
                return;
            }
            case FhSimWire.MSG.SNAPSHOT: {
                const snap = FhSimWire.decodeSnapshot(dv);
                if (snap) this.onSnapshot(snap);
                return;
            }
            case FhSimWire.MSG.EVENT:
                this.onEvent(new Uint8Array(data,
                             FhSimWire.FRAME_HEADER_BYTES,
                             hdr.payloadLen));
                return;
            default:
                // Ignore unknown types — forward-compat with future M1+.
                return;
        }
    }

    // Send an INPUT message. `intent` shape matches wire.encodeInput().
    sendInput(intent) {
        if (!this.ws || this.ws.readyState !== WebSocket.OPEN) return false;
        try {
            this.ws.send(FhSimWire.encodeInput(intent));
            return true;
        } catch (e) {
            this.onError('send failed: ' + (e.message || e));
            return false;
        }
    }

    close() {
        if (this._closed) return;
        this._closed = true;
        if (this.ws && this.ws.readyState !== WebSocket.CLOSED) {
            try { this.ws.close(1000, 'client leaving'); } catch (_e) { /* ignore */ }
        }
    }

    get readyState() {
        return this.ws ? this.ws.readyState : WebSocket.CLOSED;
    }
}

window.FhSimTransport = FhSimTransport;
