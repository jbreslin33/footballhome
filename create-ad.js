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
    name:       'U23 Mens Interest Form',
    imageUrl:   'https://footballhome.org/images/posts/u23-ad-mens.png',
    caption:    `Now forming Lighthouse Boys Club U23 team in CASA Men's U23 Premier League.\n\n📅 First Match: May 30, 2026\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer`,

    ctaUrl:     'https://tr.ee/hSxfHUV4jR',
    ctaType:    'SIGN_UP',
    // U23 Men specific targeting overrides
    defaultBudget: 20,
    // no defaultDays — runs until manually cancelled
    targeting: {
      geo_locations: {
        // Philadelphia city + 30mi radius covers Bucks, Montgomery, Delaware, Chester (PA) and Camden/Burlington (NJ)
        cities: [{ key: '2511940', radius: 30, distance_unit: 'mile' }],
      },
      age_min: 18,
      age_max: 25,
      genders: [1], // 1 = male
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'u23-womens': {
    name:    'U23 Womens Interest Form',
    imageUrl: 'https://footballhome.org/images/posts/u23-ad-womens.png',
    caption:  `⚽ NOW FORMING: LIGHTHOUSE WOMEN'S CLUB U23!\n\nLighthouse Women's Club U23 is forming a team in partnership with CASA Soccer!\n\n📅 First Match: TBD\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players · Ages 16–25 eligible\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer #Lighthouse1893SC #PhillyFootball #WomensSoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer#554813194',
    ctaType:  'SIGN_UP',
    targeting: {
      geo_locations: { cities: [{ key: '2511940', radius: 30, distance_unit: 'mile' }] },
      age_min: 18,
      age_max: 25,
      genders: [2], // 2 = female
      publisher_platforms: ['instagram'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'grassroots-brazil': {
    name:    'Philly Grassroots Cup — Brazil',
    imageUrl: 'https://footballhome.org/images/posts/grassroots-cup-ad-brazil.png',
    caption:  `🇧🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — BRAZIL TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Brazil team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Brazilian!\n⚠️ Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #Brazil #Lighthouse1893 #PhillySoccer #CASASoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer#554813194',
    ctaType:  'LEARN_MORE',
    targeting: {
      geo_locations: { cities: [{ key: '2511940', radius: 30, distance_unit: 'mile' }] },
      age_min: 18,
      age_max: 32,
      genders: [1], // 1 = male
      publisher_platforms: ['instagram'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'grassroots-puertorico': {
    name:    'Philly Grassroots Cup — Puerto Rico',
    imageUrl: 'https://footballhome.org/images/posts/grassroots-cup-ad-puertorico.png',
    caption:  `🇵🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — PUERTO RICO TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Puerto Rico team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Puerto Rican!\n⚠️ Spots are limited and filling fast!\n\n#PhillyGrassrootsCup #PuertoRico #Lighthouse1893 #PhillySoccer #CASASoccer`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer#554813194',
    ctaType:  'LEARN_MORE',
    targeting: {
      geo_locations: { cities: [{ key: '2511940', radius: 30, distance_unit: 'mile' }] },
      age_min: 18,
      age_max: 32,
      genders: [1], // 1 = male
      publisher_platforms: ['instagram'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'youth-signup': {
    name:    'Lighthouse Youth Soccer — Now Enrolling (Grades 1–6)',
    imageUrl: 'https://footballhome.org/images/posts/youth-signup-ad.png',
    caption: `⚽ LIGHTHOUSE YOUTH SOCCER — NOW ENROLLING\n\nBoys & girls, grades 1–6.\nTravel & In-House Leagues.\n\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer`,
    ctaUrl:  'https://linktr.ee/Lighthouse1893Soccer',
    ctaType: 'LEARN_MORE',  // softer than SIGN_UP — typically lower CPL on youth/community
    defaultBudget: 8,    // ~$112 for a 14-day learning test
    defaultDays:   14,   // 2-week smoke test; renew with optimizations
    // Parent-only lead form — Meta Lead Ads policy prohibits collecting
    // information about minors / third parties. Coach captures kid details
    // on the follow-up call.
    leadForm: {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        {
          type: 'CUSTOM',
          key: 'best_time',
          label: 'Best time for a coach to reach you?',
          options: [
            { key: 'morning',   value: 'Morning (8am–12pm)' },
            { key: 'afternoon', value: 'Afternoon (12pm–5pm)' },
            { key: 'evening',   value: 'Evening (5pm–9pm)' },
            { key: 'anytime',   value: 'Anytime' },
          ],
        },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Lighthouse Youth Soccer — Travel & In-House',
        content: [
          'Local community-based club — Philadelphia',
          '199 East Erie Avenue · since 1893',
          'A coach will follow up with season dates, fees, and next steps.',
        ],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks — talk soon!',
        body: 'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    },
    // 14-day learning test (defaultDays:14 above)
    targeting: {
      // 5-mile radius around 199 East Erie Avenue, Philadelphia
      // Coordinates verified via Nominatim geocode of the full address (June 2026)
      geo_locations: {
        custom_locations: [{
          latitude:  40.0071,
          longitude: -75.1306,
          radius:    5,
          distance_unit: 'mile',
          address_string: '199 East Erie Avenue, Philadelphia, PA 19140',
        }],
      },
      age_min: 25,    // young parents through stepparents/older parents
      age_max: 55,
      // No gender filter — both parents
      // English-language speakers (US + UK English) — creative is English-only
      locales: [6, 24],
      // No detailed targeting (interests/behaviors) — let Meta's algorithm
      // find engaged parents from the geo+age pool. Meta has been retiring
      // parent-of-X-year-olds behavior IDs frequently in 2026.
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'trial-pathway': {
    name:    'APSL & CASA Select — Summer Trial Pathway',
    imageUrl: 'https://footballhome.org/images/posts/trial-pathway-ad.png',
    caption:  `Join now and compete in meaningful competitions and train with the teams during summer to prepare for APSL season.`,
    ctaUrl:   'https://linktr.ee/Lighthouse1893Soccer#554813194',
    ctaType:  'SIGN_UP',
    targeting: {
      geo_locations: { cities: [{ key: '2511940', radius: 30, distance_unit: 'mile' }] },
      age_min: 18,
      age_max: 32,
      genders: [1], // 1 = male
      publisher_platforms: ['instagram'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'mens-club': {
    name:    'Lighthouse Mens Club — APSL / Liga 1',
    mode:    'direct',  // → LeagueApps (A/B test vs lead-form live ads)
    imageUrl: 'https://footballhome.org/images/posts/mens-club-ad.png',
    caption: `⚽ JOIN LIGHTHOUSE MENS CLUB — APSL / LIGA 1\n\nOpen-tryout adult men's team competing in APSL / Liga 1.\nAll skill levels welcome. Train with the squad, compete on weekends.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #APSL #Liga1 #PhillySoccer #MensSoccer`,
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/leagues/soccer-(outdoor)/5039300-lighthouse-1893-mens-club-soccer-membership?utm_source=meta&utm_medium=cpc&utm_campaign=club_direct_2026&utm_content=mens-club',
    ctaType: 'SIGN_UP',
    defaultBudget: 5,
    // no defaultDays — runs until manually cancelled
    leadForm: {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        {
          type: 'CUSTOM',
          key: 'best_time',
          label: 'Best time for a coach to reach you?',
          options: [
            { key: 'morning',   value: 'Morning (8am–12pm)' },
            { key: 'afternoon', value: 'Afternoon (12pm–5pm)' },
            { key: 'evening',   value: 'Evening (5pm–9pm)' },
            { key: 'anytime',   value: 'Anytime' },
          ],
        },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Lighthouse Mens Club — APSL / Liga 1',
        content: [
          'Adult open-tryout team — Philadelphia',
          '199 East Erie Avenue · since 1893',
          'A coach will follow up with tryout dates, fees, and next steps.',
        ],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks — talk soon!',
        body: 'A Lighthouse 1893 coach will reach out within 24–48 hours with tryout details and next steps.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    },
    targeting: {
      geo_locations: {
        cities: [{ key: '2511940', radius: 10, distance_unit: 'mile' }],  // Philadelphia, explicit
      },
      age_min: 18,
      age_max: 40,
      genders: [1],  // male
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'womens-club': {
    name:    'Lighthouse Womens Club — Tri County',
    mode:    'direct',  // → LeagueApps (A/B test vs lead-form live ads)
    imageUrl: 'https://footballhome.org/images/posts/womens-club-ad.png',
    caption: `⚽ JOIN LIGHTHOUSE WOMENS CLUB — TRI COUNTY\n\nOpen-tryout adult women's team — Tri County League. Games on Sundays.\nAll skill levels welcome. Train with the squad, compete this season.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #TriCounty #PhillySoccer #WomensSoccer`,
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/leagues/soccer-(outdoor)/5039340-lighthouse-1893-womens-club-soccer-membership?utm_source=meta&utm_medium=cpc&utm_campaign=club_direct_2026&utm_content=womens-club',
    ctaType: 'SIGN_UP',
    defaultBudget: 3,
    // no defaultDays — runs until manually cancelled
    leadForm: {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        {
          type: 'CUSTOM',
          key: 'best_time',
          label: 'Best time for a coach to reach you?',
          options: [
            { key: 'morning',   value: 'Morning (8am–12pm)' },
            { key: 'afternoon', value: 'Afternoon (12pm–5pm)' },
            { key: 'evening',   value: 'Evening (5pm–9pm)' },
            { key: 'anytime',   value: 'Anytime' },
          ],
        },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Lighthouse Womens Club — Tri County',
        content: [
          'Adult open-tryout team — Tri County League',
          '199 East Erie Avenue · since 1893',
          'A coach will follow up with tryout dates, fees, and next steps.',
        ],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks — talk soon!',
        body: 'A Lighthouse 1893 coach will reach out within 24–48 hours with tryout details and next steps.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    },
    targeting: {
      geo_locations: {
        cities: [{ key: '2511940', radius: 10, distance_unit: 'mile' }],  // Philadelphia, explicit
      },
      age_min: 18,
      age_max: 50,
      genders: [2],  // female
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'boys-club': {
    name:    'Lighthouse Boys Club — Now Enrolling (K-12)',
    mode:    'direct',  // → LeagueApps (A/B test vs lead-form live ads)
    imageUrl: 'https://footballhome.org/images/posts/boys-club-k12-ad.png',
    caption: `⚽ LIGHTHOUSE BOYS CLUB — NOW ENROLLING\n\nKindergarten through 12th grade · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #BoysClub`,
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039252-lighthouse-1893-boys-club-soccer-membership?utm_source=meta&utm_medium=cpc&utm_campaign=club_direct_2026&utm_content=boys-club',
    ctaType: 'LEARN_MORE',
    defaultBudget: 5,
    // no defaultDays — runs until manually cancelled
    leadForm: {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        {
          type: 'CUSTOM',
          key: 'best_time',
          label: 'Best time for a coach to reach you?',
          options: [
            { key: 'morning',   value: 'Morning (8am–12pm)' },
            { key: 'afternoon', value: 'Afternoon (12pm–5pm)' },
            { key: 'evening',   value: 'Evening (5pm–9pm)' },
            { key: 'anytime',   value: 'Anytime' },
          ],
        },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Lighthouse Boys Club — Travel & In-House',
        content: [
          'Local community-based club — Philadelphia',
          '199 East Erie Avenue · since 1893',
          'A coach will follow up with season dates, fees, and next steps.',
        ],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks — talk soon!',
        body: 'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    },
    targeting: {
      // 5-mile pin at the complex (verified lat/lng)
      geo_locations: {
        custom_locations: [{
          latitude:  40.0071,
          longitude: -75.1306,
          radius:    5,
          distance_unit: 'mile',
          address_string: '199 East Erie Avenue, Philadelphia, PA 19140',
        }],
        location_types: ['home'],
      },
      age_min: 25,
      age_max: 55,
      // No gender filter — both parents
      locales: [6, 24],
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
  'girls-club': {
    name:    'Lighthouse Girls Club — Now Enrolling (K-12)',
    mode:    'direct',  // → LeagueApps (A/B test vs lead-form live ads)
    imageUrl: 'https://footballhome.org/images/posts/girls-club-k12-ad.png',
    caption: `⚽ LIGHTHOUSE GIRLS CLUB — NOW ENROLLING\n\nKindergarten through 12th grade · Travel & In-House Leagues.\nSummer training + fall season · all skill levels welcome.\n\n📍 Lighthouse Sports & Entertainment Complex\n199 East Erie Avenue, Philadelphia, PA 19140\n\n#Lighthouse1893 #PhillySoccer #YouthSoccer #GirlsClub`,
    ctaUrl:  'https://lighthouse1893soccerclub.leagueapps.com/memberships/5039357-lighthouse-1893-girls-club-soccer-membership?utm_source=meta&utm_medium=cpc&utm_campaign=club_direct_2026&utm_content=girls-club',
    ctaType: 'LEARN_MORE',
    defaultBudget: 5,
    // no defaultDays — runs until manually cancelled
    leadForm: {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        {
          type: 'CUSTOM',
          key: 'best_time',
          label: 'Best time for a coach to reach you?',
          options: [
            { key: 'morning',   value: 'Morning (8am–12pm)' },
            { key: 'afternoon', value: 'Afternoon (12pm–5pm)' },
            { key: 'evening',   value: 'Evening (5pm–9pm)' },
            { key: 'anytime',   value: 'Anytime' },
          ],
        },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Lighthouse Girls Club — Travel & In-House',
        content: [
          'Local community-based club — Philadelphia',
          '199 East Erie Avenue · since 1893',
          'A coach will follow up with season dates, fees, and next steps.',
        ],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks — talk soon!',
        body: 'A Lighthouse 1893 coach will reach out within 24–48 hours with season details and next steps.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    },
    targeting: {
      // 5-mile pin at the complex (verified lat/lng)
      geo_locations: {
        custom_locations: [{
          latitude:  40.0071,
          longitude: -75.1306,
          radius:    5,
          distance_unit: 'mile',
          address_string: '199 East Erie Avenue, Philadelphia, PA 19140',
        }],
        location_types: ['home'],
      },
      age_min: 25,
      age_max: 55,
      locales: [6, 24],
      publisher_platforms: ['facebook', 'instagram'],
      facebook_positions: ['feed'],
      instagram_positions: ['stream', 'explore'],
    },
  },
};

// ── Arg parsing ───────────────────────────────────────────────────────
const args = process.argv.slice(2);
const adKey = args[0];

function getArg(flag, defaultVal) {
  const i = args.indexOf(flag);
  return i !== -1 ? args[i + 1] : defaultVal;
}

const dryRun  = args.includes('--dry-run');
const formIdArg = getArg('--form-id', null);  // skip form creation if provided

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
const dailyBudgetUSD     = parseFloat(getArg('--budget', ad.defaultBudget ?? '5'));
const days               = getArg('--days', ad.defaultDays ?? null);
const dailyBudgetCents   = Math.round(dailyBudgetUSD * 100);

// End date only if --days was specified
const endDateStr = days
  ? (() => { const d = new Date(); d.setDate(d.getDate() + parseInt(days, 10)); return d.toISOString().split('T')[0] + 'T23:59:59-0500'; })()
  : null;

const ageMin = parseInt(getArg('--age-min', '16'), 10);
const ageMax = parseInt(getArg('--age-max', '40'), 10);

// ── Targeting: use per-ad targeting if defined, else Philadelphia metro default ──
const targeting = ad.targeting ?? {
  geo_locations: {
    cities: [{ key: '2511940', radius: 25, distance_unit: 'mile' }],
  },
  age_min: ageMin,
  age_max: ageMax,
  publisher_platforms: ['facebook', 'instagram'],
  facebook_positions: ['feed'],
  instagram_positions: ['stream', 'explore'],
};

async function apiPost(path, params) {
  const body = new URLSearchParams({ ...params, access_token: ACCESS_TOKEN });
  const res = await fetch(`${API}/${path}`, { method: 'POST', body });
  return res.json();
}

async function run() {
  console.log(`\n📣 Creating Instagram Ad: ${ad.name}`);
  console.log(`   Budget: $${dailyBudgetUSD}/day${days ? ` for ${days} days ($${dailyBudgetUSD * days} total)` : ' (runs until cancelled)'}`);
  const genderLabel = targeting.genders ? (targeting.genders.includes(1) ? 'Male' : 'Female') : 'All';
  let geoLabel = 'Philadelphia +30mi';
  if (targeting.geo_locations) {
    if (targeting.geo_locations.custom_locations && targeting.geo_locations.custom_locations[0]) {
      const cl = targeting.geo_locations.custom_locations[0];
      geoLabel = `${cl.address_string || (cl.latitude + ',' + cl.longitude)} +${cl.radius}${cl.distance_unit === 'mile' ? 'mi' : 'km'}`;
    } else if (targeting.geo_locations.cities && targeting.geo_locations.cities[0]) {
      const c = targeting.geo_locations.cities[0];
      geoLabel = `City ${c.key} +${c.radius}${c.distance_unit === 'mile' ? 'mi' : 'km'}`;
    }
  }
  console.log(`   Audience: ${geoLabel}, ages ${targeting.age_min}–${targeting.age_max}, ${genderLabel}`);
  console.log(`   Mode: ${ad.mode === 'direct' ? 'DIRECT (→ landing page)' : 'LEAD FORM (→ IG form → thank-you)'}`);
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
    objective: ad.mode === 'direct' ? 'OUTCOME_TRAFFIC' : 'OUTCOME_LEADS',
    status: 'PAUSED',
    special_ad_categories: JSON.stringify([]),
    is_adset_budget_sharing_enabled: false,
  });
  if (campaign.error) { console.error('Campaign error:', JSON.stringify(campaign.error, null, 2)); process.exit(1); }
  console.log(`   Campaign ID: ${campaign.id}`);

  // Step 2: Create Ad Set
  console.log('2️⃣  Creating ad set...');
  const adSetParams = {
    name: `${ad.name} — Ad Set`,
    campaign_id: campaign.id,
    daily_budget: dailyBudgetCents,
    billing_event: 'IMPRESSIONS',
    optimization_goal: ad.mode === 'direct' ? 'LANDING_PAGE_VIEWS' : 'LEAD_GENERATION',
    bid_strategy: 'LOWEST_COST_WITHOUT_CAP',
    promoted_object: JSON.stringify({ page_id: PAGE_ID }),
    destination_type: ad.mode === 'direct' ? 'WEBSITE' : 'ON_AD',
    targeting: JSON.stringify({ ...targeting, targeting_automation: { advantage_audience: 0 } }),
    status: 'PAUSED',
  };
  if (endDateStr) adSetParams.end_time = endDateStr;
  const adSet = await apiPost(`${AD_ACCOUNT_ID}/adsets`, adSetParams);
  if (adSet.error) { console.error('Ad set error:', JSON.stringify(adSet.error, null, 2)); process.exit(1); }
  console.log(`   Ad Set ID: ${adSet.id}`);

  // Step 3a: Create Lead Form (skipped for direct-mode ads)
  let leadForm;
  if (ad.mode === 'direct') {
    console.log('3️⃣  Skipping lead form (direct-to-landing-page mode)');
  } else if (formIdArg) {
    console.log('3️⃣  Using existing lead form ID:', formIdArg);
    leadForm = { id: formIdArg };
  } else {
    console.log('3️⃣  Creating lead form...');
    // Per-ad lead form definition (questions, context, thank you) — falls back
    // to the player-focused default if the ad doesn't define its own.
    const lf = ad.leadForm || {
      questions: [
        { type: 'FULL_NAME' },
        { type: 'EMAIL' },
        { type: 'PHONE' },
        { type: 'DOB' },
        { type: 'GENDER' },
      ],
      context_card: {
        style: 'LIST_STYLE',
        title: 'Join Lighthouse 1893 Soccer Club',
        content: ['Express your interest in joining. We will be in touch with next steps.'],
        button_text: 'Continue',
      },
      thank_you_page: {
        title: 'Thanks for your interest!',
        body: 'A Lighthouse 1893 coach will reach out to you soon. Follow us on Instagram for updates.',
        button_type: 'VIEW_WEBSITE',
        button_text: 'Follow @lighthouse1893soccerclub',
        website_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
      },
    };
  leadForm = await apiPost(`${PAGE_ID}/leadgen_forms`, {
    name: `${ad.name} — Lead Form — ${new Date().toISOString().replace(/[:.]/g, '-')}`,
    questions: JSON.stringify(lf.questions),
    privacy_policy: JSON.stringify({
      url: 'https://footballhome.org/privacy',
      link_text: 'Privacy Policy',
    }),
    context_card: JSON.stringify(lf.context_card),
    thank_you_page: JSON.stringify(lf.thank_you_page),
    locale: 'EN_US',
    follow_up_action_url: 'https://www.instagram.com/lighthouse1893soccerclub/',
  });
    if (leadForm.error) { console.error('Lead form error:', JSON.stringify(leadForm.error, null, 2)); process.exit(1); }
    console.log(`   Lead Form ID: ${leadForm.id}`);
  }

  // Step 3b: Upload image to get hash
  console.log('   Uploading image...');
  const imgRes = await fetch(ad.imageUrl);
  if (!imgRes.ok) { console.error('Failed to fetch image:', ad.imageUrl); process.exit(1); }
  const imgBuffer = await imgRes.arrayBuffer();
  const imgForm = new FormData();
  imgForm.append('access_token', ACCESS_TOKEN);
  imgForm.append('filename', new Blob([imgBuffer], { type: 'image/png' }), 'ad.png');
  const imgUploadRes = await fetch(`${API}/${AD_ACCOUNT_ID}/adimages`, { method: 'POST', body: imgForm });
  const imgUpload = await imgUploadRes.json();
  if (imgUpload.error) { console.error('Image upload error:', JSON.stringify(imgUpload.error, null, 2)); process.exit(1); }
  const imageHash = Object.values(imgUpload.images)[0].hash;
  console.log(`   Image hash: ${imageHash}`);

  // Step 3c: Create Ad Creative (direct-to-landing or native lead form)
  console.log('   Creating ad creative...');
  const creative = await apiPost(`${AD_ACCOUNT_ID}/adcreatives`, {
    name: `${ad.name} — Creative`,
    object_story_spec: JSON.stringify({
      page_id: PAGE_ID,
      link_data: {
        image_hash: imageHash,
        link: ad.ctaUrl,
        message: ad.caption,
        call_to_action: ad.mode === 'direct'
          ? { type: ad.ctaType || 'SIGN_UP', value: { link: ad.ctaUrl } }
          : { type: 'SIGN_UP', value: { lead_gen_form_id: leadForm.id } },
      },
    }),
  });
  if (creative.error) { console.error('Creative error:', JSON.stringify(creative.error, null, 2)); process.exit(1); }
  if (!creative.id) { console.error('Creative response missing id:', JSON.stringify(creative, null, 2)); process.exit(1); }
  console.log(`   Creative ID: ${creative.id}`);

  // Step 4: Create Ad
  console.log('4️⃣  Creating ad...');
  const createdAd = await apiPost(`${AD_ACCOUNT_ID}/ads`, {
    name: `${ad.name} — Ad`,
    adset_id: adSet.id,
    creative: JSON.stringify({ creative_id: creative.id }),
    status: 'PAUSED',
  });
  if (createdAd.error) { console.error('Ad error:', JSON.stringify(createdAd.error, null, 2)); process.exit(1); }
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
