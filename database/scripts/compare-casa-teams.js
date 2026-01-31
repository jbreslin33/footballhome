#!/usr/bin/env node

const path = require('path');
const teams = require(path.join(__dirname, '../scraped-html/casa/division-teams.json'));
const standingsTeams = new Set();
teams.divisions.forEach(d => d.teams.forEach(t => standingsTeams.add(t)));

const matches = require(path.join(__dirname, '../scraped-html/casa/division-matches.json'));
const matchTeams = new Set();
matches.divisions.forEach(d => d.matches.forEach(m => {
  matchTeams.add(m.home);
  matchTeams.add(m.away);
}));

console.log('Teams in STANDINGS but NOT in MATCHES:');
[...standingsTeams].filter(t => !matchTeams.has(t)).forEach(t => console.log('  -', t));

console.log('\nTeams in MATCHES but NOT in STANDINGS:');
[...matchTeams].filter(t => !standingsTeams.has(t)).forEach(t => console.log('  -', t));

console.log(`\nTotal standings teams: ${standingsTeams.size}`);
console.log(`Total match teams: ${matchTeams.size}`);
