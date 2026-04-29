#!/usr/bin/env node
/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * Scrape Team Detail Pages (Rosters + Schedule)
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *
 * Standalone script that fetches team detail pages for APSL or CSL.
 * Reads team external IDs from the cached standings HTML — no DB needed.
 *
 * Usage:
 *   node scrape-team-pages.js --league apsl
 *   node scrape-team-pages.js --league csl
 *   node scrape-team-pages.js --league apsl --force   # Ignore cache freshness
 *   node scrape-team-pages.js --league apsl --team 114812  # Single team
 *
 * Safety features:
 *   - 3-7s random delay between requests
 *   - 7-day cache freshness (skips if recent)
 *   - Max 50 fetches per session
 *   - 403 detection
 *   - Backs up existing files before overwriting
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');
const HtmlFetcher = require('../infrastructure/fetchers/HtmlFetcher');

const LEAGUE_CONFIG = {
  apsl: {
    configPath: path.join(__dirname, '../leagues/north-america/usa/apsl/config.json'),
    cacheDir: path.join(__dirname, '../../scraped-html/apsl'),
    standingsDir: path.join(__dirname, '../../scraped-html/apsl'),
    standingsPrefix: ['tables-', 'standings-'],
    teamUrlTemplate: 'https://www.apslsoccer.com/APSL/Team/{teamId}',
    cacheFilenamePrefix: 'apsl-team-',
    teamLinkPattern: /\/APSL\/Team\/(\d+)/i,
    seasonHeadingSelector: '.leagueAccordTitle1',
    seasonPattern: /^(\d{4}\/\d{4})/
  },
  csl: {
    configPath: path.join(__dirname, '../leagues/north-america/usa/csl/config.json'),
    cacheDir: path.join(__dirname, '../../scraped-html/csl'),
    standingsDir: path.join(__dirname, '../../scraped-html/csl'),
    standingsPrefix: ['tables-'],
    teamUrlTemplate: 'https://www.cosmosoccerleague.com/CSL/Team/{teamId}',
    cacheFilenamePrefix: null, // CSL uses default HtmlFetcher naming
    teamLinkPattern: /\/CSL\/Team\/(\d+)/i,
    seasonHeadingSelector: null, // CSL tables page doesn't use accordion headings
    seasonPattern: null,
    // CSL is a JavaScript SPA — direct URL navigation redirects to homepage.
    // Must click team links from the Tables page to get real content.
    spaNavigation: {
      startUrl: 'https://www.cosmosoccerleague.com/CSL/Tables/',
      clickSelectorTemplate: 'a[href="/CSL/Team/{teamId}"]',
      urlMustInclude: '/CSL/Team/'
    }
  }
};

function parseArgs() {
  const args = process.argv.slice(2);
  const result = { league: null, force: false, singleTeam: null };

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--league' && args[i + 1]) {
      result.league = args[++i].toLowerCase();
    } else if (args[i] === '--force') {
      result.force = true;
    } else if (args[i] === '--team' && args[i + 1]) {
      result.singleTeam = args[++i];
    }
  }

  if (!result.league || !LEAGUE_CONFIG[result.league]) {
    console.error('Usage: node scrape-team-pages.js --league <apsl|csl> [--force] [--team <id>]');
    process.exit(1);
  }

  return result;
}

/**
 * Read the cached standings HTML for a league
 */
function readStandingsHtml(leagueCfg, config) {
  const files = fs.readdirSync(leagueCfg.standingsDir)
    .filter(f => leagueCfg.standingsPrefix.some(prefix => f.startsWith(prefix)))
    .filter(f => f.endsWith('.html'))
    .map(f => ({
      name: f,
      path: path.join(leagueCfg.standingsDir, f),
      mtime: fs.statSync(path.join(leagueCfg.standingsDir, f)).mtime
    }))
    .sort((a, b) => b.mtime - a.mtime);

  if (files.length === 0) {
    throw new Error('No standings HTML found. Run scrape-standings first.');
  }

  // Try to find file matching active season
  if (leagueCfg.seasonHeadingSelector && config.activeSeason) {
    for (const file of files) {
      const html = fs.readFileSync(file.path, 'utf-8');
      const dom = new JSDOM(html);
      const heading = dom.window.document.querySelector(leagueCfg.seasonHeadingSelector);
      if (heading && heading.textContent.trim().startsWith(config.activeSeason)) {
        console.log(`   📂 Using standings: ${file.name} (season: ${config.activeSeason})`);
        return fs.readFileSync(file.path, 'utf-8');
      }
    }
    console.warn(`   ⚠️  No HTML for season ${config.activeSeason}, using most recent`);
  }

  console.log(`   📂 Using standings: ${files[0].name}`);
  return fs.readFileSync(files[0].path, 'utf-8');
}

/**
 * Extract team external IDs from standings HTML
 */
function extractTeamIds(html, leagueCfg) {
  const dom = new JSDOM(html);
  const document = dom.window.document;
  const teamIds = new Set();

  // Find all team links matching the pattern
  const links = document.querySelectorAll('a');
  for (const link of links) {
    const href = link.getAttribute('href') || '';
    const match = href.match(leagueCfg.teamLinkPattern);
    if (match) {
      teamIds.add(match[1]);
    }
  }

  return Array.from(teamIds);
}

/**
 * Build the team page URL, appending season param for CSL
 */
function buildTeamUrl(teamId, leagueCfg, config) {
  let url = leagueCfg.teamUrlTemplate.replace('{teamId}', teamId);
  // CSL needs ?Table_Season= parameter
  if (config.seasonExternalId) {
    url += `?Table_Season=${config.seasonExternalId}`;
  }
  return url;
}

async function main() {
  const args = parseArgs();
  const leagueCfg = LEAGUE_CONFIG[args.league];
  const config = JSON.parse(fs.readFileSync(leagueCfg.configPath, 'utf8'));
  const leagueName = args.league.toUpperCase();
  const lighthouseOnly = process.env.LIGHTHOUSE_ONLY === '1';

  console.log(`\n🌐 ${leagueName} Team Page Scraper`);
  console.log('='.repeat(60));

  // Read standings to get team IDs
  const standingsHtml = readStandingsHtml(leagueCfg, config);
  let teamIds = extractTeamIds(standingsHtml, leagueCfg);

  if (lighthouseOnly && !args.singleTeam) {
    const scopedTeamIds = new Set((config.lighthouseScope?.teamExternalIds || []).map(String));
    if (scopedTeamIds.size > 0) {
      const filteredTeamIds = teamIds.filter(teamId => scopedTeamIds.has(String(teamId)));
      teamIds = filteredTeamIds.length > 0 ? filteredTeamIds : Array.from(scopedTeamIds);
      console.log(`   Lighthouse scope enabled: ${teamIds.length} team(s)`);
    }
  }

  if (args.singleTeam) {
    if (!teamIds.includes(args.singleTeam)) {
      console.warn(`   ⚠️  Team ${args.singleTeam} not found in standings, fetching anyway`);
      teamIds = [args.singleTeam];
    } else {
      teamIds = [args.singleTeam];
    }
  }

  console.log(`   Found ${teamIds.length} teams in standings`);

  if (teamIds.length === 0) {
    console.log('   No teams found. Check standings HTML.');
    process.exit(0);
  }

  // Clear old .skip files for this season (they may be from a previous season)
  if (!args.singleTeam) {
    const skipFiles = fs.readdirSync(leagueCfg.cacheDir).filter(f => f.endsWith('.skip'));
    if (skipFiles.length > 0) {
      console.log(`   🧹 Removing ${skipFiles.length} stale .skip files`);
      for (const f of skipFiles) {
        fs.unlinkSync(path.join(leagueCfg.cacheDir, f));
      }
    }
  }

  // Create fetcher with safety settings
  const fetcher = new HtmlFetcher(leagueCfg.cacheDir, {
    delayMs: 3000,
    delayJitterMs: 4000,
    cacheFreshnessDays: args.force ? 0 : 7,
    maxFetchesPerSession: 50
  });

  const useSpa = !!leagueCfg.spaNavigation;
  if (useSpa) {
    console.log(`   🔗 Using SPA click-navigation (site redirects on direct URL access)`);
    // Append season parameter to start URL if needed
    if (config.seasonExternalId && !leagueCfg.spaNavigation.startUrl.includes('Table_Season')) {
      leagueCfg.spaNavigation.startUrl += `?Table_Season=${config.seasonExternalId}`;
    }
  }

  let fetched = 0;
  let cached = 0;
  let failed = 0;
  const failedTeams = [];

  for (const teamId of teamIds) {
    const url = buildTeamUrl(teamId, leagueCfg, config);
    try {
      let html;

      if (useSpa) {
        // SPA navigation: click link from Tables page instead of direct URL
        const clickSelector = leagueCfg.spaNavigation.clickSelectorTemplate.replace('{teamId}', teamId);
        html = await fetcher.fetchViaSpaClick({
          startUrl: leagueCfg.spaNavigation.startUrl,
          clickSelector,
          urlMustInclude: leagueCfg.spaNavigation.urlMustInclude + teamId,
          cacheUrl: url,
          useCache: !args.force
        });
      } else {
        html = await fetcher.fetch(url, !args.force);
      }

      // Validate: reject 403 pages
      if (html && html.includes('403 - Forbidden')) {
        console.log(`   ⚠️  Got 403 for team ${teamId} — skipping`);
        failedTeams.push(teamId);
        failed++;
        continue;
      }

      // Validate: reject tiny responses
      if (html && html.length < 1000) {
        console.log(`   ⚠️  Response too small for team ${teamId} (${html.length} bytes)`);
        failedTeams.push(teamId);
        failed++;
        continue;
      }

      // Check if it was served from cache
      if (html && html.length > 0) {
        // HtmlFetcher logs cache hits, so count based on fetch count
        if (fetcher._fetchCount > fetched) {
          fetched = fetcher._fetchCount;
        } else {
          cached++;
        }
      }
    } catch (error) {
      if (error.message === 'EMPTY_CACHE') {
        failedTeams.push(teamId);
        failed++;
      } else {
        console.log(`   ⚠️  Error for team ${teamId}: ${error.message}`);
        failedTeams.push(teamId);
        failed++;
      }
    }
  }

  // Retry failed teams (skip for SPA — re-clicking is handled in fetchViaSpaClick)
  if (failedTeams.length > 0 && !args.singleTeam && !useSpa) {
    console.log(`\n   🔄 Retrying ${failedTeams.length} failed teams...`);
    for (const teamId of failedTeams) {
      const url = buildTeamUrl(teamId, leagueCfg, config);
      try {
        await fetcher.fetch(url, false, 1);
        failed--;
      } catch (error) {
        console.log(`   ⚠️  Retry failed for team ${teamId}: ${error.message}`);
      }
    }
  }

  await fetcher.closeBrowser();

  const liveCount = fetcher._fetchCount;
  const cachedCount = teamIds.length - liveCount - failed;
  console.log(`\n   📊 Summary:`);
  console.log(`      Teams in standings: ${teamIds.length}`);
  console.log(`      Live fetches: ${liveCount}`);
  console.log(`      Served from cache: ${cachedCount}`);
  console.log(`      Failed: ${failed}`);

  // Loud failure modes — refuse to silently exit clean when something is wrong.
  if (failed > 0) {
    console.error(`\n❌ ${leagueName}: ${failed} team page(s) failed to fetch.`);
    console.error(`   Failed team IDs: ${failedTeams.join(', ')}`);
    process.exit(2);
  }
  if (args.force && liveCount === 0 && teamIds.length > 0) {
    console.error(`\n❌ ${leagueName}: --force was set but ZERO live fetches occurred.`);
    console.error(`   The scraper served everything from cache despite the force flag.`);
    console.error(`   This usually means env vars (e.g. FORCE_SCRAPE) were dropped at`);
    console.error(`   the VPN-container boundary, or the cache path is wrong.`);
    process.exit(3);
  }
  console.log(`\n✅ ${leagueName} team pages done\n`);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
