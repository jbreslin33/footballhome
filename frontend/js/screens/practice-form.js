// PracticeFormScreen - create or edit a practice
class PracticeFormScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.mode = 'create'; // 'create' or 'edit'
    this.practiceId = null;
  }
  
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-practice-form';
    div.innerHTML = `
      <div class="screen-header">
        <h1 id="form-title">⚽ Create Practice</h1>
        <p class="subtitle">Fill in the details below</p>
      </div>
      
      <div class="card" style="max-width: 600px; margin: var(--space-4) auto;">
        <form id="practice-form">
          <div class="form-group">
            <label for="title" class="form-label">Practice Title *</label>
            <input type="text" id="title" name="title" class="form-input" required 
                   placeholder="e.g., Tuesday Night Practice">
          </div>
          
          <div class="form-group">
            <label for="date" class="form-label">Date *</label>
            <input type="date" id="date" name="date" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label for="time" class="form-label">Time *</label>
            <input type="time" id="time" name="time" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label for="venue_id" class="form-label">Venue *</label>
            <select id="venue_id" name="venue_id" class="form-input" required>
              <option value="">Select a venue...</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="notes" class="form-label">Notes</label>
            <textarea id="notes" name="notes" class="form-input" rows="4"
                      placeholder="Any additional details about this practice..."></textarea>
          </div>
          
          <div style="display: flex; gap: var(--space-3); margin-top: var(--space-6);">
            <button type="button" id="cancel-btn" class="btn btn-secondary" style="flex: 1;">Cancel</button>
            <button type="submit" id="submit-btn" class="btn btn-primary" style="flex: 2;">Create Practice</button>
          </div>
        </form>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.mode = params.mode || 'create';
    this.practiceId = params.practiceId || null;
    
    // Update UI based on mode
    if (this.mode === 'edit') {
      this.find('#form-title').textContent = 'Edit Practice';
      this.find('#submit-btn').textContent = 'Save Changes';
      // Load venues first, then load practice data
      this.loadVenues(() => {
        this.loadPractice(this.practiceId);
      });
    } else {
      // For create mode, just load venues
      this.loadVenues();
      // Set today as default date for new practices
      const today = new Date().toISOString().split('T')[0];
      this.find('#date').value = today;
    }
    
    // Handle form submission
    const form = this.find('#practice-form');
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      
      const formData = new FormData(e.target);
      const practice = {
        team_id: this.navigation.context.team.id,
        event_type: 'training',
        title: formData.get('title'),
        date: formData.get('date'),
        start_time: formData.get('time'),
        end_time: '', // Can add later if needed
        venue_id: formData.get('venue_id'),
        notes: formData.get('notes')
      };
      
      if (this.mode === 'create') {
        this.createPractice(practice);
      } else {
        this.updatePractice(this.practiceId, practice);
      }
    });
    
    // Handle cancel
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'cancel-btn' || e.target.closest('#cancel-btn')) {
        this.navigation.goBack();
      }
    });
  }
  
  loadVenues(callback) {
    this.safeFetch('/api/venues', response => {
      // Extract venues from standardized response format
      const venues = response.data || [];
      const select = this.find('#venue_id');
      
      // Clear existing options except the first one
      select.innerHTML = '<option value="">Select a venue...</option>';
      
      // Add venue options
      venues.forEach(venue => {
        const option = document.createElement('option');
        option.value = venue.id;
        option.textContent = `${venue.name}${venue.city ? ' - ' + venue.city : ''}`;
        select.appendChild(option);
      });
      
      // Call callback after venues are loaded
      if (callback) callback();
    });
  }
  
  loadPractice(practiceId) {
    this.safeFetch(`/api/events/${practiceId}`, response => {
      // Extract practice from standardized response format
      const practice = response.data || response;
      
      this.find('#title').value = practice.title || '';
      this.find('#date').value = practice.date || '';
      this.find('#time').value = practice.time || '';
      this.find('#venue_id').value = practice.venue_id || '';
      this.find('#notes').value = practice.notes || '';
    });
  }
  
  createPractice(practice) {
    this.auth.fetch('/api/events', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(practice)
    })
    .then(r => {
      if (!r.ok) throw new Error('Failed to create practice');
      return r.json();
    })
    .then(() => {
      console.log('Practice created successfully');
      this.navigation.goBack(); // Back to management screen
    })
    .catch(err => {
      this.handleError(err, 'create');
    });
  }
  
  updatePractice(practiceId, practice) {
    this.auth.fetch(`/api/events/${practiceId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(practice)
    })
    .then(r => {
      if (!r.ok) throw new Error('Failed to update practice');
      return r.json();
    })
    .then(() => {
      console.log('Practice updated successfully');
      this.navigation.goBack(); // Back to management screen
    })
    .catch(err => {
      this.handleError(err, 'update');
    });
  }
}
