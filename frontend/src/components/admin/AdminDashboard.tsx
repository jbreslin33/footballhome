import React, { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import SystemAdmin from './SystemAdmin';
import ClubAdmin from './ClubAdmin';
import SoccerClubAdmin from './SoccerClubAdmin';
import TeamCoach from './TeamCoach';
import PlayerView from './PlayerView';
import './AdminDashboard.css';

interface AdminDashboardProps {}

const AdminDashboard: React.FC<AdminDashboardProps> = () => {
  const { user } = useAuth();
  const [activeRole, setActiveRole] = useState<string>('player');

  if (!user || !user.roles) {
    return <div>Loading user roles...</div>;
  }

  const availableRoles = user.roles;

  const roleComponents = {
    admin: { component: SystemAdmin, title: 'System Administration', icon: '⚙️' },
    club_owner: { component: ClubAdmin, title: 'Lighthouse 1893 Organization', icon: '🏛️' },
    soccer_admin: { component: SoccerClubAdmin, title: 'Lighthouse 1893 SC', icon: '⚽' },
    coach: { component: TeamCoach, title: 'Team Coach (APSL)', icon: '📋' },
    player: { component: PlayerView, title: 'Player Dashboard', icon: '👤' }
  };

  const ActiveComponent = roleComponents[activeRole as keyof typeof roleComponents]?.component || PlayerView;

  return (
    <div className="admin-dashboard">
      <div className="role-selector">
        <h2>Select Your Role</h2>
        <div className="role-tabs">
          {availableRoles.map((role: string) => {
            const roleKey = role === 'admin' ? 'admin' : 
                           role === 'club_owner' ? 'club_owner' :
                           role === 'coach' ? 'coach' : 'player';
            
            const roleInfo = roleComponents[roleKey as keyof typeof roleComponents];
            
            if (!roleInfo) return null;

            return (
              <button
                key={role}
                className={`role-tab ${activeRole === roleKey ? 'active' : ''}`}
                onClick={() => setActiveRole(roleKey)}
              >
                <span className="role-icon">{roleInfo.icon}</span>
                <span className="role-title">{roleInfo.title}</span>
              </button>
            );
          })}
        </div>
      </div>

      <div className="admin-content">
        <div className="page-header">
          <div className="current-role-indicator">
            <span className="role-label">You are viewing as:</span>
            <div className="active-role-badge">
              {roleComponents[activeRole as keyof typeof roleComponents]?.icon} {' '}
              {roleComponents[activeRole as keyof typeof roleComponents]?.title}
            </div>
          </div>
          <div className="breadcrumb">
            Football Home → Admin Dashboard → {roleComponents[activeRole as keyof typeof roleComponents]?.title}
          </div>
        </div>
        <ActiveComponent />
      </div>
    </div>
  );
};

export default AdminDashboard;