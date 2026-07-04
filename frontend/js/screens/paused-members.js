// PausedMembersScreen — Club-admin view of everyone currently on an
// active- or paused-variant LA sub-program (Men / Women / Boys / Girls,
// or their paused counterparts).
//
// Data source: `GET /api/admin/{paused-,}members?variant=…`, which reads
// the `person_la_memberships` junction table populated by PersonLinker.
// Paused members are still members of the club (they show up in the
// paused view) but are hidden from the LA pool + team rosters.
//
// Screen is used for BOTH the "Membership" and "Paused Membership" tiles
// on admin-club — the `variant` navigation param toggles which slice is
// shown; the title/subtitle/icon swap automatically.  An optional
// `category` param (men / women / boys / girls) narrows the view to a
// single sub-program so bulk actions (Email All → Gmail BCC) apply
// only to that group.
class PausedMembersScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="members-title">Membership</h1>
        <p class="subtitle" id="members-subtitle">Members grouped by sub-program</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="members-filters" style="display:none; margin-bottom: var(--space-3);
             flex-wrap:wrap; gap: var(--space-1);">
        </div>

        <div id="members-search-wrap" style="margin-bottom: var(--space-3); display:none;">
          <input id="members-search" type="search" placeholder="Search name, email, phone…"
                 style="width:100%; padding: var(--space-2) var(--space-3); font-size: 1rem;
                        border-radius: var(--radius-md); border: 1px solid var(--color-border);
                        background: var(--bg-secondary); color: var(--text-primary);">
        </div>

        <div id="members-bulk-bar" style="display:none; margin-bottom: var(--space-3);
             padding: var(--space-2) var(--space-3); border-radius: var(--radius-md);
             background: var(--bg-secondary); border: 1px solid var(--color-border);
             display:flex; flex-wrap:wrap; gap: var(--space-2); align-items:center;">
        </div>

        <div id="members-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">
          Loading members…
        </div>
        <div id="members-error" style="display:none; color: var(--color-error);
                                       padding: var(--space-4); text-align:center;"></div>
        <div id="members-empty" style="display:none; text-align:center; padding: var(--space-6); opacity:0.6;">
          No members found.
        </div>

        <div id="members-groups" style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;
    // 'active' → Membership, 'paused' → Paused Membership.  Default to
    // 'paused' for legacy callers that navigate to 'paused-members'
    // without a variant param.
    this.variant  = (params?.variant === 'active') ? 'active' : 'paused';
    // Optional per-category filter — matches leagueapps_programs.category.
    const cat = String(params?.category || '').toLowerCase();
    this.category = ['men','women','boys','girls'].includes(cat) ? cat : '';
    this._groups  = [];
    this._filter  = '';

    // Swap title + subtitle to match the variant + optional category.
    const titleEl    = this.find('#members-title');
    const subtitleEl = this.find('#members-subtitle');
    const catLabel   = { men:'Men', women:'Women', boys:'Boys', girls:'Girls' }[this.category] || '';
    if (this.variant === 'active') {
      if (titleEl)    titleEl.textContent    = catLabel ? `👥 ${catLabel} Members` : '👥 Membership';
      if (subtitleEl) subtitleEl.textContent = catLabel
        ? `Active ${catLabel.toLowerCase()} club members`
        : 'Active members across Men / Women / Boys / Girls sub-programs';
    } else {
      if (titleEl)    titleEl.textContent    = catLabel ? `⏸ ${catLabel} Paused` : '⏸ Paused Membership';
      if (subtitleEl) subtitleEl.textContent = catLabel
        ? `${catLabel} members currently on a paused sub-program`
        : 'Members currently on a paused-membership sub-program';
    }

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const bulkBtn = e.target.closest('[data-bulk]');
      if (bulkBtn) {
        this._handleBulk(bulkBtn.getAttribute('data-bulk'));
        return;
      }
      const chip = e.target.closest('[data-category-chip]');
      if (chip) {
        const cat = chip.getAttribute('data-category-chip');
        this.category = (cat === 'all') ? '' : cat;
        this._renderCategoryChips();
        this._renderGroups();
        this._renderBulkBar();
        this._updateSubtitle();
        return;
      }
    });

    const search = this.find('#members-search');
    if (search) {
      search.addEventListener('input', (e) => {
        this._filter = (e.target.value || '').trim().toLowerCase();
        this._renderGroups();
        this._renderBulkBar();
      });
    }

    this._load();
  }

  async _load() {
    const loadingEl = this.find('#members-loading');
    const errorEl   = this.find('#members-error');
    const emptyEl   = this.find('#members-empty');
    const groupsEl  = this.find('#members-groups');
    const searchWrap = this.find('#members-search-wrap');
    const filtersEl  = this.find('#members-filters');
    const bulkBar   = this.find('#members-bulk-bar');

    loadingEl.style.display = 'block';
    errorEl.style.display   = 'none';
    emptyEl.style.display   = 'none';
    groupsEl.style.display  = 'none';
    if (searchWrap) searchWrap.style.display = 'none';
    if (filtersEl)  filtersEl.style.display  = 'none';
    if (bulkBar)    bulkBar.style.display    = 'none';

    try {
      // /members defaults to variant=active; /paused-members defaults
      // to variant=paused.  Passing the explicit query param makes the
      // choice unambiguous either way.
      const url = `/api/admin/members?variant=${encodeURIComponent(this.variant)}`;
      const res = await this.auth.fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      if (!body?.success) throw new Error(body?.error || 'Load failed');

      // Store ALL groups; category is applied at render time so the
      // chip row can flip between Men / Women / Boys / Girls instantly
      // without re-fetching.
      this._groups = Array.isArray(body?.data?.groups) ? body.data.groups : [];
      const total  = this._filteredGroups().reduce((n, g) => n + (g.members?.length || 0), 0);

      loadingEl.style.display = 'none';

      if (this._groups.length === 0) {
        emptyEl.style.display = 'block';
        emptyEl.textContent = this.variant === 'paused'
          ? 'Nobody is on a paused membership right now.'
          : 'No active members found.';
        return;
      }

      this._renderCategoryChips();
      if (filtersEl)  filtersEl.style.display  = 'flex';
      if (searchWrap) searchWrap.style.display = 'block';

      if (total === 0) {
        // Chips visible but selected category has 0 → soft empty.
        emptyEl.style.display = 'block';
        const catLabel = { men:'men', women:'women', boys:'boys', girls:'girls' }[this.category] || '';
        emptyEl.textContent = this.variant === 'paused'
          ? (catLabel ? `No ${catLabel} on paused membership right now.` : 'Nobody is on a paused membership right now.')
          : (catLabel ? `No active ${catLabel} members found.` : 'No active members found.');
        return;
      }

      this._updateSubtitle();
      groupsEl.style.display = 'block';
      this._renderGroups();
      this._renderBulkBar();
    } catch (err) {
      console.error('members load failed', err);
      loadingEl.style.display = 'none';
      errorEl.style.display   = 'block';
      errorEl.textContent     = `Failed to load members: ${err.message}`;
    }
  }

  // Groups after applying the category chip.  Returns everything if
  // `this.category` is empty (== "All" chip selected).
  _filteredGroups() {
    if (!this.category) return this._groups;
    return this._groups.filter(g => (g.category || '').toLowerCase() === this.category);
  }

  _renderCategoryChips() {
    const el = this.find('#members-filters');
    if (!el) return;
    // Available categories = whatever categories the server returned +
    // an "All" pseudo-chip.  Preserves display order (men → women → boys → girls).
    const order = ['men', 'women', 'boys', 'girls'];
    const present = new Set(this._groups.map(g => (g.category || '').toLowerCase()));
    const cats = order.filter(c => present.has(c));
    const totalAll = this._groups.reduce((n, g) => n + (g.members?.length || 0), 0);
    const countFor = (cat) => this._groups
      .filter(g => (g.category || '').toLowerCase() === cat)
      .reduce((n, g) => n + (g.members?.length || 0), 0);
    const label = { men:'👨 Men', women:'👩 Women', boys:'👦 Boys', girls:'👧 Girls' };

    const chip = (id, text, count, active) => `
      <button data-category-chip="${id}"
              style="padding:6px 12px; border-radius:999px; cursor:pointer;
                     font-weight:600; font-size:0.85rem; border:1px solid var(--color-border);
                     background:${active ? 'var(--color-primary, #2563eb)' : 'var(--bg-secondary)'};
                     color:${active ? 'white' : 'var(--text-primary)'};">
        ${text} <span style="opacity:0.7; font-weight:400;">(${count})</span>
      </button>`;

    el.innerHTML = [
      chip('all', 'All', totalAll, !this.category),
      ...cats.map(c => chip(c, label[c] || c, countFor(c), this.category === c)),
    ].join(' ');
  }

  _updateSubtitle() {
    const subtitle = this.find('#members-subtitle');
    if (!subtitle) return;
    const groups = this._filteredGroups();
    const total  = groups.reduce((n, g) => n + (g.members?.length || 0), 0);
    const noun = this.variant === 'paused' ? 'paused' : 'active';
    const catLabel = { men:'Men', women:'Women', boys:'Boys', girls:'Girls' }[this.category] || '';
    const scope = catLabel ? `${catLabel} — ` : '';
    subtitle.textContent = `${scope}${total} ${noun} member${total === 1 ? '' : 's'} across ${groups.length} sub-program${groups.length === 1 ? '' : 's'}`;
  }

  // Return the flat list of members currently in view (respects the
  // search filter).  Used to power bulk actions and the summary strip.
  _visibleMembers() {
    const filter = this._filter;
    const matches = (m) => {
      if (!filter) return true;
      const hay = [
        m.first_name, m.last_name, m.email, m.phone, m.dob,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(filter);
    };
    const out = [];
    for (const g of this._filteredGroups()) {
      for (const m of (g.members || [])) {
        if (matches(m)) out.push(m);
      }
    }
    return out;
  }

  _renderBulkBar() {
    const bar = this.find('#members-bulk-bar');
    if (!bar) return;
    const visible = this._visibleMembers();
    const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
    const phones = [...new Set(visible.map(m => this._phoneDigits(m.phone)).filter(Boolean))];

    if (visible.length === 0) {
      bar.style.display = 'none';
      return;
    }
    bar.style.display = 'flex';
    bar.innerHTML = `
      <div style="font-weight:600; margin-right: var(--space-2);">
        ${visible.length} in view
      </div>
      <button class="btn btn-sm btn-primary" data-bulk="email"
              ${emails.length ? '' : 'disabled'}
              title="Open Gmail with all ${emails.length} email${emails.length===1?'':'s'} as BCC">
        ✉️ Email All (${emails.length})
      </button>
      <button class="btn btn-sm btn-secondary" data-bulk="copy-emails"
              ${emails.length ? '' : 'disabled'}
              title="Copy emails to clipboard, comma-separated">
        📋 Copy emails
      </button>
      <button class="btn btn-sm btn-secondary" data-bulk="copy-phones"
              ${phones.length ? '' : 'disabled'}
              title="Copy phones to clipboard, comma-separated">
        📋 Copy phones
      </button>
    `;
  }

  _handleBulk(action) {
    const visible = this._visibleMembers();
    if (action === 'email') {
      const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
      if (!emails.length) return;
      // Gmail compose URL — puts every email into the BCC field so the
      // list stays private between recipients.  `su=` presets the
      // account (Gmail ignores it if the user isn't logged into that
      // account, so it's a safe hint).
      const bcc = encodeURIComponent(emails.join(','));
      const url = `https://mail.google.com/mail/?view=cm&fs=1&tf=1&bcc=${bcc}`;
      window.open(url, '_blank', 'noopener');
      return;
    }
    if (action === 'copy-emails') {
      const emails = [...new Set(visible.map(m => (m.email || '').trim()).filter(Boolean))];
      this._copyToClipboard(emails.join(', '), `${emails.length} email${emails.length===1?'':'s'} copied`);
      return;
    }
    if (action === 'copy-phones') {
      const phones = [...new Set(visible.map(m => this._phoneDigits(m.phone)).filter(Boolean))];
      this._copyToClipboard(phones.join(', '), `${phones.length} phone${phones.length===1?'':'s'} copied`);
      return;
    }
  }

  _copyToClipboard(text, successMsg) {
    if (!text) return;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text)
        .then(() => this._toast(successMsg))
        .catch(() => this._fallbackCopy(text, successMsg));
    } else {
      this._fallbackCopy(text, successMsg);
    }
  }

  _fallbackCopy(text, successMsg) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try {
      document.execCommand('copy');
      this._toast(successMsg);
    } catch (e) {
      alert('Copy failed — the values were:\n\n' + text);
    } finally {
      ta.remove();
    }
  }

  _toast(msg) {
    // Cheap, no-dep toast.  Clears itself after 2.5s.
    let t = this.find('#members-toast');
    if (!t) {
      t = document.createElement('div');
      t.id = 'members-toast';
      t.style.cssText = `
        position:fixed; bottom:24px; left:50%; transform:translateX(-50%);
        background:#0b3a2e; color:#a7f3d0; padding:10px 16px;
        border-radius:8px; font-weight:600; z-index:9999;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
        transition:opacity 0.25s;`;
      this.element.appendChild(t);
    }
    t.textContent = msg;
    t.style.opacity = '1';
    clearTimeout(this._toastT);
    this._toastT = setTimeout(() => { if (t) t.style.opacity = '0'; }, 2500);
  }

  _renderGroups() {
    const groupsEl = this.find('#members-groups');
    if (!groupsEl) return;

    const filter = this._filter;
    const matches = (m) => {
      if (!filter) return true;
      const hay = [
        m.first_name, m.last_name, m.email, m.phone, m.dob,
        `${m.first_name || ''} ${m.last_name || ''}`,
      ].map(v => (v || '').toLowerCase()).join(' ');
      return hay.includes(filter);
    };

    // Verb used in the "since" line — "Joined" for active, "Paused since"
    // for paused.  joined_at reflects when the current membership row
    // was opened by PersonLinker::recordMembership.
    const sinceLabel = this.variant === 'paused' ? 'Paused since' : 'Joined';

    const html = this._filteredGroups().map(g => {
      const members = (g.members || []).filter(matches);
      const count = members.length;
      const cards = members.map(m => this._renderCard(m, sinceLabel)).join('');

      // Skip empty groups when filtering.
      if (filter && count === 0) return '';

      return `
        <section style="margin-bottom: var(--space-5);">
          <h3 style="margin: 0 0 var(--space-2); opacity:0.9;">
            ${this._esc(g.label || 'Members')}
            <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">(${count})</span>
          </h3>
          <p style="opacity:0.6; font-size:0.8rem; margin: 0 0 var(--space-3);">
            ${this._esc(g.program_name || '')}
          </p>
          ${count === 0
            ? `<div style="opacity:0.5; font-style:italic;">No members.</div>`
            : `<div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: var(--space-3);">${cards}</div>`}
        </section>
      `;
    }).join('');

    groupsEl.innerHTML = html || `<div style="opacity:0.6; text-align:center; padding: var(--space-4);">No matches.</div>`;
  }

  _renderCard(m, sinceLabel) {
    const name  = `${m.first_name || ''} ${m.last_name || ''}`.trim() || '(no name)';
    const email = m.email || '';
    const phone = m.phone || '';
    const phoneDigits = this._phoneDigits(phone);
    const dob   = m.dob || '';
    const joined = m.joined_at ? new Date(m.joined_at).toLocaleDateString() : '';
    // Youth (boys/girls) usually have contact info on the parent row;
    // the API returns the parent value when the child has none and flags
    // it so we can label it clearly.
    const emailViaParent = !!m.email_via_parent;
    const phoneViaParent = !!m.phone_via_parent;
    const parentTag = m.parent_name
      ? ` <span style="opacity:0.6; font-size:0.7rem;">(via ${this._esc(m.parent_name)})</span>`
      : ` <span style="opacity:0.6; font-size:0.7rem;">(via parent)</span>`;

    const dobLine = dob
      ? `<div style="font-size:0.8rem; opacity:0.75;">🎂 ${this._esc(this._fmtDob(dob))}</div>`
      : '';
    const emailLine = email
      ? `<div style="font-size:0.85rem; opacity:0.85;">✉ ${this._esc(email)}${emailViaParent ? parentTag : ''}</div>`
      : '';
    const phoneLine = phone
      ? `<div style="font-size:0.85rem; opacity:0.85;">📞 ${this._esc(this._fmtPhone(phone))}${phoneViaParent ? parentTag : ''}</div>`
      : '';

    const buttons = [];
    if (email) {
      buttons.push(
        `<a href="mailto:${this._esc(email)}" target="_blank" rel="noopener"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#0b3a2e; color:#a7f3d0; border:1px solid #10b981;
                    font-size:0.75rem; font-weight:700;">✉️ Email</a>`
      );
    }
    if (phoneDigits && m.phone_sms !== false) {
      buttons.push(
        `<a href="sms:${phoneDigits}"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#3a2e05; color:#fde68a; border:1px solid #d97706;
                    font-size:0.75rem; font-weight:700;">💬 Text</a>`
      );
    }
    if (phoneDigits && m.phone_call !== false) {
      buttons.push(
        `<a href="tel:${phoneDigits}"
             style="padding:5px 10px; border-radius:4px; text-decoration:none;
                    background:#1f2937; color:#e5e7eb; border:1px solid #4b5563;
                    font-size:0.75rem; font-weight:700;">📞 Call</a>`
      );
    }
    const btnRow = buttons.length
      ? `<div style="display:flex; gap:6px; margin-top: var(--space-2); flex-wrap:wrap;">${buttons.join('')}</div>`
      : '';

    return `
      <div class="paused-card" style="background: var(--bg-secondary);
            border-radius: var(--radius-md); padding: var(--space-3);
            border: 1px solid var(--color-border);
            display:flex; flex-direction:column; gap:4px;">
        <div style="font-weight:600;">${this._esc(name)}</div>
        ${dobLine}
        ${emailLine}
        ${phoneLine}
        ${joined ? `<div style="font-size:0.75rem; opacity:0.6; margin-top: var(--space-1);">
                      ${this._esc(sinceLabel)} ${this._esc(joined)}
                    </div>` : ''}
        ${btnRow}
      </div>
    `;
  }

  // ── Formatters ────────────────────────────────────────────────────
  _fmtDob(ymd) {
    if (!ymd) return '';
    const s = String(ymd);
    const mt = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (!mt) return s;
    const y  = Number(mt[1]);
    const mo = Number(mt[2]);
    const d  = Number(mt[3]);
    const now = new Date();
    let age = now.getUTCFullYear() - y;
    const m2 = now.getUTCMonth() + 1;
    const d2 = now.getUTCDate();
    if (m2 < mo || (m2 === mo && d2 < d)) age -= 1;
    return `${mo}/${d}/${y} (age ${age})`;
  }

  _phoneDigits(s) {
    return String(s || '').replace(/\D+/g, '');
  }

  _fmtPhone(s) {
    const d = this._phoneDigits(s);
    if (d.length === 10) return `(${d.slice(0,3)}) ${d.slice(3,6)}-${d.slice(6)}`;
    if (d.length === 11 && d.startsWith('1')) return `+1 (${d.slice(1,4)}) ${d.slice(4,7)}-${d.slice(7)}`;
    return s;
  }

  _esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
