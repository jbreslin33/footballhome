/**
 * LeagueGamesCard Component
 * Displays external league data and upcoming games
 */
class LeagueGamesCard extends Component {
    constructor(container, leagues = []) {
        super(container, { leagues });
        this.leagues = leagues;
    }

    render() {
        return `
            <div class="card league-games-card">
                <h3 class="font-medium mb-2">
                    <span class="card-icon">🏆</span>
                    League Games
                </h3>
                <p class="text-sm text-gray-600 mb-3">
                    External league data and standings
                </p>
                
                <div class="leagues-list">
                    ${this.renderLeaguesList()}
                </div>
                
                <div class="card-actions mt-4">
                    <button class="btn btn-primary btn-sm" data-action="view-standings">
                        View Standings
                    </button>
                    <button class="btn btn-secondary btn-sm" data-action="sync-leagues">
                        Sync Data
                    </button>
                </div>
            </div>
        `;
    }

    renderLeaguesList() {
        if (!this.leagues || this.leagues.length === 0) {
            return `
                <div class="empty-state">
                    <p class="text-sm text-gray-500">No league data available</p>
                </div>
            `;
        }

        return this.leagues.slice(0, 3).map(league => `
            <div class="league-item">
                <div class="league-info">
                    <span class="league-name">${league.name || 'Unknown League'}</span>
                    <span class="league-position">Position: ${league.position || 'N/A'}</span>
                </div>
                <div class="league-status ${this.getLeagueStatusClass(league.position)}">
                    ${this.formatPosition(league.position)}
                </div>
            </div>
        `).join('');
    }

    formatPosition(position) {
        if (!position || position === 'N/A') return 'Unranked';
        
        const pos = parseInt(position);
        if (isNaN(pos)) return 'Unranked';
        
        // Add ordinal suffix
        const suffix = ['th', 'st', 'nd', 'rd'][pos % 10 > 3 ? 0 : (pos % 100 - 20) % 10 < 0 ? pos % 10 : 0];
        return `${pos}${suffix}`;
    }

    getLeagueStatusClass(position) {
        if (!position) return 'unranked';
        
        const pos = parseInt(position);
        if (isNaN(pos)) return 'unranked';
        
        if (pos <= 3) return 'top-tier';
        if (pos <= 10) return 'mid-tier';
        return 'lower-tier';
    }

    setupEventListeners() {
        // View standings button
        const standingsBtn = this.querySelector('[data-action="view-standings"]');
        if (standingsBtn) {
            this.addEventListener(standingsBtn, 'click', this.handleViewStandings);
        }

        // Sync data button
        const syncBtn = this.querySelector('[data-action="sync-leagues"]');
        if (syncBtn) {
            this.addEventListener(syncBtn, 'click', this.handleSyncLeagues);
        }

        // League item clicks
        const leagueItems = this.querySelectorAll('.league-item');
        leagueItems.forEach(item => {
            this.addEventListener(item, 'click', (e) => {
                const leagueName = item.querySelector('.league-name')?.textContent;
                this.handleLeagueClick(leagueName);
            });
        });
    }

    handleViewStandings() {
        console.log('LeagueGamesCard: View standings clicked');
        this.emit('league:viewStandings');
    }

    handleSyncLeagues() {
        console.log('LeagueGamesCard: Sync leagues clicked');
        this.setState('syncing');
        this.emit('league:sync');
        
        // Simulate sync process
        setTimeout(() => {
            this.setState('');
            console.log('LeagueGamesCard: Sync completed');
        }, 2000);
    }

    handleLeagueClick(leagueName) {
        console.log('LeagueGamesCard: League clicked:', leagueName);
        this.emit('league:select', { leagueName });
    }

    // Update leagues data
    updateLeagues(leagues) {
        this.leagues = leagues;
        this.update();
    }

    // Get team performance in leagues
    getOverallPerformance() {
        if (!this.leagues || this.leagues.length === 0) {
            return { average: 0, trend: 'neutral' };
        }

        const positions = this.leagues
            .map(league => parseInt(league.position))
            .filter(pos => !isNaN(pos));

        if (positions.length === 0) {
            return { average: 0, trend: 'neutral' };
        }

        const average = positions.reduce((sum, pos) => sum + pos, 0) / positions.length;
        const trend = average <= 5 ? 'excellent' : average <= 10 ? 'good' : 'needs-improvement';

        return { average: Math.round(average), trend };
    }
}