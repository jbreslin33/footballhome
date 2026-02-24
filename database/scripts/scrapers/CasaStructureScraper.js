const path = require('path');
const fs = require('fs');
const LeagueSnapshot = require('../update/LeagueSnapshot');

/**
 * CASA Structure Scraper
 *
 * Scrapes standings and schedules from casasoccerleagues.com using Puppeteer.
 * CASA uses SportsEngine iframes that require browser automation and scroll-to-load.
 *
 * Outputs: LeagueSnapshot JSON saved to database/scraped-html/casa/snapshot.json
 *
 * Division pages:
 *   Standings: /season_management_season_page/tab_standings?page_node_id={ext_id}
 *   Schedule:  /season_management_season_page/tab_schedule?page_node_id={ext_id}
 */
class CasaStructureScraper {
  constructor() {
    const configPath = path.join(__dirname, '../leagues/north-america/usa/casa/config.json');
    this.config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    this.cacheDir = path.join(__dirname, '../../scraped-html/casa');
    this._browser = null;

    // Division mapping from 034-divisions.sql
    this.divisions = [
      { id: 54, name: 'Philadelphia Liga 1', externalId: '9090889' },
      { id: 55, name: 'Philadelphia Liga 2', externalId: '9096430' },
      { id: 56, name: 'Boston Liga 1', externalId: '9090891' },
      { id: 57, name: 'Lancaster Liga 1', externalId: '9090893' }
    ];
  }

  /**
   * Launch Puppeteer with stealth plugin
   */
  async _getBrowser() {
    if (this._browser) return this._browser;

    const puppeteer = require('puppeteer-extra');
    const StealthPlugin = require('puppeteer-extra-plugin-stealth');
    puppeteer.use(StealthPlugin());

    console.log('   🚀 Launching headless browser (stealth mode)...');
    this._browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    return this._browser;
  }

  /**
   * Close the browser
   */
  async closeBrowser() {
    if (this._browser) {
      await this._browser.close();
      this._browser = null;
    }
  }

  /**
   * Auto-scroll a page and its iframes to trigger lazy loading
   */
  async _scrollToLoad(page, scrollCount = 10, delayMs = 1500) {
    // Scroll main page
    for (let i = 0; i < scrollCount; i++) {
      await page.evaluate(() => {
        window.scrollTo(0, document.body.scrollHeight);
        const containers = document.querySelectorAll('[style*="overflow"], .scrollable, .table-container');
        containers.forEach(c => {
          if (c.scrollHeight > c.clientHeight) {
            c.scrollTop = c.scrollHeight;
          }
        });
      });
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }

    // Scroll inside iframes
    const frames = page.frames();
    for (const frame of frames) {
      try {
        for (let i = 0; i < scrollCount; i++) {
          await frame.evaluate(() => {
            window.scrollTo(0, document.body.scrollHeight);
          });
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } catch (e) {
        // Frame might not be accessible (cross-origin)
      }
    }

    // Scroll back to top
    await page.evaluate(() => window.scrollTo(0, 0));
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  /**
   * Scrape standings for a single division
   * @returns {Array<{teamName, played, wins, draws, losses, goalsFor, goalsAgainst, goalDiff, points}>}
   */
  async scrapeStandings(browser, division) {
    const page = await browser.newPage();

    try {
      const url = `https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=${division.externalId}`;
      console.log(`   🌐 Standings: ${division.name} (${division.externalId})`);
      console.log(`      ${url}`);

      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
      await new Promise(resolve => setTimeout(resolve, 5000));

      // Scroll to load lazy SportsEngine content
      await this._scrollToLoad(page);

      // Wait for iframes to fully render
      await new Promise(resolve => setTimeout(resolve, 3000));

      // Save rendered HTML for debugging
      const html = await page.content();
      fs.mkdirSync(this.cacheDir, { recursive: true });
      fs.writeFileSync(path.join(this.cacheDir, `standings-${division.externalId}-rendered.html`), html);

      // Extract standings from iframes (SportsEngine renders tables inside iframes)
      let teams = [];
      const frames = page.frames();

      for (const frame of frames) {
        const frameUrl = frame.url();
        if (!frameUrl.includes('standing') && !frameUrl.includes('division') && !frameUrl.includes('season')) {
          continue;
        }

        // Scroll iframe tables to load all rows
        try {
          for (let i = 0; i < 10; i++) {
            await frame.evaluate(() => {
              window.scrollTo(0, document.body.scrollHeight);
              document.querySelectorAll('table').forEach(table => {
                table.scrollTop = table.scrollHeight;
                let parent = table.parentElement;
                while (parent && parent !== document.body) {
                  if (parent.scrollHeight > parent.clientHeight) {
                    parent.scrollTop = parent.scrollHeight;
                  }
                  parent = parent.parentElement;
                }
              });
            });
            await new Promise(resolve => setTimeout(resolve, 500));
          }
        } catch (e) {
          // Frame scroll error — continue
        }

        const frameTeams = await frame.evaluate(() => {
          const results = [];
          const tables = document.querySelectorAll('table');

          for (const table of tables) {
            const rows = table.querySelectorAll('tr');

            for (const row of rows) {
              const cells = row.querySelectorAll('td, th');
              if (cells.length < 8) continue;

              // Find team name column (first non-numeric, >2 chars, not a header label)
              let teamName = null;
              let teamColIndex = 0;

              for (let i = 0; i < Math.min(3, cells.length); i++) {
                const text = cells[i]?.textContent?.trim();
                if (text && text.length > 2 && !/^\d+$/.test(text) &&
                    !text.match(/^(team|teams|gp|pts|w|d|l|gf|ga|gd|pld|played|rank)$/i)) {
                  teamName = text;
                  teamColIndex = i;
                  break;
                }
              }

              if (!teamName) continue;

              const offset = teamColIndex;
              results.push({
                teamName,
                played: parseInt(cells[offset + 1]?.textContent?.trim()) || 0,
                wins: parseInt(cells[offset + 2]?.textContent?.trim()) || 0,
                draws: parseInt(cells[offset + 3]?.textContent?.trim()) || 0,
                losses: parseInt(cells[offset + 4]?.textContent?.trim()) || 0,
                goalsFor: parseInt(cells[offset + 5]?.textContent?.trim()) || 0,
                goalsAgainst: parseInt(cells[offset + 6]?.textContent?.trim()) || 0,
                goalDiff: parseInt(cells[offset + 7]?.textContent?.trim()) || 0,
                points: parseInt(cells[offset + 8]?.textContent?.trim()) || 0
              });
            }
          }

          return results;
        }).catch(() => []);

        if (frameTeams.length > 0) {
          teams = teams.concat(frameTeams);
          console.log(`      ✓ Found ${frameTeams.length} teams in iframe`);
        }
      }

      // Fallback: try main page tables if no iframe data
      if (teams.length === 0) {
        teams = await page.evaluate(() => {
          const results = [];
          const tables = document.querySelectorAll('table');

          for (const table of tables) {
            const rows = table.querySelectorAll('tr');

            for (const row of rows) {
              const cells = row.querySelectorAll('td, th');
              if (cells.length < 10) continue;

              const teamName = cells[1]?.textContent?.trim();
              if (teamName && !teamName.match(/^(rank|team|teams|gp|pts|w|d|l|gf|ga|gd|pld|played)$/i)) {
                results.push({
                  teamName,
                  played: parseInt(cells[2]?.textContent?.trim()) || 0,
                  wins: parseInt(cells[3]?.textContent?.trim()) || 0,
                  draws: parseInt(cells[4]?.textContent?.trim()) || 0,
                  losses: parseInt(cells[5]?.textContent?.trim()) || 0,
                  goalsFor: parseInt(cells[6]?.textContent?.trim()) || 0,
                  goalsAgainst: parseInt(cells[7]?.textContent?.trim()) || 0,
                  goalDiff: parseInt(cells[8]?.textContent?.trim()) || 0,
                  points: parseInt(cells[9]?.textContent?.trim()) || 0
                });
              }
            }
          }
          return results;
        });
      }

      return teams;
    } finally {
      await page.close();
    }
  }

  /**
   * Scrape schedule for a single division
   * @returns {Array<{home, away, time, status, score}>}
   */
  async scrapeSchedule(browser, division) {
    const page = await browser.newPage();

    try {
      const url = `https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=${division.externalId}`;
      console.log(`   🌐 Schedule: ${division.name} (${division.externalId})`);
      console.log(`      ${url}`);

      await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
      await new Promise(resolve => setTimeout(resolve, 5000));

      // Scroll to load
      await this._scrollToLoad(page, 5, 1000);
      await new Promise(resolve => setTimeout(resolve, 3000));

      // Save frame HTML for debugging
      const frames = page.frames();
      let matches = [];

      for (const frame of frames) {
        const frameUrl = frame.url();
        if (!frameUrl.includes('schedule') && !frameUrl.includes('season')) continue;

        const frameHtml = await frame.content();
        fs.writeFileSync(path.join(this.cacheDir, `schedule-${division.externalId}-frame.html`), frameHtml);

        // Extract from Angular sm-schedule-event components
        const frameMatches = await frame.evaluate(() => {
          const events = document.querySelectorAll('sm-schedule-event');
          return Array.from(events).map(event => {
            const awayTeamEl = event.querySelector('[tag="away-team-name"]');
            const awayTeam = awayTeamEl ? awayTeamEl.textContent.trim() : null;

            const homeTeamEl = event.querySelector('[tag="home-team-name"]');
            const outsideHomeEl = event.querySelector('[data-cy="outside-home-team"]');
            const homeTeam = homeTeamEl ? homeTeamEl.textContent.trim() :
                            outsideHomeEl ? outsideHomeEl.textContent.trim() : null;

            const timeEl = event.querySelector('[data-cy="event-time"]');
            const time = timeEl ? timeEl.textContent.trim() : null;

            const statusEl = event.querySelector('[data-cy="event-status"]');
            const status = statusEl ? statusEl.textContent.trim() : null;

            const scoreEl = event.querySelector('[data-cy="game-score"]');
            const score = scoreEl ? scoreEl.textContent.trim() : null;

            return { home: homeTeam, away: awayTeam, time, status, score };
          }).filter(m => m.away && m.home);
        }).catch(() => []);

        if (frameMatches.length > 0) {
          matches = matches.concat(frameMatches);
          console.log(`      ✓ Found ${frameMatches.length} matches in iframe`);
        }
      }

      return matches;
    } finally {
      await page.close();
    }
  }

  /**
   * Parse a score string like "3 - 1" into [homeScore, awayScore]
   */
  parseScore(scoreStr) {
    if (!scoreStr) return [null, null];
    const match = scoreStr.match(/(\d+)\s*-\s*(\d+)/);
    if (!match) return [null, null];
    return [parseInt(match[1]), parseInt(match[2])];
  }

  /**
   * Generate a stable external ID for a match
   */
  matchExternalId(division, home, away, index) {
    const homeSlug = home.toLowerCase().replace(/\s+/g, '-');
    const awaySlug = away.toLowerCase().replace(/\s+/g, '-');
    return `${division.externalId}_${homeSlug}_vs_${awaySlug}_${index}`;
  }

  /**
   * Main scrape: fetch all divisions, produce LeagueSnapshot
   */
  async scrape() {
    console.log('\n⚽ CASA Structure Scraper');
    console.log('='.repeat(60));

    const browser = await this._getBrowser();

    const snapshot = new LeagueSnapshot({
      league: this.config.leagueSlug,
      season: this.config.activeSeason,
      sourceSystemId: this.config.sourceSystemId
    });

    // Track match counts per division for stable external IDs
    const matchCounters = {};

    try {
      for (const division of this.divisions) {
        console.log(`\n📂 ${division.name}`);
        matchCounters[division.externalId] = {};

        // Scrape standings
        try {
          const standingsTeams = await this.scrapeStandings(browser, division);
          console.log(`   ✓ Standings: ${standingsTeams.length} teams`);

          for (const team of standingsTeams) {
            // Add team
            snapshot.addTeam({
              name: team.teamName,
              divisionName: division.name,
              divisionExternalId: division.externalId,
              externalId: `${division.externalId}-${team.teamName.toLowerCase().replace(/\s+/g, '-')}`
            });

            // Add standing
            snapshot.addStanding({
              teamName: team.teamName,
              divisionName: division.name,
              played: team.played,
              wins: team.wins,
              draws: team.draws,
              losses: team.losses,
              goalsFor: team.goalsFor,
              goalsAgainst: team.goalsAgainst,
              goalDiff: team.goalDiff,
              points: team.points
            });
          }
        } catch (error) {
          console.error(`   ✗ Standings error: ${error.message}`);
        }

        // Rate limit between page types
        await new Promise(resolve => setTimeout(resolve, 2000));

        // Scrape schedule
        try {
          const matches = await this.scrapeSchedule(browser, division);
          console.log(`   ✓ Schedule: ${matches.length} matches`);

          for (const match of matches) {
            // Generate stable external ID using home_vs_away + occurrence counter
            const pairKey = `${match.home}::${match.away}`;
            matchCounters[division.externalId][pairKey] = (matchCounters[division.externalId][pairKey] || 0) + 1;
            const occurrence = matchCounters[division.externalId][pairKey];

            const [homeScore, awayScore] = this.parseScore(match.score);
            const status = (match.status || '').toLowerCase().includes('final') ? 'completed' : 'scheduled';

            snapshot.addMatch({
              homeTeam: match.home,
              awayTeam: match.away,
              divisionName: division.name,
              divisionExternalId: division.externalId,
              date: null, // CASA schedule pages don't show dates in the event components
              time: match.time || null,
              status,
              homeScore,
              awayScore,
              externalId: this.matchExternalId(division, match.home, match.away, occurrence)
            });
          }
        } catch (error) {
          console.error(`   ✗ Schedule error: ${error.message}`);
        }

        // Rate limit between divisions
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    } finally {
      await this.closeBrowser();
    }

    // Save snapshot
    const snapshotPath = path.join(this.cacheDir, 'snapshot.json');
    snapshot.save(snapshotPath);
    console.log(`\n💾 Snapshot saved: ${snapshotPath}`);
    console.log(`   Teams: ${snapshot.teams.length}`);
    console.log(`   Matches: ${snapshot.matches.length}`);
    console.log(`   Standings: ${snapshot.standings.length}`);

    // Also save in the old JSON formats for backwards compatibility with generate-sql.js
    this._saveBackwardsCompatible(snapshot);

    console.log('\n✅ CASA scrape complete\n');
    return snapshot;
  }

  /**
   * Save data in old JSON format for backwards compatibility with generate-sql.js
   * This can be removed once generate-sql.js is updated to read LeagueSnapshot
   */
  _saveBackwardsCompatible(snapshot) {
    // standings-data.json
    const standingsData = {
      generated: new Date().toISOString(),
      divisions: this.divisions.map(d => ({
        id: d.id,
        name: d.name,
        external_id: d.externalId,
        teams: snapshot.standings
          .filter(s => s.divisionName === d.name)
          .map(s => ({
            teamName: s.teamName,
            played: s.played,
            wins: s.wins,
            draws: s.draws,
            losses: s.losses,
            goalsFor: s.goalsFor,
            goalsAgainst: s.goalsAgainst,
            goalDiff: s.goalDiff,
            points: s.points
          }))
      }))
    };
    fs.writeFileSync(path.join(this.cacheDir, 'standings-data.json'), JSON.stringify(standingsData, null, 2));

    // division-teams.json
    const divisionTeams = {
      generated: new Date().toISOString(),
      divisions: this.divisions.map(d => ({
        id: d.id,
        name: d.name,
        external_id: d.externalId,
        teams: snapshot.standings
          .filter(s => s.divisionName === d.name)
          .map(s => ({
            teamName: s.teamName,
            played: s.played,
            wins: s.wins,
            draws: s.draws,
            losses: s.losses,
            goalsFor: s.goalsFor,
            goalsAgainst: s.goalsAgainst,
            goalDiff: s.goalDiff,
            points: s.points
          }))
      }))
    };
    fs.writeFileSync(path.join(this.cacheDir, 'division-teams.json'), JSON.stringify(divisionTeams, null, 2));

    // division-matches.json
    const divisionMatches = {
      generated: new Date().toISOString(),
      total_matches: snapshot.matches.length,
      divisions: this.divisions.map(d => {
        const divMatches = snapshot.matches.filter(m => m.divisionName === d.name);
        return {
          id: d.id,
          name: d.name,
          external_id: d.externalId,
          match_count: divMatches.length,
          matches: divMatches.map(m => ({
            home: m.homeTeam,
            away: m.awayTeam,
            time: m.time,
            status: m.status === 'completed' ? 'Final' : m.status,
            score: (m.homeScore !== null && m.awayScore !== null)
              ? `${m.homeScore} - ${m.awayScore}` : null
          }))
        };
      })
    };
    fs.writeFileSync(path.join(this.cacheDir, 'division-matches.json'), JSON.stringify(divisionMatches, null, 2));

    console.log('   📄 Saved backwards-compatible JSON files');
  }
}

// Run if executed directly
if (require.main === module) {
  const scraper = new CasaStructureScraper();
  scraper.scrape()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = CasaStructureScraper;
