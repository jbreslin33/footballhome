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
    this.lighthouseOnly = process.env.LIGHTHOUSE_ONLY === '1';
    this.lighthouseDivisionNames = new Set((config.lighthouseScope?.divisionNames || []).map(name => this._normalizeName(name)));
    this.lighthouseTeamNames = new Set((config.lighthouseScope?.teamNames || []).map(name => this._normalizeName(name)));
    this.rosterSheets = this._filterRosterSheets(config.rosterSheets || {});
  }

  _normalizeName(name) {
    return String(name || '').trim().toLowerCase();
  }

  _isLighthouseTeam(teamName) {
    if (!this.lighthouseOnly || this.lighthouseTeamNames.size === 0) {
      return true;
    }
    return this.lighthouseTeamNames.has(this._normalizeName(teamName));
  }

  _filterRosterSheets(rosterSheets) {
    if (!this.lighthouseOnly) {
      return rosterSheets;
    }

    const filteredSheets = {};

    for (const [divisionName, sheetConfig] of Object.entries(rosterSheets)) {
      if (this.lighthouseDivisionNames.size > 0 && !this.lighthouseDivisionNames.has(this._normalizeName(divisionName))) {
        continue;
      }

      const filteredTabMap = Object.fromEntries(
        Object.entries(sheetConfig.tabMap || {}).filter(([, teamName]) => this._isLighthouseTeam(teamName))
      );

      if (Object.keys(filteredTabMap).length === 0) {
        continue;
      }

      filteredSheets[divisionName] = {
        ...sheetConfig,
        tabMap: filteredTabMap
      };
    }

    return filteredSheets;
  }

  /**
   * Download a file from a URL using curl (HTTP/1.1 for Google Sheets compatibility)
   * Downloads to a temp file first, then moves on success to avoid corrupting cache.
   * Validates the response is actually a spreadsheet (not an HTML error page).
   * @param {string} url - URL to download
   * @param {string} outputPath - Path to save the file
   */
  _download(url, outputPath) {
    const tmpPath = outputPath + '.tmp';
    try {
      // Use curl with HTTP/1.1 — Google Sheets HTTP/2 export aborts on large files
      // Write HTTP code to stderr so we can check it
      const result = execSync(
        `curl --http1.1 -L -sS --retry 2 --retry-delay 5 -w "%{http_code}" -o "${tmpPath}" "${url}"`,
        { timeout: 180000, stdio: ['pipe', 'pipe', 'pipe'] }
      );
      const httpCode = result.toString().trim();

      // Check HTTP status
      if (httpCode !== '200') {
        try { fs.unlinkSync(tmpPath); } catch (_) {}
        throw new Error(`HTTP ${httpCode} from Google Sheets`);
      }

      // Validate it's not an HTML error page
      const head = Buffer.alloc(100);
      const fd = fs.openSync(tmpPath, 'r');
      fs.readSync(fd, head, 0, 100, 0);
      fs.closeSync(fd);
      const headerStr = head.toString('utf8').trim();
      if (headerStr.startsWith('<!DOCTYPE') || headerStr.startsWith('<html')) {
        try { fs.unlinkSync(tmpPath); } catch (_) {}
        throw new Error('Google returned HTML error page instead of spreadsheet');
      }

      // Only move to final path on success
      fs.renameSync(tmpPath, outputPath);
    } catch (err) {
      // Clean up temp file on failure
      try { fs.unlinkSync(tmpPath); } catch (_) {}
      if (err.message.startsWith('HTTP ') || err.message.startsWith('Google returned')) throw err;
      const stderr = err.stderr ? err.stderr.toString() : '';
      throw new Error(`curl failed: ${stderr || err.message}`);
    }
  }

  /**
   * Download a Google Sheet as XLSX (with per-tab CSV fallback for old-format Drive files)
   * @param {string} sheetId - Google Sheet document ID
   * @param {string} divisionName - Division name for logging
   * @param {Object} tabMap - Tab name → DB team name mapping (needed for CSV fallback)
   * @returns {XLSX.WorkBook} Parsed workbook
   */
  downloadSheet(sheetId, divisionName, tabMap) {
    const cachePath = path.join(this.cacheDir, this._cacheFilename(divisionName));

    // Try xlsx export first (works for native Google Sheets)
    const xlsxUrl = `https://docs.google.com/spreadsheets/d/${sheetId}/export?format=xlsx`;
    console.log(`   🌐 Downloading: ${divisionName}`);
    console.log(`      ${xlsxUrl}`);

    try {
      this._download(xlsxUrl, cachePath);
    } catch (xlsxErr) {
      // Fallback: download each tab individually as CSV via gviz API
      // (old uploaded .xls files can't export as xlsx but per-tab CSV works)
      console.log(`      ⚠️  XLSX export failed (${xlsxErr.message}), trying per-tab CSV fallback...`);
      // Remove stale XLSX so parseFromCache() uses the fresh CSVs
      if (fs.existsSync(cachePath)) {
        fs.unlinkSync(cachePath);
      }
      return this._downloadTabsAsCsv(sheetId, divisionName, tabMap);
    }

    const stats = fs.statSync(cachePath);
    console.log(`      ✓ Saved: ${path.basename(cachePath)} (${(stats.size / 1024).toFixed(0)} KB)`);

    const buffer = fs.readFileSync(cachePath);
    return XLSX.read(buffer, { type: 'buffer', cellDates: true });
  }

  /**
   * Download individual tabs as CSV and assemble into a multi-sheet workbook.
   * Used when xlsx export fails (old uploaded .xls files on Google Drive).
   * Each tab is fetched via gviz API with &sheet= parameter and cached individually.
   * @param {string} sheetId - Google Sheet document ID
   * @param {string} divisionName - Division name for logging
   * @param {Object} tabMap - Tab name → DB team name mapping
   * @returns {XLSX.WorkBook} Assembled workbook with one sheet per tab
   */
  _downloadTabsAsCsv(sheetId, divisionName, tabMap) {
    const workbook = XLSX.utils.book_new();
    const tabNames = Object.keys(tabMap);
    const divSlug = divisionName.toLowerCase().replace(/\s+/g, '-');
    let totalSize = 0;

    for (const tabName of tabNames) {
      const csvUrl = `https://docs.google.com/spreadsheets/d/${sheetId}/gviz/tq?tqx=out:csv&sheet=${encodeURIComponent(tabName)}`;
      const tabSlug = tabName.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
      const csvPath = path.join(this.cacheDir, `roster-${divSlug}-${tabSlug}.csv`);

      console.log(`      📋 Tab: ${tabName}`);
      try {
        this._download(csvUrl, csvPath);
        const csvBuffer = fs.readFileSync(csvPath);
        const stats = fs.statSync(csvPath);
        totalSize += stats.size;
        console.log(`         ✓ ${(stats.size / 1024).toFixed(0)} KB`);

        // Parse CSV into a worksheet and add to workbook with the tab name
        const tabWorkbook = XLSX.read(csvBuffer, { type: 'buffer', cellDates: true });
        const firstSheet = tabWorkbook.Sheets[tabWorkbook.SheetNames[0]];
        XLSX.utils.book_append_sheet(workbook, firstSheet, tabName);
      } catch (err) {
        console.log(`         ❌ Failed: ${err.message}`);
      }
    }

    console.log(`      ✓ Assembled ${workbook.SheetNames.length}/${tabNames.length} tabs (${(totalSize / 1024).toFixed(0)} KB total) [per-tab CSV fallback]`);
    return workbook;
  }

  /**
   * Assemble a workbook from cached per-tab CSV files (for parseFromCache).
   * These are created by _downloadTabsAsCsv during scrape phase.
   * @param {string} divisionName
   * @param {Object} tabMap - Tab name → DB team name mapping
   * @returns {XLSX.WorkBook|null} Assembled workbook, or null if no tab CSVs found
   */
  _assembleFromTabCsvs(divisionName, tabMap) {
    const divSlug = divisionName.toLowerCase().replace(/\s+/g, '-');
    const tabNames = Object.keys(tabMap);
    const workbook = XLSX.utils.book_new();
    let found = 0;

    for (const tabName of tabNames) {
      const tabSlug = tabName.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
      const csvPath = path.join(this.cacheDir, `roster-${divSlug}-${tabSlug}.csv`);
      if (!fs.existsSync(csvPath)) continue;

      try {
        const csvBuffer = fs.readFileSync(csvPath);
        const tabWorkbook = XLSX.read(csvBuffer, { type: 'buffer', cellDates: true });
        const firstSheet = tabWorkbook.Sheets[tabWorkbook.SheetNames[0]];
        XLSX.utils.book_append_sheet(workbook, firstSheet, tabName);
        found++;
      } catch (err) {
        console.log(`   ⚠️  Error reading ${path.basename(csvPath)}: ${err.message}`);
      }
    }

    if (found === 0) return null;
    console.log(`   📖 Assembled ${found}/${tabNames.length} tabs from cached CSVs`);
    return workbook;
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
   * Parse a flat roster sheet where all players are in one sheet.
   * Uses the "Team" column to assign players to teams via the tabMap.
   * Falls back to this when the workbook has no matching team tabs (e.g. CSV fallback).
   * @param {XLSX.WorkBook} workbook
   * @param {Object} sheetConfig - { sheetId, tabMap }
   * @param {string} divisionName
   * @returns {{ players: Object[], teamSummaries: Object }}
   */
  _parseFlatRoster(workbook, sheetConfig, divisionName) {
    const players = [];
    const teamSummaries = {};
    const sheet = workbook.Sheets[workbook.SheetNames[0]];

    // Convert to array of arrays
    const rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: null });

    // Find header row
    let headerRowIdx = -1;
    for (let i = 0; i < Math.min(rows.length, 15); i++) {
      const row = rows[i];
      if (row && row.some(cell => cell && String(cell).toLowerCase().includes('first name'))) {
        headerRowIdx = i;
        break;
      }
    }
    if (headerRowIdx === -1) {
      console.log(`   ⚠️  No header row found in flat roster`);
      return { players, teamSummaries };
    }

    const headers = rows[headerRowIdx].map(h => h ? String(h).toLowerCase().trim() : '');
    const colMap = {
      firstName: headers.indexOf('first name'),
      lastName: headers.indexOf('last name'),
      dob: headers.indexOf('date of birth'),
      team: headers.indexOf('team'),
    };

    // Build reverse lookup: normalize team column values → DB team names
    // tabMap keys are tab names but may also match team column values
    const teamLookup = new Map();
    for (const [tabName, teamName] of Object.entries(sheetConfig.tabMap)) {
      teamLookup.set(tabName.toLowerCase().trim(), teamName);
      teamLookup.set(teamName.toLowerCase().trim(), teamName);
    }

    let assigned = 0;
    let unassigned = 0;

    for (let i = headerRowIdx + 1; i < rows.length; i++) {
      const row = rows[i];
      if (!row) continue;

      const firstName = colMap.firstName >= 0 ? row[colMap.firstName] : null;
      const lastName = colMap.lastName >= 0 ? row[colMap.lastName] : null;
      if (!firstName || !lastName) continue;
      if (String(firstName).trim() === '' || String(lastName).trim() === '') continue;

      // Try to resolve team from "Team" column
      let teamName = null;
      if (colMap.team >= 0 && row[colMap.team]) {
        const rawTeam = String(row[colMap.team]).trim();
        if (rawTeam !== '') {
          teamName = teamLookup.get(rawTeam.toLowerCase()) || rawTeam;
        }
      }

      // Parse DOB
      let dateOfBirth = null;
      if (colMap.dob >= 0 && row[colMap.dob]) {
        const dob = row[colMap.dob];
        const parsed = dob instanceof Date ? dob : new Date(dob);
        if (parsed && !isNaN(parsed.getTime())) {
          const year = parsed.getFullYear();
          if (year >= 1950 && year <= 2010) {
            dateOfBirth = parsed.toISOString().split('T')[0];
          }
        }
      }

      if (teamName) {
        assigned++;
      } else {
        unassigned++;
      }

      players.push({
        firstName: String(firstName).trim(),
        lastName: String(lastName).trim(),
        dateOfBirth,
        jerseyNumber: null,
        teamName: teamName || '__unassigned__',
        divisionName
      });
    }

    // Build summaries for assigned players
    for (const p of players) {
      if (p.teamName === '__unassigned__') continue;
      if (!teamSummaries[p.teamName]) {
        teamSummaries[p.teamName] = { division: divisionName, tab: 'flat', playerCount: 0 };
      }
      teamSummaries[p.teamName].playerCount++;
    }

    if (assigned > 0) {
      for (const [team, summary] of Object.entries(teamSummaries)) {
        console.log(`   ✓ ${team}: ${summary.playerCount} players (from Team column)`);
      }
    }
    if (unassigned > 0) {
      console.log(`   ⚠️  ${unassigned} players have no team assignment — skipping them`);
      // Remove unassigned players (can't generate SQL without a team)
      const assignedPlayers = players.filter(p => p.teamName !== '__unassigned__');
      return { players: assignedPlayers, teamSummaries };
    }

    return { players, teamSummaries };
  }

  /**
   * Parse a single workbook using the tabMap config.
   * Falls back to flat roster parsing if no matching tabs found (CSV fallback sheets).
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

    // Check if any configured tabs exist in this workbook
    const configuredTabs = Object.keys(sheetConfig.tabMap);
    const matchingTabs = configuredTabs.filter(t => availableTabs.includes(t));

    // If no tabs match (e.g. CSV fallback with single sheet), try flat roster parsing
    if (matchingTabs.length === 0 && availableTabs.length > 0) {
      console.log(`   📋 No matching team tabs found (available: ${availableTabs.join(', ')})`);
      console.log(`   📋 Trying flat roster parse with Team column...`);
      return this._parseFlatRoster(workbook, sheetConfig, divisionName);
    }

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
        workbook = this.downloadSheet(sheetConfig.sheetId, divisionName, sheetConfig.tabMap);
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

      // Check for xlsx first, then fall back to per-tab CSVs (from CSV fallback downloads)
      let cachePath = path.join(this.cacheDir, this._cacheFilename(divisionName));
      if (!fs.existsSync(cachePath)) {
        // Try to assemble workbook from per-tab CSV files
        const workbook = this._assembleFromTabCsvs(divisionName, sheetConfig.tabMap);
        if (workbook) {
          const { players, teamSummaries } = this._parseWorkbook(workbook, sheetConfig, divisionName);
          allPlayers.push(...players);
          Object.assign(allSummaries, teamSummaries);
          continue;
        }
        console.log(`   ⚠️  Cached file not found: ${path.basename(cachePath)}`);
        console.log(`      Run CasaRosterScraper in download mode first`);
        continue;
      }

      console.log(`   📖 Reading: ${path.basename(cachePath)}`);
      
      let workbook;
      try {
        const buffer = fs.readFileSync(cachePath);
        workbook = XLSX.read(buffer, { type: 'buffer', cellDates: true });
      } catch (err) {
        console.warn(`   ⚠️  Corrupt/invalid file (${err.message}) — skipping ${divisionName}`);
        console.warn(`      Re-run scrape to re-download this file`);
        continue;
      }

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
