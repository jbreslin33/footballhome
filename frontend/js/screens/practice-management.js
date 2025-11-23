// PracticeManagementScreen - list practices with add/edit/delete
class PracticeManagementScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-management';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>⚽ Manage Practices</h1>
        <p class="subtitle">Create, edit, and delete practices</p>
      </div>
      
      <div style="padding: var(--space-4);">
        <button id="add-practice-btn" class="btn btn-lg btn-success" style="width: 100%; max-width: 500px; margin: 0 auto var(--space-4); display: flex; justify-content: center;">
          + Add New Practice
        </button>
        
        <div id="practice-list" class="practice-cards"></div>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.loadPractices();
    
    this.element.addEventListener('click', (e) => {
      // Add new practice
      if (e.target.id === 'add-practice-btn' || e.target.closest('#add-practice-btn')) {
        this.navigation.goTo('practice-form', { mode: 'create' });
        return;
      }
      
      // Edit practice
      const editBtn = e.target.closest('[data-action="edit"]');
      if (editBtn) {
        const practiceId = editBtn.getAttribute('data-id');
        this.navigation.goTo('practice-form', { 
          mode: 'edit', 
          practiceId: practiceId 
        });
        return;
      }
      
      // Delete practice
      const deleteBtn = e.target.closest('[data-action="delete"]');
      if (deleteBtn) {
        const practiceId = deleteBtn.getAttribute('data-id');
        const practiceName = deleteBtn.getAttribute('data-name');
        
        if (confirm(`Delete practice "${practiceName}"?`)) {
          this.deletePractice(practiceId);
        }
        return;
      }
      
      // Back button
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
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
        p => `
          <div class="card practice-card">
            <div class="practice-card-header">
              <h3>${p.title}</h3>
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
            
            <div style="display: flex; gap: var(--space-3); margin-top: var(--space-4);">
              <button data-action="edit" data-id="${p.id}" class="btn btn-primary" style="flex: 1;">Edit</button>
              <button data-action="delete" data-id="${p.id}" data-name="${p.title}" class="btn btn-danger" style="flex: 1;">Delete</button>
            </div>
          </div>
        `,
        '<div class="empty-state"><p>⚽ No practices scheduled yet</p><p class="text-muted">Click "Add New Practice" to create one</p></div>'
      );
    });
  }
  
  deletePractice(practiceId) {
    this.auth.fetch(`/api/events/${practiceId}`, { 
      method: 'DELETE' 
    })
    .then(r => {
      if (!r.ok) throw new Error('Delete failed');
      console.log('Practice deleted');
      this.loadPractices(); // Refresh list
    })
    .catch(err => {
      this.handleError(err, 'delete');
    });
  }
}
