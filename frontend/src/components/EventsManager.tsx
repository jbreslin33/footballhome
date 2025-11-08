import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import RSVPWidget from './RSVPWidget';
import './EventsManager.css';

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
}

interface EventsManagerProps {
  onClose?: () => void;
}

const EventsManager: React.FC<EventsManagerProps> = ({ onClose }) => {
  const { user } = useAuth();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadEvents();
  }, []);

  const loadEvents = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Get upcoming events for the user
      const response = await api.get('/events-simple', {
        params: {
          upcoming: true,
          limit: 50
        }
      });
      
      setEvents(response.data.events || []);
    } catch (err: any) {
      console.error('Failed to load events:', err);
      setError('Failed to load events. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const formatEventDate = (dateString: string) => {
    const date = new Date(dateString);
    return {
      date: date.toLocaleDateString('en-US', { 
        weekday: 'short', 
        month: 'short', 
        day: 'numeric',
        year: 'numeric'
      }),
      time: date.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit' 
      })
    };
  };

  const getEventTypeIcon = (eventType: string) => {
    switch (eventType.toLowerCase()) {
      case 'practice':
      case 'training':
        return '🏃';
      case 'match':
      case 'game':
        return '⚽';
      case 'meeting':
        return '📋';
      default:
        return '📅';
    }
  };

  if (loading) {
    return (
      <div className="events-manager">
        <div className="loading">Loading events...</div>
      </div>
    );
  }

  return (
    <div className="events-manager">
      <div className="events-header">
        <h2>📅 My Events</h2>
        <p>View and respond to your upcoming events</p>
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

      <div className="events-content">
        {events.length === 0 ? (
          <div className="no-events">
            <p>No upcoming events found</p>
          </div>
        ) : (
          <div className="events-list">
            {events.map(event => {
              const { date, time } = formatEventDate(event.event_date);
              
              return (
                <div key={event.id} className="event-card">
                  <div className="event-header">
                    <div className="event-title">
                      <span className="event-icon">
                        {getEventTypeIcon(event.event_type_name)}
                      </span>
                      <h3>{event.title}</h3>
                    </div>
                    <div className="event-date">
                      <div className="date">{date}</div>
                      <div className="time">{time}</div>
                    </div>
                  </div>

                  <div className="event-details">
                    <div className="detail">
                      <span className="label">🏆 Team:</span>
                      <span>{event.team_name}</span>
                    </div>
                    
                    <div className="detail">
                      <span className="label">📍 Type:</span>
                      <span>{event.event_type_name}</span>
                    </div>
                    
                    {event.venue_name && (
                      <div className="detail">
                        <span className="label">🏟️ Venue:</span>
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

                  <div className="event-rsvp">
                    <RSVPWidget 
                      eventId={event.id}
                      currentStatus={event.my_rsvp_status}
                      showAttendanceCount={true}
                      compact={false}
                      onStatusChange={() => loadEvents()}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default EventsManager;