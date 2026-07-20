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

    // ── Game Model ───────────────────────────────────────────────────
    const gameModelTiles = [
      { id: 'game-model', icon: '🧠', label: 'Game Model', description: 'Open the club principles and weekly session plan on this page' },
    ];
    renderInto('#section-game-model', gameModelTiles);

    const gameModelContent = `
      <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
        <h4 style="margin: 0 0 var(--space-2) 0;">Core principles</h4>
        <div style="display: grid; gap: 0.5rem;">
          <div><strong>Build from the back</strong> — calm circulation and clean patterns before the attack becomes vertical.</div>
          <div><strong>Create overloads in the middle</strong> — the central shape should create rhythm and a free player.</div>
          <div><strong>Attack with purpose in the final third</strong> — every entry should create a chance, a rotation, or a numerical advantage.</div>
          <div><strong>Defend compact and aggressive</strong> — press together, recover together, and counter-press fast.</div>
          <div><strong>Be ruthless with standards</strong> — the identity is built by repetition and detail every day.</div>
        </div>
      </article>

      <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
        <h4 style="margin: 0 0 var(--space-2) 0;">Base formation: 4-4-2</h4>
        <div style="display: grid; gap: 0.5rem;">
          <div><strong>Exact setup by player count:</strong></div>
          <div><strong>If 6:</strong> 2-2-2 with a keeper; use a very small game and focus on quick passing and immediate support.</div>
          <div><strong>If 7:</strong> 2-3-2 with a keeper; keep the midfield compact and use the extra player as a connector.</div>
          <div><strong>If 8:</strong> 3-3-2 with a keeper; use a narrow 4-4-2-like shape in possession and defend with the front two pressing together.</div>
          <div><strong>If 9:</strong> 3-4-2 with a keeper; the extra midfielder becomes the main connector between the back line and the front two.</div>
          <div><strong>If 10:</strong> 4-4-2 with a keeper; this is the cleanest version of the base shape and the easiest to coach.</div>
          <div><strong>If 11:</strong> 4-4-2 with a keeper; use the full base shape with one extra player as a rotation option.</div>
          <div><strong>If 12:</strong> 4-4-2 plus 2 neutrals; split the group into two units and keep the same structure in both.</div>
          <div><strong>If 13:</strong> 4-4-2 plus 3 neutrals; use one neutral as the 10 and keep the rest of the shape intact.</div>
          <div><strong>If 14:</strong> 4-4-2 plus 4 neutrals; use two groups of 7 and keep the same positional rules in both.</div>
          <div><strong>If 15:</strong> 4-4-2 plus 5 neutrals; use two channels and rotate the neutrals in and out quickly.</div>
          <div><strong>If 16:</strong> 4-4-2 plus 6 neutrals; split into two parallel blocks and keep the same 4-4-2 rhythm in each.</div>
          <div><strong>If 17:</strong> 4-4-2 plus 7 neutrals; use a larger game with one extra neutral in the middle to keep the build alive.</div>
          <div><strong>If 18:</strong> 4-4-2 plus 8 neutrals; use two 9-player blocks and keep the same structure in both.</div>
          <div><strong>If 19+:</strong> 4-4-2 plus extra neutrals; split into two groups and keep the same base shape with quick rotation.</div>
          <div><strong>In possession:</strong> when the group is small, use the extra player as a connector; when the group is large, split into two channels and keep the same 4-4-2 principles.</div>
          <div><strong>Out of possession:</strong> the front two press together, the midfield stays compact, and the fullbacks step together when the ball is wide.</div>
          <div><strong>Attacking shape:</strong> the 10 connects the build to the finish and the wide midfielders support the overloads.</div>
          <div><strong>Defensive shape:</strong> the 4-4-2 should stay compact, recover quickly, and trigger the press from the front two.</div>
        </div>
      </article>

      <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
        <h4 style="margin: 0 0 var(--space-2) 0;">First-team priority model</h4>
        <div style="display: grid; gap: 0.5rem;">
          <div><strong>Eligibility rule:</strong> any player who wants to start must attend at least 2 training sessions per week before the next game.</div>
          <div><strong>Learning priority:</strong> the first team is the main learning environment. Position-specific work should be built around the first-team group because that is where the standards, the game model, and the roles are being reinforced.</div>
          <div><strong>Large squad reality:</strong> with 2 teams, the group may be around 70 players; with 3 teams, it may be around 105. Not everyone will attend every day, so the session should be designed around the first-team core and use the rest of the players as support, rotation, and overload players.</div>
          <div><strong>How to use the extra players:</strong> if the first-team core is small, use the extra players as neutrals and rotation players. If the first-team core is larger, split the session into parallel blocks and keep the same positional rules so the first team still gets the main reps.</div>
          <div><strong>Principle:</strong> the first team learns the model first; the other teams still improve because they are practicing inside that same environment and absorbing the same standards.</div>
        </div>
      </article>

      <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
        <h4 style="margin: 0 0 var(--space-2) 0;">Weekly session plan</h4>
        <div style="display: grid; gap: 0.75rem;">
          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="tuesday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Tuesday — Base build</strong>
            </button>
            <div id="tuesday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8; margin-bottom: 0.5rem;">Same Tuesday template every week; the exercise size changes with player numbers and the work stays continuous.</div>
              <div style="display: grid; gap: 0.5rem;">
                <div><strong>Exercise 1:</strong> Build from the back — <em>8–10:</em> 4v2 rondo, <em>11–14:</em> 6v4 pattern game with a neutral, <em>15–18:</em> 8v6 positional game in two channels, <em>19+:</em> 10v8+2 neutrals with constant rotation.</div>
                <div><strong>Exercise 2:</strong> Midfield overloads — <em>8–10:</em> 4v4+2, <em>11–14:</em> 6v6+4, <em>15–18:</em> 8v8+4 in two grids, <em>19+:</em> 10v10+4 with one team resting only briefly.</div>
                <div><strong>Exercise 3:</strong> Final-third finish — <em>8–10:</em> 3v3+GK, <em>11–14:</em> 5v5+GK, <em>15–18:</em> 7v7+GK, <em>19+:</em> 2 blocks of 7v7+GK so everyone stays involved.</div>
              </div>
            </div>
          </div>

          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="wednesday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Wednesday — Anchor day</strong>
            </button>
            <div id="wednesday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8; margin-bottom: 0.5rem;">This is the protected Wednesday template. It stays as the weekly reference until we intentionally change it.</div>
              <div style="display: grid; gap: 0.5rem;">
                <div><strong>Exercise 1:</strong> Positional play from the back — <em>8–10:</em> 5v5, <em>11–14:</em> 7v7, <em>15–18:</em> 9v9, <em>19+:</em> 11v11 in two lanes.</div>
                <div><strong>Exercise 2:</strong> Wide overloads and cutback — <em>8–10:</em> 4v4, <em>11–14:</em> 6v6, <em>15–18:</em> 8v8, <em>19+:</em> 10v10 with quick rotation and a neutral.</div>
                <div><strong>Exercise 3:</strong> Match-like finish — <em>8–10:</em> 5v5+GK, <em>11–14:</em> 7v7+GK, <em>15–18:</em> 9v9+GK, <em>19+:</em> 2 blocks of 8v8+GK.</div>
              </div>
            </div>
          </div>

          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="thursday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Thursday — Transition detail</strong>
            </button>
            <div id="thursday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8; margin-bottom: 0.5rem;">Same Thursday theme every week; the emphasis is on reactions after the first action and the team must stay active on every transition.</div>
              <div style="display: grid; gap: 0.5rem;">
                <div><strong>Exercise 1:</strong> Counter-press — <em>8–10:</em> 4v4, <em>11–14:</em> 6v6, <em>15–18:</em> 8v8, <em>19+:</em> 10v10 with one team rotating in immediately.</div>
                <div><strong>Exercise 2:</strong> Rest defence shape — <em>8–10:</em> 5v3, <em>11–14:</em> 7v5, <em>15–18:</em> 9v7, <em>19+:</em> 2 parallel units of 6v4.</div>
                <div><strong>Exercise 3:</strong> Transition finish — <em>8–10:</em> 3v3+GK, <em>11–14:</em> 5v5+GK, <em>15–18:</em> 7v7+GK, <em>19+:</em> 2 groups of 6v6+GK.</div>
              </div>
            </div>
          </div>

          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="friday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Friday — Match prep</strong>
            </button>
            <div id="friday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8; margin-bottom: 0.5rem;">Same Friday pattern work every week, focused on the next game rather than random intensity.</div>
              <div style="display: grid; gap: 0.5rem;">
                <div><strong>Exercise 1:</strong> Pattern repetition — <em>8–10:</em> 5v4, <em>11–14:</em> 7v6, <em>15–18:</em> 9v8, <em>19+:</em> 2 groups of 7v6.</div>
                <div><strong>Exercise 2:</strong> Final-third decision making — <em>8–10:</em> 4v4+GK, <em>11–14:</em> 6v6+GK, <em>15–18:</em> 8v8+GK, <em>19+:</em> 2 parallel blocks of 7v7+GK.</div>
                <div><strong>Exercise 3:</strong> Game-ready finish — <em>8–10:</em> 6v6, <em>11–14:</em> 8v8, <em>15–18:</em> 10v10, <em>19+:</em> 2 groups of 8v8.</div>
              </div>
            </div>
          </div>

          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="saturday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Saturday — Game rehearsal</strong>
            </button>
            <div id="saturday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8; margin-bottom: 0.5rem;">The session should feel like a rehearsal rather than a full training day. The shape is the same, the load changes, and nobody is left idle.</div>
              <div style="display: grid; gap: 0.5rem;">
                <div><strong>Exercise 1:</strong> Match rehearsal — <em>8–10:</em> 6v6, <em>11–14:</em> 8v8, <em>15–18:</em> 10v10, <em>19+:</em> 2 blocks of 8v8.</div>
                <div><strong>Exercise 2:</strong> Attacking rhythm — <em>8–10:</em> 4v3+GK, <em>11–14:</em> 6v5+GK, <em>15–18:</em> 8v7+GK, <em>19+:</em> 2 groups of 7v6+GK.</div>
                <div><strong>Exercise 3:</strong> Defensive recovery — <em>8–10:</em> 4v4, <em>11–14:</em> 6v6, <em>15–18:</em> 8v8, <em>19+:</em> 2 groups of 7v7 and constant rotation.</div>
              </div>
            </div>
          </div>

          <div style="border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden;">
            <button class="btn btn-secondary" type="button" data-toggle-section="sunday" style="width: 100%; text-align: left; justify-content: flex-start; border: 0; border-radius: 0; padding: var(--space-3);">
              <strong>Sunday — Game day</strong>
            </button>
            <div id="sunday" style="display: none; padding: var(--space-3); border-top: 1px solid var(--border-color);">
              <div style="opacity: 0.8;">The game is the live proof of the model. The session plan supports the match rather than taking over it.</div>
            </div>
          </div>
        </div>
      </article>
    `;
    const gameModelContentsEl = this.find('#game-model-contents');
    if (gameModelContentsEl) {
      gameModelContentsEl.innerHTML = gameModelContent;
    }

    this.element.querySelectorAll('[data-toggle-section]').forEach((button) => {
      button.addEventListener('click', () => {
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
        panel.style.display = isOpen ? 'none' : 'block';
      });
    });

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
      const panel = this.find('#game-model-panel');
      if (panel) {
        panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
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
