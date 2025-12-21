// PracticeListScreen - view practices and RSVP
class PracticeListScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-list';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">
          ← Back
        </button>
        <h1>⚽ Practice Schedule</h1>
        <p class="subtitle">Tap a button to RSVP</p>
      </div>
      
      <div id="practice-list" class="practice-cards"></div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadPractices();
    
    this.element.addEventListener('click', (e) => {
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
        return;
      }
      
      // Tactics button
      const tacticsBtn = e.target.closest('[data-action="tactics"]');
      if (tacticsBtn) {
        const practiceId = tacticsBtn.getAttribute('data-id');
        const practiceTitle = tacticsBtn.getAttribute('data-title');
        const team = this.navigation.context.team;
        
        this.navigation.goTo('tactical-board', { 
          practiceId: practiceId,
          practiceTitle: practiceTitle,
          team: team
        });
        return;
      }
      
      // RSVP buttons
      const rsvpBtn = e.target.closest('[data-action="rsvp"]');
      if (rsvpBtn) {
        const practiceId = rsvpBtn.getAttribute('data-id');
        const status = rsvpBtn.getAttribute('data-status');
        this.handleRSVP(practiceId, status);
      }
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
      // Extract practices from standardized response format
      const practices = response.data || [];
      
      // Load RSVP status for each practice
      this.loadPracticesWithRSVP(practices);
    });
  }
  
  async loadPracticesWithRSVP(practices) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role; // 'coach', 'player', or 'parent'
    
    console.log('Loading practices with RSVP for:', { userId, roleType });
    
    if (!userId || !roleType) {
      console.error('Missing user ID or role type');
      this.renderPractices(practices);
      return;
    }
    
    // Fetch RSVP status for each practice
    const practicesWithRSVP = await Promise.all(
      practices.map(async (practice) => {
        try {
          const response = await this.auth.fetch(`/api/events/${practice.id}/rsvps?role_type=${roleType}`);
          const data = await response.json();
          
          console.log(`RSVPs for practice ${practice.id}:`, data);
          
          if (data.success && data.data) {
            // Find current user's RSVP
            const userRsvp = data.data.find(rsvp => rsvp.user_id === userId);
            practice.userRsvpStatus = userRsvp ? userRsvp.status : null;
            practice.rsvpCount = data.data.length;
            
            console.log(`Practice ${practice.id} - User RSVP status:`, practice.userRsvpStatus);
          }
        } catch (err) {
          console.error(`Failed to load RSVP for practice ${practice.id}:`, err);
        }
        return practice;
      })
    );
    
    this.renderPractices(practicesWithRSVP);
  }
  
  renderPractices(practices) {
    // Transform event_date into separate date and time fields
    const transformedPractices = practices.map(p => {
      const eventDate = new Date(p.event_date);
      
      // Format date as relative or absolute
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      
      let dateDisplay;
      if (eventDate.toDateString() === today.toDateString()) {
        dateDisplay = 'Today';
      } else if (eventDate.toDateString() === tomorrow.toDateString()) {
        dateDisplay = 'Tomorrow';
      } else {
        dateDisplay = eventDate.toLocaleDateString('en-US', { 
          weekday: 'short', 
          month: 'short', 
          day: 'numeric' 
        });
      }
      
      return {
        ...p,
        dateDisplay: dateDisplay,
        time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    });
    
    this.renderList('#practice-list', transformedPractices,
      p => {
        // Check if event has ended - no RSVP allowed
        if (p.has_ended) {
          return `
            <div class="card practice-card practice-ended">
              <div class="practice-card-header">
                <h3>${p.title}</h3>
                <span class="badge badge-muted">Ended</span>
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
              </div>
              
              ${p.notes ? `<p class="practice-notes">${p.notes}</p>` : ''}
              
              <div class="practice-card-actions">
                <div class="event-ended-notice">
                  ${p.userRsvpStatus ? `You RSVP'd: <strong>${p.userRsvpStatus === 'attending' ? '✓ Attending' : '✗ Not Attending'}</strong>` : 'No RSVP recorded'}
                </div>
              </div>
            </div>
          `;
        }
        
        // Active event - show RSVP buttons
        // Determine current RSVP status styling
        console.log(`Rendering practice ${p.id} with RSVP status: "${p.userRsvpStatus}"`);
        const attendingClass = p.userRsvpStatus === 'attending' ? 'btn-success' : 'btn-secondary';
        const notAttendingClass = p.userRsvpStatus === 'not_attending' ? 'btn-danger' : 'btn-secondary';
        console.log(`Classes: attending=${attendingClass}, notAttending=${notAttendingClass}`);
        
        return `
          <div class="card practice-card">
            <div class="practice-card-header">
              <h3>${p.title}</h3>
              ${p.rsvpCount ? `<span class="badge">${p.rsvpCount} responses</span>` : ''}
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
            
            ${p.notes ? `<p class="practice-notes">${p.notes}</p>` : ''}
            
            <div class="practice-card-actions">
              <button 
                data-action="rsvp" 
                data-id="${p.id}" 
                data-status="attending"
                class="btn ${attendingClass}">
                ✓ Attending
              </button>
              <button 
                data-action="rsvp" 
                data-id="${p.id}" 
                data-status="not_attending"
                class="btn ${notAttendingClass}">
                ✗ Can't Make It
              </button>
            </div>
            
            <div class="practice-card-actions" style="margin-top: var(--space-2); border-top: 1px solid var(--border-color); padding-top: var(--space-2);">
              <button 
                data-action="tactics" 
                data-id="${p.id}" 
                data-title="${p.title}"
                class="btn btn-secondary"
                style="width: 100%;">
                📋 Tactics Board
              </button>
            </div>
          </div>
        `;
      },
      '<div class="empty-state"><p>⚽ No practices scheduled yet</p><p class="text-muted">Check back later or ask your coach</p></div>'
    );
  }
  
  handleRSVP(practiceId, status) {
    const userId = this.auth.getUser()?.id;
    const roleType = this.navigation.context.role;
    
    if (!userId || !roleType) {
      console.error('Missing user ID or role type for RSVP');
      alert('Unable to record RSVP. Please log in again.');
      return;
    }
    
    console.log('Submitting RSVP:', { practiceId, userId, roleType, status });
    
    this.auth.fetch(`/api/events/${practiceId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        user_id: userId,
        role_type: roleType,
        status: status,
        notes: ''
      })
    })
    .then(r => {
      if (!r.ok) throw new Error('RSVP failed');
      return r.json();
    })
    .then((response) => {
      console.log('RSVP response:', response);
      console.log(`RSVP recorded: ${status}`);
      
      // Refresh list to show updated status
      this.loadPractices();
    })
    .catch(err => {
      console.error('RSVP error:', err);
      this.handleError(err, 'rsvp');
    });
  }
}
