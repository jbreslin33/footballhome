// MainMenuScreen — #main-menu (was #role-selection until 2026-11-11; owner:
// "i don't like role-selection screen name … shouldn't it be main-menu").
// Since 2026-11-16 the groups are the top bar (lib/main-menu.js) and this
// screen is 👤 Account: sign out, view-as (admins), tactical board.
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
      <div style="padding: var(--space-4); display: flex; flex-direction: column; gap: var(--space-4); max-width: 500px; margin: 0 auto;">
        <!-- The group buttons moved to the bar on top of every page
             (lib/main-menu.js, owner 11/16); this is 👤 Account now.
             The signed-in name was the old "Welcome, …" title — kept as
             data so Logout says whose session it ends. -->
        <div class="signed-in-as" style="text-align: center; opacity: 0.8;">👤 ${this.escapeHtml(userName)}</div>
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
    // (11/16: no auto-skip any more — players come here on purpose, from
    // 👤 Account, to sign out; everyone lands on the Calendar.)

    this.element.addEventListener('click', (e) => {
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

  async _maybeLoadViewAsPicker() {
    // Club / super admins only (owner 11/18 "reg users should not have view
    // as"); never offered from inside view-as — the banner's Exit is the way out.
    const user = this.auth.realUser;
    const isAdmin = !this.auth.viewAsPersonId && ['club', 'super'].includes(user && user.role);
    const picker = this.element.querySelector('.view-as-picker');
    if (!isAdmin) { if (picker) picker.style.display = 'none'; return; }

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
      select.disabled = true;
      this.auth.enterViewAs(personId, personName).then((why) => {
        if (!why) return;   // reloading as them
        select.disabled = false;
        select.value = '';
        let note = this.element.querySelector('.view-as-note');
        if (!note) {
          note = document.createElement('div');
          note.className = 'view-as-note';
          note.style.cssText = 'color:#f97316; font-weight:600; font-size:0.9rem;';
          select.insertAdjacentElement('afterend', note);
        }
        note.textContent = why;
      });
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

  // Helper to escape HTML
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
