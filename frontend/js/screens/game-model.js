// GameModelScreen — club-wide game model rendered from the normalized DB structure
class GameModelScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = 'Club';
    this.selectedPhaseKey = null;
    this.selectedPlayerPhaseKey = null;
    this.selectedViewMode = 'all';
    this.showSubPrinciples = true;
    this.showPlayerActionItems = true;
    this.currentStructure = null;
  }

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
    this.selectedPhaseKey = null;
    this.selectedPlayerPhaseKey = null;
    this.selectedViewMode = 'all';
    this.showSubPrinciples = true;
    this.showPlayerActionItems = true;

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
    if (!container) return;
    if (!this.clubId) {
      container.innerHTML = '<div style="opacity: 0.7;">No club selected.</div>';
      return;
    }

    container.innerHTML = '<div style="opacity: 0.7;">Loading…</div>';

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure?_t=${Date.now()}`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        if (!this.isMounted) return;
        const data = payload?.data || payload;
        const structure = data && typeof data === 'object' && !Array.isArray(data) ? data : null;
        this.currentStructure = structure;
        container.innerHTML = this.renderStructure(structure);
        this.bindInteractions();
      })
      .catch(() => {
        if (!this.isMounted) return;
        container.innerHTML = '<div style="opacity: 0.7;">Unable to load game model.</div>';
      });
  }

  bindInteractions() {
    this.element.querySelectorAll('[data-phase-key]').forEach((button) => {
      button.addEventListener('click', () => {
        this.selectedPhaseKey = button.getAttribute('data-phase-key');
        this.selectedViewMode = 'all-game-model';
        const container = this.find('#game-model-page-content');
        if (container) {
          container.innerHTML = this.renderStructure(this.currentStructure);
          this.bindInteractions();
        }
      });
    });

    this.element.querySelectorAll('[data-player-phase-key]').forEach((button) => {
      button.addEventListener('click', () => {
        this.selectedPlayerPhaseKey = button.getAttribute('data-player-phase-key');
        this.selectedViewMode = 'just-player-actions';
        const container = this.find('#game-model-page-content');
        if (container) {
          container.innerHTML = this.renderStructure(this.currentStructure);
          this.bindInteractions();
        }
      });
    });

    this.element.querySelectorAll('[data-view-mode]').forEach((button) => {
      button.addEventListener('click', () => {
        this.selectedViewMode = button.getAttribute('data-view-mode') || 'all';
        const container = this.find('#game-model-page-content');
        if (container) {
          container.innerHTML = this.renderStructure(this.currentStructure);
          this.bindInteractions();
        }
      });
    });

    this.element.querySelectorAll('[data-toggle-sub-principles]').forEach((button) => {
      button.addEventListener('click', () => {
        this.showSubPrinciples = button.getAttribute('data-toggle-sub-principles') === 'show';
        const container = this.find('#game-model-page-content');
        if (container) {
          container.innerHTML = this.renderStructure(this.currentStructure);
          this.bindInteractions();
        }
      });
    });

    this.element.querySelectorAll('[data-toggle-player-action-items]').forEach((button) => {
      button.addEventListener('click', () => {
        this.showPlayerActionItems = button.getAttribute('data-toggle-player-action-items') === 'show';
        const container = this.find('#game-model-page-content');
        if (container) {
          container.innerHTML = this.renderStructure(this.currentStructure);
          this.bindInteractions();
        }
      });
    });

    this.element.querySelectorAll('[data-admin-entity]').forEach((button) => {
      button.addEventListener('click', () => {
        const entity = button.getAttribute('data-admin-entity');
        this.navigation.goTo('game-model-admin', {
          clubId: this.clubId,
          clubName: this.clubName,
          entity,
        });
      });
    });

    this.element.querySelectorAll('[data-player-actions]').forEach((button) => {
      button.addEventListener('click', () => {
        this.navigation.goTo('player-actions', {
          clubId: this.clubId,
          clubName: this.clubName,
        });
      });
    });
  }

  getDefaultPhases() {
    return [
      { id: 'attacking', slug: 'attacking', label: 'Attacking', description: 'How the team creates chances and attacks the goal.' },
      { id: 'defending', slug: 'defending', label: 'Defending', description: 'How the team closes space and protects the goal.' },
      { id: 'transition-to-attack', slug: 'transition-to-attack', label: 'Transition to Attack', description: 'How the team turns regain into immediate threat.' },
      { id: 'transition-to-defense', slug: 'transition-to-defense', label: 'Transition to Defense', description: 'How the team reacts when possession is lost.' },
      { id: 'in-possession', slug: 'in-possession', label: 'In Possession', description: 'The team’s patterns while they have the ball.' },
      { id: 'out-of-possession', slug: 'out-of-possession', label: 'Out of Possession', description: 'The team’s patterns when the opponent has the ball.' },
    ];
  }

  getGameModelPhaseOptions(phases) {
    const source = Array.isArray(phases) && phases.length ? phases : this.getDefaultPhases();
    return source.slice(0, 4).map((phase) => ({
      id: phase.id || phase.slug || phase.label,
      slug: phase.slug || phase.id || phase.label,
      label: phase.label || phase.slug || phase.id || 'Phase',
      description: phase.description || '',
      principles: phase.principles || [],
      action_catalogs: phase.action_catalogs || [],
    }));
  }

  getPlayerActionPhaseOptions(phases) {
    const source = Array.isArray(phases) && phases.length ? phases : this.getDefaultPhases();
    const preferred = [
      { id: 'in-possession', slug: 'in-possession', label: 'In Possession' },
      { id: 'out-of-possession', slug: 'out-of-possession', label: 'Out of Possession' },
      { id: 'attacking', slug: 'attacking', label: 'Attacking' },
      { id: 'defending', slug: 'defending', label: 'Defending' },
    ];

    return preferred.map((preferredPhase) => {
      const matched = source.find((phase) => {
        const phaseKey = String(phase.id || phase.slug || phase.label || '').trim().toLowerCase();
        const preferredKey = String(preferredPhase.id || preferredPhase.slug || preferredPhase.label || '').trim().toLowerCase();
        return phaseKey === preferredKey || String(phase.label || '').trim().toLowerCase() === String(preferredPhase.label || '').trim().toLowerCase();
      });

      return {
        id: matched?.id || preferredPhase.id,
        slug: matched?.slug || preferredPhase.slug,
        label: matched?.label || preferredPhase.label,
        description: matched?.description || '',
        principles: matched?.principles || [],
        action_catalogs: matched?.action_catalogs || [],
      };
    });
  }

  getSelectedPhase(phases, selectedKey = null) {
    if (!Array.isArray(phases) || phases.length === 0) return null;
    const key = String(selectedKey || this.selectedPhaseKey || '').trim().toLowerCase();
    if (!key) return phases[0];
    return phases.find((phase) => {
      const candidates = [phase.id, phase.slug, phase.label].filter(Boolean).map((value) => String(value).trim().toLowerCase());
      return candidates.includes(key);
    }) || phases[0];
  }

  renderStructure(structure) {
    const gameModel = structure?.game_model || {};
    const phases = Array.isArray(structure?.phases) && structure.phases.length ? structure.phases : this.getDefaultPhases();
    const gameModelPhases = this.getGameModelPhaseOptions(phases);
    const playerActionPhases = this.getPlayerActionPhaseOptions(phases);
    const selectedPhase = this.getSelectedPhase(gameModelPhases, this.selectedPhaseKey);
    const selectedPlayerActionPhase = this.getSelectedPhase(playerActionPhases, this.selectedPlayerPhaseKey);
    const gameModelPhaseButtons = gameModelPhases.map((phase) => {
      const isActive = selectedPhase && (String(phase.id || phase.slug || phase.label).toLowerCase() === String(selectedPhase.id || selectedPhase.slug || selectedPhase.label).toLowerCase());
      return `
        <button class="btn ${isActive ? 'btn-primary' : 'btn-secondary'}" type="button" data-phase-key="${this.escapeHtml(String(phase.id || phase.slug || phase.label))}" style="justify-content:flex-start;">
          ${this.escapeHtml(phase.label || phase.slug || 'Phase')}
        </button>
      `;
    }).join('');

    const playerActionPhaseButtons = playerActionPhases.map((phase) => {
      const isActive = selectedPlayerActionPhase && (String(phase.id || phase.slug || phase.label).toLowerCase() === String(selectedPlayerActionPhase.id || selectedPlayerActionPhase.slug || selectedPlayerActionPhase.label).toLowerCase());
      return `
        <button class="btn ${isActive ? 'btn-primary' : 'btn-secondary'}" type="button" data-player-phase-key="${this.escapeHtml(String(phase.id || phase.slug || phase.label))}" style="justify-content:flex-start;">
          ${this.escapeHtml(phase.label || phase.slug || 'Phase')}
        </button>
      `;
    }).join('');

    const viewButtons = [
      { key: 'all', label: 'All' },
      { key: 'all-game-model', label: 'All Game Model' },
      { key: 'just-player-actions', label: 'Just Player Actions' },
    ].map((button) => {
      const isActive = this.selectedViewMode === button.key;
      return `
        <button class="btn ${isActive ? 'btn-primary' : 'btn-secondary'}" type="button" data-view-mode="${button.key}">${this.escapeHtml(button.label)}</button>
      `;
    }).join('');

    const subPrinciplesButtons = `
      <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
        <button class="btn ${this.showSubPrinciples ? 'btn-primary' : 'btn-secondary'}" type="button" data-toggle-sub-principles="show">Show Sub Principles</button>
        <button class="btn ${this.showSubPrinciples ? 'btn-secondary' : 'btn-primary'}" type="button" data-toggle-sub-principles="hide">Hide Sub Principles</button>
      </div>
    `;

    const playerActionItemsButtons = `
      <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
        <button class="btn ${this.showPlayerActionItems ? 'btn-primary' : 'btn-secondary'}" type="button" data-toggle-player-action-items="show">Show Action Items</button>
        <button class="btn ${this.showPlayerActionItems ? 'btn-secondary' : 'btn-primary'}" type="button" data-toggle-player-action-items="hide">Hide Action Items</button>
      </div>
    `;

    const gameDetailMarkup = selectedPhase ? this.renderPhaseDetail(selectedPhase) : '<div style="opacity: 0.7;">Select a game-model phase to view the principles.</div>';
    const playerActionsMarkup = selectedPlayerActionPhase ? this.renderPlayerActionsDetail(selectedPlayerActionPhase) : '<div style="opacity: 0.7;">Select a player-action phase to view the catalog.</div>';
    const contentMarkup = this.selectedViewMode === 'all-game-model'
      ? gameDetailMarkup
      : this.selectedViewMode === 'just-player-actions'
        ? playerActionsMarkup
        : `${gameDetailMarkup}${playerActionsMarkup}`;

    return `
      <div style="display:grid; gap: var(--space-3);">
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <h2 style="margin: 0;">${this.escapeHtml(gameModel.title || 'Game Model')}</h2>
          <p style="margin: 0; opacity: 0.9; line-height: 1.55;">${this.escapeHtml(gameModel.summary || 'A normalized coaching framework with phases and principles.')}</p>
          ${gameModel.base_shape ? `<div style="margin-top: 0.25rem; opacity: 0.75;">Base shape: ${this.escapeHtml(gameModel.base_shape)}</div>` : ''}
        </article>

        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
            ${viewButtons}
          </div>
          <div style="display:grid; gap: var(--space-2); margin-top: 0.25rem;">
            <div style="font-weight: 700; opacity: 0.9; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.04em;">Game Model</div>
            <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
              ${gameModelPhaseButtons}
            </div>
            ${subPrinciplesButtons}
          </div>
          <div style="display:grid; gap: var(--space-2); margin-top: 0.25rem;">
            <div style="font-weight: 700; opacity: 0.9; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.04em;">Player Actions</div>
            <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
              ${playerActionPhaseButtons}
            </div>
            ${playerActionItemsButtons}
          </div>
          <div style="display:flex; flex-wrap:wrap; gap: var(--space-2); margin-top: 0.25rem;">
            <button class="btn btn-secondary" type="button" data-admin-entity="days">Days</button>
            <button class="btn btn-secondary" type="button" data-admin-entity="sessions">Sessions</button>
            <button class="btn btn-secondary" type="button" data-admin-entity="exercises">Exercises</button>
            <button class="btn btn-secondary" type="button" data-player-actions="true">Player Actions</button>
          </div>
        </article>

        ${contentMarkup}
      </div>
    `;
  }

  renderPlayerActionsDetail(phase) {
    const actionCatalogs = Array.isArray(phase?.action_catalogs) ? phase.action_catalogs : [];
    if (!actionCatalogs.length) {
      return `
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
          <div style="display:flex; justify-content:space-between; align-items:flex-start; gap: var(--space-2); flex-wrap:wrap;">
            <div>
              <h3 style="margin: 0 0 0.25rem 0;">${this.escapeHtml(phase?.label || phase?.slug || 'Player Actions')}</h3>
              <p style="margin: 0; opacity: 0.8;">No player actions are available for this phase yet.</p>
            </div>
          </div>
        </article>
      `;
    }

    const catalogsMarkup = actionCatalogs.map((catalog) => {
      const categoriesMarkup = (catalog.categories || []).map((category) => {
        const itemsMarkup = this.showPlayerActionItems
          ? (category.items || []).map((item) => `
              <div style="padding: var(--space-2) var(--space-3); border-left: 3px solid #60a5fa; background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
                <div style="opacity: 0.9; line-height: 1.45; white-space: pre-line;">${this.escapeHtml(item.description || '')}</div>
              </div>
            `).join('')
          : '';

        return `
          <div style="display:grid; gap: 0.2rem;">
            <div style="padding: 0.15rem 0;">
              <span style="display:inline-block; padding: 0.05rem 0.5rem; border-radius: 999px; background: var(--accent, #6ea8fe); color: #0b0f14; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em; margin-right:0.5rem;">Category</span>
              <strong>${this.escapeHtml(category.title || category.slug || 'Category')}</strong>
            </div>
            ${this.showPlayerActionItems ? `<div style="margin-top: 0.35rem; padding-left: 1.1rem; border-left: 2px dashed rgba(255,255,255,0.16); display:grid; gap: 0.5rem;">${itemsMarkup || '<div style="opacity: 0.7;">No items yet.</div>'}</div>` : ''}
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

    return `
      <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap: var(--space-2); flex-wrap:wrap;">
          <div>
            <h3 style="margin: 0 0 0.25rem 0;">${this.escapeHtml(phase?.label || phase?.slug || 'Player Actions')}</h3>
            <p style="margin: 0; opacity: 0.8;">Player-action catalog for this phase.</p>
          </div>
          <div style="padding: 0.3rem 0.6rem; border-radius: 999px; background: rgba(255,255,255,0.06); font-size: 0.85rem; opacity: 0.8;">${this.escapeHtml(phase?.slug || 'phase')}</div>
        </div>
        <div style="display:grid; gap: 0.9rem; margin-top: 0.2rem;">
          ${catalogsMarkup}
        </div>
      </article>
    `;
  }

  renderPhaseDetail(phase) {
    const principlesMarkup = this.renderPrincipleTree(phase.principles || []);
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
        </div>
      </article>
    `;
  }

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
    const subMarkup = this.showSubPrinciples ? this.renderSubPrinciples(subPrinciples) : '';

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
}
