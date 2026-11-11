// MainMenuScreen — #main-menu (was #role-selection until 2026-11-11; owner:
// "i don't like role-selection screen name … shouldn't it be main-menu").
// The six group buttons are lib/main-menu.js (MainMenu, mig 1244).
class MainMenuScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-main-menu';
    
    const user = this.navigation.context.user;
    const userName = user?.name || user?.email || 'User';
    
    // Check if user has admin role (club, sport division, team, super, or system level)
    const isAdmin = user?.role && (user.role === 'club' || user.role === 'sport_division' || user.role === 'team' || user.role === 'super' || user.role === 'system' || user.role === 'league');
    const adminButtonDisplay = isAdmin ? 'flex' : 'none';

    
    div.innerHTML = `
      <div class="screen-header">
        <h1>Welcome, ${this.escapeHtml(userName)}</h1>
        <p class="subtitle">${this.escapeHtml((window.MessageCopy && MessageCopy.has && MessageCopy.has('main_menu', 'subtitle') && MessageCopy.block('main_menu', 'subtitle')) || 'Where to?')}</p>
      </div>
      
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        <!-- Six groups (menu_groups / menu_pages, mig 1244): a button per
             group; its pages are the pill row on every page inside it
             (lib/main-menu.js).  Filled once GET /api/menu answers. -->
        <div class="rs-groups" style="display: flex; flex-direction: column; gap: var(--space-4);">
          <div style="opacity: 0.6; text-align: center; padding: var(--space-4);">Loading…</div>
        </div>

        <button class="btn btn-text logout-btn" style="margin-top: var(--space-4);">Logout</button>
        <button class="btn btn-outline-secondary open-tactical-btn" style="margin-top: var(--space-2);">Open Tactical Board</button>

        <!-- ── View-as / impersonation picker (2026-07-11) ────────────
             Admin-only debugging tool: pick any active member and
             the app reloads as that person (all /api/my/* calls get
             ?asPersonId=<id> appended by the auth fetch wrapper).
             Persistent orange banner at the top of every screen shows
             who you're viewing as, with an "Exit view-as" button.
             Writes remain locked to the real caller \u2014 the backend
             refuses ?asPersonId= on POST/PUT/DELETE. -->
        <div class="view-as-picker" style="display: ${adminButtonDisplay}; flex-direction: column; gap: var(--space-2); margin-top: var(--space-4); padding: var(--space-3); border: 1px dashed #f97316; border-radius: 8px;">
          <div style="font-weight: bold; color: #c2410c;">\ud83c\udfad View as another member</div>
          <div style="font-size: 0.8rem; color: #666;">Read-only impersonation \u2014 debugging tool for admins.</div>
          <select class="view-as-select" style="padding: 8px; font-size: 1rem; border-radius: 6px; border: 1px solid #ccc;">
            <option value="">\u2014 loading members\u2026 \u2014</option>
          </select>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // ── Player-only auto-skip (2026-07-06) ─────────────────────────
    //
    // If the user is a plain player (no coach affiliation, no admin
    // claim, no admin-level `user.role`) there's nothing to pick from
    // here — force them straight to their weekly RSVP view.  This is
    // the natural landing page for the vast majority of accounts and
    // saves them from a meaningless button-tap on every visit.
    //
    // Coaches and admins keep the picker because they routinely
    // switch context (coach ↔ player, admin ↔ club-admin, etc).
    this._maybeAutoSkipToMy();

    this._drawGroups();

    // Group buttons via event delegation
    this.element.addEventListener('click', (e) => {
      const groupBtn = e.target.closest('[data-menu-group]');
      if (groupBtn) {
        MainMenu.openGroup(groupBtn.dataset.menuGroup);
        return;
      }
      
      // Handle logout
      if (e.target.closest('.logout-btn')) {
        this.handleLogout();
      }

      // Open tactical board (direct)
      if (e.target.closest('.open-tactical-btn')) {
        // If we already have a selected team in navigation context, open tactical board directly
        const team = this.navigation.context?.team;
        const club = this.navigation.context?.club;

        if (team && team.id) {
          this.navigation.goTo('tactical-board', { teamId: team.id, teamName: team.name, clubId: team.clubId || club?.id });
        } else if (club && club.id) {
          // open at club level
          this.navigation.goTo('tactical-board', { clubId: club.id, clubName: club.name });
        } else {
          // Open tactical board without a specific context so user can work freely
          this.navigation.goTo('tactical-board');
        }
      }
    });

    // ── View-as picker ────────────────────────────────────────────────
    // Only meaningful for admins.  The dropdown is already hidden via
    // CSS `display: none` for non-admins, but we also short-circuit
    // the fetch to keep server logs clean.
    this._maybeLoadViewAsPicker();
  }

  // One big button per group the viewer has pages in; the line under it
  // names those pages (the pills it opens onto).
  async _drawGroups() {
    const host = this.element && this.element.querySelector('.rs-groups');
    if (!host) return;
    try {
      await MainMenu.load(this.auth);
    } catch (err) {
      console.error('[menu] load failed:', err);
      host.innerHTML = `<div style="text-align:center; padding: var(--space-4);">${this.escapeHtml((window.MessageCopy && MessageCopy.has && MessageCopy.has('main_menu', 'unavailable') && MessageCopy.block('main_menu', 'unavailable')) || 'Menu did not load — refresh the page.')}</div>`;
      return;
    }
    host.innerHTML = MainMenu.groups().map((g) => `
        <button class="btn btn-lg btn-primary" data-menu-group="${this.escapeHtml(g.code)}" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-size: 2rem;">${this.escapeHtml(g.icon)}</span>
          <div style="flex: 1; text-align: left;">
            <div style="font-weight: bold;">${this.escapeHtml(g.label)}</div>
            <div style="font-size: 0.85rem; opacity: 0.8;">${g.pages.map((p) => this.escapeHtml(p.label)).join(' · ')}</div>
          </div>
        </button>`).join('');
  }

  async _maybeLoadViewAsPicker() {
    const user = this.navigation.context.user;
    const isAdmin = user?.role && (
      user.role === 'club' || user.role === 'sport_division' ||
      user.role === 'team' || user.role === 'super' ||
      user.role === 'system' || user.role === 'league'
    );
    if (!isAdmin) return;

    const select = this.element.querySelector('.view-as-select');
    if (!select) return;

    // One-time change handler.  Setting `viewAsPersonId` in Auth fires
    // a `viewAsChanged` DOM event; the banner in index.html reacts to
    // it and shows itself.  Then we navigate to /my as the target so
    // the admin immediately sees that person's weekly schedule.
    select.addEventListener('change', (ev) => {
      const opt = ev.target.selectedOptions[0];
      if (!opt || !opt.value) return;
      const personId   = Number(opt.value);
      const personName = opt.getAttribute('data-name') || opt.textContent || '';
      if (!personId) return;
      this.auth.setViewAs(personId, personName);
      this.navigation.context.role = 'player';
      this.navigation.goTo('my');
    });

    try {
      const [res, staffRes] = await Promise.all([
        this.auth.fetch('/api/admin/members?variant=active'),
        // Staff / Admins group is optional — a failure here must not
        // take down the member groups.
        this.auth.fetch('/api/admin/staff').catch(() => null),
      ]);
      if (!res.ok) {
        select.innerHTML = '<option value="">— failed to load members —</option>';
        return;
      }
      const body = await res.json();
      const groups = body?.data?.groups || [];

      // Category emoji + display order — mirrors the "everyone pickup
      // and regular members on men, boys etc" phrasing from the
      // feature request.  Any category not in this map falls through
      // as a plain-labelled optgroup at the end.
      const catOrder  = ['men', 'women', 'boys', 'girls'];
      const catEmoji  = { men: '👨', women: '👩', boys: '👦', girls: '👧' };
      groups.sort((a, b) => {
        const ai = catOrder.indexOf(a.category);
        const bi = catOrder.indexOf(b.category);
        return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
      });

      const parts = ['<option value="">— pick a member —</option>'];
      for (const g of groups) {
        const emoji = catEmoji[g.category] || '•';
        const label = `${emoji} ${g.label || g.category} — ${g.program_name || ''}`.trim();
        parts.push(`<optgroup label="${this.escapeHtml(label)}">`);
        const members = (g.members || []).slice().sort((a, b) => {
          const an = (a.first_name || '').trim();
          const bn = (b.first_name || '').trim();
          return an.localeCompare(bn, undefined, { sensitivity: 'base' });
        });
        for (const m of members) {
          const name = `${m.first_name || ''} ${m.last_name || ''}`.trim() || `Person #${m.person_id}`;
          parts.push(
            `<option value="${m.person_id}" data-name="${this.escapeHtml(name)}">`
            + this.escapeHtml(name)
            + '</option>'
          );
        }
        parts.push('</optgroup>');
      }

      // ── Staff / Admins group ──────────────────────────────────────
      // People with an admins row but often no open LA membership
      // (e.g. club staff like Charles).  The member groups above come
      // from LA memberships only, so without this group they'd be
      // impossible to pick even though the backend allows viewing-as
      // any existing person.
      if (staffRes && staffRes.ok) {
        try {
          const staffBody = await staffRes.json();
          const staff = (staffBody?.data?.staff || []).slice().sort((a, b) => {
            const an = (a.first_name || '').trim();
            const bn = (b.first_name || '').trim();
            return an.localeCompare(bn, undefined, { sensitivity: 'base' });
          });
          if (staff.length) {
            parts.push('<optgroup label="🛠 Staff / Admins">');
            for (const m of staff) {
              const name = `${m.first_name || ''} ${m.last_name || ''}`.trim() || `Person #${m.person_id}`;
              parts.push(
                `<option value="${m.person_id}" data-name="${this.escapeHtml(name)}">`
                + this.escapeHtml(name)
                + '</option>'
              );
            }
            parts.push('</optgroup>');
          }
        } catch (_e) {
          // Ignore — member groups still render without the staff group.
        }
      }

      select.innerHTML = parts.join('');
    } catch (e) {
      console.error('[view-as] failed to load members:', e);
      select.innerHTML = '<option value="">— failed to load members —</option>';
    }
  }
  
  // The old tile routes live in MainMenu.open (mig 1244) — the menu
  // buttons and the pill rows share them.
  handleRoleSelection(role) {
    MainMenu.open(role);
  }

  handleLogout() {
    this.auth.logout();
    if (window.MainMenu) MainMenu.reset();
    this.navigation.context = { user: null, role: null, team: null }; // Clear context
    this.navigation.updateContextHeader();
    this.navigation.goTo('login');
  }

  // Fetches /api/auth/me/roles and, if the user has NO coach or admin
  // affiliation, immediately redirects to the weekly RSVP view.  Pure
  // players never need to see the picker.
  //
  // Also treats admin-level `user.role` (club / sport_division / team
  // / super / system / league / marketing) as "keep the picker" so
  // admins retain the ability to switch modes even if the DB has no
  // matching `admins` / `team_coaches` rows yet.
  async _maybeAutoSkipToMy() {
    try {
      const user = this.navigation.context.user || {};
      const isAdmin = user.role && (
        user.role === 'club' || user.role === 'sport_division' ||
        user.role === 'team' || user.role === 'super' ||
        user.role === 'system' || user.role === 'league' ||
        user.role === 'marketing'
      );
      if (isAdmin) return;

      const res = await this.auth.fetch('/api/auth/me/roles');
      if (!res.ok) return;
      const body = await res.json();
      const roles = (body && body.data && Array.isArray(body.data.roles))
        ? body.data.roles
        : [];
      const hasCoach = roles.some(r => r && r.type === 'coach');
      const hasAdmin = roles.some(r => r && r.type === 'admin');
      if (!hasCoach && !hasAdmin) {
        this.navigation.context.role = 'player';
        this.navigation.goTo('my');
        return;
      }
      // A coach without an admin role sees the coach pages (Event Center,
      // Teams, Tactical, Kit, Reports) — MainMenu reads the same roles.
    } catch (_e) {
      // Non-fatal — fall back to the manual picker.
    }
  }
  
  // Helper to escape HTML
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
