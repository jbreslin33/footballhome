#!/usr/bin/env node
// create-ad.js — Create a boosted Instagram ad via Meta Marketing API
//
// Usage:
//   node create-ad.js u23-mens --budget 10 --days 5
//   node create-ad.js u23-womens --budget 5 --days 3
//   node create-ad.js grassroots-brazil --budget 20 --days 7
//
// Options:
//   --budget  Daily budget in USD (default: 5)
//   --days    Number of days to run (default: 3)
//   --age-min Minimum age (default: 16)
//   --age-max Maximum age (default: 40)
//   --dry-run Print what would be created without actually creating it

require('dotenv').config({ path: __dirname + '/env' });

const AD_ACCOUNT_ID = process.env.META_AD_ACCOUNT_ID;   // act_XXXXXXXXXX
const PAGE_ID       = process.env.META_PAGE_ID;
const ACCESS_TOKEN  = process.env.META_ADS_TOKEN;
const API           = 'https://graph.facebook.com/v21.0';

// ── Ad definitions (image + caption + CTA URL per post type) ──────────
const ADS = {
  'u23-mens': {
    name:    'U23 Mens Interest Form',
    imageUrl: 'https://footballhome.org/images/posts/u23-ad-1778954703154.png',
    caption:  `⚽ NOW FORMING: LIGHTHOUSE U23 MEN'S TEAM!\n\nLighthouse 1893 SC is forming a U23 Men's team in partnership with CASA Soccer!\n\n📅 First Match: May 30, 2026\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players\n\nInterested? Fill out the interest form directly:\n\n👉 https://tr.ee/hSxfHUV4jR\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer #Lighthouse1893SC #PhillyFootball`,
    ctaUrl:   'https://tr.ee/hSxfHUV4jR',
    ctaType:  'SIGN_UP',
  },
  'u23-womens': {
    name:    'U23 Womens Interest Form',
    imageUrl: 'https://footballhome.org/images/posts/u23-ad-1778946255917.png',
    caption:  `⚽ NOW FORMING: LIGHTHOUSE U23 WOMEN'S TEAM!\n\nLighthouse 1893 SC is forming a U23 Women's team in partnership with CASA Soccer!\n\n📅 First Match: TBD\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players\n\nInterested? Fill out the interest form in bio!\n\n👉 linktr.ee/Lighthouse1893Soccer\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer #Lighthouse1893SC #PhillyFootball #WomensSoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer',
    ctaType:  'SIGN_UP',
  },
  'grassroots-brazil': {
    name:    'Philly Grassroots Cup — Brazil',
    imageUrl: 'https://footballhome.org/images/posts/grassroots-cup-ad-1778890201372.png',
    caption:  `🇧🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — BRAZIL TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Brazil team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\nSpots are open to ALL players! Fill out interest form in bio.\n\n👉 linktr.ee/Lighthouse1893Soccer\n\n#PhillyGrassrootsCup #Brazil #Lighthouse1893 #PhillySoccer #CASASoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer',
    ctaType:  'LEARN_MORE',
  },
  'grassroots-puertorico': {
    name:    'Philly Grassroots Cup — Puerto Rico',
    imageUrl: 'https://footballhome.org/images/posts/grassroots-cup-ad-1778890205134.png',
    caption:  `🇵🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — PUERTO RICO TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Puerto Rico team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\nSpots are open to ALL players! Fill out interest form in bio.\n\n👉 linktr.ee/Lighthouse1893Soccer\n\n#PhillyGrassrootsCup #PuertoRico #Lighthouse1893 #PhillySoccer #CASASoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer',
    ctaType:  'LEARN_MORE',
  },
};

// ── Arg parsing ───────────────────────────────────────────────────────
const args = process.argv.slice(2);
const adKey = args[0];

function getArg(flag, defaultVal) {
  const i = args.indexOf(flag);
  return i !== -1 ? args[i + 1] : defaultVal;
}

const dailyBudgetUSD = parseFloat(getArg('--budget', '5'));
const days           = parseInt(getArg('--days', '3'), 10);
const ageMin         = parseInt(getArg('--age-min', '16'), 10);
const ageMax         = parseInt(getArg('--age-max', '40'), 10);
const dryRun         = args.includes('--dry-run');

// ── Validate ──────────────────────────────────────────────────────────
if (!adKey || !ADS[adKey]) {
  console.error(`\nUsage: node create-ad.js <ad-key> [options]\n`);
  console.error(`Available ad keys:\n  ${Object.keys(ADS).join('\n  ')}\n`);
  console.error(`Options:\n  --budget <USD/day>  (default: 5)\n  --days <n>          (default: 3)\n  --age-min <n>       (default: 16)\n  --age-max <n>       (default: 40)\n  --dry-run\n`);
  process.exit(1);
}
if (!AD_ACCOUNT_ID || !PAGE_ID || !ACCESS_TOKEN) {
  console.error('Missing META_AD_ACCOUNT_ID, META_PAGE_ID or META_ADS_TOKEN in env file.');
  process.exit(1);
}

const ad = ADS[adKey];
const dailyBudgetCents = Math.round(dailyBudgetUSD * 100);

// End date = today + days
const endDate = new Date();
endDate.setDate(endDate.getDate() + days);
const endDateStr = endDate.toISOString().split('T')[0] + 'T23:59:59-0500';

// ── Targeting: Philadelphia metro area ────────────────────────────────
const targeting = {
  geo_locations: {
    cities: [{ key: '2418779', radius: 25, distance_unit: 'mile' }], // Philadelphia
  },
  age_min: ageMin,
  age_max: ageMax,
  publisher_platforms: ['instagram'],
  instagram_positions: ['stream', 'explore'],
};

async function apiPost(path, params) {
  const body = new URLSearchParams({ ...params, access_token: ACCESS_TOKEN });
  const res = await fetch(`${API}/${path}`, { method: 'POST', body });
  return res.json();
}

async function run() {
  console.log(`\n📣 Creating Instagram Ad: ${ad.name}`);
  console.log(`   Budget: $${dailyBudgetUSD}/day for ${days} days ($${dailyBudgetUSD * days} total)`);
  console.log(`   Audience: Philadelphia metro, ages ${ageMin}–${ageMax}`);
  console.log(`   CTA: ${ad.ctaType} → ${ad.ctaUrl}`);
  console.log(`   Image: ${ad.imageUrl}`);

  if (dryRun) {
    console.log('\n[dry-run] No API calls made.\n');
    return;
  }

  // Step 1: Create Campaign
  console.log('\n1️⃣  Creating campaign...');
  const campaign = await apiPost(`${AD_ACCOUNT_ID}/campaigns`, {
    name: `${ad.name} — ${new Date().toLocaleDateString()}`,
    objective: 'OUTCOME_TRAFFIC',
    status: 'PAUSED',
    special_ad_categories: [],
  });
  if (campaign.error) { console.error('Campaign error:', campaign.error.message); process.exit(1); }
  console.log(`   Campaign ID: ${campaign.id}`);

  // Step 2: Create Ad Set
  console.log('2️⃣  Creating ad set...');
  const adSet = await apiPost(`${AD_ACCOUNT_ID}/adsets`, {
    name: `${ad.name} — Ad Set`,
    campaign_id: campaign.id,
    daily_budget: dailyBudgetCents,
    end_time: endDateStr,
    billing_event: 'IMPRESSIONS',
    optimization_goal: 'LINK_CLICKS',
    targeting: JSON.stringify(targeting),
    status: 'PAUSED',
  });
  if (adSet.error) { console.error('Ad set error:', adSet.error.message); process.exit(1); }
  console.log(`   Ad Set ID: ${adSet.id}`);

  // Step 3: Create Ad Creative
  console.log('3️⃣  Creating ad creative...');
  const creative = await apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
    name: `${ad.name} — Creative`,
    object_story_spec: JSON.stringify({
      page_id: PAGE_ID,
      instagram_actor_id: PAGE_ID,
      link_data: {
        image_url: ad.imageUrl,
        link: ad.ctaUrl,
        message: ad.caption,
        call_to_action: { type: ad.ctaType, value: { link: ad.ctaUrl } },
      },
    }),
  });
  if (creative.error) { console.error('Creative error:', creative.error.message); process.exit(1); }
  console.log(`   Creative ID: ${creative.id}`);

  // Step 4: Create Ad
  console.log('4️⃣  Creating ad...');
  const createdAd = await apiPost(`${AD_ACCOUNT_ID}/ads`, {
    name: `${ad.name} — Ad`,
    adset_id: adSet.id,
    creative: JSON.stringify({ creative_id: creative.id }),
    status: 'PAUSED',
  });
  if (createdAd.error) { console.error('Ad error:', createdAd.error.message); process.exit(1); }
  console.log(`   Ad ID: ${createdAd.id}`);

  console.log(`
✅ Ad created successfully (status: PAUSED)
   Review it at: https://adsmanager.facebook.com/adsmanager/manage/ads?act=${AD_ACCOUNT_ID.replace('act_', '')}

   When ready to go live, either:
   - Turn it on in Ads Manager, OR
   - Run: node create-ad.js ${adKey} --budget ${dailyBudgetUSD} --days ${days}  (and activate in Ads Manager)
`);
}

run().catch(err => { console.error(err); process.exit(1); });
