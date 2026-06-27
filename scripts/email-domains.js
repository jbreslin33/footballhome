// Break down current LA member emails by domain.
//
// Standalone Node script — the meta-leads-webhook container that used to
// host this was removed in the Phase 14 port; run it from the host with
// the LEAGUEAPPS_* env vars set and the PEM living at
// $LEAGUEAPPS_PEM_DIR/<CID>.pem (defaults to ./config/<CID>.pem).
//   Usage: (cd /path/to/footballhome && env $(grep -E '^LEAGUEAPPS_' env | xargs) node scripts/email-domains.js)
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

  const byDomain = {};
  let withEmail = 0, withoutEmail = 0;
  for (const r of all) {
    const e = (r.email || '').trim().toLowerCase();
    if (!e || !e.includes('@')) { withoutEmail++; continue; }
    withEmail++;
    const dom = e.split('@')[1] || '(?)';
    byDomain[dom] = (byDomain[dom] || 0) + 1;
  }

  const total = all.length;
  const sorted = Object.entries(byDomain).sort((a, b) => b[1] - a[1]);

  const gmail     = byDomain['gmail.com'] || 0;
  const msPersonal = ['outlook.com','hotmail.com','live.com','msn.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const apple     = ['icloud.com','me.com','mac.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const yahoo     = ['yahoo.com','ymail.com','rocketmail.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const other     = withEmail - gmail - msPersonal - apple - yahoo;

  console.log(`\nTOTAL active registrations: ${total}`);
  console.log(`  with email:    ${withEmail}`);
  console.log(`  without email: ${withoutEmail}\n`);
  const pct = n => withEmail ? (100 * n / withEmail).toFixed(1) + '%' : '—';
  console.log(`COVERAGE BY PROVIDER GROUP (of ${withEmail} with email):`);
  console.log(`  Gmail              ${String(gmail).padStart(3)}  ${pct(gmail)}`);
  console.log(`  Microsoft (out/hot/live/msn)  ${String(msPersonal).padStart(3)}  ${pct(msPersonal)}`);
  console.log(`  Apple (icloud/me/mac)        ${String(apple).padStart(3)}  ${pct(apple)}`);
  console.log(`  Yahoo              ${String(yahoo).padStart(3)}  ${pct(yahoo)}`);
  console.log(`  Other              ${String(other).padStart(3)}  ${pct(other)}`);

  console.log(`\nTOP DOMAINS:`);
  for (const [d, n] of sorted.slice(0, 25)) {
    console.log(`  ${d.padEnd(28)} ${String(n).padStart(3)}  ${pct(n)}`);
  }

  // "Other" providers list:
  const knownGmail = new Set(['gmail.com']);
  const knownMs = new Set(['outlook.com','hotmail.com','live.com','msn.com']);
  const knownApple = new Set(['icloud.com','me.com','mac.com']);
  const knownYahoo = new Set(['yahoo.com','ymail.com','rocketmail.com']);
  const otherList = sorted.filter(([d]) =>
    !knownGmail.has(d) && !knownMs.has(d) && !knownApple.has(d) && !knownYahoo.has(d)
  );
  if (otherList.length) {
    console.log(`\nOTHER DOMAINS (need email magic-link fallback):`);
    for (const [d, n] of otherList) console.log(`  ${d.padEnd(28)} ${n}`);
  }
})().catch(e => { console.error('FAIL:', e.message); process.exit(1); });
