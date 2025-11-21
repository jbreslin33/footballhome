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
      <div class="card">
        <h2 id="form-title">Create Practice</h2>
        
        <form id="practice-form">
          <div class="form-group">
            <label for="title">Practice Title *</label>
            <input type="text" id="title" name="title" class="form-input" required 
                   placeholder="e.g., Tuesday Night Practice">
          </div>
          
          <div class="form-group">
            <label for="date">Date *</label>
            <input type="date" id="date" name="date" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label for="time">Time *</label>
            <input type="time" id="time" name="time" class="form-input" required>
          </div>
          
          <div class="form-group">
            <label for="venue_id">Venue *</label>
            <select id="venue_id" name="venue_id" class="form-input" required>
              <option value="">Select a venue...</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="notes">Notes</label>
            <textarea id="notes" name="notes" class="form-input" rows="4"
                      placeholder="Any additional details about this practice..."></textarea>
          </div>
          
          <div class="form-actions">
            <button type="button" id="cancel-btn" class="btn btn-secondary">Cancel</button>
            <button type="submit" id="submit-btn" class="btn btn-primary">Create Practice</button>
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
    
    // Load venues into dropdown
    this.loadVenues();
    
    // Update UI based on mode
    if (this.mode === 'edit') {
      this.find('#form-title').textContent = 'Edit Practice';
      this.find('#submit-btn').textContent = 'Save Changes';
      this.loadPractice(this.practiceId);
    } else {
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
  
  loadVenues() {
    this.safeFetch('/api/venues', venues => {
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
    });
  }
  
  loadPractice(practiceId) {
    this.safeFetch(`/api/practices/${practiceId}`, practice => {
      this.find('#title').value = practice.title || '';
      this.find('#date').value = practice.date || '';
      this.find('#time').value = practice.time || '';
      this.find('#venue_id').value = practice.venue_id || '';
      this.find('#notes').value = practice.notes || '';
    });
  }
  
  createPractice(practice) {
    this.auth.fetch('/api/practices', {
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
    this.auth.fetch(`/api/practices/${practiceId}`, {
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
