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
        .iv-row { display:grid; grid-template-columns:70px 1fr 80px 90px 60px; gap:8px; align-items:center; padding:8px 0;
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
        @media (max-width: 720px) {
          .iv-row { grid-template-columns:1fr 1fr; }
          .iv-row .desc { grid-column:1 / -1; }
          .iv-row.head { display:none; }
          .iv-grid { grid-template-columns:1fr; }
          .iv-list-row { grid-template-columns:60px 1fr 90px; }
          .iv-list-row .hrs { display:none; }
        }

        /* ── the sheet: Lighthouse's InvoiceTemplate ─────────────────── */
        .inv-sheet { background:#fff; color:#000; font-family:Arial, Helvetica, sans-serif; width:100%; max-width:8.5in;
                     margin:0 auto; padding:0.55in 0.6in 0.6in; box-sizing:border-box; box-shadow:0 2px 12px rgba(0,0,0,0.25);
                     position:relative; min-height:10.5in; }
        .inv-sheet .sh-title { text-align:right; font-size:34pt; font-weight:800; color:#5a5a5a; letter-spacing:0.5px;
                               line-height:1; margin:0.15in 0.05in 0.25in 0; }
        .inv-sheet .sh-top { display:flex; justify-content:space-between; align-items:flex-start; gap:0.4in; }
        .inv-sheet .sh-from { flex:1; }
        .inv-sheet .sh-row { display:grid; grid-template-columns:1.05in 1fr; align-items:baseline; margin:0 0 7pt; }
        .inv-sheet .sh-row .lbl { font-size:7.5pt; text-align:right; padding-right:8pt; white-space:nowrap; }
        .inv-sheet .sh-row .val { font-size:10.5pt; }
        .inv-sheet .sh-row .val.sm { font-size:7.5pt; }
        .inv-sheet .sh-billto { font-size:8pt; font-weight:700; margin:12pt 0 9pt 0.32in; }
        .inv-sheet .sh-meta { width:2.3in; padding-top:14pt; }
        .inv-sheet .sh-meta div { display:grid; grid-template-columns:0.95in 1fr; align-items:baseline; margin-bottom:16pt; }
        .inv-sheet .sh-meta b { font-size:8.5pt; }
        .inv-sheet .sh-meta span { font-size:10.5pt; }
        .inv-sheet table.sh-table { width:100%; border-collapse:collapse; margin-top:0.35in; font-size:10pt; page-break-inside:avoid; }
        .inv-sheet table.sh-table th { font-size:8.5pt; font-weight:700; text-align:center; padding:4pt 3pt; border:1px solid #333; }
        .inv-sheet table.sh-table td { border:1px solid #333; padding:3pt 6pt; height:15pt; }
        .inv-sheet table.sh-table th.cat, .inv-sheet table.sh-table td.cat { border:none; width:0.8in; text-align:right;
                               font-size:10pt; padding-right:6pt; white-space:nowrap; }
        .inv-sheet table.sh-table thead tr { border-top:3px solid #333; }
        .inv-sheet table.sh-table th.cat { border:none; }
        .inv-sheet table.sh-table td.r { text-align:right; white-space:nowrap; }
        .inv-sheet table.sh-table td.c { text-align:center; white-space:nowrap; }
        .inv-sheet table.sh-table td.desc { width:auto; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:3.6in; }
        .inv-sheet table.sh-table .col-hu { width:0.8in; } .inv-sheet table.sh-table .col-rate { width:0.8in; }
        .inv-sheet table.sh-table .col-amt { width:0.95in; }
        .inv-sheet table.sh-table tr.total td { border:none; }
        .inv-sheet table.sh-table tr.total td.lbl { text-align:right; font-weight:700; font-size:8.5pt; padding-right:8pt; }
        .inv-sheet table.sh-table tr.total td.amt { border:1px solid #333; text-align:right; white-space:nowrap; }
        .inv-sheet .sh-payable { display:flex; align-items:center; gap:6pt; margin:14pt 0 0 0.4in; font-size:8.5pt; font-weight:700; }
        .inv-sheet .sh-payable .box { flex:0 0 3.2in; border:1px solid #333; min-height:16pt; font-weight:400; font-size:11pt;
                                      padding:1pt 6pt; box-sizing:border-box; }
        .inv-sheet .sh-thanks { text-align:center; font-size:8.5pt; font-weight:700; margin-top:0.45in; }
        .inv-sheet .sh-page { position:absolute; left:0; right:0; bottom:0.3in; text-align:center; font-size:7pt; color:#999; }
        .inv-preview-wrap { overflow:auto; padding:8px 0; }
        @media (max-width: 720px) { .inv-sheet { padding:0.35in 0.3in; min-height:0; }
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
      this.inv = body;
      this.issuerId = body.issuer_id;
      this.showPlanForm = false;
      this.flash = '';
      this._renderBody();
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
      this.inv = await this._post(`/api/invoices/${this.inv.id}/line`, { category: cat, description: desc, quantity: qty, rate });
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
    const style = document.createElement('style');
    style.textContent = `
      @media print {
        @page { size: letter; margin: 0.4in; }
        body.inv-printing > :not(.inv-print-root) { display:none !important; }
        body.inv-printing { background:#fff !important; margin:0; }
        .inv-print-root .inv-sheet { box-shadow:none; max-width:none; width:100%; min-height:0; padding:0.15in 0.2in; }
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
      if (pill) { this.issuerId = Number(pill.dataset.issuer); this.editIssuer = false; this.confirmDelete = 0; this._renderBody(); return; }
      if (e.target.closest('#iv-new')) { await this.newInvoice(); return; }
      if (e.target.closest('#iv-edit-issuer')) { this.editIssuer = !this.editIssuer; this._renderBody(); return; }
      if (e.target.closest('#iv-save-issuer')) { await this.saveIssuer(); return; }
      if (e.target.closest('#iv-close')) { this.inv = null; this._renderBody(); return; }
      if (e.target.closest('#iv-print')) { this.print(); return; }
      if (e.target.closest('#iv-add-line')) { await this.addLine(); return; }
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
    });
    el.addEventListener('change', async (e) => {
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
    });
    el.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && e.target.closest('#iv-new-desc, #iv-new-qty, #iv-new-rate')) { e.preventDefault(); this.addLine(); }
      if (e.key === 'Enter' && e.target.closest('[data-f]')) { e.preventDefault(); e.target.blur(); }
    });
  }

  // ── render ────────────────────────────────────────────────────────────

  static money(n) {
    const v = Number(n) || 0;
    return '$' + v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  static plain(n) {
    const v = Number(n) || 0;
    return Number.isInteger(v) ? String(v) : String(Math.round(v * 100) / 100);
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
    }
    if (this.inv) {
      parts.push(this._renderEditor());
      parts.push(`<div class="iv-sec">Sheet</div><div class="inv-preview-wrap">${this._renderSheet(this.inv)}</div>`);
    }
    body.innerHTML = parts.join('');
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
            <button id="iv-edit-issuer" class="iv-btn ghost sm">✏️ Details</button>
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

  _renderInvoiceList(i) {
    const esc = (t) => this.escapeHtml(t);
    const rows = (i.invoices || []).map(v => `
      <div class="iv-list-row">
        <div style="font-weight:800;">${v.year}.${v.number}</div>
        <div>${esc(InvoicesScreen.usDate(v.date))} <span class="iv-tag ${v.is_final ? 'final' : 'draft'}">${v.is_final ? 'final' : 'draft'}</span></div>
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
            : `<input class="iv-in" data-f="description" value="${esc(l.description)}">`}</div>
          <div><input class="iv-in num" data-f="quantity" type="number" step="0.25" min="0" value="${l.quantity}" title="${l.category === 'labor' ? 'Hours' : 'Units'}"></div>
          <div><input class="iv-in num" data-f="rate" type="number" step="0.01" min="0" value="${l.rate == null ? '' : l.rate}" title="Rate"></div>
          <div style="display:flex; gap:4px; align-items:center;">
            <input class="iv-in num" data-f="amount" type="number" step="0.01" value="${l.amount}" title="Amount">
            <button class="iv-btn danger sm" data-delete-line="${l.id}" title="Remove line">✕</button>
          </div>
        </div>`;
    }).join('');
    const expenses = !!inv.issuer?.bills_expenses;
    return `
      <div class="iv-sec" id="iv-editor">Invoice ${inv.year}.${inv.number} — ${esc(inv.issuer?.name || '')}</div>
      <div class="iv-card">
        <div class="iv-grid" style="grid-template-columns:120px 170px 1fr auto; align-items:end;">
          <div><div class="iv-lbl">Invoice #</div><input class="iv-in num" id="iv-number" type="number" min="1" value="${inv.number}"></div>
          <div><div class="iv-lbl">Date</div><input class="iv-in" id="iv-date" type="date" value="${esc(inv.date)}"></div>
          <div><label style="display:flex; gap:6px; align-items:center; font-size:0.9rem;"><input type="checkbox" id="iv-final" ${inv.is_final ? 'checked' : ''}> Final (sent)</label></div>
          <div class="iv-acts" style="margin:0;">
            <button id="iv-print" class="iv-btn">🖨 Print / Save PDF</button>
            <button id="iv-close" class="iv-btn ghost">Close</button>
          </div>
        </div>
        <div class="iv-hint">${esc(this._copy('print_hint', { file: inv.file_name }))}</div>

        <div style="margin-top:var(--space-3);">
          <div class="iv-row head"><div>Section</div><div class="desc">Description</div><div class="r">Hours / units</div><div class="r">Rate</div><div class="r">Amount</div></div>
          ${lines}
        </div>
        <div class="iv-total"><span>TOTAL</span><span>${InvoicesScreen.money(inv.total)}</span></div>

        ${expenses ? `
        <div class="iv-sec">Add a line</div>
        <div class="iv-row" style="border-top:none;">
          <div>${catSel('other', 'id="iv-new-cat"')}</div>
          <div class="desc"><input class="iv-in" id="iv-new-desc" placeholder="Description"></div>
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
            <div><div class="iv-lbl">Description</div><input class="iv-in" id="iv-plan-desc" placeholder="Veo Subscription"></div>
            <div><div class="iv-lbl">Total paid</div><input class="iv-in num" id="iv-plan-total" type="number" step="0.01" min="0" placeholder="862.92"></div>
            <div><div class="iv-lbl">Over N</div><input class="iv-in num" id="iv-plan-count" type="number" step="1" min="1" value="4"></div>
            <div><div class="iv-lbl">&nbsp;</div><label style="font-size:0.85rem; display:flex; gap:6px; align-items:center; height:36px;"><input type="checkbox" id="iv-plan-show"> print total</label></div>
          </div>
          <div class="iv-acts"><button id="iv-plan-add" class="iv-btn">Add plan + first instalment</button></div>
        </div>` : ''}` : ''}
      </div>`;
  }

  _renderSheet(inv) {
    const esc = (t) => this.escapeHtml(t);
    const is = inv.issuer || {};
    const bt = inv.bill_to || {};
    const lines = inv.lines || [];
    const MIN_ROWS = 14;
    let lastCat = null;
    const rows = lines.map(l => {
      const label = l.category !== lastCat ? (l.category_label || '') : '';
      lastCat = l.category;
      const rate = l.rate == null ? '' : (l.category === 'labor' ? InvoicesScreen.plain(l.rate) : InvoicesScreen.money(l.rate));
      return `<tr><td class="cat">${esc(label)}</td><td class="desc">${esc(l.printed)}</td><td class="c">${InvoicesScreen.plain(l.quantity)}</td><td class="c">${esc(rate)}</td><td class="r">${InvoicesScreen.money(l.amount)}</td></tr>`;
    });
    while (rows.length < MIN_ROWS) rows.push('<tr><td class="cat"></td><td class="desc">&nbsp;</td><td></td><td></td><td></td></tr>');
    return `
      <div class="inv-sheet">
        <div class="sh-title">INVOICE</div>
        <div class="sh-top">
          <div class="sh-from">
            <div class="sh-row"><span class="lbl">Address:</span><span class="val">${esc(is.address || '')}</span></div>
            <div class="sh-row"><span class="lbl">City, State, Zip:</span><span class="val">${esc(is.city_state_zip || '')}</span></div>
            <div class="sh-row"><span class="lbl">Phone:</span><span class="val">${esc(is.phone || '')}</span></div>
            <div class="sh-billto">BILL TO:</div>
            <div class="sh-row"><span class="lbl">Organization:</span><span class="val sm">${esc(bt.organization || '')}</span></div>
            <div class="sh-row"><span class="lbl">Name:</span><span class="val sm">${esc(bt.contact_name || '')}</span></div>
            <div class="sh-row"><span class="lbl">Address:</span><span class="val sm">${esc(bt.address || '')}</span></div>
            <div class="sh-row"><span class="lbl">City, State, Zip:</span><span class="val sm">${esc(bt.city_state_zip || '')}</span></div>
          </div>
          <div class="sh-meta">
            <div><b>INVOICE#:</b><span>${inv.number}</span></div>
            <div><b>DATE:</b><span>${esc(inv.date_us || InvoicesScreen.usDate(inv.date))}</span></div>
          </div>
        </div>
        <table class="sh-table">
          <thead><tr><th class="cat"></th><th>DESCRIPTION</th><th class="col-hu">HOURS/UNITS</th><th class="col-rate">RATE</th><th class="col-amt">AMOUNT</th></tr></thead>
          <tbody>
            ${rows.join('')}
            <tr class="total"><td class="cat"></td><td class="lbl" colspan="3">TOTAL</td><td class="amt">${InvoicesScreen.money(inv.total)}</td></tr>
          </tbody>
        </table>
        <div class="sh-payable"><span>${esc(this._copy('payable') || 'Make all checks payable to:')}</span><span class="box">${esc(is.payable_to || '')}</span></div>
        <div class="sh-thanks">${esc(this._copy('thanks') || 'Thank you for your business!')}</div>
      </div>`;
  }
}
