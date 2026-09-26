// FilesScreen — #files — uploaded files, kept or shared (owner 2026-09-26:
// "can we have a file upload on footballhome where i can upload a file for
// you to look at? but also maybe to publish for others? like maybe a files
// button at top level with various options?").
//
// Backed by /api/files (backend/src/controllers/ClubFileController.cpp,
// migration 455).  The bytes live only in the DB; who sees a file is its
// visibility (file_visibilities): private (uploader + super — the slot for
// something Claude should look at), admins, members, public (anyone with
// the link).  Admins upload, retitle, change visibility and delete; every
// signed-in member sees the files shared with them.
//
// Top-level page for everyone (owner 2026-09-17: staff tools get dedicated
// pages; #my stays personal).  Page copy is message_templates kind='files'.
class FilesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.loading = false;
    this.error = null;
    this.flash = '';
    this.staged = [];       // { key, file, title, note, visibility, status, error }
    this.uploading = false;
    this.confirmDelete = 0; // id armed for a second tap
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fl-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase;
                  letter-spacing:0.05em; opacity:0.6; }
        .fl-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary);
                   padding:12px 14px; margin-bottom:var(--space-2); }
        .fl-drop { border:2px dashed var(--border-color); border-radius:12px; padding:18px; text-align:center; opacity:0.85;
                   display:flex; flex-direction:column; gap:10px; align-items:center; cursor:pointer; }
        .fl-drop.over { border-color:#4ade80; background:rgba(74,222,128,0.08); }
        .fl-btn { padding:8px 14px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.9rem;
                  color:#0b1c3d; background:#4ade80; }
        .fl-btn.alt { background:var(--primary-color); color:#fff; }
        .fl-btn.sm { padding:5px 10px; font-size:0.78rem; }
        .fl-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .fl-btn.danger { background:transparent; color:#f87171; border:1px solid #f87171; }
        .fl-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .fl-in { padding:8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary);
                 color:var(--text-primary); font-size:0.9rem; min-width:0; width:100%; }
        .fl-row { display:grid; grid-template-columns:44px 1fr; gap:10px; align-items:start; padding:10px 0;
                  border-top:1px solid var(--border-color); }
        .fl-row:first-child { border-top:none; }
        .fl-icon { font-size:1.8rem; line-height:44px; text-align:center; }
        .fl-title { font-weight:700; }
        .fl-meta { font-size:0.75rem; opacity:0.65; }
        .fl-note { font-size:0.85rem; opacity:0.85; margin-top:2px; white-space:pre-wrap; }
        .fl-acts { display:flex; flex-wrap:wrap; gap:6px; margin-top:8px; align-items:center; }
        .fl-pill { display:inline-block; padding:2px 8px; border-radius:999px; font-size:0.72rem; border:1px solid var(--border-color); }
        .fl-pill.private { border-color:#f59e0b; color:#f59e0b; }
        .fl-pill.admins  { border-color:#a78bfa; color:#a78bfa; }
        .fl-pill.members { border-color:#60a5fa; color:#60a5fa; }
        .fl-pill.public  { border-color:#4ade80; color:#4ade80; }
        .fl-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .fl-flash.bad { background:rgba(248,113,113,0.15); }
        .fl-stage { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-top:6px; }
        .fl-stage .wide { grid-column:1 / -1; }
        .fl-ok { color:#4ade80; font-weight:700; } .fl-bad { color:#f87171; font-weight:700; }
        @media (max-width: 640px) { .fl-stage { grid-template-columns:1fr; } }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>📁 Files</h1>
        <p class="subtitle" id="fl-subtitle"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div style="display:flex; justify-content:flex-end; margin-bottom:var(--space-2);">
          <button id="fl-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>
        <div id="fl-body"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter() { this.load(); }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('files', tier, tokens) : ''; }

  _wireEvents() {
    const el = this.element;
    el.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      if (e.target.closest('#fl-refresh')) { this.load(); return; }
      if (e.target.closest('#fl-upload-all')) { await this.uploadStaged(); return; }
      if (e.target.closest('#fl-clear')) { this.staged = []; this._renderBody(); return; }
      if (e.target.closest('.fl-drop') && !e.target.closest('input')) { this.find('#fl-pick').click(); return; }
      const rm = e.target.closest('[data-unstage]');
      if (rm) { this.staged = this.staged.filter(s => s.key !== rm.dataset.unstage); this._renderBody(); return; }
      const open = e.target.closest('[data-open]');
      if (open) { await this.open(Number(open.dataset.open), open.dataset.mode === 'download'); return; }
      const link = e.target.closest('[data-copy-link]');
      if (link) { await this.copyLink(Number(link.dataset.copyLink)); return; }
      const del = e.target.closest('[data-delete]');
      if (del) { await this.remove(Number(del.dataset.delete)); return; }
    });
    el.addEventListener('change', async (e) => {
      const pick = e.target.closest('#fl-pick');
      if (pick && pick.files && pick.files.length) { this._stage(Array.from(pick.files)); pick.value = ''; this._renderBody(); return; }
      const st = e.target.closest('[data-stage-field]');
      if (st) { const s = this.staged.find(x => x.key === st.dataset.key); if (s) s[st.dataset.stageField] = st.value; return; }
      const vis = e.target.closest('select[data-set-vis]');
      if (vis) { await this.update(Number(vis.dataset.setVis), { visibility: vis.value }); return; }
    });
    el.addEventListener('dragover', (e) => { const z = e.target.closest('.fl-drop'); if (z) { e.preventDefault(); z.classList.add('over'); } });
    el.addEventListener('dragleave', (e) => { const z = e.target.closest('.fl-drop'); if (z) z.classList.remove('over'); });
    el.addEventListener('drop', (e) => {
      const z = e.target.closest('.fl-drop');
      if (!z) return;
      e.preventDefault(); z.classList.remove('over');
      this._stage(Array.from(e.dataTransfer.files || []));
      this._renderBody();
    });
  }

  // ── data ──────────────────────────────────────────────────────────────

  async load() {
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/files/list');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
    } catch (err) {
      this.data = null;
      this.error = err.message || 'Failed to load.';
    }
    this.loading = false;
    const sub = this.find('#fl-subtitle');
    if (sub) sub.textContent = this._copy('subtitle');
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

  _maxMb() { return Math.floor((this.data?.max_bytes || 30 * 1024 * 1024) / (1024 * 1024)); }

  _stage(files) {
    const max = this.data?.max_bytes || 30 * 1024 * 1024;
    for (const file of files) {
      const tooBig = file.size > max;
      this.staged.push({
        key: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
        file, title: FilesScreen.titleFromFilename(file.name), note: '', visibility: 'private',
        status: tooBig ? 'error' : 'ready', error: tooBig ? `Over ${this._maxMb()} MB` : '',
      });
    }
  }

  static titleFromFilename(name) {
    return String(name || '').split('/').pop().replace(/\.[a-z0-9]{1,5}$/i, '').replace(/[-_]+/g, ' ').trim() || 'File';
  }

  _readAsDataUrl(file) {
    return new Promise((resolve, reject) => {
      const r = new FileReader();
      r.onload = () => resolve(r.result);
      r.onerror = () => reject(new Error('Could not read the file'));
      r.readAsDataURL(file);
    });
  }

  async uploadStaged() {
    if (this.uploading) return;
    const todo = this.staged.filter(s => s.status === 'ready' || s.status === 'error' && !/Over \d+ MB/.test(s.error));
    if (!todo.length) return;
    this.uploading = true;
    let ok = 0, bad = 0;
    for (const s of todo) {
      s.status = 'uploading'; s.error = '';
      this._renderBody();
      try {
        const dataUrl = await this._readAsDataUrl(s.file);
        await this._post('/api/files/upload', {
          file: dataUrl, filename: s.file.name, title: s.title, note: s.note, visibility: s.visibility,
        });
        s.status = 'done'; ok++;
      } catch (err) {
        s.status = 'error'; s.error = err.message || 'Upload failed'; bad++;
      }
    }
    this.uploading = false;
    this.flash = bad ? `✗ ${bad} failed, ${ok} uploaded.` : `✓ ${ok} uploaded.`;
    this.staged = this.staged.filter(s => s.status !== 'done');
    await this.load();
  }

  async update(id, fields) {
    try {
      await this._post('/api/files/update', { id, ...fields });
      this.flash = '✓ Saved.';
    } catch (err) {
      this.flash = `✗ ${err.message}`;
    }
    await this.load();
  }

  async remove(id) {
    if (this.confirmDelete !== id) { this.confirmDelete = id; this._renderBody(); return; }
    this.confirmDelete = 0;
    try {
      const res = await this.auth.fetch(`/api/files?id=${id}`, { method: 'DELETE' });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.flash = '✓ Deleted.';
    } catch (err) {
      this.flash = `✗ ${err.message}`;
    }
    await this.load();
  }

  _file(id) { return (this.data?.files || []).find(f => f.id === id); }

  _publicUrl(f) { return `${location.origin}/api/files/dl/${f.id}/${encodeURIComponent(f.filename)}`; }

  // Public files open by their plain link.  Everything else needs the bearer
  // token, so the page fetches the blob itself: the tab is opened first
  // (synchronously, so the popup blocker allows it) and pointed at the blob
  // once it arrives; a download uses an anchor instead.
  async open(id, download) {
    const f = this._file(id);
    if (!f) return;
    const inlineOk = f.inline_ok && !download;
    if (f.visibility === 'public') {
      const url = this._publicUrl(f) + (download ? '?download=1' : '');
      if (inlineOk) window.open(url, '_blank', 'noopener'); else location.href = url;
      return;
    }
    const tab = inlineOk ? window.open('', '_blank') : null;
    try {
      const res = await this.auth.fetch(`/api/files/dl/${f.id}/${encodeURIComponent(f.filename)}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      if (tab) { tab.location = url; }
      else {
        const a = document.createElement('a');
        a.href = url; a.download = f.filename; document.body.appendChild(a); a.click(); a.remove();
      }
      setTimeout(() => URL.revokeObjectURL(url), 60000);
    } catch (err) {
      if (tab) tab.close();
      this.flash = `✗ ${err.message}`;
      this._renderBody();
    }
  }

  async copyLink(id) {
    const f = this._file(id);
    if (!f) return;
    try {
      await navigator.clipboard.writeText(this._publicUrl(f));
      this.flash = this._copy('link_copied', { title: f.title }) || '✓ Link copied.';
    } catch (_e) {
      this.flash = this._publicUrl(f);
    }
    this._renderBody();
  }

  // ── render ────────────────────────────────────────────────────────────

  static fmtSize(n) {
    if (n >= 1024 * 1024) return `${(n / 1024 / 1024).toFixed(1)} MB`;
    if (n >= 1024) return `${Math.round(n / 1024)} KB`;
    return `${n} B`;
  }

  static icon(mime) {
    if (/^image\//.test(mime)) return '🖼️';
    if (/pdf/.test(mime)) return '📄';
    if (/spreadsheet|csv/.test(mime)) return '📊';
    if (/word|presentation/.test(mime)) return '📝';
    if (/^text\/|json/.test(mime)) return '📃';
    if (/zip/.test(mime)) return '🗜️';
    return '📎';
  }

  _visLabel(code) {
    const v = (this.data?.visibilities || []).find(x => x.code === code);
    return v ? v.label : code;
  }

  _renderBody() {
    const body = this.find('#fl-body');
    if (!body) return;
    const esc = (s) => this.escapeHtml(s);
    if (this.loading && !this.data) { body.innerHTML = '<p style="opacity:0.7;">Loading…</p>'; return; }
    if (this.error) { body.innerHTML = `<div class="fl-flash bad">✗ ${esc(this.error)}</div>`; return; }
    const d = this.data || { files: [], visibilities: [], can_manage: false };
    const vis = d.visibilities || [];
    const visOptions = (sel) => vis.map(v =>
      `<option value="${esc(v.code)}" ${v.code === sel ? 'selected' : ''} title="${esc(v.description)}">${esc(v.label)}</option>`).join('');
    let html = '';
    if (this.flash) { html += `<div class="fl-flash ${this.flash.startsWith('✗') ? 'bad' : ''}">${esc(this.flash)}</div>`; this.flash = ''; }

    if (d.can_manage) {
      html += `<div class="fl-sec">Add files</div>
        <div class="fl-card">
          <div class="fl-drop">
            <div style="font-size:2rem;">📤</div>
            <div>${esc(this._copy('drop_hint', { max_mb: String(this._maxMb()) }))}</div>
            <input id="fl-pick" type="file" multiple style="display:none;">
          </div>
          <div class="fl-meta" style="margin-top:8px;">${esc(this._copy('private_hint'))}</div>`;
      if (this.staged.length) {
        html += `<div style="margin-top:10px;">`;
        for (const s of this.staged) {
          const stat = s.status === 'done' ? '<span class="fl-ok">✓</span>'
                     : s.status === 'uploading' ? '⏳'
                     : s.status === 'error' ? `<span class="fl-bad">✗ ${esc(s.error)}</span>` : '';
          html += `<div class="fl-row">
            <div class="fl-icon">${FilesScreen.icon(s.file.type || '')}</div>
            <div>
              <div class="fl-meta">${esc(s.file.name)} · ${FilesScreen.fmtSize(s.file.size)} ${stat}</div>
              <div class="fl-stage">
                <input class="fl-in" data-stage-field="title" data-key="${s.key}" value="${esc(s.title)}" placeholder="Title">
                <select class="fl-in" data-stage-field="visibility" data-key="${s.key}">${visOptions(s.visibility)}</select>
                <input class="fl-in wide" data-stage-field="note" data-key="${s.key}" value="${esc(s.note)}" placeholder="Note (optional)">
              </div>
              <div class="fl-acts"><button class="fl-btn sm ghost" data-unstage="${s.key}">Remove</button></div>
            </div>
          </div>`;
        }
        html += `</div><div class="fl-acts" style="justify-content:flex-end;">
          <button class="fl-btn ghost" id="fl-clear" ${this.uploading ? 'disabled' : ''}>Clear</button>
          <button class="fl-btn" id="fl-upload-all" ${this.uploading ? 'disabled' : ''}>⬆️ Upload ${this.staged.length}</button>
        </div>`;
      }
      html += `</div>`;
    }

    html += `<div class="fl-sec">Files</div><div class="fl-card">`;
    const files = d.files || [];
    if (!files.length) {
      html += `<p style="opacity:0.7; margin:0;">${esc(this._copy(d.can_manage ? 'empty_admin' : 'empty_member'))}</p>`;
    }
    for (const f of files) {
      const date = String(f.created_at || '').slice(0, 10);
      const meta = [f.filename, FilesScreen.fmtSize(f.byte_size), date, f.uploader].filter(Boolean).map(esc).join(' · ');
      const pill = d.can_manage
        ? `<select class="fl-in" style="width:auto; padding:3px 6px; font-size:0.78rem;" data-set-vis="${f.id}">${visOptions(f.visibility)}</select>`
        : `<span class="fl-pill ${esc(f.visibility)}">${esc(this._visLabel(f.visibility))}</span>`;
      const delLabel = this.confirmDelete === f.id ? (this._copy('delete_confirm', { title: f.title }) || 'Tap again to delete') : 'Delete';
      html += `<div class="fl-row">
        <div class="fl-icon">${FilesScreen.icon(f.mime)}</div>
        <div>
          <div class="fl-title">${esc(f.title)}</div>
          <div class="fl-meta">${meta}</div>
          ${f.note ? `<div class="fl-note">${esc(f.note)}</div>` : ''}
          <div class="fl-acts">
            ${f.inline_ok ? `<button class="fl-btn sm alt" data-open="${f.id}" data-mode="inline">Open</button>` : ''}
            <button class="fl-btn sm ghost" data-open="${f.id}" data-mode="download">⬇️ Download</button>
            ${f.visibility === 'public' ? `<button class="fl-btn sm ghost" data-copy-link="${f.id}">🔗 Copy link</button>` : ''}
            ${pill}
            ${d.can_manage ? `<button class="fl-btn sm danger" data-delete="${f.id}">${esc(delLabel)}</button>` : ''}
          </div>
        </div>
      </div>`;
    }
    html += `</div>`;
    body.innerHTML = html;
  }
}
