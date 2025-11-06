import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import './PracticeForm.css'; // Reuse the same CSS styles

interface Venue {
  id: string;
  name: string;
  address: string;
}

interface Team {
  id: string;
  name: string;
}

interface OpponentTeam {
  id: string;
  name: string;
  age_group: string;
  skill_level: string;
}

interface HomeAwayStatus {
  id: string;
  name: string;
  display_name: string;
  description: string;
}

interface EventType {
  id: string;
  name: string;
  display_name: string;
  category: string;
  default_duration: number;
}

interface MatchFormData {
  title: string;
  description: string;
  event_date: string;
  event_time: string;
  duration_minutes: number;
  venue_id: string;
  team_id: string;
  event_type_id: string;
  max_players: number | '';
  // Match-specific fields
  opponent_team_id: string;
  competition_name: string;
  season: string;
  round: string;
  home_away_status_id: string;
  expected_attendance: number | '';
  referee_assigned: boolean;
  referee_contact: string;
  kickoff_time: string;
  pre_match_meeting_time: string;
  arrival_time: string;
  warm_up_duration: number;
  notes: string;
}

interface MatchFormProps {
  onSuccess?: () => void;
  onCancel?: () => void;
}

const MatchForm: React.FC<MatchFormProps> = ({ onSuccess, onCancel }) => {
  const { user, token } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [venues, setVenues] = useState<Venue[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [opponents, setOpponents] = useState<OpponentTeam[]>([]);
  const [homeAwayStatuses, setHomeAwayStatuses] = useState<HomeAwayStatus[]>([]);
  const [eventTypes, setEventTypes] = useState<EventType[]>([]);
  
  const [formData, setFormData] = useState<MatchFormData>({
    title: '',
    description: '',
    event_date: '',
    event_time: '',
    duration_minutes: 90,
    venue_id: '',
    team_id: '',
    event_type_id: '',
    max_players: '',
    opponent_team_id: '',
    competition_name: '',
    season: new Date().getFullYear().toString(),
    round: '',
    home_away_status_id: '',
    expected_attendance: '',
    referee_assigned: false,
    referee_contact: '',
    kickoff_time: '',
    pre_match_meeting_time: '',
    arrival_time: '',
    warm_up_duration: 30,
    notes: ''
  });

  // Load initial data
  useEffect(() => {
    const loadData = async () => {
      try {
        console.log('🔄 Loading match form data...');
        
        // Load venues, teams, opponents, statuses, and event types
        const [venuesResponse, teamsResponse, opponentsResponse, statusesResponse, eventTypesResponse] = await Promise.all([
          api.get('/venues'),
          api.get('/teams'),
          api.get('/matches/opponents'),
          api.get('/matches/home-away-statuses'),
          api.get('/events/types?category=match')
        ]);

        console.log('📊 Match API Responses:', {
          venues: venuesResponse.data.venues?.length || 0,
          teams: teamsResponse.data.teams?.length || 0,
          opponents: opponentsResponse.data.opponents?.length || 0,
          statuses: statusesResponse.data.statuses?.length || 0,
          eventTypes: eventTypesResponse.data.event_types?.length || 0
        });

        setVenues(venuesResponse.data.venues || []);
        setTeams(teamsResponse.data.teams || []);
        setOpponents(opponentsResponse.data.opponents || []);
        setHomeAwayStatuses(statusesResponse.data.statuses || []);
        setEventTypes(eventTypesResponse.data.event_types || []);

        console.log('✅ Match form data loaded successfully');

        // Set default event type to match if available
        const matchType = eventTypesResponse.data.event_types?.find((type: EventType) => type.name === 'match');
        if (matchType) {
          setFormData(prev => ({
            ...prev,
            event_type_id: matchType.id,
            duration_minutes: matchType.default_duration
          }));
        }

      } catch (error) {
        console.error('❌ Failed to load match form data:', error);
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

  const handleEventTypeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const eventTypeId = e.target.value;
    const eventType = eventTypes.find(type => type.id === eventTypeId);
    
    setFormData(prev => ({
      ...prev,
      event_type_id: eventTypeId,
      duration_minutes: eventType?.default_duration || 90
    }));
  };

  const handleOpponentChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const opponentId = e.target.value;
    const opponent = opponents.find(opp => opp.id === opponentId);
    
    setFormData(prev => ({
      ...prev,
      opponent_team_id: opponentId,
      title: opponent ? `vs ${opponent.name}` : ''
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Combine date and time
      const eventDateTime = new Date(`${formData.event_date}T${formData.event_time}`);
      
      // Prepare the match data
      const matchData = {
        // Event fields
        team_id: formData.team_id,
        event_type_id: formData.event_type_id,
        title: formData.title,
        description: formData.description,
        event_date: eventDateTime.toISOString(),
        venue_id: formData.venue_id || null,
        duration_minutes: formData.duration_minutes,
        max_players: formData.max_players || null,
        
        // Match-specific fields
        opponent_team_id: formData.opponent_team_id,
        competition_name: formData.competition_name,
        season: formData.season,
        round: formData.round,
        home_away_status_id: formData.home_away_status_id,
        expected_attendance: formData.expected_attendance || null,
        referee_assigned: formData.referee_assigned,
        referee_contact: formData.referee_contact,
        kickoff_time: formData.kickoff_time,
        pre_match_meeting_time: formData.pre_match_meeting_time,
        arrival_time: formData.arrival_time,
        warm_up_duration: formData.warm_up_duration,
        notes: formData.notes
      };

      console.log('🚀 Submitting match data:', matchData);
      const response = await api.post('/matches', matchData);
      console.log('✅ Match created successfully:', response.data);
      
      setSuccess(true);
      
      // Redirect after a brief success message
      setTimeout(() => {
        if (onSuccess) {
          onSuccess();
        }
      }, 2000);
    } catch (error: any) {
      console.error('Failed to create match:', error);
      setError(error.response?.data?.error || 'Failed to create match');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="practice-form-container">
      <div className="practice-form">
        <header className="form-header">
          <h2>⚽ Schedule Match</h2>
          <p>Create a new match for your team</p>
        </header>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {success && (
          <div className="success-message">
            ✅ Match created successfully! Redirecting...
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Basic Information */}
          <div className="form-section">
            <h3>Basic Information</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="team_id">Our Team *</label>
                <select
                  id="team_id"
                  name="team_id"
                  value={formData.team_id}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select our team</option>
                  {teams.map(team => (
                    <option key={team.id} value={team.id}>
                      {team.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="opponent_team_id">Opponent Team *</label>
                <select
                  id="opponent_team_id"
                  name="opponent_team_id"
                  value={formData.opponent_team_id}
                  onChange={handleOpponentChange}
                  required
                >
                  <option value="">Select opponent</option>
                  {opponents.map(opponent => (
                    <option key={opponent.id} value={opponent.id}>
                      {opponent.name} ({opponent.age_group} - {opponent.skill_level})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="title">Match Title *</label>
                <input
                  type="text"
                  id="title"
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  required
                  placeholder="e.g., vs Manchester United"
                />
              </div>

              <div className="form-group">
                <label htmlFor="home_away_status_id">Home/Away *</label>
                <select
                  id="home_away_status_id"
                  name="home_away_status_id"
                  value={formData.home_away_status_id}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select status</option>
                  {homeAwayStatuses.map(status => (
                    <option key={status.id} value={status.id}>
                      {status.display_name}
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
                placeholder="Brief description of the match"
              />
            </div>
          </div>

          {/* Competition Details */}
          <div className="form-section">
            <h3>Competition Details</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="competition_name">Competition/League</label>
                <input
                  type="text"
                  id="competition_name"
                  name="competition_name"
                  value={formData.competition_name}
                  onChange={handleChange}
                  placeholder="e.g., Premier League, FA Cup"
                />
              </div>

              <div className="form-group">
                <label htmlFor="season">Season</label>
                <input
                  type="text"
                  id="season"
                  name="season"
                  value={formData.season}
                  onChange={handleChange}
                  placeholder="e.g., 2024-25"
                />
              </div>

              <div className="form-group">
                <label htmlFor="round">Round/Matchday</label>
                <input
                  type="text"
                  id="round"
                  name="round"
                  value={formData.round}
                  onChange={handleChange}
                  placeholder="e.g., Round 1, Matchday 15"
                />
              </div>
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
                <label htmlFor="event_time">Kickoff Time *</label>
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
                  min="45"
                  max="150"
                />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="event_type_id">Match Type *</label>
                <select
                  id="event_type_id"
                  name="event_type_id"
                  value={formData.event_type_id}
                  onChange={handleEventTypeChange}
                  required
                >
                  <option value="">Select match type</option>
                  {eventTypes.map(type => (
                    <option key={type.id} value={type.id}>
                      {type.display_name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="venue_id">Venue *</label>
                <select
                  id="venue_id"
                  name="venue_id"
                  value={formData.venue_id}
                  onChange={handleChange}
                  required
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

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="max_players">Squad Size</label>
                <input
                  type="number"
                  id="max_players"
                  name="max_players"
                  value={formData.max_players}
                  onChange={handleChange}
                  min="11"
                  max="30"
                  placeholder="e.g, 18 (starting XI + subs)"
                />
              </div>

              <div className="form-group">
                <label htmlFor="expected_attendance">Expected Attendance</label>
                <input
                  type="number"
                  id="expected_attendance"
                  name="expected_attendance"
                  value={formData.expected_attendance}
                  onChange={handleChange}
                  min="0"
                  placeholder="Number of expected spectators"
                />
              </div>
            </div>
          </div>

          {/* Match Organization */}
          <div className="form-section">
            <h3>Match Organization</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="arrival_time">Team Arrival Time</label>
                <input
                  type="time"
                  id="arrival_time"
                  name="arrival_time"
                  value={formData.arrival_time}
                  onChange={handleChange}
                  placeholder="When team should arrive"
                />
              </div>

              <div className="form-group">
                <label htmlFor="pre_match_meeting_time">Team Meeting Time</label>
                <input
                  type="time"
                  id="pre_match_meeting_time"
                  name="pre_match_meeting_time"
                  value={formData.pre_match_meeting_time}
                  onChange={handleChange}
                  placeholder="Pre-match team talk time"
                />
              </div>

              <div className="form-group">
                <label htmlFor="warm_up_duration">Warm-up Duration (minutes)</label>
                <input
                  type="number"
                  id="warm_up_duration"
                  name="warm_up_duration"
                  value={formData.warm_up_duration}
                  onChange={handleChange}
                  min="15"
                  max="60"
                />
              </div>
            </div>

            <div className="form-group checkbox-group">
              <label>
                <input
                  type="checkbox"
                  name="referee_assigned"
                  checked={formData.referee_assigned}
                  onChange={handleChange}
                />
                Referee assigned
              </label>
            </div>

            {formData.referee_assigned && (
              <div className="form-group">
                <label htmlFor="referee_contact">Referee Contact</label>
                <input
                  type="text"
                  id="referee_contact"
                  name="referee_contact"
                  value={formData.referee_contact}
                  onChange={handleChange}
                  placeholder="Referee name, phone, or email"
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
                placeholder="Special instructions, tactics, or other important information for players"
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
              {success ? '✅ Created!' : loading ? 'Creating...' : 'Create Match'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default MatchForm;