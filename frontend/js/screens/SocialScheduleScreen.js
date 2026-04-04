// SocialScheduleScreen - Configure per-team default posting schedule
// Sets days_before and post_time for each post type
class SocialScheduleScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-social-schedule';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>⏱️ Social Posting Schedule</h1>
        <p class="subtitle" id="team-name"></p>
      </div>

      <div class="schedule-container" style="padding: var(--space-4); max-width: 700px; margin: 0 auto;">
        <div class="card" style="margin-bottom: var(--space-4); padding: var(--space-4);">
          <p style="opacity: 0.7; line-height: 1.6;">
            Set a default posting schedule for <strong>all matches</strong>. When you click "Apply Schedule" on a match,
            these times will be used to auto-schedule each post type relative to match day.
          </p>
        </div>

        <div id="schedule-list">
          <div class="loading-state"><div class="spinner"></div><p>Loading schedule...</p></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.team = this.navigation.context.team;
    if (!this.team) {
      this.navigation.goBack();
      return;
    }

    this.find('#team-name').textContent = this.team.name || 'Team Schedule';
    this.loadSchedule();
    this.setupEventListeners();
  }

  setupEventListeners() {
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }

      const saveBtn = e.target.closest('[data-action="save-template"]');
      if (saveBtn) {
        const postTypeId = parseInt(saveBtn.dataset.postTypeId);
        this.saveTemplate(postTypeId);
      }
    });
  }

  loadSchedule() {
    this.safeFetch(`/api/social/schedule/team/${this.team.id}`, response => {
      this.templates = response.data || [];
      this.renderSchedule();
    });
  }

  renderSchedule() {
    const container = this.find('#schedule-list');
    container.innerHTML = '';

    const icons = {
      'pre_match_announcement': '📢',
      'game_day': '⚽',
      'lineup': '📋',
      'post_game': '🏆'
    };

    const defaults = {
      'pre_match_announcement': { days: 4, time: '10:00' },
      'game_day': { days: 0, time: '09:00' },
      'lineup': { days: 0, time: '-2' },
      'post_game': { days: 0, time: '18:00' }
    };

    this.templates.forEach(t => {
      const icon = icons[t.post_type] || '📱';
      const def = defaults[t.post_type] || { days: 0, time: '10:00' };

      const card = document.createElement('div');
      card.className = 'card';
      card.style.cssText = 'margin-bottom: var(--space-3); padding: var(--space-4);';
      card.innerHTML = `
        <div style="display: flex; align-items: center; gap: var(--space-3); margin-bottom: var(--space-3);">
          <span style="font-size: 1.5em;">${icon}</span>
          <div style="flex: 1;">
            <h3 style="margin: 0;">${t.display_name}</h3>
          </div>
          <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
            <input type="checkbox" id="enabled-${t.post_type_id}" ${t.enabled ? 'checked' : ''}>
            <span>Enabled</span>
          </label>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-3); margin-bottom: var(--space-3);">
          <div class="form-group" style="margin: 0;">
            <label class="form-label">Days Before Match</label>
            <input type="number" id="days-${t.post_type_id}" class="form-input"
              value="${t.template_id !== null ? t.days_before : def.days}" min="0" max="30">
            <small style="opacity: 0.6;">0 = match day</small>
          </div>
          <div class="form-group" style="margin: 0;">
            <label class="form-label">Time to Post</label>
            <input type="time" id="time-${t.post_type_id}" class="form-input"
              value="${t.template_id !== null ? t.post_time.substring(0, 5) : def.time}">
          </div>
        </div>

        <div style="text-align: right;">
          <button class="btn btn-primary btn-sm" data-action="save-template" data-post-type-id="${t.post_type_id}">
            💾 Save
          </button>
        </div>
      `;

      container.appendChild(card);
    });
  }

  saveTemplate(postTypeId) {
    const days = this.find(`#days-${postTypeId}`)?.value || '0';
    const time = this.find(`#time-${postTypeId}`)?.value || '10:00';
    const enabled = this.find(`#enabled-${postTypeId}`)?.checked ?? true;

    this.auth.fetch(`/api/social/schedule/team/${this.team.id}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        post_type_id: postTypeId,
        days_before: parseInt(days),
        post_time: time,
        enabled: enabled
      })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        // Brief visual feedback
        const btn = this.element.querySelector(`[data-post-type-id="${postTypeId}"]`);
        if (btn) {
          const orig = btn.innerHTML;
          btn.innerHTML = '✅ Saved!';
          setTimeout(() => { btn.innerHTML = orig; }, 1500);
        }
      } else {
        alert('Failed to save: ' + data.message);
      }
    });
  }
}
