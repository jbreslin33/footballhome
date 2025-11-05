import React from 'react';

const TeamCoach: React.FC = () => {
  return (
    <div className="admin-section">
      <header className="admin-header">
        <h1>📋 Team Coach Dashboard</h1>
        <p>Lighthouse 1893 SC - APSL Division 1</p>
      </header>

      <div className="admin-grid">
        <div className="admin-card">
          <h3>Team Overview</h3>
          <p>First Team - APSL Division 1</p>
          <div className="team-stats">
            <div className="stat">
              <span className="stat-number">22</span>
              <span className="stat-label">Squad Size</span>
            </div>
            <div className="stat">
              <span className="stat-number">12</span>
              <span className="stat-label">Matches Played</span>
            </div>
            <div className="stat">
              <span className="stat-number">8-2-2</span>
              <span className="stat-label">W-D-L Record</span>
            </div>
          </div>
        </div>

        <div className="admin-card">
          <h3>Squad Management</h3>
          <p>Manage team roster, positions, and player assignments</p>
          <div className="admin-actions">
            <button className="primary-btn">View Squad</button>
            <button className="secondary-btn">Set Formation</button>
            <button className="secondary-btn">Injury List</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Training Sessions</h3>
          <p>Schedule and manage practice sessions</p>
          <div className="training-schedule">
            <div className="training-item">
              <span className="training-day">Tuesday</span>
              <span className="training-time">7:00 PM - 9:00 PM</span>
              <span className="training-venue">Lighthouse Field</span>
            </div>
            <div className="training-item">
              <span className="training-day">Thursday</span>
              <span className="training-time">7:00 PM - 9:00 PM</span>
              <span className="training-venue">Lighthouse Field</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn">Manage Training</button>
            <button className="secondary-btn">Add Session</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Match Management</h3>
          <p>Upcoming matches and team selection</p>
          <div className="next-match">
            <div className="match-info">
              <span className="opponent">vs. Phoenix FC</span>
              <span className="match-date">Nov 10, 2025 - 3:00 PM</span>
              <span className="venue">Away - Phoenix Stadium</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn">Team Selection</button>
            <button className="secondary-btn">Match Prep</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Player Performance</h3>
          <p>Track player stats, fitness, and development</p>
          <div className="admin-actions">
            <button className="primary-btn">Player Stats</button>
            <button className="secondary-btn">Fitness Reports</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Communications</h3>
          <p>Send messages to players and manage team communications</p>
          <div className="admin-actions">
            <button className="primary-btn">Team Messages</button>
            <button className="secondary-btn">Send Notice</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TeamCoach;