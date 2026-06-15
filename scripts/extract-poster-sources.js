#!/usr/bin/env node
/**
 * Extract every cite-worthy thing out of frontend/exhibit/lighthouse-history.html
 * and dump it into frontend/exhibit/sources.html, one section per poster.
 *
 * The source IS the source: this script does no rewording, summarising,
 * categorising, or interpretation. For each <article class="poster"> in
 * lighthouse-history.html we harvest, verbatim, three buckets:
 *
 *   1. External hyperlinks: <a href="http(s)://..."> inside the poster body.
 *   2. Blockquotes: the entire innerHTML of <blockquote> (quote + attribution
 *      byline already live together in the source).
  // 3. Photo / archival credits: every <figure> in the poster — capture both the
 *      <img alt> text and the <figcaption> innerHTML so we get the visible
 *      attribution line ("Photo: archival, via The Philadelphia Soccer Page",
 *      "Photo courtesy of Len Oliver.", etc.) along with the alt text.
 *
 * Outputs:
 *   - rewrites frontend/exhibit/sources.html in place, preserving the existing
 *     <head>, hero, TOC, and footer, and replacing every <section
 *     class="poster-block" id="poster-N"> body with the harvested material.
 *
 * Run: node scripts/extract-poster-sources.js
 */

const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

const ROOT = path.resolve(__dirname, '..');
const SRC  = path.join(ROOT, 'frontend/exhibit/lighthouse-history.html');
const OUT  = path.join(ROOT, 'frontend/exhibit/sources.html');

const photoCreditMarkers = [
  'Photo courtesy',
  'Historical Society of Pennsylvania',
  'National Soccer Hall of Fame',
  'Lighthouse Records',
  'archival',
  'educational use',
  'Society for American Soccer History',
  'via The Philadelphia Soccer Page',
  'Henry Holt',
  'IFC Films',
];

function looksLikePhotoCredit(alt) {
  if (!alt) return false;
  return photoCreditMarkers.some((m) => alt.toLowerCase().includes(m.toLowerCase()));
}

function harvestPoster(article) {
  const num = (article.querySelector('.poster-num')?.textContent || '').trim();
  const kicker = (article.querySelector('.poster-band .kicker')?.textContent || '').trim();
  const title = (article.querySelector('.poster-band h2')?.textContent || '').trim();
  const sub = (article.querySelector('.poster-band .sub')?.innerHTML || '').trim();

  // 1. External hyperlinks (dedup by href). Visible link text preserved.
  const linkMap = new Map();
  article.querySelectorAll('a[href^="http"]').forEach((a) => {
    const href = a.getAttribute('href');
    const text = (a.textContent || '').trim();
    if (!linkMap.has(href)) {
      linkMap.set(href, text);
    }
  });
  const links = [...linkMap.entries()].map(([href, text]) => ({ href, text }));

  // 2. Blockquotes — full innerHTML preserved verbatim (quote + attribution).
  const blockquotes = [...article.querySelectorAll('blockquote')].map((bq) =>
    bq.innerHTML.trim(),
  );

  // 3. Photo / archival credits — every <figure> in the poster is a primary
  // visual source, so capture all of them (alt + figcaption verbatim). For
  // standalone <img> elements not wrapped in <figure>, require either a
  // credit marker in the alt text or a substantive alt (>40 chars) so we
  // skip purely decorative icons.
  const photoSet = new Map();
  const addPhoto = (alt, caption, src) => {
    const key = `${src}::${alt}`;
    if (photoSet.has(key)) return;
    photoSet.set(key, { alt: alt || '', caption: caption || '', src: src || '' });
  };

  article.querySelectorAll('figure').forEach((fig) => {
    const img = fig.querySelector('img');
    const cap = fig.querySelector('figcaption');
    const alt = img?.getAttribute('alt') || '';
    const src = img?.getAttribute('src') || '';
    const caption = cap?.innerHTML.trim() || '';
    if (!alt && !caption && !src) return;
    addPhoto(alt, caption, src);
  });
  // Loose images (not wrapped in <figure>), e.g. inline portraits inside <p>.
  article.querySelectorAll('img[alt]').forEach((img) => {
    if (img.closest('figure')) return;
    const alt = img.getAttribute('alt') || '';
    const src = img.getAttribute('src') || '';
    if (alt.length < 40 && !looksLikePhotoCredit(alt)) return;
    addPhoto(alt, '', src);
  });
  const photos = [...photoSet.values()];

  return { num, kicker, title, sub, links, blockquotes, photos };
}

function renderSection(p) {
  const id = `poster-${parseInt(p.num, 10)}`;
  const parts = [];
  parts.push(`  <section class="poster-block" id="${id}">`);
  if (p.kicker) parts.push(`    <p class="kicker">${p.kicker}</p>`);
  parts.push(`    <h2>${p.title}</h2>`);

  const hasAny = p.links.length || p.blockquotes.length || p.photos.length;
  if (!hasAny) {
    parts.push(`    <p class="none">No external citations on this poster.</p>`);
    parts.push(`    <a class="back-top" href="#top">↑ Back to top</a>`);
    parts.push(`  </section>`);
    return parts.join('\n');
  }

  if (p.links.length) {
    parts.push(`    <h3 class="src-group">Linked sources</h3>`);
    parts.push(`    <ol class="src-list">`);
    for (const { href, text } of p.links) {
      const label = text || href;
      parts.push(
        `      <li><a href="${href}" rel="noopener" target="_blank">${label}</a><br><span class="src-url">${href}</span></li>`,
      );
    }
    parts.push(`    </ol>`);
  }

  if (p.blockquotes.length) {
    parts.push(`    <h3 class="src-group">Quoted sources</h3>`);
    for (const html of p.blockquotes) {
      parts.push(`    <blockquote class="src-quote">${html}</blockquote>`);
    }
  }

  if (p.photos.length) {
    parts.push(`    <h3 class="src-group">Photo &amp; archival credits</h3>`);
    parts.push(`    <ul class="src-photos">`);
    for (const { alt, caption, src } of p.photos) {
      const isExternal = /^https?:\/\//i.test(src);
      const fileLabel = isExternal
        ? src
        : src
          ? src.split('/').pop()
          : '';
      const altBlock = alt ? `<span class="src-photo-alt">${alt}</span>` : '';
      const capBlock = caption ? `<span class="src-photo-caption">${caption}</span>` : '';
      const fileBlock = fileLabel
        ? isExternal
          ? `<a class="src-photo-file" href="${src}" rel="noopener" target="_blank">${src}</a>`
          : `<span class="src-photo-file">${fileLabel}</span>`
        : '';
      parts.push(
        `      <li>${fileBlock}${altBlock}${capBlock}</li>`,
      );
    }
    parts.push(`    </ul>`);
  }

  parts.push(`    <a class="back-top" href="#top">↑ Back to top</a>`);
  parts.push(`  </section>`);
  return parts.join('\n');
}

function main() {
  const srcHtml = fs.readFileSync(SRC, 'utf8');
  const dom = new JSDOM(srcHtml);
  const articles = [...dom.window.document.querySelectorAll('article.poster')];
  if (articles.length === 0) {
    throw new Error('No <article class="poster"> found in lighthouse-history.html');
  }
  const posters = articles.map(harvestPoster).sort(
    (a, b) => parseInt(a.num, 10) - parseInt(b.num, 10),
  );

  console.log(`Harvested ${posters.length} posters from lighthouse-history.html`);
  for (const p of posters) {
    console.log(
      `  P${p.num.padStart(2, '0')}  links:${p.links.length}  quotes:${p.blockquotes.length}  photos:${p.photos.length}  ${p.title.slice(0, 50)}`,
    );
  }

  // Read current sources.html and surgically replace just the per-poster
  // sections, preserving every byte of the surrounding chrome (head, hero,
  // TOC, footer, body close).
  const outHtml = fs.readFileSync(OUT, 'utf8');

  // Locate the run of <section class="poster-block" id="poster-N"> ... </section>
  // blocks. The first such opening tag and the last closing </section> before
  // <footer class="page-footer"> bound the region we rewrite.
  const startMatch = outHtml.match(/[ \t]*<section class="poster-block" id="poster-1"/);
  if (!startMatch) {
    throw new Error('Could not find first <section class="poster-block" id="poster-1"> in sources.html');
  }
  const startIdx = startMatch.index;

  const footerMatch = outHtml.match(/\n[ \t]*<footer class="page-footer">/);
  if (!footerMatch) {
    throw new Error('Could not find <footer class="page-footer"> in sources.html');
  }
  const endIdx = footerMatch.index;

  const before = outHtml.slice(0, startIdx);
  const after = outHtml.slice(endIdx);

  const sectionsHtml = posters.map(renderSection).join('\n');
  const newHtml = before + sectionsHtml + '\n' + after;

  fs.writeFileSync(OUT, newHtml);
  console.log(`\nWrote ${OUT}`);
}

main();
