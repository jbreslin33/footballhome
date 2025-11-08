import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import './ProfileSettings.css';

interface UserProfile {
  id: string;
  name: string;
  email: string;
  phone?: string;
  emergency_contact?: string;
  emergency_phone?: string;
  date_of_birth?: string;
  address?: string;
  profile_photo?: string;
}

interface ProfileSettingsProps {
  onClose?: () => void;
}

const ProfileSettings: React.FC<ProfileSettingsProps> = ({ onClose }) => {
  const { user, updateUser } = useAuth();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'profile' | 'security' | 'notifications'>('profile');

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Get user profile data
      const response = await api.get('/auth/profile');
      setProfile(response.data.user);
    } catch (err: any) {
      console.error('Failed to load profile:', err);
      setError('Failed to load profile data');
    } finally {
      setLoading(false);
    }
  };

  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile) return;

    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      await api.put('/auth/profile', {
        name: profile.name,
        phone: profile.phone,
        emergency_contact: profile.emergency_contact,
        emergency_phone: profile.emergency_phone,
        date_of_birth: profile.date_of_birth,
        address: profile.address
      });

      setSuccess('Profile updated successfully!');
      
      // Update the user context with new profile data
      updateUser({
        name: profile.name,
        phone: profile.phone
      });
      
      setTimeout(() => setSuccess(null), 3000);
    } catch (err: any) {
      console.error('Failed to update profile:', err);
      setError(err.response?.data?.error || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handleInputChange = (field: keyof UserProfile, value: string) => {
    if (!profile) return;
    setProfile({ ...profile, [field]: value });
  };

  if (loading) {
    return (
      <div className="profile-settings">
        <div className="loading">Loading profile...</div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="profile-settings">
        <div className="error-message">Failed to load profile data</div>
      </div>
    );
  }

  return (
    <div className="profile-settings">
      <div className="settings-header">
        <h2>⚙️ Profile Settings</h2>
        <p>Manage your account information and preferences</p>
        {onClose && (
          <button className="close-btn" onClick={onClose}>×</button>
        )}
      </div>

      {error && (
        <div className="error-message">
          {error}
          <button onClick={() => setError(null)}>×</button>
        </div>
      )}

      {success && (
        <div className="success-message">
          {success}
          <button onClick={() => setSuccess(null)}>×</button>
        </div>
      )}

      <div className="settings-tabs">
        <button 
          className={`tab ${activeTab === 'profile' ? 'active' : ''}`}
          onClick={() => setActiveTab('profile')}
        >
          👤 Profile
        </button>
        <button 
          className={`tab ${activeTab === 'security' ? 'active' : ''}`}
          onClick={() => setActiveTab('security')}
        >
          🔒 Security
        </button>
        <button 
          className={`tab ${activeTab === 'notifications' ? 'active' : ''}`}
          onClick={() => setActiveTab('notifications')}
        >
          🔔 Notifications
        </button>
      </div>

      <div className="settings-content">
        {activeTab === 'profile' && (
          <form onSubmit={handleProfileUpdate} className="profile-form">
            <div className="form-section">
              <h3>Personal Information</h3>
              
              <div className="form-group">
                <label htmlFor="name">Full Name *</label>
                <input
                  type="text"
                  id="name"
                  value={profile.name}
                  onChange={(e) => handleInputChange('name', e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label htmlFor="email">Email Address</label>
                <input
                  type="email"
                  id="email"
                  value={profile.email}
                  disabled
                  className="disabled"
                />
                <small>Email cannot be changed. Contact administrator if needed.</small>
              </div>

              <div className="form-group">
                <label htmlFor="phone">Phone Number</label>
                <input
                  type="tel"
                  id="phone"
                  value={profile.phone || ''}
                  onChange={(e) => handleInputChange('phone', e.target.value)}
                  placeholder="(555) 123-4567"
                />
              </div>

              <div className="form-group">
                <label htmlFor="date_of_birth">Date of Birth</label>
                <input
                  type="date"
                  id="date_of_birth"
                  value={profile.date_of_birth || ''}
                  onChange={(e) => handleInputChange('date_of_birth', e.target.value)}
                />
              </div>

              <div className="form-group">
                <label htmlFor="address">Address</label>
                <textarea
                  id="address"
                  value={profile.address || ''}
                  onChange={(e) => handleInputChange('address', e.target.value)}
                  rows={3}
                  placeholder="Street address, city, state, zip code"
                />
              </div>
            </div>

            <div className="form-section">
              <h3>Emergency Contact</h3>
              
              <div className="form-group">
                <label htmlFor="emergency_contact">Emergency Contact Name</label>
                <input
                  type="text"
                  id="emergency_contact"
                  value={profile.emergency_contact || ''}
                  onChange={(e) => handleInputChange('emergency_contact', e.target.value)}
                  placeholder="Contact person's full name"
                />
              </div>

              <div className="form-group">
                <label htmlFor="emergency_phone">Emergency Contact Phone</label>
                <input
                  type="tel"
                  id="emergency_phone"
                  value={profile.emergency_phone || ''}
                  onChange={(e) => handleInputChange('emergency_phone', e.target.value)}
                  placeholder="(555) 123-4567"
                />
              </div>
            </div>

            <div className="form-actions">
              <button type="submit" className="primary-btn" disabled={saving}>
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
              {onClose && (
                <button type="button" className="secondary-btn" onClick={onClose}>
                  Cancel
                </button>
              )}
            </div>
          </form>
        )}

        {activeTab === 'security' && (
          <div className="security-section">
            <h3>🔒 Account Security</h3>
            <div className="security-item">
              <div className="security-info">
                <h4>Password</h4>
                <p>Change your account password</p>
              </div>
              <button className="secondary-btn" onClick={() => alert('Password change functionality would be implemented here')}>
                Change Password
              </button>
            </div>
            
            <div className="security-item">
              <div className="security-info">
                <h4>Two-Factor Authentication</h4>
                <p>Add an extra layer of security to your account</p>
              </div>
              <button className="secondary-btn" onClick={() => alert('2FA setup would be implemented here')}>
                Enable 2FA
              </button>
            </div>
            
            <div className="security-item">
              <div className="security-info">
                <h4>Active Sessions</h4>
                <p>Manage devices logged into your account</p>
              </div>
              <button className="secondary-btn" onClick={() => alert('Session management would be implemented here')}>
                View Sessions
              </button>
            </div>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="notifications-section">
            <h3>🔔 Notification Preferences</h3>
            
            <div className="notification-group">
              <h4>Event Notifications</h4>
              <div className="notification-item">
                <label>
                  <input type="checkbox" defaultChecked />
                  <span>New event invitations</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="checkbox" defaultChecked />
                  <span>Event reminders (24 hours before)</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="checkbox" defaultChecked />
                  <span>Event cancellations or changes</span>
                </label>
              </div>
            </div>

            <div className="notification-group">
              <h4>Team Communications</h4>
              <div className="notification-item">
                <label>
                  <input type="checkbox" defaultChecked />
                  <span>Team announcements</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="checkbox" defaultChecked />
                  <span>Coach messages</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="checkbox" />
                  <span>Team chat messages</span>
                </label>
              </div>
            </div>

            <div className="notification-group">
              <h4>Delivery Method</h4>
              <div className="notification-item">
                <label>
                  <input type="radio" name="delivery" defaultChecked />
                  <span>Email notifications</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="radio" name="delivery" />
                  <span>SMS notifications</span>
                </label>
              </div>
              <div className="notification-item">
                <label>
                  <input type="radio" name="delivery" />
                  <span>Both email and SMS</span>
                </label>
              </div>
            </div>

            <div className="form-actions">
              <button className="primary-btn" onClick={() => alert('Notification preferences would be saved here')}>
                Save Preferences
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProfileSettings;