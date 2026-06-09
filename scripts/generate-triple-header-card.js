// scripts/generate-triple-header-card.js
// Generates a 1080x1080 promo card for the Sat Jun 7 triple-header
// and writes it as frontend/images/posts/promo_<id>.jpg + updates DB.
//
// Usage:
//   node scripts/generate-triple-header-card.js [promoId]
//   (defaults to promoId=11)

const puppeteer = require('puppeteer');
const path      = require('path');
const fs        = require('fs');
const { Client } = require('pg');

const promoId = process.argv[2] || '11';

const ROOT       = path.resolve(__dirname, '..');
const POSTS_DIR  = path.join(ROOT, 'frontend', 'images', 'posts');
const OUT_FILE   = path.join(POSTS_DIR, `promo_${promoId}.jpg`);
const PUBLIC_URL = `https://footballhome.org/images/posts/promo_${promoId}.jpg`;

const LH_1893   = path.join(ROOT, 'frontend', 'images', 'teams', 'logos', 'lighthouse-1893.png');
const LH_CPLX   = path.join(ROOT, 'frontend', 'images', 'lighthouse-complex.png');
const TCWSL     = path.join(ROOT, 'frontend', 'images', 'leagues', 'tcwsl.png');
const CASA      = path.join(ROOT, 'frontend', 'images', 'leagues', 'casa.png');

function dataUri(p) {
  if (!fs.existsSync(p)) { console.warn('⚠️  missing:', p); return ''; }
  const ext = path.extname(p).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : ext === '.jpg' || ext === '.jpeg' ? 'image/jpeg' : ext === '.svg' ? 'image/svg+xml' : 'image/png';
  return `data:${mime};base64,${fs.readFileSync(p).toString('base64')}`;
}

const lh1893   = dataUri(LH_1893);
const lhCplx   = dataUri(LH_CPLX);
const tcwsl    = dataUri(TCWSL);
const casa     = dataUri(CASA);

// Country flags — pulled via flagcdn at render time
const flag = (cc) => `https://flagcdn.com/w320/${cc}.png`;

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body { width:1080px; height:1080px; overflow:hidden;
         font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; color:#fff; }
  .card {
    width:1080px; height:1080px; position:relative;
    background: linear-gradient(160deg, #0a1628 0%, #0d2247 40%, #002870 100%);
    padding:50px 60px;
  }
  .pattern {
    position:absolute; inset:0; opacity:0.06; pointer-events:none;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 22px 22px;
  }
  .gold-bar  { position:absolute; top:0; left:0; right:0; height:10px; background:#f5d442; }
  .gold-bar2 { position:absolute; bottom:0; left:0; right:0; height:10px; background:#f5d442; }

  .header { display:flex; align-items:center; gap:18px; margin-bottom:24px; }
  .header img.lh { height:92px; }
  .header .right { margin-left:auto; text-align:right; }
  .header .right .day { font-size:18px; letter-spacing:6px; opacity:0.7; }
  .header .right .date { font-size:34px; font-weight:800; color:#f5d442; }

  .title { text-align:center; margin: 10px 0 6px; }
  .title .kicker { font-size:22px; letter-spacing:10px; color:#f5d442; font-weight:700; }
  .title h1 { font-size:84px; font-weight:900; letter-spacing:4px;
              text-shadow:0 4px 14px rgba(0,0,0,0.5); line-height:1; }
  .title .sub { font-size:26px; font-weight:600; margin-top:6px; opacity:0.92; }

  .games { display:flex; flex-direction:column; gap:14px; margin-top:30px; }
  .game {
    background: rgba(255,255,255,0.07);
    border:1px solid rgba(255,255,255,0.12);
    border-left:6px solid #f5d442;
    border-radius:14px;
    padding:16px 22px;
    display:grid;
    grid-template-columns: 130px 1fr 70px 1fr 140px;
    align-items:center;
    gap:14px;
  }
  .game .time {
    font-size:30px; font-weight:900; color:#f5d442;
    letter-spacing:1px;
  }
  .game .side {
    display:flex; align-items:center; gap:14px;
  }
  .game .side.right { justify-content:flex-end; }
  .game .side img {
    height:74px; width:74px; object-fit:contain;
    background:#fff; border-radius:50%; padding:6px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.4);
  }
  .game .side .name {
    font-size:24px; font-weight:700; line-height:1.05;
  }
  .game .side .name small {
    display:block; font-size:13px; font-weight:500; opacity:0.65; margin-top:2px;
  }
  .game .vs { text-align:center; font-size:24px; font-weight:800; opacity:0.55; letter-spacing:2px; }
  .game .league {
    text-align:right; font-size:13px; font-weight:700;
    opacity:0.85; line-height:1.2;
    display:flex; flex-direction:column; align-items:flex-end; gap:6px;
  }
  .game .league img { height:32px; width:auto; }

  .amenities {
    display:flex; justify-content:center; gap:28px; margin-top:26px;
    font-size:18px; font-weight:600;
  }
  .amenities .pill {
    background: rgba(245,212,66,0.15);
    border:1px solid rgba(245,212,66,0.5);
    color:#f5d442;
    padding:8px 18px; border-radius:999px;
  }

  .venue { text-align:center; margin-top:22px; }
  .venue .name { font-size:24px; font-weight:800; }
  .venue .addr { font-size:18px; opacity:0.85; margin-top:4px; }

  .footer-logos {
    position:absolute; bottom:30px; left:0; right:0;
    display:flex; justify-content:center; align-items:center; gap:36px;
  }
  .footer-logos img { height:60px; width:auto; object-fit:contain;
                      background:#fff; border-radius:10px; padding:6px; }
</style>
</head>
<body>
  <div class="card">
    <div class="pattern"></div>
    <div class="gold-bar"></div>

    <div class="header">
      <img class="lh" src="${lh1893}" alt="Lighthouse 1893">
      <div>
        <div style="font-size:22px; font-weight:800; letter-spacing:2px;">LIGHTHOUSE 1893 SC</div>
        <div style="font-size:14px; opacity:0.7;">Lighthouse Sports &amp; Entertainment Complex</div>
      </div>
      <div class="right">
        <div class="day">TODAY · SUNDAY</div>
        <div class="date">JUN 7</div>
      </div>
    </div>

    <div class="title">
      <div class="kicker">TRIPLE-HEADER</div>
      <h1>MATCH DAY</h1>
      <div class="sub">Three Games · One Pitch · All Day Football</div>
      <div class="sub" style="font-size:18px; margin-top:8px; color:#f5d442; letter-spacing:3px; font-weight:700;">FULL REGULATION · 11v11 · 90 MINUTES</div>
    </div>

    <div class="games">
      <!-- Game 1: Tri-County (FINAL) -->
      <div class="game" style="opacity:0.92;">
        <div class="time" style="color:#9aa7c2;font-size:22px;line-height:1.1;">FINAL<br><span style="font-size:28px;font-weight:900;color:#f5d442;">2 - 2</span></div>
        <div class="side">
          <img src="${lh1893}">
          <div class="name">Lighthouse Women<small>Tri-County League · 10:00 AM</small></div>
        </div>
        <div class="vs">2 - 2</div>
        <div class="side right">
          <div class="name" style="text-align:right;">Boyertown<small>&nbsp;</small></div>
        </div>
        <div class="league">
          <img src="${tcwsl}" alt="TCWSL">
          <span>Tri-County WSL</span>
        </div>
      </div>

      <!-- Game 2: Sudan vs Egypt -->
      <div class="game">
        <div class="time">3:15<br><span style="font-size:18px;opacity:0.7;">PM</span></div>
        <div class="side">
          <img src="${flag('sd')}">
          <div class="name">Sudan</div>
        </div>
        <div class="vs">VS</div>
        <div class="side right">
          <div class="name" style="text-align:right;">Egypt</div>
          <img src="${flag('eg')}">
        </div>
        <div class="league">
          <img src="${casa}" alt="CASA">
          <span>CASA Grassroots Cup<br><small style="opacity:0.95;font-weight:800;color:#f5d442;font-size:14px;">GROUP A · 1st Round</small><br><small style="opacity:0.7;font-weight:600;">Group Stage</small></span>
        </div>
      </div>

      <!-- Game 3: Brazil vs Puerto Rico -->
      <div class="game">
        <div class="time">5:15<br><span style="font-size:18px;opacity:0.7;">PM</span></div>
        <div class="side">
          <img src="${flag('br')}">
          <div class="name">Brazil</div>
        </div>
        <div class="vs">VS</div>
        <div class="side right">
          <div class="name" style="text-align:right;">Puerto Rico</div>
          <img src="${flag('pr')}">
        </div>
        <div class="league">
          <img src="${casa}" alt="CASA">
          <span>CASA Grassroots Cup<br><small style="opacity:0.95;font-weight:800;color:#f5d442;font-size:14px;">GROUP C · 1st Round</small><br><small style="opacity:0.7;font-weight:600;">Group Stage</small></span>
        </div>
      </div>
    </div>

    <div class="amenities">
      <div class="pill">✓ Free Admission</div>
      <div class="pill">✓ Free Gated Parking</div>
      <div class="pill">✓ Shaded Seating</div>
    </div>

    <div class="venue">
      <div class="name">📍 Lighthouse Sports &amp; Entertainment Complex</div>
      <div class="addr">199 East Erie Avenue · Philadelphia, PA 19140</div>
    </div>

    <div class="footer-logos">
      <img src="${lh1893}" alt="Lighthouse 1893">
      <img src="${lhCplx}" alt="Lighthouse Complex">
      <img src="${tcwsl}" alt="TCWSL">
      <img src="${casa}" alt="CASA">
    </div>

    <div class="gold-bar2"></div>
  </div>
</body></html>`;

(async () => {
  console.log('🚀 Launching headless browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1080, height: 1080, deviceScaleFactor: 1 });
    await page.setContent(html, { waitUntil: 'networkidle0', timeout: 60000 });

    if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, { recursive: true });

    console.log('📸 Screenshotting...');
    await page.screenshot({ path: OUT_FILE, type: 'jpeg', quality: 92, fullPage: false });
    console.log('✅ Wrote', OUT_FILE);
  } finally {
    await browser.close();
  }

  // Update DB
  console.log('💾 Updating promotional_posts row #' + promoId);
  const client = new Client({
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
    user: process.env.PGUSER || 'footballhome_user',
    password: process.env.PGPASSWORD || 'footballhome_pass',
    database: process.env.PGDATABASE || 'footballhome',
  });
  await client.connect();
  try {
    const res = await client.query(
      `UPDATE promotional_posts
         SET image_path = $1,
             image_url  = $2,
             updated_at = NOW()
       WHERE id = $3
       RETURNING id, title, status, image_url`,
      [`promo_${promoId}.jpg`, PUBLIC_URL, promoId]
    );
    console.log('✅ DB updated:', res.rows[0]);
  } finally {
    await client.end();
  }

  console.log('\n🎉 Done.');
  console.log('   File: ' + OUT_FILE);
  console.log('   URL:  ' + PUBLIC_URL);
})().catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
