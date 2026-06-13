// scripts/generate-club-card.js
// Generates 1080x1080 promo cards for Lighthouse Boys / Girls / Mens / Womens
// Club soccer ads. Layout: bold typography only — no figures or silhouettes.
// Brand palette: navy + gold. Same template across all variants; only the
// wordmark + badge change.
//
// Usage:
//   node scripts/generate-club-card.js boys       → boys-club-ad.png        (legacy, Grades 1–6)
//   node scripts/generate-club-card.js girls      → girls-club-ad.png       (legacy, Grades 1–6)
//   node scripts/generate-club-card.js boys-k12   → boys-club-k12-ad.png    (NEW, K–12)
//   node scripts/generate-club-card.js girls-k12  → girls-club-k12-ad.png   (NEW, K–12)
//   node scripts/generate-club-card.js mens       → mens-club-ad.png        (NEW, APSL / Liga 1)
//   node scripts/generate-club-card.js womens     → womens-club-ad.png      (NEW, Tri County)
//
//   node scripts/generate-club-card.js <variant> <promoId>   # also writes promo_<id>.jpg + DB update

const puppeteer  = require('puppeteer');
const path       = require('path');
const fs         = require('fs');
const { Client } = require('pg');

const variant = (process.argv[2] || '').toLowerCase();
const promoId = process.argv[3] || null;

const VARIANTS = {
  'boys':      { word: 'BOYS CLUB',    badge: 'Grades 1–6',   file: 'boys-club-ad.png'        },
  'girls':     { word: 'GIRLS CLUB',   badge: 'Grades 1–6',   file: 'girls-club-ad.png'       },
  'boys-k12':  { word: 'BOYS CLUB',    badge: 'K – 12',         file: 'boys-club-k12-ad.png'    },
  'girls-k12': { word: 'GIRLS CLUB',   badge: 'K – 12',         file: 'girls-club-k12-ad.png'   },
  'mens':      { word: 'MENS CLUB',    badge: 'APSL · LIGA 1',  file: 'mens-club-ad.png'        },
  'womens':    { word: 'WOMENS CLUB',  badge: 'TRI COUNTY',     file: 'womens-club-ad.png'      },
};

if (!VARIANTS[variant]) {
  console.error('Usage: node scripts/generate-club-card.js <variant> [promoId]');
  console.error('Variants: ' + Object.keys(VARIANTS).join(', '));
  process.exit(1);
}

const V = VARIANTS[variant];

const ROOT      = path.resolve(__dirname, '..');
const POSTS_DIR = path.join(ROOT, 'frontend', 'images', 'posts');
const OUT_FILE  = path.join(POSTS_DIR, V.file);
const OUT_URL   = `https://footballhome.org/images/posts/${V.file}`;

const LH_1893   = path.join(ROOT, 'frontend', 'images', 'teams', 'logos', 'lighthouse-1893.png');

function dataUri(p) {
  if (!fs.existsSync(p)) { console.warn('⚠️  missing:', p); return ''; }
  const ext  = path.extname(p).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : (ext === '.jpg' || ext === '.jpeg') ? 'image/jpeg' : 'image/png';
  return `data:${mime};base64,${fs.readFileSync(p).toString('base64')}`;
}

const lh1893 = dataUri(LH_1893);

const WORD  = V.word;
const BADGE = V.badge;

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body { width:1080px; height:1080px; overflow:hidden;
         font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; color:#fff; }
  .card {
    width:1080px; height:1080px; position:relative;
    background: radial-gradient(ellipse at 50% 30%, #1a3a8a 0%, #0d2247 50%, #060f25 100%);
    padding:80px 70px;
    display:flex; flex-direction:column;
  }
  .gold-bar  { position:absolute; top:0;    left:0; right:0; height:14px; background:#f5d442; }
  .gold-bar2 { position:absolute; bottom:0; left:0; right:0; height:14px; background:#f5d442; }

  /* Top: centered crest + small wordmark */
  .crest {
    display:flex; flex-direction:column; align-items:center; gap:14px;
  }
  .crest .row {
    display:flex; align-items:center; gap:36px;
  }
  .crest img {
    height:170px; width:auto;
    filter: drop-shadow(0 6px 16px rgba(0,0,0,0.5));
  }
  .crest .ball {
    width:130px; height:130px; border-radius:50%;
    background:#0d2247;
    border:5px solid #f5d442;
    display:flex; align-items:center; justify-content:center;
    font-size:78px; line-height:1;
    box-shadow: 0 6px 18px rgba(0,0,0,0.5);
  }
  .crest .since {
    font-size:18px; letter-spacing:8px; color:#f5d442;
    font-weight:800; opacity:0.95;
  }

  /* Hero block: LIGHTHOUSE / BOYS CLUB / SOCCER */
  .hero {
    display:flex; flex-direction:column; align-items:center; justify-content:center;
    text-align:center;
    margin-top:10px;
  }
  .hero .lighthouse {
    font-size:56px; font-weight:900; letter-spacing:6px;
    color:#ffffff; opacity:0.92;
    text-shadow: 0 4px 14px rgba(0,0,0,0.5);
  }
  .hero h1 {
    font-size:160px; font-weight:900; letter-spacing:3px;
    line-height:0.95; margin-top:4px;
    color:#ffffff;
    text-shadow: 0 6px 22px rgba(0,0,0,0.6);
  }
  .hero .soccer {
    font-size:120px; font-weight:900; letter-spacing:14px;
    color:#f5d442; line-height:1; margin-top:4px;
    text-shadow: 0 4px 16px rgba(0,0,0,0.55);
  }

  .grades {
    display:flex; justify-content:center;
  }
  .spacer-top { flex:1; }
  .spacer-bot { flex:2; }
  .grades .pill {
    background: rgba(245,212,66,0.18);
    border:2px solid rgba(245,212,66,0.65);
    color:#f5d442;
    padding:16px 40px;
    border-radius:999px;
    font-size:28px; font-weight:900; letter-spacing:5px;
    text-transform:uppercase;
  }

  .footer {
    text-align:center;
  }
  .footer .name { font-size:26px; font-weight:800; letter-spacing:1px; }
  .footer .addr { font-size:22px; opacity:0.85; margin-top:6px; letter-spacing:0.5px; }
</style>
</head>
<body>
  <div class="card">
    <div class="gold-bar"></div>

    <div class="crest">
      <div class="row">
        <img src="${lh1893}" alt="Lighthouse 1893">
        <div class="ball">⚽</div>
      </div>
      <div class="since">EST. 1893 · PHILADELPHIA</div>
    </div>

    <div class="hero">
      <div class="lighthouse">LIGHTHOUSE</div>
      <h1>${WORD}</h1>
      <div class="soccer">SOCCER</div>
    </div>

    <div class="spacer-top"></div>

    <div class="grades">
      <div class="pill">${BADGE}</div>
    </div>

    <div class="spacer-bot"></div>

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
