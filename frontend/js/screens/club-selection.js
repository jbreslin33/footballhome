// ClubSelectionScreen — generic "pick which club" step, shown only when a
// role resolves to more than one club (e.g. a coach with teams at two
// different clubs). Callers pass the already-resolved club list plus the
// screen/params to land on once a club is chosen, so this screen does no
// fetching of its own.
class ClubSelectionScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-club-selection';

    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Select Club</h1>
        <p class="subtitle">Choose which club to manage</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="club-selection-list"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubs = Array.isArray(params?.clubs) ? params.clubs : [];
    this.target = params?.target || null;
    this.targetParams = params?.targetParams || {};

    const listContainer = this.find('#club-selection-list');
    if (this.clubs.length === 0) {
      listContainer.innerHTML = '<div class="empty-state"><p>No clubs available</p></div>';
    } else {
      listContainer.innerHTML = this.clubs.map(club => `
        <button class="btn btn-lg btn-primary club-option"
                data-club-id="${club.id}"
                data-club-name="${club.name}"
                style="width: 100%; text-align: left; margin-bottom: var(--space-2); padding: var(--space-3);">
          <h3 style="margin: 0; font-size: 1.2rem;">🏟️ ${club.name}</h3>
        </button>
      `).join('');
    }

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const clubBtn = e.target.closest('.club-option');
      if (clubBtn && this.target) {
        this.navigation.goTo(this.target, {
          ...this.targetParams,
          clubId: clubBtn.getAttribute('data-club-id'),
          clubName: clubBtn.getAttribute('data-club-name'),
        });
      }
    });
  }
}
