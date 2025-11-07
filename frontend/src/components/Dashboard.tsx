import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import AdminDashboard from './admin/AdminDashboard';
import RSVPManager from './RSVPManager';
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();
  const [showAdmin, setShowAdmin] = useState(false);
  const [showRSVPs, setShowRSVPs] = useState(false);

  if (!user) return null;

  // Check if user has admin roles
  const hasAdminRoles = user.roles && user.roles.length > 0;

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>Football Home</h1>
          <div className="user-info">
            <span>Welcome, {user.name || user.email}!</span>
            
            {/* Current Mode Indicator */}
            <div className="current-mode">
              <span className="mode-label">Current Mode:</span>
              <span className={`mode-badge ${showAdmin ? 'admin' : 'player'}`}>
                {showAdmin ? '⚙️ Admin Dashboard' : '👤 Player Dashboard'}
              </span>
            </div>

            {hasAdminRoles && (
              <button 
                onClick={() => setShowAdmin(!showAdmin)} 
                className="mode-switch-button"
                title={showAdmin ? 'Switch to Player Dashboard' : 'Switch to Admin Dashboard'}
              >
                Switch to {showAdmin ? '👤 Player' : '⚙️ Admin'}
              </button>
            )}
            <button onClick={logout} className="logout-button">
              Logout
            </button>
          </div>
        </div>
      </header>

      {showAdmin ? (
        <AdminDashboard />
      ) : showRSVPs ? (
        <div className="dashboard-main">
          <div className="current-view-header">
            <button 
              onClick={() => setShowRSVPs(false)}
              className="back-button"
              style={{ marginBottom: '1rem', padding: '0.5rem 1rem', backgroundColor: '#f0f0f0', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer' }}
            >
              ← Back to Dashboard
            </button>
            <div className="view-indicator">
              <span className="view-label">You are viewing:</span>
              <div className="view-badge player">
                📝 RSVP Management
              </div>
            </div>
          </div>
          <RSVPManager onClose={() => setShowRSVPs(false)} />
        </div>
      ) : (
        <main className="dashboard-main">
          <div className="current-view-header">
            <div className="view-indicator">
              <span className="view-label">You are viewing:</span>
              <div className="view-badge player">
                👤 Player Dashboard
              </div>
            </div>
            <div className="view-breadcrumb">
              Football Home → Player Dashboard
            </div>
          </div>
          
          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h2>My Events</h2>
              <p>View and manage your upcoming events, practices, and games.</p>
              <button className="card-button" onClick={() => alert('Events view would open here')}>View Events</button>
            </div>

            <div className="dashboard-card">
              <h2>My RSVPs</h2>
              <p>See your RSVP status for upcoming events and respond to new invitations.</p>
              <button className="card-button" onClick={() => setShowRSVPs(true)}>View RSVPs</button>
            </div>

            <div className="dashboard-card">
              <h2>Team Schedule</h2>
              <p>Check your team's complete schedule and event calendar.</p>
              <button className="card-button" onClick={() => alert('Schedule view would open here')}>View Schedule</button>
            </div>

            <div className="dashboard-card">
              <h2>Profile Settings</h2>
              <p>Update your profile information and notification preferences.</p>
              <button className="card-button" onClick={() => alert('Profile settings would open here')}>Edit Profile</button>
            </div>
          </div>

          <div className="user-details">
            <h3>Account Information</h3>
            <div className="info-grid">
              <div className="info-item">
                <label>Name:</label>
                <span>{user.name || user.email}</span>
              </div>
              <div className="info-item">
                <label>Email:</label>
                <span>{user.email}</span>
              </div>
              {user.phone && (
                <div className="info-item">
                  <label>Phone:</label>
                  <span>{user.phone}</span>
                </div>
              )}
              <div className="info-item">
                <label>Roles:</label>
                <span>{user.roles?.join(', ') || 'No roles assigned'}</span>
              </div>
              <div className="info-item">
                <label>Member Since:</label>
                <span>{new Date(user.created_at).toLocaleDateString()}</span>
              </div>
            </div>
          </div>
        </main>
      )}
    </div>
  );
};

export default Dashboard;