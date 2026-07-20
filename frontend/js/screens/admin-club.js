// AdminClubScreen — Lighthouse club operations hub.
// Person is the hub: users, roster connections, and RSVP ability all
// hang off persons.  Scraped league/opponent-only people stay in
// System Admin until linked into a Lighthouse membership.
class AdminClubScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-club';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="club-title">Club Administration</h1>
        <p class="subtitle" id="club-subtitle">Club-level admin features</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center; margin-bottom: var(--space-4);">
          <span style="font-size: 3rem; display: block; margin-bottom: var(--space-2);">🏢</span>
          <h2 id="club-name-display" style="margin-bottom: var(--space-2);">Club Name</h2>
          <p style="opacity: 0.8;">
            Admin level: <strong>CLUB</strong> · Lighthouse people only
          </p>
        </div>

        <!-- ── Club-admin funnel · People → Billing → Roster → RSVP Eligibility ──
             Person is the hub. Everything below derives from persons:
               1. People       — who is this Lighthouse human? (users, roles, links)
               2. Billing      — if a member, are they paid up?
               3. Roster       — assigned to which team?
               4. RSVP Elig.   — which team events can they RSVP for?
             Outside-club / scraped people: System Admin. -->

        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">🎯 Recruitment</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 0 — before someone is a member, they're a lead. Ad-interest form submissions, funnel touch-history, and conversion analytics from first touch through LA registration.
        </p>
        <div id="section-recruitment" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">👥 People</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 1 — Lighthouse <code>persons</code> and everything that derives from them: users, players, coaches/admins, membership, roster connections, RSVP ability. Scraped league/opponent people stay in System Admin unless linked.
        </p>
        <div id="section-people"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">💰 Billing</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 2 — if you're a member, we bill you and track it. Payments by status (Paid Up · Behind · Overdue · Never Paid), delinquent queue, LA charge flags.
        </p>
        <div id="section-billing" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🎽 Roster</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 3 — put each paid member on a specific team. Mens tiers (APSL / Liga 1 / Liga 2 / Adult / Practice / Pickup), Boys teams, Girls teams, cross-domain master board.
        </p>
        <div id="section-rosters" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🗳️ RSVP Eligibility</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 4 — which team events each member can RSVP for (Pickup, Practice, APSL, Liga 1, Liga 2, Adult). Tabs: All / Men / Women / Boys / Girls.
        </p>
        <div id="section-rsvp" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🗓️ Soccer Calendar</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Google Calendar owns event timing and tags. Football Home mirrors soccer events here and translates FH details when classification exists.
        </p>
        <div id="section-schedule" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📢 Reminders</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Event RSVP nudges. Mens reminders are live now; this section is the home for expanding the same workflow to women, boys, and girls.
        </p>
        <div id="section-reminders" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📣 Communications</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Outbound club voice: recipient-first messages, public social posts, and reusable poster/flyer assets.
        </p>
        <div id="section-communications"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🧠 Game Model</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          The club’s game model, principles, and weekly session plan with player-count variations for each day.
        </p>
        <div id="section-game-model" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚙️ Teams &amp; Structure</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Teams, venues, tactical boards, and club-wide settings. Human records live under People.
        </p>
        <div id="section-structure" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

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
    
    this.find('#club-title').textContent = this.clubName;
    this.find('#club-name-display').textContent = this.clubName;
    this.find('#club-subtitle').textContent = `Manage ${this.clubName}`;
    
    this.renderSubNavigation();
    
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      
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
        <button class="btn btn-lg btn-secondary sub-nav-btn"
                data-section="${section.id}"
                style="height: auto; padding: var(--space-3); text-align: left;">
          <div style="font-size: 2rem; margin-bottom: var(--space-1);">${section.icon}</div>
          <div style="font-weight: 600; margin-bottom: var(--space-1);">${section.label}</div>
          <div style="opacity: 0.7; font-size: 0.85rem;">${section.description}</div>
        </button>
      `).join('');
    };

    const renderGroupsInto = (elId, groups) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = groups.map(group => `
        <div style="margin-bottom: var(--space-4);">
          <div style="font-weight: 700; margin-bottom: var(--space-2); opacity: 0.88;">${group.label}</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);">
            ${group.tiles.map(section => `
              <button class="btn btn-lg btn-secondary sub-nav-btn"
                      data-section="${section.id}"
                      style="height: auto; padding: var(--space-3); text-align: left;">
                <div style="font-size: 2rem; margin-bottom: var(--space-1);">${section.icon}</div>
                <div style="font-weight: 600; margin-bottom: var(--space-1);">${section.label}</div>
                <div style="opacity: 0.7; font-size: 0.85rem;">${section.description}</div>
              </button>
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
          { id: 'person-duplicates', icon: '🔎', label: 'Duplicates / Merges', description: 'Shared emails, matching name+DOB, and merge history' },
          { id: 'person-data-issues', icon: '⚠️', label: 'Data Issues', description: 'Missing contact, account, LA alias, roster, or RSVP links' },
        ],
      },
    ];
    renderGroupsInto('#section-people', peopleGroups);

    // ── Recruitment ────────────────────────────────────────────────────
    // Step 0 of the funnel — the world before someone is a member.
    // Leads (Meta ad-form submissions) + Leads Analytics (touch-history
    // → LA-registration conversion).  Both handlers stay in
    // handleSubNavigation() below (`section === 'leads'` / `'leads-analytics'`)
    // so tile ids remain stable across the reorg.
    const recruitmentTiles = [
      { id: 'leads',           icon: '📋', label: 'Leads',           description: 'Ad interest form submissions' },
      { id: 'leads-analytics', icon: '📊', label: 'Leads Analytics', description: 'What touches actually turn into LA registrations' },
    ];
    renderInto('#section-recruitment', recruitmentTiles);

    // ── Reminders ────────────────────────────────────────────────────
    // Mens reminders are the only live implementation today.  Keep the
    // tile data category-scoped so women/boys/girls can become adjacent
    // tiles without changing the click routing shape.
    const reminderTiles = [
      { id: 'event-reminders-mens', target: 'mens-events-reminders', params: { category: 'mens' }, icon: '📢', label: 'Event Reminders', description: 'Mens events now; same workflow can expand to women, boys, and girls' },
    ];
    this._dashTiles = reminderTiles;
    renderInto('#section-reminders', reminderTiles);

    // ── RSVP ──────────────────────────────────────────────────────────
    // Single diagnostic tile — opens the RSVP-eligibility board with
    // All / Men / Women / Boys / Girls tabs so the coach can see at a
    // glance who's eligible for which mens-selection team (APSL,
    // Liga 1, Liga 2, Adult, Practice, Pickup) and toggle grants.
    const rsvpTiles = [
      { id: 'rsvp-eligibility', icon: '🗳️', label: 'RSVP Eligibility', description: 'Men / Women / Boys / Girls — home teams plus Practice & Pickup pools' },
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

    // ── Communications ─────────────────────────────────────────────────
    // Outbound club voice.  Messages are recipient-first; socials are
    // channel-first; posters/flyers are assets that can be printed,
    // shared directly, or exported into social formats.
    const communicationGroups = [
      {
        label: 'Messages',
        tiles: [
          { id: 'messages', icon: '💬', label: 'Messages', description: 'Canned responses, welcomes, broadcasts, and follow-up copy per team' },
        ],
      },
      {
        label: 'Socials',
        tiles: [
          { id: 'holiday-posts', icon: '🎉', label: 'Holiday Posts', description: 'Instagram holiday posts' },
          { id: 'promo-posts', icon: '📢', label: 'Promo Posts', description: 'Instagram promotional posts' },
          { id: 'content-posts', icon: '📷', label: 'Content Posts', description: 'Upload photos & videos to Instagram' },
          { id: 'ad-preview', icon: '📱', label: 'Ad Preview', description: 'See exactly what your ads look like' },
        ],
      },
      {
        label: 'Posters & Assets',
        tiles: [
          { id: 'flyers', icon: '🖨️', label: 'Flyers', description: 'Printable recruitment flyers with QR codes' },
          { id: 'public-exhibits', icon: '🖼️', label: 'Public Exhibits', description: 'Publicly shareable poster boards & history pages' },
          { id: 'exhibit-social', icon: '📲', label: 'Exhibit → Social', description: 'Export poster assets as IG carousel, 4:5 single, or long poster renders' },
        ],
      },
    ];
    renderGroupsInto('#section-communications', communicationGroups);

    // ── 💰 Billing funnel section ────────────────────────────────────
    // Step 2 of the club-admin funnel.  Everything money-related lives
    // here — the Payments screen groups members by status (Paid Up /
    // Behind / Overdue / Never Paid) with client-side aggregation across
    // all four programs (Mens / Womens / Boys / Girls).  The old dedicated
    // Delinquent tile was retired 2026-07-13 — the Overdue chip on Payments
    // surfaces the same past-due queue with better filtering.
    //
    // Uses the shared `_dashTiles` lookup for click routing.
    const billingTiles = [
      { id: 'payments',        target: 'payments',        params: {},                    icon: '💳', label: 'Payments',           description: 'Members grouped by status: Paid Up · Behind · Overdue · Never Paid — filter by Men / Women / Boys / Girls inside' },
    ];
    renderInto('#section-billing', billingTiles);
    this._dashTiles = (this._dashTiles || []).concat(billingTiles);

    // ── 🎽 Roster funnel section ─────────────────────────────────────
    // Step 3 of the club-admin funnel.  Assign each paid member to a
    // specific team.  Consolidated 2026-07-13 into a single tile that
    // routes to the /#rosters screen — a FilterBar chip switcher
    // (All / Mens / Womens / Boys / Girls) which mounts the appropriate
    // sub-screen underneath.  Same UX pattern as Members + Payments.
    const rosterTiles = [
      { id: 'rosters', target: 'rosters', params: {}, icon: '🎽', label: 'Rosters', description: 'Assign every FH member to a team — one screen, chip-switch between Mens (workbench) / Boys / Girls / All (side-by-side)' },
    ];
    renderInto('#section-rosters', rosterTiles);
    this._dashTiles = (this._dashTiles || []).concat(
      rosterTiles.filter(t => t.target)
    );

    // ── Training / Game Model ───────────────────────────────────────
    const gameModelTiles = [
      { id: 'game-model', target: 'game-model', params: { entity: 'game-model' }, icon: '🧠', label: 'Game Model', description: 'Open the club’s live game-model view from the database' },
      { id: 'game-model-days', target: 'game-model-admin', params: { entity: 'days' }, icon: '🗓️', label: 'Days', description: 'Create and edit the weekly day structure' },
      { id: 'game-model-sessions', target: 'game-model-admin', params: { entity: 'sessions' }, icon: '⚽', label: 'Sessions', description: 'Build the training blocks inside each day' },
      { id: 'game-model-exercises', target: 'game-model-admin', params: { entity: 'exercises' }, icon: '🏋️', label: 'Exercises', description: 'Manage the drills and activities used in sessions' },
    ];
    renderInto('#section-game-model', gameModelTiles);
    this._dashTiles = (this._dashTiles || []).concat(gameModelTiles.filter(tile => tile.target));

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

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure`)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
      })
      .then((payload) => {
        if (!this.isMounted) return;
        const data = payload?.data || payload;
        const structure = data && typeof data === 'object' && !Array.isArray(data) ? data : null;
        const html = structure?.phases?.length
          ? this.renderStructuredGameModel(structure)
          : (structure?.content_html || structure?.content || '<div style="opacity: 0.7;">Game model content is not available yet.</div>');
        contentsEl.innerHTML = html;
        this.bindGameModelInteractions();
      })
      .catch((error) => {
        if (!this.isMounted) return;
        contentsEl.innerHTML = `<div style="opacity: 0.7;">Unable to load game model content: ${this.escapeHtml(error.message)}</div>`;
      });
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
          title: 'People Directory',
          subtitle: 'Lighthouse person graph',
          description: 'One row per Lighthouse person with account, player, staff, roster, and RSVP links.',
          action: 'directory',
        },
        accounts: {
          title: 'Accounts',
          subtitle: 'Login users linked to Lighthouse persons',
          description: 'Review account ownership, sign-in state, and activity on Lighthouse people.',
          action: 'accounts',
        },
        'player-records': {
          title: 'Players',
          subtitle: 'Lighthouse player records',
          description: 'Player rows linked to Lighthouse persons — not scraped opponent-only players.',
          action: 'players',
        },
        'staff-records': {
          title: 'Coaches & Admins',
          subtitle: 'Staff roles on Lighthouse people',
          description: 'Coach, team admin, and club admin assignments derived from persons.',
          action: 'staff',
        },
        'person-duplicates': {
          title: 'Duplicates / Merges',
          subtitle: 'Duplicate signals and merge history',
          description: 'Shared emails, matching name+DOB, and people touched by merges.',
          action: 'duplicates',
        },
        'person-data-issues': {
          title: 'Data Issues',
          subtitle: 'Broken person-graph links',
          description: 'Missing contact, account, LA alias, roster assignment, or RSVP eligibility.',
          action: 'data-issues',
        },
      };
      const view = viewMap[section];
      this.navigation.goTo('people-workbench', {
        clubId: this.clubId,
        clubName: this.clubName,
        view: view.action,
        title: view.title,
        subtitle: view.subtitle,
        description: view.description,
      });
      return;
    }

    if (section === 'admin-calendar') {
      // Google Calendar mirror view (agenda list).  See
      // screens/calendar.js + docs/calendar-design.md §10.1.
      // clubId/clubName aren't consumed today — calendar is site-
      // wide — but we pass them so the back button lands here.
      this.navigation.goTo('calendar', {
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
    
    if (section === 'game-model') {
      this.navigation.goTo('game-model', {
        clubId: this.clubId,
        clubName: this.clubName,
      });
      return;
    }

    if (section === 'game-model-admin' || section === 'game-model-days' || section === 'game-model-sessions' || section === 'game-model-exercises') {
      const entity = section === 'game-model-admin' ? 'game-model'
        : section === 'game-model-days' ? 'days'
        : section === 'game-model-sessions' ? 'sessions'
        : section === 'game-model-exercises' ? 'exercises'
        : 'game-model';
      this.navigation.goTo('game-model-admin', {
        clubId: this.clubId,
        clubName: this.clubName,
        entity,
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

    if (section === 'holiday-posts') {
      this.navigation.goTo('holiday-posts', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'promo-posts') {
      this.navigation.goTo('promo-posts', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'content-posts') {
      this.navigation.goTo('content-posts', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'flyers') {
      this.navigation.goTo('flyers', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'leads') {
      this.navigation.goTo('leads', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'leads-analytics') {
      this.navigation.goTo('leads-analytics', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'messages') {
      this.navigation.goTo('messages', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'rsvp-eligibility') {
      this.navigation.goTo('rsvp-eligibility', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'ad-preview') {
      this.navigation.goTo('ad-preview', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'public-exhibits') {
      // Public, no-login pages. Open in a new tab so coaches/staff can share the link.
      window.open('/exhibit/lighthouse-history.html', '_blank', 'noopener');
      return;
    }

    if (section === 'exhibit-social') {
      // Local preview of the rendered IG carousel + 4:5 single + long poster.
      // The slideshow viewer reads PNGs from /images/posts/exhibit-pNN-*.png, which are
      // generated directly from lighthouse-history.html by
      // `scripts/render-poster-from-source.js <N>` and live-served by nginx.
      window.open('/exhibit/slideshow.html?p=1', '_blank', 'noopener');
      return;
    }

    // Placeholder - will implement actual navigation later
    alert(`${section.toUpperCase()} management coming soon for ${this.clubName}`);
  }
}
