#!/usr/bin/env node

/**
 * Simple GroupMe Events Scraper
 * 
 * Uses Puppeteer to:
 * 1. Login to GroupMe
 * 2. Navigate to the group's events page
 * 3. Extract all event data including RSVPs with names
 * 
 * No API needed - just scrapes the web UI directly!
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
require('dotenv').config();

const GROUP_ID = process.argv[2];
const OUTPUT_FILE = process.argv[3] || 'groupme-events.json';

if (!GROUP_ID) {
  console.error('Usage: node scrape-groupme-events-simple.js <group_id> [output_file]');
  process.exit(1);
}

const GROUPME_EMAIL = process.env.GROUPME_EMAIL;
const GROUPME_PASSWORD = process.env.GROUPME_PASSWORD;

async function scrapeGroupMeEvents() {
  console.log('🚀 Launching browser...');
  const browser = await puppeteer.launch({
    headless: false, // Show browser for debugging
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 720 });

    // Go to GroupMe
    console.log('📱 Navigating to GroupMe...');
    await page.goto('https://web.groupme.com', { waitUntil: 'networkidle2' });

    // Check if we need to login
    const currentUrl = page.url();
    if (currentUrl.includes('signin') || currentUrl.includes('login')) {
      console.log('🔐 Logging in...');
      
      if (GROUPME_EMAIL && GROUPME_PASSWORD) {
        // Automated login
        await page.waitForSelector('input[type="email"]', { timeout: 5000 });
        await page.type('input[type="email"]', GROUPME_EMAIL);
        await page.type('input[type="password"]', GROUPME_PASSWORD);
        await page.click('button[type="submit"]');
        await page.waitForNavigation({ waitUntil: 'networkidle2' });
        console.log('✅ Logged in automatically');
      } else {
        // Manual login
        console.log('⏳ Please log in manually (no credentials in .env)...');
        await page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 120000 });
        console.log('✅ Logged in manually');
      }
    } else {
      console.log('✅ Already logged in');
    }

    // Navigate to the group
    console.log(`📬 Opening group ${GROUP_ID}...`);
    await page.goto(`https://web.groupme.com/chats/${GROUP_ID}`, { 
      waitUntil: 'networkidle2',
      timeout: 30000 
    });

    // Wait a bit for the page to fully load
    await page.waitForTimeout(2000);

    // Click on the group name/header to open group details
    console.log('📋 Opening group details...');
    try {
      // Try to find and click the events/calendar button
      // GroupMe's UI might have different selectors, we'll try a few
      await page.evaluate(() => {
        // Look for calendar/events button
        const buttons = Array.from(document.querySelectorAll('button, div[role="button"], a'));
        const eventsButton = buttons.find(btn => 
          btn.textContent.toLowerCase().includes('event') ||
          btn.textContent.toLowerCase().includes('calendar')
        );
        if (eventsButton) eventsButton.click();
      });
      
      await page.waitForTimeout(2000);
    } catch (error) {
      console.log('⚠️  Could not find events button automatically');
      console.log('💡 Please navigate to the Events/Calendar tab manually...');
      await page.waitForTimeout(10000); // Give user time to click
    }

    // Extract all events from the page
    console.log('🔍 Extracting events...');
    
    const events = await page.evaluate(() => {
      const eventsData = [];
      
      // Try to find event elements - GroupMe's structure varies
      // We'll look for common patterns
      const eventElements = document.querySelectorAll('[data-event-id], .event-card, .calendar-event');
      
      eventElements.forEach(element => {
        try {
          const event = {
            id: element.getAttribute('data-event-id') || '',
            name: '',
            date: '',
            location: '',
            going: [],
            not_going: [],
            maybe: []
          };
          
          // Extract text content
          const text = element.textContent || '';
          
          // Try to find title
          const titleElement = element.querySelector('.event-title, .title, h2, h3');
          if (titleElement) {
            event.name = titleElement.textContent.trim();
          }
          
          // Try to find date
          const dateElement = element.querySelector('.event-date, .date, time');
          if (dateElement) {
            event.date = dateElement.textContent.trim();
          }
          
          // Try to find location
          const locationElement = element.querySelector('.event-location, .location');
          if (locationElement) {
            event.location = locationElement.textContent.trim();
          }
          
          // Try to find RSVP lists
          const rsvpLists = element.querySelectorAll('.rsvp-list, .attendees');
          rsvpLists.forEach(list => {
            const listText = list.textContent.toLowerCase();
            const names = Array.from(list.querySelectorAll('.name, .user-name'))
              .map(n => n.textContent.trim())
              .filter(n => n);
            
            if (listText.includes('going') || listText.includes('yes')) {
              event.going.push(...names);
            } else if (listText.includes('not going') || listText.includes('no')) {
              event.not_going.push(...names);
            } else if (listText.includes('maybe')) {
              event.maybe.push(...names);
            }
          });
          
          if (event.name || event.date) {
            eventsData.push(event);
          }
        } catch (err) {
          console.error('Error parsing event:', err);
        }
      });
      
      return eventsData;
    });

    console.log(`\n✅ Found ${events.length} events\n`);
    
    // Save to file
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(events, null, 2));
    console.log(`💾 Saved to ${OUTPUT_FILE}`);
    
    // Also save page HTML for debugging
    const html = await page.content();
    fs.writeFileSync(OUTPUT_FILE.replace('.json', '.html'), html);
    console.log(`💾 Saved HTML to ${OUTPUT_FILE.replace('.json', '.html')}`);
    
    // Take a screenshot
    await page.screenshot({ 
      path: OUTPUT_FILE.replace('.json', '.png'),
      fullPage: true 
    });
    console.log(`📸 Saved screenshot to ${OUTPUT_FILE.replace('.json', '.png')}`);
    
    return events;

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    console.log('\n🔒 Closing browser...');
    await browser.close();
  }
}

// Run the scraper
scrapeGroupMeEvents()
  .then(events => {
    console.log('\n✨ Done!');
    console.log(JSON.stringify(events, null, 2));
  })
  .catch(error => {
    console.error('\n❌ Failed:', error);
    process.exit(1);
  });
