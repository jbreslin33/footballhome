#!/usr/bin/env node
// LeagueApps API round-trip probe.
//
// Usage:
//   ./scripts/la-probe.js men           # or women, boys, girls, men-pickup, ...
//   ./scripts/la-probe.js 5039300       # or a raw program id
//   ./scripts/la-probe.js men women     # any number of programs, run serially
//   FORCE_NEW_TOKEN=1 ./scripts/la-probe.js men   # skip token cache, cold path
//
// Talks directly to the LeagueApps API (no backend, no DB). Prints per-step
// timing (token mint, GET pages, parse) and the resolved member list.

const fs   = require('fs');
const path = require('path');
const crypto = require('crypto');
const https  = require('https');

// ─── env loader (very small .env parser — we only need a few keys) ──────────
function loadEnvFile(p) {
    if (!fs.existsSync(p)) return;
    const text = fs.readFileSync(p, 'utf8');
    for (const raw of text.split('\n')) {
        const line = raw.trim();
        if (!line || line.startsWith('#')) continue;
        const eq = line.indexOf('=');
        if (eq < 0) continue;
        const k = line.slice(0, eq).trim();
        let v = line.slice(eq + 1).trim();
        if ((v.startsWith('"') && v.endsWith('"')) ||
            (v.startsWith("'") && v.endsWith("'"))) {
            v = v.slice(1, -1);
        }
        if (process.env[k] === undefined) process.env[k] = v;
    }
}
loadEnvFile(path.join(__dirname, '..', 'env'));

const CLIENT_ID = process.env.LEAGUEAPPS_API_PRIVATE_KEY;
const SITE_ID   = parseInt(process.env.LEAGUEAPPS_SITE_ID || '0', 10);
if (!CLIENT_ID) { console.error('LEAGUEAPPS_API_PRIVATE_KEY not set'); process.exit(2); }
if (!SITE_ID)   { console.error('LEAGUEAPPS_SITE_ID not set');       process.exit(2); }

const PEM_PATH = path.join(__dirname, '..', 'config', `${CLIENT_ID}.pem`);
if (!fs.existsSync(PEM_PATH)) {
    console.error(`PEM not found: ${PEM_PATH}`);
    process.exit(2);
}
const PEM = fs.readFileSync(PEM_PATH, 'utf8');

const AUTH_URL = 'https://auth.leagueapps.io/v2/auth/token';
const API_BASE = 'https://public.leagueapps.io/v2';

// ─── program name → id resolver ─────────────────────────────────────────────
const PROGRAMS = {
    'men':          parseInt(process.env.LEAGUEAPPS_MENS_PROGRAM_ID       || '5039300', 10),
    'women':        parseInt(process.env.LEAGUEAPPS_WOMENS_PROGRAM_ID     || '5039340', 10),
    'boys':         parseInt(process.env.LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID  || '5039252', 10),
    'girls':        parseInt(process.env.LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID || '5039357', 10),
    'men-pickup':   5070075,
    'women-pickup': 5064686,
    'boys-pickup':  5064618,
    'girls-pickup': 5064662,
    'membership':   parseInt(process.env.LEAGUEAPPS_MEMBERSHIP_PROGRAM_ID || '0', 10),
};

function resolveProgram(arg) {
    const lower = String(arg).toLowerCase();
    if (PROGRAMS[lower]) return { name: lower, id: PROGRAMS[lower] };
    const n = parseInt(arg, 10);
    if (Number.isFinite(n) && n > 0) return { name: `program-${n}`, id: n };
    console.error(`Unknown program: ${arg}. Known: ${Object.keys(PROGRAMS).join(', ')}, or a raw numeric id.`);
    process.exit(2);
}

// ─── JWT (RS256) mint ───────────────────────────────────────────────────────
function b64url(buf) {
    return Buffer.from(buf).toString('base64')
        .replace(/=+$/,'').replace(/\+/g,'-').replace(/\//g,'_');
}
function mintAssertion() {
    const now = Math.floor(Date.now() / 1000);
    const header  = { alg: 'RS256', typ: 'JWT' };
    const payload = { aud: AUTH_URL, iss: CLIENT_ID, sub: CLIENT_ID, iat: now, exp: now + 300 };
    const enc = b64url(JSON.stringify(header)) + '.' + b64url(JSON.stringify(payload));
    const sig = crypto.createSign('RSA-SHA256').update(enc).sign(PEM);
    return enc + '.' + b64url(sig);
}

// ─── https helpers ──────────────────────────────────────────────────────────
function httpsRequest(url, opts, body) {
    return new Promise((resolve, reject) => {
        const req = https.request(url, opts, (res) => {
            const chunks = [];
            res.on('data', (c) => chunks.push(c));
            res.on('end', () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString('utf8') }));
        });
        req.on('error', reject);
        if (body) req.write(body);
        req.end();
    });
}

// ─── token cache on disk ────────────────────────────────────────────────────
const TOKEN_CACHE = path.join(__dirname, '..', '.la-probe-token.json');
function readTokenCache() {
    try {
        const obj = JSON.parse(fs.readFileSync(TOKEN_CACHE, 'utf8'));
        if (obj.expiresAt && Date.now() < obj.expiresAt - 60_000) return obj;
    } catch {}
    return null;
}
function writeTokenCache(token, expiresInSec) {
    fs.writeFileSync(TOKEN_CACHE, JSON.stringify({
        token, expiresAt: Date.now() + expiresInSec * 1000,
    }));
}

async function getToken() {
    if (!process.env.FORCE_NEW_TOKEN) {
        const cached = readTokenCache();
        if (cached) return { token: cached.token, source: 'cache', ms: 0 };
    }
    const t0 = Date.now();
    const assertion = mintAssertion();
    const body =
        'grant_type=' + encodeURIComponent('urn:ietf:params:oauth:grant-type:jwt-bearer') +
        '&assertion=' + encodeURIComponent(assertion);
    const res = await httpsRequest(AUTH_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': Buffer.byteLength(body),
        },
    }, body);
    const ms = Date.now() - t0;
    if (res.status !== 200) {
        throw new Error(`token exchange failed status=${res.status}: ${res.body.slice(0, 300)}`);
    }
    const data = JSON.parse(res.body);
    if (!data.access_token) throw new Error(`token response missing access_token: ${res.body.slice(0, 300)}`);
    writeTokenCache(data.access_token, data.expires_in || 1800);
    return { token: data.access_token, source: 'fresh', ms };
}

// ─── paginated program fetch ────────────────────────────────────────────────
const MEMBER_STATUSES = new Set(['SPOT_RESERVED', 'SPOT_PENDING', 'WAITING_LIST']);

async function fetchProgram(programId, token) {
    const pages = [];
    let lastUpdated = 0, lastId = 0;
    const t0 = Date.now();
    for (let page = 0; page < 50; ++page) {
        const url = `${API_BASE}/sites/${SITE_ID}/export/registrations-2` +
                    `?last-updated=${lastUpdated}&last-id=${lastId}&program-id=${programId}`;
        const pT0 = Date.now();
        const res = await httpsRequest(url, {
            method: 'GET',
            headers: { Authorization: `Bearer ${token}` },
        });
        const pMs = Date.now() - pT0;
        if (res.status !== 200) {
            throw new Error(`GET page ${page} status=${res.status}: ${res.body.slice(0, 300)}`);
        }
        const batch = JSON.parse(res.body);
        if (!Array.isArray(batch) || batch.length === 0) {
            pages.push({ page, ms: pMs, count: 0 });
            break;
        }
        pages.push({ page, ms: pMs, count: batch.length });
        for (const rec of batch) pages.push, batch;
        // dedupe accumulator
        pages._all = (pages._all || []).concat(batch);
        const tail = batch[batch.length - 1];
        lastUpdated = tail.lastUpdated || 0;
        lastId      = tail.id         || 0;
    }
    const all = pages._all || [];
    // dedupe by registrationId
    const latest = new Map();
    for (const r of all) {
        const rid = String(r.registrationId ?? r.id ?? '');
        if (!rid) continue;
        const key = (r.lastUpdated || 0) * 1_000_000 + (r.id || 0);
        const existing = latest.get(rid);
        if (!existing || key >= existing.key) latest.set(rid, { key, rec: r });
    }
    const totalMs = Date.now() - t0;
    return { totalMs, pages: pages.filter(p => p.page !== undefined), all, uniques: [...latest.values()].map(v => v.rec) };
}

// ─── person shape helper ────────────────────────────────────────────────────
function personRow(rec) {
    const first = rec.firstName || rec.userFirstName || rec.member?.firstName || '';
    const last  = rec.lastName  || rec.userLastName  || rec.member?.lastName  || '';
    const email = rec.email     || rec.userEmail     || rec.member?.email     || '';
    const status = rec.registrationStatus || rec.status || '';
    const userId = rec.userId ?? rec.member?.userId ?? '';
    const regId  = rec.registrationId ?? rec.id ?? '';
    return { userId, regId, first, last, email, status, isMember: MEMBER_STATUSES.has(status) };
}

// ─── main ───────────────────────────────────────────────────────────────────
async function main() {
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.error('usage: la-probe.js <program> [<program> ...]');
        console.error('       programs: ' + Object.keys(PROGRAMS).join(', ') + ', or raw numeric id');
        process.exit(2);
    }

    const targets = args.map(resolveProgram);

    const tokenResult = await getToken();
    console.log(`token: source=${tokenResult.source} mint_ms=${tokenResult.ms}`);
    console.log('');

    for (const { name, id } of targets) {
        console.log(`── ${name} (program ${id}) ────────────────────────────`);
        const { totalMs, pages, uniques } = await fetchProgram(id, tokenResult.token);
        for (const p of pages) {
            console.log(`  page ${p.page}: ${p.count} recs in ${p.ms}ms`);
        }
        const members = uniques.map(personRow).filter(p => p.isMember);
        const nonMembers = uniques.map(personRow).filter(p => !p.isMember);
        console.log(`  total: ${uniques.length} unique registrations in ${totalMs}ms (${members.length} members / ${nonMembers.length} non-members)`);
        console.log('');
        console.log('  MEMBERS (registrationStatus in SPOT_RESERVED / SPOT_PENDING / WAITING_LIST):');
        for (const p of members.sort((a,b) => (a.last+a.first).localeCompare(b.last+b.first))) {
            console.log(`    userId=${String(p.userId).padEnd(9)} regId=${String(p.regId).padEnd(9)} ${p.status.padEnd(14)} ${p.first} ${p.last}  <${p.email}>`);
        }
        if (nonMembers.length) {
            console.log('');
            console.log('  NON-MEMBERS (any other status):');
            for (const p of nonMembers.sort((a,b) => (a.last+a.first).localeCompare(b.last+b.first))) {
                console.log(`    userId=${String(p.userId).padEnd(9)} regId=${String(p.regId).padEnd(9)} ${p.status.padEnd(14)} ${p.first} ${p.last}  <${p.email}>`);
            }
        }
        console.log('');
    }
}

main().catch((e) => { console.error('probe failed:', e.message); process.exit(1); });
