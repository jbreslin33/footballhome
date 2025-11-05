import React from 'react';

const SoccerClubAdmin: React.FC = () => {
  return (
    <div className="admin-section">
      <header className="admin-header">
        <h1>⚽ Lighthouse 1893 SC</h1>
        <p>Manage the soccer club division</p>
      </header>

      <div className="admin-grid">
        <div className="admin-card">
          <h3>Club Overview</h3>
          <p>Soccer division of Lighthouse 1893</p>
          <div className="club-stats">
            <div className="stat">
              <span className="stat-number">4</span>
              <span className="stat-label">Teams</span>
            </div>
            <div className="stat">
              <span className="stat-number">45</span>
              <span className="stat-label">Players</span>
            </div>
            <div className="stat">
              <span className="stat-number">8</span>
              <span className="stat-label">Coaches</span>
            </div>
          </div>
        </div>

        <div className="admin-card">
          <h3>APSL League Management</h3>
          <p>Manage APSL league participation and standings</p>
          <div className="league-info">
            <div className="league-stat">
              <span className="label">Current Season:</span>
              <span className="value">2024/25</span>
            </div>
            <div className="league-stat">
              <span className="label">League:</span>
              <span className="value">APSL Division 1</span>
            </div>
            <div className="league-stat">
              <span className="label">Current Position:</span>
              <span className="value">3rd Place</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn">View Standings</button>
            <button className="secondary-btn">Submit Match Results</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Team Management</h3>
          <p>Manage all soccer teams under Lighthouse 1893 SC</p>
          <div className="teams-list">
            <div className="team-item">
              <span className="team-name">Lighthouse 1893 SC (First Team)</span>
              <span className="team-league">APSL Division 1</span>
            </div>
            <div className="team-item">
              <span className="team-name">Lighthouse Women's Club</span>
              <span className="team-league">Women's Premier</span>
            </div>
            <div className="team-item">
              <span className="team-name">Lighthouse Boys Club</span>
              <span className="team-league">Youth Division</span>
            </div>
            <div className="team-item">
              <span className="team-name">Lighthouse Old Timers</span>
              <span className="team-league">Veterans League</span>
            </div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn">Manage Teams</button>
            <button className="secondary-btn">Add New Team</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Schedule & Fixtures</h3>
          <p>Manage match schedules and training sessions</p>
          <div className="admin-actions">
            <button className="primary-btn">View Schedule</button>
            <button className="secondary-btn">Add Match</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Player Registration</h3>
          <p>Manage player registrations and transfers</p>
          <div className="admin-actions">
            <button className="primary-btn">View Players</button>
            <button className="secondary-btn">Register Player</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Club Finances</h3>
          <p>Soccer club budget, fees, and financial management</p>
          <div className="admin-actions">
            <button className="primary-btn">View Finances</button>
            <button className="secondary-btn">Manage Fees</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SoccerClubAdmin;