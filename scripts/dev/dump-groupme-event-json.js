#!/usr/bin/env node
/**
 * Dump full JSON for one event from each group to see complete structure
 */
require('dotenv').config();
const https = require('https');

const TOKEN = process.env.GROUPME_ACCESS_TOKEN;

function apiGet(path) {
  return new Promise((resolve, reject) => {
    const url = `https://api.groupme.com/v3${path}${path.includes('?') ? '&' : '?'}token=${TOKEN}`;
    https.get(url, res => {
      let d = '';
      res.on('data', c => d += c);
      res.on('end', () => {
        try { resolve(JSON.parse(d).response); }
        catch(e) { console.log('RAW:', d.substring(0, 1000)); reject(e); }
      });
    }).on('error', reject);
  });
}

async function main() {
  // Fetch full event list from APSL Lighthouse (has a cup game)
  const events = await apiGet('/conversations/109785985/events/list');
  console.log('=== FULL EVENT JSON (APSL Lighthouse first event) ===');
  console.log(JSON.stringify(events.events[0], null, 2));

  // Also get Training group first event to see practice structure
  const training = await apiGet('/conversations/108640377/events/list');
  console.log('\n=== FULL EVENT JSON (Training first event) ===');
  console.log(JSON.stringify(training.events[0], null, 2));
}

main().catch(console.error);
