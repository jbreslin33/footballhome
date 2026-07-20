// GameModelScreen — club-wide game model rendered from the normalized DB structure
class GameModelScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-game-model';

    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Game Model</h1>
      </div>

      <div style="padding: var(--space-4); display: grid; gap: var(--space-4);">
        <section id="game-model-page-content" style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: var(--space-4);"></section>
      </div>
    `;

    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';

    this.find('.back-btn')?.addEventListener('click', () => {
      this.navigation.goBack();
    });

    this.loadStructure();
  }

  loadStructure() {
    const container = this.find('#game-model-page-content');
    if (!container || !this.clubId) {
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
      const principlesMarkup = (phase.principles || []).map((principle) => `
        <div style="padding: var(--space-2); border-left: 2px solid var(--accent); background: rgba(255,255,255,0.03); border-radius: var(--radius-sm);">
          <div><strong>${this.escapeHtml(principle.title || principle.slug || 'Principle')}</strong></div>
          <div style="margin-top: 0.2rem; opacity: 0.8;">${this.escapeHtml(principle.description || '')}</div>
        </div>
      `).join('');

      return `
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h3 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(phase.label || phase.slug || 'Phase')}</h3>
          <p style="margin: 0 0 var(--space-2) 0; opacity: 0.8;">${this.escapeHtml(phase.description || '')}</p>
          <div style="display:grid; gap: 0.6rem;">${principlesMarkup}</div>
        </article>
      `;
    }).join('');

    return `
      <div style="display:grid; gap: var(--space-3);">
        ${phasesMarkup || '<div style="opacity: 0.7;">No phases available yet.</div>'}
      </div>
    `;
  }
}
