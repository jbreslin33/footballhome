// Audit youth roster vs LA boys/girls program registrations.
//
// Standalone Node script — the meta-leads-webhook container that used to
// host this was removed in the Phase 14 port; run it from the host with
// the LEAGUEAPPS_* env vars set and the PEM living at
// $LEAGUEAPPS_PEM_DIR/<CID>.pem (defaults to ./config/<CID>.pem).
// Usage:  (cd /path/to/footballhome && env $(grep -E '^LEAGUEAPPS_|^POSTGRES_' env | xargs) node scripts/audit-youth-la.js)
const jwt = require('jsonwebtoken');
const fsp = require('fs').promises;
const { Pool } = require('pg');

const LA_AUTH = 'https://auth.leagueapps.io/v2/auth/token';
const LA_API  = 'https://public.leagueapps.io/v2';
const SITE  = parseInt(process.env.LEAGUEAPPS_SITE_ID, 10);
const BOYS  = parseInt(process.env.LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID  || '5039252', 10);
const GIRLS = parseInt(process.env.LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID || '5039357', 10);
const CID   = process.env.LEAGUEAPPS_API_PRIVATE_KEY;

async function getToken() {
  const pemDir = process.env.LEAGUEAPPS_PEM_DIR || './config';
  const pem = await fsp.readFile(`${pemDir}/${CID}.pem`, 'utf8');
  const now = Math.floor(Date.now() / 1000);
  const assertion = jwt.sign(
    { aud: LA_AUTH, iss: CID, sub: CID, iat: now, exp: now + 300 },
    pem, { algorithm: 'RS256' }
  );
  const r = await fetch(LA_AUTH, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const j = await r.json();
  return j.access_token;
}

async function fetchAll(pid, tok) {
  const recs = [];
  const p = new URLSearchParams({ 'last-updated': '0', 'last-id': '0', 'program-id': String(pid) });
  for (let i = 0; i < 50; i++) {
    const r = await fetch(`${LA_API}/sites/${SITE}/export/registrations-2?${p}`, {
      headers: { Authorization: 'Bearer ' + tok },
    });
    const b = await r.json();
    if (!Array.isArray(b) || !b.length) break;
    recs.push(...b);
    const t = b[b.length - 1];
    p.set('last-updated', String(t.lastUpdated || 0));
    p.set('last-id', String(t.id || 0));
  }
  const m = new Map();
  for (const r of recs) {
    const id = r.registrationId ?? r.id;
    if (id == null) continue;
    const k = (r.lastUpdated || 0) * 1e9 + (r.id || 0);
    const c = m.get(id);
    const pk = c ? (c.lastUpdated || 0) * 1e9 + (c.id || 0) : -1;
    if (!c || k >= pk) m.set(id, r);
  }
  return [...m.values()].filter(r => !r.deleted);
}

async function loadBuckets(seasonEndYear, pool) {
  const r = await pool.query(
    `SELECT bucket_label, club_filter, min_birth_date, max_birth_date, max_roster, color, sort_order
       FROM youth_age_groups
      WHERE season_end_year = $1
      ORDER BY sort_order, bucket_label`,
    [seasonEndYear]
  );
  return r.rows.map(r => ({
    label: r.bucket_label,
    clubFilter: r.club_filter,
    minBirthISO: r.min_birth_date.toISOString().slice(0, 10),
    maxBirthISO: r.max_birth_date.toISOString().slice(0, 10),
  }));
}

function matchBucket(birthDate, club, defs) {
  if (!birthDate) return null;
  return defs.find(b => {
    if (b.clubFilter && b.clubFilter !== 'both' && b.clubFilter !== club) return false;
    return birthDate >= b.minBirthISO && birthDate <= b.maxBirthISO;
  }) || null;
}

(async () => {
  const pool = new Pool();
  const tok = await getToken();
  const [boys, girls] = await Promise.all([fetchAll(BOYS, tok), fetchAll(GIRLS, tok)]);

  const isActive = r => {
    const s = (r.registrationStatus || '').toUpperCase();
    return s === 'SPOT_RESERVED' || s === 'SPOT_PENDING';
  };

  const breakdown = (label, arr) => {
    const by = {};
    for (const r of arr) {
      const s = (r.registrationStatus || 'NONE').toUpperCase();
      by[s] = (by[s] || 0) + 1;
    }
    console.log(`${label}: total=${arr.length}`, by);
  };
  breakdown('BOYS  raw', boys);
  breakdown('GIRLS raw', girls);

  const boysA  = boys.filter(isActive);
  const girlsA = girls.filter(isActive);
  console.log(`ACTIVE: boys=${boysA.length}  girls=${girlsA.length}  total=${boysA.length + girlsA.length}`);

  // Today's default seasonEndYear (mirrors defaultSeasonEndYear() in webhook).
  const now = new Date();
  const seasonEndYear = now.getMonth() >= 5 ? now.getFullYear() + 1 : now.getFullYear();
  const defs = await loadBuckets(seasonEndYear, pool);
  console.log(`seasonEndYear=${seasonEndYear}, buckets configured: ${defs.length}`);

  let bucketed = 0, unbucketed = [];
  for (const r of [...boysA, ...girlsA]) {
    const club = boysA.includes(r) ? 'boys' : 'girls';
    let birthDate = null;
    const raw = r.birthDate;
    if (typeof raw === 'number' && isFinite(raw)) birthDate = new Date(raw).toISOString().slice(0, 10);
    else if (typeof raw === 'string' && raw.length >= 10) birthDate = raw.slice(0, 10);
    const b = matchBucket(birthDate, club, defs);
    if (b) bucketed++;
    else unbucketed.push({
      name: `${(r.firstName || '').trim()} ${(r.lastName || '').trim()}`,
      birthDate, club, userId: r.userId, regStatus: r.registrationStatus,
    });
  }
  console.log(`BUCKETED: ${bucketed}    UNBUCKETED: ${unbucketed.length}`);
  if (unbucketed.length) {
    console.log('Unbucketed players:');
    for (const u of unbucketed) {
      console.log(`  ${u.club.padEnd(5)} ${u.birthDate || '????-??-??'}  ${u.name.padEnd(30)} userId=${u.userId}`);
    }
  }

  await pool.end();
})().catch(e => { console.error('FAIL:', e.message); process.exit(1); });
