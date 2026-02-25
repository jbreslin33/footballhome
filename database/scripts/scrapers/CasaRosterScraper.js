#!/usr/bin/env node
/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * CASA Roster Scraper
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *
 * Downloads CASA roster Google Sheets as XLSX, parses player data.
 * Each division has one Google Sheet with one tab per team.
 *
 * Sheet format (consistent across all divisions):
 *   Row 0: Header ("CASA Soccer Philadelphia Liga 1 Roster")
 *   Row 2: Team Name (col C), value (col D)
 *   Row 4: Manager name (col D)
 *   Row 6: Column headers: First Name, Last Name, DOB, Headshot, Date Added, Jersey #, Goals, Yellows, Reds
 *   Row 7+: Player data (numbered rows)
 *
 * Config: rosterSheets in config.json maps divisions → Google Sheet IDs → tab names → DB team names
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const XLSX = require('xlsx');

class CasaRosterScraper {
  /**
   * @param {Object} config - League config from config.json (must have rosterSheets)
   * @param {string} cacheDir - Path to scraped-html/casa/ for caching XLSX files
   */
  constructor(config, cacheDir) {
    this.config = config;
    this.cacheDir = cacheDir;
    this.rosterSheets = config.rosterSheets || {};
  }

  /**
   * Download a file from a URL using curl (HTTP/1.1 for Google Sheets compatibility)
   * Downloads to a temp file first, then moves on success to avoid corrupting cache.
   * @param {string} url - URL to download
   * @param {string} outputPath - Path to save the file
   */
  _download(url, outputPath) {
    const tmpPath = outputPath + '.tmp';
    try {
      // Use curl with HTTP/1.1 — Google Sheets HTTP/2 export aborts on large files
      execSync(`curl --http1.1 -L -sS --retry 2 --retry-delay 5 -o "${tmpPath}" "${url}"`, {
        timeout: 180000,
        stdio: ['pipe', 'pipe', 'pipe']
      });
      // Only move to final path on success
      fs.renameSync(tmpPath, outputPath);
    } catch (err) {
      // Clean up temp file on failure
      try { fs.unlinkSync(tmpPath); } catch (_) {}
      const stderr = err.stderr ? err.stderr.toString() : '';
      throw new Error(`curl failed: ${stderr || err.message}`);
    }
  }

  /**
   * Download a Google Sheet as XLSX
   * @param {string} sheetId - Google Sheet document ID
   * @param {string} divisionName - Division name for logging
   * @returns {XLSX.WorkBook} Parsed workbook
   */
  downloadSheet(sheetId, divisionName) {
    const url = `https://docs.google.com/spreadsheets/d/${sheetId}/export?format=xlsx`;
    const cachePath = path.join(this.cacheDir, this._cacheFilename(divisionName));

    console.log(`   🌐 Downloading: ${divisionName}`);
    console.log(`      ${url}`);

    this._download(url, cachePath);
    const stats = fs.statSync(cachePath);
    console.log(`      ✓ Saved: ${path.basename(cachePath)} (${(stats.size / 1024).toFixed(0)} KB)`);

    const buffer = fs.readFileSync(cachePath);
    return XLSX.read(buffer, { type: 'buffer', cellDates: true });
  }

  /**
   * Parse a single team tab from a workbook
   * @param {XLSX.WorkBook} workbook - Parsed XLSX workbook
   * @param {string} tabName - Sheet tab name
   * @param {string} teamName - DB team name
   * @param {string} divisionName - Division name
   * @returns {Object[]} Array of player objects
   */
  parseTeamTab(workbook, tabName, teamName, divisionName) {
    const sheet = workbook.Sheets[tabName];
    if (!sheet) {
      console.log(`      ⚠️  Tab "${tabName}" not found in workbook`);
      return [];
    }

    // Convert to array of arrays
    const rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: null });
    const players = [];

    // Find the header row (contains "First Name")
    let headerRowIdx = -1;
    for (let i = 0; i < Math.min(rows.length, 15); i++) {
      const row = rows[i];
      if (row && row.some(cell => cell && String(cell).toLowerCase().includes('first name'))) {
        headerRowIdx = i;
        break;
      }
    }

    if (headerRowIdx === -1) {
      console.log(`      ⚠️  No header row found in tab "${tabName}"`);
      return [];
    }

    // Map column positions from header
    const headers = rows[headerRowIdx].map(h => h ? String(h).toLowerCase().trim() : '');
    const colMap = {
      firstName: headers.indexOf('first name'),
      lastName: headers.indexOf('last name'),
      dob: headers.indexOf('date of birth'),
      jerseyNumber: headers.indexOf('jersey #'),
      dateAdded: headers.indexOf('date added')
    };

    // Extract manager name from row 4 (col D = index 3)
    let manager = null;
    for (let i = 2; i < Math.min(rows.length, 8); i++) {
      const row = rows[i];
      if (row && row.some(cell => cell && String(cell).toLowerCase().includes('manager'))) {
        // Manager name is typically the next non-null cell
        const managerIdx = row.findIndex(cell => cell && String(cell).toLowerCase().includes('manager'));
        manager = row[managerIdx + 1] || null;
        break;
      }
    }

    // Parse player rows (start after header row)
    for (let i = headerRowIdx + 1; i < rows.length; i++) {
      const row = rows[i];
      if (!row) continue;

      const firstName = colMap.firstName >= 0 ? row[colMap.firstName] : null;
      const lastName = colMap.lastName >= 0 ? row[colMap.lastName] : null;

      // Skip empty rows or non-player rows
      if (!firstName || !lastName) continue;
      if (String(firstName).trim() === '' || String(lastName).trim() === '') continue;

      // Parse jersey number
      let jerseyNumber = null;
      if (colMap.jerseyNumber >= 0 && row[colMap.jerseyNumber] != null) {
        const jn = parseInt(row[colMap.jerseyNumber]);
        if (!isNaN(jn)) jerseyNumber = jn;
      }

      // Parse date of birth
      let dateOfBirth = null;
      if (colMap.dob >= 0 && row[colMap.dob]) {
        const dob = row[colMap.dob];
        let parsed;
        if (dob instanceof Date) {
          parsed = dob;
        } else {
          parsed = new Date(dob);
        }
        if (parsed && !isNaN(parsed.getTime())) {
          const year = parsed.getFullYear();
          // Sanity check: valid birth years for soccer players
          if (year >= 1950 && year <= 2010) {
            dateOfBirth = parsed.toISOString().split('T')[0];
          }
        }
      }

      players.push({
        firstName: String(firstName).trim(),
        lastName: String(lastName).trim(),
        dateOfBirth,
        jerseyNumber,
        teamName,
        divisionName
      });
    }

    return players;
  }

  /**
   * Get the cache filename for a division's XLSX
   * @param {string} divisionName
   * @returns {string} Filename
   */
  _cacheFilename(divisionName) {
    return `roster-${divisionName.toLowerCase().replace(/\s+/g, '-')}.xlsx`;
  }

  /**
   * Parse a single workbook using the tabMap config
   * @param {XLSX.WorkBook} workbook
   * @param {Object} sheetConfig - { sheetId, tabMap }
   * @param {string} divisionName
   * @returns {{ players: Object[], teamSummaries: Object }}
   */
  _parseWorkbook(workbook, sheetConfig, divisionName) {
    const players = [];
    const teamSummaries = {};

    const availableTabs = workbook.SheetNames;
    console.log(`   📋 Tabs: ${availableTabs.length} total`);

    for (const [tabName, teamName] of Object.entries(sheetConfig.tabMap)) {
      const teamPlayers = this.parseTeamTab(workbook, tabName, teamName, divisionName);

      if (teamPlayers.length > 0) {
        players.push(...teamPlayers);
        teamSummaries[teamName] = {
          division: divisionName,
          tab: tabName,
          playerCount: teamPlayers.length
        };
        console.log(`   ✓ ${teamName}: ${teamPlayers.length} players`);
      } else {
        console.log(`   ⚠️  ${teamName} (tab: "${tabName}"): no players found`);
      }
    }

    return { players, teamSummaries };
  }

  /**
   * Download all roster sheets from Google and cache as XLSX
   * @returns {Object} { players: [...], teamSummaries: {...} }
   */
  scrape() {
    console.log('\n👥 CASA Roster Scraper (download mode)');
    console.log('='.repeat(60));

    const allPlayers = [];
    const allSummaries = {};
    const entries = Object.entries(this.rosterSheets);

    for (let i = 0; i < entries.length; i++) {
      const [divisionName, sheetConfig] = entries[i];
      console.log(`\n📂 ${divisionName}`);

      // Delay between downloads to avoid Google rate limiting
      if (i > 0) {
        console.log('   ⏳ Waiting 5s between downloads...');
        execSync('sleep 5');
      }

      let workbook;
      try {
        workbook = this.downloadSheet(sheetConfig.sheetId, divisionName);
      } catch (err) {
        console.log(`   ❌ Failed to download: ${err.message}`);
        continue;
      }

      const { players, teamSummaries } = this._parseWorkbook(workbook, sheetConfig, divisionName);
      allPlayers.push(...players);
      Object.assign(allSummaries, teamSummaries);
    }

    console.log(`\n✅ Roster scrape complete`);
    console.log(`   Teams: ${Object.keys(allSummaries).length}`);
    console.log(`   Players: ${allPlayers.length}`);

    return { players: allPlayers, teamSummaries: allSummaries };
  }

  /**
   * Parse roster data from cached XLSX files (no network access)
   * Used by generate-sql.js during offline parse phase.
   * @returns {{ players: Object[], teamSummaries: Object }}
   */
  parseFromCache() {
    console.log('\n👥 CASA Roster Parser (cache mode)');
    console.log('='.repeat(60));

    const allPlayers = [];
    const allSummaries = {};

    for (const [divisionName, sheetConfig] of Object.entries(this.rosterSheets)) {
      console.log(`\n📂 ${divisionName}`);

      const cachePath = path.join(this.cacheDir, this._cacheFilename(divisionName));
      if (!fs.existsSync(cachePath)) {
        console.log(`   ⚠️  Cached file not found: ${path.basename(cachePath)}`);
        console.log(`      Run CasaRosterScraper in download mode first`);
        continue;
      }

      console.log(`   📖 Reading: ${path.basename(cachePath)}`);
      const buffer = fs.readFileSync(cachePath);
      const workbook = XLSX.read(buffer, { type: 'buffer', cellDates: true });

      const { players, teamSummaries } = this._parseWorkbook(workbook, sheetConfig, divisionName);
      allPlayers.push(...players);
      Object.assign(allSummaries, teamSummaries);
    }

    console.log(`\n✅ Roster parse complete`);
    console.log(`   Teams: ${Object.keys(allSummaries).length}`);
    console.log(`   Players: ${allPlayers.length}`);

    return { players: allPlayers, teamSummaries: allSummaries };
  }

  /**
   * Scrape (download) and save results to a JSON file
   * @returns {Object} Same as scrape()
   */
  scrapeAndSave() {
    const result = this.scrape();

    const outputPath = path.join(this.cacheDir, 'roster-data.json');
    fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
    console.log(`\n💾 Saved: ${outputPath}`);

    return result;
  }
}

module.exports = CasaRosterScraper;

// CLI: run standalone
if (require.main === module) {
  const configPath = path.join(__dirname, '../leagues/north-america/usa/casa/config.json');
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const cacheDir = path.join(__dirname, '../../scraped-html/casa');

  const scraper = new CasaRosterScraper(config, cacheDir);
  scraper.scrapeAndSave();
}
