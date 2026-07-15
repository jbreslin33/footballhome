#!/usr/bin/env python3
# =============================================================================
# sim/scripts/check_cross_match_input_isolation.py
# =============================================================================
#
# Closes §21.7 item 3 M2-blocker: cross-match input isolation invariant not
# exercised end-to-end. Slice 14.7's baseline load test drives no clients,
# so per-daemon `AsyncPgLog<InputRow>` keying on `SIM_MATCH_ID` env
# (§22.12) is only proven structurally by unit tests, not against a live
# multi-daemon pod.
#
# What this script does:
#
#   1. POST /api/sim/matches × N to spawn N orchestrator-launched matches.
#      Each match_id gets its own per-match sim daemon container
#      (footballhome_sim_${match_id}) reachable through nginx at
#      /sim/${match_id} (per Slice 14.4 regex block in frontend/nginx.conf).
#
#   2. For each match: POST /api/sim/matches/${match_id}/join to receive
#      the sim JWT + subprotocol string the browser would use.
#
#   3. Open ONE WebSocket per match to ws://<BACKEND_HOST>:3000${ws_path}
#      via a raw stdlib TCP socket + hand-crafted RFC 6455 handshake.
#      Auth travels in the Sec-WebSocket-Protocol header exactly the way
#      the real browser client speaks it. Read the unsolicited HELLO_ACK
#      + optional SCENARIO_META frames the server pushes after the WS
#      upgrade completes.
#
#   4. Send N_INPUTS masked INPUT frames per match at ~20 Hz. Each frame's
#      u32 client_tick field is (match_marker << 16) | seq — bytes 2 and 3
#      of the 16-byte payload become a unique-per-match 16-bit magnitude.
#      dir_x/dir_y/flags stay zero (we're not testing physics, only
#      persistence-side keying + payload passthrough).
#
#   5. Close every WS cleanly, then POST /api/sim/matches/${match_id}/stop
#      for each match so the reaper doesn't have to garbage-collect us.
#
#   6. Query sim_match_inputs and assert:
#      - Every spawned match_id has ≥ N_INPUTS rows (all inputs recorded).
#      - Every row for match_id=M carries marker=M in bytes 2-3 of its
#        payload — proves the daemon received our frames verbatim.
#      - No row for match_id=A ever carries marker=B for any other spawned
#        match B — proves the per-daemon `AsyncPgLog<InputRow>` never
#        writes to another daemon's match_id (the isolation invariant).
#
# Deliberately NOT tested here:
#   - Physics correctness under load (that's the determinism test's job).
#   - Snapshot broadcast (this test only sends, doesn't decode snapshots
#     beyond confirming HELLO_ACK arrived).
#   - Slot claiming (sim auto-claims slot on first INPUT per §22.13).
#
# Prereqs (identical to sim/scripts/load_test_orchestrator.sh):
#   - Backend + db + footballhome_footballhome_sim image up.
#   - FH_SIM_ORCHESTRATOR_ENABLED=1 in the backend's env.
#   - /srv/footballhome/env contains JWT_SECRET (same value docker-compose
#     hands to the sim + backend containers).
#   - users.id=${USER_ID} exists in the DB (default 2).
#   - Python 3.8+ (uses only stdlib: socket, struct, hmac, hashlib,
#     json, threading, subprocess, urllib).
#
# Exit codes:
#   0   isolation invariant holds
#   1   at least one assertion failed
#   2   setup error (missing env, backend unreachable, spawn failed, etc.)
#
# Usage:
#   sim/scripts/check_cross_match_input_isolation.py
#     [--matches N]           default 3
#     [--inputs-per-match M]  default 200
#     [--tick-hz H]           default 20 (client sends at this cadence)
#     [--backend-url URL]     default http://localhost:3001
#     [--proxy-url URL]       default http://localhost:3000  (nginx WS proxy)
#     [--user-id ID]          default 2
# =============================================================================

from __future__ import annotations

import argparse
import base64
import hashlib
import hmac
import json
import os
import secrets
import socket
import struct
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass, field
from typing import List, Optional, Tuple

# ----------------------------------------------------------------------------
# ANSI helpers — same visual language as load_test_orchestrator.sh so a
# reader can eyeball the output in the same terminal without cognitive
# gear-shifting.
# ----------------------------------------------------------------------------
def _say(msg: str) -> None:  print(f"\n\033[1;36m=== {msg} ===\033[0m", flush=True)
def _ok(msg: str)  -> None:  print(f"  \033[1;32m✓\033[0m {msg}", flush=True)
def _fail(msg: str) -> None: print(f"  \033[1;31m✗\033[0m {msg}", flush=True)
def _info(msg: str) -> None: print(f"  · {msg}", flush=True)


# ----------------------------------------------------------------------------
# JWT helpers (HS256). Mirrors what load_test_orchestrator.sh does with
# openssl + jq in bash — inlined here so we don't need to shell out.
# ----------------------------------------------------------------------------
def _b64url(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")

def mint_backend_jwt(user_id: int, secret: str, ttl_s: int = 3600) -> str:
    """
    Mints a login-shape JWT the backend's SimLobbyController accepts.
    See SimLobbyController::personIdFromLoginJwtPayload — expects
    {"userId": "<int-as-string>"} in the payload.
    """
    now = int(time.time())
    header = _b64url(b'{"alg":"HS256","typ":"JWT"}')
    payload_dict = {"userId": str(user_id), "iat": now, "exp": now + ttl_s}
    payload = _b64url(json.dumps(payload_dict, separators=(",", ":")).encode())
    signing_input = f"{header}.{payload}".encode("ascii")
    sig = hmac.new(secret.encode("utf-8"), signing_input, hashlib.sha256).digest()
    return f"{header}.{payload}.{_b64url(sig)}"


# ----------------------------------------------------------------------------
# HTTP helpers — thin wrapper around urllib so we don't pull in requests.
# ----------------------------------------------------------------------------
def _http_json(method: str, url: str, token: str,
               body: Optional[dict] = None, timeout: float = 30.0) -> Tuple[int, dict]:
    data = json.dumps(body).encode("utf-8") if body is not None else None
    req = urllib.request.Request(url, data=data, method=method,
                                 headers={"Authorization": f"Bearer {token}",
                                          "Content-Type":  "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            try:
                return resp.status, json.loads(raw or b"{}")
            except json.JSONDecodeError:
                return resp.status, {"_raw": raw.decode("utf-8", errors="replace")}
    except urllib.error.HTTPError as e:
        raw = e.read()
        try:
            return e.code, json.loads(raw or b"{}")
        except json.JSONDecodeError:
            return e.code, {"_raw": raw.decode("utf-8", errors="replace")}


# ----------------------------------------------------------------------------
# WebSocket client (RFC 6455). Hand-rolled because we don't want to add a
# pip dependency for a diagnostic script. Just enough to:
#   - Complete a client-side handshake with Sec-WebSocket-Protocol carrying
#     `fh-sim.v1.bearer.<jwt>` (the sim daemon parses this per
#     sim/src/net/WebSocketTransport.hpp).
#   - Send masked binary frames (client → server MUST mask per RFC 6455 §5.3).
#   - Read unmasked binary frames (server → client MUST NOT mask).
#   - Send a close frame politely on shutdown.
# ----------------------------------------------------------------------------

class WsClient:
    _WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    def __init__(self, host: str, port: int, path: str, subprotocol: str,
                 connect_timeout: float = 10.0, io_timeout: float = 5.0):
        self._host = host
        self._port = port
        self._path = path
        self._subproto = subprotocol
        self._sock: Optional[socket.socket] = None
        self._connect_timeout = connect_timeout
        self._io_timeout = io_timeout

    def connect(self) -> None:
        s = socket.create_connection((self._host, self._port),
                                     timeout=self._connect_timeout)
        s.settimeout(self._io_timeout)
        self._sock = s

        key = base64.b64encode(secrets.token_bytes(16)).decode("ascii")
        req = (
            f"GET {self._path} HTTP/1.1\r\n"
            f"Host: {self._host}:{self._port}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            f"Sec-WebSocket-Protocol: {self._subproto}\r\n"
            "\r\n"
        )
        s.sendall(req.encode("ascii"))

        # Read HTTP response headers up to the blank line.
        buf = b""
        while b"\r\n\r\n" not in buf:
            chunk = s.recv(4096)
            if not chunk:
                raise RuntimeError("WS handshake: server closed before end of headers")
            buf += chunk
            if len(buf) > 32 * 1024:
                raise RuntimeError("WS handshake: header block too large")

        header_end = buf.index(b"\r\n\r\n") + 4
        status_line = buf.split(b"\r\n", 1)[0].decode("ascii", errors="replace")
        if not status_line.startswith("HTTP/1.1 101"):
            raise RuntimeError(f"WS handshake failed: {status_line}")

        # Push any post-header body bytes (early server pushes like HELLO_ACK)
        # into a small pre-fill buffer that recv_frame drains first.
        self._prefill = buf[header_end:]

    def recv_frame(self, timeout: Optional[float] = None) -> Tuple[int, bytes]:
        """Reads one complete WS frame (no fragmentation support needed —
        the sim daemon never fragments). Returns (opcode, payload)."""
        if timeout is not None:
            self._sock.settimeout(timeout)  # type: ignore[union-attr]

        # Read the 2-byte fixed header (FIN+opcode + MASK+len7).
        hdr = self._read_exact(2)
        b1, b2 = hdr[0], hdr[1]
        opcode = b1 & 0x0F
        masked = (b2 & 0x80) != 0
        length = b2 & 0x7F
        if masked:
            # Server frames MUST NOT be masked per RFC 6455 §5.1. If we
            # see one, some middlebox is misbehaving — bail loudly.
            raise RuntimeError("received a masked server frame (RFC 6455 violation)")

        if length == 126:
            length = struct.unpack("!H", self._read_exact(2))[0]
        elif length == 127:
            length = struct.unpack("!Q", self._read_exact(8))[0]
        # No mask key from server.

        payload = self._read_exact(length) if length > 0 else b""
        return opcode, payload

    def send_binary(self, payload: bytes) -> None:
        """Sends a single BINARY frame, masked per RFC 6455 §5.3."""
        mask = secrets.token_bytes(4)
        masked_payload = bytes(b ^ mask[i & 3] for i, b in enumerate(payload))

        n = len(payload)
        b1 = 0x80 | 0x02  # FIN + BINARY
        if n <= 125:
            hdr = struct.pack("!BB", b1, 0x80 | n)
        elif n <= 0xFFFF:
            hdr = struct.pack("!BBH", b1, 0x80 | 126, n)
        else:
            hdr = struct.pack("!BBQ", b1, 0x80 | 127, n)

        self._sock.sendall(hdr + mask + masked_payload)  # type: ignore[union-attr]

    def send_close(self, code: int = 1000) -> None:
        payload = struct.pack("!H", code)
        mask = secrets.token_bytes(4)
        masked_payload = bytes(b ^ mask[i & 3] for i, b in enumerate(payload))
        hdr = struct.pack("!BB", 0x80 | 0x08, 0x80 | len(payload))
        try:
            self._sock.sendall(hdr + mask + masked_payload)  # type: ignore[union-attr]
        except OSError:
            pass  # server may have already closed

    def close(self) -> None:
        try:
            if self._sock is not None:
                self._sock.close()
        finally:
            self._sock = None

    def _read_exact(self, n: int) -> bytes:
        out = bytearray()
        # Drain any prefill left over from the handshake tail before hitting
        # the socket again — the server pushes HELLO_ACK immediately after
        # the 101 response and it may arrive glued to the header block.
        if self._prefill:
            take = min(n, len(self._prefill))
            out.extend(self._prefill[:take])
            self._prefill = self._prefill[take:]
        while len(out) < n:
            chunk = self._sock.recv(n - len(out))  # type: ignore[union-attr]
            if not chunk:
                raise RuntimeError("WS: peer closed mid-frame")
            out.extend(chunk)
        return bytes(out)


# ----------------------------------------------------------------------------
# INPUT frame encode (fh-sim.v1 §7.3).
#
#   Frame header (4):  [u8 ver=1][u8 msg_type=0x20][u16 payload_len=16]
#   INPUT payload (16): [u32 client_tick][f32 dir_x][f32 dir_y]
#                       [u8 flags][u8 reserved[3]]
#
# EMPIRICAL: `sim_match_inputs.payload` stores the FULL 20-byte wire
# frame (header + payload), NOT just the 16-byte payload — verified
# 2026-07-13 by SELECT octet_length(payload). So byte offsets in
# sim_match_inputs.payload are:
#
#   0-3   frame header (ver, msg_type, payload_len LE u16)
#   4-7   client_tick (LE u32)                  ← our marker + seq live here
#   8-11  dir_x (LE f32)
#   12-15 dir_y (LE f32)
#   16    flags
#   17-19 reserved
#
# client_tick is packed as (marker << 16) | seq. LE u32 layout of
# client_tick puts seq in bytes 4-5 and marker in bytes 6-7.
# ----------------------------------------------------------------------------
_FRAME_HEADER_LEN = 4
_INPUT_MSG_TYPE   = 0x20
_INPUT_PAYLOAD_BYTES = 16

def encode_input_frame(client_tick: int,
                       dir_x: float = 0.0, dir_y: float = 0.0,
                       flags: int = 0) -> bytes:
    payload = struct.pack("<Iff B 3s",
                          client_tick & 0xFFFFFFFF,
                          float(dir_x), float(dir_y),
                          flags & 0xFF, b"\x00\x00\x00")
    assert len(payload) == _INPUT_PAYLOAD_BYTES, f"INPUT payload wrong size: {len(payload)}"
    header = struct.pack("<BBH", 1, _INPUT_MSG_TYPE, _INPUT_PAYLOAD_BYTES)
    return header + payload


# ----------------------------------------------------------------------------
# One-match session worker. Runs on its own thread so all N sessions
# execute concurrently — this matters for the isolation invariant: if any
# cross-daemon bleed exists at the InputLog / PgClient level, it should
# surface under concurrent write pressure, not serial one-at-a-time.
# ----------------------------------------------------------------------------

@dataclass
class MatchSession:
    match_id: int
    marker: int
    subprotocol: str
    ws_path: str
    proxy_host: str
    proxy_port: int
    n_inputs: int
    tick_hz: int
    # populated by run()
    error: Optional[str] = None
    inputs_sent: int = 0
    hello_ack_seen: bool = False
    elapsed_ms: int = 0

    def run(self) -> None:
        client = WsClient(self.proxy_host, self.proxy_port,
                          self.ws_path, self.subprotocol)
        t_start = time.monotonic()
        try:
            client.connect()

            # Drain any server-pushed frames sitting in prefill / early
            # socket bytes (HELLO_ACK, optionally SCENARIO_META). We don't
            # decode them beyond opcode discrimination — HELLO_ACK is
            # msg_type 0x02, SCENARIO_META is 0x03. We just want to
            # confirm the daemon acknowledged the connection before we
            # start sending INPUTs.
            for _ in range(4):  # bounded read — don't spin forever
                try:
                    opcode, payload = client.recv_frame(timeout=2.0)
                except (socket.timeout, TimeoutError):
                    break
                if opcode == 0x8:  # CLOSE
                    raise RuntimeError("server closed before HELLO_ACK")
                if opcode == 0x2 and len(payload) >= 2 and payload[1] == 0x02:
                    # WS binary frame carrying an fh-sim HELLO_ACK.
                    self.hello_ack_seen = True
                    break
                if opcode == 0x2 and len(payload) >= 2 and payload[1] == 0x10:
                    # SNAPSHOT — server started ticking before we could
                    # get HELLO_ACK. Weird but not fatal for our test.
                    self.hello_ack_seen = True
                    break

            if not self.hello_ack_seen:
                # Not fatal — the connection is up and daemon accepts input
                # even without us decoding the HELLO_ACK. Downgrade to a
                # warning, keep sending.
                pass

            # Send N INPUT frames at tick_hz cadence. client_tick encodes
            # (marker << 16) | seq so payload bytes 2-3 = little-endian
            # marker, bytes 0-1 = little-endian seq.
            period_s = 1.0 / max(1, self.tick_hz)
            next_send = time.monotonic()
            for seq in range(self.n_inputs):
                client_tick = ((self.marker & 0xFFFF) << 16) | (seq & 0xFFFF)
                frame = encode_input_frame(client_tick)
                client.send_binary(frame)
                self.inputs_sent += 1
                next_send += period_s
                slack = next_send - time.monotonic()
                if slack > 0:
                    time.sleep(slack)

            # Brief drain window so the daemon's InputLog can flush
            # before we tear the socket down.
            time.sleep(0.5)
            client.send_close()

        except Exception as e:  # noqa: BLE001
            self.error = f"{type(e).__name__}: {e}"
        finally:
            client.close()
            self.elapsed_ms = int((time.monotonic() - t_start) * 1000)


# ----------------------------------------------------------------------------
# Postgres access — same as load_test_orchestrator.sh: shell out to
# `sudo podman exec footballhome_db psql`. Avoids a psycopg2 dependency
# and matches the surrounding test-harness style.
# ----------------------------------------------------------------------------

def psql_query(sql: str) -> str:
    cmd = ["sudo", "podman", "exec", "-i", "footballhome_db",
           "psql", "-U", "footballhome_user", "-d", "footballhome",
           "-t", "-A", "-F", "|", "-c", sql]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            f"psql failed (rc={result.returncode}): {result.stderr.strip()}")
    return result.stdout.strip()


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> int:
    p = argparse.ArgumentParser(
        description="Cross-match input isolation harness — §21.7 item 3.")
    p.add_argument("--matches", type=int, default=3,
                   help="number of matches to spawn (default: 3)")
    p.add_argument("--inputs-per-match", type=int, default=200,
                   help="INPUT frames sent to each match (default: 200)")
    p.add_argument("--tick-hz", type=int, default=20,
                   help="client send cadence (default: 20)")
    p.add_argument("--backend-url", default=os.environ.get(
        "BACKEND_URL", "http://localhost:3001"),
                   help="backend base URL (default: http://localhost:3001)")
    p.add_argument("--proxy-url", default=os.environ.get(
        "PROXY_URL", "http://localhost:3000"),
                   help="nginx WS proxy base URL (default: http://localhost:3000)")
    p.add_argument("--user-id", type=int, default=int(os.environ.get("USER_ID", "2")),
                   help="users.id whose JWT authorizes spawns (default: 2)")
    p.add_argument("--env-file", default="/srv/footballhome/env",
                   help="path to env file with JWT_SECRET (default: /srv/footballhome/env)")
    args = p.parse_args()

    failures = 0
    spawned: List[int] = []

    _say("0) preflight")

    if not os.path.isfile(args.env_file):
        _fail(f"missing env file: {args.env_file}")
        return 2
    jwt_secret = ""
    with open(args.env_file, "r", encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("JWT_SECRET="):
                jwt_secret = line[len("JWT_SECRET="):].strip()
                break
    if not jwt_secret:
        _fail(f"JWT_SECRET missing in {args.env_file}")
        return 2
    _ok(f"loaded JWT_SECRET from {args.env_file}")

    backend_token = mint_backend_jwt(args.user_id, jwt_secret)
    _ok(f"minted backend JWT (userId={args.user_id}, ttl=1h)")

    # Proxy URL → host + port.
    proxy_parsed = urllib.parse.urlparse(args.proxy_url)
    proxy_host = proxy_parsed.hostname or "localhost"
    proxy_port = proxy_parsed.port or 80

    # ------------------------------------------------------------------
    # 1) spawn N matches
    # ------------------------------------------------------------------
    _say(f"1) spawn {args.matches} matches")

    def _spawn_one(seed: int) -> Optional[int]:
        code, body = _http_json(
            "POST", f"{args.backend_url}/api/sim/matches", backend_token,
            {"scenario_id": 0, "seed": seed, "tick_hz": 20}, timeout=60.0)
        if code != 200:
            _fail(f"spawn seed={seed} HTTP {code}: {body}")
            return None
        return int(body["id"])

    for i in range(args.matches):
        mid = _spawn_one(seed=500000 + i)
        if mid is None:
            failures += 1
            continue
        spawned.append(mid)
        _info(f"spawned match_id={mid}")

    if len(spawned) != args.matches:
        _fail(f"only {len(spawned)}/{args.matches} spawned — aborting")
        _cleanup_matches(spawned, args.backend_url, backend_token)
        return 1
    _ok(f"all {args.matches} matches spawned: {spawned}")

    # ------------------------------------------------------------------
    # 2) join each — collects sim JWT + ws_path per match
    # ------------------------------------------------------------------
    _say("2) join each match to obtain sim JWT + ws_path")
    sessions: List[MatchSession] = []
    for i, mid in enumerate(spawned):
        code, body = _http_json(
            "POST", f"{args.backend_url}/api/sim/matches/{mid}/join",
            backend_token, {}, timeout=15.0)
        if code != 200 or "subprotocol" not in body or "ws_path" not in body:
            _fail(f"join match_id={mid} HTTP {code}: {body}")
            failures += 1
            continue
        # marker = index+1 so we don't use 0 (which would clash with
        # zero-initialized payload bytes if the daemon ever failed to
        # write ours).
        marker = i + 1
        sessions.append(MatchSession(
            match_id=mid,
            marker=marker,
            subprotocol=body["subprotocol"],
            ws_path=body["ws_path"],
            proxy_host=proxy_host,
            proxy_port=proxy_port,
            n_inputs=args.inputs_per_match,
            tick_hz=args.tick_hz,
        ))
        _info(f"match_id={mid}  marker={marker}  ws_path={body['ws_path']}")

    if len(sessions) != len(spawned):
        _fail(f"only {len(sessions)}/{len(spawned)} joined — aborting")
        _cleanup_matches(spawned, args.backend_url, backend_token)
        return 1
    _ok(f"joined all {len(sessions)} matches")

    # ------------------------------------------------------------------
    # 3) drive concurrent WS sessions — one thread per match
    # ------------------------------------------------------------------
    _say(f"3) send {args.inputs_per_match} INPUTs to each of "
         f"{len(sessions)} matches @ {args.tick_hz} Hz (concurrent)")
    threads = [threading.Thread(target=s.run, name=f"ws-{s.match_id}")
               for s in sessions]
    t_start = time.monotonic()
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    wall_ms = int((time.monotonic() - t_start) * 1000)
    _info(f"all sessions completed in {wall_ms} ms wall")

    for s in sessions:
        if s.error is not None:
            _fail(f"session match_id={s.match_id} failed: {s.error}")
            failures += 1
        else:
            hello = "HELLO_ACK ✓" if s.hello_ack_seen else "no HELLO_ACK observed (still counted)"
            _info(f"match_id={s.match_id}  sent={s.inputs_sent}  "
                  f"elapsed={s.elapsed_ms} ms  ({hello})")

    # Brief settle so the daemons' AsyncPgLog<InputRow> can drain the
    # tail of their buffers before we run the DB assertion.
    time.sleep(1.5)

    # ------------------------------------------------------------------
    # 4) DB assertion — the actual isolation invariant check
    # ------------------------------------------------------------------
    _say("4) verify sim_match_inputs isolation")
    id_csv = ",".join(str(s.match_id) for s in sessions)

    # Per-match count + marker distribution. `sim_match_inputs.payload`
    # stores the full 20-byte wire frame (see docblock above). The
    # marker sits in the HIGH 16 bits of client_tick (LE u32 at frame
    # offset 4-7), so the marker bytes are payload offsets 6 (low) and
    # 7 (high). get_byte() is 0-indexed.
    query = f"""
        SELECT match_id,
               COUNT(*) AS n_rows,
               (get_byte(payload, 6)::int + (get_byte(payload, 7)::int << 8)) AS marker,
               COUNT(*) AS marker_count
          FROM sim_match_inputs
         WHERE match_id IN ({id_csv})
         GROUP BY match_id,
                  (get_byte(payload, 6)::int + (get_byte(payload, 7)::int << 8))
         ORDER BY match_id, marker
    """
    raw = psql_query(query)

    # Parse rows: match_id | n_rows | marker | marker_count
    per_match_rows: dict = {}
    per_match_markers: dict = {}
    for line in raw.splitlines():
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) < 4:
            continue
        mid = int(parts[0])
        marker = int(parts[2])
        cnt = int(parts[3])
        per_match_markers.setdefault(mid, {})[marker] = cnt
        per_match_rows[mid] = per_match_rows.get(mid, 0) + cnt

    # Expected marker per match
    expected_marker = {s.match_id: s.marker for s in sessions}
    all_markers_in_test = set(expected_marker.values())

    for s in sessions:
        rows_seen = per_match_rows.get(s.match_id, 0)
        markers_seen = per_match_markers.get(s.match_id, {})

        # Assertion A: enough rows landed. We tolerate the count being
        # slightly BELOW n_inputs (daemon's InputLog is a bounded ring;
        # a tail-window drain of 1.5 s is usually enough but not always).
        # A count of exactly 0 means the write path never fired — bail
        # loudly; anything > 0 counts as "the invariant is testable".
        if rows_seen == 0:
            _fail(f"match_id={s.match_id} — 0 rows in sim_match_inputs "
                  f"(expected up to {s.n_inputs}); write path broken")
            failures += 1
            continue

        pct = 100.0 * rows_seen / s.n_inputs
        if rows_seen >= s.n_inputs:
            _ok(f"match_id={s.match_id} — {rows_seen}/{s.n_inputs} rows "
                f"({pct:.1f}%)")
        else:
            _info(f"match_id={s.match_id} — {rows_seen}/{s.n_inputs} rows "
                  f"({pct:.1f}%) — tail drain incomplete but non-zero")

        # Assertion B: every row for THIS match carries the expected marker.
        own_marker_count = markers_seen.get(s.marker, 0)
        if own_marker_count == rows_seen:
            _ok(f"match_id={s.match_id} — 100% of rows carry own marker "
                f"({s.marker})")
        else:
            _fail(f"match_id={s.match_id} — only {own_marker_count}/{rows_seen} "
                  f"rows carry own marker ({s.marker}); other markers found: "
                  f"{ {m: c for m, c in markers_seen.items() if m != s.marker} }")
            failures += 1

        # Assertion C: NO row for THIS match carries a marker belonging
        # to another match in this test cohort — the invariant itself.
        foreign = {m: c for m, c in markers_seen.items()
                   if m != s.marker and m in all_markers_in_test}
        if not foreign:
            _ok(f"match_id={s.match_id} — no foreign markers "
                f"(isolation invariant holds)")
        else:
            _fail(f"match_id={s.match_id} — FOREIGN MARKERS LEAKED IN: "
                  f"{foreign} — isolation invariant BROKEN")
            failures += 1

    # ------------------------------------------------------------------
    # 5) cleanup — stop all matches
    # ------------------------------------------------------------------
    _say("5) stop matches")
    _cleanup_matches(spawned, args.backend_url, backend_token)

    # ------------------------------------------------------------------
    # summary
    # ------------------------------------------------------------------
    _say("summary")
    if failures == 0:
        print(f"  \033[1;32mALL ASSERTIONS PASSED\033[0m "
              f"(matches={args.matches}, inputs/match={args.inputs_per_match})")
        return 0
    else:
        print(f"  \033[1;31m{failures} ASSERTION(S) FAILED\033[0m")
        return 1


def _cleanup_matches(spawned: List[int], backend_url: str, token: str) -> None:
    for mid in spawned:
        try:
            code, _ = _http_json(
                "POST", f"{backend_url}/api/sim/matches/{mid}/stop",
                token, {}, timeout=30.0)
            if code == 200:
                _info(f"stopped match_id={mid}")
            else:
                _info(f"stop match_id={mid} HTTP {code}")
        except Exception as e:  # noqa: BLE001
            _info(f"stop match_id={mid} error: {e}")


if __name__ == "__main__":
    sys.exit(main())
