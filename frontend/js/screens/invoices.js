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
    this.confirmDelete = 0;
    // 📅 Period calendar (owner 2026-10-20: "a calendar type thing …
    // calendar and pills to show hide things … running total of invoice
    // below it").  Which chip kinds are showing; remembered per browser.
    this.calKinds = { match: true, practice: true, claim: true, ref: true, expense: true };
    // The calendar IS the editor (mig 703; owner 2026-10-26: "i am
    // proposing no line item section"): ＋ on a day, tap a 💵 chip, or the
    // ⋯ of an event chip each open one popup.
    this.addOn = '';          // ＋ day being added to (YYYY-MM-DD)
    this.addMode = 'expense'; // expense | hours | plan
    this.editLine = 0;        // 💵 line open in the popup
    this.detailFor = null;    // event chip key (f123 / g456) open in the popup
    try { Object.assign(this.calKinds, JSON.parse(localStorage.getItem('invoices.calKinds') || '{}')); } catch (err) { /* private window */ }
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
        .iv-inv-row { display:flex; flex-wrap:wrap; gap:6px 8px; align-items:center; padding:8px 0;
                      border-top:1px solid var(--border-color); font-size:0.9rem; }
        .iv-inv-row:first-child { border-top:none; }
        .iv-inv-row .iv-in { width:auto; }
        .iv-tag { display:inline-block; padding:2px 8px; border-radius:999px; font-size:0.72rem; border:1px solid var(--border-color); }
        .iv-tag.final { border-color:#4ade80; color:#4ade80; }
        .iv-tag.draft { border-color:#f59e0b; color:#f59e0b; }
        .iv-tag.due { border-color:#f87171; color:#f87171; font-weight:800; }
        .iv-mk { width:30px; height:26px; border-radius:8px; border:1px solid var(--border-color); background:transparent;
                 color:var(--text-primary); cursor:pointer; font-weight:800; font-size:0.85rem; opacity:0.55; }
        .iv-mk.on-yes { background:#4ade80; border-color:#4ade80; color:#0b1c3d; opacity:1; }
        .iv-mk.on-no { background:#f87171; border-color:#f87171; color:#fff; opacity:1; }
        .iv-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .iv-flash.bad { background:rgba(248,113,113,0.15); }
        /* 📅 period calendar */
        .iv-cal { display:grid; grid-template-columns:repeat(7, 1fr); gap:4px; margin-top:6px; }
        .iv-cal .hd { font-size:0.68rem; font-weight:700; text-transform:uppercase; letter-spacing:0.04em; opacity:0.6; text-align:center; padding:2px 0; }
        .iv-cal .cell { border:1px solid var(--border-color); border-radius:8px; min-height:74px; padding:4px 5px 3px;
                        display:flex; flex-direction:column; gap:3px; background:var(--bg-primary); min-width:0; }
        .iv-cal .cell.out { opacity:0.32; background:transparent; }
        .iv-cal .dnum { font-size:0.7rem; font-weight:700; opacity:0.7; }
        .iv-cal .iv-wd { display:none; }
        @media (max-width: 720px) { .iv-cal .iv-wd { display:inline; } }
        .iv-chip { display:flex; gap:4px; align-items:center; border:1px solid var(--border-color); border-radius:6px;
                   padding:2px 5px; font-size:0.68rem; line-height:1.25; cursor:pointer; background:transparent;
                   color:var(--text-primary); text-align:left; min-width:0; }
        .iv-chip > span { white-space:normal; overflow-wrap:anywhere; }
        .iv-chip.on { background:rgba(74,222,128,0.18); border-color:#4ade80; }
        .iv-chip.part { background:rgba(234,179,8,0.20); border-color:#eab308; }
        .iv-chip.off { border-color:#f87171; background:rgba(248,113,113,0.12); }
        .iv-chip.off .iv-chip-zone:first-child { text-decoration:line-through; opacity:0.6; }
        .iv-chip.todo { border-color:#f59e0b; }
        .iv-chip.ref { border-style:dashed; }
        .iv-ev { display:flex; flex-direction:column; min-width:0; text-align:left; }
        .iv-ev > span { white-space:normal; overflow-wrap:anywhere; }
        .iv-ev .pl { opacity:0.7; font-size:0.92em; }
        .iv-chip.ovl { box-shadow:inset 0 0 0 2px #f87171; }
        .iv-chip.exp { border-color:#60a5fa; background:rgba(96,165,250,0.14); }
        .iv-cal-add { border:none; background:transparent; color:var(--text-primary); cursor:pointer; padding:0 2px;
                      font-size:0.85rem; line-height:1; opacity:0.45; min-width:0; min-height:0; }
        .iv-cal-add:hover { opacity:1; }
        .iv-chip-zone { border:none; background:transparent; color:inherit; cursor:pointer; padding:0; font-size:inherit;
                        display:flex; gap:4px; align-items:center; min-width:0; }
        .iv-chip-zone > span { white-space:normal; overflow-wrap:anywhere; }
        .iv-mk.on-part { background:#eab308; border-color:#eab308; color:#0b1c3d; opacity:1; }
        .iv-part-box { display:flex; gap:4px; align-items:center; border:1px solid #eab308; border-radius:6px;
                       padding:3px 5px; font-size:0.68rem; background:rgba(234,179,8,0.10); }
        .iv-part-box input { width:58px; }
        .iv-cal .dsum { margin-top:auto; font-size:0.66rem; font-weight:700; text-align:right; opacity:0.85; }
        .iv-cal-tot { display:flex; flex-wrap:wrap; gap:6px 16px; justify-content:flex-end; align-items:baseline;
                      padding:8px 4px 2px; font-size:0.85rem; }
        .iv-cal-tot b { font-size:1.05rem; }
        /* Every chip's whole text shows (owner 2026-10-26: "i need to be able to
           read all text on cal items even if you need to extend them"): chips
           wrap and cells grow; on a phone the week stacks one day per row. */
        .iv-chip, .iv-chip-zone { align-items:flex-start; }
        @media (max-width: 720px) {
          .iv-cal { grid-template-columns:1fr; }
          .iv-cal .hd, .iv-cal .cell.out { display:none; }
          .iv-cal .cell { min-height:0; }
          .iv-chip { font-size:0.8rem; padding:4px 6px; }
        }
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

  onEnter() {
    this._autoOpened = false;
    this.load().then(() => {
      // Land on the invoice that is due, not just the list (owner
      // 2026-10-12: "it needs to be the ones due the friday that passed").
      if (!this._autoOpened && !this.inv) { this._autoOpened = true; this.openDueInvoice(); }
    });
  }

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

  // The ONE invoice the club is dealing with now (owner 2026-10-12: "we
  // are ONLY worried about the invoicess that ended oct 8 and were due oct
  // 9 … default showing invoices weak leading up and until sent to
  // julian"): board.due_year/due_number name the period whose due Friday
  // is within a week, and its sheet keeps the spotlight until Final (sent)
  // is ticked.  Older unsent drafts stay plain rows.
  _isDue(v) {
    return !!v && !v.is_final && v.year === this.board?.due_year && v.number === this.board?.due_number;
  }

  _dueInvoice(issuer) {
    return (issuer?.invoices || []).find(v => this._isDue(v)) || null;
  }

  // Picking an issuer (or landing on the page) opens their due invoice by
  // itself, so the sheet on screen is the one to check and send.
  async openDueInvoice() {
    const due = this._dueInvoice(this._issuer());
    if (due && (!this.inv || this.inv.id !== due.id)) await this.openInvoice(due.id);
  }

  _say(text, bad = false) { this.flash = text; this.flashBad = bad; this._renderBody(); }

  async openInvoice(id) {
    try {
      const res = await this.auth.fetch(`/api/invoices/${id}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (!this.inv || this.inv.id !== body.id) { this.editShift = 0; this.addOn = ''; this.editLine = 0; this.detailFor = null; }
      this.inv = body;
      this.issuerId = body.issuer_id;
      this.flash = '';
      // Reality check from gcal (owner 2026-10-12): the backend just held
      // this draft's days against the calendar — say what changed.
      if (body.reality) {
        const r = body.reality, bits = [];
        if (r.removed) bits.push(this._copy('reality_removed', { n: r.removed, list: (r.removed_notes || []).join(', ') }) || `${r.removed} day(s) came off — cancelled on the calendar: ${(r.removed_notes || []).join(', ')}`);
        if (r.moved) bits.push(this._copy('reality_moved', { n: r.moved, list: (r.moved_notes || []).join(', ') }) || `${r.moved} day(s) moved to match the calendar: ${(r.moved_notes || []).join(', ')}`);
        this.flash = bits.join(' '); this.flashBad = true;
      }
      this._renderBody();
      this._loadRefGames();
      this._loadGames();
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
      const res = await this.auth.fetch(`/api/invoices/ref-fees?invoice=${inv.id}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (this.inv && this.inv.id === inv.id) { this.refGames = body.games || []; this._renderBody(); }
    } catch (err) { console.warn('ref fees unavailable:', err.message); }
  }

  // Games off the calendar (mig 531): the period's matches of a team the
  // issuer coaches, to tick and add as day rows.  Owner 2026-10-06: "we
  // are missing youth games that were played. u12 parkwood game on sunday".
  async _loadGames() {
    const inv = this.inv;
    if (!inv || inv.is_final) { this.calGames = []; return; }
    try {
      const res = await this.auth.fetch(`/api/invoices/${inv.id}/games`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (this.inv && this.inv.id === inv.id) { this.calGames = body.games || []; this._renderBody(); }
    } catch (err) { console.warn('calendar games unavailable:', err.message); }
  }

  // 🧑‍⚖️ one fee on/off the sheet, or its amount (mig 624) — `tag` is
  // "source:ref_id"; game_on/opponent ride along so a drifted fixture id
  // still finds its payment row.
  async _markRefFee(tag, action, data, amount) {
    if (!this.inv || !tag) return;
    const [source, id] = tag.split(':');
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/ref-fee-mark`, {
        source, ref_id: Number(id), action,
        game_on: data.refGameOn || '', opponent: data.refOpp || '',
        ...(action === 'amount' ? { amount } : {}),
      });
      await this.load();
      this._loadRefGames();
    } catch (err) { this._say(err.message, true); }
  }

  // One dashed 🧑‍⚖️ chip on the 📅 calendar = one fee straight onto the
  // sheet; `tag` is the chip's "source:ref_id".
  async _addSingleRefFee(tag) {
    if (!this.inv || !tag) return;
    const [source, id] = tag.split(':');
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/ref-fees`, { games: [{ source, ref_id: Number(id) }] });
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

  // 💵 the line popup's Save — a new line on the ＋ day (editLine 0) or
  // the open line.  Every line carries a day (mig 703).
  async saveLine() {
    if (!this.inv) return;
    const v = (id) => (this.find(`#iv-ln-${id}`)?.value ?? '').trim();
    const line = (this.inv.lines || []).find(l => l.id === this.editLine) || null;
    const qty = v('qty') === '' ? 1 : Number(v('qty'));
    const rate = v('rate') === '' ? null : Number(v('rate'));
    const amt = v('amt') === '' ? null : Number(v('amt'));
    const payload = {
      category: line && line.category === 'labor' ? 'labor' : (v('cat') || 'other'),
      description: line && line.plan_id ? line.description : v('desc'),
      quantity: Number.isFinite(qty) ? qty : 1,
      date: v('date'),
    };
    if (!payload.description) { this._say('Describe the line first.', true); return; }
    if (rate !== null && Number.isFinite(rate)) payload.rate = rate;
    if (amt !== null && Number.isFinite(amt)) payload.amount = amt;
    else if (payload.rate != null) payload.amount = Math.round(payload.quantity * payload.rate * 100) / 100;
    else { this._say('Enter the amount.', true); return; }
    if (payload.rate == null && payload.quantity === 1) payload.rate = payload.amount;
    const bsel = this.find('#iv-ln-budget');
    if (bsel) payload.budget_line_id = Number(bsel.value) || null;
    if (line) payload.id = line.id;
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/line`, payload);
      this.editLine = 0; this.addOn = '';
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  async removeLine(lineId) {
    if (!this.inv) return;
    try {
      await this._delete(`/api/invoices/line?id=${lineId}`);
      this.editLine = 0;
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
      this.addOn = '';
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
      this.inv = await this._post(`/api/invoices/${this.inv.id}/shift`, payload);
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

  // ✉️ straight off the invoice row (owner 2026-10-12: the number, dates
  // covered and due date live on the row "to see it and edit it send it").
  // Same message as the editor's Email button, without opening the sheet.
  async emailRow(id) {
    try {
      const res = await this.auth.fetch(`/api/invoices/${id}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      const d = this._emailDraft(body);
      if (!d) return;
      if (!d.to) { this._say('No email on the bill-to row.', true); return; }
      const copied = await this._copyEmailBody(d);
      this.openGmailCompose(this.buildGmailComposeHref({ to: d.to, cc: d.cc, subject: d.subject, body: copied ? '' : d.body }));
      if (copied) this._say(this._copy('email_copied') || 'Message copied — paste it into the Gmail body.');
    } catch (err) { this._say(err.message, true); }
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
  // ("so i can see if its what we need") and sent by emailDeputy() — or, for
  // a row's ✉️ button (mig 569), built from a fetched invoice.
  _emailDraft(inv = this.inv) {
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
        const switched = next !== this.issuerId;
        if (switched) this.inv = null;
        this.issuerId = next; this.editIssuer = false; this.confirmDelete = 0; this._renderBody();
        if (switched) await this.openDueInvoice();   // their due sheet straight away
        return;
      }
      if (e.target.closest('#iv-new')) { await this.newInvoice(); return; }
      if (e.target.closest('#iv-edit-issuer')) { this.editIssuer = !this.editIssuer; this._renderBody(); return; }
      if (e.target.closest('#iv-save-issuer')) { await this.saveIssuer(); return; }
      if (e.target.closest('#iv-close')) { this.inv = null; this._renderBody(); return; }
      if (e.target.closest('#iv-print')) { this.print(); return; }
      if (e.target.closest('#iv-plan-add')) { await this.addPlan(); return; }
      // 📅 the calendar's popups (mig 703): ＋ on a day, a 💵 line, an
      // event chip's ⋯ details.
      const calAdd = e.target.closest('[data-cal-add]');
      if (calAdd) { this.addOn = calAdd.dataset.calAdd; this.addMode = 'expense'; this.editLine = 0; this._renderBody(); this.find('#iv-ln-desc')?.focus(); return; }
      const addMode = e.target.closest('[data-add-mode]');
      if (addMode) { this.addMode = addMode.dataset.addMode; this._renderBody(); return; }
      const edLine = e.target.closest('[data-edit-line]');
      if (edLine) { this.editLine = Number(edLine.dataset.editLine); this.addOn = ''; this._renderBody(); return; }
      if (e.target.closest('#iv-ln-save')) { await this.saveLine(); return; }
      const calDetail = e.target.closest('[data-cal-detail]');
      if (calDetail) { this.detailFor = calDetail.dataset.calDetail; this.partialFor = null; this._renderBody(); return; }
      if (e.target.closest('[data-pop-close]') || e.target.id === 'iv-pop-bg') {
        this.addOn = ''; this.editLine = 0; this.detailFor = null; this.partialFor = null; this._renderBody(); return;
      }
      const em = e.target.closest('[data-email-invoice]');
      if (em) { await this.emailRow(Number(em.dataset.emailInvoice)); return; }
      const open = e.target.closest('[data-open]');
      if (open) { await this.openInvoice(Number(open.dataset.open)); return; }
      const del = e.target.closest('[data-delete-invoice]');
      if (del) { await this.removeInvoice(Number(del.dataset.deleteInvoice)); return; }
      const rmLine = e.target.closest('[data-delete-line]');
      if (rmLine) { await this.removeLine(Number(rmLine.dataset.deleteLine)); return; }
      const rmPlan = e.target.closest('[data-delete-plan]');
      if (rmPlan) { await this.removePlan(Number(rmPlan.dataset.deletePlan)); return; }
      if (e.target.closest('#iv-nd-save')) { await this.addDayManual(); return; }
      const edt = e.target.closest('[data-edit-shift]');
      if (edt) { const id = Number(edt.dataset.editShift); this.editShift = this.editShift === id ? 0 : id; this.detailFor = null; this._renderBody(); return; }
      if (e.target.closest('#iv-shift-close') || e.target.id === 'iv-shift-bg') { this.editShift = 0; this._renderBody(); return; }
      const mk = e.target.closest('[data-mk]');
      if (mk) { await this._markEvent(mk); return; }
      // 📅 period calendar: pills show/hide chip kinds; an event chip
      // toggles billed ⟷ unanswered; a dashed ref chip bills that one fee.
      const calPill = e.target.closest('[data-cal-pill]');
      if (calPill) {
        const k = calPill.dataset.calPill;
        this.calKinds[k] = this.calKinds[k] === false;
        try { localStorage.setItem('invoices.calKinds', JSON.stringify(this.calKinds)); } catch (err) { /* private window */ }
        this._renderBody(); return;
      }
      // 📅 chip main zone: one tap cycles ✓ worked → ✗ not there → clear.
      const calCycle = e.target.closest('[data-cal-cycle]');
      if (calCycle) {
        const st = calCycle.dataset.state;
        const mark = (st === '' || st === 'rsvpno') ? 'worked' : (st === 'yes' || st === 'part') ? 'no' : 'clear';
        await this._postMark(calCycle.dataset.ev, calCycle.dataset.gev, mark);
        return;
      }
      // 🟡 partial: open/close the hours box for this chip or row.
      const calPart = e.target.closest('[data-cal-part]');
      if (calPart) {
        const key = calPart.dataset.calPart;
        this.partialFor = this.partialFor === key ? null : key;
        this._renderBody();
        const box = this.find('[data-part-hours]');
        if (box) { box.focus(); box.select(); }
        return;
      }
      const partSave = e.target.closest('[data-part-save]');
      if (partSave) {
        const hrs = Number(this.find('[data-part-hours]')?.value);
        if (!(hrs > 0)) { this._say('Type the hours you were there.', true); return; }
        this.partialFor = null;
        await this._postMark(partSave.dataset.ev, partSave.dataset.gev, 'partial', hrs);
        return;
      }
      if (e.target.closest('[data-part-close]')) { this.partialFor = null; this._renderBody(); return; }
      const calRef = e.target.closest('[data-cal-ref]');
      if (calRef) { await this._addSingleRefFee(calRef.dataset.calRef); return; }
      // 🧑‍⚖️ default-on ref fee (mig 624): main zone toggles on/off the
      // sheet; the amount zone opens a small box to re-price the one fee.
      const refOff = e.target.closest('[data-ref-off]');
      if (refOff) { await this._markRefFee(refOff.dataset.refOff, 'off', refOff.dataset); return; }
      const refOn = e.target.closest('[data-ref-on]');
      if (refOn) { await this._markRefFee(refOn.dataset.refOn, 'on', refOn.dataset); return; }
      const refAmt = e.target.closest('[data-ref-amt]');
      if (refAmt) {
        const key = refAmt.dataset.refAmt;
        this.refAmtFor = this.refAmtFor === key ? null : key;
        this._renderBody();
        const box = this.find('[data-ref-amt-input]');
        if (box) { box.focus(); box.select(); }
        return;
      }
      const refAmtSave = e.target.closest('[data-ref-amt-save]');
      if (refAmtSave) {
        const amt = Number(this.find('[data-ref-amt-input]')?.value);
        if (!(amt >= 0)) { this._say('Type the fee amount.', true); return; }
        this.refAmtFor = null;
        await this._markRefFee(refAmtSave.dataset.refAmtSave, 'amount', refAmtSave.dataset, amt);
        return;
      }
      if (e.target.closest('[data-ref-amt-close]')) { this.refAmtFor = null; this._renderBody(); return; }
      if (e.target.closest('#iv-email')) { this.emailDeputy(); return; }
      if (e.target.closest('#iv-copy-link')) { await this.copyPublicLink(); return; }
      if (e.target.closest('#iv-copy-email')) { await this.copyEmailBody(); return; }
    });
    el.addEventListener('change', async (e) => {
      // The row's own number / covers / due inputs (mig 569).
      const rf = e.target.closest('[data-row-f]');
      if (rf) {
        const id = Number(rf.closest('[data-inv-row]')?.dataset.invRow);
        if (id) {
          try {
            await this._post(`/api/invoices/${id}/update`, { [rf.dataset.rowF]: rf.dataset.rowF === 'number' ? Number(rf.value) : rf.value });
            if (this.inv && this.inv.id === id) await this.openInvoice(id);
            await this.load();
          } catch (err) { this._say(err.message, true); }
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
    });
    // 💵 popup: the amount follows units × each as they're typed.
    el.addEventListener('input', (e) => {
      if (!e.target.matches('#iv-ln-qty, #iv-ln-rate')) return;
      const q = Number(this.find('#iv-ln-qty')?.value), r = this.find('#iv-ln-rate')?.value;
      const amt = this.find('#iv-ln-amt');
      if (amt && r !== '' && Number.isFinite(q) && Number.isFinite(Number(r))) amt.value = (Math.round(q * Number(r) * 100) / 100).toFixed(2);
    });
    el.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && e.target.closest('#iv-ln-desc, #iv-ln-amt, #iv-ln-qty, #iv-ln-rate')) { e.preventDefault(); this.saveLine(); }
      if (e.key === 'Enter' && e.target.closest('[data-sf]')) { e.preventDefault(); e.target.blur(); }
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
  // A ref-fee chip's name: league/age shorthand + opponent ("U10 · Fishtown").
  static refLabel(policy, opponent) {
    const p = String(policy || '').replace(/^Parks & Rec /, '').trim();
    return [p, opponent].filter(Boolean).join(' · ');
  }
  // '18:30' → '6:30p', '10:00' → '10a' — fits a calendar chip.
  static shortTime(hhmm) {
    const m = /^(\d{1,2}):(\d{2})/.exec(String(hhmm || ''));
    if (!m) return '';
    const h = +m[1], ap = h < 12 ? 'a' : 'p', h12 = h % 12 || 12;
    return `${h12}${m[2] === '00' ? '' : `:${m[2]}`}${ap}`;
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

    // Focus mode (owner 2026-10-12: "once i open it we need to hide the
    // others … its too confuusing"): with a sheet open, only the pills and
    // that sheet are on screen.  Close brings the list back; a pill opens
    // the next person's due sheet.
    if (issuer && !this.inv) {
      parts.push(this._renderIssuerCard(issuer));
      parts.push(this._renderInvoiceList(issuer));
    }
    if (this.inv) {
      parts.push(this._renderEditor());
      parts.push(`<div class="iv-sec">Sheet</div><div class="inv-preview-wrap"><div class="inv-scale">${this._renderSheet(this.inv)}</div></div>`);
      parts.push(this._renderShiftModal());
      parts.push(this._renderCalPopup());
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

  // Each invoice is a row with its number, dates covered and due date as
  // live inputs, plus ✉️ (owner 2026-10-12: "the due date should be on or
  // round button to see it and edit it send it and so should the dates
  // covered and the number").  Drafts auto-make themselves on the backend
  // (mig 569), so New invoice is only the odd manual extra.
  _renderInvoiceList(i) {
    const esc = (t) => this.escapeHtml(t);
    const rows = (i.invoices || []).map(v => `
      <div class="iv-inv-row" data-inv-row="${v.id}">
        <span style="font-weight:800;">#</span><input class="iv-in num" style="width:58px;" data-row-f="number" type="number" min="1" value="${v.number}" title="Pay period of the year">
        <span class="iv-lbl" style="margin:0;">covers</span>
        <input class="iv-in" style="width:136px;" data-row-f="period_start" type="date" value="${esc(v.period_start || '')}" title="Work from (Fri)">
        <span style="opacity:0.6;">–</span>
        <input class="iv-in" style="width:136px;" data-row-f="period_end" type="date" value="${esc(v.period_end || '')}" title="Work till (Thu)">
        <span class="iv-lbl" style="margin:0;">due</span>
        <input class="iv-in" style="width:136px;" data-row-f="date" type="date" value="${esc(v.date)}" title="Due date on the sheet">
        <span class="iv-tag ${v.is_final ? 'final' : 'draft'}">${v.is_final ? 'final' : 'draft'}</span>
        ${this._isDue(v) ? `<span class="iv-tag due">${esc(this._copy('due_badge', { date: InvoicesScreen.usDate(v.date) }) || `due ${InvoicesScreen.usDate(v.date)} — send`)}</span>` : ''}
        <span style="opacity:0.7;">${InvoicesScreen.plain(v.hours)} h</span>
        <span style="font-weight:700;">${InvoicesScreen.money(v.total)}</span>
        <span style="display:flex; gap:6px; margin-left:auto;">
          <button class="iv-btn ghost sm" data-email-invoice="${v.id}" title="Email ${esc(this.board?.bill_to?.email_label || 'Lighthouse')}">✉️</button>
          <button class="iv-btn alt sm" data-open="${v.id}">Open</button>
          <button class="iv-btn danger sm" data-delete-invoice="${v.id}">${this.confirmDelete === v.id ? esc(this._copy('delete_confirm', { number: `${v.year}.${v.number}` })) : '🗑'}</button>
        </span>
      </div>`).join('');
    const plans = (i.open_plans || []);
    return `
      <div class="iv-sec">Invoices</div>
      <div class="iv-card">
        ${rows || `<div style="opacity:0.7; font-size:0.9rem;">${esc(this._copy('empty', { name: i.name }))}</div>`}
        <div class="iv-acts" style="margin:8px 0 0;">
          <button id="iv-new" class="iv-btn ghost sm">➕ New invoice #${i.next_number}</button>
          ${plans.length ? `<span style="font-size:0.85rem; opacity:0.75;">${plans.length} instalment plan${plans.length === 1 ? '' : 's'} still running — the next invoice picks them up</span>` : ''}
        </div>
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

        <div class="iv-sec">${esc(this._copy('games_title') || 'Hours from the calendar')} — ${inv.period_start && inv.period_end ? `${esc(InvoicesScreen.dayLabel(inv.period_start))} to ${esc(InvoicesScreen.dayLabel(inv.period_end))}` : 'set the window above'}</div>
        ${inv.period_start && inv.period_end ? this._renderPeriodCalendar() : `<div class="iv-hint">Set the work-from and work-till dates first.</div>`}
        ${inv.is_final ? `<div class="iv-hint">Final — the sheet keeps its billed hours; un-tick Final to change them.</div>`
                       : `<div class="iv-hint" style="margin:6px 0 0;">${esc(this._copy('games_hint'))}</div>`}
      </div>`;
  }

  // Info only, never a control: the words "RSVP yes", not a ✓ glyph — the
  // old "✓ yes" read as a tick that wasn't ticked (owner 2026-10-12: "it
  // says yes but the check is not checked").
  _rsvpBadge(g) {
    if (!g) return '';
    if (g.rsvp === 'yes') return `<span style="color:#4ade80;">${this.escapeHtml(this._copy('games_rsvp_yes') || 'RSVP yes')}</span>`;
    if (g.rsvp === 'no')  return `<span style="color:#f87171;">${this.escapeHtml(this._copy('games_rsvp_no') || 'RSVP no')}</span>`;
    return `<span style="opacity:0.5;">${this.escapeHtml(this._copy('games_rsvp_none') || 'no RSVP')}</span>`;
  }

  // The attendance mark from #attendance (fh_event_attendance), the second
  // informer for the check-off (owner 2026-10-12: "show if rsvp and show if
  // marked present to inform if we check it off").
  _attBadge(g) {
    const esc = (t) => this.escapeHtml(t);
    if (!g) return '';
    const a = g.attendance || '';
    if (a === 'present') return `<span style="color:#4ade80;">${esc(this._copy('games_att_present') || 'present')}</span>`;
    if (a === 'late')    return `<span style="color:#f59e0b;">${esc(this._copy('games_att_late') || 'late')}</span>`;
    if (a === 'absent')  return `<span style="color:#f87171;">${esc(this._copy('games_att_absent') || 'absent')}</span>`;
    if (a === 'excused') return `<span style="color:#60a5fa;">${esc(this._copy('games_att_excused') || 'excused')}</span>`;
    return g.played ? `<span style="opacity:0.5;">${esc(this._copy('games_att_none') || 'not marked')}</span>` : '';
  }

  // Hours straight off the calendar — flat line items, nothing summed until
  // the bottom (owner 2026-10-12: "do not total until bottom total hours.
  // just line items of each practice or game … so we can check if attended
  // to get paid or not").  Every event of the issuer's teams in the period
  // is one row: ✓/✗ check-off, date, what it was, then the two informers —
  // RSVP and the attendance mark — time and hours.  ✏️ opens the override
  // popup (_renderShiftModal); billed rows without an event (hand-added
  // hours) sit in the same list with ✏️ as their only control.
  // 📅 The period as a calendar (owner 2026-10-20: "a calendar type thing
  // is better for each person … calendar and pills to show hide things …
  // running total of invoice below it … total hours and total earned on
  // each day just for sake of data").  Shows ONLY the invoice's own window
  // — a Fri→Thu pay period lands as 3 week rows with the lead-in/out days
  // dimmed.  Chips are the same rows the breakdown list below carries:
  // green = billed, amber outline = still to answer, struck = not worked;
  // tap toggles billed ⟷ unanswered (the ✗ nuance stays in the list).
  // Dashed 🧑‍⚖️ chips are unbilled ref fees — tap puts the fee on the sheet.
  _renderPeriodCalendar() {
    const inv = this.inv, esc = (t) => this.escapeHtml(t);
    if (!inv.period_start || !inv.period_end) return '';
    const locked = !!inv.is_final;
    const laborLine = (inv.lines || []).find(l => l.category === 'labor');
    const rate = Number(laborLine && laborLine.rate != null ? laborLine.rate : (inv.issuer?.hourly_rate || 0));
    const dow = (iso) => new Date(iso + 'T12:00:00').getDay();
    const gridStart = InvoicesScreen.addDays(inv.period_start, -dow(inv.period_start));
    const gridEnd   = InvoicesScreen.addDays(inv.period_end, 6 - dow(inv.period_end));
    // Anything dated outside the window sits on its first day (mig 703:
    // "if not sure we just put 1st date of invoice").
    const inWin = (d) => (d && d >= inv.period_start && d <= inv.period_end) ? d : inv.period_start;

    // Every day adds up its own money (owner 2026-10-26: "this way we can
    // add up each day still and give total too and category totals"):
    // billed hours × rate + the lines and referee fees dated that day.
    const byDate = new Map();
    const day = (date) => { if (!byDate.has(date)) byDate.set(date, { chips: [], hours: 0, money: 0 }); return byDate.get(date); };
    const put = (date, html) => day(date).chips.push(html);
    const kindOf = (i) => i.g ? (i.g.kind === 'match' ? 'match' : i.g.kind === 'practice' ? 'practice' : 'claim')
                             : (i.s.gcal_event_id ? 'claim' : i.s.fh_event_id ? 'match' : 'manual');
    const ICON = { match: '⚽', practice: '🏃', claim: '🧾', manual: '⏱' };
    const items = this._mergedPeriodItems();

    // ⚠ Overlap (owner 2026-10-26: "check for overlap in time we give them
    // green credit for. so we don't over invoice"): billed stints on the
    // same day whose clock times cross.  A stint's window is its own
    // from–till, else the event's start + its billed hours; flat hours
    // with no time at all can't be placed and are left out.
    const mins = (t) => { const m = /^(\d{1,2}):(\d{2})/.exec(String(t || '')); return m ? (+m[1]) * 60 + (+m[2]) : NaN; };
    const ovl = new Map();          // item → labels it crosses
    const dblByDate = new Map();    // date → hours billed twice
    {
      const spans = new Map();
      for (const i of items) {
        if (!i.s) continue;
        const a = mins(!i.s.flat && i.s.start ? i.s.start : (i.g && i.g.start) || '');
        if (!Number.isFinite(a)) continue;
        const bRaw = !i.s.flat && i.s.end ? mins(i.s.end) : a + Number(i.s.hours || 0) * 60;
        const b = Math.min(Number.isFinite(bRaw) && bRaw > a ? bRaw : a + Number(i.s.hours || 0) * 60, 24 * 60);
        if (!(b > a)) continue;
        const d = inWin(i.date);
        if (!spans.has(d)) spans.set(d, []);
        spans.get(d).push({ i, a, b });
      }
      for (const [d, list] of spans) {
        list.sort((x, y) => x.a - y.a);
        for (let x = 0; x < list.length; x++)
          for (let y = x + 1; y < list.length && list[y].a < list[x].b; y++) {
            const nm = (z) => (z.i.g ? (z.i.g.note || z.i.g.opponent) : (z.i.s.note || z.i.s.auto_note)) || 'Hours';
            ovl.set(list[x].i, [...(ovl.get(list[x].i) || []), nm(list[y])]);
            ovl.set(list[y].i, [...(ovl.get(list[y].i) || []), nm(list[x])]);
          }
        // Billed minutes minus the clock minutes they actually cover.
        let union = 0, curA = -1, curB = -1;
        for (const z of list) {
          if (z.a >= curB) { if (curB > curA) union += curB - curA; curA = z.a; curB = z.b; }
          else curB = Math.max(curB, z.b);
        }
        if (curB > curA) union += curB - curA;
        const sum = list.reduce((t, z) => t + (z.b - z.a), 0);
        if (sum - union > 0.5) dblByDate.set(d, (sum - union) / 60);
      }
    }
    const dblHours = [...dblByDate.values()].reduce((t, h) => t + h, 0);

    for (const i of items) {
      const kind = kindOf(i);
      const billed = !!i.s;
      const date = inWin(i.date);
      if (billed) { const d = day(date); d.hours += Number(i.s.hours || 0); d.money += Number(i.s.hours || 0) * rate; }
      if (kind !== 'manual' && this.calKinds[kind] === false) continue;
      // 🟡 partial (mig 621): billed flat BELOW the event's own hours.  A
      // 0 h stint is "covered" by a ⚠ Resolve window (mig 710) — still a
      // worked event, its time paid on the merged stint.
      const covered = billed && Number(i.s.hours) === 0;
      const partial = billed && !covered && i.g && i.s.flat && Number(i.s.hours) < Number(i.g.hours || 0) - 0.01;
      const state = billed ? (partial ? 'part' : 'on') : (i.g && (i.g.declined || i.g.rsvp === 'no')) ? 'off' : 'todo';
      // Matches lead with the opponent; everything else reads the event's
      // note, never a placeholder team label.  auto_note (mig 624 round):
      // a noteless day stint reads the calendar events its window overlaps.
      // Say WHICH game (owner 2026-10-26: "we need to show what game or
      // event it was. like liga 1, u10 etc"): a match reads its note —
      // league/age + vs/at + opponent ("U10 at Fishtown", "Liga 1 vs …").
      const label = i.g ? (i.g.note || i.g.opponent || i.g.team_label || '')
                        : (i.s.note || i.s.auto_note || inv.issuer?.duty_description || 'Hours');
      const hrs = covered ? ` · ${this._copy('cal_covered') || 'covered'}` : billed ? ` · ${InvoicesScreen.plain(i.s.hours)}h` : '';
      // Time + place on the chip (owner 2026-10-26: "i need the times of
      // the event on the cal and the address … that will help me tell who
      // was sent to that event"); the full address rides the tooltip.
      // From–till: the billed stint's own times when it has them, else the event's.
      const from = (i.s && !i.s.flat && i.s.start) || (i.g && i.g.start) || i.at || '';
      const till = (i.s && !i.s.flat && i.s.end) || (i.g && i.g.end) || '';
      const at = from ? `${InvoicesScreen.shortTime(from)}${till ? `–${InvoicesScreen.shortTime(till)}` : ''}` : '';
      const place = i.g && i.g.location ? i.g.location.split(',')[0].trim() : '';
      const crosses = ovl.get(i);
      // ↔ settled (mig 713): the backend moved this stint so the day's
      // hours run continuous, never twice; hover shows the calendar's own.
      const settled = billed && i.s.auto_adjusted;
      const settledTip = settled ? `${(covered
          ? this._copy('cal_covered_tip', { was: i.s.auto_from || '' }) || `↔ Inside the event before it — its time is already paid there (calendar: ${i.s.auto_from || ''})`
          : this._copy('cal_trimmed_tip', { was: i.s.auto_from || '' }) || `↔ Starts when the event before it ends, so no hour is paid twice (calendar: ${i.s.auto_from || ''})`)}\n` : '';
      const title = `${settledTip}${crosses ? `⚠ ${this._copy('cal_overlap_tip', { list: crosses.join(', ') }) || `Overlaps ${crosses.join(', ')} — the same hours billed twice`}\n` : ''}${i.g ? i.g.note || label : label}${i.at ? ` · ${i.at}` : ''}${hrs}${i.g && i.g.location ? `\n📍 ${i.g.location}` : ''}`;
      const inner = `<span class="iv-ev"><span>${crosses ? '⚠ ' : ''}${settled ? '↔ ' : ''}${ICON[kind]} ${at ? `<b>${esc(at)}</b> ` : ''}${esc(label)}${esc(hrs)}</span>${place ? `<span class="pl">📍 ${esc(place)}</span>` : ''}</span>`;
      const cls = `${state}${crosses ? ' ovl' : ''}`;
      if (locked) put(date, `<span class="iv-chip ${cls}" style="display:flex;" title="${esc(title)}">${inner}</span>`);
      else if (!i.g && i.s) put(date, `<button class="iv-chip ${cls}" data-edit-shift="${i.s.id}" title="${esc(title)}">${inner}</button>`);
      else {
        // One tap cycles ✓ → ✗ → clear (owner 2026-10-20: "easier to turn
        // green or red"); ⋯ opens the details popup (RSVP, attendance,
        // part hours, ✏️) that the old list rows carried.
        const key = i.g.fh_event_id ? `f${i.g.fh_event_id}` : `g${i.g.gcal_event_id}`;
        const mkState = billed ? (partial ? 'part' : 'yes') : (i.g.declined ? 'no' : (i.g.rsvp === 'no' ? 'rsvpno' : ''));
        put(date, `<span class="iv-chip ${cls}" style="display:flex;">
          <button class="iv-chip-zone" style="flex:1;" data-cal-cycle data-ev="${i.g.fh_event_id || ''}" data-gev="${i.g.gcal_event_id || ''}"
                  data-state="${mkState}" title="${esc(title)} — ${esc(this._copy('cycle_tip') || 'tap cycles: ✓ worked → ✗ not there → unanswered')}">${inner}</button>
          <button class="iv-chip-zone" data-cal-detail="${key}" title="${esc(this._copy('cal_detail_tip') || 'Details — RSVP, attendance, part hours, edit')}"
                  style="flex:0 0 auto; padding:0 2px; font-weight:800;">⋯</button>
        </span>`);
      }
    }

    // 🧑‍⚖️ billed fees on their game day (ref_items, mig 703); the
    // unbilled / left-off ones from the picker feed (mig 624).
    const refItemsByLine = new Map();
    for (const r of (inv.ref_items || [])) {
      refItemsByLine.set(r.line_id, (refItemsByLine.get(r.line_id) || 0) + Number(r.amount || 0));
      day(r.day).money += Number(r.amount || 0);
      if (this.calKinds.ref === false) continue;
      const tag = `${r.source}:${r.ref_id}`;
      const amtSpan = `<span style="flex-shrink:0;">${InvoicesScreen.money(r.amount)}</span>`;
      const inner = `🧑‍⚖️ <span>${esc(InvoicesScreen.refLabel(r.policy_label, r.opponent))}</span>`;
      const tip = `${r.policy_label} — ${r.opponent}${r.game_on !== r.day ? ` (${InvoicesScreen.dayLabel(r.game_on)})` : ''}`;
      if (locked) { put(r.day, `<span class="iv-chip ref on" style="display:flex;" title="${esc(tip)}">${inner}${amtSpan}</span>`); continue; }
      put(r.day, `<span class="iv-chip ref on" style="display:flex;">
        <button class="iv-chip-zone" style="flex:1;" data-ref-off="${esc(tag)}" data-ref-game-on="${esc(r.game_on)}" data-ref-opp="${esc(r.opponent)}"
                title="${esc(tip)} · ${esc(this._copy('ref_on_tip') || 'On the sheet — tap to leave this fee off the invoice')}">${inner}</button>
        <button class="iv-chip-zone" data-ref-amt="${esc(tag)}" style="flex:0 0 auto;"
                title="${esc(this._copy('ref_amt_tip') || "Edit this fee's amount")}">${amtSpan}</button>
      </span>`);
      if (this.refAmtFor === tag) put(r.day, this._refAmtBoxHtml(tag, { game_on: r.game_on, opponent: r.opponent }, r.amount));
    }
    if (this.calKinds.ref !== false && !locked) {
      for (const g of (this.refGames || [])) {
        if (g.on_this || !g.game_on || g.game_on < gridStart || g.game_on > gridEnd) continue;
        const tag = `${g.source}:${g.ref_id}`;
        const amtSpan = `<span style="flex-shrink:0;">${InvoicesScreen.money(g.amount)}</span>`;
        const inner = `🧑‍⚖️ <span>${esc(InvoicesScreen.refLabel(g.policy_label, g.opponent))}</span>${amtSpan}`;
        if (g.in_gcal === false) {
          put(g.game_on, `<span class="iv-chip ref" style="opacity:0.45;" title="${esc(g.opponent)} — ${esc(this._copy('refs_not_on_gcal') || 'not on the calendar')}">${inner}</span>`);
        } else if (g.declined) {
          put(g.game_on, `<button class="iv-chip ref off" data-ref-on="${esc(tag)}" data-ref-game-on="${esc(g.game_on)}" data-ref-opp="${esc(g.opponent)}"
            title="${esc(g.policy_label)} — ${esc(g.opponent)} · ${esc(this._copy('ref_off_tip') || 'Left off the invoice — tap to put this fee back on')}">
            <span style="text-decoration:line-through; opacity:0.6;">${inner}</span></button>`);
        } else {
          put(g.game_on, `<button class="iv-chip ref todo" data-cal-ref="${esc(tag)}"
            title="${esc(g.policy_label)} — ${esc(g.opponent)} · ${esc(this._copy('cal_ref_tip') || 'tap to put this referee fee on the sheet')}">${inner}</button>`);
        }
      }
    }

    // 💵 every other line on its day.  A referees line shows only what its
    // per-game fees don't already cover (a hand-added one shows whole).
    for (const l of (inv.lines || [])) {
      if (l.category === 'labor') continue;
      const amount = Number(l.amount || 0) - (l.category === 'referees' ? (refItemsByLine.get(l.id) || 0) : 0);
      if (Math.abs(amount) < 0.005) continue;
      day(l.day).money += amount;
      if (this.calKinds.expense === false) continue;
      const inner = `💵 <span>${esc(l.printed || l.description)}</span><span style="flex-shrink:0;">${InvoicesScreen.money(amount)}</span>`;
      const tip = `${l.category_label || l.category} ${l.printed || l.description}`;
      put(l.day, locked ? `<span class="iv-chip exp" style="display:flex;" title="${esc(tip)}">${inner}</span>`
                        : `<button class="iv-chip exp" data-edit-line="${l.id}" title="${esc(tip)}">${inner}</button>`);
    }

    // Grid: Su–Sa header, then the period's weeks; out-of-window cells dim.
    const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    let cells = DAYS.map(d => `<div class="hd">${d}</div>`).join('');
    let daysMoney = 0;
    for (let d = gridStart; d <= gridEnd; d = InvoicesScreen.addDays(d, 1)) {
      const out = d < inv.period_start || d > inv.period_end;
      const dd = byDate.get(d);
      if (dd && !out) daysMoney += dd.money;
      const dnum = d.slice(8).replace(/^0/, '');
      const dlabel = (d === gridStart || dnum === '1') ? InvoicesScreen.dayLabel(d).replace(/^\w+ /, '') : dnum;
      const wday = InvoicesScreen.dayLabel(d).split(' ')[0];
      const dbl = out ? 0 : (dblByDate.get(d) || 0);
      const sum = dd && !out && (dd.hours > 0 || Math.abs(dd.money) >= 0.005)
        ? `<div class="dsum">${dbl ? `<div style="color:#f87171;">⚠ ${InvoicesScreen.plain(Math.round(dbl * 100) / 100)}h ×2</div>` : ''}${dd.hours > 0 ? `${InvoicesScreen.plain(dd.hours)}h · ` : ''}${InvoicesScreen.money(dd.money)}</div>` : '';
      cells += `
        <div class="cell ${out ? 'out' : ''}">
          <div class="dnum" style="display:flex; justify-content:space-between; align-items:center;">
            <span><span class="iv-wd">${esc(wday)} </span>${esc(dlabel)}</span>
            ${out || locked ? '' : `<button class="iv-cal-add" data-cal-add="${d}" title="${esc(this._copy('cal_add_tip') || 'Add an expense or hours on this day')}">＋</button>`}
          </div>
          ${out ? '' : (dd ? dd.chips.join('') : '')}
          ${sum}
        </div>`;
    }

    // Show/hide pills + the totals: per category, then the invoice.
    const PILLS = [['match', '⚽ Games'], ['practice', '🏃 Practices'], ['claim', '🧾 Claims'], ['ref', '🧑‍⚖️ Ref fees'], ['expense', '💵 Expenses']];
    const pills = PILLS.map(([k, label]) =>
      `<button class="iv-pill ${this.calKinds[k] !== false ? 'on' : ''}" data-cal-pill="${k}" style="padding:4px 10px; font-size:0.78rem;">${esc(label)}</button>`).join('');
    const cats = new Map();
    for (const l of (inv.lines || [])) {
      const k = l.category === 'labor' ? 'labor' : l.category;
      const c = cats.get(k) || { label: (l.category_label || l.category).replace(/:$/, ''), amount: 0 };
      c.amount += Number(l.amount || 0); cats.set(k, c);
    }
    const labor = cats.get('labor');
    const catSpans = [...cats.entries()].filter(([k]) => k !== 'labor')
      .map(([, c]) => `<span>${esc(c.label)} ${InvoicesScreen.money(c.amount)}</span>`).join('');
    const total = Number(inv.total || 0);
    const off = Math.abs(daysMoney - total) >= 0.01;
    const nLines = (inv.lines || []).length;
    const totals = `
      <div class="iv-cal-tot">
        <span>${InvoicesScreen.plain(inv.shift_hours || 0)} h · ${InvoicesScreen.money(labor ? labor.amount : 0)} ${esc(inv.issuer?.duty_description || 'hours')}</span>
        ${catSpans}
        <span>${esc(this._copy('cal_running_total') || 'Invoice so far')} <b>${InvoicesScreen.money(total)}</b></span>
      </div>
      <div class="iv-cal-tot" style="padding-top:0; font-size:0.75rem; opacity:0.75;">
        ${dblHours > 0.005 ? `<span style="color:#f87171; opacity:1; font-weight:700;">${esc(this._copy('cal_overlap', { hours: InvoicesScreen.plain(Math.round(dblHours * 100) / 100), amount: InvoicesScreen.money(dblHours * rate) })
          || `⚠ ${InvoicesScreen.plain(Math.round(dblHours * 100) / 100)} h billed twice (${InvoicesScreen.money(dblHours * rate)}) — times that can't be placed; ✏️ or ✗ one`)}</span>` : ''}
        ${off ? `<span style="color:#f87171; opacity:1; font-weight:700;">${esc(this._copy('cal_mismatch', { days: InvoicesScreen.money(daysMoney), total: InvoicesScreen.money(total) }) || `⚠ The days add up to ${InvoicesScreen.money(daysMoney)} but the invoice says ${InvoicesScreen.money(total)}`)}</span>` : ''}
        <span style="${nLines > InvoicesScreen.SHEET_ROWS ? 'color:#f59e0b;' : ''}">${esc(nLines > InvoicesScreen.SHEET_ROWS
          ? this._copy('sheet_fit', { n: nLines, max: InvoicesScreen.SHEET_ROWS })
          : (this._copy('cal_rows', { n: nLines, max: InvoicesScreen.SHEET_ROWS }) || `${nLines} of ${InvoicesScreen.SHEET_ROWS} rows on the sheet`))}</span>
      </div>`;
    return `<div class="iv-pills" style="margin-top:4px;">${pills}</div><div class="iv-cal">${cells}</div>${totals}`;
  }

  // The 📅 calendar's one popup (mig 703): ＋ add on a day (expense /
  // hours / instalment plan), a 💵 line to edit, or an event chip's ⋯.
  _renderCalPopup() {
    const inv = this.inv, esc = (t) => this.escapeHtml(t);
    if (!inv || inv.is_final) return '';
    const shell = (title, body) => `
      <div class="iv-modal-bg" id="iv-pop-bg"><div class="iv-modal" style="max-width:620px;">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
          <div style="font-weight:800;">${title}</div>
          <button class="iv-btn ghost sm" data-pop-close>Close</button>
        </div>
        ${body}
      </div></div>`;
    const cats = (this.board?.categories || []).filter(c => c.code !== 'labor');
    const catSel = (cur) => `<select class="iv-in" id="iv-ln-cat">${cats.map(c =>
      `<option value="${esc(c.code)}" ${c.code === cur ? 'selected' : ''}>${esc((c.label || c.code).replace(/:$/, ''))}</option>`).join('')}</select>`;
    const dateIn = (id, val) => `<input class="iv-in" id="${id}" type="date" value="${esc(val)}" min="${esc(inv.period_start)}" max="${esc(inv.period_end)}">`;
    const lineForm = (l, date) => `
      <div class="iv-grid" style="grid-template-columns:150px 1fr;">
        <div><div class="iv-lbl">Day</div>${dateIn('iv-ln-date', date)}</div>
        <div><div class="iv-lbl">Section</div>${l && l.category === 'labor' ? '<div style="padding:8px 0;">Hours</div>' : catSel(l ? l.category : 'other')}</div>
        <div class="wide"><div class="iv-lbl">Description</div>${l && l.plan_id
          ? `<div style="padding:8px 0;">${esc(l.printed)}</div>`
          : `<input class="iv-in" id="iv-ln-desc" value="${esc(l ? l.description : '')}" placeholder="Seed for field">`}
          ${l && l.ref_games ? `<div class="iv-hint">🧑‍⚖️ ${l.ref_games} game${l.ref_games === 1 ? '' : 's'} — those fees sit on their game days</div>`
                             : this._budgetSel(l ? l.category : '__any__', l ? l.budget_line_id : null, 'id="iv-ln-budget"')}</div>
      </div>
      <div class="iv-grid" style="grid-template-columns:1fr 1fr 1fr;">
        <div><div class="iv-lbl">Units</div><input class="iv-in num" id="iv-ln-qty" type="number" step="0.25" min="0" value="${l ? InvoicesScreen.plain(l.quantity) : 1}"></div>
        <div><div class="iv-lbl">Each</div><input class="iv-in num" id="iv-ln-rate" type="number" step="0.01" min="0" value="${l && l.rate != null ? l.rate : ''}" placeholder="0.00"></div>
        <div><div class="iv-lbl">Amount</div><input class="iv-in num" id="iv-ln-amt" type="number" step="0.01" value="${l ? Number(l.amount).toFixed(2) : ''}" placeholder="0.00"></div>
      </div>
      <div class="iv-hint">${esc(this._copy('cal_date_hint') || 'Not sure of the day? Leave it on the first day of the invoice.')}</div>
      <div class="iv-acts">
        <button class="iv-btn" id="iv-ln-save">${l ? 'Save' : 'Add'}</button>
        ${l ? `<button class="iv-btn danger sm" data-delete-line="${l.id}">Remove from the invoice</button>` : ''}
      </div>`;

    if (this.editLine) {
      const l = (inv.lines || []).find(x => x.id === this.editLine);
      if (!l) return '';
      return shell(`💵 ${esc(InvoicesScreen.dayLabel(l.day))} — ${esc(l.printed || l.description)}`, lineForm(l, l.line_date && l.line_date === l.day ? l.line_date : l.day));
    }
    if (this.addOn) {
      const MODES = [['expense', '💵 Expense'], ['hours', '⏱ Hours without an event'], ['plan', '➕ Instalment plan (k of N)']];
      const pills = `<div class="iv-pills" style="margin:8px 0;">${MODES.map(([k, label]) =>
        `<button class="iv-pill ${this.addMode === k ? 'on' : ''}" data-add-mode="${k}" style="padding:4px 10px; font-size:0.8rem;">${esc(label)}</button>`).join('')}</div>`;
      let body;
      if (this.addMode === 'hours') {
        body = `
          <div class="iv-grid" style="grid-template-columns:150px 1fr 1fr 80px;">
            <div><div class="iv-lbl">Day</div>${dateIn('iv-nd-date', this.addOn)}</div>
            <div><div class="iv-lbl">From</div><input class="iv-in" id="iv-nd-start" type="time"></div>
            <div><div class="iv-lbl">Till</div><input class="iv-in" id="iv-nd-end" type="time"></div>
            <div><div class="iv-lbl">Hours</div><input class="iv-in num" id="iv-nd-hours" type="number" step="0.25" min="0"></div>
            <div class="wide"><div class="iv-lbl">Note</div><input class="iv-in" id="iv-nd-note" placeholder="what it was"></div>
          </div>
          <div class="iv-acts"><button id="iv-nd-save" class="iv-btn">Add</button></div>`;
      } else if (this.addMode === 'plan') {
        body = `
          <div class="iv-hint" style="margin:0 0 6px;">${esc(this._copy('plan_hint', { k: 1, n: 'N' }))}</div>
          <div class="iv-grid" style="grid-template-columns:1fr 1fr;">
            <div><div class="iv-lbl">Section</div><select class="iv-in" id="iv-plan-cat">${cats.map(c =>
              `<option value="${esc(c.code)}" ${c.code === 'equipment' ? 'selected' : ''}>${esc((c.label || c.code).replace(/:$/, ''))}</option>`).join('')}</select></div>
            <div><div class="iv-lbl">Description</div><input class="iv-in" id="iv-plan-desc" placeholder="Veo Subscription">${this._budgetSel('__any__', null, 'id="iv-plan-budget"')}</div>
            <div><div class="iv-lbl">Total paid</div><input class="iv-in num" id="iv-plan-total" type="number" step="0.01" min="0" placeholder="862.92"></div>
            <div><div class="iv-lbl">Over N</div><input class="iv-in num" id="iv-plan-count" type="number" step="1" min="1" value="4"></div>
            <div class="wide"><label style="font-size:0.85rem; display:flex; gap:6px; align-items:center;"><input type="checkbox" id="iv-plan-show"> print total</label></div>
          </div>
          <div class="iv-acts"><button id="iv-plan-add" class="iv-btn">Add plan + first instalment</button></div>`;
      } else body = lineForm(null, this.addOn);
      return shell(esc(this._copy('cal_add_title', { day: InvoicesScreen.dayLabel(this.addOn) }) || `Add to ${InvoicesScreen.dayLabel(this.addOn)}`), pills + body);
    }
    if (this.detailFor) {
      const key = (x) => x.fh_event_id ? `f${x.fh_event_id}` : x.gcal_event_id ? `g${x.gcal_event_id}` : '';
      const it = this._mergedPeriodItems().find(i => i.g && key(i.g) === this.detailFor);
      if (!it) return '';
      const { g, s } = it;
      const partial = s && Number(s.hours) > 0 && s.flat && Number(s.hours) < Number(g.hours || 0) - 0.01;
      const state = s ? (partial ? 'part' : 'yes') : (g.declined || g.rsvp === 'no') ? 'no' : '';
      const time = s && !s.flat ? `${s.start}–${s.end}` : `${g.start || ''}${g.end ? `–${g.end}` : ''}`;
      const mk = (k, glyph, cls, tip) => `<button class="iv-mk ${cls}" style="width:auto; padding:0 12px; height:32px;" data-mk="${k}" data-ev="${g.fh_event_id || ''}" data-gev="${g.gcal_event_id || ''}" data-state="${state}" data-stored="${g.declined ? 1 : 0}" title="${esc(tip)}">${glyph}</button>`;
      return shell(`${g.kind === 'match' ? '⚽' : g.kind === 'practice' ? '🏃' : '🧾'} ${esc(InvoicesScreen.dayLabel(it.date))} — ${esc(g.note || g.opponent || '')}`, `
        <div style="display:flex; flex-wrap:wrap; gap:8px 14px; align-items:center; font-size:0.9rem; margin:8px 0;">
          <span>${esc(time)}</span>
          ${g.location ? `<a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(g.location)}" target="_blank" rel="noopener">📍 ${esc(g.location)}</a>` : ''}
          <span>${this._rsvpBadge(g)}</span>
          <span>${this._attBadge(g)}</span>
          ${g.policy_pays ? `<span style="font-size:0.8rem; opacity:0.7;">paid by policy</span>` : ''}
          <span style="margin-left:auto; font-weight:800; ${state === 'part' ? 'color:#eab308;' : ''}">${s ? InvoicesScreen.plain(s.hours) : '0'} h</span>
        </div>
        <div class="iv-acts">
          ${mk('yes', '✓ Worked', state === 'yes' ? 'on-yes' : '', this._copy('mark_yes_tip') || 'Worked this as coach — bill its hours')}
          ${mk('part', '🟡 Part of it', state === 'part' ? 'on-part' : '', this._copy('partial_tip') || 'There for part of it — enter the hours worked')}
          ${mk('no', '✗ Didn’t', state === 'no' ? 'on-no' : '', this._copy('mark_no_tip') || 'Did not work this')}
          ${s ? `<button class="iv-btn ghost sm" data-edit-shift="${s.id}" title="Late or stayed on? Override the hours">✏️ Edit hours</button>` : ''}
        </div>
        ${this.partialFor === this.detailFor ? `<div style="margin-top:8px;">${this._partialBoxHtml(this.detailFor, g, s)}</div>` : ''}`);
    }
    return '';
  }

  // Every claimable / claimed thing in the period as one list: calendar
  // events (coaching + name-claims) paired with their billed day row when
  // one exists, plus hand-added day rows.  Shared by the hours breakdown
  // and the 📅 period calendar so the two can't disagree.
  // A row keys on its fh_event, or — a claimed calendar event (mig 577,
  // "anytime it says CASA soccer that is me") — on the gcal event.
  _mergedPeriodItems() {
    const inv = this.inv;
    const shifts = inv.shifts || [];
    const games = inv.is_final ? [] : (this.calGames || []);
    const key = (x) => x.fh_event_id ? `f${x.fh_event_id}` : x.gcal_event_id ? `g${x.gcal_event_id}` : '';
    const byEvent = new Map(shifts.filter(s => key(s)).map(s => [key(s), s]));
    const evIds = new Set(games.map(key));
    const items = [];
    for (const g of games) { const s = byEvent.get(key(g)) || null; items.push({ date: s ? s.date : g.date, at: (s && !s.flat && s.start) || g.start || '', g, s }); }
    for (const s of shifts) if (!key(s) || !evIds.has(key(s))) items.push({ date: s.date, at: (!s.flat && s.start) || '', g: null, s });
    items.sort((a, b) => a.date < b.date ? -1 : a.date > b.date ? 1 : (a.at < b.at ? -1 : 1));
    return items;
  }

  // ✏️ as a popup (owner 2026-10-12: "an edit button to edit the hours
  // which will rarely be used to override event hours … like a pop up").
  // The data-sf inputs save on change exactly as the old inline row did;
  // wiping every box removes the day, and the popup closes with it.
  _renderShiftModal() {
    const inv = this.inv, esc = (t) => this.escapeHtml(t);
    if (!inv || inv.is_final || !this.editShift) return '';
    const s = (inv.shifts || []).find(x => x.id === this.editShift);
    if (!s) return '';
    return `
      <div class="iv-modal-bg" id="iv-shift-bg"><div class="iv-modal" style="max-width:620px;">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px;">
          <div style="font-weight:800;">✏️ ${esc(InvoicesScreen.dayLabel(s.date))} — ${esc(s.note || s.auto_note || inv.issuer?.duty_description || 'Hours')}</div>
          <button id="iv-shift-close" class="iv-btn ghost sm">Close</button>
        </div>
        <div class="iv-hint" style="margin:4px 0 8px;">${esc(this._copy('edit_shift_hint') || "Override the event's hours — a late start, or stayed on. Wipe every box to take the day off the sheet.")}</div>
        <div class="iv-day" data-shift-row="${s.id}" data-date="${s.date}" style="border-top:none; grid-template-columns:1fr 1fr 90px 1.4fr;">
          <div><div class="iv-lbl">From</div><input class="iv-in" type="time" data-sf="start" value="${esc(!s.flat ? s.start : '')}"></div>
          <div><div class="iv-lbl">Till</div><input class="iv-in" type="time" data-sf="end" value="${esc(!s.flat ? s.end : '')}"></div>
          <div><div class="iv-lbl">Hours</div><input class="iv-in num" type="number" step="0.25" min="0" data-sf="hours" value="${InvoicesScreen.plain(s.hours)}"></div>
          <div class="note"><div class="iv-lbl">Note</div><input class="iv-in" data-sf="note" value="${esc(s.note || '')}" placeholder="note"></div>
        </div>
      </div></div>`;
  }

  // ✓ worked / 🟡 partial / ✗ didn't on one event row.  Tapping the active
  // mark clears it back to unanswered; a ✗ shown only because of an RSVP
  // no has nothing stored, so tapping it stores the answer.  🟡 opens the
  // hours box (mig 621); when already partial it clears.
  async _markEvent(btn) {
    if (!this.inv) return;
    const ev = Number(btn.dataset.ev) || 0, gev = Number(btn.dataset.gev) || 0, state = btn.dataset.state || '';
    let mark;
    if (btn.dataset.mk === 'yes') mark = (state === 'yes') ? 'clear' : 'worked';
    else if (btn.dataset.mk === 'part') {
      if (state === 'part') mark = 'clear';
      else {
        const key = ev ? `f${ev}` : `g${gev}`;
        this.partialFor = this.partialFor === key ? null : key;
        this._renderBody();
        const box = this.find('[data-part-hours]');
        if (box) { box.focus(); box.select(); }
        return;
      }
    }
    else mark = state === 'no' && btn.dataset.stored === '1' ? 'clear' : 'no';
    await this._postMark(ev, gev, mark);
  }

  // Shared POST for ✓/🟡/✗/clear from the list rows and the 📅 chips.
  async _postMark(ev, gev, mark, hours) {
    if (!this.inv) return;
    const body = Number(ev) ? { fh_event_id: Number(ev), mark } : { gcal_event_id: Number(gev), mark };
    if (mark === 'partial') body.hours = Number(hours);
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/event-mark`, body);
      await this.load();
      this._loadGames();
    } catch (err) { this._say(err.message, true); }
  }

  // The 🟡 hours box (mig 621), shown under a chip or list row.
  // 🧑‍⚖️ amount box (mig 624): re-price the one fee; same shape as the
  // 🟡 partial box.
  _refAmtBoxHtml(tag, g, amt) {
    const esc = (t) => this.escapeHtml(t);
    return `<span class="iv-part-box" data-ref-amt-row="${esc(tag)}">
      💲 <input class="iv-in num" type="number" step="0.01" min="0" max="10000" data-ref-amt-input
                value="${esc(InvoicesScreen.plain(amt))}" placeholder="$">
      <button class="iv-btn sm" data-ref-amt-save="${esc(tag)}" data-ref-game-on="${esc(g.game_on)}"
              data-ref-opp="${esc(g.opponent)}" style="padding:2px 8px;">OK</button>
      <button class="iv-btn ghost sm" data-ref-amt-close style="padding:2px 6px;">✕</button>
    </span>`;
  }

  _partialBoxHtml(key, g, s) {
    const esc = (t) => this.escapeHtml(t);
    const dflt = s && s.flat ? InvoicesScreen.plain(s.hours) : '';
    return `<span class="iv-part-box" data-part-row="${key}">
      🟡 <input class="iv-in num" type="number" step="0.25" min="0.25" max="24" data-part-hours
                value="${esc(dflt)}" placeholder="${esc(this._copy('partial_ph') || 'hours')}">
      <button class="iv-btn sm" data-part-save data-ev="${g && g.fh_event_id ? g.fh_event_id : ''}"
              data-gev="${g && g.gcal_event_id ? g.gcal_event_id : ''}" style="padding:2px 8px;">OK</button>
      <button class="iv-btn ghost sm" data-part-close style="padding:2px 6px;">✕</button>
    </span>`;
  }

  async addDayManual() {
    if (!this.inv) return;
    const v = (id) => (this.find(`#iv-nd-${id}`)?.value || '').trim();
    const payload = { date: v('date'), note: v('note') };
    if (v('start') && v('end')) { payload.start = v('start'); payload.end = v('end'); }
    else if (Number(v('hours')) > 0) payload.hours = Number(v('hours'));
    if (!payload.date) { this._say('Pick the day first.', true); return; }
    try {
      this.inv = await this._post(`/api/invoices/${this.inv.id}/shift`, payload);
      this.addOn = '';
      await this.load();
      this._loadGames();
    } catch (err) { this._say(err.message, true); }
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
        // A long line (instalment "k of N · $total total") shrinks to fit
        // its column rather than run into the hours.
        const len = String(l.printed || '').length;
        body += f(COL.desc, y, l.printed, len > 44 ? Math.max(7, Math.round(10 * 44 / len * 10) / 10) : 10, '', 233);
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
