// Inspect "no email" LA registrations to see what fields they actually carry.
const jwt = require('jsonwebtoken');
const fsp = require('fs').promises;

const LA_AUTH = 'https://auth.leagueapps.io/v2/auth/token';
const LA_API  = 'https://public.leagueapps.io/v2';
const SITE   = parseInt(process.env.LEAGUEAPPS_SITE_ID, 10);
const BOYS   = parseInt(process.env.LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID  || '5039252', 10);
const GIRLS  = parseInt(process.env.LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID || '5039357', 10);
const MENS   = parseInt(process.env.LEAGUEAPPS_MENS_PROGRAM_ID       || '5039300', 10);
const CID    = process.env.LEAGUEAPPS_API_PRIVATE_KEY;

async function getToken() {
  const pem = await fsp.readFile('/app/config/' + CID + '.pem', 'utf8');
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
  return (await r.json()).access_token;
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

const isActive = r => {
  const s = (r.registrationStatus || '').toUpperCase();
  return s === 'SPOT_RESERVED' || s === 'SPOT_PENDING';
};

(async () => {
  const tok = await getToken();
  const [boys, girls, mens] = await Promise.all([
    fetchAll(BOYS,  tok),
    fetchAll(GIRLS, tok),
    fetchAll(MENS,  tok),
  ]);
  const all = [
    ...boys .filter(isActive).map(r => ({ ...r, _src: 'boys'  })),
    ...girls.filter(isActive).map(r => ({ ...r, _src: 'girls' })),
    ...mens .filter(isActive).map(r => ({ ...r, _src: 'mens'  })),
  ];

  const noEmail = all.filter(r => {
    const e = (r.email || '').trim().toLowerCase();
    return !e || !e.includes('@');
  });

  console.log(`\n${noEmail.length} active records with no top-level 'email'\n`);

  // dump first record fully so we can see every field LA returns
  if (noEmail.length) {
    console.log('--- FULL FIELD DUMP of first no-email record ---');
    console.log(JSON.stringify(noEmail[0], null, 2));
    console.log('--- END ---\n');
  }

  // for each, list which fields contain an "@"
  console.log('PER-RECORD EMAIL-LIKE FIELDS:');
  for (const r of noEmail) {
    const hits = [];
    const walk = (obj, path) => {
      if (obj == null) return;
      if (typeof obj === 'string') {
        if (obj.includes('@') && obj.includes('.')) hits.push(`${path}=${obj}`);
        return;
      }
      if (Array.isArray(obj)) { obj.forEach((v, i) => walk(v, `${path}[${i}]`)); return; }
      if (typeof obj === 'object') {
        for (const k of Object.keys(obj)) walk(obj[k], path ? `${path}.${k}` : k);
      }
    };
    walk(r, '');
    console.log(`\n[${r._src}] ${r.firstName} ${r.lastName} (regId ${r.registrationId ?? r.id}, userId ${r.userId ?? '?'})`);
    if (hits.length) {
      for (const h of hits) console.log('   ' + h);
    } else {
      console.log('   (no @-containing strings anywhere in record)');
    }
  }

  // top-level keys of first record so we know what's available
  if (all.length) {
    console.log('\n\nALL TOP-LEVEL KEYS (sample record):');
    console.log(Object.keys(all[0]).sort().join(', '));
  }
})().catch(e => { console.error(e); process.exit(1); });
