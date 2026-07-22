// GameModelScreen — club-wide game model rendered from the normalized DB structure
class GameModelScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-game-model';

    div.innerHTML = `
      <div class="screen-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:var(--space-2);">
        <div style="display:flex; align-items:center; gap:var(--space-2);">
          <button class="btn btn-secondary back-btn">← Back</button>
          <h1 style="margin:0;">Game Model</h1>
        </div>
        <button class="btn btn-primary edit-game-model-btn">Edit Game Model</button>
      </div>

      <div style="padding: var(--space-4); display: grid; gap: var(--space-4);">
        <section id="game-model-page-content" style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: var(--space-4);"></section>
      </div>
    `;

    this.element = div;
    return div;
  }

  onEnter(params) {
    const requestedClubId = params?.clubId ?? params?.club?.id ?? 134;
    this.clubId = Number.isFinite(Number(requestedClubId)) ? Number(requestedClubId) : 134;
    this.clubName = params?.clubName || (this.clubId === 134 ? 'Lighthouse' : 'Club');

    this.find('.back-btn')?.addEventListener('click', () => {
      this.navigation.goBack();
    });

    this.find('.edit-game-model-btn')?.addEventListener('click', () => {
      this.navigation.goTo('game-model-admin', {
        clubId: this.clubId,
        clubName: this.clubName,
      });
    });

    this.loadStructure();
  }

  loadStructure() {
    const container = this.find('#game-model-page-content');
    if (!container) {
      return;
    }
    if (!this.clubId) {
      container.innerHTML = '<div style="opacity: 0.7;">No club selected.</div>';
      return;
    }

    container.innerHTML = '<div style="opacity: 0.7;">Loading…</div>';

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure`)
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
      .catch((error) => {
        if (!this.isMounted) return;
        container.innerHTML = `<div style="opacity: 0.7;">Unable to load game model.</div>`;
      });
  }

  renderStructure(structure) {
    const gameModel = structure?.game_model || {};
    const phases = Array.isArray(structure?.phases) ? structure.phases : [];

    const phasesMarkup = phases.map((phase) => {
      const principlesMarkup = this.renderPrincipleTree(phase.principles || []);
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
            <div style="display:grid; gap: 0.5rem;">
              <div style="font-weight: 700; opacity: 0.9; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.04em;">Principles</div>
              ${principlesMarkup || '<div style="opacity: 0.7;">No principles yet.</div>'}
            </div>
            <div style="display:grid; gap: 0.5rem;">
              <div style="font-weight: 700; opacity: 0.9; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.04em;">Player Actions</div>
              ${actionCatalogsMarkup || '<div style="opacity: 0.7;">No player actions yet.</div>'}
            </div>
          </div>
        </article>
      `;
    }).join('');

    return `
      <div style="display:grid; gap: var(--space-3);">
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <h2 style="margin: 0;">${this.escapeHtml(gameModel.title || 'Game Model')}</h2>
          <p style="margin: 0; opacity: 0.9; line-height: 1.55;">${this.escapeHtml(gameModel.summary || 'A normalized coaching framework with phases and principles.')}</p>
          ${gameModel.base_shape ? `<div style="margin-top: 0.25rem; opacity: 0.75;">Base shape: ${this.escapeHtml(gameModel.base_shape)}</div>` : ''}
        </article>
        ${phasesMarkup || '<div style="opacity: 0.7;">No phases available yet.</div>'}
      </div>
    `;
  }

  // Two fixed levels now: main principle → sub-principle (with its single
  // definition). Each level gets its own accent color; sub-principles live
  // inside a container with a continuous vertical guide line (border-left)
  // so the parent/child relationship is visible at a glance.
  renderPrincipleTree(principles) {
    if (!Array.isArray(principles) || principles.length === 0) return '';

    const items = principles
      .slice()
      .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
      .map((principle) => this.renderPrincipleNode(principle))
      .join('');

    return `<div style="display:grid; gap: 0.85rem;">${items}</div>`;
  }

  renderPrincipleNode(principle) {
    const color = 'var(--accent, #6ea8fe)';
    const subPrinciples = Array.isArray(principle.sub_principles) ? principle.sub_principles : [];
    const subMarkup = this.renderSubPrinciples(subPrinciples);

    return `
      <div style="display:grid; gap: 0.2rem;">
        <div style="padding: var(--space-2) var(--space-3); border-left: 4px solid ${color}; background: rgba(255,255,255,0.04); border-radius: var(--radius-sm); display:grid; gap: 0.3rem;">
          <div>
            <span style="display:inline-block; margin-right:0.5rem; padding: 0.05rem 0.5rem; border-radius: 999px; background: ${color}; color: #0b0f14; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em; vertical-align: middle;">Main Principle</span>
            <strong style="font-size: 1.02rem; font-weight: 800;">${this.escapeHtml(principle.title || principle.slug || 'Principle')}</strong>
          </div>
          ${principle.description ? `<div style="opacity: 0.8; line-height: 1.45;">${this.escapeHtml(principle.description)}</div>` : ''}
        </div>
        ${subMarkup ? `<div style="margin-top: 0.5rem; padding-left: 1.1rem; border-left: 2px dashed rgba(255,255,255,0.16); display:grid; gap: 0.6rem;">${subMarkup}</div>` : ''}
      </div>
    `;
  }

  renderSubPrinciples(subPrinciples) {
    if (!Array.isArray(subPrinciples) || subPrinciples.length === 0) return '';
    return subPrinciples
      .slice()
      .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
      .map((sub) => `
        <div style="display:grid; gap: 0.35rem;">
          <div style="padding: var(--space-2) var(--space-3); border-left: 4px solid #60a5fa; background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
            <span style="display:inline-block; margin-right:0.5rem; padding: 0.05rem 0.5rem; border-radius: 999px; background: #60a5fa; color: #0b0f14; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em; vertical-align: middle;">Sub Principle</span>
            <strong style="font-size: 0.97rem; font-weight: 700;">${this.escapeHtml(sub.title || sub.slug || 'Sub Principle')}</strong>
          </div>
          ${sub.definition ? `
            <div style="padding-left: 1.1rem; border-left: 2px dashed rgba(255,255,255,0.16);">
              <div style="padding: var(--space-2) var(--space-3); border-left: 4px solid #fbbf24; background: rgba(251,191,36,0.08); border-radius: var(--radius-sm); display:grid; gap: 0.3rem;">
                <span style="display:inline-block; width:fit-content; padding: 0.05rem 0.5rem; border-radius: 999px; background: #fbbf24; color: #1a1300; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em;">📖 Definition</span>
                <div style="opacity: 0.9; line-height: 1.5; white-space: pre-line; font-style: italic;">${this.escapeHtml(sub.definition)}</div>
              </div>
            </div>
          ` : ''}
        </div>
      `).join('');
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
