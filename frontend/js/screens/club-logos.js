// ClubLogosScreen — #logos — club crests, ours and every opponent's
// (owner 2026-09-25: "make a logo upload that i can upload a folder and it
// will have name of club in file names … it should also accept a url and
// then capture that logo … all logos need to be saved in db and normalized
// with club").
//
// Backed by /api/club-logos (backend/src/controllers/ClubLogoController.cpp,
// migration 428).  Three jobs on one page:
//   1. Add logos — pick a folder (or files, or drop them); each file name
//      becomes the club name ("fishtown-ac.png" → "Fishtown AC"), matched
//      against the clubs table or created as a new club.  Or paste an
//      image URL and the backend captures it.
//   2. Opponents with no crest — every Opponent: text on the calendar that
//      nothing resolves yet; link it to a club (alias) or upload for it.
//   3. Clubs with logos — what is stored, its aliases, replace / add alias.
//   4. Found online — the automatic web search (mig 432): a new opponent
//      text nothing matches gets searched once; what it finds is published
//      straight away (owner 2026-09-25: "i am fine with publish we can
//      always fix") and listed here with a Reject button.
//
// Top-level admin page (owner 2026-09-17: staff tools get dedicated pages).
class ClubLogosScreen extends Screen {
  static KEEP_UPPER = new Set(['FC', 'SC', 'AC', 'CF', 'AFC', 'SCM', 'SCR', 'KSC', 'NJ', 'NY', 'PA', 'CT', 'USA', 'II', 'III', 'IV']);

  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.loading = false;
    this.error = null;
    this.flash = '';
    this.staged = [];      // { key, file, previewUrl, name, clubId, status, error }
    this.uploading = false;
  }

  // "german-american_kickers.PNG" → "German American Kickers"
  static nameFromFilename(filename) {
    let base = String(filename || '').split('/').pop().replace(/\.[a-z0-9]{2,5}$/i, '');
    base = base.replace(/[-_.+]+/g, ' ').replace(/\b(logo|crest|badge)\b/ig, '').replace(/\s+/g, ' ').trim();
    if (!base) return '';
    return base.split(' ').map(w => {
      const up = w.toUpperCase();
      if (ClubLogosScreen.KEEP_UPPER.has(up)) return up;
      if (w === up && w.length <= 3) return up;                  // an acronym typed as such
      return w.charAt(0).toUpperCase() + w.slice(1).toLowerCase();
    }).join(' ');
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cl-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase;
                  letter-spacing:0.05em; opacity:0.6; }
        .cl-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary);
                   padding:12px 14px; margin-bottom:var(--space-2); }
        .cl-drop { border:2px dashed var(--border-color); border-radius:12px; padding:18px; text-align:center; opacity:0.85;
                   display:flex; flex-direction:column; gap:10px; align-items:center; }
        .cl-drop.over { border-color:#4ade80; background:rgba(74,222,128,0.08); }
        .cl-btn { padding:8px 14px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.9rem;
                  color:#0b1c3d; background:#4ade80; }
        .cl-btn.alt { background:var(--primary-color); color:#fff; }
        .cl-btn.sm { padding:5px 10px; font-size:0.78rem; }
        .cl-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .cl-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .cl-in { padding:8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary);
                 color:var(--text-primary); font-size:0.9rem; min-width:0; }
        .cl-row { display:grid; grid-template-columns:56px 1fr auto; gap:10px; align-items:center; padding:8px 0;
                  border-top:1px solid var(--border-color); }
        .cl-row:first-child { border-top:none; }
        .cl-thumb { width:56px; height:56px; object-fit:contain; border-radius:8px; background:#fff; border:1px solid var(--border-color); }
        .cl-thumb.empty { display:flex; align-items:center; justify-content:center; opacity:0.4; font-size:1.4rem; }
        .cl-meta { font-size:0.75rem; opacity:0.65; }
        .cl-ok { color:#4ade80; font-weight:700; } .cl-bad { color:#f87171; font-weight:700; }
        .cl-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(230px, 1fr)); gap:var(--space-2); }
        .cl-grid .cl-card { margin:0; display:flex; flex-direction:column; gap:6px; }
        .cl-grid .cl-thumb { width:88px; height:88px; align-self:center; }
        .cl-pill { display:inline-block; padding:2px 8px; border-radius:999px; font-size:0.72rem; border:1px solid var(--border-color);
                   margin:2px 2px 0 0; }
        .cl-pill button { border:none; background:none; color:inherit; cursor:pointer; opacity:0.6; padding:0 0 0 4px; }
        .cl-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .cl-flash.bad { background:rgba(248,113,113,0.15); }
        .cl-url { display:grid; grid-template-columns:1fr 2fr auto; gap:8px; }
        @media (max-width: 640px) { .cl-url { grid-template-columns:1fr; } .cl-row { grid-template-columns:48px 1fr; } .cl-row > :last-child { grid-column:1 / -1; } }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🛡️ Club Logos</h1>
        <p class="subtitle">Upload a folder of opponent crests named after the club, or capture one from a URL — every logo is stored against its club and shows on #my and Game Center</p>
      </div>
      <div style="padding: var(--space-4); max-width: 1000px; margin: 0 auto;">
        <div style="display:flex; justify-content:flex-end; margin-bottom:var(--space-2);">
          <button id="cl-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>
        <div id="cl-body"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter() { this.load(); }

  _wireEvents() {
    const el = this.element;
    el.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      if (e.target.closest('#cl-refresh')) { this.load(); return; }
      if (e.target.closest('#cl-upload-all')) { await this.uploadStaged(); return; }
      if (e.target.closest('#cl-clear')) { this._clearStaged(); this._renderBody(); return; }
      const rm = e.target.closest('[data-unstage]');
      if (rm) { this._unstage(rm.dataset.unstage); this._renderBody(); return; }
      if (e.target.closest('#cl-url-go')) { await this.captureUrl(); return; }
      const link = e.target.closest('[data-link-opp]');
      if (link) { await this.linkOpponent(link.dataset.linkOpp); return; }
      const find = e.target.closest('[data-find-opp]');
      if (find) { await this.findOnline(find.dataset.findOpp); return; }
      const rej = e.target.closest('[data-reject-search]');
      if (rej) { await this.rejectSearch(Number(rej.dataset.rejectSearch)); return; }
      const upFor = e.target.closest('[data-upload-for]');
      if (upFor) { this._openPickerFor(upFor.dataset.uploadFor); return; }
      const addAlias = e.target.closest('[data-add-alias]');
      if (addAlias) { await this.addAlias(Number(addAlias.dataset.addAlias)); return; }
      const delAlias = e.target.closest('[data-del-alias]');
      if (delAlias) { await this.removeAlias(Number(delAlias.dataset.delAlias)); return; }
    });
    el.addEventListener('change', async (e) => {
      const files = e.target.closest('input[type=file][data-stage]');
      if (files && files.files && files.files.length) {
        await this._stageFiles(Array.from(files.files), files.dataset.forClub || '');
        files.value = '';
        this._renderBody();
        return;
      }
      const replace = e.target.closest('input[type=file][data-replace]');
      if (replace && replace.files && replace.files[0]) {
        await this.replaceLogo(Number(replace.dataset.replace), replace.files[0]);
        return;
      }
      const nameIn = e.target.closest('input[data-stage-name]');
      if (nameIn) { const s = this._staged(nameIn.dataset.stageName); if (s) { s.name = nameIn.value; s.clubId = this._matchClub(s.name); } this._renderBody(); return; }
      const clubSel = e.target.closest('select[data-stage-club]');
      if (clubSel) { const s = this._staged(clubSel.dataset.stageClub); if (s) s.clubId = clubSel.value ? Number(clubSel.value) : 0; return; }
    });
    el.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter' && e.target.closest('#cl-url')) { e.preventDefault(); await this.captureUrl(); }
    });
    // Drop a folder or files anywhere on the drop zone.
    el.addEventListener('dragover', (e) => { const z = e.target.closest('.cl-drop'); if (z) { e.preventDefault(); z.classList.add('over'); } });
    el.addEventListener('dragleave', (e) => { const z = e.target.closest('.cl-drop'); if (z) z.classList.remove('over'); });
    el.addEventListener('drop', async (e) => {
      const z = e.target.closest('.cl-drop');
      if (!z) return;
      e.preventDefault(); z.classList.remove('over');
      const files = await this._filesFromDrop(e.dataTransfer);
      await this._stageFiles(files, '');
      this._renderBody();
    });
  }

  // ── data ──────────────────────────────────────────────────────────────

  async load() {
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      const res = await this.auth.fetch('/api/club-logos/board');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      for (const s of this.staged) if (!s.clubId) s.clubId = this._matchClub(s.name);
    } catch (err) {
      this.data = null;
      this.error = err.message || 'Failed to load.';
    }
    this.loading = false;
    this._renderBody();
  }

  async _post(path, payload) {
    const res = await this.auth.fetch(path, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  _matchClub(name) {
    const key = String(name || '').trim().toLowerCase();
    if (!key || !this.data) return 0;
    const hits = (this.data.all_clubs || []).filter(c => c.name.trim().toLowerCase() === key);
    if (!hits.length) return 0;
    return (hits.find(c => c.has_logo) || hits[0]).id;
  }

  // ── staging files ─────────────────────────────────────────────────────

  _staged(key) { return this.staged.find(s => s.key === key); }
  _unstage(key) { const s = this._staged(key); if (s) URL.revokeObjectURL(s.previewUrl); this.staged = this.staged.filter(x => x.key !== key); }
  _clearStaged() { for (const s of this.staged) URL.revokeObjectURL(s.previewUrl); this.staged = []; }

  async _filesFromDrop(dt) {
    const out = [];
    const items = dt.items ? Array.from(dt.items) : [];
    const walk = async (entry) => {
      if (entry.isFile) { await new Promise(r => entry.file(f => { out.push(f); r(); }, () => r())); return; }
      if (entry.isDirectory) {
        const reader = entry.createReader();
        const batch = await new Promise(r => reader.readEntries(r, () => r([])));
        for (const child of batch) await walk(child);
      }
    };
    for (const it of items) {
      const entry = it.webkitGetAsEntry ? it.webkitGetAsEntry() : null;
      if (entry) await walk(entry);
      else if (it.kind === 'file') { const f = it.getAsFile(); if (f) out.push(f); }
    }
    if (!out.length && dt.files) out.push(...Array.from(dt.files));
    return out;
  }

  async _stageFiles(files, forClubName) {
    const images = files.filter(f => /^image\//.test(f.type) || /\.(png|jpe?g|webp|gif|svg)$/i.test(f.name));
    for (const file of images) {
      const name = forClubName || ClubLogosScreen.nameFromFilename(file.name);
      this.staged.push({
        key: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
        file, previewUrl: URL.createObjectURL(file), name,
        clubId: this._matchClub(name), status: 'ready', error: '',
      });
    }
    if (files.length && !images.length) this.flash = '✗ None of those files were images.';
  }

  _openPickerFor(clubName) {
    const input = document.createElement('input');
    input.type = 'file'; input.accept = 'image/*';
    input.addEventListener('change', async () => {
      if (input.files && input.files[0]) { await this._stageFiles([input.files[0]], clubName); this._renderBody(); }
    });
    input.click();
  }

  // Original bytes when small enough (PNG transparency survives); otherwise
  // a PNG re-draw at 600 px.  Never JPEG — crests need their alpha.
  async _fileToDataUrl(file) {
    if (file.size <= 1.5 * 1024 * 1024) {
      return new Promise((resolve, reject) => {
        const r = new FileReader();
        r.onload = () => resolve(r.result);
        r.onerror = () => reject(new Error('Could not read the file'));
        r.readAsDataURL(file);
      });
    }
    const bitmap = await createImageBitmap(file);
    const scale = Math.min(1, 600 / Math.max(bitmap.width, bitmap.height));
    const canvas = document.createElement('canvas');
    canvas.width = Math.round(bitmap.width * scale);
    canvas.height = Math.round(bitmap.height * scale);
    canvas.getContext('2d').drawImage(bitmap, 0, 0, canvas.width, canvas.height);
    if (bitmap.close) bitmap.close();
    return canvas.toDataURL('image/png');
  }

  async uploadStaged() {
    if (this.uploading) return;
    const todo = this.staged.filter(s => s.status !== 'done');
    if (!todo.length) return;
    this.uploading = true;
    let ok = 0, bad = 0;
    for (const s of todo) {
      if (!s.name.trim() && !s.clubId) { s.status = 'error'; s.error = 'Give it a club name'; bad++; this._renderBody(); continue; }
      s.status = 'uploading'; s.error = '';
      this._renderBody();
      try {
        const image = await this._fileToDataUrl(s.file);
        const payload = { image, filename: s.file.name };
        if (s.clubId) payload.club_id = s.clubId; else payload.club_name = s.name.trim();
        const body = await this._post('/api/club-logos/upload', payload);
        s.status = 'done'; s.error = body.created_club ? 'new club' : '';
        ok++;
      } catch (err) {
        s.status = 'error'; s.error = err.message || 'failed'; bad++;
      }
      this._renderBody();
    }
    this.uploading = false;
    this.flash = bad ? `✗ ${ok} stored, ${bad} failed — see the rows below.` : `${ok} logo${ok === 1 ? '' : 's'} stored.`;
    await this.load();
  }

  async captureUrl() {
    const nameEl = this.find('#cl-url-name'), urlEl = this.find('#cl-url');
    const name = (nameEl?.value || '').trim(), url = (urlEl?.value || '').trim();
    if (!url) { this.flash = '✗ Paste the image URL first.'; this._renderBody(); return; }
    if (!name) { this.flash = '✗ Which club is it for?'; this._renderBody(); return; }
    this.flash = `Capturing ${url}…`; this._renderBody();
    try {
      const payload = { url };
      const id = this._matchClub(name);
      if (id) payload.club_id = id; else payload.club_name = name;
      const body = await this._post('/api/club-logos/from-url', payload);
      this.flash = `Stored the crest for ${name}${body.created_club ? ' (new club)' : ''}.`;
    } catch (err) {
      this.flash = `✗ ${err.message || 'Capture failed.'}`;
    }
    await this.load();
  }

  async linkOpponent(opponent) {
    const sel = this.find(`select[data-opp-club="${CSS.escape(opponent)}"]`);
    const clubId = sel && sel.value ? Number(sel.value) : 0;
    if (!clubId) { this.flash = `✗ Pick the club "${opponent}" means first.`; this._renderBody(); return; }
    try {
      await this._post('/api/club-logos/alias', { alias: opponent, club_id: clubId });
      this.flash = `"${opponent}" now shows that club's crest.`;
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not link.'}`;
    }
    await this.load();
  }

  async findOnline(opponent) {
    try {
      await this._post('/api/club-logos/search', { opponent });
      this.flash = `Searching the web for "${opponent}" — takes a minute or two; refresh to see the result.`;
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not start the search.'}`;
    }
    await this.load();
  }

  async rejectSearch(id) {
    try {
      await this._post('/api/club-logos/search/reject', { id });
      this.flash = 'Thrown out. The club is back to its previous crest, or none — upload the right one below.';
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not reject.'}`;
    }
    await this.load();
  }

  async addAlias(clubId) {
    const input = this.find(`input[data-alias-for="${clubId}"]`);
    const alias = (input?.value || '').trim();
    if (!alias) return;
    try {
      await this._post('/api/club-logos/alias', { alias, club_id: clubId });
      this.flash = `Added "${alias}".`;
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not add the alias.'}`;
    }
    await this.load();
  }

  async removeAlias(aliasId) {
    try {
      const res = await this.auth.fetch(`/api/club-logos/alias?id=${aliasId}`, { method: 'DELETE' });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not remove the alias.'}`;
    }
    await this.load();
  }

  async replaceLogo(clubId, file) {
    this.flash = 'Storing the new crest…'; this._renderBody();
    try {
      const image = await this._fileToDataUrl(file);
      await this._post('/api/club-logos/upload', { club_id: clubId, image, filename: file.name });
      this.flash = 'Crest replaced.';
    } catch (err) {
      this.flash = `✗ ${err.message || 'Upload failed.'}`;
    }
    await this.load();
  }

  // ── render ────────────────────────────────────────────────────────────

  _clubOptions(selectedId, { allowNew } = {}) {
    const all = (this.data && this.data.all_clubs) || [];
    const opts = all.map(c => `<option value="${c.id}" ${c.id === selectedId ? 'selected' : ''}>${this.escapeHtml(c.name)}${c.has_logo ? ' ✓' : ''}</option>`);
    return `<option value="" ${!selectedId ? 'selected' : ''}>${allowNew ? '— new club with this name —' : '— pick a club —'}</option>${opts.join('')}`;
  }

  _stagedRows() {
    if (!this.staged.length) return '';
    const rows = this.staged.map(s => {
      const st = s.status === 'done' ? `<span class="cl-ok">✓ stored${s.error ? ' · ' + this.escapeHtml(s.error) : ''}</span>`
               : s.status === 'uploading' ? '<span style="opacity:0.7;">uploading…</span>'
               : s.status === 'error' ? `<span class="cl-bad">✗ ${this.escapeHtml(s.error)}</span>`
               : `<button class="cl-btn ghost sm" data-unstage="${s.key}">remove</button>`;
      const busy = this.uploading || s.status === 'done';
      return `
        <div class="cl-row">
          <img class="cl-thumb" src="${s.previewUrl}" alt="">
          <div style="display:grid; grid-template-columns:1fr 1fr; gap:6px; min-width:0;">
            <input class="cl-in" data-stage-name="${s.key}" value="${this.escapeHtml(s.name)}" placeholder="Club name" ${busy ? 'disabled' : ''}>
            <select class="cl-in" data-stage-club="${s.key}" ${busy ? 'disabled' : ''}>${this._clubOptions(s.clubId, { allowNew: true })}</select>
            <div class="cl-meta" style="grid-column:1 / -1;">${this.escapeHtml(s.file.name)} · ${Math.round(s.file.size / 1024)} KB</div>
          </div>
          <div>${st}</div>
        </div>`;
    }).join('');
    const pending = this.staged.filter(s => s.status !== 'done').length;
    return `
      <div class="cl-card">
        ${rows}
        <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:10px; flex-wrap:wrap;">
          <button class="cl-btn ghost" id="cl-clear" ${this.uploading ? 'disabled' : ''}>Clear</button>
          <button class="cl-btn" id="cl-upload-all" ${this.uploading || !pending ? 'disabled' : ''}>⬆ Store ${pending} logo${pending === 1 ? '' : 's'}</button>
        </div>
      </div>`;
  }

  _searchFor(opponent) {
    const key = String(opponent).trim().toLowerCase();
    return ((this.data && this.data.searches) || []).find(s => s.opponent.trim().toLowerCase() === key) || null;
  }

  _searchBadge(sr) {
    if (!sr) return '';
    const map = {
      queued:   ['⏳ web search queued', 'opacity:0.7;'],
      running:  ['🔎 searching the web…', 'opacity:0.7;'],
      none:     [`🌐 searched — nothing usable${sr.judge_note ? ': ' + sr.judge_note : sr.reason ? ': ' + sr.reason : ''}`, 'color:#facc15;'],
      failed:   [`⚠ search failed${sr.error ? ': ' + sr.error : ''}`, 'color:#f87171;'],
      rejected: ['🚫 found crest was rejected', 'opacity:0.7;'],
      found:    ['✓ found online', 'color:#4ade80;'],
    };
    const [label, style] = map[sr.status] || [sr.status, ''];
    return `<div class="cl-meta" style="${style}">${this.escapeHtml(label)}</div>`;
  }

  _unresolved() {
    const list = (this.data && this.data.unresolved) || [];
    if (!list.length) return '<p style="opacity:0.6;">Every opponent on the calendar has a crest.</p>';
    return `<div class="cl-card">${list.map(u => `
      <div class="cl-row">
        <div class="cl-thumb empty">?</div>
        <div style="min-width:0;">
          <div><strong>${this.escapeHtml(u.opponent)}</strong></div>
          <div class="cl-meta">${u.games} game${u.games === 1 ? '' : 's'} · last ${this.escapeHtml(u.last_label)}</div>
          ${this._searchBadge(this._searchFor(u.opponent))}
          <div style="display:flex; gap:6px; margin-top:6px; flex-wrap:wrap;">
            <select class="cl-in" data-opp-club="${this.escapeHtml(u.opponent)}" style="flex:1; min-width:180px;">${this._clubOptions(this._matchClub(u.opponent))}</select>
            <button class="cl-btn alt sm" data-link-opp="${this.escapeHtml(u.opponent)}">Link</button>
          </div>
        </div>
        <div style="display:flex; flex-direction:column; gap:6px;">
          <button class="cl-btn sm" data-upload-for="${this.escapeHtml(u.opponent)}">⬆ Upload logo</button>
          ${['queued', 'running'].includes((this._searchFor(u.opponent) || {}).status) ? '' : `<button class="cl-btn ghost sm" data-find-opp="${this.escapeHtml(u.opponent)}">🌐 Find online</button>`}
        </div>
      </div>`).join('')}</div>`;
  }

  _foundOnline() {
    const list = ((this.data && this.data.searches) || []).filter(s => s.status === 'found');
    if (!list.length) return '';
    return `
      <div class="cl-sec">Found online — published, throw out any that are wrong</div>
      <div class="cl-card">${list.map(sr => `
        <div class="cl-row">
          ${sr.logo_url && sr.is_current ? `<img class="cl-thumb" src="${this.escapeHtml(sr.logo_url)}" alt="">` : '<div class="cl-thumb empty">?</div>'}
          <div style="min-width:0;">
            <div><strong>${this.escapeHtml(sr.opponent)}</strong> → ${this.escapeHtml(sr.club_name || sr.club_name_found)}</div>
            <div class="cl-meta">${this.escapeHtml(sr.reason || '')}${sr.judge_note ? ' · ' + this.escapeHtml(sr.judge_note) : ''}</div>
            <div class="cl-meta">${sr.when_label ? this.escapeHtml(sr.when_label) + ' · ' : ''}${sr.automatic ? 'automatic' : 'asked for'} · confidence ${Math.round((sr.confidence || 0) * 100)}%
              ${sr.page_url ? ` · <a href="${this.escapeHtml(sr.page_url)}" target="_blank" rel="noopener">source page</a>` : ''}
              ${!sr.is_current ? ' · <span style="opacity:0.7;">since replaced</span>' : ''}</div>
          </div>
          <button class="cl-btn ghost sm" data-reject-search="${sr.id}">🚫 Reject</button>
        </div>`).join('')}</div>`;
  }

  _clubCards() {
    const clubs = (this.data && this.data.clubs) || [];
    if (!clubs.length) return '<p style="opacity:0.6;">No logos stored yet.</p>';
    return `<div class="cl-grid">${clubs.map(c => {
      const src = c.source === 'url' ? `captured from URL` : c.source === 'upload' ? `uploaded${c.original_filename ? ' · ' + c.original_filename : ''}` : c.source === 'search' ? 'found online' : c.source === 'legacy' ? 'imported' : 'not stored yet';
      const aliases = (c.aliases || []).map(a => `<span class="cl-pill">${this.escapeHtml(a.alias)}<button data-del-alias="${a.id}" title="Remove">×</button></span>`).join('');
      return `
        <div class="cl-card">
          ${c.logo_url ? `<img class="cl-thumb" src="${this.escapeHtml(c.logo_url)}" alt="">` : '<div class="cl-thumb empty">?</div>'}
          <div style="text-align:center;"><strong>${this.escapeHtml(c.name)}</strong></div>
          <div class="cl-meta" style="text-align:center;">${this.escapeHtml(src)}${c.uploaded_label ? ' · ' + this.escapeHtml(c.uploaded_label) : ''}${c.team_count ? ` · ${c.team_count} team${c.team_count === 1 ? '' : 's'}` : ''}</div>
          <div>${aliases}</div>
          <div style="display:flex; gap:6px;">
            <input class="cl-in" data-alias-for="${c.id}" placeholder="Also known as…" style="flex:1;">
            <button class="cl-btn alt sm" data-add-alias="${c.id}">Add</button>
          </div>
          <label class="cl-btn ghost sm" style="text-align:center; cursor:pointer;">↻ Replace logo
            <input type="file" accept="image/*" data-replace="${c.id}" hidden>
          </label>
        </div>`;
    }).join('')}</div>`;
  }

  _renderBody() {
    const el = this.find('#cl-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<p style="opacity:0.6;">Loading…</p>'; return; }
    if (this.error) { el.innerHTML = `<div class="cl-flash bad">${this.escapeHtml(this.error)}</div>`; return; }
    const flash = this.flash ? `<div class="cl-flash ${this.flash.startsWith('✗') ? 'bad' : ''}">${this.escapeHtml(this.flash)}</div>` : '';
    el.innerHTML = `
      ${flash}
      <div class="cl-sec">Add logos</div>
      <div class="cl-drop">
        <div>Drop a folder of crests here — the file name is the club name (<code>fishtown-ac.png</code> → Fishtown AC)</div>
        <div style="display:flex; gap:8px; flex-wrap:wrap; justify-content:center;">
          <label class="cl-btn" style="cursor:pointer;">📁 Pick a folder<input type="file" data-stage multiple webkitdirectory directory hidden></label>
          <label class="cl-btn alt" style="cursor:pointer;">🖼 Pick files<input type="file" data-stage multiple accept="image/*" hidden></label>
        </div>
      </div>
      ${this._stagedRows()}
      <div class="cl-card" style="margin-top:var(--space-2);">
        <div class="cl-meta" style="margin-bottom:6px;">Or capture a logo from the web — the image's own address (right-click → Copy image address)</div>
        <div class="cl-url">
          <input class="cl-in" id="cl-url-name" placeholder="Club name" list="cl-club-names">
          <input class="cl-in" id="cl-url" placeholder="https://…/crest.png" inputmode="url">
          <button class="cl-btn" id="cl-url-go">⬇ Capture</button>
        </div>
        <datalist id="cl-club-names">${((this.data && this.data.all_clubs) || []).map(c => `<option value="${this.escapeHtml(c.name)}">`).join('')}</datalist>
      </div>
      <div class="cl-sec">Opponents on the calendar with no crest</div>
      ${this._unresolved()}
      ${this._foundOnline()}
      <div class="cl-sec">Clubs with logos</div>
      ${this._clubCards()}
    `;
  }
}
