#!/usr/bin/env node

/**
 * Unified Scraper CLI
 * Main entry point for all OOP scrapers
 */

const ApslScraper = require('./scrapers/ApslScraper');
const CasaScraper = require('./scrapers/CasaScraper');
const TrainingLighthouseScraper = require('./scrapers/TrainingLighthouseScraper');
const BoysClubLiga1Scraper = require('./scrapers/BoysClubLiga1Scraper');
const OldTimersLiga2Scraper = require('./scrapers/OldTimersLiga2Scraper');
const ApslLighthouseScraper = require('./scrapers/ApslLighthouseScraper');
const VenueScraper = require('./scrapers/VenueScraper');

// Parse command line arguments
const args = process.argv.slice(2);
const scraper = args[0];
const mode = args[1] || 'full';
const includeSchedules = args.includes('--schedules');

// Extract --team parameter
const teamIndex = args.indexOf('--team');
const teamFilter = teamIndex >= 0 && args[teamIndex + 1] ? args[teamIndex + 1] : null;

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
    let instance;
    
    switch (scraper) {
      case 'apsl':
        instance = new ApslScraper(mode, { includeSchedules, teamFilter });
        break;
        
      case 'casa':
        instance = new CasaScraper(mode, { includeSchedules, teamFilter });
        break;
        
      case 'groupme-training':
        instance = new TrainingLighthouseScraper(mode, { includeSchedules });
        break;
        
      case 'groupme-boys-club':
        instance = new BoysClubLiga1Scraper(mode, { includeSchedules });
        break;
        
      case 'groupme-old-timers':
        instance = new OldTimersLiga2Scraper(mode, { includeSchedules });
        break;
        
      case 'groupme-apsl':
        instance = new ApslLighthouseScraper(mode, { includeSchedules });
        break;
        
      case 'venues':
        instance = new VenueScraper(mode, { location, radius });
        break;
        
      default:
        console.error(`Unknown scraper: ${scraper}`);
        console.log('\nUsage: node index.js <scraper> [mode] [options]');
        console.log('\nScrapers:');
        console.log('  apsl                - APSL Soccer League');
        console.log('  casa                - CASA Soccer League');
        console.log('  groupme-training    - Training Lighthouse chat');
        console.log('  groupme-boys-club   - Lighthouse Boys Club Liga 1 chat');
        console.log('  groupme-old-timers  - Lighthouse Old Timers Liga 2 chat');
        console.log('  groupme-apsl        - APSL Lighthouse chat');
        console.log('  venues              - Google Places venues');
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
        process.exit(1);
    }
    
    // Run the scraper
    await instance.scrape();
    
    // Explicitly exit after successful scrape (Puppeteer can keep event loop alive)
    process.exit(0);
    
  } catch (error) {
    console.error('\n❌ Fatal error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

main();
