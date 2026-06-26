// Email domain breakdown — MENS program only.
const jwt = require('jsonwebtoken');
const fsp = require('fs').promises;

const LA_AUTH = 'https://auth.leagueapps.io/v2/auth/token';
const LA_API  = 'https://public.leagueapps.io/v2';
const SITE = parseInt(process.env.LEAGUEAPPS_SITE_ID, 10);
const MENS = parseInt(process.env.LEAGUEAPPS_MENS_PROGRAM_ID || '5039300', 10);
const CID  = process.env.LEAGUEAPPS_API_PRIVATE_KEY;

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
  const mens = (await fetchAll(MENS, tok)).filter(isActive);

  const byDomain = {};
  let withEmail = 0, withoutEmail = 0;
  const noEmailList = [];
  for (const r of mens) {
    // for mens, almost everyone is ADULT; check both 'email' and 'parentEmail' just in case
    const primary = (r.email || '').trim().toLowerCase();
    const parent  = (r.parentEmail || '').trim().toLowerCase();
    const e = primary && primary.includes('@') ? primary
            : (parent && parent.includes('@') ? parent : '');
    if (!e) { withoutEmail++; noEmailList.push(r); continue; }
    withEmail++;
    const dom = e.split('@')[1] || '(?)';
    byDomain[dom] = (byDomain[dom] || 0) + 1;
  }

  const total = mens.length;
  const sorted = Object.entries(byDomain).sort((a, b) => b[1] - a[1]);
  const pct = n => withEmail ? (100 * n / withEmail).toFixed(1) + '%' : '—';

  const gmail = byDomain['gmail.com'] || 0;
  const ms    = ['outlook.com','hotmail.com','live.com','msn.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const apple = ['icloud.com','me.com','mac.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const yahoo = ['yahoo.com','ymail.com','rocketmail.com'].reduce((s, d) => s + (byDomain[d] || 0), 0);
  const other = withEmail - gmail - ms - apple - yahoo;

  console.log(`\nMENS active registrations: ${total}`);
  console.log(`  with email:    ${withEmail}`);
  console.log(`  without email: ${withoutEmail}\n`);

  console.log(`COVERAGE BY PROVIDER GROUP (of ${withEmail} with email):`);
  console.log(`  Gmail              ${String(gmail).padStart(3)}  ${pct(gmail)}`);
  console.log(`  Microsoft          ${String(ms).padStart(3)}  ${pct(ms)}`);
  console.log(`  Apple              ${String(apple).padStart(3)}  ${pct(apple)}`);
  console.log(`  Yahoo              ${String(yahoo).padStart(3)}  ${pct(yahoo)}`);
  console.log(`  Other              ${String(other).padStart(3)}  ${pct(other)}`);

  console.log(`\nALL DOMAINS:`);
  for (const [d, n] of sorted) {
    console.log(`  ${d.padEnd(28)} ${String(n).padStart(3)}  ${pct(n)}`);
  }

  if (noEmailList.length) {
    console.log(`\nMENS with NO email at all:`);
    for (const r of noEmailList) {
      console.log(`  ${r.firstName} ${r.lastName} (userId ${r.userId}, regId ${r.registrationId ?? r.id})`);
    }
  }
})().catch(e => { console.error(e); process.exit(1); });
