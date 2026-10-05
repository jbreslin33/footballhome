#!/usr/bin/env node
// scripts/drive-times.js — coordinates and driving minutes for the places
// events are held at (mig 526), for the conflict check on #my.
//
//   event_places       ← every location text of an event in the window that
//                        has no row yet, geocoded with OpenStreetMap's
//                        Nominatim (one request a second, as its policy asks)
//   place_drive_times  ← driving minutes between every pair of places, from
//                        the public OSRM router's table service, whenever a
//                        place was added
//
// Called at the end of every calendar sync (scripts/gcal-sync.js) — a no-op
// query when nothing is new — and runnable by hand:  node scripts/drive-times.js
// A location that will not geocode keeps a row with a note and is not asked
// again; set its latitude / longitude by hand (migration) to include it.
const UA = 'footballhome.org schedule-conflicts (jbreslin@footballhome.org)';
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function getJson(url) {
  const res = await fetch(url, { headers: { 'User-Agent': UA, 'Accept': 'application/json' }, signal: AbortSignal.timeout(30000) });
  if (!res.ok) throw new Error(`HTTP ${res.status} ${url.slice(0, 80)}`);
  return res.json();
}

// The calendar's text is "Venue name, street, city, ST zip, USA".  The
// geocoder does best on a plain street address, so try the whole thing,
// then without the venue name, with a house-number range ("101-199") or a
// lettered number ("5847R") reduced to one number, and an "A & B" corner
// as "A and B".  A match that is only a city, county or zip is refused —
// it would put every such place on the same spot.
function candidates(location) {
  const clean = location.replace(/\s+/g, ' ').replace(/\bField \d+\s*$/i, '').replace(/\(.*?\)/g, ' ').replace(/\s+/g, ' ').trim();
  const plain = (t) => t.replace(/\b\d+-(\d+)\b/, '$1').replace(/\b(\d+)[A-Za-z]\b/, '$1').replace(/\s*&\s*/g, ' and ');
  const parts = clean.split(',').map(x => x.trim()).filter(Boolean);
  const out = [clean, plain(clean)];
  if (parts.length > 2) { out.push(parts.slice(1).join(', ')); out.push(plain(parts.slice(1).join(', '))); }
  if (parts.length > 3 && /^\d/.test(parts[1]) === false && /\d/.test(parts[0])) out.push(plain(parts[0] + ', ' + parts.slice(-2).join(', ')));
  return [...new Set(out)];
}

const TOO_COARSE = new Set(['city', 'town', 'village', 'hamlet', 'county', 'state', 'postcode', 'municipality', 'township', 'suburb', 'borough', 'neighbourhood', 'administrative', 'country']);

async function geocode(location) {
  for (const q of candidates(location)) {
    const hits = await getJson(`https://nominatim.openstreetmap.org/search?format=json&limit=3&countrycodes=us&q=${encodeURIComponent(q)}`);
    await sleep(1100);
    const hit = hits.find(h => !TOO_COARSE.has(h.addresstype) && !TOO_COARSE.has(h.type));
    if (hit) return { lat: Number(hit.lat), lon: Number(hit.lon), as: hit.display_name };
  }
  return null;
}

async function run(pg, { log = console.log } = {}) {
  const { rows: fresh } = await pg.query(`
    SELECT DISTINCT BTRIM(ge.location) AS location
      FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.deleted_at IS NULL AND ge.starts_at > now() - interval '7 days' AND ge.starts_at < now() + interval '120 days'
       AND COALESCE(BTRIM(ge.location), '') <> ''
       AND NOT EXISTS (SELECT 1 FROM event_places p WHERE p.location = BTRIM(ge.location))`);
  let added = 0;
  for (const { location } of fresh) {
    let g = null, note = 'ok';
    try { g = await geocode(location); if (!g) note = 'no match'; } catch (err) { log(`  drive-times: geocode failed for "${location}": ${err.message}`); continue; }
    await pg.query(`INSERT INTO event_places (location, latitude, longitude, geocoded_as, geocode_note, geocoded_at)
                    VALUES ($1, $2, $3, $4, $5, now()) ON CONFLICT (location) DO NOTHING`,
                   [location, g ? g.lat : null, g ? g.lon : null, g ? g.as : null, note]);
    added++;
    if (!g) log(`  drive-times: no coordinates for "${location}"`);
  }
  // Any place still missing a row to or from another → redo the whole table.
  const { rows: places } = await pg.query('SELECT id, latitude, longitude FROM event_places WHERE latitude IS NOT NULL ORDER BY id');
  const { rows: [{ n }] } = await pg.query('SELECT COUNT(*)::int AS n FROM place_drive_times');
  if (places.length < 2 || n >= places.length * places.length) return { added, pairs: 0 };
  let pairs = 0;
  const CHUNK = 80;   // the public router caps a table at 100 coordinates
  for (let a = 0; a < places.length; a += CHUNK) {
    for (let b = 0; b < places.length; b += CHUNK) {
      const src = places.slice(a, a + CHUNK), dst = a === b ? [] : places.slice(b, b + CHUNK);
      const all = [...src, ...dst];
      const coords = all.map(p => `${Number(p.longitude)},${Number(p.latitude)}`).join(';');
      const srcIdx = src.map((_, i) => i).join(';');
      const dstIdx = (dst.length ? dst.map((_, i) => src.length + i) : src.map((_, i) => i)).join(';');
      const t = await getJson(`https://router.project-osrm.org/table/v1/driving/${coords}?annotations=duration,distance&sources=${srcIdx}&destinations=${dstIdx}`);
      if (t.code !== 'Ok') throw new Error(`OSRM ${t.code}`);
      const to = dst.length ? dst : src;
      for (let i = 0; i < src.length; i++) for (let j = 0; j < to.length; j++) {
        const secs = t.durations[i][j]; if (secs === null || secs === undefined) continue;
        await pg.query(`INSERT INTO place_drive_times (from_place_id, to_place_id, minutes, meters) VALUES ($1, $2, $3, $4)
                        ON CONFLICT (from_place_id, to_place_id) DO UPDATE SET minutes = EXCLUDED.minutes, meters = EXCLUDED.meters, fetched_at = now()`,
                       [src[i].id, to[j].id, Math.round(secs / 6) / 10, t.distances ? Math.round(t.distances[i][j]) : null]);
        pairs++;
      }
      await sleep(1100);
    }
  }
  log(`  drive-times: ${added} place(s) added, ${pairs} drive times stored`);
  return { added, pairs };
}

module.exports = { run };

if (require.main === module) {
  require('dotenv').config({ path: __dirname + '/../env' });
  const { Pool } = require('pg');
  const pg = new Pool({ host: process.env.PGHOST || 'localhost', port: parseInt(process.env.PGPORT || '5432', 10),
                        database: process.env.PGDATABASE || 'footballhome', user: process.env.PGUSER || 'footballhome_user',
                        password: process.env.PGPASSWORD || 'footballhome_pass' });
  run(pg).then(r => { console.log('drive-times:', r); return pg.end(); })
         .catch(err => { console.error('drive-times failed:', err.message); pg.end(); process.exit(1); });
}
