import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import AdminDashboard from './admin/AdminDashboard';
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();
  const [showAdmin, setShowAdmin] = useState(false);

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
            {hasAdminRoles && (
              <button 
                onClick={() => setShowAdmin(!showAdmin)} 
                className="admin-toggle-button"
              >
                {showAdmin ? 'Player View' : 'Admin View'}
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
      ) : (
        <main className="dashboard-main">
          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h2>My Events</h2>
              <p>View and manage your upcoming events, practices, and games.</p>
              <button className="card-button" onClick={() => alert('Events view would open here')}>View Events</button>
            </div>

            <div className="dashboard-card">
              <h2>My RSVPs</h2>
              <p>See your RSVP status for upcoming events and respond to new invitations.</p>
              <button className="card-button" onClick={() => alert('RSVPs view would open here')}>View RSVPs</button>
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