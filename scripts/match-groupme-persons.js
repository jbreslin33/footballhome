#!/usr/bin/env node
/**
 * Match GroupMe Members → Persons in footballhome DB
 * 
 * Fetches all members from the 5 Lighthouse GroupMe groups,
 * attempts to match by name to existing persons, and shows results.
 * 
 * Usage:
 *   node scripts/match-groupme-persons.js              # Preview matches
 *   node scripts/match-groupme-persons.js --apply       # Write matches to DB
 *   node scripts/match-groupme-persons.js --show-all    # Show all members including unmatched
 */

require('dotenv').config();
const https = require('https');
const { Client } = require('pg');

const TOKEN = process.env.GROUPME_ACCESS_TOKEN;
const GROUPME_PROVIDER_ID = 1; // chat_providers.id for 'groupme'
const APPLY = process.argv.includes('--apply');
const SHOW_ALL = process.argv.includes('--show-all');

const GROUPS = [
  { name: 'APSL Lighthouse', id: '109785985' },
  { name: 'Liga 1 & 2', id: '109786182' },
  { name: 'Old Timers', id: '109786278' },
  { name: 'Training', id: '108640377' },
  { name: 'Philly Pickup', id: '65284700' },
];

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballhome_user',
  password: process.env.DB_PASSWORD || 'footballhome_pass',
};

function apiGet(path) {
  return new Promise((resolve, reject) => {
    const url = `https://api.groupme.com/v3${path}${path.includes('?') ? '&' : '?'}token=${TOKEN}`;
    https.get(url, res => {
      let d = '';
      res.on('data', c => d += c);
      res.on('end', () => {
        try { resolve(JSON.parse(d).response); }
        catch (e) { reject(e); }
      });
    }).on('error', reject);
  });
}

/**
 * Split a GroupMe nickname into first/last name candidates.
 * Handles emoji, single names, multi-word names.
 */
function splitName(nickname) {
  // Strip emoji and special chars
  const clean = nickname
    .replace(/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{200D}\u{20E3}]/gu, '')
    .replace(/[⚽️🏆🔥💪🎯⭐]/g, '')
    .trim();
  
  const parts = clean.split(/\s+/).filter(p => p.length > 0);
  
  if (parts.length === 0) return null;
  if (parts.length === 1) return { first: parts[0], last: null };
  
  return {
    first: parts[0],
    last: parts.slice(1).join(' ')
  };
}

/**
 * Normalize name for matching: lowercase, strip accents, remove punctuation
 */
function normalize(s) {
  if (!s) return '';
  return s.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // strip accents
    .replace(/[^a-z0-9\s]/g, '') // remove punctuation
    .trim();
}

async function main() {
  const client = new Client(dbConfig);
  await client.connect();
  console.log('🔌 Connected to database\n');

  // 1. Load all persons
  const personsRes = await client.query(
    `SELECT id, first_name, last_name FROM persons ORDER BY last_name, first_name`
  );
  const persons = personsRes.rows;
  console.log(`📋 ${persons.length} persons in database\n`);

  // Build lookup indexes
  const byExactName = new Map();   // "first last" → [person]
  const byFirstName = new Map();   // "first" → [person]
  const byLastName = new Map();    // "last" → [person]

  for (const p of persons) {
    const key = `${normalize(p.first_name)} ${normalize(p.last_name)}`;
    if (!byExactName.has(key)) byExactName.set(key, []);
    byExactName.get(key).push(p);

    const fkey = normalize(p.first_name);
    if (!byFirstName.has(fkey)) byFirstName.set(fkey, []);
    byFirstName.get(fkey).push(p);

    const lkey = normalize(p.last_name);
    if (!byLastName.has(lkey)) byLastName.set(lkey, []);
    byLastName.get(lkey).push(p);
  }

  // 2. Check existing external_identities
  const existingRes = await client.query(
    `SELECT external_user_id, person_id FROM external_identities WHERE provider_id = $1`,
    [GROUPME_PROVIDER_ID]
  );
  const existingLinks = new Map();
  for (const row of existingRes.rows) {
    existingLinks.set(row.external_user_id, row.person_id);
  }
  console.log(`🔗 ${existingLinks.size} existing GroupMe→person links\n`);

  // 3. Fetch all members from all groups
  const allMembers = new Map(); // groupme_user_id → { nickname, avatar, groups[] }

  for (const group of GROUPS) {
    const g = await apiGet(`/groups/${group.id}`);
    if (!g) continue;

    for (const m of g.members) {
      if (allMembers.has(m.user_id)) {
        allMembers.get(m.user_id).groups.push(group.name);
      } else {
        allMembers.set(m.user_id, {
          userId: m.user_id,
          nickname: m.nickname,
          avatar: m.image_url,
          groups: [group.name],
        });
      }
    }
  }

  console.log(`👥 ${allMembers.size} unique GroupMe members across ${GROUPS.length} groups\n`);

  // 4. Match each member
  const exactMatches = [];
  const fuzzyMatches = [];
  const noMatch = [];
  const alreadyLinked = [];

  for (const [gmId, member] of allMembers) {
    // Skip if already linked
    if (existingLinks.has(gmId)) {
      alreadyLinked.push({ member, personId: existingLinks.get(gmId) });
      continue;
    }

    const parsed = splitName(member.nickname);
    if (!parsed) {
      noMatch.push({ member, reason: 'Could not parse name' });
      continue;
    }

    const first = normalize(parsed.first);
    const last = parsed.last ? normalize(parsed.last) : null;

    // A) Exact match: first + last
    if (last) {
      const key = `${first} ${last}`;
      const matches = byExactName.get(key) || [];
      if (matches.length === 1) {
        exactMatches.push({ member, person: matches[0], method: 'exact' });
        continue;
      }
      if (matches.length > 1) {
        fuzzyMatches.push({ member, candidates: matches, method: 'exact_ambiguous' });
        continue;
      }
    }

    // B) First name only match (when nickname is single name like "Amar")
    if (!last) {
      const fmatches = byFirstName.get(first) || [];
      if (fmatches.length === 1) {
        fuzzyMatches.push({ member, candidates: fmatches, method: 'first_name_only' });
        continue;
      }
      if (fmatches.length > 1 && fmatches.length <= 5) {
        fuzzyMatches.push({ member, candidates: fmatches, method: 'first_name_multiple' });
        continue;
      }
    }

    // C) Reversed name (GroupMe has "Last First" sometimes)
    if (last) {
      const reversedKey = `${last} ${first}`;
      const rmatches = byExactName.get(reversedKey) || [];
      if (rmatches.length === 1) {
        fuzzyMatches.push({ member, candidates: rmatches, method: 'reversed_name' });
        continue;
      }
    }

    // D) Last name fuzzy: check if last name matches any person with similar first
    if (last) {
      const lmatches = byLastName.get(last) || [];
      const filtered = lmatches.filter(p => {
        const pf = normalize(p.first_name);
        return pf.startsWith(first) || first.startsWith(pf);
      });
      if (filtered.length === 1) {
        fuzzyMatches.push({ member, candidates: filtered, method: 'partial_first' });
        continue;
      }
      // Also check first name in last name field (nickname "Chris" matching "Chris Fletcher")
      if (lmatches.length === 1) {
        fuzzyMatches.push({ member, candidates: lmatches, method: 'last_name_only' });
        continue;
      }
    }

    noMatch.push({ member, reason: last ? 'No match found' : 'Single name, too many candidates' });
  }

  // 5. Display results
  console.log('='.repeat(70));
  console.log(`✅ EXACT MATCHES (${exactMatches.length}) — High confidence, safe to auto-link`);
  console.log('='.repeat(70));
  for (const { member, person } of exactMatches) {
    const groups = member.groups.join(', ');
    console.log(`  "${member.nickname}" (GM:${member.userId}) → ${person.first_name} ${person.last_name} (person:${person.id}) [${groups}]`);
  }

  console.log('');
  console.log('='.repeat(70));
  console.log(`🔍 FUZZY MATCHES (${fuzzyMatches.length}) — Need human review`);
  console.log('='.repeat(70));
  for (const { member, candidates, method } of fuzzyMatches) {
    const groups = member.groups.join(', ');
    const candStr = candidates.map(c => `${c.first_name} ${c.last_name} (${c.id})`).join(' | ');
    console.log(`  "${member.nickname}" (GM:${member.userId}) → ${candStr}  [${method}] [${groups}]`);
  }

  if (SHOW_ALL || noMatch.length <= 50) {
    console.log('');
    console.log('='.repeat(70));
    console.log(`❌ NO MATCH (${noMatch.length}) — Unknown or unparseable`);
    console.log('='.repeat(70));
    for (const { member, reason } of noMatch) {
      const groups = member.groups.join(', ');
      console.log(`  "${member.nickname}" (GM:${member.userId}) — ${reason} [${groups}]`);
    }
  } else {
    console.log('');
    console.log(`❌ NO MATCH: ${noMatch.length} members (use --show-all to see full list)`);
  }

  if (alreadyLinked.length > 0) {
    console.log(`\n🔗 ALREADY LINKED: ${alreadyLinked.length} members`);
  }

  // 6. Summary
  console.log('');
  console.log('='.repeat(70));
  console.log('📊 SUMMARY');
  console.log('='.repeat(70));
  console.log(`  Total unique GroupMe members:  ${allMembers.size}`);
  console.log(`  Already linked:                ${alreadyLinked.length}`);
  console.log(`  Exact matches:                 ${exactMatches.length}`);
  console.log(`  Fuzzy matches (need review):   ${fuzzyMatches.length}`);
  console.log(`  No match:                      ${noMatch.length}`);

  // 7. Apply if --apply
  if (APPLY && exactMatches.length > 0) {
    console.log('');
    console.log('='.repeat(70));
    console.log('💾 APPLYING EXACT MATCHES...');
    console.log('='.repeat(70));

    let applied = 0;
    let errors = 0;

    for (const { member, person } of exactMatches) {
      try {
        await client.query(
          `INSERT INTO external_identities 
             (person_id, provider_id, external_user_id, external_username, external_display_name, external_avatar_url, last_synced_at)
           VALUES ($1, $2, $3, $4, $5, $6, NOW())
           ON CONFLICT (provider_id, external_user_id) DO UPDATE SET
             person_id = EXCLUDED.person_id,
             external_username = EXCLUDED.external_username,
             external_display_name = EXCLUDED.external_display_name,
             external_avatar_url = EXCLUDED.external_avatar_url,
             last_synced_at = NOW()`,
          [person.id, GROUPME_PROVIDER_ID, member.userId, member.nickname, member.nickname, member.avatar]
        );
        applied++;
      } catch (err) {
        console.error(`  ⚠️  Error linking "${member.nickname}": ${err.message}`);
        errors++;
      }
    }

    console.log(`  ✅ Applied: ${applied}`);
    if (errors) console.log(`  ⚠️  Errors: ${errors}`);

    // Also update chat_event_rsvps that now have a matching person
    const updateRes = await client.query(
      `UPDATE chat_event_rsvps r
       SET person_id = ei.person_id
       FROM external_identities ei
       WHERE ei.provider_id = $1
         AND ei.external_user_id = r.external_user_id
         AND r.person_id IS NULL`,
      [GROUPME_PROVIDER_ID]
    );
    console.log(`  🔄 Updated ${updateRes.rowCount} RSVPs with person_id backfill`);

  } else if (APPLY) {
    console.log('\n  No exact matches to apply.');
  } else if (exactMatches.length > 0) {
    console.log(`\n  Run with --apply to write ${exactMatches.length} exact matches to database.`);
  }

  await client.end();
}

main().catch(err => {
  console.error('❌', err);
  process.exit(1);
});
