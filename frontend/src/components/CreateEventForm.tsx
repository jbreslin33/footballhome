import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
  Box,
} from '@mui/material';
import { apiService, Event } from '../services/api';

interface CreateEventFormProps {
  open: boolean;
  onClose: () => void;
  onEventCreated: (event: Event) => void;
}

const CreateEventForm: React.FC<CreateEventFormProps> = ({ open, onClose, onEventCreated }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    event_type_name: 'training',
    event_date: new Date().toISOString().split('T')[0], // YYYY-MM-DD format
    event_time: '18:00', // Default to 6 PM
    location: '',
    duration_minutes: 90,
    max_players: 20,
    team_id: '550e8400-e29b-41d4-a716-446655440001', // Default team ID
  });
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const eventTypes = [
    { value: 'training', label: 'Training Session' },
    { value: 'match', label: 'Match' },
    { value: 'meeting', label: 'Team Meeting' },
  ];

  const handleInputChange = (field: string) => (event: any) => {
    const value = event.target?.value ?? event;
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Format the date and time for the API
      const [hours, minutes] = formData.event_time.split(':').map(Number);
      const eventDateTime = new Date(formData.event_date);
      eventDateTime.setHours(hours);
      eventDateTime.setMinutes(minutes);

      const eventData = {
        ...formData,
        event_date: eventDateTime.toISOString(),
        duration_minutes: Number(formData.duration_minutes),
        max_players: Number(formData.max_players),
      };

      console.log('Creating event with data:', eventData);
      
      const response = await apiService.createEvent(eventData);
      
      if (response.success && response.event) {
        onEventCreated(response.event);
        onClose();
        // Reset form
        setFormData({
          title: '',
          description: '',
          event_type_name: 'training',
          event_date: new Date().toISOString().split('T')[0],
          event_time: '18:00',
          location: '',
          duration_minutes: 90,
          max_players: 20,
          team_id: '550e8400-e29b-41d4-a716-446655440001',
        });
      } else {
        setError('Failed to create event. Please try again.');
      }
    } catch (err: any) {
      console.error('Create event error:', err);
      if (err.response?.data?.error) {
        setError(err.response.data.error);
      } else {
        setError('Failed to create event. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (!loading) {
      onClose();
      setError('');
    }
  };

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
        <form onSubmit={handleSubmit}>
          <DialogTitle>Create New Event</DialogTitle>
          
          <DialogContent>
            {error && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {error}
              </Alert>
            )}
            
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
              <TextField
                fullWidth
                label="Event Title"
                value={formData.title}
                onChange={handleInputChange('title')}
                required
                placeholder="e.g., Weekly Training Session"
              />
              
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Description"
                value={formData.description}
                onChange={handleInputChange('description')}
                placeholder="Describe the event details..."
              />
              
              <Box sx={{ display: 'flex', gap: 2 }}>
                <FormControl fullWidth required>
                  <InputLabel>Event Type</InputLabel>
                  <Select
                    value={formData.event_type_name}
                    label="Event Type"
                    onChange={handleInputChange('event_type_name')}
                  >
                    {eventTypes.map((type) => (
                      <MenuItem key={type.value} value={type.value}>
                        {type.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
                
                <TextField
                  fullWidth
                  label="Location"
                  value={formData.location}
                  onChange={handleInputChange('location')}
                  required
                  placeholder="e.g., Main Field, Training Ground"
                />
              </Box>
              
              <Box sx={{ display: 'flex', gap: 2 }}>
                <TextField
                  fullWidth
                  type="date"
                  label="Date"
                  value={formData.event_date}
                  onChange={handleInputChange('event_date')}
                  required
                  InputLabelProps={{ shrink: true }}
                  inputProps={{ min: new Date().toISOString().split('T')[0] }}
                />
                
                <TextField
                  fullWidth
                  type="time"
                  label="Time"
                  value={formData.event_time}
                  onChange={handleInputChange('event_time')}
                  required
                  InputLabelProps={{ shrink: true }}
                />
              </Box>
              
              <Box sx={{ display: 'flex', gap: 2 }}>
                <TextField
                  fullWidth
                  type="number"
                  label="Duration (minutes)"
                  value={formData.duration_minutes}
                  onChange={handleInputChange('duration_minutes')}
                  inputProps={{ min: 15, max: 300 }}
                />
                
                <TextField
                  fullWidth
                  type="number"
                  label="Max Players"
                  value={formData.max_players}
                  onChange={handleInputChange('max_players')}
                  inputProps={{ min: 1, max: 50 }}
                />
              </Box>
            </Box>
          </DialogContent>
          
          <DialogActions sx={{ px: 3, pb: 2 }}>
            <Button onClick={handleClose} disabled={loading}>
              Cancel
            </Button>
            <Button 
              type="submit" 
              variant="contained"
              disabled={loading || !formData.title || !formData.location}
            >
              {loading ? 'Creating...' : 'Create Event'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>
  );
};

export default CreateEventForm;