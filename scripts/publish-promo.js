// scripts/publish-promo.js
// Publish a promotional_posts row to Instagram and mark it as posted.
//
// Usage:  node scripts/publish-promo.js <promoId>
//
// Reads caption/image_url from the DB, creates an IG media container,
// polls until FINISHED, publishes, then updates the row to 'posted'.

require('dotenv').config({ path: __dirname + '/../env' });
const { Client } = require('pg');

const promoId = process.argv[2];
if (!promoId) {
  console.error('Usage: node scripts/publish-promo.js <promoId>');
  process.exit(1);
}

const IG_USER_ID = process.env.INSTAGRAM_USER_ID || '26233831926285183';
const TOKEN      = process.env.INSTAGRAM_ACCESS_TOKEN;
const API        = 'https://graph.instagram.com/v21.0';

if (!TOKEN) {
  console.error('❌ INSTAGRAM_ACCESS_TOKEN not set in env');
  process.exit(1);
}

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

(async () => {
  const db = new Client({
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
    user: process.env.PGUSER || 'footballhome_user',
    password: process.env.PGPASSWORD || 'footballhome_pass',
    database: process.env.PGDATABASE || 'footballhome',
  });
  await db.connect();

  const { rows } = await db.query(
    'SELECT id, title, caption, image_url, video_path, status FROM promotional_posts WHERE id = $1',
    [promoId]
  );
  if (rows.length === 0) {
    console.error('❌ Promo not found:', promoId);
    process.exit(1);
  }
  const p = rows[0];
  console.log(`📋 Promo #${p.id}: "${p.title}" (status: ${p.status})`);
  console.log('🖼️  image_url:', p.image_url);
  if (!p.image_url) {
    console.error('❌ No image_url on row');
    process.exit(1);
  }

  await db.query(
    "UPDATE promotional_posts SET status='publishing', updated_at=NOW() WHERE id=$1",
    [p.id]
  );

  // 1) Create media container
  console.log('📤 Creating media container...');
  const createParams = new URLSearchParams({
    image_url: p.image_url,
    caption: p.caption || '',
    access_token: TOKEN,
  });
  const createRes = await fetch(`${API}/${IG_USER_ID}/media`, {
    method: 'POST',
    body: createParams,
  });
  const createData = await createRes.json();
  console.log('   →', JSON.stringify(createData));
  if (createData.error || !createData.id) {
    const msg = (createData.error && createData.error.message) || 'Failed to create container';
    await db.query(
      "UPDATE promotional_posts SET status='error', error_message=$1, updated_at=NOW() WHERE id=$2",
      [msg, p.id]
    );
    console.error('❌', msg);
    process.exit(1);
  }
  const creationId = createData.id;

  // 2) Poll status (images are usually instant but be safe)
  for (let i = 0; i < 8; i++) {
    await sleep(2500);
    const sRes = await fetch(`${API}/${creationId}?fields=status_code&access_token=${TOKEN}`);
    const sData = await sRes.json();
    console.log(`   poll ${i+1}: ${sData.status_code || JSON.stringify(sData)}`);
    if (sData.status_code === 'FINISHED') break;
    if (sData.status_code === 'ERROR') {
      await db.query(
        "UPDATE promotional_posts SET status='error', error_message='Instagram processing failed', updated_at=NOW() WHERE id=$1",
        [p.id]
      );
      console.error('❌ Instagram processing failed');
      process.exit(1);
    }
  }

  // 3) Publish
  console.log('🚀 Publishing...');
  const pubParams = new URLSearchParams({
    creation_id: creationId,
    access_token: TOKEN,
  });
  const pubRes = await fetch(`${API}/${IG_USER_ID}/media_publish`, {
    method: 'POST',
    body: pubParams,
  });
  const pubData = await pubRes.json();
  console.log('   →', JSON.stringify(pubData));
  if (pubData.error || !pubData.id) {
    const msg = (pubData.error && pubData.error.message) || 'Publish failed';
    await db.query(
      "UPDATE promotional_posts SET status='error', error_message=$1, updated_at=NOW() WHERE id=$2",
      [msg, p.id]
    );
    console.error('❌', msg);
    process.exit(1);
  }

  await db.query(
    `UPDATE promotional_posts
        SET status='posted',
            posted_at=NOW(),
            external_media_id=$1,
            error_message=NULL,
            updated_at=NOW()
      WHERE id=$2`,
    [pubData.id, p.id]
  );
  await db.end();

  console.log('\n✅ Posted! IG media id =', pubData.id);
  console.log('   View: https://www.instagram.com/p/');
})().catch(async (err) => {
  console.error('❌ Fatal:', err);
  process.exit(1);
});
