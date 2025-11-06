import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import './PracticeForm.css';

interface Venue {
  id: string;
  name: string;
  address: string;
}

interface Team {
  id: string;
  name: string;
}

interface EventType {
  id: string;
  name: string;
  display_name: string;
  category: string;
  default_duration: number;
}

interface PracticeFormData {
  title: string;
  description: string;
  event_date: string;
  event_time: string;
  duration_minutes: number;
  venue_id: string;
  team_id: string;
  event_type_id: string;
  max_players: number | '';
  // Practice-specific fields
  focus_areas: string[];
  drill_plan: string;
  equipment_needed: string[];
  fitness_focus: string;
  skill_level: string;
  weather_dependent: boolean;
  indoor_alternative_location: string;
  notes: string;
}

interface PracticeFormProps {
  onSuccess?: () => void;
  onCancel?: () => void;
}

const PracticeForm: React.FC<PracticeFormProps> = ({ onSuccess, onCancel }) => {
  const { user, token } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [venues, setVenues] = useState<Venue[]>([]);
  
  // Debug user authentication
  useEffect(() => {
    console.log('👤 User authentication status:', {
      isAuthenticated: !!user,
      userId: user?.id,
      userEmail: user?.email
    });
  }, [user]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [eventTypes, setEventTypes] = useState<EventType[]>([]);
  
  const [formData, setFormData] = useState<PracticeFormData>({
    title: '',
    description: '',
    event_date: '',
    event_time: '',
    duration_minutes: 90,
    venue_id: '',
    team_id: '',
    event_type_id: '',
    max_players: '',
    focus_areas: [],
    drill_plan: '',
    equipment_needed: [],
    fitness_focus: '',
    skill_level: 'intermediate',
    weather_dependent: true,
    indoor_alternative_location: '',
    notes: ''
  });

  // Load initial data
  useEffect(() => {
    const loadData = async () => {
      try {
        console.log('🔄 Loading practice form data...');
        console.log('👤 Current user:', user);
        console.log('🔑 Current token:', token ? 'Present' : 'Not present');
        console.log('🌐 API service configured with base URL: /api');
        
        // Load venues, teams, and event types
        const [venuesResponse, teamsResponse, eventTypesResponse] = await Promise.all([
          api.get('/venues'),
          api.get('/teams'),
          api.get('/events/types?category=practice')
        ]);

        console.log('📊 API Responses:', {
          venues: venuesResponse.data.venues?.length || 0,
          teams: teamsResponse.data.teams?.length || 0,
          eventTypes: eventTypesResponse.data.event_types?.length || 0
        });

        setVenues(venuesResponse.data.venues || []);
        setTeams(teamsResponse.data.teams || []);
        setEventTypes(eventTypesResponse.data.event_types || []);

        console.log('✅ Practice form data loaded successfully');

        // Set default event type to training if available
        const trainingType = eventTypesResponse.data.event_types?.find((type: EventType) => type.name === 'training');
        if (trainingType) {
          setFormData(prev => ({
            ...prev,
            event_type_id: trainingType.id,
            duration_minutes: trainingType.default_duration
          }));
        }

      } catch (error) {
        console.error('❌ Failed to load form data:', error);
        if (error instanceof Error) {
          console.error('Error details:', {
            message: error.message,
            response: (error as any).response?.data,
            status: (error as any).response?.status
          });
        }
        setError('Failed to load form data');
      }
    };

    loadData();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    
    if (type === 'checkbox') {
      const checkbox = e.target as HTMLInputElement;
      setFormData(prev => ({
        ...prev,
        [name]: checkbox.checked
      }));
    } else if (type === 'number') {
      setFormData(prev => ({
        ...prev,
        [name]: value === '' ? '' : parseInt(value)
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };

  const handleArrayChange = (name: 'focus_areas' | 'equipment_needed', value: string) => {
    const items = value.split(',').map(item => item.trim()).filter(item => item.length > 0);
    setFormData(prev => ({
      ...prev,
      [name]: items
    }));
  };

  const handleEventTypeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const eventTypeId = e.target.value;
    const eventType = eventTypes.find(type => type.id === eventTypeId);
    
    setFormData(prev => ({
      ...prev,
      event_type_id: eventTypeId,
      duration_minutes: eventType?.default_duration || 90
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Combine date and time
      const eventDateTime = new Date(`${formData.event_date}T${formData.event_time}`);
      
      // Prepare the practice data
      const practiceData = {
        // Event fields
        team_id: formData.team_id,
        event_type_id: formData.event_type_id,
        title: formData.title,
        description: formData.description,
        event_date: eventDateTime.toISOString(),
        venue_id: formData.venue_id || null,
        duration_minutes: formData.duration_minutes,
        max_players: formData.max_players || null,
        
        // Practice-specific fields
        focus_areas: formData.focus_areas,
        drill_plan: formData.drill_plan,
        equipment_needed: formData.equipment_needed,
        fitness_focus: formData.fitness_focus,
        skill_level: formData.skill_level,
        weather_dependent: formData.weather_dependent,
        indoor_alternative_location: formData.indoor_alternative_location,
        notes: formData.notes
      };

      console.log('🚀 Submitting practice data:', practiceData);
      const response = await api.post('/practices', practiceData);
      console.log('✅ Practice created successfully:', response.data);
      
      setSuccess(true);
      
      // Redirect after a brief success message
      setTimeout(() => {
        if (onSuccess) {
          onSuccess();
        }
      }, 2000);
    } catch (error: any) {
      console.error('Failed to create practice:', error);
      setError(error.response?.data?.error || 'Failed to create practice session');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="practice-form-container">
      <div className="practice-form">
        <header className="form-header">
          <h2>🏃‍♂️ Schedule Practice Session</h2>
          <p>Create a new training session for your team</p>
        </header>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {success && (
          <div className="success-message">
            ✅ Practice session created successfully! Redirecting...
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Basic Information */}
          <div className="form-section">
            <h3>Basic Information</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="title">Practice Title *</label>
                <input
                  type="text"
                  id="title"
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  required
                  placeholder="e.g., Weekly Training Session"
                />
              </div>

              <div className="form-group">
                <label htmlFor="team_id">Team *</label>
                <select
                  id="team_id"
                  name="team_id"
                  value={formData.team_id}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select a team</option>
                  {teams.map(team => (
                    <option key={team.id} value={team.id}>
                      {team.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="description">Description</label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows={3}
                placeholder="Brief description of the practice session"
              />
            </div>
          </div>

          {/* Date, Time & Location */}
          <div className="form-section">
            <h3>Schedule & Location</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="event_date">Date *</label>
                <input
                  type="date"
                  id="event_date"
                  name="event_date"
                  value={formData.event_date}
                  onChange={handleChange}
                  required
                  min={new Date().toISOString().split('T')[0]}
                />
              </div>

              <div className="form-group">
                <label htmlFor="event_time">Time *</label>
                <input
                  type="time"
                  id="event_time"
                  name="event_time"
                  value={formData.event_time}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="form-group">
                <label htmlFor="duration_minutes">Duration (minutes) *</label>
                <input
                  type="number"
                  id="duration_minutes"
                  name="duration_minutes"
                  value={formData.duration_minutes}
                  onChange={handleChange}
                  required
                  min="15"
                  max="300"
                />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="event_type_id">Practice Type *</label>
                <select
                  id="event_type_id"
                  name="event_type_id"
                  value={formData.event_type_id}
                  onChange={handleEventTypeChange}
                  required
                >
                  <option value="">Select practice type</option>
                  {eventTypes.map(type => (
                    <option key={type.id} value={type.id}>
                      {type.display_name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="venue_id">Venue</label>
                <select
                  id="venue_id"
                  name="venue_id"
                  value={formData.venue_id}
                  onChange={handleChange}
                >
                  <option value="">Select a venue</option>
                  {venues.map(venue => (
                    <option key={venue.id} value={venue.id}>
                      {venue.name} - {venue.address}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="max_players">Maximum Players</label>
              <input
                type="number"
                id="max_players"
                name="max_players"
                value={formData.max_players}
                onChange={handleChange}
                min="1"
                max="50"
                placeholder="Leave empty for no limit"
              />
            </div>
          </div>

          {/* Practice Details */}
          <div className="form-section">
            <h3>Practice Details</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="skill_level">Skill Level</label>
                <select
                  id="skill_level"
                  name="skill_level"
                  value={formData.skill_level}
                  onChange={handleChange}
                >
                  <option value="beginner">Beginner</option>
                  <option value="intermediate">Intermediate</option>
                  <option value="advanced">Advanced</option>
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="fitness_focus">Fitness Focus</label>
                <select
                  id="fitness_focus"
                  name="fitness_focus"
                  value={formData.fitness_focus}
                  onChange={handleChange}
                >
                  <option value="">Select focus</option>
                  <option value="endurance">Endurance</option>
                  <option value="strength">Strength</option>
                  <option value="agility">Agility</option>
                  <option value="speed">Speed</option>
                  <option value="flexibility">Flexibility</option>
                </select>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="focus_areas">Focus Areas (comma-separated)</label>
              <input
                type="text"
                id="focus_areas"
                name="focus_areas"
                value={formData.focus_areas.join(', ')}
                onChange={(e) => handleArrayChange('focus_areas', e.target.value)}
                placeholder="e.g., passing, shooting, defense, set pieces"
              />
            </div>

            <div className="form-group">
              <label htmlFor="equipment_needed">Equipment Needed (comma-separated)</label>
              <input
                type="text"
                id="equipment_needed"
                name="equipment_needed"
                value={formData.equipment_needed.join(', ')}
                onChange={(e) => handleArrayChange('equipment_needed', e.target.value)}
                placeholder="e.g., cones, balls, bibs, goals"
              />
            </div>

            <div className="form-group">
              <label htmlFor="drill_plan">Drill Plan</label>
              <textarea
                id="drill_plan"
                name="drill_plan"
                value={formData.drill_plan}
                onChange={handleChange}
                rows={4}
                placeholder="Detailed practice plan and drills to be executed"
              />
            </div>
          </div>

          {/* Weather & Backup */}
          <div className="form-section">
            <h3>Weather & Backup Plans</h3>
            
            <div className="form-group checkbox-group">
              <label>
                <input
                  type="checkbox"
                  name="weather_dependent"
                  checked={formData.weather_dependent}
                  onChange={handleChange}
                />
                Weather dependent (practice may be cancelled due to weather)
              </label>
            </div>

            {formData.weather_dependent && (
              <div className="form-group">
                <label htmlFor="indoor_alternative_location">Indoor Alternative Location</label>
                <input
                  type="text"
                  id="indoor_alternative_location"
                  name="indoor_alternative_location"
                  value={formData.indoor_alternative_location}
                  onChange={handleChange}
                  placeholder="Backup indoor venue if weather is bad"
                />
              </div>
            )}

            <div className="form-group">
              <label htmlFor="notes">Additional Notes</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows={3}
                placeholder="Any additional information for players"
              />
            </div>
          </div>

          {/* Form Actions */}
          <div className="form-actions">
            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="secondary-button"
                disabled={loading}
              >
                Cancel
              </button>
            )}
            <button 
              type="submit" 
              className="primary-button"
              disabled={loading || success}
            >
              {success ? '✅ Created!' : loading ? 'Creating...' : 'Create Practice Session'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default PracticeForm;