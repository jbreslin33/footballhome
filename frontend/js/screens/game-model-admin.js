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
    this.parentOptions = {
      days: [], practices: [], phases: [], principles: [], sub_principles: [],
      exercises: [], sessions: [], practice_events: [], action_items: []
    };
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-game-model-admin';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <div>
          <h1 id="game-model-admin-title">Game Model Admin</h1>
          <p class="subtitle" id="game-model-admin-subtitle">Build the club's U17+ game model</p>
        </div>
      </div>
      <div style="padding: var(--space-4); display: grid; gap: var(--space-4);">
        <div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-secondary); color: var(--text-primary);">
          <strong>Game model structure:</strong> Main principles and their sub-principles are managed as first-class items with their own IDs.
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
    const validEntities = [
      'days', 'phases', 'principles', 'sub_principles', 'exercises',
      'practices', 'sessions', 'session_exercises',
      'exercise_principles', 'exercise_sub_principles', 'exercise_action_items'
    ];
    this.selectedEntity = validEntities.includes(params?.entity) ? params.entity : 'game-model';
    this.currentContext = null;
    this.find('#game-model-admin-title').textContent = `${this.clubName} · Training`;
    this.find('#game-model-admin-subtitle').textContent = `Build ${this.clubName}'s U17+ game model`;
    this.renderContent();
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const inlineAction = e.target.closest('[data-inline-action]');
      if (inlineAction) {
        const action = inlineAction.getAttribute('data-inline-action');
        const actionEntityMap = {
          'edit-phases': 'phases',
          'edit-principles': 'principles',
          'edit-sub-principles': 'sub_principles',
          'edit-days': 'days',
          'edit-exercises': 'exercises',
          'edit-practices': 'practices',
          'edit-sessions': 'sessions',
          'edit-session-exercises': 'session_exercises',
          'edit-exercise-principles': 'exercise_principles',
          'edit-exercise-sub-principles': 'exercise_sub_principles',
          'edit-exercise-action-items': 'exercise_action_items',
          'back-to-overview': 'game-model'
        };
        if (Object.prototype.hasOwnProperty.call(actionEntityMap, action)) {
          this.switchEntity(actionEntityMap[action]);
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

  // Switches the visible entity without pushing a new browser-history
  // entry (Back should still leave the whole Game Model Admin screen in
  // one step), but still keeps the visible URL honest about which
  // sub-view is on screen.
  switchEntity(entity) {
    this.selectedEntity = entity;
    this.currentContext = null;
    const hash = entity === 'game-model' ? '#game-model-admin' : `#game-model-admin/${entity}`;
    window.history.replaceState(window.history.state, '', hash);
    this.renderContent();
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

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure?_t=${Date.now()}`)
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
                  <h3 style="margin: 0 0 var(--space-2) 0;">U17+ game model</h3>
                  <p style="margin:0; opacity:0.8;">The club’s coaching identity is now stored in a normalized structure aligned to the U.S. Soccer framework.</p>
                </div>
                <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                  <button class="btn btn-secondary" data-inline-action="edit-phases">Edit phases</button>
                  <button class="btn btn-secondary" data-inline-action="edit-principles">Edit principles</button>
                  <button class="btn btn-secondary" data-inline-action="edit-sub-principles">Edit sub-principles</button>
                </div>
              </div>
              <div style="margin-top: var(--space-2); padding: var(--space-2); border-left: 3px solid var(--accent); background: rgba(255,255,255,0.04); border-radius: var(--radius-sm);">
                Attack, defend, transition to attack, and transition to defense each carry their own principles so the language stays consistent across training and matches.
              </div>
            </div>
            <div style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
              <h3 style="margin: 0 0 var(--space-2) 0;">Practice plan</h3>
              <p style="margin:0 0 var(--space-2) 0; opacity:0.8;">Days are reusable weekly buckets. Practices link to real calendar events. Sessions are time blocks inside a practice, and exercises are the drill library sessions draw from.</p>
              <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
                <button class="btn btn-secondary" data-inline-action="edit-days">Edit days</button>
                <button class="btn btn-secondary" data-inline-action="edit-exercises">Edit exercises</button>
                <button class="btn btn-secondary" data-inline-action="edit-practices">Edit practices</button>
                <button class="btn btn-secondary" data-inline-action="edit-sessions">Edit sessions</button>
                <button class="btn btn-secondary" data-inline-action="edit-session-exercises">Edit session exercises</button>
                <button class="btn btn-secondary" data-inline-action="edit-exercise-principles">Tag exercises: principles</button>
                <button class="btn btn-secondary" data-inline-action="edit-exercise-sub-principles">Tag exercises: sub-principles</button>
                <button class="btn btn-secondary" data-inline-action="edit-exercise-action-items">Tag exercises: action items</button>
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
                  <h3 style="margin: 0 0 var(--space-2) 0;">U17+ game model</h3>
                  <p style="margin:0; opacity:0.8;">The club’s coaching identity is now stored in a normalized structure aligned to the U.S. Soccer framework.</p>
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

    const renderPrinciples = (principles) => {
      return (principles || [])
        .slice()
        .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
        .map((principle) => this.renderStructuredPrincipleNode(principle))
        .join('');
    };

    const phasesMarkup = structure.phases.map((phase) => `
      <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
        <h4 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(phase.label || phase.slug)}</h4>
        <p style="margin: 0 0 var(--space-2) 0; opacity: 0.8;">${this.escapeHtml(phase.description || '')}</p>
        <div style="display:grid; gap: 0.6rem; margin-top: var(--space-2);">${renderPrinciples(phase.principles || [])}</div>
      </article>
    `).join('');

    return `
      <div style="display:grid; gap: var(--space-3);">
        <article style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h4 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(structure.game_model?.title || 'Game Model')}</h4>
          <p style="margin: 0; opacity: 0.9;">${this.escapeHtml(structure.game_model?.summary || 'A normalized coaching framework with phases and principles.')}</p>
          <div style="margin-top: var(--space-2); opacity: 0.75;">Base shape: ${this.escapeHtml(structure.game_model?.base_shape || '11v11')}</div>
        </article>
        ${phasesMarkup}
      </div>
    `;
  }

  renderStructuredPrincipleNode(principle) {
    const subMarkup = (principle.sub_principles || [])
      .slice()
      .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
      .map((sub) => `
        <div style="padding: var(--space-2); border-left: 2px solid #60a5fa; background: rgba(255,255,255,0.03); border-radius: var(--radius-sm);">
          <div><strong>Sub Principle:</strong> ${this.escapeHtml(sub.title || sub.slug || 'Sub Principle')}</div>
          ${sub.definition ? `<div style="margin-top: 0.2rem; opacity: 0.8; white-space: pre-line;">${this.escapeHtml(sub.definition)}</div>` : ''}
        </div>
      `)
      .join('');

    return `
      <div style="padding: var(--space-2); border-left: 2px solid var(--accent); background: rgba(255,255,255,0.03); border-radius: var(--radius-sm);">
        <div><strong>Main Principle:</strong> ${this.escapeHtml(principle.title || principle.slug || 'Principle')}</div>
        ${principle.description ? `<div style="margin-top: 0.2rem; opacity: 0.8;">${this.escapeHtml(principle.description)}</div>` : ''}
        ${subMarkup ? `<div style="display:grid; gap: 0.6rem; margin-top: 0.6rem;">${subMarkup}</div>` : ''}
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
          <h4 style="margin:0 0 var(--space-2) 0;">U17+ game model</h4>
          <p style="margin:0; opacity:0.9;">The club’s coaching identity is stored in a normalized framework aligned to the U.S. Soccer U17+ model.</p>
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

    if (this.selectedEntity === 'sessions') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'principles') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/phases`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'sub_principles') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/principles`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'practices') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practice_events`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/days`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'session_exercises') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'exercise_principles') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/principles`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'exercise_sub_principles') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sub_principles`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
    } else if (this.selectedEntity === 'exercise_action_items') {
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      }));
      requests.push(this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/action_items_flat`).then((response) => {
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

        if (this.selectedEntity === 'sessions' && results[1]) {
          this.parentOptions.practices = this.getPayloadItems(results[1]);
        } else if (this.selectedEntity === 'principles') {
          this.parentOptions.phases = this.getPayloadItems(results[1]);
        } else if (this.selectedEntity === 'sub_principles') {
          this.parentOptions.principles = this.getPayloadItems(results[1]);
        } else if (this.selectedEntity === 'practices') {
          this.parentOptions.practice_events = this.getPayloadItems(results[1]);
          this.parentOptions.days = this.getPayloadItems(results[2]);
        } else if (this.selectedEntity === 'session_exercises') {
          this.parentOptions.sessions = this.getPayloadItems(results[1]);
          this.parentOptions.exercises = this.getPayloadItems(results[2]);
        } else if (this.selectedEntity === 'exercise_principles') {
          this.parentOptions.exercises = this.getPayloadItems(results[1]);
          this.parentOptions.principles = this.getPayloadItems(results[2]);
        } else if (this.selectedEntity === 'exercise_sub_principles') {
          this.parentOptions.exercises = this.getPayloadItems(results[1]);
          this.parentOptions.sub_principles = this.getPayloadItems(results[2]);
        } else if (this.selectedEntity === 'exercise_action_items') {
          this.parentOptions.exercises = this.getPayloadItems(results[1]);
          this.parentOptions.action_items = this.getPayloadItems(results[2]);
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

  getEntityTitle() {
    switch (this.selectedEntity) {
      case 'sub_principles': return 'Sub-Principle';
      case 'session_exercises': return 'Session Exercise';
      case 'exercise_principles': return 'Exercise ↔ Principle';
      case 'exercise_sub_principles': return 'Exercise ↔ Sub-Principle';
      case 'exercise_action_items': return 'Exercise ↔ Action Item';
      default: return this.selectedEntity.charAt(0).toUpperCase() + this.selectedEntity.slice(1);
    }
  }

  renderList(items) {
    const title = this.getEntityTitle();
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

  getEntityHelperText() {
    switch (this.selectedEntity) {
      case 'days':
        return 'Reusable weekly day buckets (Monday, Tuesday, …) that a practice can be tagged with.';
      case 'phases':
        return 'Edit the major phases of the game model such as attack, defend, transition to attack, and transition to defense.';
      case 'principles':
        return 'Edit the main principles inside each phase.';
      case 'sub_principles':
        return 'Edit the sub-principles that belong to each main principle, including their definition text.';
      case 'exercises':
        return 'Build the drill library that sessions can reuse across weeks.';
      case 'practices':
        return 'Link a real calendar practice event (Google Calendar owns the date/time) to an optional weekly day bucket, with notes.';
      case 'sessions':
        return 'Time blocks inside a practice (e.g. Warmup, Rondo block, Scrimmage), each with its own start/end time.';
      case 'session_exercises':
        return 'Place an exercise inside a session. Same sequence_order = concurrent stations; increasing = sequential blocks.';
      case 'exercise_principles':
        return 'Tag an exercise with the main principle(s) it reinforces, for coverage reporting.';
      case 'exercise_sub_principles':
        return 'Tag an exercise with the sub-principle(s) it reinforces, for coverage reporting.';
      case 'exercise_action_items':
        return 'Tag an exercise with the player action item(s) it reinforces, for coverage reporting.';
      default:
        return 'Build the weekly plan once, then reuse and adjust it over time.';
    }
  }

  renderItem(item) {
    const id = item.id;
    let label = item.title || item.label || item.name || item.slug || 'Untitled';
    let subtitle = item.summary || item.description || item.definition || item.notes || '';
    const meta = [];
    if (item.slug) meta.push(`slug: ${item.slug}`);
    if (item.day_of_week != null) meta.push(`day: ${this.getDayOfWeekLabel(item.day_of_week)}`);
    if (item.min_players != null) meta.push(`min players: ${item.min_players}`);
    if (item.max_players != null) meta.push(`max players: ${item.max_players}`);
    if (item.default_duration_minutes != null) meta.push(`duration: ${item.default_duration_minutes}m`);
    if (item.player_count != null) meta.push(`players: ${item.player_count}`);
    if (item.sequence_order != null) meta.push(`sequence: ${item.sequence_order}`);
    if (item.start_time) meta.push(`start: ${item.start_time}`);
    if (item.end_time) meta.push(`end: ${item.end_time}`);

    let parentLabel = '';
    if (this.selectedEntity === 'practices') {
      label = item.event_summary || `Practice #${id}`;
      subtitle = item.event_starts_at ? new Date(item.event_starts_at).toLocaleString() : '';
      if (item.day_id != null) {
        const day = this.parentOptions.days.find((entry) => entry.id === item.day_id);
        parentLabel = day ? `Day: ${day.label || day.slug || item.day_id}` : `Day ID: ${item.day_id}`;
      }
    } else if (this.selectedEntity === 'sessions' && item.practice_id != null) {
      const practice = this.parentOptions.practices.find((entry) => entry.id === item.practice_id);
      parentLabel = practice ? `Practice: ${practice.event_summary || practice.id}` : `Practice ID: ${item.practice_id}`;
    } else if (this.selectedEntity === 'session_exercises') {
      const session = this.parentOptions.sessions.find((entry) => entry.id === item.session_id);
      const exercise = this.parentOptions.exercises.find((entry) => entry.id === item.exercise_id);
      label = exercise ? exercise.title : `Exercise ID: ${item.exercise_id}`;
      parentLabel = session ? `Session: ${session.title || session.id}` : `Session ID: ${item.session_id}`;
    } else if (this.selectedEntity === 'exercise_principles') {
      const exercise = this.parentOptions.exercises.find((entry) => entry.id === item.exercise_id);
      const principle = this.parentOptions.principles.find((entry) => entry.id === item.principle_id);
      label = `${exercise ? exercise.title : `Exercise ${item.exercise_id}`} → ${principle ? principle.title : `Principle ${item.principle_id}`}`;
      subtitle = '';
    } else if (this.selectedEntity === 'exercise_sub_principles') {
      const exercise = this.parentOptions.exercises.find((entry) => entry.id === item.exercise_id);
      const subPrinciple = this.parentOptions.sub_principles.find((entry) => entry.id === item.sub_principle_id);
      label = `${exercise ? exercise.title : `Exercise ${item.exercise_id}`} → ${subPrinciple ? subPrinciple.title : `Sub-Principle ${item.sub_principle_id}`}`;
      subtitle = '';
    } else if (this.selectedEntity === 'exercise_action_items') {
      const exercise = this.parentOptions.exercises.find((entry) => entry.id === item.exercise_id);
      const actionItem = this.parentOptions.action_items.find((entry) => entry.id === item.action_item_id);
      label = `${exercise ? exercise.title : `Exercise ${item.exercise_id}`} → ${actionItem ? actionItem.description : `Action Item ${item.action_item_id}`}`;
      subtitle = '';
    } else if (this.selectedEntity === 'principles') {
      if (item.phase_id != null) {
        const phase = this.parentOptions.phases.find((entry) => entry.id === item.phase_id);
        parentLabel = phase ? `Phase: ${phase.label || phase.slug || phase.title || item.phase_id}` : `Phase ID: ${item.phase_id}`;
      }
    } else if (this.selectedEntity === 'sub_principles') {
      if (item.principle_id != null) {
        const principle = this.parentOptions.principles.find((entry) => entry.id === item.principle_id);
        parentLabel = principle ? `Principle: ${principle.title || principle.slug || item.principle_id}` : `Principle ID: ${item.principle_id}`;
      }
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

  getDayOfWeekLabel(dayOfWeek) {
    const labels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return labels[dayOfWeek] != null ? labels[dayOfWeek] : String(dayOfWeek);
  }


  openEditor(id, context = null) {
    const container = this.find('#game-model-admin-content');
    if (!container) return;
    this.currentEditId = id;
    this.currentContext = context || this.currentContext || null;
    const item = this.entities.find((entry) => entry.id === id) || null;
    const title = this.getEntityTitle();
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
          { key: 'day_of_week', label: 'Day of Week', value: base.day_of_week != null ? base.day_of_week : '', type: 'select', options: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((name, index) => ({ value: index, label: name })) },
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
      case 'principles': {
        return [
          { key: 'phase_id', label: 'Phase', value: base.phase_id != null ? base.phase_id : '', type: 'select', options: this.parentOptions.phases.map((entry) => ({ value: entry.id, label: entry.label || entry.slug || entry.title || `Phase ${entry.id}` })) },
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'description', label: 'Description', value: base.description || '', type: 'textarea' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      }
      case 'sub_principles': {
        return [
          { key: 'principle_id', label: 'Principle', value: base.principle_id != null ? base.principle_id : '', type: 'select', options: this.parentOptions.principles.map((entry) => ({ value: entry.id, label: entry.title || entry.slug || `Principle ${entry.id}` })) },
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'definition', label: 'Definition', value: base.definition || '', type: 'textarea' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      }
      case 'practices': {
        return [
          { key: 'fh_event_id', label: 'Calendar Practice Event', value: base.fh_event_id != null ? base.fh_event_id : '', type: 'select', options: this.parentOptions.practice_events.map((entry) => ({ value: entry.id, label: `${entry.summary || 'Untitled event'} — ${entry.starts_at ? new Date(entry.starts_at).toLocaleString() : ''}` })) },
          { key: 'day_id', label: 'Weekly Day (optional)', value: base.day_id != null ? base.day_id : '', type: 'select', options: this.parentOptions.days.map((entry) => ({ value: entry.id, label: entry.label || entry.slug || `Day ${entry.id}` })) },
          { key: 'notes', label: 'Notes', value: base.notes || '', type: 'textarea' }
        ];
      }
      case 'sessions': {
        return [
          { key: 'practice_id', label: 'Practice', value: base.practice_id != null ? base.practice_id : '', type: 'select', options: this.parentOptions.practices.map((entry) => ({ value: entry.id, label: entry.event_summary || `Practice ${entry.id}` })) },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'notes', label: 'Notes', value: base.notes || '', type: 'textarea' },
          { key: 'start_time', label: 'Start Time', value: base.start_time || '', type: 'text' },
          { key: 'end_time', label: 'End Time', value: base.end_time || '', type: 'text' },
          { key: 'sort_order', label: 'Sort Order', value: base.sort_order != null ? base.sort_order : '', type: 'number' }
        ];
      }
      case 'session_exercises': {
        return [
          { key: 'session_id', label: 'Session', value: base.session_id != null ? base.session_id : '', type: 'select', options: this.parentOptions.sessions.map((entry) => ({ value: entry.id, label: entry.title || `Session ${entry.id}` })) },
          { key: 'exercise_id', label: 'Exercise', value: base.exercise_id != null ? base.exercise_id : '', type: 'select', options: this.parentOptions.exercises.map((entry) => ({ value: entry.id, label: entry.title || `Exercise ${entry.id}` })) },
          { key: 'sequence_order', label: 'Sequence Order', value: base.sequence_order != null ? base.sequence_order : '', type: 'number' },
          { key: 'player_count', label: 'Player Count', value: base.player_count != null ? base.player_count : '', type: 'number' },
          { key: 'notes', label: 'Notes', value: base.notes || '', type: 'textarea' }
        ];
      }
      case 'exercise_principles': {
        return [
          { key: 'exercise_id', label: 'Exercise', value: base.exercise_id != null ? base.exercise_id : '', type: 'select', options: this.parentOptions.exercises.map((entry) => ({ value: entry.id, label: entry.title || `Exercise ${entry.id}` })) },
          { key: 'principle_id', label: 'Principle', value: base.principle_id != null ? base.principle_id : '', type: 'select', options: this.parentOptions.principles.map((entry) => ({ value: entry.id, label: entry.title || entry.slug || `Principle ${entry.id}` })) }
        ];
      }
      case 'exercise_sub_principles': {
        return [
          { key: 'exercise_id', label: 'Exercise', value: base.exercise_id != null ? base.exercise_id : '', type: 'select', options: this.parentOptions.exercises.map((entry) => ({ value: entry.id, label: entry.title || `Exercise ${entry.id}` })) },
          { key: 'sub_principle_id', label: 'Sub-Principle', value: base.sub_principle_id != null ? base.sub_principle_id : '', type: 'select', options: this.parentOptions.sub_principles.map((entry) => ({ value: entry.id, label: entry.title || entry.slug || `Sub-Principle ${entry.id}` })) }
        ];
      }
      case 'exercise_action_items': {
        return [
          { key: 'exercise_id', label: 'Exercise', value: base.exercise_id != null ? base.exercise_id : '', type: 'select', options: this.parentOptions.exercises.map((entry) => ({ value: entry.id, label: entry.title || `Exercise ${entry.id}` })) },
          { key: 'action_item_id', label: 'Action Item', value: base.action_item_id != null ? base.action_item_id : '', type: 'select', options: this.parentOptions.action_items.map((entry) => ({ value: entry.id, label: `${entry.catalog_title || ''} · ${entry.category_title || ''} · ${entry.description || ''}` })) }
        ];
      }
      case 'exercises':
        return [
          { key: 'slug', label: 'Slug', value: base.slug || '', type: 'text' },
          { key: 'title', label: 'Title', value: base.title || '', type: 'text' },
          { key: 'summary', label: 'Summary', value: base.summary || '', type: 'textarea' },
          { key: 'setup', label: 'Setup', value: base.setup || '', type: 'textarea' },
          { key: 'coaching_points', label: 'Coaching Points', value: base.coaching_points || '', type: 'textarea' },
          { key: 'min_players', label: 'Min Players', value: base.min_players != null ? base.min_players : '', type: 'number' },
          { key: 'max_players', label: 'Max Players', value: base.max_players != null ? base.max_players : '', type: 'number' },
          { key: 'default_duration_minutes', label: 'Default Duration (minutes)', value: base.default_duration_minutes != null ? base.default_duration_minutes : '', type: 'number' },
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
          <textarea id="${inputId}" style="min-height: 90px; padding: 0.7rem; border-radius: var(--radius-sm); border: 1px solid var(--border-color); background: var(--bg-primary); color: var(--text-primary);">${this.escapeHtml(field.value || '')}</textarea>
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
          <select id="${inputId}" style="padding:0.7rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); background: var(--bg-primary); color: var(--text-primary);">
            <option value="">Select…</option>
            ${options}
          </select>
        </label>
      `;
    }
    return `
      <label style="display:grid;gap:0.25rem;font-weight:600;">
        <span>${this.escapeHtml(field.label)}</span>
        <input id="${inputId}" type="${field.type}" value="${this.escapeHtml(field.value || '')}" style="padding:0.7rem; border-radius:var(--radius-sm); border:1px solid var(--border-color); background: var(--bg-primary); color: var(--text-primary);">
      </label>
    `;
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
