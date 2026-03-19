#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Update Scrape Status Manifest
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Records the timestamp and status of a scrape operation.
// Called at the end of each scrape-*.sh script.
//
// Usage:
//   node update-scrape-status.js <key> [status] [details]
//
// Keys:
//   apsl-standings    APSL standings page
//   apsl-teams        APSL team pages (rosters + schedule)
//   csl-standings     CSL standings page
//   csl-teams         CSL team pages (rosters + schedule)
//   casa-standings    CASA standings (Puppeteer)
//   casa-rosters      CASA rosters (Google Sheets)
//   casa-schedule     CASA schedule (SportsEngine API)
//
// Status: success (default), error, skipped
//
// Examples:
//   node update-scrape-status.js apsl-standings
//   node update-scrape-status.js apsl-standings success "80 teams found"
//   node update-scrape-status.js csl-teams error "403 Forbidden"
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');

const key = process.argv[2];
const status = process.argv[3] || 'success';
const details = process.argv[4] || '';

if (!key) {
  console.error('Usage: node update-scrape-status.js <key> [status] [details]');
  process.exit(1);
}

const manifestPath = path.join(__dirname, '..', 'data', 'scrape-status.json');

let manifest = {};
if (fs.existsSync(manifestPath)) {
  try {
    manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  } catch (e) {
    // Corrupted file — start fresh
    manifest = {};
  }
}

manifest[key] = {
  updatedAt: new Date().toISOString(),
  status: status,
  details: details || undefined
};

fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
