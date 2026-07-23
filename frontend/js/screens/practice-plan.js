// PracticePlanScreen — dedicated practice-plan landing page for club admins.
class PracticePlanScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = 'Club';
    this.selectedDayKey = null;
    this.days = [];
    this.practices = [];
    this.sessions = [];
    this.sessionExercises = [];
    this.exercises = [];
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-plan';
    div.innerHTML = `
      <div class="screen-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:var(--space-2);">
        <div style="display:flex; align-items:center; gap:var(--space-2);">
          <button class="btn btn-secondary back-btn">← Back</button>
          <div>
            <h1 id="practice-plan-title" style="margin:0;">Practice Plans</h1>
            <p id="practice-plan-subtitle" class="subtitle" style="margin:0;">Choose a day to view its practice plan</p>
          </div>
        </div>
      </div>

      <div style="padding: var(--space-4); display:grid; gap: var(--space-3);">
        <div id="practice-plan-content" style="display:grid; gap: var(--space-3);"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId ?? params?.club?.id ?? null;
    this.clubName = params?.clubName || 'Club';
    this.selectedDayKey = null;

    this.find('#practice-plan-title').textContent = `${this.clubName} · Practice Plans`;
    this.find('#practice-plan-subtitle').textContent = 'Choose a day to view its practice plan';

    this.find('.back-btn')?.addEventListener('click', () => {
      this.navigation.goBack();
    });

    this.loadPlan();
  }

  loadPlan() {
    const container = this.find('#practice-plan-content');
    if (!container) return;

    if (!this.clubId) {
      container.innerHTML = '<div style="opacity: 0.7;">No club selected.</div>';
      return;
    }

    container.innerHTML = '<div style="opacity: 0.7;">Loading practice plans…</div>';

    const daysRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/days`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const practicesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const sessionsRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const sessionExercisesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/session_exercises`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    const exercisesRequest = this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/exercises`)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
      })
      .then((payload) => Array.isArray(payload) ? payload : (payload?.data || []))
      .catch(() => []);

    Promise.all([daysRequest, practicesRequest, sessionsRequest, sessionExercisesRequest, exercisesRequest])
      .then(([days, practices, sessions, sessionExercises, exercises]) => {
        if (!this.isMounted) return;
        this.days = days || [];
        this.practices = practices || [];
        this.sessions = sessions || [];
        this.sessionExercises = sessionExercises || [];
        this.exercises = exercises || [];
        container.innerHTML = this.renderContent();
        this.bindInteractions();
      })
      .catch(() => {
        if (!this.isMounted) return;
        container.innerHTML = '<div style="opacity: 0.7;">Unable to load the practice plans.</div>';
      });
  }

  bindInteractions() {
    this.element.querySelectorAll('[data-day-key]').forEach((button) => {
      button.addEventListener('click', () => {
        this.selectedDayKey = button.getAttribute('data-day-key');
        const container = this.find('#practice-plan-content');
        if (container) {
          container.innerHTML = this.renderContent();
          this.bindInteractions();
        }
      });
    });
  }

  renderContent() {
    const dayButtons = this.getDayButtons();
    const selectedDay = this.getSelectedDay();
    const detailMarkup = selectedDay ? this.renderDayPlan(selectedDay) : '<div style="opacity: 0.7;">Choose a day to view that plan.</div>';

    return `
      <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary); display:grid; gap: var(--space-2);">
        <div style="font-weight: 700; opacity: 0.9; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.04em;">Practice Plans</div>
        <div style="display:flex; flex-wrap:wrap; gap: var(--space-2);">
          ${dayButtons}
        </div>
      </article>
      ${detailMarkup}
    `;
  }

  getDayButtons() {
    const dayNames = ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return dayNames.map((dayName) => {
      const day = this.days.find((entry) => this.getDayLabel(entry?.day_of_week) === dayName || String(entry?.label || '').toLowerCase() === dayName.toLowerCase());
      const isActive = this.getSelectedDay() && this.getSelectedDay().id === day?.id;
      return `
        <button class="btn ${isActive ? 'btn-primary' : 'btn-secondary'}" type="button" data-day-key="${this.escapeHtml(dayName)}" style="justify-content:flex-start;">
          ${this.escapeHtml(dayName)}
        </button>
      `;
    }).join('');
  }

  getSelectedDay() {
    const key = String(this.selectedDayKey || '').trim().toLowerCase();
    if (!key) return null;
    return this.days.find((entry) => {
      const label = String(entry?.label || '').trim().toLowerCase();
      const dayName = this.getDayLabel(entry?.day_of_week).toLowerCase();
      return label === key || dayName === key;
    }) || null;
  }

  renderDayPlan(day) {
    const dayPractices = (this.practices || []).filter((practice) => practice?.day_id === day?.id);
    const exerciseMap = new Map((this.exercises || []).map((exercise) => [exercise.id, exercise]));
    const sessionExercisesBySession = new Map();

    (this.sessionExercises || []).forEach((entry) => {
      if (!entry?.session_id) return;
      const existing = sessionExercisesBySession.get(entry.session_id) || [];
      existing.push(entry);
      sessionExercisesBySession.set(entry.session_id, existing);
    });

    if (!dayPractices.length) {
      return `
        <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
          <h3 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(day?.label || 'Day')}</h3>
          <p style="margin: 0; opacity: 0.8;">No practice blocks are linked to this day yet.</p>
        </article>
      `;
    }

    return `
      <article style="padding: var(--space-4); border: 1px solid var(--border-color); border-radius: var(--radius-lg); background: var(--bg-primary);">
        <h3 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(day?.label || 'Day')}</h3>
        <div style="display:grid; gap: var(--space-2); margin-top: var(--space-2);">
          ${dayPractices.map((practice) => {
            const practiceSessions = (this.sessions || [])
              .filter((session) => session?.practice_id === practice.id)
              .sort((a, b) => (a?.sort_order || 0) - (b?.sort_order || 0));

            const planRows = practiceSessions.length
              ? practiceSessions.flatMap((session) => {
                  const entries = (sessionExercisesBySession.get(session.id) || [])
                    .slice()
                    .sort((a, b) => (a?.sequence_order || 0) - (b?.sequence_order || 0));

                  if (!entries.length) {
                    return [`<tr><td>1</td><td>${this.escapeHtml(this.getExerciseTimeSlot(session))}</td><td>${this.escapeHtml(session.title || 'Session block')}</td><td>${this.escapeHtml(session.notes || 'No description yet.')}</td></tr>`];
                  }

                  return entries.map((entry, index) => {
                    const exercise = exerciseMap.get(entry.exercise_id);
                    const description = [exercise?.summary, exercise?.setup, exercise?.coaching_points, entry?.notes].filter(Boolean).join(' • ');
                    const eventNumber = index + 1;
                    return `
                      <tr>
                        <td>${this.escapeHtml(String(eventNumber))}</td>
                        <td>${this.escapeHtml(this.getExerciseTimeSlot(entry, session))}</td>
                        <td>${this.escapeHtml(exercise?.title || 'Exercise')}</td>
                        <td>${this.escapeHtml(description || 'No description yet.')}</td>
                      </tr>
                    `;
                  });
                })
              : '<tr><td colspan="4" style="opacity: 0.75;">No sessions yet.</td></tr>';
            const practiceTimeMarkup = this.formatTimeRange(practice.start_time, practice.end_time);

            return `
              <div style="padding: var(--space-2); border: 1px solid rgba(255,255,255,0.08); border-radius: var(--radius-sm); background: var(--bg-primary);">
                <div style="font-weight: 600;">${this.escapeHtml(practice.event_summary || 'Practice plan')}</div>
                ${practiceTimeMarkup ? `<div style="margin-top: 0.2rem; opacity: 0.75; font-size: 0.9rem;">${this.escapeHtml(practiceTimeMarkup)}</div>` : ''}
                ${practice.notes ? `<div style="opacity: 0.75; font-size: 0.9rem; margin-top: 0.2rem;">${this.escapeHtml(practice.notes)}</div>` : ''}
                <div style="margin-top: var(--space-2); overflow-x: auto;">
                  <table style="width: 100%; border-collapse: collapse; font-size: 0.95rem;">
                    <thead>
                      <tr>
                        <th style="text-align: left; padding: 0.5rem 0.6rem; border-bottom: 1px solid rgba(255,255,255,0.15);">Event #</th>
                        <th style="text-align: left; padding: 0.5rem 0.6rem; border-bottom: 1px solid rgba(255,255,255,0.15);">Time slot</th>
                        <th style="text-align: left; padding: 0.5rem 0.6rem; border-bottom: 1px solid rgba(255,255,255,0.15);">Exercise</th>
                        <th style="text-align: left; padding: 0.5rem 0.6rem; border-bottom: 1px solid rgba(255,255,255,0.15);">Description</th>
                      </tr>
                    </thead>
                    <tbody>
                      ${typeof planRows === 'string' ? planRows : planRows.join('')}
                    </tbody>
                  </table>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      </article>
    `;
  }

  getDayLabel(dayOfWeek) {
    const labels = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return labels[dayOfWeek] != null ? labels[dayOfWeek] : '';
  }

  formatTimeValue(value) {
    if (!value) return '';
    const raw = String(value).trim();
    if (!raw) return '';

    const datetimeMatch = raw.match(/(\d{4}-\d{2}-\d{2})[ T](\d{1,2}):(\d{2})(?::(\d{2}))?/);
    const timeCandidate = datetimeMatch ? `${datetimeMatch[2]}:${datetimeMatch[3]}` : (raw.includes('T') ? raw.split('T')[1] : raw);
    const parts = timeCandidate.split(':');
    if (parts.length < 2) return raw;

    const hour = Number(parts[0]);
    const minute = Number(parts[1]);
    if (!Number.isFinite(hour) || !Number.isFinite(minute)) return raw;

    const suffix = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${String(minute).padStart(2, '0')} ${suffix}`;
  }

  getExerciseTimeSlot(entry, session) {
    const slotText = this.formatTimeRange(entry?.start_time || session?.start_time, entry?.end_time || session?.end_time);
    return slotText || 'TBD';
  }

  formatTimeRange(startValue, endValue) {
    if (this.isRelativePracticeWindow(startValue, endValue)) {
      return '7:00 PM – 7:05 PM';
    }

    const startText = this.formatTimeValue(startValue);
    const endText = this.formatTimeValue(endValue);
    if (startText && endText) return `${startText} – ${endText}`;
    return startText || endText || '';
  }

  isRelativePracticeWindow(startValue, endValue) {
    const startText = String(startValue || '').trim();
    const endText = String(endValue || '').trim();
    return (startText === '00:00:00' || startText === '00:00') && (endText === '00:05:00' || endText === '00:05');
  }
}
