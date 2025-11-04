import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const { user, logout } = useAuth();

  if (!user) return null;

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>Football Home</h1>
          <div className="user-info">
            <span>Welcome, {user.first_name}!</span>
            <button onClick={logout} className="logout-button">
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard-main">
        <div className="dashboard-grid">
          <div className="dashboard-card">
            <h2>My Events</h2>
            <p>View and manage your upcoming events, practices, and games.</p>
            <button className="card-button">View Events</button>
          </div>

          <div className="dashboard-card">
            <h2>My RSVPs</h2>
            <p>See your RSVP status for upcoming events and respond to new invitations.</p>
            <button className="card-button">View RSVPs</button>
          </div>

          <div className="dashboard-card">
            <h2>Team Schedule</h2>
            <p>Check your team's complete schedule and event calendar.</p>
            <button className="card-button">View Schedule</button>
          </div>

          <div className="dashboard-card">
            <h2>Profile Settings</h2>
            <p>Update your profile information and notification preferences.</p>
            <button className="card-button">Edit Profile</button>
          </div>
        </div>

        <div className="user-details">
          <h3>Account Information</h3>
          <div className="info-grid">
            <div className="info-item">
              <label>Name:</label>
              <span>{user.first_name} {user.last_name}</span>
            </div>
            <div className="info-item">
              <label>Email:</label>
              <span>{user.email}</span>
            </div>
            <div className="info-item">
              <label>Email Verified:</label>
              <span className={user.email_verified ? 'verified' : 'unverified'}>
                {user.email_verified ? '✅ Verified' : '⚠️ Not Verified'}
              </span>
            </div>
            <div className="info-item">
              <label>Roles:</label>
              <span>{user.roles?.join(', ') || 'No roles assigned'}</span>
            </div>
            <div className="info-item">
              <label>Member Since:</label>
              <span>{new Date(user.created_at).toLocaleDateString()}</span>
            </div>
            {user.last_login_at && (
              <div className="info-item">
                <label>Last Login:</label>
                <span>{new Date(user.last_login_at).toLocaleString()}</span>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;