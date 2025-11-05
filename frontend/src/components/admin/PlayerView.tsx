import React, { useState, useEffect } from 'react';
import { useAuth } from '../../contexts/AuthContext';

const PlayerView: React.FC = () => {
  const { user } = useAuth();
  const [events, setEvents] = useState<any[]>([]);
  const [rsvps, setRsvps] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  const handleEditProfile = () => {
    alert('Edit Profile functionality would open here');
  };

  const handleViewSchedule = () => {
    alert('Full schedule view would open here');
  };

  const handleManageRSVPs = () => {
    alert('RSVP management would open here');
  };

  const handleViewStats = () => {
    alert('Full statistics view would open here');
  };

  const handleViewMessages = () => {
    alert('Team messages view would open here');
  };

  const handleAccountSettings = () => {
    alert('Account settings would open here');
  };
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