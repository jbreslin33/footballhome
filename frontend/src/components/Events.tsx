import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  Button,
  Alert,
  Chip,
  IconButton,
  Stack,
} from '@mui/material';
import {
  Add,
  Event as EventIcon,
  LocationOn,
  AccessTime,
  MoreVert,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { apiService, Event } from '../services/api';

const Events: React.FC = () => {
  const { isCoach } = useAuth();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [rsvpStatus, setRsvpStatus] = useState<{[eventId: string]: 'loading' | 'success' | 'error'}>({});

  useEffect(() => {
    loadEvents();
  }, []);

  const loadEvents = async () => {
    try {
      setLoading(true);
      const teamId = '550e8400-e29b-41d4-a716-446655440001'; // Default team ID
      const response = await apiService.getTeamEvents(teamId);
      
      console.log('Events API response:', response);
      
      if (response.success) {
        setEvents(response.events);
        setError('');
      } else {
        setError(response.error || 'Failed to load events');
      }
    } catch (err: any) {
      console.error('Load events error:', err);
      if (err.response?.status === 401) {
        setError('Authentication required. Please log in again.');
      } else if (err.response?.data?.error) {
        setError(err.response.data.error);
      } else {
        setError('Failed to load events. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const formatTime = (timeString: string) => {
    return new Date(`2000-01-01T${timeString}`).toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });
  };

  const getEventTypeColor = (eventType: string): "default" | "primary" | "secondary" | "success" | "warning" | "info" | "error" => {
    switch (eventType.toLowerCase()) {
      case 'match':
      case 'game':
        return 'error';
      case 'practice':
      case 'training':
        return 'primary';
      case 'meeting':
        return 'secondary';
      default:
        return 'default';
    }
  };

  if (loading) {
    return (
      <Container>
        <Box display="flex" justifyContent="center" mt={4}>
          <Typography>Loading events...</Typography>
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" gutterBottom>
          Upcoming Events
        </Typography>
        {isCoach && (
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => {
              // TODO: Implement create event functionality
              console.log('Create event clicked');
            }}
          >
            Create Event
          </Button>
        )}
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {events.length === 0 ? (
        <Box sx={{ textAlign: 'center', mt: 4 }}>
          <Typography variant="h6" color="textSecondary" gutterBottom>
            No events scheduled yet.
          </Typography>
          {isCoach && (
            <Button
              variant="contained"
              startIcon={<Add />}
              sx={{ mt: 2 }}
              onClick={() => {
                // TODO: Implement create event functionality
                console.log('Create first event clicked');
              }}
            >
              Create First Event
            </Button>
          )}
        </Box>
      ) : (
        <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 3 }}>
          {events.map((event) => (
              <Card elevation={2} sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                    <Typography variant="h6" component="h2" gutterBottom>
                      {event.title}
                    </Typography>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                      <Chip
                        label={event.event_type}
                        color={getEventTypeColor(event.event_type)}
                        size="small"
                        sx={{ mr: 1 }}
                      />
                      {isCoach && (
                        <IconButton size="small">
                          <MoreVert />
                        </IconButton>
                      )}
                    </Box>
                  </Box>

                  <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
                    {event.description}
                  </Typography>

                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                    <EventIcon sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                    <Typography variant="body2">
                      {formatDate(event.event_date)}
                    </Typography>
                  </Box>

                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                    <AccessTime sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                    <Typography variant="body2">
                      {formatTime(event.event_time)}
                    </Typography>
                  </Box>

                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    <LocationOn sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                    <Typography variant="body2">
                      {event.location}
                    </Typography>
                  </Box>

                  <Box sx={{ mt: 'auto', pt: 2 }}>
                    <Button
                      variant={rsvpStatus[event.id] === 'success' ? 'contained' : 'outlined'}
                      color={rsvpStatus[event.id] === 'success' ? 'success' : rsvpStatus[event.id] === 'error' ? 'error' : 'primary'}
                      fullWidth
                      disabled={rsvpStatus[event.id] === 'loading'}
                      onClick={async () => {
                        try {
                          setRsvpStatus(prev => ({ ...prev, [event.id]: 'loading' }));
                          const response = await apiService.rsvpEvent(event.id, 'yes');
                          if (response.success) {
                            setRsvpStatus(prev => ({ ...prev, [event.id]: 'success' }));
                            console.log('RSVP successful for event:', event.id);
                          } else {
                            setRsvpStatus(prev => ({ ...prev, [event.id]: 'error' }));
                            console.error('RSVP failed:', response);
                          }
                        } catch (error) {
                          setRsvpStatus(prev => ({ ...prev, [event.id]: 'error' }));
                          console.error('RSVP error:', error);
                        }
                      }}
                    >
                      {rsvpStatus[event.id] === 'loading' ? 'RSVPing...' : 
                       rsvpStatus[event.id] === 'success' ? 'RSVP\'d ✓' : 
                       rsvpStatus[event.id] === 'error' ? 'Failed' : 'RSVP'}
                    </Button>
                  </Box>
                </CardContent>
              </Card>
          ))}
        </Box>
      )}
    </Container>
  );
};

export default Events;