import React from 'react';

const SystemAdmin: React.FC = () => {
  return (
    <div className="admin-section">
      <header className="admin-header">
        <h1>⚙️ System Administration</h1>
        <p>Manage the entire Football Home system</p>
      </header>

      <div className="admin-grid">
        <div className="admin-card">
          <h3>User Management</h3>
          <p>Manage all users across all clubs and organizations</p>
          <div className="admin-actions">
            <button className="primary-btn">View All Users</button>
            <button className="secondary-btn">Create User</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Club Management</h3>
          <p>Oversee all clubs and organizations in the system</p>
          <div className="admin-actions">
            <button className="primary-btn">View All Clubs</button>
            <button className="secondary-btn">Create Club</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>System Settings</h3>
          <p>Configure global system settings and permissions</p>
          <div className="admin-actions">
            <button className="primary-btn">System Config</button>
            <button className="secondary-btn">Role Management</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Database Management</h3>
          <p>Database maintenance, backups, and monitoring</p>
          <div className="admin-actions">
            <button className="primary-btn">DB Status</button>
            <button className="secondary-btn">Run Backup</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Reports & Analytics</h3>
          <p>System-wide reports and usage analytics</p>
          <div className="admin-actions">
            <button className="primary-btn">View Reports</button>
            <button className="secondary-btn">Export Data</button>
          </div>
        </div>

        <div className="admin-card">
          <h3>Venue Management</h3>
          <p>Manage Google Places venues and locations</p>
          <div className="admin-actions">
            <button className="primary-btn">View Venues</button>
            <button className="secondary-btn">Sync Google Places</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SystemAdmin;