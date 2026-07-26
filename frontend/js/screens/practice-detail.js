// PracticeDetailScreen - view the flow of a single practice
class PracticeDetailScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.practice = null;
    this.practiceId = null;
    this.clubId = null;
    this.coverageStructure = null;
    this.coverageSelection = new Set();
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-detail';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <div>
          <h1>⚽ Practice Flow</h1>
          <p class="subtitle">A simple 3-part structure for the session</p>
        </div>
      </div>

      <div id="practice-detail-content" style="padding: var(--space-4);"></div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.practice = params?.practice || null;
    this.practiceId = params?.practiceId || this.practice?.id || null;

    const team = this.navigation.context?.team;
    const rawClubId = params?.clubId ?? this.practice?.club_id ?? team?.clubId ?? team?.club_id ?? team?.club?.id ?? null;
    this.clubId = Number.isFinite(Number(rawClubId)) ? Number(rawClubId) : null;
    this.coverageSelection = new Set();

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const toggle = e.target.closest('[data-action="coverage-toggle"]');
      if (toggle) {
        e.preventDefault();
        const id = toggle.getAttribute('data-id');
        if (!id) return;
        if (this.coverageSelection.has(id)) {
          this.coverageSelection.delete(id);
        } else {
          this.coverageSelection.add(id);
        }
        this.renderPractice(this.practice);
      }
    });

    this.loadPractice();
  }

  loadPractice() {
    const container = this.find('#practice-detail-content');
    if (!container) return;

    if (this.practice) {
      this.renderPractice(this.practice);
      this.loadGameModelStructure();
      return;
    }

    if (!this.practiceId) {
      container.innerHTML = '<div class="empty-state"><p>No practice selected.</p></div>';
      return;
    }

    container.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading practice flow...</p></div>';

    this.auth.fetch(`/api/events/${this.practiceId}`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        const practice = payload?.data || payload;
        this.practice = practice;
        this.renderPractice(practice);
        this.loadGameModelStructure();
      })
      .catch((error) => {
        container.innerHTML = `<div class="empty-state"><p>Unable to load this practice.</p><p class="text-muted">${this.escapeHtml(error.message || 'Unknown error')}</p></div>`;
      });
  }

  loadGameModelStructure() {
    if (!this.clubId) {
      this.coverageStructure = null;
      this.renderPractice(this.practice);
      return;
    }

    this.auth.fetch(`/api/clubs/${this.clubId}/game-model/structure`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        const data = payload?.data || payload;
        this.coverageStructure = data && typeof data === 'object' && !Array.isArray(data) ? data : null;
        this.renderPractice(this.practice);
      })
      .catch(() => {
        this.coverageStructure = null;
        this.renderPractice(this.practice);
      });
  }

  renderPractice(practice) {
    const container = this.find('#practice-detail-content');
    if (!container) return;

    const title = practice?.title || 'Practice';
    const notes = practice?.notes || '';
    const eventDate = practice?.event_date || practice?.date || practice?.starts_at || null;
    const dateText = this.formatDate(eventDate);
    const timeText = this.formatTime(eventDate);
    const flow = this.getFlowBlocks(notes);

    container.innerHTML = `
      <div style="display:grid; gap: var(--space-4); max-width: 760px; margin: 0 auto;">
        <section class="card" style="padding: var(--space-4); display:grid; gap: var(--space-2);">
          <div style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.08em; opacity: 0.7;">Practice overview</div>
          <h2 style="margin: 0;">${this.escapeHtml(title)}</h2>
          <div style="display:flex; flex-wrap:wrap; gap: var(--space-3); opacity: 0.9;">
            ${dateText ? `<div>📅 ${this.escapeHtml(dateText)}</div>` : ''}
            ${timeText ? `<div>🕐 ${this.escapeHtml(timeText)}</div>` : ''}
          </div>
          ${notes ? `<div style="margin-top: var(--space-2); padding: var(--space-3); border-left: 3px solid var(--accent); background: rgba(255,255,255,0.04); border-radius: var(--radius-sm); white-space: pre-line;">${this.escapeHtml(notes)}</div>` : ''}
        </section>

        <section style="display:grid; gap: var(--space-3);">
          <div style="font-size: 0.95rem; font-weight: 700; opacity: 0.9;">Recommended flow</div>
          ${flow.map((block) => `
            <article class="card" style="padding: var(--space-4); display:grid; gap: var(--space-2);">
              <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--accent);">${this.escapeHtml(block.title)}</div>
              <div style="font-size: 1.05rem; font-weight: 700;">${this.escapeHtml(block.heading)}</div>
              <div style="line-height: 1.6; opacity: 0.9;">${this.escapeHtml(block.detail)}</div>
              ${block.objectives ? `
                <div style="margin-top: 0.25rem; padding: var(--space-3); border-left: 3px solid #60a5fa; background: rgba(96,165,250,0.08); border-radius: var(--radius-sm); display:grid; gap: 0.4rem;">
                  <div style="font-weight: 700;">Objectives</div>
                  <div>${this.escapeHtml(block.objectives.shortTerm)}</div>
                  <div style="opacity: 0.8;">${this.escapeHtml(block.objectives.longTerm)}</div>
                </div>
              ` : ''}
            </article>
          `).join('')}
        </section>

        ${this.buildCoverageSectionMarkup()}

        <section class="card" style="padding: var(--space-4); display:grid; gap: var(--space-2);">
          <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--accent);">Weekly coverage goal</div>
          <div style="font-size: 1.05rem; font-weight: 700;">Expose the main principles, sub-principles, and player actions across the week</div>
          <div style="line-height: 1.6; opacity: 0.9;">Even a small amount of time in each session can help cover the main, sub, and player actions over the week. The game is especially useful for this because it naturally creates repeated moments for the same ideas.</div>
        </section>
      </div>
    `;
  }

  buildCoverageSectionMarkup() {
    if (!this.coverageStructure) {
      return `
        <section class="card" style="padding: var(--space-4); display:grid; gap: var(--space-2);">
          <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--accent);">Coverage anchors</div>
          <div style="font-size: 1.05rem; font-weight: 700;">Connect the session to the club's game model</div>
          <div style="line-height: 1.6; opacity: 0.9;">${this.clubId ? 'Loading the game-model structure…' : 'Select a team with a club attached to see the coverage anchors.'}</div>
        </section>
      `;
    }

    const phases = Array.isArray(this.coverageStructure?.phases) ? this.coverageStructure.phases : [];
    const selectedCount = this.coverageSelection.size;
    const selectedSummary = Array.from(this.coverageSelection).slice(0, 3).join(', ');

    return `
      <section class="card" style="padding: var(--space-4); display:grid; gap: var(--space-3);">
        <div style="display:grid; gap: 0.35rem;">
          <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: var(--accent);">Coverage anchors</div>
          <div style="font-size: 1.05rem; font-weight: 700;">Check off the main principles you want this practice to reinforce</div>
          <div style="line-height: 1.6; opacity: 0.9;">The list below is pulled from the club's game-model structure so the practice can stay tied to the week's broader coaching themes.</div>
        </div>
        <div style="padding: var(--space-3); border-radius: var(--radius-sm); background: rgba(96, 165, 250, 0.08); border: 1px solid rgba(96, 165, 250, 0.2); display:grid; gap: 0.25rem;">
          <div style="font-weight: 700;">${selectedCount ? `Selected focus (${selectedCount})` : 'No anchors selected yet'}</div>
          <div style="opacity: 0.85;">${selectedCount ? this.escapeHtml(selectedSummary) : 'Tap a principle to mark it as the focus for this session.'}</div>
        </div>
        <div style="display:grid; gap: var(--space-3);">
          ${phases.map((phase) => this.renderPhaseCoverageCard(phase)).join('')}
        </div>
      </section>
    `;
  }

  renderPhaseCoverageCard(phase) {
    const principles = Array.isArray(phase?.principles) ? phase.principles : [];
    return `
      <div style="padding: var(--space-3); border: 1px solid var(--border-color); border-radius: var(--radius-md); display:grid; gap: var(--space-2);">
        <div style="font-weight: 700;">${this.escapeHtml(phase?.label || phase?.slug || 'Phase')}</div>
        <div style="display:grid; gap: 0.6rem;">
          ${principles.map((principle) => this.renderPrincipleCoverageOption(phase, principle)).join('')}
        </div>
      </div>
    `;
  }

  renderPrincipleCoverageOption(phase, principle) {
    const principleId = `principle:${principle?.id ?? ''}`;
    const selected = this.coverageSelection.has(principleId);
    const subPrinciples = Array.isArray(principle?.sub_principles) ? principle.sub_principles : [];
    const actionHints = this.getActionHints(phase?.action_catalogs || []);

    return `
      <div style="padding: var(--space-2) var(--space-3); border-left: 3px solid ${selected ? '#60a5fa' : 'rgba(255,255,255,0.16)'}; background: ${selected ? 'rgba(96, 165, 250, 0.1)' : 'rgba(255,255,255,0.03)'}; border-radius: var(--radius-sm); display:grid; gap: 0.45rem;">
        <button data-action="coverage-toggle" data-id="${this.escapeHtml(principleId)}" class="btn btn-secondary" style="justify-content:flex-start; width:100%; text-align:left;">
          <span style="margin-right:0.45rem;">${selected ? '✓' : '○'}</span>
          <span>${this.escapeHtml(principle?.title || principle?.slug || 'Principle')}</span>
        </button>
        ${subPrinciples.length ? `<div style="display:flex; flex-wrap:wrap; gap: 0.35rem;">${subPrinciples.slice(0, 2).map((sub) => `<span style="padding: 0.2rem 0.45rem; border-radius: 999px; background: rgba(255,255,255,0.06); font-size: 0.8rem;">${this.escapeHtml(sub?.title || sub?.slug || 'Sub principle')}</span>`).join('')}</div>` : ''}
        ${actionHints.length ? `<div style="display:flex; flex-wrap:wrap; gap: 0.35rem; opacity: 0.85;">${actionHints.slice(0, 2).map((hint) => `<span style="padding: 0.2rem 0.45rem; border-radius: 999px; background: rgba(255,255,255,0.05); font-size: 0.75rem;">${this.escapeHtml(hint)}</span>`).join('')}</div>` : ''}
      </div>
    `;
  }

  getActionHints(actionCatalogs) {
    const hints = [];
    const catalogs = Array.isArray(actionCatalogs) ? actionCatalogs : [];
    catalogs.forEach((catalog) => {
      const categories = Array.isArray(catalog?.categories) ? catalog.categories : [];
      categories.forEach((category) => {
        const items = Array.isArray(category?.items) ? category.items : [];
        items.forEach((item) => {
          if (item?.description) hints.push(item.description);
        });
      });
    });
    return hints.slice(0, 4);
  }

  getFlowBlocks(notes) {
    const normalizedNotes = (notes || '').trim();
    const hasCustomPlan = normalizedNotes.length > 0;

    return [
      {
        title: '1. Possession',
        heading: 'Start here',
        detail: hasCustomPlan
          ? normalizedNotes
          : 'Open with possession-based rondos, positional play, or low-structure rondo play. This is the most flexible block when numbers are uneven or players arrive late.',
        objectives: {
          shortTerm: 'Short-term: create clean repetitions of the first passing pattern and the first defensive action.',
          longTerm: 'Long-term: build comfort with the main and sub-principles that will be repeated in later sessions.'
        }
      },
      {
        title: '2. Middle block',
        heading: 'Adjust to the day',
        detail: hasCustomPlan
          ? 'Use the middle block to layer in the theme of the day: pattern play, finishing, transition, or conditioning.'
          : 'Choose a middle block that fits the group and the objective: pattern play, finishing, transition, or conditioning.',
        objectives: {
          shortTerm: 'Short-term: introduce one clear tactical problem for the group to solve.',
          longTerm: 'Long-term: keep the week moving toward a wider set of main principles and player actions without overloading the session.'
        }
      },
      {
        title: '3. Game',
        heading: 'Finish with match-play',
        detail: hasCustomPlan
          ? 'Finish with a small-sided game that reinforces the same ideas from the first two blocks.'
          : 'End with a small-sided game or match-play so the session closes in a realistic environment.',
        objectives: {
          shortTerm: 'Short-term: make the game reveal whether the players can apply the idea under pressure.',
          longTerm: 'Long-term: use the game to touch on main principles, sub-principles, and player actions across the week even if only briefly.'
        }
      }
    ];
  }

  formatDate(value) {
    if (!value) return '';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '';
    return date.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  }

  formatTime(value) {
    if (!value) return '';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '';
    return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  }

  escapeHtml(value) {
    const text = value == null ? '' : String(value);
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}
