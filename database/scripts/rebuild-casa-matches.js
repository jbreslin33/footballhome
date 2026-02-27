#!/usr/bin/env node
/**
 * Rebuild CASA division-matches.json from cached frame HTML files
 * 
 * The CASA scraper saves frame HTML for each division's schedule.
 * This script re-parses those saved HTML files to extract matches,
 * useful when the scraper fails partway through (e.g., connection errors).
 */

const fs = require('fs');
const { JSDOM } = require('jsdom');
const casaDir = require('path').join(__dirname, '../scraped-html/casa');

const divisionMap = {
  '9090889': { name: 'Philadelphia Liga 1', id: 61 },
  '9096430': { name: 'Philadelphia Liga 2', id: 62 },
  '9090891': { name: 'Boston Liga 1', id: 63 },
  '9090893': { name: 'Lancaster Liga 1', id: 64 }
};

const divisions = [];
let totalMatches = 0;

for (const [extId, div] of Object.entries(divisionMap)) {
  const file = `${casaDir}/schedule-${extId}-frame.html`;
  if (fs.existsSync(file) === false) {
    console.log(`MISSING: ${file}`);
    continue;
  }
  
  const html = fs.readFileSync(file, 'utf-8');
  const dom = new JSDOM(html);
  const events = dom.window.document.querySelectorAll('sm-schedule-event');
  
  const matches = [];
  events.forEach(event => {
    const awayEl = event.querySelector('[tag="away-team-name"]');
    const homeEl = event.querySelector('[tag="home-team-name"]');
    const outsideHome = event.querySelector('[data-cy="outside-home-team"]');
    const timeEl = event.querySelector('[data-cy="event-time"]');
    const statusEl = event.querySelector('[data-cy="event-status"]');
    const scoreEl = event.querySelector('[data-cy="event-score"]');
    
    const home = homeEl ? homeEl.textContent.trim() : (outsideHome ? outsideHome.textContent.trim() : null);
    const away = awayEl ? awayEl.textContent.trim() : null;
    const time = timeEl ? timeEl.textContent.trim() : null;
    const status = statusEl ? statusEl.textContent.trim() : null;
    const score = scoreEl ? scoreEl.textContent.trim() : null;
    
    if (home && away) {
      matches.push({ home, away, time, status: status === 'Final' ? 'Final' : status, score });
    }
  });
  
  totalMatches += matches.length;
  divisions.push({
    id: div.id,
    name: div.name,
    external_id: extId,
    match_count: matches.length,
    matches
  });
  console.log(`${div.name}: ${matches.length} matches (from ${events.length} events)`);
}

const result = { generated: new Date().toISOString(), total_matches: totalMatches, divisions };
fs.writeFileSync(`${casaDir}/division-matches.json`, JSON.stringify(result, null, 2));
console.log(`\nTotal: ${totalMatches} matches written to division-matches.json`);
