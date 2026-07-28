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
    this.searchFilterId = null;
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
            <p id="practice-plan-subtitle" class="subtitle" style="margin:0;">Edit practice sessions and exercises for each day</p>
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
        this.selectDay();
      });
    });

    // Bind edit interactions
    this.element.querySelectorAll('[data-add-session]').forEach((button) => {
      button.addEventListener('click', async (e) => {
        const practiceId = parseInt(button.getAttribute('data-practice-id'));
        await this.createSession(practiceId);
      });
    });

    this.element.querySelectorAll('[data-delete-session]').forEach((button) => {
      button.addEventListener('click', async (e) => {
        const sessionId = parseInt(button.getAttribute('data-session-id'));
        await this.deleteSession(sessionId);
      });
    });

    this.element.querySelectorAll('[data-resplit-sessions]').forEach((button) => {
      button.addEventListener('click', async (e) => {
        const practiceId = parseInt(button.getAttribute('data-practice-id'));
        const startsAt = button.getAttribute('data-starts-at');
        const endsAt = button.getAttribute('data-ends-at');
        await this.resplitSessionsFromPracticeTime(practiceId, startsAt, endsAt);
      });
    });

    this.element.querySelectorAll('[data-time-input]').forEach((input) => {
      input.addEventListener('change', async (e) => {
        const sessionId = parseInt(input.getAttribute('data-session-id'));
        const field = input.getAttribute('data-time-input');
        const value = input.value;
        await this.updateSession(sessionId, { [field]: value });
      });
    });

    this.element.querySelectorAll('[data-session-title]').forEach((input) => {
      input.addEventListener('change', async (e) => {
        const sessionId = parseInt(input.getAttribute('data-session-id'));
        await this.updateSession(sessionId, { title: input.value });
      });
    });

    this.element.querySelectorAll('[data-exercise-search]').forEach((input) => {
      const sessionId = parseInt(input.getAttribute('data-session-id'));
      const dropdownId = `exercises-dropdown-${sessionId}`;
      input.addEventListener('input', (e) => {
        this.filterExercises(input.value, sessionId, dropdownId);
      });
    });

    this.element.addEventListener('click', async (e) => {
      if (e.target.closest('[data-exercise-option]')) {
        const option = e.target.closest('[data-exercise-option]');
        const sessionId = parseInt(option.getAttribute('data-session-id'));
        const exerciseId = parseInt(option.getAttribute('data-exercise-id'));
        await this.addExerciseToSession(sessionId, exerciseId);
        const search = this.element.querySelector(`[data-exercise-search][data-session-id="${sessionId}"]`);
        if (search) search.value = '';
        const dropdownId = `exercises-dropdown-${sessionId}`;
        const dropdown = this.find(`#${dropdownId}`);
        if (dropdown) dropdown.innerHTML = '';
      }
    });

    this.element.querySelectorAll('[data-delete-exercise]').forEach((button) => {
      button.addEventListener('click', async (e) => {
        const sessionExerciseId = parseInt(button.getAttribute('data-session-exercise-id'));
        await this.deleteSessionExercise(sessionExerciseId);
      });
    });
  }

  // Selecting a day with no practice yet transparently sets up a blank
  // template (3 empty sessions) instead of showing "nothing here" — Days
  // already establishes which weekdays get a plan; Practice Plans just
  // needs to be ready to fill in as soon as you land on one.
  selectDay() {
    const day = this.getSelectedDay();
    const hasPractice = day && (this.practices || []).some((practice) => practice?.day_id === day.id);
    if (day && !hasPractice) {
      this.ensureDayPlan(day);
      return;
    }
    const container = this.find('#practice-plan-content');
    if (container) {
      container.innerHTML = this.renderContent();
      this.bindInteractions();
    }
  }

  async ensureDayPlan(day) {
    const container = this.find('#practice-plan-content');
    if (container) {
      container.innerHTML = this.renderContent();
    }

    try {
      const practiceResponse = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/practices`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ day_id: day.id, notes: '' })
      });
      const practicePayload = await practiceResponse.json();
      const practiceId = practicePayload?.data?.id ?? practicePayload?.id;

      if (practiceResponse.ok && practiceId) {
        for (let i = 0; i < 3; i++) {
          await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              practice_id: practiceId,
              title: `Session ${i + 1}`,
              start_time: '00:00:00',
              end_time: '00:30:00',
              sort_order: i
            })
          });
        }
      }
    } catch (e) {
      console.error('Error setting up day plan:', e);
    }

    this.loadPlan();
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
          <p style="margin: 0; opacity: 0.8;">Setting up this day's plan…</p>
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

            const practiceTimeMarkup = this.formatTimeRange(practice.event_starts_at, practice.event_ends_at);
            // Real calendar-linked window (via fh_event_id) — only then is
            // there an actual time range to split sessions from. Blank
            // template practices (no linked gcal event) have nothing to
            // derive times from, so they don't get this button.
            const hasCalendarWindow = Boolean(practice.event_starts_at && practice.event_ends_at);

            return `
              <div style="padding: var(--space-3); border: 1px solid rgba(255,255,255,0.08); border-radius: var(--radius-sm); background: var(--bg-primary);">
                <div style="font-weight: 600;">${this.escapeHtml(practice.event_summary || 'Practice plan')}</div>
                ${practiceTimeMarkup ? `<div style="margin-top: 0.2rem; opacity: 0.75; font-size: 0.9rem;">${this.escapeHtml(practiceTimeMarkup)}</div>` : ''}
                <div style="margin-top: var(--space-3); display: grid; gap: var(--space-2);">
                  ${practiceSessions.map((session) => {
                    const sessionExercises = (sessionExercisesBySession.get(session.id) || [])
                      .slice()
                      .sort((a, b) => (a?.sequence_order || 0) - (b?.sequence_order || 0));

                    return this.renderSessionEditCard(session, sessionExercises, exerciseMap, practice);
                  }).join('')}
                  <div style="padding-top: var(--space-2); display:flex; gap: var(--space-2);">
                    <button class="btn btn-secondary" type="button" data-add-session data-practice-id="${practice.id}" style="flex:1;">+ Add Session</button>
                    ${hasCalendarWindow ? `
                      <button class="btn btn-secondary" type="button" data-resplit-sessions
                              data-practice-id="${practice.id}"
                              data-starts-at="${this.escapeHtml(practice.event_starts_at)}"
                              data-ends-at="${this.escapeHtml(practice.event_ends_at)}"
                              style="flex:1;" title="Retime this practice's sessions to 3 even blocks of its real calendar time (titles/exercises kept)">
                        ↻ Split evenly from practice time
                      </button>
                    ` : ''}
                  </div>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      </article>
    `;
  }

  renderSessionEditCard(session, sessionExercises, exerciseMap, practice) {
    const startTime = this.formatTimeValue(session.start_time);
    const endTime = this.formatTimeValue(session.end_time);

    return `
      <div style="padding: var(--space-2); border: 1px solid rgba(255,255,255,0.15); border-radius: var(--radius-sm); background: rgba(255,255,255,0.02); display: grid; gap: var(--space-2);">
        <div style="display: grid; gap: var(--space-2); grid-template-columns: 1fr auto auto auto;">
          <input type="text" class="form-input" data-session-title data-session-id="${session.id}" value="${this.escapeHtml(session.title || 'Session')}" placeholder="Session title" style="font-weight: 600;">
          <input type="time" class="form-input" data-time-input="start_time" data-session-id="${session.id}" value="${this.timeToInput(session.start_time)}" style="width: 120px;">
          <div style="align-self: center; opacity: 0.7;">–</div>
          <input type="time" class="form-input" data-time-input="end_time" data-session-id="${session.id}" value="${this.timeToInput(session.end_time)}" style="width: 120px;">
          <button class="btn btn-danger btn-sm" type="button" data-delete-session data-session-id="${session.id}" style="align-self: start;">Delete</button>
        </div>

        <div style="display: grid; gap: var(--space-1);">
          ${sessionExercises.length > 0 ? sessionExercises.map((se) => {
            const ex = exerciseMap.get(se.exercise_id);
            return `
              <div style="padding: var(--space-1); background: rgba(255,255,255,0.05); border-radius: var(--radius-sm); display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <div style="font-weight: 500;">${this.escapeHtml(ex?.title || 'Exercise')}</div>
                  <div style="opacity: 0.7; font-size: 0.85rem;">${this.escapeHtml(ex?.summary || '')}</div>
                </div>
                <button class="btn btn-danger btn-sm" type="button" data-delete-exercise data-session-exercise-id="${se.id}">Remove</button>
              </div>
            `;
          }).join('') : '<div style="opacity: 0.7; font-size: 0.9rem;">No exercises yet</div>'}
        </div>

        <div style="position: relative; display: grid; gap: var(--space-1);">
          <input type="text" class="form-input" data-exercise-search data-session-id="${session.id}" placeholder="Search and add exercises..." autocomplete="off" style="font-size: 0.9rem;">
          <div id="exercises-dropdown-${session.id}" style="position: absolute; top: 100%; left: 0; right: 0; background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-sm); max-height: 200px; overflow-y: auto; z-index: 10; display: none;">
          </div>
        </div>
      </div>
    `;
  }

  timeToInput(timeStr) {
    if (!timeStr) return '';
    const match = timeStr.match(/(\d{2}):(\d{2})/);
    return match ? `${match[1]}:${match[2]}` : '';
  }

  filterExercises(searchText, sessionId, dropdownId) {
    const dropdown = this.find(`#${dropdownId}`);
    if (!dropdown) return;

    if (!searchText.trim()) {
      dropdown.style.display = 'none';
      dropdown.innerHTML = '';
      return;
    }

    const filtered = (this.exercises || [])
      .filter((ex) => ex.title.toLowerCase().includes(searchText.toLowerCase()))
      .slice(0, 10);

    if (filtered.length === 0) {
      dropdown.innerHTML = '<div style="padding: var(--space-2); opacity: 0.7;">No exercises found</div>';
      dropdown.style.display = 'block';
      return;
    }

    dropdown.innerHTML = filtered.map((ex) => `
      <div data-exercise-option data-session-id="${sessionId}" data-exercise-id="${ex.id}" style="padding: var(--space-2); border-bottom: 1px solid rgba(255,255,255,0.1); cursor: pointer; transition: background 0.2s;">
        <div style="font-weight: 500;">${this.escapeHtml(ex.title)}</div>
        <div style="opacity: 0.7; font-size: 0.85rem;">${this.escapeHtml(ex.summary || '')}</div>
      </div>
    `).join('');

    dropdown.style.display = 'block';
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

  // "HH:MM" clock time out of a gcal-style timestamp — same extraction
  // formatTimeValue() uses for display, so the split lines up with what
  // the practice-time header already shows (no timezone conversion here;
  // this app treats these timestamps as literal wall-clock).
  extractClockTime(value) {
    if (!value) return null;
    const raw = String(value).trim();
    const match = raw.match(/(\d{4}-\d{2}-\d{2})[ T](\d{1,2}):(\d{2})(?::(\d{2}))?/);
    if (!match) return null;
    return `${match[2].padStart(2, '0')}:${match[3]}`;
  }

  minutesToClock(totalMinutes) {
    const wrapped = ((totalMinutes % 1440) + 1440) % 1440;
    const hh = String(Math.floor(wrapped / 60)).padStart(2, '0');
    const mm = String(wrapped % 60).padStart(2, '0');
    return `${hh}:${mm}:00`;
  }

  // Split a practice's real calendar window into `count` equal
  // {start_time, end_time} blocks. Returns null when there's no usable
  // window (blank template practice, or end <= start) — callers must
  // not offer this action in that case.
  splitEvenSessions(startsAt, endsAt, count) {
    const startClock = this.extractClockTime(startsAt);
    const endClock = this.extractClockTime(endsAt);
    if (!startClock || !endClock) return null;

    const toMinutes = (clock) => {
      const [h, m] = clock.split(':').map(Number);
      return h * 60 + m;
    };
    const startMin = toMinutes(startClock);
    const endMin = toMinutes(endClock);
    if (!(endMin > startMin)) return null;

    const totalMin = endMin - startMin;
    const blocks = [];
    for (let i = 0; i < count; i++) {
      const blockStartMin = startMin + Math.round((totalMin * i) / count);
      const blockEndMin = startMin + Math.round((totalMin * (i + 1)) / count);
      blocks.push({
        start_time: this.minutesToClock(blockStartMin),
        end_time: this.minutesToClock(blockEndMin),
      });
    }
    return blocks;
  }

  // Replace every session on this practice with 3 even blocks of its
  // real (calendar-linked) time — e.g. a 7:00-8:30pm practice becomes
  // 7:00-7:30, 7:30-8:00, 8:00-8:30, instead of hand-typed guesses.
  //
  // Retimes existing sessions IN PLACE (matched by sort_order) rather
  // than delete-and-recreate — session ids are what session_exercises
  // hangs off of, so an in-place update keeps a coach's exercises
  // attached instead of cascade-deleting them. Only start/end time
  // changes; title is left alone. A 3rd session is created if the
  // practice currently has fewer than 3; extras beyond 3 are untouched.
  async resplitSessionsFromPracticeTime(practiceId, startsAt, endsAt) {
    const blocks = this.splitEvenSessions(startsAt, endsAt, 3);
    if (!blocks) return;

    if (!confirm("Set this practice's sessions to 3 even blocks of its real practice time? Titles and any exercises already attached are kept — only start/end times change.")) {
      return;
    }

    try {
      const existing = (this.sessions || [])
        .filter((s) => s.practice_id === practiceId)
        .sort((a, b) => (a?.sort_order || 0) - (b?.sort_order || 0));

      for (let i = 0; i < blocks.length; i++) {
        const session = existing[i];
        if (session) {
          await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              id: session.id,
              practice_id: practiceId,
              title: session.title,
              start_time: blocks[i].start_time,
              end_time: blocks[i].end_time,
              sort_order: i,
              notes: session.notes || ''
            })
          });
        } else {
          await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              practice_id: practiceId,
              title: `Session ${i + 1}`,
              start_time: blocks[i].start_time,
              end_time: blocks[i].end_time,
              sort_order: i
            })
          });
        }
      }
    } catch (e) {
      console.error('Error re-splitting sessions:', e);
    }

    this.loadPlan();
  }

  async createSession(practiceId) {
    try {
      const nextSortOrder = Math.max(0, ...((this.sessions || [])
        .filter(s => s.practice_id === practiceId)
        .map(s => s.sort_order || 0))) + 1;

      const response = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          practice_id: practiceId,
          title: `Session ${nextSortOrder + 1}`,
          start_time: '00:00:00',
          end_time: '00:30:00',
          sort_order: nextSortOrder
        })
      });

      if (response.ok) {
        this.loadPlan();
      }
    } catch (e) {
      console.error('Error creating session:', e);
    }
  }

  async updateSession(sessionId, updates) {
    try {
      const session = this.sessions.find(s => s.id === sessionId);
      if (!session) return;

      const response = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: sessionId,
          practice_id: session.practice_id,
          ...updates,
          title: updates.title !== undefined ? updates.title : session.title,
          start_time: updates.start_time !== undefined ? updates.start_time : session.start_time,
          end_time: updates.end_time !== undefined ? updates.end_time : session.end_time,
          sort_order: session.sort_order,
          notes: session.notes || ''
        })
      });

      if (response.ok) {
        this.loadPlan();
      }
    } catch (e) {
      console.error('Error updating session:', e);
    }
  }

  async deleteSession(sessionId) {
    if (!confirm('Delete this session?')) return;

    try {
      const response = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/sessions/${sessionId}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        this.loadPlan();
      }
    } catch (e) {
      console.error('Error deleting session:', e);
    }
  }

  async addExerciseToSession(sessionId, exerciseId) {
    try {
      const sessionExercises = this.sessionExercises.filter(se => se.session_id === sessionId);
      const nextSequence = sessionExercises.length;

      const response = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/session_exercises`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          session_id: sessionId,
          exercise_id: exerciseId,
          sequence_order: nextSequence,
          player_count: null,
          notes: ''
        })
      });

      if (response.ok) {
        this.loadPlan();
      }
    } catch (e) {
      console.error('Error adding exercise:', e);
    }
  }

  async deleteSessionExercise(sessionExerciseId) {
    if (!confirm('Remove this exercise?')) return;

    try {
      const response = await this.auth.fetch(`/api/clubs/${this.clubId}/game-model/admin/session_exercises/${sessionExerciseId}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        this.loadPlan();
      }
    } catch (e) {
      console.error('Error removing exercise:', e);
    }
  }
}
