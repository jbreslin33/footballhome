// PublicScreenBase - common header/nav/loading shell for public team views.
// All public screens are auth-less; they fetch /api/public/teams/:slug/...
class PublicScreenBase extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.slug = null;
    this.teamData = null;
  }

  // The active link key: 'gameday' | 'lineup' | 'schedule'
  get activeNav() { return ''; }

  onEnter(params = {}) {
    this.slug = params.slug || this.slug;
    if (!this.slug) {
      this.showError('No team slug provided');
      return;
    }
    this.loadTeam();
  }

  loadTeam() {
    fetch(`/api/public/teams/${encodeURIComponent(this.slug)}`)
      .then(r => {
        if (!r.ok) throw new Error(r.status === 404 ? 'Team not found' : `HTTP ${r.status}`);
        return r.json();
      })
      .then(data => {
        if (!this.isMounted) return;
        this.teamData = data.team || data;
        this.renderHeader();
        this.loadContent();
      })
      .catch(err => {
        if (this.isMounted) this.showError(err.message);
      });
  }

  // Subclasses implement
  loadContent() {}

  render() {
    const el = document.createElement('div');
    el.className = 'screen public-screen';
    el.innerHTML = `
      <div id="public-header-slot"></div>
      <div id="public-content-slot">
        <div class="public-loading">Loading…</div>
      </div>
    `;
    this.element = el;
    return el;
  }

  renderHeader() {
    const slot = this.find('#public-header-slot');
    if (!slot || !this.teamData) return;
    const t = this.teamData;
    const slug = encodeURIComponent(this.slug);
    const navLink = (key, label) => {
      const cls = this.activeNav === key ? 'active' : '';
      return `<a class="${cls}" href="#t/${slug}/${key}">${label}</a>`;
    };
    const logo = t.logo_url
      ? `<img src="${this.resolveAssetUrl(t.logo_url)}" alt="${this.escapeHtml(t.name)}">`
      : '⚽';
    slot.innerHTML = `
      <div class="public-header">
        <div class="logo">${logo}</div>
        <div>
          <div class="team-name">${this.escapeHtml(t.name || '')}</div>
          <div class="team-meta">${this.escapeHtml(t.division_name || t.city || '')}</div>
        </div>
        <div class="nav-links">
          ${navLink('gameday', 'Game Day')}
          ${navLink('lineup', 'Lineup')}
          ${navLink('schedule', 'Schedule')}
        </div>
      </div>
    `;
  }

  setContent(html) {
    const slot = this.find('#public-content-slot');
    if (slot) slot.innerHTML = html;
  }

  showError(msg) {
    this.setContent(`<div class="public-error">⚠️ ${this.escapeHtml(msg)}</div>`);
  }

  onExit() { /* nothing to clean up */ }

  fmtDate(iso) {
    if (!iso) return { d: '?', m: '' };
    const d = new Date(iso);
    if (isNaN(d.getTime())) return { d: '?', m: '' };
    return {
      d: String(d.getDate()),
      m: d.toLocaleString('en-US', { month: 'short' })
    };
  }
}

// PublicGamedayScreen — Instagram-style 18/20 alphabetical roster card
class PublicGamedayScreen extends PublicScreenBase {
  get activeNav() { return 'gameday'; }

  loadContent() {
    fetch(`/api/public/teams/${encodeURIComponent(this.slug)}/gameday`)
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(data => { if (this.isMounted) this.renderGameday(data); })
      .catch(err => { if (this.isMounted) this.showError(err.message); });
  }

  renderGameday(data) {
    if (!data.match) {
      this.setContent(`<div class="public-empty">No upcoming match scheduled.</div>`);
      return;
    }
    const m = data.match;
    const venue = m.venue_name ? ` · ${this.escapeHtml(m.venue_name)}` : '';
    const opp = m.is_home
      ? this.escapeHtml(m.away_team_name || 'TBD')
      : this.escapeHtml(m.home_team_name || 'TBD');
    const homeAway = m.is_home ? 'vs' : '@';

    let body;
    if (data.hidden) {
      const n = data.player_count != null
        ? `${data.player_count} player${data.player_count === 1 ? '' : 's'} selected`
        : 'Roster not yet published';
      body = `<div class="public-empty">🙈 Players to be selected soon<br><span style="font-size:12px;opacity:0.7;">${n}</span></div>`;
    } else {
      const players = (data.players || []).slice().sort((a, b) => {
        const an = (a.last_name || '') + (a.first_name || '');
        const bn = (b.last_name || '') + (b.first_name || '');
        return an.localeCompare(bn);
      });
      if (players.length === 0) {
        body = `<div class="public-empty">No players on the roster yet.</div>`;
      } else {
        body = `
          <div class="gameday-roster-list">
            ${players.map(p => `
              <div class="player">
                <span class="num">${p.jersey_number != null ? '#' + this.escapeHtml(String(p.jersey_number)) : ''}</span>
                <span class="name">${this.escapeHtml((p.first_name || '') + ' ' + (p.last_name || ''))}</span>
              </div>
            `).join('')}
          </div>
        `;
      }
    }

    const dateStr = m.match_date
      ? new Date(m.match_date).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })
      : '';

    this.setContent(`
      <div class="public-card gameday-card">
        <h2>${homeAway} ${opp}</h2>
        <div class="subtitle">${this.escapeHtml(dateStr)}${this.escapeHtml(m.match_time ? ' · ' + m.match_time : '')}${venue}</div>
        ${body}
      </div>
    `);
  }
}

// PublicLineupScreen — starters / bench (private until coach publishes)
class PublicLineupScreen extends PublicScreenBase {
  get activeNav() { return 'lineup'; }

  loadContent() {
    fetch(`/api/public/teams/${encodeURIComponent(this.slug)}/lineup`)
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(data => { if (this.isMounted) this.renderLineup(data); })
      .catch(err => { if (this.isMounted) this.showError(err.message); });
  }

  renderSlot(p, anon) {
    if (anon) {
      return `
        <div class="lineup-slot">
          <span class="pos">${this.escapeHtml(p.position_name || '—')}</span>
          <span class="name">Player ${p.slot_number || ''}</span>
        </div>
      `;
    }
    return `
      <div class="lineup-slot">
        <span class="pos">${this.escapeHtml(p.position_name || '—')}</span>
        <span class="name">${this.escapeHtml((p.first_name || '') + ' ' + (p.last_name || ''))}</span>
        ${p.jersey_number != null ? `<span class="num">#${this.escapeHtml(String(p.jersey_number))}</span>` : ''}
      </div>
    `;
  }

  renderLineup(data) {
    if (!data.match) {
      this.setContent(`<div class="public-empty">No upcoming match.</div>`);
      return;
    }
    const m = data.match;
    const anon = !!data.hidden;
    const starters = data.starters || [];
    const bench = data.bench || [];

    const banner = anon
      ? `<div class="public-card" style="text-align:center;opacity:0.85;">🔒 Lineup not yet published — showing layout only</div>`
      : '';

    const opp = m.is_home
      ? this.escapeHtml(m.away_team_name || 'TBD')
      : this.escapeHtml(m.home_team_name || 'TBD');
    const dateStr = m.match_date
      ? new Date(m.match_date).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })
      : '';

    this.setContent(`
      <div class="public-card">
        <h2 style="margin:0 0 6px;">${m.is_home ? 'vs' : '@'} ${opp}</h2>
        <div style="opacity:0.7;font-size:14px;">${this.escapeHtml(dateStr)}</div>
      </div>
      ${banner}
      <div class="public-card lineup-section">
        <h3>Starting XI</h3>
        ${starters.length === 0
          ? `<div class="public-empty">No starters selected.</div>`
          : `<div class="lineup-grid">${starters.map(p => this.renderSlot(p, anon)).join('')}</div>`}
      </div>
      <div class="public-card lineup-section">
        <h3>Bench</h3>
        ${bench.length === 0
          ? `<div class="public-empty">No bench players.</div>`
          : `<div class="lineup-grid">${bench.map(p => this.renderSlot(p, anon)).join('')}</div>`}
      </div>
    `);
  }
}

// PublicScheduleScreen — chronological match list with 📍 LIVE indicator
class PublicScheduleScreen extends PublicScreenBase {
  get activeNav() { return 'schedule'; }

  loadContent() {
    fetch(`/api/public/teams/${encodeURIComponent(this.slug)}/schedule`)
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(data => { if (this.isMounted) this.renderSchedule(data); })
      .catch(err => { if (this.isMounted) this.showError(err.message); });
  }

  renderSchedule(data) {
    const matches = data.matches || [];
    if (matches.length === 0) {
      this.setContent(`<div class="public-empty">No matches scheduled.</div>`);
      return;
    }

    // Group by month
    const groups = new Map();
    for (const m of matches) {
      const d = m.match_date ? new Date(m.match_date) : null;
      const key = d ? d.toLocaleString('en-US', { month: 'long', year: 'numeric' }) : 'TBD';
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(m);
    }

    let html = '<div class="public-card">';
    let liveAnchor = null;
    for (const [month, ms] of groups) {
      html += `<div class="schedule-month-header">${this.escapeHtml(month)}</div>`;
      for (const m of ms) {
        const dm = this.fmtDate(m.match_date);
        const opp = m.is_home
          ? this.escapeHtml(m.away_team_name || 'TBD')
          : this.escapeHtml(m.home_team_name || 'TBD');
        const venue = m.venue_name ? this.escapeHtml(m.venue_name) : '';
        const score = (m.home_score != null && m.away_score != null)
          ? `${m.home_score} - ${m.away_score}`
          : (m.match_time ? this.escapeHtml(m.match_time) : '');
        const liveCls = m.is_live ? ' is-live' : '';
        const liveBadge = m.is_live ? `<span class="live-badge">📍 LIVE</span>` : '';
        const anchorId = m.is_live ? ` id="live-match"` : '';
        if (m.is_live) liveAnchor = true;
        html += `
          <div class="schedule-row${liveCls}"${anchorId}>
            <div class="date"><div class="d">${dm.d}</div><div class="m">${dm.m}</div></div>
            <div class="opp">
              <div class="opp-name">${liveBadge}${m.is_home ? 'vs' : '@'} ${opp}</div>
              <div class="opp-meta">${venue}</div>
            </div>
            <div class="score">${score}</div>
          </div>
        `;
      }
    }
    html += '</div>';
    this.setContent(html);

    if (liveAnchor) {
      // Scroll the live match into view shortly after render.
      setTimeout(() => {
        const el = document.getElementById('live-match');
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }, 100);
    }
  }
}
