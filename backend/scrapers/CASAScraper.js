const BaseScraper = require('./BaseScraper');

/**
 * CASA (Community Amateur Soccer Association) Scraper
 * Scrapes match data from CASA website
 */
class CASAScraper extends BaseScraper {
  constructor(config) {
    super({
      leagueName: 'CASA',
      baseUrl: 'https://www.casa.org.au',
      dataSource: 'scraped_casa',
      requestDelay: 1500, // 1.5 seconds between requests
      ...config
    });

    // CASA specific configuration
    this.divisions = config.divisions || [
      { name: 'Division 1', id: 'div1' },
      { name: 'Division 2', id: 'div2' },
      { name: 'Division 3', id: 'div3' },
      { name: 'Masters Over 35', id: 'masters35' },
      { name: 'Masters Over 45', id: 'masters45' }
    ];
  }

  /**
   * Scrape fixtures from CASA website
   * Mock implementation for demonstration
   */
  async scrapeFixtures() {
    console.log('Scraping CASA fixtures...');
    
    // Mock fixture data for demonstration
    const mockFixtures = [
      {
        homeTeam: 'Northern Demons FC',
        awayTeam: 'Southern United SC',
        scheduledDate: '2024-12-08 10:00:00',
        competitionName: 'CASA Division 1',
        competitionRound: 'Round 18',
        leagueGameId: 'CASA_2024_D1_18_001',
        externalUrl: 'https://www.casa.org.au/match/98765',
        venue: 'Gepps Cross Sports Complex',
        status: 'completed',
        homeScore: 1,
        awayScore: 2
      },
      {
        homeTeam: 'Eastern Suburbs FC',
        awayTeam: 'Western Warriors SC',
        scheduledDate: '2024-12-08 12:30:00',
        competitionName: 'CASA Division 1',
        competitionRound: 'Round 18',
        leagueGameId: 'CASA_2024_D1_18_002',
        externalUrl: 'https://www.casa.org.au/match/98766',
        venue: 'Windsor Park',
        status: 'scheduled'
      },
      {
        homeTeam: 'Golden Grove FC',
        awayTeam: 'Tea Tree Gully SC',
        scheduledDate: '2024-12-07 14:00:00',
        competitionName: 'CASA Masters Over 35',
        competitionRound: 'Round 15',
        leagueGameId: 'CASA_2024_M35_15_001',
        externalUrl: 'https://www.casa.org.au/match/98767',
        venue: 'Golden Grove Sports Park',
        status: 'completed',
        homeScore: 3,
        awayScore: 3
      }
    ];

    // Process each mock fixture
    const fixtures = [];
    for (const fixture of mockFixtures) {
      try {
        // Find or create teams
        const homeTeamId = await this.findOrCreateTeam(fixture.homeTeam);
        const awayTeamId = await this.findOrCreateTeam(fixture.awayTeam);

        // Find or create venue
        let venueId = null;
        if (fixture.venue) {
          const venueResult = await this.pool.query(
            'SELECT id FROM venues WHERE name ILIKE $1 OR address ILIKE $1',
            [`%${fixture.venue}%`]
          );
          if (venueResult.rows.length > 0) {
            venueId = venueResult.rows[0].id;
          }
        }

        fixtures.push({
          homeTeamId,
          awayTeamId,
          scheduledDate: fixture.scheduledDate,
          competitionName: fixture.competitionName,
          competitionRound: fixture.competitionRound,
          leagueGameId: fixture.leagueGameId,
          externalUrl: fixture.externalUrl,
          venueId,
          status: fixture.status,
          homeScore: fixture.homeScore,
          awayScore: fixture.awayScore
        });
      } catch (error) {
        console.error(`Error processing CASA fixture ${fixture.leagueGameId}:`, error.message);
      }
    }

    return fixtures;
  }

  /**
   * Scrape detailed match information for CASA
   */
  async scrapeMatchDetails(gameId, externalUrl) {
    console.log(`Scraping CASA match details for game ${gameId}: ${externalUrl}`);

    // Mock match details for CASA (typically simpler than APSL)
    const mockMatchData = {
      homeScore: 1,
      awayScore: 2,
      homeHTScore: 0,
      awayHTScore: 1,
      attendance: 45, // CASA matches typically smaller crowds
      events: [
        {
          eventType: 'goal',
          minute: 23,
          team: 'away',
          player: 'Mark Thompson',
          description: 'Close-range finish'
        },
        {
          eventType: 'yellow_card',
          minute: 38,
          team: 'home',
          player: 'Paul Richards',
          description: 'Late tackle'
        },
        {
          eventType: 'goal',
          minute: 56,
          team: 'home',
          player: 'Simon Foster',
          description: 'Free kick goal'
        },
        {
          eventType: 'goal',
          minute: 78,
          team: 'away',
          player: 'Kevin Brooks',
          description: 'Winning goal from corner'
        },
        {
          eventType: 'red_card',
          minute: 85,
          team: 'home',
          player: 'Paul Richards',
          description: 'Second yellow card'
        }
      ],
      playerStats: [
        // CASA typically has less detailed stats
        {
          team: 'home',
          player: 'Simon Foster',
          position: 'MF',
          minutesPlayed: 90,
          goals: 1,
          assists: 0,
          yellowCards: 0,
          isStarter: true
        },
        {
          team: 'home',
          player: 'Paul Richards',
          position: 'DF',
          minutesPlayed: 85,
          goals: 0,
          assists: 0,
          yellowCards: 2,
          redCards: 1,
          isStarter: true
        },
        {
          team: 'away',
          player: 'Mark Thompson',
          position: 'ST',
          minutesPlayed: 90,
          goals: 1,
          assists: 0,
          isStarter: true
        },
        {
          team: 'away',
          player: 'Kevin Brooks',
          position: 'MF',
          minutesPlayed: 90,
          goals: 1,
          assists: 0,
          isStarter: true
        }
      ]
    };

    // Update match result
    await this.updateGameResult(gameId, {
      homeScore: mockMatchData.homeScore,
      awayScore: mockMatchData.awayScore,
      homeHTScore: mockMatchData.homeHTScore,
      awayHTScore: mockMatchData.awayHTScore,
      attendance: mockMatchData.attendance,
      rawMatchData: mockMatchData
    });

    // Get team IDs for this game
    const gameResult = await this.pool.query(
      'SELECT home_team_id, away_team_id FROM league_games WHERE id = $1',
      [gameId]
    );
    
    if (gameResult.rows.length === 0) {
      throw new Error(`Game ${gameId} not found`);
    }

    const { home_team_id: homeTeamId, away_team_id: awayTeamId } = gameResult.rows[0];

    // Add match events
    for (const event of mockMatchData.events) {
      const teamId = event.team === 'home' ? homeTeamId : awayTeamId;
      
      await this.addMatchEvent(gameId, {
        eventType: event.eventType,
        teamId: teamId,
        playerName: event.player,
        minute: event.minute,
        description: event.description,
        additionalData: event.additionalData || {}
      });
    }

    // Add player statistics
    for (const playerStat of mockMatchData.playerStats) {
      const teamId = playerStat.team === 'home' ? homeTeamId : awayTeamId;
      
      await this.addPlayerStats(gameId, {
        teamId: teamId,
        playerName: playerStat.player,
        minutesPlayed: playerStat.minutesPlayed || 90,
        goals: playerStat.goals || 0,
        assists: playerStat.assists || 0,
        yellowCards: playerStat.yellowCards || 0,
        redCards: playerStat.redCards || 0,
        shots: playerStat.shots || 0,
        shotsOnTarget: playerStat.shotsOnTarget || 0,
        startingPosition: playerStat.position,
        isStarter: playerStat.isStarter || true,
        rawStatsData: playerStat
      });
    }

    console.log(`Completed CASA match details scraping for game ${gameId}`);
  }

  /**
   * CASA-specific helper methods
   */
  
  /**
   * Parse CASA date format (often different from APSL)
   */
  parseCASADate(dateString) {
    // CASA might use formats like "Sat 08 Dec 2024, 2:00 PM"
    // Implementation would depend on actual CASA date formats
    return new Date(dateString).toISOString();
  }

  /**
   * Generate CASA-specific game ID
   */
  generateCASAGameId(homeTeam, awayTeam, date, division) {
    const shortDate = date.substring(0, 10).replace(/-/g, '');
    const homeInitials = homeTeam.split(' ').map(w => w[0]).join('').toUpperCase();
    const awayInitials = awayTeam.split(' ').map(w => w[0]).join('').toUpperCase();
    return `CASA_${this.season}_${division}_${shortDate}_${homeInitials}_${awayInitials}`;
  }

  /**
   * Handle CASA-specific venue mapping
   */
  async mapCASAVenue(venueName) {
    // CASA venues are often community parks with different naming conventions
    const venueMapping = {
      'Gepps Cross Sports Complex': 'Gepps Cross',
      'Golden Grove Sports Park': 'Golden Grove Reserve',
      'Windsor Park': 'Windsor Reserve'
    };

    const mappedName = venueMapping[venueName] || venueName;
    
    const venueResult = await this.pool.query(
      'SELECT id FROM venues WHERE name ILIKE $1 OR address ILIKE $2',
      [`%${mappedName}%`, `%${venueName}%`]
    );

    return venueResult.rows.length > 0 ? venueResult.rows[0].id : null;
  }
}

module.exports = CASAScraper;