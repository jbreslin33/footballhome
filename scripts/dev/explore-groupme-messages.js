#!/usr/bin/env node
/**
 * Explore GroupMe messages to understand format for practice/game parsing
 */
require('dotenv').config();
const https = require('https');

const TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE = 'https://api.groupme.com/v3';

function apiGet(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE}${path}${path.includes('?') ? '&' : '?'}token=${TOKEN}`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.response);
        } catch(e) { reject(e); }
      });
    }).on('error', reject);
  });
}

const GROUPS = [
  { name: 'APSL Lighthouse', id: '109785985' },
  { name: 'Lighthouse Boys Club (Liga 1)', id: '109786182' },
  { name: 'Lighthouse Old Timers Club (Liga 2)', id: '109786278' },
  { name: 'Training Lighthouse', id: '108640377' }
];

async function main() {
  for (const group of GROUPS) {
    console.log(`\n${'='.repeat(70)}`);
    console.log(`📱 ${group.name} (${group.id})`);
    console.log('='.repeat(70));

    // Fetch last 40 messages
    const msgs = await apiGet(`/groups/${group.id}/messages?limit=40`);
    if (!msgs || !msgs.messages) {
      console.log('   No messages found');
      continue;
    }

    // Look for messages that might be about practices or games
    const keywords = /practice|game|match|cup|field|scrimmage|training|kickoff|lineup|saturday|sunday|tuesday|wednesday|thursday|vs\b|versus|epsa|state cup/i;

    for (const msg of msgs.messages) {
      const text = msg.text || '';
      const isRelevant = keywords.test(text);
      const date = new Date(msg.created_at * 1000);
      const dateStr = date.toISOString().substring(0, 10);
      
      // Show relevant messages in full, others just summarized
      if (isRelevant) {
        console.log(`\n  🔵 [${dateStr}] ${msg.name}:`);
        console.log(`     "${text.substring(0, 300)}${text.length > 300 ? '...' : ''}"`);
        if (msg.attachments && msg.attachments.length > 0) {
          console.log(`     📎 Attachments: ${JSON.stringify(msg.attachments.map(a => a.type))}`);
        }
        // Check for event-type attachments
        if (msg.event) {
          console.log(`     📅 Event: ${JSON.stringify(msg.event)}`);
        }
      }
    }

    // Also check if the group has any calendar events
    try {
      const groupInfo = await apiGet(`/groups/${group.id}`);
      if (groupInfo) {
        console.log(`\n  ℹ️  Group members: ${groupInfo.members?.length || 0}`);
        console.log(`  ℹ️  Message count: ${groupInfo.messages?.count || 0}`);
      }
    } catch(e) {}
  }
}

main().catch(console.error);
