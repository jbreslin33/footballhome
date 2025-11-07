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
  attending_count?: number;
  not_attending_count?: number;
  maybe_count?: number;
  no_response_count?: number;
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
  const { login } = useAuth(); // Authentication context for token refresh
  const [activeTab, setActiveTab] = useState<'upcoming' | 'my-rsvps'>('upcoming');
  const [events, setEvents] = useState<Event[]>([]);
  const [rsvps, setRsvps] = useState<RSVP[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState<string | null>(null);

  // Temporary function to force token refresh
  const forceTokenRefresh = async () => {
    try {
      console.log('🔄 Forcing token refresh...');
      await login('jbreslin@footballhome.org', 'm13m13m1');
      console.log('✅ Token refreshed successfully!');
      setError(null);
      // Reload events after token refresh
      if (activeTab === 'upcoming') {
        loadUpcomingEvents();
      }
    } catch (err: any) {
      console.error('❌ Token refresh failed:', err);
      setError('Failed to refresh token: ' + err.message);
    }
  };

  // Load upcoming events that need RSVP
  const loadUpcomingEvents = async () => {
    console.log('📅 Loading upcoming events...');
    try {
      setLoading(true);
      
      // First get user's teams
      console.log('👥 Fetching user teams...');
      const teamsResponse = await api.get('/teams');
      const userTeams = teamsResponse.data.teams || [];
      console.log('👥 User teams:', userTeams.length, userTeams.map((t: any) => t.name));
      
      if (userTeams.length === 0) {
        setEvents([]);
        setError('You are not a member of any teams');
        return;
      }
      
      // Get events for all user's teams
      console.log('📊 Fetching events for each team...');
      const eventPromises = userTeams.map((team: any) => 
        api.get(`/events/team/${team.id}`, {
          params: {
            start_date: new Date().toISOString(),
            limit: 20
          }
        }).then(response => {
          console.log(`📊 Events for team ${team.name}:`, response.data.events?.length || 0);
          return {
            ...response,
            teamName: team.name
          };
        })
      );
      
      const eventResponses = await Promise.all(eventPromises);
      
      // Combine and add team names to events
      const allEvents = eventResponses.flatMap(response => 
        (response.data.events || []).map((event: any) => ({
          ...event,
          team_name: response.teamName || event.team_name
        }))
      );
      
      console.log('📊 Total combined events:', allEvents.length);
      console.log('📊 Events with RSVP status:', allEvents.map((e: any) => ({ id: e.id, title: e.title, rsvp: e.my_rsvp_status })));
      
      // Sort by event date
      allEvents.sort((a, b) => new Date(a.event_date).getTime() - new Date(b.event_date).getTime());
      
      setEvents(allEvents);
      console.log('✅ Events loaded successfully');
    } catch (err: any) {
      console.error('❌ Failed to load upcoming events:', err);
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
    console.log('🎯 RSVP handleRSVP called:', { eventId, status, notes });
    
    try {
      setSubmitting(eventId);
      console.log('📤 Submitting RSVP request...');
      
      const requestData = {
        event_id: eventId,
        status,
        notes
      };
      console.log('📝 Request payload:', requestData);
      console.log('📝 Current token:', localStorage.getItem('token') ? 'Token exists' : 'No token found');
      
      const response = await api.post('/rsvps', requestData);
      
      console.log('✅ RSVP request successful:', response.data);
      
      // Refresh the current view
      if (activeTab === 'upcoming') {
        console.log('🔄 Refreshing upcoming events...');
        loadUpcomingEvents();
      } else {
        console.log('🔄 Refreshing my RSVPs...');
        loadMyRSVPs();
      }
      
      console.log('🎉 RSVP process complete');
      
    } catch (err: any) {
      console.error('❌ Failed to save RSVP:', err);
      console.error('❌ Error details:', {
        message: err.message,
        response: err.response?.data,
        status: err.response?.status,
        config: err.config
      });
      console.error('❌ Full error response:', err.response);
      console.error('❌ Request config:', err.config);
      setError(err.response?.data?.error || err.response?.data?.message || 'Failed to save RSVP');
    } finally {
      setSubmitting(null);
      console.log('🏁 RSVP submission finished');
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
        <div style={{ marginBottom: '10px' }}>
          <button 
            onClick={forceTokenRefresh}
            style={{
              backgroundColor: '#f39c12',
              color: 'white',
              border: 'none',
              padding: '5px 10px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '12px',
              marginRight: '10px'
            }}
          >
            🔄 Refresh Token (Temp Fix)
          </button>
        </div>
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
                            {event.attending_count || 0} / {event.max_players}
                            {event.attending_count && event.attending_count >= event.max_players && 
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

                    <div className="attendance-summary">
                      <small>
                        Responses: {event.attending_count || 0} attending, {' '}
                        {event.maybe_count || 0} maybe, {' '}
                        {event.not_attending_count || 0} not attending
                      </small>
                    </div>
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