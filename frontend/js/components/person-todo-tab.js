// PersonTodoTab — the player sheet's ✅ To do tab (mig 1903).
//
// Owner 2026-11-25: "we need indivdual todo lists for all players. for
// example it might be for our hight school kids did you apply for financial
// aid. college applications. for some it might reminders to stretch every
// day."  Club admins and the player's coaches give items here; the player
// sees them in the 🚦 band's red "✅ To do" box on every screen (TodoPanel)
// and ticks them there.
//
//   [e.g. Apply for financial aid              ]
//   [Once ▾]  By [date]  [Just Sam ▾ / Everyone on U12 (14)]  [➕ Give]
//   Apply for financial aid · by Dec 15 · from James     Not done   [✕ Remove]
//   Stretch · 🔁 every day                              ✓ Done today [✕ Remove from all 14]
//   Their own reminders …
//
// Server: GET/POST /api/person-todos (PersonTodoController).  Words:
// player_sheet todo_* / tab_todo rows.  The sheet calls:
//   PersonTodoTab.load(auth, personId, force) → Promise
//   PersonTodoTab.html(person)                → the tab body
//   PersonTodoTab.handleClick(e, ctx)         → true when it was ours
//     ctx: { auth, person, redraw, say }
(function () {
  const cache = {};   // personId → { data, error, busy, draft: {body, repeat, due, to} }
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  const t = (tier, tokens, fb) =>
    (window.MessageCopy && MessageCopy.has && MessageCopy.has('player_sheet', tier))
      ? MessageCopy.block('player_sheet', tier, tokens || {}) : fb;
  const entry = (pid) => (cache[pid] = cache[pid] || { data: null, error: '', busy: false, draft: { body: '', repeat: '', due: '', to: '' } });

  async function call0(auth, url) {   // a binary GET (the photo) → Blob
    const res = await auth.fetch(url);
    if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error || `HTTP ${res.status}`);
    return res.blob();
  }

  async function call(auth, url, init) {
    const res = await auth.fetch(url, init);
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  function load(auth, pid, force) {
    if (!auth || !pid) return Promise.resolve();
    const c = entry(pid);
    if (c.data && !force) return Promise.resolve();
    return call(auth, `/api/person-todos?person_id=${encodeURIComponent(pid)}`)
      .then((d) => { c.data = d; c.error = ''; })
      .catch((e) => { c.error = e.message || 'Could not load'; });
  }

  const day = (iso) => {
    if (!iso) return '';
    const d = /^\d{4}-\d{2}-\d{2}$/.test(iso) ? new Date(`${iso}T12:00:00`) : new Date(iso);
    return d.toLocaleDateString([], { month: 'short', day: 'numeric' });
  };

  // "13:00" → "1 PM" (club time as the player's device shows it).
  const clock = (hhmm) => {
    const [h, m] = String(hhmm || '').split(':').map(Number);
    if (!Number.isFinite(h)) return hhmm || '';
    const d = new Date(); d.setHours(h, m || 0, 0, 0);
    return d.toLocaleTimeString([], { hour: 'numeric', minute: m ? '2-digit' : undefined });
  };

  function stateHtml(x) {
    if (x.repeat === 'daily') {
      if (x.done_today) return `<span style="color:#4ade80;">${esc(t('todo_state_today', {}, '✓ Done today'))}</span>`;
      return x.done_at
        ? `<span style="opacity:0.75;">${esc(t('todo_state_last', { when: day(x.done_at) }, `Last done ${day(x.done_at)}`))}</span>`
        : `<span style="color:#fca5a5;">${esc(t('todo_state_never', {}, 'Not ticked yet'))}</span>`;
    }
    return x.done_at
      ? `<span style="color:#4ade80;">${esc(t('todo_state_done', { when: day(x.done_at) }, `✓ Done ${day(x.done_at)}`))}</span>`
      : `<span style="color:#fca5a5;">${esc(t('todo_state_open', {}, 'Not done'))}</span>`;
  }

  function itemHtml(x) {
    const notes = [
      x.repeat === 'daily' ? '🔁 ' + t('todo_daily', {}, 'Every day') : '',
      x.due_on ? t('todo_by', { when: day(x.due_on) }, `by ${day(x.due_on)}`) : '',
      (!x.mine && x.from) ? t('todo_from', { name: x.from }, `from ${x.from}`) : '',
      x.photo_proof && x.call_at ? t('todo_call_tag', { time: clock(x.call_at) }, `📞 call ${clock(x.call_at)} if no photo`) : '',
      x.called_at ? t('todo_called', { time: new Date(x.called_at).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }) }, '📞 called') : '',
    ].filter(Boolean).join(' · ');
    const btn = 'min-height:0; padding:4px 8px; border-radius:6px; font:inherit; font-size:0.75rem; font-weight:700; cursor:pointer; background:transparent; color:inherit; border:1px solid #475569;';
    // 📷 mig 1944: today's photo opens in a new tab (fetched with auth).
    const photo = !x.photo_proof ? ''
      : x.photo_id ? `<button type="button" data-pt-photo="${x.photo_id}" style="${btn} border-color:#16a34a;">${esc(t('todo_photo_view', {}, "📷 Today's photo"))}</button>`
      : `<span style="font-size:0.75rem; color:#fca5a5; padding:4px 0;">${esc(t('todo_photo_none', {}, '📷 No photo today'))}</span>`;
    const takes = photo + (x.mine ? '' : `
      <button type="button" data-pt-take="${x.id}" style="${btn}">${esc(t('todo_remove', {}, '✕ Remove'))}</button>
      ${x.batch_n > 1 ? `<button type="button" data-pt-take="${x.id}" data-pt-all style="${btn}">${esc(t('todo_remove_all', { n: x.batch_n }, `✕ Remove from all ${x.batch_n}`))}</button>` : ''}`);
    const finished = x.repeat === 'daily' ? x.done_today : !!x.done_at;
    return `<div style="display:flex; align-items:flex-start; gap:8px; padding:8px 10px; border-radius:8px; margin-bottom:6px;
                        border:1px solid #374151; background:rgba(255,255,255,0.03);">
      <div style="flex:1; min-width:0;">
        <div style="font-weight:700; overflow-wrap:anywhere; ${finished && x.repeat !== 'daily' ? 'text-decoration:line-through; opacity:0.6;' : ''}">${esc(x.body)}</div>
        <div style="font-size:0.75rem; opacity:0.85; display:flex; gap:8px; flex-wrap:wrap;">${notes ? `<span style="opacity:0.8;">${esc(notes)}</span>` : ''}${stateHtml(x)}</div>
      </div>
      <div style="display:flex; gap:4px; flex-wrap:wrap; justify-content:flex-end;">${takes}</div>
    </div>`;
  }

  function html(p) {
    const pid = p && p.personId;
    if (!pid) return '';
    const c = entry(pid);
    if (c.error && !c.data) return `<div style="opacity:0.7; font-style:italic;">${esc(c.error)}</div>`;
    if (!c.data) return '<div style="opacity:0.6;">…</div>';
    const d = c.data, dr = c.draft;
    const name = p.firstName || t('todo_this_player', {}, 'this player');
    const field = 'padding:6px 8px; border-radius:6px; font:inherit; border:1px solid #475569; background:#0f172a; color:#fff; color-scheme:dark;';
    const toOpts = [`<option value="">${esc(t('todo_to_one', { name }, `Just ${name}`))}</option>`]
      .concat((d.teams || []).map(tm => `<option value="${tm.teamId}" ${String(dr.to) === String(tm.teamId) ? 'selected' : ''}>${esc(t('todo_to_team', { team: tm.label, n: tm.n }, `Everyone on ${tm.label} (${tm.n})`))}</option>`))
      .join('');
    const given = d.todos.filter(x => !x.mine), own = d.todos.filter(x => x.mine);
    return `<div class="pt-tab" data-pt-pid="${pid}">
      <div style="display:flex; flex-direction:column; gap:6px; padding-bottom:12px; margin-bottom:12px; border-bottom:1px solid #374151;">
        <input type="text" data-pt-body maxlength="500" value="${esc(dr.body)}" placeholder="${esc(t('todo_placeholder', {}, 'e.g. Apply for financial aid'))}" style="${field}">
        <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center;">
          <select data-pt-repeat style="${field}">
            <option value="" ${dr.repeat ? '' : 'selected'}>${esc(t('todo_once', {}, 'Once'))}</option>
            <option value="daily" ${dr.repeat === 'daily' ? 'selected' : ''}>🔁 ${esc(t('todo_daily', {}, 'Every day'))}</option>
          </select>
          <label style="display:flex; align-items:center; gap:4px; font-size:0.75rem; font-weight:700; opacity:0.85;">${esc(t('todo_due_label', {}, 'By (optional)'))}
            <input type="date" data-pt-due value="${esc(dr.due)}" style="${field}"></label>
          <select data-pt-to style="${field} max-width:100%;">${toOpts}</select>
          <button type="button" data-pt-give ${c.busy ? 'disabled' : ''}
                  style="padding:6px 12px; border-radius:6px; font:inherit; font-weight:800; cursor:pointer; background:#2563eb; color:#fff; border:1px solid #1d4ed8;">${esc(t('todo_add', {}, '➕ Give'))}</button>
        </div>
        ${c.error ? `<div style="color:#fca5a5; font-size:0.8rem;">${esc(c.error)}</div>` : ''}
      </div>
      ${!d.todos.length ? `<div style="opacity:0.6; font-style:italic;">${esc(t('empty_todo', {}, 'Nothing on their list.'))}</div>` : ''}
      ${given.map(itemHtml).join('')}
      ${own.length ? `<div style="font-size:0.72rem; font-weight:800; letter-spacing:0.05em; text-transform:uppercase; opacity:0.7; margin:12px 0 6px;">${esc(t('todo_own', {}, 'Their own reminders'))}</div>${own.map(itemHtml).join('')}` : ''}
    </div>`;
  }

  // Keep what is typed across a redraw (another part of the sheet loading).
  function keepDraft(root, c) {
    if (!root) return;
    c.draft = {
      body: root.querySelector('[data-pt-body]')?.value || '',
      repeat: root.querySelector('[data-pt-repeat]')?.value || '',
      due: root.querySelector('[data-pt-due]')?.value || '',
      to: root.querySelector('[data-pt-to]')?.value || '',
    };
  }

  async function post(ctx, c, pid, payload) {
    if (c.busy) return null;
    c.busy = true; c.error = ''; ctx.redraw();
    try {
      const d = await call(ctx.auth, '/api/person-todos', {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ person_id: pid, ...payload }) });
      c.data = d;
      return d;
    } catch (e) {
      c.error = e.message || 'Could not save';
      return null;
    } finally {
      c.busy = false;
      ctx.redraw();
    }
  }

  function handleClick(e, ctx) {
    const root = e.target.closest('.pt-tab');
    if (!root) return false;
    const pid = Number(root.getAttribute('data-pt-pid'));
    const c = entry(pid);
    if (e.target.closest('[data-pt-give]')) {
      keepDraft(root, c);
      const dr = c.draft;
      if (!dr.body.trim()) { root.querySelector('[data-pt-body]')?.focus(); return true; }
      post(ctx, c, pid, { action: 'give', body: dr.body, repeat: dr.repeat, due_on: dr.due, team_id: Number(dr.to) || 0 })
        .then((d) => {
          if (!d) return;
          c.draft = { body: '', repeat: '', due: '', to: '' };
          ctx.redraw();
          if (ctx.say) ctx.say(t('todo_saved', { n: d.given }, `Given to ${d.given}.`));
        });
      return true;
    }
    const ph = e.target.closest('[data-pt-photo]');
    if (ph) {
      const w = window.open('', '_blank');   // opened now, inside the tap, so no popup block
      call0(ctx.auth, `/api/my/todo-photo?id=${encodeURIComponent(ph.getAttribute('data-pt-photo'))}`)
        .then(b => { const u = URL.createObjectURL(b); if (w) w.location = u; else window.open(u, '_blank'); })
        .catch(err => { if (w) w.close(); if (ctx.say) ctx.say(err.message || 'Could not open the photo'); });
      return true;
    }
    const tk = e.target.closest('[data-pt-take]');
    if (tk) {
      keepDraft(root, c);
      post(ctx, c, pid, { action: 'take', id: Number(tk.getAttribute('data-pt-take')), all: tk.hasAttribute('data-pt-all') });
      return true;
    }
    // Typing / picking inside the tab: remember it before any redraw.
    keepDraft(root, c);
    return false;
  }

  // Before the sheet repaints, save the typed draft (called from draw()).
  function saveDraft(container) {
    const root = container && container.querySelector('.pt-tab');
    if (root) keepDraft(root, entry(Number(root.getAttribute('data-pt-pid'))));
  }

  window.PersonTodoTab = { load, html, handleClick, saveDraft };
})();
