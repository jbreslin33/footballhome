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

        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">👥 Membership</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Unified members board — flip Active / Pickup and filter by category from one screen.
        </p>
        <div id="section-membership" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h4 style="margin: var(--space-4) 0 var(--space-2); opacity: 0.75; font-size: 0.9rem; font-weight: 500;">
          Other — pending re-homing
        </h4>
        <div id="section-membership-misc" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🧩 Team Dashboards</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Aggregated per-team views — grouped by club (Mens · Womens · Boys · Girls).
        </p>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👨 Mens Club</h4>
        <div id="dash-mens" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👩 Womens Club</h4>
        <div id="dash-womens" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👦 Boys Club</h4>
        <div id="dash-boys" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h4 style="margin: var(--space-3) 0 var(--space-1); opacity: 0.85; font-size: 0.95rem;">👧 Girls Club</h4>
        <div id="dash-girls" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2); margin-bottom: var(--space-3);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">�️ RSVP</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Diagnostic — who can RSVP for Pickup, Practice, APSL, Liga 1, Liga 2, Adult.
        </p>
        <div id="section-rsvp" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">�📲 Media &amp; Socials</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Instagram posts, printable flyers, ad previews, public exhibits, and coach-facing messaging.
        </p>
        <div id="section-media" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">💰 Financials</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          LeagueApps payment history — one screen per program, freshly synced on every load.
        </p>
        <div id="financials" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

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
    // Single tile that opens the unified Members board (paused-members
    // screen).  The board has an Active / Pickup toggle and category
    // chips (Men / Women / Boys / Girls) so the coach can reach any of
    // the 8 LA sub-programs (4 categories × 2 variants) from one place
    // without leaving the screen.
    //
    // Deep-link tile ids (`members-mens`, `paused-members-girls`, etc.)
    // are still honored by handleSubNavigation() below, so any external
    // bookmark / hash-route pointing at a specific slice keeps working.
    const membershipTiles = [
      { id: 'members', icon: '👥', label: 'Members', description: 'Unified board — Active / Pickup toggle, filter by Men / Women / Boys / Girls' },
    ];
    renderInto('#section-membership', membershipTiles);

    // Membership-adjacent tiles that don't map 1:1 to an LA program —
    // parked here until the next reorg pass decides where they live.
    // Handlers stay in handleSubNavigation() so the tiles work as-is.
    const membershipMiscTiles = [
      { id: 'club-rosters',    icon: '🗂️', label: 'Club Rosters',    description: 'Cross-domain master board — every FH member with color-coded team chips across Mens / Womens / Boys / Girls' },
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
      { id: 'mens-roster-board', target: 'mens-roster',        params: { gender: 'mens' },                        icon: '🎽', label: 'Mens Roster',              description: 'Dues-aware roster selection — assign to teams, see overdue counts, Dues Owed column, LA pause actions' },
      { id: 'mens-delinquent', target: 'mens-delinquent',       params: { gender: 'mens' },                        icon: '💰', label: 'Delinquent Members',       description: 'Players overdue on dues — 7+ days = dues owed (past hold threshold)' },
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
      { id: 'boys-roster',    target: 'boys-roster',         params: { gender: 'youth', sex: 'boys' },                    icon: '🎽', label: 'Boys Roster',          description: 'Live LA roster — boys + girls together (girls play on boys teams for now)' },
      { id: 'boys-practice',  target: 'youth-practice-dash', params: { gender: 'youth', sex: 'boys', kind: 'practice' }, icon: '🏃', label: 'Boys Practice',        description: 'Add / edit / delete boys practices' },
      { id: 'boys-pickup',    target: 'youth-pickup-dash',   params: { gender: 'youth', sex: 'boys', kind: 'pickup'   }, icon: '⚡', label: 'Boys Pickup',          description: 'Add / edit / delete boys pickup sessions' },
      { id: 'u8-boys-dash',   target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u8'  }, icon: '👦', label: 'U8 Boys',              description: 'U8 boys teams — roster, schedule, attendance' },
      { id: 'u10-boys-dash',  target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u10' }, icon: '👦', label: 'U10 Boys',             description: 'U10 boys teams — roster, schedule, attendance' },
      { id: 'u12-boys-dash',  target: 'youth-roster',        params: { gender: 'youth', sex: 'boys', ageGroup: 'u12' }, icon: '👦', label: 'U12 Boys',             description: 'U12 boys teams — roster, schedule, attendance' },
    ];

    const girlsDashTiles = [
      { id: 'girls-lineups',  target: 'youth-roster',        params: { gender: 'youth', sex: 'girls', matchType: 'game' }, icon: '🧩', label: 'Girls Dashboard',    description: 'Girls teams — roster, schedule, attendance' },
      { id: 'girls-roster',   target: 'girls-roster',        params: { gender: 'youth', sex: 'girls' },                    icon: '🎽', label: 'Girls Roster',       description: 'Live LA roster — girls + boys together (mirror of Boys Roster while girls play on boys teams)' },
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

    // ── Financials tiles ─────────────────────────────────────────────
    // Single tile — the payments screen groups members by payment
    // status (Paid Up / Behind / Overdue / Never Paid) and lets the
    // operator filter by category (Men / Women / Boys / Girls) inside.
    const financialTiles = [
      { id: 'payments', target: 'payments', params: {}, icon: '💳', label: 'Payments', description: 'Members grouped by status: Paid Up · Behind · Overdue · Never Paid' },
    ];
    this._dashTiles = (this._dashTiles || []).concat(financialTiles);

    const finNav = this.find('#financials');
    if (finNav) {
      finNav.innerHTML = financialTiles.map(t => `
        <button class="btn btn-lg btn-secondary sub-nav-btn"
                data-section="${t.id}"
                style="height: auto; padding: var(--space-3); text-align: left;">
          <div style="font-size: 2rem; margin-bottom: var(--space-1);">${t.icon}</div>
          <div style="font-weight: 600; margin-bottom: var(--space-1);">${t.label}</div>
          <div style="opacity: 0.7; font-size: 0.85rem;">${t.description}</div>
        </button>
      `).join('');
    }

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

    if (section === 'paused-members') {
      this.navigation.goTo('paused-members', {
        clubId: this.clubId,
        clubName: this.clubName
      });
      return;
    }

    if (section === 'members') {
      // Reuses the paused-members screen with variant=active so we
      // don't maintain two nearly-identical class definitions.
      this.navigation.goTo('paused-members', {
        clubId: this.clubId,
        clubName: this.clubName,
        variant: 'active',
      });
      return;
    }

    // Per-category deep links.  Same screen, but the screen filters
    // groups client-side by category and updates the title so bulk
    // actions (email-all / copy-all) apply to a single sub-program.
    const catMatch = section.match(/^(paused-members|members)-(mens|womens|boys|girls)$/);
    if (catMatch) {
      const [, base, cat] = catMatch;
      const variant  = base === 'paused-members' ? 'paused' : 'active';
      // UI category ids map to DB `category` column values:
      //   mens   → men       womens → women
      //   boys   → boys      girls  → girls
      const dbCategory = cat === 'mens' ? 'men'
                       : cat === 'womens' ? 'women'
                       : cat;
      this.navigation.goTo('paused-members', {
        clubId:   this.clubId,
        clubName: this.clubName,
        variant,
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

    if (section === 'club-rosters') {
      this.navigation.goTo('club-rosters', {
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
