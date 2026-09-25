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
        <h1 style="display:flex; align-items:center; gap:0.35em;"><span style="display:inline-flex; line-height:1;" aria-hidden="true">            <svg width="1em" height="1em" viewBox="0 0 32 32" fill="currentColor"><rect x="1" y="1" width="30" height="30" rx="1.5" fill="none" stroke="currentColor" stroke-width="2" /><g opacity="0.32">  <rect x="5.5" y="2" width="3.5" height="3.5" />  <rect x="12.5" y="2" width="3.5" height="3.5" />  <rect x="19.5" y="2" width="3.5" height="3.5" />  <rect x="26.5" y="2" width="3.5" height="3.5" />  <rect x="2" y="5.5" width="3.5" height="3.5" />  <rect x="9" y="5.5" width="3.5" height="3.5" />  <rect x="16" y="5.5" width="3.5" height="3.5" />  <rect x="23" y="5.5" width="3.5" height="3.5" />  <rect x="5.5" y="9" width="3.5" height="3.5" />  <rect x="12.5" y="9" width="3.5" height="3.5" />  <rect x="19.5" y="9" width="3.5" height="3.5" />  <rect x="26.5" y="9" width="3.5" height="3.5" />  <rect x="2" y="12.5" width="3.5" height="3.5" />  <rect x="9" y="12.5" width="3.5" height="3.5" />  <rect x="16" y="12.5" width="3.5" height="3.5" />  <rect x="23" y="12.5" width="3.5" height="3.5" />  <rect x="5.5" y="16" width="3.5" height="3.5" />  <rect x="12.5" y="16" width="3.5" height="3.5" />  <rect x="19.5" y="16" width="3.5" height="3.5" />  <rect x="26.5" y="16" width="3.5" height="3.5" />  <rect x="2" y="19.5" width="3.5" height="3.5" />  <rect x="9" y="19.5" width="3.5" height="3.5" />  <rect x="16" y="19.5" width="3.5" height="3.5" />  <rect x="23" y="19.5" width="3.5" height="3.5" />  <rect x="5.5" y="23" width="3.5" height="3.5" />  <rect x="12.5" y="23" width="3.5" height="3.5" />  <rect x="19.5" y="23" width="3.5" height="3.5" />  <rect x="26.5" y="23" width="3.5" height="3.5" />  <rect x="2" y="26.5" width="3.5" height="3.5" />  <rect x="9" y="26.5" width="3.5" height="3.5" />  <rect x="16" y="26.5" width="3.5" height="3.5" />  <rect x="23" y="26.5" width="3.5" height="3.5" /></g><!-- pawn (dark, with a light outline so it reads on either square) --><g stroke="currentColor" stroke-width="1.2" stroke-linejoin="round">  <circle cx="9.5" cy="16.5" r="2.4" />  <path d="M7 24.5c0-2.6 1.1-4.4 2.5-5.4 1.4 1 2.5 2.8 2.5 5.4z" />  <path d="M6 25h7v2H6z" /></g><!-- king --><g stroke="currentColor" stroke-width="1.2" stroke-linejoin="round">  <path d="M22 4.5h2v2h2v2h-2v2h-2v-2h-2v-2h2z" />  <path d="M19.5 22c0-4.2 1.5-7.2 3.5-8.6 2 1.4 3.5 4.4 3.5 8.6z" />  <path d="M18 23h10v2H18z" /></g>
            </svg></span> Tactical</h1>
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
