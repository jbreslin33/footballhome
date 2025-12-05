#!/usr/bin/env node
/**
 * GroupMe Scraper - Fetch messages and RSVPs from GroupMe groups
 * 
 * Usage:
 *   node scripts/groupme-scraper.js list                    - List all groups
 *   node scripts/groupme-scraper.js messages <group_id>     - Fetch messages from a group
 *   node scripts/groupme-scraper.js rsvp <group_id>         - Parse RSVPs from messages
 *   node scripts/groupme-scraper.js events <group_id>       - List events with RSVPs
 */

require('dotenv').config();
const https = require('https');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';

if (!ACCESS_TOKEN) {
  console.error('❌ Error: GROUPME_ACCESS_TOKEN not found in .env file');
  process.exit(1);
}

// Helper function to make GroupMe API requests
function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    
    https.get(url, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.response) {
            resolve(json.response);
          } else {
            reject(new Error('Invalid response from GroupMe API'));
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// List all groups
async function listGroups() {
  try {
    console.log('📋 Fetching your GroupMe groups...\n');
    
    const groups = await apiRequest('/groups');
    
    if (!groups || groups.length === 0) {
      console.log('No groups found.');
      return;
    }
    
    console.log(`Found ${groups.length} group(s):\n`);
    
    groups.forEach((group, index) => {
      console.log(`${index + 1}. ${group.name}`);
      console.log(`   ID: ${group.id}`);
      console.log(`   Members: ${group.members.length}`);
      console.log(`   Messages: ${group.messages.count}`);
      console.log(`   Created: ${new Date(group.created_at * 1000).toLocaleDateString()}`);
      console.log('');
    });
    
    console.log('\n💡 To fetch messages from a group, run:');
    console.log('   node scripts/groupme-scraper.js messages <GROUP_ID>');
    
  } catch (error) {
    console.error('❌ Error fetching groups:', error.message);
    process.exit(1);
  }
}

// Fetch messages from a specific group
async function fetchMessages(groupId, limit = 100) {
  try {
    console.log(`📨 Fetching messages from group ${groupId}...\n`);
    
    const messages = await apiRequest(`/groups/${groupId}/messages?limit=${limit}`);
    
    if (!messages || !messages.messages || messages.messages.length === 0) {
      console.log('No messages found.');
      return [];
    }
    
    console.log(`Found ${messages.messages.length} message(s):\n`);
    
    messages.messages.forEach((msg, index) => {
      const date = new Date(msg.created_at * 1000);
      console.log(`${index + 1}. [${date.toLocaleString()}] ${msg.name}: ${msg.text || '(attachment)'}`);
    });
    
    return messages.messages;
    
  } catch (error) {
    console.error('❌ Error fetching messages:', error.message);
    process.exit(1);
  }
}

// Parse RSVP responses from messages
async function parseRSVPs(groupId) {
  try {
    console.log(`🔍 Parsing RSVPs from group ${groupId}...\n`);
    
    const messages = await apiRequest(`/groups/${groupId}/messages?limit=100`);
    
    if (!messages || !messages.messages) {
      console.log('No messages found.');
      return;
    }
    
    // RSVP patterns
    const patterns = {
      yes: /\b(yes|in|attending|i'?m in|count me in|i'?ll be there|coming)\b/i,
      no: /\b(no|out|can'?t make it|won'?t make it|not coming|can'?t come)\b/i,
      maybe: /\b(maybe|might|possibly|not sure|tentative)\b/i
    };
    
    const rsvps = [];
    
    messages.messages.forEach((msg) => {
      if (!msg.text) return;
      
      let status = null;
      if (patterns.yes.test(msg.text)) status = 'yes';
      else if (patterns.no.test(msg.text)) status = 'no';
      else if (patterns.maybe.test(msg.text)) status = 'maybe';
      
      if (status) {
        const date = new Date(msg.created_at * 1000);
        rsvps.push({
          user: msg.name,
          user_id: msg.user_id,
          status: status,
          message: msg.text,
          timestamp: date.toLocaleString()
        });
      }
    });
    
    console.log(`Found ${rsvps.length} RSVP response(s):\n`);
    
    const summary = { yes: 0, no: 0, maybe: 0 };
    
    rsvps.forEach((rsvp) => {
      summary[rsvp.status]++;
      const icon = rsvp.status === 'yes' ? '✅' : rsvp.status === 'no' ? '❌' : '❓';
      console.log(`${icon} ${rsvp.user} (${rsvp.status}) - ${rsvp.timestamp}`);
      console.log(`   "${rsvp.message}"`);
      console.log('');
    });
    
    console.log('\n📊 Summary:');
    console.log(`   ✅ Yes: ${summary.yes}`);
    console.log(`   ❌ No: ${summary.no}`);
    console.log(`   ❓ Maybe: ${summary.maybe}`);
    
    return rsvps;
    
  } catch (error) {
    console.error('❌ Error parsing RSVPs:', error.message);
    process.exit(1);
  }
}

// Fetch events from a group
async function fetchEvents(groupId) {
  try {
    console.log(`📅 Fetching events from group ${groupId}...\n`);
    
    // First get the group info to access events
    const group = await apiRequest(`/groups/${groupId}`);
    
    if (!group) {
      console.log('Group not found.');
      return;
    }
    
    // GroupMe doesn't have a direct events API endpoint, so we need to parse event links from messages
    const messages = await apiRequest(`/groups/${groupId}/messages?limit=100`);
    
    if (!messages || !messages.messages) {
      console.log('No messages found.');
      return [];
    }
    
    // Find messages with event links
    const eventPattern = /https:\/\/groupme\.com\/join_event\/(\d+)\/([a-f0-9]+)/gi;
    const events = [];
    const seenEvents = new Set();
    
    messages.messages.forEach((msg) => {
      if (!msg.text) return;
      
      let match;
      while ((match = eventPattern.exec(msg.text)) !== null) {
        const eventId = match[2];
        
        if (!seenEvents.has(eventId)) {
          seenEvents.add(eventId);
          
          // Extract event details from the message
          const lines = msg.text.split('\n');
          const eventInfo = {
            eventId: eventId,
            groupId: match[1],
            creator: msg.name,
            created: new Date(msg.created_at * 1000).toLocaleString(),
            description: msg.text.substring(0, msg.text.indexOf('https://')).trim(),
            link: match[0]
          };
          
          events.push(eventInfo);
        }
      }
    });
    
    if (events.length === 0) {
      console.log('No events found in recent messages.');
      console.log('💡 Events are created through the GroupMe app and appear as special message links.');
      return [];
    }
    
    console.log(`Found ${events.length} event(s):\n`);
    
    events.forEach((event, index) => {
      console.log(`${index + 1}. Created by: ${event.creator}`);
      console.log(`   Date: ${event.created}`);
      console.log(`   Description: ${event.description || '(no description)'}`);
      console.log(`   Event ID: ${event.eventId}`);
      console.log(`   Link: ${event.link}`);
      console.log('');
    });
    
    console.log('💡 Note: GroupMe events API requires polling individual event attendance.');
    console.log('   The "rsvp" command shows who responded to practice invites.');
    
    return events;
    
  } catch (error) {
    console.error('❌ Error fetching events:', error.message);
    process.exit(1);
  }
}

// Main command handler
const command = process.argv[2];
const arg = process.argv[3];

switch (command) {
  case 'list':
    listGroups();
    break;
  
  case 'messages':
    if (!arg) {
      console.error('❌ Error: Please provide a group ID');
      console.log('Usage: node scripts/groupme-scraper.js messages <GROUP_ID>');
      process.exit(1);
    }
    fetchMessages(arg);
    break;
  
  case 'rsvp':
    if (!arg) {
      console.error('❌ Error: Please provide a group ID');
      console.log('Usage: node scripts/groupme-scraper.js rsvp <GROUP_ID>');
      process.exit(1);
    }
    parseRSVPs(arg);
    break;
  
  case 'events':
    if (!arg) {
      console.error('❌ Error: Please provide a group ID');
      console.log('Usage: node scripts/groupme-scraper.js events <GROUP_ID>');
      process.exit(1);
    }
    fetchEvents(arg);
    break;
  
  default:
    console.log('GroupMe Scraper\n');
    console.log('Usage:');
    console.log('  node scripts/groupme-scraper.js list                 - List all groups');
    console.log('  node scripts/groupme-scraper.js messages <GROUP_ID>  - Fetch messages');
    console.log('  node scripts/groupme-scraper.js rsvp <GROUP_ID>      - Parse RSVPs');
    console.log('  node scripts/groupme-scraper.js events <GROUP_ID>    - List events');
    break;
}
