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

        <!-- ── Club-admin funnel · Member → Billing → Roster → RSVP Eligibility ──
             These four sections gate each other in order:
               1. Member       — are you in the club?
               2. Billing      — if so, are you paid up?
               3. Roster       — assigned to which team?
               4. RSVP Elig.   — which team events can you RSVP for?
             Layout below this block (Team Dashboards, Media, Structure, misc)
             is still being evaluated and is intentionally left below the fold. -->

        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">👥 Member</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Step 1 — are you in the club? LA-synced roster of every active / pickup registration, filterable by Men · Women · Boys · Girls.
        </p>
        <div id="section-membership" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

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

        <!-- ── Below the funnel · still evaluating layout ────────────
             Everything below is either a viewing lens on the same
             underlying data (Team Dashboards) or supporting infra
             (Media, Structure, leads).  Grouping here is provisional. -->

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🧩 Team Dashboards</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Aggregated per-team views — grouped by club (Mens · Womens · Boys · Girls). Lineups, practice, pickup, game-day eligibility.
        </p>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👨 Mens Club</h4>
        <div id="dash-mens" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👩 Womens Club</h4>
        <div id="dash-womens" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👦 Boys Club</h4>
        <div id="dash-boys" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👧 Girls Club</h4>
        <div id="dash-girls" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-4) 0 var(--space-2); opacity: 0.75; font-size: 0.9rem; font-weight: 500;">
          Other — pending re-homing
        </h4>
        <div id="section-membership-misc" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📲 Media &amp; Socials</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Instagram posts, printable flyers, ad previews, public exhibits, and coach-facing messaging.
        </p>
        <div id="section-media" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚙️ Structure</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Events, users, players, teams, venues, tactical boards, and club-wide settings.
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

    // ── Membership ─────────────────────────────────────────────────────
    // Single tile that opens the unified Members board.  The board has
    // an Active / Pickup toggle and category chips (Men / Women / Boys /
    // Girls) so the coach can reach any of the 8 LA sub-programs (4
    // categories × 2 variants) from one place without leaving the screen.
    //
    // Deep-link tile ids (`members-mens`, `members-girls`, etc.) are
    // still honored by handleSubNavigation() below, so any external
    // bookmark / hash-route pointing at a specific slice keeps working.
    const membershipTiles = [
      { id: 'members', icon: '👥', label: 'Members', description: 'Unified board — Active / Pickup toggle, filter by Men / Women / Boys / Girls' },
    ];
    renderInto('#section-membership', membershipTiles);

    // Membership-adjacent tiles that don't map 1:1 to an LA program —
    // parked here until the next reorg pass decides where they live.
    // Handlers stay in handleSubNavigation() so the tiles work as-is.
    const membershipMiscTiles = [
      { id: 'leads',           icon: '📋', label: 'Leads',           description: 'Ad interest form submissions' },
      { id: 'leads-analytics', icon: '📊', label: 'Leads Analytics', description: 'What touches actually turn into LA registrations' },
    ];
    renderInto('#section-membership-misc', membershipMiscTiles);

    // ── Team Dashboards ────────────────────────────────────────────────
    // Grouped by club (Mens / Womens / Boys / Girls).  Each tile is a
    // lens on the same underlying data (matches, rosters, RSVPs);
    // filter params tell the target screen which slice to render.  The
    // shared `youth-*` screens honor gender / sex filters incrementally
    // — until then they render the full youth set and ignore the
    // filter (no error, just unfiltered).
    const mensDashTiles = [
      { id: 'mens-lineups',   target: 'mens-lineups',       params: { gender: 'mens',   matchType: 'game'    }, icon: '🧩', label: 'Mens Dashboard',           description: 'Men\'s teams — LA pool, per-team rosters, next match, starters & bench' },
      { id: 'mens-practice',  target: 'mens-practice-dash', params: { gender: 'mens',   kind: 'practice'     }, icon: '🏃', label: 'Mens Practice',            description: 'Add / edit / delete men\'s practices — shared across all mens teams' },
      { id: 'mens-pickup',    target: 'mens-pickup-dash',   params: { gender: 'mens',   kind: 'pickup'       }, icon: '⚡', label: 'Mens Pickup',              description: 'Add / edit / delete men\'s pickup sessions — shared across all mens teams' },
      { id: 'series-editor',  target: 'admin-series-editor',params: {},                                          icon: '🔁', label: 'Recurring Series',         description: 'Weekly templates — every Sunday 8pm the next week\'s matches are auto-materialised' },
      { id: 'apsl-dash',      target: 'mens-lineups',       params: { gender: 'mens',   division: 'apsl'     }, icon: '🏆', label: 'APSL',                     description: 'APSL teams only — standings, schedule, rosters' },
      { id: 'liga1-dash',     target: 'mens-lineups',       params: { gender: 'mens',   division: 'liga1'    }, icon: '🏆', label: 'Liga 1',                   description: 'CASA Liga 1 teams — standings, schedule, rosters' },
      { id: 'liga2-dash',     target: 'mens-lineups',       params: { gender: 'mens',   division: 'liga2'    }, icon: '🏆', label: 'Liga 2',                   description: 'CASA Liga 2 teams — standings, schedule, rosters' },
      { id: 'tricounty-dash', target: 'mens-lineups',       params: { gender: 'mens',   division: 'tricounty'}, icon: '🏆', label: 'Tri County',               description: 'Tri County league teams — standings, schedule, rosters' },
      { id: 'mens-game-elig', target: 'mens-game-eligibility', params: { gender: 'mens' },                        icon: '🎯', label: 'Game Eligibility',         description: 'Projected 35-player APSL & Liga 1 rosters — game-day availability & call-ups' },
      // (2026-07-12) `mens-roster-board` moved to 🎽 Roster funnel section.
      // (2026-07-13) `mens-delinquent`  removed — Payments screen (Overdue chip) covers this.
      { id: 'mens-events-reminders', target: 'mens-events-reminders', params: {},                                    icon: '📢', label: 'Mens Reminders',           description: 'All upcoming men\'s events (games · practice · pickup) — one tap to nudge non-responders' },
    ];

    const womensDashTiles = [
      { id: 'womens-lineups',  target: 'womens-lineups',      params: { gender: 'womens', matchType: 'game' }, icon: '🧩', label: 'Womens Dashboard',       description: 'Women\'s teams — LA pool, per-team rosters, next match, starters & bench' },
      { id: 'womens-practice', target: 'womens-practice-dash',params: { gender: 'womens', kind: 'practice'  }, icon: '🏃', label: 'Womens Practice',        description: 'Add / edit / delete women\'s practices — shared across all women\'s teams' },
      { id: 'womens-pickup',   target: 'womens-pickup-dash',  params: { gender: 'womens', kind: 'pickup'    }, icon: '⚡', label: 'Womens Pickup',          description: 'Add / edit / delete women\'s pickup sessions — shared across all women\'s teams' },
    ];

    // Youth shared screens (practice, pickup, dashboard) appear under
    // both Boys and Girls because the youth program is one unit
    // physically — same practices, same pickups, same coaches.  Tile
    // ids differ (`boys-*` vs `girls-*`) so click routing stays clean
    // even though target + params are identical.
    const boysDashTiles = [
      { id: 'boys-lineups',   target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', matchType: 'game' }, icon: '🧩', label: 'Boys Dashboard',       description: 'Boys teams — roster, schedule, attendance' },
      // (2026-07-12) `boys-roster` moved to 🎽 Roster funnel section.
      { id: 'boys-practice',  target: 'youth-practice-dash', params: { gender: 'youth', sex: 'boys', kind: 'practice' }, icon: '🏃', label: 'Boys Practice',        description: 'Add / edit / delete boys practices' },
      { id: 'boys-pickup',    target: 'youth-pickup-dash',   params: { gender: 'youth', sex: 'boys', kind: 'pickup'   }, icon: '⚡', label: 'Boys Pickup',          description: 'Add / edit / delete boys pickup sessions' },
      { id: 'u8-boys-dash',   target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u8'  }, icon: '👦', label: 'U8 Boys',              description: 'U8 boys teams — roster, schedule, attendance' },
      { id: 'u10-boys-dash',  target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u10' }, icon: '👦', label: 'U10 Boys',             description: 'U10 boys teams — roster, schedule, attendance' },
      { id: 'u12-boys-dash',  target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u12' }, icon: '👦', label: 'U12 Boys',             description: 'U12 boys teams — roster, schedule, attendance' },
    ];

    const girlsDashTiles = [
      { id: 'girls-lineups',  target: 'youth-roster',        params: { gender: 'youth', sex: 'girls', matchType: 'game' }, icon: '🧩', label: 'Girls Dashboard',    description: 'Girls teams — roster, schedule, attendance' },
      // (2026-07-12) `girls-roster` moved to 🎽 Roster funnel section.
      { id: 'girls-practice', target: 'youth-practice-dash', params: { gender: 'youth', sex: 'girls', kind: 'practice' }, icon: '🏃', label: 'Girls Practice',      description: 'Add / edit / delete girls practices' },
      { id: 'girls-pickup',   target: 'youth-pickup-dash',   params: { gender: 'youth', sex: 'girls', kind: 'pickup'   }, icon: '⚡', label: 'Girls Pickup',        description: 'Add / edit / delete girls pickup sessions' },
    ];

    const dashTiles = [...mensDashTiles, ...womensDashTiles, ...boysDashTiles, ...girlsDashTiles];
    // Stash for handleSubNavigation so it can look up the target screen
    // + params by tile id without a giant switch.
    this._dashTiles = dashTiles;

    renderInto('#dash-mens',   mensDashTiles);
    renderInto('#dash-womens', womensDashTiles);
    renderInto('#dash-boys',   boysDashTiles);
    renderInto('#dash-girls',  girlsDashTiles);

    // ── RSVP ──────────────────────────────────────────────────────────
    // Single diagnostic tile — opens the RSVP-eligibility board with
    // All / Men / Women / Boys / Girls tabs so the coach can see at a
    // glance who's eligible for which mens-selection team (APSL,
    // Liga 1, Liga 2, Adult, Practice, Pickup) and toggle grants.
    const rsvpTiles = [
      { id: 'rsvp-eligibility', icon: '🗳️', label: 'RSVP Eligibility', description: 'Debug board — who can RSVP for Pickup, Practice, APSL, Liga 1, Liga 2, Adult (tabs: All / Men / Women / Boys / Girls)' },
    ];
    renderInto('#section-rsvp', rsvpTiles);

    // ── Media & Socials ────────────────────────────────────────────────
    // Everything that ends up in front of a prospect or member — IG
    // posts (holiday / promo / content), printable flyers, ad preview,
    // public exhibit pages, and coach-facing canned messages.
    const mediaTiles = [
      { id: 'holiday-posts',   icon: '🎉',  label: 'Holiday Posts',     description: 'Instagram holiday posts' },
      { id: 'promo-posts',     icon: '📢',  label: 'Promo Posts',       description: 'Instagram promotional posts' },
      { id: 'content-posts',   icon: '📷',  label: 'Content Posts',     description: 'Upload photos & videos to Instagram' },
      { id: 'flyers',          icon: '🖨️', label: 'Flyers',            description: 'Printable recruitment flyers with QR codes' },
      { id: 'ad-preview',      icon: '📱',  label: 'Ad Preview',        description: 'See exactly what your ads look like' },
      { id: 'public-exhibits', icon: '🖼️', label: 'Public Exhibits',   description: 'Publicly shareable poster boards & history pages' },
      { id: 'exhibit-social',  icon: '📲',  label: 'Exhibit → Social',  description: 'Preview IG carousel / 4:5 single / long poster renders' },
      { id: 'messages',        icon: '💬',  label: 'Messages',          description: 'Canned responses & welcome messages per team' },
    ];
    renderInto('#section-media', mediaTiles);

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

    // ── Structure ──────────────────────────────────────────────────────
    // Club structural entities — events, users, players, teams,
    // venues, tactical boards, and club-wide settings.
    const structureTiles = [
      { id: 'events',   icon: '📅',  label: 'Events',   description: 'Club events & RSVPs' },
      { id: 'users',    icon: '👤',  label: 'Users',    description: 'Manage user accounts' },
      { id: 'players',  icon: '⚽',  label: 'Players',  description: 'Manage player records' },
      { id: 'teams',    icon: '👥',  label: 'Teams',    description: 'Manage teams' },
      { id: 'venues',   icon: '🏟️', label: 'Venues',   description: 'Manage venues' },
      { id: 'tactics',  icon: '🧠',  label: 'Tactics',  description: 'Club-wide tactical boards' },
      { id: 'settings', icon: '⚙️', label: 'Settings', description: 'Club settings' },
    ];
    renderInto('#section-structure', structureTiles);
  }
  
  handleSubNavigation(section) {
    // Team-dashboard tiles: single lookup routes to the right screen
    // with filter params (gender / matchType / division / ageGroup /
    // sex).  This handles Mens/Womens/Youth Dashboard, Practice /
    // Pickup variants, APSL / Liga 1 / Liga 2 / Tri County, and
    // U8/U10/U12 Boys.  Target screens can honor filters
    // incrementally.
    const dashTile = (this._dashTiles || []).find(t => t.id === section);
    if (dashTile) {
      this.navigation.goTo(dashTile.target, {
        clubId:   this.clubId,
        clubName: this.clubName,
        ...dashTile.params,
      });
      return;
    }

    if (section === 'events') {
      this.navigation.goTo('club-events', {
        clubId: this.clubId,
        clubName: this.clubName
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
