#!/usr/bin/env node
/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * APSL DOB Scraper
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *
 * Logs in to app.teampass.com with the Lighthouse team manager account
 * and scrapes DOBs from the authenticated team roster management page.
 *
 * Credentials loaded from apsl-credentials.conf (decrypted from .age at setup).
 *
 * Usage (must run via VPN wrapper — apslsoccer.com blocks our IP):
 *   VPN_ACTIVE=1 node database/scripts/scrapers/ApslDobScraper.js
 *   # Or via the shell wrapper:
 *   database/scripts/leagues/north-america/usa/apsl/scrape-dobs.sh
 *
 * Output:
 *   database/scraped-html/apsl/apsl-dobs-116079.json   (team 116079 DOBs)
 *   database/scraped-html/apsl/apsl-dobs-116136.json   (reserves DOBs)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const fs = require('fs');
const path = require('path');

const CACHE_DIR = path.join(__dirname, '../../scraped-html/apsl');
const CREDENTIALS_FILE = path.join(__dirname, '../../../apsl-credentials.conf');

// Lighthouse team IDs on APSL
const LIGHTHOUSE_TEAM_IDS = ['116079', '116136'];

/**
 * Load APSL credentials from apsl-credentials.conf
 */
function loadCredentials() {
  if (!fs.existsSync(CREDENTIALS_FILE)) {
    throw new Error(
      `apsl-credentials.conf not found at ${CREDENTIALS_FILE}\n` +
      'Run setup.sh to decrypt apsl-credentials.conf.age'
    );
  }
  const content = fs.readFileSync(CREDENTIALS_FILE, 'utf8');
  const email = content.match(/^APSL_EMAIL=(.+)$/m)?.[1]?.trim();
  const password = content.match(/^APSL_PASSWORD=(.+)$/m)?.[1]?.trim();
  if (!email || !password) throw new Error('APSL_EMAIL or APSL_PASSWORD missing from apsl-credentials.conf');
  return { email, password };
}

/**
 * Delay helper
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Parse a DOB string in MM/DD/YY or MM/DD/YYYY format to ISO YYYY-MM-DD.
 * Returns null if invalid or birth year outside 1950–2010.
 */
function parseDob(raw) {
  if (!raw) return null;
  const s = String(raw).trim();
  const parts = s.split('/');
  if (parts.length !== 3) return null;

  let [month, day, year] = parts.map(Number);
  if (isNaN(month) || isNaN(day) || isNaN(year)) return null;

  // Expand two-digit year: 50–99 → 1950–1999, 0–10 → 2000–2010
  if (year < 100) {
    year = year >= 50 ? 1900 + year : 2000 + year;
  }

  if (year < 1950 || year > 2010) return null;
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > 31) return null;

  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

async function scrapeTeamDobs(page, teamId) {
  const teamUrl = `https://app.teampass.com/APSL/Team/${teamId}`;
  console.log(`   🌐 Fetching: ${teamUrl}`);

  await page.goto(teamUrl, { waitUntil: 'networkidle2', timeout: 30000 });
  const finalUrl = page.url();
  console.log(`   📍 Final URL: ${finalUrl}`);

  // Check if redirected to login or home
  if (!finalUrl.includes(`/Team/${teamId}`)) {
    console.log(`   ⚠️  Redirected away — not authenticated or team not found`);
    return null;
  }

  // Extract player names and DOBs from the team roster page.
  // Structure:
  //   Player name: <div style="font-size:12px;line-height:1;">FIRST LAST</div>
  //   DOB: <td>\n  M/D/YY\n  <br>\n  Age:XX\n</td>
  //   Player ID in edit button class: Coach_Edit_Player_XXXXXXX_Button
  const players = await page.evaluate(() => {
    const results = [];

    // Find all player rows — each has an edit button with Coach_Edit_Player_XXXXXX_Button
    const editButtons = document.querySelectorAll('i[class*="Coach_Edit_Player_"]');

    for (const btn of editButtons) {
      // Extract player ID from class name
      const classMatch = btn.className.match(/Coach_Edit_Player_(\d+)_Button/);
      const playerId = classMatch ? classMatch[1] : null;

      // Walk up to the containing <td>, then to the <tr>
      let td = btn.closest('td');
      if (!td) continue;
      const tr = td.closest('tr');
      if (!tr) continue;

      // Player name: find the font-size:12px div in this row
      const nameDiv = tr.querySelector('div[style*="font-size:12px"]');
      const fullName = nameDiv ? nameDiv.textContent.trim() : null;

      // DOB: find the <td> that contains "Age:" text
      let dob = null;
      const tds = tr.querySelectorAll('td');
      for (const cell of tds) {
        const text = cell.innerText || cell.textContent;
        if (text && /Age:\d+/i.test(text)) {
          // DOB is the text before the <br>/Age: part
          const dobMatch = text.trim().match(/^(\d{1,2}\/\d{1,2}\/\d{2,4})/);
          if (dobMatch) {
            dob = dobMatch[1];
          }
          break;
        }
      }

      if (fullName && dob) {
        results.push({ fullName, dob, playerId });
      }
    }

    return results;
  });

  console.log(`   Found ${players.length} players with DOBs`);
  if (players.length > 0) {
    console.log(`   Sample: ${JSON.stringify(players[0])}`);
  } else {
    // Save debug HTML
    const html = await page.content();
    const debugPath = path.join(CACHE_DIR, `apsl-dobs-debug-${teamId}.html`);
    fs.writeFileSync(debugPath, html);
    console.log(`   💾 Saved debug HTML: ${path.basename(debugPath)}`);
  }

  return players.length > 0 ? players : null;
}

async function main() {
  const credentials = loadCredentials();
  console.log(`📧 Using account: ${credentials.email}`);

  const puppeteer = require('puppeteer-extra');
  const StealthPlugin = require('puppeteer-extra-plugin-stealth');
  puppeteer.use(StealthPlugin());

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 900 });

    // ── Step 1: Navigate to the TeamPass login page ──
    console.log('\n🔐 Logging in to APSL TeamPass...');
    await page.goto('https://app.teampass.com/reg/login/', {
      waitUntil: 'networkidle2',
      timeout: 30000
    });
    console.log(`   Login page: ${page.url()}`);

    // ── Step 2: Fill and submit the login form ──
    const loginFound = await page.evaluate((email, password) => {
      const emailInput = document.querySelector('#form_Login_UserName, input[name="form_Login_UserName"]');
      const passwordInput = document.querySelector('#form_Login_Password, input[name="form_Login_Password"]');
      if (!emailInput || !passwordInput) return false;
      emailInput.value = email;
      emailInput.dispatchEvent(new Event('input', { bubbles: true }));
      emailInput.dispatchEvent(new Event('change', { bubbles: true }));
      passwordInput.value = password;
      passwordInput.dispatchEvent(new Event('input', { bubbles: true }));
      passwordInput.dispatchEvent(new Event('change', { bubbles: true }));
      return true;
    }, credentials.email, credentials.password);

    if (!loginFound) {
      console.log('   ⚠️  Could not find login form fields');
      const html = await page.content();
      fs.writeFileSync(path.join(CACHE_DIR, 'apsl-login-debug.html'), html);
      console.log('   💾 Saved debug HTML for inspection');
      return;
    }

    // Submit login form
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 20000 }).catch(() => {}),
      page.evaluate(() => {
        const btn = document.querySelector('input[type="submit"], button[type="submit"]');
        if (btn) btn.click();
        else document.querySelector('form')?.submit();
      })
    ]);

    const afterLoginUrl = page.url();
    console.log(`   After login URL: ${afterLoginUrl}`);

    // Check if login succeeded (redirected away from login page)
    if (afterLoginUrl.includes('/reg/login/') || afterLoginUrl.includes('login')) {
      // May have shown an error — check page text
      const errorText = await page.evaluate(() => document.body.innerText.slice(0, 300));
      console.log('   ⚠️  May still be on login page. Page text:', errorText.replace(/\n/g, ' '));
    }

    // ── Step 3: Scrape each Lighthouse team ──
    const allResults = {};

    for (const teamId of LIGHTHOUSE_TEAM_IDS) {
      console.log(`\n📋 Team ${teamId}...`);
      await delay(2000 + Math.random() * 2000);

      const players = await scrapeTeamDobs(page, teamId);
      if (players) {
        allResults[teamId] = players;
      }
    }

    // ── Step 4: Save results ──
    for (const [teamId, players] of Object.entries(allResults)) {
      const outPath = path.join(CACHE_DIR, `apsl-dobs-${teamId}.json`);
      const output = players.map(p => {
        // Parse name — "First Last" or "Last, First"
        let firstName = '', lastName = '';
        if (p.fullName.includes(',')) {
          const parts = p.fullName.split(',').map(s => s.trim());
          lastName = parts[0];
          firstName = parts[1] || '';
        } else {
          const parts = p.fullName.trim().split(/\s+/);
          firstName = parts[0];
          lastName = parts.slice(1).join(' ');
        }
        return {
          firstName,
          lastName,
          dateOfBirth: parseDob(p.dob),
          teamPassPlayerId: p.playerId || null
        };
      }).filter(p => p.firstName && p.lastName && p.dateOfBirth);

      fs.writeFileSync(outPath, JSON.stringify(output, null, 2));
      console.log(`\n✅ Team ${teamId}: ${output.length} players with DOBs → ${path.basename(outPath)}`);
    }

    if (Object.keys(allResults).length === 0) {
      console.log('\n⚠️  No DOB data collected. Check debug HTML files in database/scraped-html/apsl/');
    }

  } finally {
    await browser.close();
  }
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
