#!/usr/bin/env node
// scripts/preview-creative.js
// Preview a club-card creative (boys/girls) in Meta's ad-preview iframe
// WITHOUT modifying any live ad. Uploads the local PNG to /adimages just
// to get an image_hash, then calls /act_<id>/generatepreviews with a
// creative_spec, fetches the iframe, and screenshots it via Puppeteer.
//
// Usage:
//   node scripts/preview-creative.js boys
//   node scripts/preview-creative.js girls

require('dotenv').config({ path: __dirname + '/../env' });

const puppeteer = require('puppeteer');
const path      = require('path');
const fs        = require('fs');

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;
const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

const variant = (process.argv[2] || '').toLowerCase();
if (!['boys', 'girls'].includes(variant)) {
  console.error('Usage: node scripts/preview-creative.js <boys|girls>');
  process.exit(1);
}
if (!AD_ACCOUNT_ID || !PAGE_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID, META_PAGE_ID or META_ADS_TOKEN in env');
  process.exit(1);
}

const ROOT = path.resolve(__dirname, '..');
const PNG  = path.join(ROOT, 'frontend', 'images', 'posts', `${variant}-club-ad.png`);
const OUT_DIR = path.join(ROOT, 'frontend', 'images', 'posts', 'previews');

const SPECS = {
  boys: {
    formId:  '1704106777282059',
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039252-lighthouse-1893-boys-club-soccer-membership',
    caption: `⚽ LIGHTHOUSE BOYS CLUB — NOW ENROLLING\n\nGrades 1–6 · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #BoysClub`,
  },
  girls: {
    formId:  '1571742281184926',
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039357-lighthouse-1893-girls-club-soccer-membership',
    caption: `⚽ LIGHTHOUSE GIRLS CLUB — NOW ENROLLING\n\nGrades 1–6 · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #GirlsClub`,
  },
};

const FORMATS = [
  { key: 'INSTAGRAM_STANDARD',   label: 'Instagram Feed',       viewport: { width: 540, height: 1100 } },
  { key: 'MOBILE_FEED_STANDARD', label: 'Facebook Mobile Feed', viewport: { width: 540, height: 1100 } },
];

(async () => {
  if (!fs.existsSync(PNG)) { console.error('Missing PNG:', PNG); process.exit(1); }
  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

  const spec = SPECS[variant];

  // 1) Upload image → image_hash
  console.log(`📤 Uploading ${path.basename(PNG)}...`);
  const buf = fs.readFileSync(PNG);
  const form = new FormData();
  form.append('access_token', ACCESS_TOKEN);
  form.append('filename', new Blob([buf], { type: 'image/png' }), `${variant}-club-ad.png`);
  const upRes = await fetch(`${API}/${AD_ACCOUNT_ID}/adimages`, { method: 'POST', body: form });
  const up = await upRes.json();
  if (up.error) { console.error('Upload error:', JSON.stringify(up.error, null, 2)); process.exit(1); }
  const imageHash = Object.values(up.images)[0].hash;
  console.log(`   image_hash: ${imageHash}`);

  // 2) Build creative spec
  const creativeSpec = {
    object_story_spec: {
      page_id: PAGE_ID,
      link_data: {
        image_hash: imageHash,
        link:       spec.ctaUrl,
        message:    spec.caption,
        call_to_action: { type: 'SIGN_UP', value: { lead_gen_form_id: spec.formId } },
      },
    },
    degrees_of_freedom_spec: { creative_features_spec: { standard_enhancements: { enroll_status: 'OPT_OUT' } } },
  };

  // 3) Loop formats → generatepreviews → screenshot iframe
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const results = [];
  try {
    for (const fmt of FORMATS) {
      console.log(`\n→ ${fmt.label} (${fmt.key})`);
      const params = new URLSearchParams({
        ad_format:    fmt.key,
        creative:     JSON.stringify(creativeSpec),
        access_token: ACCESS_TOKEN,
      });
      const res = await fetch(`${API}/${AD_ACCOUNT_ID}/generatepreviews?${params}`);
      const data = await res.json();
      if (data.error) { console.log(`  ⚠️  ${data.error.message}`); continue; }
      const iframe = data?.data?.[0]?.body;
      if (!iframe) { console.log('  ⚠️  no iframe returned'); continue; }
      const srcMatch = iframe.match(/src="([^"]+)"/);
      if (!srcMatch) { console.log('  ⚠️  no iframe src'); continue; }
      const iframeSrc = srcMatch[1].replace(/&amp;/g, '&');

      const page = await browser.newPage();
      await page.setViewport(fmt.viewport);
      await page.goto(iframeSrc, { waitUntil: 'networkidle0', timeout: 60000 });
      await new Promise(r => setTimeout(r, 1500));
      const outFile = path.join(OUT_DIR, `${variant}-club-${fmt.key.toLowerCase()}.png`);
      await page.screenshot({ path: outFile, fullPage: true });
      await page.close();
      console.log(`  ✅ ${outFile}`);
      results.push({ label: fmt.label, file: outFile });
    }
  } finally {
    await browser.close();
  }

  console.log('\n🎉 Previews:');
  results.forEach(r => console.log(`   ${r.label}: ${r.file}`));
})().catch(err => { console.error('❌ Failed:', err); process.exit(1); });
