#!/usr/bin/env node
/**
 * Find the latest GroupMe event and print its details.
 * 
 * Usage: node scripts/find-latest-event.js [group_id]
 */

require('dotenv').config();
const https = require('https');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const GROUP_ID = process.argv[2] || '108640377'; // Default to the known group ID

if (!ACCESS_TOKEN) {
  console.error('❌ Error: GROUPME_ACCESS_TOKEN not found in .env file');
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
             // Don't reject immediately on 304/404 if we can handle it, but here we treat as error
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

async function findLatestEvent() {
  console.log(`🔍 Scanning for the latest event in group ${GROUP_ID}...`);
  
  let allMessages = [];
  let beforeId = null;
  const limit = 100;
  const maxMessages = 2000; // Scan up to 2000 messages
  
  let targetEventId = null;
  let eventDetails = {
    id: null,
    name: 'Unknown',
    description: null,
    location: null,
    created_at: null,
    creator: null
  };
  
  const userStatus = new Map(); // userId -> { name, status, timestamp }

  try {
    // Loop to fetch messages
    while (allMessages.length < maxMessages) {
      const path = `/groups/${GROUP_ID}/messages?limit=${limit}${beforeId ? `&before_id=${beforeId}` : ''}`;
      const data = await apiRequest(path);
      
      if (!data || !data.messages || data.messages.length === 0) break;
      
      const messages = data.messages;
      allMessages = allMessages.concat(messages);
      beforeId = messages[messages.length - 1].id;
      
      process.stdout.write(`\rScanned ${allMessages.length} messages...`);

      for (const msg of messages) {
        // 1. Check for System Event Messages (RSVPs)
        if (msg.event && msg.event.data && msg.event.data.event) {
          const evtId = msg.event.data.event.id;
          
          // If we haven't found an event yet, this is the latest one
          if (!targetEventId) {
            targetEventId = evtId;
            eventDetails.id = evtId;
            eventDetails.name = msg.event.data.event.name;
            console.log(`\n\n🎉 Found latest event: "${eventDetails.name}" (ID: ${targetEventId})`);
          }
          
          // If this message belongs to our target event, process the RSVP
          if (evtId === targetEventId) {
            const type = msg.event.type;
            const user = msg.event.data.user;
            
            if (user && user.id) {
              // Only record the LATEST status (which is the first one we see since we scan backwards)
              if (!userStatus.has(user.id)) {
                let status = 'unknown';
                if (type === 'calendar.event.user.going') status = 'going';
                else if (type === 'calendar.event.user.not_going') status = 'not_going';
                else if (type === 'calendar.event.user.undecided') status = 'undecided';
                
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
        
        // 2. Check for Event Creation/Link Messages
        // Look for the link: https://groupme.com/join_event/<GROUP>/<EVENT>
        if (msg.text && msg.text.includes('groupme.com/join_event')) {
           const match = /join_event\/(\d+)\/([a-f0-9]+)/.exec(msg.text);
           if (match) {
             const evtId = match[2];
             
             // If we haven't found an event yet, this is it
             if (!targetEventId) {
                targetEventId = evtId;
                eventDetails.id = evtId;
                console.log(`\n\n🎉 Found latest event link (ID: ${targetEventId})`);
             }
             
             // If this is the creation message for our target event, grab details
             if (evtId === targetEventId) {
               eventDetails.created_at = new Date(msg.created_at * 1000).toLocaleString();
               eventDetails.creator = msg.name;
               
               // Try to extract description (text before the link)
               const linkIndex = msg.text.indexOf('https://');
               if (linkIndex > 0) {
                 eventDetails.description = msg.text.substring(0, linkIndex).trim();
               }
               
               // Sometimes location is in the text or attachments?
               // The message text usually contains the location if it was auto-generated.
             }
           }
        }
      }
      
      // If we found the event and scanned enough to likely get all RSVPs, we could stop.
      // But let's scan the full maxMessages to be safe, or until we find a DIFFERENT event ID?
      // Actually, if we find a DIFFERENT event ID that is NEWER, we would have picked that one first.
      // If we find a DIFFERENT event ID that is OLDER, we should ignore it.
      // So we just keep scanning to fill up the RSVP list for the target event.
    }
    
    console.log('\n');
    
    if (!targetEventId) {
      console.log('❌ No events found in the scanned messages.');
      return;
    }

    // Print Results
    console.log('==========================================');
    console.log(`EVENT DETAILS`);
    console.log('==========================================');
    console.log(`Name:        ${eventDetails.name}`);
    console.log(`ID:          ${eventDetails.id}`);
    console.log(`Created By:  ${eventDetails.creator || 'Unknown'}`);
    console.log(`Created At:  ${eventDetails.created_at || 'Unknown'}`);
    console.log(`Description: ${eventDetails.description || '(No description found in text)'}`);
    console.log('==========================================');
    console.log(`RSVP SUMMARY`);
    console.log('==========================================');
    
    const going = [];
    const notGoing = [];
    const undecided = [];
    
    userStatus.forEach((value) => {
      if (value.status === 'going') going.push(value);
      else if (value.status === 'not_going') notGoing.push(value);
      else if (value.status === 'undecided') undecided.push(value);
    });
    
    console.log(`✅ GOING (${going.length})`);
    going.forEach(u => console.log(`   • ${u.name}`));
    
    console.log(`\n❌ NOT GOING (${notGoing.length})`);
    notGoing.forEach(u => console.log(`   • ${u.name}`));
    
    if (undecided.length > 0) {
      console.log(`\n❓ UNDECIDED (${undecided.length})`);
      undecided.forEach(u => console.log(`   • ${u.name}`));
    }
    
    console.log('\nDone.');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

findLatestEvent();
