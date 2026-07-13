// frontend/js/sim/client.js
//
// Top-level orchestrator for the fh-sim.v1 browser demo. Wires together
// transport, renderer, input and interpolator, and drives the render
// loop + fixed-rate INPUT publisher.
//
// Life-cycle:
//   1. Resolve target match_id from `?match=<n>` URL param (default 1
//      = M0 seed).
//   2. Resolve a sim JWT (see resolveSimJwt below):
//        a. `?token=<jwt>` URL param wins (dev / mint-dev-jwt.sh path).
//        b. Else if the site's backend login JWT is in localStorage
//           ('token'), POST /api/sim/matches/${match_id}/join with a
//           Bearer header — the backend bridges users.id → person_id,
//           mints a fresh sim JWT, AND returns the ws_path (either
//           legacy `/sim` for the M0 seed or `/sim/${match_id}` for
//           orchestrator-launched matches). Cache the token as
//           sim_token.
//        c. Else fall back to a previously-cached sim_token.
//        d. Else surface a fatal message.
//   3. Open the WS connection at the resolved ws_path with the
//      fh-sim.v1.bearer.<jwt> subprotocol.
//   4. On HELLO_ACK, remember our slot + tick rate and start the loop.
//   5. requestAnimationFrame draws whatever the interpolator can
//      produce for `now`; a setInterval publishes INPUT at 30 Hz
//      (slightly faster than the server tick so late frames still
//      land inside a tick window).
//   6. Any failure surfaces to the on-page status HUD; page reload = retry.

'use strict';

// Match-id resolution:
//   * `?match=<n>` URL param wins (dev / direct-link path — e.g. after
//     the SPA POSTs /api/sim/matches and receives {id, ws_url}, it can
//     redirect the user here with ?match=N).
//   * Else fall back to 1 — the M0 seed match served by the
//     docker-compose `footballhome_sim` container (see migration 202).
//     This keeps the pre-14.4 direct-load flow working: hitting
//     /sim.html with a valid login token joins the M0 daemon exactly
//     like it did before multi-match orchestration landed.
function resolveMatchId() {
    const params = new URLSearchParams(location.search);
    const raw = params.get('match');
    if (raw && /^\d+$/.test(raw)) {
        const n = parseInt(raw, 10);
        if (n > 0) return n;
    }
    return 1;
}

// Fetch a fresh sim JWT + ws_path from the backend using the caller's
// login JWT. Returns { token, wsPath } on success, or null on any
// failure. The ws_path discriminates orchestrator-launched matches
// (routed to footballhome_sim_${id}:9100 via the nginx regex block)
// from the legacy M0 seed (routed to footballhome_sim:9100 via the
// exact-match block) — see backend/src/controllers/SimLobbyController.cpp
// handleJoinMatch for the discrimination rule.
async function fetchSimTokenViaLoginJwt(loginJwt, matchId) {
    try {
        const resp = await fetch(
            '/api/sim/matches/' + matchId + '/join',
            {
                method:      'POST',
                cache:       'no-store',
                credentials: 'same-origin',
                headers: {
                    'Authorization': 'Bearer ' + loginJwt,
                    'Accept':        'application/json',
                    'Cache-Control': 'no-store',
                },
            }
        );
        if (!resp.ok) {
            console.warn('[sim] /join returned HTTP ' + resp.status);
            return null;
        }
        const body = await resp.json();
        if (typeof body.token !== 'string' || body.token.length === 0) {
            console.warn('[sim] /join response missing token field');
            return null;
        }
        // ws_path is guaranteed by handleJoinMatch (Slice 14.4). Fall
        // back to legacy /sim for a defensive-but-technically-dead-code
        // path if an old backend somehow ships without the field.
        const wsPath = (typeof body.ws_path === 'string' && body.ws_path.length > 0)
            ? body.ws_path
            : '/sim';
        return { token: body.token, wsPath: wsPath };
    } catch (err) {
        console.warn('[sim] /join fetch failed:', err);
        return null;
    }
}

// Priority-ordered resolution — see life-cycle step 1 in the header
// comment. Returns { jwt, wsPath, source } — wsPath may be null when
// jwt came from ?token=… or from the cache, in which case the caller
// falls back to the legacy /sim path (the only path a pre-14.4 cached
// token could have been minted for).
async function resolveSimJwt(matchId) {
    const params = new URLSearchParams(location.search);
    const urlToken = params.get('token');
    if (urlToken) {
        try { localStorage.setItem('sim_token', urlToken); } catch (_e) {}
        // ?token=… is the dev/manual path — we don't know which
        // match the mint-dev-jwt.sh caller targeted, so use the
        // ?match=… hint (defaulting to /sim if no match hint).
        const wsPath = matchId > 1 ? ('/sim/' + matchId) : '/sim';
        return { jwt: urlToken, wsPath: wsPath, source: 'url' };
    }

    let loginJwt = null;
    try { loginJwt = localStorage.getItem('token'); } catch (_e) {}
    if (loginJwt) {
        const fresh = await fetchSimTokenViaLoginJwt(loginJwt, matchId);
        if (fresh) {
            try { localStorage.setItem('sim_token', fresh.token); } catch (_e) {}
            return { jwt: fresh.token, wsPath: fresh.wsPath, source: 'join' };
        }
        // fall through to cached sim_token if /join failed
    }

    let cached = null;
    try { cached = localStorage.getItem('sim_token'); } catch (_e) {}
    if (cached) {
        const wsPath = matchId > 1 ? ('/sim/' + matchId) : '/sim';
        return { jwt: cached, wsPath: wsPath, source: 'cache' };
    }

    return { jwt: null, wsPath: null, source: null };
}

(async function main() {
    const canvas    = document.getElementById('sim-canvas');
    const stickCvs  = document.getElementById('sim-joystick');
    const sprintPad = document.getElementById('sim-sprint-pad');
    const statusEl  = document.getElementById('sim-status');

    if (!canvas || !stickCvs || !sprintPad || !statusEl) {
        console.error('sim.html: required DOM elements missing');
        return;
    }

    statusEl.textContent = 'resolving token…';
    const matchId  = resolveMatchId();
    const resolved = await resolveSimJwt(matchId);
    const jwt      = resolved.jwt;
    if (!jwt) {
        showFatal(statusEl,
            'No sim JWT. Sign in to footballhome first, append ?token=<jwt> ' +
            'to the URL, or run sim/scripts/mint-dev-jwt.sh to generate one.');
        return;
    }
    console.log('[sim] using JWT from', resolved.source,
                '\u2192 ws_path', resolved.wsPath, 'match_id', matchId);

    // WS URL: same host, ws_path from /join response (or fallback for
    // ?token=/cache paths), matching protocol scheme.
    const scheme = location.protocol === 'https:' ? 'wss:' : 'ws:';
    const url = scheme + '//' + location.host + resolved.wsPath;

    const renderer     = new FhSimRenderer(canvas);
    const interpolator = new FhSimInterpolator(20);
    const input        = new FhSimInput({
        stickCanvas: stickCvs,
        sprintPad:   sprintPad,
    });

    const state = {
        matchId:   null,
        slot:      null,
        tickHz:    20,
        clientTick: 0,
        lastSnapAt: 0,
        pingMs:    null,
        clients:   0,
        state:     'connecting…',
        // Diagnostic counters surfaced in #sim-status DOM so we can
        // see what's happening even if canvas render itself is broken.
        helloAcks: 0,
        snaps:     0,
        lastSnapEntities: 0,
        myPos:     null,
    };

    // Resize handling – recompute pixel scale on rotation/DPR change.
    const onResize = () => { renderer.resize(); input.resize(); };
    window.addEventListener('resize', onResize);
    window.addEventListener('orientationchange', onResize);

    // Some browsers finish CSS layout AFTER our synchronous constructor
    // runs (esp. when JS is served no-cache and executed early). The
    // canvas's first getBoundingClientRect() can return a 1x1 or 0x0
    // rect, so the pitch is drawn into a nub in the corner and looks
    // like nothing rendered until a manual click bumps a resize. Guard
    // with a ResizeObserver + a couple of deferred re-measures.
    if (typeof ResizeObserver === 'function') {
        const ro = new ResizeObserver(() => onResize());
        ro.observe(canvas);
    }
    window.addEventListener('load', onResize);
    requestAnimationFrame(onResize);
    setTimeout(onResize, 200);

    const transport = new FhSimTransport({
        url: url,
        jwt: jwt,

        onOpen: () => {
            state.state = 'handshake…';
        },

        onHelloAck: (ack) => {
            state.matchId = ack.matchId.toString();
            state.slot    = ack.slot;
            state.tickHz  = ack.tickHz || 20;
            state.state   = ack.slot === 0 ? 'spectating' : 'playing';
            state.helloAcks++;
            interpolator.setTickHz(state.tickHz);
            renderer.setMySlot(ack.slot);
        },

        onSnapshot: (snap) => {
            const now = performance.now();
            interpolator.pushSnapshot(snap, now);
            if (state.lastSnapAt > 0) {
                // Rough ping proxy — snapshot inter-arrival dispersion
                // as a placeholder until a real PING/PONG loop lands.
                const dt = now - state.lastSnapAt;
                state.pingMs = state.pingMs == null
                    ? dt
                    : state.pingMs * 0.9 + dt * 0.1;
            }
            state.lastSnapAt = now;
            state.snaps++;
            state.lastSnapEntities = snap.entities.length;
            state.clients    = snap.entities.filter(
                (e) => (e.flags & FhSimWire.ENTITY_FLAG.HUMAN) !== 0
            ).length;
            // Track my entity position so we can surface it in status HUD.
            if (state.slot != null) {
                const me = snap.entities.find((e) => e.slotId === state.slot);
                state.myPos = me ? { x: me.posX, y: me.posY, flags: me.flags } : null;
            }
        },

        onClose: (evt) => {
            state.state = 'closed (' + evt.code + ')';
        },

        onError: (msg) => {
            state.state = 'error: ' + msg;
        },
    });
    transport.connect();

    // Fixed-rate INPUT publisher (30 Hz — slightly above server tick to
    // ensure at least one INPUT lands per tick window even with jitter).
    const inputHz = 30;
    const inputTimer = setInterval(() => {
        if (state.slot == null || state.slot === 0) return;   // spectator
        const intent = input.read() || { dirX: 0, dirY: 0, wantsSprint: false, wantsWalk: false };
        transport.sendInput({
            clientTick:  state.clientTick++,
            dirX:        intent.dirX,
            dirY:        intent.dirY,
            wantsSprint: intent.wantsSprint,
            wantsWalk:   intent.wantsWalk,
        });
    }, 1000 / inputHz);

    // Render loop ----------------------------------------------------------
    let raf = 0;
    const step = () => {
        const now = performance.now();
        const snap = interpolator.sample(now);
        const hudStatus = {
            matchId: state.matchId,
            slot:    state.slot,
            tick:    snap ? snap.tick : null,
            clients: state.clients,
            pingMs:  state.pingMs,
            state:   state.state,
        };
        renderer.render(snap, hudStatus);
        // Surface everything to the always-visible #sim-status DOM element
        // so we can diagnose even if the canvas itself never draws.
        const rect = canvas.getBoundingClientRect();
        const parts = [
            state.state,
            'slot=' + (state.slot == null ? '?' : state.slot),
            'hellos=' + state.helloAcks,
            'snaps=' + state.snaps,
            'ents=' + state.lastSnapEntities,
            'cvs=' + Math.round(rect.width) + 'x' + Math.round(rect.height),
        ];
        if (state.myPos) {
            parts.push('me=(' + state.myPos.x.toFixed(1) + ',' + state.myPos.y.toFixed(1) + ',f=0x' + state.myPos.flags.toString(16) + ')');
        }
        statusEl.textContent = parts.join(' | ');
        raf = requestAnimationFrame(step);
    };
    raf = requestAnimationFrame(step);

    // Ship diagnostics to the server every 2 seconds. The URL doesn't
    // need to exist — nginx access-log captures the query string so we
    // can `podman logs footballhome_frontend | grep _fh_diag` to read
    // what the client sees. Cheap and works even if console is broken.
    setInterval(() => {
        const rect = canvas.getBoundingClientRect();
        const q = new URLSearchParams({
            state: state.state,
            slot: String(state.slot),
            hellos: String(state.helloAcks),
            snaps: String(state.snaps),
            ents: String(state.lastSnapEntities),
            cvs: Math.round(rect.width) + 'x' + Math.round(rect.height),
            me: state.myPos
                ? state.myPos.x.toFixed(1) + ',' + state.myPos.y.toFixed(1) + ',0x' + state.myPos.flags.toString(16)
                : 'null',
        });
        // Fire-and-forget. Even a 404 is fine — we just need the URL logged.
        fetch('/_fh_diag?' + q.toString(), { cache: 'no-store' }).catch(() => {});
    }, 2000);

    // Clean shutdown on page hide (mobile background). Reload will
    // re-establish; the sim releases the slot when the socket closes.
    window.addEventListener('beforeunload', () => {
        clearInterval(inputTimer);
        cancelAnimationFrame(raf);
        transport.close();
        input.dispose();
    });
})();

function showFatal(el, msg) {
    el.textContent = msg;
    el.classList.add('sim-status--fatal');
}
