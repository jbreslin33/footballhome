import React, { useState } from 'react';
import {
  Container,
  Typography,
  Box,
  TextField,
  Button,
  Alert,
  Card,
  CardContent,
  FormControlLabel,
  Checkbox,
  InputAdornment,
  IconButton,
  Chip,
  Stack,
} from '@mui/material';
import { Edit, Save, Cancel, Visibility, VisibilityOff } from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { apiService } from '../services/api';

const Profile: React.FC = () => {
  const { user, updateUser } = useAuth();
  const [editing, setEditing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    name: user?.name || '',
    phone: user?.phone || '',
    emergency_contact: user?.emergency_contact || '',
    emergency_phone: user?.emergency_phone || '',
    password: '',
  });

  const handleEdit = () => {
    setEditing(true);
    setError('');
    setSuccess('');
    setFormData({
      name: user?.name || '',
      phone: user?.phone || '',
      emergency_contact: user?.emergency_contact || '',
      emergency_phone: user?.emergency_phone || '',
      password: '',
    });
  };

  const handleCancel = () => {
    setEditing(false);
    setError('');
    setSuccess('');
    setShowPassword(false);
  };

  const handleSave = async () => {
    setLoading(true);
    setError('');

    try {
      const updateData: any = {
        name: formData.name,
        phone: formData.phone,
        emergency_contact: formData.emergency_contact,
        emergency_phone: formData.emergency_phone,
      };

      // Only include password if it's provided
      if (formData.password.trim()) {
        updateData.password = formData.password;
      }

      const response = await apiService.updateProfile(updateData);
      
      if (response.success) {
        updateUser(updateData);
        setEditing(false);
        setSuccess('Profile updated successfully!');
        setShowPassword(false);
      } else {
        throw new Error(response.message || 'Failed to update profile');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  if (!user) {
    return (
      <Container>
        <Alert severity="error">No user data available</Alert>
      </Container>
    );
  }

  return (
    <Container maxWidth="md" sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Profile
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 2 }}>
          {success}
        </Alert>
      )}

      <Card elevation={3}>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <Typography variant="h6">
              Personal Information
            </Typography>
            {!editing && (
              <Button
                startIcon={<Edit />}
                variant="outlined"
                onClick={handleEdit}
              >
                Edit Profile
              </Button>
            )}
          </Box>

          <Stack spacing={3}>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="Role"
                value={user.primary_role || 'Player'}
                disabled
                InputProps={{
                  endAdornment: (
                    <Chip 
                      label={user.primary_role || 'Player'} 
                      color="primary" 
                      size="small" 
                    />
                  ),
                }}
              />

              <TextField
                fullWidth
                label="Email"
                value={user.email}
                disabled
              />
            </Box>

            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="Name"
                value={editing ? formData.name : (user.name || 'Not set')}
                disabled={!editing}
                onChange={(e) => handleInputChange('name', e.target.value)}
                required={editing}
              />

              <TextField
                fullWidth
                label="Phone"
                value={editing ? formData.phone : (user.phone || 'Not set')}
                disabled={!editing}
                onChange={(e) => handleInputChange('phone', e.target.value)}
              />
            </Box>

            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="Emergency Contact"
                value={editing ? formData.emergency_contact : (user.emergency_contact || 'Not set')}
                disabled={!editing}
                onChange={(e) => handleInputChange('emergency_contact', e.target.value)}
              />

              <TextField
                fullWidth
                label="Emergency Phone"
                value={editing ? formData.emergency_phone : (user.emergency_phone || 'Not set')}
                disabled={!editing}
                onChange={(e) => handleInputChange('emergency_phone', e.target.value)}
              />
            </Box>

            {editing && (
              <>
                <TextField
                  fullWidth
                  label="New Password (optional)"
                  type={showPassword ? 'text' : 'password'}
                  value={formData.password}
                  onChange={(e) => handleInputChange('password', e.target.value)}
                  placeholder="Leave blank to keep current password"
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          aria-label="toggle password visibility"
                          onClick={() => setShowPassword(!showPassword)}
                          onMouseDown={(e) => e.preventDefault()}
                          edge="end"
                        >
                          {showPassword ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />

                <FormControlLabel
                  control={
                    <Checkbox
                      checked={showPassword}
                      onChange={(e) => setShowPassword(e.target.checked)}
                      color="primary"
                    />
                  }
                  label="Show password"
                />
              </>
            )}

            {(user.position || user.jersey_number) && (
              <Box sx={{ display: 'flex', gap: 2 }}>
                {user.position && (
                  <TextField
                    fullWidth
                    label="Position"
                    value={user.position}
                    disabled
                  />
                )}

                {user.jersey_number && (
                  <TextField
                    fullWidth
                    label="Jersey Number"
                    value={user.jersey_number}
                    disabled
                  />
                )}
              </Box>
            )}
          </Stack>

          {editing && (
            <Box sx={{ mt: 3, display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
              <Button
                startIcon={<Cancel />}
                variant="outlined"
                onClick={handleCancel}
                disabled={loading}
              >
                Cancel
              </Button>
              <Button
                startIcon={<Save />}
                variant="contained"
                onClick={handleSave}
                disabled={loading || !formData.name.trim()}
              >
                {loading ? 'Saving...' : 'Save Changes'}
              </Button>
            </Box>
          )}
        </CardContent>
      </Card>
    </Container>
  );
};

export default Profile;