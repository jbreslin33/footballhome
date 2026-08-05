// CoachHomeScreen — coach operations hub. Landing screen for the Coach
// role: My Week now hands off to MyScreen (my.js) — the same weekly
// schedule players use, where a coach/admin additionally gets P/A/L/E
// attendance controls per event (scoped to teams they actually coach,
// see CalendarController::isEventCoachOrAdmin). This screen also hosts
// club-wide roster/reminders/game-model tools (moved off admin-club so
// coach work is separate from club-admin work), plus a Teams entry
// point into the existing per-team flow (schedule, practices, matches,
// lineups via context-selection → team-dashboard).
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
        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">📋 My Week</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Every practice and match this week, across every team — set your own availability, or check in players.
        </p>
        <div id="section-week" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">⚽ My Teams</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Schedule, practices, matches, attendance, and lineups for a team you coach.
        </p>
        <div id="section-teams" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">🎽 Roster</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Assign players to teams — chip-switch between Mens (workbench) / Boys / Girls / All.
        </p>
        <div id="section-rosters" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📢 Reminders</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Event RSVP nudges. Mens reminders are live now; this section is the home for expanding the same workflow to women, boys, and girls.
        </p>
        <div id="section-reminders" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

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

  onEnter() {
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
      { id: 'attendance', target: 'my', params: {}, icon: '📋', label: 'Attendance & Availability', description: 'This week — set your own availability, or check in players for teams you coach' },
    ];
    renderInto('#section-week', weekTiles);

    const teamsTiles = [
      { id: 'teams', target: 'context-selection', params: { role: 'coach' }, icon: '⚽', label: 'Teams', description: 'Pick a team you coach to open its schedule, practices, matches, and lineups' },
    ];
    renderInto('#section-teams', teamsTiles);

    const rosterTiles = [
      { id: 'rosters', target: 'rosters', params: {}, icon: '🎽', label: 'Team Players', description: 'Assign every FH member to a team — one screen, chip-switch between Mens (workbench) / Boys / Girls / All (side-by-side)' },
    ];
    renderInto('#section-rosters', rosterTiles);

    const reminderTiles = [
      { id: 'event-reminders-mens', target: 'mens-events-reminders', params: { category: 'mens' }, icon: '📢', label: 'Event Reminders', description: 'Mens events now; same workflow can expand to women, boys, and girls' },
    ];
    renderInto('#section-reminders', reminderTiles);

    const gameModelTiles = [
      { id: 'game-model', target: 'game-model', params: {}, icon: '🧠', label: 'Game Model', description: 'Open the club’s live game-model view from the database' },
      { id: 'practice-plans', target: 'practice-plan', params: {}, icon: '📋', label: 'Practice Plans', description: 'Open the weekly day-by-day practice-plan view' },
      { id: 'game-model-days', target: 'game-model-admin', params: { entity: 'days' }, icon: '🗓️', label: 'Days', description: 'Create and edit the weekly day structure' },
      { id: 'game-model-exercises', target: 'game-model-admin', params: { entity: 'exercises' }, icon: '🏋️', label: 'Exercises', description: 'Manage the drills and activities used in sessions' },
    ];
    renderInto('#section-game-model', gameModelTiles);

    this._dashTiles = [...weekTiles, ...teamsTiles, ...rosterTiles, ...reminderTiles, ...gameModelTiles];

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
