import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import Login from './Login';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireRoles?: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ 
  children, 
  requireRoles = [] 
}) => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading...</p>
      </div>
    );
  }

  if (!user) {
    return <Login />;
  }

  // Check if user has required roles
  if (requireRoles.length > 0) {
    const userRoles = user.roles || [];
    const hasRequiredRole = requireRoles.some(role => userRoles.includes(role));
    
    if (!hasRequiredRole) {
      return (
        <div className="access-denied">
          <h2>Access Denied</h2>
          <p>You don't have permission to view this page.</p>
          <p>Required roles: {requireRoles.join(', ')}</p>
          <p>Your roles: {userRoles.join(', ') || 'None'}</p>
        </div>
      );
    }
  }

  return <>{children}</>;
};

export default ProtectedRoute;