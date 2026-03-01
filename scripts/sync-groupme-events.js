#!/usr/bin/env node
/**
 * Sync GroupMe Calendar Events → footballhome database
 * 
 * Fetches structured calendar events (not chat messages) from GroupMe groups
 * and imports them as chat_events with RSVPs.
 * 
 * What it does:
 *   1. Ensures chats + chat_integrations exist for each GroupMe group
 *   2. Fetches calendar events from GroupMe API
 *   3. Classifies events (practice, league game, cup, pickup)
 *   4. Upserts chat_events (deduped by external_id = GroupMe event_id)
 *   5. For cup matches, creates match records in EPSA Open State Cup division
 *   6. Resolves GroupMe user IDs → person_ids via external_identities
 *   7. Upserts chat_event_rsvps (going/not_going/maybe)
 * 
 * Usage:
 *   node scripts/sync-groupme-events.js           # Sync all groups
 *   node scripts/sync-groupme-events.js --dry-run  # Preview without DB writes
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

// ============================================================================
// Configuration
// ============================================================================

const TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const GROUPME_PROVIDER_ID = 1; // chat_providers.id for 'groupme'
const GROUPME_SOURCE_SYSTEM_ID = 4; // source_systems.id for 'groupme'
const DRY_RUN = process.argv.includes('--dry-run');

// GroupMe group → team mapping
// team lookup uses source_system_id + external_id (unique per source)
const GROUPS = [
  {
    name: 'APSL Lighthouse',
    groupmeId: '109785985',
    chatTypeId: 1,  // team
    teamLookup: { sourceSystemId: 1, externalId: '116079' }, // APSL Lighthouse 1893 SC
  },
  {
    name: 'Lighthouse Boys Club Liga 1 & 2',
    groupmeId: '109786182',
    chatTypeId: 1,  // team
    teamLookup: { sourceSystemId: 2, externalId: '9090889-lighthouse-boys-club' }, // CASA Boys Club
  },
  {
    name: 'Lighthouse Old Timers Club',
    groupmeId: '109786278',
    chatTypeId: 1,  // team
    teamLookup: { sourceSystemId: 2, externalId: '9096430-lighthouse-old-timers-club' }, // CASA Old Timers
  },
  {
    name: 'Training Lighthouse',
    groupmeId: '108640377',
    chatTypeId: 5,  // training
    teamLookup: null, // Cross-team training (no single team)
    clubIds: [134, 20006, 20008], // All Lighthouse clubs
  },
  {
    name: 'Philadelphia Pickup',
    groupmeId: '65284700',
    chatTypeId: 3,  // pickup
    teamLookup: null, // Community pickup
    clubIds: [134, 20006, 20008], // All Lighthouse clubs
  },
];

// Event classification patterns
const CUP_PATTERNS = [/state cup/i, /open cup/i, /knockout/i, /epsa.*cup/i];
const PRACTICE_PATTERNS = [/training/i, /practice/i, /indoor/i, /flats/i];
const PICKUP_PATTERNS = [/pickup/i, /pick-up/i, /pick up/i];

// RSVP status mapping: GroupMe → DB
const RSVP_MAP = {
  going: 1,      // rsvp_statuses: yes
  not_going: 2,  // rsvp_statuses: no
  maybe_going: 3 // rsvp_statuses: maybe
};

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

// ============================================================================
// GroupMe API
// ============================================================================

function apiGet(path) {
  return new Promise((resolve, reject) => {
    const url = `https://api.groupme.com/v3${path}${path.includes('?') ? '&' : '?'}token=${TOKEN}`;
    https.get(url, res => {
      let d = '';
      res.on('data', c => d += c);
      res.on('end', () => {
        try {
          const json = JSON.parse(d);
          if (json.meta && json.meta.code >= 400) {
            if (json.meta.code === 404) resolve(null);
            else reject(new Error(`API ${json.meta.code}: ${JSON.stringify(json.meta.errors)}`));
          } else {
            resolve(json.response);
          }
        } catch (e) { reject(e); }
      });
    }).on('error', reject);
  });
}

// ============================================================================
// Event Classification
// ============================================================================

function classifyEvent(title, groupConfig) {
  // Check group type first
  if (groupConfig.chatTypeId === 3) return 'pickup';   // pickup group
  if (groupConfig.chatTypeId === 5) return 'practice';  // training group
  
  // Check title patterns
  if (CUP_PATTERNS.some(p => p.test(title))) return 'cup';
  if (PRACTICE_PATTERNS.some(p => p.test(title))) return 'practice';
  if (PICKUP_PATTERNS.some(p => p.test(title))) return 'pickup';
  
  // Default: if it's a team chat and has "vs" or "Vs", it's a league game
  if (/\bvs?\b/i.test(title)) return 'league_game';
  
  return 'other';
}

/**
 * Get match_type_id for event classification
 */
function getMatchTypeId(classification) {
  switch (classification) {
    case 'practice': return 3;    // practice
    case 'pickup': return 7;      // pickup
    case 'cup': return 6;         // cup
    case 'league_game': return 1; // league
    default: return 2;            // custom
  }
}

/**
 * Parse team names from a cup/game title like "Lighthouse Boys Club Vs Ukies"
 */
function parseTeamNames(title) {
  // Remove cup identifiers
  const cleaned = title
    .replace(/state (open )?cup:?\s*/i, '')
    .replace(/knockout round/i, '')
    .replace(/pigtail/i, '')
    .trim();
  
  // Split on "Vs", "vs", "VS", " v "
  const parts = cleaned.split(/\s+(?:vs\.?|v)\s+/i);
  if (parts.length === 2) {
    return { home: parts[0].trim(), away: parts[1].trim() };
  }
  return null;
}

/**
 * Fuzzy team name matching (handles "Westown" vs "West Town" etc.)
 */
function fuzzyTeamMatch(name1, name2) {
  if (!name1 || !name2) return false;
  const normalize = s => s.toLowerCase().replace(/[^a-z0-9]/g, '');
  return normalize(name1) === normalize(name2) 
    || normalize(name1).includes(normalize(name2))
    || normalize(name2).includes(normalize(name1));
}

// ============================================================================
// Database Operations
// ============================================================================

class GroupMeSync {
  constructor(client) {
    this.client = client;
    this.stats = {
      chatsCreated: 0,
      eventsCreated: 0,
      eventsUpdated: 0,
      eventsSkipped: 0,
      rsvpsCreated: 0,
      rsvpsUpdated: 0,
      matchesCreated: 0,
      personsResolved: 0,
      personsUnresolved: 0,
    };
    // Cache: GroupMe user ID → person_id
    this.personCache = {};
    // Cache: GroupMe user ID → user nickname (from group members)
    this.nicknameCache = {};
  }

  /**
   * Load all external_identities for GroupMe into cache
   */
  async loadPersonCache() {
    const res = await this.client.query(
      `SELECT external_user_id, person_id 
       FROM external_identities 
       WHERE provider_id = $1`,
      [GROUPME_PROVIDER_ID]
    );
    for (const row of res.rows) {
      this.personCache[row.external_user_id] = row.person_id;
    }
    console.log(`  📋 Loaded ${res.rows.length} GroupMe → person mappings`);
  }

  /**
   * Load group member nicknames for RSVP display
   */
  async loadGroupNicknames(groupmeId) {
    const group = await apiGet(`/groups/${groupmeId}`);
    if (group && group.members) {
      for (const m of group.members) {
        this.nicknameCache[m.user_id] = m.nickname;
      }
    }
  }

  /**
   * Ensure a chat + chat_integration exists for a GroupMe group.
   * Returns the chat_id.
   */
  async ensureChat(groupConfig) {
    // Check if integration already exists
    const existing = await this.client.query(
      `SELECT ci.chat_id FROM chat_integrations ci
       WHERE ci.provider_id = $1 AND ci.external_id = $2`,
      [GROUPME_PROVIDER_ID, groupConfig.groupmeId]
    );

    if (existing.rows.length > 0) {
      return existing.rows[0].chat_id;
    }

    // Look up team_id if applicable
    let teamId = null;
    if (groupConfig.teamLookup) {
      const teamRes = await this.client.query(
        `SELECT id FROM teams 
         WHERE source_system_id = $1 AND external_id = $2`,
        [groupConfig.teamLookup.sourceSystemId, groupConfig.teamLookup.externalId]
      );
      if (teamRes.rows.length > 0) {
        teamId = teamRes.rows[0].id;
      }
    }

    if (DRY_RUN) {
      console.log(`  [DRY RUN] Would create chat: ${groupConfig.name} (team_id=${teamId})`);
      return -1;
    }

    // Create chat
    const chatRes = await this.client.query(
      `INSERT INTO chats (team_id, name, chat_type_id, is_active)
       VALUES ($1, $2, $3, true)
       RETURNING id`,
      [teamId, groupConfig.name, groupConfig.chatTypeId]
    );
    const chatId = chatRes.rows[0].id;

    // Create integration
    await this.client.query(
      `INSERT INTO chat_integrations (chat_id, provider_id, external_id, external_name, is_primary, sync_events)
       VALUES ($1, $2, $3, $4, true, true)`,
      [chatId, GROUPME_PROVIDER_ID, groupConfig.groupmeId, groupConfig.name]
    );

    // Link cross-team chats to their clubs
    if (groupConfig.clubIds && groupConfig.clubIds.length > 0) {
      for (const clubId of groupConfig.clubIds) {
        await this.client.query(
          `INSERT INTO chat_clubs (chat_id, club_id) VALUES ($1, $2)
           ON CONFLICT (chat_id, club_id) DO NOTHING`,
          [chatId, clubId]
        );
      }
      console.log(`  🔗 Linked chat #${chatId} to ${groupConfig.clubIds.length} clubs`);
    }

    this.stats.chatsCreated++;
    console.log(`  ✅ Created chat #${chatId}: ${groupConfig.name}`);
    return chatId;
  }

  /**
   * Upsert a chat_event from a GroupMe calendar event
   */
  async upsertChatEvent(chatId, gmEvent, classification) {
    const externalId = gmEvent.event_id;
    const title = gmEvent.name;
    const location = gmEvent.location?.name || null;
    const locationAddress = gmEvent.location?.address || null;
    const startAt = gmEvent.start_at;
    const endAt = gmEvent.end_at || null;
    const eventDate = new Date(gmEvent.start_at).toISOString().split('T')[0];
    const eventTime = new Date(gmEvent.start_at).toLocaleTimeString('en-US', {
      hour12: false, hour: '2-digit', minute: '2-digit', second: '2-digit',
      timeZone: gmEvent.timezone || 'America/New_York'
    });

    // Build RSVP snapshot
    const rsvpSnapshot = {
      going: (gmEvent.going || []).map(uid => ({
        groupme_id: uid,
        nickname: this.nicknameCache[uid] || null,
        person_id: this.personCache[uid] || null,
      })),
      not_going: (gmEvent.not_going || []).map(uid => ({
        groupme_id: uid,
        nickname: this.nicknameCache[uid] || null,
        person_id: this.personCache[uid] || null,
      })),
      maybe_going: (gmEvent.maybe_going || []).map(uid => ({
        groupme_id: uid,
        nickname: this.nicknameCache[uid] || null,
        person_id: this.personCache[uid] || null,
      })),
      fetched_at: new Date().toISOString(),
    };

    if (DRY_RUN) {
      console.log(`  [DRY RUN] Would upsert event: "${title}" (${classification})`);
      console.log(`            ${startAt} at ${location || 'TBD'}`);
      console.log(`            Going: ${gmEvent.going?.length || 0} | Not: ${gmEvent.not_going?.length || 0} | Maybe: ${gmEvent.maybe_going?.length || 0}`);
      return -1;
    }

    // Upsert by external_id
    const res = await this.client.query(
      `INSERT INTO chat_events 
         (chat_id, title, description, location, location_address, event_date, event_time, start_at, end_at, external_id, rsvp_snapshot, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, true)
       ON CONFLICT (external_id) DO UPDATE SET
         title = EXCLUDED.title,
         location = EXCLUDED.location,
         location_address = EXCLUDED.location_address,
         start_at = EXCLUDED.start_at,
         end_at = EXCLUDED.end_at,
         rsvp_snapshot = EXCLUDED.rsvp_snapshot,
         updated_at = CURRENT_TIMESTAMP
       RETURNING id, (xmax = 0) AS is_new`,
      [chatId, title, `${classification} (via GroupMe)`, location, locationAddress, 
       eventDate, eventTime, startAt, endAt, externalId, JSON.stringify(rsvpSnapshot)]
    );

    const chatEventId = res.rows[0].id;
    const isNew = res.rows[0].is_new;

    if (isNew) {
      this.stats.eventsCreated++;
      console.log(`  ✅ Created event: "${title}" → chat_event #${chatEventId}`);
    } else {
      this.stats.eventsUpdated++;
      console.log(`  🔄 Updated event: "${title}" → chat_event #${chatEventId}`);
    }

    return chatEventId;
  }

  /**
   * Sync RSVPs for a chat event
   */
  async syncRsvps(chatEventId, gmEvent) {
    if (DRY_RUN) return;

    const rsvpEntries = [
      ...((gmEvent.going || []).map(uid => ({ uid, statusId: RSVP_MAP.going }))),
      ...((gmEvent.not_going || []).map(uid => ({ uid, statusId: RSVP_MAP.not_going }))),
      ...((gmEvent.maybe_going || []).map(uid => ({ uid, statusId: RSVP_MAP.maybe_going }))),
    ];

    for (const { uid, statusId } of rsvpEntries) {
      const personId = this.personCache[uid] || null;
      const nickname = this.nicknameCache[uid] || `GroupMe#${uid}`;
      const respondedAt = gmEvent.rsvp_list?.[uid] || null;

      try {
        if (personId) {
          // Person is mapped — upsert by person_id
          await this.client.query(
            `INSERT INTO chat_event_rsvps 
               (chat_event_id, person_id, external_user_id, external_username, rsvp_status_id, responded_at)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (chat_event_id, person_id) DO UPDATE SET
               rsvp_status_id = EXCLUDED.rsvp_status_id,
               responded_at = EXCLUDED.responded_at,
               external_username = EXCLUDED.external_username`,
            [chatEventId, personId, uid, nickname, statusId, respondedAt]
          );
          this.stats.personsResolved++;
        } else {
          // Unknown person — store with external_user_id only
          await this.client.query(
            `INSERT INTO chat_event_rsvps 
               (chat_event_id, external_user_id, external_username, rsvp_status_id, responded_at)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (chat_event_id, external_user_id) DO UPDATE SET
               rsvp_status_id = EXCLUDED.rsvp_status_id,
               responded_at = EXCLUDED.responded_at,
               external_username = EXCLUDED.external_username`,
            [chatEventId, uid, nickname, statusId, respondedAt]
          );
          this.stats.personsUnresolved++;
        }
        this.stats.rsvpsCreated++;
      } catch (err) {
        console.error(`    ⚠️  RSVP error for ${nickname}: ${err.message}`);
      }
    }
  }

  /**
   * Create a match record for a cup game.
   * Returns match_id or null on failure.
   */
  async createCupMatch(gmEvent, chatEventId) {
    const teamNames = parseTeamNames(gmEvent.name);
    if (!teamNames) {
      console.log(`    ⚠️  Could not parse teams from: "${gmEvent.name}"`);
      return null;
    }

    const matchDate = new Date(gmEvent.start_at).toISOString().split('T')[0];
    const matchTime = new Date(gmEvent.start_at).toLocaleTimeString('en-US', {
      hour12: false, hour: '2-digit', minute: '2-digit', second: '2-digit',
      timeZone: gmEvent.timezone || 'America/New_York'
    });

    // Check if match already exists (by groupme external_id)
    const existing = await this.client.query(
      `SELECT id FROM matches WHERE source_system_id = $1 AND external_id = $2`,
      [GROUPME_SOURCE_SYSTEM_ID, gmEvent.event_id]
    );

    if (existing.rows.length > 0) {
      const matchId = existing.rows[0].id;
      // Link to chat_event
      await this.client.query(
        `UPDATE chat_events SET match_id = $1 WHERE id = $2`,
        [matchId, chatEventId]
      );
      return matchId;
    }

    // Check for duplicate cup match on same date with similar teams
    // (same real-world game posted in multiple GroupMe groups)
    const dupCheck = await this.client.query(
      `SELECT m.id FROM matches m
       JOIN match_divisions md ON md.match_id = m.id AND md.division_id = 66
       WHERE m.match_date = $1 AND m.match_type_id = 6`,
      [matchDate]
    );
    
    if (dupCheck.rows.length > 0) {
      // There's already a cup match on this date — check if teams match
      for (const row of dupCheck.rows) {
        const existingMatch = await this.client.query(
          `SELECT m.title, ht.name as home_name, at.name as away_name
           FROM matches m 
           LEFT JOIN teams ht ON ht.id = m.home_team_id
           LEFT JOIN teams at ON at.id = m.away_team_id
           WHERE m.id = $1`,
          [row.id]
        );
        if (existingMatch.rows.length > 0) {
          const em = existingMatch.rows[0];
          // Fuzzy match: check if team names overlap
          const homeMatch = fuzzyTeamMatch(teamNames.home, em.home_name) || fuzzyTeamMatch(teamNames.home, em.away_name);
          const awayMatch = fuzzyTeamMatch(teamNames.away, em.home_name) || fuzzyTeamMatch(teamNames.away, em.away_name);
          if (homeMatch && awayMatch) {
            console.log(`    ℹ️  Cup match already exists (match #${row.id}): "${em.home_name} vs ${em.away_name}"`);
            // Link this event's external_id as an alternate
            await this.client.query(
              `UPDATE chat_events SET match_id = $1 WHERE id = $2`,
              [row.id, chatEventId]
            );
            return row.id;
          }
        }
      }
    }

    // Look up venue
    let venueId = null;
    if (gmEvent.location?.name) {
      const venueRes = await this.client.query(
        `SELECT id FROM venues WHERE name = $1`,
        [gmEvent.location.name.trim()]
      );
      if (venueRes.rows.length > 0) {
        venueId = venueRes.rows[0].id;
      } else {
        // Create venue
        const newVenue = await this.client.query(
          `INSERT INTO venues (name, address) VALUES ($1, $2)
           ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address)
           RETURNING id`,
          [gmEvent.location.name.trim(), gmEvent.location.address || null]
        );
        venueId = newVenue.rows[0].id;
      }
    }

    // Try to find home/away teams in the EPSA cup division (division_id=66)
    // First check if teams exist; if not, create them
    const homeTeamId = await this.findOrCreateCupTeam(teamNames.home);
    const awayTeamId = await this.findOrCreateCupTeam(teamNames.away);

    if (!homeTeamId || !awayTeamId) {
      console.log(`    ⚠️  Could not resolve teams for cup match: "${gmEvent.name}"`);
      return null;
    }

    if (DRY_RUN) {
      console.log(`  [DRY RUN] Would create cup match: ${teamNames.home} vs ${teamNames.away}`);
      return null;
    }

    // Determine match status based on date
    const now = new Date();
    const matchDateObj = new Date(gmEvent.start_at);
    const statusId = matchDateObj < now ? 3 : 1; // completed or scheduled

    const matchRes = await this.client.query(
      `INSERT INTO matches 
         (match_type_id, home_team_id, away_team_id, match_date, match_time, 
          venue_id, title, match_status_id, source_system_id, external_id, round_name)
       VALUES (6, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING id`,
      [homeTeamId, awayTeamId, matchDate, matchTime, venueId, 
       gmEvent.name, statusId, GROUPME_SOURCE_SYSTEM_ID, gmEvent.event_id,
       this.detectRoundName(gmEvent.name)]
    );

    const matchId = matchRes.rows[0].id;
    this.stats.matchesCreated++;

    // Link match to EPSA cup division
    await this.client.query(
      `INSERT INTO match_divisions (match_id, division_id, counts_for_standings)
       VALUES ($1, 66, false)
       ON CONFLICT DO NOTHING`,
      [matchId]
    );

    // Link match to chat_event
    await this.client.query(
      `UPDATE chat_events SET match_id = $1 WHERE id = $2`,
      [matchId, chatEventId]
    );

    console.log(`  🏆 Created cup match #${matchId}: ${teamNames.home} vs ${teamNames.away}`);
    return matchId;
  }

  /**
   * Find or create a team in the EPSA cup division (division_id=66)
   */
  async findOrCreateCupTeam(teamName) {
    // Normalize team name for matching
    const normalized = teamName.replace(/'/g, "'").trim();

    // Check if team already exists in EPSA cup division
    const existing = await this.client.query(
      `SELECT id FROM teams WHERE division_id = 66 AND name = $1`,
      [normalized]
    );
    if (existing.rows.length > 0) return existing.rows[0].id;

    // Try fuzzy match (ILIKE)
    const fuzzy = await this.client.query(
      `SELECT id FROM teams WHERE division_id = 66 AND name ILIKE $1`,
      [`%${normalized}%`]
    );
    if (fuzzy.rows.length === 1) return fuzzy.rows[0].id;

    // Try to find matching club from other leagues
    const clubMatch = await this.client.query(
      `SELECT DISTINCT c.id as club_id FROM clubs c
       JOIN teams t ON t.club_id = c.id
       WHERE t.name ILIKE $1`,
      [`%${normalized}%`]
    );

    const clubId = clubMatch.rows.length === 1 ? clubMatch.rows[0].club_id : null;

    if (DRY_RUN) {
      console.log(`  [DRY RUN] Would create cup team: "${normalized}" (club_id=${clubId})`);
      return null;
    }

    // Create team in EPSA cup division
    const newTeam = await this.client.query(
      `INSERT INTO teams (division_id, club_id, name, source_system_id)
       VALUES (66, $1, $2, $3)
       ON CONFLICT (division_id, name) DO UPDATE SET club_id = COALESCE(EXCLUDED.club_id, teams.club_id)
       RETURNING id`,
      [clubId, normalized, GROUPME_SOURCE_SYSTEM_ID]
    );

    console.log(`  🆕 Created cup team: "${normalized}" (id=${newTeam.rows[0].id}, club_id=${clubId})`);
    return newTeam.rows[0].id;
  }

  /**
   * Detect round name from event title
   */
  detectRoundName(title) {
    if (/pigtail/i.test(title)) return 'Pigtail';
    if (/knockout/i.test(title)) return 'Knockout Round';
    if (/quarter/i.test(title)) return 'Quarterfinals';
    if (/semi/i.test(title)) return 'Semifinals';
    if (/final/i.test(title) && !/semi/i.test(title)) return 'Final';
    return 'Round 1';
  }

  /**
   * Check for duplicate events across chats (same GroupMe event posted in multiple groups)
   */
  isDuplicateEvent(gmEvent, processedEventIds) {
    // GroupMe event_ids are unique per group, so same event in different groups
    // will have different event_ids. We detect duplicates by matching title + date.
    const key = `${gmEvent.name.toLowerCase().trim()}|${gmEvent.start_at}`;
    if (processedEventIds.has(key)) return true;
    processedEventIds.add(key);
    return false;
  }
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  if (!TOKEN) {
    console.error('❌ GROUPME_ACCESS_TOKEN not found in .env');
    process.exit(1);
  }

  console.log('🔄 GroupMe Calendar Events → footballhome sync');
  console.log(`   Mode: ${DRY_RUN ? '🔍 DRY RUN (no DB writes)' : '💾 LIVE'}`);
  console.log('');

  const client = new Client(dbConfig);
  
  try {
    await client.connect();
    console.log('🔌 Connected to database\n');

    const sync = new GroupMeSync(client);
    await sync.loadPersonCache();
    console.log('');

    // Track processed events to skip cross-chat duplicates
    const processedEventKeys = new Set();

    for (const groupConfig of GROUPS) {
      console.log('='.repeat(60));
      console.log(`📱 ${groupConfig.name} (GroupMe: ${groupConfig.groupmeId})`);
      console.log('='.repeat(60));

      // 1. Ensure chat exists
      const chatId = await sync.ensureChat(groupConfig);

      // 2. Load group member nicknames
      await sync.loadGroupNicknames(groupConfig.groupmeId);

      // 3. Fetch calendar events
      const eventsResponse = await apiGet(`/conversations/${groupConfig.groupmeId}/events/list`);
      const events = eventsResponse?.events || [];
      console.log(`  📅 ${events.length} calendar events found\n`);

      for (const gmEvent of events) {
        // Skip duplicates across groups
        if (sync.isDuplicateEvent(gmEvent, processedEventKeys)) {
          console.log(`  ⏭️  Skipping duplicate: "${gmEvent.name}" (already processed from another chat)`);
          sync.stats.eventsSkipped++;
          continue;
        }

        // 4. Classify
        const classification = classifyEvent(gmEvent.name, groupConfig);
        
        // 5. Upsert chat_event
        const chatEventId = await sync.upsertChatEvent(chatId, gmEvent, classification);

        // 6. Sync RSVPs
        if (chatEventId > 0) {
          await sync.syncRsvps(chatEventId, gmEvent);
        }

        // 7. For cup games, create match records
        if (classification === 'cup' && chatEventId > 0) {
          await sync.createCupMatch(gmEvent, chatEventId);
        }
      }
      console.log('');
    }

    // Summary
    console.log('='.repeat(60));
    console.log('📊 Sync Summary');
    console.log('='.repeat(60));
    console.log(`  Chats created:      ${sync.stats.chatsCreated}`);
    console.log(`  Events created:     ${sync.stats.eventsCreated}`);
    console.log(`  Events updated:     ${sync.stats.eventsUpdated}`);
    console.log(`  Events skipped:     ${sync.stats.eventsSkipped} (duplicates)`);
    console.log(`  RSVPs synced:       ${sync.stats.rsvpsCreated}`);
    console.log(`  Cup matches:        ${sync.stats.matchesCreated}`);
    console.log(`  Persons resolved:   ${sync.stats.personsResolved}`);
    console.log(`  Persons unresolved: ${sync.stats.personsUnresolved}`);

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

main();
