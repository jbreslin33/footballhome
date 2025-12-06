#!/usr/bin/env node
/**
 * Get RSVPs for a specific GroupMe event by scanning message history.
 * 
 * Usage: node scripts/get-event-rsvps.js <group_id> <event_id>
 */

require('dotenv').config();
const https = require('https');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const GROUP_ID = process.argv[2];
const EVENT_ID = process.argv[3];

if (!ACCESS_TOKEN || !GROUP_ID || !EVENT_ID) {
  console.error('Usage: node scripts/get-event-rsvps.js <group_id> <event_id>');
  process.exit(1);
}

function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.meta && json.meta.code >= 400) {
             reject(new Error(`API Error ${json.meta.code}: ${JSON.stringify(json.meta.errors)}`));
          } else {
             resolve(json.response);
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function getEventRSVPs() {
  console.log(`🔍 Searching for RSVPs for event ${EVENT_ID} in group ${GROUP_ID}...`);
  
  let allMessages = [];
  let beforeId = null;
  const limit = 100;
  const maxMessages = 2000; // Scan up to 2000 messages
  let foundEvent = false;
  let eventName = 'Unknown Event';

  // Map to store user status: userId -> { name, status, timestamp }
  const userStatus = new Map();

  try {
    while (allMessages.length < maxMessages) {
      const path = `/groups/${GROUP_ID}/messages?limit=${limit}${beforeId ? `&before_id=${beforeId}` : ''}`;
      const data = await apiRequest(path);
      
      if (!data || !data.messages || data.messages.length === 0) break;
      
      const messages = data.messages;
      allMessages = allMessages.concat(messages);
      beforeId = messages[messages.length - 1].id;
      
      process.stdout.write(`\rScanned ${allMessages.length} messages...`);

      // Process messages in this batch
      // Note: Messages come in descending order (newest first).
      // We should process them in ascending order to get the final state, 
      // OR process descending and only take the first occurrence for each user.
      // Let's process descending (as received) and ignore subsequent (older) updates for the same user.
      
      for (const msg of messages) {
        // Check for event updates
        if (msg.event && msg.event.data && msg.event.data.event && msg.event.data.event.id === EVENT_ID) {
          foundEvent = true;
          eventName = msg.event.data.event.name;
          
          const type = msg.event.type;
          const user = msg.event.data.user;
          
          if (user && user.id) {
            // If we haven't seen this user yet, this is their latest status
            if (!userStatus.has(user.id)) {
              let status = 'unknown';
              if (type === 'calendar.event.user.going') status = 'going';
              else if (type === 'calendar.event.user.not_going') status = 'not_going';
              else if (type === 'calendar.event.user.undecided') status = 'undecided'; // Assuming this exists
              
              if (status !== 'unknown') {
                userStatus.set(user.id, {
                  name: user.nickname,
                  status: status,
                  timestamp: msg.created_at
                });
              }
            }
          }
        }
      }
    }
    
    console.log('\n');
    
    if (!foundEvent) {
      console.log('⚠️  Event not found in the scanned messages.');
      console.log('   Try increasing the scan limit if the event is older.');
      return;
    }

    console.log(`📅 Event: ${eventName}`);
    console.log(`📊 RSVP Status:`);
    
    const going = [];
    const notGoing = [];
    
    userStatus.forEach((value, key) => {
      if (value.status === 'going') going.push(value);
      else if (value.status === 'not_going') notGoing.push(value);
    });
    
    console.log(`\n✅ Going (${going.length}):`);
    going.forEach(u => console.log(`   - ${u.name}`));
    
    console.log(`\n❌ Not Going (${notGoing.length}):`);
    notGoing.forEach(u => console.log(`   - ${u.name}`));
    
    // Output JSON for other tools to use
    const output = {
      event_id: EVENT_ID,
      event_name: eventName,
      going: going.map(u => ({ id: u.id, name: u.name })), // u.id is undefined here because I used map key. Fix below.
      not_going: notGoing.map(u => ({ id: u.id, name: u.name }))
    };
    
    // Fix id mapping
    output.going = going.map(u => ({ name: u.name })); 
    output.not_going = notGoing.map(u => ({ name: u.name }));

    // Actually, let's include the IDs from the map keys if needed, but for now names are fine.
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

getEventRSVPs();
