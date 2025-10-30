import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
  Chip,
} from '@mui/material';
import { Logout, Person, Event, Dashboard } from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

const NavBar: React.FC = () => {
  const { user, logout, isCoach } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    await logout();
  };

  const isActive = (path: string) => location.pathname === path;

  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6" component="div" sx={{ mr: 4 }}>
          ⚽ Football Home
        </Typography>
        
        <Box sx={{ flexGrow: 1, display: 'flex', gap: 1 }}>
          <Button
            color="inherit"
            startIcon={<Event />}
            onClick={() => navigate('/events')}
            variant={isActive('/events') ? 'outlined' : 'text'}
            sx={{ color: 'white', borderColor: 'white' }}
          >
            Events
          </Button>
          
          <Button
            color="inherit"
            startIcon={<Person />}
            onClick={() => navigate('/profile')}
            variant={isActive('/profile') ? 'outlined' : 'text'}
            sx={{ color: 'white', borderColor: 'white' }}
          >
            Profile
          </Button>
          
          {isCoach && (
            <Button
              color="inherit"
              startIcon={<Dashboard />}
              onClick={() => {
                // TODO: Implement coach dashboard
                console.log('Coach dashboard clicked');
              }}
              variant="text"
              sx={{ color: 'white' }}
            >
              Dashboard
            </Button>
          )}
        </Box>
        
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Person />
            <Typography variant="body2">
              {user?.name || user?.email}
            </Typography>
            <Chip 
              label={user?.primary_role || 'Player'} 
              color={isCoach ? 'secondary' : 'default'}
              size="small" 
            />
          </Box>
          
          <Button
            color="inherit"
            onClick={handleLogout}
            startIcon={<Logout />}
          >
            Logout
          </Button>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default NavBar;