#!/usr/bin/env node
// scripts/ad-targeting-audit.js — full location + audience-expansion audit
// for every adset in the ad account.  Flags anything that could cause an
// ad to leak outside the intended Philadelphia radius.

require('dotenv').config({ path: __dirname + '/../env' });
const API = 'https://graph.facebook.com/v21.0';
const acc = process.env.META_AD_ACCOUNT_ID;
const tok = process.env.META_ADS_TOKEN;

async function fbList(path) {
  const out = [];
  let url = `${API}/${path}${path.includes('?') ? '&' : '?'}access_token=${tok}&limit=100`;
  while (url) {
    const r = await fetch(url);
    const j = await r.json();
    if (j.error) throw new Error(JSON.stringify(j.error));
    out.push(...(j.data || []));
    url = j.paging && j.paging.next;
  }
  return out;
}

function summarizeGeo(geo) {
  if (!geo) return '(none)';
  const parts = [];
  if (geo.countries)         parts.push('countries=' + geo.countries.join(','));
  if (geo.regions)           parts.push('regions=' + geo.regions.map(r => r.name || r.key).join(','));
  if (geo.cities)            parts.push('cities=' + geo.cities.map(c => `${c.name}(${c.radius}${c.distance_unit || 'mi'})`).join(','));
  if (geo.zips)              parts.push('zips=' + geo.zips.map(z => z.name || z.key).join(','));
  if (geo.custom_locations)  parts.push('custom=' + geo.custom_locations.map(c => `${c.name || c.address_string}(${c.radius}${c.distance_unit || 'mi'})`).join(' | '));
  if (geo.geo_markets)       parts.push('markets=' + geo.geo_markets.map(m => m.name || m.key).join(','));
  if (geo.places)            parts.push('places=' + geo.places.map(p => p.name).join(','));
  if (geo.location_types)    parts.push('types=' + geo.location_types.join('+'));
  return parts.join('  |  ') || '(empty)';
}

(async () => {
  const adsets = await fbList(`${acc}/adsets?fields=id,name,effective_status,targeting,targeting_optimization,is_dynamic_creative,promoted_object`);

  const rows = [];
  for (const a of adsets) {
    const t = a.targeting || {};
    const flags = [];

    // === HARD LOCATION LEAKS ===
    const geo = t.geo_locations || {};
    if (geo.countries && geo.countries.length && !geo.cities && !geo.custom_locations && !geo.zips && !geo.regions) {
      flags.push('WHOLE-COUNTRY targeting (no city/zip/custom refinement)');
    }
    if (geo.regions && geo.regions.some(r => !/pennsylvania|new jersey|delaware/i.test(r.name || ''))) {
      flags.push('regions include NON-tri-state area: ' + geo.regions.map(r => r.name).join(','));
    }
    if (geo.cities && geo.cities.some(c => !/philadelphia|camden|cherry hill|trenton|wilmington/i.test(c.name || ''))) {
      flags.push('cities outside metro: ' + geo.cities.map(c => c.name).join(','));
    }
    if (geo.cities && geo.cities.some(c => c.radius > 25)) {
      flags.push('city radius > 25mi: ' + geo.cities.map(c => c.name + '=' + c.radius + 'mi').join(','));
    }
    if (geo.custom_locations && geo.custom_locations.some(c => c.radius > 25)) {
      flags.push('custom location radius > 25mi');
    }
    if (geo.location_types && geo.location_types.includes('travel_in')) {
      flags.push('location_types includes travel_in (targets tourists)');
    }
    if (geo.location_types && geo.location_types.includes('visit')) {
      flags.push('location_types includes visit (targets visitors)');
    }

    // === EXPANSION / ADVANTAGE settings that override manual targeting ===
    const ta = t.targeting_automation || {};
    if (ta.advantage_audience === 1 || ta.advantage_audience === true) {
      flags.push('advantage_audience=ON (Meta may expand beyond your targeting)');
    }
    if (t.targeting_optimization && t.targeting_optimization !== 'none') {
      flags.push('targeting_optimization=' + t.targeting_optimization);
    }
    if (a.targeting_optimization && a.targeting_optimization !== 'none') {
      flags.push('adset targeting_optimization=' + a.targeting_optimization);
    }
    if (t.flexible_spec && t.flexible_spec.some(s => s.expansion === 'expanded')) {
      flags.push('flexible_spec has expansion=expanded');
    }
    // Interest / detailed-targeting expansion is the sneakiest one:
    if (t.expanded_audience_targeting_options
        || t.expansion === true
        || t.audience_network_positions === undefined && false) {
      // no-op placeholder; audience-network positions checked below
    }

    // === PLATFORM SURFACE (audience network can serve nationally) ===
    if (t.publisher_platforms && t.publisher_platforms.includes('audience_network')) {
      flags.push('audience_network placement enabled');
    }
    if (t.publisher_platforms && t.publisher_platforms.includes('messenger')) {
      flags.push('messenger placement enabled');
    }
    // If publisher_platforms unset → Meta uses ALL placements incl audience network.
    if (!t.publisher_platforms) {
      flags.push('publisher_platforms UNSET (Meta uses all placements incl Audience Network — CAN LEAK GEO)');
    }

    // === EXCLUSIONS worth noting ===
    if (t.excluded_geo_locations) {
      flags.push('has excluded_geo_locations');
    }

    rows.push({
      name: a.name.replace(/ — Ad Set.*/, '').replace(/^Lighthouse /, ''),
      id: a.id,
      status: a.effective_status,
      age: (t.age_min || '?') + '-' + (t.age_max || '?'),
      genders: JSON.stringify(t.genders || []),
      locales: JSON.stringify(t.locales || []),
      geo: summarizeGeo(t.geo_locations),
      platforms: (t.publisher_platforms || ['ALL(default)']).join('+'),
      advAudience: ta.advantage_audience,
      flags,
    });
  }

  // Sort ACTIVE first, then flagged
  rows.sort((a, b) => {
    if (a.status === 'ACTIVE' && b.status !== 'ACTIVE') return -1;
    if (b.status === 'ACTIVE' && a.status !== 'ACTIVE') return 1;
    return b.flags.length - a.flags.length;
  });

  for (const r of rows) {
    const badge = r.flags.length ? ' ⚠️ ' + r.flags.length + ' FLAG(S)' : ' ✅ clean';
    console.log('\n' + '='.repeat(90));
    console.log(`[${r.status}] ${r.name}${badge}`);
    console.log(`  id=${r.id}  age=${r.age}  gender=${r.genders}  locales=${r.locales}  advAud=${r.advAudience}`);
    console.log(`  platforms: ${r.platforms}`);
    console.log(`  geo: ${r.geo}`);
    for (const f of r.flags) console.log(`     ⚠️  ${f}`);
  }

  // Summary
  const active = rows.filter(r => r.status === 'ACTIVE');
  const flagged = active.filter(r => r.flags.length);
  console.log('\n' + '='.repeat(90));
  console.log(`SUMMARY:  ${active.length} ACTIVE adsets, ${flagged.length} with flags.`);
  if (flagged.length) {
    console.log('Flagged ACTIVE:');
    for (const r of flagged) console.log(`  - ${r.name}  (${r.flags.length} flag${r.flags.length > 1 ? 's' : ''})`);
  }
})().catch(e => { console.error('ERROR:', e); process.exit(1); });
