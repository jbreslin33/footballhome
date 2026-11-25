// frontend/js/teach/concept.js — the concept viewer (concept.html?concept=<game_concepts id>).
//
// Owner 2026-11-25, of the clip viewer it replaces: "states need to be writtin small next to player but
// able to see through it. it should follow plaeyr" · "we need youutbe like bar to slide the game forward
// or back to see exacatly what statest the plaeyrs is in and the situation on field" · "get rid of one on
// side" · "orient field side to side. even on phone as they would tilt phone" · "we need also controls
// for play speed. a slider bar will do" · "all controls on pitch and transpearnet. the iptch should be
// whole screen" · "stop switching player focus. show all players on screen at all times" · "don't jump
// to diff players its disorietning" · "the players involved for US should ahve state machnines over them
// transparent. in the case of stey in prssing dist its only one player we are focuesed on. also we need
// to see his statemmacne theat he is defendiing or transigint to def etc." · "just show entire pitch and
// goals and make plaeyrs a little smaller".
//
// So: the live match (the concept's own room of the full engine when the sim keeps the concept at zero),
// recorded; the WHOLE pitch, goals included, fixed — no camera, no cutting; every player drawn. ONE of
// our players is followed: his states in a see-through label that moves with him — his team's phase,
// his job, and every machine that is on (the concept's own in gold). He stays the one followed until a
// different player is tapped. Below, on the pitch: play/pause, a scrub bar over everything recorded,
// LIVE, and a speed slider. Tap a line of his label for what it means; tap the concept's title for its
// definition. The clip viewer before this is in git (8b30c21c and earlier).

(function () {
  'use strict';
  const $ = (id) => document.getElementById(id);
  const token = localStorage.getItem('token');
  if (!token) { location.href = '/'; return; }
  const CONCEPT = Number(new URLSearchParams(location.search).get('concept')) || 0;
  const NO = 255, KEEP = 30 * 60 * 10, US = 0;   // 10 minutes of snapshots at 30 Hz; "us" = the home side

  const copy = new Map();
  const say = (tier, tokens = {}) => (copy.get(tier) || '').replace(/\{(\w+)\}/g, (_, k) => (tokens[k] == null ? '' : String(tokens[k])));
  let concept = null, terms = [], tax = {}, legend = {};

  // ── the match, recorded ──
  const snaps = [];                                   // {tick, players, ball}
  const logs = { machines: [], states: [], phase: [], reach: [], shadow: [], brain: [] };   // {tick, v}
  let hello = null, roster = [], kits = [null, null];
  const teamOf = (i) => (hello && i < hello.slotCount / 2 ? 0 : 1);
  const numOf = (i) => (roster[i] && roster[i].number) || '';
  const nameOf = (i) => (roster[i] && roster[i].name) || ('#' + numOf(i));
  const lastTick = () => (snaps.length ? snaps[snaps.length - 1].tick : 0);
  const firstTick = () => (snaps.length ? snaps[0].tick : 0);
  const push = (log, v) => { log.push({ tick: lastTick(), v }); if (log.length > KEEP / 6 + 50) log.shift(); };

  // The concept's own room when the real sim keeps it at zero (game/src/main.cpp, game_concept_dials).
  let roomOn = false;
  function connect() {
    load.step = Math.max(load.step, 1);
    const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
    const ws = new WebSocket(`${scheme}://${location.host}${roomOn ? `/game?trainer=1&concept=${CONCEPT}` : '/game'}`, `fh-game.v2.bearer.${token}`);
    ws.binaryType = 'arraybuffer';
    ws.onmessage = (ev) => {
      const view = new DataView(ev.data), T = GameWire.FrameType;
      for (const f of GameWire.decodeFrame(ev.data)) {
        if (f.type === T.HELLO) { hello = GameWire.decodeHello(view, f.payloadAt); ws.send(GameWire.encodeBrainWatch(true)); if (roomOn) ws.send(GameWire.encodeSpeed(100)); }
        else if (f.type === T.SNAPSHOT) {
          const s = GameWire.decodeSnapshot(view, f.payloadAt);
          snaps.push({ tick: s.tick, players: s.players, ball: s.ball });
          if (snaps.length > KEEP) snaps.shift();
          if (load.step < 2) load.step = 2;
        } else if (f.type === T.ROSTER) roster = GameWire.decodeRoster(view, f.payloadAt, f.payloadLen);
        else if (f.type === T.TEAMS) kits = GameWire.decodeTeams(view, f.payloadAt, f.payloadLen).kits;
        else if (f.type === T.CONCEPT_LEGEND) legend = GameWire.decodeConceptLegend(view, f.payloadAt);
        else if (f.type === T.MACHINES) { push(logs.machines, GameWire.decodeMachines(view, f.payloadAt)); pickFollow(); }
        else if (f.type === T.STATES) push(logs.states, GameWire.decodeStates(view, f.payloadAt));
        else if (f.type === T.PHASE) push(logs.phase, GameWire.decodePhase(view, f.payloadAt));
        else if (f.type === T.REACH) push(logs.reach, GameWire.decodeReach(view, f.payloadAt));
        else if (f.type === T.SHADOW) push(logs.shadow, GameWire.decodeShadow(view, f.payloadAt));
        else if (f.type === T.BRAIN) push(logs.brain, GameWire.decodeBrain(view, f.payloadAt));
      }
    };
    ws.onclose = () => setTimeout(connect, 2000);
  }

  // Binary search: the newest entry at or before tick t.
  function at(log, t) {
    let lo = 0, hi = log.length - 1, best = -1;
    while (lo <= hi) { const m = (lo + hi) >> 1; if (log[m].tick <= t) { best = m; lo = m + 1; } else hi = m - 1; }
    return best >= 0 ? log[best].v : null;
  }
  function snapAt(t) {
    let lo = 0, hi = snaps.length - 1;
    while (lo < hi) { const m = (lo + hi + 1) >> 1; if (snaps[m].tick <= t) lo = m; else hi = m - 1; }
    const a = snaps[lo], b = snaps[Math.min(lo + 1, snaps.length - 1)];
    return [a, b, b.tick > a.tick ? Math.max(0, Math.min(1, (t - a.tick) / (b.tick - a.tick))) : 0];
  }
  const lerp = (a, b, k) => a + (b - a) * k;

  // ── the concept's machine: the engine machine (or marking-scheme state) titled as the concept ──
  let cMachine = null, cState = null;   // wire numbers
  function findConceptMachine() {
    if (!concept) return;
    const m = terms.find((x) => x.kind === 'machine' && x.title === concept.title);
    if (m) { cMachine = m.wire; return; }
    const s = terms.find((x) => x.kind === 'machine_state' && x.title === concept.title);
    if (s) { const p = terms.find((x) => x.kind === 'machine' && x.code === s.parent); if (p) { cMachine = p.wire; cState = s.wire; } }
  }
  const conceptOn = (e) => e.machine === cMachine && (cState == null || e.state === cState);

  // ── the one player followed: ours, the first whose concept machine comes on; then only a tap moves it ──
  const saved = localStorage.getItem('fh.concept.follow.' + CONCEPT);
  let follow = saved != null && saved !== '' && Number.isFinite(Number(saved)) ? Number(saved) : -1;
  function pickFollow() {
    if (follow >= 0 || cMachine == null || !hello) return;
    const v = logs.machines[logs.machines.length - 1].v;
    for (let i = 0; i < v.length; i++) if (teamOf(i) === US && (v[i] || []).some(conceptOn)) { follow = i; return; }
  }

  // ── his states as lines: team phase, his job, every machine that is on ──
  const MACHINE_KEY = { 1: 'scheme', 2: 'shadow', 3: 'pdist', 4: 'recover', 5: 'press', 6: 'chase', 7: 'double', 8: 'cover' };
  function rowsFor(t, slot) {
    const rows = [];
    const ph = at(logs.phase, t), phases = terms.filter((x) => x.kind === 'phase');
    const phase = ph ? phases[ph[teamOf(slot)]] : null;
    rows.push({ id: 'team', k: say('tbl_team'), v: phase ? phase.title : '—', def: phase ? phase.definition || phase.note || '' : '' });
    const sl = at(logs.states, t), code = sl ? sl[slot] : null, st = code ? terms.find((x) => x.kind === 'state' && x.code === code) : null;
    rows.push({ id: 'job', k: say('tbl_job'), v: st ? st.title : (code || '—'), def: st ? st.definition || st.note || '' : '' });
    // What he is DOING this moment (the engine's decision, BRAIN frame) and the concept his act plays.
    const br = at(logs.brain, t), e = br && br[slot];
    const dec = e ? terms.find((x) => x.kind === 'decision' && x.wire === e.why) : null;
    if (dec) rows.push({ id: 'doing', k: say('tbl_doing'), v: dec.title, def: dec.definition || dec.note || '' });
    if (e && e.concept !== NO && legend[e.concept]) {
      const kc = (tax.concepts || []).find((x) => x.id === e.concept);
      rows.push({ id: 'using', k: say('tbl_using'), v: legend[e.concept].title, def: kc ? kc.definition || kc.cue || '' : '' });
    }
    const eng = at(logs.machines, t);
    const order = (copy.get('machine_order') || '').split(',').map((x) => x.trim());
    const mrows = [];
    for (const e of (eng && eng[slot]) || []) {
      const m = terms.find((x) => x.kind === 'machine' && x.wire === e.machine);
      const s = m ? terms.find((x) => x.kind === 'machine_state' && x.parent === m.code && x.wire === e.state) : null;
      const key = MACHINE_KEY[e.machine] || String(e.machine);
      let detail = '';
      if (key === 'pdist') {
        const rr = at(logs.reach, t), r = rr && rr[slot];
        if (r && r.reach != null && e.other !== NO) {
          const a = posAt(t, slot), b = posAt(t, e.other);
          detail = say('tbl_reach', { gap: Math.hypot(a.x - b.x, a.y - b.y).toFixed(1), reach: r.reach.toFixed(1), verdict: say(r.in ? 'tbl_in' : 'tbl_out') });
        }
      }
      if (key === 'shadow') {
        const sv = at(logs.shadow, t);
        if (sv) { const mask = sv.hidden[slot] >>> 0, h = []; for (let i = 0; i < 32; i++) if ((mask >>> i) & 1) h.push('#' + numOf(i)); if (h.length) detail = say('tbl_hidden', { list: h.join(', ') }); }
      }
      let def = s ? s.definition || '' : '';
      if (key === 'pdist' && e.state === 2) { const on = m && terms.find((x) => x.kind === 'machine_state' && x.parent === m.code && x.wire === 1); if (on) def = (on.definition || '') + ' ' + def; }
      mrows.push({ id: 'm' + e.machine, key, m: true, c: conceptOn(e), k: m ? m.title : key, v: s ? s.title : '', man: key !== 'shadow' && e.other !== NO ? '#' + numOf(e.other) : '', other: e.other, d: detail, def: def || (m ? m.definition || '' : '') });
    }
    mrows.sort((a, b) => (order.indexOf(a.key) + 1 || 99) - (order.indexOf(b.key) + 1 || 99));
    return rows.concat(mrows);
  }

  // ── playback: a position on the recording, a rate; at the newest moment it is LIVE ──
  const play = { t: 0, on: true, live: true, rate: 1, last: performance.now(), dragging: false };
  function posAt(t, slot) { const [a, b, k] = snapAt(t); return { x: lerp(a.players[slot].x, b.players[slot].x, k), y: lerp(a.players[slot].y, b.players[slot].y, k) }; }

  // ── drawing: the whole pitch and both goals, side to side, fixed ──
  const cv = $('pitch'), g = cv.getContext('2d');
  let W = 0, H = 0, sc = 1, ox = 0, oy = 0, side = 0;
  function layout() {
    const app = $('app'), dpr = Math.min(window.devicePixelRatio || 1, 2);
    W = app.clientWidth; H = app.clientHeight;
    cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
    g.setTransform(dpr, 0, 0, dpr, 0, 0);
    // 105 × 68 plus the goals (2 m deep) and a margin; the controls sit over the bottom strip.
    // A wide screen keeps a strip on the left for his state table and fits the pitch in the rest.
    side = W >= 900 ? Math.min(400, Math.round(W * 0.27)) : 0;
    sc = Math.min((W - side) / 113, H / 76);
    ox = side + (W - side) / 2; oy = H / 2;
  }
  const P = (x, y) => [ox + x * sc, oy - y * sc];
  const hex = (n) => '#' + (n >>> 0).toString(16).padStart(6, '0').slice(-6);
  const ink = (n) => (((n >> 16) & 255) * 299 + ((n >> 8) & 255) * 587 + (n & 255) * 114) / 1000 > 150 ? '#0b1c3d' : '#ffffff';
  const kitOf = (i, keeper) => { const t = teamOf(i), k = kits[t] && kits[t].shirt != null ? kits[t].shirt : (t ? 0xeef1f6 : 0x14326e); return keeper ? (t ? 0xff8a1f : 0x2e9e44) : k; };
  let shown = [];   // where each player is on screen this frame (for a tap)

  function drawPitch() {
    const line = (x0, y0, x1, y1) => { const a = P(x0, y0), b = P(x1, y1); g.beginPath(); g.moveTo(a[0], a[1]); g.lineTo(b[0], b[1]); g.stroke(); };
    const [x0, y0] = P(-52.5, 34), [x1, y1] = P(52.5, -34);
    g.fillStyle = '#2f6b2a'; g.fillRect(x0, y0, x1 - x0, y1 - y0);
    g.strokeStyle = 'rgba(255,255,255,.6)'; g.lineWidth = 1.5;
    g.strokeRect(x0, y0, x1 - x0, y1 - y0);
    line(0, -34, 0, 34);
    { const c = P(0, 0); g.beginPath(); g.arc(c[0], c[1], 9.15 * sc, 0, Math.PI * 2); g.stroke(); }
    for (const s of [-1, 1]) {
      for (const [d, w] of [[16.5, 20.16], [5.5, 9.16]]) { const gx = 52.5 * s; line(gx, -w, gx - d * s, -w); line(gx - d * s, -w, gx - d * s, w); line(gx - d * s, w, gx, w); }
      const ps = P(41.5 * s, 0); g.fillStyle = 'rgba(255,255,255,.6)'; g.beginPath(); g.arc(ps[0], ps[1], 2, 0, Math.PI * 2); g.fill();
      // the goal: 7.32 m wide, 2 m deep behind the line
      const a = P(52.5 * s, 3.66), b = P((52.5 + 2) * s, -3.66);
      g.fillStyle = 'rgba(255,255,255,.18)'; g.fillRect(Math.min(a[0], b[0]), a[1], Math.abs(b[0] - a[0]), b[1] - a[1]);
      g.strokeStyle = '#fff'; g.lineWidth = 2; g.strokeRect(Math.min(a[0], b[0]), a[1], Math.abs(b[0] - a[0]), b[1] - a[1]);
      g.strokeStyle = 'rgba(255,255,255,.6)'; g.lineWidth = 1.5;
    }
  }

  function frame(now) {
    requestAnimationFrame(frame);
    if (!W) layout();
    g.fillStyle = '#0b1c3d'; g.fillRect(0, 0, W, H);
    drawPitch();
    paintLoad();
    if (!snaps.length || !hello) { $('tag').textContent = ''; return; }

    const dt = Math.min(0.1, (now - play.last) / 1000); play.last = now;
    if (play.live && !play.dragging) play.t = lastTick();
    else if (play.on && !play.dragging) {
      play.t += dt * 30 * play.rate;
      if (play.t >= lastTick()) { play.t = lastTick(); play.live = true; }
    }
    play.t = Math.max(firstTick(), Math.min(lastTick(), play.t));
    const t = play.t, [sa, sb, k] = snapAt(t);
    const ball = { x: lerp(sa.ball.x, sb.ball.x, k), y: lerp(sa.ball.y, sb.ball.y, k) };

    const rows = follow >= 0 && follow < sa.players.length ? rowsFor(t, follow) : [];
    const man = (rows.find((r) => r.c && r.other !== NO && r.other != null) || {}).other;

    // every player, a little smaller than life-size on the old zoom
    const r = Math.max(6, 0.85 * sc);
    shown = [];
    for (let i = 0; i < sa.players.length; i++) {
      const p = posAt(t, i), q = P(p.x, p.y), col = kitOf(i, !!(sa.players[i].flags & 2));
      shown.push([q[0], q[1], i]);
      // His feet (the engine's own steps, 2.3 wire): each in its real direction from his centre, just
      // outside the rim — further out the longer the stride (0.5 m+ = the most) — filled planted, hollow
      // in the air.
      const pa = sa.players[i], pb = sb.players[i];
      if (pa.feet) for (let f = 0; f < 2; f++) {
        const fa = pa.feet[f], fb = (pb.feet || pa.feet)[f];
        const dx = lerp(fa.x, fb.x, k) - p.x, dy = lerp(fa.y, fb.y, k) - p.y, dl = Math.hypot(dx, dy);
        if (dl < 0.02 || dl > 1.5) continue;   // under him, or a stale step from a restart
        const out = r * 0.55 + r * 0.75 * Math.min(1, dl / 0.5), fq = [q[0] + dx / dl * out, q[1] - dy / dl * out];
        g.beginPath(); g.arc(fq[0], fq[1], Math.max(2, r * 0.3), 0, Math.PI * 2);
        if (fa.down) { g.fillStyle = 'rgba(15,15,15,.9)'; g.fill(); } else { g.lineWidth = 1.2; g.strokeStyle = 'rgba(15,15,15,.9)'; g.stroke(); }
      }
      g.beginPath(); g.arc(q[0], q[1], r, 0, Math.PI * 2); g.fillStyle = hex(col); g.fill();
      g.lineWidth = 1.2; g.strokeStyle = 'rgba(0,0,0,.55)'; g.stroke();
      // His body's facing (engine, 1.8 wire): a white wedge on the rim. His head: toward the ball, as the
      // 3D game turns it (players.js "look") — a dark dot on the rim.
      if (pa.fx != null && (pa.fx || pa.fy)) {
        const a = Math.atan2(-pa.fy, pa.fx), w = 0.45;
        g.beginPath(); g.moveTo(q[0] + Math.cos(a) * (r + 4), q[1] + Math.sin(a) * (r + 4));
        g.lineTo(q[0] + Math.cos(a - w) * r, q[1] + Math.sin(a - w) * r); g.lineTo(q[0] + Math.cos(a + w) * r, q[1] + Math.sin(a + w) * r);
        g.closePath(); g.fillStyle = '#fff'; g.fill();
      }
      g.fillStyle = ink(col); g.font = `800 ${Math.round(r * 1.05)}px system-ui, sans-serif`; g.textAlign = 'center'; g.textBaseline = 'middle';
      g.fillText(numOf(i), q[0], q[1] + 0.5);
      { const hx = ball.x - p.x, hy = ball.y - p.y, hl = Math.hypot(hx, hy);
        if (hl > 0.3) { const a = Math.atan2(-hy, hx); g.beginPath(); g.arc(q[0] + Math.cos(a) * r * 0.7, q[1] + Math.sin(a) * r * 0.7, Math.max(2.2, r * 0.32), 0, Math.PI * 2); g.fillStyle = '#111'; g.fill(); } }
      if (i === follow || i === man) { g.lineWidth = 3; g.strokeStyle = i === follow ? '#ffcc00' : '#ff5c7a'; g.beginPath(); g.arc(q[0], q[1], r + 4, 0, Math.PI * 2); g.stroke(); }
    }
    { const q = P(ball.x, ball.y); g.beginPath(); g.arc(q[0], q[1], Math.max(3.5, 0.35 * sc), 0, Math.PI * 2); g.fillStyle = '#fff'; g.fill(); g.lineWidth = 1.5; g.strokeStyle = '#111'; g.stroke(); }

    paintTag(rows);
    paintControls();
  }

  // ── his states, docked beside the pitch: one line each ──
  let tagKey = '', tagRows = new Map();
  function paintTag(rows) {
    const el = $('tag');
    // The rows (with this moment's man and numbers, for the popup) every frame; the table only when a name changes.
    tagRows = new Map(rows.map((x) => [x.id, x]));
    for (const x of rows) if (x.m && x.v && x.v !== 'On') tagRows.set(x.id + ':s', Object.assign({}, x, { k: x.v, sdef: true }));
    const key = follow + '§' + rows.map((x) => [x.id, x.k, x.v].join('=')).join('§');
    if (key !== tagKey) {
      tagKey = key;
      el.textContent = '';
      if (!rows.length) return;
      const add = (parent, cls, text) => { const d = document.createElement('div'); d.className = cls; d.textContent = text; parent.appendChild(d); return d; };
      add(el, 'who', say('view_following', { num: numOf(follow), player: nameOf(follow) }));
      // Owner 11/25: "state, on (don't show if off) — that is it. then if you click a state it has popup
      // explaining". One row per state that is on: its name. A machine in a deeper state (stepping into
      // reach) is the machine's row, then the deeper state on its own row. Everything else is in the popup.
      const tbl = document.createElement('table');
      // One name once: his action, the concept he plays and a machine can all be "Close down the man on the
      // ball". The machine's row wins (its deeper state sits under it), so a single row with a machine's
      // name or one of its state names is dropped.
      const seen = new Set();
      for (const x of rows) if (x.m) { seen.add('m:' + x.k); if (x.v) seen.add('m:' + x.v); }
      for (const x of rows) {
        if (!x.m && seen.has('m:' + x.v)) continue;
        const lines = x.m && x.v && x.v !== 'On' ? [[x.id, x.k, ''], [x.id + ':s', x.v, ' sub']] : [[x.id, x.m ? x.k : x.v, '']];
        for (const [id, name, sub] of lines) {
          if (seen.has(name)) continue;
          seen.add(name);
          const tr = tbl.insertRow();
          tr.className = 'row' + (x.c ? ' c' : '') + sub;
          tr.dataset.id = id;
          const td = tr.insertCell(); td.className = 'val'; td.textContent = name || '—';
        }
      }
      el.appendChild(tbl);
    }
    // Docked in the dark beside the pitch when there is room; else over the pitch's left edge (see-through).
    el.style.width = (side ? side - 16 : Math.min(340, W * 0.45)) + 'px';
    el.style.maxHeight = (H - 50 - 64) + 'px';
  }

  // ── the controls ──
  const RATE = (v) => Math.pow(2, (v - 50) / 50 * 3);   // slider 0…100 → ⅛× … 8×, 1× in the middle
  const clockOf = (ticks) => { const s = Math.max(0, Math.round(ticks / 30)); return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0'); };
  function paintControls() {
    const sc_ = $('scrub'), a = firstTick(), b = lastTick();
    sc_.min = a; sc_.max = Math.max(a + 1, b);
    if (!play.dragging) sc_.value = Math.round(play.t);
    sc_.style.setProperty('--p', (b > a ? 100 * (play.t - a) / (b - a) : 100).toFixed(2) + '%');
    $('clock').textContent = play.live ? clockOf(play.t) : say('view_behind', { s: clockOf(b - play.t) });
    const lv = $('live'); lv.classList.toggle('on', play.live); lv.textContent = play.live ? say('view_live') : say('view_go_live');
    $('playbtn').textContent = play.on || play.live ? '⏸' : '▶';
    $('playbtn').title = say(play.on || play.live ? 'clip_pause' : 'clip_play');
  }

  // ── loading: words, connecting, the first frame ──
  const load = { step: 0 };
  function paintLoad() {
    const box = $('loader');
    if (load.step >= 2 && snaps.length) { box.hidden = true; return; }
    box.hidden = false;
    const pct = [10, 50, 100][load.step];
    $('load-title').textContent = load.step ? say('view_connecting') : say('load_words');
    $('load-bar').style.width = pct + '%'; $('load-pct').textContent = pct + '%';
  }

  // ── one popup for every meaning ──
  function popup(title, body) {
    $('popup-t').textContent = title;
    const b = $('popup-b'); b.textContent = '';
    if (typeof body === 'string') b.textContent = body || say('m_nodef'); else if (body) b.appendChild(body);
    $('popup').hidden = false;
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
    roomOn = !!concept && (concept.name === 'pressing-distance' || concept.name === 'cover-shadow');
    findConceptMachine();
    document.title = concept ? concept.title : say('clip_title');
    $('ctitle').textContent = concept ? concept.title : say('clip_title');
    $('ctitle').addEventListener('click', () => popup(concept ? concept.title : '', concept ? concept.definition || concept.cue || '' : ''));
    $('exit').textContent = say('view_exit');
    $('exit').addEventListener('click', () => { if (window.opener) window.close(); else location.href = '/#football-taxonomy'; });
    $('hint').textContent = say('view_tap');

    $('playbtn').addEventListener('click', () => {
      if (play.on || play.live) { play.on = false; play.live = false; } else play.on = true;
      play.last = performance.now();
    });
    $('live').addEventListener('click', () => { play.live = true; play.on = true; });
    const scrub = $('scrub');
    scrub.addEventListener('pointerdown', () => { play.dragging = true; play.live = false; });
    scrub.addEventListener('input', () => { play.t = Number(scrub.value); play.live = false; });
    const endDrag = () => { if (play.dragging) { play.dragging = false; play.last = performance.now(); } };
    scrub.addEventListener('pointerup', endDrag); scrub.addEventListener('change', endDrag); window.addEventListener('pointerup', endDrag);
    const speed = $('speed');
    const paintSpeed = () => { play.rate = RATE(Number(speed.value)); $('speedval').textContent = say('view_speed', { x: play.rate >= 1 ? play.rate.toFixed(play.rate < 2 ? 2 : 1).replace(/\.?0+$/, '') : play.rate.toFixed(2).replace(/0$/, '') }); };
    speed.addEventListener('input', () => { paintSpeed(); if (play.live && play.rate < 1) { play.live = false; play.on = true; } });   // slower than live leaves live
    paintSpeed();

    // Tap a player: he is the one followed (until another is tapped). Tap a line of his label: what it means.
    cv.addEventListener('click', (ev) => {
      let best = null, bd = 30 * 30;
      for (const [x, y, i] of shown) { const d = (x - ev.offsetX) ** 2 + (y - ev.offsetY) ** 2; if (d < bd) { bd = d; best = i; } }
      if (best != null) { follow = best; localStorage.setItem('fh.concept.follow.' + CONCEPT, String(best)); tagKey = ''; }
    });
    $('tag').addEventListener('click', (ev) => {
      const ln = ev.target.closest('.row'), x = ln && tagRows.get(ln.dataset.id);
      if (!x) return;
      // The popup: what the state means, then his man and the numbers.
      const box = document.createElement('div');
      const p1 = document.createElement('p'); p1.textContent = x.def || say('m_nodef'); box.appendChild(p1);
      for (const extra of [x.man ? say('tbl_man') + ': ' + x.man : '', ...(x.d ? x.d.split(' · ') : [])]) {
        if (!extra) continue;
        const pe = document.createElement('p'); pe.className = 'key'; pe.textContent = extra; box.appendChild(pe);
      }
      popup(x.m ? x.k : x.v, box);
    });
    $('popup').addEventListener('click', (ev) => { if (ev.target.id === 'popup' || ev.target.id === 'popup-x') $('popup').hidden = true; });
    window.addEventListener('keydown', (ev) => {
      if (ev.key === 'Escape') $('popup').hidden = true;
      else if (ev.key === ' ') { ev.preventDefault(); $('playbtn').click(); }
      else if (ev.key === 'ArrowLeft') { play.live = false; play.t = Math.max(firstTick(), play.t - 150); }
      else if (ev.key === 'ArrowRight') { play.t = Math.min(lastTick(), play.t + 150); }
    });
    window.addEventListener('resize', layout);
    try { if (screen.orientation && screen.orientation.lock) screen.orientation.lock('landscape').catch(() => {}); } catch (_) { /* not allowed outside fullscreen */ }
    load.step = 1;
    layout();
    requestAnimationFrame(frame);
    connect();
  })();
})();
