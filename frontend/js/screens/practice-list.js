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
    
    this.safeFetch(`/api/teams/${teamId}/practices`, practices => {
      this.renderList('#practice-list', practices,
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
    });
  }
  
  handleRSVP(practiceId, status) {
    this.auth.fetch(`/api/practices/${practiceId}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: status })
    })
    .then(r => {
      if (!r.ok) throw new Error('RSVP failed');
      return r.json();
    })
    .then(() => {
      console.log(`RSVP recorded: ${status}`);
      
      // Show feedback
      const message = status === 'attending' 
        ? '✓ Marked as Attending' 
        : '✗ Marked as Not Attending';
      
      // Simple alert for now (can enhance with toast notification later)
      alert(message);
      
      // Refresh list to show updated status
      this.loadPractices();
    })
    .catch(err => {
      this.handleError(err, 'rsvp');
    });
  }
}
