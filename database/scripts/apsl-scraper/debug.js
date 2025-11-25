const https = require('https');
const { JSDOM } = require('jsdom');

function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      headers: { 'User-Agent': 'Mozilla/5.0' }
    };
    https.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

async function main() {
  const html = await fetchHTML('https://apslsoccer.com/APSL/Fixtures/?futureEvents=1&DivisionID=20076,0');
  const dom = new JSDOM(html);
  const doc = dom.window.document;
  
  const table = doc.querySelector('table.ScheduleTable');
  if (!table) {
    console.log('No ScheduleTable found');
    return;
  }
  
  const rows = table.querySelectorAll('tr.row2');
  console.log('Found', rows.length, 'match rows');
  
  for (const row of rows) {
    // Get only team links from Team1_vs_Team2_Team divs (home/away teams)
    const teamDivs = row.querySelectorAll('.Team1_vs_Team2_Team');
    console.log('Team divs:', teamDivs.length);
    
    for (let i = 0; i < teamDivs.length; i++) {
      const div = teamDivs[i];
      const link = div.querySelector('a[href*="/APSL/Team/"]');
      if (link) {
        const teamName = div.querySelector('.Club_Box_Name')?.textContent.trim() || 'Unknown';
        console.log(`  Team ${i+1}: ${link.getAttribute('href')} -> ${teamName}`);
      }
    }
  }
}
main();
