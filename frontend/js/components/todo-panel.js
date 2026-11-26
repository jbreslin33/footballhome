// TodoPanel — ✅ the person's own to-do list, in the 🚦 band's popup (mig 1570).
//
// Owner 2026-11-19: "i need a todo all my screens lol. so its like a reminer
// every time i oepn app lol".  The band shows a red "✅ To do — …  Open ›"
// box while anything is due; this is what Open (or ☰ ✅ To do) shows:
//
//   [Remind me to…                    ] [Now ▾] [➕ Add]
//   Due now   · Email leads …                 [✓ Done] [✕]
//   Later     · Call ref assignor  shows Fri 9:00 AM   [✓ Done] [✕]
//   Done      · ~~Order kits~~                 [↩ Undo]
//
// "When": Now · Tomorrow 9 AM · Pick a time… (datetime-local, the device's
// own time zone, sent as ISO).  Words: event_center todo_* rows.
//
// 📷 mig 1944: a photo_proof item is ticked by uploading the day's photo
// (shrunk on the phone first); call_at shows "📞 a call at 1 PM if no photo";
// guide_id adds a 📖 Routine toggle that opens the routine under the item.
//
//   const p = new TodoPanel(el, { fetchJson, escapeHtml, onChange(list) });
//   p.load();   p.render();
class TodoPanel {
  constructor(el, ctx) {
    this.el = el;
    this.ctx = ctx;
    this.data = { todos: [], due: 0 };
    this.busy = false;
    this.err = '';
    this.when = 'now';
    this.guides = {};        // guide_id → {guide} once fetched
    this.openGuide = null;   // the item id whose routine is showing
    this.thumbs = {};        // photo_id → object URL
    this.uploading = null;   // the item id being uploaded
    if (el) {
      el.addEventListener('click', (e) => this.onClick(e));
      el.addEventListener('change', (e) => {
        if (e.target.matches('[data-td-when]')) { this.when = e.target.value; this.render(); }
        const ph = e.target.closest('input[data-td-photo]');
        if (ph && ph.files && ph.files[0]) { const f = ph.files[0]; ph.value = ''; this.uploadPhoto(Number(ph.getAttribute('data-td-photo')), f); }
      });
      el.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && e.target.matches('[data-td-body]')) { e.preventDefault(); this.add(); }
      });
    }
  }

  static cp(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
      ? MessageCopy.block('event_center', tier, tokens) : fb;
  }

  async load() {
    try { this.set(await this.ctx.fetchJson('/api/my/todos')); }
    catch (_) { /* the band just shows no box */ }
  }

  set(data) {
    this.data = data && Array.isArray(data.todos) ? data : { todos: [], due: 0 };
    this.render();
    if (this.ctx.onChange) this.ctx.onChange(this.data);
  }

  dueItems() { return this.data.todos.filter(t => t.due); }

  remindAtIso() {
    if (this.when === 'morning') {
      const d = new Date();
      d.setDate(d.getDate() + 1);
      d.setHours(9, 0, 0, 0);
      return d.toISOString();
    }
    if (this.when === 'pick') {
      const v = this.el.querySelector('[data-td-at]')?.value;
      return v ? new Date(v).toISOString() : '';
    }
    return '';
  }

  async post(payload) {
    if (this.busy) return;
    this.busy = true; this.err = ''; this.render();
    try { this.set(await this.ctx.fetchJson('/api/my/todos', { method: 'POST', body: JSON.stringify(payload) })); }
    catch (e) { this.err = e.message || 'Could not save'; }
    finally { this.busy = false; this.render(); }
  }

  add() {
    const input = this.el.querySelector('[data-td-body]');
    const body = (input?.value || '').trim();
    if (!body) { input?.focus(); return; }
    if (this.when === 'pick' && !this.el.querySelector('[data-td-at]')?.value) {
      this.el.querySelector('[data-td-at]')?.focus();
      return;
    }
    input.value = '';
    this.draft = '';
    this.post({ action: 'add', body, remind_at: this.remindAtIso() }).then(() => {
      if (this.err) this.draft = body;   // failed — keep what was typed
      else this.when = 'now';
      this.render();
      this.el.querySelector('[data-td-body]')?.focus();
    });
  }

  onClick(e) {
    if (e.target.closest('[data-td-add]')) { this.add(); return; }
    const gb = e.target.closest('[data-td-guide]');
    if (gb) { this.toggleGuide(Number(gb.getAttribute('data-td-guide')), Number(gb.getAttribute('data-td-guide-id'))); return; }
    const b = e.target.closest('[data-td-act]');
    if (b) this.post({ action: b.getAttribute('data-td-act'), id: Number(b.getAttribute('data-td-id')) });
  }

  // A camera shot → a JPEG data URL, longest side 1600 px (fast on a phone).
  static readPhoto(file) {
    const asDataUrl = (blob) => new Promise((res, rej) => {
      const r = new FileReader(); r.onload = () => res(r.result); r.onerror = () => rej(new Error('Could not read the photo')); r.readAsDataURL(blob);
    });
    if (!/^image\/(jpeg|png|webp)$/.test(file.type) || file.size < 800 * 1024) return asDataUrl(file);
    return new Promise((resolve) => {
      const url = URL.createObjectURL(file);
      const img = new Image();
      img.onload = () => {
        const k = Math.min(1, 1600 / Math.max(img.width, img.height));
        const c = document.createElement('canvas');
        c.width = Math.round(img.width * k); c.height = Math.round(img.height * k);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);
        resolve(c.toDataURL('image/jpeg', 0.85));
      };
      img.onerror = () => { URL.revokeObjectURL(url); asDataUrl(file).then(resolve); };
      img.src = url;
    });
  }

  async uploadPhoto(id, file) {
    if (!id || this.busy) return;
    this.uploading = id; this.render();
    try {
      const data = await TodoPanel.readPhoto(file);
      await this.post({ action: 'photo', id, file: data });
    } catch (e) { this.err = e.message || 'Could not upload'; }
    finally { this.uploading = null; this.render(); }
  }

  async toggleGuide(id, guideId) {
    this.openGuide = this.openGuide === id ? null : id;
    this.render();
    if (this.openGuide && guideId && !this.guides[guideId]) {
      try { this.guides[guideId] = (await this.ctx.fetchJson(`/api/my/todo-guide?id=${guideId}`)).guide; }
      catch (e) { this.guides[guideId] = { error: e.message || 'Could not load the routine' }; }
      this.render();
    }
  }

  // Today's photo as a thumbnail — fetched with the app's auth (a bearer
  // token never rides on a plain <img src>).
  loadThumb(photoId) {
    if (!photoId || this.thumbs[photoId] !== undefined) return;
    this.thumbs[photoId] = null;
    const auth = window.app && window.app.auth;
    if (!auth || !auth.fetch) return;
    auth.fetch(`/api/my/todo-photo?id=${photoId}`)
      .then(r => (r.ok ? r.blob() : null))
      .then(b => { if (b) { this.thumbs[photoId] = URL.createObjectURL(b); this.render(); } })
      .catch(() => {});
  }

  fmtClock(hhmm) {
    const [h, m] = String(hhmm || '').split(':').map(Number);
    if (!Number.isFinite(h)) return hhmm || '';
    const d = new Date(); d.setHours(h, m || 0, 0, 0);
    return d.toLocaleTimeString([], { hour: 'numeric', minute: m ? '2-digit' : undefined });
  }

  guideHtml(g) {
    const esc = this.ctx.escapeHtml;
    if (!g) return `<div style="opacity:0.7; font-size:0.85rem; padding:8px 4px;">…</div>`;
    if (g.error) return `<div style="color:#fca5a5; font-size:0.85rem; padding:8px 4px;">${esc(g.error)}</div>`;
    return `
      <div style="margin:-2px 0 10px; padding:10px 12px; border-radius:10px; border:1px solid var(--border-color, #374151); background:rgba(37,99,235,0.08);">
        <div style="font-weight:800; font-size:1rem;">${esc(g.title)}</div>
        ${g.intro ? `<div style="font-size:0.85rem; opacity:0.85; margin:4px 0 8px;">${esc(g.intro)}</div>` : ''}
        ${(g.sections || []).map(sec => `
          <div style="font-size:0.78rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; margin:12px 0 2px; color:#93c5fd;">${esc(sec.title)}</div>
          ${sec.note ? `<div style="font-size:0.8rem; opacity:0.75; margin-bottom:6px;">${esc(sec.note)}</div>` : ''}
          <ol style="margin:0; padding-left:20px;">
            ${(sec.items || []).map(it => `
              <li style="margin:0 0 7px;">
                <span style="font-weight:700;">${esc(it.name)}</span>${it.dose ? ` <span style="font-size:0.78rem; opacity:0.75;">— ${esc(it.dose)}</span>` : ''}
                <div style="font-size:0.83rem; opacity:0.85;">${esc(it.how)}</div>
              </li>`).join('')}
          </ol>`).join('')}
      </div>`;
  }

  fmtDay(ymd) {
    return new Date(`${ymd}T12:00:00`).toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' });
  }

  fmtWhen(iso) {
    const d = new Date(iso);
    return d.toLocaleString([], { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  }

  render() {
    if (!this.el) return;
    const esc = this.ctx.escapeHtml;
    const cp = TodoPanel.cp;
    // Keep what was typed across a re-render (a ✓ while drafting).
    const typed = this.el.querySelector('[data-td-body]');
    if (typed) this.draft = typed.value;
    const at = this.el.querySelector('[data-td-at]')?.value || '';
    const todos = this.data.todos;
    const due = todos.filter(t => t.due);
    const later = todos.filter(t => !t.due && !t.done_at);
    const done = todos.filter(t => t.done_at);
    const btn = 'min-height:0; padding:6px 10px; border-radius:8px; font:inherit; font-weight:700; font-size:0.85rem; cursor:pointer;';
    // Given by staff (mig 1903): who, 🔁 every day, by <date> — on every row.
    const given = (t) => [
      t.repeat === 'daily' ? cp('todo_every_day', {}, '🔁 every day') : '',
      t.due_on ? cp('todo_by', { when: this.fmtDay(t.due_on) }, `by ${this.fmtDay(t.due_on)}`) : '',
      (t.mine === false && t.from) ? cp('todo_given_by', { name: t.from }, `from ${t.from}`) : '',
      t.photo_proof && !t.photo_id ? cp('todo_photo_need', {}, 'a photo ticks it off') : '',
      t.photo_proof && t.call_at && !t.photo_id ? cp('todo_call_note', { time: this.fmtClock(t.call_at) }, `📞 a call at ${this.fmtClock(t.call_at)} if no photo`) : '',
    ].filter(Boolean).join(' · ');
    const photoBtn = (t, tier, fb, bg, bd) => this.uploading === t.id
      ? `<span style="${btn} background:transparent; border:1px solid var(--border-color, #374151); cursor:default;">${esc(cp('todo_photo_busy', {}, 'Uploading…'))}</span>`
      : `<label style="${btn} background:${bg}; color:#fff; border:1px solid ${bd}; display:inline-block;">${esc(cp(tier, {}, fb))}<input type="file" accept="image/*" data-td-photo="${t.id}" style="display:none;"></label>`;
    const extras = (t) => {
      if (t.photo_id) this.loadThumb(t.photo_id);
      const thumb = t.photo_id && this.thumbs[t.photo_id]
        ? `<img src="${this.thumbs[t.photo_id]}" alt="" style="width:44px; height:44px; object-fit:cover; border-radius:8px; flex:none;">` : '';
      const guide = t.guide_id
        ? `<button type="button" data-td-guide="${t.id}" data-td-guide-id="${t.guide_id}" style="${btn} background:transparent; color:inherit; border:1px solid #2563eb;">${esc(cp(this.openGuide === t.id ? 'todo_guide_close' : 'todo_guide_open', {}, this.openGuide === t.id ? '📖 Hide routine' : '📖 Routine'))}</button>` : '';
      return { thumb, guide };
    };
    const row = (t, note0) => { const note = [note0, t.photo_id && t.photo_at ? cp('todo_photo_in', { time: new Date(t.photo_at).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }) }, '📷 Photo in') : '', given(t)].filter(Boolean).join(' · '); const x = extras(t); return `
      <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:8px 10px; border-radius:10px; margin-bottom:6px;
                  border:1px solid ${t.due ? '#ef4444' : 'var(--border-color, #374151)'}; background:${t.due ? 'rgba(239,68,68,0.12)' : 'rgba(255,255,255,0.03)'};">
        ${x.thumb}
        <div style="flex:1 1 160px; min-width:0; ${t.done_at ? 'text-decoration:line-through; opacity:0.6;' : ''}">
          <div style="font-weight:700; overflow-wrap:anywhere;">${esc(t.body)}</div>
          ${note ? `<div style="font-size:0.75rem; opacity:0.7;">${esc(note)}</div>` : ''}
        </div>
        ${x.guide}
        ${t.photo_proof
          ? (t.done_at && t.photo_id ? photoBtn(t, 'todo_photo_again', '📷 Replace', '#374151', '#4b5563') : photoBtn(t, 'todo_photo', '📷 Upload photo', '#16a34a', '#15803d'))
          : t.done_at
          ? `<button type="button" data-td-act="undo" data-td-id="${t.id}" style="${btn} background:transparent; color:inherit; border:1px solid var(--border-color, #374151);">${esc(cp('todo_undo', {}, '↩ Undo'))}</button>`
          : `<button type="button" data-td-act="done" data-td-id="${t.id}" style="${btn} background:#16a34a; color:#fff; border:1px solid #15803d;">${esc(cp('todo_check', {}, '✓ Done'))}</button>
             ${t.mine === false ? '' : `<button type="button" data-td-act="remove" data-td-id="${t.id}" aria-label="Remove" style="${btn} background:transparent; color:inherit; border:1px solid var(--border-color, #374151);">✕</button>`}`}
      </div>${this.openGuide === t.id ? this.guideHtml(this.guides[t.guide_id]) : ''}`; };
    const head = (tier, fb) => `<div style="font-size:0.72rem; font-weight:800; letter-spacing:0.05em; text-transform:uppercase; opacity:0.7; margin:12px 0 6px;">${esc(cp(tier, {}, fb))}</div>`;
    const opt = (v, tier, fb) => `<option value="${v}" ${this.when === v ? 'selected' : ''}>${esc(cp(tier, {}, fb))}</option>`;
    this.el.innerHTML = `
      <div style="display:flex; gap:6px; flex-wrap:wrap;">
        <input type="text" data-td-body maxlength="500" placeholder="${esc(cp('todo_placeholder', {}, 'Remind me to…'))}" value="${esc(this.draft || '')}"
               style="flex:1 1 220px; min-width:0; padding:8px 10px; border-radius:8px; font:inherit; border:1px solid var(--border-color, #374151); background:var(--bg-primary, #0b1220); color:inherit;">
        <select data-td-when style="padding:8px; border-radius:8px; font:inherit; border:1px solid var(--border-color, #374151); background:var(--bg-primary, #0b1220); color:inherit;">
          ${opt('now', 'todo_when_now', 'Now')}${opt('morning', 'todo_when_morning', 'Tomorrow 9 AM')}${opt('pick', 'todo_when_pick', 'Pick a time…')}
        </select>
        ${this.when === 'pick' ? `<input type="datetime-local" data-td-at value="${esc(at)}"
               style="padding:8px; border-radius:8px; font:inherit; border:1px solid var(--border-color, #374151); background:var(--bg-primary, #0b1220); color:inherit;">` : ''}
        <button type="button" data-td-add ${this.busy ? 'disabled' : ''} style="${btn} padding:8px 14px; background:#2563eb; color:#fff; border:1px solid #1d4ed8;">${esc(cp('todo_add', {}, '➕ Add'))}</button>
      </div>
      ${this.err ? `<div style="color:#fca5a5; font-size:0.85rem; margin-top:6px;">${esc(this.err)}</div>` : ''}
      ${!todos.length ? `<div style="opacity:0.7; font-size:0.9rem; margin-top:12px;">${esc(cp('todo_empty', {}, 'Nothing to do.'))}</div>` : ''}
      ${due.length ? head('todo_due', 'Due now') + due.map(t => row(t, '')).join('') : ''}
      ${later.length ? head('todo_later', 'Later') + later.map(t => row(t, cp('todo_from', { when: this.fmtWhen(t.remind_at) }, `shows ${this.fmtWhen(t.remind_at)}`))).join('') : ''}
      ${done.length ? head('todo_done', 'Done') + done.map(t => row(t, '')).join('') : ''}`;
  }
}

window.TodoPanel = TodoPanel;
