// MessagesScreen — central copy-paste hub for all club outreach messages.
//
// Lives under Club Admin → 💬 Messages.  Pulls its copy from the same
// canonical source as the Leads page (`LeadsScreen.prototype.funnelContext`
// / `.messageTemplate` / `.messageSnippets`) so any tweak to the leads
// follow-up copy automatically flows through here too.  We reuse the
// LeadsScreen methods via a tiny prototype-only helper instance — no
// duplicate copy, no second source of truth.
//
// What this page IS:
//   • Coach picks a team (funnel) on the left.
//   • Right pane shows every canned response for that team — initial
//     email, welcome blurb, register CTA, schedule, cost, etc. — each
//     with a one-tap "Copy" button.
//   • Quick-links strip at the top: handbook, roster, game chat,
//     practice chat, pickup chat (only the ones that exist for that
//     team — TODOs are skipped silently).
//
// What this page is NOT:
//   • Not a per-lead screen.  No phone number, no lead context, no
//     send-as-email/SMS handoff.  Use the Leads page for that — this
//     page is purely a "I'm replying to someone in WhatsApp /
//     wherever and need the canonical wording" reference.
//
// Token substitution:
//   {first} → "[first name]"  (placeholder — coach swaps in by hand)
//   {coach} → "Coach <first_name>" from the logged-in user (matches the
//             same fallback rule as Leads), or just "Coach" if not signed
//             in with a known first name.

class MessagesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);

    this._templates = [];
    this._templateError = null;

    // Share LeadsScreen's per-funnel copy methods by binding them to a
    // bare prototype shell — gives us funnelContext/messageTemplate/
    // messageSnippets/formLabel/fillTemplate without instantiating a
    // real LeadsScreen (which would try to render and fetch leads).
    // _nextPickup is read by the Pickup snippet body; null is fine —
    // it just falls through to the generic invite wording.
    this._helper = Object.create(LeadsScreen.prototype);
    this._helper.auth = auth;
    this._helper._nextPickup = null;

    // Canonical funnel label order — same list rendered as columns on
    // the Leads page.  Funnels at the top are the ones we actively
    // chase; keep them most-accessible.
    this._funnels = [
      'PR Men', 'U23 Men', 'U23 Men + PR', "Men's Club",
      'APSL / Liga 1',
      'U23 Women', 'Tri County Women', "Women's Club",
      'Boys Club (Grades 1–6)', 'Boys Club (K-12)', 'Boys Club (U11/U12)',
      'Girls Club (Grades 1–6)', 'Girls Club (K-12)', 'Girls Club (U11/U12)',
      'Youth (Grades 1–6)',
    ];

    this._selected = this._funnels[0];
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    // Layout is a 2-column grid on desktop (sticky team list + main
    // pane) that collapses to a single column on narrow viewports.
    // On mobile the team list becomes a horizontally-scrolling tab
    // strip pinned to the top of the main pane — same content, but
    // reachable with a thumb-swipe instead of eating half the screen.
    // Also caps snippet <pre> font-size on mobile so 90-char SMS
    // bodies don't force a horizontal scroll.
    div.innerHTML = `
      <style>
        .messages-layout {
          display: grid;
          grid-template-columns: 220px minmax(0, 1fr);
          gap: var(--space-4);
          padding: var(--space-4);
          align-items: start;
        }
        .messages-layout #messages-team-list {
          display: flex;
          flex-direction: column;
          gap: var(--space-2);
          position: sticky;
          top: var(--space-4);
        }
        @media (max-width: 720px) {
          .messages-layout {
            grid-template-columns: minmax(0, 1fr);
            gap: var(--space-2);
            padding: var(--space-2);
          }
          .messages-layout #messages-team-list {
            position: sticky;
            top: 0;
            flex-direction: row;
            overflow-x: auto;
            padding: var(--space-2) 0;
            background: var(--bg-primary, #0f172a);
            z-index: 2;
            -webkit-overflow-scrolling: touch;
          }
          .messages-layout #messages-team-list button {
            flex: 0 0 auto;
            white-space: nowrap;
          }
          .messages-layout #messages-body pre {
            font-size: 0.82rem !important;
          }
          .messages-layout #messages-body h2,
          .messages-layout #messages-body h3 {
            font-size: 1rem !important;
          }
        }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>💬 Messages</h1>
        <p class="subtitle">Canned responses & welcome messages for every team — pick a team, copy what you need.</p>
      </div>

      <div class="messages-layout">
        <aside id="messages-team-list"></aside>
        <main id="messages-body" style="min-width:0;"></main>
      </div>
    `;
    this.element = div;
    return div;
  }

  async onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const teamBtn = e.target.closest('[data-funnel]');
      if (teamBtn) {
        this._selected = teamBtn.dataset.funnel;
        this.renderTeamList();
        this.renderBody();
        return;
      }

      const copyBtn = e.target.closest('[data-copy-target]');
      if (copyBtn) {
        const sel = copyBtn.dataset.copyTarget;
        const src = this.element.querySelector(sel);
        if (src) {
          // If the source is flagged as HTML (rendered snippet body),
          // write BOTH text/html and text/plain to the clipboard so
          // pasting into a WYSIWYG editor (LeagueApps' program editor,
          // Gmail, etc.) preserves the bold/lists, while plain-text
          // targets still receive readable copy.
          if (src.dataset.copyHtml === '1') {
            this._copyHtml(src.innerHTML, src.textContent, copyBtn);
          } else {
            this._copy(src.textContent, copyBtn);
          }
        }
        return;
      }
    });

    this.renderTeamList();
    await this._loadTemplates();
    this.renderBody();
  }

  // Funnel-label colors match the Leads page so the same visual cue
  // (green = Brazil Men, blue = U23 Men, etc.) carries over.
  _funnelColor(label) {
    const c = {
      'Brazil Men':              '#15803d',
      'U23 Men':                 '#1d4ed8',
      'PR Men':                  '#7c3aed',
      'U23 Women':               '#be185d',
      'Tri County Women':        '#9d174d',
      "Men's Club":              '#1d4ed8',
      "Women's Club":            '#be185d',
      'APSL / Liga 1':           '#f59e0b',
      'Youth (Grades 1–6)':      '#c9a14a',
      'Boys Club (Grades 1–6)':  '#0e7490',
      'Boys Club (K-12)':        '#0e7490',
      'Boys Club (U11/U12)':     '#0e7490',
      'Girls Club (Grades 1–6)': '#db2777',
      'Girls Club (K-12)':       '#db2777',
      'Girls Club (U11/U12)':    '#db2777',
    };
    return c[label] || '#475569';
  }

  renderTeamList() {
    const list = this.find('#messages-team-list');
    list.innerHTML = this._funnels.map((label) => {
      const selected = label === this._selected;
      const color    = this._funnelColor(label);
      // Always set BOTH bg + text colors explicitly so the button is
      // readable on the app's dark navy theme.  Unselected: surface
      // bg + near-white text.  Selected: funnel color + white text.
      const styles = selected
        ? `background: ${color}; color: #ffffff; border: 1px solid ${color};`
        : `background: var(--bg-surface); color: var(--text-primary); border: 1px solid var(--border-color);`;
      return `
        <button data-funnel="${this.escapeHtml(label)}"
                type="button"
                style="display:flex; align-items:center; gap: var(--space-2); justify-content:flex-start; text-align:left; padding: var(--space-2) var(--space-3); border-left: 4px solid ${color}; border-radius: var(--radius-md); cursor: pointer; font: inherit; ${styles}">
          <span style="font-weight:600;">${this.escapeHtml(label)}</span>
        </button>
      `;
    }).join('');
  }

  async _loadTemplates() {
    try {
      const res = await this.auth.fetch('/api/messages/templates');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const payload = await res.json();
      const data = Array.isArray(payload?.data) ? payload.data : Array.isArray(payload) ? payload : [];
      this._templates = data.filter((t) => t && t.is_active !== false);
      this._templateError = null;
    } catch (err) {
      console.error('Failed to load message templates:', err);
      this._templates = [];
      this._templateError = err.message || 'Unable to load templates';
    }
  }

  // Replace {first}/{coach} so the coach can paste raw — no leftover
  // template tokens to confuse leads if they forget to edit.
  _personalize(text) {
    const me    = (this.auth && this.auth.getUser && this.auth.getUser()) || {};
    const coach = me.first_name ? `Coach ${me.first_name}` : 'Coach';
    return String(text || '')
      .replace(/\{first\}/g, '[first name]')
      .replace(/\{full\}/g,  '[full name]')
      .replace(/\{phone\}/g, '[phone]')
      .replace(/\{coach\}/g, coach);
  }

  // Copy helper — writes text to the clipboard and flashes the button.
  async _copy(text, btn) {
    try {
      await navigator.clipboard.writeText(text);
      const orig = btn.textContent;
      btn.textContent = '✅ Copied';
      btn.disabled = true;
      setTimeout(() => {
        btn.textContent = orig;
        btn.disabled = false;
      }, 1400);
    } catch (err) {
      console.error('Clipboard write failed:', err);
      // Fallback: select + execCommand for ancient browsers / missing
      // permission.  Best-effort; usually clipboard API just works.
      try {
        const ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        ta.remove();
        btn.textContent = '✅ Copied';
        setTimeout(() => { btn.textContent = '📋 Copy'; }, 1400);
      } catch {
        btn.textContent = '⚠️ Copy failed';
        setTimeout(() => { btn.textContent = '📋 Copy'; }, 1800);
      }
    }
  }

  // Copy an HTML snippet.  Writes text/html + text/plain via the async
  // Clipboard API so pasting into a WYSIWYG editor preserves formatting
  // (bold, lists, links) while plain-text targets still get readable
  // copy.  Falls back to plain text if ClipboardItem isn't available.
  async _copyHtml(html, text, btn) {
    try {
      if (typeof ClipboardItem !== 'undefined' && navigator.clipboard?.write) {
        const item = new ClipboardItem({
          'text/html':  new Blob([html], { type: 'text/html' }),
          'text/plain': new Blob([text], { type: 'text/plain' }),
        });
        await navigator.clipboard.write([item]);
      } else {
        await navigator.clipboard.writeText(text);
      }
      const orig = btn.textContent;
      btn.textContent = '✅ Copied';
      btn.disabled = true;
      setTimeout(() => {
        btn.textContent = orig;
        btn.disabled = false;
      }, 1400);
    } catch (err) {
      console.error('HTML clipboard write failed, falling back to text:', err);
      this._copy(text, btn);
    }
  }

  renderBody() {
    const body = this.find('#messages-body');
    const label = this._selected;
    if (!label) {
      body.innerHTML = '<div style="opacity:0.6; padding: var(--space-4); color: var(--text-primary);">Pick a team on the left.</div>';
      return;
    }

    const ctx      = this._helper.funnelContext(label);
    const template = this._helper.messageTemplate(label);
    const snippets = this._helper.messageSnippets(label);
    const color    = this._funnelColor(label);

    const subject = this._personalize(template.subject);
    const email   = this._personalize(template.email);
    const sms     = this._personalize(template.sms);

    const dbTemplates = this._templates.filter((t) => {
      const left = String(t.category || '').toLowerCase().replace(/[^a-z0-9]+/g, '');
      const right = String(label || '').toLowerCase().replace(/[^a-z0-9]+/g, '');
      return left === right;
    });
    const dbInitial = dbTemplates.filter((t) => t.kind === 'initial');
    const dbSnippets = dbTemplates.filter((t) => t.kind !== 'initial');

    body.innerHTML = `
      <div style="padding: var(--space-3); border-radius: 8px; background: ${color}; color: #ffffff; margin-bottom: var(--space-4);">
        <div style="font-size: 1.4rem; font-weight: 700; color: #ffffff;">${this.escapeHtml(label)}</div>
        <div style="opacity: 0.92; font-size: 0.9rem; margin-top: var(--space-1); color: #ffffff;">${this.escapeHtml(ctx.program)}</div>
      </div>

      ${this._renderQuickLinks(ctx)}
      ${this._renderTemplateSection('Initial email', dbInitial, subject, email)}
      ${this._renderTemplateSection('Initial SMS / WhatsApp', dbInitial.filter((t) => t.tier === 'sms'), null, sms)}
      ${this._renderSnippets(snippets)}
      ${this._renderDbSnippets(dbSnippets)}
    `;
  }

  _renderQuickLinks(ctx) {
    // Only show links that actually exist for this funnel — TODO_/null
    // entries get skipped so the strip never carries a dead link.
    const links = [];
    if (ctx.link)          links.push({ label: 'LeagueApps register ($35)', url: ctx.link, icon: '💳' });
    if (ctx.handbookLink)  links.push({ label: 'Handbook',                 url: ctx.handbookLink, icon: '📖' });
    if (ctx.rosterLink)    links.push({ label: 'League roster form',       url: ctx.rosterLink, icon: '📝' });
    if (ctx.gameChat)      links.push({ label: 'Game chat',                url: ctx.gameChat, icon: '🗓' });
    if (ctx.practiceLink)  links.push({ label: 'Practice chat',            url: ctx.practiceLink, icon: '🏃' });
    if (ctx.pickupLink)    links.push({ label: 'Pickup chat',              url: ctx.pickupLink, icon: '⚽' });
    if (ctx.schedule?.url) links.push({ label: `Schedule (${ctx.schedule.sourceOf || 'league'})`, url: ctx.schedule.url, icon: '📅' });

    if (!links.length) return '';

    return `
      <section style="margin-bottom: var(--space-4); padding: var(--space-3); border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-surface); color: var(--text-primary);">
        <div style="font-weight: 600; margin-bottom: var(--space-2); color: var(--text-primary);">🔗 Quick links</div>
        <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
          ${links.map((l) => `
            <a href="${this.escapeHtml(l.url)}" target="_blank" rel="noopener"
               class="btn btn-secondary"
               style="display:inline-flex; align-items:center; gap: 6px; font-size: 0.85rem; padding: 6px 10px;">
              ${l.icon} ${this.escapeHtml(l.label)}
            </a>
          `).join('')}
        </div>
      </section>
    `;
  }

  _renderTemplateSection(title, templates, subject, bodyText) {
    if (templates && templates.length) {
      return templates.map((template) => {
        const subjectId = `msg-${template.id || template.label || title}-subject`;
        const bodyId = `msg-${template.id || template.label || title}-body`;
        const bodyTextValue = this._personalize(template.body || bodyText || '');
        const subjectText = template.subject ? this._personalize(template.subject) : subject;
        const htmlBody = template.html_body ? this._personalize(template.html_body) : null;
        const bodyBlock = htmlBody
          ? `<div id="${bodyId}" data-copy-html="1" style="margin: 0; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; line-height: 1.55;">${htmlBody}</div>`
          : `<pre id="${bodyId}" style="flex:1; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; white-space: pre-wrap; word-wrap: break-word; margin: 0; font-family: inherit; line-height: 1.5;">${this.escapeHtml(bodyTextValue)}</pre>`;
        return `
          <section style="margin-bottom: var(--space-4); padding: var(--space-3); border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-surface); color: var(--text-primary);">
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom: var(--space-2); gap: var(--space-2);">
              <div style="font-weight: 600; color: var(--text-primary);">✉️ ${this.escapeHtml(title)}</div>
            </div>
            ${subjectText ? `
              <div style="display:flex; align-items:center; gap: var(--space-2); margin-bottom: var(--space-2);">
                <div style="opacity: 0.75; font-size: 0.85rem; min-width: 56px; color: var(--text-primary);">Subject:</div>
                <div id="${subjectId}" style="flex:1; padding: 8px 12px; background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem;">${this.escapeHtml(subjectText)}</div>
                <button class="btn btn-secondary" data-copy-target="#${subjectId}" style="font-size: 0.85rem; padding: 4px 10px;">📋 Copy</button>
              </div>
            ` : ''}
            <div style="display:flex; gap: var(--space-2); align-items:flex-start;">
              ${bodyBlock}
              <button class="btn btn-secondary" data-copy-target="#${bodyId}" style="font-size: 0.85rem; padding: 4px 10px; flex-shrink: 0;">📋 Copy</button>
            </div>
          </section>
        `;
      }).join('');
    }

    const subjectId = `msg-${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-subject`;
    const bodyId    = `msg-${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-body`;
    // Message bodies use email-app styling on purpose: white paper,
    // black ink.  The app's dark navy theme is great for nav but
    // terrible for reading a paragraph of email copy you're about to
    // paste into Gmail.  Picking the email's actual native colors makes
    // it instantly readable AND a faithful preview of what the lead
    // will see.
    return `
      <section style="margin-bottom: var(--space-4); padding: var(--space-3); border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-surface); color: var(--text-primary);">
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom: var(--space-2); gap: var(--space-2);">
          <div style="font-weight: 600; color: var(--text-primary);">✉️ ${this.escapeHtml(title)}</div>
        </div>
        ${subject ? `
          <div style="display:flex; align-items:center; gap: var(--space-2); margin-bottom: var(--space-2);">
            <div style="opacity: 0.75; font-size: 0.85rem; min-width: 56px; color: var(--text-primary);">Subject:</div>
            <div id="${subjectId}" style="flex:1; padding: 8px 12px; background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem;">${this.escapeHtml(subject)}</div>
            <button class="btn btn-secondary" data-copy-target="#${subjectId}" style="font-size: 0.85rem; padding: 4px 10px;">📋 Copy</button>
          </div>
        ` : ''}
        <div style="display:flex; gap: var(--space-2); align-items:flex-start;">
          <pre id="${bodyId}" style="flex:1; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; white-space: pre-wrap; word-wrap: break-word; margin: 0; font-family: inherit; line-height: 1.5;">${this.escapeHtml(bodyText)}</pre>
          <button class="btn btn-secondary" data-copy-target="#${bodyId}" style="font-size: 0.85rem; padding: 4px 10px; flex-shrink: 0;">📋 Copy</button>
        </div>
      </section>
    `;
  }

  _renderDbSnippets(snippets) {
    if (!snippets || !snippets.length) return '';

    const groups = {};
    for (const s of snippets) {
      const t = s.tier || 'info';
      (groups[t] ||= []).push(s);
    }

    const TIER_ORDER = ['program', 'alumni', 'followup', 'broadcast', 'close', 'soft', 'info', 'qualify'];
    const TIER_TITLES = {
      program: '📋 LeagueApps Program Description',
      alumni: '🎯 Alumni return (SMS + "in" reply follow-up)',
      followup: '📨 Follow-up (touch 2 — after they say yes)',
      broadcast: '📣 Broadcasts (LA Messages — entire roster)',
      close: '🎯 Close (the ask)',
      soft: '🌱 Soft fallback',
      info: 'ℹ️ Info replies',
      qualify: '🤔 Qualifying questions',
    };

    return TIER_ORDER.filter((t) => groups[t]?.length).map((t) => {
      const items = groups[t].map((s, idx) => {
        const bodyText = this._personalize(s.body);
        const bodyHtml = s.html_body ? this._personalize(s.html_body) : null;
        const id = `db-snip-${t}-${idx}`;
        const bodyBlock = bodyHtml
          ? `<div id="${id}" data-copy-html="1" style="margin: 0; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; line-height: 1.55;">${bodyHtml}</div>`
          : `<pre id="${id}" style="margin: 0; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.88rem; white-space: pre-wrap; word-wrap: break-word; font-family: inherit; line-height: 1.5;">${this.escapeHtml(bodyText)}</pre>`;
        return `
          <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: var(--space-3); background: var(--bg-surface); color: var(--text-primary); margin-bottom: var(--space-2);">
            <div style="display:flex; align-items:center; justify-content:space-between; gap: var(--space-2); margin-bottom: var(--space-2);">
              <div style="font-weight: 600; font-size: 0.95rem; color: var(--text-primary);">${this.escapeHtml(s.label)}</div>
              <button class="btn btn-secondary" data-copy-target="#${id}" style="font-size: 0.8rem; padding: 4px 10px;">📋 Copy</button>
            </div>
            ${bodyBlock}
          </div>
        `;
      }).join('');

      return `
        <section style="margin-bottom: var(--space-4);">
          <h3 style="margin: 0 0 var(--space-2) 0; font-size: 1rem; color: var(--text-primary);">${TIER_TITLES[t] || t}</h3>
          ${items}
        </section>
      `;
    }).join('');
  }

  _renderSnippets(snippets) {
    if (!snippets || !snippets.length) return '';

    // Group by tier so the post-touch-1 follow-up reads first
    // (most-common chip — touch 1 is sent from the Leads list, not here),
    // then broadcasts, close (the ASK), soft fallback, info chips, and
    // qualifying questions last.  Matches the visual grouping on the
    // Leads page.  'program' is the canonical LA program-page copy —
    // pinned at the top so admins can grab-and-paste when editing a
    // LeagueApps program listing.
    const TIER_ORDER = ['program', 'alumni', 'followup', 'broadcast', 'close', 'soft', 'info', 'qualify'];
    const TIER_TITLES = {
      program:  '📋 LeagueApps Program Description',
      alumni:   '🎯 Alumni return (SMS + "in" reply follow-up)',
      followup: '📨 Follow-up (touch 2 — after they say yes)',
      broadcast: '📣 Broadcasts (LA Messages — entire roster)',
      close:   '🎯 Close (the ask)',
      soft:    '🌱 Soft fallback',
      info:    'ℹ️ Info replies',
      qualify: '🤔 Qualifying questions',
    };
    const groups = {};
    for (const s of snippets) {
      const t = s.tier || 'info';
      (groups[t] ||= []).push(s);
    }

    return TIER_ORDER
      .filter((t) => groups[t]?.length)
      .map((t) => {
        const items = groups[t].map((s, idx) => {
          const bodyText = this._personalize(s.body);
          const bodyHtml = s.html ? this._personalize(s.html) : null;
          const id = `snip-${t}-${idx}`;
          const subjectId = `snip-${t}-${idx}-subject`;
          const subjectText = s.subject ? this._personalize(s.subject) : '';
          const todoBadge = s.todo
            ? `<span style="margin-left: 6px; padding: 1px 6px; border-radius: 4px; background: #fef3c7; color: #92400e; font-size: 0.7rem; font-weight: 600;">⚠ TODO</span>`
            : '';
          // HTML snippets render inside a styled <div> (so bold/lists
          // actually show up) and flag data-copy-html="1" so the copy
          // handler writes text/html to the clipboard.  Plain-text
          // snippets keep the <pre> renderer that preserves the exact
          // paste-into-chat formatting they were authored in.
          const bodyBlock = bodyHtml
            ? `<div id="${id}" data-copy-html="1" style="margin: 0; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; line-height: 1.55;">${bodyHtml}</div>`
            : `<pre id="${id}" style="margin: 0; padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.88rem; white-space: pre-wrap; word-wrap: break-word; font-family: inherit; line-height: 1.5;">${this.escapeHtml(bodyText)}</pre>`;
          return `
            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: var(--space-3); background: var(--bg-surface); color: var(--text-primary); margin-bottom: var(--space-2);">
              <div style="display:flex; align-items:center; justify-content:space-between; gap: var(--space-2); margin-bottom: var(--space-2);">
                <div style="font-weight: 600; font-size: 0.95rem; color: var(--text-primary);">${this.escapeHtml(s.label)}${todoBadge}</div>
                <button class="btn btn-secondary" data-copy-target="#${id}" style="font-size: 0.8rem; padding: 4px 10px;">📋 Copy</button>
              </div>
              ${subjectText ? `
              <div style="display:flex; align-items:center; gap: var(--space-2); margin-bottom: var(--space-2);">
                <div style="opacity: 0.75; font-size: 0.85rem; min-width: 56px; color: var(--text-primary);">Subject:</div>
                <div id="${subjectId}" style="flex:1; padding: 8px 12px; background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem;">${this.escapeHtml(subjectText)}</div>
                <button class="btn btn-secondary" data-copy-target="#${subjectId}" style="font-size: 0.8rem; padding: 4px 10px;">📋 Copy</button>
              </div>
              ` : ''}
              ${bodyBlock}
            </div>
          `;
        }).join('');
        return `
          <section style="margin-bottom: var(--space-4);">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 1rem; color: var(--text-primary);">${TIER_TITLES[t] || t}</h3>
            ${items}
          </section>
        `;
      })
      .join('');
  }
}
