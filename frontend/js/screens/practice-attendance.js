// PracticeAttendanceScreen - coach/admin check-in for practices and
// matches. Route slug stays 'practice-attendance' (existing entry
// point from practice-options.js) but the screen now covers both
// event kinds — match-options.js links here too.
//
// Data:
//   GET /api/calendar/upcoming?start=<iso>&days=<n>
//     → shared with calendar.js; filtered client-side to this team's
//       practice/match events (see docs/calendar-design.md §10.1).
//   GET  /api/calendar/events/:fhEventId/attendance
//     → { fh_event_id, can_mark, roster: [{ person_id, first_name,
//         last_name, status, marked_at }, ...] }
//   POST /api/calendar/events/:fhEventId/attendance
//     Body: { person_id, status: 'present'|'absent'|'late'|'excused' }
class PracticeAttendanceScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-attendance';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Attendance</h1>
        <p class="subtitle">Select a practice or match to check in players</p>
      </div>

      <div style="padding: var(--space-4);">
        <div id="practice-list" class="practice-cards"></div>
      </div>

      <!-- Attendance Modal -->
      <div id="attendance-modal" class="modal" style="display: none;">
        <div class="modal-content">
          <div class="modal-header">
            <h2 id="modal-title">Attendance</h2>
            <button id="modal-close" class="btn btn-secondary">✕</button>
          </div>
          <div id="attendance-list" class="attendance-list"></div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.statuses = [
      { id: 'present', label: 'Present', icon: '✓', color: '#22c55e' },
      { id: 'late',    label: 'Late',    icon: '⏰', color: '#f59e0b' },
      { id: 'excused', label: 'Excused', icon: '📝', color: '#64748b' },
      { id: 'absent',  label: 'Absent',  icon: '✗', color: '#ef4444' },
    ];
    this.currentFhEventId = null;
    this.canMark = false;
    this.loadEvents();

    this.element.addEventListener('click', (e) => {
      const eventCard = e.target.closest('[data-fh-event-id]');
      if (eventCard) {
        this.openAttendanceModal(eventCard.getAttribute('data-fh-event-id'),
                                  eventCard.getAttribute('data-event-title'));
        return;
      }

      const attendanceBtn = e.target.closest('.attendance-btn');
      if (attendanceBtn) {
        const personId = attendanceBtn.getAttribute('data-person-id');
        const status = attendanceBtn.getAttribute('data-status');
        this.updateAttendance(personId, status, attendanceBtn);
        return;
      }

      if (e.target.id === 'modal-close' || e.target.id === 'attendance-modal') {
        this.closeAttendanceModal();
        return;
      }

      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }

  loadEvents() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      console.error('No team selected');
      return;
    }

    const listContainer = this.find('#practice-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading events...</p></div>';

    // 14 days back (covers "mark attendance for last week's practice
    // I forgot to check in") through 14 days forward.
    const start = new Date();
    start.setDate(start.getDate() - 14);

    this.safeFetch(
      `/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=28`,
      response => {
        const events = (response.events || [])
          .filter(ev => (ev.kind === 'practice' || ev.kind === 'match') &&
                        (ev.teams || []).some(t => t.id === teamId));

        const now = new Date();
        const today = new Date(); today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
        const yesterday = new Date(today); yesterday.setDate(yesterday.getDate() - 1);

        const items = events.map(ev => {
          const startsAt = new Date(ev.starts_at);
          let dateDisplay;
          if (startsAt.toDateString() === today.toDateString()) dateDisplay = 'Today';
          else if (startsAt.toDateString() === tomorrow.toDateString()) dateDisplay = 'Tomorrow';
          else if (startsAt.toDateString() === yesterday.toDateString()) dateDisplay = 'Yesterday';
          else dateDisplay = startsAt.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });

          const title = ev.kind === 'match'
            ? `${ev.is_home === false ? '@ ' : 'vs '}${ev.opponent || 'Match'}`
            : (ev.summary || 'Practice');

          return {
            fhEventId: ev.fh_event_id,
            title,
            kind: ev.kind,
            dateDisplay,
            time: startsAt.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            location: ev.location,
            isPast: startsAt < now,
          };
        }); // already ascending by starts_at — that's the API's own ORDER BY

        this.renderList('#practice-list', items,
          ev => `
            <div class="card practice-card" data-fh-event-id="${ev.fhEventId}" data-event-title="${ev.title}"
                 style="cursor: pointer; ${ev.isPast ? 'opacity: 0.85;' : ''}">
              <div class="practice-card-header" style="display: flex; justify-content: space-between; align-items: center;">
                <h3>${ev.kind === 'match' ? '⚽' : '🏃'} ${ev.title}</h3>
                <span class="badge ${ev.isPast ? 'badge-secondary' : 'badge-primary'}">${ev.isPast ? 'Past' : 'Upcoming'}</span>
              </div>
              <div class="practice-card-meta">
                <div class="meta-item"><span class="meta-icon">📅</span><span>${ev.dateDisplay}</span></div>
                <div class="meta-item"><span class="meta-icon">🕐</span><span>${ev.time}</span></div>
                ${ev.location ? `<div class="meta-item"><span class="meta-icon">📍</span><span>${ev.location}</span></div>` : ''}
              </div>
              <p style="margin-top: var(--space-3); color: var(--text-muted); font-size: 0.9em;">
                Tap to check in players →
              </p>
            </div>
          `,
          '<div class="empty-state"><p>⚽ No practices or matches found</p></div>'
        );
      }
    );
  }

  openAttendanceModal(fhEventId, title) {
    const modal = this.find('#attendance-modal');
    const modalTitle = this.find('#modal-title');
    const attendanceList = this.find('#attendance-list');

    modalTitle.textContent = `${title} - Attendance`;
    attendanceList.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading roster...</p></div>';
    modal.style.display = 'flex';

    this.currentFhEventId = fhEventId;
    this.loadAttendance(fhEventId);
  }

  closeAttendanceModal() {
    this.find('#attendance-modal').style.display = 'none';
  }

  loadAttendance(fhEventId) {
    const attendanceList = this.find('#attendance-list');

    this.safeFetch(`/api/calendar/events/${fhEventId}/attendance`, response => {
      this.canMark = !!response.can_mark;
      const roster = response.roster || [];

      if (roster.length === 0) {
        attendanceList.innerHTML = '<div class="empty-state"><p>No roster found for this event</p></div>';
        return;
      }

      attendanceList.innerHTML = roster.map(player => `
        <div class="attendance-row" data-person-id="${player.person_id}">
          <div class="attendance-player">
            <strong>${player.first_name || ''} ${player.last_name || ''}</strong>
          </div>
          <div class="attendance-status-buttons">
            ${this.statuses.map(status => `
              <button
                class="attendance-btn ${player.status === status.id ? 'active' : ''}"
                data-person-id="${player.person_id}"
                data-status="${status.id}"
                ${this.canMark ? '' : 'disabled'}
                style="background-color: ${player.status === status.id ? status.color : 'transparent'};
                       color: ${player.status === status.id ? 'white' : status.color};
                       border: 2px solid ${status.color};"
                title="${status.label}"
              >${status.icon}</button>
            `).join('')}
          </div>
        </div>
      `).join('') + (this.canMark ? '' : `
        <p style="text-align:center; color: var(--text-muted); margin-top: var(--space-3);">
          Only this team's coaches or a club admin can mark attendance.
        </p>
      `);
    });
  }

  updateAttendance(personId, status, buttonElement) {
    const row = buttonElement.closest('.attendance-row');
    const allButtons = row.querySelectorAll('.attendance-btn');

    allButtons.forEach(btn => {
      btn.classList.remove('active');
      const color = btn.style.borderColor;
      btn.style.backgroundColor = 'transparent';
      btn.style.color = color;
    });

    buttonElement.classList.add('active');
    const statusDef = this.statuses.find(s => s.id === status);
    if (statusDef) {
      buttonElement.style.backgroundColor = statusDef.color;
      buttonElement.style.color = 'white';
    }

    this.auth.fetch(`/api/calendar/events/${this.currentFhEventId}/attendance`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ person_id: Number(personId), status }),
    })
      .then(r => {
        if (!r.ok) throw new Error('Update failed');
      })
      .catch(err => {
        console.error('Failed to update attendance:', err);
        this.loadAttendance(this.currentFhEventId);
      });
  }
}
