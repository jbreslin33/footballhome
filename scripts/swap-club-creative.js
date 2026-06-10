#!/usr/bin/env node
// scripts/swap-club-creative.js
// Replaces the image on live Boys Club, Girls Club + Youth signup ads.
// Meta creatives are immutable — so we:
//   1. Upload the local PNG → image_hash
//   2. Create a NEW adcreative with the same caption / CTA / lead form
//   3. Update the live ad to point at the new creative_id
//
// Usage:
//   node scripts/swap-club-creative.js          # swap all three
//   node scripts/swap-club-creative.js boys     # only boys
//   node scripts/swap-club-creative.js girls    # only girls
//   node scripts/swap-club-creative.js youth    # only youth
//   node scripts/swap-club-creative.js --dry-run

require('dotenv').config({ path: __dirname + '/../env' });

const path = require('path');
const fs   = require('fs');

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

const args = process.argv.slice(2);
const DRY  = args.includes('--dry-run');
const which = args.find(a => ['boys', 'girls', 'youth'].includes(a.toLowerCase()));
const variants = which ? [which.toLowerCase()] : ['boys', 'girls', 'youth'];

if (!AD_ACCOUNT_ID || !PAGE_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID, META_PAGE_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

const ROOT = path.resolve(__dirname, '..');

const SPECS = {
  boys: {
    adId:    '120245826738410390',
    formId:  '2471488896628970',
    png:     path.join(ROOT, 'frontend', 'images', 'posts', 'boys-club-ad.png'),
    name:    'Lighthouse Boys Club — Creative (typography)',
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039252-lighthouse-1893-boys-club-soccer-membership',
    caption: `⚽ LIGHTHOUSE BOYS CLUB — NOW ENROLLING\n\nGrades 1–6 · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #BoysClub`,
  },
  girls: {
    adId:    '120245826836390390',
    formId:  '1008195014960429',
    png:     path.join(ROOT, 'frontend', 'images', 'posts', 'girls-club-ad.png'),
    name:    'Lighthouse Girls Club — Creative (typography)',
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039357-lighthouse-1893-girls-club-soccer-membership',
    caption: `⚽ LIGHTHOUSE GIRLS CLUB — NOW ENROLLING\n\nGrades 1–6 · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #GirlsClub`,
  },
  youth: {
    adId:    '120245748851660390',
    formId:  '1277787647463515',
    png:     path.join(ROOT, 'frontend', 'images', 'posts', 'youth-signup-ad.png'),
    name:    'Lighthouse Youth Soccer — Creative (typography)',
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039252-lighthouse-1893-boys-club-soccer-membership',
    caption: `⚽ LIGHTHOUSE YOUTH SOCCER — NOW ENROLLING\n\nBoys & Girls · Grades 1–6 · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer`,
  },
};

async function apiPost(pathStr, body) {
  const form = new URLSearchParams();
  for (const [k, v] of Object.entries(body)) form.append(k, v);
  form.append('access_token', ACCESS_TOKEN);
  const res = await fetch(`${API}/${pathStr}`, { method: 'POST', body: form });
  return res.json();
}

async function uploadImage(pngPath) {
  const buf  = fs.readFileSync(pngPath);
  const form = new FormData();
  form.append('access_token', ACCESS_TOKEN);
  form.append('filename', new Blob([buf], { type: 'image/png' }), path.basename(pngPath));
  const res = await fetch(`${API}/${AD_ACCOUNT_ID}/adimages`, { method: 'POST', body: form });
  const data = await res.json();
  if (data.error) throw new Error('Image upload error: ' + JSON.stringify(data.error, null, 2));
  return Object.values(data.images)[0].hash;
}

(async () => {
  for (const variant of variants) {
    const s = SPECS[variant];
    console.log(`\n=== ${variant.toUpperCase()} CLUB ===`);
    if (!fs.existsSync(s.png)) { console.error('Missing PNG:', s.png); process.exit(1); }

    if (DRY) {
      console.log(`[dry-run] would upload ${s.png}`);
      console.log(`[dry-run] would create creative "${s.name}"`);
      console.log(`[dry-run] would update ad ${s.adId} to new creative_id`);
      continue;
    }

    // 1. Upload image
    console.log(`📤 Uploading ${path.basename(s.png)}...`);
    const imageHash = await uploadImage(s.png);
    console.log(`   image_hash: ${imageHash}`);

    // 2. Create new ad creative
    console.log(`🎨 Creating new adcreative...`);
    const creative = await apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
      name: `${s.name} — ${new Date().toISOString().replace(/[:.]/g, '-')}`,
      object_story_spec: JSON.stringify({
        page_id: PAGE_ID,
        link_data: {
          image_hash: imageHash,
          link:       s.ctaUrl,
          message:    s.caption,
          call_to_action: { type: 'SIGN_UP', value: { lead_gen_form_id: s.formId } },
        },
      }),
    });
    if (creative.error) { console.error('Creative error:', JSON.stringify(creative.error, null, 2)); process.exit(1); }
    console.log(`   creative_id: ${creative.id}`);

    // 3. Point the live ad at the new creative
    console.log(`🔁 Updating ad ${s.adId} → creative ${creative.id}`);
    const upd = await apiPost(s.adId, {
      creative: JSON.stringify({ creative_id: creative.id }),
    });
    if (upd.error) { console.error('Ad update error:', JSON.stringify(upd.error, null, 2)); process.exit(1); }
    console.log(`   ✅ ${JSON.stringify(upd)}`);
  }

  console.log('\n🎉 Done. New creative is live. (Meta may cache old preview iframes briefly.)');
})().catch(err => { console.error('❌ Failed:', err); process.exit(1); });
