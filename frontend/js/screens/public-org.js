// PublicOrgScreen — footballhome.org/<slug>, the public page of a club or
// league (migration 632).  Signed out it is the club's front door (crest,
// sections + teams, join buttons); signed in it adds the way into the
// app.  Everything comes from GET /api/orgs/<slug> — headings are
// message_templates kind='org_page', buttons organization_page_links —
// so this screen holds no wording and nothing about any one club.
class PublicOrgScreen extends Screen {
  onEnter(params = {}) {
    this.slug = params.slug;
    const root = this.find('#porg-root');
    if (root) root.innerHTML = this.pageShell(`<div style="text-align:center; padding:60px 20px; opacity:0.7;">…</div>`);
    fetch(`/api/orgs/${encodeURIComponent(this.slug)}`)
      .then(r => {
        // No organization at this address: boot the app as if the visitor
        // had typed footballhome.org.
        if (r.status === 404) { window.location.replace('/'); return null; }
        return r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`));
      })
      .then(body => { if (body && this.isMounted) this.renderPage(body.data || {}); })
      .catch(err => { if (this.isMounted) this.renderError(err.message); });
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `<div id="porg-root"></div>`;
    this.element = el;
    return el;
  }

  renderError(msg) {
    const root = this.find('#porg-root');
    if (root) root.innerHTML = this.pageShell(`<div style="text-align:center; padding:40px 20px; color:#f5a3a3;">⚠️ ${this.escapeHtml(msg)}</div>`);
  }

  renderPage(org) {
    const root = this.find('#porg-root');
    if (!root) return;
    document.title = org.name || document.title;
    const copy = org.copy || {};
    const text = (tier, tokens = {}) => this.escapeHtml(MessageCopy.fill(copy[tier] || '', tokens));
    const links = org.links || {};
    const signedIn = !!(this.auth && this.auth.isLoggedIn && this.auth.isLoggedIn());

    const header = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:10px; text-align:center; margin-bottom:32px;">
        ${org.logo_url ? `<img src="${this.escapeHtml(org.logo_url)}" alt="" style="width:104px; height:104px; object-fit:contain;">` : ''}
        <h1 style="font-size:30px; font-weight:900; letter-spacing:1px; margin:0;">${this.escapeHtml(org.name || '')}</h1>
        ${org.founded_year ? `<div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.65;">${text('founded', { year: org.founded_year })}</div>` : ''}
      </div>`;

    const members = `
      ${this.heading(text('members_heading'))}
      ${this.button(signedIn ? text('open_app') : text('sign_in'), '/', true)}`;

    const join = (links.join || []).length ? `
      ${this.heading(text('join_heading'))}
      ${links.join.map(l => this.button(this.escapeHtml(l.label), l.url, true)).join('')}` : '';

    const sections = (org.sections || []).length ? `
      ${this.heading(text('sections_heading'))}
      ${org.sections.map(s => this.sectionCard(s, text)).join('')}` : '';

    const more = (links.more || []).length ? `
      ${this.heading(text('more_heading'))}
      ${links.more.map(l => this.button(this.escapeHtml(l.label), l.url, false)).join('')}` : '';

    const contact = org.contact_email ? `
      <div style="text-align:center; margin-top:36px; opacity:0.6; font-size:13px;">
        ${MessageCopy.fill(this.escapeHtml(copy.contact || ''), {
          email: `<a href="mailto:${this.escapeHtml(org.contact_email)}" style="color:#f5d442;">${this.escapeHtml(org.contact_email)}</a>`,
        })}
      </div>` : '';

    // Members first when signed in (they came to use the app); the
    // join buttons first for everyone else.
    root.innerHTML = this.pageShell(header + (signedIn ? members + join : join + members) + sections + more + contact);
  }

  sectionCard(s, text) {
    const chips = (s.teams || []).map(t => `
      <span title="${this.escapeHtml(t.division || '')}"
            style="display:inline-block; padding:4px 10px; border-radius:999px; font-size:12px; font-weight:600;
                   background:rgba(255,255,255,0.08); border:1px solid rgba(255,255,255,0.15);">${this.escapeHtml(t.label || t.name)}</span>`).join('');
    return `
      <div style="background:rgba(255,255,255,0.06); border-radius:14px; padding:14px 16px; margin-bottom:10px;">
        <div style="display:flex; align-items:baseline; justify-content:space-between; gap:12px; margin-bottom:10px;">
          <div style="font-weight:800; font-size:17px;">${this.escapeHtml(s.name)}</div>
          ${s.founded_year ? `<div style="font-size:12px; opacity:0.6;">${text('section_since', { year: s.founded_year })}</div>` : ''}
        </div>
        <div style="display:flex; flex-wrap:wrap; gap:6px;">${chips}</div>
      </div>`;
  }

  heading(label) {
    return `<div style="font-size:13px; letter-spacing:2px; text-transform:uppercase; opacity:0.6; margin:28px 0 10px;">${label}</div>`;
  }

  // label arrives escaped.  primary = the gold call-to-action style.
  button(label, url, primary) {
    const external = /^https?:\/\//i.test(url);
    return `
      <a href="${this.escapeHtml(url)}"${external ? ' target="_blank" rel="noopener"' : ''}
         style="display:block; text-align:center; font-weight:800; font-size:16px; padding:14px 20px; border-radius:12px;
                text-decoration:none; margin-bottom:10px; box-sizing:border-box;
                ${primary ? 'background:#f5d442; color:#0a1628;' : 'background:rgba(255,255,255,0.08); color:#fff; border:1px solid rgba(255,255,255,0.2);'}">
        ${label}${external ? ' ↗' : ''}
      </a>`;
  }

  pageShell(bodyHtml) {
    return `
      <div style="min-height:100vh; background:linear-gradient(160deg,#0D2A52 0%,#0a1628 55%,#0D2A52 100%); color:#fff; font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;">
        <div style="max-width:720px; margin:0 auto; padding:32px 16px 60px; box-sizing:border-box;">
          ${bodyHtml}
        </div>
      </div>`;
  }
}
