// PracticeManagementScreen - list practices with add/edit/delete
class PracticeManagementScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-management';
    div.innerHTML = `
      <div class="card">
        <h2>Manage Practices</h2>
        
        <button id="add-practice-btn" class="btn btn-primary" style="margin-bottom: 20px;">
          + Add New Practice
        </button>
        
        <div id="practice-list"></div>
        
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
    
    this.safeFetch(`/api/events/${teamId}`, response => {
      // Extract practices from standardized response format
      const practices = response.data || [];
      
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
        p => `
          <div class="practice-item">
            <div class="practice-header">
              <h3>${p.title}</h3>
              <div class="practice-actions">
                <button data-action="edit" data-id="${p.id}" class="btn btn-sm">Edit</button>
                <button data-action="delete" data-id="${p.id}" data-name="${p.title}" class="btn btn-sm btn-secondary">Delete</button>
              </div>
            </div>
            <p class="practice-meta">
              📅 ${p.date} at ${p.time}
              ${p.location ? `<br>📍 ${p.location}` : ''}
            </p>
            ${p.notes ? `<p class="practice-notes">${p.notes}</p>` : ''}
          </div>
        `,
        'No practices scheduled yet. Click "Add New Practice" to create one.'
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
