import React, { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import RSVPManager from '../RSVPManager';
import EventsManager from '../EventsManager';
import ScheduleManager from '../ScheduleManager';
import ProfileSettings from '../ProfileSettings';
import StatsManager from '../StatsManager';

const PlayerView: React.FC = () => {
  const { user } = useAuth();
  const [activeView, setActiveView] = useState<'dashboard' | 'rsvp-manager' | 'events-manager' | 'schedule-manager' | 'profile-settings' | 'stats-manager' | 'messages-placeholder'>('dashboard');

  const handleEditProfile = () => {
    setActiveView('profile-settings');
  };

  const handleViewSchedule = () => {
    setActiveView('schedule-manager');
  };

  const handleManageRSVPs = () => {
    setActiveView('rsvp-manager');
  };

  const handleViewStats = () => {
    setActiveView('stats-manager');
  };

  const handleViewMessages = () => {
    setActiveView('messages-placeholder');
  };

  const handleAccountSettings = () => {
    setActiveView('profile-settings');
  };

  const handleViewEvents = () => {
    setActiveView('events-manager');
  };

  // Show specific views based on activeView
  if (activeView === 'rsvp-manager') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>📝 RSVP Management</h1>
          <p>Manage your event responses and attendance</p>
        </header>
        
        <RSVPManager onClose={() => setActiveView('dashboard')} />
      </div>
    );
  }

  if (activeView === 'events-manager') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>📅 My Events</h1>
          <p>View and manage your upcoming events</p>
        </header>
        
        <EventsManager onClose={() => setActiveView('dashboard')} />
      </div>
    );
  }

  if (activeView === 'schedule-manager') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>� Team Schedule</h1>
          <p>View your complete team schedule</p>
        </header>
        
        <ScheduleManager onClose={() => setActiveView('dashboard')} />
      </div>
    );
  }

  if (activeView === 'profile-settings') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>⚙️ Profile Settings</h1>
          <p>Manage your account and preferences</p>
        </header>
        
        <ProfileSettings onClose={() => setActiveView('dashboard')} />
      </div>
    );
  }

  if (activeView === 'stats-manager') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>📊 My Statistics</h1>
          <p>View your performance statistics</p>
        </header>
        
        <StatsManager onClose={() => setActiveView('dashboard')} />
      </div>
    );
  }

  if (activeView === 'messages-placeholder') {
    return (
      <div className="admin-section">
        <header className="admin-header">
          <button 
            className="back-btn"
            onClick={() => setActiveView('dashboard')}
            style={{ marginRight: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
          >
            ← Back to Dashboard
          </button>
          <h1>💬 Team Messages</h1>
          <p>Team communication system</p>
        </header>
        
        <div style={{ padding: '2rem', backgroundColor: 'white', borderRadius: '8px', margin: '2rem', textAlign: 'center' }}>
          <h3>📧 Team Messages</h3>
          <p>Team messaging functionality will be implemented here.</p>
          <p>Features will include:</p>
          <ul style={{ textAlign: 'left', maxWidth: '400px', margin: '0 auto' }}>
            <li>Team announcements</li>
            <li>Direct messages between players and coaches</li>
            <li>Group chat functionality</li>
            <li>Message notifications</li>
            <li>File sharing capabilities</li>
          </ul>
          <button 
            onClick={() => setActiveView('dashboard')}
            style={{ marginTop: '2rem', padding: '0.75rem 2rem', backgroundColor: '#0066cc', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer' }}
          >
            Back to Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-section">
      <header className="admin-header">
        <h1>👤 Player Dashboard</h1>
        <p>Your personal Football Home experience</p>
      </header>

      <div className="admin-grid">
        <div className="admin-card">
          <h3>My Profile</h3>
          <p>Personal information and player details</p>
          <div className="player-info">
            <div className="player-stat">
              <span className="label">Name:</span>
              <span className="value">{user?.name || 'Not set'}</span>
            </div>
            <div className="player-stat">
              <span className="label">Email:</span>
              <span className="value">{user?.email}</span>
            </div>
            <div className="player-stat">
              <span className="label">Phone:</span>
              <span className="value">{user?.phone || 'Not set'}</span>
            </div>
            <div className="player-stat">
              <span className="label">Roles:</span>
              <span className="value">{user?.roles?.join(', ') || 'None'}</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleEditProfile}>Edit Profile</button>
            <button className="secondary-btn" onClick={handleEditProfile}>Update Photo</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>My Schedule</h3>
          <p>Upcoming training sessions and matches</p>
          <div className="schedule-list">
            <div className="schedule-item">
              <span className="event-type">Training</span>
              <span className="event-date">Nov 7, 2025 - 7:00 PM</span>
              <span className="event-venue">Lighthouse Field</span>
            </div>
            <div className="schedule-item">
              <span className="event-type">Match</span>
              <span className="event-date">Nov 10, 2025 - 3:00 PM</span>
              <span className="event-venue">Phoenix Stadium (Away)</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleViewSchedule}>View Full Schedule</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>RSVP Status</h3>
          <p>Respond to upcoming events and view your attendance</p>
          <div className="rsvp-list">
            <div className="rsvp-item">
              <span className="event">Training - Nov 7</span>
              <span className="status confirmed">✅ Confirmed</span>
            </div>
            <div className="rsvp-item">
              <span className="event">Match - Nov 10</span>
              <span className="status pending">⏳ Pending</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleManageRSVPs}>Manage RSVPs</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>My Statistics</h3>
          <p>Personal performance stats and records</p>
          <div className="player-stats">
            <div className="stat">
              <span className="stat-number">12</span>
              <span className="stat-label">Matches Played</span>
            </div>
            <div className="stat">
              <span className="stat-number">3</span>
              <span className="stat-label">Goals</span>
            </div>
            <div className="stat">
              <span className="stat-number">5</span>
              <span className="stat-label">Assists</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleViewStats}>View Full Stats</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Team Communications</h3>
          <p>Messages from coaches and team announcements</p>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleViewMessages}>View Messages</button>
            <button className="secondary-btn" onClick={handleViewMessages}>Team Chat</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Settings</h3>
          <p>Manage your account and notification preferences</p>
          <div className="admin-actions">
            <button className="primary-btn" onClick={handleAccountSettings}>Account Settings</button>
            <button className="secondary-btn" onClick={handleAccountSettings}>Notifications</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PlayerView;