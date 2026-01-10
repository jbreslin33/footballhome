const fs = require('fs');
const { JSDOM } = require('jsdom');

const html = fs.readFileSync('../scraped-html/csl/227496-6ed7a3c7c6f97034d16a42a2f3c90fe2-4ec3f678.html', 'utf8');
const dom = new JSDOM(html);
const doc = dom.window.document;

// Find headers
const headers = doc.querySelectorAll('h2');
console.log('Team headers found:');
for (const h2 of headers) {
  const text = h2.textContent.trim();
  if (text.length < 50 && text !== 'Affiliations' && text !== 'Sponsors') {
    console.log('  -', text);
  }
}

// Find table after first team header
const firstTeamHeader = headers[0];
let table = firstTeamHeader.nextElementSibling;
while (table && table.tagName !== 'TABLE') {
  table = table.nextElementSibling;
}

if (table) {
  console.log('\nFound table after first team header');
  
  // Check for tbody rows vs direct tr
  const tbodyRows = table.querySelectorAll('tbody tr');
  const directRows = table.querySelectorAll('tr');
  console.log('Rows via tbody:', tbodyRows.length);
  console.log('Rows via table:', directRows.length);
  
  // Check first data row (skip header)
  if (directRows.length > 1) {
    const row = directRows[1];
    const cells = row.querySelectorAll('td');
    console.log('\nFirst data row has', cells.length, 'cells');
    if (cells.length >= 4) {
      console.log('Cell[0] (Player):', cells[0].textContent.trim().substring(0, 30));
      console.log('Cell[2] (Goals):', cells[2].textContent.trim() || '(empty)');
      console.log('Cell[3] (Assists):', cells[3].textContent.trim() || '(empty)');
    }
  }
  
  // Search for a row with actual numbers
  console.log('\nSearching for rows with stats...');
  let found = 0;
  for (const row of directRows) {
    const cells = row.querySelectorAll('td');
    if (cells.length >= 4) {
      const goals = cells[2].textContent.trim();
      const assists = cells[3].textContent.trim();
      if ((goals && goals !== '' && goals !== '0') || (assists && assists !== '' && assists !== '0')) {
        console.log('Found:', cells[0].textContent.trim().substring(0, 30), '- G:', goals, ', A:', assists);
        found++;
        if (found >= 5) break;
      }
    }
  }
  if (found === 0) {
    console.log('❌ No rows with stats found!');
  } else {
    console.log(`✅ Found ${found} players with stats`);
  }
}
