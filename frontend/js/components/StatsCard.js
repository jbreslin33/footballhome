/**
 * StatsCard Component
 * Displays user performance statistics
 */
class StatsCard extends Component {
    constructor(container, stats = {}) {
        super(container, { stats });
        this.stats = stats;
    }

    render() {
        return `
            <div class="card stats-card">
                <h3 class="font-medium mb-2">
                    <span class="card-icon">📊</span>
                    Statistics
                </h3>
                <p class="text-sm text-gray-600 mb-3">
                    Your performance metrics
                </p>
                
                <div class="stats-grid">
                    ${this.renderStatsGrid()}
                </div>
                
                <div class="card-actions mt-4">
                    <button class="btn btn-primary btn-sm" data-action="view-detailed-stats">
                        View Details
                    </button>
                    <button class="btn btn-secondary btn-sm" data-action="export-stats">
                        Export Data
                    </button>
                </div>
            </div>
        `;
    }

    renderStatsGrid() {
        const defaultStats = {
            gamesPlayed: 0,
            wins: 0,
            goals: 0,
            assists: 0,
            ...this.stats
        };

        return `
            <div class="stat-item">
                <div class="stat-value">${defaultStats.gamesPlayed}</div>
                <div class="stat-label">Games</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${defaultStats.wins}</div>
                <div class="stat-label">Wins</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${defaultStats.goals}</div>
                <div class="stat-label">Goals</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${defaultStats.assists}</div>
                <div class="stat-label">Assists</div>
            </div>
        `;
    }

    setupEventListeners() {
        // View detailed stats button
        const detailsBtn = this.querySelector('[data-action="view-detailed-stats"]');
        if (detailsBtn) {
            this.addEventListener(detailsBtn, 'click', this.handleViewDetailedStats);
        }

        // Export stats button
        const exportBtn = this.querySelector('[data-action="export-stats"]');
        if (exportBtn) {
            this.addEventListener(exportBtn, 'click', this.handleExportStats);
        }
    }

    handleViewDetailedStats() {
        console.log('StatsCard: View detailed stats clicked');
        this.emit('stats:viewDetails', this.stats);
    }

    handleExportStats() {
        console.log('StatsCard: Export stats clicked');
        this.emit('stats:export', this.stats);
    }

    // Update stats data
    updateStats(stats) {
        this.stats = { ...this.stats, ...stats };
        this.update();
    }

    // Calculate win percentage
    getWinPercentage() {
        if (!this.stats.gamesPlayed || this.stats.gamesPlayed === 0) {
            return 0;
        }
        return Math.round((this.stats.wins / this.stats.gamesPlayed) * 100);
    }

    // Get performance trend (could be enhanced with historical data)
    getPerformanceTrend() {
        const winPercentage = this.getWinPercentage();
        if (winPercentage >= 70) return 'excellent';
        if (winPercentage >= 50) return 'good';
        if (winPercentage >= 30) return 'average';
        return 'needs-improvement';
    }
}