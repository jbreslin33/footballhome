// TacticalScreen — #tactical — the club's tactical work in one place
// (owner 2026-09-25: "Game model and all that stuff belongs in a tactical
// section. tactical section should be top level on ui").
//
//   🧠 Game Model      (#game-model)        the live game model from the DB
//   📋 Practice Plans  (#practice-plan)     the weekly day-by-day plan
//   🗓️ Days            (#game-model-admin)  edit the weekly day structure
//   🏋️ Exercises       (#game-model-admin)  the drills used in sessions
//   📐 Tactical Board  (#tactical-board)    draw formations and movements
//
// These lived on the old coach-home page; that page went the same day
// (its only other tile was Teams, which is the top-level #teams board).
// Top-level tile on the role picker for admins and coaches.
class TacticalScreen extends Screen {
  static LIGHTHOUSE_CLUB_ID = 134;

  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = 'Club';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🧠 Tactical</h1>
        <p class="subtitle">The game model, the weekly plan, the exercises, and the board</p>
      </div>
      <div style="padding: var(--space-4);">
        <div id="tac-tiles" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>
      </div>
    `;
    this.element = div;
    div.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const btn = e.target.closest('[data-tile]');
      if (!btn) return;
      const tile = this._tiles().find(t => t.id === btn.dataset.tile);
      if (tile) this.navigation.goTo(tile.target, { ...tile.params });
    });
    return div;
  }

  async onEnter(params) {
    this.clubId = params?.clubId ?? null;
    this.clubName = params?.clubName || 'Club';
    if (!this.clubId) await this._resolveClub();
    this._renderTiles();
  }

  // The club whose model to open: the caller's, else the one club the
  // viewer coaches, else Lighthouse (the only club with a game model).
  async _resolveClub() {
    try {
      const res = await this.auth.fetch('/api/auth/coach/clubs');
      if (res.ok) {
        const clubs = (await res.json())?.data || [];
        if (clubs.length >= 1) { this.clubId = clubs[0].id; this.clubName = clubs[0].name; return; }
      }
    } catch (_) { /* fall through */ }
    this.clubId = TacticalScreen.LIGHTHOUSE_CLUB_ID;
    this.clubName = 'Lighthouse 1893 SC';
  }

  _tiles() {
    const club = { clubId: this.clubId, clubName: this.clubName };
    return [
      { id: 'game-model',     target: 'game-model',       params: { ...club },                      icon: '🧠', label: 'Game Model',     description: 'The club’s live game model — phases, principles, actions' },
      { id: 'practice-plans', target: 'practice-plan',    params: { ...club },                      icon: '📋', label: 'Practice Plans', description: 'The weekly day-by-day practice plan with player-count variations' },
      { id: 'days',           target: 'game-model-admin', params: { ...club, entity: 'days' },      icon: '🗓️', label: 'Days',           description: 'Create and edit the weekly day structure' },
      { id: 'exercises',      target: 'game-model-admin', params: { ...club, entity: 'exercises' }, icon: '🏋️', label: 'Exercises',      description: 'The drills and activities used in sessions' },
      { id: 'board',          target: 'tactical-board',   params: { ...club },                      icon: '📐', label: 'Tactical Board', description: 'Draw formations, runs and set pieces' },
    ];
  }

  _renderTiles() {
    const el = this.find('#tac-tiles');
    if (!el) return;
    el.innerHTML = this._tiles().map(t => `
      <button class="btn btn-lg btn-secondary sub-nav-btn" data-tile="${t.id}" style="height: auto; padding: var(--space-3); text-align: left;">
        <div style="font-size: 2rem; margin-bottom: var(--space-1);">${t.icon}</div>
        <div style="font-weight: 600; margin-bottom: var(--space-1);">${t.label}</div>
        <div style="opacity: 0.7; font-size: 0.85rem;">${t.description}</div>
      </button>`).join('');
  }
}
