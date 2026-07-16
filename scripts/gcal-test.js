#!/usr/bin/env node
// scripts/gcal-test.js — smoke test the Google Calendar integration.
//
// Prereqs (do these once):
//   1. In Google Cloud Console (logged in as jbreslin33@gmail.com):
//        - Create a project (or reuse one) → enable "Google Calendar API"
//        - Create a service account → download the JSON key file
//   2. Log into soccer@lighthouse1893.org → Google Calendar → the soccer calendar
//        → Settings and sharing → "Share with specific people or groups"
//        → paste the service-account email (client_email from the JSON)
//        → permission: "Make changes to events" → Send
//   3. Copy the Calendar ID from Settings → "Integrate calendar"
//   4. Add to /srv/footballhome/env (secrets live here, encrypted via env.age):
//        GCAL_SOCCER_CALENDAR_ID=soccer@lighthouse1893.org
//        GCAL_OPS_CALENDAR_ID=sports@lighthouse1893.org
//        GCAL_SA_JSON='{"type":"service_account","project_id":"...", ... }'
//      (the entire JSON on one line, wrapped in single quotes so the JSON's
//       double-quotes survive shell parsing)
//   5. Install deps: npm install googleapis   (already done)
//   6. Run: node scripts/gcal-test.js

require('dotenv').config({ path: __dirname + '/../env' });
const { google } = require('googleapis');

const RAW_JSON = process.env.GCAL_SA_JSON;
const CALENDAR_ID = process.env.GCAL_SOCCER_CALENDAR_ID || 'primary';

if (!RAW_JSON) {
  console.error('ERROR: GCAL_SA_JSON not set in env');
  console.error('       Paste the whole service-account JSON on one line in env,');
  console.error('       wrapped in single quotes.');
  process.exit(1);
}

let credentials;
try {
  credentials = JSON.parse(RAW_JSON);
} catch (e) {
  console.error('ERROR: GCAL_SA_JSON is not valid JSON:');
  console.error('       ' + e.message);
  process.exit(1);
}

if (!credentials.client_email || !credentials.private_key) {
  console.error('ERROR: GCAL_SA_JSON missing client_email or private_key');
  process.exit(1);
}

(async () => {
  const auth = new google.auth.GoogleAuth({
    credentials,
    scopes: ['https://www.googleapis.com/auth/calendar'],
  });
  const calendar = google.calendar({ version: 'v3', auth });

  // 1) Confirm we can see the calendar itself.
  let calMeta;
  try {
    calMeta = (await calendar.calendars.get({ calendarId: CALENDAR_ID })).data;
  } catch (e) {
    console.error('Failed to read calendar metadata:');
    console.error(`  Calendar ID:     ${CALENDAR_ID}`);
    console.error(`  Service account: ${credentials.client_email}`);
    console.error('');
    console.error(e.errors || e.message);
    console.error('');
    console.error('Common causes:');
    console.error('  - Calendar not yet shared with the service-account email above.');
    console.error('  - Calendar ID typo. Copy it from Settings → "Integrate calendar".');
    console.error('  - Google Calendar API not enabled on the Cloud project.');
    process.exit(1);
  }

  console.log('=== Calendar ===');
  console.log(`Summary:     ${calMeta.summary}`);
  console.log(`ID:          ${calMeta.id}`);
  console.log(`Timezone:    ${calMeta.timeZone}`);
  console.log(`Description: ${calMeta.description || '(none)'}`);
  console.log('');

  // 2) List upcoming events.
  const now = new Date().toISOString();
  const events = (await calendar.events.list({
    calendarId: CALENDAR_ID,
    timeMin: now,
    maxResults: 20,
    singleEvents: true,
    orderBy: 'startTime',
  })).data.items || [];

  console.log(`=== Next ${events.length} upcoming events (from now) ===`);
  if (events.length === 0) {
    console.log('(no upcoming events)');
    return;
  }
  for (const e of events) {
    const start = e.start.dateTime || e.start.date;   // dateTime for timed events, date for all-day
    const end   = e.end.dateTime   || e.end.date;
    const where = e.location ? `  @ ${e.location}` : '';
    console.log(`${start.padEnd(28)}  →  ${end.padEnd(28)}  ${e.summary || '(no title)'}${where}`);
  }
})().catch(err => {
  console.error('Unexpected error:');
  console.error(err);
  process.exit(1);
});
