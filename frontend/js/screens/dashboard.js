// dashboard.js — #dashboard: the admin's front page (migration 548).
// Owner 2026-10-09: "a live dashboard could be interesting. maybe have
// cells with important information. like quick dash for rsvps to games
// and practices to identify trouble spots. payments how many are up to
// date and late and total collected that month. rosters. how many roster
// spots out of max are filled. how many uniforms assigned out of players
// on rosters. leads if any leads not contacted" — "then i could click any
// cell and go to that page that is already working like go to rsvp
// reminders tuition etc" — "that would be my front page … make that the
// top page for all admin. coaches can go to my page to rsvp same with
// players".
//
// Nothing is typed in here.  GET /api/dashboard reads the same models the
// cells' own pages read, so a number here is the number on that page:
//
//   ⚽ Games / 🏃 Practices   RsvpBoard::weekEvents per section (the #rsvps
//                tiles), split by kind (owner: "separate game and practice
//                rsvps") — players still to answer, the events with the most
//                of their roster unanswered on top.  Cell → #rsvps on that
//                kind; a section row → that section too.
//   💰 Dues      PaymentsOverview (the #payments / #finances summary) —
//                up to date / behind / over the line, owed, what a month's
//                dues come to for all members; collected this month from
//                person_payments.  Cell → #payments.
//   👥 Rosters   teams.max_roster vs live team_persons.  Cell → #teams;
//                a team row → #teams on that section.
//   👕 Numbers   person_uniform_numbers vs rostered players.  Cell → #kit.
//   📋 Leads     leads with no lead_contacts row (the #leads "new"
//                status), on a running ad or not.  Cell → #leads.
//   💬 Texts     rostered players (or parent) opted in to club texts, the
//                #texts board's test: percent + count, per section.  → #texts.
//   🏟️ Game Center  this week's games — going, can start (the Practice
//                Criteria rule), on track, lineup set / everyone plays.
//                Cell → #game-center picker; a game → that match.
//   🏠 Home games  every home game in the next 28 days by day, with the
//                format to line (teams.field_size).  Cell → #calendar; a
//                game → #game-center on that match.
//
// Live: re-read every 10 minutes while open and whenever the tab comes
// back to the front.  Wording: message_templates kind 'dashboard'.
class DashboardScreen extends Screen {
  static get REFRESH_MS() { return 10 * 60 * 1000; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.loading = false; this.timer = null;
    this._onVisible = () => { if (document.visibilityState === 'visible' && this.isMounted) this.load(); };
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('dashboard', tier, tokens) : ''; }
  _t(tier, fallback, tokens = {}) { return this._copy(tier, tokens) || (window.MessageCopy ? MessageCopy.fill(fallback, tokens) : fallback); }
  static money(n) { const v = Number(n) || 0; return Number.isInteger(v) ? `$${v.toLocaleString()}` : `$${v.toFixed(2)}`; }
  static pct(part, whole) { return whole > 0 ? Math.round(100 * part / whole) : 100; }
  // Traffic light for a share of trouble: green under 10 %, amber under 30 %, red beyond.
  static tone(badShare) { return badShare < 0.1 ? 'ok' : badShare < 0.3 ? 'warn' : 'bad'; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .db-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(290px, 1fr)); gap:14px; align-items:start; }
        .db-cell { border:1px solid var(--border-color, #374151); border-left:5px solid var(--border-color, #374151); border-radius:10px;
                   background:var(--bg-tertiary, #1f2937); padding:14px 16px; cursor:pointer; text-align:left; color:inherit; font:inherit;
                   display:flex; flex-direction:column; gap:8px; width:100%; transition:transform .08s, box-shadow .08s; }
        .db-cell:hover { transform:translateY(-1px); box-shadow:0 6px 18px rgba(0,0,0,0.25); }
        .db-cell a { text-decoration:underline; }
        .db-cell.ok { border-left-color:var(--success-color, #16a34a); }
        .db-cell.warn { border-left-color:var(--warning-color, #d97706); }
        .db-cell.bad { border-left-color:var(--error-color, #dc2626); }
        .db-head { display:flex; align-items:baseline; justify-content:space-between; gap:8px; }
        .db-title { font-weight:800; font-size:1.05rem; }
        .db-sub { opacity:0.65; font-size:0.78rem; margin-top:-4px; }
        .db-big { font-size:2.1rem; font-weight:900; line-height:1.1; }
        .db-big small { font-size:0.95rem; font-weight:600; opacity:0.7; margin-left:6px; }
        .db-stats { display:flex; gap:14px; flex-wrap:wrap; }
        .db-stat .k { font-size:0.65rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; }
        .db-stat .v { font-size:1.25rem; font-weight:800; }
        .db-stat.ok .v { color:#86efac; } .db-stat.warn .v { color:#fde68a; } .db-stat.bad .v { color:#fca5a5; }
        .db-rows { display:flex; flex-direction:column; gap:4px; font-size:0.84rem; }
        .db-row { display:flex; justify-content:space-between; gap:8px; padding:3px 6px; border-radius:6px; }
        .db-row.link:hover { background:rgba(148,163,184,0.12); }
        .db-row .l { flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .db-row .r { white-space:nowrap; font-weight:700; }
        .db-row .r.warn, .db-row .warn { color:#fde68a; } .db-row .r.bad, .db-row .bad { color:#fca5a5; } .db-row .r.ok, .db-row .ok { color:#86efac; }
        .db-bar { height:6px; border-radius:3px; background:rgba(148,163,184,0.18); overflow:hidden; margin-top:2px; }
        .db-bar > i { display:block; height:100%; background:var(--primary-color, #2563eb); }
        .db-bar > i.full { background:var(--success-color, #16a34a); }
        .db-h { font-size:0.68rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; margin-top:4px; }
        .db-tag { display:inline-block; padding:0 6px; border-radius:999px; font-size:0.65rem; font-weight:800; margin-left:6px; background:#052e16; color:#86efac; border:1px solid #15803d; }
        .db-foot { opacity:0.55; font-size:0.75rem; margin-top:14px; text-align:right; }
        .db-note { opacity:0.7; font-size:0.82rem; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <div style="flex:1;"><h1 style="margin:0;" id="db-title">📊 Dashboard</h1><div id="db-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-secondary" id="db-tools" style="padding:6px 12px; font-size:0.9rem;">🧭 All tools</button>
        <button class="btn btn-secondary" id="db-refresh" style="padding:6px 12px; font-size:0.9rem;">🔄</button>
      </div>
      <div class="screen-content" style="max-width:1300px; margin:0 auto;">
        <div id="db-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#db-tools').addEventListener('click', () => this.navigation.goTo('role-selection'));
    div.querySelector('#db-refresh').addEventListener('click', () => this.load());
    div.addEventListener('click', (e) => {
      // A row inside a cell wins over the cell itself (a section → that
      // section's board); otherwise the cell opens its page.
      if (e.target.closest('a[href]')) return;   // a tel:/mailto: link inside a cell does its own thing
      const row = e.target.closest('[data-db-row]');
      const cell = e.target.closest('[data-db-go]');
      const go = row ? row.dataset.dbRow : cell ? cell.dataset.dbGo : '';
      if (!go) return;
      e.stopPropagation();
      this._open(go);
    });
    return div;
  }

  // target: "screen" or "screen?key=value&…" (plain string params).
  _open(target) {
    const [screen, qs] = target.split('?');
    const params = {};
    if (qs) for (const kv of qs.split('&')) { const [k, v] = kv.split('='); params[decodeURIComponent(k)] = decodeURIComponent(v || ''); }
    if (screen === 'teams') this.navigation.context.role = 'club-admin';   // the board scopes by the hat worn (role-selection does the same)
    if (params.matchId) params.matchId = Number(params.matchId);
    if (params.pick) params.pick = true;
    this.navigation.goTo(screen, params);
  }

  async onEnter() {
    if (window.MessageCopy && typeof MessageCopy.load === 'function') { try { await MessageCopy.load(this.auth); } catch (_) { /* fallbacks */ } }
    const t = this.find('#db-title'), s = this.find('#db-sub'), b = this.find('#db-tools');
    if (t) t.textContent = this._t('title', '📊 Dashboard');
    if (s) s.textContent = this._t('subtitle', 'Live from the same boards each cell opens. Tap a cell.');
    if (b) b.textContent = this._t('all_tools', '🧭 All tools');
    document.addEventListener('visibilitychange', this._onVisible);
    this.timer = setInterval(() => { if (this.isMounted && document.visibilityState === 'visible') this.load(); }, DashboardScreen.REFRESH_MS);
    this.load();
  }

  onExit() {
    document.removeEventListener('visibilitychange', this._onVisible);
    if (this.timer) { clearInterval(this.timer); this.timer = null; }
    super.onExit();
  }

  async load() {
    if (this.loading) return;
    this.loading = true; this.err = '';
    if (!this.data) this._renderBody();
    try {
      const res = await this.auth.fetch('/api/dashboard');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
    } catch (err) { this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) this._renderBody();
  }

  _renderBody() {
    const el = this.find('#db-body');
    if (!el) return;
    if (!this.data) {
      el.innerHTML = this.err ? `<div style="color:#f87171; padding:var(--space-3);">⚠️ ${this.escapeHtml(this.err)}</div>` : `<div class="loading">Loading…</div>`;
      return;
    }
    const d = this.data;
    const when = d.generated_at ? new Date(d.generated_at) : null;
    const time = when && !isNaN(when) ? when.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }) : '';
    el.innerHTML = `
      ${this.err ? `<div style="color:#f87171; padding:0 0 8px;">⚠️ ${this.escapeHtml(this.err)}</div>` : ''}
      <div class="db-grid">
        ${this._rsvpCell(d.rsvps || {}, 'games')}
        ${this._rsvpCell(d.rsvps || {}, 'practices')}
        ${this._gcCell(d.game_center || {})}
        ${this._homeCell(d.home_games || {})}
        ${this._payCell(d.payments || {})}
        ${this._rosterCell(d.rosters || {})}
        ${this._kitCell(d.kit || {})}
        ${this._leadsCell(d.leads || {})}
        ${this._textsCell(d.texts || {})}
      </div>
      <div class="db-foot">${this.escapeHtml(this._t('updated', 'Read {time}', { time }))}${this.loading ? ' · …' : ''}</div>`;
  }

  _cell(tone, go, title, sub, body) {
    return `<div class="db-cell ${tone}" role="button" tabindex="0" data-db-go="${this.escapeHtml(go)}">
      <div class="db-head"><div class="db-title">${this.escapeHtml(title)}</div></div>
      <div class="db-sub">${this.escapeHtml(sub)}</div>
      ${body}
    </div>`;
  }

  // One cell per kind (owner 2026-10-09: "separate game and practice
  // rsvps"): kind 'games' = matches + intra squads, 'practices' = practices,
  // split from each section's released-week list.
  _rsvpCell(r, kind) {
    const isGame = (ev) => ev.kind !== 'practice';
    const pick = (list) => (list || []).filter(ev => (kind === 'games') === isGame(ev));
    const sections = (r.sections || []).map(s => {
      const list = pick(s.list);
      const expected = list.reduce((a, ev) => a + (Number(ev.expected) || 0), 0);
      const unanswered = list.reduce((a, ev) => a + (Number(ev.unanswered) || 0), 0);
      return { code: s.code, key: s.key, list, events: list.length, expected, unanswered };
    });
    const expected = sections.reduce((a, s) => a + s.expected, 0), unanswered = sections.reduce((a, s) => a + s.unanswered, 0), answered = expected - unanswered;
    const anyEvents = sections.some(s => s.events > 0);
    const tone = !anyEvents ? 'ok' : DashboardScreen.tone(expected > 0 ? unanswered / expected : 0);
    const secLabel = (s) => this._t(`rsvp_sec_${s.code}`, s.code === 'M' ? 'Men' : s.code === 'W' ? 'Women' : 'Youth');
    const go = (key) => `rsvps?kind=${kind}${key ? `&section=${encodeURIComponent(key)}` : ''}`;
    // Every released event of the kind, under its section, the team first
    // (owner 2026-10-09: "should show what game. like u12 apsl etc"), the
    // ones with the most of their roster unanswered on top; a row opens
    // #rsvps on that section and kind.
    const when = (ev) => { const d = new Date(ev.starts_at); return isNaN(d) ? (ev.when_text || '') : d.toLocaleString([], { weekday: 'short', hour: 'numeric', minute: '2-digit' }); };
    const rows = sections.map(s => {
      const list = s.list.slice().sort((a, b) => (b.unanswered / Math.max(1, b.expected)) - (a.unanswered / Math.max(1, a.expected)) || (a.starts_at < b.starts_at ? -1 : 1));
      const head = `<div class="db-row link" data-db-row="${this.escapeHtml(go(s.key))}" style="padding-top:6px;">
        <span class="l db-h" style="margin:0;">${this.escapeHtml(secLabel(s))}</span>
        <span class="r" style="font-weight:400; opacity:0.6; font-size:0.75rem;">${!s.events ? this.escapeHtml(this._t('rsvp_none', 'None released')) : s.unanswered === 0 ? `<span class="ok">${this.escapeHtml(this._t('rsvp_clear', 'All in'))}</span>` : `${this.escapeHtml(this._t('rsvp_row', '{n}/{of} rsvp', { n: s.expected - s.unanswered, of: s.expected }))}`}</span></div>`;
      return head + list.map(ev => {
        const what = ev.kind === 'practice' ? '' : ` ${ev.is_home === false ? '@' : 'vs'} ${ev.opponent || 'TBD'}`;
        const un = Number(ev.unanswered) || 0, ex = Number(ev.expected) || 0;
        const t = un ? DashboardScreen.tone(un / Math.max(1, ex)) : 'ok';
        return `<div class="db-row link" data-db-row="${this.escapeHtml(go(s.key))}" style="${un ? '' : 'opacity:0.6;'}">
          <span class="l" style="white-space:normal;"><b>${this.escapeHtml(ev.teams)}</b>${this.escapeHtml(what)} <span style="opacity:0.6;">· ${this.escapeHtml(when(ev))}</span></span>
          <span class="r ${t}" style="font-size:0.78rem;">${un ? this.escapeHtml(this._t('rsvp_row', '{n}/{of} rsvp', { n: ex - un, of: ex })) : '✓'}</span></div>`;
      }).join('');
    }).join('');
    const big = anyEvents ? `<div class="db-big">${DashboardScreen.pct(answered, expected)}%<small>${this.escapeHtml(this._t('rsvp_answered', '{n} / {of} answered', { n: answered, of: expected }))}</small></div>`
                          : `<div class="db-note">${this.escapeHtml(this._t('rsvp_none', 'None released'))}</div>`;
    const title = kind === 'games' ? this._t('rsvp_games_title', '⚽ Game RSVPs') : this._t('rsvp_practices_title', '🏃 Practice RSVPs');
    const sub = kind === 'games' ? this._t('rsvp_games_sub', 'Released games this week · rsvp\'d of expected') : this._t('rsvp_practices_sub', 'Released practices this week · rsvp\'d of expected');
    return this._cell(tone, go(''), title, sub, `${big}<div class="db-rows">${rows}</div>`);
  }

  // Owner 2026-10-09: "add in upcoming home games because i always need
  // to be aware to line fields and make sure i can be there".  Every home
  // game in the next 28 days by day, with the format to line.  → #calendar.
  // Owner 2026-10-09: "we need game center dash item. like showing number
  // of possible starters and subs … and if starters have been filled out.
  // i know we auto fill the kids".  This week's games: going, can start
  // (Game Center's Practice Criteria rule), on track, and the lineup.
  // Cell → #game-center picker; a game → that match.
  _gcCell(gc) {
    const games = gc.games || [], days = gc.days || 7;
    const tones = [];
    const rows = games.map(g => {
      const need = Number(g.field_size) || 11;
      const going = Number(g.going) || 0, canStart = Number(g.can_start) || 0, onTrack = Number(g.on_track) || 0;
      const starters = Number(g.starters_set) || 0, bench = Number(g.bench_set) || 0, wrong = Number(g.lineup_not_going) || 0;
      // Red: not enough going for a side.  Amber: enough going but not
      // enough who can start, or no lineup yet for a game that needs one.
      let tone = going < need ? 'bad' : (!g.everyone_plays && (canStart < need || starters < need)) || wrong ? 'warn' : 'ok';
      tones.push(tone);
      const lineup = g.everyone_plays ? this._t('gc_everyone', 'everyone plays')
        : starters === 0 ? this._t('gc_lineup_none', 'no lineup yet')
        : starters < need ? this._t('gc_lineup_part', 'lineup {starters} of {need}', { starters, need })
        : this._t('gc_lineup_set', 'lineup {starters} + {bench} bench', { starters, bench });
      const bits = [
        `<span class="${going < need ? 'bad' : 'ok'}">${this.escapeHtml(this._t('gc_going', '{n} going of {of}', { n: going, of: g.roster }))}</span>`,
        this.escapeHtml(this._t('gc_need', 'need {n}', { n: need })),
        g.everyone_plays ? '' : `<span class="${canStart < need ? 'warn' : 'ok'}">${this.escapeHtml(this._t('gc_can_start', '{n} can start', { n: canStart }))}</span>`,
        g.everyone_plays || !onTrack ? '' : this.escapeHtml(this._t('gc_on_track', '{n} on track', { n: onTrack })),
        `<span class="${g.everyone_plays || starters >= need ? 'ok' : 'warn'}">${this.escapeHtml(lineup)}</span>`,
        wrong ? `<span class="bad">${this.escapeHtml(this._t('gc_not_going', '{n} in lineup not going', { n: wrong }))}</span>` : '',
      ].filter(Boolean).join(' · ');
      // The opponent's contact(s): name, role, a tel: and a mailto: link.
      const contacts = (g.contacts || []).length ? g.contacts.map(c => `${this.escapeHtml(c.name || '')}${c.role ? ` <span style="opacity:0.6;">(${this.escapeHtml(c.role)})</span>` : ''}${c.phone ? ` · <a href="tel:${this.escapeHtml(String(c.phone).replace(/[^+\d]/g, ''))}" style="color:#bfdbfe;">${this.escapeHtml(c.phone)}</a>` : ''}${c.email ? ` · <a href="mailto:${this.escapeHtml(c.email)}" style="color:#bfdbfe;">${this.escapeHtml(c.email)}</a>` : ''}`).join(' · ')
        : `<span style="opacity:0.6;">${this.escapeHtml(this._t('gc_contact_none', 'no opponent contact on file'))}${g.opponent_club ? '' : ''}</span>`;
      return `<div class="db-row link" data-db-row="game-center?matchId=${g.match_id}" style="flex-direction:column; align-items:stretch; gap:1px; border-left:3px solid ${tone === 'bad' ? '#dc2626' : tone === 'warn' ? '#d97706' : '#16a34a'}; padding-left:8px;">
        <span class="l" style="white-space:normal;"><b>${this.escapeHtml(g.teams || '')}</b> ${g.is_home === false ? '@' : 'vs'} ${this.escapeHtml(g.opponent)} <span style="opacity:0.6;">· ${this.escapeHtml(g.when_text)}</span></span>
        <span class="db-rows" style="font-size:0.76rem; opacity:0.95; display:block;">${bits}</span>
        <span style="font-size:0.76rem; opacity:0.85; display:block;">📇 ${contacts}</span></div>`;
    }).join('');
    const tone = tones.includes('bad') ? 'bad' : tones.includes('warn') ? 'warn' : 'ok';
    return this._cell(tone, 'game-center?pick=1', this._t('gc_title', '🏟️ Game Center'), this._t('gc_sub', "This week's games — who is going, who can start, is the lineup set"),
      `<div class="db-big">${games.length}<small>${this.escapeHtml(this._t('gc_count', 'games in {days} days', { days }))}</small></div>
       <div class="db-rows" style="gap:6px;">${rows || `<div class="db-note">${this.escapeHtml(this._t('gc_none', 'No games in the next {days} days', { days }))}</div>`}</div>`);
  }

  _homeCell(h) {
    const games = h.games || [], days = h.days || 28;
    const byDay = new Map();
    for (const g of games) { if (!byDay.has(g.day)) byDay.set(g.day, { text: g.day_text, games: [] }); byDay.get(g.day).games.push(g); }
    const facilities = [...new Set(games.map(g => g.facility).filter(Boolean))];
    const rows = [...byDay.values()].map(d => `
      <div class="db-row" style="padding-top:6px;"><span class="l db-h" style="margin:0;">${this.escapeHtml(d.text)}</span>
        <span class="r" style="font-weight:400; opacity:0.6; font-size:0.75rem;">${d.games.length > 1 ? `${d.games.length} ${this.escapeHtml(this._t('home_games_word', 'games'))}` : ''}</span></div>
      ${d.games.map(g => `<div class="db-row link" data-db-row="${g.match_id ? `game-center?matchId=${g.match_id}` : 'calendar'}">
        <span class="l" style="white-space:normal;"><span style="opacity:0.75;">${this.escapeHtml(g.time_text)}</span> · <b>${this.escapeHtml(g.teams || '')}</b> vs ${this.escapeHtml(g.opponent)}</span>
        <span class="r" style="font-weight:600; opacity:0.8;">${this.escapeHtml(g.format || '')}</span></div>`).join('')}`).join('');
    const tone = games.some(g => g.day === new Date().toLocaleDateString('en-CA')) ? 'warn' : 'ok';
    return this._cell(tone, 'calendar', this._t('home_title', '🏠 Home games'), this._t('home_sub', 'Next {days} days at {facility} — line the field, be there', { days, facility: facilities.join(' / ') || 'home' }),
      `<div class="db-big">${games.length}<small>${this.escapeHtml(this._t('home_count', 'in {days} days', { days }))}</small></div>
       <div class="db-rows">${rows || `<div class="db-note">${this.escapeHtml(this._t('home_none', 'No home games in the next {days} days', { days }))}</div>`}</div>`);
  }

  // Owner 2026-10-09: "add a texts dash cell for who has opted in".
  // Rostered players (or their parent) with club-text consent, the
  // #texts board's own test.  Cell → #texts.
  _textsCell(t) {
    const players = Number(t.players) || 0, optedIn = Number(t.opted_in) || 0;
    const tone = DashboardScreen.tone(players > 0 ? (players - optedIn) / players : 0);
    const name = { M: this._t('rsvp_sec_M', 'Men'), W: this._t('rsvp_sec_W', 'Women'), B: this._t('rsvp_sec_B', 'Youth'), G: this._t('rsvp_sec_G', 'Girls') };
    const rows = (t.sections || []).map(s => `<div class="db-row"><span class="l">${this.escapeHtml(name[s.code] || s.code || '—')}</span>
        <span class="r ${DashboardScreen.tone(s.players > 0 ? (s.players - s.opted_in) / s.players : 0)}">${s.opted_in} <span style="opacity:0.6; font-weight:400;">/ ${s.players}</span></span></div>`).join('');
    return this._cell(tone, 'texts', this._t('texts_title', '💬 Texts'), this._t('texts_sub', 'Players (or their parent) opted in to club texts'),
      `<div class="db-big">${DashboardScreen.pct(optedIn, players)}%<small>${this.escapeHtml(this._t('texts_in', '{n} of {of} opted in', { n: optedIn, of: players }))}</small></div>
       <div class="db-rows">${rows}</div>`);
  }

  _payCell(p) {
    const paying = Number(p.paying) || 0, paidUp = Number(p.paid_up) || 0, behind = Number(p.behind) || 0, blocked = Number(p.blocked) || 0;
    const tone = DashboardScreen.tone(paying > 0 ? (behind + blocked) / paying : 0);
    const c = p.collected || {};
    const proj = p.projections || {};
    const monthlyAll = Number((proj.all_members || {}).monthly) || 0, monthlyCur = Number((proj.current_dues || {}).monthly) || 0;
    const by = (c.by_section || []).filter(s => Number(s.collected) !== 0);
    const stat = (k, v, t) => `<div class="db-stat ${t || ''}"><div class="k">${this.escapeHtml(k)}</div><div class="v">${v}</div></div>`;
    return this._cell(tone, 'payments', this._t('pay_title', '💰 Dues'), this._t('pay_sub', 'Paying members by standing, and what came in this month'),
      `<div class="db-big">${DashboardScreen.pct(paidUp, paying)}%<small>${paidUp} / ${paying} ${this.escapeHtml(this._t('pay_paid_up', 'Up to date').toLowerCase())}</small></div>
       <div class="db-stats">
         ${stat(this._t('pay_paid_up', 'Up to date'), paidUp, 'ok')}
         ${stat(this._t('pay_behind', 'Behind'), behind, behind ? 'warn' : '')}
         ${stat(this._t('pay_blocked', 'Over the line'), blocked, blocked ? 'bad' : '')}
       </div>
       <div class="db-h">${this.escapeHtml(this._t('pay_month', 'This month'))}</div>
       <div class="db-rows">
         <div class="db-row"><span class="l">${this.escapeHtml(this._t('pay_monthly', 'Due each month, all members'))}</span><span class="r">${DashboardScreen.money(monthlyAll)} <span style="opacity:0.6; font-weight:400;">· ${this.escapeHtml(this._t('pay_monthly_current', '{amount} from those up to date', { amount: DashboardScreen.money(monthlyCur) }))}</span></span></div>
         <div class="db-row"><span class="l">${this.escapeHtml(this._t('pay_collected', 'Collected in {month}', { month: c.month_label || '' }))}</span><span class="r ${monthlyAll > 0 ? DashboardScreen.tone(Math.max(0, 1 - Number(c.total || 0) / monthlyAll)) : ''}">${DashboardScreen.money(c.total)}</span></div>
         <div class="db-row"><span class="l"></span>
           <span class="r" style="opacity:0.75; font-weight:500;">${by.map(s => `${this.escapeHtml(s.category)} ${DashboardScreen.money(s.collected)}`).join(' · ')}</span></div>
         <div class="db-row"><span class="l">${this.escapeHtml(this._t('pay_owed', 'Owed in all'))}</span><span class="r ${Number(p.owed) > 0 ? 'warn' : ''}">${DashboardScreen.money(p.owed)}</span></div>
       </div>`);
  }

  _rosterCell(r) {
    const teams = r.teams || [];
    const cp = Number(r.capped_players) || 0, cm = Number(r.capped_max) || 0, open = Math.max(0, cm - cp);
    const tone = cm > 0 ? DashboardScreen.tone(open / cm) : 'ok';
    const secKey = { M: 'mens', W: 'womens', B: 'boys', G: 'girls' };
    const rows = teams.map(t => {
      const go = `teams?teamsPill=${secKey[t.section] || 'mens'}`;
      const capped = t.max != null;
      const share = capped ? Math.min(1, t.players / Math.max(1, t.max)) : 0;
      return `<div class="db-row link" data-db-row="${this.escapeHtml(go)}" style="flex-direction:column; align-items:stretch; gap:0;">
        <div style="display:flex; justify-content:space-between; gap:8px;">
          <span class="l">${this.escapeHtml(t.label)}${t.full ? `<span class="db-tag">${this.escapeHtml(this._t('roster_full', 'FULL'))}</span>` : ''}</span>
          <span class="r">${t.players}${capped ? ` <span style="opacity:0.6; font-weight:400;">/ ${t.max}</span>` : ''}</span></div>
        ${capped ? `<div class="db-bar"><i class="${t.full ? 'full' : ''}" style="width:${Math.round(share * 100)}%"></i></div>` : ''}</div>`;
    }).join('');
    return this._cell(tone, 'teams', this._t('roster_title', '👥 Rosters'), this._t('roster_sub', 'Spots filled on capped teams; uncapped teams show their count'),
      `<div class="db-big">${cp}<small>/ ${cm} · ${this.escapeHtml(this._t('roster_open', '{n} open', { n: open }))} · ${r.full_teams || 0} ${this.escapeHtml(this._t('roster_full', 'FULL').toLowerCase())}</small></div>
       <div class="db-rows">${rows}</div>`);
  }

  _kitCell(k) {
    const players = Number(k.players) || 0, numbered = Number(k.numbered) || 0, missing = players - numbered;
    const tone = DashboardScreen.tone(players > 0 ? missing / players : 0);
    const name = { M: this._t('rsvp_sec_M', 'Men'), W: this._t('rsvp_sec_W', 'Women'), B: this._t('rsvp_sec_B', 'Youth'), G: this._t('rsvp_sec_G', 'Girls') };
    const rows = (k.sections || []).map(s => {
      const m = (s.players || 0) - (s.numbered || 0);
      return `<div class="db-row"><span class="l">${this.escapeHtml(name[s.code] || s.code || '—')}</span>
        <span class="r ${m ? DashboardScreen.tone(m / Math.max(1, s.players)) : 'ok'}">${s.numbered} <span style="opacity:0.6; font-weight:400;">/ ${s.players}</span></span></div>`;
    }).join('');
    return this._cell(tone, 'kit', this._t('kit_title', '👕 Uniform numbers'), this._t('kit_sub', 'Players on a roster who have a number'),
      `<div class="db-big">${numbered}<small>/ ${players} · ${this.escapeHtml(this._t('kit_missing', '{n} without a number', { n: missing }))}</small></div>
       <div class="db-rows">${rows}</div>`);
  }

  _leadsCell(l) {
    const n = Number(l.new_total) || 0, active = Number(l.new_on_active) || 0, fu = Number(l.needs_followup) || 0;
    const tone = active === 0 ? 'ok' : (Number(l.oldest_active_hours) || 0) > 48 ? 'bad' : 'warn';
    const stat = (k, v, t) => `<div class="db-stat ${t || ''}"><div class="k">${this.escapeHtml(k)}</div><div class="v">${v}</div></div>`;
    const sub = n === 0 ? this._t('leads_clear', 'Everyone contacted')
      : `${this._t('leads_active', '{n} on a running ad', { n: active })}${active ? ' · ' + this._t('leads_oldest', 'oldest waiting {hours} h', { hours: l.oldest_active_hours || 0 }) : ''}`;
    return this._cell(tone, 'leads', this._t('leads_title', '📋 Leads'), this._t('leads_sub', 'Ad leads nobody has contacted yet'),
      `<div class="db-big">${n}<small>${this.escapeHtml(this._t('leads_new', 'Not contacted').toLowerCase())} · ${this.escapeHtml(sub)}</small></div>
       <div class="db-stats">
         ${stat(this._t('leads_followup', 'Due a follow-up'), fu, fu ? 'warn' : '')}
         ${stat(this._t('leads_week', 'This week'), l.new_this_week || 0, '')}
         ${stat(this._t('leads_responded', 'Responded'), l.responded || 0, '')}
         ${stat(this._t('leads_signedup', 'Signed up'), l.signedup || 0, 'ok')}
       </div>`);
  }
}
