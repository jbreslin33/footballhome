// AdminClubScreen - Placeholder for club-level administration
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
            Admin level: <strong>CLUB</strong>
          </p>
        </div>

        <!-- ── Club-admin funnel · People → Billing → Roster → RSVP Eligibility ──
             These four sections gate each other in order:
               1. People       — who is this Lighthouse human, and are they in the club?
               2. Billing      — if so, are you paid up?
               3. Roster       — assigned to which team?
               4. RSVP Elig.   — which team events can you RSVP for?
             Layout below this block (Team Dashboards, Media, Structure, misc)
             is still being evaluated and is intentionally left below the fold. -->

        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">🎯 Recruitment</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 0 — before someone is a member, they're a lead. Ad-interest form submissions, funnel touch-history, and conversion analytics from first touch through LA registration.
        </p>
        <div id="section-recruitment" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">👥 People</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 1 — Lighthouse human records: membership, accounts, player/coach/admin roles, duplicates, and data issues. Scraped league/opponent people stay in System Admin unless linked to Lighthouse.
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

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚙️ Teams &amp; Structure</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Teams, venues, tactical boards, and club-wide settings. Human records live under People.
        </p>
        <div id="section-structure" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>
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
    // Lighthouse human-record workbench.  Membership is a person-connected
    // workflow, so the existing Members board lives here.  Scraped league
    // or opponent-only identities belong in System Admin / League Data until
    // they are explicitly linked to a Lighthouse person.
    const peopleGroups = [
      {
        label: 'Membership',
        tiles: [
          { id: 'members', icon: '👥', label: 'Members', description: 'LA-synced board — Active / Pickup toggle, filter by Men / Women / Boys / Girls' },
        ],
      },
      {
        label: 'Records',
        tiles: [
          { id: 'people-directory', icon: '🧾', label: 'People Directory', description: 'One Lighthouse person graph: contact, account, player, coach/admin, membership, and roster links' },
          { id: 'accounts', icon: '🔐', label: 'Accounts', description: 'Login users connected to Lighthouse persons' },
          { id: 'player-records', icon: '⚽', label: 'Players', description: 'Lighthouse player records and role flags, separate from scraped opponent players' },
          { id: 'staff-records', icon: '🧢', label: 'Coaches & Admins', description: 'Coach, team admin, and club admin assignments' },
        ],
      },
      {
        label: 'Cleanup',
        tiles: [
          { id: 'person-duplicates', icon: '🔎', label: 'Duplicates / Merges', description: 'Find duplicate Lighthouse people and review merge history' },
          { id: 'person-data-issues', icon: '⚠️', label: 'Data Issues', description: 'Missing links, bad contacts, account gaps, roster mismatches, and membership sync issues' },
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
      { id: 'rsvp-eligibility', icon: '🗳️', label: 'RSVP Eligibility', description: 'Debug board — who can RSVP for Pickup, Practice, APSL, Liga 1, Liga 2, Adult (tabs: All / Men / Women / Boys / Girls)' },
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

    if (section === 'people-directory') {
      this.navigation.goTo('members', {
        clubId: this.clubId,
        clubName: this.clubName,
        variant: 'active',
        mode: 'people',
        title: 'People Directory',
        subtitle: 'One Lighthouse person graph: contact, account, player, coach/admin, membership, and roster links',
      });
      return;
    }

    if (['accounts', 'player-records', 'staff-records', 'person-duplicates', 'person-data-issues'].includes(section)) {
      const viewMap = {
        accounts: {
          title: 'Accounts',
          subtitle: 'Login users and their linked Lighthouse person records',
          description: 'Review account ownership, sign-in state, and person-link quality before broader person cleanup.',
          action: 'accounts',
        },
        'player-records': {
          title: 'Players',
          subtitle: 'Lighthouse player records and role flags',
          description: 'Inspect player-role state separately from scraped opponent-player data.',
          action: 'players',
        },
        'staff-records': {
          title: 'Coaches & Admins',
          subtitle: 'Coach, team admin, and club admin assignments',
          description: 'Review staff roles, assignments, and current access relationships.',
          action: 'staff',
        },
        'person-duplicates': {
          title: 'Duplicates / Merges',
          subtitle: 'Duplicate Lighthouse people and review merge history',
          description: 'Find likely duplicates and prepare merge decisions with existing person links intact.',
          action: 'duplicates',
        },
        'person-data-issues': {
          title: 'Data Issues',
          subtitle: 'Missing links, bad contacts, roster mismatches, and membership sync issues',
          description: 'Use this workbench to triage the common data-quality exceptions that block clean person workflows.',
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
