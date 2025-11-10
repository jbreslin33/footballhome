import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import './TrainingManager.css';

interface Practice {
  id: number;
  title: string;
  description?: string;
  event_date: string;
  event_time: string;
  venue?: string;
  team_name?: string;
  rsvp_status: string | null;
  rsvp_count: number;
}

const TrainingManager: React.FC = () => {
  console.log('TrainingManager component rendering...');
  const [practices, setPractices] = useState<Practice[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingPractice, setEditingPractice] = useState<Practice | null>(null);
  const [showConfirmCancel, setShowConfirmCancel] = useState<number | null>(null);
  const { token } = useAuth();
  console.log('TrainingManager token:', token ? 'exists' : 'null');

  useEffect(() => {
    fetchPractices();
  }, []);

  const fetchPractices = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch('/api/practices', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      console.log('Practices API Response:', response.status, response.statusText);

      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('Authentication required. Please log in again.');
        } else if (response.status === 403) {
          throw new Error('Access denied. You may not have permission to view practices.');
        } else {
          throw new Error(`Failed to fetch practices: ${response.status} ${response.statusText}`);
        }
      }

      const data = await response.json();
      console.log('Practices data:', data);
      
      setPractices(data.practices || []);
    } catch (err) {
      console.error('Error fetching practices:', err);
      setError(err instanceof Error ? err.message : 'Failed to load training sessions');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateStr: string) => {
    if (!dateStr) return 'Date TBD';
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const formatTime = (timeStr: string) => {
    if (!timeStr) return 'Time TBD';
    const [hours, minutes] = timeStr.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${minutes} ${ampm}`;
  };

  const getRSVPStatusClass = (status: string | null) => {
    switch (status) {
      case 'attending':
        return 'rsvp-attending';
      case 'not_attending':
        return 'rsvp-not-attending';
      case 'maybe':
        return 'rsvp-maybe';
      default:
        return 'rsvp-pending';
    }
  };

  const getRSVPStatusText = (status: string | null) => {
    switch (status) {
      case 'attending':
        return 'Attending';
      case 'not_attending':
        return 'Not Attending';
      case 'maybe':
        return 'Maybe';
      default:
        return 'No Response';
    }
  };

  const handleEditPractice = (practice: Practice) => {
    console.log('Edit practice:', practice.id, practice.title);
    setEditingPractice(practice);
  };

  const handleCancelPractice = async (practiceId: number) => {
    console.log('Cancel practice:', practiceId);
    
    try {
      const response = await fetch(`/api/practices/${practiceId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to cancel practice');
      }

      // Remove the practice from the local state
      setPractices(practices.filter(p => p.id !== practiceId));
      setShowConfirmCancel(null);
      
      // You could also show a success message here
      console.log('Practice cancelled successfully');
      
    } catch (err) {
      console.error('Error cancelling practice:', err);
      // You could show an error message here
    }
  };

  const closeEditModal = () => {
    setEditingPractice(null);
  };

  if (loading) {
    return (
      <div className="training-manager">
        <div className="loading-state">
          <p>Loading training sessions...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="training-manager">
        <div className="error-state">
          <p className="error-message">{error}</p>
          <button 
            className="secondary-btn" 
            onClick={fetchPractices}
            style={{ marginTop: '1rem' }}
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  console.log('TrainingManager rendering with practices:', practices.length, 'loading:', loading, 'error:', error);

  // Edit Modal
  if (editingPractice) {
    return (
      <div className="training-manager">
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h3>Edit Practice Session</h3>
              <button className="close-btn" onClick={closeEditModal}>×</button>
            </div>
            <div className="modal-body">
              <p><strong>Practice:</strong> {editingPractice.title}</p>
              <p><strong>Date:</strong> {formatDate(editingPractice.event_date)}</p>
              <p><strong>Time:</strong> {formatTime(editingPractice.event_time)}</p>
              <p><strong>Venue:</strong> {editingPractice.venue || 'TBD'}</p>
              <p><strong>Team:</strong> {editingPractice.team_name || 'TBD'}</p>
              <br />
              <p style={{color: '#666', fontStyle: 'italic'}}>
                Full edit functionality will be implemented here. For now, you can close this modal.
              </p>
            </div>
            <div className="modal-footer">
              <button className="secondary-btn" onClick={closeEditModal}>
                Close
              </button>
              <button className="primary-btn" onClick={closeEditModal}>
                Save Changes (Coming Soon)
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="training-manager">
      <div className="training-header">
        <h2>Training Sessions</h2>
        <p>Manage and view all practice sessions across your teams</p>
        <p style={{color: 'red', fontSize: '12px'}}>DEBUG: Component loaded, practices: {practices.length}, loading: {loading ? 'true' : 'false'}</p>
      </div>

      {practices.length === 0 ? (
        <div className="empty-state">
          <p>No training sessions found.</p>
          <p>Check that you're assigned to teams with scheduled practices.</p>
        </div>
      ) : (
        <div className="practices-list">
          {practices.map((practice) => (
              <div key={practice.id} className="practice-card">
              <div className="practice-header">
                <h3 className="practice-title">{practice.title || 'Practice Session'}</h3>
                {practice.team_name && <span className="team-badge">{practice.team_name}</span>}
              </div>              <div className="practice-details">
                <div className="practice-datetime">
                  <span className="practice-date">
                    📅 {formatDate(practice.event_date)}
                  </span>
                  <span className="practice-time">
                    🕐 {formatTime(practice.event_time)}
                  </span>
                </div>
                
                {practice.venue && (
                  <div className="practice-venue">
                    📍 {practice.venue}
                  </div>
                )}
                
                {practice.description && (
                  <div className="practice-description">
                    {practice.description}
                  </div>
                )}
              </div>
              
              <div className="practice-footer">
                <div className="rsvp-info">
                  <span className={`rsvp-status ${getRSVPStatusClass(practice.rsvp_status)}`}>
                    {getRSVPStatusText(practice.rsvp_status)}
                  </span>
                  <span className="rsvp-count">
                    {practice.rsvp_count} attending
                  </span>
                </div>
                
                <div className="practice-actions">
                  <button 
                    className="primary-btn btn-sm"
                    onClick={() => handleEditPractice(practice)}
                  >
                    Edit
                  </button>
                  <button 
                    className="secondary-btn btn-sm"
                    onClick={() => setShowConfirmCancel(practice.id)}
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Cancel Confirmation Dialog */}
      {showConfirmCancel && (
        <div className="modal-overlay">
          <div className="modal-content confirm-dialog">
            <div className="modal-header">
              <h3>Cancel Practice Session</h3>
            </div>
            <div className="modal-body">
              <p>Are you sure you want to cancel this practice session?</p>
              <p><strong>This action cannot be undone.</strong></p>
            </div>
            <div className="modal-footer">
              <button 
                className="secondary-btn" 
                onClick={() => setShowConfirmCancel(null)}
              >
                Keep Practice
              </button>
              <button 
                className="danger-btn" 
                onClick={() => handleCancelPractice(showConfirmCancel)}
              >
                Cancel Practice
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TrainingManager;