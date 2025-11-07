import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import './RSVPManager.css';

interface Event {
  id: string;
  title: string;
  description: string;
  event_date: string;
  venue_name?: string;
  venue_address?: string;
  team_name: string;
  event_type_name: string;
  duration_minutes: number;
  max_players?: number;
  my_rsvp_status?: string;
  rsvp_summary?: {
    attending: number;
    not_attending: number;
    maybe: number;
    total_rsvps: number;
  };
}

interface RSVP {
  id: string;
  event_id: string;
  status: string;
  notes?: string;
  response_date: string;
  event_title: string;
  event_date: string;
  team_name: string;
  venue_name?: string;
}

interface RSVPManagerProps {
  onClose?: () => void;
}

const RSVPManager: React.FC<RSVPManagerProps> = ({ onClose }) => {
  const { } = useAuth(); // Authentication context available if needed
  const [activeTab, setActiveTab] = useState<'upcoming' | 'my-rsvps'>('upcoming');
  const [events, setEvents] = useState<Event[]>([]);
  const [rsvps, setRsvps] = useState<RSVP[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState<string | null>(null);

  // Load upcoming events that need RSVP
  const loadUpcomingEvents = async () => {
    try {
      setLoading(true);
      // We'll need to get events from user's teams
      const response = await api.get('/events', {
        params: {
          upcoming: true,
          limit: 20
        }
      });
      
      setEvents(response.data.events || []);
    } catch (err: any) {
      console.error('Failed to load upcoming events:', err);
      setError('Failed to load upcoming events');
    } finally {
      setLoading(false);
    }
  };

  // Load user's RSVP history
  const loadMyRSVPs = async () => {
    try {
      setLoading(true);
      const response = await api.get('/rsvps/my-rsvps', {
        params: {
          limit: 50,
          start_date: new Date().toISOString() // Only future events
        }
      });
      
      setRsvps(response.data.rsvps || []);
    } catch (err: any) {
      console.error('Failed to load RSVPs:', err);
      setError('Failed to load your RSVPs');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'upcoming') {
      loadUpcomingEvents();
    } else {
      loadMyRSVPs();
    }
  }, [activeTab]);

  // Handle RSVP submission
  const handleRSVP = async (eventId: string, status: 'attending' | 'not_attending' | 'maybe', notes: string = '') => {
    try {
      setSubmitting(eventId);
      
      await api.post('/rsvps', {
        event_id: eventId,
        status,
        notes
      });
      
      // Refresh the current view
      if (activeTab === 'upcoming') {
        loadUpcomingEvents();
      } else {
        loadMyRSVPs();
      }
      
    } catch (err: any) {
      console.error('Failed to save RSVP:', err);
      setError(err.response?.data?.error || 'Failed to save RSVP');
    } finally {
      setSubmitting(null);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'attending': return '#27ae60';
      case 'not_attending': return '#e74c3c';
      case 'maybe': return '#f39c12';
      default: return '#95a5a6';
    }
  };

  const getStatusDisplay = (status: string) => {
    switch (status) {
      case 'attending': return '✅ Attending';
      case 'not_attending': return '❌ Not Attending';
      case 'maybe': return '❓ Maybe';
      default: return '⏳ No Response';
    }
  };

  const formatEventDate = (dateString: string) => {
    const date = new Date(dateString);
    return {
      date: date.toLocaleDateString('en-US', { 
        weekday: 'short', 
        month: 'short', 
        day: 'numeric' 
      }),
      time: date.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit' 
      })
    };
  };

  if (loading) {
    return (
      <div className="rsvp-manager">
        <div className="loading">Loading events...</div>
      </div>
    );
  }

  return (
    <div className="rsvp-manager">
      <div className="rsvp-header">
        <h2>🗳️ RSVP Management</h2>
        <p>Respond to event invitations and manage your attendance</p>
        {onClose && (
          <button className="close-btn" onClick={onClose}>×</button>
        )}
      </div>

      {error && (
        <div className="error-message">
          {error}
          <button onClick={() => setError(null)}>×</button>
        </div>
      )}

      <div className="rsvp-tabs">
        <button 
          className={`tab ${activeTab === 'upcoming' ? 'active' : ''}`}
          onClick={() => setActiveTab('upcoming')}
        >
          📅 Upcoming Events
        </button>
        <button 
          className={`tab ${activeTab === 'my-rsvps' ? 'active' : ''}`}
          onClick={() => setActiveTab('my-rsvps')}
        >
          📝 My RSVPs
        </button>
      </div>

      <div className="rsvp-content">
        {activeTab === 'upcoming' && (
          <div className="upcoming-events">
            {events.length === 0 ? (
              <div className="no-events">
                <p>No upcoming events found</p>
              </div>
            ) : (
              events.map(event => {
                const { date, time } = formatEventDate(event.event_date);
                const isSubmitting = submitting === event.id;
                
                return (
                  <div key={event.id} className="event-card">
                    <div className="event-header">
                      <h3>{event.title}</h3>
                      <div className="event-type">{event.event_type_name}</div>
                    </div>
                    
                    <div className="event-details">
                      <div className="detail">
                        <span className="label">📅 Date:</span>
                        <span>{date} at {time}</span>
                      </div>
                      
                      <div className="detail">
                        <span className="label">⚽ Team:</span>
                        <span>{event.team_name}</span>
                      </div>
                      
                      {event.venue_name && (
                        <div className="detail">
                          <span className="label">📍 Venue:</span>
                          <span>{event.venue_name}</span>
                        </div>
                      )}
                      
                      <div className="detail">
                        <span className="label">⏱️ Duration:</span>
                        <span>{event.duration_minutes} minutes</span>
                      </div>
                      
                      {event.max_players && (
                        <div className="detail">
                          <span className="label">👥 Capacity:</span>
                          <span>
                            {event.rsvp_summary?.attending || 0} / {event.max_players}
                            {event.rsvp_summary?.attending && event.rsvp_summary.attending >= event.max_players && 
                              <span className="full-indicator"> (Full)</span>
                            }
                          </span>
                        </div>
                      )}
                    </div>

                    {event.description && (
                      <div className="event-description">
                        <p>{event.description}</p>
                      </div>
                    )}

                    <div className="current-rsvp">
                      <span className="label">Your Status:</span>
                      <span 
                        className="status-badge"
                        style={{ 
                          backgroundColor: getStatusColor(event.my_rsvp_status || 'none'),
                          color: 'white'
                        }}
                      >
                        {getStatusDisplay(event.my_rsvp_status || 'none')}
                      </span>
                    </div>

                    <div className="rsvp-actions">
                      <button
                        className={`rsvp-btn attending ${event.my_rsvp_status === 'attending' ? 'selected' : ''}`}
                        onClick={() => handleRSVP(event.id, 'attending')}
                        disabled={isSubmitting}
                      >
                        {isSubmitting ? '...' : '✅ Attending'}
                      </button>
                      
                      <button
                        className={`rsvp-btn maybe ${event.my_rsvp_status === 'maybe' ? 'selected' : ''}`}
                        onClick={() => handleRSVP(event.id, 'maybe')}
                        disabled={isSubmitting}
                      >
                        {isSubmitting ? '...' : '❓ Maybe'}
                      </button>
                      
                      <button
                        className={`rsvp-btn not-attending ${event.my_rsvp_status === 'not_attending' ? 'selected' : ''}`}
                        onClick={() => handleRSVP(event.id, 'not_attending')}
                        disabled={isSubmitting}
                      >
                        {isSubmitting ? '...' : '❌ Can\'t Attend'}
                      </button>
                    </div>

                    {event.rsvp_summary && (
                      <div className="attendance-summary">
                        <small>
                          Responses: {event.rsvp_summary.attending} attending, {' '}
                          {event.rsvp_summary.maybe} maybe, {' '}
                          {event.rsvp_summary.not_attending} not attending
                        </small>
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        )}

        {activeTab === 'my-rsvps' && (
          <div className="my-rsvps">
            {rsvps.length === 0 ? (
              <div className="no-rsvps">
                <p>No RSVP history found</p>
              </div>
            ) : (
              rsvps.map(rsvp => {
                const { date, time } = formatEventDate(rsvp.event_date);
                
                return (
                  <div key={rsvp.id} className="rsvp-card">
                    <div className="rsvp-header">
                      <h3>{rsvp.event_title}</h3>
                      <span 
                        className="status-badge"
                        style={{ 
                          backgroundColor: getStatusColor(rsvp.status),
                          color: 'white'
                        }}
                      >
                        {getStatusDisplay(rsvp.status)}
                      </span>
                    </div>
                    
                    <div className="rsvp-details">
                      <div className="detail">
                        <span className="label">📅 Event Date:</span>
                        <span>{date} at {time}</span>
                      </div>
                      
                      <div className="detail">
                        <span className="label">⚽ Team:</span>
                        <span>{rsvp.team_name}</span>
                      </div>
                      
                      {rsvp.venue_name && (
                        <div className="detail">
                          <span className="label">📍 Venue:</span>
                          <span>{rsvp.venue_name}</span>
                        </div>
                      )}
                      
                      <div className="detail">
                        <span className="label">📝 Response Date:</span>
                        <span>{new Date(rsvp.response_date).toLocaleDateString()}</span>
                      </div>
                    </div>

                    {rsvp.notes && (
                      <div className="rsvp-notes">
                        <span className="label">Notes:</span>
                        <p>{rsvp.notes}</p>
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default RSVPManager;