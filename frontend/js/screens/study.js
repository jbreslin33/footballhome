// StudyScreen — 🎓 #study (mig 1937): the signed-in person's study plan for a
// test.  First one: the owner's Praxis Mathematics (5165) for the PA
// Mathematics 7-12 certificate.  Owner 2026-11-26: "i need a project on fh lol
// to prepare for the math 7-12 praxis for pa so i can teach it" · "this is an
// example of how fh can help players/coaches beyond football".
//
//   the test     pass score, time, calculator, 📅 test date → days to go
//   🗓 THIS WEEK  the topics not yet 🟢 Confident, spread over the weeks left
//   ✏️ PRACTICE   one question at a time (this week's topics first, never-right
//                first); Check → ✅/❌ + the worked answer
//   📚 THE TEST   every area → topic (its lettered points folded), rated
//                ⚪ / 🟡 Learning / 🟢 Confident, ✏️ Practise this topic
//
//   GET  /api/study
//   POST /api/study/answer {question_id, given}
//   POST /api/study/mark   {topic_id, status}
//   POST /api/study/date   {plan_id, date}
// Words: message_templates kind 'study'.  Only people with a study_plans row
// get the 🎓 Learn menu (trigger on study_plans → menu_page_people).
class StudyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.busy = false;
    this.planId = null;
    this.q = null;            // current question
    this.picked = new Set();  // chosen choice indexes
    this.result = null;       // { is_correct, answer_text, solution }
    this.topicOnly = null;    // ✏️ Practise one topic
  }

  _c(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('study', tier, tokens) : ''; }

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-study';
    el.innerHTML = '<div id="st-body" style="padding: 0 var(--space-4) var(--space-4); max-width: 820px; margin: 0 auto;"></div>';
    el.addEventListener('click', (e) => this._onClick(e));
    el.addEventListener('change', (e) => this._onChange(e));
    el.addEventListener('keydown', (e) => { if (e.key === 'Enter' && e.target.id === 'st-num') this._check(); });
    this.element = el;
    return el;
  }

  onEnter() { this.err = ''; this._load(); }

  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, { ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _load() {
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      this.data = await this._json('/api/study');
      if (!this.q) this._nextQuestion();
    } catch (err) { this.err = err.message; }
    this._draw();
  }

  async _post(path, payload) {
    if (this.busy) return null;
    this.busy = true; this.err = '';
    let out = null;
    try { out = await this._json('/api/study' + path, { method: 'POST', body: JSON.stringify(payload) }); this.data = { plans: out.plans }; }
    catch (err) { this.err = err.message; }
    this.busy = false;
    return out;
  }

  _plan() {
    const plans = (this.data && this.data.plans) || [];
    return plans.find(p => p.id === this.planId) || plans[0] || null;
  }

  _topics(plan) {
    const out = [];
    for (const a of plan.areas) for (const t of a.topics) out.push({ ...t, area: a });
    return out;
  }

  _daysLeft(plan) {
    if (!plan.test_date) return null;
    const [y, m, d] = plan.test_date.split('-').map(Number);
    const today = new Date(); today.setHours(0, 0, 0, 0);
    return Math.round((new Date(y, m - 1, d) - today) / 86400000);
  }

  // This week: the not-yet-confident topics in outline order, enough of them
  // that the rest are covered by the test date at the same pace.
  _week(plan) {
    const left = this._topics(plan).filter(t => t.mark !== 'confident');
    const days = this._daysLeft(plan);
    const weeks = days == null ? null : Math.max(1, Math.ceil(days / 7));
    const per = weeks == null ? Math.min(5, left.length) : Math.ceil(left.length / weeks);
    // 🟡 Learning first — they're already started
    const ordered = [...left.filter(t => t.mark === 'learning'), ...left.filter(t => t.mark !== 'learning')];
    return { left, per, topics: ordered.slice(0, per) };
  }

  _nextQuestion() {
    const plan = this._plan();
    this.picked = new Set(); this.result = null; this.q = null;
    if (!plan) return;
    const week = new Set(this._week(plan).topics.map(t => t.id));
    const confident = new Set(this._topics(plan).filter(t => t.mark === 'confident').map(t => t.id));
    let pool = plan.questions.filter(q => !this.topicOnly || q.topic_id === this.topicOnly);
    const score = (q) => (q.right ? 4 : 0) + (confident.has(q.topic_id) ? 2 : 0) + (week.has(q.topic_id) ? 0 : 1);
    const best = Math.min(...pool.map(score));
    pool = pool.filter(q => score(q) === best && !(q.right && best >= 4 && !this.topicOnly));
    if (!pool.length && this.topicOnly) pool = plan.questions.filter(q => q.topic_id === this.topicOnly);
    this.q = pool.length ? pool[Math.floor(Math.random() * pool.length)] : null;
  }

  async _check() {
    const q = this.q; if (!q || this.result) return;
    let given;
    if (q.kind === 'numeric') {
      const v = parseFloat((this.element.querySelector('#st-num') || {}).value);
      if (Number.isNaN(v)) { this.err = this._c('need_number'); this._draw(); return; }
      given = v;
    } else if (q.kind === 'single') {
      if (!this.picked.size) return;
      given = [...this.picked][0];
    } else {
      if (!this.picked.size) return;
      given = [...this.picked].sort((a, b) => a - b);
    }
    const out = await this._post('/answer', { question_id: q.id, given });
    if (out) { this.result = out; this.given = given; }
    this._draw();
  }

  _onChange(e) {
    const date = e.target.closest('[data-st-date]');
    if (date) { this._post('/date', { plan_id: Number(date.dataset.stDate), date: date.value || '' }).then(() => this._draw()); }
  }

  _onClick(e) {
    const b = e.target.closest('[data-st]'); if (!b) return;
    const act = b.dataset.st;
    if (act === 'choice' && !this.result) {
      const i = Number(b.dataset.i);
      if (this.q.kind === 'single') this.picked = new Set([i]);
      else if (this.picked.has(i)) this.picked.delete(i); else this.picked.add(i);
      this._draw();
    } else if (act === 'check') this._check();
    else if (act === 'next') { this._nextQuestion(); this._draw(); }
    else if (act === 'mark') {
      this._post('/mark', { topic_id: Number(b.dataset.topic), status: b.dataset.status }).then(() => this._draw());
    } else if (act === 'practise') {
      this.topicOnly = Number(b.dataset.topic); this._nextQuestion(); this._draw();
      const p = this.element.querySelector('#st-practice'); if (p) p.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } else if (act === 'mixed') { this.topicOnly = null; this._nextQuestion(); this._draw(); }
  }

  // ── drawing ───────────────────────────────────────────────────────────────
  _draw() {
    const body = this.element && this.element.querySelector('#st-body'); if (!body) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const plan = this._plan();
    let h = `<h2 style="margin: var(--space-3) 0 4px;">${esc(this._c('title'))}</h2>`;
    if (this.err) h += `<div style="color: #ff8a80; margin: 6px 0;">⚠ ${esc(this.err)}</div>`;
    if (!this.data) { body.innerHTML = h + '<div style="opacity:.6">…</div>'; return; }
    if (!plan) { body.innerHTML = h + `<p>${esc(this._c('none'))}</p>`; return; }
    h += `<p style="opacity:.75; margin: 0 0 var(--space-3);">${esc(this._c('intro'))}</p>`;
    h += this._examCard(plan, esc) + this._weekCard(plan, esc) + this._practiceCard(plan, esc) + this._outline(plan, esc);
    h += `<p style="opacity:.6; font-size:.85em; margin-top: var(--space-4);">${esc(this._c('source'))}</p>`;
    body.innerHTML = h;
  }

  _card(inner, id = '') {
    return `<div ${id ? `id="${id}"` : ''} style="border:1px solid var(--border-color); border-radius:10px; padding: var(--space-3); margin: 0 0 var(--space-3); background: var(--bg-secondary);">${inner}</div>`;
  }

  _head(text) { return `<div style="font-weight:700; letter-spacing:.04em; font-size:.85em; opacity:.8; margin-bottom:8px;">${text}</div>`; }

  _examCard(plan, esc) {
    const e = plan.exam;
    const days = this._daysLeft(plan);
    const left = days == null ? esc(this._c('no_date')) : esc(this._c('days_left', { n: days }));
    return this._card(`
      <div style="font-size:1.15em; font-weight:700;">${esc(e.title)}</div>
      <div style="margin:4px 0; font-weight:600;">${esc(this._c('pass', { state: e.pass_score_state, score: e.pass_score, min: e.score_min, max: e.score_max }))}</div>
      <div style="opacity:.75;">${esc(this._c('facts', { minutes: e.minutes, questions: e.question_count }))}</div>
      <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-top:10px;">
        <label>${esc(this._c('test_date'))} <input type="date" data-st-date="${plan.id}" value="${esc(plan.test_date || '')}" style="margin-left:6px; color-scheme:dark;"></label>
        <span style="opacity:.8;">${left}</span>
      </div>
      <div style="display:flex; flex-wrap:wrap; gap:12px; margin-top:10px;">
        ${e.companion_url ? `<a href="${esc(e.companion_url)}" target="_blank" rel="noopener">${esc(this._c('companion'))}</a>` : ''}
        ${e.register_url ? `<a href="${esc(e.register_url)}" target="_blank" rel="noopener">${esc(this._c('register'))}</a>` : ''}
      </div>`);
  }

  _weekCard(plan, esc) {
    const w = this._week(plan);
    let h = this._head(esc(this._c('sec_plan')));
    if (!w.left.length) return this._card(h + `<div>${esc(this._c('plan_done'))}</div>`);
    if (plan.test_date) h += `<div style="margin-bottom:6px;">${esc(this._c('plan_line', { n: w.per, date: plan.test_date }))}</div>`;
    else h += `<div style="margin-bottom:6px; opacity:.75;">${esc(this._c('no_date'))}</div>`;
    h += w.topics.map(t => `
      <div style="display:flex; gap:8px; align-items:baseline; padding:4px 0; border-top:1px solid var(--border-color);">
        <span style="opacity:.6; min-width:3.2em;">${esc(t.area.code)}.${t.num}</span>
        <span style="flex:1;">${t.mark === 'learning' ? '🟡 ' : ''}${esc(t.statement)}</span>
        ${t.questions ? `<button class="btn btn-sm" data-st="practise" data-topic="${t.id}">${esc(this._c('practise_topic'))}</button>` : ''}
      </div>`).join('');
    return this._card(h);
  }

  _practiceCard(plan, esc) {
    let h = this._head(esc(this._c('sec_practice')));
    const pct = plan.answered ? Math.round(100 * plan.right / plan.answered) : 0;
    h += `<div style="opacity:.7; font-size:.9em; margin-bottom:8px;">${esc(this._c('stats', { answered: plan.answered, pct }))}</div>`;
    const q = this.q;
    if (!q) return this._card(h + `<div>${esc(this._c('no_questions'))}</div>`, 'st-practice');
    const topic = this._topics(plan).find(t => t.id === q.topic_id);
    if (topic) h += `<div style="opacity:.65; font-size:.85em;">${esc(this._c('practice_from', { topic: `${topic.area.code}.${topic.num} ${topic.statement}` }))}
      ${this.topicOnly ? ` · <a href="#" onclick="return false;" data-st="mixed">✕</a>` : ''}</div>`;
    h += `<div style="font-size:1.08em; margin:8px 0 4px; white-space:pre-wrap;">${esc(q.prompt)}</div>`;
    h += `<div style="opacity:.6; font-size:.85em; margin-bottom:8px;">${esc(q.kind_label)}</div>`;
    const r = this.result;
    if (q.kind === 'numeric') {
      h += `<input id="st-num" type="number" step="any" inputmode="decimal" ${r ? 'disabled' : ''} value="${r ? esc(this.given) : ''}" style="font-size:1.1em; padding:6px 8px; width:12em; color-scheme:dark;">`;
    } else {
      const right = r ? new Set([].concat(r.answer)) : null;
      h += q.choices.map((c, i) => {
        const on = this.picked.has(i);
        let bg = on ? 'var(--accent-dim)' : 'transparent';
        if (right && right.has(i)) bg = 'rgba(22,163,74,0.30)';
        else if (right && on) bg = 'rgba(220,38,38,0.30)';
        const mark = q.kind === 'multi' ? (on ? '☑' : '☐') : (on ? '◉' : '○');
        return `<button data-st="choice" data-i="${i}" style="display:block; width:100%; text-align:left; margin:4px 0; padding:8px 10px; border:1px solid var(--border-color); border-radius:8px; background:${bg}; cursor:pointer; font:inherit; color:inherit;">${mark} ${esc(c)}</button>`;
      }).join('');
    }
    if (!r) {
      h += `<div style="margin-top:10px;"><button class="btn btn-primary" data-st="check" ${this.busy ? 'disabled' : ''}>${esc(this._c('check'))}</button></div>`;
    } else {
      h += `<div style="margin-top:10px; font-weight:700;">${r.is_correct ? esc(this._c('right')) : esc(this._c('wrong', { answer: r.answer_text }))}</div>`;
      h += `<div style="margin-top:6px; padding:8px 10px; border-left:3px solid var(--accent); background: var(--bg-surface); white-space:pre-wrap;">${esc(r.solution)}</div>`;
      h += `<div style="margin-top:10px;"><button class="btn btn-primary" data-st="next">${esc(this._c('next'))}</button></div>`;
    }
    return this._card(h, 'st-practice');
  }

  _outline(plan, esc) {
    let h = this._head(esc(this._c('sec_areas')));
    const tops = plan.areas.filter(a => !a.parent_code);
    for (const top of tops) {
      const kids = plan.areas.filter(a => a.parent_code === top.code);
      h += `<div style="margin-top:12px; font-weight:700; font-size:1.05em;">${esc(top.code)}. ${esc(top.name)}
        <span style="font-weight:400; opacity:.65; font-size:.85em;">${esc(this._c('area_weight', { q: top.approx_questions, pct: top.pct }))}</span></div>`;
      if (top.is_overlay) h += `<div style="opacity:.7; font-size:.9em;">${esc(this._c('overlay_note'))}</div>`;
      for (const a of (kids.length ? kids : [top])) {
        if (kids.length) h += `<div style="margin:8px 0 2px; font-weight:600;">${esc(a.code)}. ${esc(a.name)}
          ${a.approx_questions ? `<span style="font-weight:400; opacity:.65; font-size:.85em;">${esc(this._c('area_weight', { q: a.approx_questions, pct: a.pct }))}</span>` : ''}</div>`;
        h += a.topics.map(t => this._topicRow(a, t, esc)).join('');
      }
    }
    return this._card(h);
  }

  _topicRow(area, t, esc) {
    const pill = (status, tier) => {
      const on = (t.mark || '') === status;
      return `<button data-st="mark" data-topic="${t.id}" data-status="${status}" style="padding:2px 8px; border-radius:999px; border:1px solid ${on ? 'var(--accent)' : 'var(--border-color)'}; background:${on ? 'var(--accent-dim)' : 'transparent'}; font:inherit; font-size:.8em; cursor:pointer; color:inherit;">${esc(this._c(tier))}</button>`;
    };
    const progress = t.questions ? `<span style="opacity:.6; font-size:.8em;">✓ ${t.right}/${t.questions}</span>` : '';
    const points = t.points.length ? `<details style="margin:2px 0 0 3.2em;"><summary style="opacity:.6; font-size:.85em; cursor:pointer;">${esc(this._c('points', { n: t.points.length }))}</summary>
      ${t.points.map(p => `<div style="font-size:.9em; margin:2px 0;">${esc(p.letter)}. ${esc(p.statement)}</div>`).join('')}</details>` : '';
    return `<div style="padding:6px 0; border-top:1px solid var(--border-color);">
      <div style="display:flex; gap:8px; align-items:baseline;">
        <span style="opacity:.6; min-width:3.2em;">${esc(area.code)}.${t.num}</span>
        <span style="flex:1;">${esc(t.statement)}</span>
      </div>
      <div style="display:flex; flex-wrap:wrap; gap:6px; align-items:center; margin:4px 0 0 3.2em;">
        ${pill('', 'mark_none')}${pill('learning', 'mark_learning')}${pill('confident', 'mark_confident')}
        ${progress}
        ${t.questions ? `<button class="btn btn-sm" data-st="practise" data-topic="${t.id}">${esc(this._c('practise_topic'))}</button>` : ''}
      </div>
      ${points}
    </div>`;
  }
}
