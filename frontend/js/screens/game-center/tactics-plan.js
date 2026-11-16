// 🎯 Tactics + match plan — the coach-drawn situations pitch and the tactic plan (mig 1120, tactic_plans)
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterTactics {
  async _loadTactics() {
    const t = this._tactics;
    const fid = this._formationId();
    if (!fid || (t.formationId === fid && (t.data || t.loading))) return;
    Object.assign(t, { formationId: fid, data: null, loading: true, error: null, idx: 0, editing: false, draft: null, msg: '' });
    this._render();
    try {
      const res = await this.auth.fetch(`/api/formation-tactics/${fid}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (t.formationId === fid) t.data = body;
    } catch (err) {
      if (t.formationId === fid) t.error = err.message;
    }
    if (t.formationId === fid) { t.loading = false; this._render(); }
  }

  _tacticsSituations() { return (this._tactics.data && this._tactics.data.situations) || []; }

  _startTacticsEdit() {
    const sit = this._tacticsSituations()[this._tactics.idx];
    if (!sit) return;
    this._tactics.draft = JSON.parse(JSON.stringify(sit));
    this._tactics.editing = true;
    this._tactics.msg = '';
    this._render();
  }

  async _saveTactics() {
    const t = this._tactics;
    const d = t.draft;
    if (!d) return;
    try {
      const res = await this.auth.fetch(`/api/formation-tactics/situations/${d.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ball: d.ball, players: d.players, opponents: d.opponents }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      const list = this._tacticsSituations();
      const i = list.findIndex(s => s.id === d.id);
      if (i >= 0) list[i] = d;
      Object.assign(t, { editing: false, draft: null, msg: this._copyTactics('saved') || 'Saved ✓' });
    } catch (err) {
      t.msg = `⚠ ${err.message}`;
    }
    this._render();
  }

  // Shirt number + the day's name in that slot (blank when nobody is).
  _tacticsChipFor() {
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    return (positionId) => {
      const pos = startingPositions.find(p => p.id === positionId);
      const occupant = rosterById.get(slotToPlayerId.get(positionId));
      return { number: pos ? pos.sortOrder : positionId, name: occupant ? occupant.name : '' };
    };
  }

  _tacticsDrawnHtml() {
    const t = this._tactics;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    if (!this._tacticsAvailable()) return `<div style="font-size:0.75rem; opacity:0.75;">${esc(this._copyTactics('none', { formation: this.formation || '' }))}</div>`;
    // Formation changed while open: fetch after this render, not inside it.
    if (t.formationId !== this._formationId()) setTimeout(() => this._loadTactics(), 0);
    let inner;
    const list = this._tacticsSituations();
    if (!this._formationId()) inner = `<div style="font-size:0.75rem; opacity:0.75;">${esc(this._copyTactics('none', { formation: this.formation }) || `No situations drawn for ${this.formation} yet.`)}</div>`;
    else if (t.loading || (!t.data && !t.error)) inner = '<div style="font-size:0.75rem; opacity:0.7;">Loading…</div>';
    else if (t.error) inner = `<div style="font-size:0.75rem; color:#f87171;">⚠ ${esc(t.error)}</div>`;
    else if (!list.length) inner = `<div style="font-size:0.75rem; opacity:0.75;">${esc(this._copyTactics('none', { formation: this.formation }) || `No situations drawn for ${this.formation} yet.`)}</div>`;
    else {
      const idx = Math.min(t.idx, list.length - 1);
      const sit = t.editing && t.draft ? t.draft : list[idx];
      const pills = list.map((s, i) => `<button type="button" data-gc-tactics-sit="${i}" class="btn btn-sm ${i === idx ? 'btn-primary' : 'btn-secondary'}"
          ${t.editing && i !== idx ? 'disabled' : ''} style="font-size:0.72rem; padding:3px 9px; white-space:nowrap;">${esc(s.label)}</button>`).join('');
      const tools = !this._tacticsCanEdit() ? '' : t.editing
        ? `<button type="button" data-gc-tactics-save class="btn btn-primary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('save') || '💾 Save')}</button>
           <button type="button" data-gc-tactics-cancel class="btn btn-secondary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('cancel') || 'Cancel')}</button>
           <span style="font-size:0.7rem; opacity:0.8;">${esc(this._copyTactics('editing_drawn'))}</span>`
        : `<button type="button" data-gc-tactics-edit class="btn btn-secondary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('edit_drawn') || '✏️ Move pieces')}</button>`;
      inner = `
        <div style="display:flex; gap:6px; overflow-x:auto; padding-bottom:4px; margin-bottom:6px;">${pills}</div>
        ${sit.notes ? `<div style="font-size:0.78rem; line-height:1.35; margin-bottom:8px;">${esc(sit.notes)}</div>` : ''}
        <div data-gc-tactics-pitch></div>
        <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:8px;">${tools}
          ${t.msg ? `<span style="font-size:0.72rem; font-weight:700;">${esc(t.msg)}</span>` : ''}</div>`;
    }
    return `<div style="margin:0 0 12px;">
      <div style="padding:10px; border:1px solid var(--border-color); border-radius:8px;">
        <div style="font-size:0.72rem; opacity:0.75; margin-bottom:6px;">${esc(this._copyTactics('hint'))}</div>
        ${inner}
      </div></div>`;
  }

  // The Tactics pill: 🧠 Game model (jobs plan, mig 1121) or ✏️ Drawn
  // (hand-placed situations, mig 1120).
  _tacticsSectionHtml() {
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const mode = this._tacticsMode === 'drawn' ? 'drawn' : 'plan';
    const modes = [['plan', this._copyTactics('mode_plan') || '🧠 Game model'], ['drawn', this._copyTactics('mode_drawn') || '✏️ Drawn']]
      .map(([k, label]) => `<button type="button" data-gc-tactics-mode="${k}" class="btn btn-sm ${k === mode ? 'btn-primary' : 'btn-secondary'}" style="font-size:0.74rem; padding:3px 10px;">${esc(label)}</button>`).join('');
    const v = this._tacticsView;
    const orient = [['portrait', this._copyTactics('orient_portrait') || '↕ Upright'], ['landscape', this._copyTactics('orient_landscape') || '↔ Sideways']]
      .map(([k, label]) => `<button type="button" data-gc-tactics-orient="${k}" class="btn btn-sm ${k === v.orientation ? 'btn-primary' : 'btn-secondary'}" style="font-size:0.72rem; padding:3px 9px;">${esc(label)}</button>`).join('');
    const big = `<button type="button" data-gc-tactics-big class="btn btn-sm ${v.big ? 'btn-primary' : 'btn-secondary'}" style="font-size:0.72rem; padding:3px 10px;">${esc(v.big ? (this._copyTactics('big_close') || '✕ Close') : (this._copyTactics('big') || '⛶ Big'))}</button>`;
    // 🎮 3D trainer (mig 1200): the game's PL-sides tactics trainer, link and
    // label both DB copy — no row, no button.
    const trainerHref = this._copyTactics('trainer_href'), trainerLabel = this._copyTactics('trainer');
    const trainer = trainerHref && trainerLabel && trainerHref.startsWith('/game.html?')
      ? `<a href="${esc(trainerHref)}" target="_blank" rel="noopener" data-gc-tactics-trainer class="btn btn-sm btn-secondary" style="font-size:0.72rem; padding:3px 10px; text-decoration:none;">${esc(trainerLabel)}</a>` : '';
    const body = `<div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center; margin-bottom:8px;">${modes}
        <span style="flex:1;"></span>${orient}${big}${trainer}</div>`
      + (mode === 'drawn' ? this._tacticsDrawnHtml() : this._planHtml());
    if (!v.big) return body;
    // Full screen: the same panel over everything (the job sheet, z 1000,
    // still opens above it).  The pitch is fitted to what is left of the
    // screen by _fitTacticsBig after mount.
    // Wide screen: controls in a left column, the pitch beside them at full
    // height (sticky while the job list scrolls).  Narrow: stacked.
    return `<style>
        @media (min-width: 900px) {
          [data-gc-tactics-bigbox] { display:grid; grid-template-columns:minmax(260px, 320px) 1fr; column-gap:14px; align-content:start; }
          [data-gc-tactics-bigbox] > * { grid-column:1; min-width:0; }
          [data-gc-tactics-bigbox] > [data-gc-tactics-pitch] { grid-column:2; grid-row:1 / span 40; position:sticky; top:0; align-self:start; }
        }
      </style>
      <div data-gc-tactics-bigbox style="position:fixed; inset:0; z-index:999; background:var(--bg-color, #0b1220); overflow:auto; padding:10px 12px; box-sizing:border-box;">${body}</div>`;
  }

  // The pitch's view settings, for TacticsPitch.
  _tacticsPitchView() { return { orientation: this._tacticsView.orientation, big: this._tacticsView.big }; }

  // Big off without a render: leaving the pill or the screen.
  _tacticsBigOff() {
    if (!this._tacticsView.big && !this._tacticsBigKeys) return;
    this._tacticsView.big = false;
    try { if (document.fullscreenElement && document.exitFullscreen) document.exitFullscreen().catch(() => {}); } catch (e) { /* no fullscreen API */ }
    if (this._tacticsBigKeys) {
      document.removeEventListener('keydown', this._tacticsBigKeys);
      window.removeEventListener('resize', this._tacticsBigResize);
      document.removeEventListener('fullscreenchange', this._tacticsBigFs);
      this._tacticsBigKeys = this._tacticsBigResize = this._tacticsBigFs = null;
    }
  }

  _setTacticsBig(on) {
    if (!on) { this._tacticsBigOff(); this._render(); return; }
    const v = this._tacticsView;
    v.big = true;
    // The browser's own full screen too (phones lose the address bar); the
    // whole page goes, so re-renders keep it.  Refused = the overlay alone.
    try {
      if (!document.fullscreenElement && document.documentElement.requestFullscreen) document.documentElement.requestFullscreen().catch(() => {});
    } catch (e) { /* no fullscreen API */ }
    if (!this._tacticsBigKeys) {
      this._tacticsBigKeys = (e) => { if (e.key === 'Escape' && this._tacticsView.big && !this._plan.popupPid) this._setTacticsBig(false); };
      this._tacticsBigResize = () => this._fitTacticsBig();
      this._tacticsBigFs = () => { if (!document.fullscreenElement && this._tacticsView.big) this._setTacticsBig(false); };
      document.addEventListener('keydown', this._tacticsBigKeys);
      window.addEventListener('resize', this._tacticsBigResize);
      document.addEventListener('fullscreenchange', this._tacticsBigFs);
    }
    this._render();
  }

  // Big view: the pitch takes the screen height left under the controls
  // above it (keeping ~44 px for the Play / Save row under it), never less
  // than 260 px.
  _fitTacticsBig() {
    const box = document.querySelector('[data-gc-tactics-bigbox]');
    const host = box && box.querySelector('[data-gc-tactics-pitch]');
    if (!host) return;
    // Side by side (wide): the whole height.  Stacked: what is left under
    // the controls, keeping ~54 px for the Play / Save row.
    const side = getComputedStyle(host).gridColumnStart === '2';
    const top = host.getBoundingClientRect().top - box.getBoundingClientRect().top + box.scrollTop;
    box.style.setProperty('--tp-fit-h', `${Math.max(260, side ? box.clientHeight - 24 : box.clientHeight - top - 54)}px`);
    if (this._tacticsPitchObj) this._tacticsPitchObj.remeasure();
  }

  _mountTactics() {
    if (this._tacticsMode === 'drawn') this._mountTacticsDrawn();
    else this._mountPlan();
    if (this._tacticsView.big) this._fitTacticsBig();
  }

  // ── 🧠 Game model: jobs per ball position (mig 1121) ─────────────────
  // Owner 11/6: "we pick formation we play vs ... start with ball with
  // keeper and that triggers the drop down for each player ... what number
  // to cover shadow and what number to press from that cover shadow or to
  // hold between them ... smooth animation ... at a speed the user picks."
  // Our spots come from the backend: shared/tactics/TacticGeometry.hpp, the
  // ONE rule set the game engine builds too (owner 11/7: "always share where
  // we can").  Each state arrives solved; an edited one is solved by POST
  // /api/tactic-plans/solve.  No placement rule lives in this file.
  _planKey() {
    return [this._planUsId(), this._plan.oppFormationId, this._plan.moment, this._plan.block].join('|');
  }

  // The game's picked opponent shape (mig 912 matchup) when there is one,
  // else 4-3-3 — so a 2-3-2-3 matched to a 4-2-3-1 opens on that plan.
  _planDefaultOpp() {
    const m = (this.matchups || []).find(x => x.id === this.matchupId);
    const code = m && m.opponentCode ? m.opponentCode : '4-3-3';
    // A note's bare family ("3-5-2", "3-4-3") means its classic shape: the
    // first formation of that family in sort order (3-5-2 (3-2), 3-4-3 (2-3)).
    const fs = this.formations || [];
    const f = fs.find(x => x.code === code) || fs.find(x => String(x.code).startsWith(`${code} (`)) || fs.find(x => x.code === '4-3-3');
    return f ? Number(f.id) : 0;
  }

  async _loadPlan() {
    const p = this._plan;
    if (!p.oppFormationId) p.oppFormationId = this._planDefaultOpp();
    const key = this._planKey();
    if (!this._planUsId() || !p.oppFormationId) return;
    Object.assign(p, { key, loading: true, error: null, editing: false, draft: null, msg: '' });
    this._render();
    try {
      const q = new URLSearchParams({ formation_id: this._planUsId(), opponent_formation_id: p.oppFormationId, moment: p.moment, block: p.block });
      const res = await this.auth.fetch(`/api/tactic-plans?${q}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (p.key !== key) return;
      p.data = body;
      p.solved = new Map();
      for (const st of body.states || []) if (st.solved) p.solved.set(this._planSolveKey(st, this._planOpps(st)), st.solved);
      const states = body.states || [];
      if (!states.some(st => st.id === p.stateId)) p.stateId = states.length ? states[0].id : 0;
    } catch (err) {
      if (p.key === key) p.error = err.message;
    }
    if (p.key === key) { p.loading = false; this._render(); }
  }

  _planStates() { return (this._plan.data && this._plan.data.states) || []; }
  _planState(id) { return this._planStates().find(st => st.id === id) || null; }
  _planKinds() {
    const out = {};
    for (const k of (this._plan.data && this._plan.data.kinds) || []) out[k.code] = k;
    return out;
  }
  _planGkY() {
    const b = ((this._plan.data && this._plan.data.blocks) || []).find(x => x.code === this._plan.block);
    return b ? b.gk_y : null;
  }

  // Root → state, following parents.
  _planPath(id) {
    const path = [];
    let st = this._planState(id);
    while (st) { path.unshift(st); st = st.parent_state_id != null ? this._planState(st.parent_state_id) : null; }
    return path;
  }

  // Our side of the plan: the game's formation unless the coach picked
  // another (a step copied from a PL side lives under that side's shape).
  _planUsId() { return this._plan.usFormationId || this._formationId(); }

  _planStateLabel(st) {
    const c = st.copied_from;   // mig 1202: copied from the game's trainer
    if (c && this._copyTactics('copied_pill'))
      return this._copyTactics('copied_pill', { home: c.home || '', away: c.away || '', clock: c.clock || '', ball: st.ball_with });
    return Number(st.ball_with) === 1
      ? (this._copyTactics('ball_gk') || 'their GK')
      : (this._copyTactics('ball_with', { n: st.ball_with }) || `their ${st.ball_with}`);
  }

  // Theirs as stored, or their formation mirrored.
  _planOpps(st) {
    const base = (this._plan.data && this._plan.data.opponent_base) || [];
    return (st.opponents && st.opponents.length ? st.opponents : base)
      .map(o => ({ number: Number(o.number), x: Number(o.x), y: Number(o.y) }))
      .sort((a, b) => a.number - b.number);
  }

  // What a solution depends on — the cache key for the backend's answer.
  _planSolveKey(st, opps) {
    return JSON.stringify([Number(st.ball_with), st.restart || null, opps.map(o => [o.number, o.x, o.y]),
      (st.jobs || []).map(j => [Number(j.position_id), j.kind, (j.targets || []).map(Number), j.target_b == null ? null : Number(j.target_b),
                                j.partner_position_id == null ? null : Number(j.partner_position_id), j.stance || 'goal_side'])]);
  }

  // The backend's solution for this state; while an edited one is being
  // solved, the last one shown for it (then the answer glides in).
  _planSolution(st, opps) {
    const p = this._plan;
    if (!p.solved) p.solved = new Map();
    if (!p.lastSolved) p.lastSolved = new Map();
    const key = this._planSolveKey(st, opps);
    const hit = p.solved.get(key);
    if (hit) { p.lastSolved.set(st.id, hit); return hit; }
    if (!p.solving) p.solving = new Set();
    if (!p.solving.has(key)) {
      p.solving.add(key);
      const planKey = p.key;
      this._planFetch('/api/tactic-plans/solve', { method: 'POST', body: JSON.stringify({
        formation_id: this._planUsId(), block: p.block,
        state: { ball_with: Number(st.ball_with), restart: st.restart || null, opponents: opps, jobs: st.jobs || [] } }) })
        .then(sol => {
          if (p.key !== planKey) return;
          p.solved.set(key, sol);
          this._planGlideFrom = p.lastSit || null;
          this._render();
        })
        .catch(err => { if (p.key === planKey) { p.msg = err.message; this._render(); } })
        .finally(() => p.solving.delete(key));
    }
    const ours = (this._plan.data && this._plan.data.our_positions) || [];
    return p.lastSolved.get(st.id) || st.solved || {
      ball: { x: 50, y: 95 }, free: [], doubled: [],
      players: Array.from({ length: 11 }, (_, i) => ours.find(o => Number(o.position_id) === i + 1) || { position_id: i + 1, x: 50, y: 30 }),
    };
  }

  // The state as drawn: the backend's spots for ours, theirs as stored
  // (or their formation mirrored), the ball at the man who has it.
  _planSituation(st) {
    const opps = this._planOpps(st);
    const solved = this._planSolution(st, opps);
    // A step copied from a Premier League moment (mig 1202) shows ours where
    // the PL side's men actually stood — the copy IS the lesson; the jobs
    // underneath still say what each man was doing.
    const pl = st.copied_from && Array.isArray(st.copied_from.ours) && st.copied_from.ours.length ? st.copied_from.ours : null;
    if (pl) {
      const players = solved.players.map(q => {
        const m = pl.find(o => Number(o.position_id) === Number(q.position_id));
        return m ? { ...q, x: Number(m.x), y: Number(m.y) } : { ...q };
      });
      const b = st.copied_from.ball;
      return { ball: b ? { x: Number(b.x) + 1.2, y: Number(b.y) - 1.2 } : { x: solved.ball.x + 1.2, y: solved.ball.y - 1.2 }, players,
               opponents: opps.map(o => ({ ...o, label: o.number })), free: [], doubled: [], holdY: null };
    }
    return { ball: { x: solved.ball.x + 1.2, y: solved.ball.y - 1.2 }, players: solved.players.map(q => ({ ...q })),
             opponents: opps.map(o => ({ ...o, label: o.number })), free: solved.free || [], doubled: solved.doubled || [],
             holdY: this._planHoldY(st) };
  }

  // The line nobody of ours passes under this state's restart (goal kick:
  // their 18, tactic_restarts.our_max_y), or null when the ball is in play.
  _planHoldY(st) {
    const r = this._planRestart(st);
    const y = r && r.our_max_y != null ? Number(r.our_max_y) : null;
    return y != null && y < 100 ? y : null;
  }

  _lerp(a, b, t) { return { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t }; }

  // The restart law a state is played under (Law 16 goal kick), or null.
  _planRestart(st) {
    if (!st || !st.restart) return null;
    return ((this._plan.data && this._plan.data.restarts) || []).find(r => r.code === st.restart) || null;
  }

  _planJobText(job) {
    const k = job && this._planKinds()[job.kind];
    if (k && !k.target_a_label) return k.label;   // a 'home' job names nobody
    if (!k || !(job.targets || []).length) return '';
    const stance = job.stance && job.stance !== 'goal_side'
      ? (((this._plan.data && this._plan.data.stances) || []).find(x => x.code === job.stance) || {}).label : '';
    return `${k.target_a_label} ${job.targets.join(', ')}` + (k.target_b_label && job.target_b != null ? ` · ${k.target_b_label} ${job.target_b}` : '')
      + (k.partner_label && job.partner_position_id != null ? ` · ${k.partner_label} ${this._planOurNumber(job.partner_position_id)}` : '')
      + (stance ? ` · ${String(stance).toLowerCase()}` : '');
  }

  // Our slot's number as drawn (position id → formation sort order).
  _planOurNumber(pid) {
    const pos = this._slotMaps().startingPositions.find(p => p.id === Number(pid));
    return pos ? pos.sortOrder : pid;
  }

  _planJobComplete(j) {
    const k = this._planKinds()[j.kind];
    return (!k || !k.target_a_label || (j.targets || []).length > 0) && (!k || !k.partner_label || j.partner_position_id != null);
  }

  _planHtml() {
    const p = this._plan;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    if (!p.oppFormationId) p.oppFormationId = this._planDefaultOpp();
    if (this._planUsId() && p.oppFormationId && p.key !== this._planKey() && !p.loading) setTimeout(() => this._loadPlan(), 0);
    const data = p.data;
    const sel = (which, options, value) => `<select data-gc-tp-select="${which}" ${p.editing ? 'disabled' : ''}
        style="font-size:0.72rem; font-weight:700; padding:3px 6px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;">
        ${options.map(([v, label]) => `<option value="${esc(v)}" ${String(v) === String(value) ? 'selected' : ''}>${esc(label)}</option>`).join('')}</select>`;
    const controls = `<div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin-bottom:8px;">
        ${this._copyTactics('us_game') ? sel('us', [[0, this._copyTactics('us_game', { formation: this.formation || '' })]].concat((this.formations || []).filter(f => f.code !== this.formation).map(f => [f.id, f.code])), p.usFormationId || 0)
          : `<span style="font-size:0.74rem; font-weight:800;">${esc(this.formation)}</span>`}
        <span style="font-size:0.72rem; opacity:0.75;">${esc(this._copyTactics('vs') || 'vs')}</span>
        ${sel('opp', (this.formations || []).map(f => [f.id, f.code]), p.oppFormationId)}
        ${data ? sel('moment', (data.moments || []).map(m => [m.code, m.title]), p.moment) : ''}
        ${data ? sel('block', (data.blocks || []).map(b => [b.code, b.label]), p.block) : ''}
      </div>`;
    if (p.error) return controls + `<div style="font-size:0.75rem; color:#f87171;">⚠ ${esc(p.error)}</div>`;
    if (!data || p.loading) return controls + '<div style="font-size:0.75rem; opacity:0.7;">Loading…</div>';
    if (!data.plan) {
      const m = (data.moments || []).find(x => x.code === p.moment), b = (data.blocks || []).find(x => x.code === p.block);
      const them = (this.formations || []).find(f => Number(f.id) === Number(p.oppFormationId));
      return controls + `<div style="font-size:0.78rem; opacity:0.8; margin-bottom:8px;">${esc(this._copyTactics('no_plan', { us: this.formation, them: them ? them.code : '', moment: m ? m.title : p.moment, block: b ? b.label : p.block }))}</div>`
        + (this._tacticsCanEdit() ? `<button type="button" data-gc-tp-create class="btn btn-primary" style="font-size:0.74rem; padding:4px 12px;">${esc(this._copyTactics('create') || '➕ Start this plan')}</button>` : '')
        + (p.msg ? `<div style="font-size:0.74rem; font-weight:700; margin-top:6px; color:#f87171;">${esc(p.msg)}</div>` : '');
    }
    const cur = this._planState(p.stateId) || this._planStates()[0];
    if (!cur) return controls;
    const shown = p.editing && p.draft ? p.draft : cur;
    const path = this._planPath(cur.id);
    const kids = this._planStates().filter(st => st.parent_state_id === cur.id);
    const pill = (st, active) => `<button type="button" data-gc-tp-state="${st.id}" class="btn btn-sm ${active ? 'btn-primary' : 'btn-secondary'}" ${p.editing ? 'disabled' : ''}
        style="font-size:0.72rem; padding:3px 9px; white-space:nowrap;">⚽ ${esc(this._planStateLabel(st))}</button>`;
    const pathHtml = path.map(st => pill(st, st.id === cur.id)).join('<span style="opacity:0.6;">→</span>');
    const nextHtml = kids.length ? `<span style="font-size:0.7rem; opacity:0.75; margin-left:6px;">${esc(this._copyTactics('next') || 'Next:')}</span>${kids.map(st => pill(st, false)).join('')}` : '';
    // ⚽ Pass to: their 2–11 (not the man on the ball).  Green = already
    // drawn (opens it); grey = a new pass for a coach (copies these jobs).
    const passTo = Array.from({ length: 10 }, (_, i) => i + 2).filter(n => n !== Number(cur.ball_with)).map(n => {
      const kid = kids.find(st => Number(st.ball_with) === n && !st.copied_from);
      if (!kid && !this._tacticsCanEdit()) return '';
      return `<button type="button" data-gc-tp-pass="${n}" ${p.editing || p.playing ? 'disabled' : ''} title="${esc(kid ? '' : this._copyTactics('pass_to_new'))}"
        style="font-size:0.72rem; min-width:28px; padding:2px 6px; border-radius:999px; cursor:pointer; font-weight:800; color:#fff;
        border:1px solid ${kid ? '#16a34a' : '#dc2626'}; background:${kid ? '#16a34a' : 'transparent'};">${n}</button>`;
    }).join('');
    const passHtml = passTo ? `<div style="display:flex; gap:4px; align-items:center; flex-wrap:wrap; margin-bottom:6px;">
        <span style="font-size:0.72rem; font-weight:800;">${esc(this._copyTactics('pass_to') || '⚽ Pass to:')}</span>${passTo}</div>` : '';
    const cov = this._planSituation(shown);
    const covHtml = [cov.free.length ? esc(this._copyTactics('free', { list: cov.free.join(', ') })) : '',
                     cov.doubled.length ? esc(this._copyTactics('double', { list: cov.doubled.join(', ') })) : '']
      .filter(Boolean).join(' · ') || esc(this._copyTactics('all_on'));
    const canEdit = this._tacticsCanEdit();
    const speeds = [0.25, 0.5, 1, 1.5, 2].map(v => [v, `${v}×`]);
    const tools = `<div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:8px;">
        <button type="button" data-gc-tp-play class="btn ${p.playing ? 'btn-primary' : 'btn-secondary'}" ${p.editing ? 'disabled' : ''} style="font-size:0.72rem; padding:3px 10px;">${esc(p.playing ? (this._copyTactics('stop') || '■ Stop') : (this._copyTactics('play') || '▶ Play'))}</button>
        <span style="font-size:0.7rem; opacity:0.75;">${esc(this._copyTactics('speed') || 'Speed')}</span> ${sel('speed', speeds, p.speed)}
        ${!canEdit ? '' : p.editing
          ? `<button type="button" data-gc-tp-save class="btn btn-primary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('save') || '💾 Save')}</button>
             <button type="button" data-gc-tp-cancel class="btn btn-secondary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('cancel') || 'Cancel')}</button>
             <span style="font-size:0.7rem; opacity:0.8;">${esc(this._copyTactics('editing'))}</span>`
          : `<button type="button" data-gc-tp-edit class="btn btn-secondary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('edit') || '✏️ Move pieces')}</button>
             ${cur.parent_state_id != null ? `<button type="button" data-gc-tp-delete class="btn btn-secondary" style="font-size:0.72rem; padding:3px 10px;">${esc(this._copyTactics('delete') || '🗑 Remove this pass')}</button>` : ''}`}
        ${p.msg ? `<span style="font-size:0.72rem; font-weight:700;">${esc(p.msg)}</span>` : ''}
      </div>`;
    return controls
      + `<div style="display:flex; gap:4px; align-items:center; flex-wrap:wrap; margin-bottom:6px;">${pathHtml}${nextHtml}</div>` + passHtml
      + (!p.editing ? `<div style="font-size:0.7rem; opacity:0.75; margin-bottom:4px;">${esc(this._copyTactics(canEdit ? 'pass_hint' : 'player_hint'))}</div>` : '')
      + `<div style="font-size:0.72rem; font-weight:700; margin-bottom:6px; color:${cov.free.length || cov.doubled.length ? '#fbbf24' : '#4ade80'};">${covHtml}</div>`
      + (cur.copied_from && this._copyTactics('copied_note') ? `<div style="font-size:0.7rem; opacity:0.85; margin-bottom:6px;">📋 ${esc(this._copyTactics('copied_note', { home: cur.copied_from.home || '', away: cur.copied_from.away || '', clock: cur.copied_from.clock || '' }))}</div>` : '')
      + (this._planRestart(shown) ? `<div style="font-size:0.7rem; opacity:0.85; margin-bottom:6px;" title="${esc(this._planRestart(shown).law)}">${esc(this._copyTactics('restart', { label: this._planRestart(shown).label }))}</div>` : '')
      + `<div data-gc-tactics-pitch></div>` + tools + this._planJobsHtml(shown) + this._planPopupHtml(shown);
  }

  // One row per our outfield slot, in formation order: who, and his job —
  // dropdowns for coaches always (owner 11/6: "i need to be able to set
  // tactics via drop down when keeper has it ... this is the initial
  // instructions when keeper places ball down"; each change saves),
  // words for players.
  // His job: dropdowns (job, their numbers) for a coach, words otherwise.
  // Shared by the list under the pitch and the tap-a-player sheet.
  _planJobControls(pid, job, size = '0.7rem') {
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const kinds = (this._plan.data && this._plan.data.kinds) || [];
    const kind = job ? kinds.find(k => k.code === job.kind) : null;
    const their = (n) => this._copyTactics('their', { n }) || `their ${n}`;
    const css = `font-size:${size}; padding:2px 4px; border-radius:4px; border:1px solid #475569; background:#0f172a; color:#fff;`;
    const numSel = (field, value) => `<select data-gc-tp-job="${pid}" data-gc-tp-field="${field}" style="${css}${field === 'target_a' && value == null ? ' border-color:#f59e0b; box-shadow:0 0 0 2px rgba(245,158,11,0.45);' : ''}">
        ${field === 'target_b' ? '<option value="">—</option>' : ''}
        ${field === 'target_a' && value == null ? `<option value="" selected>${esc(this._copyTactics('who') || '— who? —')}</option>` : ''}
        ${Array.from({ length: 11 }, (_, i) => i + 1).map(n => `<option value="${n}" ${Number(value) === n ? 'selected' : ''}>${esc(their(n))}</option>`).join('')}</select>`;
    const targets = job ? (job.targets || []) : [];
    // Their men: tap-to-toggle chips for a job on several (deter 5 and 3),
    // one dropdown otherwise.
    const whoHtml = !job || (kind && !kind.target_a_label) ? '' : kind && kind.multi_a
      ? `<span style="font-size:${size}; opacity:0.75;">${esc(kind.target_a_label)}</span>
         <span style="display:inline-flex; gap:3px; flex-wrap:wrap;${targets.length ? '' : ' outline:2px solid rgba(245,158,11,0.6); border-radius:6px; padding:2px;'}">
           ${Array.from({ length: 11 }, (_, i) => i + 1).map(n => { const on = targets.includes(n);
             return `<button type="button" data-gc-tp-tgt="${pid}" data-n="${n}" style="font-size:${size}; min-width:24px; padding:1px 5px; border-radius:999px; cursor:pointer;
               border:1px solid ${on ? '#dc2626' : '#475569'}; background:${on ? '#dc2626' : 'transparent'}; color:#fff; font-weight:${on ? 800 : 500};">${n}</button>`; }).join('')}
         </span>${targets.length ? '' : `<span style="font-size:${size}; opacity:0.75;">${esc(this._copyTactics('multi_hint'))}</span>`}`
      : `<span style="font-size:${size}; opacity:0.75;">${esc(kind ? kind.target_a_label : '')}</span> ${numSel('target_a', targets.length ? targets[0] : null)}`;
    const stances = (this._plan.data && this._plan.data.stances) || [];
    const stanceHtml = job && job.kind === 'mark' && stances.length
      ? `<span style="font-size:${size}; opacity:0.75;">${esc(this._copyTactics('stance') || 'stance')}</span>
         <select data-gc-tp-job="${pid}" data-gc-tp-field="stance" style="${css}">${stances.map(x => `<option value="${esc(x.code)}" ${(job.stance || 'goal_side') === x.code ? 'selected' : ''}>${esc(x.label)}</option>`).join('')}</select>` : '';
    if (this._tacticsCanEdit() && !this._plan.playing) {
      return `<select data-gc-tp-job="${pid}" data-gc-tp-field="kind" style="${css}">
          <option value="">${esc(this._copyTactics('no_job') || '— no job —')}</option>
          ${this._planKindOptions(job)}</select>
        ${job && kind ? this._planShortcutStar(job.kind, size) : ''}
        ${whoHtml}
        ${job && kind && kind.target_b_label ? `<span style="font-size:${size}; opacity:0.75;">${esc(kind.target_b_label)}</span> ${numSel('target_b', job.target_b)}` : ''}
        ${job && kind && kind.partner_label ? `<span style="font-size:${size}; opacity:0.75;">${esc(kind.partner_label)}</span> ${this._planPartnerSel(pid, job.partner_position_id, css)}` : ''}
        ${stanceHtml}`;
    }
    return job && kind ? `<span style="font-weight:700;">${esc(kind.label)}</span> <span style="opacity:0.85;">${esc(this._planJobText(job))}</span>`
      : `<span style="opacity:0.6;">${esc(this._copyTactics('no_job') || '— no job —')}</span>`;
  }

  // Every game concept of the plan's moment (mig 1153), grouped Individual
  // / Group / Team (owner 11/6: "all 'game' tactics in the 'tactic' drop
  // down for that phase").  A job from another moment stays listed so it
  // still shows.
  _planKindOptions(job) {
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const kinds = (this._plan.data && this._plan.data.kinds) || [];
    const shown = kinds.filter(k => !k.moment || k.moment === this._plan.moment || (job && job.kind === k.code));
    // ⭐ Shortcuts first (mig 1177): every job we use, plus what a coach
    // added; each kind is listed once, so they leave their family group.
    const starred = new Set(this._planShortcuts());
    const opt = (k) => `<option value="${esc(k.code)}" ${job && job.kind === k.code ? 'selected' : ''}>${esc(k.label)}</option>`;
    const top = shown.filter(k => starred.has(k.code));
    return (top.length ? `<optgroup label="${esc(this._copyTactics('fam_shortcuts') || '⭐ Shortcuts')}">${top.map(opt).join('')}</optgroup>` : '')
      + ['individual', 'group', 'team'].map(fam => {
      const list = shown.filter(k => (k.family || 'individual') === fam && !starred.has(k.code));
      if (!list.length) return '';
      return `<optgroup label="${esc(this._copyTactics('fam_' + fam) || fam)}">${list.map(k =>
        `<option value="${esc(k.code)}" ${job && job.kind === k.code ? 'selected' : ''}>${esc(k.label)}</option>`).join('')}</optgroup>`;
    }).join('');
  }

  _planShortcuts() { return (this._plan.data && this._plan.data.shortcuts) || []; }

  // ★ = on ⭐ Shortcuts (tap takes it off), ☆ = not (tap adds it).
  _planShortcutStar(code, size) {
    const on = this._planShortcuts().includes(code);
    const tip = this.escapeHtml(this._copyTactics(on ? 'shortcut_remove' : 'shortcut_add') || (on ? 'Take this job off ⭐ Shortcuts' : 'Add this job to ⭐ Shortcuts'));
    return `<button type="button" data-gc-tp-shortcut="${this.escapeHtml(code)}" data-on="${on ? 1 : 0}" title="${tip}" aria-label="${tip}"
      style="font-size:${size}; line-height:1; padding:2px 5px; min-height:0; min-width:0; height:auto; width:auto; border-radius:4px; cursor:pointer; border:1px solid ${on ? '#ca8a04' : '#475569'};
      background:${on ? 'rgba(202,138,4,0.18)' : 'transparent'}; color:${on ? '#facc15' : '#94a3b8'};">${on ? '★' : '☆'}</button>`;
  }

  async _togglePlanShortcut(code, on) {
    const p = this._plan;
    if (!p.data) return;
    const before = this._planShortcuts();
    p.data.shortcuts = on ? [...new Set([...before, code])] : before.filter(c => c !== code);   // show it now
    this._render();
    try {
      const body = await this._planFetch('/api/tactic-plans/shortcuts', { method: 'POST', body: JSON.stringify({ kind: code, on }) });
      if (Array.isArray(body.shortcuts)) p.data.shortcuts = body.shortcuts;
    } catch (err) {
      p.data.shortcuts = before;
      p.msg = `⚠ ${err.message}`;
    }
    this._render();
  }

  // "with?" — one of ours for a partnered job (straddle): every outfield
  // slot but his own, by number and the day's name.
  _planPartnerSel(pid, value, css) {
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    const opts = startingPositions.filter(pos => pos.id !== 1 && pos.id !== pid).map(pos => {
      const occ = rosterById.get(slotToPlayerId.get(pos.id));
      return `<option value="${pos.id}" ${Number(value) === pos.id ? 'selected' : ''}>#${esc(pos.sortOrder)}${occ ? ' ' + esc(occ.name) : ''}</option>`;
    }).join('');
    const pending = value == null;
    return `<select data-gc-tp-job="${pid}" data-gc-tp-field="partner_position_id" style="${css}${pending ? ' border-color:#f59e0b; box-shadow:0 0 0 2px rgba(245,158,11,0.45);' : ''}">
        ${pending ? `<option value="" selected>${esc(this._copyTactics('with_who') || '— with? —')}</option>` : ''}${opts}</select>`;
  }

  // Tap a player on the pitch: his sheet — who, the situation, his job,
  // and the concept's coaching cue (game_concepts.cue_answer) — the same
  // words the game's AI plays from (owner 11/6: "players can read this and
  // understand their roles right along with the ai").
  _planPopupHtml(st) {
    const p = this._plan;
    const pid = p.popupPid;
    if (!pid || pid === 1) return '';
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const chip = this._tacticsChipFor()(pid);
    const job = (st.jobs || []).find(j => Number(j.position_id) === pid);
    const kind = job ? ((p.data && p.data.kinds) || []).find(k => k.code === job.kind) : null;
    return `<div data-gc-tp-popup-bg style="position:fixed; inset:0; z-index:1000; background:rgba(0,0,0,0.55); display:flex; align-items:center; justify-content:center; padding:16px;">
      <div style="width:100%; max-width:420px; background:var(--card-bg, #0f172a); color:inherit; border:1px solid var(--border-color); border-radius:12px; padding:14px; box-shadow:0 10px 30px rgba(0,0,0,0.5);">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
          <span style="display:inline-block; min-width:28px; text-align:center; font-weight:800; color:#facc15; background:#1d4ed8; border-radius:999px; padding:2px 6px;">${esc(chip.number)}</span>
          <span style="font-weight:800; font-size:1rem; flex:1;">${esc(chip.name || '—')}</span>
          <button type="button" data-gc-tp-popup-x class="btn btn-secondary" style="font-size:0.8rem; padding:2px 10px;">✕</button>
        </div>
        <div style="font-size:0.74rem; opacity:0.75; margin-bottom:10px;">⚽ ${esc(this._planStateLabel(st))}</div>
        <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; font-size:0.85rem; margin-bottom:10px;">${this._planJobControls(pid, job, '0.85rem')}</div>
        ${kind ? `<div style="font-size:0.78rem; font-weight:800; margin-bottom:2px;">${esc(kind.concept_title || '')}</div>
                  <div style="font-size:0.78rem; line-height:1.4; opacity:0.9;">${esc(kind.cue || '')}</div>` : ''}
      </div></div>`;
  }

  _planJobsHtml(st) {
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const { rosterById, slotToPlayerId, startingPositions } = this._slotMaps();
    const jobs = new Map((st.jobs || []).map(j => [Number(j.position_id), j]));
    const rows = startingPositions.filter(pos => pos.id !== 1).map(pos => {
      const occ = rosterById.get(slotToPlayerId.get(pos.id));
      const what = this._planJobControls(pos.id, jobs.get(pos.id));
      return `<div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; padding:4px 0; border-top:1px solid var(--border-color); font-size:0.74rem;">
          <span style="display:inline-block; min-width:22px; text-align:center; font-weight:800; color:#facc15; background:#1d4ed8; border-radius:999px; padding:1px 4px;">${esc(pos.sortOrder)}</span>
          <span style="min-width:90px; font-weight:700;">${esc(occ ? occ.name : '—')}</span>${what}</div>`;
    }).join('');
    return `<div style="margin-top:10px;">${rows}</div>`;
  }

  _mountPlan() {
    const el = document.querySelector('[data-gc-tactics-pitch]');
    const p = this._plan;
    if (!el || !window.TacticsPitch || !p.data || !p.data.plan) return;
    const cur = this._planState(p.stateId) || this._planStates()[0];
    if (!cur) return;
    const shown = p.editing && p.draft ? p.draft : cur;
    const sit = this._planSituation(shown);
    p.lastSit = { ball: { ...sit.ball }, players: sit.players.map(q => ({ ...q })), opponents: sit.opponents.map(q => ({ ...q })) };
    const chip = this._tacticsChipFor();
    const jobs = new Map((shown.jobs || []).map(j => [Number(j.position_id), j]));
    const canEdit = this._tacticsCanEdit();
    this._tacticsPitchObj = new TacticsPitch({
      situation: sit,
      chipFor: (pid) => ({ ...chip(pid), job: this._planJobText(jobs.get(pid)) }),
      editable: p.editing,
      dragKinds: ['opp'],
      ...this._tacticsPitchView(),
      // Dragging theirs edits the draft (the pitch moved the copy in sit).
      onChange: () => {
        if (!p.draft) return;
        p.draft.opponents = sit.opponents.map(o => ({ number: o.number, x: o.x, y: o.y }));
        this._mountPlan();
      },
      // Tap one of theirs = the ball goes to him: open that pass (anyone, if
      // drawn) or draw it (coaches).
      onPieceClick: (kind, idx) => {
        if (p.playing) return;
        if (kind === 'us') {
          const pid = sit.players[idx] && sit.players[idx].position_id;
          if (pid && pid !== 1) { p.popupPid = pid; this._render(); }
          return;
        }
        if (kind !== 'opp') return;
        const n = sit.opponents[idx] && sit.opponents[idx].number;
        if (!n || n === Number(cur.ball_with)) return;
        const kid = this._planStates().find(st => st.parent_state_id === cur.id && Number(st.ball_with) === n);
        if (kid) { p.stateId = kid.id; p.msg = ''; this._render(); return; }
        if (canEdit) this._addPlanState(cur.id, n);
      },
    });
    this._tacticsPitchObj.mount(el);
    const from = this._planGlideFrom;
    this._planGlideFrom = null;
    if (from && from.players.length === sit.players.length && !p.playing) {
      const pitch = this._tacticsPitchObj, to = sit, t0 = performance.now(), ms = 450;
      const frame = (now) => {
        if (this._tacticsPitchObj !== pitch) return;
        const t = Math.min(1, (now - t0) / ms), e = t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
        const mix = (xs, ys) => ys.map((y, k) => ({ ...y, ...this._lerp(xs[k] || y, y, e) }));
        pitch.update({ ball: this._lerp(from.ball, to.ball, e), players: mix(from.players, to.players), opponents: mix(from.opponents, to.opponents) });
        if (t < 1) requestAnimationFrame(frame);
      };
      pitch.update(from);
      requestAnimationFrame(frame);
    }
  }

  async _planFetch(url, opts) {
    const res = await this.auth.fetch(url, { headers: { 'Content-Type': 'application/json' }, ...opts });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _reloadPlanTo(stateId) {
    this._plan.key = '';
    await this._loadPlan();
    if (stateId) { this._plan.stateId = stateId; this._render(); }
  }

  async _createPlan() {
    const p = this._plan;
    try {
      await this._planFetch('/api/tactic-plans', { method: 'POST', body: JSON.stringify({ formation_id: this._planUsId(), opponent_formation_id: p.oppFormationId, moment: p.moment, block: p.block }) });
      await this._reloadPlanTo(0);
    } catch (err) { p.msg = `⚠ ${err.message}`; this._render(); }
  }

  async _addPlanState(parentId, ballWith) {
    try {
      const body = await this._planFetch('/api/tactic-plans/states', { method: 'POST', body: JSON.stringify({ parent_state_id: parentId, ball_with: ballWith }) });
      await this._reloadPlanTo(body.id);
    } catch (err) { this._plan.msg = `⚠ ${err.message}`; this._render(); }
  }

  async _deletePlanState() {
    const cur = this._planState(this._plan.stateId);
    if (!cur || cur.parent_state_id == null) return;
    try {
      await this._planFetch(`/api/tactic-plans/states/${cur.id}`, { method: 'DELETE' });
      await this._reloadPlanTo(cur.parent_state_id);
    } catch (err) { this._plan.msg = `⚠ ${err.message}`; this._render(); }
  }

  _startPlanEdit() {
    const cur = this._planState(this._plan.stateId);
    if (!cur) return;
    const draft = JSON.parse(JSON.stringify(cur));
    if (!draft.opponents || !draft.opponents.length) draft.opponents = this._planSituation(cur).opponents.map(o => ({ number: o.number, x: o.x, y: o.y }));
    Object.assign(this._plan, { draft, editing: true, msg: '' });
    this._render();
  }

  // A job dropdown changed.  While dragging theirs (✏️) it edits the
  // draft; otherwise it saves that state straight away.
  _editPlanJob(pid, field, value) {
    const p = this._plan;
    const live = !p.editing;
    const cur = this._planState(p.stateId);
    const d = live ? (cur ? JSON.parse(JSON.stringify(cur)) : null) : p.draft;
    if (!d) return;
    // Where everyone stood before this instruction — _mountPlan glides
    // them from here to their new spots (owner 11/6: "after i tell a player
    // what to do it should reflect right away").
    this._planGlideFrom = this._planSituation(live ? cur : p.draft);
    if (live && (!d.opponents || !d.opponents.length)) d.opponents = this._planSituation(cur).opponents.map(o => ({ number: o.number, x: o.x, y: o.y }));
    this._applyPlanJob(d, pid, field, value);
    const mine = (d.jobs || []).find(j => Number(j.position_id) === pid);
    if (mine && !this._planJobComplete(mine)) p.popupPid = pid;   // prompt: who? / with?
    if (!live) { this._render(); return; }
    const list = this._planStates();
    const i = list.findIndex(st => st.id === d.id);
    if (i >= 0) list[i] = d;
    p.msg = '';
    this._render();
    this._putPlanState(d).then((body) => { if (body && Array.isArray(body.shortcuts) && p.data) p.data.shortcuts = body.shortcuts; p.msg = mine && !this._planJobComplete(mine) ? '' : (this._copyTactics('saved') || 'Saved ✓'); this._render(); })
      .catch(err => { p.msg = `⚠ ${err.message}`; this._reloadPlanTo(d.id); });
  }

  // Jobs still waiting for their man stay on screen but aren't sent.
  _putPlanState(d) {
    return this._planFetch(`/api/tactic-plans/states/${d.id}`, { method: 'PUT', body: JSON.stringify({
      opponents: (d.opponents || []).map(o => ({ number: Number(o.number), x: Number(o.x), y: Number(o.y) })),
      jobs: (d.jobs || []).filter(j => this._planJobComplete(j)).map(j => ({ position_id: Number(j.position_id), kind: j.kind, targets: (j.targets || []).map(Number),
        target_b: j.target_b == null ? null : Number(j.target_b), partner_position_id: j.partner_position_id == null ? null : Number(j.partner_position_id),
        stance: j.stance || 'goal_side' })),
    }) });
  }

  _applyPlanJob(d, pid, field, value) {
    d.jobs = d.jobs || [];
    let job = d.jobs.find(j => Number(j.position_id) === pid);
    // Partnered jobs (straddle) live in pairs: dropping one drops its mate.
    const dropMate = (j) => {
      if (!j || j.partner_position_id == null) return;
      const mate = Number(j.partner_position_id);
      d.jobs = d.jobs.filter(x => !(Number(x.position_id) === mate && Number(x.partner_position_id) === Number(j.position_id)));
    };
    if (field === 'partner_position_id') {
      if (!job) return;
      const q = value === '' ? null : Number(value);
      dropMate(job);
      job.partner_position_id = q;
      if (q != null) {
        // Owner 11/6: "it asks who the 7 will straddle with (11) and then it
        // updates 11 too" — the partner takes the mirrored job, leaving any
        // pair he was in.
        const old = d.jobs.find(x => Number(x.position_id) === q);
        if (old) { dropMate(old); d.jobs = d.jobs.filter(x => Number(x.position_id) !== q); }
        d.jobs.push({ position_id: q, kind: job.kind, targets: [...(job.targets || [])], target_b: null, partner_position_id: pid, stance: 'goal_side' });
      }
      return;
    }
    if ((field === 'target_a' || field === 'toggle') && job) {
      // One man (dropdown) or toggle one in/out of the set (chips).
      if (field === 'target_a') job.targets = value === '' ? [] : [Number(value)];
      else {
        const n = Number(value);
        job.targets = (job.targets || []).includes(n) ? job.targets.filter(x => x !== n) : [...(job.targets || []), n];
      }
      if (job.partner_position_id != null) {
        const mate = d.jobs.find(x => Number(x.position_id) === Number(job.partner_position_id));
        if (mate) mate.targets = [...job.targets];
      }
      return;
    }
    if (field === 'stance' && job) { job.stance = value || 'goal_side'; return; }
    if (field === 'kind') {
      if (job && job.kind !== value) { dropMate(job); job.partner_position_id = null; }
      if (!value) { d.jobs = d.jobs.filter(j => Number(j.position_id) !== pid); return; }
      const kind = this._planKinds()[value];
      // A new or changed job asks for its man first (owner 11/6: "if i pick
      // cover shadow it should then prompt for who to cover shadow AND it's
      // assumed that is from the current ball carrier") — the shadow line
      // always runs from whoever has the ball, so only the man is asked.
      if (!job) { job = { position_id: pid, kind: value, targets: [], target_b: null, partner_position_id: null, stance: 'goal_side' }; d.jobs.push(job); }
      else if (job.kind !== value) { job.targets = []; job.target_b = null; job.stance = 'goal_side'; }
      job.kind = value;
      if (!kind || !kind.target_b_label) job.target_b = null;
    } else if (job) {
      job[field] = value === '' ? null : Number(value);
    }
  }

  async _savePlanState() {
    const p = this._plan;
    const d = p.draft;
    if (!d) return;
    try {
      await this._putPlanState(d);
      p.editing = false; p.draft = null;
      await this._reloadPlanTo(d.id);
      p.msg = this._copyTactics('saved') || 'Saved ✓';
      this._render();
    } catch (err) { p.msg = `⚠ ${err.message}`; this._render(); }
  }

  // ▶ Play: the passes from their GK to the state on screen (or, from the
  // GK, down the first drawn line), each a smooth move of every piece.
  _playPlan() {
    const p = this._plan;
    let path = this._planPath(p.stateId);
    if (path.length === 1) {
      let st = path[0];
      for (;;) { const kid = this._planStates().find(x => x.parent_state_id === st.id); if (!kid) break; path.push(kid); st = kid; }
    }
    if (path.length < 2 || !this._tacticsPitchObj) return;
    const frames = path.map(st => this._planSituation(st));
    p.playing = true;
    p.stateId = path[0].id;
    this._render();
    const ease = (t) => t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
    let i = 0, t0 = null;
    const stepMs = () => 1400 / (p.speed || 1), holdMs = () => 500 / (p.speed || 1);
    const tick = (now) => {
      if (!p.playing || !this._tacticsPitchObj) return;
      if (t0 == null) t0 = now;
      const el = now - t0;
      const a = frames[i], b = frames[i + 1];
      const t = ease(Math.min(1, el / stepMs()));
      const mix = (xs, ys) => xs.map((x, k) => ({ ...x, ...this._lerp(x, ys[k] || x, t) }));
      this._tacticsPitchObj.update({ ball: this._lerp(a.ball, b.ball, t), players: mix(a.players, b.players), opponents: mix(a.opponents, b.opponents) });
      if (el >= stepMs() + holdMs()) {
        i += 1; t0 = now;
        if (i >= frames.length - 1) { p.playing = false; p.stateId = path[path.length - 1].id; this._render(); return; }
      }
      this._planRaf = requestAnimationFrame(tick);
    };
    this._planRaf = requestAnimationFrame(tick);
  }

  _stopPlanPlay() {
    if (this._planRaf) cancelAnimationFrame(this._planRaf);
    this._planRaf = null;
    if (this._plan.playing) { this._plan.playing = false; this._render(); }
  }

  _mountTacticsDrawn() {
    const el = document.querySelector('[data-gc-tactics-pitch]');
    if (!el || !window.TacticsPitch) return;
    const t = this._tactics;
    const list = this._tacticsSituations();
    const sit = t.editing && t.draft ? t.draft : list[Math.min(t.idx, list.length - 1)];
    if (!sit) return;
    this._tacticsPitchObj = new TacticsPitch({ situation: sit, chipFor: this._tacticsChipFor(), editable: t.editing, ...this._tacticsPitchView() });
    this._tacticsPitchObj.mount(el);
  }
}

Mixin.into(GameCenterScreen, GameCenterTactics);
