import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import './StatsManager.css';

interface PlayerStats {
  matches_played: number;
  goals: number;
  assists: number;
  yellow_cards: number;
  red_cards: number;
  minutes_played: number;
  attendance_rate: number;
}

interface StatsManagerProps {
  onClose?: () => void;
}

const StatsManager: React.FC<StatsManagerProps> = ({ onClose }) => {
  const { user } = useAuth();
  const [stats, setStats] = useState<PlayerStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedSeason, setSelectedSeason] = useState<string>('2025');

  useEffect(() => {
    loadStats();
  }, [selectedSeason]);

  const loadStats = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // For now, we'll simulate stats data since we don't have a real stats endpoint yet
      // In a real implementation, this would call something like: api.get(`/stats/player/${user?.id}`)
      
      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate loading
      
      // Mock data - replace with real API call
      setStats({
        matches_played: 12,
        goals: 3,
        assists: 5,
        yellow_cards: 2,
        red_cards: 0,
        minutes_played: 1080,
        attendance_rate: 85
      });
      
    } catch (err: any) {
      console.error('Failed to load stats:', err);
      setError('Failed to load statistics. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const calculateAverageMinutesPerMatch = () => {
    if (!stats || stats.matches_played === 0) return 0;
    return Math.round(stats.minutes_played / stats.matches_played);
  };

  const getStatColor = (stat: string, value: number) => {
    switch (stat) {
      case 'goals':
      case 'assists':
        if (value >= 10) return '#28a745';
        if (value >= 5) return '#ffc107';
        return '#6c757d';
      case 'attendance_rate':
        if (value >= 90) return '#28a745';
        if (value >= 75) return '#ffc107';
        return '#dc3545';
      case 'yellow_cards':
        if (value <= 2) return '#28a745';
        if (value <= 5) return '#ffc107';
        return '#dc3545';
      case 'red_cards':
        if (value === 0) return '#28a745';
        return '#dc3545';
      default:
        return '#0066cc';
    }
  };

  if (loading) {
    return (
      <div className="stats-manager">
        <div className="loading">Loading statistics...</div>
      </div>
    );
  }

  if (!stats) {
    return (
      <div className="stats-manager">
        <div className="error-message">No statistics available</div>
      </div>
    );
  }

  return (
    <div className="stats-manager">
      <div className="stats-header">
        <h2>📊 My Statistics</h2>
        <p>Track your performance and achievements</p>
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

      <div className="stats-controls">
        <div className="season-selector">
          <label htmlFor="season">Season:</label>
          <select
            id="season"
            value={selectedSeason}
            onChange={(e) => setSelectedSeason(e.target.value)}
          >
            <option value="2025">2025</option>
            <option value="2024">2024</option>
            <option value="2023">2023</option>
          </select>
        </div>
      </div>

      <div className="stats-content">
        <div className="stats-grid">
          {/* Performance Stats */}
          <div className="stats-category">
            <h3>⚽ Performance</h3>
            <div className="stats-cards">
              <div className="stat-card">
                <div className="stat-icon">🎯</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('goals', stats.goals) }}>
                    {stats.goals}
                  </div>
                  <div className="stat-label">Goals</div>
                </div>
              </div>

              <div className="stat-card">
                <div className="stat-icon">🤝</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('assists', stats.assists) }}>
                    {stats.assists}
                  </div>
                  <div className="stat-label">Assists</div>
                </div>
              </div>

              <div className="stat-card">
                <div className="stat-icon">🏃</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('matches', stats.matches_played) }}>
                    {stats.matches_played}
                  </div>
                  <div className="stat-label">Matches</div>
                </div>
              </div>

              <div className="stat-card">
                <div className="stat-icon">⏱️</div>
                <div className="stat-info">
                  <div className="stat-value">{calculateAverageMinutesPerMatch()}</div>
                  <div className="stat-label">Avg Minutes</div>
                </div>
              </div>
            </div>
          </div>

          {/* Discipline Stats */}
          <div className="stats-category">
            <h3>🃏 Discipline</h3>
            <div className="stats-cards">
              <div className="stat-card">
                <div className="stat-icon">🟨</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('yellow_cards', stats.yellow_cards) }}>
                    {stats.yellow_cards}
                  </div>
                  <div className="stat-label">Yellow Cards</div>
                </div>
              </div>

              <div className="stat-card">
                <div className="stat-icon">🟥</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('red_cards', stats.red_cards) }}>
                    {stats.red_cards}
                  </div>
                  <div className="stat-label">Red Cards</div>
                </div>
              </div>
            </div>
          </div>

          {/* Attendance Stats */}
          <div className="stats-category">
            <h3>📅 Attendance</h3>
            <div className="stats-cards">
              <div className="stat-card wide">
                <div className="stat-icon">✅</div>
                <div className="stat-info">
                  <div className="stat-value" style={{ color: getStatColor('attendance_rate', stats.attendance_rate) }}>
                    {stats.attendance_rate}%
                  </div>
                  <div className="stat-label">Attendance Rate</div>
                </div>
                <div className="attendance-bar">
                  <div 
                    className="attendance-fill" 
                    style={{ 
                      width: `${stats.attendance_rate}%`,
                      backgroundColor: getStatColor('attendance_rate', stats.attendance_rate)
                    }}
                  />
                </div>
              </div>

              <div className="stat-card">
                <div className="stat-icon">🕐</div>
                <div className="stat-info">
                  <div className="stat-value">{stats.minutes_played}</div>
                  <div className="stat-label">Total Minutes</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Summary Section */}
        <div className="stats-summary">
          <h3>📈 Season Summary</h3>
          <div className="summary-content">
            <div className="summary-item">
              <span className="summary-label">Goals per match:</span>
              <span className="summary-value">
                {stats.matches_played > 0 ? (stats.goals / stats.matches_played).toFixed(2) : '0.00'}
              </span>
            </div>
            <div className="summary-item">
              <span className="summary-label">Assists per match:</span>
              <span className="summary-value">
                {stats.matches_played > 0 ? (stats.assists / stats.matches_played).toFixed(2) : '0.00'}
              </span>
            </div>
            <div className="summary-item">
              <span className="summary-label">Goal contributions:</span>
              <span className="summary-value">{stats.goals + stats.assists}</span>
            </div>
            <div className="summary-item">
              <span className="summary-label">Disciplinary points:</span>
              <span className="summary-value">{stats.yellow_cards + (stats.red_cards * 2)}</span>
            </div>
          </div>
        </div>

        <div className="stats-note">
          <p>
            <strong>Note:</strong> Statistics are updated after each match. 
            Attendance rate includes training sessions and matches. 
            Contact your coach if you notice any discrepancies.
          </p>
        </div>
      </div>
    </div>
  );
};

export default StatsManager;