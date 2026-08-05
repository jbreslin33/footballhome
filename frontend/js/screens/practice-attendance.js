// PracticeAttendanceScreen - the coach's weekly attendance board.
// Route slug stays 'practice-attendance' (existing entry points from
// coach-home.js, practice-options.js, match-options.js) but the screen
// is no longer team-scoped — it's the coach's version of #my: every
// practice/match across every team for the week, gcal-based, with a
// category chip row (All / Mens / Womens / Boys / Girls) instead of a
// per-team drill-down. Any coach can mark attendance on any event —
// see CalendarController::isEventCoachOrAdmin (2026-08-04 — dropped
// the "must coach one of this event's teams" restriction).
//
// Data:
//   GET /api/calendar/upcoming?start=<iso>&days=<n>
//     → shared with calendar.js / #my; filtered client-side to
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
        <p class="subtitle">This week's practices &amp; matches — set your own availability, or tap a card to check in players</p>
      </div>

      <div style="padding: 0 var(--space-4);">
        <div id="pa-chips" style="display:flex; flex-wrap:wrap; gap:6px; margin-bottom: var(--space-3);"></div>
      </div>

      <div style="padding: 0 var(--space-4) var(--space-4);">
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
    this.allEvents = [];
    this.category = 'all';

    this.renderChips();
    this.loadEvents();

    this.element.addEventListener('click', (e) => {
      const chipBtn = e.target.closest('[data-category]');
      if (chipBtn) {
        this.category = chipBtn.getAttribute('data-category');
        this.renderChips();
        this.renderEventList();
        return;
      }

      const rsvpBtn = e.target.closest('.my-rsvp-btn');
      if (rsvpBtn) {
        e.stopPropagation();
        const fhEventId = rsvpBtn.getAttribute('data-fh-event-id');
        const response = rsvpBtn.getAttribute('data-response');
        this.sendMyRsvp(fhEventId, response);
        return;
      }

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

  renderChips() {
    const host = this.find('#pa-chips');
    if (!host) return;
    const chips = [
      { id: 'all',    label: '🗂️ All'    },
      { id: 'mens',   label: '👨 Mens'   },
      { id: 'womens', label: '👩 Womens' },
      { id: 'boys',   label: '👦 Boys'   },
      { id: 'girls',  label: '👧 Girls'  },
    ];
    host.innerHTML = chips.map(c => `
      <button type="button" data-category="${c.id}" class="btn btn-sm ${this.category === c.id ? 'btn-primary' : 'btn-secondary'}">
        ${c.label}
      </button>
    `).join('');
  }

  loadEvents() {
    const listContainer = this.find('#practice-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading events...</p></div>';

    // 14 days back (covers "mark attendance for last week's practice
    // I forgot to check in") through 14 days forward.
    const start = new Date();
    start.setDate(start.getDate() - 14);

    this.safeFetch(
      `/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=28`,
      response => {
        this.allEvents = (response.events || [])
          .filter(ev => ev.kind === 'practice' || ev.kind === 'match');
        this.renderEventList();
      }
    );
  }

  renderEventList() {
    const events = this.category === 'all'
      ? this.allEvents
      : this.allEvents.filter(ev => (ev.teams || []).some(t => t.gender_category === this.category));

    const now = new Date();
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
    const yesterday = new Date(today); yesterday.setDate(yesterday.getDate() - 1);

    const categoryLabels = { mens: '👨 Mens', womens: '👩 Womens', boys: '👦 Boys', girls: '👧 Girls' };

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

      const teamBadges = (ev.teams || [])
        .map(t => categoryLabels[t.gender_category] || t.name)
        .filter((v, i, arr) => arr.indexOf(v) === i); // de-dupe

      return {
        fhEventId: ev.fh_event_id,
        title,
        kind: ev.kind,
        dateDisplay,
        time: startsAt.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        location: ev.location,
        teamBadges,
        isPast: startsAt < now,
        myRsvp: ev.my_rsvp,
        myRsvpEligible: ev.my_rsvp_eligible !== false,
        rsvpsOpenNow: ev.rsvps_open_now !== false,
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
            ${ev.teamBadges.length ? `<div class="meta-item"><span class="meta-icon">👥</span><span>${ev.teamBadges.join(', ')}</span></div>` : ''}
          </div>
          ${!ev.isPast && ev.myRsvpEligible && ev.rsvpsOpenNow ? `
            <div style="margin-top: var(--space-2); display:flex; align-items:center; gap:8px;">
              <span style="font-size:0.82rem; color: var(--text-muted);">Your availability:</span>
              <button type="button" class="my-rsvp-btn btn btn-sm ${ev.myRsvp === 'yes' ? 'btn-primary' : 'btn-secondary'}"
                      data-fh-event-id="${ev.fhEventId}" data-response="yes">✅ Going</button>
              <button type="button" class="my-rsvp-btn btn btn-sm ${ev.myRsvp === 'no' ? 'btn-primary' : 'btn-secondary'}"
                      data-fh-event-id="${ev.fhEventId}" data-response="no">❌ Can't go</button>
            </div>
          ` : ''}
          <p style="margin-top: var(--space-3); color: var(--text-muted); font-size: 0.9em;">
            Tap the card to check in players →
          </p>
        </div>
      `,
      '<div class="empty-state"><p>⚽ No practices or matches found</p></div>'
    );
  }

  sendMyRsvp(fhEventId, response) {
    const numericId = Number(fhEventId);
    this.auth.fetch('/api/calendar/rsvp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ fh_event_id: numericId, response }),
    })
      .then(r => {
        if (!r.ok) throw new Error('RSVP failed');
        return r.json();
      })
      .then(body => {
        const ev = this.allEvents.find(e => e.fh_event_id === numericId);
        if (ev) {
          ev.my_rsvp = (body && body.rsvp && body.rsvp.response) || response;
        }
        this.renderEventList();
      })
      .catch(err => {
        console.error('Failed to save RSVP:', err);
      });
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
          Only coaches or a club admin can mark attendance.
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
