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

function grassrootsCupAdHTML({ country, flagEmoji, colorPrimary, colorSecondary, colorAccent, lighthouseLogo, welovejunkLogo, complexLogo, casaLogo, openBannerText = '🌎 Open to All Players — Spots Limited!', eligibilityText = null }) {
  const lighthouseLogoTag = lighthouseLogo ? logoImgTag(lighthouseLogo, '⚓') : '<span style="font-size:60px;">⚓</span>';
  const welovejunkLogoTag = welovejunkLogo ? logoImgTag(welovejunkLogo, '🗑️') : '<span style="font-size:40px;">🗑️</span>';
  const complexLogoTag = complexLogo ? logoImgTag(complexLogo, '🏟️') : '<span style="font-size:40px;">🏟️</span>';
  const casaLogoTag = casaLogo ? logoImgTag(casaLogo, '⚽') : '<span style="font-size:40px;">⚽</span>';
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative; overflow: hidden;
    background: linear-gradient(160deg, ${colorPrimary} 0%, #0a1628 55%, ${colorSecondary} 100%);
    color: white;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.04;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 28px 28px;
  }
  .hex-bg {
    position: absolute; top: -80px; right: -80px; width: 500px; height: 500px;
    opacity: 0.08; border-radius: 50%;
    background: radial-gradient(circle, ${colorAccent} 0%, transparent 70%);
  }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, ${colorAccent}, #f5d442, ${colorAccent}); }
  .bottom-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 6px; background: linear-gradient(90deg, ${colorAccent}, #f5d442, ${colorAccent}); }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: space-between;
    padding: 30px 60px 30px;
  }
  .top-row {
    display: flex; align-items: center; justify-content: center; gap: 18px;
    padding-top: 12px;
  }
  .tournament-badge {
    background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.25);
    border-radius: 40px; padding: 10px 30px;
    font-size: 22px; font-weight: 700; letter-spacing: 3px; text-transform: uppercase;
    color: #f5d442;
  }
  .flag-section {
    display: flex; flex-direction: column; align-items: center; gap: 10px;
    margin-top: -10px;
  }
  .flag-emoji { font-size: 160px; line-height: 1; filter: drop-shadow(0 8px 24px rgba(0,0,0,0.6)); }
  .country-name {
    font-size: 96px; font-weight: 900; letter-spacing: 8px; text-transform: uppercase;
    text-shadow: 0 6px 20px rgba(0,0,0,0.7);
    color: white;
    line-height: 1;
  }
  .team-label {
    font-size: 30px; font-weight: 600; letter-spacing: 6px; text-transform: uppercase;
    color: ${colorAccent}; opacity: 0.9; margin-top: 4px;
  }
  .details-grid {
    display: grid; grid-template-columns: 1fr 1fr; gap: 14px; width: 100%;
    margin-top: 10px;
  }
  .detail-pill {
    background: rgba(255,255,255,0.09); border: 1px solid rgba(255,255,255,0.18);
    border-radius: 14px; padding: 16px 20px;
    display: flex; align-items: center; gap: 12px;
    font-size: 25px; font-weight: 500;
  }
  .detail-pill .icon { font-size: 28px; flex-shrink: 0; }
  .detail-pill .txt { line-height: 1.2; }
  .detail-pill .txt .label { font-size: 16px; opacity: 0.5; font-weight: 400; display: block; margin-bottom: 2px; letter-spacing: 1px; text-transform: uppercase; }
  .open-banner {
    background: linear-gradient(90deg, ${colorPrimary}, ${colorSecondary});
    border: 2px solid ${colorAccent};
    border-radius: 12px; padding: 14px 50px;
    font-size: 28px; font-weight: 800; letter-spacing: 5px; text-transform: uppercase;
    color: white; text-align: center; width: 100%;
  }
  .sponsor-row {
    display: flex; align-items: center; justify-content: center; gap: 24px; width: 100%;
  }
  .logo-wrap {
    width: 80px; height: 80px;
    display: flex; align-items: center; justify-content: center;
  }
  .sponsor-text { text-align: center; }
  .sponsor-text .by { font-size: 17px; opacity: 0.5; letter-spacing: 2px; text-transform: uppercase; }
  .sponsor-text .name { font-size: 26px; font-weight: 800; color: #f5d442; }
  .cta {
    text-align: center; font-size: 24px; color: rgba(255,255,255,0.7);
    letter-spacing: 1px; line-height: 1.6;
  }
  .cta strong { color: #f5d442; font-size: 26px; display: block; }
  .bio-cta {
    background: #f5d442; color: #0a1628;
    border-radius: 12px; padding: 14px 50px;
    font-size: 26px; font-weight: 900; letter-spacing: 3px; text-transform: uppercase;
    text-align: center; width: 100%;
  }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="hex-bg"></div>
  <div class="gold-bar"></div>
  <div class="bottom-bar"></div>
  <div class="content">
    <div class="top-row">
      <div class="tournament-badge">⚽ Philly Grassroots Cup 2026</div>
    </div>
    <div class="flag-section">
      <div class="flag-emoji">${flagEmoji}</div>
      <div class="country-name">${country}</div>
      <div class="team-label">Grassroots Cup Team</div>
    </div>
    <div class="details-grid">
      <div class="detail-pill"><span class="icon">📅</span><span class="txt"><span class="label">Kickoff</span>June 7, 2026</span></div>
      <div class="detail-pill"><span class="icon">🏆</span><span class="txt"><span class="label">Format</span>3-Game Group Stage + Knockouts</span></div>
      <div class="detail-pill"><span class="icon">📍</span><span class="txt"><span class="label">Location</span>Philadelphia, PA</span></div>
      <div class="detail-pill"><span class="icon">🏅</span><span class="txt"><span class="label">Final</span>June 19 · Drexel Vidas Field</span></div>
      ${eligibilityText ? `<div class="detail-pill" style="grid-column:1/-1"><span class="icon">🎯</span><span class="txt"><span class="label">Eligibility</span>${eligibilityText}</span></div>` : ''}
    </div>
    <div class="open-banner">${openBannerText}</div>
    <div class="bio-cta">🔗 Fill out the Interest Form — Link in Bio!</div>
    <div class="sponsor-row">
      <div class="logo-wrap">${welovejunkLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Sponsored By</div>
        <div class="name">We Love Junk</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap" style="width:160px;height:160px;">${complexLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Hosted At</div>
        <div class="name">The Lighthouse Sports &amp; Entertainment Complex</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap">${casaLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">In Partnership With</div>
        <div class="name">CASA Soccer</div>
      </div>
    </div>
  </div>
</div>
</body></html>`;
}

function trialPathwayAdHTML({ lighthouseLogo, welovejunkLogo, complexLogo, casaLogo, apslLogo, openCupLogo, amateurLogo, fifaLogo, epsaLogo, concacafLogo }) {
  const colorPrimary   = '#0D47A1';
  const colorSecondary = '#041D53';
  const colorAccent    = '#F5D442';
  const lighthouseLogoTag = lighthouseLogo ? logoImgTag(lighthouseLogo, '⚓') : '<span style="font-size:60px;">⚓</span>';
  const welovejunkLogoTag = welovejunkLogo ? logoImgTag(welovejunkLogo, '🗑️') : '<span style="font-size:40px;">🗑️</span>';
  const complexLogoTag    = complexLogo    ? logoImgTag(complexLogo,    '🏟️') : '<span style="font-size:40px;">🏟️</span>';
  const casaLogoTag       = casaLogo       ? logoImgTag(casaLogo,       '⚽') : '<span style="font-size:40px;">⚽</span>';
  const casaInline = casaLogo ? `<img src="${logoToDataUri(casaLogo)}" style="height:1.6em;width:1.6em;object-fit:contain;background:white;border-radius:50%;padding:2px;vertical-align:-0.45em;margin-right:8px;box-shadow:0 2px 6px rgba(0,0,0,0.4);">` : '';
  const chipLogo = (p) => p ? `<img src="${logoToDataUri(p)}" style="height:1.6em;width:1.6em;object-fit:contain;background:white;border-radius:50%;padding:2px;vertical-align:-0.45em;margin-right:6px;box-shadow:0 2px 6px rgba(0,0,0,0.4);">` : '';
  const apslInline    = chipLogo(apslLogo);
  const openCupInline = chipLogo(openCupLogo);
  const amateurInline = '<span style="font-size:1.4em;vertical-align:-0.18em;margin-right:6px;">🇺🇸</span>';
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative; overflow: hidden;
    background: linear-gradient(160deg, ${colorPrimary} 0%, #0a1628 55%, ${colorSecondary} 100%);
    color: white;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.04;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 28px 28px;
  }
  .hex-bg {
    position: absolute; top: -80px; right: -80px; width: 500px; height: 500px;
    opacity: 0.08; border-radius: 50%;
    background: radial-gradient(circle, ${colorAccent} 0%, transparent 70%);
  }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, ${colorAccent}, #f5d442, ${colorAccent}); }
  .bottom-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 6px; background: linear-gradient(90deg, ${colorAccent}, #f5d442, ${colorAccent}); }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: space-between;
    padding: 30px 60px 30px;
  }
  .top-row {
    display: flex; align-items: center; justify-content: center; gap: 18px;
    padding-top: 12px;
  }
  .tournament-badge {
    background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.25);
    border-radius: 40px; padding: 10px 30px;
    font-size: 22px; font-weight: 700; letter-spacing: 3px; text-transform: uppercase;
    color: #f5d442;
  }
  .flag-section {
    display: flex; flex-direction: column; align-items: center; gap: 10px;
    margin-top: 22px;
  }
  .crest-wrap { width: 180px; height: 180px; display: flex; align-items: center; justify-content: center; filter: drop-shadow(0 8px 24px rgba(0,0,0,0.6)); }
  .country-name {
    font-size: 96px; font-weight: 900; letter-spacing: 8px; text-transform: uppercase;
    text-shadow: 0 6px 20px rgba(0,0,0,0.7);
    color: white;
    line-height: 1;
    display: flex; align-items: center; justify-content: center; gap: 28px;
  }
  .title-logo { height: 140px; width: auto; max-width: 260px; object-fit: contain; background: white; border-radius: 24px; padding: 14px 22px; box-shadow: 0 6px 20px rgba(0,0,0,0.6); }
  .bodies-row { display: flex; flex-direction: column; align-items: center; gap: 8px; margin: 10px 0 6px; }
  .bodies-label { font-size: 14px; font-weight: 700; letter-spacing: 4px; text-transform: uppercase; color: rgba(255,255,255,0.7); }
  .bodies-logos { display: flex; align-items: center; justify-content: center; gap: 18px; background: rgba(255,255,255,0.95); border-radius: 14px; padding: 10px 22px; box-shadow: 0 4px 14px rgba(0,0,0,0.4); }
  .body-logo { height: 44px; width: auto; max-width: 80px; object-fit: contain; }
  .team-label {
    font-size: 30px; font-weight: 600; letter-spacing: 6px; text-transform: uppercase;
    color: ${colorAccent}; opacity: 0.95; margin-top: 4px;
  }
  .details-grid {
    display: grid; grid-template-columns: 1fr 1fr; gap: 14px; width: 100%;
    margin-top: 10px;
  }
  .detail-pill {
    background: rgba(255,255,255,0.09); border: 1px solid rgba(255,255,255,0.18);
    border-radius: 14px; padding: 16px 20px;
    display: flex; align-items: center; gap: 12px;
    font-size: 25px; font-weight: 500;
  }
  .detail-pill .icon { font-size: 28px; flex-shrink: 0; }
  .detail-pill .txt { line-height: 1.2; }
  .detail-pill .txt .label { font-size: 16px; opacity: 0.5; font-weight: 400; display: block; margin-bottom: 2px; letter-spacing: 1px; text-transform: uppercase; }
  .open-banner {
    background: linear-gradient(90deg, ${colorPrimary}, ${colorSecondary});
    border: 2px solid ${colorAccent};
    border-radius: 12px; padding: 14px 50px;
    font-size: 28px; font-weight: 800; letter-spacing: 5px; text-transform: uppercase;
    color: white; text-align: center; width: 100%;
  }
  .sponsor-row {
    display: flex; align-items: center; justify-content: center; gap: 24px; width: 100%;
  }
  .logo-wrap {
    width: 80px; height: 80px;
    display: flex; align-items: center; justify-content: center;
  }
  .sponsor-text { text-align: center; }
  .sponsor-text .by { font-size: 17px; opacity: 0.5; letter-spacing: 2px; text-transform: uppercase; }
  .sponsor-text .name { font-size: 26px; font-weight: 800; color: #f5d442; }
  .bio-cta {
    background: #f5d442; color: #0a1628;
    border-radius: 12px; padding: 14px 50px;
    font-size: 26px; font-weight: 900; letter-spacing: 3px; text-transform: uppercase;
    text-align: center; width: 100%;
  }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="hex-bg"></div>
  <div class="gold-bar"></div>
  <div class="bottom-bar"></div>
  <div class="content">
    <div class="top-row">
      <div class="tournament-badge">${lighthouseLogo ? `<img src="${logoToDataUri(lighthouseLogo)}" style="height:1.5em;width:1.5em;object-fit:contain;vertical-align:-0.35em;margin-right:8px;">` : ''}Lighthouse 1893 SC · APSL</div>
    </div>
    <div class="flag-section">
      <div class="crest-wrap">${lighthouseLogoTag}</div>
      <div class="country-name">${apslLogo ? `<img class="title-logo" src="${logoToDataUri(apslLogo)}">` : ''}<span>TRIALS</span></div>
      <div class="team-label">APSL 1st Team &amp; APSL Reserves</div>
    </div>
    <div class="details-grid">
      <div class="detail-pill" style="grid-column:1/-1"><span class="txt" style="width:100%"><span class="label">June &amp; July</span>${casaInline}CASA U23 Premier League · Grassroots Cup (<span style="font-size:1.3em;vertical-align:-0.12em;">🇧🇷</span> Brazil or <span style="font-size:1.3em;vertical-align:-0.12em;">🇵🇷</span> Puerto Rico)</span></div>
      <div class="detail-pill"><span class="txt" style="width:100%"><span class="label">August</span>Roster Selection for: ${openCupInline}US Open Cup · ${amateurInline}US Amateur Cup · ${apslInline}APSL · Friendlies</span></div>
      <div class="detail-pill"><span class="txt" style="width:100%"><span class="label">September</span>${apslInline}APSL Season Begins · ${openCupInline}US Open Cup &amp; ${amateurInline}US Amateur Cup Local Qualifiers</span></div>
    </div>
    <div class="open-banner">Play U23, Grassroots &amp; Friendlies RIGHT NOW · Get Evaluated for APSL</div>
    <div class="bodies-row">
      <div class="bodies-label">Officially Affiliated With</div>
      <div class="bodies-logos">
        ${fifaLogo ? `<img src="${logoToDataUri(fifaLogo)}" class="body-logo">` : ''}
        ${concacafLogo ? `<img src="${logoToDataUri(concacafLogo)}" class="body-logo">` : ''}
        ${amateurLogo ? `<img src="${logoToDataUri(amateurLogo)}" class="body-logo">` : ''}
        ${openCupLogo ? `<img src="${logoToDataUri(openCupLogo)}" class="body-logo">` : ''}
        ${epsaLogo ? `<img src="${logoToDataUri(epsaLogo)}" class="body-logo">` : ''}
        ${apslLogo ? `<img src="${logoToDataUri(apslLogo)}" class="body-logo">` : ''}
        ${casaLogo ? `<img src="${logoToDataUri(casaLogo)}" class="body-logo">` : ''}
      </div>
    </div>
    <div class="sponsor-row">
      <div class="logo-wrap">${welovejunkLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Sponsored By</div>
        <div class="name">We Love Junk</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap" style="width:160px;height:160px;">${complexLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Home Games At</div>
        <div class="name">The Lighthouse Sports &amp; Entertainment Complex</div>
      </div>
    </div>
  </div>
</div>
</body></html>`;
}

function u23AdHTML({ division, teamName = 'Lighthouse Boys Club U23', colorPrimary, colorSecondary, lighthouseLogo, welovejunkLogo, complexLogo, casaLogo, ctaLink = 'linktr.ee/Lighthouse1893Soccer', eligibilityText = 'Open to All Players', firstMatch = 'May 31, 2026' }) {
  const lighthouseLogoTag = lighthouseLogo ? logoImgTag(lighthouseLogo, '⚓') : '<span style="font-size:60px;">⚓</span>';
  const welovejunkLogoTag = welovejunkLogo ? logoImgTag(welovejunkLogo, '🗑️') : '<span style="font-size:40px;">🗑️</span>';
  const complexLogoTag = complexLogo ? logoImgTag(complexLogo, '🏟️') : '<span style="font-size:40px;">🏟️</span>';
  const casaLogoTag = casaLogo ? logoImgTag(casaLogo, '⚽') : '<span style="font-size:40px;">⚽</span>';
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative; overflow: hidden;
    background: linear-gradient(160deg, ${colorPrimary} 0%, #0a1628 55%, ${colorSecondary} 100%);
    color: white;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.04;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 28px 28px;
  }
  .glow { position: absolute; top: -60px; right: -60px; width: 450px; height: 450px; opacity: 0.1; border-radius: 50%; background: radial-gradient(circle, #ffffff 0%, transparent 70%); }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, ${colorPrimary}, #f5d442, ${colorSecondary}); }
  .bottom-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 6px; background: linear-gradient(90deg, ${colorPrimary}, #f5d442, ${colorSecondary}); }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: space-between;
    padding: 30px 60px 30px;
  }
  .casa-badge {
    background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.25);
    border-radius: 40px; padding: 10px 30px; margin-top: 12px;
    font-size: 22px; font-weight: 700; letter-spacing: 3px; text-transform: uppercase;
    color: #f5d442;
  }
  .main-section { display: flex; flex-direction: column; align-items: center; gap: 12px; }
  .emoji-icon { font-size: 100px; line-height: 1; }
  .division-label {
    font-size: 30px; font-weight: 700; letter-spacing: 6px; text-transform: uppercase;
    color: rgba(255,255,255,0.6);
  }
  .team-name {
    font-size: 88px; font-weight: 900; letter-spacing: 6px; text-transform: uppercase;
    text-shadow: 0 6px 20px rgba(0,0,0,0.7); color: white; line-height: 1; text-align: center;
  }
  .sub-name {
    font-size: 42px; font-weight: 700; letter-spacing: 5px; color: #f5d442;
    text-align: center;
  }
  .details-grid {
    display: grid; grid-template-columns: 1fr 1fr; gap: 14px; width: 100%;
  }
  .detail-pill {
    background: rgba(255,255,255,0.09); border: 1px solid rgba(255,255,255,0.18);
    border-radius: 14px; padding: 16px 20px;
    display: flex; align-items: center; gap: 12px; font-size: 25px; font-weight: 500;
  }
  .detail-pill .icon { font-size: 28px; flex-shrink: 0; }
  .detail-pill .txt .label { font-size: 16px; opacity: 0.5; font-weight: 400; display: block; margin-bottom: 2px; letter-spacing: 1px; text-transform: uppercase; }
  .open-banner {
    background: rgba(255,255,255,0.1); border: 2px solid #f5d442;
    border-radius: 12px; padding: 14px 50px;
    font-size: 28px; font-weight: 800; letter-spacing: 5px; text-transform: uppercase;
    color: white; text-align: center; width: 100%;
  }
  .sponsor-row { display: flex; align-items: center; justify-content: center; gap: 24px; }
  .logo-wrap { width: 80px; height: 80px; display: flex; align-items: center; justify-content: center; }
  .sponsor-text .by { font-size: 17px; opacity: 0.5; letter-spacing: 2px; text-transform: uppercase; }
  .sponsor-text .name { font-size: 26px; font-weight: 800; color: #f5d442; }
  .cta { text-align: center; }
  .cta-action { font-size: 26px; font-weight: 800; color: rgba(255,255,255,0.9); letter-spacing: 1px; margin-bottom: 10px; }
  .bio-cta {
    background: #f5d442; color: #0a1628;
    border-radius: 12px; padding: 14px 50px;
    font-size: 26px; font-weight: 900; letter-spacing: 3px; text-transform: uppercase;
    text-align: center; width: 100%;
  }
  .cta-link-box {
    display: inline-block;
    background: #f5d442;
    color: #0a1628;
    font-size: 28px;
    font-weight: 900;
    letter-spacing: 2px;
    padding: 14px 40px;
    border-radius: 10px;
    text-transform: uppercase;
  }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="glow"></div>
  <div class="gold-bar"></div>
  <div class="bottom-bar"></div>
  <div class="content">
    <div class="casa-badge" style="display:flex;align-items:center;gap:12px;"><span style="width:36px;height:36px;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;">${casaLogoTag}</span>⚽ CASA U23 ${division} Premier League</div>
    <div class="main-section">
      <div class="division-label">Now Forming</div>
      <div class="team-name">U23</div>
      <div class="sub-name">${division} Team</div>
    </div>
    <div class="details-grid">
      <div class="detail-pill"><span class="icon">📅</span><span class="txt"><span class="label">First Match</span>${firstMatch}</span></div>
      <div class="detail-pill"><span class="icon">🏆</span><span class="txt"><span class="label">League</span>CASA U23 ${division} Premier League</span></div>
      <div class="detail-pill"><span class="icon">📍</span><span class="txt"><span class="label">Location</span>Philadelphia, PA</span></div>
      <div class="detail-pill"><span class="icon">🎯</span><span class="txt"><span class="label">Eligibility</span>${eligibilityText}</span></div>
    </div>
    <div class="open-banner">🌟 Open to All Players — Spots Available!</div>

    <div class="sponsor-row">
      <div class="logo-wrap">${welovejunkLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Sponsored By</div>
        <div class="name">We Love Junk</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap" style="width:160px;height:160px;">${complexLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Home Games At</div>
        <div class="name">The Lighthouse Sports &amp; Entertainment Complex</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap">${lighthouseLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Team</div>
        <div class="name">${teamName}</div>
      </div>
    </div>
  </div>
</div>
</body></html>`;
}

function u23FlyerHTML({ division, teamName = 'Lighthouse Boys Club U23', colorPrimary, colorSecondary, lighthouseLogo, welovejunkLogo, complexLogo, casaLogo, ctaUrl = 'tr.ee/hSxfHUV4jR', eligibilityText = 'Open to All Players', firstMatch = 'May 31, 2026' }) {
  const lighthouseLogoTag = lighthouseLogo ? logoImgTag(lighthouseLogo, '⚓') : '<span style="font-size:60px;">⚓</span>';
  const welovejunkLogoTag = welovejunkLogo ? logoImgTag(welovejunkLogo, '🗑️') : '<span style="font-size:40px;">🗑️</span>';
  const complexLogoTag = complexLogo ? logoImgTag(complexLogo, '🏟️') : '<span style="font-size:40px;">🏟️</span>';
  const casaLogoTag = casaLogo ? logoImgTag(casaLogo, '⚽') : '<span style="font-size:40px;">⚽</span>';
  const qrImgUrl = `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent('https://' + ctaUrl)}&format=png`;
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1080px; height: 1080px; overflow: hidden; font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; }
  .card {
    width: 1080px; height: 1080px; position: relative; overflow: hidden;
    background: linear-gradient(160deg, ${colorPrimary} 0%, #0a1628 55%, ${colorSecondary} 100%);
    color: white;
  }
  .pattern {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.04;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 28px 28px;
  }
  .glow { position: absolute; top: -60px; right: -60px; width: 450px; height: 450px; opacity: 0.1; border-radius: 50%; background: radial-gradient(circle, #ffffff 0%, transparent 70%); }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, ${colorPrimary}, #f5d442, ${colorSecondary}); }
  .bottom-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 6px; background: linear-gradient(90deg, ${colorPrimary}, #f5d442, ${colorSecondary}); }
  .content {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: space-between;
    padding: 28px 60px 28px;
  }
  .casa-badge {
    background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.25);
    border-radius: 40px; padding: 10px 30px; margin-top: 12px;
    font-size: 22px; font-weight: 700; letter-spacing: 3px; text-transform: uppercase;
    color: #f5d442;
  }
  .main-section { display: flex; flex-direction: column; align-items: center; gap: 10px; }
  .division-label { font-size: 28px; font-weight: 700; letter-spacing: 6px; text-transform: uppercase; color: rgba(255,255,255,0.6); }
  .team-name { font-size: 84px; font-weight: 900; letter-spacing: 6px; text-transform: uppercase; text-shadow: 0 6px 20px rgba(0,0,0,0.7); color: white; line-height: 1; text-align: center; }
  .sub-name { font-size: 40px; font-weight: 700; letter-spacing: 5px; color: #f5d442; text-align: center; }
  .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; width: 100%; }
  .detail-pill {
    background: rgba(255,255,255,0.09); border: 1px solid rgba(255,255,255,0.18);
    border-radius: 14px; padding: 14px 18px;
    display: flex; align-items: center; gap: 12px; font-size: 23px; font-weight: 500;
  }
  .detail-pill .icon { font-size: 26px; flex-shrink: 0; }
  .detail-pill .txt .label { font-size: 14px; opacity: 0.5; font-weight: 400; display: block; margin-bottom: 2px; letter-spacing: 1px; text-transform: uppercase; }
  .open-banner {
    background: rgba(255,255,255,0.1); border: 2px solid #f5d442;
    border-radius: 12px; padding: 12px 40px;
    font-size: 26px; font-weight: 800; letter-spacing: 4px; text-transform: uppercase;
    color: white; text-align: center; width: 100%;
  }
  .qr-section {
    background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.2);
    border-radius: 16px; padding: 18px 36px;
    display: flex; align-items: center; gap: 28px; width: 100%;
  }
  .qr-img { background: white; padding: 10px; border-radius: 10px; flex-shrink: 0; }
  .qr-text .heading { font-size: 26px; font-weight: 800; margin-bottom: 6px; }
  .qr-text .url { font-size: 20px; opacity: 0.7; }
  .qr-text .note { font-size: 17px; opacity: 0.5; margin-top: 4px; }
  .sponsor-row { display: flex; align-items: center; justify-content: center; gap: 24px; }
  .logo-wrap { width: 80px; height: 80px; display: flex; align-items: center; justify-content: center; }
  .sponsor-text .by { font-size: 17px; opacity: 0.5; letter-spacing: 2px; text-transform: uppercase; }
  .sponsor-text .name { font-size: 24px; font-weight: 800; color: #f5d442; }
</style>
</head><body>
<div class="card">
  <div class="pattern"></div>
  <div class="glow"></div>
  <div class="gold-bar"></div>
  <div class="bottom-bar"></div>
  <div class="content">
    <div class="casa-badge" style="display:flex;align-items:center;gap:12px;"><span style="width:36px;height:36px;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;">${casaLogoTag}</span>⚽ CASA U23 ${division} Premier League</div>
    <div class="main-section">
      <div class="division-label">Now Forming</div>
      <div class="team-name">U23</div>
      <div class="sub-name">${division} Team</div>
    </div>
    <div class="details-grid">
      <div class="detail-pill"><span class="icon">📅</span><span class="txt"><span class="label">First Match</span>${firstMatch}</span></div>
      <div class="detail-pill"><span class="icon">🏆</span><span class="txt"><span class="label">League</span>CASA U23 ${division} Premier League</span></div>
      <div class="detail-pill"><span class="icon">📍</span><span class="txt"><span class="label">Location</span>Philadelphia, PA</span></div>
      <div class="detail-pill"><span class="icon">🎯</span><span class="txt"><span class="label">Eligibility</span>${eligibilityText}</span></div>
    </div>
    <div class="open-banner">🌟 Open to All Players — Spots Available!</div>
    <div class="qr-section">
      <img class="qr-img" src="${qrImgUrl}" width="220" height="220">
      <div class="qr-text">
        <div class="heading">📲 Scan to Fill Out the Interest Form</div>
        <div class="url">Or visit: ${ctaUrl}</div>
        <div class="note">Free to join · All skill levels welcome</div>
      </div>
    </div>
    <div class="sponsor-row">
      <div class="logo-wrap">${welovejunkLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Sponsored By</div>
        <div class="name">We Love Junk</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap" style="width:160px;height:160px;">${complexLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Home Games At</div>
        <div class="name">The Lighthouse Sports &amp; Entertainment Complex</div>
      </div>
      <div style="width:1px;height:48px;background:rgba(255,255,255,0.25);margin:0 4px;"></div>
      <div class="logo-wrap">${lighthouseLogoTag}</div>
      <div class="sponsor-text">
        <div class="by">Team</div>
        <div class="name">${teamName}</div>
      </div>
    </div>
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

async function generateCard(type, data = {}) {
  const fixedFilename = data.filename;
  let html;
  if (type === 'match-result' || type === 'post_game') {
    html = matchResultHTML(data);
  } else if (type === 'match-announcement' || type === 'pre_match_announcement') {
    html = matchAnnouncementHTML(data);
  } else if (type === 'game_day') {
    html = gameDayHTML(data);
  } else if (type === 'lineup') {
    html = lineupHTML(data);
  } else if (type === 'grassroots-cup-ad') {
    html = grassrootsCupAdHTML(data);
  } else if (type === 'trial-pathway-ad') {
    html = trialPathwayAdHTML(data);
  } else if (type === 'u23-ad') {
    html = u23AdHTML(data);
  } else if (type === 'u23-flyer') {
    html = u23FlyerHTML(data);
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

  const filename = fixedFilename || `${type}-${Date.now()}.png`;
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

  } else if (type === 'grassroots-brazil') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const { filepath, filename } = await generateCard('grassroots-cup-ad', {
      country: 'Brazil', flagEmoji: '🇧🇷',
      colorPrimary: '#009C3B', colorSecondary: '#002776', colorAccent: '#FFDF00',
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo,
      openBannerText: '🌎 You Do Not Have To Be Brazilian — Spots Are Limited!',
      eligibilityText: 'Ages 16+',
      filename: 'grassroots-cup-ad-brazil.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else if (type === 'trial-pathway') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const apslLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'apsl.png');
    const openCupLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'us-open-cup.png');
    const amateurLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'ussoccer.png');
    const fifaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'fifa.png');
    const epsaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'epsa.png');
    const concacafLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'concacaf.png');
    const { filepath, filename } = await generateCard('trial-pathway-ad', {
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo, apslLogo, openCupLogo, amateurLogo, fifaLogo, epsaLogo, concacafLogo,
      filename: 'trial-pathway-ad.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else if (type === 'grassroots-puertorico') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const { filepath, filename } = await generateCard('grassroots-cup-ad', {
      country: 'Puerto Rico', flagEmoji: '🇵🇷',
      colorPrimary: '#ED0000', colorSecondary: '#0023A0', colorAccent: '#ffffff',
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo,
      openBannerText: '🌎 You Do Not Have To Be Puerto Rican — Spots Are Limited!',
      eligibilityText: 'Ages 16+',
      filename: 'grassroots-cup-ad-puertorico.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else if (type === 'u23-mens') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const { filepath, filename } = await generateCard('u23-ad', {
      division: "Men's",
      colorPrimary: '#1565C0', colorSecondary: '#0D47A1',
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo,
      eligibilityText: 'Ages 16–25 Welcome',
      ctaLink: 'tr.ee/hSxfHUV4jR',
      firstMatch: 'May 31, 2026',
      filename: 'u23-ad-mens.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else if (type === 'u23-womens') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const { filepath, filename } = await generateCard('u23-ad', {
      division: "Women's",
      colorPrimary: '#1565C0', colorSecondary: '#0D47A1',
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo,
      eligibilityText: 'Ages 16–23 Welcome',
      teamName: "Lighthouse Women's Club U23",
      firstMatch: 'May 31, 2026',
      filename: 'u23-ad-womens.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else if (type === 'u23-womens-flyer') {
    const lighthouseLogo = findLogo('lighthouse-1893');
    const welovejunkLogo = path.join(__dirname, 'frontend', 'images', 'sponsors', 'welovejunk_logo.png');
    const complexLogo = path.join(__dirname, 'frontend', 'images', 'lighthouse-complex.png');
    const casaLogo = path.join(__dirname, 'frontend', 'images', 'leagues', 'casa.png');
    const { filepath, filename } = await generateCard('u23-flyer', {
      division: "Women's",
      colorPrimary: '#1565C0', colorSecondary: '#0D47A1',
      lighthouseLogo, welovejunkLogo, complexLogo, casaLogo,
      eligibilityText: 'Ages 16–25 Welcome',
      teamName: "Lighthouse Women's Club U23",
      firstMatch: 'May 31, 2026',
      ctaUrl: 'tr.ee/hSxfHUV4jR',
      filename: 'u23-flyer-womens.png',
    });
    console.log(`\nImage saved: ${filepath}`);
    console.log(`Public URL:  https://footballhome.org/images/posts/${filename}`);

  } else {
    console.log(`Match Card Generator

Usage:
  node generate-match-card.js match-result <home> <away> <score_h> <score_a> <league> <date> <time> <venue>
  node generate-match-card.js match-announcement <home> <away> <league> <date> <time> <venue>
  node generate-match-card.js grassroots-brazil
  node generate-match-card.js grassroots-puertorico
  node generate-match-card.js u23-mens
  node generate-match-card.js u23-womens
  node generate-match-card.js u23-womens-flyer

Example:
  node generate-match-card.js match-result "Lighthouse 1893 SC" "Sewell Old Boys FC" 1 3 "APSL" "March 29, 2026" "5:30 PM" "Northeast High School"
`);
  }
}

module.exports = { generateCard, findLogo, matchResultHTML, matchAnnouncementHTML, gameDayHTML, lineupHTML, grassrootsCupAdHTML, u23AdHTML, u23FlyerHTML, POSTS_DIR };
main();
