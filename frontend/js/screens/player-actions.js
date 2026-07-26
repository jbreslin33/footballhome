// PlayerActionsScreen — dedicated view for player-action catalogs.
class PlayerActionsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = 'Club';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-player-actions';
    div.innerHTML = `
      <div class="screen-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:var(--space-2);">
        <div style="display:flex; align-items:center; gap:var(--space-2);">
          <button class="btn btn-secondary back-btn">← Back</button>
          <div>
            <h1 style="margin:0;">Player Actions</h1>
            <p class="subtitle" style="margin:0;">Catalog of player actions by phase</p>
          </div>
        </div>
      </div>

      <div style="padding: var(--space-4); display:grid; gap: var(--space-3);">
        <div id="player-actions-content"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId ?? params?.club?.id ?? null;
    this.clubName = params?.clubName || 'Club';

    this.find('.back-btn')?.addEventListener('click', () => {
      this.navigation.goBack();
    });

    this.loadStructure();
  }

  loadStructure() {
    const container = this.find('#player-actions-content');
    if (!container) return;

    if (!this.clubId) {
      container.innerHTML = '<div style="opacity: 0.7;">No club selected.</div>';
      return;
    }

    container.innerHTML = '<div style="opacity: 0.7;">Loading player actions…</div>';

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure?_t=${Date.now()}`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        if (!this.isMounted) return;
        const data = payload?.data || payload;
        const structure = data && typeof data === 'object' && !Array.isArray(data) ? data : null;
        container.innerHTML = this.renderStructure(structure);
      })
      .catch(() => {
        if (!this.isMounted) return;
        container.innerHTML = '<div style="opacity: 0.7;">Unable to load player actions.</div>';
      });
  }

  renderStructure(structure) {
    const phases = Array.isArray(structure?.phases) ? structure.phases : [];
    if (!phases.length) {
      return '<div style="opacity: 0.7;">No player action data available yet.</div>';
    }

    const phasesMarkup = phases.map((phase) => {
      const actionCatalogsMarkup = this.renderActionCatalogs(phase.action_catalogs || []);
      return `
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <div style="display:flex; justify-content:space-between; align-items:flex-start; gap: var(--space-2); flex-wrap:wrap;">
            <div>
              <h3 style="margin: 0 0 0.25rem 0;">${this.escapeHtml(phase.label || phase.slug || 'Phase')}</h3>
              <p style="margin: 0; opacity: 0.8;">${this.escapeHtml(phase.description || '')}</p>
            </div>
            <div style="padding: 0.3rem 0.6rem; border-radius: 999px; background: rgba(255,255,255,0.06); font-size: 0.85rem; opacity: 0.8;">${this.escapeHtml(phase.slug || 'phase')}</div>
          </div>
          <div style="display:grid; gap: 0.9rem; margin-top: 0.2rem;">
            ${actionCatalogsMarkup || '<div style="opacity: 0.7;">No player actions yet.</div>'}
          </div>
        </article>
      `;
    }).join('');

    return `
      <div style="display:grid; gap: var(--space-3);">
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <h2 style="margin: 0;">Player Actions</h2>
          <p style="margin: 0; opacity: 0.9; line-height: 1.55;">The action catalog for each phase, separated from the game-model overview.</p>
        </article>
        ${phasesMarkup}
      </div>
    `;
  }

  renderActionCatalogs(actionCatalogs) {
    if (!Array.isArray(actionCatalogs) || actionCatalogs.length === 0) return '';
    return actionCatalogs.map((catalog) => {
      const categoriesMarkup = (catalog.categories || []).map((category) => {
        const itemsMarkup = (category.items || []).map((item) => `
          <div style="padding: var(--space-2) var(--space-3); border-left: 3px solid #60a5fa; background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
            <div style="opacity: 0.9; line-height: 1.45; white-space: pre-line;">${this.escapeHtml(item.description || '')}</div>
          </div>
        `).join('');
        return `
          <div style="display:grid; gap: 0.2rem;">
            <div style="padding: 0.15rem 0; ">
              <span style="display:inline-block; padding: 0.05rem 0.5rem; border-radius: 999px; background: var(--accent, #6ea8fe); color: #0b0f14; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em; margin-right:0.5rem;">Category</span>
              <strong>${this.escapeHtml(category.title || category.slug || 'Category')}</strong>
            </div>
            <div style="margin-top: 0.35rem; padding-left: 1.1rem; border-left: 2px dashed rgba(255,255,255,0.16); display:grid; gap: 0.5rem;">${itemsMarkup || '<div style="opacity: 0.7;">No items yet.</div>'}</div>
          </div>
        `;
      }).join('');

      return `
        <div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-md); background: rgba(255,255,255,0.03); display:grid; gap: 0.6rem;">
          <div style="font-weight: 700;">${this.escapeHtml(catalog.title || catalog.slug || 'Catalog')}</div>
          <div style="display:grid; gap: 0.8rem;">${categoriesMarkup || '<div style="opacity: 0.7;">No categories yet.</div>'}</div>
        </div>
      `;
    }).join('');
  }
}
