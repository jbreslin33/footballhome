// GameModelAdminScreen - manage club game-model overview, days, sessions, and exercises
class GameModelAdminScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = 'Club';
    this.entities = [];
    this.selectedEntity = 'game-model';
    this.currentEditId = null;
    this.currentContext = null;
    this.parentOptions = { days: [], practices: [] };
    this.builderData = { days: [], practices: [], sessions: [] };
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-game-model-admin';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <div>
          <h1 id="game-model-admin-title">Game Model Admin</h1>
          <p class="subtitle" id="game-model-admin-subtitle">Build the club's 4-4-2 game model</p>
        </div>
      </div>
      <div style="padding: var(--space-4); display: grid; gap: var(--space-4);">
        <div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-secondary); color: var(--text-primary);">
          <strong>Game model structure:</strong> Principles, sub-principles, sub-sub-principles, and linked exercises are all managed as first-class items with their own IDs.
        </div>
        <div id="game-model-admin-content"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';
    this.selectedEntity = 'game-model';
    this.find('#game-model-admin-title').textContent = `${this.clubName} · Training`;
    this.find('#game-model-admin-subtitle').textContent = `Build ${this.clubName}'s 4-4-2 game model`;
    this.renderContent();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const inlineAction = e.target.closest('[data-inline-action]');
      if (inlineAction) {
        const action = inlineAction.getAttribute('data-inline-action');
        const id = parseInt(inlineAction.getAttribute('data-id'), 10);
        if (action === 'edit-day') {
          this.selectedEntity = 'days';
          this.currentContext = null;
          this.openEditor(id);
          return;
        }
        if (action === 'edit-phases') {
          this.selectedEntity = 'phases';
          this.currentContext = null;
          this.renderContent();
          return;
        }
        if (action === 'edit-principles') {
          this.selectedEntity = 'principles';
          this.currentContext = null;
          this.renderContent();
          return;
        }
        if (action === 'back-to-overview') {
          this.selectedEntity = 'game-model';
          this.currentContext = null;
          this.renderContent();
          return;
        }
        if (action === 'add-session') {
          this.quickAddSession(id);
          return;
        }
        if (action === 'edit-session') {
          this.selectedEntity = 'sessions';
          this.currentContext = null;
          this.openEditor(id);
          return;
        }
        if (action === 'add-exercise') {
          this.quickAddExercise(id);
          return;
        }
      }
      const addBtn = e.target.closest('.add-item-btn');
      if (addBtn) {
        this.openEditor(null);
      }
      const editBtn = e.target.closest('.edit-item-btn');
      if (editBtn) {
        this.openEditor(parseInt(editBtn.getAttribute('data-id'), 10));
      }
      const deleteBtn = e.target.closest('.delete-item-btn');
      if (deleteBtn) {
        this.deleteItem(parseInt(deleteBtn.getAttribute('data-id'), 10));
      }
      const saveBtn = e.target.closest('.save-item-btn');
      if (saveBtn) {
        this.saveItem();
      }
      const cancelBtn = e.target.closest('.cancel-item-btn');
      if (cancelBtn) {
        this.renderContent();
      }
    });
  }

  renderContent() {
    const container = this.find('#game-model-admin-content');
    if (!container) return;
    if (!this.clubId) {
      container.innerHTML = '<div class="empty-state"><p>No club selected.</p></div>';
      return;
    }

    if (this.selectedEntity === 'game-model') {
      container.innerHTML = '<div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">Loading overview…</div>';
      this.loadOverview();
      return;
    }

    container.innerHTML = '<div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">Loading…</div>';
    this.loadEntities();
  }

  loadOverview() {
    const container = this.find('#game-model-admin-content');
    if (!container || !this.clubId) return;

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        if (!this.isMounted) return;
        const data = payload?.data || payload;
        const structure = data && typeof data === 'object' && !Array.isArray(data) ? data : null;
        const html = structure?.phases?.length
          ? this.renderStructuredGameModel(structure)
          : this.getRenderableGameModelHtml(structure?.content_html || structure?.content || '');
        container.innerHTML = `
          <div style="display:grid;gap:var(--space-3);">
            <div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
              <div style="display:flex; justify-content:space-between; gap:var(--space-2); flex-wrap:wrap; align-items:center;">
                <div>
                  <h3 style="margin: 0 0 var(--space-2) 0;">4-4-2 game model</h3>
                  <p style="margin:0; opacity:0.8;">The club’s coaching identity is now stored in a normalized structure with phases and principles.</p>
                </div>
                <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                  <button class="btn btn-secondary" data-inline-action="edit-phases">Edit phases</button>
                  <button class="btn btn-secondary" data-inline-action="edit-principles">Edit principles</button>
                </div>
              </div>
              <div style="margin-top: var(--space-2); padding: var(--space-2); border-left: 3px solid var(--accent); background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
                Offense, defense, offensive transition, and defensive transition each carry their own principles so the language stays consistent across training and matches.
              </div>
            </div>
            <div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-secondary);">
              ${html}
            </div>
          </div>
        `;
      })
      .catch(() => {
        if (!this.isMounted) return;
        this.auth.fetch(`/api/clubs/${this.clubId}/game-model`)
          .then((response) => {
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return response.json();
          })
          .then((fallbackPayload) => {
            if (!this.isMounted) return;
            const fallbackData = fallbackPayload?.data || fallbackPayload;
            const html = this.getRenderableGameModelHtml(fallbackData?.content_html || fallbackData?.content || '');
            container.innerHTML = `
              <div style="display:grid;gap:var(--space-3);">
                <div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
                  <h3 style="margin: 0 0 var(--space-2) 0;">4-4-2 game model</h3>
                  <p style="margin:0; opacity:0.8;">The club’s coaching identity is now stored in a normalized structure with phases and principles.</p>
                </div>
                <div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-secondary);">
                  ${html}
                </div>
              </div>
            `;
          })
          .catch((error) => {
            if (!this.isMounted) return;
            container.innerHTML = `<div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">Unable to load overview: ${this.escapeHtml(error.message)}</div>`;
          });
      });
  }

  renderStructuredGameModel(structure) {
    if (!structure?.phases?.length) return this.getDefaultGameModelHtml();

    const phasesMarkup = structure.phases.map((phase) => {
      const principlesMarkup = (phase.principles || []).map((principle) => `
        <div style="padding: var(--space-2); border-left: 2px solid var(--accent); background: rgba(255,255,255,0.03); border-radius: var(--radius-sm);">
          <div><strong>${this.escapeHtml(principle.title || principle.slug)}</strong></div>
          <div style="margin-top: 0.2rem; opacity: 0.8;">${this.escapeHtml(principle.description || '')}</div>
          <div style="margin-top: 0.2rem; opacity: 0.7; font-size: 0.9rem; text-transform: capitalize;">${this.escapeHtml(principle.level || 'main')}</div>
        </div>
      `).join('');

      return `
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(phase.label || phase.slug)}</h4>
          <p style="margin: 0 0 var(--space-2) 0; opacity: 0.8;">${this.escapeHtml(phase.description || '')}</p>
          <div style="display:grid; gap: 0.6rem;">${principlesMarkup}</div>
        </article>
      `;
    }).join('');

    return `
      <div style="display:grid; gap: var(--space-3);">
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(structure.game_model?.title || 'Game Model')}</h4>
          <p style="margin: 0; opacity: 0.9;">${this.escapeHtml(structure.game_model?.summary || 'A normalized 4-4-2 coaching framework with phases and principles.')}</p>
          <div style="margin-top: var(--space-2); opacity: 0.75;">Base shape: ${this.escapeHtml(structure.game_model?.base_shape || '4-4-2')}</div>
        </article>
        ${phasesMarkup}
      </div>
    `;
  }

  getRenderableGameModelHtml(rawContent) {
    if (!rawContent) return this.getDefaultGameModelHtml();
    const legacyMarkers = ['Weekly preparation plan', 'data-toggle-section=', 'Base build', 'Final-third finish', 'Build from the back', 'Final-third combinations'];
    const hasLegacy = legacyMarkers.some((marker) => rawContent.includes(marker));
    return hasLegacy ? this.getDefaultGameModelHtml() : rawContent;
  }

  getDefaultGameModelHtml() {
    return `
      <div style="display:grid;gap:var(--space-3);">
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin:0 0 var(--space-2) 0;">Base shape: 4-4-2</h4>
          <p style="margin:0; opacity:0.9;">The team plays with a compact 4-4-2 in and out of possession. The full-back and wide midfielder create width; the two central midfielders connect the build and the attack; the front two split the defensive line and press together.</p>
        </article>

        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin:0 0 var(--space-2) 0;">Offense</h4>
          <div style="display:grid;gap:0.6rem;">
            <div><strong>Principle 1:</strong> Build from the back with calm circulation and clean support angles.</div>
            <div><strong>Sub-principle:</strong> The first pass should always create an extra body or an easy line.</div>
            <div><strong>Sub-sub-principle:</strong> The receiver should receive on the half-turn or with a body shape that allows the next action immediately.</div>
            <div><strong>Principle 2:</strong> Create overloads in the middle to free a player in the attacking third.</div>
            <div><strong>Sub-principle:</strong> The central midfielders connect the build to the attack and help the wide players become dangerous.</div>
            <div><strong>Sub-sub-principle:</strong> The third-man run is the main trigger for the breakthrough.</div>
            <div><strong>Principle 3:</strong> Finish with purpose in the final third.</div>
            <div><strong>Sub-principle:</strong> Every attack should try to create a chance, a cross, or a line-breaking run.</div>
            <div><strong>Sub-sub-principle:</strong> The front two attack the space behind the back line and the wide midfielders stretch the block.</div>
          </div>
        </article>

        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin:0 0 var(--space-2) 0;">Defense</h4>
          <div style="display:grid;gap:0.6rem;">
            <div><strong>Principle 1:</strong> Defend compact and aggressive as a unit.</div>
            <div><strong>Sub-principle:</strong> The front two press together and the midfielders protect the central lane.</div>
            <div><strong>Sub-sub-principle:</strong> The nearest player presses, the second player covers, and the third player balances the space.</div>
            <div><strong>Principle 2:</strong> Force play to the outside and deny central penetration.</div>
            <div><strong>Sub-principle:</strong> The full-backs and wide midfielders defend the touchline and protect the central channel.</div>
            <div><strong>Sub-sub-principle:</strong> The back line stays compact so the opposition cannot play through the middle.</div>
            <div><strong>Principle 3:</strong> Recover quickly after the first pressure action.</div>
            <div><strong>Sub-principle:</strong> Counter-press immediately if the ball is won.</div>
            <div><strong>Sub-sub-principle:</strong> If the ball is lost, the first recovery run should be to protect the central space and the second to support the counter-press.</div>
          </div>
        </article>

        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin:0 0 var(--space-2) 0;">Transitions</h4>
          <div style="display:grid;gap:0.6rem;">
            <div><strong>Transition to offense:</strong> As soon as the ball is won, the team should play forward quickly and create a numerical advantage in the next zone.</div>
            <div><strong>Sub-principle:</strong> The first pass should break the line or create a second action.</div>
            <div><strong>Sub-sub-principle:</strong> The wide midfielder and full-back both support the attack in the first two passes.</div>
            <div><strong>Transition to defense:</strong> If the ball is lost, the team should sprint back into the compact shape and protect the middle.</div>
            <div><strong>Sub-principle:</strong> The first two players to recover must make the shape compact again.</div>
            <div><strong>Sub-sub-principle:</strong> The pressure is immediate but the shape must stay organized.</div>
          </div>
        </article>
      </div>
    `;
  }

  loadEntities() {
    const container = this.find('#game-model-admin-content');
    if (!container || !this.clubId) return;
    const endpoint = `/api/clubs/${this.clubId}/game-model/admin/${this.selectedEntity}`;
    const requests = [this.auth.fetch(endpoint).then((response) => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json();
    })];

    if (this.selectedEntity === 'days') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'sessions') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'principles') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/phases`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'practices') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'practices') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/days`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    }

    Promise.all(requests)
      .then((results) => {
        if (!this.isMounted) return;
        const payload = results[0];
        const items = this.getPayloadItems(payload);
        this.entities = items;

        if (this.selectedEntity === 'days') {
          this.builderData.days = items;
          this.builderData.practices = this.getPayloadItems(results[1]);
          this.builderData.sessions = this.getPayloadItems(results[2]);
          this.parentOptions.days = items;
        } else if (this.selectedEntity === 'practices' && results[1]) {
          this.parentOptions.days = this.getPayloadItems(results[1]);
        } else if (this.selectedEntity === 'sessions' && results[1]) {
          this.parentOptions.practices = this.getPayloadItems(results[1]);
        } else if (this.selectedEntity === 'principles' && results[1]) {
          this.parentOptions.phases = this.getPayloadItems(results[1]);
        }

        container.innerHTML = this.renderList(items);
      })
      .catch((error) => {
        if (!this.isMounted) return;
        container.innerHTML = `<div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">Unable to load ${this.selectedEntity}: ${this.escapeHtml(error.message)}</div>`;
      });
  }

  getPayloadItems(payload) {
    if (Array.isArray(payload)) return payload;
    if (payload && Array.isArray(payload.data)) return payload.data;
    return [];
  }

  renderList(items) {
    if (this.selectedEntity === 'days') {
      return this.renderWeekBuilder();
    }

    const title = this.selectedEntity.charAt(0).toUpperCase() + this.selectedEntity.slice(1);
    return `
      <div style="display:grid;gap:var(--space-3);">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:var(--space-2);flex-wrap:wrap;">
          <div>
            <h3 style="margin:0;">${title}</h3>
            <p style="margin:0.2rem 0 0; opacity:0.8; font-size:0.9rem;">${this.getEntityHelperText()}</p>
          </div>
          <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
            <button class="btn btn-secondary" data-inline-action="back-to-overview">Back to overview</button>
            <button class="btn btn-primary add-item-btn">Add ${title}</button>
          </div>
        </div>
        <div style="display:grid;gap:var(--space-2);">
          ${items.length ? items.map((item) => this.renderItem(item)).join('') : '<div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-md); background: var(--bg-primary);">No items yet.</div>'}
        </div>
      </div>
    `;
  }

  renderWeekBuilder() {
    const days = this.builderData.days || [];
    return `
      <div style="display:grid;gap:var(--space-3);">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:var(--space-2);flex-wrap:wrap;">
          <div>
            <h3 style="margin:0;">Weekly builder</h3>
            <p style="margin:0.2rem 0 0; opacity:0.8; font-size:0.9rem;">Use the week as a reusable template. Add or edit days, then place sessions under each day.</p>
          </div>
          <button class="btn btn-primary add-item-btn">Add Day</button>
        </div>
        <div style="display:grid;gap:var(--space-2);">
          ${days.length ? days.map((day) => this.renderWeekBuilderDay(day)).join('') : '<div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-md); background: var(--bg-primary);">No days yet.</div>'}
        </div>
      </div>
    `;
  }

  renderWeekBuilderDay(day) {
    const practices = (this.builderData.practices || []).filter((practice) => practice.day_id === day.id);
    return `
      <div style="border:1px solid var(--border-color); border-radius:var(--radius-lg); padding:var(--space-3); background:var(--bg-primary); display:grid; gap:var(--space-2);">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:var(--space-2);flex-wrap:wrap;">
          <div>
            <div style="font-weight:700; color: var(--text-primary);">${this.escapeHtml(day.label || day.slug || 'Untitled day')}</div>
            ${day.description ? `<div style="opacity:0.8; font-size:0.9rem; margin-top:0.2rem;">${this.escapeHtml(day.description)}</div>` : ''}
          </div>
          <div style="display:flex;gap:var(--space-2);">
            <button class="btn btn-secondary" data-inline-action="edit-day" data-id="${day.id}">Edit day</button>
            <button class="btn btn-primary" data-inline-action="add-session" data-id="${day.id}">Add session</button>
          </div>
        </div>
        <div style="display:grid;gap:var(--space-2);">
          ${practices.length ? practices.map((practice) => this.renderWeekBuilderPractice(practice)).join('') : '<div style="padding: var(--space-2); border: 1px dashed var(--border-color); border-radius: var(--radius-md); opacity:0.7;">No sessions yet for this day.</div>'}
        </div>
      </div>
    `;
  }

  renderWeekBuilderPractice(practice) {
    const sessions = (this.builderData.sessions || []).filter((session) => session.practice_id === practice.id);
    return `
      <div style="padding: var(--space-2); border: 1px solid var(--border-color); border-radius: var(--radius-md); background: var(--bg-secondary); display:grid; gap:var(--space-2);">
        <div style="font-weight:600; color: var(--text-primary);">${this.escapeHtml(practice.title || 'Untitled practice')}</div>
        <div style="display:grid;gap:var(--space-2);">
          ${sessions.length ? sessions.map((session) => `
            <div style="padding: var(--space-2); border-left: 3px solid var(--accent); border-radius: var(--radius-sm); background: rgba(255,255,255,0.03); display:grid; gap:0.35rem;">
              <div style="display:flex; justify-content:space-between; align-items:center; gap:var(--space-2); flex-wrap:wrap;">
                <div style="font-weight:600;">${this.escapeHtml(session.title || 'Untitled session')}</div>
                <div style="display:flex; gap:var(--space-2);">
                  <button class="btn btn-secondary" data-inline-action="edit-session" data-id="${session.id}">Edit</button>
                  <button class="btn btn-primary" data-inline-action="add-exercise" data-id="${session.id}">Add exercise</button>
                </div>
              </div>
              ${session.summary ? `<div style="opacity:0.8; font-size:0.9rem;">${this.escapeHtml(session.summary)}</div>` : ''}
              ${session.start_time || session.end_time ? `<div style="opacity:0.7; font-size:0.85rem;">${this.escapeHtml([session.start_time, session.end_time].filter(Boolean).join(' - '))}</div>` : ''}
            </div>
          `).join('') : '<div style="opacity:0.7;">No sessions in this block yet.</div>'}
        </div>
      </div>
    `;
  }

  getEntityHelperText() {
    switch (this.selectedEntity) {
      case 'days':
        return 'Create the weekly day containers that make up the reusable week: Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, Monday.';
      case 'phases':
        return 'Edit the major phases of the game model such as offense, defense, offensive transition, and defensive transition.';
      case 'principles':
        return 'Edit the principles inside each phase, including the main and sub-principles.';
      case 'sessions':
        return 'Add the training blocks inside each day so the week can be reused next week.';
      case 'exercises':
        return 'Build the drill library that sessions can reuse across weeks.';
      default:
        return 'Build the weekly plan once, then reuse and adjust it over time.';
    }
  }

  renderItem(item) {
    const id = item.id;
    const label = item.title || item.label || item.name || item.slug || 'Untitled';
    const subtitle = item.summary || item.description || item.notes || '';
    const meta = [];
    if (item.slug) meta.push(`slug: ${item.slug}`);
    if (item.player_count != null) meta.push(`players: ${item.player_count}`);
    if (item.duration_minutes != null) meta.push(`duration: ${item.duration_minutes}m`);
    if (item.start_time) meta.push(`start: ${item.start_time}`);
    if (item.end_time) meta.push(`end: ${item.end_time}`);

    let parentLabel = '';
    if (this.selectedEntity === 'practices' && item.day_id != null) {
      const day = this.parentOptions.days.find((entry) => entry.id === item.day_id);
      parentLabel = day ? `Day: ${day.label || day.slug || day.title || item.day_id}` : `Day ID: ${item.day_id}`;
    } else if (this.selectedEntity === 'sessions' && item.practice_id != null) {
      const practice = this.parentOptions.practices.find((entry) => entry.id === item.practice_id);
      parentLabel = practice ? `Practice: ${practice.title || practice.label || practice.name || item.practice_id}` : `Practice ID: ${item.practice_id}`;
    } else if (this.selectedEntity === 'principles' && item.phase_id != null) {
      const phase = this.parentOptions.phases.find((entry) => entry.id === item.phase_id);
      parentLabel = phase ? `Phase: ${phase.label || phase.slug || phase.title || item.phase_id}` : `Phase ID: ${item.phase_id}`;
    }

    return `
      <div style="border:1px solid var(--border-color); border-radius:var(--radius-lg); padding:var(--space-3); background:var(--bg-primary); display:grid; gap:var(--space-2);">
        <div style="display:flex; justify-content:space-between; gap:var(--space-2); flex-wrap:wrap;">
          <div>
            <div style="font-weight:700; color: var(--text-primary);">${this.escapeHtml(label)}</div>
            ${subtitle ? `<div style="opacity:0.8; font-size:0.9rem; margin-top:0.2rem;">${this.escapeHtml(subtitle)}</div>` : ''}
            ${parentLabel ? `<div style="opacity:0.75; font-size:0.85rem; margin-top:0.25rem;">${this.escapeHtml(parentLabel)}</div>` : ''}
          </div>
          <div style="display:flex;gap:var(--space-2);">
            <button class="btn btn-secondary edit-item-btn" data-id="${id}">Edit</button>
            <button class="btn btn-danger delete-item-btn" data-id="${id}">Delete</button>
          </div>
        </div>
        ${meta.length ? `<div style="opacity:0.75; font-size:0.85rem;">${meta.join(' · ')}</div>` : ''}
      </div>
    `;
  }

  openEditor(id, context = null) {
    const container = this.find('#game-model-admin-content');
    if (!container) return;
    this.currentEditId = id;
    this.currentContext = context || this.currentContext || null;
    const item = this.entities.find((entry) => entry.id === id) || null;
    const title = this.selectedEntity.charAt(0).toUpperCase() + this.selectedEntity.slice(1);
    const fields = this.getFields(item, this.currentContext);
    container.innerHTML = `
      <div style="border:1px solid var(--border-color); border-radius:var(--radius-lg); padding:var(--space-4); background:var(--bg-primary); display:grid; gap:var(--space-3);">
        <h3 style="margin:0;">${id ? `Edit ${title}` : `Add ${title}`}</h3>
        <div style="display:grid;gap:var(--space-2);">
          ${fields.map((field) => this.renderField(field)).join('')}
        </div>
        <div style="display:flex;gap:var(--space-2);flex-wrap:wrap;">
          <button class="btn btn-primary save-item-btn">Save</button>
          <button class="btn btn-secondary cancel-item-btn">Cancel</button>
        </div>
      </div>
    `;
  }

  getFields(item, context = null) {
    const base = item || {};
    switch (this.selectedEntity) {
      case 'days':
        return [
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'label', label: 'Label', value: base.label || '', type: 'text' },
          { key: 'description', label: 'Description', value: base.description || '', type: 'textarea' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      case 'phases':
        return [
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'label', label: 'Label', value: base.label || '', type: 'text' },
          { key: 'description', label: 'Description', value: base.description || '', type: 'textarea' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      case 'principles':
        return [
          { key: 'phase_id', label: 'Phase', value: base.phase_id != null ? base.phase_id : '', type: 'select', options: this.parentOptions.phases.map((entry) => ({ value: entry.id, label: entry.label || entry.slug || entry.title || `Phase ${entry.id}` })) },
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'level', label: 'Level', value: base.level || 'main', type: 'text' },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'description', label: 'Description', value: base.description || '', type: 'textarea' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      case 'sessions': {
        const defaultPracticeId = context?.dayId != null
          ? (this.parentOptions.practices.find((entry) => entry.day_id === context.dayId) || {}).id || base.practice_id || ''
          : base.practice_id != null ? base.practice_id : '';
        return [
          { key: 'practice_id', label: 'Practice', value: defaultPracticeId, type: 'select', options: this.parentOptions.practices.map((entry) => ({ value: entry.id, label: entry.title || entry.label || entry.name || `Practice ${entry.id}` })) },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'summary', label: 'Summary', value: base.summary || '', type: 'textarea' },
          { key: 'start_time', label: 'Start Time', value: base.start_time || '', type: 'text' },
          { key: 'end_time', label: 'End Time', value: base.end_time || '', type: 'text' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      }
      case 'exercises':
        return [
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'summary', label: 'Summary', value: base.summary || '', type: 'textarea' },
          { key: 'setup', label: 'Setup', value: base.setup || '', type: 'textarea' },
          { key: 'coaching_points', label: 'Coaching Points', value: base.coaching_points || '', type: 'textarea' },
          { key: 'simulator_slug', label: 'Simulator Slug', value: base.simulator_slug || '', type: 'text' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      default:
        return [];
    }
  }

  renderField(field) {
    const inputId = `gm-admin-field-${field.key}`;
    if (field.type === 'textarea') {
      return `
        <label style="display:grid;gap:0.25rem;font-weight:600;">
          <span>${this.escapeHtml(field.label)}</span>
          <textarea id="${inputId}" style="min-height: 90px; padding: 0.7rem; border-radius: var(--radius-sm); border: 1px solid var(--border-color); background: var(--bg-primary);">${this.escapeHtml(field.value || '')}</textarea>
        </label>
      `;
    }
    if (field.type === 'select') {
      const options = (field.options || []).map((option) => {
        const selected = String(option.value) === String(field.value) ? 'selected' : '';
        return `<option value="${this.escapeHtml(String(option.value))}" ${selected}>${this.escapeHtml(option.label)}</option>`;
      }).join('');
      return `
        <label style="display:grid;gap:0.25rem;font-weight:600;">
          <span>${this.escapeHtml(field.label)}</span>
          <select id="${inputId}" style="padding:0.7rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); background: var(--bg-primary);">
            <option value="">Select…</option>
            ${options}
          </select>
        </label>
      `;
    }
    return `
      <label style="display:grid;gap:0.25rem;font-weight:600;">
        <span>${this.escapeHtml(field.label)}</span>
        <input id="${inputId}" type="${field.type}" value="${this.escapeHtml(field.value || '')}" style="padding:0.7rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); background: var(--bg-primary);">
      </label>
    `;
  }

  quickAddSession(dayId) {
    this.selectedEntity = 'sessions';
    this.currentEditId = null;
    this.currentContext = { dayId };
    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        if (!this.isMounted) return;
        this.parentOptions.practices = this.getPayloadItems(payload);
        this.openEditor(null, this.currentContext);
      })
      .catch((error) => {
        console.error(error);
        this.renderContent();
      });
  }

  quickAddExercise(sessionId) {
    this.selectedEntity = 'exercises';
    this.currentEditId = null;
    this.currentContext = { sessionId };
    this.openEditor(null, this.currentContext);
  }

  saveItem() {
    const payload = { club_id: this.clubId };
    if (this.currentEditId != null) {
      payload.id = this.currentEditId;
    }
    const existingItem = this.currentEditId != null
      ? this.entities.find((entry) => entry.id === this.currentEditId) || null
      : null;
    const fields = this.getFields(existingItem);
    fields.forEach((field) => {
      const el = this.find(`#gm-admin-field-${field.key}`);
      if (!el) return;
      const raw = el.value;
      payload[field.key] = field.type === 'number' && raw !== '' ? Number(raw) : raw;
    });
    const endpoint = `/api/clubs/${this.clubId}/game-model/admin/${this.selectedEntity}`;
    this.auth.fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
      .then((response) => response.json())
      .then(() => {
        this.currentEditId = null;
        this.currentContext = null;
        this.renderContent();
      })
      .catch((error) => {
        console.error(error);
        this.renderContent();
      });
  }

  deleteItem(id) {
    if (!window.confirm('Delete this item?')) return;
    const endpoint = `/api/clubs/${this.clubId}/game-model/admin/${this.selectedEntity}/${id}`;
    this.auth.fetch(endpoint, { method: 'DELETE' })
      .then((response) => response.json())
      .then(() => {
        this.currentContext = null;
        this.renderContent();
      })
      .catch((error) => {
        console.error(error);
      });
  }
}
