// PracticeListScreen - view practices and RSVP
class PracticeListScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-list';
    div.innerHTML = `
      <div class="card">
        <h2>Practices - RSVP</h2>
        <p class="text-gray-600">View and respond to upcoming practices</p>
        
        <div id="practice-list" style="margin-top: 20px;"></div>
        
        <button id="back-btn" class="btn btn-secondary" style="margin-top: 20px;">
          ← Back
        </button>
      </div>
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
      return {
        ...p,
        date: eventDate.toLocaleDateString(),
        time: eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    });
    
    this.renderList('#practice-list', transformedPractices,
      p => {
        // Determine current RSVP status styling
        const attendingClass = p.userRsvpStatus === 'attending' ? 'btn-primary' : 'btn-secondary';
        const notAttendingClass = p.userRsvpStatus === 'not_attending' ? 'btn-primary' : 'btn-secondary';
        
        return `
          <div class="practice-item">
            <h3>${p.title}</h3>
            <p class="practice-meta">
              📅 ${p.date} at ${p.time}
              ${p.location ? `<br>📍 ${p.location}` : ''}
            </p>
            ${p.notes ? `<p class="practice-notes">${p.notes}</p>` : ''}
            
            <div class="rsvp-buttons" style="margin-top: 10px; display: flex; gap: 10px;">
              <button 
                data-action="rsvp" 
                data-id="${p.id}" 
                data-status="attending"
                class="btn btn-sm ${attendingClass}">
                ✓ Attending
              </button>
              <button 
                data-action="rsvp" 
                data-id="${p.id}" 
                data-status="not_attending"
                class="btn btn-sm ${notAttendingClass}">
                ✗ Not Attending
              </button>
            </div>
            
            ${p.rsvpCount ? `<p class="rsvp-count" style="margin-top: 10px; color: #666; font-size: 0.9em;">${p.rsvpCount} responses</p>` : ''}
          </div>
        `;
      },
      'No practices scheduled. Check back later or ask your coach to create one.'
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
