// frontend/js/teach/teach.js — the teaching room (docs/teaching-room.md).
//
// Owner 11/24: "i want a teaching room/sandbox that does not touch game" — its own page and
// its own small client. It opens a private room on the game daemon
// (/game?trainer=1&teach=<tactic_plans.id>…, game/src/teach/TeachingServer): their side is
// the engine's own Premier League build-out from a goal kick; ours stand where their jobs
// on the 🎯 Tactics board put them. This page only watches and steps: ⏭ plays one pass and
// freezes, every one of ours is labelled with his job (the board's own concept words, sent
// by the server) and the man it names.
//
// Top-down, drawn the way the board draws a plan: upright = our goal at the bottom, wide
// screens = our goal on the left. No three.js, none of game.html's scripts but the wire
// codec. Every word is message_templates kind 'teach' (mig 1789) — none lives here.

(function () {
  'use strict';

  const $ = (id) => document.getElementById(id);
  const q = new URLSearchParams(location.search);
  const token = localStorage.getItem('token');
  if (!token) { location.href = '/'; return; }

  // ── Copy (GET /api/messages/templates/copy, the rows MessageCopy reads) ──
  const copy = new Map();
  const say = (tier, tokens = {}) => (copy.get(tier) || '').replace(/\{(\w+)\}/g, (_, k) => (tokens[k] == null ? '' : String(tokens[k])));
  async function loadCopy() {
    const r = await fetch('/api/messages/templates/copy', { headers: { Authorization: 'Bearer ' + token } });
    if (r.status === 401) { location.href = '/'; return false; }
    const j = await r.json();
    for (const t of ((j.data || {}).templates || [])) if (t.kind === 'teach' && !copy.has(t.tier)) copy.set(t.tier, t.body || '');
    return true;
  }

  // ── The room ──
  const NO = 255, US = 0, THEM = 1;
  const SPEEDS = [25, 50, 100];
  const S = {
    ws: null, hello: null, snap: null, roster: [], brain: null, legend: {}, kits: [null, null], names: ['', ''],
    speed: 0, pace: 50, shown: [], ballShown: null, prevJobs: {}, changedUntil: {},
  };
  const PLAN = q.get('plan');
  const teamOf = (i) => (S.hello && i < S.hello.slotCount / 2 ? US : THEM);
  const numOf = (i) => (S.roster[i] && S.roster[i].number) || null;

  function connect() {
    if (S.ws) { S.ws.onclose = null; S.ws.close(); }
    Object.assign(S, { hello: null, snap: null, brain: null, shown: [], ballShown: null, speed: 0, prevJobs: {}, changedUntil: {} });
    status(say('st_connecting'));
    paintButtons();
    // With a plan: ours run its jobs. Without one (?us_team=…&them_team=…): two sides, both the
    // engine's own — the Premier League lesson, whose frozen moments 📋 copy to the board.
    const p = new URLSearchParams({ trainer: '1', gk: 'away',
                                    home: q.get('us_team') || say('us_team'), away: q.get('them_team') || say('them_team') });
    if (PLAN) p.set('teach', PLAN);
    const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
    const ws = new WebSocket(`${scheme}://${location.host}/game?${p}`, `fh-game.v2.bearer.${token}`);
    ws.binaryType = 'arraybuffer';
    S.ws = ws;
    ws.onmessage = (ev) => {
      const view = new DataView(ev.data), T = GameWire.FrameType;
      for (const f of GameWire.decodeFrame(ev.data)) {
        if (f.type === T.HELLO) { S.hello = GameWire.decodeHello(view, f.payloadAt); send(GameWire.encodeBrainWatch(true)); }
        else if (f.type === T.SNAPSHOT) S.snap = GameWire.decodeSnapshot(view, f.payloadAt);
        else if (f.type === T.ROSTER) S.roster = GameWire.decodeRoster(view, f.payloadAt, f.payloadLen);
        else if (f.type === T.BRAIN) { S.brain = GameWire.decodeBrain(view, f.payloadAt); paintJobs(); }
        else if (f.type === T.CONCEPT_LEGEND) S.legend = GameWire.decodeConceptLegend(view, f.payloadAt);
        else if (f.type === T.TEAMS) { const t = GameWire.decodeTeams(view, f.payloadAt, f.payloadLen); S.kits = t.kits; S.names = [t.home, t.away]; paintKits(); }
        else if (f.type === T.SPEED) { S.speed = GameWire.decodeSpeed(view, f.payloadAt); paintButtons(); }
      }
    };
    ws.onclose = () => { if (S.ws !== ws) return; S.ws = null; S.hello = null; status(say('st_closed')); paintButtons(); };
  }
  const send = (buf) => { if (S.ws && S.ws.readyState === WebSocket.OPEN) S.ws.send(buf); };

  // ── Controls ──
  function status(text) { $('status').textContent = text; }
  function paintButtons() {
    const live = !!S.hello, paused = S.speed === 0;
    $('btn-step').disabled = !live || !paused;
    $('btn-play').disabled = !live;
    $('btn-play').textContent = paused ? say('play') : say('pause');
    for (const b of document.querySelectorAll('[data-pace]')) b.classList.toggle('on', Number(b.dataset.pace) === S.pace);
    if (copyBtn) copyBtn.hidden = !live || !paused;
  }

  // 📋 A frozen moment of two engine sides → a step on our 🎯 Tactics board (owner 11/9: "except
  // right to copy it over to … the event center"; POST /api/tactic-plans/copies, mig 1202). One
  // way: nothing comes back to the engine. Only a room with no plan offers it — a plan's own
  // moment is already on the board. The plan pitch: 0-100 from our view, y 0 = our goal line.
  let copyBtn = null;
  function moment() {
    const s = S.snap;
    if (!s || !S.hello) return null;
    const xy = (px, py) => { const cl = (v) => Math.max(0, Math.min(100, Math.round(v * 10) / 10)); return { x: cl((34 + py) / 68 * 100), y: cl((px + 52.5) / 105 * 100) }; };
    let ballWith = null;
    if (s.ball.owner !== NO && teamOf(s.ball.owner) === THEM) ballWith = numOf(s.ball.owner);
    else {
      let best = 4;   // their man within 2 m of a loose ball
      for (let i = 0; i < s.players.length; i++) if (teamOf(i) === THEM) {
        const d = (s.players[i].x - s.ball.x) ** 2 + (s.players[i].y - s.ball.y) ** 2;
        if (d < best) { best = d; ballWith = numOf(i); }
      }
    }
    const opponents = [], ours = [];
    for (let i = 0; i < s.players.length; i++) {
      if (!numOf(i)) continue;
      const p = xy(s.players[i].x, s.players[i].y);
      if (teamOf(i) === THEM) { opponents.push({ number: numOf(i), x: p.x, y: p.y }); continue; }
      const e = S.brain && S.brain[i];
      ours.push({ position_id: numOf(i), x: p.x, y: p.y, concept_id: e && e.concept !== NO ? e.concept : null,
                  target: e && e.other !== NO && teamOf(e.other) === THEM ? numOf(e.other) : null });
    }
    const mm = String(Math.floor(s.match.clockSec / 60)).padStart(2, '0'), ss = String(s.match.clockSec % 60).padStart(2, '0');
    return { source: { home: S.names[0], away: S.names[1], clock: `${mm}:${ss}`, period: s.match.period, match_id: S.hello.matchId },
             us_team: S.names[US], them_team: S.names[THEM], moment: 'out_of_possession',
             ball_with: ballWith, ball: xy(s.ball.x, s.ball.y), opponents, ours };
  }
  async function copyMoment() {
    const body = moment();
    if (!body) return;
    copyBtn.disabled = true;
    copyBtn.textContent = say('copy_busy');
    try {
      const r = await fetch('/api/tactic-plans/copies', { method: 'POST', headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
                                                         body: JSON.stringify(body) });
      const j = await r.json().catch(() => ({}));
      if (!r.ok) throw new Error(j.error || ('HTTP ' + r.status));
      copyBtn.textContent = say('copy_done', { us: j.us, them: j.them, block: j.block });
    } catch (e) {
      copyBtn.textContent = say('copy_fail', { why: e.message || '' });
    } finally {
      setTimeout(() => { copyBtn.textContent = say('copy'); copyBtn.disabled = false; }, 6000);
    }
  }
  function buildControls() {
    $('btn-step').textContent = say('step');
    $('btn-restart').textContent = say('restart');
    $('speed-label').textContent = say('speed');
    for (const pct of SPEEDS) {
      const b = document.createElement('button');
      b.type = 'button';
      b.dataset.pace = pct;
      b.textContent = pct === 100 ? '1×' : pct === 50 ? '½×' : '¼×';
      b.addEventListener('click', () => { S.pace = pct; if (S.speed > 0) send(GameWire.encodeSpeed(pct)); paintButtons(); });
      $('speeds').appendChild(b);
    }
    $('btn-step').addEventListener('click', () => send(GameWire.encodeStep(S.pace)));
    $('btn-play').addEventListener('click', () => send(GameWire.encodeSpeed(S.speed === 0 ? S.pace : 0)));
    $('btn-restart').addEventListener('click', connect);
    if (say('pick_back')) {   // ☰ back to the list of plans
      const a = document.createElement('a');
      a.href = '/teach.html';
      a.textContent = say('pick_back');
      a.className = 'pill';
      $('speeds').after(a);
    }
    if (!PLAN && say('copy')) {
      copyBtn = document.createElement('button');
      copyBtn.type = 'button';
      copyBtn.hidden = true;
      copyBtn.textContent = say('copy');
      copyBtn.addEventListener('click', copyMoment);
      $('btn-restart').after(copyBtn);
    }
    $('back').addEventListener('click', (e) => { if (history.length > 1 && document.referrer.startsWith(location.origin)) { e.preventDefault(); history.back(); } });
  }

  // ── Who does what ──
  function conceptTitle(id) { const c = S.legend[id]; return c ? (c.title || c.name) : ''; }
  function paintJobs() {
    if (!S.brain || !S.hello) return;
    const rows = [], now = performance.now();
    for (let i = 0; i < S.hello.slotCount; i++) {
      if (teamOf(i) !== US || !numOf(i) || numOf(i) === 1 || (S.snap && S.snap.players[i] && (S.snap.players[i].flags & 2))) continue;   // outfielders
      const e = S.brain[i];
      if (!e) continue;
      const job = e.concept !== NO ? conceptTitle(e.concept) : say('job_engine');
      const on = e.concept !== NO && e.other !== NO && teamOf(e.other) === THEM && numOf(e.other) ? say('job_on', { n: numOf(e.other) }) : '';
      const key = job + '|' + on;
      if (S.prevJobs[i] !== undefined && S.prevJobs[i] !== key) S.changedUntil[i] = now + 4000;
      S.prevJobs[i] = key;
      rows.push({ n: numOf(i), job, on, changed: (S.changedUntil[i] || 0) > now });
    }
    rows.sort((a, b) => a.n - b.n);
    const ul = $('jobs');
    ul.textContent = '';
    for (const r of rows) {
      const li = document.createElement('li');
      if (r.changed) li.className = 'changed';
      for (const [cls, text] of [['n', r.n], ['j', r.job], ['t', r.on]]) {
        const s = document.createElement('span');
        s.className = cls;
        s.textContent = text;
        li.appendChild(s);
      }
      ul.appendChild(li);
    }
  }

  // ── The pitch ──
  const cv = $('pitch'), g = cv.getContext('2d');
  const hex = (n) => '#' + (n >>> 0).toString(16).padStart(6, '0').slice(-6);
  const inkOn = (n) => (((n >> 16) & 255) * 299 + ((n >> 8) & 255) * 587 + (n & 255) * 114) / 1000 > 150 ? '#0b1c3d' : '#ffffff';
  const KIT = { us: 0x4169e1, them: 0xeef1f6, usGk: 0x2e9e44, themGk: 0xff8a1f };
  function paintKits() {
    if (S.kits[0] && S.kits[0].shirt != null) KIT.us = S.kits[0].shirt;
    if (S.kits[1] && S.kits[1].shirt != null) KIT.them = S.kits[1].shirt;
    document.documentElement.style.setProperty('--us', hex(KIT.us));
    document.documentElement.style.setProperty('--us-ink', inkOn(KIT.us));
  }

  let W = 0, H = 0, wide = false, sc = 1, ox = 0, oy = 0;
  function layout() {
    const box = cv.parentElement.getBoundingClientRect(), dpr = Math.min(window.devicePixelRatio || 1, 2);
    W = box.width; H = box.height;
    cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
    g.setTransform(dpr, 0, 0, dpr, 0, 0);
    wide = W > H * 1.15;
    const pad = 14, L = 105, B = 68;
    sc = wide ? Math.min((W - 2 * pad) / L, (H - 2 * pad) / B) : Math.min((W - 2 * pad) / B, (H - 2 * pad) / L);
    ox = (W - (wide ? L : B) * sc) / 2;
    oy = (H - (wide ? B : L) * sc) / 2;
  }
  // Pitch metres (we attack +x) → screen. Upright: our goal at the bottom, -y on the left
  // (the board's x 0). Wide: our goal on the left, -y at the top.
  const P = (x, y) => (wide ? [ox + (x + 52.5) * sc, oy + (y + 34) * sc] : [ox + (y + 34) * sc, oy + (52.5 - x) * sc]);

  function line(x0, y0, x1, y1) { const a = P(x0, y0), b = P(x1, y1); g.beginPath(); g.moveTo(a[0], a[1]); g.lineTo(b[0], b[1]); g.stroke(); }
  function ring(x, y, r) { const c = P(x, y); g.beginPath(); g.arc(c[0], c[1], r * sc, 0, Math.PI * 2); g.stroke(); }
  function drawPitch() {
    g.fillStyle = '#0b1c3d'; g.fillRect(0, 0, W, H);
    const a = P(-52.5, -34), b = P(52.5, 34);
    g.fillStyle = '#2f6b2a';
    g.fillRect(Math.min(a[0], b[0]), Math.min(a[1], b[1]), Math.abs(b[0] - a[0]), Math.abs(b[1] - a[1]));
    g.strokeStyle = 'rgba(255,255,255,.8)'; g.lineWidth = 1.5; g.setLineDash([]);
    g.strokeRect(Math.min(a[0], b[0]), Math.min(a[1], b[1]), Math.abs(b[0] - a[0]), Math.abs(b[1] - a[1]));
    line(0, -34, 0, 34); ring(0, 0, 9.15);
    for (const s of [-1, 1]) {
      const gx = 52.5 * s;
      for (const [d, w] of [[16.5, 20.16], [5.5, 9.16]]) { line(gx, -w, gx - d * s, -w); line(gx - d * s, -w, gx - d * s, w); line(gx - d * s, w, gx, w); }
      g.lineWidth = 3; line(gx, -3.66, gx, 3.66); g.lineWidth = 1.5;
    }
  }

  function man(i, x, y) {
    const us = teamOf(i) === US, gk = !!(S.snap.players[i].flags & 2);
    const col = gk ? (us ? KIT.usGk : KIT.themGk) : (us ? KIT.us : KIT.them);
    const c = P(x, y), r = Math.max(9, 1.5 * sc);
    g.beginPath(); g.arc(c[0], c[1], r, 0, Math.PI * 2);
    g.fillStyle = hex(col); g.fill();
    g.lineWidth = S.snap.ball.owner === i ? 3 : 1.5;
    g.strokeStyle = S.snap.ball.owner === i ? '#ffcc00' : 'rgba(0,0,0,.55)'; g.setLineDash([]); g.stroke();
    const n = numOf(i);
    if (n) { g.fillStyle = inkOn(col); g.font = `800 ${Math.round(r * 1.05)}px system-ui, sans-serif`; g.textAlign = 'center'; g.textBaseline = 'middle'; g.fillText(n, c[0], c[1] + 0.5); }
    return [c[0], c[1], r];
  }

  function frame() {
    requestAnimationFrame(frame);
    if (!W) layout();
    drawPitch();
    const s = S.snap;
    if (!s || !S.hello) return;
    const n = s.players.length;
    // Ease toward the newest snapshot (30 Hz in, the screen's rate out).
    for (let i = 0; i < n; i++) {
      const p = s.players[i], d = S.shown[i] || (S.shown[i] = { x: p.x, y: p.y });
      d.x += (p.x - d.x) * 0.4; d.y += (p.y - d.y) * 0.4;
    }
    const bs = S.ballShown || (S.ballShown = { x: s.ball.x, y: s.ball.y });
    bs.x += (s.ball.x - bs.x) * 0.5; bs.y += (s.ball.y - bs.y) * 0.5;

    // Under the men: where each of ours is going (solid), and the man his job names (dashed).
    if (S.brain) for (let i = 0; i < n; i++) {
      const e = S.brain[i];
      if (teamOf(i) !== US || !e || e.concept === NO) continue;
      const d = S.shown[i];
      g.strokeStyle = 'rgba(255,204,0,.9)'; g.lineWidth = 2; g.setLineDash([]);
      if (Math.hypot(e.tx - d.x, e.ty - d.y) > 1.2) { line(d.x, d.y, e.tx, e.ty); ring(e.tx, e.ty, 0.8); }
      if (e.other !== NO && S.shown[e.other]) {
        g.strokeStyle = 'rgba(255,255,255,.7)'; g.lineWidth = 1.5; g.setLineDash([5, 5]);
        line(d.x, d.y, S.shown[e.other].x, S.shown[e.other].y);
      }
    }
    g.setLineDash([]);
    const tags = [];
    for (let i = 0; i < n; i++) {
      const at = man(i, S.shown[i].x, S.shown[i].y), e = S.brain && S.brain[i];
      if (teamOf(i) === US && e && e.concept !== NO && S.legend[e.concept]) tags.push([at, S.legend[e.concept].name || S.legend[e.concept].title]);
    }
    // The job's short name under each of ours.
    g.font = '700 11px system-ui, sans-serif'; g.textAlign = 'center'; g.textBaseline = 'top';
    for (const [[x, y, r], text] of tags) {
      const w = g.measureText(text).width + 8;
      g.fillStyle = 'rgba(8,12,18,.78)'; g.fillRect(x - w / 2, y + r + 2, w, 15);
      g.fillStyle = '#ffcc00'; g.fillText(text, x, y + r + 4);
    }
    // The ball: bigger as it rises.
    const b = P(bs.x, bs.y), br = Math.max(4, 0.55 * sc) * (1 + Math.min(1.2, s.ball.z / 6));
    g.beginPath(); g.arc(b[0], b[1], br, 0, Math.PI * 2); g.fillStyle = '#fff'; g.fill();
    g.strokeStyle = '#111'; g.lineWidth = 1.5; g.stroke();

    // The moment, in words.
    const o = s.ball.owner, rt = s.match.restartTeam;
    status(o !== NO ? (teamOf(o) === THEM ? (rt === THEM ? say('st_goal_kick') : say('st_with', { n: numOf(o) || '' })) : say('st_ours', { n: numOf(o) || '' }))
                    : rt === THEM ? say('st_goal_kick') : rt !== NO ? say('st_dead') : say('st_flight'));
  }

  // ── No plan in the link (opened from the ⚽ Football menu): the plans to pick from ──
  async function pickPlan() {
    document.body.classList.add('picking');
    $('jobs-title').textContent = say('pick_title');
    $('note').textContent = '';
    status(say('pick_status'));
    const ul = $('jobs');
    ul.textContent = '';
    const add = (href, text) => {
      const li = document.createElement('li'), a = document.createElement('a');
      a.href = href;
      a.textContent = text;
      li.appendChild(a);
      ul.appendChild(li);
    };
    let plans = [];
    try {
      const r = await fetch('/api/tactic-plans/list', { headers: { Authorization: 'Bearer ' + token } });
      if (r.ok) plans = (await r.json()).plans || [];
    } catch (_) { /* the list stays empty */ }
    for (const p of plans)
      add('/teach.html?' + new URLSearchParams({ plan: p.id, us: p.us, them: p.them, block: p.block }),
          say('pick_row', { us: p.us, them: p.them, block: p.block_label, steps: p.steps }));
    if (!plans.length) status(say('pick_none'));
    if (say('pick_pl')) add('/teach.html?' + new URLSearchParams({ us_team: 'Arsenal', them_team: 'West Ham United' }), say('pick_pl'));
  }

  // ── Boot ──
  (async function () {
    if (!(await loadCopy())) return;
    document.title = say('title');
    $('title').textContent = say('title');
    $('back').textContent = say('back');
    $('jobs-title').textContent = say('jobs_title');
    $('note').textContent = say(PLAN ? 'note' : 'note_pl');
    $('matchup').textContent = q.get('us') && q.get('them') ? say('matchup', { us: q.get('us'), them: q.get('them'), block: q.get('block') || '' }) : '';
    buildControls();
    window.addEventListener('resize', layout);
    layout();
    requestAnimationFrame(frame);
    if (!PLAN && !(q.get('us_team') && q.get('them_team'))) { pickPlan(); return; }
    connect();
  })();
})();
