#!/usr/bin/env node
/**
 * Dump GroupMe Calendar Events to JSON
 * 
 * Fetches all calendar events from GroupMe and saves the raw JSON
 * so we can see exactly what data is available.
 */

require('dotenv').config();
const https = require('https');
const fs = require('fs');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';

const groupId = process.argv[2] || '108640377';

if (!ACCESS_TOKEN) {
  console.error('❌ GROUPME_ACCESS_TOKEN not found in .env');
  process.exit(1);
}

function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.response || json);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function dumpEvents() {
  console.log(`📅 Fetching events from group ${groupId}...`);
  
  const response = await apiRequest(`/conversations/${groupId}/events/list`);
  const events = response.events || response;
  
  console.log(`✅ Found ${events.length} events\n`);
  
  // Save full response
  const filename = `groupme-events-${groupId}.json`;
  fs.writeFileSync(filename, JSON.stringify(events, null, 2));
  console.log(`💾 Saved to ${filename}`);
  
  // Show summary
  console.log('\n📊 Event Summary:');
  events.forEach((event, i) => {
    console.log(`\n${i + 1}. ${event.name}`);
    console.log(`   Date: ${new Date(event.start_at).toLocaleString()}`);
    console.log(`   Going: ${event.going?.length || 0}`);
    console.log(`   Not Going: ${event.not_going?.length || 0}`);
    console.log(`   Has rsvp_list: ${event.rsvp_list ? 'YES' : 'NO'}`);
    console.log(`   Event ID: ${event.event_id}`);
  });
  
  console.log('\n✨ Check the JSON file to see ALL available fields!');
}

dumpEvents().catch(console.error);
