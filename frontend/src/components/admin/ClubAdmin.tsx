import React from 'react';

const ClubAdmin: React.FC = () => {
  return (
    <div className="admin-section">
      <header className="admin-header">
        <h1>🏛️ Lighthouse 1893 Organization</h1>
        <p>Manage the parent organization and all sub-clubs</p>
      </header>

      <div className="admin-grid">
        <div className="admin-card">
          <h3>Organization Overview</h3>
          <p>Parent organization founded in 1893</p>
          <div className="org-stats">
            <div className="stat">
              <span className="stat-number">4</span>
              <span className="stat-label">Sub-Clubs</span>
            </div>
            <div className="stat">
              <span className="stat-number">150+</span>
              <span className="stat-label">Total Members</span>
            </div>
          </div>
        </div>

        <div className="admin-card">
          <h3>Sub-Club Management</h3>
          <p>Manage all sports divisions under Lighthouse 1893</p>
          <div className="sub-clubs">
            <div className="sub-club">⚽ Lighthouse 1893 SC (Soccer)</div>
            <div className="sub-club">🏀 Lighthouse Basketball</div>
            <div className="sub-club">🥊 Lighthouse Boxing</div>
            <div className="sub-club">🏊 Lighthouse Swimming</div>
          </div>
          <div className="admin-actions">
            <button className="primary-btn">Manage Sub-Clubs</button>
            <button className="secondary-btn">Add New Sport</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Billing & Subscriptions</h3>
          <p>Organization-wide billing and financial management</p>
          <div className="admin-actions">
            <button className="primary-btn">View Billing</button>
            <button className="secondary-btn">Payment Settings</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Organization Settings</h3>
          <p>Manage branding, policies, and organization-wide settings</p>
          <div className="admin-actions">
            <button className="primary-btn">Edit Settings</button>
            <button className="secondary-btn">Update Branding</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Cross-Club Events</h3>
          <p>Organize events across multiple sports and clubs</p>
          <div className="admin-actions">
            <button className="primary-btn">View Events</button>
            <button className="secondary-btn">Create Event</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Member Management</h3>
          <p>Manage membership across all Lighthouse 1893 clubs</p>
          <div className="admin-actions">
            <button className="primary-btn">View Members</button>
            <button className="secondary-btn">Import Members</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ClubAdmin;