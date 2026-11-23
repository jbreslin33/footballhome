// DocxFill — fill a league's own Word form in the browser (mig 1746,
// 📝 #league-registration).  A .docx is a zip of XML; the forms leagues send
// are text with "Label ________" blanks and empty table cells.  This opens
// the zip, writes values over the blanks in word/document.xml and zips it
// again — the league's layout, logo and wording stay exactly theirs.
//
//   const doc = await DocxFill.open(arrayBuffer);
//   doc.blank('Team Name:', 'Lighthouse U12');      // "Label ____" → "Label Lighthouse U12"
//   doc.blanks('Phone', [coach, assistant]);        // every "Phone ____", in order
//   doc.lones(['Sat 9–1']);                         // lines that are only underscores, in order
//   doc.swap('____MALE', '_X_ MALE');               // plain text swap
//   doc.cell(0, 'U12', 1, '1');                     // table 0, row starting "U12", cell 1
//   doc.cellAt(0, 3, 1, 'Ana Diaz');                // table 0, row 3, cell 1
//   const blob = await doc.blob();
//
// An empty value leaves the blank as it is (so the form still shows the
// line to write on).  No library: DecompressionStream reads the zip, the
// new one is stored uncompressed (a form is a few hundred KB).
const DocxFill = (() => {
  const MIME = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const rx = (s) => String(s).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

  let crcTable = null;
  function crc32(bytes) {
    if (!crcTable) {
      crcTable = new Uint32Array(256);
      for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; crcTable[n] = c >>> 0; }
    }
    let c = 0xFFFFFFFF;
    for (let i = 0; i < bytes.length; i++) c = crcTable[(c ^ bytes[i]) & 0xFF] ^ (c >>> 8);
    return (c ^ 0xFFFFFFFF) >>> 0;
  }

  async function inflate(bytes) {
    const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream('deflate-raw'));
    return new Uint8Array(await new Response(stream).arrayBuffer());
  }

  // name → bytes, in the file's order (read from the central directory).
  async function unzip(buffer) {
    const u8 = new Uint8Array(buffer), dv = new DataView(u8.buffer, u8.byteOffset, u8.byteLength);
    let eocd = -1;
    for (let i = u8.length - 22; i >= 0 && i >= u8.length - 66000; i--) if (dv.getUint32(i, true) === 0x06054b50) { eocd = i; break; }
    if (eocd < 0) throw new Error('Not a Word file.');
    const count = dv.getUint16(eocd + 10, true);
    let at = dv.getUint32(eocd + 16, true);
    const files = [];
    for (let n = 0; n < count; n++) {
      if (dv.getUint32(at, true) !== 0x02014b50) throw new Error('Not a Word file.');
      const method = dv.getUint16(at + 10, true), csize = dv.getUint32(at + 20, true);
      const nameLen = dv.getUint16(at + 28, true), extraLen = dv.getUint16(at + 30, true), commentLen = dv.getUint16(at + 32, true);
      const local = dv.getUint32(at + 42, true);
      const name = new TextDecoder().decode(u8.subarray(at + 46, at + 46 + nameLen));
      const start = local + 30 + dv.getUint16(local + 26, true) + dv.getUint16(local + 28, true);
      const raw = u8.subarray(start, start + csize);
      files.push({ name, bytes: method === 0 ? raw.slice() : await inflate(raw) });
      at += 46 + nameLen + extraLen + commentLen;
    }
    return files;
  }

  function zip(files) {
    const enc = new TextEncoder(), parts = [], central = [];
    let offset = 0;
    for (const f of files) {
      const name = enc.encode(f.name), crc = crc32(f.bytes), size = f.bytes.length;
      const head = new DataView(new ArrayBuffer(30));
      head.setUint32(0, 0x04034b50, true); head.setUint16(4, 20, true); head.setUint16(6, 0x0800, true);
      head.setUint16(8, 0, true); head.setUint16(10, 0, true); head.setUint16(12, 0x21, true);
      head.setUint32(14, crc, true); head.setUint32(18, size, true); head.setUint32(22, size, true);
      head.setUint16(26, name.length, true); head.setUint16(28, 0, true);
      parts.push(new Uint8Array(head.buffer), name, f.bytes);
      const c = new DataView(new ArrayBuffer(46));
      c.setUint32(0, 0x02014b50, true); c.setUint16(4, 20, true); c.setUint16(6, 20, true); c.setUint16(8, 0x0800, true);
      c.setUint16(10, 0, true); c.setUint16(12, 0, true); c.setUint16(14, 0x21, true);
      c.setUint32(16, crc, true); c.setUint32(20, size, true); c.setUint32(24, size, true);
      c.setUint16(28, name.length, true); c.setUint32(42, offset, true);
      central.push(new Uint8Array(c.buffer), name);
      offset += 30 + name.length + size;
    }
    const csize = central.reduce((a, p) => a + p.length, 0);
    const end = new DataView(new ArrayBuffer(22));
    end.setUint32(0, 0x06054b50, true); end.setUint16(8, files.length, true); end.setUint16(10, files.length, true);
    end.setUint32(12, csize, true); end.setUint32(16, offset, true);
    return new Blob([...parts, ...central, new Uint8Array(end.buffer)], { type: MIME });
  }

  class Doc {
    constructor(files) {
      this.files = files;
      this.main = files.find(f => f.name === 'word/document.xml');
      if (!this.main) throw new Error('Not a Word file.');
      this.xml = new TextDecoder().decode(this.main.bytes);
    }

    // Every "label ____" in the form, in order, takes the next value:
    // blanks('Phone', [coachPhone, assistantPhone]).  An empty value leaves
    // that blank alone.  not = text that must not sit right before the label
    // ("ail " keeps "Address" from matching "Email Address").
    blanks(label, values, { not = '' } = {}) {
      const re = new RegExp(`${not ? `(?<!${rx(esc(not))})` : ''}(${rx(esc(label))})([ \\t]*)_{2,}`, 'g');
      let n = 0;
      this.xml = this.xml.replace(re, (m, lab, gap) => {
        const v = values[n++];
        return v == null || String(v).trim() === '' ? m : `${lab}${gap || ' '}${esc(v)} `;
      });
      return this;
    }
    blank(label, value, opts) { return this.blanks(label, [value], opts); }

    // The text runs that are nothing but a long line of underscores, in order.
    lones(values) {
      let n = 0;
      this.xml = this.xml.replace(/>_{20,}</g, (m) => {
        const v = values[n++];
        return v == null || String(v).trim() === '' ? m : `>${esc(v)}<`;
      });
      return this;
    }

    swap(from, to) { this.xml = this.xml.replace(esc(from), esc(to)); return this; }

    _tables() { return this.xml.match(/<w:tbl>[\s\S]*?<\/w:tbl>/g) || []; }
    _setCell(table, rowIndex, cellIndex, value) {
      if (value == null || String(value).trim() === '') return this;
      const tbl = this._tables()[table]; if (!tbl) return this;
      const rows = tbl.match(/<w:tr[ >][\s\S]*?<\/w:tr>/g) || [], row = rows[rowIndex]; if (!row) return this;
      const cells = row.match(/<w:tc>[\s\S]*?<\/w:tc>/g) || [], cell = cells[cellIndex]; if (!cell) return this;
      // the run takes the paragraph's own look (font, size, bold) when it names one
      const look = (cell.match(/<w:pPr>[\s\S]*?(<w:rPr>[\s\S]*?<\/w:rPr>)[\s\S]*?<\/w:pPr>/) || [])[1] || '';
      const run = `<w:r>${look}<w:t xml:space="preserve">${esc(value)}</w:t></w:r>`;
      let filled;
      if (/<\/w:p>/.test(cell)) { const i = cell.lastIndexOf('</w:p>'); filled = cell.slice(0, i) + run + cell.slice(i); }
      else filled = cell.replace(/<w:p( [^>]*)?\/>/, (m, attrs) => `<w:p${attrs || ''}>${run}</w:p>`);
      this.xml = this.xml.replace(tbl, tbl.replace(row, row.replace(cell, filled)));
      return this;
    }
    cellAt(table, rowIndex, cellIndex, value) { return this._setCell(table, rowIndex, cellIndex, value); }
    // The row whose first cell reads rowLabel ("U12").
    cell(table, rowLabel, cellIndex, value) {
      const tbl = this._tables()[table]; if (!tbl) return this;
      const rows = tbl.match(/<w:tr[ >][\s\S]*?<\/w:tr>/g) || [];
      const text = (c) => (c.match(/<w:t[^>]*>[^<]*<\/w:t>/g) || []).map(t => t.replace(/<[^>]+>/g, '')).join('').trim();
      const at = rows.findIndex(r => text((r.match(/<w:tc>[\s\S]*?<\/w:tc>/) || [''])[0]) === rowLabel);
      return at < 0 ? this : this._setCell(table, at, cellIndex, value);
    }

    blob() {
      this.main.bytes = new TextEncoder().encode(this.xml);
      return zip(this.files);
    }
  }

  return {
    MIME,
    async open(buffer) { return new Doc(await unzip(buffer)); },
    // Blob → "data:…;base64,…" for a JSON upload.
    dataUrl(blob) {
      return new Promise((resolve, reject) => {
        const r = new FileReader();
        r.onload = () => resolve(String(r.result));
        r.onerror = () => reject(new Error('Could not read the form.'));
        r.readAsDataURL(blob);
      });
    },
  };
})();

window.DocxFill = DocxFill;
