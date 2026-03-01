#!/usr/bin/env node
/**
 * Fetch GroupMe calendar events (structured data) for all 5 Lighthouse groups
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
        catch(e) { console.log('RAW:', d.substring(0, 500)); reject(e); }
      });
    }).on('error', reject);
  });
}

const GROUPS = [
  { name: 'APSL Lighthouse', id: '109785985' },
  { name: 'Liga 1 & 2', id: '109786182' },
  { name: 'Old Timers', id: '109786278' },
  { name: 'Training', id: '108640377' },
  { name: 'Philly Pickup', id: '65284700' }
];

async function main() {
  for (const g of GROUPS) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`📱 ${g.name} (${g.id})`);
    console.log('='.repeat(60));

    try {
      const events = await apiGet(`/conversations/${g.id}/events/list`);
      if (events && events.events) {
        console.log(`  📅 ${events.events.length} events found\n`);
        for (const e of events.events) {
          const going = e.going || [];
          const notGoing = e.not_going || [];
          const undecided = e.maybe_going || [];
          console.log(`  🎯 "${e.name}"`);
          console.log(`     ID: ${e.event_id}`);
          console.log(`     Start: ${e.start_at}`);
          console.log(`     End: ${e.end_at || 'N/A'}`);
          console.log(`     Location: ${e.location ? e.location.name || e.location.address : 'N/A'}`);
          console.log(`     Going: ${going.length} | Not Going: ${notGoing.length} | Maybe: ${undecided.length}`);
          if (e.is_all_day) console.log(`     All Day: true`);
          console.log('');
        }
      } else {
        console.log('  No events found or unexpected format');
        if (events) console.log('  Keys:', Object.keys(events));
      }
    } catch(err) {
      console.log(`  Error: ${err.message}`);
    }
  }
}

main().catch(console.error);
