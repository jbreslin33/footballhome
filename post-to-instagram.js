require('dotenv').config();
const readline = require('readline');
const { exec } = require('child_process');
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

} else {
  console.log(`Lighthouse 1893 SC - Instagram Posting Tool

Usage (manual - requires pre-hosted image URL):
  node post-to-instagram.js photo <image_url> <caption>
  node post-to-instagram.js match-result <image_url> <home> <away> <score_h> <score_a> <league> <date>
  node post-to-instagram.js upcoming <image_url> <opponent> <date> <time> <venue>

Usage (auto-generate image + preview + confirm):
  node post-to-instagram.js auto-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node post-to-instagram.js auto-announcement <home> <away> <league> <date> <time> <venue>

Usage (preview only - no posting):
  node post-to-instagram.js preview-only match-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node post-to-instagram.js preview-only match-announcement <home> <away> <league> <date> <time> <venue>

Example:
  node post-to-instagram.js auto-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"`);
}
