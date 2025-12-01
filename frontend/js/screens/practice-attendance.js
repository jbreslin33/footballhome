// PracticeAttendanceScreen - list practices and manage attendance
class PracticeAttendanceScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-attendance';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Practice Attendance</h1>
        <p class="subtitle">Select a practice to manage attendance</p>
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
    this.attendanceStatuses = [];
    this.loadAttendanceStatuses();
    this.loadPractices();
    
    this.element.addEventListener('click', (e) => {
      // Practice card clicked - open attendance modal
      const practiceCard = e.target.closest('[data-practice-id]');
      if (practiceCard && !e.target.closest('.attendance-btn')) {
        const practiceId = practiceCard.getAttribute('data-practice-id');
        const practiceTitle = practiceCard.getAttribute('data-practice-title');
        this.openAttendanceModal(practiceId, practiceTitle);
        return;
      }
      
      // Attendance status button clicked
      const attendanceBtn = e.target.closest('.attendance-btn');
      if (attendanceBtn) {
        const attendanceId = attendanceBtn.getAttribute('data-attendance-id');
        const statusId = attendanceBtn.getAttribute('data-status-id');
        this.updateAttendance(attendanceId, statusId, attendanceBtn);
        return;
      }
      
      // Modal close
      if (e.target.id === 'modal-close' || e.target.id === 'attendance-modal') {
        this.closeAttendanceModal();
        return;
      }
      
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });
  }
  
  loadAttendanceStatuses() {
    this.safeFetch('/api/attendance/statuses', response => {
      this.attendanceStatuses = response.data || [];
      console.log('Loaded attendance statuses:', this.attendanceStatuses);
    });
  }
  
  loadPractices() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      console.error('No team selected');
      return;
    }
    
    const listContainer = this.find('#practice-list');
    listContainer.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading practices...</p></div>';
    
    this.safeFetch(`/api/events/team/${teamId}`, response => {
      const practices = response.data || [];
      
      // Sort by date (most recent first for past, soonest first for future)
      const now = new Date();
      const sortedPractices = practices.sort((a, b) => {
        const dateA = new Date(a.event_date);
        const dateB = new Date(b.event_date);
        // Past practices: most recent first
        // Future practices: soonest first
        return dateB - dateA;
      });
      
      // Transform for display
      const transformedPractices = sortedPractices.map(p => {
        const eventDate = new Date(p.event_date);
        const isPast = eventDate < now;
        
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        
        let dateDisplay;
        if (eventDate.toDateString() === today.toDateString()) {
          dateDisplay = 'Today';
        } else if (eventDate.toDateString() === tomorrow.toDateString()) {
          dateDisplay = 'Tomorrow';
        } else if (eventDate.toDateString() === yesterday.toDateString()) {
          dateDisplay = 'Yesterday';
        } else {
          dateDisplay = eventDate.toLocaleDateString('en-US', { 
            weekday: 'short', 
            month: 'short', 
            day: 'numeric' 
          });
        }
        
        return {
          ...p,
          dateDisplay,
          time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          isPast
        };
      });
      
      this.renderList('#practice-list', transformedPractices,
        p => `
          <div class="card practice-card" data-practice-id="${p.id}" data-practice-title="${p.title}" style="cursor: pointer; ${p.isPast ? 'opacity: 0.85;' : ''}">
            <div class="practice-card-header" style="display: flex; justify-content: space-between; align-items: center;">
              <h3>${p.title}</h3>
              <span class="badge ${p.isPast ? 'badge-secondary' : 'badge-primary'}">${p.isPast ? 'Past' : 'Upcoming'}</span>
            </div>
            
            <div class="practice-card-meta">
              <div class="meta-item">
                <span class="meta-icon">📅</span>
                <span>${p.dateDisplay}</span>
              </div>
              <div class="meta-item">
                <span class="meta-icon">🕐</span>
                <span>${p.time}</span>
              </div>
              ${p.location ? `
              <div class="meta-item">
                <span class="meta-icon">📍</span>
                <span>${p.location}</span>
              </div>
              ` : ''}
            </div>
            
            <p style="margin-top: var(--space-3); color: var(--text-muted); font-size: 0.9em;">
              Tap to manage attendance →
            </p>
          </div>
        `,
        '<div class="empty-state"><p>⚽ No practices found</p><p class="text-muted">Create practices first in "Manage Practices"</p></div>'
      );
    });
  }
  
  openAttendanceModal(practiceId, practiceTitle) {
    const modal = this.find('#attendance-modal');
    const modalTitle = this.find('#modal-title');
    const attendanceList = this.find('#attendance-list');
    
    modalTitle.textContent = `${practiceTitle} - Attendance`;
    attendanceList.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Loading attendance...</p></div>';
    modal.style.display = 'flex';
    
    this.currentPracticeId = practiceId;
    this.loadAttendance(practiceId);
  }
  
  closeAttendanceModal() {
    const modal = this.find('#attendance-modal');
    modal.style.display = 'none';
  }
  
  loadAttendance(eventId) {
    const attendanceList = this.find('#attendance-list');
    
    this.safeFetch(`/api/events/${eventId}/attendance`, response => {
      const attendance = response.data || [];
      
      if (attendance.length === 0) {
        attendanceList.innerHTML = `
          <div class="empty-state">
            <p>No attendance records yet</p>
            <p class="text-muted">Attendance is auto-created from RSVPs when the practice starts</p>
          </div>
        `;
        return;
      }
      
      // Render attendance list with status buttons
      attendanceList.innerHTML = attendance.map(record => `
        <div class="attendance-row" data-attendance-id="${record.id}">
          <div class="attendance-player">
            <strong>${record.player_name || 'Unknown Player'}</strong>
          </div>
          <div class="attendance-status-buttons">
            ${this.attendanceStatuses.map(status => `
              <button 
                class="attendance-btn ${record.status_id === status.id ? 'active' : ''}" 
                data-attendance-id="${record.id}"
                data-status-id="${status.id}"
                style="background-color: ${record.status_id === status.id ? status.color : 'transparent'}; 
                       color: ${record.status_id === status.id ? 'white' : status.color};
                       border: 2px solid ${status.color};"
                title="${status.display_name}"
              >
                ${this.getStatusIcon(status.name)}
              </button>
            `).join('')}
          </div>
        </div>
      `).join('');
    });
  }
  
  getStatusIcon(statusName) {
    const icons = {
      'present': '✓',
      'absent': '✗',
      'late': '⏰',
      'excused': '📝',
      'unknown': '?'
    };
    return icons[statusName] || '?';
  }
  
  updateAttendance(attendanceId, statusId, buttonElement) {
    // Optimistic UI update
    const row = buttonElement.closest('.attendance-row');
    const allButtons = row.querySelectorAll('.attendance-btn');
    
    // Remove active from all buttons in this row
    allButtons.forEach(btn => {
      btn.classList.remove('active');
      const color = btn.style.borderColor;
      btn.style.backgroundColor = 'transparent';
      btn.style.color = color;
    });
    
    // Add active to clicked button
    buttonElement.classList.add('active');
    const status = this.attendanceStatuses.find(s => s.id === statusId);
    if (status) {
      buttonElement.style.backgroundColor = status.color;
      buttonElement.style.color = 'white';
    }
    
    // Send update to server
    this.auth.fetch(`/api/attendance/${attendanceId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status_id: statusId })
    })
    .then(r => {
      if (!r.ok) throw new Error('Update failed');
      console.log('Attendance updated');
    })
    .catch(err => {
      console.error('Failed to update attendance:', err);
      // Revert on error - reload the attendance
      this.loadAttendance(this.currentPracticeId);
    });
  }
}
