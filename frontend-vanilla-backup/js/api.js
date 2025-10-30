// API Client for Football Home
class APIClient {
    constructor() {
        this.baseURL = window.location.hostname === 'localhost' 
            ? 'http://localhost:3000'
            : 'https://footballhome.org';
    }

    async request(endpoint, options = {}) {
        const url = `${this.baseURL}/api${endpoint}`;
        
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include', // Include cookies for session management
        };

        const config = {
            ...defaultOptions,
            ...options,
            headers: {
                ...defaultOptions.headers,
                ...options.headers,
            },
        };

        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
                
                // Try to get more detailed error from response body
                try {
                    const errorData = await response.json();
                    if (errorData.error || errorData.message) {
                        errorMessage = errorData.error || errorData.message;
                    }
                } catch (parseError) {
                    // If we can't parse JSON, stick with the status text
                }
                
                throw new Error(errorMessage);
            }

            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return await response.json();
            }
            
            return await response.text();
        } catch (error) {
            // Enhance error message for common network issues
            if (error.name === 'TypeError' && error.message.includes('fetch')) {
                throw new Error('Network connection failed. Please check your internet connection.');
            }
            console.error('API Request failed:', error);
            throw error;
        }
    }

    // Health check
    async healthCheck() {
        return this.request('/health');
    }

    // Events
    async getTeamEvents(teamId) {
        return this.request(`/teams/${teamId}/events`);
    }

    async createEvent(eventData) {
        return this.request('/events', {
            method: 'POST',
            body: JSON.stringify(eventData),
        });
    }

    async updateEvent(eventId, eventData) {
        return this.request(`/events/${eventId}`, {
            method: 'PUT',
            body: JSON.stringify(eventData),
        });
    }

    async deleteEvent(eventId) {
        return this.request(`/events/${eventId}`, {
            method: 'DELETE',
        });
    }

    // RSVPs
    async rsvpToEvent(eventId, rsvpData) {
        return this.request(`/events/${eventId}/rsvp`, {
            method: 'POST',
            body: JSON.stringify(rsvpData),
        });
    }

    async getEventRSVPs(eventId) {
        return this.request(`/events/${eventId}/rsvps`);
    }

    // Teams
    async getTeam(teamId) {
        return this.request(`/teams/${teamId}`);
    }

    async getTeamMembers(teamId) {
        return this.request(`/teams/${teamId}/members`);
    }

    // Users/Auth (placeholder for future implementation)
    async login(credentials) {
        return this.request('/auth/login', {
            method: 'POST',
            body: JSON.stringify(credentials),
        });
    }

    async logout() {
        return this.request('/auth/logout', {
            method: 'POST',
        });
    }

    async getCurrentUser() {
        return this.request('/auth/me');
    }

    async updateProfile(profileData) {
        return this.request('/auth/profile', {
            method: 'PUT',
            body: JSON.stringify(profileData),
        });
    }

    // Utility method for handling offline scenarios
    async requestWithOfflineSupport(endpoint, options = {}) {
        try {
            return await this.request(endpoint, options);
        } catch (error) {
            // Check if we're offline
            if (!navigator.onLine) {
                console.log('Offline - checking cache or local storage');
                // TODO: Implement offline data handling
                throw new Error('You are currently offline. Please try again when connected.');
            }
            throw error;
        }
    }
}

// Create global API instance
window.API = new APIClient();

// Test API connection when loaded
API.healthCheck()
    .then(response => {
        console.log('API Health Check:', response);
    })
    .catch(error => {
        console.warn('API not available:', error.message);
    });