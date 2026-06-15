#!/usr/bin/env node
// Quick probe: open the source page and report what counts.paras / counts.bqs
// resolve to for poster N. Usage: node scripts/debug-poster-count.js 2
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const n = parseInt(process.argv[2] || '2', 10);
  const SOURCE = 'file://' + path.resolve(__dirname, '..', 'frontend/exhibit/lighthouse-history.html');
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 1400, height: 2400 });
  await page.goto(SOURCE, { waitUntil: 'domcontentloaded' });
  try { await page.evaluate(() => document.fonts && document.fonts.ready); } catch {}
  // Let source JS run its init pass.
  await new Promise(r => setTimeout(r, 800));

  const report = await page.evaluate(() => {
    const posters = Array.from(document.querySelectorAll('article.poster'));
    return posters.map((p, idx) => {
      const num = idx + 1;
      const body = p.querySelector('.poster-body');
      if (!body) return { num, error: 'no body' };
      const directChildren = Array.from(body.children).map(c => c.tagName.toLowerCase() + (c.className ? '.' + c.className.split(/\s+/)[0] : ''));
      const paras = body.querySelectorAll(':scope > p').length;
      const bqs   = body.querySelectorAll(':scope > blockquote').length;
      // Detect adoption-agency artifacts: any direct child that's a formatting
      // element (strong/em/b/i/u/s) is a sign of misnested tags upstream.
      const formattingOrphans = Array.from(body.children)
        .filter(c => /^(strong|em|b|i|u|s)$/.test(c.tagName.toLowerCase()))
        .map(c => c.tagName.toLowerCase());
      return { num, paras, bqs, formattingOrphans, directChildren };
    });
  });

  console.log(JSON.stringify(report, null, 2));
  await browser.close();
})();
