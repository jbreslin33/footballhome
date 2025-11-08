#!/usr/bin/env node

/**
 * League Data Scraper Test Script
 * 
 * Tests the league scrapers with mock data to verify functionality
 * and demonstrate the complete data import workflow.
 * 
 * Usage:
 *   node test-scrapers.js [scraper-name]
 *   node test-scrapers.js all
 *   node test-scrapers.js stats
 * 
 * Examples:
 *   node test-scrapers.js apsl     # Run only APSL scraper
 *   node test-scrapers.js casa     # Run only CASA scraper  
 *   node test-scrapers.js all      # Run all scrapers
 *   node test-scrapers.js stats    # Show scraping statistics
 */

require('dotenv').config();
const ScraperManager = require('./ScraperManager');

async function main() {
  const command = process.argv[2] || 'all';
  
  console.log('🏈 Football League Scraper Test');
  console.log('================================');
  console.log(`Command: ${command}`);
  console.log(`Season: 2024`);
  console.log('');

  const config = {
    season: '2024',
    POSTGRES_USER: process.env.POSTGRES_USER || 'footballhome_user',
    POSTGRES_HOST: process.env.POSTGRES_HOST || 'postgres',
    POSTGRES_DB: process.env.POSTGRES_DB || 'footballhome',
    POSTGRES_PASSWORD: process.env.POSTGRES_PASSWORD || 'footballhome_pass',
    POSTGRES_PORT: process.env.POSTGRES_PORT || 5432
  };

  const manager = new ScraperManager(config);

  try {
    switch (command.toLowerCase()) {
      case 'stats':
        await showStats(manager);
        break;
        
      case 'all':
        await manager.runAllScrapers();
        break;
        
      case 'apsl':
      case 'casa':
        await manager.runScraper(command);
        break;
        
      default:
        console.log('❌ Invalid command');
        console.log('Available commands: apsl, casa, all, stats');
        process.exit(1);
    }

    console.log('\n--- Final Statistics ---');
    await showStats(manager);
    
  } catch (error) {
    console.error('💥 Scraper test failed:', error);
    process.exit(1);
  } finally {
    await manager.close();
  }
}

async function showStats(manager) {
  try {
    const stats = await manager.getStats();
    
    console.log('\n📊 Scraping Statistics:');
    
    if (stats.bySource && stats.bySource.length > 0) {
      console.log('\nBy Data Source:');
      stats.bySource.forEach(source => {
        console.log(`  ${source.data_source}:`);
        console.log(`    Total Games: ${source.game_count}`);
        console.log(`    Completed: ${source.completed_games}`);
        console.log(`    Scheduled: ${source.scheduled_games}`);
        console.log(`    Last Scraped: ${source.last_scraped || 'Never'}`);
      });
    } else {
      console.log('  No scraped games found');
    }

    if (stats.totals) {
      console.log('\nOverall Totals:');
      console.log(`  Match Events: ${stats.totals.total_events || 0}`);
      console.log(`  Player Stats: ${stats.totals.total_player_stats || 0}`);
    }

    if (stats.recentGames && stats.recentGames.length > 0) {
      console.log('\nRecent Games:');
      stats.recentGames.forEach((game, i) => {
        const score = game.score !== 'null-null' ? game.score : 'vs';
        console.log(`  ${i + 1}. ${game.home_team} ${score} ${game.away_team} (${game.data_source})`);
      });
    }
    
  } catch (error) {
    console.error('Failed to get statistics:', error.message);
  }
}

// Handle uncaught errors
process.on('unhandledRejection', (error) => {
  console.error('💥 Unhandled promise rejection:', error);
  process.exit(1);
});

process.on('uncaughtException', (error) => {
  console.error('💥 Uncaught exception:', error);
  process.exit(1);
});

// Run the script
if (require.main === module) {
  main();
}