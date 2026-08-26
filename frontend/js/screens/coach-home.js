// CoachHomeScreen — coach operations hub. Landing screen for the Coach
// role: My Week now hands off to MyScreen (my.js) — the same weekly
// schedule players use, where a coach/admin additionally gets P/A/L/E
// attendance controls per event (scoped to teams they actually coach,
// see CalendarController::isEventCoachOrAdmin). This screen also hosts
// club-wide roster/reminders/game-model tools (moved off admin-club so
// coach work is separate from club-admin work), plus a My Teams entry
// point into the existing per-team flow (schedule, practices, matches,
// lineups via context-selection → team-dashboard).
//
// Section order (2026-08-26): the Teams board (#teams) comes first —
// owner: "for coach role the first thing at top should be #Teams …
// reason is that is feature i use most for coach role". It was third,
// under a "Roster" heading, and its tile read "Team Players" while the
// route it opens is #teams; the tile now matches the route it lands on.
//
// The two are easy to confuse, so they are named for what you get:
//   Teams    (#teams)             — the whole board, every player, every
//                                   team, where you assign and move people.
//   My Teams (#context-selection) — pick one team you coach and open its
//                                   schedule / practices / matches / lineups.
class CoachHomeScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-coach-home';

    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Coach</h1>
        <p class="subtitle">Coach tools</p>
      </div>

      <div style="padding: var(--space-4);">
        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">🎽 Teams</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Every player and every team on one board — chip-switch between Mens (workbench) / Boys / Girls / All.
        </p>
        <div id="section-rosters" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📋 My Week</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Every practice and match this week, across every team — set your own availability, or check in players.
        </p>
        <div id="section-week" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚽ My Teams</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Schedule, practices, matches, attendance, and lineups for a team you coach.
        </p>
        <div id="section-teams" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🧠 Game Model</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          The club's game model, principles, and weekly session plan with player-count variations for each day.
        </p>
        <div id="section-game-model" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId ?? null;
    this.clubName = params?.clubName || 'Club';

    const renderInto = (elId, tiles) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = tiles.map(tile => `
        <button class="btn btn-lg btn-secondary sub-nav-btn"
                data-section="${tile.id}"
                style="height: auto; padding: var(--space-3); text-align: left;">
          <div style="font-size: 2rem; margin-bottom: var(--space-1);">${tile.icon}</div>
          <div style="font-weight: 600; margin-bottom: var(--space-1);">${tile.label}</div>
          <div style="opacity: 0.7; font-size: 0.85rem;">${tile.description}</div>
        </button>
      `).join('');
    };

    const weekTiles = [
      { id: 'attendance', target: 'my', params: {}, icon: '📋', label: 'Attendance & Availability', description: 'This week — set your own availability, check in players for teams you coach, and nudge no-response players' },
    ];
    renderInto('#section-week', weekTiles);

    const teamsTiles = [
      { id: 'teams', target: 'context-selection', params: { role: 'coach' }, icon: '⚽', label: 'My Teams', description: 'Pick a team you coach to open its schedule, practices, matches, and lineups' },
      { id: 'game-eligibility', target: 'mens-game-eligibility', params: { clubId: this.clubId, clubName: this.clubName }, icon: '🎯', label: 'Game-Day Analytics', description: 'Projected APSL & Liga 1 starting lineups + bench, based on attendance-tier probability' },
    ];
    renderInto('#section-teams', teamsTiles);

    const rosterTiles = [
      { id: 'rosters', target: 'teams', params: {}, icon: '🎽', label: 'Teams', description: 'Assign every FH member to a team — one screen, chip-switch between Mens (workbench) / Boys / Girls / All (side-by-side), with an Active/Inactive filter' },
    ];
    renderInto('#section-rosters', rosterTiles);

    const clubParams = { clubId: this.clubId, clubName: this.clubName };
    const gameModelTiles = [
      { id: 'game-model', target: 'game-model', params: { ...clubParams }, icon: '🧠', label: 'Game Model', description: 'Open the club’s live game-model view from the database' },
      { id: 'practice-plans', target: 'practice-plan', params: { ...clubParams }, icon: '📋', label: 'Practice Plans', description: 'Open the weekly day-by-day practice-plan view' },
      { id: 'game-model-days', target: 'game-model-admin', params: { ...clubParams, entity: 'days' }, icon: '🗓️', label: 'Days', description: 'Create and edit the weekly day structure' },
      { id: 'game-model-exercises', target: 'game-model-admin', params: { ...clubParams, entity: 'exercises' }, icon: '🏋️', label: 'Exercises', description: 'Manage the drills and activities used in sessions' },
    ];
    renderInto('#section-game-model', gameModelTiles);

    this._dashTiles = [...weekTiles, ...teamsTiles, ...rosterTiles, ...gameModelTiles];

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const subNavBtn = e.target.closest('.sub-nav-btn');
      if (subNavBtn) {
        const section = subNavBtn.getAttribute('data-section');
        const tile = (this._dashTiles || []).find(t => t.id === section);
        if (tile) {
          this.navigation.goTo(tile.target, { ...tile.params });
        }
      }
    });
  }
}
