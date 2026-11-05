// MatchPlanPanel — the 🎯 Match plan section of #game-center (mig 966).
//
// Owner 2026-11-03: "we need a game warmup section … also part of corner
// tactics and free kick assignments … it can go through everything from
// warmups to tactics" — then the order of the day: a checklist to get to
// the game, arrival, dress, the FIFA 11+ (no ball), a few minutes for
// water, the 4v4+3 (ball), ref check-in, together again, walk out, the
// captain's huddle, kickoff.
//
// Three parts, top to bottom:
//   🕐 Match day   match_day_stages in order.  Each stage: its time (arrival
//                  / warm-up / kickoff from the event), minutes, who leads
//                  it (the holders of its job, migs 625/960+), its how-to.
//                  The first stage is a checklist each viewer ticks for
//                  themselves.  A routine lists its sections and steps
//                  (FIFA 11+ at the routine's level); a drill with sides
//                  (4v4+3) fills each side from the lineup — shirt number
//                  = the starting position's number — plus the first
//                  bench players for bench_extras (the coach's bench order
//                  = the next best not starting), each side with its bibs.
//   🚩 Set pieces  set_piece_roles per group; coaches pick a POSITION (a
//                  shirt number 1–11, or ball-side / weak-side winger or
//                  fullback — mig 1107) or a person from the squad.  A
//                  position resolves to whoever starts there in this
//                  lineup; a side-relative one uses the role's ball_side
//                  (corner takers) or shows both sides.  Everyone else
//                  reads, a player sees their own line on top.  No picks
//                  yet → the team's last game's, flagged.
//   ♟️ Tactics     the formation and opponent match-up from the lineup,
//                  then the coach's notes.
//
// All wording is the DB's (MessageCopy kind 'match_plan').
//
// Host contract: new MatchPlanPanel(auth, {
//   fhEventId: () => id|null, rerender: () => void, toast: (msg) => void,
//   escapeHtml: (t) => string,
//   squad: () => ({ byNumber: Map<no, {id, name}>, bench: [{id, name}],   // bench in the coach's order
//                   others: [{id, name}], formation: string, matchup: string,
//                   viewerPersonId: id|null, coachView: bool }) }).
// The host routes clicks on [data-mp-*] to click(el), 'change'/'input' on
// them to input(el), and 'toggle' on [data-mp-fold] to toggle(el).
class MatchPlanPanel {
  constructor(auth, host) {
    this.auth = auth;
    this.host = host;
    this.data = null;          // GET /api/match-plan/:id
    this.picks = new Map();    // "roleId:slot" -> "p:<personId>" | "r:<positionRefId>" (the coach's working copy)
    this.tactics = '';
    this.dirty = false;
    this.busy = false;
    this.open = new Set(['plan']);
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('match_plan', tier, tokens) : ''; }
  _esc(t) { return this.host.escapeHtml(t == null ? '' : String(t)); }

  async load() {
    this.data = null;
    const id = this.host.fhEventId();
    if (!id) return;
    try {
      const res = await this.auth.fetch(`/api/match-plan/${id}`);
      if (!res.ok) return;   // 403 = not on this game: no panel
      const body = await res.json();
      if (!body.success || this.host.fhEventId() !== id) return;
      this._take(body);
    } catch (err) { console.warn('[match-plan] unavailable:', err.message); }
  }

  _take(body) {
    this.data = body;
    this.picks = new Map();
    for (const g of body.setPieces?.groups || [])
      for (const r of g.roles) for (const p of r.picks)
        this.picks.set(`${r.id}:${p.slot}`, p.positionRefId ? `r:${p.positionRefId}` : `p:${p.personId}`);
    this.tactics = body.tactics || '';
    this.dirty = false;
  }

  _editing() { return !!(this.data && this.data.canEdit && this.host.squad().coachView); }

  _fold(key, summaryHtml, bodyHtml, style = '') {
    return `<details data-mp-fold="${this._esc(key)}" ${this.open.has(key) ? 'open' : ''} style="${style}">
      <summary style="cursor:pointer; list-style:revert;">${summaryHtml}</summary>${bodyHtml}</details>`;
  }

  html() {
    const d = this.data;
    if (!d || !this._copy('title')) return '';
    const body = `
      <div style="font-size:0.7rem; opacity:0.75; line-height:1.4; margin:4px 0 8px;">${this._esc(this._copy('hint'))}</div>
      ${this._stagesHtml()}
      ${this._setPiecesHtml()}
      ${this._tacticsHtml()}
      ${this._editing() ? `
        <div style="display:flex; justify-content:flex-end; margin-top:10px;">
          <button type="button" class="btn btn-primary" data-mp-save ${this.busy ? 'disabled' : ''}
                  style="padding:5px 12px; font-size:0.75rem;">${this._esc(this._copy('save'))}${this.dirty ? ' •' : ''}</button>
        </div>` : ''}`;
    return `<div style="margin-top:10px; border:1px solid var(--border-color); border-radius:12px; padding:10px 12px;">
      ${this._fold('plan', `<span style="font-size:0.8rem; font-weight:800;">${this._esc(this._copy('title'))}</span>`, body)}
    </div>`;
  }

  // ── 🕐 Match day ────────────────────────────────────────────────────
  _stagesHtml() {
    const stages = this.data.stages || [];
    if (!stages.length) return '';
    const rows = stages.map((s, i) => {
      const meta = [s.time, s.minutes ? this._copy('minutes', { n: s.minutes }) : ''].filter(Boolean).join(' · ');
      const lead = s.hasJob
        ? `<div style="font-size:0.68rem; margin-top:2px; ${s.leaders.length ? '' : 'opacity:0.6;'}">${this._esc(s.leaders.length ? this._copy('led_by', { names: s.leaders.join(', ') }) : this._copy('no_leader'))}</div>`
        : '';
      const desc = s.description ? `<div style="font-size:0.7rem; opacity:0.8; line-height:1.4; margin-top:2px;">${this._esc(s.description)}</div>` : '';
      return `
        <li style="padding:6px 0; border-top:1px solid var(--border-color);">
          <div style="display:flex; gap:8px; align-items:baseline;">
            <span style="font-size:0.68rem; font-weight:800; opacity:0.55; min-width:16px;">${i + 1}</span>
            <div style="flex:1; min-width:0;">
              <div style="display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap;">
                <b style="font-size:0.78rem;">${this._esc(s.title)}</b>
                ${meta ? `<span style="font-size:0.7rem; font-weight:700; opacity:0.8;">${this._esc(meta)}</span>` : ''}
              </div>
              ${desc}${lead}
              ${s.checklist.length ? this._checklistHtml(s) : ''}
              ${s.routine ? this._routineHtml(s) : ''}
            </div>
          </div>
        </li>`;
    }).join('');
    return `<div style="font-size:0.74rem; font-weight:800; margin:6px 0 2px;">${this._esc(this._copy('day_h'))}</div>
      <ol style="list-style:none; margin:0; padding:0;">${rows}</ol>`;
  }

  _checklistHtml(stage) {
    const done = stage.checklist.filter(c => c.ticked).length;
    const items = stage.checklist.map(c => `
      <label style="display:flex; gap:6px; align-items:center; font-size:0.72rem; padding:2px 0; cursor:pointer;">
        <input type="checkbox" data-mp-tick="${c.id}" ${c.ticked ? 'checked' : ''}> ${this._esc(c.title)}
      </label>`).join('');
    return `<div style="margin-top:4px;">${items}
      <div style="font-size:0.66rem; opacity:0.7; margin-top:2px;">${this._esc(this._copy('ready', { done, total: stage.checklist.length }))}</div></div>`;
  }

  _routineHtml(stage) {
    const r = stage.routine;
    const head = [r.title, r.level ? this._copy('level', { level: r.level }) : ''].filter(Boolean).join(' · ');
    const source = r.sourceUrl
      ? ` <a href="${this._esc(r.sourceUrl)}" target="_blank" rel="noopener" style="font-size:0.66rem; color:#93c5fd;">${this._esc(this._copy('source'))}</a>` : '';
    const sections = r.sections.map((sec, si) => {
      const steps = sec.steps.map(st => `
        <div style="padding:3px 0;">
          <div style="font-size:0.72rem;"><b>${st.no}. ${this._esc(st.title)}</b>${st.sets ? ` <span style="opacity:0.65;">· ${this._esc(st.sets)}</span>` : ''}</div>
          ${st.description ? `<div style="font-size:0.68rem; opacity:0.8; line-height:1.4;">${this._esc(st.description)}</div>` : ''}
        </div>`).join('');
      const title = `<span style="font-size:0.72rem; font-weight:700;">${this._esc(sec.title)}${sec.minutes ? ` · ${this._esc(this._copy('minutes', { n: sec.minutes }))}` : ''}</span>`;
      // One-section routines (4v4+3) show their steps straight away.
      return r.sections.length === 1 ? steps : this._fold(`st:${stage.slug}:${si}`, title, `<div style="padding-left:10px;">${steps}</div>`, 'margin-top:3px;');
    }).join('');
    return `<div style="margin-top:4px; padding:6px 8px; border-radius:8px; background:rgba(148,163,184,0.08);">
      <div style="font-size:0.72rem; font-weight:800;">${this._esc(head)}${source}</div>
      ${sections}${r.teams && r.teams.length ? this._teamsHtml(r.teams) : ''}
    </div>`;
  }

  // The drill's sides from the lineup: shirt numbers → the starters at
  // those position numbers; bench_extras → the next bench players not
  // already used by an earlier side.
  _teamsHtml(teams) {
    const sq = this.host.squad();
    if (!sq.byNumber.size) return `<div style="font-size:0.68rem; opacity:0.7; margin-top:4px;">${this._esc(this._copy('lineup_first'))}</div>`;
    let benchAt = 0;
    const sides = teams.map(t => {
      const names = t.numbers.map(n => {
        const p = sq.byNumber.get(n);
        return p ? `<span>${n} ${this._esc(p.name)}</span>` : `<span style="opacity:0.55;">${this._esc(this._copy('open_no', { n }))}</span>`;
      });
      for (let k = 0; k < t.benchExtras; k++) {
        const p = sq.bench[benchAt++];
        names.push(p ? `<span title="${this._esc(this._copy('bench_extra'))}">↗ ${this._esc(p.name)}</span>`
                     : `<span style="opacity:0.55;">${this._esc(this._copy('bench_extra'))}</span>`);
      }
      const swatch = t.bibColor ? `<span style="display:inline-block; width:10px; height:10px; border-radius:3px; background:${this._esc(t.bibColor)}; border:1px solid rgba(100,116,139,0.6); margin-right:4px; vertical-align:-1px;"></span>` : '';
      return `<div style="padding:4px 0; border-top:1px dashed var(--border-color);">
        <div style="font-size:0.7rem; font-weight:700;">${swatch}${this._esc(t.title)}${t.bib ? ` <span style="opacity:0.7; font-weight:600;">· ${this._esc(t.bib)}</span>` : ''}</div>
        <div style="font-size:0.7rem; display:flex; flex-wrap:wrap; gap:4px 10px;">${names.join('')}</div>
      </div>`;
    }).join('');
    return `<div style="margin-top:4px;">${sides}</div>`;
  }

  // ── 🚩 Set pieces ───────────────────────────────────────────────────
  _setPiecesHtml() {
    const sp = this.data.setPieces;
    if (!sp || !sp.groups.length) return '';
    const sq = this.host.squad();
    const editing = this._editing();
    const nameOf = new Map();
    for (const p of [...sq.byNumber.values(), ...sq.bench, ...sq.others]) nameOf.set(Number(p.id), p.name);
    for (const g of sp.groups) for (const r of g.roles) for (const p of r.picks) if (p.personId && !nameOf.has(p.personId)) nameOf.set(p.personId, p.name);
    const refs = new Map((sp.positionRefs || []).map(f => [f.id, f]));

    // A pick → its words and the people it means right now.  A shirt
    // number is whoever starts there; a side-relative ref takes the
    // role's ball side, or reads both sides when the role has none.
    const atNo = (n) => { const p = sq.byNumber.get(n); return p ? `${n} ${p.name}` : this._copy('pos_open', { pos: n }); };
    const resolve = (val, role) => {
      if (!val) return { label: this._copy('none_picked'), ids: [], empty: true };
      const [kind, raw] = val.split(':');
      if (kind === 'p') return { label: nameOf.get(Number(raw)) || '', ids: [Number(raw)] };
      const f = refs.get(Number(raw));
      if (!f) return { label: '', ids: [] };
      const idAt = (n) => { const p = sq.byNumber.get(n); return p ? [Number(p.id)] : []; };
      if (f.number) return { label: atNo(f.number), ids: idAt(f.number) };
      if (role.ballSide) { const n = f[role.ballSide]; return { label: `${f.title} · ${atNo(n)}`, ids: idAt(n) }; }
      return { label: `${f.title} (${this._copy('pos_sides', { right: atNo(f.right), left: atNo(f.left) })})`, ids: [...idAt(f.right), ...idAt(f.left)] };
    };

    // A player's own line first.
    let mine = '';
    if (!editing && sq.viewerPersonId) {
      const roles = [];
      for (const g of sp.groups) for (const r of g.roles)
        for (let s = 1; s <= r.needed; s++)
          if (resolve(this.picks.get(`${r.id}:${s}`), r).ids.includes(Number(sq.viewerPersonId))) { roles.push(`${g.title}: ${r.title}`); break; }
      if (roles.length) mine = `<div style="font-size:0.72rem; font-weight:700; margin:4px 0; padding:5px 8px; border-radius:8px; background:rgba(34,197,94,0.12);">${this._esc(this._copy('mine', { roles: roles.join(' · ') }))}</div>`;
    }

    const squadIds = new Set([...sq.byNumber.values(), ...sq.bench].map(p => Number(p.id)));
    const option = (val, label, cur) => `<option value="${this._esc(val)}" ${val === cur ? 'selected' : ''}>${this._esc(label)}</option>`;
    const select = (role, slot) => {
      const cur = this.picks.get(`${role.id}:${slot}`) || '';
      const squad = [...sq.byNumber.values(), ...sq.bench];
      const others = sq.others.filter(p => !squadIds.has(Number(p.id)));
      const curPid = cur.startsWith('p:') ? Number(cur.slice(2)) : null;
      const stray = curPid && !squadIds.has(curPid) && !others.some(p => Number(p.id) === curPid)
        ? `<option value="${this._esc(cur)}" selected>${this._esc(nameOf.get(curPid) || '#' + curPid)}</option>` : '';
      const positions = [...refs.values()].map(f => option(`r:${f.id}`, resolve(`r:${f.id}`, role).label, cur)).join('');
      return `<select data-mp-pick="${role.id}:${slot}" style="font-size:0.7rem; padding:2px 4px; max-width:190px;">
        <option value="">${this._esc(this._copy('pick'))}</option>${stray}
        ${refs.size ? `<optgroup label="${this._esc(this._copy('positions_group'))}">${positions}</optgroup>` : ''}
        ${squad.length ? `<optgroup label="${this._esc(this._copy('squad_group'))}">${squad.map(p => option(`p:${p.id}`, p.name, cur)).join('')}</optgroup>` : ''}
        ${others.length ? `<optgroup label="${this._esc(this._copy('others_group'))}">${others.map(p => option(`p:${p.id}`, p.name, cur)).join('')}</optgroup>` : ''}
      </select>`;
    };

    const groups = sp.groups.map(g => {
      const rows = g.roles.map(r => {
        const slots = [];
        for (let s = 1; s <= r.needed; s++) {
          if (editing) slots.push(select(r, s));
          else {
            const res = resolve(this.picks.get(`${r.id}:${s}`), r);
            slots.push(`<span style="${res.empty ? 'opacity:0.5;' : ''}">${this._esc(res.label)}</span>`);
          }
        }
        return `<div style="display:flex; justify-content:space-between; gap:8px; align-items:center; padding:3px 0; flex-wrap:wrap;">
          <span style="font-size:0.72rem;" title="${this._esc(r.description)}">${this._esc(r.title)}</span>
          <span style="display:flex; gap:4px 8px; flex-wrap:wrap; justify-content:flex-end; font-size:0.72rem; font-weight:600;">${slots.join('')}</span>
        </div>`;
      }).join('');
      const filled = g.roles.reduce((n, r) => n + [...Array(r.needed).keys()].filter(i => this.picks.get(`${r.id}:${i + 1}`)).length, 0);
      const total = g.roles.reduce((n, r) => n + r.needed, 0);
      return this._fold(`sp:${g.slug}`,
        `<span style="font-size:0.74rem; font-weight:700;">${this._esc(g.title)}</span> <span style="font-size:0.66rem; opacity:0.6;">${filled}/${total}</span>`,
        `<div style="padding-left:10px;">${rows}</div>`, 'padding:3px 0; border-top:1px solid var(--border-color);');
    }).join('');

    const inherited = sp.inheritedFrom
      ? `<div style="font-size:0.66rem; opacity:0.75; margin:2px 0 4px;">${this._esc(this._copy('from_last', { when: sp.inheritedFrom }))}</div>` : '';
    return `<div style="font-size:0.74rem; font-weight:800; margin:12px 0 2px;">${this._esc(this._copy('setpieces_h'))}</div>${inherited}${mine}${groups}`;
  }

  // ── ♟️ Tactics ──────────────────────────────────────────────────────
  _tacticsHtml() {
    const sq = this.host.squad();
    const lines = [sq.formation ? this._copy('formation', { formation: sq.formation }) : '',
                   sq.matchup ? this._copy('matchup', { matchup: sq.matchup }) : ''].filter(Boolean)
      .map(l => `<div style="font-size:0.72rem;">${this._esc(l)}</div>`).join('');
    const notes = this._editing()
      ? `<textarea data-mp-tactics rows="4" placeholder="${this._esc(this._copy('tactics_ph'))}"
           style="width:100%; box-sizing:border-box; margin-top:4px; font-size:0.74rem; padding:6px; border-radius:6px;">${this._esc(this.tactics)}</textarea>`
      : `<div style="font-size:0.72rem; line-height:1.45; margin-top:4px; white-space:pre-wrap; ${this.tactics ? '' : 'opacity:0.6;'}">${this._esc(this.tactics || this._copy('no_tactics'))}</div>`;
    return `<div style="font-size:0.74rem; font-weight:800; margin:12px 0 2px;">${this._esc(this._copy('tactics_h'))}</div>${lines}${notes}`;
  }

  // ── Events from the host ────────────────────────────────────────────
  toggle(el) {
    const key = el.getAttribute('data-mp-fold');
    if (!key) return;
    if (el.open) this.open.add(key); else this.open.delete(key);
  }

  // 'change' / 'input' — kept on the panel so a re-render never drops them.
  input(el) {
    if (el.matches('[data-mp-pick]')) {
      const v = el.value || '';
      if (/^[pr]:\d+$/.test(v)) this.picks.set(el.dataset.mpPick, v); else this.picks.delete(el.dataset.mpPick);
      this.dirty = true;
      return false;
    }
    if (el.matches('[data-mp-tactics]')) { this.tactics = el.value; this.dirty = true; return false; }
    if (el.matches('[data-mp-tick]')) { this._tick(el); return true; }
    return false;
  }

  async click(el) {
    if (el.matches('[data-mp-save]')) await this._save();
  }

  async _tick(el) {
    const id = this.host.fhEventId();
    const itemId = Number(el.dataset.mpTick);
    const ticked = !!el.checked;
    for (const s of this.data?.stages || []) for (const c of s.checklist) if (c.id === itemId) c.ticked = ticked;
    this.host.rerender();
    try {
      const res = await this.auth.fetch(`/api/match-plan/${id}/tick`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ itemId, ticked }),
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
    } catch (err) {
      for (const s of this.data?.stages || []) for (const c of s.checklist) if (c.id === itemId) c.ticked = !ticked;
      this.host.rerender();
      this.host.toast(this._copy('save_failed', { reason: err.message }));
    }
  }

  async _save() {
    const id = this.host.fhEventId();
    if (!id || this.busy) return;
    const picks = [...this.picks.entries()].map(([k, v]) => {
      const [roleId, slot] = k.split(':').map(Number);
      const id = Number(v.slice(2));
      return v.startsWith('r:') ? { roleId, slot, positionRefId: id } : { roleId, slot, personId: id };
    });
    this.busy = true;
    this.host.rerender();
    try {
      const res = await this.auth.fetch(`/api/match-plan/${id}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ picks, tactics: this.tactics }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok || !body.success) throw new Error(body.error || `HTTP ${res.status}`);
      this._take(body);
      this.host.toast(this._copy('saved'));
    } catch (err) {
      this.host.toast(this._copy('save_failed', { reason: err.message }));
    } finally {
      this.busy = false;
      this.host.rerender();
    }
  }
}

window.MatchPlanPanel = MatchPlanPanel;
