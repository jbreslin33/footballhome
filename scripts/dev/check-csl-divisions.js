#!/usr/bin/env node
/**
 * Check which CSL divisions contain which teams.
 * Useful for debugging missing teams in the parse pipeline.
 */
const fs = require('fs');
const { JSDOM } = require('jsdom');
const html = fs.readFileSync('database/scraped-html/csl/tables-4ab2e129.html', 'utf8');
const dom = new JSDOM(html);
const doc = dom.window.document;

const allDivs = doc.querySelectorAll('div');
for (const div of allDivs) {
  const text = div.textContent.trim();
  const m = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+)$/);
  if (!m || m[1] !== '2025/2026') continue;

  const divName = m[2];
  // find following table
  let current = div;
  let table = null;
  let iterations = 0;
  while (current && !table && iterations < 100) {
    iterations++;
    current = current.nextElementSibling;
    if (current && current.tagName === 'TABLE') table = current;
    if (!current && div.parentElement) {
      current = div.parentElement.nextElementSibling;
      if (current) table = current.querySelector('table');
    }
  }
  if (!table) {
    console.log(`${divName}: NO TABLE FOUND`);
    continue;
  }

  const rows = table.querySelectorAll('tr');
  let teams = [];
  rows.forEach(row => {
    const cells = row.querySelectorAll('td');
    if (cells.length < 10) return;
    const teamName = cells[1].textContent.trim();
    const teamLink = cells[1].querySelector('a[href*="/CSL/Team/"]');
    const teamHref = teamLink ? teamLink.getAttribute('href') : '';
    const extMatch = teamHref.match(/\/CSL\/Team\/(\d+)/);
    const externalId = extMatch ? extMatch[1] : 'N/A';
    if (teamName) teams.push({ name: teamName, externalId });
  });

  console.log(`\n${divName}: ${teams.length} teams`);
  teams.forEach(t => console.log(`  ${t.name} (ext: ${t.externalId})`));
}
