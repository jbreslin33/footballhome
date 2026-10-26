// frontend/js/game/client.js
//
// Orchestrates the G0 walking skeleton: connect → HELLO builds the scene →
// tap/click a player to claim it → drive it with keys or the joystick.
// All state shown is server snapshots; this file owns no game logic.

(function () {
  'use strict';

  const statusEl = document.getElementById('status');
  const boardEl = document.getElementById('scoreboard');
  const autoBtn = document.getElementById('btn-auto');
  const lvlHomeBtn = document.getElementById('btn-level-home');
  const lvlAwayBtn = document.getElementById('btn-level-away');
  const editBtn = document.getElementById('btn-edit');
  const editPanel = document.getElementById('edit-panel');
  const presetBar = document.getElementById('preset-bar');
  const presetSelect = document.getElementById('preset-select');
  const canvas = document.getElementById('game-canvas');
  const renderer = new GameRenderer(canvas);
  const input = new GameInput(
    document.getElementById('joystick'),
    document.getElementById('joystick-knob'),
    document.getElementById('btn-pass'),
    document.getElementById('btn-loft'),
    document.getElementById('btn-tackle'));

  const mySlots = new Set();
  let activeSlot = null;  // the ONE slot the controls drive right now
  let autoSwitch = false; // AUTO: drive whichever held player is ball-nearest
  let hello = null;
  let intentTimer = null;
  let toastTimer = null;

  // Names for EVENT frames (PROTOCOL.md §7 / MatchEventType).
  const EVENT_NAMES = { 1: 'GOAL!', 2: 'Throw-in', 3: 'Goal kick',
                        4: 'Corner', 5: 'Kickoff', 6: 'Half time',
                        7: 'FULL TIME', 10: 'Offside' };

  function toast(text, ms) {
    statusEl.textContent = text;
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(updateStatus, ms || 2500);
  }

  // Live levels (from the snapshot 1.3 tail) + admin picker state.
  const levels = { home: 0, away: 0 };
  let roster = [];        // [{ratings, name}] per slot, server-authoritative
  let presets = [];       // style-preset names (mig 630); id = index
  let editMode = false;   // admin: tap a player to open his knowledge

  // Paint a team identity in one tap (CONCEPTS.md schools; wire 1.4).
  function paintPresetBar() {
    if (!presetBar) return;
    presetBar.style.display =
      editMode && presets.length ? 'flex' : 'none';
  }
  for (const [btnId, team, label] of [['preset-home', 0, 'HOME'],
                                      ['preset-away', 1, 'AWAY']]) {
    const btn = document.getElementById(btnId);
    if (!btn) continue;
    btn.addEventListener('click', () => {
      const id = presetSelect.selectedIndex;
      if (id < 0) return;
      net.applyPreset(team, id);
      toast(presets[id] + ' → ' + label);
    });
  }

  // ── EDIT panel (admin): tap a player → PLAYER (attributes + what type of
  // player he is, saved to the club DB and sent live to the match, G4.30)
  // or KNOWLEDGE (concept ratings, live). James: "give our guys random
  // attributes and i can fix them and describe the type of player".
  let teams = null;            // { home, away } from the TEAMS frame
  let idTeams = null;          // [home, away] roster payloads: slot numbers
  // Each on-pitch figure: its formation slot's shirt number + last name.
  function applyIdentities() {
    const figs = renderer.figures || [];
    if (!figs.length || !roster.length) return;
    const perTeam = figs.length / 2;
    figs.forEach((f, i) => {
      const side = i < perTeam ? 0 : 1;
      const k = side ? i - perTeam : i;
      const nums = idTeams && idTeams[side] && idTeams[side].numbers;
      const n = (nums && nums[k]) || (k + 1);
      f.setIdentity(n, roster[i] && roster[i].name);
    });
  }
  const teamCache = {};        // team name → /api/game/roster payload
  const authHeaders = () => {
    let t = '';
    try { t = localStorage.getItem('token') || ''; } catch (e) { /* none */ }
    return Object.assign({ 'Content-Type': 'application/json' }, t ? { Authorization: 'Bearer ' + t } : {});
  };
  const esc = (t) => String(t).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  async function loadTeam(name, fresh) {
    if (!fresh && teamCache[name]) return teamCache[name];
    const r = await fetch('/api/game/roster?team=' + encodeURIComponent(name), { headers: authHeaders() });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error || 'HTTP ' + r.status);
    teamCache[name] = j;
    return j;
  }
  // Typing in the panel must not steer the player or fire game keys.
  const shieldKeys = (root) => root.querySelectorAll('input, textarea, select').forEach((el) => {
    for (const ev of ['keydown', 'keyup', 'keypress']) el.addEventListener(ev, (e) => e.stopPropagation());
  });

  function openEditPanel(slot, tab) {
    const e = roster[slot] || { ratings: [], name: '#' + (slot + 1) };
    tab = tab || 'player';
    const tabBtn = (id, label) => `<button data-tab="${id}" style="padding:3px 10px;border-radius:12px;border:1px solid #889;
      background:${tab === id ? '#ffcc00' : 'transparent'};color:${tab === id ? '#0b1c3d' : '#f4f6fb'};font-weight:700;">${label}</button>`;
    editPanel.innerHTML = `<div style="display:flex;justify-content:space-between;align-items:center;gap:6px;">
        <b>${esc(e.name)}</b><button id="ep-close">✕</button></div>
      <div style="display:flex;gap:6px;margin:6px 0;">${tabBtn('player', 'PLAYER')}${tabBtn('lineup', 'LINEUP')}${tabBtn('knowledge', 'KNOWLEDGE')}</div>
      <div id="ep-body">loading…</div>`;
    editPanel.style.display = 'block';
    editPanel.style.width = 'min(340px, calc(100vw - 24px))';
    editPanel.querySelector('#ep-close').onclick = () => (editPanel.style.display = 'none');
    editPanel.querySelectorAll('button[data-tab]').forEach((b) => (b.onclick = () => openEditPanel(slot, b.dataset.tab)));
    const body = editPanel.querySelector('#ep-body');
    if (tab === 'knowledge') return renderKnowledge(body, slot, e);
    (tab === 'lineup' ? renderLineup(body, slot) : renderPlayer(body, slot)).catch((err) => {
      body.innerHTML = '<span style="color:#ff8a94">Couldn\'t load the roster: ' + esc(err.message) + '</span>';
    });
  }

  async function renderPlayer(body, slot) {
    const perTeam = ((hello && hello.slotCount) || 22) / 2;
    const away = slot >= perTeam;
    const teamName = teams && (away ? teams.away : teams.home);
    if (!teamName) { body.textContent = 'This match has no rostered teams.'; return; }
    const t = await loadTeam(teamName);
    let idx = away ? slot - perTeam : slot;       // roster order = slot order
    const draw = () => {
      const p = t.players[idx];
      if (!p) { body.textContent = 'No rostered player in this slot.'; return; }
      const onPitch = idx < perTeam;
      let html = `<select id="ep-who" style="width:100%;margin-bottom:6px;background:#0b1c3d;color:#f4f6fb;border:1px solid #889;border-radius:6px;padding:3px;">` +
        t.players.map((q, i) => `<option value="${i}"${i === idx ? ' selected' : ''}>#${q.shirt} ${esc(q.name)} · ${esc(q.position || '')}${i >= perTeam ? ' (bench)' : ''}</option>`).join('') +
        `</select><div style="font-size:11px;opacity:.7;margin-bottom:4px;">${esc(t.team)} · ${esc(t.formation)} · ${esc(t.level_band)} — 50 = average for this level</div>`;
      for (const a of t.attributes) {
        const v = p.attrs[a.code];
        html += `<div style="display:flex;align-items:center;gap:6px;margin:2px 0;" title="${esc(a.description)}">
          <span style="width:92px;font-size:11px;">${esc(a.name)}</span>
          <input type="range" min="0" max="100" value="${v == null ? 50 : v}" data-attr="${a.code}" style="flex:1;"
                 oninput="this.nextElementSibling.textContent=this.value">
          <span style="width:26px;text-align:right;font-size:11px;">${v == null ? '—' : v}</span></div>`;
      }
      html += `<textarea id="ep-desc" rows="3" placeholder="What type of player is he? (e.g. ball-playing centre back, wins everything in the air, slow on the turn)"
          style="width:100%;box-sizing:border-box;margin-top:6px;background:#0b1c3d;color:#f4f6fb;border:1px solid #889;border-radius:6px;padding:4px;font:12px system-ui,sans-serif;">${esc(p.description || '')}</textarea>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px;">
          <span id="ep-msg" style="font-size:11px;opacity:.8;">${onPitch ? 'Saves to the club and applies to the match now' : 'On the bench — saves to the club'}</span>
          <button id="ep-save" style="background:#ffcc00;color:#0b1c3d;border:none;padding:4px 14px;border-radius:6px;font-weight:700;">SAVE</button></div>`;
      body.innerHTML = html;
      shieldKeys(body);
      body.querySelector('#ep-who').onchange = (ev) => { idx = +ev.target.value; draw(); };
      body.querySelector('#ep-save').onclick = async () => {
        const msg = body.querySelector('#ep-msg');
        const attrs = {};
        body.querySelectorAll('input[data-attr]').forEach((sl) => { attrs[sl.dataset.attr] = +sl.value; });
        const description = body.querySelector('#ep-desc').value.trim();
        msg.textContent = 'saving…';
        try {
          const r = await fetch('/api/game/player', { method: 'PUT', headers: authHeaders(),
            body: JSON.stringify({ team: t.team, shirt: p.shirt, attrs, description }) });
          const j = await r.json().catch(() => ({}));
          if (!r.ok) throw new Error(j.error || 'HTTP ' + r.status);
          p.attrs = attrs;
          p.description = description;
          // Live: the running match uses the new numbers now (wire 0x37).
          if (onPitch) net.setAttributes((away ? perTeam : 0) + idx, GameWire.ATTRIBUTES.map((c) => attrs[c]));
          msg.textContent = onPitch ? '✓ saved — playing with it now' : '✓ saved';
          msg.style.color = '#7dff9a';
        } catch (err) {
          msg.textContent = '⚠ not saved: ' + err.message;
          msg.style.color = '#ff8a94';
        }
      };
    };
    draw();
  }

  // LINEUP (mig 641; James: "allow for lineup change and for set lineup
  // from game center"): who starts in each formation slot, bench included;
  // a team linked to the club can take a Game Center lineup. Both save to
  // the DB, then RELOAD_ROSTERS makes the running match re-read the teams.
  async function renderLineup(body, slot) {
    const perTeam = ((hello && hello.slotCount) || 22) / 2;
    const away = slot >= perTeam;
    const teamName = teams && (away ? teams.away : teams.home);
    if (!teamName) { body.textContent = 'This match has no rostered teams.'; return; }
    const t = await loadTeam(teamName, true);
    const after = (msg, ok, text) => {
      for (const k of Object.keys(teamCache)) delete teamCache[k];   // slot order changed
      net.reloadRosters();
      msg.textContent = text;
      msg.style.color = ok ? '#7dff9a' : '#ff8a94';
    };
    let html = `<div style="font-size:11px;opacity:.7;margin-bottom:4px;">${esc(t.team)} · ${esc(t.formation)} — who starts where</div>`;
    t.slots.forEach((label, i) => {
      const cur = t.players.find((p) => p.lineup_slot === i + 1);
      html += `<div style="display:flex;align-items:center;gap:6px;margin:2px 0;">
        <span style="width:34px;font-size:11px;font-weight:700;">${esc(label)}</span>
        <select data-slot="${i}" style="flex:1;min-width:0;background:#0b1c3d;color:#f4f6fb;border:1px solid #889;border-radius:6px;padding:2px;">` +
        t.players.map((p) => `<option value="${p.shirt}"${cur && cur.shirt === p.shirt ? ' selected' : ''}>#${p.shirt} ${esc(p.name)}${p.lineup_slot ? '' : ' (bench)'}</option>`).join('') +
        `</select></div>`;
    });
    html += `<div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px;">
        <span id="lu-msg" style="font-size:11px;opacity:.8;"></span>
        <button id="lu-save" style="background:#ffcc00;color:#0b1c3d;border:none;padding:4px 14px;border-radius:6px;font-weight:700;">SAVE LINEUP</button></div>`;
    if (t.game_center) {
      html += `<div style="margin-top:10px;padding-top:8px;border-top:1px solid rgba(255,255,255,.2);">
        <div style="font-size:11px;font-weight:700;margin-bottom:4px;">Set lineup from Game Center</div>
        <select id="gc-match" style="width:100%;background:#0b1c3d;color:#f4f6fb;border:1px solid #889;border-radius:6px;padding:3px;"><option>loading…</option></select>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px;">
          <span id="gc-msg" style="font-size:11px;opacity:.8;"></span>
          <button id="gc-set" style="background:#ffcc00;color:#0b1c3d;border:none;padding:4px 10px;border-radius:6px;font-weight:700;">SET FROM GAME CENTER</button></div></div>`;
    }
    body.innerHTML = html;
    shieldKeys(body);
    body.querySelector('#lu-save').onclick = async () => {
      const msg = body.querySelector('#lu-msg');
      const shirts = [...body.querySelectorAll('select[data-slot]')].map((sel) => +sel.value);
      if (new Set(shirts).size !== shirts.length) {
        msg.textContent = '⚠ someone is picked twice';
        msg.style.color = '#ff8a94';
        return;
      }
      msg.textContent = 'saving…';
      try {
        const r = await fetch('/api/game/lineup', { method: 'PUT', headers: authHeaders(),
          body: JSON.stringify({ team: t.team, shirts }) });
        const j = await r.json().catch(() => ({}));
        if (!r.ok) throw new Error(j.error || 'HTTP ' + r.status);
        after(msg, true, '✓ saved — the match re-reads the team now');
      } catch (err) {
        after(msg, false, '⚠ not saved: ' + err.message);
      }
    };
    if (!t.game_center) return;
    const sel = body.querySelector('#gc-match');
    try {
      const r = await fetch('/api/game/game-center-lineups?team=' + encodeURIComponent(t.team), { headers: authHeaders() });
      const j = await r.json().catch(() => ({}));
      if (!r.ok) throw new Error(j.error || 'HTTP ' + r.status);
      sel.innerHTML = j.matches.length
        ? j.matches.map((m) => `<option value="${m.match_id}">${esc(m.date)} · ${esc(m.title)} (${m.starters} starters)</option>`).join('')
        : '<option value="">No Game Center lineups yet</option>';
    } catch (err) {
      sel.innerHTML = '<option value="">' + esc('Couldn\'t load: ' + err.message) + '</option>';
    }
    body.querySelector('#gc-set').onclick = async () => {
      const msg = body.querySelector('#gc-msg');
      if (!sel.value) return;
      msg.textContent = 'setting…';
      try {
        const r = await fetch('/api/game/lineup/game-center', { method: 'POST', headers: authHeaders(),
          body: JSON.stringify({ team: t.team, match_id: +sel.value }) });
        const j = await r.json().catch(() => ({}));
        if (!r.ok) throw new Error(j.error || 'HTTP ' + r.status);
        after(msg, true, '✓ set' + (j.added ? ` (${j.added} new to the game)` : '') + ' — playing it now');
        setTimeout(() => renderLineup(body, slot).catch(() => {}), 600);
      } catch (err) {
        after(msg, false, '⚠ not set: ' + err.message);
      }
    };
  }

  function renderKnowledge(body, slot, e) {
    let html = `<div style="max-height:52vh;overflow-y:auto;">`;
    GameWire.CONCEPTS.forEach((c, i) => {
      if (!c) return;   // an id hole in the curriculum
      const v = e.ratings[i] || 0;
      html += `<div style="display:flex;align-items:center;gap:6px;margin:2px 0;">
        <span style="width:92px;font-size:11px;">${c}</span>
        <input type="range" min="0" max="100" value="${v}" data-idx="${i}"
               style="flex:1;" oninput="this.nextElementSibling.textContent=this.value">
        <span style="width:26px;text-align:right;font-size:11px;">${v}</span></div>`;
    });
    html += `</div><div style="margin-top:8px;text-align:right;">
      <button id="ep-apply" style="background:#ffcc00;color:#0b1c3d;
        border:none;padding:4px 14px;border-radius:6px;font-weight:700;">APPLY</button></div>`;
    body.innerHTML = html;
    body.querySelector('#ep-apply').onclick = () => {
      const ratings = new Array(GameWire.CONCEPTS.length).fill(0);
      body.querySelectorAll('input[data-idx]').forEach((sl) => {
        ratings[+sl.dataset.idx] = +sl.value;
      });
      net.setConcepts(slot, ratings);
      editPanel.style.display = 'none';
    };
  }

  function sendLevels() {
    net.setLevels(levels.home, levels.away);
  }
  function paintLevelButtons() {
    if (lvlHomeBtn)
      lvlHomeBtn.textContent = 'H: ' + GameWire.LEVELS[levels.home];
    if (lvlAwayBtn)
      lvlAwayBtn.textContent = 'A: ' + GameWire.LEVELS[levels.away];
  }

  let reconnectTimer = null;
  function scheduleReconnect() {
    if (reconnectTimer) return;
    reconnectTimer = setTimeout(() => {
      reconnectTimer = null;
      statusEl.textContent = 'reconnecting…';
      net.connect();
    }, 1500);
  }


  // ── Brain overlay (G4.41) — James: "we should have overlay that shows info
  // about players brain. pills to show just one guy etc or whole team. like
  // a hud … buckland does basically this in his book". Pills: off / one
  // player / home / away / both. Each shown player: what he decided, a line
  // to where he's going, a dashed line to the man he's acting on. ──
  const WHY_CONCEPT = {
    'pass ladder': 'pass-ladder', 'over the top': 'over-top', 'recycle': 'safe-pass',
    'keeper sweep': 'sweep', 'cover shadow': 'cover-shadow', 'counter-press': 'counter-press',
    'tackle': 'tackle-timing', 'recover goal-side': 'recover', 'chase ball': 'intercept',
    'delay': 'delay', 'libero': 'libero', 'mark': 'marking', 'give and go': 'give-and-go',
    'blind-side run': 'blind-side-run', 'run in behind': 'runs', 'outlet': 'outlet',
    'support': 'support', 'shoot': 'shot-selection',
  };
  Object.assign(WHY_CONCEPT, {
    'jockey side-on': 'side-on-jockey', 'turn and run with him': 'drop-step',
    'meet the pass': 'meet-the-pass', 'hold shape': 'line-hold',
    'play it back': 'keep-it-under-pressure', 'shield and turn': 'keep-it-under-pressure',
  });
  // G4.57 HUD — James: "needs to be see through and off to side. maybe ukies
  // on one side and lh on other. we should be able to toggle players on and
  // off." One see-through panel per team (home left, away right): a row per
  // player — tick to draw his lines on the pitch, tap his name for the
  // concept and rating behind the decision. Ticks are remembered on this
  // device.
  let brainOn = false, brainLegend = [], brainEntries = null, brainOpen = null;
  const brainPick = new Set();
  const BRAIN_KEY = 'fh-game-brain-picks';
  try { (JSON.parse(localStorage.getItem(BRAIN_KEY) || '[]') || []).forEach((i) => brainPick.add(i)); } catch (_) {}
  const savePicks = () => { try { localStorage.setItem(BRAIN_KEY, JSON.stringify([...brainPick])); } catch (_) {} };
  const brainBar = document.createElement('button');
  brainBar.type = 'button';
  brainBar.className = 'game-only';
  brainBar.style.cssText = 'position:fixed;left:50%;transform:translateX(-50%);' +
    'top:calc(env(safe-area-inset-top, 0px) + 30px);z-index:20;border:0;border-radius:14px;' +
    'padding:5px 14px;font:700 11px system-ui,sans-serif;cursor:pointer;';
  brainBar.onclick = () => setBrainOn(!brainOn);
  const brainSides = [0, 1].map((team) => {
    const el = document.createElement('div');
    el.className = 'game-only';
    el.hidden = true;
    el.setAttribute('role', 'region');
    el.style.cssText = `position:fixed;${team === 0 ? 'left' : 'right'}:max(8px, env(safe-area-inset-${team === 0 ? 'left' : 'right'}, 0px));` +
      'top:calc(env(safe-area-inset-top, 0px) + 96px);width:min(210px, 44vw);max-height:calc(100vh - 200px);' +
      'overflow:auto;background:rgba(8,12,18,.32);backdrop-filter:blur(3px);-webkit-backdrop-filter:blur(3px);' +
      'color:#fff;text-shadow:0 1px 2px rgba(0,0,0,.9);font:11px/1.35 system-ui,sans-serif;' +
      'border-radius:10px;z-index:20;padding:6px;';
    document.body.appendChild(el);
    return { el, collapsed: window.innerWidth < 700, rows: [] };
  });
  document.body.appendChild(brainBar);
  function teamSlots(team) {
    const n = (hello && hello.slotCount) || roster.length || 22;
    const half = Math.floor(n / 2);
    const out = [];
    for (let i = team === 0 ? 0 : half; i < (team === 0 ? half : n); i++) out.push(i);
    return out;
  }
  function slotName(i) {
    const r = roster[i];
    return r && r.name ? r.name : '#' + (i + 1);
  }
  function paintBrainBar() {
    brainBar.textContent = brainOn ? 'Brain on' : 'Brain off';
    brainBar.setAttribute('aria-pressed', String(brainOn));
    brainBar.style.background = brainOn ? '#ffcc00' : 'rgba(10,14,20,.55)';
    brainBar.style.color = brainOn ? '#0b1c3d' : '#fff';
  }
  function paintBrainSides() {   // structure: on roster / teams / toggles
    const names = [(teams && teams.home) || 'Home', (teams && teams.away) || 'Away'];
    brainSides.forEach((side, team) => {
      side.el.hidden = !brainOn;
      side.el.setAttribute('aria-label', names[team] + ' brains');
      const slots = teamSlots(team);
      const all = slots.every((i) => brainPick.has(i));
      let h = `<div style="display:flex;align-items:center;gap:4px;margin-bottom:4px;">` +
        `<strong style="flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${esc(names[team])}</strong>` +
        `<button type="button" data-all="${team}" style="${pill()}">${all ? 'None' : 'All'}</button>` +
        `<button type="button" data-fold="${team}" aria-expanded="${!side.collapsed}" aria-label="${side.collapsed ? 'Show' : 'Hide'} players" style="${pill()}">${side.collapsed ? '▸' : '▾'}</button></div>`;
      if (!side.collapsed) for (const i of slots) {
        h += `<div data-row="${i}" style="padding:2px 0;border-top:1px solid rgba(255,255,255,.12);">` +
          `<div style="display:flex;align-items:center;gap:5px;">` +
          `<input type="checkbox" id="bp-${i}" data-pick="${i}" ${brainPick.has(i) ? 'checked' : ''} aria-label="Show ${esc(slotName(i))} on the pitch" style="margin:0;width:14px;height:14px;min-width:0;min-height:0;">` +
          `<button type="button" data-open="${i}" style="all:unset;cursor:pointer;flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${esc(slotName(i))}</button></div>` +
          `<div data-why="${i}" style="padding-left:19px;color:#ffcc00;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"></div>` +
          `<div data-det="${i}" style="padding-left:19px;opacity:.85;"${brainOpen === i ? '' : ' hidden'}></div></div>`;
      }
      side.el.innerHTML = h;
    });
    updateBrainRows();
  }
  function pill() {
    return 'border:0;border-radius:8px;padding:1px 7px;font:700 10px system-ui,sans-serif;cursor:pointer;' +
      'background:rgba(255,255,255,.18);color:#fff;min-width:0;min-height:0;';
  }
  function updateBrainRows() {   // text only, every BRAIN frame (~5 Hz)
    if (!brainOn) return;
    for (const side of brainSides) {
      for (const el of side.el.querySelectorAll('[data-why]')) {
        const i = Number(el.dataset.why);
        const e = brainEntries && brainEntries[i];
        const why = e ? brainLegend[e.why] || '?' : '…';
        const other = e && e.other !== 255 ? ' → ' + slotName(e.other) : '';
        el.textContent = why + other;
      }
      for (const el of side.el.querySelectorAll('[data-det]')) {
        if (el.hidden) continue;
        const i = Number(el.dataset.det);
        const e = brainEntries && brainEntries[i];
        const why = e ? brainLegend[e.why] || '' : '';
        const concept = WHY_CONCEPT[why];
        const ci = concept ? GameWire.CONCEPTS.indexOf(concept) : -1;
        const rating = ci >= 0 && roster[i] ? roster[i].ratings[ci] : null;
        el.textContent = (concept ? `${concept}: ${rating === null ? '—' : rating}` : 'no concept behind this one') +
          (e && e.rung ? ` · rung ${e.rung}` : '');
      }
    }
    renderer.setBrain({ entries: brainEntries, legend: brainLegend, show: brainPick });
  }
  for (const side of brainSides) {
    side.el.addEventListener('click', (ev) => {
      const t = ev.target;
      if (t.dataset.all !== undefined) {
        const slots = teamSlots(Number(t.dataset.all));
        const all = slots.every((i) => brainPick.has(i));
        for (const i of slots) all ? brainPick.delete(i) : brainPick.add(i);
        savePicks(); paintBrainSides();
      } else if (t.dataset.fold !== undefined) {
        side.collapsed = !side.collapsed; paintBrainSides();
      } else if (t.dataset.open !== undefined) {
        const i = Number(t.dataset.open);
        brainOpen = brainOpen === i ? null : i; paintBrainSides();
      }
    });
    side.el.addEventListener('change', (ev) => {
      const t = ev.target;
      if (t.dataset.pick === undefined) return;
      const i = Number(t.dataset.pick);
      t.checked ? brainPick.add(i) : brainPick.delete(i);
      savePicks(); paintBrainSides();
    });
  }
  function setBrainOn(on) {
    if (on === brainOn) return;
    brainOn = on;
    // First time on with nothing ticked: show everyone.
    if (on && brainPick.size === 0) for (const t of [0, 1]) for (const i of teamSlots(t)) brainPick.add(i);
    net.brainWatch(on);
    paintBrainBar();
    paintBrainSides();
    if (!on) renderer.setBrain(null);
  }
  paintBrainBar();

  // ── Phases of play (G4.58, admin) — James: "lets have a restart from
  // keeper option. for either team … the MOST organized a team will ever
  // be" / "then mid block … final third … tap off and corners". Pick a
  // phase, run it for a team: everyone sets up in shape, play goes on. ──
  let phaseNames = [], isAdmin = false;
  const phaseBar = document.createElement('div');
  phaseBar.className = 'game-only';
  phaseBar.hidden = true;
  phaseBar.setAttribute('role', 'group');
  phaseBar.setAttribute('aria-label', 'Phase of play');
  phaseBar.style.cssText = 'position:fixed;left:50%;transform:translateX(-50%);' +
    'top:calc(env(safe-area-inset-top, 0px) + 60px);display:flex;gap:4px;align-items:center;z-index:20;' +
    'background:rgba(10,14,20,.55);padding:3px 4px;border-radius:14px;font:700 11px system-ui,sans-serif;color:#fff;';
  document.body.appendChild(phaseBar);
  function paintPhaseBar() {
    phaseBar.hidden = !isAdmin || phaseNames.length === 0;
    if (phaseBar.hidden) return;
    const names = [(teams && teams.home) || 'Home', (teams && teams.away) || 'Away'];
    const short = (t) => (t.length > 14 ? t.split(' ')[0] : t);
    const sel = phaseBar.querySelector('select');
    const keep = sel ? sel.value : '0';
    phaseBar.innerHTML =
      `<select id="phase-pick" aria-label="Phase" style="font:700 11px system-ui,sans-serif;border-radius:10px;border:0;padding:3px 6px;min-height:0;">` +
      phaseNames.map((n, i) => `<option value="${i}">${esc(n)}</option>`).join('') + `</select>` +
      names.map((n, t) => `<button type="button" data-team="${t}" title="Run this phase with ${esc(n)} on the ball" ` +
        `style="border:0;border-radius:10px;padding:3px 9px;font:700 11px system-ui,sans-serif;cursor:pointer;min-height:0;min-width:0;` +
        `background:#ffcc00;color:#0b1c3d;">▶ ${esc(short(n))}</button>`).join('');
    phaseBar.querySelector('select').value = keep;
  }
  phaseBar.addEventListener('click', (ev) => {
    const b = ev.target.closest('[data-team]');
    if (!b) return;
    net.runPhase(Number(b.dataset.team), Number(phaseBar.querySelector('select').value));
  });

  const net = new GameNet({
    onHello(h) {
      hello = h;
      if (!renderer.built) {        // reconnects reuse the scene
        renderer.buildWorld(h);
        renderer.built = true;
      }
      // Admin capability (bit 3) shows the level pickers.
      isAdmin = !!(h.capabilities & 8);
      paintPhaseBar();
      if ((h.capabilities & 8) && editBtn) {
        editBtn.style.display = 'block';
        const flipEdit = () => {
          editMode = !editMode;
          editBtn.style.background =
            editMode ? 'rgba(255,204,0,.5)' : 'rgba(255,255,255,.12)';
          if (!editMode) editPanel.style.display = 'none';
          paintPresetBar();
        };
        editBtn.addEventListener('click', flipEdit);
        editBtn.addEventListener('touchstart', (e) => {
          e.preventDefault(); e.stopPropagation(); flipEdit();
        });
      }
      if ((h.capabilities & 8) && lvlHomeBtn && lvlAwayBtn) {
        lvlHomeBtn.style.display = 'block';
        lvlAwayBtn.style.display = 'block';
        const cycle = (side) => {
          levels[side] = (levels[side] + 1) % GameWire.LEVELS.length;
          paintLevelButtons();
          sendLevels();
        };
        for (const [btn, side] of [[lvlHomeBtn, 'home'], [lvlAwayBtn, 'away']]) {
          btn.addEventListener('click', () => cycle(side));
          btn.addEventListener('touchstart', (e) => {
            e.preventDefault(); e.stopPropagation(); cycle(side);
          });
        }
      }
      statusEl.textContent =
        `match ${h.matchId} — tap a player to take control · drag to rotate`;
      // Ship intents at tick rate for every slot we own. The server
      // samples (last write before its tick wins), so this cadence is
      // exactly right. [QUAKE]
      if (intentTimer) clearInterval(intentTimer);
      intentTimer = setInterval(() => {
        if (mySlots.size === 0) return;
        // Controls are CAMERA-relative: "up" means away from the viewer
        // however the camera has been rotated.
        const v = renderer.screenToPitch(input.vector());
        const action = input.consumeAction();
        // One input device drives ONE player. Other claimed slots get an
        // explicit zero vector each tick — the server samples intents and
        // would otherwise keep running their last one forever.
        for (const slot of mySlots) {
          if (slot === activeSlot) net.intent(slot, v.x, v.y, action);
          else net.intent(slot, 0, 0, 0);
        }
      }, 1000 / (h.tickRate || 30));
    },
    onSnapshot(s) {
      renderer.pushSnapshot(s);
      if (s.match && boardEl) {
        const m = s.match;
        if (m.levelHome !== undefined &&
            (m.levelHome !== levels.home || m.levelAway !== levels.away)) {
          levels.home = m.levelHome;
          levels.away = m.levelAway;
          paintLevelButtons();
        }
        const mm = String(Math.floor(m.clockSec / 60)).padStart(2, '0');
        const ss = String(m.clockSec % 60).padStart(2, '0');
        // Team names from the TEAMS frame (game_demo_teams) — James: "should
        // say that in score label".
        const homeName = (teams && teams.home) || 'HOME';
        const awayName = (teams && teams.away) || 'AWAY';
        boardEl.textContent =
          `${homeName} ${m.score0} — ${m.score1} ${awayName}   ${mm}:${ss} ${m.period === 2 ? '2H' : '1H'}`;
      }
      // AUTO: hand the controls to whichever held player is ball-nearest.
      if (autoSwitch && mySlots.size > 1 && s.players) {
        let best = activeSlot, bestD = Infinity;
        for (const slot of mySlots) {
          const p = s.players[slot];
          if (!p) continue;
          const d = (p.x - s.ball.x) ** 2 + (p.y - s.ball.y) ** 2;
          if (d < bestD) { bestD = d; best = slot; }
        }
        if (best !== activeSlot) {
          activeSlot = best;
          renderer.setMySlots(mySlots, activeSlot);
          updateStatus();
        }
      }
    },
    onRoster(r) {
      roster = r;
      applyIdentities();   // names may have changed (lineup / reload)
      if (brainOn) paintBrainSides();
    },
    onBrain(entries) {
      brainEntries = entries;
      updateBrainRows();
    },
    onPhases(names) {
      phaseNames = names;
      paintPhaseBar();
    },
    onBrainLegend(names) {
      brainLegend = names;
    },
    onTeams(t) {
      teams = t;
      if (brainOn) paintBrainSides();
      paintPhaseBar();
      // Names + position numbers over the players (mig 643): both teams'
      // slot numbers from the club API, names from ROSTER.
      for (const k of Object.keys(teamCache)) delete teamCache[k];
      Promise.all([loadTeam(t.home, true), loadTeam(t.away, true)])
        .then(([h, a]) => { idTeams = [h, a]; applyIdentities(); })
        .catch(() => { idTeams = null; applyIdentities(); });
      // The teams' own kits (mig 639): recolour and rebuild the figures.
      if (t.kits && (t.kits[0] || t.kits[1])) {
        PlayerFigure.setKits(t.kits[0], t.kits[1]);
        for (const f of (renderer.figures || [])) f.build(f.home, f.keeper);
      }
    },
    onPresets(names) {
      presets = names;
      if (presetSelect) {
        presetSelect.innerHTML = '';
        names.forEach((n) => {
          const o = document.createElement('option');
          o.textContent = n;
          presetSelect.appendChild(o);
        });
      }
      paintPresetBar();
    },
    onEvent(ev) {
      // Tackles (8/9) fire dozens of times a match — not toast-worthy.
      if (!EVENT_NAMES[ev.eventType]) return;
      const name = EVENT_NAMES[ev.eventType];
      if (ev.eventType === 1) {
        renderer.goalFlash();
        renderer.celebrate(ev.team);
        toast(`⚽ ${name}`, 3000);
      } else {
        const side = ev.eventType === 10
          ? (ev.team === 0 ? ' — free kick home' : ' — free kick away')
          : ev.eventType <= 5 ? (ev.team === 0 ? ' — home' : ' — away') : '';
        toast(`${name}${side}`, 2000);
      }
    },
    onClose() {
      // Claims died with the socket; drop them and come back by ourselves
      // (phones sleep, wifi blips — a sandbox should just rejoin).
      if (intentTimer) { clearInterval(intentTimer); intentTimer = null; }
      mySlots.clear();
      activeSlot = null;
      renderer.setMySlots(mySlots, activeSlot);
      statusEl.textContent = 'connection lost — reconnecting…';
      scheduleReconnect();
    },
  });

  // Tap rules: unclaimed → claim it AND make it the active one;
  // claimed-but-inactive → switch control to it; the active one → release
  // it (control falls to another claimed player if you still hold one).
  function pickAt(x, y) {
    if (!hello) return;
    const slot = renderer.pickSlot(x, y);
    if (slot === null) return;
    if (editMode) {           // admin edit screen: inspect, don't claim
      openEditPanel(slot);
      return;
    }
    if (!mySlots.has(slot)) {
      mySlots.add(slot);
      net.claim(slot);
      activeSlot = slot;
    } else if (slot !== activeSlot) {
      activeSlot = slot;
    } else {
      mySlots.delete(slot);
      net.release(slot);
      activeSlot = mySlots.size ? [...mySlots][0] : null;
    }
    renderer.setMySlots(mySlots, activeSlot);
    updateStatus();
  }

  function updateStatus() {
    if (!mySlots.size) {
      statusEl.textContent = 'tap a player to take control';
      return;
    }
    const others = [...mySlots].filter((s) => s !== activeSlot);
    const myName = roster[activeSlot]
      ? roster[activeSlot].name : '#' + (activeSlot + 1);
    statusEl.textContent =
      `driving ${myName}` +
      (others.length ? ` (also holding ${others.map((s) => '#' + (s + 1)).join(', ')} — tap to switch)` : '') +
      ' — WASD/joystick, Space pass, X loft · C or 1–6 camera, +/− zoom';
  }
  if (autoBtn) {
    const flip = () => {
      autoSwitch = !autoSwitch;
      autoBtn.style.background =
        autoSwitch ? 'rgba(255,204,0,.5)' : 'rgba(255,255,255,.12)';
    };
    autoBtn.addEventListener('click', flip);
    autoBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); flip();
    });
  }

  // Q cycles which held player you're driving (G2.6).
  window.addEventListener('keydown', (e) => {
    if (e.key.toLowerCase() !== 'q' || mySlots.size < 2) return;
    const list = [...mySlots];
    activeSlot = list[(list.indexOf(activeSlot) + 1) % list.length];
    renderer.setMySlots(mySlots, activeSlot);
    updateStatus();
  });

  // A click/tap claims — unless it turned into a camera drag.
  canvas.addEventListener('click', (e) => {
    if (renderer.rig.dragged) { renderer.rig.dragged = false; return; }
    pickAt(e.clientX, e.clientY);
  });
  let tapStart = null;
  canvas.addEventListener('touchstart', (e) => {
    const t = e.touches[0];
    // Upper part of the screen only — lower part belongs to the joystick.
    tapStart = (e.touches.length === 1 && t && t.clientY < window.innerHeight * 0.4)
      ? { x: t.clientX, y: t.clientY } : null;
  });
  canvas.addEventListener('touchend', (e) => {
    const t = e.changedTouches[0];
    if (tapStart && t && !renderer.rig.dragged &&
        Math.hypot(t.clientX - tapStart.x, t.clientY - tapStart.y) < 8)
      pickAt(t.clientX, t.clientY);
    tapStart = null;
    renderer.rig.dragged = false;
  });

  // Camera: C or the CAM button cycles TV / FREE / BEHIND / TOP; any
  // drag rotates (free orbit), wheel or pinch zooms.
  const camBtn = document.getElementById('btn-cam');
  renderer.rig.onModeChange = (label) => {
    if (camBtn) camBtn.textContent = 'CAM ' + label;
  };
  if (camBtn) {
    camBtn.textContent = 'CAM ' + renderer.rig.label();
    camBtn.addEventListener('click', () => renderer.rig.cycle());
    camBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); renderer.rig.cycle();
    });
  }
  // FOLLOW button or V: stop the camera tracking the ball so it can be
  // parked and panned (drag) anywhere on the site.
  const followBtn = document.getElementById('btn-follow');
  const toggleFollow = () => {
    renderer.rig.setFollow(!renderer.rig.follow);
    if (followBtn) {
      followBtn.textContent = renderer.rig.follow ? 'FOLLOW ON' : 'FOLLOW OFF';
      followBtn.style.background = renderer.rig.follow ? '' : 'rgba(255,204,0,.5)';
    }
  };
  if (followBtn) {
    followBtn.addEventListener('click', toggleFollow);
    followBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleFollow();
    });
  }
  // Zoom: +/− buttons (hold repeats), + / − / = keys; wheel and pinch
  // are handled by the rig itself. 1–6 pick a camera directly.
  const zoomBy = (f) => renderer.rig.zoom(f);
  for (const [id, f] of [['btn-zoom-in', 0.85], ['btn-zoom-out', 1 / 0.85]]) {
    const el = document.getElementById(id);
    if (!el) continue;
    let rep = null;
    const start = (e) => {
      e.preventDefault(); e.stopPropagation();
      zoomBy(f);
      rep = setInterval(() => zoomBy(f), 120);
    };
    const stop = () => { if (rep) clearInterval(rep); rep = null; };
    el.addEventListener('mousedown', start);
    el.addEventListener('touchstart', start);
    for (const ev of ['mouseup', 'mouseleave', 'touchend', 'touchcancel'])
      el.addEventListener(ev, stop);
  }
  // Trees: see-through wire leaves by default; LEAVES button or L shows
  // solid foliage.
  const leavesBtn = document.getElementById('btn-leaves');
  let leavesOn = false;
  const toggleLeaves = () => {
    leavesOn = !leavesOn;
    if (renderer.field && renderer.field.setLeaves) renderer.field.setLeaves(leavesOn);
    if (leavesBtn) leavesBtn.textContent = leavesOn ? 'LEAVES ON' : 'LEAVES OFF';
  };
  if (leavesBtn) {
    leavesBtn.addEventListener('click', toggleLeaves);
    leavesBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleLeaves();
    });
  }
  // Ground contours: button or K cycles lidar 10 cm (USGS 3DEP) → City
  // 2 ft → USGS topo 10 ft → all → off.
  const contoursBtn = document.getElementById('btn-contours');
  const CMODES = ['lidar', 'city', 'topo', 'all', 'off'];
  const CLABEL = { lidar: 'LIDAR 10CM', city: 'CITY 2FT', topo: 'USGS 10FT', all: 'ALL LINES',
                   off: 'CONTOURS OFF' };
  let cmode = 0;
  const toggleContours = () => {
    cmode = (cmode + 1) % CMODES.length;
    if (renderer.field && renderer.field.setContours) renderer.field.setContours(CMODES[cmode]);
    if (contoursBtn) contoursBtn.textContent = CLABEL[CMODES[cmode]];
  };
  if (contoursBtn) {
    contoursBtn.addEventListener('click', toggleContours);
    contoursBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleContours();
    });
  }
  // Drag-and-drop pitch planner: live legality + water score.
  const planner = window.PitchPlanner ? window.PitchPlanner.attach(renderer) : null;
  // MODES over the one Lighthouse model (James 10/22: a "game" button and
  // a "design" button, later practice setup / barn night / rodeo — each
  // mode brings only its own controls, so none is cluttered). GAME: the
  // match + its controls, ball-follow, no contours. DESIGN: the pitch
  // planner, contours, camera parked; game-only controls hidden (CSS
  // body.mode-design .game-only). Remembered per device; GAME by default.
  const modeBar = document.getElementById('mode-bar');
  let mode = 'game';
  try {
    mode = localStorage.getItem('fh.game.mode') ||
      (localStorage.getItem('fh.game.planMode') === '1' ? 'design' : 'game');
  } catch (e) { /* default GAME */ }
  // Modes set up but not built yet (James: "setup the others functionally
  // but not implemented"): the model with the game controls cleared and a
  // note of what's coming.
  const COMING = {
    practice: '🦺 <b>Practice setup</b> — coming: place cones, grids and stations on the field so every coach knows where tonight\'s session goes.',
    barn: '🎪 <b>Barn night</b> — coming: simulate a fundraiser night at the barn, people arriving, going in and out.',
    rodeo: '🐂 <b>Rodeo night</b> — coming: the rodeo with the band, the bulls, and cars driving in.',
  };
  const modeNote = document.getElementById('mode-note');
  if (mode !== 'game' && mode !== 'design' && !COMING[mode]) mode = 'game';
  // GAME plays on the DESIGNED pitch (James: "we need field oriented like
  // it is in design. and add 7v7 too"): the site turns so the club's 11v11
  // is the match pitch, and the designed 7v7 is chalked on the grass. From
  // the planner when it's loaded (live drags), else the saved club layout.
  let savedPlan = null;
  fetch('/api/field-plan').then((r) => (r.ok ? r.json() : null)).then((j) => {
    if (j && j.current) {
      savedPlan = j.current.items.filter((i) => i.kind === 'pitch')
        .map((i) => ({ id: i.key, x: i.x, z: i.z, rot: i.rot, size: [i.length_yd, i.width_yd] }));
      if (mode === 'game') syncGameField();
    }
  }).catch(() => { /* keep the built-in spot */ });
  function syncGameField() {
    const f = renderer.field;
    if (!f || !f.setGamePitch) { setTimeout(syncGameField, 300); return; }
    const ps = (planner && planner.current()) || savedPlan;
    if (!ps) return;
    const big = ps.find((p) => p.id === '11v11');
    const seven = ps.find((p) => p.id === '7v7');
    if (big) f.setGamePitch({ x: big.x, z: big.z, rotDeg: big.rot });
    f.setGameSeven(mode === 'game' && seven
      ? { x: seven.x, z: seven.z, rotDeg: seven.rot, length: seven.size[0] * 0.9144, width: seven.size[1] * 0.9144 }
      : null);
  }
  const applyMode = () => {
    const design = mode === 'design';
    const other = !!COMING[mode];
    document.body.classList.toggle('mode-design', design);
    document.body.classList.toggle('mode-other', other);
    // The match (players + ball) only in GAME and DESIGN; the other modes
    // show the complex itself — field, animals, buildings, trees.
    renderer.showMatch = !other;
    if (modeNote) modeNote.innerHTML = other ? COMING[mode] : '';
    if (modeBar) for (const b of modeBar.querySelectorAll('button')) b.classList.toggle('on', b.dataset.mode === mode);
    if (!renderer.field || !renderer.field.setContours) {
      if (planner) planner.setOn(design);   // so a late planner build lands in the right mode
      setTimeout(applyMode, 300);
      return;
    }
    cmode = CMODES.indexOf(design ? 'lidar' : 'off');
    renderer.field.setContours(CMODES[cmode]);
    if (contoursBtn) contoursBtn.textContent = CLABEL[CMODES[cmode]];
    syncGameField();
    // Today's yellow painted pitch only in DESIGN (James: "yellow field
    // needs to not be in game just design").
    if (renderer.field.setOldPitch) renderer.field.setOldPitch(design);
    // Ball-follow only in GAME; every other mode parks the camera.
    if (renderer.rig.follow !== (mode === 'game')) toggleFollow();
    // Last: in DESIGN the planner's layer pills decide contours, today's
    // pitch, water and the match, over the mode defaults above.
    if (planner) planner.setOn(design);
  };
  const setMode = (m) => {
    if (m === mode) return;
    mode = m;
    try { localStorage.setItem('fh.game.mode', mode); } catch (e) { /* this visit only */ }
    applyMode();
  };
  if (modeBar) {
    for (const b of modeBar.querySelectorAll('button')) {
      b.addEventListener('click', (e) => { e.preventDefault(); e.stopPropagation(); setMode(b.dataset.mode); });
      b.addEventListener('touchstart', (e) => { e.preventDefault(); e.stopPropagation(); setMode(b.dataset.mode); });
    }
  }
  applyMode();
  const CAMS = ['broadcast', 'ball', 'third', 'first', 'top', 'orbit'];
  window.addEventListener('keydown', (e) => {
    const k = e.key.toLowerCase();
    if (k === 'c' && !e.repeat) renderer.rig.cycle();
    if (k === 'l' && !e.repeat) toggleLeaves();
    if (k === 'k' && !e.repeat) toggleContours();
    if (k === 'v' && !e.repeat) toggleFollow();
    if (k === '+' || k === '=') zoomBy(0.85);
    if (k === '-' || k === '_') zoomBy(1 / 0.85);
    if (k >= '1' && k <= '6' && !e.repeat) renderer.rig.setMode(CAMS[+k - 1]);
  });

  function loop() {
    renderer.frame();
    // Stale-socket watchdog: a dead TCP path can go minutes without a
    // close event. No snapshot for 4 s while "open" → force the close
    // path, which reconnects.
    if (renderer.lastSnapshotAt &&
        performance.now() - renderer.lastSnapshotAt > 4000 &&
        net.ws && net.ws.readyState === WebSocket.OPEN) {
      renderer.lastSnapshotAt = 0;
      try { net.ws.close(); } catch (e) {}
    }
    requestAnimationFrame(loop);
  }

  statusEl.textContent = 'connecting…';
  net.connect();
  loop();

  // Debug handle for automated testing and console poking — reads state,
  // never owns it (the server stays authoritative regardless).
  window.__game = { renderer, net, mySlots, pickAt, input,
                    get hello() { return hello; } };
})();
