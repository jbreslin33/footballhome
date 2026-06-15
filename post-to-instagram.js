require('dotenv').config();
const readline = require('readline');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const { generateCard, findLogo } = require('./generate-match-card');

const INSTAGRAM_USER_ID = '26233831926285183';
const ACCESS_TOKEN = process.env.INSTAGRAM_ACCESS_TOKEN;
const API_BASE = 'https://graph.instagram.com/v21.0';
const PUBLIC_BASE = 'https://footballhome.org/images/posts';

async function postPhoto(imageUrl, caption) {
  // Step 1: Create media container
  const createParams = new URLSearchParams({
    image_url: imageUrl,
    caption: caption,
    access_token: ACCESS_TOKEN,
  });

  const createRes = await fetch(`${API_BASE}/${INSTAGRAM_USER_ID}/media`, {
    method: 'POST',
    body: createParams,
  });
  const createData = await createRes.json();

  if (createData.error) {
    console.error('Error creating media container:', createData.error);
    return null;
  }

  console.log('Media container created:', createData.id);

  // Step 2: Wait for container to be ready, then publish
  await new Promise(resolve => setTimeout(resolve, 5000));
  const publishParams = new URLSearchParams({
    creation_id: createData.id,
    access_token: ACCESS_TOKEN,
  });

  const publishRes = await fetch(`${API_BASE}/${INSTAGRAM_USER_ID}/media_publish`, {
    method: 'POST',
    body: publishParams,
  });
  const publishData = await publishRes.json();

  if (publishData.error) {
    console.error('Error publishing:', publishData.error);
    return null;
  }

  console.log('Post published! Media ID:', publishData.id);
  return publishData.id;
}

async function postCarousel(imageUrls, caption) {
  // Step 1: Create individual media containers for each image
  const childIds = [];
  for (const url of imageUrls) {
    const params = new URLSearchParams({
      image_url: url,
      is_carousel_item: 'true',
      access_token: ACCESS_TOKEN,
    });

    const res = await fetch(`${API_BASE}/${INSTAGRAM_USER_ID}/media`, {
      method: 'POST',
      body: params,
    });
    const data = await res.json();

    if (data.error) {
      console.error('Error creating carousel item:', data.error);
      return null;
    }
    childIds.push(data.id);
    console.log('Carousel item created:', data.id);
  }

  // Step 2: Create carousel container
  const carouselParams = new URLSearchParams({
    media_type: 'CAROUSEL',
    caption: caption,
    access_token: ACCESS_TOKEN,
  });
  childIds.forEach(id => carouselParams.append('children', id));

  const carouselRes = await fetch(`${API_BASE}/${INSTAGRAM_USER_ID}/media`, {
    method: 'POST',
    body: carouselParams,
  });
  const carouselData = await carouselRes.json();

  if (carouselData.error) {
    console.error('Error creating carousel:', carouselData.error);
    return null;
  }

  // Step 3: Publish carousel
  const publishParams = new URLSearchParams({
    creation_id: carouselData.id,
    access_token: ACCESS_TOKEN,
  });

  const publishRes = await fetch(`${API_BASE}/${INSTAGRAM_USER_ID}/media_publish`, {
    method: 'POST',
    body: publishParams,
  });
  const publishData = await publishRes.json();

  if (publishData.error) {
    console.error('Error publishing carousel:', publishData.error);
    return null;
  }

  console.log('Carousel published! Media ID:', publishData.id);
  return publishData.id;
}

// --- Post templates ---

function matchResultCaption(homeTeam, awayTeam, homeScore, awayScore, league, date) {
  const result = homeScore > awayScore ? 'WIN' : homeScore < awayScore ? 'LOSS' : 'DRAW';
  return `⚽ MATCH RESULT: ${result}\n\n` +
    `${homeTeam} ${homeScore} - ${awayScore} ${awayTeam}\n` +
    `🏆 ${league}\n` +
    `📅 ${date}\n\n` +
    `#Lighthouse1893 #APSL #PhillySoccer #AdultSoccer #Lighthouse1893SC`;
}

function upcomingMatchCaption(opponent, date, time, venue) {
  return `🔜 MATCH DAY\n\n` +
    `Lighthouse 1893 SC vs ${opponent}\n` +
    `📅 ${date}\n` +
    `⏰ ${time}\n` +
    `📍 ${venue}\n\n` +
    `Come out and support the club! 💪\n\n` +
    `#Lighthouse1893 #APSL #PhillySoccer #MatchDay #Lighthouse1893SC`;
}

function standingsCaption(position, played, won, drawn, lost, points) {
  return `📊 LEAGUE STANDINGS UPDATE\n\n` +
    `Lighthouse 1893 SC\n` +
    `📍 Position: ${position}\n` +
    `🏟️ Played: ${played}\n` +
    `✅ Won: ${won} | 🤝 Drawn: ${drawn} | ❌ Lost: ${lost}\n` +
    `⭐ Points: ${points}\n\n` +
    `#Lighthouse1893 #APSL #PhillySoccer #LeagueStandings #Lighthouse1893SC`;
}

// --- Recruiting / organic campaign posts ---

const ORGANIC_POSTS = {
  'grassroots-brazil': {
    name: 'Philly Grassroots Cup — Brazil (organic)',
    imageUrl: `${PUBLIC_BASE}/grassroots-cup-ad-brazil.png`,
    caption: `🇧🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — BRAZIL TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Brazil team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Brazilian!\n⚠️ Spots are limited and filling fast!\n\n🔗 Fill out the interest form — link in bio!\n\n#PhillyGrassrootsCup #Brazil #Lighthouse1893 #PhillySoccer #CASASoccer`,
  },
  'grassroots-puertorico': {
    name: 'Philly Grassroots Cup — Puerto Rico (organic)',
    imageUrl: `${PUBLIC_BASE}/grassroots-cup-ad-puertorico.png`,
    caption: `🇵🇷 WE'RE GOING TO THE PHILLY GRASSROOTS CUP — PUERTO RICO TEAM!\n\nLighthouse 1893 SC is proud to sponsor the Puerto Rico team in the 2026 Philly Grassroots Cup!\n\n🏆 3-game group stage + knockouts · 12 Nations\n📅 First match: June 7, 2026\n📍 Philadelphia, PA\n\n🌎 Open to ALL players — You do not have to be Puerto Rican!\n⚠️ Spots are limited and filling fast!\n\n🔗 Fill out the interest form — link in bio!\n\n#PhillyGrassrootsCup #PuertoRico #Lighthouse1893 #PhillySoccer #CASASoccer`,
  },
  'u23-mens': {
    name: 'U23 Mens — Interest Form (organic)',
    imageUrl: `${PUBLIC_BASE}/u23-ad-mens.png`,
    caption: `⚽ NOW FORMING: LIGHTHOUSE BOYS CLUB U23!\n\nLighthouse Boys Club U23 is forming a team in the CASA Men's U23 Premier League!\n\n📅 First Match: May 31, 2026\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players · Ages 16–25 eligible\n\n🔗 Fill out the interest form — link in bio!\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer`,
  },
  'u23-womens': {
    name: 'U23 Womens — Interest Form (organic)',
    imageUrl: `${PUBLIC_BASE}/u23-ad-womens.png`,
    caption: `⚽ NOW FORMING: LIGHTHOUSE WOMEN'S CLUB U23!\n\nLighthouse Women's Club U23 is forming a team in partnership with CASA Soccer!\n\n📅 First Match: May 31, 2026\n🏆 League: CASA Soccer · Philadelphia\n📍 Philadelphia, PA\n🎯 Open to ALL players · Ages 16–25 eligible\n\n🔗 Fill out the interest form — link in bio!\n\n#Lighthouse1893 #U23 #PhillySoccer #CASASoccer #U23Soccer #Lighthouse1893SC #PhillyFootball #WomensSoccer`,
  },
};

// --- Open image for preview ---

function openImage(filepath) {
  const cmd = process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'start ""' : 'xdg-open';
  exec(`${cmd} "${filepath}"`, (err) => {
    if (err) console.log('  (Could not auto-open image. Open manually:', filepath, ')');
  });
}

// --- Interactive confirm ---

function askConfirm(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(resolve => {
    rl.question(question, answer => {
      rl.close();
      resolve(answer.trim().toLowerCase());
    });
  });
}

// --- CLI usage ---

const args = process.argv.slice(2);
const command = args[0];

if (command === 'photo') {
  const imageUrl = args[1];
  const caption = args.slice(2).join(' ');
  if (!imageUrl || !caption) {
    console.log('Usage: node post-to-instagram.js photo <image_url> <caption>');
    process.exit(1);
  }
  postPhoto(imageUrl, caption);

} else if (command === 'match-result') {
  const [, imageUrl, homeTeam, awayTeam, homeScore, awayScore, league, date] = args;
  if (!imageUrl || !homeTeam) {
    console.log('Usage: node post-to-instagram.js match-result <image_url> <home_team> <away_team> <home_score> <away_score> <league> <date>');
    process.exit(1);
  }
  const caption = matchResultCaption(homeTeam, awayTeam, homeScore, awayScore, league, date);
  console.log('Caption:', caption);
  postPhoto(imageUrl, caption);

} else if (command === 'upcoming') {
  const [, imageUrl, opponent, date, time, venue] = args;
  if (!imageUrl || !opponent) {
    console.log('Usage: node post-to-instagram.js upcoming <image_url> <opponent> <date> <time> <venue>');
    process.exit(1);
  }
  const caption = upcomingMatchCaption(opponent, date, time, venue);
  console.log('Caption:', caption);
  postPhoto(imageUrl, caption);

} else if (command === 'standings') {
  const [, imageUrl, position, played, won, drawn, lost, points] = args;
  if (!imageUrl || !position) {
    console.log('Usage: node post-to-instagram.js standings <image_url> <position> <played> <won> <drawn> <lost> <points>');
    process.exit(1);
  }
  const caption = standingsCaption(position, played, won, drawn, lost, points);
  console.log('Caption:', caption);
  postPhoto(imageUrl, caption);

// --- NEW: Auto-generate + preview + confirm ---

} else if (command === 'auto-result') {
  // node post-to-instagram.js auto-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
  (async () => {
    const [, homeTeam, awayTeam, homeScore, awayScore, league, date, time, venue] = args;
    if (!homeTeam) {
      console.log('Usage: node post-to-instagram.js auto-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>');
      process.exit(1);
    }

    // 1) Generate image
    console.log('\n🎨 Generating match result card...');
    const homeLogo = findLogo(homeTeam);
    const awayLogo = findLogo(awayTeam);
    const { filepath, filename } = await generateCard('match-result', {
      homeTeam, awayTeam, homeScore, awayScore, homeLogo, awayLogo, date, time, venue, league,
    });
    const publicUrl = `${PUBLIC_BASE}/${filename}`;

    // 2) Generate caption
    const caption = matchResultCaption(homeTeam, awayTeam, homeScore, awayScore, league, date);

    // 3) Show preview
    console.log('\n' + '='.repeat(60));
    console.log('📸 IMAGE PREVIEW');
    console.log('='.repeat(60));
    console.log(`Local file: ${filepath}`);
    console.log(`Public URL: ${publicUrl}`);
    openImage(filepath);
    console.log('\n' + '='.repeat(60));
    console.log('📝 CAPTION PREVIEW');
    console.log('='.repeat(60));
    console.log(caption);
    console.log('='.repeat(60));

    // 4) Ask for confirmation
    const answer = await askConfirm('\n🚀 Post this to Instagram? (yes/no): ');
    if (answer === 'yes' || answer === 'y') {
      console.log('\n📤 Posting to Instagram...');
      const mediaId = await postPhoto(publicUrl, caption);
      if (mediaId) {
        console.log('\n✅ Successfully posted to Instagram!');
      }
    } else {
      console.log('\n❌ Post cancelled. Image saved at:', filepath);
    }
  })();

} else if (command === 'grassroots-result') {
  // Match-result post tailored for the Philly Grassroots Cup: country-flag
  // graphics, country emojis in the caption, cup-correct hashtags.
  // Usage:
  //   node post-to-instagram.js grassroots-result \
  //     "Puerto Rico" 🇵🇷 "Israel" 🇮🇱 3 1 "Group Stage Game 2" "June 14, 2026" "Lighthouse Field" \
  //     ["optional extra blurb"]
  (async () => {
    const [, homeTeam, homeFlag, awayTeam, awayFlag, homeScore, awayScore, stage, date, venue, blurb] = args;
    if (!homeTeam || !awayTeam || homeScore === undefined || awayScore === undefined) {
      console.log('Usage: node post-to-instagram.js grassroots-result <home> <homeFlag> <away> <awayFlag> <home_score> <away_score> <stage> <date> <venue> [blurb]');
      process.exit(1);
    }

    console.log('\n🎨 Generating Grassroots Cup result card...');
    const homeLogo = findLogo(homeTeam);
    const awayLogo = findLogo(awayTeam);
    const league = `Philly Grassroots Cup — ${stage}`;
    const { filepath, filename } = await generateCard('match-result', {
      homeTeam, awayTeam, homeScore, awayScore, homeLogo, awayLogo,
      date, time: '', venue, league,
    });
    const publicUrl = `${PUBLIC_BASE}/${filename}`;

    // Caption — cup-appropriate hashtags + country tag inferred from home team
    const result = Number(homeScore) > Number(awayScore) ? 'WIN'
                 : Number(homeScore) < Number(awayScore) ? 'LOSS' : 'DRAW';
    const countryHashtag = '#' + homeTeam.replace(/[^A-Za-z0-9]/g, '');
    const caption =
      `⚽ MATCH RESULT: ${result}\n\n` +
      `${homeTeam} ${homeFlag} ${homeScore} – ${awayScore} ${awayTeam} ${awayFlag}\n` +
      `🏆 ${league}\n` +
      `📅 ${date}\n` +
      `📍 ${venue}\n` +
      (blurb ? `\n${blurb}\n` : '') +
      `\n#PhillyGrassrootsCup ${countryHashtag} #Lighthouse1893 #PhillySoccer #CASASoccer #Lighthouse1893SC`;

    console.log('\n' + '='.repeat(60));
    console.log('📸 IMAGE PREVIEW');
    console.log('='.repeat(60));
    console.log(`Local file: ${filepath}`);
    console.log(`Public URL: ${publicUrl}`);
    openImage(filepath);
    console.log('\n' + '='.repeat(60));
    console.log('📝 CAPTION PREVIEW');
    console.log('='.repeat(60));
    console.log(caption);
    console.log('='.repeat(60));

    const answer = await askConfirm('\n🚀 Post this to Instagram? (yes/no): ');
    if (answer === 'yes' || answer === 'y') {
      console.log('\n📤 Posting to Instagram...');
      const mediaId = await postPhoto(publicUrl, caption);
      if (mediaId) {
        console.log('\n✅ Successfully posted to Instagram!');
      }
    } else {
      console.log('\n❌ Post cancelled. Image saved at:', filepath);
    }
  })();

} else if (command === 'auto-announcement') {
  // node post-to-instagram.js auto-announcement "Lighthouse 1893 SC" "Sewell Old Boys FC" "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
  (async () => {
    const [, homeTeam, awayTeam, league, date, time, venue] = args;
    if (!homeTeam) {
      console.log('Usage: node post-to-instagram.js auto-announcement <home> <away> <league> <date> <time> <venue>');
      process.exit(1);
    }

    console.log('\n🎨 Generating match announcement card...');
    const homeLogo = findLogo(homeTeam);
    const awayLogo = findLogo(awayTeam);
    const { filepath, filename } = await generateCard('match-announcement', {
      homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league,
    });
    const publicUrl = `${PUBLIC_BASE}/${filename}`;
    const caption = upcomingMatchCaption(awayTeam, date, time, venue);

    console.log('\n' + '='.repeat(60));
    console.log('📸 IMAGE PREVIEW');
    console.log('='.repeat(60));
    console.log(`Local file: ${filepath}`);
    console.log(`Public URL: ${publicUrl}`);
    openImage(filepath);
    console.log('\n' + '='.repeat(60));
    console.log('📝 CAPTION PREVIEW');
    console.log('='.repeat(60));
    console.log(caption);
    console.log('='.repeat(60));

    const answer = await askConfirm('\n🚀 Post this to Instagram? (yes/no): ');
    if (answer === 'yes' || answer === 'y') {
      console.log('\n📤 Posting to Instagram...');
      const mediaId = await postPhoto(publicUrl, caption);
      if (mediaId) {
        console.log('\n✅ Successfully posted to Instagram!');
      }
    } else {
      console.log('\n❌ Post cancelled. Image saved at:', filepath);
    }
  })();

} else if (command === 'preview-only') {

  // Just generate image, no posting
  (async () => {
    const subtype = args[1]; // match-result or match-announcement
    if (subtype === 'match-result') {
      const [,, homeTeam, awayTeam, homeScore, awayScore, league, date, time, venue] = args;
      const homeLogo = findLogo(homeTeam);
      const awayLogo = findLogo(awayTeam);
      const { filepath, filename } = await generateCard('match-result', {
        homeTeam, awayTeam, homeScore, awayScore, homeLogo, awayLogo, date, time, venue, league,
      });
      console.log(`\n✅ Preview saved: ${filepath}`);
      console.log(`   Public URL:   ${PUBLIC_BASE}/${filename}`);
      openImage(filepath);
    } else if (subtype === 'match-announcement') {
      const [,, homeTeam, awayTeam, league, date, time, venue] = args;
      const homeLogo = findLogo(homeTeam);
      const awayLogo = findLogo(awayTeam);
      const { filepath, filename } = await generateCard('match-announcement', {
        homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league,
      });
      console.log(`\n✅ Preview saved: ${filepath}`);
      console.log(`   Public URL:   ${PUBLIC_BASE}/${filename}`);
      openImage(filepath);
    } else {
      console.log('Usage: node post-to-instagram.js preview-only <match-result|match-announcement> ...');
    }
  })();

} else if (command === 'recruit') {
  // node post-to-instagram.js recruit <key>
  // e.g. node post-to-instagram.js recruit grassroots-brazil
  (async () => {
    const key = args[1];
    const post = ORGANIC_POSTS[key];
    if (!post) {
      console.log(`Unknown recruit key: "${key}"`);
      console.log('Available:', Object.keys(ORGANIC_POSTS).join(', '));
      process.exit(1);
    }

    console.log(`\n📋 ${post.name}`);
    console.log('\n' + '='.repeat(60));
    console.log('📸 IMAGE');
    console.log('='.repeat(60));
    console.log(post.imageUrl);
    console.log('\n' + '='.repeat(60));
    console.log('📝 CAPTION PREVIEW');
    console.log('='.repeat(60));
    console.log(post.caption.replace(/\\n/g, '\n'));
    console.log('='.repeat(60));

    const answer = await askConfirm('\n🚀 Post this to Instagram? (yes/no): ');
    if (answer === 'yes' || answer === 'y') {
      console.log('\n📤 Posting to Instagram...');
      const mediaId = await postPhoto(post.imageUrl, post.caption);
      if (mediaId) {
        console.log('\n✅ Successfully posted to Instagram!');
      }
    } else {
      console.log('\n❌ Post cancelled.');
    }
  })();

} else if (command === 'exhibit') {
  // node post-to-instagram.js exhibit 1                    # render + post P1 carousel
  // node post-to-instagram.js exhibit 1 single             # render + post P1 as ONE 4:5 tile (no slides)
  // node post-to-instagram.js exhibit 1 preview            # carousel preview, no post
  // node post-to-instagram.js exhibit 1 single preview     # single preview, no post
  //
  // Renders directly from frontend/exhibit/lighthouse-history.html (the
  // printed museum poster IS the source). No intermediate JSON.
  (async () => {
    const posterNum = parseInt(args[1], 10);
    if (!posterNum) {
      console.log('Usage: node post-to-instagram.js exhibit <posterNum> [single] [preview]');
      process.exit(1);
    }
    // Mode parsing: 'single' = 1-tile 4:5 post; 'preview' alone = carousel preview.
    const rest = args.slice(2).map(a => (a || '').toLowerCase());
    const mode = rest.includes('single') ? 'single' : 'carousel';
    const previewOnly = rest.includes('preview');

    const pad = String(posterNum).padStart(2, '0');

    // Step 1 — render the kinds we need (always render all three so the local
    // slideshow preview can flip between them).
    console.log(`\n🎨 Rendering exhibit poster ${posterNum} from source...`);
    const { renderPoster } = require('./scripts/render-poster-from-source.js');
    const { meta, slideCount } = await renderPoster(posterNum, new Set(['long', 'single', 'slides']));

    // Caption is built straight from the source band — kicker, title, sub —
    // nothing invented. Edit the printed poster's HTML to change the caption.
    const captionParts = [];
    if (meta.kicker) captionParts.push(meta.kicker.toUpperCase());
    if (meta.title)  captionParts.push(meta.title);
    if (meta.sub)    captionParts.push('', meta.sub);
    const caption = captionParts.join('\n').slice(0, 2200);

    // Step 2 — preview
    console.log('\n' + '='.repeat(60));
    console.log(`📚 EXHIBIT POSTER ${pad}: ${meta.title || ''}`);
    console.log('='.repeat(60));

    let singleUrl = null;
    let slideUrls = [];
    if (mode === 'single') {
      singleUrl = `${PUBLIC_BASE}/exhibit-p${pad}-poster.png`;
      console.log(`IG SINGLE (1 tile, 1080x1350):\n  ${singleUrl}`);
    } else {
      if (!slideCount) {
        console.error(`Poster ${posterNum} produced no carousel slides.`);
        process.exit(1);
      }
      if (slideCount > 10) {
        console.warn(`⚠️  Poster has ${slideCount} slides; IG carousel max is 10. Only first 10 will be posted.`);
      }
      const carouselCount = Math.min(slideCount, 10);
      const slideFiles = Array.from({ length: carouselCount }, (_, i) => `exhibit-p${pad}-${i + 1}.png`);
      slideUrls = slideFiles.map(f => `${PUBLIC_BASE}/${f}`);
      console.log(`IG CAROUSEL (${carouselCount} slides):`);
      slideUrls.forEach((u, i) => console.log(`  ${i + 1}. ${u}`));
    }

    const previewView = mode === 'single' ? 'poster' : 'carousel';
    console.log(`\n👀 Local preview:  file://${path.join(__dirname, 'frontend/exhibit/slideshow.html')}?p=${posterNum}&view=${previewView}`);
    console.log('\n' + '='.repeat(60));
    console.log('📝 CAPTION (derived from source band — edit lighthouse-history.html to change)');
    console.log('='.repeat(60));
    console.log(caption);
    console.log('='.repeat(60));
    console.log(`Caption length: ${caption.length}/2200`);
    // Open the local slideshow viewer in the default browser
    openImage(`${path.join(__dirname, 'frontend/exhibit/slideshow.html')}?p=${posterNum}&view=${previewView}`);

    if (previewOnly) {
      console.log('\n👀 Preview only. Not posting.');
      return;
    }

    const promptLabel = mode === 'single' ? 'single tile' : 'carousel';
    const answer = await askConfirm(`\n🚀 Post this ${promptLabel} to Instagram? (yes/no): `);
    if (answer === 'yes' || answer === 'y') {
      console.log(`\n📤 Posting ${promptLabel} to Instagram...`);
      const mediaId = mode === 'single'
        ? await postPhoto(singleUrl, caption)
        : await postCarousel(slideUrls, caption);
      if (mediaId) {
        console.log('\n✅ Successfully posted to Instagram!');
        console.log(`\n   Media ID: ${mediaId}`);
        console.log(`   To delete: open the post in the IG app → ⋯ menu → Delete`);
        console.log(`   (Graph API does not expose post deletion; deleted posts sit in Recently Deleted for 30 days.)`);
      }
    } else {
      console.log('\n❌ Post cancelled.');
    }
  })();

} else {
  console.log(`Lighthouse 1893 SC - Instagram Posting Tool

Usage (manual - requires pre-hosted image URL):
  node post-to-instagram.js photo <image_url> <caption>
  node post-to-instagram.js match-result <image_url> <home> <away> <score_h> <score_a> <league> <date>
  node post-to-instagram.js upcoming <image_url> <opponent> <date> <time> <venue>

Usage (auto-generate image + preview + confirm):
  node post-to-instagram.js auto-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node post-to-instagram.js auto-announcement <home> <away> <league> <date> <time> <venue>
  node post-to-instagram.js grassroots-result <home> <homeFlag> <away> <awayFlag> <score_h> <score_a> <stage> <date> <venue> [blurb]

Usage (recruiting / organic campaign posts):
  node post-to-instagram.js recruit grassroots-brazil
  node post-to-instagram.js recruit grassroots-puertorico
  node post-to-instagram.js recruit u23-mens
  node post-to-instagram.js recruit u23-womens

Usage (Lighthouse history exhibit — 20-poster carousel campaign):
  node post-to-instagram.js exhibit <posterNum>                  Generate + post P# carousel
  node post-to-instagram.js exhibit <posterNum> single           Generate + post P# as one 4:5 tile
  node post-to-instagram.js exhibit <posterNum> preview          Carousel preview only
  node post-to-instagram.js exhibit <posterNum> single preview   Single-tile preview only

Usage (preview only - no posting):
  node post-to-instagram.js preview-only match-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node post-to-instagram.js preview-only match-announcement <home> <away> <league> <date> <time> <venue>

Example:
  node post-to-instagram.js auto-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"`);
}
