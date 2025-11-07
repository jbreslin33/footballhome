import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import './RSVPWidget.css';

interface RSVPWidgetProps {
  eventId: string;
  currentStatus?: string;
  onStatusChange?: (newStatus: string) => void;
  showAttendanceCount?: boolean;
  compact?: boolean;
}

interface AttendanceSummary {
  attending: number;
  not_attending: number;
  maybe: number;
  total: number;
}

const RSVPWidget: React.FC<RSVPWidgetProps> = ({ 
  eventId, 
  currentStatus, 
  onStatusChange,
  showAttendanceCount = true,
  compact = false 
}) => {
  const { user } = useAuth();
  const [status, setStatus] = useState<string>(currentStatus || '');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [attendanceSummary, setAttendanceSummary] = useState<AttendanceSummary | null>(null);

  // Load current RSVP status
  useEffect(() => {
    const loadRSVP = async () => {
      try {
        const response = await api.get(`/rsvps/event/${eventId}`);
        setStatus(response.data.rsvp?.status || '');
      } catch (err: any) {
        // No RSVP found is okay
        if (err.response?.status !== 404) {
          console.error('Failed to load RSVP:', err);
        }
      }
    };

    if (eventId && !currentStatus) {
      loadRSVP();
    }
  }, [eventId, currentStatus]);

  // Load attendance summary
  useEffect(() => {
    const loadAttendance = async () => {
      if (!showAttendanceCount) return;
      
      try {
        const response = await api.get(`/rsvps/event/${eventId}/attendees`);
        const summary = response.data.summary;
        setAttendanceSummary(summary);
      } catch (err: any) {
        // Attendance data might not be available to all users
        console.log('Attendance summary not available');
      }
    };

    if (eventId && showAttendanceCount) {
      loadAttendance();
    }
  }, [eventId, showAttendanceCount, status]);

  const handleRSVP = async (newStatus: 'attending' | 'not_attending' | 'maybe') => {
    if (!user) return;
    
    try {
      setLoading(true);
      setError(null);
      
      if (status) {
        // Update existing RSVP
        await api.put(`/rsvps/${eventId}`, {
          status: newStatus
        });
      } else {
        // Create new RSVP
        await api.post('/rsvps', {
          event_id: eventId,
          status: newStatus
        });
      }
      
      setStatus(newStatus);
      if (onStatusChange) {
        onStatusChange(newStatus);
      }
      
    } catch (err: any) {
      console.error('Failed to update RSVP:', err);
      setError(err.response?.data?.error || 'Failed to update RSVP');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (statusValue: string) => {
    switch (statusValue) {
      case 'attending': return '#27ae60';
      case 'not_attending': return '#e74c3c';
      case 'maybe': return '#f39c12';
      default: return '#6c757d';
    }
  };

  const getStatusDisplay = (statusValue: string) => {
    switch (statusValue) {
      case 'attending': return compact ? '✅' : '✅ Attending';
      case 'not_attending': return compact ? '❌' : '❌ Not Attending';
      case 'maybe': return compact ? '❓' : '❓ Maybe';
      default: return compact ? '⏳' : '⏳ No Response';
    }
  };

  if (!user) {
    return (
      <div className={`rsvp-widget ${compact ? 'compact' : ''}`}>
        <div className="login-prompt">
          <small>Login to RSVP</small>
        </div>
      </div>
    );
  }

  return (
    <div className={`rsvp-widget ${compact ? 'compact' : ''}`}>
      {error && (
        <div className="rsvp-error">
          <small>{error}</small>
          <button onClick={() => setError(null)}>×</button>
        </div>
      )}
      
      {!compact && (
        <div className="rsvp-label">
          <span>Your RSVP:</span>
        </div>
      )}

      <div className="current-status">
        <span 
          className="status-indicator"
          style={{ 
            backgroundColor: getStatusColor(status),
            color: 'white'
          }}
        >
          {getStatusDisplay(status)}
        </span>
      </div>

      <div className="rsvp-buttons">
        <button
          className={`rsvp-btn attending ${status === 'attending' ? 'selected' : ''}`}
          onClick={() => handleRSVP('attending')}
          disabled={loading}
          title="I will attend"
        >
          {compact ? '✅' : '✅ Yes'}
        </button>
        
        <button
          className={`rsvp-btn maybe ${status === 'maybe' ? 'selected' : ''}`}
          onClick={() => handleRSVP('maybe')}
          disabled={loading}
          title="I might attend"
        >
          {compact ? '❓' : '❓ Maybe'}
        </button>
        
        <button
          className={`rsvp-btn not-attending ${status === 'not_attending' ? 'selected' : ''}`}
          onClick={() => handleRSVP('not_attending')}
          disabled={loading}
          title="I cannot attend"
        >
          {compact ? '❌' : '❌ No'}
        </button>
      </div>

      {showAttendanceCount && attendanceSummary && (
        <div className="attendance-count">
          <small>
            {attendanceSummary.attending} attending
            {attendanceSummary.maybe > 0 && `, ${attendanceSummary.maybe} maybe`}
          </small>
        </div>
      )}
    </div>
  );
};

export default RSVPWidget;