// frontend/js/teach/concept.js — the concept clip viewer (concept.html?concept=<game_concepts id>).
//
// Owner 2026-11-24, of the first popup (the live 3D match with one small label): "its trash
// lol. can't tell what is happening. it should show the concept so clear!!!" · "i should be
// able to hit replay to see the example again. it should be clear what example i am on" ·
// "i should be able run it in slow mo … or sped up".
//
// It watches the ordinary live match (the whole engine, nothing staged) and keeps the last
// two minutes. Each time a player plays the concept for a second or more, the 3 s before to
// 5 s after becomes an EXAMPLE. An example plays once, then stops, and is shown so the
// concept cannot be missed:
//
//   • top-down, zoomed on the player and the man (or ball) he is acting on, turned so his
//     side attacks up the screen;
//   • him ringed in gold, his man ringed in red with the metres between them, where he is
//     heading, and his path as a trail; everyone else dimmed;
//   • BEFORE / DOING IT / AFTER across the top, a freeze at the moment it starts, and a
//     timeline with the doing-it part filled in;
//   • ↺ Replay, ‹ Previous / Next ›, "Example 2 of 5", and ⅛× … 2×.
//
// The concept's name and cue are its catalogue row (GET /api/tactic-plans/taxonomy); every
// other word is message_templates kind 'taxonomy', tiers clip_* (mig 1842).
// The engine names a concept per player only for the acts in game_engine_acts; for any
// other concept there is nothing to cut on and the page says so.

(function () {
  'use strict';
  const $ = (id) => document.getElementById(id);
  const token = localStorage.getItem('token');
  if (!token) { location.href = '/'; return; }
  const CONCEPT = Number(new URLSearchParams(location.search).get('concept')) || 0;
  const NO = 255, BEFORE = 90, AFTER = 150, MIN_HELD = 5, KEEP = 3600;   // ticks at 30 Hz; brain frames at 5 Hz
  const SPEEDS = [[0.125, '⅛×'], [0.25, '¼×'], [0.5, '½×'], [1, '1×'], [2, '2×']];

  const copy = new Map();
  const say = (tier, tokens = {}) => (copy.get(tier) || '').replace(/\{(\w+)\}/g, (_, k) => (tokens[k] == null ? '' : String(tokens[k])));
  let concept = null, reported = null;   // the catalogue row; whether the engine names this concept at all
  let terms = [], legend = {};            // the engine's vocabulary (game_engine_terms); concept id → { name, title }
  let tax = {}, sideTab = 'machine';     // the taxonomy payload; which side tab is open

  // ── the live match, remembered ──
  const snaps = [], brains = [], pairsLog = [], reachLog = [];   // [{tick, players, ball}], [{tick, entries}], [{tick, pairs}], [{tick, reach}]
  let showPairs = false, pairKind = false;        // draw who has whom; this concept IS direct opponents (examples = a change of man)
  let reachKind = false;                          // this concept IS pressing distance (examples = a pass to a man somebody has)
  let shadowKind = false;                         // this concept IS the cover shadow (examples = a man closing the ball down)
  const shadowLog = [];                           // [{tick, v: { body, screen, hidden }}]
  const stateLog = [];                            // [{tick, v: [state code per slot]}] — his own machine, from the engine (frame STATES)
  const phaseLog = [];                            // [{tick, v: [home phase, away phase]}] — the team machine (frame PHASE)
  const ownKind = () => pairKind;    // the page cuts its own examples; the engine's per-player label is not needed
  let hello = null, roster = [], kits = [null, null], teamNames = ['', ''];
  const pending = new Map();              // slot → { onset, held, last }  (playing it now)
  const clips = [];                       // { slot, onset, from, to, until }
  let at = -1;                            // the example on screen
  const play = { t: 0, rate: 0.5, on: false, holdUntil: 0, last: 0, ended: false };

  const teamOf = (i) => (hello && i < hello.slotCount / 2 ? 0 : 1);
  const numOf = (i) => (roster[i] && roster[i].number) || '';
  const nameOf = (i) => (roster[i] && roster[i].name) || ('#' + numOf(i));

  // A concept the real sim keeps at zero is watched in a private room of the full engine with it
  // switched on for both sides (game/src/main.cpp, game_concept_dials) — owner 11/24: "i am not
  // seeing the concept ran?". The room is the viewer's own; it starts paused at a goal kick, so
  // the page plays it.
  const roomOn = () => reachKind || shadowKind;
  function connect() {
    const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
    if (load.step < 1) { load.step = 1; load.since = performance.now(); }
    const path = roomOn() ? `/game?trainer=1&concept=${CONCEPT}` : '/game';
    const ws = new WebSocket(`${scheme}://${location.host}${path}`, `fh-game.v2.bearer.${token}`);
    ws.binaryType = 'arraybuffer';
    ws.onmessage = (ev) => {
      const view = new DataView(ev.data), T = GameWire.FrameType;
      for (const f of GameWire.decodeFrame(ev.data)) {
        if (f.type === T.HELLO) { hello = GameWire.decodeHello(view, f.payloadAt); ws.send(GameWire.encodeBrainWatch(true)); if (roomOn()) ws.send(GameWire.encodeSpeed(100)); }
        else if (f.type === T.SNAPSHOT) {
          const s = GameWire.decodeSnapshot(view, f.payloadAt);
          snaps.push({ tick: s.tick, players: s.players, ball: s.ball, restart: s.match ? s.match.restartTeam : NO });
          if (snaps.length > KEEP) snaps.shift();
        } else if (f.type === T.ROSTER) roster = GameWire.decodeRoster(view, f.payloadAt, f.payloadLen);
        else if (f.type === T.TEAMS) { const tm = GameWire.decodeTeams(view, f.payloadAt, f.payloadLen); kits = tm.kits; teamNames = [tm.home, tm.away]; }
        else if (f.type === T.CONCEPT_LEGEND) { legend = GameWire.decodeConceptLegend(view, f.payloadAt); reported = !!legend[CONCEPT] || shadowKind; paintBar(); }
        else if (f.type === T.BRAIN) see(GameWire.decodeBrain(view, f.payloadAt));
        else if (f.type === T.PAIRS) seePairs(GameWire.decodePairs(view, f.payloadAt));
        else if (f.type === T.STATES) { stateLog.push({ tick: snaps.length ? snaps[snaps.length - 1].tick : 0, v: GameWire.decodeStates(view, f.payloadAt) }); if (stateLog.length > KEEP / 6 + 20) stateLog.shift(); }
        else if (f.type === T.PHASE) { phaseLog.push({ tick: snaps.length ? snaps[snaps.length - 1].tick : 0, v: GameWire.decodePhase(view, f.payloadAt) }); if (phaseLog.length > KEEP / 6 + 20) phaseLog.shift(); }
        else if (f.type === T.SHADOW) { shadowLog.push({ tick: snaps.length ? snaps[snaps.length - 1].tick : 0, v: GameWire.decodeShadow(view, f.payloadAt) }); if (shadowLog.length > KEEP / 6 + 20) shadowLog.shift(); }
        else if (f.type === T.REACH) { reachLog.push({ tick: snaps.length ? snaps[snaps.length - 1].tick : 0, reach: GameWire.decodeReach(view, f.payloadAt) }); if (reachLog.length > KEEP / 6 + 20) reachLog.shift(); }
      }
    };
    ws.onclose = () => setTimeout(connect, 2000);
  }

  // Every BRAIN frame: who is playing the concept; a spell of a second or more becomes an
  // example once its five seconds after have been played.
  function see(entries) {
    const tick = snaps.length ? snaps[snaps.length - 1].tick : 0;
    brains.push({ tick, entries });
    if (brains.length > KEEP / 6 + 20) brains.shift();
    entries.forEach((e, slot) => {
      // The cover shadow is seen on whoever closes the ball down — whether or not his side presses on it.
      const doing = !ownKind() && e && (e.concept === CONCEPT || (shadowKind && legend[e.concept] && legend[e.concept].name === 'close-down')), p = pending.get(slot);
      if (doing && !p) pending.set(slot, { onset: tick, held: 1, last: tick, open: true });
      else if (doing && p && p.open) { p.held++; p.last = tick; }
      else if (!doing && p) p.open = false;
    });
    for (const [slot, p] of pending) {
      if (tick < p.onset + AFTER) continue;
      pending.delete(slot);
      const clear = !clips.length || p.onset > clips[clips.length - 1].onset + 45;   // not the same moment twice
      if (p.held >= MIN_HELD && clear && snaps.length && snaps[0].tick <= p.onset - BEFORE) {
        clips.push({ slot, onset: p.onset, from: p.onset - BEFORE, to: p.onset + AFTER, until: Math.min(p.last, p.onset + AFTER) });
        if (clips.length > 20) { clips.shift(); if (at > 0) at--; }
        if (at < 0) { load.done = true; paintLoad(); show(0); setTab('machine'); }   // the first one plays by itself, his state machine beside it
        else paintBar();
      }
    }
  }

  // Direct opponents (PAIRS, with every BRAIN frame): who has whom. For the direct-opponent
  // concept itself an example is a CHANGE of man — the temporary opponent — once the new pair
  // has held a second.
  const switching = new Map();   // slot → { onset, from, to, held }
  function seePairs(pairs) {
    const tick = snaps.length ? snaps[snaps.length - 1].tick : 0, prev = pairsLog.length ? pairsLog[pairsLog.length - 1].pairs : null;
    pairsLog.push({ tick, pairs });
    if (pairsLog.length > KEEP / 6 + 20) pairsLog.shift();
    if (!pairKind || !prev) return;
    pairs.forEach((o, slot) => {
      const sw = switching.get(slot);
      if (sw) { if (o === sw.to) sw.held++; else switching.delete(slot); }
      else if (o !== NO && prev[slot] !== NO && prev[slot] !== undefined && o !== prev[slot]) switching.set(slot, { onset: tick, from: prev[slot], to: o, held: 1 });
    });
    for (const [slot, sw] of switching) {
      if (tick < sw.onset + AFTER) continue;
      switching.delete(slot);
      const clear = !clips.length || sw.onset > clips[clips.length - 1].onset + 45;
      if (sw.held >= MIN_HELD && clear && snaps.length && snaps[0].tick <= sw.onset - BEFORE) {
        clips.push({ slot, onset: sw.onset, from: sw.onset - BEFORE, to: sw.onset + AFTER, until: sw.onset + 60, was: sw.from, now: sw.to });
        if (clips.length > 20) { clips.shift(); if (at > 0) at--; }
        if (at < 0) { load.done = true; paintLoad(); show(0); setTab('machine'); } else paintBar();
      }
    }
  }
  // Pressing distance (REACH, with every PAIRS frame): how far each defender can get while a
  // pass to his man travels. In the concept's room he acts on it (the act press_distance), so an
  // example is a spell of him stepping off his place to keep his man in reach.
  function reachAt(t) {
    let best = null;
    for (const p of reachLog) { if (p.tick <= t) best = p; else break; }
    return best ? best.reach : null;
  }
  function shadowAt(t) {
    let best = null;
    for (const p of shadowLog) { if (p.tick <= t) best = p; else break; }
    return best ? best.v : null;
  }
  function pairsAt(t) {
    let best = null;
    for (const p of pairsLog) { if (p.tick <= t) best = p; else break; }
    return best ? best.pairs : null;
  }

  // ── getting the first example: a progress bar that says which step it is on (owner 11/24:
  // "we need to show a progress bar on the loading of the video"). The wait is real — the
  // concept has to happen in the live match, then five more seconds have to be played.
  const load = { step: 0, since: performance.now(), done: false };   // 0 words · 1 connecting · 2 watching · 3 recording
  function paintLoad() {
    const box = $('loader');
    if (load.done || (reported === false && !ownKind())) { box.hidden = true; return; }
    box.hidden = false;
    // The furthest-on spell being recorded, if there is one.
    const tick = snaps.length ? snaps[snaps.length - 1].tick : 0;
    let rec = null;
    for (const [slot, p] of pending) if (p.held >= MIN_HELD && (!rec || p.onset < rec.onset)) rec = { slot, onset: p.onset };
    for (const [slot, p] of switching) if (p.held >= MIN_HELD && (!rec || p.onset < rec.onset)) rec = { slot, onset: p.onset };
    if (hello && snaps.length && load.step < 2) { load.step = 2; load.since = performance.now(); }
    const step = rec ? 3 : load.step;
    const secs = Math.round((performance.now() - load.since) / 1000);
    const recPct = rec ? Math.max(0, Math.min(1, (tick - rec.onset) / AFTER)) : 0;
    const pct = step === 0 ? 5 : step === 1 ? 15 : step === 2 ? 30 : Math.round(30 + 70 * recPct);
    $('load-bar').style.width = pct + '%';
    $('load-bar').classList.toggle('wait', step === 2);
    $('load-pct').textContent = step === 2 ? '' : pct + '%';
    $('load-title').textContent = say('load_title');
    const rows = [[0, say('load_words')], [1, say('load_connect')], [2, say('load_watch', { s: step === 2 ? secs : '' })],
                  [3, rec ? say('load_record', { num: numOf(rec.slot), player: nameOf(rec.slot), s: Math.max(0, ((AFTER - (tick - rec.onset)) / 30)).toFixed(0) }) : say('load_record_wait')]];
    const ul = $('load-steps');
    ul.textContent = '';
    for (const [i, text] of rows) { const li = document.createElement('li'); li.className = i < step ? 'done' : i === step ? 'on' : ''; li.textContent = (i < step ? '✓ ' : i === step ? '▸ ' : '· ') + text; ul.appendChild(li); }
  }
  setInterval(paintLoad, 250);

  // ── the example on screen ──
  function show(i) {
    if (!clips.length) return;   // nothing yet: a key pressed while it is still watching
    at = Math.max(0, Math.min(clips.length - 1, i));
    const c = clips[at];
    Object.assign(play, { t: c.from, on: true, holdUntil: 0, last: performance.now(), ended: false, held: false });
    cam.set = false; machineKey = ''; $('side-body').dataset.clip = '';
    // The ticks where his state changes inside this example: the clip holds a beat at each.
    c.changes = [];
    let lastKey = null;
    for (const b of brains) {
      if (b.tick < c.from || b.tick > c.to) continue;
      const [sa] = snapAt(b.tick), s2 = stateOf(b.entries[c.slot], c.slot, sa.ball.owner), k = s2 && s2.state ? s2.state.code : '';
      if (lastKey !== null && k !== lastKey) c.changes.push(b.tick);
      lastKey = k;
    }
    play.flash = null;
    paintBar();
  }
  function snapAt(t) {     // the two snapshots round tick t, and how far between
    let lo = 0, hi = snaps.length - 1;
    while (lo < hi) { const m = (lo + hi + 1) >> 1; if (snaps[m].tick <= t) lo = m; else hi = m - 1; }
    const a = snaps[lo], b = snaps[Math.min(lo + 1, snaps.length - 1)];
    return [a, b, b.tick > a.tick ? Math.max(0, Math.min(1, (t - a.tick) / (b.tick - a.tick))) : 0];
  }
  function brainAt(t) {
    let best = null;
    for (const b of brains) { if (b.tick <= t) best = b; else break; }
    return best ? best.entries : null;
  }
  const lerp = (a, b, k) => a + (b - a) * k;
  function posAt(t, slot) { const [a, b, k] = snapAt(t); return { x: lerp(a.players[slot].x, b.players[slot].x, k), y: lerp(a.players[slot].y, b.players[slot].y, k) }; }

  // ── drawing ──
  const cv = $('pitch'), g = cv.getContext('2d');
  let W = 0, H = 0;
  function layout() {
    const box = cv.parentElement.getBoundingClientRect(), dpr = Math.min(window.devicePixelRatio || 1, 2);
    W = box.width; H = box.height;
    cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
    g.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  const hex = (n) => '#' + (n >>> 0).toString(16).padStart(6, '0').slice(-6);
  const ink = (n) => (((n >> 16) & 255) * 299 + ((n >> 8) & 255) * 587 + (n & 255) * 114) / 1000 > 150 ? '#0b1c3d' : '#ffffff';
  const kitOf = (i, keeper) => { const t = teamOf(i), k = kits[t] && kits[t].shirt != null ? kits[t].shirt : (t ? 0xeef1f6 : 0x14326e); return keeper ? (t ? 0xff8a1f : 0x2e9e44) : k; };
  const cam = { x: 0, y: 0, span: 40, set: false };

  function frame(now) {
    requestAnimationFrame(frame);
    if (!W) layout();
    g.fillStyle = '#0b1c3d'; g.fillRect(0, 0, W, H);
    const c = clips[at];
    if (!c || !snaps.length || !hello) return;

    // Time: once through, a freeze where it starts, then stop on the last frame.
    const dt = Math.min(0.1, (now - play.last) / 1000); play.last = now;
    if (play.on && now >= play.holdUntil) {
      const was = play.t;
      play.t += dt * 30 * play.rate;
      if (!play.held && was < c.onset && play.t >= c.onset) { play.t = c.onset; play.held = true; play.holdUntil = now + 1100; }
      for (const ch of c.changes || []) if (was < ch && play.t >= ch && ch !== c.onset) { play.t = ch; play.holdUntil = now + 800; play.flash = now + 1800; break; }
      if (play.held && play.t === c.onset && !play.flash) play.flash = now + 2200;
      if (play.t >= c.to) { play.t = c.to; play.on = false; play.ended = true; paintBar(); }
    }
    const t = play.t, me = posAt(t, c.slot), entries = brainAt(t), e = entries && entries[c.slot];
    const doing = t >= c.onset && t <= c.until + 6;
    const [sa] = snapAt(t);
    const ballP = (() => { const [a, b, k] = snapAt(t); return { x: lerp(a.ball.x, b.ball.x, k), y: lerp(a.ball.y, b.ball.y, k), owner: a.ball.owner }; })();
    // Who he is acting on: the man his orders name, else their man on the ball, else the ball.
    const pairs = pairsAt(t);
    let other = e && e.other !== NO && e.other < sa.players.length ? e.other : null;
    if (pairKind) other = pairs && pairs[c.slot] !== NO ? pairs[c.slot] : (t < c.onset ? c.was : c.now);
    if (reachKind && pairs && pairs[c.slot] !== NO) other = pairs[c.slot];
    if (other == null && ballP.owner !== NO && teamOf(ballP.owner) !== teamOf(c.slot)) other = ballP.owner;
    const op = other != null ? posAt(t, other) : ballP;

    // His side attacks up the screen: off his keeper's end at this moment.
    let sg = teamOf(c.slot) === 0 ? 1 : -1;
    for (let i = 0; i < sa.players.length; i++) if (teamOf(i) === teamOf(c.slot) && (sa.players[i].flags & 2)) { sg = sa.players[i].x < 0 ? 1 : -1; break; }
    // Camera: between him and what he is acting on, wide enough for both and where he is heading.
    const tx = e ? e.tx : me.x, ty = e ? e.ty : me.y;
    const cx = (me.x + op.x) / 2, cy = (me.y + op.y) / 2;
    const span = Math.max(26, 2.4 * Math.hypot(me.x - op.x, me.y - op.y), 2.4 * Math.hypot(me.x - tx, me.y - ty));
    if (!cam.set) { Object.assign(cam, { x: cx, y: cy, span, set: true }); }
    cam.x += (cx - cam.x) * 0.08; cam.y += (cy - cam.y) * 0.08; cam.span += (Math.min(span, 70) - cam.span) * 0.06;
    const sc = Math.min(W, H) / cam.span;
    const P = (x, y) => [W / 2 + sg * (y - cam.y) * sc, H / 2 - sg * (x - cam.x) * sc];
    const line = (x0, y0, x1, y1) => { const a = P(x0, y0), b = P(x1, y1); g.beginPath(); g.moveTo(a[0], a[1]); g.lineTo(b[0], b[1]); g.stroke(); };

    // Pitch.
    g.save();
    g.beginPath(); g.rect(0, 0, W, H); g.clip();
    const corners = [P(-52.5, -34), P(52.5, -34), P(52.5, 34), P(-52.5, 34)];
    g.fillStyle = '#2f6b2a'; g.beginPath(); corners.forEach((p, i) => (i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]))); g.closePath(); g.fill();
    g.strokeStyle = 'rgba(255,255,255,.55)'; g.lineWidth = 1.5; g.setLineDash([]);
    g.stroke();
    line(0, -34, 0, 34);
    { const c0 = P(0, 0); g.beginPath(); g.arc(c0[0], c0[1], 9.15 * sc, 0, Math.PI * 2); g.stroke(); }
    for (const s of [-1, 1]) for (const [d, w] of [[16.5, 20.16], [5.5, 9.16]]) { const gx = 52.5 * s; line(gx, -w, gx - d * s, -w); line(gx - d * s, -w, gx - d * s, w); line(gx - d * s, w, gx, w); }

    // Who has whom: a thin line from each defender to his direct opponent.
    if (showPairs && pairs) {
      g.strokeStyle = 'rgba(255,255,255,.45)'; g.lineWidth = 1.5; g.setLineDash([3, 5]);
      pairs.forEach((o, i) => { if (o !== NO && i !== c.slot && o < sa.players.length) { const a = posAt(t, i), b = posAt(t, o); line(a.x, a.y, b.x, b.y); } });
      g.setLineDash([]);
    }
    // Pressing distance: his reach as a ring round him — how far he can get while a pass to his
    // man travels, right now. Green = his man is inside it.
    let reachNow = null;
    if (reachKind && other != null) {
      const live = reachAt(t), lr = live && live[c.slot];
      if (lr && lr.reach != null) {
        const gap = Math.hypot(me.x - op.x, me.y - op.y), ok = gap <= lr.reach, q = P(me.x, me.y);
        reachNow = { m: lr.reach, gap, ok };
        g.beginPath(); g.arc(q[0], q[1], lr.reach * sc, 0, Math.PI * 2);
        g.fillStyle = ok ? 'rgba(124,252,138,.16)' : 'rgba(255,92,122,.14)'; g.fill();
        g.lineWidth = 3; g.strokeStyle = ok ? '#7cfc8a' : '#ff5c7a'; g.stroke();
      }
    }
    // The cover shadow: the wedge of pitch behind him as seen from the ball — a ground pass into
    // it goes through him. Who stands in it is the engine's own read (frame SHADOW).
    let shade = null;
    if (shadowKind && doing && ballP.owner !== NO && teamOf(ballP.owner) !== teamOf(c.slot)) {   // only while he is closing down a man who has it
      const sv = shadowAt(t), d = Math.hypot(me.x - ballP.x, me.y - ballP.y);
      if (sv && d > 0.5) {
        const mask = sv.hidden[c.slot] >>> 0, scr = sv.screen[teamOf(c.slot)];
        shade = { hidden: [], screen: scr !== NO && scr < sa.players.length ? scr : null };
        for (let i = 0; i < sa.players.length; i++) if ((mask >>> i) & 1) shade.hidden.push(i);
        const h = Math.atan2(me.y - ballP.y, me.x - ballP.x), a = Math.asin(Math.min(1, sv.body / d)), R = 45;
        const pt = (ang, r) => P(ballP.x + Math.cos(ang) * r, ballP.y + Math.sin(ang) * r);
        const q = [pt(h - a, d), pt(h - a, R), pt(h + a, R), pt(h + a, d)];
        g.beginPath(); q.forEach((p, i) => (i ? g.lineTo(p[0], p[1]) : g.moveTo(p[0], p[1]))); g.closePath();
        g.fillStyle = 'rgba(6,10,20,.55)'; g.fill();
        g.strokeStyle = 'rgba(255,204,0,.7)'; g.lineWidth = 1.5; g.setLineDash([6, 6]); g.stroke(); g.setLineDash([]);
        if (shade.screen != null && !shade.hidden.includes(shade.screen)) {   // the pass he should be blocking, and is not
          const r = posAt(t, shade.screen);
          g.strokeStyle = 'rgba(255,255,255,.85)'; g.lineWidth = 2; g.setLineDash([4, 6]); line(ballP.x, ballP.y, r.x, r.y); g.setLineDash([]);
        }
      }
    }
    // His path so far in this example: where he has come from.
    g.fillStyle = 'rgba(255,204,0,.55)';
    for (let k = c.from; k < t; k += 6) { const p = posAt(k, c.slot), q = P(p.x, p.y); g.beginPath(); g.arc(q[0], q[1], 2.5, 0, Math.PI * 2); g.fill(); }
    // Where he is heading.
    if (doing && Math.hypot(tx - me.x, ty - me.y) > 0.8) {
      g.strokeStyle = '#ffcc00'; g.lineWidth = 2.5; g.setLineDash([7, 6]); line(me.x, me.y, tx, ty); g.setLineDash([]);
      const q = P(tx, ty); g.beginPath(); g.arc(q[0], q[1], 0.9 * sc, 0, Math.PI * 2); g.stroke();
    }
    let gapAt = null;
    // The gap between him and the man he is acting on, in metres.
    if (other != null) {
      g.strokeStyle = 'rgba(255,92,122,.9)'; g.lineWidth = 2; line(me.x, me.y, op.x, op.y);
      gapAt = P((me.x + op.x) / 2, (me.y + op.y) / 2);
    }
    // Everyone: dim, but him and his man.
    const r = Math.max(11, 1.05 * sc);
    for (let i = 0; i < sa.players.length; i++) {
      const p = posAt(t, i), q = P(p.x, p.y), lead = i === c.slot || i === other, star = lead || (shade && (shade.hidden.includes(i) || shade.screen === i)), col = kitOf(i, !!(sa.players[i].flags & 2));
      g.globalAlpha = star ? 1 : 0.32;
      g.beginPath(); g.arc(q[0], q[1], r, 0, Math.PI * 2); g.fillStyle = hex(col); g.fill();
      g.lineWidth = 1.5; g.strokeStyle = 'rgba(0,0,0,.55)'; g.stroke();
      g.fillStyle = ink(col); g.font = `800 ${Math.round(r)}px system-ui, sans-serif`; g.textAlign = 'center'; g.textBaseline = 'middle';
      g.fillText(numOf(i), q[0], q[1] + 0.5);
      g.globalAlpha = 1;
      if (lead) {
        g.lineWidth = 4; g.strokeStyle = i === c.slot ? '#ffcc00' : '#ff5c7a';
        g.beginPath(); g.arc(q[0], q[1], r + 6, 0, Math.PI * 2); g.stroke();
      }
    }
    { const q = P(ballP.x, ballP.y); g.beginPath(); g.arc(q[0], q[1], Math.max(5, 0.4 * sc), 0, Math.PI * 2); g.fillStyle = '#fff'; g.fill(); g.lineWidth = 2; g.strokeStyle = '#111'; g.stroke(); }
    // What each of the two is doing, written on him (the state for the player; the decision for his man).
    const st = (() => { const l = layersAt(t, c.slot); return l.state ? { state: l.state } : stateOf(e, c.slot, ballP.owner); })();
    const tag = (pos, text, fg, bg, below) => {
      if (!text) return;
      const q = P(pos.x, pos.y);
      g.font = '800 14px system-ui, sans-serif'; g.textAlign = 'center'; g.textBaseline = 'middle';
      const w = g.measureText(text).width + 14, y = q[1] + (below ? r + 22 : -(r + 22));
      g.fillStyle = bg; g.fillRect(q[0] - w / 2, y - 12, w, 24);
      g.fillStyle = fg; g.fillText(text, q[0], y + 1);
    };
    if (gapAt) {   // the metres between them, drawn last so nothing covers it; beside the line when they are close
      const d = Math.hypot(me.x - op.x, me.y - op.y), text = d.toFixed(1) + ' m';
      if (d * sc < 6 * r) gapAt[1] -= 3.2 * r;
      g.font = '800 15px system-ui, sans-serif'; g.textAlign = 'center'; g.textBaseline = 'middle';
      const w = g.measureText(text).width + 12; g.fillStyle = 'rgba(8,12,18,.9)'; g.fillRect(gapAt[0] - w / 2, gapAt[1] - 12, w, 24);
      g.fillStyle = '#ff9fb2'; g.fillText(text, gapAt[0], gapAt[1] + 1);
    }
    const flashing = play.flash && now < play.flash;
    tag(me, st && st.state ? (flashing ? say('cap_now', { state: st.state.title }) : st.state.title) : '', '#0b1c3d', flashing ? '#ffffff' : '#ffcc00', true);
    if (other != null) { const ol = layersAt(t, other); tag(op, ol.state ? ol.state.title : '', '#fff', 'rgba(200,40,70,.92)', op.x * sg > me.x * sg ? false : true); }   // his man's own state, the same words as the panel
    if (shade) {   // who is in his shadow, and the pass left open
      for (const i of shade.hidden) tag(posAt(t, i), say('shadow_hidden'), '#fff', 'rgba(6,10,20,.92)', false);
      if (shade.screen != null && !shade.hidden.includes(shade.screen)) tag(posAt(t, shade.screen), say('shadow_open'), '#0b1c3d', '#ffffff', false);
    }
    if (showPairs && pairs) {   // the spare man of the defending side and the man they leave free
      const def = teamOf(c.slot);
      const watched = new Set(pairs.filter((o, i) => o !== NO && teamOf(i) === def));
      for (let i = 0; i < sa.players.length; i++) {
        if (sa.players[i].flags & 2) continue;
        if (teamOf(i) === def && pairs[i] === NO) tag(posAt(t, i), say('pairs_spare'), '#0b1c3d', '#9fe39f', false);
        else if (teamOf(i) !== def && !watched.has(i)) tag(posAt(t, i), say('pairs_free'), '#0b1c3d', '#9fe39f', false);
      }
    }
    g.restore();

    // The caption: exactly what is happening, in words.
    const gapNow = Math.hypot(me.x - op.x, me.y - op.y);
    const before = Math.max(c.from, t - 15), mb = posAt(before, c.slot), ob = other != null ? posAt(before, other) : ballP;
    const gapWas = Math.hypot(mb.x - ob.x, mb.y - ob.y), trend = gapWas - gapNow > 0.25 ? 'cap_closing' : gapNow - gapWas > 0.25 ? 'cap_opening' : 'cap_steady';
    const l1 = st && st.state ? say('cap_line', { num: numOf(c.slot), player: nameOf(c.slot), state: st.state.title }) : '';
    // Out of play is said out loud: the ball over the line with a restart waiting is the match, not a glitch.
    const dead = sa.restart !== NO && sa.restart !== undefined;
    const l2 = (dead ? say('cap_ball_dead', { team: teamNames[sa.restart] || '' })
      : ballP.owner !== NO ? say('cap_ball_with', { num: numOf(ballP.owner), player: nameOf(ballP.owner) }) : say('cap_ball_loose'))
      + (other != null ? '   ·   ' + say('cap_gap', { d: gapNow.toFixed(1), num: numOf(other) }) + ', ' + say(trend) : '');
    // Line 1 says the brain in the panel's own words: team phase · his state · the concept he is
    // using in it. Line 2 is what this concept's picture shows (or the ball and the gap).
    const lay = layersAt(t, c.slot);
    const cap1 = say('cap_layers', { num: numOf(c.slot), player: nameOf(c.slot), phase: lay.phase ? lay.phase.title : '—',
                                     state: lay.state ? lay.state.title : '—', using: lay.concept ? lay.concept.title : say('brain_nothing') });
    let cap2 = l2;
    if (pairKind || showPairs) {
      const o = pairs ? pairs[c.slot] : NO;
      const h = pairs && pairs.how ? pairs.how[c.slot] : null;
      const why = h === 'matchup' ? say('pair_matchup', { num: numOf(c.slot), man: numOf(o) }) : h === 'battle' ? say('pair_battle') : h === 'nearest' ? say('pair_nearest') : '';
      const who = o !== NO && o !== undefined ? say('cap_his_man', { num: numOf(o), player: nameOf(o) }) + (why ? '  (' + why + ')' : '') : say('cap_no_man');
      if (pairKind) cap2 = t >= c.onset && t < c.onset + 75 ? who + '   ·   ' + say('cap_switch', { from: numOf(c.was), to: numOf(c.now) }) : who;
    }
    if (shadowKind && shade) {
      const who = { num: numOf(c.slot), player: nameOf(c.slot) };
      cap2 = shade.hidden.length ? say('cap_shadow', { ...who, list: shade.hidden.map((i) => '#' + numOf(i)).join(', ') })
        : shade.screen != null ? say('cap_shadow_open', { ...who, man: numOf(shade.screen) }) : say('cap_shadow_none', who);
    }
    if (reachKind && reachNow) cap2 = say('cap_reach_live', { num: numOf(c.slot), player: nameOf(c.slot), man: numOf(other), gap: reachNow.gap.toFixed(1), reach: reachNow.m.toFixed(1), verdict: say(reachNow.ok ? 'reach_in' : 'reach_out') });
    if (cap1 !== frame.l1) { frame.l1 = cap1; $('cap1').textContent = cap1; }
    if (cap2 !== frame.l2) { frame.l2 = cap2; $('cap2').textContent = cap2; }

    // BEFORE / DOING IT / AFTER, and the timeline with the doing-it part filled in.
    const phase = t < c.onset ? 'before' : doing ? 'doing' : 'after';
    if (phase !== frame.phase || at !== frame.at) { frame.phase = phase; frame.at = at; paintPhase(phase); }
    if (sideTab === 'machine') paintBrain(c, t);
    const bar = $('time');
    const pct = (k) => (100 * (k - c.from) / (c.to - c.from)).toFixed(2) + '%';
    bar.style.setProperty('--from', pct(c.onset)); bar.style.setProperty('--to', pct(Math.min(c.until + 6, c.to))); bar.style.setProperty('--now', pct(t));
  }

  // ── his state machine, beside the pitch ──
  // The match sends each man's DECISION (ai::Why, by its wire number) and the concept he is
  // playing, not his state; game_engine_terms says which state a decision belongs to, and a
  // "hold" is the block spot without the ball and support with it.
  function stateOf(e, slot, owner) {
    if (!e) return null;
    const d = terms.find((x) => x.kind === 'decision' && x.wire === e.why);
    if (!d) return null;
    const ours = owner !== NO && teamOf(owner) === teamOf(slot);
    const code = d.code === 'hold' && ours ? 'support' : d.parent;
    return { decision: d, state: terms.find((x) => x.kind === 'state' && x.code === code) || null, ours };
  }
  // ── 🧠 the brain, beside the pitch ──
  // Owner 11/24: "is he in 'stay in pressing distance' the whole time … we need a way to display
  // the state machines and how many there are. i assume the hold position is a sub state machine
  // or is it at same level? can you be in 2 states of same machine. we need this explained on the
  // graphic" · "it needs to be crystal clear what is going on in the brain and what we are seeing".
  //
  // So the panel draws the layers the engine actually has, one LANE each across the example,
  // with a playhead:
  //   TEAM      one phase at a time, shared by all eleven (game_engine_terms kind phase)
  //   HIM       one state at a time (kind state) — never two states of the same machine
  //   USING     inside that state, none or one concept (the act the BRAIN feed names) — it
  //             changes HOW he does the state, it is not a state of its own
  //   KNOWS     reads, always running: his man, can he reach him, who is in his shadow — they
  //             tell him things and decide nothing
  // Then RIGHT NOW in words, and one line: is THIS concept active, and if not, why not.
  let machineKey = '';
  const openDefs = new Set();
  const OURS_PHASES = new Set([0, 1, 4]);   // ai::Phase: in possession, attacking transition, our set piece
  function logAt(log, t) { let best = null; for (const p of log) { if (p.tick <= t) best = p; else break; } return best ? best.v : null; }
  // The three machines' answers for one player at one moment.
  function layersAt(t, slot) {
    const entries = brainAt(t), e = entries && entries[slot], [sa] = snaps.length ? snapAt(t) : [null];
    // His state is the engine's own (STATES); the order-based guess only before that frame arrives.
    const sl = logAt(stateLog, t), code = sl ? sl[slot] : null;
    const real = code ? (terms.find((x) => x.kind === 'state' && x.code === code) || { code, title: code }) : null;
    const st = real ? { state: real, decision: null } : (sa ? stateOf(e, slot, sa.ball.owner) : null);
    const ph = logAt(phaseLog, t), pi = ph ? ph[teamOf(slot)] : null;
    const phases = terms.filter((x) => x.kind === 'phase');
    const cid = e && e.concept !== NO && legend[e.concept] ? e.concept : null;
    const cRow = cid != null ? ((tax.concepts || []).find((k) => k.id === cid) || { id: cid, title: legend[cid].title }) : null;
    return { phase: pi != null ? phases[pi] || null : null, phaseIndex: pi, state: st && st.state, decision: st && st.decision, concept: cRow };
  }
  function paintBrain(c, t) {
    const host = $('side-body');
    const pct = (k) => Math.max(0, Math.min(100, 100 * (k - c.from) / (c.to - c.from)));
    host.style.setProperty('--nowf', (pct(t) / 100).toFixed(4));
    const lay = layersAt(t, c.slot);
    const pairs = pairsAt(t), reach = reachAt(t), sv = shadowAt(t);
    const man = pairs && pairs[c.slot] !== NO ? pairs[c.slot] : null;
    const r = reach && reach[c.slot];
    const status = conceptStatus(lay, r);
    const key = [at, lay.phase && lay.phase.code, lay.state && lay.state.code, lay.concept && lay.concept.id, man, pairs && pairs.how ? pairs.how[c.slot] : '', r ? r.in + '' + Math.round(r.reach || 0) : '', status.kind, [...openDefs].join(',')].join('|');
    if (key === machineKey) return;
    const fresh = !host.dataset.clip || host.dataset.clip !== String(at) || machineKey.split('|').pop() !== [...openDefs].join(',');
    machineKey = key;
    if (fresh) { host.dataset.clip = String(at); buildBrain(c, host); }
    // RIGHT NOW
    const set = (id, text) => { const n = host.querySelector('#' + id); if (n) n.textContent = text; };
    set('bn-phase', lay.phase ? lay.phase.title : '—');
    set('bn-state', lay.state ? lay.state.title : '—');
    set('bn-using', lay.concept ? lay.concept.title : say('brain_nothing'));
    const how = pairs && pairs.how ? pairs.how[c.slot] : null;
    const knows = [];
    if (man != null) knows.push(say('brain_knows_man', { man: numOf(man), player: nameOf(man), how: how === 'matchup' ? say('pair_matchup', { num: numOf(c.slot), man: numOf(man) }) : how === 'battle' ? say('pair_battle') : say('pair_nearest') }));
    else if (lay.phaseIndex != null && OURS_PHASES.has(lay.phaseIndex)) knows.push(say('brain_knows_ourball'));   // with the ball nobody has a direct opponent
    else if (pairs) knows.push(say('brain_knows_noman'));
    if (r && r.reach != null && man != null) {
      const [a, b] = [posAt(t, c.slot), posAt(t, man)];
      knows.push(say('brain_knows_reach', { gap: Math.hypot(a.x - b.x, a.y - b.y).toFixed(1), reach: r.reach.toFixed(1), verdict: say(r.in ? 'reach_in' : 'reach_out') }));
    }
    if (sv && shadowKind) { const m = sv.hidden[c.slot] >>> 0, hid = []; for (let i = 0; i < 32; i++) if ((m >>> i) & 1) hid.push('#' + numOf(i)); knows.push(hid.length ? say('brain_knows_shadow', { list: hid.join(', ') }) : say('brain_knows_noshadow')); }
    set('bn-knows', knows.join('   ·   ') || '—');
    const sn = host.querySelector('#bn-status');
    if (sn) { sn.textContent = status.text; sn.className = 'status ' + status.kind; }
    // the lists of every state, his lit
    for (const n of host.querySelectorAll('[data-term]')) {
      const [k, code] = n.dataset.term.split(':');
      n.classList.toggle('on', (k === 'phase' && lay.phase && lay.phase.code === code) || (k === 'state' && lay.state && lay.state.code === code));
    }
  }
  // Is THIS concept active right now — and if not, the reason, from the brain's own layers.
  function conceptStatus(lay, r) {
    const title = concept ? concept.title : '';
    if (pairKind) return { kind: 'read', text: say('brain_status_read', { concept: title }) };
    if (lay.concept && lay.concept.id === CONCEPT) return { kind: 'on', text: say('brain_status_on', { concept: title }) };
    if (lay.phaseIndex != null && OURS_PHASES.has(lay.phaseIndex) && concept && concept.moment === 'out_of_possession')
      return { kind: 'off', text: say('brain_status_ourball', { concept: title }) };
    const dial = (tax.dials || []).find((d) => d.concept_id === CONCEPT) || DIAL_STATES[concept ? concept.name : ''];
    const inState = dial ? terms.find((x) => x.kind === 'state' && x.code === dial.in_state) : null;
    if (inState && (!lay.state || lay.state.code !== inState.code))
      return { kind: 'off', text: say('brain_status_otherstate', { concept: title, state: lay.state ? lay.state.title : '—', host: inState.title }) };
    if (reachKind && r && r.in) return { kind: 'off', text: say('brain_status_inreach', { concept: title }) };
    return { kind: 'off', text: say('brain_status_nothing', { concept: title }) };
  }
  // Which state each switched-on concept lives in (game_concept_dials.in_state, mig 1867).
  const DIAL_STATES = {};
  function buildBrain(c, host) {
    host.textContent = '';
    const add = (tag, cls, text, parent) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; (parent || host).appendChild(n); return n; };
    const term = (parent, tag, cls, title, id, def) => {
      const n = add(tag, cls + (def ? ' tap' : ''), title, parent);
      if (!def) return n;
      n.dataset.def = id;
      if (openDefs.has(id)) add('small', '', def, n);
      return n;
    };
    const sdef = (x) => (x ? x.definition || x.note || '' : '');
    add('h2', '', say('clip_sm_title', { num: numOf(c.slot), player: nameOf(c.slot) }));
    // How to read it — the layers, in one box, always on screen.
    const how = add('div', 'howto');
    add('div', 'howto-t', say('brain_howto_title'), how);
    for (const k of ['brain_howto_team', 'brain_howto_him', 'brain_howto_using', 'brain_howto_knows']) add('div', 'howto-l', say(k), how);
    // RIGHT NOW + the status line
    add('div', 'status', '', host).id = 'bn-status';
    const now = add('div', 'nowbox');
    for (const [id, lab] of [['bn-phase', 'brain_lane_team'], ['bn-state', 'brain_lane_him'], ['bn-using', 'brain_lane_using'], ['bn-knows', 'brain_lane_knows']]) {
      const row = add('div', 'nowrow', null, now);
      add('span', 'nowlab', say(lab), row);
      add('span', 'nowval', '', row).id = id;
    }
    // The lanes: one per layer, across this example.
    add('h3', '', say('brain_lanes'));
    const lanes = add('div', 'lanes');
    const phases = terms.filter((x) => x.kind === 'phase');
    const lane = (label, segs, colour) => {
      const row = add('div', 'lane', null, lanes);
      add('div', 'lane-l', label, row);
      const track = add('div', 'lane-t', null, row);
      for (const g of segs) {
        if (!g.text) continue;
        const b = add('div', 'seg', g.text, track);
        b.style.left = g.a + '%'; b.style.width = Math.max(0.8, g.b - g.a) + '%';
        b.style.background = colour(g); b.title = g.text;
      }
      return row;
    };
    const segsOf = (fn) => {   // merge consecutive brain frames with the same text
      const out = [];
      for (const b of brains) {
        if (b.tick < c.from || b.tick > c.to) continue;
        const text = fn(b.tick) || '', p = 100 * (b.tick - c.from) / (c.to - c.from);
        if (out.length && out[out.length - 1].text === text) out[out.length - 1].b = p + 0.6;
        else { if (out.length) out[out.length - 1].b = p; out.push({ text, a: p, b: p + 0.6 }); }
      }
      return out;
    };
    const hue = (t) => { let h = 0; for (const ch of t) h = (h * 31 + ch.charCodeAt(0)) % 360; return `hsl(${h} 45% 38%)`; };
    lane(say('brain_lane_team') + ' · ' + say('brain_count', { n: phases.length }), segsOf((k) => { const ph = logAt(phaseLog, k); const pi = ph ? ph[teamOf(c.slot)] : null; return pi != null && phases[pi] ? phases[pi].title : ''; }), (g) => hue(g.text));
    const states = terms.filter((x) => x.kind === 'state');
    lane(say('brain_lane_him') + ' · ' + say('brain_count', { n: states.length }), segsOf((k) => { const l = layersAt(k, c.slot); return l.state ? l.state.title : ''; }), (g) => hue(g.text));
    lane(say('brain_lane_using') + ' · ' + say('brain_count_using'), segsOf((k) => { const l = layersAt(k, c.slot); return l.concept ? l.concept.title : ''; }), (g) => (/pressing distance|shadow/i.test(g.text) && concept && g.text === concept.title ? '#b8860b' : hue(g.text)));
    lane(say('brain_lane_man'), segsOf((k) => { const p = pairsAt(k); return p && p[c.slot] !== NO ? '#' + numOf(p[c.slot]) + (p.how && p.how[c.slot] === 'battle' ? ' ⚔' : '') : ''; }), () => 'rgba(255,255,255,.18)');
    if (reachKind) lane(say('brain_lane_reach'), segsOf((k) => { const rr = reachAt(k); const x = rr && rr[c.slot]; return x && x.reach != null ? say(x.in ? 'brain_in' : 'brain_out') : ''; }), (g) => (g.text === say('brain_in') ? '#2e8b45' : '#a83248'));
    if (shadowKind) lane(say('brain_lane_shadow'), segsOf((k) => { const v = shadowAt(k); if (!v) return ''; const m = v.hidden[c.slot] >>> 0; const h = []; for (let i = 0; i < 32; i++) if ((m >>> i) & 1) h.push('#' + numOf(i)); return h.join(' '); }), () => '#444c66');
    add('div', 'playhead', null, lanes);
    add('div', 'note', say('brain_lanes_note'));
    // Every state of each machine, his lit — how many there are.
    const all = add('details', 'all');
    add('summary', '', say('brain_all', { phases: phases.length, states: states.length }), all);
    add('h3', '', say('brain_lane_team') + ' — ' + say('brain_count', { n: phases.length }), all);
    const ul1 = add('ul', 'two', null, all);
    for (const p of phases) term(ul1, 'li', '', p.title, 'ph:' + p.code, sdef(p)).dataset.term = 'phase:' + p.code;
    add('h3', '', say('brain_lane_him') + ' — ' + say('brain_count', { n: states.length }), all);
    const ul2 = add('ul', 'two', null, all);
    for (const x of states) term(ul2, 'li', '', x.title, 's:' + x.code, sdef(x)).dataset.term = 'state:' + x.code;
    add('div', 'note', say('clip_sm_tap'));
  }

  // ── 📖 What it is: real football · the game · the engine code (owner 11/24: "the popup
  // needs to explain also what the concept is in real life, the game and the engine code").
  // Every line is the taxonomy's own: the concept row, its behaviours, their classes.
  function paintExplain() {
    const host = $('side-body');
    host.textContent = '';
    const add = (tag, cls, text, parent) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; (parent || host).appendChild(n); return n; };
    const c = concept;
    add('h3', 'big', say('clip_x_real'));
    if (c) {
      if (c.definition) add('p', '', c.definition);
      if (c.cue) { add('div', 'lab', say('clip_x_cue')); add('p', '', c.cue); }
      if (c.lacking) { add('div', 'lab', say('clip_x_lacking')); add('p', '', c.lacking); }
      const pr = (tax.principles || []).find((p) => p.id === c.principle_id);
      if (pr) add('p', 'dim', say('clip_x_principle', { p: pr.title }));
      if (c.taught_from) add('p', 'dim', say('clip_x_taught', { a: c.taught_from }));
      const byId = new Map((tax.concepts || []).map((k) => [k.id, k]));
      const words = { 'kind-of': 'link_kind_of', 'step-of': 'link_step_of', requires: 'link_requires', refines: 'link_refines', counters: 'link_counters', 'lapses-to': 'link_lapses_to' };
      for (const l of tax.links || []) {
        if (l.from === c.id && byId.get(l.to)) add('p', 'dim', say(words[l.kind]) + ' ' + byId.get(l.to).title);
        else if (l.to === c.id && byId.get(l.from)) add('p', 'dim', say(words[l.kind] + '_by') + ' ' + byId.get(l.from).title);
      }
      if (c.sources) add('p', 'dim', say('clip_x_sources', { n: c.sources }));
    }
    const behs = (tax.behaviours || []).filter((b) => b.concept_id === CONCEPT);
    add('h3', 'big', say('clip_x_game'));
    if (!behs.length) add('p', '', say('clip_x_nogame'));
    else {
      add('p', 'state', say(behs.some((b) => b.in_sim !== false) ? 'clip_x_used' : 'clip_x_zero'));
      for (const b of behs) { add('p', '', b.what); if (b.tag) add('p', 'dim', say('clip_x_built', { tag: b.tag })); }
    }
    add('h3', 'big', say('clip_x_code'));
    if (!behs.length) add('p', '', say('clip_x_nocode'));
    const cls = new Map((tax.classes || []).map((k) => [k.name, k]));
    for (const b of behs) {
      const k = b.class ? cls.get(b.class) : null;
      if (k) {
        const chain = [k.name];
        for (let p = k.parent, n = 0; p && n < 10; n++) { chain.push(p); p = cls.get(p) ? cls.get(p).parent : null; }
        add('div', 'lab', say('clip_x_chain'));
        add('p', 'code', chain.join('  →  '));
        if (b.symbol && b.symbol !== k.name) add('p', 'code dim', b.symbol);
        if (k.doc) add('p', 'dim pre', k.doc);
      } else if (b.symbol) add('p', 'code', say('clip_x_func', { symbol: b.symbol }));
      add('p', 'dim', say('clip_x_where', { file: b.file, line: b.line }));
      const btn = add('button', 'small', say('clip_x_show'));
      const pre = add('pre', 'src');
      pre.hidden = true;
      btn.type = 'button';
      btn.addEventListener('click', async () => {
        pre.hidden = !pre.hidden;
        btn.textContent = say(pre.hidden ? 'clip_x_show' : 'clip_x_hide');
        if (pre.hidden || pre.dataset.got) return;
        pre.dataset.got = '1';
        try {
          const res = await fetch('/api/tactic-plans/taxonomy/source?' + new URLSearchParams({ file: b.file, from: Math.max(1, b.line - 4), to: b.line + 40 }), { headers: { Authorization: 'Bearer ' + token } });
          if (!res.ok) throw new Error();
          const src = await res.json();
          pre.textContent = src.text.split('\n').map((line, i) => String(src.from + i).padStart(4) + '  ' + line).join('\n');
        } catch (_) { pre.textContent = say('clip_x_nosrc'); }
      });
    }
  }
  function setTab(tab) {
    sideTab = tab;
    for (const b of document.querySelectorAll('[data-tab]')) b.classList.toggle('on', b.dataset.tab === tab);
    machineKey = ''; $('side-body').dataset.clip = '';
    if (tab === 'explain') paintExplain(); else $('side-body').textContent = '';
  }

  // ── words and controls ──
  function paintPhase(phase) {
    for (const k of ['before', 'doing', 'after']) $('ph-' + k).classList.toggle('on', k === phase);
  }
  function paintBar() {
    const c = clips[at], n = clips.length;
    $('which').textContent = reported === false && !ownKind() ? say('clip_unreported')
      : c ? say(reachKind ? 'clip_which_reach_on' : pairKind ? 'clip_which_switch' : 'clip_which', { i: at + 1, n, player: nameOf(c.slot), num: numOf(c.slot) }) : say('clip_waiting');
    $('dots').textContent = '';
    clips.forEach((_, i) => { const d = document.createElement('button'); d.type = 'button'; d.className = 'dot' + (i === at ? ' on' : ''); d.title = String(i + 1); d.addEventListener('click', () => show(i)); $('dots').appendChild(d); });
    $('prev').disabled = !c || at <= 0;
    $('next').disabled = !c || at >= n - 1;
    $('replay').disabled = !c;
    $('replay').classList.toggle('pulse', !!c && play.ended);
    $('pause').disabled = !c || play.ended;
    $('pause').textContent = say(play.on ? 'clip_pause' : 'clip_play');
    for (const b of document.querySelectorAll('[data-rate]')) b.classList.toggle('on', Number(b.dataset.rate) === play.rate);
  }

  (async function () {
    const [r1, r2] = await Promise.all([
      fetch('/api/messages/templates/copy', { headers: { Authorization: 'Bearer ' + token } }),
      fetch('/api/tactic-plans/taxonomy', { headers: { Authorization: 'Bearer ' + token } })]);
    if (r1.status === 401) { location.href = '/'; return; }
    for (const t of (((await r1.json()).data || {}).templates || [])) if (t.kind === 'taxonomy' && !copy.has(t.tier)) copy.set(t.tier, t.body || '');
    tax = r2.ok ? await r2.json() : {};
    concept = (tax.concepts || []).find((c) => c.id === CONCEPT) || null;
    terms = tax.engine || [];
    pairKind = !!concept && concept.name === 'direct-opponent';
    for (const t of copy.keys()) if (t.startsWith('dial_state_')) DIAL_STATES[t.slice(11)] = { in_state: copy.get(t) };   // which state a switched-on concept lives in
    reachKind = !!concept && concept.name === 'pressing-distance';
    shadowKind = !!concept && concept.name === 'cover-shadow';
    if (shadowKind) reported = true;
    showPairs = pairKind;
    {   // who has whom: on for the direct-opponent concept, a switch for the rest
      const b = document.createElement('button');
      b.type = 'button'; b.id = 'pairs'; b.textContent = say('pairs_show'); b.classList.toggle('on', showPairs);
      b.addEventListener('click', () => { showPairs = !showPairs; b.classList.toggle('on', showPairs); });
      $('rates').after(b);
    }
    document.title = concept ? concept.title : say('clip_title');
    $('title').textContent = concept ? concept.title : say('clip_title');
    $('cue').textContent = concept ? (concept.definition || concept.cue || '') : '';
    {   // which match this is: the concept's own room with it ON, or the live sim
      const b = document.createElement('div');
      b.id = 'room'; b.textContent = roomOn() ? say('room_on', { concept: concept ? concept.title : '' }) : say('room_live');
      b.style.cssText = 'margin-top:6px;font-weight:800;font-size:13px;color:' + (roomOn() ? '#0b1c3d;background:#7cfc8a' : '#e9eef7;background:rgba(255,255,255,.12)') + ';display:inline-block;padding:4px 10px;border-radius:10px';
      $('cue').after(b);
    }
    $('ph-before').textContent = say('clip_before'); $('ph-doing').textContent = say('clip_doing'); $('ph-after').textContent = say('clip_after');
    $('prev').textContent = say('clip_prev'); $('next').textContent = say('clip_next'); $('replay').textContent = say('clip_replay');
    $('speed').textContent = say('clip_speed'); $('legend').textContent = say(reachKind ? 'reach_legend' : shadowKind ? 'shadow_legend' : 'clip_legend');
    for (const [rate, label] of SPEEDS) {
      const b = document.createElement('button');
      b.type = 'button'; b.dataset.rate = rate; b.textContent = label;
      b.addEventListener('click', () => { play.rate = rate; paintBar(); });
      $('rates').appendChild(b);
    }
    $('side-body').addEventListener('click', (ev) => {   // tap a title: its meaning opens / closes
      const n = ev.target.closest('[data-def]');
      if (!n || sideTab !== 'machine') return;
      ev.stopPropagation();
      if (openDefs.has(n.dataset.def)) openDefs.delete(n.dataset.def); else openDefs.add(n.dataset.def);
      machineKey = ''; $('side-body').dataset.clip = '';
    });
    for (const [tab, tier] of [['machine', 'brain_tab'], ['explain', 'clip_tab_explain']]) {
      const b = document.createElement('button');
      b.type = 'button'; b.dataset.tab = tab; b.textContent = say(tier);
      b.addEventListener('click', () => setTab(tab));
      $('side-tabs').appendChild(b);
    }
    setTab('explain');   // what it is first: there is nothing to watch until the first example has happened
    $('prev').addEventListener('click', () => show(at - 1));
    $('next').addEventListener('click', () => show(at + 1));
    $('replay').addEventListener('click', () => show(at));
    $('pause').addEventListener('click', () => { play.on = !play.on; play.last = performance.now(); paintBar(); });
    window.addEventListener('keydown', (e) => {
      if (e.key === ' ') { e.preventDefault(); if (play.ended) show(at); else $('pause').click(); }
      else if (e.key === 'ArrowLeft') show(at - 1);
      else if (e.key === 'ArrowRight') show(at + 1);
      else if (e.key.toLowerCase() === 'r') show(at);
    });
    window.addEventListener('resize', layout);
    layout(); paintBar(); paintPhase('');
    requestAnimationFrame(frame);
    connect();
  })();
})();
