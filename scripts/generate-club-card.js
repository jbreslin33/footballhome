// scripts/generate-club-card.js
// Generates 1080x1080 promo cards for Lighthouse Boys Club / Girls Club
// soccer ads. Layout: bold typography + striker silhouette + soccer ball.
// Brand palette is identical across both (navy + gold) so the pair reads
// as one campaign; the only difference is the word ("BOYS" vs "GIRLS")
// and the silhouette is mirrored horizontally.
//
// Usage:
//   node scripts/generate-club-card.js boys
//   node scripts/generate-club-card.js girls
//   node scripts/generate-club-card.js boys  <promoId>   # also writes promo_<id>.jpg + DB update

const puppeteer  = require('puppeteer');
const path       = require('path');
const fs         = require('fs');
const { Client } = require('pg');

const variant = (process.argv[2] || '').toLowerCase();
const promoId = process.argv[3] || null;

if (!['boys', 'girls'].includes(variant)) {
  console.error('Usage: node scripts/generate-club-card.js <boys|girls> [promoId]');
  process.exit(1);
}

const ROOT      = path.resolve(__dirname, '..');
const POSTS_DIR = path.join(ROOT, 'frontend', 'images', 'posts');
const OUT_FILE  = path.join(POSTS_DIR, `${variant}-club-ad.png`);
const OUT_URL   = `https://footballhome.org/images/posts/${variant}-club-ad.png`;

const LH_1893   = path.join(ROOT, 'frontend', 'images', 'teams', 'logos', 'lighthouse-1893.png');

function dataUri(p) {
  if (!fs.existsSync(p)) { console.warn('⚠️  missing:', p); return ''; }
  const ext  = path.extname(p).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : (ext === '.jpg' || ext === '.jpeg') ? 'image/jpeg' : 'image/png';
  return `data:${mime};base64,${fs.readFileSync(p).toString('base64')}`;
}

const lh1893 = dataUri(LH_1893);

// Striker silhouette: mid-strike pose with ball at foot.
// Single colour (gold) so it reads as a true silhouette at any size.
// For the "girls" variant we mirror horizontally via CSS so the pair
// reads visually parallel when placed side-by-side.
const SILHOUETTE_SVG = `
<svg viewBox="0 0 600 620" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet">
  <g fill="#f5d442">
    <!-- head -->
    <circle cx="240" cy="78" r="44"/>
    <!-- torso (leaning forward into the strike) -->
    <path d="M 215 122 L 198 290 L 295 305 L 300 132 Q 270 124 240 122 Z"/>
    <!-- back arm extended for balance -->
    <path d="M 218 148 L 122 232 L 138 254 L 228 180 Z"/>
    <!-- forward arm -->
    <path d="M 295 148 L 372 215 L 360 238 L 288 184 Z"/>
    <!-- planted (back) leg -->
    <path d="M 215 290 L 192 480 L 176 600 L 220 605 L 245 480 L 252 295 Z"/>
    <ellipse cx="198" cy="608" rx="36" ry="10"/>
    <!-- striking (front) leg extended forward toward ball -->
    <path d="M 268 290 L 388 380 L 460 408 L 478 386 L 405 358 L 308 282 Z"/>
    <ellipse cx="468" cy="398" rx="22" ry="9" transform="rotate(-28 468 398)"/>
  </g>

  <!-- soccer ball (white with hex/pentagon hint) -->
  <g>
    <circle cx="528" cy="432" r="38" fill="#ffffff"/>
    <circle cx="528" cy="432" r="38" fill="none" stroke="#0a1628" stroke-width="2.5"/>
    <polygon points="528,408 547,422 540,444 516,444 509,422" fill="#0a1628"/>
    <line x1="528" y1="394" x2="528" y2="408" stroke="#0a1628" stroke-width="2.5"/>
    <line x1="490" y1="432" x2="503" y2="432" stroke="#0a1628" stroke-width="2.5"/>
    <line x1="553" y1="432" x2="566" y2="432" stroke="#0a1628" stroke-width="2.5"/>
    <line x1="506" y1="456" x2="512" y2="470" stroke="#0a1628" stroke-width="2.5"/>
    <line x1="550" y1="456" x2="544" y2="470" stroke="#0a1628" stroke-width="2.5"/>
  </g>
</svg>
`.trim();

const WORD = variant === 'boys' ? 'BOYS CLUB' : 'GIRLS CLUB';
// Mirror silhouette horizontally for the girls variant so the pair
// reads as a visual mirror when displayed side-by-side.
const MIRROR = variant === 'girls' ? 'transform: scaleX(-1);' : '';

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body { width:1080px; height:1080px; overflow:hidden;
         font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; color:#fff; }
  .card {
    width:1080px; height:1080px; position:relative;
    background: radial-gradient(ellipse at 30% 20%, #1a3a8a 0%, #0d2247 45%, #060f25 100%);
    padding:60px;
  }
  .pattern {
    position:absolute; inset:0; opacity:0.06; pointer-events:none;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 22px 22px;
  }
  .gold-bar  { position:absolute; top:0;    left:0; right:0; height:12px; background:#f5d442; }
  .gold-bar2 { position:absolute; bottom:0; left:0; right:0; height:12px; background:#f5d442; }

  .header {
    display:flex; align-items:center; gap:24px;
    margin-top:8px;
  }
  .header img { height:120px; width:auto; }
  .header .text { display:flex; flex-direction:column; line-height:1.05; }
  .header .text .club  { font-size:30px; font-weight:900; letter-spacing:2px; }
  .header .text .since { font-size:18px; color:#f5d442; font-weight:700; letter-spacing:4px; }

  .stage {
    position:relative;
    margin-top:30px;
    height:560px;
    display:flex; align-items:center; justify-content:center;
  }
  .silhouette {
    position:absolute;
    width:560px; height:560px;
    top:0; left:50%; margin-left:-280px;
    ${MIRROR}
    opacity:0.92;
    filter: drop-shadow(0 8px 18px rgba(0,0,0,0.45));
  }

  .hero {
    margin-top:0;
    text-align:center;
    position:relative; z-index:2;
  }
  .hero .kicker {
    font-size:24px; letter-spacing:16px; color:#f5d442; font-weight:800;
    text-transform:uppercase; opacity:0.95;
  }
  .hero h1 {
    font-size:128px; font-weight:900; letter-spacing:2px;
    line-height:0.92; margin-top:10px;
    text-shadow: 0 6px 24px rgba(0,0,0,0.55);
  }
  .hero h1 .accent { color:#f5d442; }
  .hero .soccer-line {
    font-size:96px; font-weight:900; letter-spacing:8px;
    color:#f5d442; margin-top:6px; line-height:1;
    text-shadow: 0 4px 14px rgba(0,0,0,0.55);
  }

  .grades {
    display:flex; justify-content:center; margin-top:24px;
  }
  .grades .pill {
    background: rgba(245,212,66,0.18);
    border:2px solid rgba(245,212,66,0.6);
    color:#f5d442;
    padding:14px 32px;
    border-radius:999px;
    font-size:24px; font-weight:800; letter-spacing:3px;
    text-transform:uppercase;
  }

  .cta-banner {
    margin-top:24px;
    background:#f5d442;
    color:#0a1628;
    border-radius:14px;
    padding:18px 24px;
    text-align:center;
  }
  .cta-banner .top    { font-size:18px; font-weight:800; letter-spacing:4px; }
  .cta-banner .bottom { font-size:28px; font-weight:900; margin-top:2px; }

  .footer {
    position:absolute; bottom:40px; left:60px; right:60px;
    text-align:center;
  }
  .footer .name { font-size:16px; font-weight:800; }
  .footer .addr { font-size:12px; opacity:0.8; margin-top:2px; }
</style>
</head>
<body>
  <div class="card">
    <div class="pattern"></div>
    <div class="gold-bar"></div>

    <div class="header">
      <img src="${lh1893}" alt="Lighthouse 1893">
      <div class="text">
        <div class="club">LIGHTHOUSE 1893 SC</div>
        <div class="since">EST. 1893 · PHILADELPHIA</div>
      </div>
    </div>

    <div class="stage">
      <div class="silhouette">${SILHOUETTE_SVG}</div>
    </div>

    <div class="hero">
      <div class="kicker">Lighthouse</div>
      <h1>${WORD}</h1>
      <div class="soccer-line">SOCCER</div>
    </div>

    <div class="grades">
      <div class="pill">Grades 1–6</div>
    </div>

    <div class="cta-banner">
      <div class="top">$1 TO REGISTER</div>
      <div class="bottom">Locks your player's spot · Cancel anytime</div>
    </div>

    <div class="footer">
      <div class="name">📍 Lighthouse Sports &amp; Entertainment Complex</div>
      <div class="addr">199 East Erie Avenue, Philadelphia, PA 19140</div>
    </div>

    <div class="gold-bar2"></div>
  </div>
</body></html>`;

(async () => {
  if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, { recursive: true });

  console.log('🚀 Launching headless browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1080, height: 1080, deviceScaleFactor: 1 });
    await page.setContent(html, { waitUntil: 'networkidle0', timeout: 60000 });

    console.log('📸 Writing', OUT_FILE);
    await page.screenshot({ path: OUT_FILE, type: 'png', fullPage: false });

    if (promoId) {
      const promoOut = path.join(POSTS_DIR, `promo_${promoId}.jpg`);
      console.log('📸 Writing', promoOut);
      await page.screenshot({ path: promoOut, type: 'jpeg', quality: 92, fullPage: false });
    }
  } finally {
    await browser.close();
  }

  console.log('✅ Wrote', OUT_FILE);
  console.log('   URL: ' + OUT_URL);

  if (promoId) {
    const url = `https://footballhome.org/images/posts/promo_${promoId}.jpg`;
    const client = new Client({
      host:     process.env.PGHOST     || 'localhost',
      port:     process.env.PGPORT     || 5432,
      user:     process.env.PGUSER     || 'footballhome_user',
      password: process.env.PGPASSWORD || 'footballhome_pass',
      database: process.env.PGDATABASE || 'footballhome',
    });
    await client.connect();
    try {
      const res = await client.query(
        `UPDATE promotional_posts
            SET image_path = $1, image_url = $2, updated_at = NOW()
          WHERE id = $3
          RETURNING id, title, status, image_url`,
        [`promo_${promoId}.jpg`, url, promoId]
      );
      console.log('✅ DB updated:', res.rows[0]);
    } finally {
      await client.end();
    }
  }
})().catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
