// ClubEventsScreen - View GroupMe events & RSVPs with override capability
class ClubEventsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = '';
    this.events = [];
    this.rsvps = [];
    this.rsvpsByEvent = {};
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-club-events';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="events-title">📅 Club Events</h1>
        <p class="subtitle" id="events-subtitle">Events & RSVPs</p>
      </div>
      <div id="events-content" style="padding: var(--space-4);">
        <div class="loading-indicator">Loading events...</div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';

    this.find('#events-title').textContent = `📅 ${this.clubName} Events`;
    this.find('#events-subtitle').textContent = 'Chat events & RSVP management';

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      // Override button click
      const overrideBtn = e.target.closest('.override-btn');
      if (overrideBtn) {
        const rsvpId = overrideBtn.dataset.rsvpId;
        const name = overrideBtn.dataset.name;
        const currentStatus = overrideBtn.dataset.currentStatus;
        this.showOverrideModal(rsvpId, name, currentStatus);
        return;
      }

      // Clear override button
      const clearBtn = e.target.closest('.clear-override-btn');
      if (clearBtn) {
        const rsvpId = clearBtn.dataset.rsvpId;
        this.clearOverride(rsvpId);
        return;
      }
    });

    this.loadEvents();
  }

  async loadEvents() {
    const content = this.find('#events-content');
    try {
      const response = await this.auth.fetch(`/api/events/club/${this.clubId}/chat-events`);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const result = await response.json();

      if (!result.success) throw new Error(result.message || 'Failed to load events');

      this.events = result.data.events || [];
      this.rsvps = result.data.rsvps || [];

      // Index RSVPs by event_id
      this.rsvpsByEvent = {};
      this.rsvps.forEach(r => {
        if (!this.rsvpsByEvent[r.event_id]) this.rsvpsByEvent[r.event_id] = [];
        this.rsvpsByEvent[r.event_id].push(r);
      });

      this.renderEvents(content);

    } catch (error) {
      content.innerHTML = `<div class="error-message">Error loading events: ${error.message}</div>`;
    }
  }

  renderEvents(content) {
    if (this.events.length === 0) {
      content.innerHTML = `
        <div style="text-align: center; padding: var(--space-6); opacity: 0.7;">
          <div style="font-size: 3rem; margin-bottom: var(--space-2);">📅</div>
          <p>No events synced yet.</p>
          <p style="font-size: 0.85em; margin-top: var(--space-2);">Run <code>node scripts/sync-groupme-events.js</code> to sync GroupMe events.</p>
        </div>`;
      return;
    }

    content.innerHTML = this.events.map(evt => this.renderEventCard(evt)).join('');
  }

  renderEventCard(evt) {
    const eventRsvps = this.rsvpsByEvent[evt.id] || [];
    const going = eventRsvps.filter(r => r.effective_status_id === 1);
    const notGoing = eventRsvps.filter(r => r.effective_status_id === 2);
    const maybe = eventRsvps.filter(r => r.effective_status_id === 3);

    const startDate = evt.start_at ? new Date(evt.start_at) : null;
    const dateStr = startDate
      ? startDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })
      : (evt.event_date || 'No date');
    const timeStr = startDate
      ? startDate.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
      : '';

    let typeBadge = '';
    if (evt.match_id && evt.match_type) {
      typeBadge = `<span style="background: var(--primary); color: white; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin-left: 8px;">${evt.match_type}</span>`;
    }

    return `
      <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-3);">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: var(--space-2);">
          <div>
            <h3 style="margin: 0;">${this.escapeHtml(evt.title)}${typeBadge}</h3>
            <div style="color: var(--text-secondary); font-size: 0.9em; margin-top: 4px;">
              📅 ${dateStr} ${timeStr ? '&bull; 🕐 ' + timeStr : ''}
              ${evt.location ? '&bull; 📍 ' + this.escapeHtml(evt.location) : ''}
            </div>
            <div style="color: var(--text-secondary); font-size: 0.85em; margin-top: 2px;">💬 ${this.escapeHtml(evt.chat_name)}</div>
            ${evt.match_id && evt.home_team ? `<div style="font-size: 0.85em; margin-top: 4px;">⚽ ${this.escapeHtml(evt.home_team)} ${evt.home_score !== null ? evt.home_score : ''} vs ${evt.away_score !== null ? evt.away_score : ''} ${this.escapeHtml(evt.away_team)}</div>` : ''}
          </div>
          <div style="text-align: right; white-space: nowrap;">
            <span style="color: var(--success); font-weight: bold;">✓${evt.going}</span>
            <span style="color: var(--danger); margin-left: 8px;">✗${evt.not_going}</span>
            <span style="color: var(--warning); margin-left: 8px;">?${evt.maybe}</span>
          </div>
        </div>

        <details style="margin-top: var(--space-2);">
          <summary style="cursor: pointer; color: var(--primary); font-size: 0.9em;">Manage RSVPs (${eventRsvps.length})</summary>
          <div style="margin-top: var(--space-2);">
            ${going.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--success);">Going (${going.length}):</strong><div>${this.renderRsvpList(going, '#28a745')}</div></div>` : ''}
            ${notGoing.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--danger);">Not Going (${notGoing.length}):</strong><div>${this.renderRsvpList(notGoing, '#dc3545')}</div></div>` : ''}
            ${maybe.length > 0 ? `<div style="margin-bottom: var(--space-2);"><strong style="color: var(--warning);">Maybe (${maybe.length}):</strong><div>${this.renderRsvpList(maybe, '#ffc107')}</div></div>` : ''}
            ${eventRsvps.length === 0 ? '<p style="color: var(--text-secondary);">No RSVPs recorded</p>' : ''}
          </div>
        </details>
      </div>
    `;
  }

  renderRsvpList(list, color) {
    return list.map(r => {
      const isOverridden = r.is_overridden;
      const bgColor = r.linked ? color : '#e9ecef';
      const textColor = r.linked ? 'white' : '#666';
      const border = isOverridden ? '2px solid #6f42c1' : 'none';
      const overrideIcon = isOverridden ? '✏️' : '';
      const tooltip = isOverridden
        ? `Overridden${r.override_note ? ': ' + r.override_note : ''} (GroupMe: ${r.synced_status})`
        : (r.linked ? 'Linked to person' : 'Not linked — click to override');

      return `<span 
        class="override-btn" 
        data-rsvp-id="${r.rsvp_id}" 
        data-name="${this.escapeHtml(r.name)}"
        data-current-status="${r.effective_status_id}"
        style="display: inline-block; padding: 2px 8px; margin: 2px; border-radius: 12px; font-size: 0.8em; 
               background: ${bgColor}; color: ${textColor}; border: ${border}; cursor: pointer;
               position: relative;"
        title="${tooltip}"
      >${overrideIcon}${this.escapeHtml(r.name)}${isOverridden ? '<button class="clear-override-btn" data-rsvp-id="' + r.rsvp_id + '" style="background:none;border:none;cursor:pointer;font-size:0.8em;padding:0 0 0 4px;color:inherit;" title="Clear override">×</button>' : ''}</span>`;
    }).join('');
  }

  showOverrideModal(rsvpId, name, currentStatusId) {
    // Remove existing modal if any
    const existing = document.getElementById('override-modal');
    if (existing) existing.remove();

    const modal = document.createElement('div');
    modal.id = 'override-modal';
    modal.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:1000;display:flex;align-items:center;justify-content:center;';
    modal.innerHTML = `
      <div style="background:var(--bg-primary);border-radius:var(--radius-lg);padding:var(--space-4);max-width:360px;width:90%;box-shadow:0 8px 32px rgba(0,0,0,0.3);">
        <h3 style="margin:0 0 var(--space-3) 0;">Override RSVP: ${this.escapeHtml(name)}</h3>
        <div style="display:flex;gap:var(--space-2);margin-bottom:var(--space-3);">
          <button class="btn modal-status-btn ${currentStatusId == 1 ? 'btn-primary' : 'btn-secondary'}" data-status="1" style="flex:1;">✓ Going</button>
          <button class="btn modal-status-btn ${currentStatusId == 2 ? 'btn-primary' : 'btn-secondary'}" data-status="2" style="flex:1;">✗ Not Going</button>
          <button class="btn modal-status-btn ${currentStatusId == 3 ? 'btn-primary' : 'btn-secondary'}" data-status="3" style="flex:1;">? Maybe</button>
        </div>
        <input type="text" id="override-note" placeholder="Note (optional): Injured, confirmed via text..." 
               style="width:100%;padding:8px;border:1px solid var(--border);border-radius:var(--radius);margin-bottom:var(--space-3);box-sizing:border-box;background:var(--bg-secondary);color:var(--text-primary);">
        <div style="display:flex;gap:var(--space-2);justify-content:flex-end;">
          <button class="btn btn-secondary" id="modal-cancel">Cancel</button>
        </div>
      </div>
    `;

    document.body.appendChild(modal);

    // Event handlers
    modal.querySelector('#modal-cancel').addEventListener('click', () => modal.remove());
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.remove();
    });

    modal.querySelectorAll('.modal-status-btn').forEach(btn => {
      btn.addEventListener('click', async () => {
        const statusId = btn.dataset.status;
        const note = modal.querySelector('#override-note').value.trim();
        modal.remove();
        await this.applyOverride(rsvpId, statusId, note);
      });
    });
  }

  async applyOverride(rsvpId, statusId, note) {
    try {
      const response = await this.auth.fetch(`/api/events/chat-rsvps/${rsvpId}/override`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status_id: statusId, note: note })
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      // Reload events to reflect change
      await this.loadEvents();
    } catch (error) {
      alert('Failed to override: ' + error.message);
    }
  }

  async clearOverride(rsvpId) {
    try {
      const response = await this.auth.fetch(`/api/events/chat-rsvps/${rsvpId}/override`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ clear: true })
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      await this.loadEvents();
    } catch (error) {
      alert('Failed to clear override: ' + error.message);
    }
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
