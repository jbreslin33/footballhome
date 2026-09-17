// PublicTeamsListScreen — auth-less directory of active teams (#schedules),
// grouped by club section, each linking to the league's own season schedule
// (team_schedule_links, mig 361), plus a view-only "My schedule ahead" list
// for signed-in members. This is the "see ahead of this week without RSVP"
// page. Linked from the Schedules pill on #my.
class PublicTeamsListScreen extends Screen {
  onEnter() {
    const root = this.find('#ptl-root');
    if (root) root.innerHTML = this.pageShell(`<div style="text-align:center; padding:60px 20px; opacity:0.7;">Loading…</div>`);
    fetch('/api/public/teams')
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(body => { if (this.isMounted) this.renderTeams(body.data || []); })
      .catch(err => { if (this.isMounted) this.renderError(err.message); })
      // renderTeams/renderError repaint the whole shell, #ptl-ahead included.
      .then(() => { if (this.isMounted) this.renderAhead(); });
    this.loadAhead();
  }

  // ── Schedule ahead (signed-in members only, view only) ─────────────
  //
  // Owner 2026-09-17: "future view only on the special schedules page.
  // not on my page. they have to click schedules from my."  #my keeps
  // showing only the released week (schedule_window_end) and is the only
  // place to RSVP; this list ignores the release window on purpose and
  // renders no RSVP controls.  Same endpoint as #my, so it is already
  // scoped to the caller's teams (or their children's) and carries the
  // calendar's opponent / location / kind.  90 days is the server's cap.
  loadAhead() {
    this.ahead = null;
    this.aheadKind = 'all';
    this.aheadTeam = '';
    this.aheadLoading = !!(this.auth && this.auth.isLoggedIn && this.auth.isLoggedIn());
    this.renderAhead();
    const doFetch = (this.auth && typeof this.auth.fetch === 'function')
      ? (u) => this.auth.fetch(u)
      : (u) => fetch(u, { credentials: 'same-origin' });
    doFetch('/api/calendar/upcoming?days=90')
      .then(r => r.ok ? r.json() : null)
      .then(body => {
        this.aheadLoading = false;
        if (!this.isMounted) return;
        if (!body || !body.signed_in) { const slot = this.find('#ptl-ahead'); if (slot) slot.innerHTML = ''; return; }
        const now = Date.now();
        this.ahead = (body.events || []).filter(e => {
          const kind = (e.kind || '').toLowerCase();
          if ((e.category || '').toLowerCase() === 'staff') return false;
          if (!['pickup', 'practice', 'match', 'barn night', 'intrasquad'].includes(kind)) return false;
          const end = new Date(e.ends_at || e.starts_at);
          return !isNaN(end) && end.getTime() > now;
        });
        this.renderAhead();
      })
      .catch(err => console.warn('[schedules] ahead failed:', err));
  }

  renderAhead() {
    const slot = this.find('#ptl-ahead');
    if (!slot) return;
    if (!this.ahead) {
      // 90 days of events takes a second or two; say so for members
      // (signed-out visitors never get this section, so no note for them).
      if (this.aheadLoading) slot.innerHTML = `<div style="font-size:12px; opacity:0.6; margin-bottom:24px;">Loading your schedule…</div>`;
      return;
    }

    // Team picker only when the caller sees more than one team
    // (coaches, admins, multi-team players, parents of two kids).
    const teamNames = new Map();
    for (const e of this.ahead) for (const t of (e.teams || [])) {
      if (t && t.id != null) teamNames.set(String(t.id), t.label || t.display_name || t.name || `Team ${t.id}`);
    }
    const kindOf = (e) => (e.kind || '').toLowerCase() === 'match' ? 'games' : 'practices';
    const list = this.ahead.filter(e =>
      (this.aheadKind === 'all' || kindOf(e) === this.aheadKind) &&
      (!this.aheadTeam || (e.teams || []).some(t => String(t.id) === this.aheadTeam)));

    const pill = (key, label) => `
      <button type="button" data-ahead-kind="${key}"
              style="padding:5px 12px; border-radius:999px; cursor:pointer; font-size:12px; font-weight:700;
                     border:1px solid rgba(255,255,255,0.25);
                     background:${this.aheadKind === key ? '#f5d442' : 'transparent'};
                     color:${this.aheadKind === key ? '#0a1628' : '#fff'};">${label}</button>`;
    const teamSelect = teamNames.size > 1 ? `
      <select data-ahead-team style="padding:5px 8px; border-radius:8px; font-size:12px; background:#0a1628; color:#fff; border:1px solid rgba(255,255,255,0.25);">
        <option value="">All my teams</option>
        ${[...teamNames].map(([id, name]) =>
          `<option value="${this.escapeHtml(id)}"${id === this.aheadTeam ? ' selected' : ''}>${this.escapeHtml(name)}</option>`).join('')}
      </select>` : '';

    let rows = '';
    let lastWeek = null;
    for (const e of list) {
      const start = new Date(e.starts_at);
      const week = this._weekLabel(start);
      if (week !== lastWeek) {
        rows += `<div style="font-size:12px; letter-spacing:1.5px; text-transform:uppercase; opacity:0.6; margin:16px 0 6px;">${this.escapeHtml(week)}</div>`;
        lastWeek = week;
      }
      rows += this._renderAheadRow(e, start);
    }
    if (!rows) rows = `<div style="opacity:0.7; padding:12px 0;">Nothing scheduled in the next 90 days.</div>`;

    slot.innerHTML = `
      <div style="margin-bottom:32px;">
        <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6; margin-bottom:4px;">My schedule ahead</div>
        <div style="font-size:12px; opacity:0.7; margin-bottom:10px;">
          Next 90 days, view only. Times can change — RSVP on <a href="#my" style="color:#f5d442;">My page</a> when each week posts.
        </div>
        <div style="display:flex; flex-wrap:wrap; gap:6px; align-items:center;">
          ${pill('all', 'All')}${pill('games', 'Games')}${pill('practices', 'Practices')}${teamSelect}
        </div>
        ${rows}
      </div>`;

    slot.querySelectorAll('[data-ahead-kind]').forEach(b => b.addEventListener('click', () => {
      this.aheadKind = b.dataset.aheadKind;
      this.renderAhead();
    }));
    const sel = slot.querySelector('[data-ahead-team]');
    if (sel) sel.addEventListener('change', () => { this.aheadTeam = sel.value; this.renderAhead(); });
  }

  // "This week" / "Next week" / "Week of Sep 28" — weeks run Mon–Sun.
  _weekLabel(d) {
    const monday = (x) => {
      const m = new Date(x.getFullYear(), x.getMonth(), x.getDate());
      m.setDate(m.getDate() - ((m.getDay() + 6) % 7));
      return m;
    };
    const diff = Math.round((monday(d) - monday(new Date())) / (7 * 24 * 3600 * 1000));
    if (diff <= 0) return 'This week';
    if (diff === 1) return 'Next week';
    return `Week of ${monday(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`;
  }

  _renderAheadRow(e, start) {
    // Same player-facing title #my uses (kind label + opponent, never
    // the raw gcal summary — that one is admin-only).
    const my = window.app && window.app.screens && window.app.screens.my;
    const title = (my && typeof my._eventTitle === 'function')
      ? my._eventTitle(e)
      : ((e.kind || '').toLowerCase() === 'match' ? `Game${e.opponent ? ` vs ${e.opponent}` : ''}` : 'Practice');
    const isGame = (e.kind || '').toLowerCase() === 'match';
    const homeAway = isGame && e.is_home != null ? (e.is_home ? 'Home' : 'Away') : '';
    const fmtTime = (x) => x.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    const end = e.ends_at ? new Date(e.ends_at) : null;
    const time = e.all_day ? 'All day'
      : `${fmtTime(start)}${end && !isNaN(end) ? ` – ${fmtTime(end)}` : ''}`;
    const teams = (e.teams || []).map(t => t.label || t.display_name || t.name).filter(Boolean).join(' · ');
    const meta = [time, homeAway, e.location].filter(Boolean).map(x => this.escapeHtml(x)).join(' · ');
    // guardian_children: the server's display string naming whose event
    // this is, set only when the caller sees it as a parent.
    const kids = typeof e.guardian_children === 'string' ? e.guardian_children : '';
    return `
      <div style="display:flex; align-items:center; gap:12px; background:rgba(255,255,255,${isGame ? '0.10' : '0.05'}); border-radius:12px; padding:10px 14px; margin-bottom:6px;
                  border-left:3px solid ${isGame ? '#f5d442' : 'rgba(255,255,255,0.2)'};">
        <div style="width:44px; text-align:center; flex-shrink:0;">
          <div style="font-size:11px; opacity:0.65; text-transform:uppercase;">${start.toLocaleDateString('en-US', { weekday: 'short' })}</div>
          <div style="font-size:20px; font-weight:800; line-height:1;">${start.getDate()}</div>
          <div style="font-size:11px; opacity:0.65; text-transform:uppercase;">${start.toLocaleDateString('en-US', { month: 'short' })}</div>
        </div>
        <div style="flex:1; min-width:0;">
          <div style="font-weight:700;">${this.escapeHtml(title)}</div>
          <div style="font-size:12px; opacity:0.75;">${meta}</div>
          ${(teams || kids) ? `<div style="font-size:11px; opacity:0.55;">${this.escapeHtml([teams, kids && `for ${kids}`].filter(Boolean).join(' — '))}</div>` : ''}
        </div>
      </div>`;
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `<div id="ptl-root"></div>`;
    this.element = el;
    return el;
  }

  renderError(msg) {
    const root = this.find('#ptl-root');
    if (root) root.innerHTML = this.pageShell(`<div style="text-align:center; padding:40px 20px; color:#f5a3a3;">⚠️ ${this.escapeHtml(msg)}</div>`);
  }

  renderTeams(teams) {
    const root = this.find('#ptl-root');
    if (!root) return;

    if (teams.length === 0) {
      root.innerHTML = this.pageShell(`<div style="text-align:center; padding:40px 20px; opacity:0.7;">No teams to show yet.</div>`);
      return;
    }

    // Sections arrive in club_sections.sort_order (Men, Women, Boys,
    // Girls); Girls repeats the Boys teams because girls play on them.
    const groups = new Map();
    for (const t of teams) {
      if (!groups.has(t.section)) groups.set(t.section, []);
      groups.get(t.section).push(t);
    }

    let body = `
      <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6; margin-bottom:4px;">League schedules</div>
      <div style="font-size:12px; opacity:0.7; margin-bottom:16px;">The full season on each league's own site.</div>`;
    for (const [section, teamsInGroup] of groups) {
      body += `
        <div style="margin-bottom:28px;">
          <div style="font-size:12px; letter-spacing:2px; text-transform:uppercase; opacity:0.45; margin-bottom:10px;">
            ${this.escapeHtml(section)}
          </div>
          <div style="display:flex; flex-direction:column; gap:8px;">
            ${teamsInGroup.map(t => this.renderTeamRow(t)).join('')}
          </div>
        </div>
      `;
    }

    root.innerHTML = this.pageShell(body);
  }

  // A team row links to the league's own season schedule
  // (team_schedule_links, mig 361 — opens the league site).  The old
  // #t/<slug>/schedule link was dropped 2026-09-17: "My schedule ahead"
  // above replaces it for members and that page reads the matches
  // table, which has no opponents for gcal-sourced games.
  renderTeamRow(t) {
    const sub = t.division_name ? this.escapeHtml(t.division_name) : '';
    const linkStyle = 'font-size:13px; font-weight:600; color:#f5d442; text-decoration:none; white-space:nowrap;';
    const links = (t.links || []).map(l => `
      <a href="${this.escapeHtml(l.url)}" target="_blank" rel="noopener" style="${linkStyle}">${this.escapeHtml(l.label)} ↗</a>`);
    return `
      <div style="display:flex; align-items:center; flex-wrap:wrap; gap:8px 12px; background:rgba(255,255,255,0.06); border-radius:12px; padding:12px 16px; color:#fff;">
        ${this.buildTeamLogoMarkup(t.logo_url, { className: 'team-logo', placeholder: '⚽' })}
        <div style="flex:1; min-width:140px;">
          <div style="font-weight:700;">${this.escapeHtml(t.name)}</div>
          ${sub ? `<div style="font-size:12px; opacity:0.65;">${sub}</div>` : ''}
        </div>
        <div style="display:flex; flex-direction:column; align-items:flex-end; gap:6px;">${links.join('')}</div>
      </div>
    `;
  }

  pageShell(bodyHtml) {
    return `
      <style>
        .team-logo { width:36px; height:36px; object-fit:contain; border-radius:6px; flex-shrink:0; }
        .team-logo-placeholder { width:36px; height:36px; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
      </style>
      <div style="min-height:100vh; background:linear-gradient(160deg,#0D2A52 0%,#0a1628 55%,#0D2A52 100%); color:#fff; font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;">
        <div class="narrow" style="max-width:720px; margin:0 auto; padding:32px 20px 60px; box-sizing:border-box;">
          <!-- The installed PWA has no browser back button, and #my links here. -->
          <a href="#my" style="font-size:13px; font-weight:600; color:#dbeafe; text-decoration:none;">← My page</a>
          <div style="display:flex; flex-direction:column; align-items:center; gap:10px; text-align:center; margin-bottom:28px;">
            <img src="/images/lighthouse-1893-crest.png" alt="Lighthouse 1893 crest" style="width:88px; height:88px; object-fit:contain;">
            <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6;">footballhome.org &middot; Lighthouse 1893</div>
            <div style="font-size:26px; font-weight:900; letter-spacing:1px;">Team Schedules</div>
          </div>
          <div id="ptl-ahead"></div>
          ${bodyHtml}
        </div>
      </div>
    `;
  }
}
