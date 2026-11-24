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
  const snaps = [], brains = [];          // [{tick, players, ball}], [{tick, entries}]
  let hello = null, roster = [], kits = [null, null];
  const pending = new Map();              // slot → { onset, held, last }  (playing it now)
  const clips = [];                       // { slot, onset, from, to, until }
  let at = -1;                            // the example on screen
  const play = { t: 0, rate: 0.5, on: false, holdUntil: 0, last: 0, ended: false };

  const teamOf = (i) => (hello && i < hello.slotCount / 2 ? 0 : 1);
  const numOf = (i) => (roster[i] && roster[i].number) || '';
  const nameOf = (i) => (roster[i] && roster[i].name) || ('#' + numOf(i));

  function connect() {
    const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
    const ws = new WebSocket(`${scheme}://${location.host}/game`, `fh-game.v2.bearer.${token}`);
    ws.binaryType = 'arraybuffer';
    ws.onmessage = (ev) => {
      const view = new DataView(ev.data), T = GameWire.FrameType;
      for (const f of GameWire.decodeFrame(ev.data)) {
        if (f.type === T.HELLO) { hello = GameWire.decodeHello(view, f.payloadAt); ws.send(GameWire.encodeBrainWatch(true)); }
        else if (f.type === T.SNAPSHOT) {
          const s = GameWire.decodeSnapshot(view, f.payloadAt);
          snaps.push({ tick: s.tick, players: s.players, ball: s.ball });
          if (snaps.length > KEEP) snaps.shift();
        } else if (f.type === T.ROSTER) roster = GameWire.decodeRoster(view, f.payloadAt, f.payloadLen);
        else if (f.type === T.TEAMS) kits = GameWire.decodeTeams(view, f.payloadAt, f.payloadLen).kits;
        else if (f.type === T.CONCEPT_LEGEND) { legend = GameWire.decodeConceptLegend(view, f.payloadAt); reported = !!legend[CONCEPT]; paintBar(); }
        else if (f.type === T.BRAIN) see(GameWire.decodeBrain(view, f.payloadAt));
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
      const doing = e && e.concept === CONCEPT, p = pending.get(slot);
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
        if (at < 0) { show(0); setTab('machine'); }   // the first one plays by itself, his state machine beside it
        else paintBar();
      }
    }
  }

  // ── the example on screen ──
  function show(i) {
    at = Math.max(0, Math.min(clips.length - 1, i));
    const c = clips[at];
    Object.assign(play, { t: c.from, on: true, holdUntil: 0, last: performance.now(), ended: false, held: false });
    cam.set = false; machineKey = '';
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
    let other = e && e.other !== NO && e.other < sa.players.length ? e.other : null;
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
      const p = posAt(t, i), q = P(p.x, p.y), star = i === c.slot || i === other, col = kitOf(i, !!(sa.players[i].flags & 2));
      g.globalAlpha = star ? 1 : 0.32;
      g.beginPath(); g.arc(q[0], q[1], r, 0, Math.PI * 2); g.fillStyle = hex(col); g.fill();
      g.lineWidth = 1.5; g.strokeStyle = 'rgba(0,0,0,.55)'; g.stroke();
      g.fillStyle = ink(col); g.font = `800 ${Math.round(r)}px system-ui, sans-serif`; g.textAlign = 'center'; g.textBaseline = 'middle';
      g.fillText(numOf(i), q[0], q[1] + 0.5);
      g.globalAlpha = 1;
      if (star) {
        g.lineWidth = 4; g.strokeStyle = i === c.slot ? '#ffcc00' : '#ff5c7a';
        g.beginPath(); g.arc(q[0], q[1], r + 6, 0, Math.PI * 2); g.stroke();
      }
    }
    { const q = P(ballP.x, ballP.y); g.beginPath(); g.arc(q[0], q[1], Math.max(5, 0.4 * sc), 0, Math.PI * 2); g.fillStyle = '#fff'; g.fill(); g.lineWidth = 2; g.strokeStyle = '#111'; g.stroke(); }
    // What each of the two is doing, written on him (the state for the player; the decision for his man).
    const st = stateOf(e, c.slot, ballP.owner);
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
    if (other != null) { const os = stateOf(entries && entries[other], other, ballP.owner); tag(op, os ? os.decision.title : '', '#fff', 'rgba(200,40,70,.92)', op.x * sg > me.x * sg ? false : true); }
    g.restore();

    // The caption: exactly what is happening, in words.
    const gapNow = Math.hypot(me.x - op.x, me.y - op.y);
    const before = Math.max(c.from, t - 15), mb = posAt(before, c.slot), ob = other != null ? posAt(before, other) : ballP;
    const gapWas = Math.hypot(mb.x - ob.x, mb.y - ob.y), trend = gapWas - gapNow > 0.25 ? 'cap_closing' : gapNow - gapWas > 0.25 ? 'cap_opening' : 'cap_steady';
    const l1 = st && st.state ? say('cap_line', { num: numOf(c.slot), player: nameOf(c.slot), state: st.state.title }) + (st.state.note ? ' — ' + st.state.note : '') : '';
    const l2 = (ballP.owner !== NO ? say('cap_ball_with', { num: numOf(ballP.owner), player: nameOf(ballP.owner) }) : say('cap_ball_loose'))
      + (other != null ? '   ·   ' + say('cap_gap', { d: gapNow.toFixed(1), num: numOf(other) }) + ', ' + say(trend) : '');
    if (l1 !== frame.l1) { frame.l1 = l1; $('cap1').textContent = l1; }
    if (l2 !== frame.l2) { frame.l2 = l2; $('cap2').textContent = l2; }

    // BEFORE / DOING IT / AFTER, and the timeline with the doing-it part filled in.
    const phase = t < c.onset ? 'before' : doing ? 'doing' : 'after';
    if (phase !== frame.phase || at !== frame.at) { frame.phase = phase; frame.at = at; paintPhase(phase); }
    if (sideTab === 'machine') paintMachine(c, t, e, other, ballP);
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
  let machineKey = '';
  // Every term on this panel carries its definition right there (owner 11/24: "easily
  // accessible definitions on the video loop on side"): the concept's own at the top, a
  // state's under its name (game_engine_terms.note), a concept's cue under its title.
  function paintMachine(c, t, e, other, ball) {
    const st = stateOf(e, c.slot, ball.owner);
    const cById = new Map((tax.concepts || []).map((k) => [k.id, k]));
    const defOf = (id) => (id != null && id !== NO && cById.get(id) ? cById.get(id).cue || '' : '');
    // His states through the example, in order, with how long he was in each.
    const path = [];
    for (const b of brains) {
      if (b.tick < c.from || b.tick > c.to) continue;
      const [sa] = snapAt(b.tick), en = b.entries[c.slot], s2 = stateOf(en, c.slot, sa.ball.owner);
      const cid = en && en.concept !== NO && legend[en.concept] ? en.concept : null;
      const key = (s2 && s2.state ? s2.state.code : '') + '|' + cid;
      if (path.length && path[path.length - 1].key === key) path[path.length - 1].to = b.tick;
      else path.push({ key, state: s2 && s2.state, cid, from: b.tick, to: b.tick });
    }
    const cur = path.findIndex((p, i) => t >= p.from && (i === path.length - 1 || t < path[i + 1].from));
    const key = [at, st && st.state && st.state.code, st && st.decision.code, e && e.concept, cur, other].join('|');
    if (key === machineKey) return;
    machineKey = key;
    const host = $('side-body');
    host.textContent = '';
    const add = (tag, cls, text, parent) => { const n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; (parent || host).appendChild(n); return n; };
    // What this concept IS, always in view.
    if (concept) {
      const box = add('div', 'def');
      add('div', 'def-t', concept.title, box);
      if (concept.cue) add('div', '', concept.cue, box);
      if (concept.lacking) add('div', 'dim', say('clip_x_lacking') + ': ' + concept.lacking, box);
    }
    add('h2', '', say('clip_sm_title', { num: numOf(c.slot), player: nameOf(c.slot) }));
    add('div', 'dim', st ? say('clip_sm_side') + ' ' + say(st.ours ? 'clip_sm_with' : 'clip_sm_without') : '');
    // Through this example: each state he passes through, defined.
    add('h3', '', say('clip_sm_path'));
    const pl = add('ul');
    path.forEach((p, i) => {
      const li = add('li', i === cur ? 'on' : (i < cur ? 'done' : ''), (p.state ? p.state.title : say('clip_sm_none')) + '  ·  ' + ((p.to - p.from + 6) / 30).toFixed(1) + ' s', pl);
      if (p.state && p.state.note) add('small', '', p.state.note, li);
      if (p.cid != null) add('small', 'con', legend[p.cid].title + (defOf(p.cid) ? ' — ' + defOf(p.cid) : ''), li);
    });
    add('h3', '', say('clip_sm_decision'));
    add('div', 'now', st ? st.decision.title : say('clip_sm_none'));
    if (other != null) {
      const entries = brainAt(t), os = stateOf(entries && entries[other], other, ball.owner);
      add('h3', '', say('clip_sm_other', { num: numOf(other), player: nameOf(other) }));
      add('div', 'now', os ? (os.state ? os.state.title + ' — ' : '') + os.decision.title : say('clip_sm_none'));
      if (os && os.state && os.state.note) add('div', 'dim', os.state.note);
    }
    // Every state he could be in, each with what it means; the one he is in is lit.
    add('h3', '', say('clip_sm_states'));
    const ul = add('ul');
    const keeper = st && st.state && st.state.code === 'keeper';
    for (const s of terms.filter((x) => x.kind === 'state' && (keeper ? x.parent === 'keeper' : x.parent !== 'keeper'))) {
      const on = st && st.state && st.state.code === s.code;
      const li = add('li', on ? 'on' : (st && s.parent === (st.ours ? 'with' : 'without') ? 'done' : ''), s.title, ul);
      if (s.note) add('small', '', s.note, li);
    }
    add('div', 'note', say('clip_sm_note'));
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
    machineKey = '';
    if (tab === 'explain') paintExplain(); else $('side-body').textContent = '';
  }

  // ── words and controls ──
  function paintPhase(phase) {
    for (const k of ['before', 'doing', 'after']) $('ph-' + k).classList.toggle('on', k === phase);
  }
  function paintBar() {
    const c = clips[at], n = clips.length;
    $('which').textContent = reported === false ? say('clip_unreported')
      : c ? say('clip_which', { i: at + 1, n, player: nameOf(c.slot), num: numOf(c.slot) }) : say('clip_waiting');
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
    document.title = concept ? concept.title : say('clip_title');
    $('title').textContent = concept ? concept.title : say('clip_title');
    $('cue').textContent = concept ? (concept.cue || '') : '';
    $('ph-before').textContent = say('clip_before'); $('ph-doing').textContent = say('clip_doing'); $('ph-after').textContent = say('clip_after');
    $('prev').textContent = say('clip_prev'); $('next').textContent = say('clip_next'); $('replay').textContent = say('clip_replay');
    $('speed').textContent = say('clip_speed'); $('legend').textContent = say('clip_legend');
    for (const [rate, label] of SPEEDS) {
      const b = document.createElement('button');
      b.type = 'button'; b.dataset.rate = rate; b.textContent = label;
      b.addEventListener('click', () => { play.rate = rate; paintBar(); });
      $('rates').appendChild(b);
    }
    for (const [tab, tier] of [['machine', 'clip_tab_machine'], ['explain', 'clip_tab_explain']]) {
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
