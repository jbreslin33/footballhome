/**
 * EventCard Component
 * Displays upcoming events and matches
 */
class EventCard extends Component {
    constructor(container, events = []) {
        super(container, { events });
        this.events = events;
    }

    render() {
        return `
            <div class="card event-card">
                <h3 class="font-medium mb-2">
                    <span class="card-icon">📅</span>
                    Events
                </h3>
                <p class="text-sm text-gray-600 mb-3">
                    Upcoming matches and events
                </p>
                
                <div class="event-list">
                    ${this.renderEventList()}
                </div>
                
                <div class="card-actions mt-4">
                    <button class="btn btn-primary btn-sm" data-action="create-event">
                        + Schedule Event
                    </button>
                    <button class="btn btn-secondary btn-sm" data-action="view-calendar">
                        View Calendar
                    </button>
                </div>
            </div>
        `;
    }

    renderEventList() {
        if (!this.events || this.events.length === 0) {
            return `
                <div class="empty-state">
                    <p class="text-sm text-gray-500">No upcoming events</p>
                </div>
            `;
        }

        return this.events.slice(0, 3).map(event => `
            <div class="event-item">
                <div class="event-info">
                    <span class="event-title">${event.title || 'Untitled Event'}</span>
                    <span class="event-date">${this.formatDate(event.date)}</span>
                </div>
                <div class="event-status ${event.status || 'scheduled'}">
                    ${this.formatStatus(event.status)}
                </div>
            </div>
        `).join('');
    }

    formatDate(dateString) {
        if (!dateString) return 'TBD';
        
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch (e) {
            return 'Invalid date';
        }
    }

    formatStatus(status) {
        const statusMap = {
            'scheduled': 'Scheduled',
            'confirmed': 'Confirmed',
            'cancelled': 'Cancelled',
            'completed': 'Completed'
        };
        return statusMap[status] || 'Unknown';
    }

    setupEventListeners() {
        // Create event button
        const createBtn = this.querySelector('[data-action="create-event"]');
        if (createBtn) {
            this.addEventListener(createBtn, 'click', this.handleCreateEvent);
        }

        // View calendar button
        const calendarBtn = this.querySelector('[data-action="view-calendar"]');
        if (calendarBtn) {
            this.addEventListener(calendarBtn, 'click', this.handleViewCalendar);
        }

        // Event item clicks
        const eventItems = this.querySelectorAll('.event-item');
        eventItems.forEach(item => {
            this.addEventListener(item, 'click', (e) => {
                const eventTitle = item.querySelector('.event-title')?.textContent;
                this.handleEventClick(eventTitle);
            });
        });
    }

    handleCreateEvent() {
        console.log('EventCard: Create event clicked');
        this.emit('event:create');
    }

    handleViewCalendar() {
        console.log('EventCard: View calendar clicked');
        this.emit('event:viewCalendar');
    }

    handleEventClick(eventTitle) {
        console.log('EventCard: Event clicked:', eventTitle);
        this.emit('event:select', { eventTitle });
    }

    // Update events data
    updateEvents(events) {
        this.events = events;
        this.update();
    }
}