// InvoicesScreen — #invoices — biweekly invoices to The Lighthouse, Inc.
// (owner 2026-09-27: "i need to make it easier to make invoices for
// lighthouse … a top level section … on a specific invoice sheet … for
// myself, luke breslin, jamie Arevelo and Anthony Acevedo … the others will
// only have hours").
//
// Backed by /api/invoices (backend/src/controllers/InvoiceController.cpp,
// migration 465).  Pick who is invoicing, start the next number (the pay
// period of the year, shared by everyone), type the hours, add any
// one-off expense or instalment plan, and print — the sheet below the
// editor is Lighthouse's InvoiceTemplate laid out exactly, and Print /
// Save as PDF names the file Invoice<slug>-<year>.<number>.pdf.
//
// Instalment plans ("Veo Subscription 15 of 16 $862.92") are the part that
// used to be carried forward by hand: every new invoice picks up the next
// "k of N" line of each unfinished plan automatically.
//
// Club / super admins only.  Page copy is message_templates kind='invoices'.
class InvoicesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.board = null;
    this.issuerId = 0;
    this.inv = null;          // the open invoice (full sheet)
    this.refGames = [];       // home games not yet on an invoice (mig 490), for the open draft
    this.loading = false;
    this.error = null;
    this.flash = '';
    this.editIssuer = false;
    this.showPlanForm = false;
    this.confirmDelete = 0;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .iv-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase;
                  letter-spacing:0.05em; opacity:0.6; }
        .iv-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary);
                   padding:12px 14px; margin-bottom:var(--space-2); }
        .iv-pills { display:flex; flex-wrap:wrap; gap:8px; }
        .iv-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent;
                   color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .iv-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .iv-btn { padding:8px 14px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.9rem;
                  color:#0b1c3d; background:#4ade80; }
        .iv-btn.alt { background:var(--primary-color); color:#fff; }
        .iv-btn.sm { padding:5px 10px; font-size:0.78rem; }
        .iv-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .iv-btn.danger { background:transparent; color:#f87171; border:1px solid #f87171; }
        .iv-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .iv-in { padding:8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary);
                 color:var(--text-primary); font-size:0.9rem; min-width:0; width:100%; }
        .iv-in.num { text-align:right; }
        .iv-grid { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-top:6px; }
        .iv-grid .wide { grid-column:1 / -1; }
        .iv-lbl { font-size:0.72rem; opacity:0.65; text-transform:uppercase; letter-spacing:0.04em; margin-bottom:2px; }
        .iv-row { display:grid; grid-template-columns:70px 1fr 80px 90px 130px; gap:8px; align-items:center; padding:8px 0;
                  border-top:1px solid var(--border-color); font-size:0.9rem; }
        .iv-row:first-child { border-top:none; }
        .iv-row .r { text-align:right; }
        .iv-row.head { font-size:0.72rem; opacity:0.65; text-transform:uppercase; letter-spacing:0.04em; }
        .iv-list-row { display:grid; grid-template-columns:70px 1fr 70px 100px auto; gap:8px; align-items:center;
                       padding:8px 0; border-top:1px solid var(--border-color); font-size:0.9rem; }
        .iv-list-row:first-child { border-top:none; }
        .iv-tag { display:inline-block; padding:2px 8px; border-radius:999px; font-size:0.72rem; border:1px solid var(--border-color); }
        .iv-tag.final { border-color:#4ade80; color:#4ade80; }
        .iv-tag.draft { border-color:#f59e0b; color:#f59e0b; }
        .iv-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .iv-flash.bad { background:rgba(248,113,113,0.15); }
        .iv-total { display:flex; justify-content:flex-end; gap:12px; font-weight:800; font-size:1.1rem; padding:10px 0; }
        .iv-acts { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-top:8px; }
        .iv-hint { font-size:0.8rem; opacity:0.7; margin-top:6px; }
        .iv-day { display:grid; grid-template-columns:100px 110px 110px 80px 1fr 76px; gap:8px; align-items:center; padding:6px 0;
                  border-top:1px solid var(--border-color); font-size:0.9rem; }
        .iv-day:first-child { border-top:none; }
        .iv-day.head { font-size:0.72rem; opacity:0.65; text-transform:uppercase; letter-spacing:0.04em; }
        .iv-day .hrs { text-align:right; font-weight:700; }
        @media (max-width: 720px) { .iv-day { grid-template-columns:70px 1fr 1fr 70px; } .iv-day .note { grid-column:1 / 4; } .iv-day.head { display:none; } }
        @media (max-width: 720px) {
          .iv-row { grid-template-columns:1fr 1fr; }
          .iv-row .desc { grid-column:1 / -1; }
          .iv-row.head { display:none; }
          .iv-grid { grid-template-columns:1fr; }
          .iv-list-row { grid-template-columns:60px 1fr 90px; }
          .iv-list-row .hrs { display:none; }
        }

        /* ── the sheet: Lighthouse's InvoiceTemplate itself (images/invoice-template.png,
           the template PDF's own page image, 1020×1224 px at 144 ppi) drawn at its place
           on a letter page, with the values laid over it at the positions James's own
           typed invoices use (measured from InvoiceJBreslin-2026.19.pdf).  Everything is
           in pt on a 612×792 pt page so screen and print agree. ─────────────────── */
        .inv-sheet { position:relative; width:612pt; height:792pt; background:#fff; color:#000;
                     font-family:Arial, Helvetica, sans-serif; overflow:hidden; box-shadow:0 2px 12px rgba(0,0,0,0.25); }
        .inv-sheet .sh-bg { position:absolute; left:51pt; top:90pt; width:510pt; height:612pt; }
        .inv-sheet .sh-f { position:absolute; white-space:nowrap; line-height:1; }
        .inv-sheet .sh-f.r { text-align:right; }
        .inv-sheet .sh-f.c { text-align:center; }
        .inv-sheet .sh-over { position:absolute; left:94pt; top:359pt; width:430pt; height:248pt; background:#fff; }
        .inv-sheet .sh-over table { width:100%; height:100%; border-collapse:collapse; table-layout:fixed; }
        .inv-sheet .sh-over td { border:1px solid #333; padding:0 4pt; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .inv-sheet .sh-over td.c { text-align:center; } .inv-sheet .sh-over td.r { text-align:right; }
        .inv-preview-wrap { overflow:hidden; padding:8px 0; }
        .iv-modal-bg { position:fixed; inset:0; background:rgba(0,0,0,0.55); z-index:1000; display:flex; align-items:flex-start;
                       justify-content:center; padding:24px 12px; overflow:auto; }
        .iv-modal { background:var(--bg-primary); color:var(--text-primary); border:1px solid var(--border-color); border-radius:14px;
                    width:100%; max-width:900px; padding:14px 16px; box-shadow:0 10px 40px rgba(0,0,0,0.4); }
        .iv-modal .iv-card { background:var(--bg-secondary); }
        .inv-preview-wrap .inv-scale { transform-origin:top left; }
          .inv-sheet .sh-title { font-size:24pt; } .inv-sheet .sh-row { grid-template-columns:0.9in 1fr; } }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🧾 Invoices</h1>
        <p class="subtitle" id="iv-subtitle"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 980px; margin: 0 auto;">
        <div style="display:flex; justify-content:flex-end; margin-bottom:var(--space-2);">
          <button id="iv-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>
        <div id="iv-body"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter() { this.load(); }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('invoices', tier, tokens) : ''; }

  // ── data ──────────────────────────────────────────────────────────────

  async load(keepOpen = true) {
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/invoices/board');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.board = body;
      if (!this.issuerId && body.issuers?.length) this.issuerId = body.issuers[0].id;
      if (keepOpen && this.inv) {
        const still = (body.issuers || []).some(i => (i.invoices || []).some(v => v.id === this.inv.id));
        if (!still) this.inv = null;
      }
    } catch (err) {
      this.board = null;
      this.error = err.message || 'Failed to load.';
    }
    this.loading = false;
    const sub = this.find('#iv-subtitle');
    if (sub) sub.textContent = this._copy('subtitle');
    this._renderBody();
  }

  async _post(path, payload) {
    const res = await this.auth.fetch(path, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload || {}),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _delete(path) {
    const res = await this.auth.fetch(path, { method: 'DELETE' });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  _issuer() { return (this.board?.issuers || []).find(i => i.id === this.issuerId) || null; }

  _say(text, bad = false) { this.flash = text; this.flashBad = bad; this._renderBody(); }

  async openInvoice(id) {
    try {
      const res = await this.auth.fetch(`/api/invoices/${id}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (!this.inv || this.inv.id !== body.id) { this.extraDays = []; }
      this.inv = body;
      this.issuerId = body.issuer_id;
      this.showPlanForm = false;
      this.flash = '';
      this._renderBody();
      this._loadRefGames();
      const ed = this.find('#iv-editor');
      if (ed) ed.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } catch (err) { this._say(err.message, true); }
  }

  async newInvoice() {
    const issuer = this._issuer();
    if (!issuer) return;
    try {
      const body = await this._post('/api/invoices/new', { issuer_id: issuer.id });
      await this.load(false);
      await this.openInvoice(body.id);
    } catch (err) { this._say(err.message, true); }
  }

  async updateInvoice(fields) {
    if (!this.inv) return;
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/update`, fields);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  // Referee fees to tick off (mig 490): the home games not on any invoice.
  async _loadRefGames() {
    const inv = this.inv;
    if (!inv || inv.is_final || !inv.issuer?.bills_expenses) { this.refGames = []; return; }
    try {
      const res = await this.auth.fetch('/api/invoices/ref-fees');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (this.inv && this.inv.id === inv.id) { this.refGames = body.games || []; this._renderBody(); }
    } catch (err) { console.warn('ref fees unavailable:', err.message); }
  }

  async addRefFees() {
    if (!this.inv) return;
    const picks = [...this.element.querySelectorAll('[data-ref-game]:checked')].map(cb => { const [source, id] = cb.dataset.refGame.split(':'); return { source, ref_id: Number(id) }; });
    if (!picks.length) { this._say('Tick at least one game.', true); return; }
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/ref-fees`, { games: picks });
      await this.load();
      this._loadRefGames();
    } catch (err) { this._say(err.message, true); }
  }

  // Budget lines a line can count toward (board.budget_lines, mig 490):
  // those of the line's category, plus whatever it already points at.
  _budgetSel(category, current, extra = '') {
    const esc = (t) => this.escapeHtml(t);
    const all = (this.board && this.board.budget_lines) || [];
    const opts = category === '__any__' ? all : all.filter(b => b.category === category || b.id === current);
    if (!opts.length && !current) return '';
    return `<select class="iv-in" style="margin-top:3px; font-size:0.78rem; opacity:0.85;" title="${esc(this._copy('budget_label') || 'Counts toward')}" ${extra}>
      <option value="0">${esc(this._copy('budget_none') || '— not a planned expense —')}</option>
      ${opts.map(b => `<option value="${b.id}" ${b.id === current ? 'selected' : ''}>${esc(b.label)}${b.section ? ` (${esc(b.section)})` : ''} — ${InvoicesScreen.money(b.remaining)} left</option>`).join('')}
    </select>`;
  }

  async saveLine(lineId) {
    if (!this.inv) return;
    const row = this.find(`[data-line-row="${lineId}"]`);
    if (!row) return;
    const line = (this.inv.lines || []).find(l => l.id === lineId);
    const val = (sel) => { const el = row.querySelector(sel); return el ? el.value : ''; };
    const qty = Number(val('[data-f="quantity"]')) || 0;
    const rateRaw = val('[data-f="rate"]');
    const rate = rateRaw === '' ? null : Number(rateRaw);
    const amtRaw = val('[data-f="amount"]');
    const payload = {
      id: lineId,
      category: val('[data-f="category"]') || (line ? line.category : 'other'),
      description: line && line.plan_id ? line.description : (val('[data-f="description"]') || (line ? line.description : '')),
      quantity: qty,
    };
    if (rate !== null && Number.isFinite(rate)) payload.rate = rate;
    const bsel = row.querySelector('[data-f="budget_line_id"]');
    if (bsel) payload.budget_line_id = Number(bsel.value) || null;
    // Amount follows qty × rate unless the amount box was edited to something else.
    const computed = rate !== null && Number.isFinite(rate) ? Math.round(qty * rate * 100) / 100 : null;
    const amt = amtRaw === '' ? null : Number(amtRaw);
    if (amt !== null && Number.isFinite(amt) && (computed === null || Math.abs(amt - computed) > 0.004) && row.dataset.amountTouched === '1') payload.amount = amt;
    else if (computed !== null) payload.amount = computed;
    else if (amt !== null && Number.isFinite(amt)) payload.amount = amt;
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/line`, payload);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async addLine() {
    if (!this.inv) return;
    const cat = this.find('#iv-new-cat')?.value || 'other';
    const desc = (this.find('#iv-new-desc')?.value || '').trim();
    const qty = Number(this.find('#iv-new-qty')?.value) || 1;
    const rate = Number(this.find('#iv-new-rate')?.value);
    if (!desc) { this._say('Describe the line first.', true); return; }
    if (!Number.isFinite(rate)) { this._say('Enter the amount.', true); return; }
    try {
      const budget = Number(this.find('#iv-new-budget')?.value) || null;
      this.inv = await this._post(`/api/invoices/${this.inv.id}/line`, { category: cat, description: desc, quantity: qty, rate, budget_line_id: budget });
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async removeLine(lineId) {
    if (!this.inv) return;
    try {
      await this._delete(`/api/invoices/line?id=${lineId}`);
      await this.openInvoice(this.inv.id);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async addPlan() {
    if (!this.inv) return;
    const payload = {
      issuer_id: this.inv.issuer_id, invoice_id: this.inv.id,
      category: this.find('#iv-plan-cat')?.value || 'other',
      description: (this.find('#iv-plan-desc')?.value || '').trim(),
      total_amount: Number(this.find('#iv-plan-total')?.value),
      installment_count: Number(this.find('#iv-plan-count')?.value),
      show_total: !!this.find('#iv-plan-show')?.checked,
      budget_line_id: Number(this.find('#iv-plan-budget')?.value) || null,
    };
    if (!payload.description) { this._say('Describe the expense first.', true); return; }
    try {
      const body = await this._post('/api/invoices/plan', payload);
      if (body.invoice) this.inv = body.invoice;
      this.showPlanForm = false;
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async removePlan(planId) {
    try {
      await this._delete(`/api/invoices/plan?id=${planId}`);
      if (this.inv) await this.openInvoice(this.inv.id);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  // ── hours by day (mig 469 / 474) ─────────────────────────────────────
  // Every day of the period is a row.  From + till → hours follow; a
  // number typed into Hours → the times go blank (owner 2026-09-27).

  _dayPayload(row, changed) {
    const el = (k) => row.querySelector(`[data-sf="${k}"]`);
    const v = (k) => { const e = el(k); return e ? e.value.trim() : ''; };
    if (changed === 'hours' && v('hours')) { if (el('start')) el('start').value = ''; if (el('end')) el('end').value = ''; }
    if ((changed === 'start' || changed === 'end') && v('start') && v('end')) { if (el('hours')) el('hours').value = ''; }
    const start = v('start'), end = v('end'), hours = Number(v('hours'));
    const base = { date: row.dataset.date, note: v('note') };
    if (start && end) return { ...base, start, end };
    if (hours > 0) return { ...base, hours };
    return null;   // nothing usable yet (one time filled, or all blank)
  }

  async saveDay(row, changed) {
    if (!this.inv || !row) return;
    const id = Number(row.dataset.shiftRow) || 0;
    const payload = this._dayPayload(row, changed);
    try {
      if (!payload) {
        // A saved row wiped clean is a removed day.
        if (id && !row.querySelector('[data-sf="start"]').value && !row.querySelector('[data-sf="end"]').value && !row.querySelector('[data-sf="hours"]').value) {
          await this._delete(`/api/invoices/shift?id=${id}`);
          await this.openInvoice(this.inv.id); await this.load();
        }
        return;
      }
      if (id) payload.id = id;
      else this.extraDays = (this.extraDays || []).filter(d => d !== row.dataset.date + '#' + row.dataset.extra);
      this.inv = await this._post(`/api/invoices/${this.inv.id}/shift`, payload);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async removeShift(shiftId) {
    if (!this.inv) return;
    try {
      await this._delete(`/api/invoices/shift?id=${shiftId}`);
      await this.openInvoice(this.inv.id);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async fillFromDefault() {
    if (!this.inv) return;
    try {
      const body = await this._post(`/api/invoices/${this.inv.id}/fill`, {});
      this.inv = body;
      await this.load();
      if (!body.added) this._say('No days added — the usual week is empty for this period.', true);
    } catch (err) { this._say(err.message, true); }
  }

  // ── the usual week (mig 470 / 474) ───────────────────────────────────

  _defaultPayload(row, changed) {
    const el = (k) => row.querySelector(`[data-df="${k}"]`);
    const v = (k) => { const e = el(k); return e ? e.value.trim() : ''; };
    if (changed === 'hours' && v('hours')) { if (el('start')) el('start').value = ''; if (el('end')) el('end').value = ''; }
    if ((changed === 'start' || changed === 'end') && v('start') && v('end')) { if (el('hours')) el('hours').value = ''; }
    const start = v('start'), end = v('end'), hours = Number(v('hours'));
    const base = { day_index: Number(row.dataset.dayIndex), note: v('note') };
    if (start && end) return { ...base, start, end };
    if (hours > 0) return { ...base, hours };
    return null;
  }

  async saveDefaultRow(row, changed) {
    const issuer = this._issuer();
    if (!issuer || !row) return;
    const id = Number(row.dataset.defaultRow) || 0;
    const payload = this._defaultPayload(row, changed);
    try {
      if (!payload) {
        if (id && !row.querySelector('[data-df="start"]').value && !row.querySelector('[data-df="end"]').value && !row.querySelector('[data-df="hours"]').value) {
          await this._delete(`/api/invoices/default?id=${id}`);
          await this.load();
        }
        return;
      }
      if (id) payload.id = id;
      else this.extraWeekdays = (this.extraWeekdays || []).filter(d => d !== row.dataset.dayIndex + '#' + row.dataset.extra);
      await this._post('/api/invoices/default', { issuer_id: issuer.id, ...payload });
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async removeDefault(id) {
    try {
      await this._delete(`/api/invoices/default?id=${id}`);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  // ── email the deputy director (mig 471) ────────────────────────────────

  _publicUrl(inv) {
    return inv && inv.public_slug ? `${location.origin}/invoice?k=${inv.public_slug}` : '';
  }

  async copyPublicLink() {
    const url = this._publicUrl(this.inv);
    if (!url) return;
    try { await navigator.clipboard.writeText(url); this._say('Link copied.'); }
    catch (_) { this._say(url); }
  }

  // A Gmail compose URL carries plain text only, so "Invoice #19" can't be
  // a hyperlink through the URL (owner 2026-09-28: "it does not look like
  // hyper link … can the link be 'Invoice #19'").  The message goes on the
  // clipboard as text/html + text/plain first, then Gmail opens with To /
  // Cc / Subject filled and the body empty for one paste.  Clipboard first,
  // window second: once the new tab has focus this document can't write the
  // clipboard.  If the clipboard refuses, the plain body rides in the URL
  // as before.
  async emailDeputy() {
    const d = this._emailDraft();
    if (!d) return;
    if (!d.to) { this._say('No email on the bill-to row.', true); return; }
    const copied = await this._copyEmailBody(d);
    this.openGmailCompose(this.buildGmailComposeHref({ to: d.to, cc: d.cc, subject: d.subject, body: copied ? '' : d.body }));
    if (copied) this._say(this._copy('email_copied') || 'Message copied — paste it into the Gmail body.');
  }

  async copyEmailBody() {
    const d = this._emailDraft();
    if (!d) return;
    if (await this._copyEmailBody(d)) this._say(this._copy('email_copied') || 'Message copied — paste it into the Gmail body.');
    else this._say('Could not copy — select the message text and copy it by hand.', true);
  }

  async _copyEmailBody(d) {
    try {
      if (typeof ClipboardItem !== 'undefined' && navigator.clipboard?.write) {
        await navigator.clipboard.write([new ClipboardItem({
          'text/html':  new Blob([d.html], { type: 'text/html' }),
          'text/plain': new Blob([d.body], { type: 'text/plain' }),
        })]);
        return true;
      }
    } catch (err) { console.warn('[invoices] rich clipboard write failed:', err); }
    return false;
  }

  // The draft as it will open in Gmail: shown on the page under the buttons
  // ("so i can see if its what we need") and sent by emailDeputy().
  _emailDraft() {
    const inv = this.inv;
    if (!inv) return null;
    const to = inv.bill_to?.email || '';
    const mine = Number(this.board?.viewer_person_id || 0) > 0 && Number(inv.issuer?.person_id) === Number(this.board.viewer_person_id);
    const url = (inv.link_url || '').trim() || this._publicUrl(inv);
    const link = url || (this._copy('email_no_link') || 'view online');
    const tokens = {
      title: inv.title, number: inv.number, name: inv.issuer?.name || '', week1: inv.week1, week2: inv.week2,
      total: InvoicesScreen.money(inv.total), file: inv.file_name, link,
      to_name: inv.bill_to?.email_to_name || '',
    };
    const tier = mine ? 'email' : 'email_coach';
    const r = window.MessageCopy ? MessageCopy.render('invoices', tier, tokens) : null;
    const subject = r ? r.subject : inv.title;
    const body = r ? r.body : `${inv.title}: ${link}`;
    // The same message as HTML for the clipboard: {link} becomes
    // <a href=url>Invoice #19</a> (wording = email_link_text, mig 481).
    const esc = (t) => this.escapeHtml(t);
    const linkText = this._copy('email_link_text', { number: inv.number }) || `Invoice #${inv.number}`;
    const anchor = url ? `<a href="${esc(url)}">${esc(linkText)}</a>` : esc(link);
    const MARK = '@@fh-link@@';
    const rh = window.MessageCopy ? MessageCopy.render('invoices', tier, { ...tokens, link: MARK }) : null;
    const html = esc(rh ? rh.body : `${inv.title}: ${MARK}`).split(MARK).join(anchor)
      .split('\n').map(line => `<div>${line || '<br>'}</div>`).join('');
    // A coach's invoice copies the coach ("he is included in this email").
    const cc = !mine && inv.issuer?.email ? inv.issuer.email : undefined;
    return { to, cc, subject, body, html, mine };
  }

  async removeInvoice(id) {
    if (this.confirmDelete !== id) { this.confirmDelete = id; this._renderBody(); return; }
    this.confirmDelete = 0;
    try {
      await this._delete(`/api/invoices?id=${id}`);
      if (this.inv && this.inv.id === id) this.inv = null;
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async saveIssuer() {
    const issuer = this._issuer();
    if (!issuer) return;
    const v = (id) => this.find(`#iv-is-${id}`)?.value ?? '';
    const payload = {
      id: issuer.id, address: v('address'), city_state_zip: v('csz'), phone: v('phone'), payable_to: v('payable'),
      duty_description: v('duty'), file_slug: v('slug'),
      hourly_rate: v('rate') === '' ? null : Number(v('rate')),
    };
    try {
      await this._post('/api/invoices/issuer', payload);
      this.editIssuer = false;
      if (this.inv) await this.openInvoice(this.inv.id);
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  // ── print ─────────────────────────────────────────────────────────────

  print() {
    if (!this.inv) return;
    const sheet = this.find('.inv-sheet');
    if (!sheet) return;
    const title = document.title;
    const root = document.createElement('div');
    root.className = 'inv-print-root';
    root.appendChild(sheet.cloneNode(true));
    // Zero page margin: Chrome then prints no header (date, title) or footer
    // (URL, page number) — owner 2026-09-27: "take off the footballhome
    // footer … take off date and time stamp at top".  The rule only takes
    // in Chrome as a top-level @page in <head>, not nested in @media print.
    const pageStyle = document.createElement('style');
    pageStyle.textContent = '@page { size: letter; margin: 0; }';
    document.head.appendChild(pageStyle);
    const style = document.createElement('style');
    style.textContent = `
      @media print {
        html, body { margin:0 !important; padding:0 !important; }
        body.inv-printing > :not(.inv-print-root) { display:none !important; }
        body.inv-printing { background:#fff !important; }
        .inv-print-root .inv-sheet { box-shadow:none; }
        .inv-print-root .sh-bg { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
      }
      @media screen { .inv-print-root { display:none; } }
    `;
    root.appendChild(style);
    document.body.appendChild(root);
    document.body.classList.add('inv-printing');
    document.title = String(this.inv.file_name || 'Invoice').replace(/\.pdf$/i, '');
    const done = () => {
      document.body.classList.remove('inv-printing');
      root.remove();
      pageStyle.remove();
      document.title = title;
      window.removeEventListener('afterprint', done);
    };
    window.addEventListener('afterprint', done);
    setTimeout(() => window.print(), 50);
    setTimeout(done, 60000);   // belt and braces if afterprint never fires
  }

  // ── events ────────────────────────────────────────────────────────────

  _wireEvents() {
    const el = this.element;
    el.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      if (e.target.closest('#iv-refresh')) { this.load(); return; }
      const pill = e.target.closest('[data-issuer]');
      if (pill) {
        // Another person's pill: their board only.  The invoice open on the
        // page belongs to the previous person, so it closes too (owner
        // 2026-09-28: "when i hit jamie pill shouldn't all my stuff go away?").
        const next = Number(pill.dataset.issuer);
        if (next !== this.issuerId) { this.inv = null; this.extraWeekdays = []; }
        this.issuerId = next; this.editIssuer = false; this.showUsual = false; this.confirmDelete = 0; this._renderBody(); return;
      }
      if (e.target.closest('#iv-new')) { await this.newInvoice(); return; }
      if (e.target.closest('#iv-edit-issuer')) { this.editIssuer = !this.editIssuer; this._renderBody(); return; }
      if (e.target.closest('#iv-usual-open')) { this.showUsual = true; this._renderBody(); return; }
      if (e.target.closest('#iv-usual-close') || (e.target.id === 'iv-usual-bg')) { this.showUsual = false; this.extraWeekdays = []; this._renderBody(); return; }
      if (e.target.closest('#iv-save-issuer')) { await this.saveIssuer(); return; }
      if (e.target.closest('#iv-close')) { this.inv = null; this._renderBody(); return; }
      if (e.target.closest('#iv-print')) { this.print(); return; }
      if (e.target.closest('#iv-add-line')) { await this.addLine(); return; }
      if (e.target.closest('#iv-refs-add')) { await this.addRefFees(); return; }
      if (e.target.closest('#iv-plan-toggle')) { this.showPlanForm = !this.showPlanForm; this._renderBody(); return; }
      if (e.target.closest('#iv-plan-add')) { await this.addPlan(); return; }
      const open = e.target.closest('[data-open]');
      if (open) { await this.openInvoice(Number(open.dataset.open)); return; }
      const del = e.target.closest('[data-delete-invoice]');
      if (del) { await this.removeInvoice(Number(del.dataset.deleteInvoice)); return; }
      const rmLine = e.target.closest('[data-delete-line]');
      if (rmLine) { await this.removeLine(Number(rmLine.dataset.deleteLine)); return; }
      const rmPlan = e.target.closest('[data-delete-plan]');
      if (rmPlan) { await this.removePlan(Number(rmPlan.dataset.deletePlan)); return; }
      if (e.target.closest('#iv-fill')) { await this.fillFromDefault(); return; }
      if (e.target.closest('#iv-email')) { this.emailDeputy(); return; }
      if (e.target.closest('#iv-copy-link')) { await this.copyPublicLink(); return; }
      if (e.target.closest('#iv-copy-email')) { await this.copyEmailBody(); return; }
      const moreDay = e.target.closest('[data-more-day]');
      if (moreDay) { this.extraDays = this.extraDays || []; this.extraDays.push(moreDay.dataset.moreDay + '#' + Date.now()); this._renderBody(); return; }
      const moreWd = e.target.closest('[data-more-weekday]');
      if (moreWd) { this.extraWeekdays = this.extraWeekdays || []; this.extraWeekdays.push(moreWd.dataset.moreWeekday + '#' + Date.now()); this._renderBody(); return; }
      const rmShift = e.target.closest('[data-delete-shift]');
      if (rmShift) { await this.removeShift(Number(rmShift.dataset.deleteShift)); return; }
      const rmDef = e.target.closest('[data-delete-default]');
      if (rmDef) { await this.removeDefault(Number(rmDef.dataset.deleteDefault)); return; }
    });
    el.addEventListener('change', async (e) => {
      if (e.target.matches('[data-ref-game]')) {
        // The button reads "n games, $x" for whatever is ticked.
        const boxes = [...el.querySelectorAll('[data-ref-game]:checked')];
        const amount = boxes.reduce((a, b) => a + Number(b.dataset.amount || 0), 0);
        const btn = el.querySelector('#iv-refs-add');
        if (btn) { btn.disabled = !boxes.length; btn.textContent = this._copy('refs_button', { n: boxes.length, amount: InvoicesScreen.money(amount) }) || `Add referees line — ${boxes.length}, ${InvoicesScreen.money(amount)}`; }
        return;
      }
      const f = e.target.closest('[data-f]');
      if (f) {
        const row = f.closest('[data-line-row]');
        if (row) {
          if (f.dataset.f === 'amount') row.dataset.amountTouched = '1';
          if (f.dataset.f === 'quantity' || f.dataset.f === 'rate') row.dataset.amountTouched = '0';
          await this.saveLine(Number(row.dataset.lineRow));
        }
        return;
      }
      if (e.target.id === 'iv-number') { await this.updateInvoice({ number: Number(e.target.value) }); return; }
      if (e.target.id === 'iv-date') { await this.updateInvoice({ date: e.target.value }); return; }
      if (e.target.id === 'iv-final') { await this.updateInvoice({ is_final: !!e.target.checked }); return; }
      if (e.target.id === 'iv-pstart') { await this.updateInvoice({ period_start: e.target.value }); return; }
      if (e.target.id === 'iv-pend') { await this.updateInvoice({ period_end: e.target.value }); return; }
      if (e.target.id === 'iv-link') { await this.updateInvoice({ link_url: e.target.value }); return; }
      const sf = e.target.closest('[data-sf]');
      if (sf) { await this.saveDay(sf.closest('[data-shift-row]'), sf.dataset.sf); return; }
      const df = e.target.closest('[data-df]');
      if (df) { await this.saveDefaultRow(df.closest('[data-default-row]'), df.dataset.df); return; }
    });
    el.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && e.target.closest('#iv-new-desc, #iv-new-qty, #iv-new-rate')) { e.preventDefault(); this.addLine(); }
      if (e.key === 'Enter' && e.target.closest('[data-sf], [data-df]')) { e.preventDefault(); e.target.blur(); }
      if (e.key === 'Enter' && e.target.closest('[data-f]')) { e.preventDefault(); e.target.blur(); }
    });
  }

  // ── render ────────────────────────────────────────────────────────────

  static SHEET_ROWS = 14;   // rows on Lighthouse's template at full size
  static TIGHT_AT = 20;     // beyond this the rows go smaller still

  static money(n) {
    const v = Number(n) || 0;
    return '$' + v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  static plain(n) {
    const v = Number(n) || 0;
    return Number.isInteger(v) ? String(v) : String(Math.round(v * 100) / 100);
  }
  static addDays(iso, n) {
    const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(iso || ''));
    if (!m) return iso;
    const d = new Date(Date.UTC(+m[1], +m[2] - 1, +m[3] + n));
    return d.toISOString().slice(0, 10);
  }
  static WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static dayLabel(iso) {
    const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(iso || ''));
    if (!m) return iso;
    const d = new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
    return `${InvoicesScreen.WEEKDAYS[d.getUTCDay()]} ${+m[2]}/${+m[3]}`;
  }
  static hoursBetween(start, end) {
    const t = (x) => { const m = /^(\d{1,2}):(\d{2})/.exec(String(x || '')); return m ? (+m[1]) * 60 + (+m[2]) : NaN; };
    const a = t(start), b = t(end);
    if (!Number.isFinite(a) || !Number.isFinite(b) || b <= a) return 0;
    return Math.round((b - a) / 60 * 100) / 100;
  }
  static usDate(iso) {
    const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(iso || ''));
    return m ? `${m[2]}/${m[3]}/${m[1]}` : String(iso || '');
  }

  _renderBody() {
    const body = this.find('#iv-body');
    if (!body) return;
    const esc = (t) => this.escapeHtml(t);
    if (this.loading && !this.board) { body.innerHTML = '<div class="iv-card">Loading…</div>'; return; }
    if (this.error && !this.board) { body.innerHTML = `<div class="iv-flash bad">${esc(this.error)}</div>`; return; }
    if (!this.board) { body.innerHTML = ''; return; }

    const issuer = this._issuer();
    const parts = [];
    if (this.flash) parts.push(`<div class="iv-flash ${this.flashBad ? 'bad' : ''}">${esc(this.flash)}</div>`);

    parts.push(`<div class="iv-pills">${(this.board.issuers || []).map(i =>
      `<button class="iv-pill ${i.id === this.issuerId ? 'on' : ''}" data-issuer="${i.id}">${esc(i.name)}</button>`).join('')}</div>`);

    if (issuer) {
      parts.push(this._renderIssuerCard(issuer));
      parts.push(this._renderInvoiceList(issuer));
      if (this.showUsual) {
        parts.push(`<div class="iv-modal-bg" id="iv-usual-bg"><div class="iv-modal">
          <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
            <div style="font-weight:800;">${this.escapeHtml(issuer.name)} — usual 2 weeks</div>
            <button id="iv-usual-close" class="iv-btn ghost sm">Close</button>
          </div>
          ${this._renderUsualWeek(issuer)}
        </div></div>`);
      }
    }
    if (this.inv) {
      parts.push(this._renderEditor());
      parts.push(`<div class="iv-sec">Sheet</div><div class="inv-preview-wrap"><div class="inv-scale">${this._renderSheet(this.inv)}</div></div>`);
    }
    body.innerHTML = parts.join('');
    this._fitPreview();
  }

  _renderIssuerCard(i) {
    const esc = (t) => this.escapeHtml(t);
    const missing = !i.address || !i.city_state_zip || !i.payable_to || i.hourly_rate == null;
    if (!this.editIssuer) {
      return `
        <div class="iv-card" style="margin-top:var(--space-3);">
          <div style="display:flex; justify-content:space-between; gap:8px; align-items:flex-start;">
            <div>
              <div style="font-weight:800;">${esc(i.name)} <span style="opacity:0.6; font-weight:400; font-size:0.85rem;">· Invoice${esc(i.file_slug)}-${this.board.year}.N.pdf</span></div>
              <div style="font-size:0.9rem; margin-top:4px;">${esc(i.address || '—')} · ${esc(i.city_state_zip || '—')} · ${esc(i.phone || '—')}</div>
              <div style="font-size:0.9rem; margin-top:2px;">${esc(i.duty_description || 'Hours')} @ ${i.hourly_rate == null ? '—' : InvoicesScreen.money(i.hourly_rate)}/h · payable to ${esc(i.payable_to || '—')}${i.bills_expenses ? ' · bills expenses' : ' · hours only'}</div>
              ${missing ? `<div class="iv-hint" style="color:#f59e0b;">${esc(this._copy('missing_from'))}</div>` : ''}
            </div>
            <div style="display:flex; flex-direction:column; gap:6px; align-items:flex-end;">
              <button id="iv-edit-issuer" class="iv-btn ghost sm">✏️ Details</button>
              <button id="iv-usual-open" class="iv-btn ghost sm">🗓 Usual 2 weeks</button>
            </div>
          </div>
        </div>`;
    }
    const v = (x) => esc(x == null ? '' : x);
    return `
      <div class="iv-card" style="margin-top:var(--space-3);">
        <div style="font-weight:800;">${esc(i.name)} — details on the sheet</div>
        <div class="iv-grid">
          <div class="wide"><div class="iv-lbl">Address</div><input class="iv-in" id="iv-is-address" value="${v(i.address)}"></div>
          <div><div class="iv-lbl">City, State, Zip</div><input class="iv-in" id="iv-is-csz" value="${v(i.city_state_zip)}"></div>
          <div><div class="iv-lbl">Phone</div><input class="iv-in" id="iv-is-phone" value="${v(i.phone)}"></div>
          <div><div class="iv-lbl">Make checks payable to</div><input class="iv-in" id="iv-is-payable" value="${v(i.payable_to)}"></div>
          <div><div class="iv-lbl">File name slug</div><input class="iv-in" id="iv-is-slug" value="${v(i.file_slug)}"></div>
          <div><div class="iv-lbl">Hours line reads</div><input class="iv-in" id="iv-is-duty" value="${v(i.duty_description)}"></div>
          <div><div class="iv-lbl">Hourly rate</div><input class="iv-in num" id="iv-is-rate" type="number" step="0.01" min="0" value="${i.hourly_rate == null ? '' : i.hourly_rate}"></div>
        </div>
        <div class="iv-acts">
          <button id="iv-save-issuer" class="iv-btn">Save</button>
          <button id="iv-edit-issuer" class="iv-btn ghost">Cancel</button>
        </div>
      </div>`;
  }

  // One entry row: label | from | till | hours | note | ✕ / +.  `attr` is
  // data-sf (a day on an invoice) or data-df (the usual week).
  _entryRow(attr, keyAttr, keyVal, label, sh, extras) {
    const esc = (t) => this.escapeHtml(t);
    const id = sh ? sh.id : 0;
    const flat = sh && sh.flat;
    return `
      <div class="iv-day" data-${keyAttr}="${id}" ${extras}>
        <div style="font-weight:700;">${esc(label)}</div>
        <div><input class="iv-in" type="time" data-${attr}="start" value="${esc(sh && !flat ? sh.start : '')}"></div>
        <div><input class="iv-in" type="time" data-${attr}="end" value="${esc(sh && !flat ? sh.end : '')}"></div>
        <div><input class="iv-in num" type="number" step="0.25" min="0" data-${attr}="hours" value="${sh ? InvoicesScreen.plain(sh.hours) : ''}" placeholder="h" title="${sh && !flat ? 'From till till; type a number to use a flat figure instead' : 'Flat hours, or fill from and till'}"></div>
        <div class="note"><input class="iv-in" data-${attr}="note" value="${esc(sh ? (sh.note || '') : '')}" placeholder="note"></div>
        <div style="display:flex; gap:4px;">
          ${id ? `<button class="iv-btn danger sm" data-delete-${attr === 'sf' ? 'shift' : 'default'}="${id}" title="Clear this day">✕</button>` : ''}
          ${id ? `<button class="iv-btn ghost sm" data-more-${attr === 'sf' ? 'day' : 'weekday'}="${esc(keyVal)}" title="Another stint the same day">+</button>` : ''}
        </div>
      </div>`;
  }

  _weekdaySel(cur, attrs) {
    return `<select class="iv-in" ${attrs}>${InvoicesScreen.WEEKDAYS.map((d, n) => `<option value="${n}" ${n === cur ? 'selected' : ''}>${d}</option>`).join('')}</select>`;
  }

  _renderUsualWeek(i) {
    const esc = (t) => this.escapeHtml(t);
    const defs = i.default_shifts || [];
    const total = defs.reduce((a, d) => a + (Number(d.hours) || 0), 0);
    let rows = '';
    for (let idx = 0; idx < 14; idx++) {
      const label = `${InvoicesScreen.WEEKDAYS[(5 + idx) % 7]} · wk ${idx < 7 ? 1 : 2}`;
      const mine = defs.filter(d => d.day_index === idx);
      if (!mine.length) rows += this._entryRow('df', 'default-row', String(idx), label, null, `data-day-index="${idx}"`);
      mine.forEach((d, k) => { rows += this._entryRow('df', 'default-row', String(idx), k ? '' : label, d, `data-day-index="${idx}"`); });
      for (const x of (this.extraWeekdays || []).filter(e => e.split('#')[0] === String(idx)))
        rows += this._entryRow('df', 'default-row', String(idx), '', null, `data-day-index="${idx}" data-extra="${esc(x.split('#')[1])}"`);
    }
    return `
      <div class="iv-sec">Friday to the closing Thursday</div>
      <div class="iv-card">
        <div class="iv-hint" style="margin:0 0 6px;">${esc(this._copy('default_hint', { name: i.name }))}</div>
        <div class="iv-day head"><div>Day</div><div>From</div><div>Till</div><div>Hours</div><div class="note">Note</div><div></div></div>
        ${rows}
        <div class="iv-hint">${InvoicesScreen.plain(total)} h an invoice</div>
      </div>`;
  }

  _renderInvoiceList(i) {
    const esc = (t) => this.escapeHtml(t);
    const rows = (i.invoices || []).map(v => `
      <div class="iv-list-row">
        <div style="font-weight:800;">#${v.number}</div>
        <div>${esc(v.week1 || '')} &amp; ${esc(v.week2 || '')} <span style="opacity:0.65;">· ${v.period_start ? `${esc(InvoicesScreen.dayLabel(v.period_start))} – ${esc(InvoicesScreen.dayLabel(v.period_end))} · ` : ''}due ${esc(InvoicesScreen.usDate(v.date))}</span> <span class="iv-tag ${v.is_final ? 'final' : 'draft'}">${v.is_final ? 'final' : 'draft'}</span></div>
        <div class="hrs" style="opacity:0.7;">${InvoicesScreen.plain(v.hours)} h</div>
        <div style="text-align:right; font-weight:700;">${InvoicesScreen.money(v.total)}</div>
        <div style="display:flex; gap:6px; justify-content:flex-end;">
          <button class="iv-btn alt sm" data-open="${v.id}">Open</button>
          <button class="iv-btn danger sm" data-delete-invoice="${v.id}">${this.confirmDelete === v.id ? esc(this._copy('delete_confirm', { number: `${v.year}.${v.number}` })) : '🗑'}</button>
        </div>
      </div>`).join('');
    const plans = (i.open_plans || []);
    return `
      <div class="iv-sec">Invoices</div>
      <div class="iv-card">
        <div class="iv-acts" style="margin:0 0 8px;">
          <button id="iv-new" class="iv-btn">➕ New invoice #${i.next_number}</button>
          ${plans.length ? `<span style="font-size:0.85rem; opacity:0.75;">${plans.length} instalment plan${plans.length === 1 ? '' : 's'} still running — the next invoice picks them up</span>` : ''}
        </div>
        ${rows || `<div style="opacity:0.7; font-size:0.9rem;">${esc(this._copy('empty', { name: i.name }))}</div>`}
      </div>
      ${plans.length ? `
      <div class="iv-sec">Running instalment plans</div>
      <div class="iv-card">
        ${plans.map(p => `
          <div class="iv-list-row" style="grid-template-columns:1fr auto auto;">
            <div>${esc(p.description)} <span style="opacity:0.65;">— ${InvoicesScreen.money(p.per_amount)} × ${p.installment_count}, ${p.used} billed, next is ${p.next_no} of ${p.installment_count}</span></div>
            <div style="opacity:0.7;">${InvoicesScreen.money(p.total_amount)}</div>
            <button class="iv-btn danger sm" data-delete-plan="${p.id}" title="Stop this plan">✕</button>
          </div>`).join('')}
      </div>` : ''}`;
  }

  _renderEditor() {
    const inv = this.inv;
    const esc = (t) => this.escapeHtml(t);
    const cats = this.board.categories || [];
    const catSel = (cur, extra = '') => `<select class="iv-in" ${extra}>${cats.map(c =>
      `<option value="${esc(c.code)}" ${c.code === cur ? 'selected' : ''}>${esc(c.label || 'Hours')}</option>`).join('')}</select>`;
    const lines = (inv.lines || []).map(l => {
      const locked = !!l.plan_id;
      return `
        <div class="iv-row" data-line-row="${l.id}">
          <div>${l.category === 'labor' ? '<span style="opacity:0.6; font-size:0.8rem;">Hours</span>' : catSel(l.category, 'data-f="category"')}</div>
          <div class="desc">${locked
            ? `<span>${esc(l.printed)}</span>`
            : `<input class="iv-in" data-f="description" value="${esc(l.description)}">`}${
            l.category === 'labor' ? '' : locked
              ? (l.budget_line_id ? `<div style="font-size:0.75rem; opacity:0.7; margin-top:2px;">↳ ${esc(((this.board?.budget_lines || []).find(b => b.id === l.budget_line_id) || {}).label || 'planned expense')}</div>` : '')
              : l.ref_games ? `<div style="font-size:0.75rem; opacity:0.7; margin-top:2px;">🧑‍⚖️ ${l.ref_games} game${l.ref_games === 1 ? '' : 's'} ticked off</div>`
              : this._budgetSel(l.category, l.budget_line_id, 'data-f="budget_line_id"')}</div>
          <div><input class="iv-in num" data-f="quantity" type="number" step="0.25" min="0" value="${l.quantity}" ${l.category === 'labor' && (inv.shifts || []).length ? 'disabled title="Adds up the days above"' : `title="${l.category === 'labor' ? 'Hours' : 'Units'}"`}></div>
          <div><input class="iv-in num" data-f="rate" type="number" step="0.01" min="0" value="${l.rate == null ? '' : l.rate}" title="Rate"></div>
          <div style="display:flex; gap:4px; align-items:center;">
            <input class="iv-in num" data-f="amount" type="number" step="0.01" value="${l.amount}" title="Amount">
            <button class="iv-btn danger sm" data-delete-line="${l.id}" title="Remove line">✕</button>
          </div>
        </div>`;
    }).join('');
    const expenses = !!inv.issuer?.bills_expenses;
    return `
      <div class="iv-sec" id="iv-editor">${esc(inv.title || `Invoice #${inv.number}`)}</div>
      <div class="iv-card">
        <div class="iv-grid" style="grid-template-columns:100px 160px 160px 160px 1fr; align-items:end;">
          <div><div class="iv-lbl">Invoice #</div><input class="iv-in num" id="iv-number" type="number" min="1" value="${inv.number}"></div>
          <div><div class="iv-lbl">Work from (Fri)</div><input class="iv-in" id="iv-pstart" type="date" value="${esc(inv.period_start || '')}"></div>
          <div><div class="iv-lbl">Work till (Thu)</div><input class="iv-in" id="iv-pend" type="date" value="${esc(inv.period_end || '')}"></div>
          <div><div class="iv-lbl">Due date (on sheet)</div><input class="iv-in" id="iv-date" type="date" value="${esc(inv.date)}"></div>
          <div><label style="display:flex; gap:6px; align-items:center; font-size:0.9rem; height:36px;"><input type="checkbox" id="iv-final" ${inv.is_final ? 'checked' : ''}> Final (sent)</label></div>
        </div>
        <div class="iv-acts">
          <button id="iv-print" class="iv-btn">🖨 Print / Save PDF</button>
          <button id="iv-email" class="iv-btn alt">✉️ Email ${esc(inv.bill_to?.email_label || 'Lighthouse')}</button>
          <button id="iv-close" class="iv-btn ghost">Close</button>
        </div>
        <div class="iv-hint">${esc(this._copy('print_hint', { file: inv.file_name }))}</div>
        ${(() => { const d = this._emailDraft(); return d ? `
        <div class="iv-card" style="margin-top:8px; background:var(--bg-primary);">
          <div class="iv-lbl">Email draft</div>
          <div class="iv-hint" style="margin:2px 0 4px;">${esc(this._copy('email_hint'))}</div>
          <div style="font-size:0.85rem; margin-top:4px;"><b>To:</b> ${esc(d.to || '—')}${d.cc ? ` &nbsp; <b>Cc:</b> ${esc(d.cc)}` : ''}</div>
          <div style="font-size:0.85rem;"><b>Subject:</b> ${esc(d.subject)}</div>
          <div style="font-size:0.9rem; margin:6px 0 0; padding:8px 10px; border:1px solid var(--border-color); border-radius:8px;">${d.html}</div>
          <div style="margin-top:6px;"><button id="iv-copy-email" class="iv-btn ghost sm">Copy message</button></div>
        </div>` : ''; })()}
        <div class="iv-card" style="margin-top:8px; background:var(--bg-primary);">
          <div class="iv-lbl">Viewable link — anyone with it sees this sheet; this is the link in the email</div>
          <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
            <a href="${esc(this._publicUrl(inv))}" target="_blank" rel="noopener" style="font-size:0.9rem; word-break:break-all;">${esc(this._publicUrl(inv))}</a>
            <button id="iv-copy-link" class="iv-btn ghost sm">Copy</button>
          </div>
          <details style="margin-top:6px; font-size:0.85rem;"><summary style="cursor:pointer; opacity:0.7;">Use a different link instead (e.g. Drive)</summary>
            <input class="iv-in" id="iv-link" type="url" placeholder="https://drive.google.com/…" value="${esc(inv.link_url || '')}" style="margin-top:6px;"></details>
        </div>

        <div class="iv-sec">Hours by day — ${inv.period_start && inv.period_end ? `${esc(InvoicesScreen.dayLabel(inv.period_start))} to ${esc(InvoicesScreen.dayLabel(inv.period_end))}` : 'set the window above'}</div>
        <div class="iv-hint" style="margin:0 0 6px;">${esc(this._copy('hours_hint'))}</div>
        <div class="iv-day head"><div>Day</div><div>From</div><div>Till</div><div>Hours</div><div class="note">Note</div><div></div></div>
        ${(() => {
          const shifts = inv.shifts || [];
          if (!inv.period_start || !inv.period_end) return `<div class="iv-hint">Set the work-from and work-till dates first.</div>`;
          let rows = '';
          for (let d = inv.period_start, n = 0; d <= inv.period_end && n < 62; d = InvoicesScreen.addDays(d, 1), n++) {
            const label = InvoicesScreen.dayLabel(d);
            const mine = shifts.filter(x => x.date === d);
            if (!mine.length) rows += this._entryRow('sf', 'shift-row', d, label, null, `data-date="${d}"`);
            mine.forEach((x, k) => { rows += this._entryRow('sf', 'shift-row', d, k ? '' : label, x, `data-date="${d}"`); });
            for (const e of (this.extraDays || []).filter(e => e.split('#')[0] === d))
              rows += this._entryRow('sf', 'shift-row', d, '', null, `data-date="${d}" data-extra="${esc(e.split('#')[1])}"`);
          }
          return rows;
        })()}
        <div class="iv-acts">
          <span style="font-size:0.9rem; font-weight:700;">${InvoicesScreen.plain(inv.shift_hours || 0)} h over ${(inv.shifts || []).length} day${(inv.shifts || []).length === 1 ? '' : 's'}</span>
          ${inv.is_final ? `<span class="iv-hint" style="margin:0;">Final — the sheet keeps its billed hours; un-tick Final to let these days drive it.</span>` : ''}
          ${!(inv.shifts || []).length ? `<button id="iv-fill" class="iv-btn ghost sm">📅 Fill from usual week</button>` : ''}
        </div>

        <div style="margin-top:var(--space-3);">
          <div class="iv-row head"><div>Section</div><div class="desc">Description</div><div class="r">Hours / units</div><div class="r">Rate</div><div class="r">Amount</div></div>
          ${lines}
        </div>
        <div class="iv-total"><span>TOTAL</span><span>${InvoicesScreen.money(inv.total)}</span></div>
        ${(inv.lines || []).length > InvoicesScreen.SHEET_ROWS ? `<div class="iv-hint" style="color:#f59e0b;">${esc(this._copy('sheet_fit', { n: (inv.lines || []).length, max: InvoicesScreen.SHEET_ROWS }))}</div>`
          : `<div class="iv-hint">${(inv.lines || []).length} of ${InvoicesScreen.SHEET_ROWS} rows on the sheet</div>`}

        ${expenses ? `
        <div class="iv-sec">Add a line</div>
        <div class="iv-row" style="border-top:none;">
          <div>${catSel('other', 'id="iv-new-cat"')}</div>
          <div class="desc"><input class="iv-in" id="iv-new-desc" placeholder="Description">${this._budgetSel('__any__', null, 'id="iv-new-budget"')}</div>
          <div><input class="iv-in num" id="iv-new-qty" type="number" step="1" min="0" value="1" title="Units"></div>
          <div><input class="iv-in num" id="iv-new-rate" type="number" step="0.01" min="0" placeholder="0.00" title="Amount each"></div>
          <div><button id="iv-add-line" class="iv-btn sm">Add</button></div>
        </div>
        <div class="iv-acts">
          <button id="iv-plan-toggle" class="iv-btn ghost sm">${this.showPlanForm ? 'Cancel' : '➕ Instalment plan (k of N)'}</button>
        </div>
        ${this.showPlanForm ? `
        <div class="iv-card" style="margin-top:8px;">
          <div class="iv-hint" style="margin:0 0 6px;">${esc(this._copy('plan_hint', { k: 1, n: 'N' }))}</div>
          <div class="iv-grid" style="grid-template-columns:150px 1fr 120px 90px auto;">
            <div><div class="iv-lbl">Section</div>${catSel('equipment', 'id="iv-plan-cat"')}</div>
            <div><div class="iv-lbl">Description</div><input class="iv-in" id="iv-plan-desc" placeholder="Veo Subscription">${this._budgetSel('__any__', null, 'id="iv-plan-budget"')}</div>
            <div><div class="iv-lbl">Total paid</div><input class="iv-in num" id="iv-plan-total" type="number" step="0.01" min="0" placeholder="862.92"></div>
            <div><div class="iv-lbl">Over N</div><input class="iv-in num" id="iv-plan-count" type="number" step="1" min="1" value="4"></div>
            <div><div class="iv-lbl">&nbsp;</div><label style="font-size:0.85rem; display:flex; gap:6px; align-items:center; height:36px;"><input type="checkbox" id="iv-plan-show"> print total</label></div>
          </div>
          <div class="iv-acts"><button id="iv-plan-add" class="iv-btn">Add plan + first instalment</button></div>
        </div>` : ''}
        ${inv.is_final ? '' : this._renderRefFees()}` : ''}
      </div>`;
  }

  // Referee fees to tick off on this draft (mig 490).
  _renderRefFees() {
    const esc = (t) => this.escapeHtml(t);
    const games = this.refGames || [];
    const picked = [...(this.element?.querySelectorAll('[data-ref-game]:checked') || [])].map(cb => cb.dataset.refGame);
    const rows = games.map(g => `
      <label style="display:flex; gap:10px; align-items:center; padding:4px 0; border-bottom:1px solid var(--border-color); font-size:0.9rem; ${g.played ? '' : 'opacity:0.65;'}">
        <input type="checkbox" data-ref-game="${esc(g.source)}:${g.ref_id}" data-amount="${g.amount}" ${picked.includes(`${g.source}:${g.ref_id}`) || (g.played && !picked.length && false) ? 'checked' : ''}>
        <span style="width:90px; font-weight:700;">${esc(g.date_label)}</span>
        <span style="width:110px; opacity:0.8;">${esc(g.policy_label.replace(/^Parks & Rec /, ''))}</span>
        <span style="flex:1;">${esc(g.opponent)}</span>
        <span style="width:70px; text-align:right;">${InvoicesScreen.money(g.amount)}</span>
        <span style="width:90px; text-align:right; font-size:0.78rem; opacity:0.7;">${g.played ? 'played' : 'upcoming'}</span>
      </label>`).join('');
    return `
      <div class="iv-sec">🧑‍⚖️ ${esc(this._copy('refs_title') || 'Referee fees')}</div>
      <div class="iv-card">
        <div class="iv-hint" style="margin:0 0 6px;">${esc(this._copy('refs_hint'))}</div>
        ${rows || `<div class="iv-hint">${esc(this._copy('refs_empty') || 'No home games waiting to be invoiced.')}</div>`}
        ${rows ? `<div class="iv-acts"><button id="iv-refs-add" class="iv-btn" disabled>${esc(this._copy('refs_button', { n: 0, amount: '$0.00' }))}</button></div>` : ''}
      </div>`;
  }

  _renderSheet(inv) {
    const esc = (t) => this.escapeHtml(t);
    const is = inv.issuer || {};
    const bt = inv.bill_to || {};
    const lines = inv.lines || [];
    const f = (x, y, text, size = 10, cls = '', w = null) =>
      `<div class="sh-f ${cls}" style="left:${x}pt; top:${y}pt; font-size:${size}pt;${w != null ? ` width:${w}pt;` : ''}">${esc(text)}</div>`;
    // Table geometry from the template: 14 rows from y=359 to 607, columns at
    // x = 94 | 335 | 399 | 460 | 524 (description, hours/units, rate, amount).
    const ROWS = InvoicesScreen.SHEET_ROWS, TOP = 359, PITCH = 17.7;
    const COL = { desc: 100, hoursL: 335, hoursW: 64, rateL: 399, rateW: 61, amtR: 517, catR: 88 };
    const rateText = (l) => l.rate == null ? '' : (l.category === 'labor' ? InvoicesScreen.plain(l.rate) : InvoicesScreen.money(l.rate));
    let body = '';
    if (lines.length <= ROWS) {
      let lastCat = null;
      lines.forEach((l, i) => {
        const y = TOP + i * PITCH + 3;
        const label = l.category !== lastCat ? (l.category_label || '') : '';
        lastCat = l.category;
        if (label) body += f(0, y, label, 10, 'r', COL.catR);
        body += f(COL.desc, y, l.printed, 10, '', 233);
        body += f(COL.hoursL, y, InvoicesScreen.plain(l.quantity), 10, 'c', COL.hoursW);
        body += f(COL.rateL, y, rateText(l), 10, 'c', COL.rateW);
        body += f(COL.amtR - 60, y, InvoicesScreen.money(l.amount), 10, 'r', 60);
      });
    } else {
      // More lines than the template has rows: cover its 14 rows with our own
      // grid at a tighter pitch, same columns, so it still reads as the sheet.
      const size = lines.length > InvoicesScreen.TIGHT_AT ? 7.5 : 8.5;
      let lastCat = null;
      const rows = lines.map(l => {
        const label = l.category !== lastCat ? (l.category_label || '') : '';
        lastCat = l.category;
        return `<tr><td class="r" style="border:none; width:${COL.catR - 94 + 2}pt;">${esc(label)}</td><td>${esc(l.printed)}</td><td class="c">${InvoicesScreen.plain(l.quantity)}</td><td class="c">${esc(rateText(l))}</td><td class="r">${InvoicesScreen.money(l.amount)}</td></tr>`;
      }).join('');
      body += `<div class="sh-over" style="left:0; width:524pt; font-size:${size}pt;"><table><colgroup><col style="width:94pt"><col><col style="width:64pt"><col style="width:61pt"><col style="width:64pt"></colgroup>${rows}</table></div>`;
    }
    return `
      <div class="inv-sheet">
        <img class="sh-bg" src="images/invoice-template.png" alt="">
        ${f(122, 140, is.address || '', 12)}
        ${f(133, 160, is.city_state_zip || '', 12)}
        ${f(111, 182, is.phone || '', 12)}
        ${f(424, 161, String(inv.number), 10)}
        ${f(407, 193, inv.date_us || InvoicesScreen.usDate(inv.date), 10)}
        ${bt.contact_name ? f(122, 244, bt.contact_name, 8) : ''}
        ${body}
        ${f(COL.amtR - 70, 612, InvoicesScreen.money(inv.total), 10, 'r', 74)}
        ${f(220, 633, is.payable_to || '', 12)}
      </div>`;
  }

  // The sheet is a fixed 8.5×11 in; on a narrow screen scale the preview down to fit.
  _fitPreview() {
    const wrap = this.find('.inv-preview-wrap');
    const inner = wrap && wrap.querySelector('.inv-scale');
    if (!wrap || !inner) return;
    const sheetW = 816;   // 612pt in CSS px
    const scale = Math.min(1, (wrap.clientWidth || sheetW) / sheetW);
    inner.style.transform = `scale(${scale})`;
    wrap.style.height = `${Math.ceil(1056 * scale) + 16}px`;
  }
}
