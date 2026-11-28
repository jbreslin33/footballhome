// AdminClubScreen — Lighthouse club operations hub.
// Person is the hub: users, roster connections, and RSVP ability all
// hang off persons.  Scraped league/opponent-only people stay in
// System Admin until linked into a Lighthouse membership.
class AdminClubScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-club';
    
    div.innerHTML = `
      <div style="padding: var(--space-4);">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center; margin-bottom: var(--space-4);">
          <span style="font-size: 3rem; display: block; margin-bottom: var(--space-2);">🏢</span>
          <h2 id="club-name-display" style="margin-bottom: var(--space-2);">Club Name</h2>
          <p style="opacity: 0.8;">
            Admin level: <strong>CLUB</strong> · Lighthouse people only
          </p>
        </div>

        <!-- ── Club-admin funnel · People → RSVP Eligibility ──
             Person is the hub. Everything below derives from persons:
               1. People       — who is this Lighthouse human? (users, roles, links)
               2. RSVP Elig.   — which team events can they RSVP for?
             Roster (the Teams board, #teams) moved to the Coach screen — it's coach
             work, not club-admin work. Billing/Payments moved to the
             standalone Financial section on Role Selection (2026-08-10) —
             it's money data, not club structure, and coaches/marketing
             never needed it buried in here.
             Outside-club / scraped people: System Admin. -->

        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">👥 People</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 1 — Lighthouse <code>persons</code> and everything that derives from them: users, players, coaches/admins, membership, roster connections, RSVP ability. Scraped league/opponent people stay in System Admin unless linked.
        </p>
        <div id="section-people"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🗳️ Event Access</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 2 — which team events each member can RSVP for (Pickup, Practice, APSL, Liga 1, Liga 2, Adult). Tabs: All / Men / Women / Boys / Girls.
        </p>
        <div id="section-rsvp" style="display:flex; flex-wrap:wrap; gap:8px;"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🗓️ Soccer Calendar</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Google Calendar owns event timing and tags. Football Home mirrors soccer events here and translates FH details when classification exists.
        </p>
        <div id="section-schedule" style="display:flex; flex-wrap:wrap; gap:8px;"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚙️ Teams &amp; Structure</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Teams, venues, tactical boards, and club-wide settings. Human records live under People.
        </p>
        <div id="section-structure" style="display:flex; flex-wrap:wrap; gap:8px;"></div>

        <div id="game-model-panel" style="margin-top: var(--space-5); background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: var(--space-4);">
          <div style="display: flex; justify-content: space-between; align-items: center; gap: var(--space-3); flex-wrap: wrap; margin-bottom: var(--space-3);">
            <div>
              <h3 style="margin: 0 0 var(--space-1) 0;">🧠 Game Model &amp; Weekly Session</h3>
              <p style="margin: 0; opacity: 0.8;">The club’s principles, the weekly rhythm, and the player-count versions for each day.</p>
            </div>
            <div style="background: var(--bg-primary); border-radius: var(--radius-pill); padding: 0.35rem 0.8rem; font-size: 0.9rem; font-weight: 600;">
              Club admin reference
            </div>
          </div>
          <div id="game-model-contents" style="display: grid; gap: var(--space-3);"></div>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';
    
    this.find('#club-name-display').textContent = this.clubName;
    
    this.renderSubNavigation();

    this.element.addEventListener('click', (e) => {
      const subNavBtn = e.target.closest('.sub-nav-btn');
      if (subNavBtn) {
        const section = subNavBtn.getAttribute('data-section');
        this.handleSubNavigation(section);
      }
    });
  }
  
  renderSubNavigation() {
    // Helper: render a section of tiles into an element by id.
    const renderInto = (elId, tiles) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = tiles.map(section => `
        <button class="sub-nav-btn" data-section="${section.id}" title="${section.description}" style="padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.9rem; min-height:0; min-width:0; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">${section.icon} ${section.label}</button>
      `).join('');
    };

    const renderGroupsInto = (elId, groups) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = groups.map(group => `
        <div style="margin-bottom: var(--space-4);">
          <div style="font-weight: 700; margin-bottom: var(--space-2); opacity: 0.88;">${group.label}</div>
          <div style="display:flex; flex-wrap:wrap; gap:8px;">
            ${group.tiles.map(section => `
              <button class="sub-nav-btn" data-section="${section.id}" title="${section.description}" style="padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.9rem; min-height:0; min-width:0; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">${section.icon} ${section.label}</button>
            `).join('')}
          </div>
        </div>
      `).join('');
    };

    // ── People ─────────────────────────────────────────────────────────
    // Person hub for Lighthouse only.  Directory shows the full graph
    // (account / player / staff / roster / RSVP).  Members remains the
    // LA membership workflow.  Lens tiles open the same workbench with
    // a focused filter.  Scraped/opponent people: System Admin.
    const peopleGroups = [
      {
        label: 'Person hub',
        tiles: [
          { id: 'people-directory', icon: '🧾', label: 'People Directory', description: 'One row per Lighthouse person — account, player, staff, roster teams, RSVP eligibility' },
          { id: 'members', icon: '👥', label: 'Members', description: 'LA membership board — Active / Pickup, Men / Women / Boys / Girls' },
        ],
      },
      {
        label: 'Derived from persons',
        tiles: [
          { id: 'accounts', icon: '🔐', label: 'Accounts', description: 'users rows linked to Lighthouse persons — sign-in and activity' },
          { id: 'player-records', icon: '⚽', label: 'Players', description: 'players linked to Lighthouse persons (not scraped opponents)' },
          { id: 'staff-records', icon: '🧢', label: 'Coaches & Admins', description: 'Coach, team admin, and club admin roles on Lighthouse people' },
        ],
      },
      {
        label: 'Cleanup',
        tiles: [
          { id: 'person-duplicates', icon: '🔎', label: 'Duplicates / Merges', description: 'Shared emails, matching name+DOB, split identities, and merge history' },
          { id: 'person-data-issues', icon: '⚠️', label: 'Data Issues', description: 'Missing contact, account, LA alias, roster, or RSVP links' },
        ],
      },
    ];
    renderGroupsInto('#section-people', peopleGroups);

    // ── RSVP ──────────────────────────────────────────────────────────
    // Single diagnostic tile — opens the RSVP-eligibility board with
    // All / Men / Women / Boys / Girls tabs so the coach can see at a
    // glance who's eligible for which mens-selection team (APSL,
    // Liga 1, Liga 2, Adult, Practice, Pickup) and toggle grants.
    const rsvpTiles = [
      { id: 'rsvp-eligibility', icon: '🗳️', label: 'Event Access', description: 'Men / Women / Boys / Girls — home teams plus Practice & Pickup pools' },
      { id: 'attendance-report', icon: '📊', label: 'Attendance Report', description: 'RSVP %, attendance %, reliability and last activity per player — games and practices broken out, sortable by team and category' },
    ];
    renderInto('#section-rsvp', rsvpTiles);

    // ── Calendar ──────────────────────────────────────────────────────
    // Google Calendar owns event timing and tags.  Keep Club Admin's
    // schedule entry pointed at the mirror instead of the retired FH
    // matches/practices board so this section has one clear purpose.
    const scheduleTiles = [
      { id: 'admin-calendar', icon: '🗓️', label: 'Soccer Calendar', description: 'FH-translated soccer events from Google Calendar. To add/change timing, edit them in gcal.' },
    ];
    renderInto('#section-schedule', scheduleTiles);

    // Game Model reference panel below (#game-model-panel /
    // #game-model-contents) stays here — it's explicitly the "Club admin
    // reference" read view. The editable tiles (Game Model / Practice
    // Plans / Days / Exercises) are reachable from the coach-only nav
    // pills on MyScreen (see my.js _renderCoachPills).
    const gameModelContent = '<div style="opacity: 0.75;">Loading game model content…</div>';
    const gameModelContentsEl = this.find('#game-model-contents');
    if (gameModelContentsEl) {
      gameModelContentsEl.innerHTML = gameModelContent;
    }

    this.loadGameModelContent();

    // ── Teams & Structure ──────────────────────────────────────────────
    // Club structural entities.  Users, players, coaches, and admins are
    // human-role records, so they live under People instead of Structure.
    const structureTiles = [
      { id: 'teams',    icon: '👥',  label: 'Teams',    description: 'Manage teams' },
      { id: 'venues',   icon: '🏟️', label: 'Venues',   description: 'Manage venues' },
      { id: 'tactics',  icon: '🧠',  label: 'Tactics',  description: 'Club-wide tactical boards' },
      { id: 'settings', icon: '⚙️', label: 'Settings', description: 'Club settings' },
    ];
    renderInto('#section-structure', structureTiles);
  }
  
  bindGameModelInteractions() {
    if (!this.element) return;

    this.element.querySelectorAll('[data-toggle-section]').forEach((button) => {
      button.onclick = () => {
        const id = button.getAttribute('data-toggle-section');
        const panel = this.element.querySelector(`#${id}`);
        if (!panel) return;
        const isOpen = panel.style.display === 'block';
        this.element.querySelectorAll('[data-toggle-section]').forEach((otherButton) => {
          const otherId = otherButton.getAttribute('data-toggle-section');
          const otherPanel = this.element.querySelector(`#${otherId}`);
          if (otherPanel) {
            otherPanel.style.display = 'none';
          }
        });
        this.element.querySelectorAll('[data-toggle-player-count]').forEach((playerButton) => {
          const playerId = playerButton.getAttribute('data-toggle-player-count');
          const playerPanel = this.element.querySelector(`#${playerId}`);
          if (playerPanel) {
            playerPanel.style.display = 'none';
          }
        });
        panel.style.display = isOpen ? 'none' : 'block';
      };
    });

    this.element.querySelectorAll('[data-toggle-player-count]').forEach((button) => {
      button.onclick = () => {
        const id = button.getAttribute('data-toggle-player-count');
        const panel = this.element.querySelector(`#${id}`);
        if (!panel) return;
        const isOpen = panel.style.display === 'block';
        this.element.querySelectorAll('[data-toggle-player-count]').forEach((otherButton) => {
          const otherId = otherButton.getAttribute('data-toggle-player-count');
          const otherPanel = this.element.querySelector(`#${otherId}`);
          if (otherPanel) {
            otherPanel.style.display = 'none';
          }
        });
        panel.style.display = isOpen ? 'none' : 'block';
      };
    });

    const initialDayPanel = this.element.querySelector('#tuesday');
    if (initialDayPanel) {
      initialDayPanel.style.display = 'block';
    }
  }

  loadGameModelContent() {
    const contentsEl = this.find('#game-model-contents');
    if (!contentsEl || !this.clubId) return;

    const structureRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure?_t=${Date.now()}`)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
      })
      .then((payload) => {
        const data = payload?.data || payload;
        return data && typeof data === 'object' && !Array.isArray(data) ? data : null;
      })
      .catch(() => null);

    Promise.all([structureRequest])   // the old practice planner retired (mig 5020 → #exercises 🗓 Plans)
      .then(([structure]) => {
        if (!this.isMounted) return;

        const structureHtml = structure?.phases?.length
          ? this.renderStructuredGameModel(structure)
          : (structure?.content_html || structure?.content || '<div style="opacity: 0.7;">Game model content is not available yet.</div>');

        contentsEl.innerHTML = `
          <div style="display:grid; gap: var(--space-3);">
            <div>${structureHtml}</div>
          </div>
        `;
        this.bindGameModelInteractions();
      })
      .catch((error) => {
        if (!this.isMounted) return;
        contentsEl.innerHTML = `<div style="opacity: 0.7;">Unable to load game model content: ${this.escapeHtml(error.message)}</div>`;
      });
  }

  getDayLabel(dayOfWeek) {
    const labels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return labels[dayOfWeek] != null ? labels[dayOfWeek] : '';
  }

  formatSessionWindow(practiceStartAt, startTime, endTime) {
    if (!startTime || !endTime) return '';

    const normalizedStart = String(startTime).trim();
    const normalizedEnd = String(endTime).trim();
    if ((normalizedStart === '00:00:00' || normalizedStart === '00:00') && (normalizedEnd === '00:05:00' || normalizedEnd === '00:05')) {
      return '7:00 PM – 7:05 PM';
    }

    if (!practiceStartAt) return '';

    const baseDate = new Date(practiceStartAt);
    if (Number.isNaN(baseDate.getTime())) return '';

    const startMinutes = this.parseTimeValue(startTime);
    const endMinutes = this.parseTimeValue(endTime);
    if (startMinutes == null || endMinutes == null) return '';

    const startDate = new Date(baseDate.getTime() + (startMinutes * 60 * 1000));
    const endDate = new Date(baseDate.getTime() + (endMinutes * 60 * 1000));

    const formatter = new Intl.DateTimeFormat('en', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });

    return `${formatter.format(startDate)} – ${formatter.format(endDate)}`;
  }

  parseTimeValue(value) {
    if (value == null || value === '') return null;
    const parts = String(value).split(':').map((part) => parseInt(part, 10));
    if (parts.length < 2 || parts.some((part) => Number.isNaN(part))) return null;
    const [hours, minutes, seconds = 0] = parts;
    return (hours * 60) + minutes + (seconds / 60);
  }

  handleSubNavigation(section) {
    // Tile lookup routes reusable surfaces with params.  Reminders use
    // category params so the current mens-only screen can grow into the
    // same workflow for women, boys, and girls later.
    const dashTile = (this._dashTiles || []).find(t => t.id === section);
    if (dashTile) {
      this.navigation.goTo(dashTile.target, {
        clubId:   this.clubId,
        clubName: this.clubName,
        ...dashTile.params,
      });
      return;
    }

    if (section === 'teams') {
      this.navigation.goTo('admin-club-teams', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'members') {
      // Unified Members board — the screen filters by variant/category
      // internally via chips, so no `variant` param is needed here.
      this.navigation.goTo('members', {
        clubId: this.clubId,
        clubName: this.clubName,
        variant: 'active',
      });
      return;
    }

    if (section === 'people-directory' ||
        ['accounts', 'player-records', 'staff-records', 'person-duplicates', 'person-data-issues'].includes(section)) {
      const viewMap = {
        'people-directory': {
          description: 'One row per Lighthouse person with account, player, staff, roster, and RSVP links.',
          action: 'directory',
        },
        accounts: {
          description: 'Review account ownership, sign-in state, and activity on Lighthouse people.',
          action: 'accounts',
        },
        'player-records': {
          description: 'Player rows linked to Lighthouse persons — not scraped opponent-only players.',
          action: 'players',
        },
        'staff-records': {
          description: 'Coach, team admin, and club admin assignments derived from persons.',
          action: 'staff',
        },
        'person-duplicates': {
          description: 'Shared emails, matching name+DOB, split identities (a sign-in with no team beside a roster spot with no sign-in), and people touched by merges.',
          action: 'duplicates',
        },
        'person-data-issues': {
          description: 'Missing contact, account, LA alias, roster assignment, or RSVP eligibility.',
          action: 'data-issues',
        },
      };
      const view = viewMap[section];
      this.navigation.goTo('people-workbench', {
        clubId: this.clubId,
        clubName: this.clubName,
        view: view.action,
        description: view.description,
      });
      return;
    }

    if (section === 'admin-calendar') {
      // The one 📅 Calendar (screens/event-center.js; the old Google-
      // mirror screen folded in 2026-11-16).  clubId/clubName aren't
      // consumed — the calendar is site-wide.
      this.navigation.goTo('event-center', {
        clubId:   this.clubId,
        clubName: this.clubName,
      });
      return;
    }

    // Per-category deep links.  Same screen, but the screen filters
    // groups client-side by category and updates the title so bulk
    // actions (email-all / copy-all) apply to a single sub-program.
    const catMatch = section.match(/^members-(mens|womens|boys|girls)$/);
    if (catMatch) {
      const [, cat] = catMatch;
      // UI category ids map to DB `category` column values:
      //   mens   → men       womens → women
      //   boys   → boys      girls  → girls
      const dbCategory = cat === 'mens' ? 'men'
                       : cat === 'womens' ? 'women'
                       : cat;
      this.navigation.goTo('members', {
        clubId:   this.clubId,
        clubName: this.clubName,
        variant:  'active',
        category: dbCategory,
      });
      return;
    }
    
    if (section === 'tactics') {
      this.navigation.goTo('tactical-board', {
        clubId: this.clubId,
        teamName: 'Club Wide' // Fallback for title
      });
      return;
    }

    if (section === 'attendance-report') {
      this.navigation.goTo('reports');
      return;
    }

    if (section === 'rsvp-eligibility') {
      this.navigation.goTo('rsvp-eligibility', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    // Placeholder - will implement actual navigation later
    alert(`${section.toUpperCase()} management coming soon for ${this.clubName}`);
  }
}
