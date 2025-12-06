#!/usr/bin/env node
/**
 * Scan message history for ANY events and dump their data in JSON format.
 * 
 * Usage: node scripts/dump-events-json.js [group_id]
 */

require('dotenv').config();
const https = require('https');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const GROUP_ID = process.argv[2] || '108640377';

if (!ACCESS_TOKEN) {
  console.error(JSON.stringify({ error: 'GROUPME_ACCESS_TOKEN not found in .env file' }));
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
             resolve(null); // Treat errors as empty/null to keep scanning if possible
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

async function dumpEvents() {
  // Map: eventId -> { name, created_at, creator, userStatus: Map<userId, {name, status, timestamp}> }
  const eventsMap = new Map();
  
  let allMessages = [];
  let beforeId = null;
  const limit = 100;
  const maxMessages = 2000; // Scan up to 2000 messages

  try {
    while (allMessages.length < maxMessages) {
      const path = `/groups/${GROUP_ID}/messages?limit=${limit}${beforeId ? `&before_id=${beforeId}` : ''}`;
      const data = await apiRequest(path);
      
      if (!data || !data.messages || data.messages.length === 0) break;
      
      const messages = data.messages;
      allMessages = allMessages.concat(messages);
      beforeId = messages[messages.length - 1].id;
      
      // Process messages
      for (const msg of messages) {
        // 1. Check for System Event Messages (RSVPs)
        if (msg.event && msg.event.data && msg.event.data.event) {
          const evtId = msg.event.data.event.id;
          const evtName = msg.event.data.event.name;
          
          if (!eventsMap.has(evtId)) {
            eventsMap.set(evtId, {
              id: evtId,
              name: evtName,
              userStatus: new Map()
            });
          }
          
          const eventObj = eventsMap.get(evtId);
          const type = msg.event.type;
          const user = msg.event.data.user;
          
          if (user && user.id) {
            // Only record the LATEST status (first one seen in descending scan)
            if (!eventObj.userStatus.has(user.id)) {
              let status = 'unknown';
              if (type === 'calendar.event.user.going') status = 'going';
              else if (type === 'calendar.event.user.not_going') status = 'not_going';
              else if (type === 'calendar.event.user.undecided') status = 'undecided';
              
              if (status !== 'unknown') {
                eventObj.userStatus.set(user.id, {
                  id: user.id,
                  name: user.nickname,
                  status: status,
                  timestamp: msg.created_at
                });
              }
            }
          }
        }
        
        // 2. Check for Event Creation/Link Messages
        if (msg.text && msg.text.includes('groupme.com/join_event')) {
           const match = /join_event\/(\d+)\/([a-f0-9]+)/.exec(msg.text);
           if (match) {
             const evtId = match[2];
             
             if (!eventsMap.has(evtId)) {
                eventsMap.set(evtId, {
                  id: evtId,
                  name: 'Unknown (Found Link)',
                  userStatus: new Map()
                });
             }
             
             const eventObj = eventsMap.get(evtId);
             // Update details if we found the creation message
             eventObj.created_at = new Date(msg.created_at * 1000).toISOString();
             eventObj.creator = msg.name;
             const linkIndex = msg.text.indexOf('https://');
             if (linkIndex > 0) {
               eventObj.description = msg.text.substring(0, linkIndex).trim();
             }
           }
        }
      }
    }
    
    // Convert Map to Array for JSON output
    const output = [];
    
    eventsMap.forEach((event) => {
      const going = [];
      const notGoing = [];
      const undecided = [];
      
      event.userStatus.forEach((u) => {
        const userObj = { name: u.name, id: u.id };
        if (u.status === 'going') going.push(userObj);
        else if (u.status === 'not_going') notGoing.push(userObj);
        else if (u.status === 'undecided') undecided.push(userObj);
      });
      
      output.push({
        id: event.id,
        name: event.name,
        created_at: event.created_at || null,
        creator: event.creator || null,
        description: event.description || null,
        stats: {
          going: going.length,
          not_going: notGoing.length,
          undecided: undecided.length
        },
        rsvps: {
          going: going,
          not_going: notGoing,
          undecided: undecided
        }
      });
    });
    
    console.log(JSON.stringify(output, null, 2));

  } catch (error) {
    console.error(JSON.stringify({ error: error.message }));
  }
}

dumpEvents();
