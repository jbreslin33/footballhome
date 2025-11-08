import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import RSVPWidget from './RSVPWidget';
import './ScheduleManager.css';

interface ScheduleEvent {
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

interface ScheduleManagerProps {
  onClose?: () => void;
}

const ScheduleManager: React.FC<ScheduleManagerProps> = ({ onClose }) => {
  const { user } = useAuth();
  const [events, setEvents] = useState<ScheduleEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'upcoming' | 'all' | 'past'>('upcoming');
  const [selectedMonth, setSelectedMonth] = useState<string>(() => {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  });

  useEffect(() => {
    loadEvents();
  }, [viewMode, selectedMonth]);

  const loadEvents = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const params: any = {
        limit: 100
      };

      if (viewMode === 'upcoming') {
        params.upcoming = true;
      } else if (viewMode === 'past') {
        params.past = true;
      } else if (viewMode === 'all') {
        // Get events for the selected month
        const year = selectedMonth.split('-')[0];
        const month = selectedMonth.split('-')[1];
        const startDate = `${year}-${month}-01`;
        const endDate = new Date(parseInt(year), parseInt(month), 0).toISOString().split('T')[0];
        params.start_date = startDate;
        params.end_date = endDate;
      }
      
      const response = await api.get('/events-simple', { params });
      setEvents(response.data.events || []);
    } catch (err: any) {
      console.error('Failed to load events:', err);
      setError('Failed to load schedule. Please try again.');
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
      }),
      dayOfWeek: date.toLocaleDateString('en-US', { weekday: 'long' }),
      shortDate: date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric' 
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

  const groupEventsByDate = (events: ScheduleEvent[]) => {
    const groups: { [key: string]: ScheduleEvent[] } = {};
    
    events.forEach(event => {
      const date = new Date(event.event_date);
      const dateKey = date.toISOString().split('T')[0]; // YYYY-MM-DD
      
      if (!groups[dateKey]) {
        groups[dateKey] = [];
      }
      groups[dateKey].push(event);
    });

    // Sort events within each date group by time
    Object.keys(groups).forEach(dateKey => {
      groups[dateKey].sort((a, b) => 
        new Date(a.event_date).getTime() - new Date(b.event_date).getTime()
      );
    });

    return groups;
  };

  const eventGroups = groupEventsByDate(events);
  const sortedDates = Object.keys(eventGroups).sort();

  if (loading) {
    return (
      <div className="schedule-manager">
        <div className="loading">Loading schedule...</div>
      </div>
    );
  }

  return (
    <div className="schedule-manager">
      <div className="schedule-header">
        <h2>📅 Team Schedule</h2>
        <p>View your complete event calendar</p>
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

      <div className="schedule-controls">
        <div className="view-modes">
          <button 
            className={`view-btn ${viewMode === 'upcoming' ? 'active' : ''}`}
            onClick={() => setViewMode('upcoming')}
          >
            🔜 Upcoming
          </button>
          <button 
            className={`view-btn ${viewMode === 'all' ? 'active' : ''}`}
            onClick={() => setViewMode('all')}
          >
            📅 Monthly
          </button>
          <button 
            className={`view-btn ${viewMode === 'past' ? 'active' : ''}`}
            onClick={() => setViewMode('past')}
          >
            📜 Past Events
          </button>
        </div>

        {viewMode === 'all' && (
          <div className="month-selector">
            <input
              type="month"
              value={selectedMonth}
              onChange={(e) => setSelectedMonth(e.target.value)}
              className="month-input"
            />
          </div>
        )}
      </div>

      <div className="schedule-content">
        {sortedDates.length === 0 ? (
          <div className="no-events">
            <p>
              {viewMode === 'upcoming' && 'No upcoming events found'}
              {viewMode === 'past' && 'No past events found'}
              {viewMode === 'all' && `No events found for ${selectedMonth}`}
            </p>
          </div>
        ) : (
          <div className="schedule-timeline">
            {sortedDates.map(dateKey => {
              const dayEvents = eventGroups[dateKey];
              const { dayOfWeek, shortDate } = formatEventDate(dayEvents[0].event_date);
              
              return (
                <div key={dateKey} className="schedule-day">
                  <div className="day-header">
                    <div className="day-info">
                      <div className="day-name">{dayOfWeek}</div>
                      <div className="day-date">{shortDate}</div>
                    </div>
                    <div className="events-count">
                      {dayEvents.length} event{dayEvents.length !== 1 ? 's' : ''}
                    </div>
                  </div>

                  <div className="day-events">
                    {dayEvents.map(event => {
                      const { time } = formatEventDate(event.event_date);
                      
                      return (
                        <div key={event.id} className="schedule-event">
                          <div className="event-time">
                            {time}
                          </div>
                          
                          <div className="event-details">
                            <div className="event-main">
                              <div className="event-title">
                                <span className="event-icon">
                                  {getEventTypeIcon(event.event_type_name)}
                                </span>
                                <span className="title">{event.title}</span>
                                <span className="event-type">{event.event_type_name}</span>
                              </div>
                              
                              <div className="event-meta">
                                <span className="team">🏆 {event.team_name}</span>
                                {event.venue_name && (
                                  <span className="venue">🏟️ {event.venue_name}</span>
                                )}
                                <span className="duration">⏱️ {event.duration_minutes}min</span>
                              </div>

                              {event.description && (
                                <div className="event-description">
                                  {event.description}
                                </div>
                              )}
                            </div>

                            {viewMode !== 'past' && (
                              <div className="event-rsvp">
                                <RSVPWidget 
                                  eventId={event.id}
                                  currentStatus={event.my_rsvp_status}
                                  showAttendanceCount={true}
                                  compact={true}
                                  onStatusChange={() => loadEvents()}
                                />
                              </div>
                            )}

                            {viewMode === 'past' && event.my_rsvp_status && (
                              <div className="past-status">
                                <span className={`status-badge ${event.my_rsvp_status}`}>
                                  {event.my_rsvp_status === 'attending' && '✅ Attended'}
                                  {event.my_rsvp_status === 'not_attending' && '❌ Did not attend'}
                                  {event.my_rsvp_status === 'maybe' && '❓ Maybe attended'}
                                </span>
                              </div>
                            )}
                          </div>
                        </div>
                      );
                    })}
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

export default ScheduleManager;