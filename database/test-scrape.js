#!/usr/bin/env node

/**
 * Simple test to scrape APSL conferences
 */

const https = require('https');
const { JSDOM } = require('jsdom');

const LEAGUE_URL = 'https://apslsoccer.com/standings/';

function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

async function testScrape() {
  try {
    console.log('Fetching APSL standings page...');
    const html = await fetchHTML(LEAGUE_URL);
    const dom = new JSDOM(html);
    const doc = dom.window.document;

    console.log('\n=== Testing different selectors ===\n');

    // Test 1: Look for conference in select options
    console.log('Test 1: Select options');
    const options = doc.querySelectorAll('select[name="DivsAndSkillsFilter"] option');
    console.log(`Found ${options.length} options`);
    options.forEach((opt, i) => {
      if (i > 0) { // Skip first "All" option
        console.log(`  ${i}. ${opt.textContent.trim()}`);
      }
    });

    // Test 2: Look for conference divs
    console.log('\nTest 2: Looking for divs with "Conference" text');
    const allDivs = doc.querySelectorAll('div');
    let confCount = 0;
    allDivs.forEach(div => {
      const text = div.textContent.trim();
      if (text.includes('Conference') && text.length < 100) {
        console.log(`  Found: "${text}"`);
        confCount++;
      }
    });
    console.log(`Total conference divs found: ${confCount}`);

    // Test 3: Look for tables
    console.log('\nTest 3: Tables');
    const tables = doc.querySelectorAll('table');
    console.log(`Found ${tables.length} tables`);

  } catch (error) {
    console.error('Error:', error.message);
  }
}

testScrape();
