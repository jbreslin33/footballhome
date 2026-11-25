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
    if (el) {
      el.addEventListener('click', (e) => this.onClick(e));
      el.addEventListener('change', (e) => {
        if (e.target.matches('[data-td-when]')) { this.when = e.target.value; this.render(); }
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
    const b = e.target.closest('[data-td-act]');
    if (b) this.post({ action: b.getAttribute('data-td-act'), id: Number(b.getAttribute('data-td-id')) });
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
    ].filter(Boolean).join(' · ');
    const row = (t, note0) => { const note = [note0, given(t)].filter(Boolean).join(' · '); return `
      <div style="display:flex; align-items:center; gap:8px; padding:8px 10px; border-radius:10px; margin-bottom:6px;
                  border:1px solid ${t.due ? '#ef4444' : 'var(--border-color, #374151)'}; background:${t.due ? 'rgba(239,68,68,0.12)' : 'rgba(255,255,255,0.03)'};">
        <div style="flex:1; min-width:0; ${t.done_at ? 'text-decoration:line-through; opacity:0.6;' : ''}">
          <div style="font-weight:700; overflow-wrap:anywhere;">${esc(t.body)}</div>
          ${note ? `<div style="font-size:0.75rem; opacity:0.7;">${esc(note)}</div>` : ''}
        </div>
        ${t.done_at
          ? `<button type="button" data-td-act="undo" data-td-id="${t.id}" style="${btn} background:transparent; color:inherit; border:1px solid var(--border-color, #374151);">${esc(cp('todo_undo', {}, '↩ Undo'))}</button>`
          : `<button type="button" data-td-act="done" data-td-id="${t.id}" style="${btn} background:#16a34a; color:#fff; border:1px solid #15803d;">${esc(cp('todo_check', {}, '✓ Done'))}</button>
             ${t.mine === false ? '' : `<button type="button" data-td-act="remove" data-td-id="${t.id}" aria-label="Remove" style="${btn} background:transparent; color:inherit; border:1px solid var(--border-color, #374151);">✕</button>`}`}
      </div>`; };
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
