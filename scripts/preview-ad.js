#!/usr/bin/env node
// scripts/preview-ad.js — Render Meta-hosted ad previews to PNG images
//
// Usage:
//   node scripts/preview-ad.js <AD_ID>
//
// Fetches Meta's official preview iframes for FB feed + IG feed and
// screenshots them via Puppeteer so you can see exactly what users see.

require('dotenv').config({ path: __dirname + '/../env' });

const puppeteer = require('puppeteer');
const path      = require('path');
const fs        = require('fs');

const ACCESS_TOKEN = process.env.META_ADS_TOKEN;
const API          = 'https://graph.facebook.com/v21.0';

const adId = process.argv[2];
if (!adId) {
  console.error('Usage: node scripts/preview-ad.js <AD_ID>');
  process.exit(1);
}
if (!ACCESS_TOKEN) {
  console.error('Missing META_ADS_TOKEN in env');
  process.exit(1);
}

const FORMATS = [
  { key: 'INSTAGRAM_STANDARD',    label: 'Instagram Feed', viewport: { width: 540, height: 1100 } },
  { key: 'INSTAGRAM_EXPLORE_CONTEXTUAL', label: 'Instagram Explore', viewport: { width: 540, height: 1100 } },
  { key: 'MOBILE_FEED_STANDARD',  label: 'Facebook Mobile Feed', viewport: { width: 540, height: 1100 } },
];

const OUT_DIR = path.resolve(__dirname, '..', 'frontend', 'images', 'posts', 'previews');

(async () => {
  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

  console.log(`📸 Fetching previews for ad ${adId}...\n`);

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const results = [];

  try {
    for (const fmt of FORMATS) {
      console.log(`→ ${fmt.label} (${fmt.key})`);
      const url = `${API}/${adId}/previews?ad_format=${fmt.key}&access_token=${ACCESS_TOKEN}`;
      const res = await fetch(url);
      const data = await res.json();

      if (data.error) {
        console.log(`  ⚠️  ${data.error.message}`);
        continue;
      }

      const iframe = data?.data?.[0]?.body;
      if (!iframe) {
        console.log('  ⚠️  no preview iframe returned');
        continue;
      }

      // Extract the iframe src
      const srcMatch = iframe.match(/src="([^"]+)"/);
      if (!srcMatch) {
        console.log('  ⚠️  could not find iframe src');
        continue;
      }
      const iframeSrc = srcMatch[1].replace(/&amp;/g, '&');

      const page = await browser.newPage();
      await page.setViewport(fmt.viewport);
      await page.goto(iframeSrc, { waitUntil: 'networkidle0', timeout: 60000 });
      // Tiny pause for any late-loading content
      await new Promise(r => setTimeout(r, 1500));

      const outFile = path.join(OUT_DIR, `ad-${adId}-${fmt.key.toLowerCase()}.png`);
      await page.screenshot({ path: outFile, fullPage: true });
      await page.close();

      console.log(`  ✅ ${outFile}`);
      results.push({ label: fmt.label, file: outFile });
    }
  } finally {
    await browser.close();
  }

  console.log('\n🎉 Done. Previews saved to:');
  results.forEach(r => console.log(`   ${r.label}: ${r.file}`));
})().catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
