// DocxView — show a Word form on the page (mig 1816, 📝 #league-registration
// 👁 Preview).  Owner 2026-11-24: "i need to be able to preview on site the
// club commitment form and team commitment form".
//
//   const doc = await DocxFill.open(arrayBuffer);   // … doc.blank(…) etc.
//   host.appendChild(DocxView.render(doc));         // a white Letter page
//
// It reads the same word/document.xml DocxFill writes, so what shows is what
// the league gets.  It draws what a league's form is made of — paragraphs
// (alignment, spacing, indent, rule lines), runs (font, size, bold, italic,
// underline, caps, colour), tabs, line breaks, tables with their borders,
// inline pictures — and nothing else: no headers, footers, floating shapes
// or page breaks.  A look, not a print: Word decides the real line breaks.
const DocxView = (() => {
  const kids = (el, name) => (el ? Array.from(el.children).filter(c => c.nodeName === name) : []);
  const kid = (el, name) => kids(el, name)[0] || null;
  const attr = (el, name, a = 'w:val') => { const k = kid(el, name); return k ? k.getAttribute(a) : null; };
  // <w:b/> and <w:b w:val="1"/> are on; <w:b w:val="0"/> is off.
  const on = (el, name) => { const k = kid(el, name); return !!k && !/^(0|false|off|none)$/.test(k.getAttribute('w:val') || '1'); };
  const pt = (twips) => `${Number(twips) / 20}pt`;
  const xml = (text) => new DOMParser().parseFromString(text.replace(/^﻿/, ''), 'application/xml');
  const MIMES = { jpg: 'image/jpeg', jpeg: 'image/jpeg', png: 'image/png', gif: 'image/gif', bmp: 'image/bmp' };

  class View {
    constructor(doc) {
      this.files = new Map(doc.files.map(f => [f.name, f.bytes]));
      this.body = xml(doc.xml).getElementsByTagName('w:body')[0];
      this.rels = new Map();     // rId → path in the zip
      this.styles = new Map();   // paragraph styleId → { pPr, rPr }
      this.base = { after: 0, line: 0, size: 24, font: '' };   // the document's own defaults
      this._readRels();
      this._readStyles();
    }

    _text(name) { const b = this.files.get(name); return b ? new TextDecoder().decode(b) : ''; }

    _readRels() {
      const t = this._text('word/_rels/document.xml.rels');
      if (!t) return;
      for (const r of Array.from(xml(t).getElementsByTagName('Relationship'))) {
        const target = r.getAttribute('Target') || '';
        this.rels.set(r.getAttribute('Id'), target.startsWith('/') ? target.slice(1) : `word/${target}`);
      }
    }

    _readStyles() {
      const t = this._text('word/styles.xml');
      if (!t) return;
      const d = xml(t);
      const defaults = d.getElementsByTagName('w:docDefaults')[0];
      const rd = defaults && kid(kid(defaults, 'w:rPrDefault'), 'w:rPr'), pd = defaults && kid(kid(defaults, 'w:pPrDefault'), 'w:pPr');
      if (rd && attr(rd, 'w:sz')) this.base.size = Number(attr(rd, 'w:sz'));
      if (rd && attr(rd, 'w:rFonts', 'w:ascii')) this.base.font = attr(rd, 'w:rFonts', 'w:ascii');
      const sp = pd && kid(pd, 'w:spacing');
      if (sp) { this.base.after = Number(sp.getAttribute('w:after') || 0); this.base.line = Number(sp.getAttribute('w:line') || 0); }
      for (const s of Array.from(d.getElementsByTagName('w:style')))
        if (s.getAttribute('w:type') === 'paragraph') this.styles.set(s.getAttribute('w:styleId'), { pPr: kid(s, 'w:pPr'), rPr: kid(s, 'w:rPr') });
    }

    _picture(drawing) {
      const blip = drawing.getElementsByTagName('a:blip')[0], extent = drawing.getElementsByTagName('wp:extent')[0];
      const path = blip && this.rels.get(blip.getAttribute('r:embed')), bytes = path && this.files.get(path);
      if (!bytes) return null;
      const img = document.createElement('img');
      img.src = URL.createObjectURL(new Blob([bytes], { type: MIMES[path.split('.').pop().toLowerCase()] || 'image/png' }));
      img.onload = () => URL.revokeObjectURL(img.src);
      img.alt = '';
      // EMU → CSS px: 914400 to the inch, 96 px to the inch
      if (extent) { img.style.width = `${Number(extent.getAttribute('cx')) / 9525}px`; img.style.maxWidth = '100%'; img.style.height = 'auto'; }
      return img;
    }

    _runCss(rPr, el) {
      if (!rPr) return;
      const font = attr(rPr, 'w:rFonts', 'w:ascii'), size = attr(rPr, 'w:sz'), color = attr(rPr, 'w:color');
      if (font) el.style.fontFamily = `"${font.replace(/"/g, '')}", Cambria, Georgia, serif`;
      if (size) el.style.fontSize = `${Number(size) / 2}pt`;
      if (kid(rPr, 'w:b')) el.style.fontWeight = on(rPr, 'w:b') ? '700' : '400';
      if (kid(rPr, 'w:i')) el.style.fontStyle = on(rPr, 'w:i') ? 'italic' : 'normal';
      if (on(rPr, 'w:u')) el.style.textDecoration = 'underline';
      if (on(rPr, 'w:caps')) el.style.textTransform = 'uppercase';
      if (on(rPr, 'w:smallCaps')) el.style.fontVariant = 'small-caps';
      if (color && /^[0-9a-f]{6}$/i.test(color)) el.style.color = `#${color}`;
    }

    _run(r) {
      const span = document.createElement('span');
      this._runCss(kid(r, 'w:rPr'), span);
      for (const c of Array.from(r.children)) {
        if (c.nodeName === 'w:t') span.appendChild(document.createTextNode(c.textContent));
        else if (c.nodeName === 'w:tab') { const t = document.createElement('span'); t.style.cssText = 'display:inline-block; width:0.5in;'; span.appendChild(t); }
        else if (c.nodeName === 'w:br' || c.nodeName === 'w:cr') span.appendChild(document.createElement('br'));
        else if (c.nodeName === 'w:drawing') { const img = this._picture(c); if (img) span.appendChild(img); }
      }
      return span;
    }

    _paragraph(p) {
      const div = document.createElement('div');
      const pPr = kid(p, 'w:pPr'), style = this.styles.get(attr(pPr, 'w:pStyle') || '') || {};
      const first = (name, a) => { for (const src of [pPr, style.pPr]) { const k = kid(src, name); if (k && k.getAttribute(a) != null) return k.getAttribute(a); } return null; };
      const jc = first('w:jc', 'w:val');
      div.style.textAlign = jc === 'center' ? 'center' : (jc === 'right' || jc === 'end') ? 'right' : jc === 'both' ? 'justify' : 'left';
      div.style.marginTop = pt(first('w:spacing', 'w:before') || 0);
      div.style.marginBottom = pt(first('w:spacing', 'w:after') ?? this.base.after);
      const line = Number(first('w:spacing', 'w:line') || this.base.line);
      if (line) div.style.lineHeight = String(Math.max(1, line / 240) * 1.15);   // 240 = single, and a font's own leading
      const left = Number(first('w:ind', 'w:left') || 0), right = Number(first('w:ind', 'w:right') || 0);
      const indent = Number(first('w:ind', 'w:firstLine') || 0) - Number(first('w:ind', 'w:hanging') || 0);
      if (left) div.style.paddingLeft = pt(left);
      if (right) div.style.paddingRight = pt(right);
      if (indent) div.style.textIndent = pt(indent);
      const bdr = kid(pPr, 'w:pBdr');
      for (const side of ['top', 'bottom']) if (bdr && attr(bdr, `w:${side}`) && attr(bdr, `w:${side}`) !== 'none') div.style[side === 'top' ? 'borderTop' : 'borderBottom'] = '1px solid #000';
      this._runCss(style.rPr, div);
      const runs = kids(p, 'w:r');
      // an empty paragraph is a blank line as tall as its paragraph mark
      if (!runs.length) { this._runCss(kid(pPr, 'w:rPr'), div); div.appendChild(document.createTextNode(' ')); }
      for (const r of runs) div.appendChild(this._run(r));
      return div;
    }

    _table(tbl) {
      const table = document.createElement('table');
      table.style.cssText = 'border-collapse:collapse; margin:0 0 4pt; max-width:100%;';
      const tblPr = kid(tbl, 'w:tblPr');
      const gridded = (attr(tblPr, 'w:tblStyle') || '') === 'TableGrid';   // Word's "every line drawn" style
      const cols = kids(kid(tbl, 'w:tblGrid'), 'w:gridCol').map(c => Number(c.getAttribute('w:w') || 0));
      for (const tr of kids(tbl, 'w:tr')) {
        const row = table.insertRow();
        const h = attr(kid(tr, 'w:trPr'), 'w:trHeight');
        if (h) row.style.height = pt(h);
        let at = 0;
        for (const tc of kids(tr, 'w:tc')) {
          const cell = row.insertCell(), tcPr = kid(tc, 'w:tcPr');
          const span = Number(attr(tcPr, 'w:gridSpan') || 1);
          if (span > 1) cell.colSpan = span;
          const w = Number(attr(tcPr, 'w:tcW', 'w:w') || 0) || cols.slice(at, at + span).reduce((a, b) => a + b, 0);
          if (w) cell.style.width = pt(w);
          at += span;
          cell.style.padding = '0 5.4pt';
          cell.style.verticalAlign = { center: 'middle', bottom: 'bottom' }[attr(tcPr, 'w:vAlign')] || 'top';
          const borders = kid(tcPr, 'w:tcBorders');
          for (const side of ['Top', 'Left', 'Bottom', 'Right']) {
            const b = attr(borders, `w:${side.toLowerCase()}`);
            if (b ? b !== 'none' && b !== 'nil' : gridded) cell.style[`border${side}`] = '1px solid #000';
          }
          this._blocks(tc, cell);
        }
      }
      return table;
    }

    _blocks(from, into) {
      for (const c of Array.from(from.children)) {
        if (c.nodeName === 'w:p') into.appendChild(this._paragraph(c));
        else if (c.nodeName === 'w:tbl') into.appendChild(this._table(c));
      }
    }

    // A white Letter page, the document's own margins, scaled down on a
    // narrow screen (the margins are a share of the width).
    page() {
      const page = document.createElement('div');
      const sect = kid(this.body, 'w:sectPr'), sz = kid(sect, 'w:pgSz'), mar = kid(sect, 'w:pgMar');
      const width = Number((sz && sz.getAttribute('w:w')) || 12240), m = (side) => Number((mar && mar.getAttribute(`w:${side}`)) || 1440);
      const share = (twips) => `${(twips / width * 100).toFixed(2)}%`;
      page.style.cssText = `background:#fff; color:#000; box-sizing:border-box; width:100%; max-width:${width / 20}pt; margin:0 auto;
        padding:${share(m('top'))} ${share(m('right'))} ${share(m('bottom'))} ${share(m('left'))};
        font-family:${this.base.font ? `"${this.base.font.replace(/"/g, '')}", ` : ''}Aptos, Calibri, Arial, sans-serif; font-size:${this.base.size / 2}pt;
        line-height:1.2; white-space:pre-wrap; overflow-wrap:anywhere; box-shadow:0 2px 14px rgba(0,0,0,0.45);`;
      this._blocks(this.body, page);
      return page;
    }
  }

  return { render(doc) { return new View(doc).page(); } };
})();

window.DocxView = DocxView;
