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
        <div id="section-rsvp" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🗓️ Soccer Calendar</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Google Calendar owns event timing and tags. Football Home mirrors soccer events here and translates FH details when classification exists.
        </p>
        <div id="section-schedule" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

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

    const practicePlanButton = this.find('.practice-plans-btn');
    if (practicePlanButton) {
      practicePlanButton.addEventListener('click', (event) => {
        event.preventDefault();
        event.stopPropagation();
        this.navigation.goTo('practice-plan', {
          clubId: this.clubId,
          clubName: this.clubName,
        });
      });
    }
    
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

  bindPracticePlanInteractions() {
    if (!this.element) return;

    this.element.querySelectorAll('[data-lightbox-src]').forEach((img) => {
      img.onclick = (event) => {
        event.stopPropagation();
        this.openImageLightbox(img.getAttribute('data-lightbox-src'));
      };
    });

    this.element.querySelectorAll('[data-toggle-practice-exercise]').forEach((button) => {
      button.onclick = (event) => {
        event.stopPropagation();
        const targetId = button.getAttribute('data-toggle-practice-exercise');
        const targetPanel = this.element.querySelector(`#${targetId}`);
        if (!targetPanel) return;
        const isOpen = targetPanel.style.display === 'block';
        this.element.querySelectorAll('[data-toggle-practice-exercise]').forEach((otherButton) => {
          const otherTargetId = otherButton.getAttribute('data-toggle-practice-exercise');
          const otherPanel = this.element.querySelector(`#${otherTargetId}`);
          if (otherPanel) {
            otherPanel.style.display = 'none';
          }
        });
        targetPanel.style.display = isOpen ? 'none' : 'block';
      };
    });
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

    const daysRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/days`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const practicesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const sessionsRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const sessionExercisesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/session_exercises`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const exercisesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const exerciseImagesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercise_images`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    Promise.all([structureRequest, daysRequest, practicesRequest, sessionsRequest, sessionExercisesRequest, exercisesRequest, exerciseImagesRequest])
      .then(([structure, days, practices, sessions, sessionExercises, exercises, exerciseImages]) => {
        if (!this.isMounted) return;

        const structureHtml = structure?.phases?.length
          ? this.renderStructuredGameModel(structure)
          : (structure?.content_html || structure?.content || '<div style="opacity: 0.7;">Game model content is not available yet.</div>');

        const practicePlanHtml = this.renderPracticePlanSection({ days, practices, sessions, sessionExercises, exercises, exerciseImages });

        contentsEl.innerHTML = `
          <div style="display:grid; gap: var(--space-3);">
            <div>${structureHtml}</div>
            <div>${practicePlanHtml}</div>
          </div>
        `;
        this.bindGameModelInteractions();
        this.bindPracticePlanInteractions();
      })
      .catch((error) => {
        if (!this.isMounted) return;
        contentsEl.innerHTML = `<div style="opacity: 0.7;">Unable to load game model content: ${this.escapeHtml(error.message)}</div>`;
      });
  }

  renderPracticePlanSection({ days = [], practices = [], sessions = [], sessionExercises = [], exercises = [], exerciseImages = [] }) {
    const dayMap = new Map((days || []).map((day) => [day.id, day]));
    const exerciseMap = new Map((exercises || []).map((exercise) => [exercise.id, exercise]));
    const exerciseDiagramMap = new Map();
    const exerciseDescriptionImageMap = new Map();
    (exerciseImages || []).forEach((img) => {
      if (img.role === 'diagram') exerciseDiagramMap.set(img.exercise_id, img.image_url);
      if (img.role === 'description') exerciseDescriptionImageMap.set(img.exercise_id, img.image_url);
    });
    const sessionExercisesBySession = new Map();

    (sessionExercises || []).forEach((entry) => {
      if (!entry?.session_id) return;
      const existing = sessionExercisesBySession.get(entry.session_id) || [];
      existing.push(entry);
      sessionExercisesBySession.set(entry.session_id, existing);
    });

    const buckets = [];
    const orderedDays = (days || [])
      .slice()
      .sort((a, b) => (a?.sort_order ?? 0) - (b?.sort_order ?? 0) || (a?.day_of_week ?? 0) - (b?.day_of_week ?? 0));

    orderedDays.forEach((day) => {
      buckets.push({ day, practices: [] });
    });

    const unscheduledBucket = { day: null, practices: [] };
    buckets.push(unscheduledBucket);

    (practices || []).forEach((practice) => {
      const day = practice?.day_id != null ? dayMap.get(practice.day_id) : null;
      const bucket = day ? buckets.find((entry) => entry.day?.id === day.id) : unscheduledBucket;
      if (bucket) {
        bucket.practices.push(practice);
      }
    });

    const dayBuckets = buckets.filter((bucket) => bucket.practices.length > 0);

    if (!dayBuckets.length) {
      return `
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin: 0 0 var(--space-2) 0;">Practice Days &amp; Sessions</h4>
          <p style="margin: 0; opacity: 0.8;">No practice-day data has been stored yet.</p>
        </article>
      `;
    }

    return `
      <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
        <div style="display:flex; justify-content:space-between; align-items:center; gap: var(--space-2); flex-wrap:wrap; margin-bottom: var(--space-3);">
          <div>
            <h4 style="margin: 0 0 var(--space-1) 0;">Practice Plans</h4>
            <p style="margin: 0; opacity: 0.8;">Weekly practice blocks under each day, with the Thursday block shown from the database.</p>
          </div>
        </div>
        <div style="display:grid; gap: var(--space-2);">
          ${dayBuckets.map((bucket) => {
            const dayLabel = bucket.day ? (bucket.day.label || this.getDayLabel(bucket.day.day_of_week) || 'Day') : 'Unscheduled';
            return `
              <div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-md); background: var(--bg-secondary);">
                <div style="font-weight: 700; margin-bottom: var(--space-2); text-transform: uppercase; letter-spacing: 0.06em;">${this.escapeHtml(dayLabel)}</div>
                <div style="display:grid; gap: var(--space-2);">
                  ${bucket.practices.map((practice) => {
                    const practiceSessions = (sessions || [])
                      .filter((session) => session?.practice_id === practice.id)
                      .sort((a, b) => (a?.sort_order || 0) - (b?.sort_order || 0));

                    const sessionMarkup = practiceSessions.length
                      ? practiceSessions.map((session) => {
                          const exerciseLinks = (sessionExercisesBySession.get(session.id) || [])
                            .map((link) => {
                              const exercise = exerciseMap.get(link.exercise_id);
                              if (!exercise) return '';
                              const detailId = `practice-exercise-${session.id}-${exercise.id}`;
                              const detailLines = [exercise.diagram_text, exercise.description, exercise.setup, exercise.coaching_points].filter(Boolean);
                              const descriptionImageUrl = exerciseDescriptionImageMap.get(exercise.id);
                              const descriptionImageMarkup = descriptionImageUrl
                                ? `<img src="${this.escapeHtml(descriptionImageUrl)}" alt="" data-lightbox-src="${this.escapeHtml(descriptionImageUrl)}" style="display:block; max-width:100%; width:220px; height:auto; border-radius:var(--radius-sm); border:1px solid var(--border-color); cursor:zoom-in; margin-bottom:0.4rem;">`
                                : '';
                              const detailMarkup = (detailLines.length || descriptionImageMarkup)
                                ? `<div id="${detailId}" style="display:none; margin-top: 0.4rem; padding: 0.6rem; border-radius: var(--radius-sm); background: rgba(255,255,255,0.04);">
                                    ${descriptionImageMarkup}
                                    ${detailLines.map((line) => `<div style="margin-top: 0.25rem; opacity: 0.9;">${this.escapeHtml(line)}</div>`).join('')}
                                  </div>`
                                : `<div id="${detailId}" style="display:none; margin-top: 0.4rem; padding: 0.6rem; border-radius: var(--radius-sm); background: rgba(255,255,255,0.04);">
                                    <div style="opacity: 0.75;">Details will be filled in as the plan is refined.</div>
                                  </div>`;
                              const diagramUrl = exerciseDiagramMap.get(exercise.id);
                              const diagramThumbMarkup = diagramUrl
                                ? `<img src="${this.escapeHtml(diagramUrl)}" alt="" data-lightbox-src="${this.escapeHtml(diagramUrl)}" style="width:28px; height:28px; object-fit:cover; border-radius:4px; border:1px solid var(--border-color); cursor:zoom-in; flex-shrink:0;">`
                                : '';
                              return `
                                <li style="margin-left: var(--space-3); list-style: none; margin-top: 0.25rem;">
                                  <button type="button" class="btn btn-secondary" data-toggle-practice-exercise="${detailId}" style="width: 100%; display:flex; align-items:center; gap:0.5rem; justify-content: flex-start; padding: 0.55rem 0.7rem; text-align: left;">
                                    ${diagramThumbMarkup}
                                    <span>${this.escapeHtml(exercise.title || 'Exercise')}</span>
                                  </button>
                                  ${detailMarkup}
                                </li>
                              `;
                            })
                            .filter(Boolean)
                            .join('');
                          const timeLabel = this.formatSessionWindow(practice.event_starts_at, session.start_time, session.end_time);
                          const firstExerciseTitle = (sessionExercisesBySession.get(session.id) || [])
                            .map((link) => exerciseMap.get(link.exercise_id))
                            .filter(Boolean)[0];
                          return `
                            <div style="padding: var(--space-2); border-left: 2px solid var(--accent); background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
                              <div style="font-weight: 600;">${this.escapeHtml(session.title || 'Session block')}</div>
                              ${timeLabel ? `<div style="opacity: 0.8; font-size: 0.9rem; margin-top: 0.15rem;">${this.escapeHtml(timeLabel)}</div>` : ''}
                              ${firstExerciseTitle ? `<div style="margin-top: 0.35rem; font-weight: 600;">${this.escapeHtml(firstExerciseTitle.title || 'Exercise')}</div>` : ''}
                              ${exerciseLinks ? `<ul style="margin: 0.35rem 0 0 0; padding-left: 0;">${exerciseLinks}</ul>` : ''}
                            </div>
                          `;
                        }).join('')
                      : '<div style="opacity: 0.75;">No sessions yet.</div>';

                    return `
                      <div style="padding: var(--space-2); border: 1px solid rgba(255,255,255,0.08); border-radius: var(--radius-sm); background: var(--bg-primary);">
                        <div style="font-weight: 600;">${this.escapeHtml(practice.event_summary || 'Practice plan')}</div>
                        ${practice.notes ? `<div style="opacity: 0.75; font-size: 0.9rem; margin-top: 0.2rem;">${this.escapeHtml(practice.notes)}</div>` : ''}
                        <div style="display:grid; gap: var(--space-2); margin-top: var(--space-2);">
                          ${sessionMarkup}
                        </div>
                      </div>
                    `;
                  }).join('')}
                </div>
              </div>
            `;
          }).join('')}
        </div>
      </article>
    `;
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
          description: 'Shared emails, matching name+DOB, split identities (a sign-in with no team beside a roster spot with no sign-in), and people touched by merges.',
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
    
    if (section === 'tactics') {
      this.navigation.goTo('tactical-board', {
        clubId: this.clubId,
        teamName: 'Club Wide' // Fallback for title
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

    // Placeholder - will implement actual navigation later
    alert(`${section.toUpperCase()} management coming soon for ${this.clubName}`);
  }
}
