#!/usr/bin/env node
/**
 * GroupMe Calendar Scraper - Extract RSVPs from GroupMe calendar events using browser automation
 * 
 * This script uses Puppeteer to scrape calendar event RSVPs that aren't available through
 * the GroupMe API. This is essential for migrating from GroupMe to Football Home.
 * 
 * Usage:
 *   node scripts/groupme-calendar-scraper.js <group_id> <event_id>
 *   node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd
 * 
 * First run will open browser for login, subsequent runs reuse saved session.
 */

require('dotenv').config();
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());
const fs = require('fs');
const path = require('path');

const COOKIES_FILE = path.join(__dirname, '../.groupme-cookies.json');
const GROUPME_EMAIL = process.env.GROUPME_EMAIL;
const GROUPME_PASSWORD = process.env.GROUPME_PASSWORD;

// Check for login credentials
if (!GROUPME_EMAIL || !GROUPME_PASSWORD) {
  console.log('⚠️  Warning: GROUPME_EMAIL and GROUPME_PASSWORD not set in .env');
  console.log('   First run will require manual login in the browser window.');
  console.log('   Add credentials to .env for automated login:');
  console.log('   GROUPME_EMAIL=your-email@example.com');
  console.log('   GROUPME_PASSWORD=your-password');
  console.log('');
}

async function login(page) {
  console.log('🔐 Logging into GroupMe...');
  
  await page.goto('https://web.groupme.com/signin', { waitUntil: 'networkidle2' });
  
  // Check if we need to login or if cookies worked
  const currentUrl = page.url();
  if (currentUrl.includes('/chats') || currentUrl.includes('/groups')) {
    console.log('✅ Already logged in (using saved session)');
    return;
  }
  
  // Try automated login if credentials provided
  if (GROUPME_EMAIL && GROUPME_PASSWORD) {
    try {
      console.log('   Entering credentials...');
      await page.waitForSelector('input[name="email"], input[type="email"]', { timeout: 10000 });
      await page.type('input[name="email"], input[type="email"]', GROUPME_EMAIL);
      await page.type('input[name="password"], input[type="password"]', GROUPME_PASSWORD);
      
      // Click sign in button
      await page.click('button[type="submit"]');
      
      // Wait for redirect after login
      await page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 15000 });
      
      console.log('✅ Logged in successfully');
    } catch (error) {
      console.log('⚠️  Automated login failed, may need manual intervention');
      console.log('   Browser will stay open for 60 seconds - please login manually if needed');
      await new Promise(r => setTimeout(r, 60000));
    }
  } else {
    // Manual login required
    console.log('⏳ Please login manually in the browser window...');
    console.log('   Waiting up to 60 seconds...');
    
    // Wait for navigation to chats page (indicates successful login)
    try {
      await page.waitForFunction(
        () => window.location.href.includes('/chats') || window.location.href.includes('/groups'),
        { timeout: 60000 }
      );
      console.log('✅ Login detected');
    } catch (error) {
      throw new Error('Login timeout - please try again');
    }
  }
  
  // Save cookies for future runs
  const cookies = await page.cookies();
  fs.writeFileSync(COOKIES_FILE, JSON.stringify(cookies, null, 2));
  console.log('💾 Session saved for future runs');
}

async function scrapeEventRSVPs(groupId, eventId) {
  console.log('🚀 GroupMe Calendar Scraper\n');
  console.log(`Group ID: ${groupId}`);
  console.log(`Event ID: ${eventId}\n`);
  
  // Determine if we can show browser (has DISPLAY set)
  const hasDisplay = !!process.env.DISPLAY;
  const headless = !hasDisplay;
  
  if (headless) {
    console.log('ℹ️  Running in headless mode (no display available)');
    if (!fs.existsSync(COOKIES_FILE)) {
      console.log('⚠️  Warning: No saved session found!');
      console.log('   Headless mode requires saved cookies from a previous login.');
      console.log('   Run this script on a machine with a display first, or manually');
      console.log('   create .groupme-cookies.json with valid session cookies.');
      console.log('');
    }
  }
  
  const browser = await puppeteer.launch({
    headless: headless,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  
  const page = await browser.newPage();
  
  try {
    // Load saved cookies if they exist
    if (fs.existsSync(COOKIES_FILE)) {
      console.log('📂 Loading saved session...');
      const cookies = JSON.parse(fs.readFileSync(COOKIES_FILE));
      await page.setCookie(...cookies);
    }
    
    // Login (will skip if cookies work)
    await login(page);
    
    // Navigate to the event page
    const eventUrl = `https://web.groupme.com/join_event/${groupId}/${eventId}`;
    console.log(`\n📅 Navigating to event: ${eventUrl}`);
    await page.goto(eventUrl, { waitUntil: 'networkidle2', timeout: 30000 });
    
    // Wait a bit for dynamic content to load
    console.log('⏳ Waiting for event details to load...');
    try {
      // Wait for a generic container that likely holds the RSVP info
      // We'll wait for the body to be fully populated
      await page.waitForSelector('body', { timeout: 10000 });
      await new Promise(r => setTimeout(r, 5000)); // Extra wait for JS rendering
    } catch (e) {
      console.log('⚠️  Wait timed out, proceeding anyway...');
    }
    
    // Save HTML for debugging
    const html = await page.content();
    fs.writeFileSync('debug-groupme-event.html', html);
    console.log('📸 Saved page HTML to debug-groupme-event.html');
    
    // Take screenshot for debugging
    await page.screenshot({ path: 'groupme-event.png', fullPage: true });
    console.log('📸 Screenshot saved to groupme-event.png');
    
    // Extract RSVP data from the page
    console.log('\n🔍 Extracting RSVP data...');
    
    const rsvpData = await page.evaluate(() => {
      const results = {
        going: [],
        maybe: [],
        not_going: [],
        no_response: []
      };
      
      // Try multiple possible selectors for GroupMe's event RSVP UI
      // GroupMe's DOM structure may vary, so we'll try different patterns
      
      // Pattern 1: Look for sections with data-rsvp-status attributes
      const rsvpSections = document.querySelectorAll('[data-rsvp-status], .rsvp-section, .event-rsvps');
      
      rsvpSections.forEach(section => {
        const status = section.getAttribute('data-rsvp-status') || 
                      section.className.match(/going|maybe|not-going|no-response/)?.[0];
        
        const names = Array.from(section.querySelectorAll('.member-name, .user-name, .name'))
          .map(el => el.textContent.trim())
          .filter(name => name.length > 0);
        
        if (status && names.length > 0) {
          if (status.includes('going') && !status.includes('not')) {
            results.going.push(...names);
          } else if (status.includes('maybe')) {
            results.maybe.push(...names);
          } else if (status.includes('not')) {
            results.not_going.push(...names);
          } else if (status.includes('no-response')) {
            results.no_response.push(...names);
          }
        }
      });
      
      // Pattern 2: Look for text labels "Going", "Maybe", "Not Going"
      const headings = Array.from(document.querySelectorAll('h3, h4, .heading, .section-title'));
      
      headings.forEach(heading => {
        const text = heading.textContent.toLowerCase();
        let targetArray = null;
        
        if (text.includes('going') && !text.includes('not')) {
          targetArray = results.going;
        } else if (text.includes('maybe')) {
          targetArray = results.maybe;
        } else if (text.includes('not going')) {
          targetArray = results.not_going;
        }
        
        if (targetArray) {
          // Find sibling or parent container with member names
          let container = heading.nextElementSibling;
          if (!container) container = heading.parentElement?.nextElementSibling;
          
          if (container) {
            const names = Array.from(container.querySelectorAll('.member-name, .user-name, .name, li'))
              .map(el => el.textContent.trim())
              .filter(name => name.length > 0 && !name.toLowerCase().includes('going') && !name.toLowerCase().includes('maybe'));
            
            targetArray.push(...names);
          }
        }
      });
      
      // Deduplicate
      results.going = [...new Set(results.going)];
      results.maybe = [...new Set(results.maybe)];
      results.not_going = [...new Set(results.not_going)];
      results.no_response = [...new Set(results.no_response)];
      
      return results;
    });
    
    // Also get full page HTML for debugging (already saved above)
    // const html = await page.content();
    // fs.writeFileSync('/tmp/groupme-event.html', html);
    // console.log('💾 Page HTML saved to /tmp/groupme-event.html\n');
    
    // Display results
    console.log('📊 RSVP Results:\n');
    
    if (rsvpData.going.length > 0) {
      console.log(`✅ Going (${rsvpData.going.length}):`);
      rsvpData.going.forEach(name => console.log(`   - ${name}`));
      console.log('');
    }
    
    if (rsvpData.maybe.length > 0) {
      console.log(`❓ Maybe (${rsvpData.maybe.length}):`);
      rsvpData.maybe.forEach(name => console.log(`   - ${name}`));
      console.log('');
    }
    
    if (rsvpData.not_going.length > 0) {
      console.log(`❌ Not Going (${rsvpData.not_going.length}):`);
      rsvpData.not_going.forEach(name => console.log(`   - ${name}`));
      console.log('');
    }
    
    if (rsvpData.no_response.length > 0) {
      console.log(`⏳ No Response (${rsvpData.no_response.length}):`);
      rsvpData.no_response.forEach(name => console.log(`   - ${name}`));
      console.log('');
    }
    
    const totalRsvps = rsvpData.going.length + rsvpData.maybe.length + 
                       rsvpData.not_going.length + rsvpData.no_response.length;
    
    if (totalRsvps === 0) {
      console.log('⚠️  No RSVPs found!');
      console.log('   This could mean:');
      console.log('   1. Event has no RSVPs yet');
      console.log('   2. DOM selectors need updating (check screenshot/HTML)');
      console.log('   3. Event URL is incorrect');
      console.log('\n💡 Check /tmp/groupme-event.png and /tmp/groupme-event.html to debug');
    }
    
    return rsvpData;
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    
    // Save screenshot on error
    try {
      await page.screenshot({ path: '/tmp/groupme-error.png', fullPage: true });
      console.log('📸 Error screenshot saved to /tmp/groupme-error.png');
    } catch (screenshotError) {
      // Ignore screenshot errors
    }
    
    throw error;
  } finally {
    await browser.close();
  }
}

// Main
const groupId = process.argv[2];
const eventId = process.argv[3];

if (!groupId || !eventId || groupId === '--help' || groupId === '-h') {
  console.log('GroupMe Calendar Scraper\n');
  console.log('Usage:');
  console.log('  node scripts/groupme-calendar-scraper.js <GROUP_ID> <EVENT_ID>\n');
  console.log('Example:');
  console.log('  node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd\n');
  console.log('Setup:');
  console.log('  Add to .env file (optional, for automated login):');
  console.log('  GROUPME_EMAIL=your-email@example.com');
  console.log('  GROUPME_PASSWORD=your-password');
  process.exit(0);
}

scrapeEventRSVPs(groupId, eventId).catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
