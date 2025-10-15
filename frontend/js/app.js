// Football Home - Main Application
class FootballApp {
    constructor() {
        this.currentView = 'events';
        this.currentTeamId = '550e8400-e29b-41d4-a716-446655440001'; // TODO: Get from auth
        this.init();
    }

    init() {
        this.setupNavigation();
        this.setupEventForm();
        this.loadEvents();
        this.setupPWA();
    }

    setupNavigation() {
        const navButtons = document.querySelectorAll('.nav-btn');
        const views = document.querySelectorAll('.view');

        navButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const viewName = btn.id.replace('nav-', '');
                this.switchView(viewName);
            });
        });
    }

    switchView(viewName) {
        // Update active nav button
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.getElementById(`nav-${viewName}`).classList.add('active');

        // Update active view
        document.querySelectorAll('.view').forEach(view => {
            view.classList.remove('active');
        });
        document.getElementById(`${viewName}-view`).classList.add('active');

        this.currentView = viewName;
    }

    setupEventForm() {
        const form = document.getElementById('create-event-form');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = new FormData(form);
            const eventData = {
                team_id: this.currentTeamId,
                title: formData.get('title'),
                event_type: formData.get('event_type'),
                event_date: formData.get('event_date'),
                location: formData.get('location'),
                duration_minutes: parseInt(formData.get('duration_minutes')),
                description: formData.get('description')
            };

            try {
                const response = await API.createEvent(eventData);
                if (response.status === 'created') {
                    this.showNotification('Event created successfully!', 'success');
                    form.reset();
                    this.switchView('events');
                    this.loadEvents(); // Refresh events list
                }
            } catch (error) {
                this.showNotification('Error creating event', 'error');
                console.error('Create event error:', error);
            }
        });
    }

    async loadEvents() {
        const eventsList = document.getElementById('events-list');
        eventsList.innerHTML = '<div class="loading">Loading events...</div>';

        try {
            const response = await API.getTeamEvents(this.currentTeamId);
            this.renderEvents(response.events);
        } catch (error) {
            eventsList.innerHTML = '<div class="loading">Error loading events</div>';
            console.error('Load events error:', error);
        }
    }

    renderEvents(events) {
        const eventsList = document.getElementById('events-list');
        
        if (events.length === 0) {
            eventsList.innerHTML = `
                <div class="loading">
                    <p>No events scheduled yet.</p>
                    <button class="btn btn-primary" onclick="app.switchView('create')">Create First Event</button>
                </div>
            `;
            return;
        }

        eventsList.innerHTML = events.map(event => this.createEventCard(event)).join('');
    }

    createEventCard(event) {
        const date = new Date(event.event_date);
        const formattedDate = date.toLocaleDateString();
        const formattedTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        return `
            <div class="event-card" data-event-id="${event.id}">
                <div class="event-card-header">
                    <h3 class="event-title">${event.title}</h3>
                    <span class="event-type ${event.event_type}">${event.event_type}</span>
                </div>
                
                <div class="event-details">
                    <div class="event-detail">
                        <span class="event-detail-icon">📅</span>
                        <span>${formattedDate} at ${formattedTime}</span>
                    </div>
                    ${event.location ? `
                        <div class="event-detail">
                            <span class="event-detail-icon">📍</span>
                            <span>${event.location}</span>
                        </div>
                    ` : ''}
                    <div class="event-detail">
                        <span class="event-detail-icon">⏱️</span>
                        <span>${event.duration_minutes} minutes</span>
                    </div>
                </div>
                
                ${event.description ? `
                    <div class="event-description">${event.description}</div>
                ` : ''}
                
                <div class="rsvp-status">
                    <span class="rsvp-count">3 attending • 1 maybe • 0 can't make it</span>
                </div>
                
                <div class="rsvp-buttons">
                    <button class="rsvp-btn" data-status="yes" onclick="app.handleRSVP('${event.id}', 'yes')">✓ Yes</button>
                    <button class="rsvp-btn" data-status="maybe" onclick="app.handleRSVP('${event.id}', 'maybe')">? Maybe</button>
                    <button class="rsvp-btn" data-status="no" onclick="app.handleRSVP('${event.id}', 'no')">✗ No</button>
                </div>
            </div>
        `;
    }

    async handleRSVP(eventId, status) {
        try {
            const response = await API.rsvpToEvent(eventId, {
                user_id: '550e8400-e29b-41d4-a716-446655440011', // TODO: Get from auth
                status: status
            });
            
            if (response.status === 'rsvp_updated') {
                this.showNotification('RSVP updated!', 'success');
                
                // Update button states
                const eventCard = document.querySelector(`[data-event-id="${eventId}"]`);
                const rsvpButtons = eventCard.querySelectorAll('.rsvp-btn');
                rsvpButtons.forEach(btn => btn.classList.remove('active'));
                eventCard.querySelector(`[data-status="${status}"]`).classList.add('active');
            }
        } catch (error) {
            this.showNotification('Error updating RSVP', 'error');
            console.error('RSVP error:', error);
        }
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Style the notification
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            color: white;
            font-weight: 500;
            z-index: 1000;
            transform: translateX(100%);
            transition: transform 0.3s ease;
        `;
        
        if (type === 'success') {
            notification.style.background = '#10b981';
        } else if (type === 'error') {
            notification.style.background = '#ef4444';
        } else {
            notification.style.background = '#3b82f6';
        }
        
        document.body.appendChild(notification);
        
        // Animate in
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 100);
        
        // Remove after delay
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    }

    setupPWA() {
        // Register service worker
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('Service Worker registered:', registration);
                })
                .catch(error => {
                    console.log('Service Worker registration failed:', error);
                });
        }

        // Handle install prompt
        let deferredPrompt;
        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
            
            const installPrompt = document.getElementById('install-prompt');
            installPrompt.classList.remove('hidden');
            
            document.getElementById('install-btn').addEventListener('click', () => {
                deferredPrompt.prompt();
                deferredPrompt.userChoice.then((choiceResult) => {
                    if (choiceResult.outcome === 'accepted') {
                        console.log('PWA installed');
                    }
                    deferredPrompt = null;
                    installPrompt.classList.add('hidden');
                });
            });
            
            document.getElementById('dismiss-install').addEventListener('click', () => {
                installPrompt.classList.add('hidden');
            });
        });
    }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.app = new FootballApp();
});