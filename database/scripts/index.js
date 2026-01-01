#!/usr/bin/env node

/**
 * Unified Scraper CLI
 * Main entry point for all OOP scrapers
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../env') });

// Force disable SSL verification for development environment
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const ApslScraper = require('./scrapers/ApslScraper');
const CasaScraper = require('./scrapers/CasaScraper');
const TrainingLighthouseScraper = require('./scrapers/TrainingLighthouseScraper');
const BoysClubLiga1Scraper = require('./scrapers/BoysClubLiga1Scraper');
const OldTimersLiga2Scraper = require('./scrapers/OldTimersLiga2Scraper');
const ApslLighthouseScraper = require('./scrapers/ApslLighthouseScraper');
const VenueScraper = require('./scrapers/VenueScraper');

// Parse command line arguments
const args = process.argv.slice(2);

// Check for aggregate flags
const runApsl = args.includes('--apsl');
const runCasa = args.includes('--casa');
const runGroupMe = args.includes('--groupme');

// If no aggregate flags, look for specific scraper argument
const scraper = (!runApsl && !runCasa && !runGroupMe) ? args[0] : null;
const mode = args[1] && !args[1].startsWith('--') ? args[1] : 'full';
const includeSchedules = args.includes('--schedules');

// Extract --team parameter
const teamIndex = args.indexOf('--team');
const teamFilter = teamIndex >= 0 && args[teamIndex + 1] ? args[teamIndex + 1] : null;

// Extract --force-refresh parameter (bypass cache)
const forceRefresh = args.includes('--force-refresh');

// Extract --discover flag (discovery mode: structure only, no DB writes)
const discover = args.includes('--discover');

// Extract --location parameter (lat,lng)
const locationIndex = args.indexOf('--location');
const location = locationIndex >= 0 && args[locationIndex + 1] 
  ? (() => {
      const [lat, lng] = args[locationIndex + 1].split(',').map(parseFloat);
      return { lat, lng };
    })()
  : null;

// Extract --radius parameter (meters)
const radiusIndex = args.indexOf('--radius');
const radius = radiusIndex >= 0 && args[radiusIndex + 1] ? parseInt(args[radiusIndex + 1]) : null;

async function main() {
  try {
    const scrapersToRun = [];

    // 1. Aggregate Flags
    if (runApsl) {
      // Always include schedules for APSL to enable per-match player stats
      scrapersToRun.push(new ApslScraper(mode, { includeSchedules: true, teamFilter, forceRefresh, discover }));
    }

    if (runCasa) {
      scrapersToRun.push(new CasaScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
    }

    if (runGroupMe) {
      scrapersToRun.push(new TrainingLighthouseScraper(mode, { includeSchedules }));
      scrapersToRun.push(new BoysClubLiga1Scraper(mode, { includeSchedules }));
      scrapersToRun.push(new OldTimersLiga2Scraper(mode, { includeSchedules }));
      scrapersToRun.push(new ApslLighthouseScraper(mode, { includeSchedules }));
    }

    // 2. Specific Scraper (if no aggregate flags)
    if (scrapersToRun.length === 0 && scraper) {
      switch (scraper) {
        case 'apsl':
          scrapersToRun.push(new ApslScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
          break;
          
        case 'casa':
          scrapersToRun.push(new CasaScraper(mode, { includeSchedules, teamFilter, forceRefresh, discover }));
          break;
          
        case 'groupme-training':
          scrapersToRun.push(new TrainingLighthouseScraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-boys-club':
          scrapersToRun.push(new BoysClubLiga1Scraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-old-timers':
          scrapersToRun.push(new OldTimersLiga2Scraper(mode, { includeSchedules }));
          break;
          
        case 'groupme-apsl':
          scrapersToRun.push(new ApslLighthouseScraper(mode, { includeSchedules }));
          break;
          
        case 'venues':
          scrapersToRun.push(new VenueScraper(mode, { location, radius }));
          break;
          
        default:
          console.error(`Unknown scraper: ${scraper}`);
          printUsage();
          process.exit(1);
      }
    }

    if (scrapersToRun.length === 0) {
      printUsage();
      process.exit(1);
    }

    // Run all selected scrapers sequentially
    console.log(`\n🚀 Starting ${scrapersToRun.length} scraper(s)...\n`);
    
    for (const instance of scrapersToRun) {
      await instance.scrape();
      console.log('\n----------------------------------------\n');
    }
    
    console.log('✨ All tasks completed successfully.');
    
    // Explicitly exit after successful scrape (Puppeteer can keep event loop alive)
    process.exit(0);
    
  } catch (error) {
    console.error('\n❌ Fatal error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

function printUsage() {
  console.log('\nUsage: node index.js [scraper] [mode] [options]');
  console.log('       node index.js --apsl [mode] [options]');
  console.log('       node index.js --casa [mode] [options]');
  console.log('       node index.js --groupme [mode] [options]');
  console.log('\nScrapers:');
  console.log('  apsl                - APSL Soccer League');
  console.log('  casa                - CASA Soccer League');
  console.log('  groupme-training    - Training Lighthouse chat');
  console.log('  groupme-boys-club   - Lighthouse Boys Club Liga 1 chat');
  console.log('  groupme-old-timers  - Lighthouse Old Timers Liga 2 chat');
  console.log('  groupme-apsl        - APSL Lighthouse chat');
  console.log('  venues              - Google Places venues');
  console.log('\nAggregate Flags:');
  console.log('  --apsl              - Run APSL scraper');
  console.log('  --casa              - Run CASA scraper');
  console.log('  --groupme           - Run all GroupMe scrapers');
  console.log('\nModes:');
  console.log('  structure - League structure only');
  console.log('  teams     - Structure + teams');
  console.log('  players   - Structure + teams + rosters');
  console.log('  full      - Everything (default)');
  console.log('\nOptions:');
  console.log('  --schedules              Include match schedules');
  console.log('  --team <name>            Filter to teams matching name (e.g., "Lighthouse", "United")');
  console.log('  --location <lat,lng>     Search location for venues (e.g., "39.9526,-75.1652")');
  console.log('  --radius <meters>        Search radius for venues (default: 50000)');
}

main();
