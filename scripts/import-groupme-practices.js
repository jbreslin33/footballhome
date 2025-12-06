
require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const ACCESS_TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const BASE_URL = 'https://api.groupme.com/v3';
const GROUP_ID = process.argv[2] || '108640377'; // Default to Training Lighthouse chat

// Constants from DB
const CLUB_TEAM_ID = 'd37eb44b-8e47-0005-9060-f0cbe96fe089'; // Lighthouse 1893 SC
const EVENT_TYPE_TRAINING = '550e8400-e29b-41d4-a716-446655440401';
const RSVP_YES = '550e8400-e29b-41d4-a716-446655440301';
const RSVP_MAYBE = '550e8400-e29b-41d4-a716-446655440302';
const RSVP_NO = '550e8400-e29b-41d4-a716-446655440303';
const SOURCE_APP = '550e8400-e29b-41d4-a716-446655440311'; // Using 'app' as source for now, or maybe 'bulk_import'

const client = new Client({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'footballhome',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: process.env.POSTGRES_PORT || 5432,
});

function apiRequest(path) {
  return new Promise((resolve, reject) => {
    const url = `${BASE_URL}${path}${path.includes('?') ? '&' : '?'}token=${ACCESS_TOKEN}`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
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

async function getAdminUser() {
  const res = await client.query("SELECT id FROM users LIMIT 1"); // Just grab the first user for now as creator
  return res.rows[0]?.id;
}

async function getUserIdByGroupMeId(groupmeId) {
  const res = await client.query("SELECT id FROM users WHERE groupme_id = $1", [groupmeId]);
  return res.rows[0]?.id;
}

async function ensurePlayerExists(userId) {
    // 1. Check/Create Player Record (id matches user_id)
    const playerRes = await client.query("SELECT id FROM players WHERE id = $1", [userId]);
    if (playerRes.rows.length === 0) {
        await client.query("INSERT INTO players (id) VALUES ($1)", [userId]);
    }

    // 2. Check/Create Team Association
    const teamRes = await client.query(
        "SELECT id FROM team_players WHERE team_id = $1 AND player_id = $2", 
        [CLUB_TEAM_ID, userId]
    );
    
    if (teamRes.rows.length === 0) {
        await client.query(
            "INSERT INTO team_players (team_id, player_id, roster_status_id) VALUES ($1, $2, 1)",
            [CLUB_TEAM_ID, userId]
        );
    }
    
    return userId; // Player ID is same as User ID
}

async function importPractices() {
  try {
    await client.connect();
    console.log('Connected to database');

    const adminUserId = await getAdminUser();
    if (!adminUserId) {
        console.error('No users found in DB to assign as creator');
        process.exit(1);
    }

    console.log(`Fetching events from GroupMe group ${GROUP_ID}...`);
    const response = await apiRequest(`/conversations/${GROUP_ID}/events/list`);
    const events = response.events || [];
    console.log(`Found ${events.length} events.`);

    for (const gmEvent of events) {
        const eventDate = new Date(gmEvent.start_at);
        const title = gmEvent.name;
        
        // Check if event exists (Fuzzy match: Title + Date within 1 min)
        // We'll check a range of +/- 1 minute
        const checkQuery = `
            SELECT id FROM events 
            WHERE title = $1 
            AND event_date >= $2::timestamptz - interval '1 minute'
            AND event_date <= $2::timestamptz + interval '1 minute'
        `;
        const checkRes = await client.query(checkQuery, [title, eventDate]);
        
        let eventId;
        
        if (checkRes.rows.length > 0) {
            eventId = checkRes.rows[0].id;
            console.log(`Event "${title}" already exists (ID: ${eventId}). Updating RSVPs...`);
        } else {
            console.log(`Creating new event "${title}"...`);
            
            // Insert into events
            const insertEventQuery = `
                INSERT INTO events (
                    created_by, event_type_id, title, description, event_date, duration_minutes
                ) VALUES ($1, $2, $3, $4, $5, 90)
                RETURNING id
            `;
            const eventRes = await client.query(insertEventQuery, [
                adminUserId, EVENT_TYPE_TRAINING, title, 
                `Imported from GroupMe. Event ID: ${gmEvent.event_id}`, 
                eventDate
            ]);
            eventId = eventRes.rows[0].id;
            
            // Insert into practices
            await client.query(
                "INSERT INTO practices (id, team_id) VALUES ($1, $2)",
                [eventId, CLUB_TEAM_ID]
            );
        }
        
        // Process RSVPs
        // gmEvent.going is array of user IDs
        // gmEvent.not_going is array of user IDs
        // gmEvent.rsvp_list is map of user_id -> timestamp
        
        const processRsvpList = async (userIds, statusId) => {
            for (const gmUserId of userIds) {
                const userId = await getUserIdByGroupMeId(gmUserId);
                if (userId) {
                    const playerId = await ensurePlayerExists(userId);
                    
                    // Check if this specific RSVP status is already recorded (latest one)
                    const latestRsvpQuery = `
                        SELECT rsvp_status_id FROM player_rsvp_history 
                        WHERE event_id = $1 AND player_id = $2 
                        ORDER BY changed_at DESC LIMIT 1
                    `;
                    const latestRes = await client.query(latestRsvpQuery, [eventId, playerId]);
                    
                    if (latestRes.rows.length === 0 || latestRes.rows[0].rsvp_status_id !== statusId) {
                        // Insert new RSVP record
                        let timestamp = new Date();
                        if (gmEvent.rsvp_list && gmEvent.rsvp_list[gmUserId]) {
                            const val = gmEvent.rsvp_list[gmUserId];
                            if (typeof val === 'number') timestamp = new Date(val * 1000);
                            else timestamp = new Date(val);
                        }

                        await client.query(`
                            INSERT INTO player_rsvp_history (
                                event_id, player_id, rsvp_status_id, changed_by, change_source_id, changed_at
                            ) VALUES ($1, $2, $3, $4, $5, $6)
                        `, [eventId, playerId, statusId, userId, SOURCE_APP, timestamp]);
                        // console.log(`  Recorded RSVP for user ${userId}`);
                    }
                } else {
                    // console.warn(`  Warning: GroupMe User ID ${gmUserId} not found in DB.`);
                }
            }
        };

        if (gmEvent.going) await processRsvpList(gmEvent.going, RSVP_YES);
        if (gmEvent.not_going) await processRsvpList(gmEvent.not_going, RSVP_NO);
    }

    console.log('Import complete.');
  } catch (err) {
    console.error('Error importing practices:', err);
  } finally {
    await client.end();
  }
}

importPractices();
