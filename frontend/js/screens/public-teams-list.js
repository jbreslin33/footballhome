// PublicTeamsListScreen — auth-less directory of active teams (#schedules),
// grouped by club section, each linking to the league's own season schedule
// (team_schedule_links, mig 361) and/or that team's public FH schedule page
// (#t/<slug>/schedule — see public-team.js). This is the "see ahead of this
// week without RSVP" page — it holds no schedule data itself, it just fans
// a visitor out to the pages that do. Linked from the Schedules pill on #my.
class PublicTeamsListScreen extends Screen {
  onEnter() {
    const root = this.find('#ptl-root');
    if (root) root.innerHTML = this.pageShell(`<div style="text-align:center; padding:60px 20px; opacity:0.7;">Loading…</div>`);
    fetch('/api/public/teams')
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(body => { if (this.isMounted) this.renderTeams(body.data || []); })
      .catch(err => { if (this.isMounted) this.renderError(err.message); });
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

    let body = '';
    for (const [section, teamsInGroup] of groups) {
      body += `
        <div style="margin-bottom:28px;">
          <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6; margin-bottom:10px;">
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

  // A team row carries up to two kinds of link: the league's own season
  // schedule (team_schedule_links, mig 361 — opens the league site) and
  // the FH schedule page (#t/<slug>/schedule) when the team has a slug.
  // Both are read-only; RSVPs stay on #my for the released week.
  renderTeamRow(t) {
    const sub = t.division_name ? this.escapeHtml(t.division_name) : '';
    const linkStyle = 'font-size:13px; font-weight:600; color:#f5d442; text-decoration:none; white-space:nowrap;';
    const links = (t.links || []).map(l => `
      <a href="${this.escapeHtml(l.url)}" target="_blank" rel="noopener" style="${linkStyle}">${this.escapeHtml(l.label)} ↗</a>`);
    if (t.slug) {
      links.push(`
      <a href="#t/${encodeURIComponent(t.slug)}/schedule" style="${linkStyle}">Schedule →</a>`);
    }
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
          ${bodyHtml}
        </div>
      </div>
    `;
  }
}
