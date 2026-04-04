require('dotenv').config();
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const LOGOS_DIR = path.join(__dirname, 'frontend', 'images', 'teams', 'logos');
const POSTS_DIR = path.join(__dirname, 'frontend', 'images', 'posts');

// Ensure posts dir exists
if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, { recursive: true });

// --- Logo to data URI ---

function logoToDataUri(logoPath) {
  if (!logoPath) return null;
  const ext = path.extname(logoPath).toLowerCase();
  const mimeTypes = { '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.svg': 'image/svg+xml' };
  const mime = mimeTypes[ext] || 'image/png';
  const data = fs.readFileSync(logoPath).toString('base64');
  return `data:${mime};base64,${data}`;
}

function logoImgTag(logoPath, fallbackEmoji) {
  const dataUri = logoToDataUri(logoPath);
  if (dataUri) return `<img src="${dataUri}" style="width:100%;height:100%;object-fit:contain;">`;
  return `<span style="font-size:100px;">${fallbackEmoji}</span>`;
}

// --- Card HTML templates ---

function matchResultHTML({ homeTeam, awayTeam, homeScore, awayScore, homeLogo, awayLogo, date, time, venue, league }) {
  const result = Number(homeScore) > Number(awayScore) ? 'WIN' : Number(homeScore) < Number(awayScore) ? 'LOSS' : 'DRAW';
  const resultColor = result === 'WIN' ? '#22c55e' : result === 'LOSS' ? '#ef4444' : '#f59e0b';
  const headline = `FINAL SCORE`;

  const homeLogoTag = logoImgTag(homeLogo, '🏠');
  const awayLogoTag = logoImgTag(awayLogo, '✈️');

  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative;
    background: linear-gradient(145deg, #0a1628 0%, #0d2247 40%, #0033a0 100%);
    color: white; display: flex; flex-direction: column; align-items: center; justify-content: center;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.05;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 20px 20px;
  }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    padding: 60px;
  }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 8px; background: #f5d442; }
  .result-badge {
    font-size: 36px; font-weight: 800; letter-spacing: 6px; padding: 8px 40px;
    border-radius: 8px; margin-bottom: 20px;
    background: ${resultColor}; color: white;
  }
  .headline {
    font-size: 72px; font-weight: 900; letter-spacing: 6px; text-transform: uppercase;
    text-shadow: 0 4px 10px rgba(0,0,0,0.5); margin-bottom: 50px; color: #f5d442;
  }
  .teams-row { display: flex; align-items: center; justify-content: center; gap: 40px; margin-bottom: 50px; width: 100%; }
  .team-col { display: flex; flex-direction: column; align-items: center; width: 300px; }
  .logo-circle {
    width: 220px; height: 220px; display: flex; align-items: center; justify-content: center;
    background: white; border-radius: 50%; padding: 20px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.4);
  }
  .team-name { font-size: 32px; margin-top: 20px; text-align: center; font-weight: 700; }
  .score-box {
    display: flex; align-items: center; gap: 20px;
    font-size: 100px; font-weight: 900; letter-spacing: 4px;
    text-shadow: 0 4px 20px rgba(0,0,0,0.5);
  }
  .score-dash { font-size: 60px; opacity: 0.6; }
  .details-box {
    background: rgba(255,255,255,0.08); backdrop-filter: blur(10px);
    padding: 30px 60px; border-radius: 16px;
    border: 1px solid rgba(255,255,255,0.15); text-align: center; width: 75%;
  }
  .detail-row { display: flex; align-items: center; justify-content: center; gap: 14px; margin-bottom: 12px; font-size: 34px; }
  .detail-row:last-child { margin-bottom: 0; }
  .footer { margin-top: 40px; font-size: 24px; opacity: 0.5; letter-spacing: 3px; }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="gold-bar"></div>
  <div class="content">
    <div class="result-badge">${result}</div>
    <div class="headline">${headline}</div>
    <div class="teams-row">
      <div class="team-col">
        <div class="logo-circle">${homeLogoTag}</div>
        <div class="team-name">${homeTeam}</div>
      </div>
      <div class="score-box">
        <span>${homeScore}</span>
        <span class="score-dash">–</span>
        <span>${awayScore}</span>
      </div>
      <div class="team-col">
        <div class="logo-circle">${awayLogoTag}</div>
        <div class="team-name">${awayTeam}</div>
      </div>
    </div>
    <div class="details-box">
      <div class="detail-row"><span>🏆</span><span>${league}</span></div>
      <div class="detail-row"><span>📅</span><span>${date}</span></div>
      <div class="detail-row"><span>🕐</span><span>${time}</span></div>
      <div class="detail-row"><span>📍</span><span>${venue}</span></div>
    </div>
    <div class="footer">FOOTBALLHOME.ORG</div>
  </div>
</div>
</body></html>`;
}

function matchAnnouncementHTML({ homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league }) {
  const homeLogoTag = logoImgTag(homeLogo, '🏠');
  const awayLogoTag = logoImgTag(awayLogo, '✈️');

  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative;
    background: linear-gradient(145deg, #0a1628 0%, #0d2247 40%, #0033a0 100%);
    color: white; display: flex; flex-direction: column; align-items: center; justify-content: center;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.05;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 20px 20px;
  }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    padding: 80px 60px 60px 60px;
  }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 8px; background: #f5d442; }
  .headline {
    font-size: 110px; font-weight: 900; letter-spacing: 8px; text-transform: uppercase;
    text-shadow: 0 4px 10px rgba(0,0,0,0.5); margin-bottom: 70px; color: #f5d442; line-height: 1;
  }
  .teams-row { display: flex; align-items: center; justify-content: center; gap: 50px; margin-bottom: 80px; width: 100%; }
  .team-col { display: flex; flex-direction: column; align-items: center; width: 320px; }
  .logo-circle {
    width: 260px; height: 260px; display: flex; align-items: center; justify-content: center;
    background: white; border-radius: 50%; padding: 20px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.4);
  }
  .team-name { font-size: 36px; margin-top: 25px; text-align: center; font-weight: 700; }
  .vs { font-size: 80px; font-weight: 900; color: rgba(255,255,255,0.4); font-style: italic; }
  .details-box {
    background: rgba(255,255,255,0.08); backdrop-filter: blur(10px);
    padding: 35px 70px; border-radius: 16px;
    border: 1px solid rgba(255,255,255,0.15); text-align: center; width: 75%;
  }
  .detail-row { display: flex; align-items: center; justify-content: center; gap: 14px; margin-bottom: 14px; font-size: 38px; }
  .detail-row:last-child { margin-bottom: 0; }
  .footer { margin-top: 50px; font-size: 24px; opacity: 0.5; letter-spacing: 3px; }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="gold-bar"></div>
  <div class="content">
    <div class="headline">MATCH DAY</div>
    <div class="teams-row">
      <div class="team-col">
        <div class="logo-circle">${homeLogoTag}</div>
        <div class="team-name">${homeTeam}</div>
      </div>
      <div class="vs">VS</div>
      <div class="team-col">
        <div class="logo-circle">${awayLogoTag}</div>
        <div class="team-name">${awayTeam}</div>
      </div>
    </div>
    <div class="details-box">
      <div class="detail-row"><span>🏆</span><span>${league}</span></div>
      <div class="detail-row"><span>📅</span><span>${date}</span></div>
      <div class="detail-row"><span>🕐</span><span>${time}</span></div>
      <div class="detail-row"><span>📍</span><span>${venue}</span></div>
    </div>
    <div class="footer">FOOTBALLHOME.ORG</div>
  </div>
</div>
</body></html>`;
}

function gameDayHTML({ homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league, players }) {
  const homeLogoTag = logoImgTag(homeLogo, '🏠');
  const awayLogoTag = logoImgTag(awayLogo, '✈️');
  const playerList = (players || []).map(p => `<span class="player">${p}</span>`).join('');

  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative;
    background: linear-gradient(145deg, #0a1628 0%, #0d2247 40%, #0033a0 100%);
    color: white; display: flex; flex-direction: column; align-items: center; justify-content: center;
  }
  .pattern { position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.05; background-image: radial-gradient(#ffffff 1px, transparent 1px); background-size: 20px 20px; }
  .content { position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 50px 60px; }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 8px; background: #f5d442; }
  .headline { font-size: 80px; font-weight: 900; letter-spacing: 6px; text-transform: uppercase; text-shadow: 0 4px 10px rgba(0,0,0,0.5); margin-bottom: 30px; color: #f5d442; line-height: 1; }
  .teams-row { display: flex; align-items: center; justify-content: center; gap: 30px; margin-bottom: 30px; width: 100%; }
  .team-col { display: flex; flex-direction: column; align-items: center; width: 200px; }
  .logo-circle { width: 160px; height: 160px; display: flex; align-items: center; justify-content: center; background: white; border-radius: 50%; padding: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.4); }
  .team-name { font-size: 26px; margin-top: 12px; text-align: center; font-weight: 700; }
  .vs { font-size: 50px; font-weight: 900; color: rgba(255,255,255,0.4); font-style: italic; }
  .details-row { display: flex; gap: 30px; margin-bottom: 25px; font-size: 28px; opacity: 0.9; }
  .details-row span { display: flex; align-items: center; gap: 8px; }
  .roster-box { background: rgba(255,255,255,0.08); backdrop-filter: blur(10px); padding: 25px 40px; border-radius: 16px; border: 1px solid rgba(255,255,255,0.15); width: 85%; }
  .roster-title { font-size: 28px; font-weight: 700; text-align: center; margin-bottom: 15px; color: #f5d442; letter-spacing: 3px; }
  .roster-grid { display: flex; flex-wrap: wrap; justify-content: center; gap: 8px; }
  .player { background: rgba(255,255,255,0.12); padding: 8px 18px; border-radius: 20px; font-size: 22px; font-weight: 500; }
  .footer { margin-top: 25px; font-size: 24px; opacity: 0.5; letter-spacing: 3px; }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="gold-bar"></div>
  <div class="content">
    <div class="headline">⚽ GAME DAY</div>
    <div class="teams-row">
      <div class="team-col">
        <div class="logo-circle">${homeLogoTag}</div>
        <div class="team-name">${homeTeam}</div>
      </div>
      <div class="vs">VS</div>
      <div class="team-col">
        <div class="logo-circle">${awayLogoTag}</div>
        <div class="team-name">${awayTeam}</div>
      </div>
    </div>
    <div class="details-row">
      <span>🏆 ${league}</span>
      <span>📅 ${date}</span>
      <span>🕐 ${time}</span>
    </div>
    <div class="details-row">
      <span>📍 ${venue}</span>
    </div>
    ${players && players.length ? `
    <div class="roster-box">
      <div class="roster-title">GAME DAY SQUAD</div>
      <div class="roster-grid">${playerList}</div>
    </div>` : ''}
    <div class="footer">FOOTBALLHOME.ORG</div>
  </div>
</div>
</body></html>`;
}

function lineupHTML({ homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league, starters, subs }) {
  const homeLogoTag = logoImgTag(homeLogo, '🏠');
  const awayLogoTag = logoImgTag(awayLogo, '✈️');

  const starterRows = (starters || []).map(p =>
    `<div class="lineup-player"><span class="jersey">${p.number || ''}</span><span class="pname">${p.name}</span><span class="pos">${p.position || ''}</span></div>`
  ).join('');

  const subRows = (subs || []).map(p =>
    `<div class="lineup-player sub"><span class="jersey">${p.number || ''}</span><span class="pname">${p.name}</span><span class="pos">${p.position || ''}</span></div>`
  ).join('');

  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative;
    background: linear-gradient(145deg, #0a1628 0%, #0d2247 40%, #0033a0 100%);
    color: white; display: flex; flex-direction: column; align-items: center; justify-content: center;
  }
  .pattern { position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.05; background-image: radial-gradient(#ffffff 1px, transparent 1px); background-size: 20px 20px; }
  .content { position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; flex-direction: column; align-items: center; padding: 50px 60px; }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 8px; background: #f5d442; }
  .headline { font-size: 70px; font-weight: 900; letter-spacing: 6px; text-transform: uppercase; text-shadow: 0 4px 10px rgba(0,0,0,0.5); margin-bottom: 20px; color: #f5d442; line-height: 1; }
  .match-info { display: flex; align-items: center; gap: 20px; margin-bottom: 25px; }
  .mini-logo { width: 50px; height: 50px; display: flex; align-items: center; justify-content: center; background: white; border-radius: 50%; padding: 6px; }
  .mini-logo img { width: 100%; height: 100%; object-fit: contain; }
  .match-text { font-size: 30px; font-weight: 700; }
  .lineup-section { width: 85%; margin-bottom: 15px; }
  .section-title { font-size: 24px; font-weight: 700; letter-spacing: 3px; color: #f5d442; margin-bottom: 10px; text-align: center; }
  .lineup-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
  .lineup-player { display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.1); padding: 10px 16px; border-radius: 8px; font-size: 22px; }
  .lineup-player.sub { opacity: 0.75; }
  .jersey { font-weight: 800; color: #f5d442; min-width: 30px; text-align: center; }
  .pname { flex: 1; font-weight: 500; }
  .pos { font-size: 18px; opacity: 0.6; text-transform: uppercase; }
  .divider { width: 60%; height: 1px; background: rgba(255,255,255,0.15); margin: 10px 0; }
  .footer { margin-top: auto; padding-top: 15px; font-size: 24px; opacity: 0.5; letter-spacing: 3px; }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="gold-bar"></div>
  <div class="content">
    <div class="headline">STARTING XI</div>
    <div class="match-info">
      <div class="mini-logo">${homeLogoTag}</div>
      <span class="match-text">${homeTeam} vs ${awayTeam}</span>
      <div class="mini-logo">${awayLogoTag}</div>
    </div>
    <div class="lineup-section">
      <div class="section-title">STARTERS</div>
      <div class="lineup-grid">${starterRows}</div>
    </div>
    ${subs && subs.length ? `
    <div class="divider"></div>
    <div class="lineup-section">
      <div class="section-title">SUBSTITUTES</div>
      <div class="lineup-grid">${subRows}</div>
    </div>` : ''}
    <div class="footer">FOOTBALLHOME.ORG</div>
  </div>
</div>
</body></html>`;
}

// --- Logo lookup ---

function findLogo(teamName) {
  // Normalize team name to match filenames
  const slug = teamName.toLowerCase()
    .replace(/\s+fc$/i, '').replace(/\s+sc$/i, '')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  
  const files = fs.readdirSync(LOGOS_DIR);
  // Try exact slug match first
  for (const f of files) {
    const base = path.parse(f).name.toLowerCase();
    if (base === slug) return path.join(LOGOS_DIR, f);
  }
  // Try partial match
  for (const f of files) {
    const base = path.parse(f).name.toLowerCase();
    if (slug.includes(base) || base.includes(slug)) return path.join(LOGOS_DIR, f);
  }
  // Try first word match
  const firstWord = slug.split('-')[0];
  if (firstWord.length > 3) {
    for (const f of files) {
      const base = path.parse(f).name.toLowerCase();
      if (base.includes(firstWord)) return path.join(LOGOS_DIR, f);
    }
  }
  return null;
}

// --- Generate image ---

async function generateCard(type, data) {
  let html;
  if (type === 'match-result' || type === 'post_game') {
    html = matchResultHTML(data);
  } else if (type === 'match-announcement' || type === 'pre_match_announcement') {
    html = matchAnnouncementHTML(data);
  } else if (type === 'game_day') {
    html = gameDayHTML(data);
  } else if (type === 'lineup') {
    html = lineupHTML(data);
  } else {
    throw new Error(`Unknown card type: ${type}`);
  }

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1080, height: 1080 });
  await page.setContent(html, { waitUntil: 'networkidle0' });

  const filename = `${type}-${Date.now()}.png`;
  const filepath = path.join(POSTS_DIR, filename);
  await page.screenshot({ path: filepath, type: 'png' });
  await browser.close();

  return { filepath, filename };
}

// --- CLI ---

async function main() {
  const args = process.argv.slice(2);
  const type = args[0];

  if (type === 'match-result') {
    // node generate-match-card.js match-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
    const [, homeTeam, awayTeam, homeScore, awayScore, league, date, time, venue] = args;
    if (!homeTeam) {
      console.log('Usage: node generate-match-card.js match-result <home> <away> <home_score> <away_score> <league> <date> <time> <venue>');
      process.exit(1);
    }
    const homeLogo = findLogo(homeTeam);
    const awayLogo = findLogo(awayTeam);
    console.log('Home logo:', homeLogo || '(none)');
    console.log('Away logo:', awayLogo || '(none)');

    const { filepath, filename } = await generateCard('match-result', {
      homeTeam, awayTeam, homeScore, awayScore, homeLogo, awayLogo, date, time, venue, league,
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);
    return { filepath, filename };

  } else if (type === 'match-announcement') {
    // node generate-match-card.js match-announcement "Lighthouse 1893 SC" "Sewell Old Boys FC" "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
    const [, homeTeam, awayTeam, league, date, time, venue] = args;
    if (!homeTeam) {
      console.log('Usage: node generate-match-card.js match-announcement <home> <away> <league> <date> <time> <venue>');
      process.exit(1);
    }
    const homeLogo = findLogo(homeTeam);
    const awayLogo = findLogo(awayTeam);
    console.log('Home logo:', homeLogo || '(none)');
    console.log('Away logo:', awayLogo || '(none)');

    const { filepath, filename } = await generateCard('match-announcement', {
      homeTeam, awayTeam, homeLogo, awayLogo, date, time, venue, league,
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);
    return { filepath, filename };

  } else {
    console.log(`Match Card Generator

Usage:
  node generate-match-card.js match-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node generate-match-card.js match-announcement <home> <away> <league> <date> <time> <venue>

Example:
  node generate-match-card.js match-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
`);
  }
}

module.exports = { generateCard, findLogo, matchResultHTML, matchAnnouncementHTML, gameDayHTML, lineupHTML, POSTS_DIR };
main();
