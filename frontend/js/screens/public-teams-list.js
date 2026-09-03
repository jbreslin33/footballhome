// PublicTeamsListScreen — auth-less directory of active teams (#teams),
// grouped by gender category, each linking to that team's existing public
// schedule page (#t/<slug>/schedule — see public-team.js). This is the
// "footballhome page for the long-term schedule of each team" — it doesn't
// hold schedule data itself, it just fans a visitor out to the per-team
// page that already does.
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

  static get CATEGORY_LABELS() {
    return { mens: "Men's", womens: "Women's", boys: 'Boys', girls: 'Girls' };
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

    const groups = new Map();
    for (const t of teams) {
      const key = t.gender_category || 'other';
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(t);
    }

    const order = ['mens', 'womens', 'boys', 'girls', 'other'];
    const labels = PublicTeamsListScreen.CATEGORY_LABELS;
    let body = '';
    for (const key of order) {
      const teamsInGroup = groups.get(key);
      if (!teamsInGroup || teamsInGroup.length === 0) continue;
      body += `
        <div style="margin-bottom:28px;">
          <div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6; margin-bottom:10px;">
            ${this.escapeHtml(labels[key] || 'Other')}
          </div>
          <div style="display:flex; flex-direction:column; gap:8px;">
            ${teamsInGroup.map(t => this.renderTeamRow(t)).join('')}
          </div>
        </div>
      `;
    }

    root.innerHTML = this.pageShell(body);
  }

  renderTeamRow(t) {
    const slug = encodeURIComponent(t.slug);
    const sub = t.division_name ? this.escapeHtml(t.division_name) : '';
    return `
      <a href="#t/${slug}/schedule" style="display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.06); border-radius:12px; padding:12px 16px; text-decoration:none; color:#fff;">
        ${this.buildTeamLogoMarkup(t.logo_url, { className: 'team-logo', placeholder: '⚽' })}
        <div style="flex:1; min-width:0;">
          <div style="font-weight:700;">${this.escapeHtml(t.name)}</div>
          ${sub ? `<div style="font-size:12px; opacity:0.65;">${sub}</div>` : ''}
        </div>
        <div style="font-size:13px; font-weight:600; color:#f5d442;">Schedule →</div>
      </a>
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
