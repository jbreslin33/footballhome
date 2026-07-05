// AdminSeriesEditorScreen — CRUD for `match_series` (migration 087).
//
// A series is a recurring weekly template.  Every Sunday 20:00
// America/New_York the cron hits POST /api/match-series/rollover which
// expands each active series into concrete `matches` rows for the
// coming Mon–Sun window.  This screen lets an admin create / edit /
// deactivate templates without touching SQL.
//
// Endpoints (all bearer-authed):
//   GET    /api/match-series            → { data: [ {…, upcoming_count, past_count, override_count} ] }
//   POST   /api/match-series            → { data: { new row } }
//   GET    /api/match-series/:id        → { data: { …, upcoming: [ next 8 materialised matches ] } }
//   PUT    /api/match-series/:id        → { data: { …, propagated_matches } }
//                                         body may include apply_to_future: true
//   DELETE /api/match-series/:id?cancel_future=true → { success, cancelled_matches }
//
// "Google-Cal 3-mode" mapping when the admin edits a template:
//   • "This event only"    → NOT handled here; use per-match edit UI +
//                            set matches.is_override=true.  Series editor
//                            is deliberately template-only.
//   • "This and future"    → PUT with apply_to_future: true.  Series row
//                            updated + non-override future matches
//                            propagated.
//   • "All events"         → PUT without apply_to_future.  Only series
//                            row changes; future rollovers pick up the
//                            new values but existing materialised matches
//                            remain unchanged.

class AdminSeriesEditorScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.rows      = [];
    this.editing   = null;         // series row currently in modal (null|obj|'new')
    this.saving    = false;
    this.errorMsg  = null;

    // Copy of match_types kept in sync with the backend enum.  Names
    // are lower-cased in the DB; the label column is what we surface.
    this.matchTypes = [
      { id: 1, label: 'League' },
      { id: 2, label: 'Custom' },
      { id: 3, label: 'Practice' },
      { id: 4, label: 'Scrimmage' },
      { id: 5, label: 'Tournament' },
      { id: 6, label: 'Cup' },
      { id: 7, label: 'Pickup' },
    ];
    this.dowNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    this.dowLong  = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  }

  // ---------- lifecycle ----------

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-admin-series-editor';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🔁 Recurring Match Series</h1>
        <p class="subtitle">
          Weekly templates. Every Sunday 20:00 Eastern the next week's matches
          are materialized automatically from the active rows below.
        </p>
      </div>

      <div style="padding: var(--space-4); max-width: 1100px; margin: 0 auto;">
        <div style="display: flex; gap: var(--space-2); margin-bottom: var(--space-3); flex-wrap: wrap;">
          <button class="btn btn-primary" id="new-series-btn">+ New Series</button>
          <button class="btn btn-secondary" id="rollover-now-btn"
                  title="Immediately materialize matches for the current week — normally the Sunday-8pm cron does this">
            ⚡ Run Rollover Now
          </button>
          <div id="status-msg" style="align-self:center; opacity:.85;"></div>
        </div>
        <div id="series-list">
          <div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>
        </div>
      </div>

      <div id="series-modal" style="display:none; position:fixed; inset:0; z-index:1000;">
        <div id="series-modal-backdrop" style="position:absolute; inset:0; background:rgba(0,0,0,.55);"></div>
        <div id="series-modal-card"
             style="position:relative; max-width:640px; margin:5vh auto; background:white; color:#0f1f3d;
                    border-radius:12px; padding: var(--space-4); box-shadow:0 20px 60px rgba(0,0,0,.4);
                    max-height:90vh; overflow:auto;">
          <div id="series-modal-body"></div>
        </div>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this.editing = null;
    this.errorMsg = null;

    this.element.addEventListener('click', (e) => this._onClick(e));
    this.element.addEventListener('input', (e) => this._onInput(e));
    this._load();
  }

  // ---------- data ----------

  async _load() {
    try {
      const res  = await this.auth.fetch('/api/match-series');
      const body = await res.json();
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.rows = body.data || [];
      this._renderList();
    } catch (err) {
      console.error('[series editor] load failed', err);
      const list = this.find('#series-list');
      if (list) list.innerHTML =
        `<div style="color:var(--color-danger); padding: var(--space-3);">Failed to load: ${this._esc(err.message)}</div>`;
    }
  }

  // ---------- list render ----------

  _renderList() {
    const list = this.find('#series-list');
    if (!list) return;
    if (!this.rows.length) {
      list.innerHTML = `
        <div style="padding: var(--space-4); text-align:center; opacity:.75;">
          No series yet. Click <strong>+ New Series</strong> to create the first one.
        </div>`;
      return;
    }

    // Two buckets: active on top, inactive collapsed below.
    const active   = this.rows.filter(r => r.active);
    const inactive = this.rows.filter(r => !r.active);

    const row = (r) => {
      const day = this.dowNames[r.day_of_week] || `dow=${r.day_of_week}`;
      const time = this._fmtTime(r.start_time)
                 + (r.end_time ? ' → ' + this._fmtTime(r.end_time) : '');
      const mt = this.matchTypes.find(t => t.id === r.match_type_id);
      const mtLabel = mt ? mt.label : `type ${r.match_type_id}`;
      const dim = r.active ? '' : 'opacity:.55;';
      const badge = r.active
        ? `<span class="badge badge-primary">Active</span>`
        : `<span class="badge badge-secondary">Inactive</span>`;

      return `
        <div data-series-id="${r.id}"
             style="${dim} background: rgba(15,31,61,.03); border:1px solid rgba(15,31,61,.15);
                    border-radius:8px; padding: var(--space-3); margin-bottom: var(--space-2);
                    display:flex; flex-wrap:wrap; align-items:center; gap: var(--space-3);">
          <div style="flex:1; min-width:260px;">
            <div style="font-weight:700; font-size:1.05em;">${this._esc(r.name)} ${badge}</div>
            <div style="opacity:.85; margin-top:2px;">
              📅 <strong>${day}</strong> · 🕐 ${this._esc(time)} · 🏷 ${mtLabel}
              ${r.home_team_id ? ` · 🏠 team ${r.home_team_id}` : ''}
              ${r.away_team_id ? ` · 🆚 team ${r.away_team_id}` : ''}
              ${r.venue_id    ? ` · 📍 venue ${r.venue_id}`   : ''}
            </div>
            <div style="opacity:.7; font-size:.85em; margin-top:4px;">
              since ${this._esc(r.starts_on)}${r.ends_on ? ` · ends ${this._esc(r.ends_on)}` : ''}
              · ${r.upcoming_count || 0} upcoming, ${r.past_count || 0} past${
                (r.override_count || 0) > 0 ? `, ${r.override_count} override${r.override_count === 1 ? '' : 's'}` : ''}
            </div>
          </div>
          <div style="display:flex; gap: var(--space-2);">
            <button class="btn btn-sm btn-primary" data-action="edit"   data-series-id="${r.id}">✏️ Edit</button>
            <button class="btn btn-sm btn-danger"  data-action="delete" data-series-id="${r.id}">🗑 Delete</button>
          </div>
        </div>
      `;
    };

    let html = '';
    if (active.length) {
      html += `<h3 style="margin: var(--space-3) 0 var(--space-2);">Active (${active.length})</h3>`;
      html += active.map(row).join('');
    }
    if (inactive.length) {
      html += `<h3 style="margin: var(--space-4) 0 var(--space-2); opacity:.7;">Inactive (${inactive.length})</h3>`;
      html += inactive.map(row).join('');
    }
    list.innerHTML = html;
  }

  // ---------- modal ----------

  _openModal(row) {
    // row === 'new' means create; otherwise it's the existing series
    // object we're editing.  We deep-copy so the form doesn't mutate
    // list state until Save succeeds.
    this.editing = (row === 'new') ? this._blankSeries() : { ...row };
    this._renderModal();
    const modal = this.find('#series-modal');
    if (modal) modal.style.display = 'block';
  }

  _closeModal() {
    this.editing = null;
    const modal = this.find('#series-modal');
    if (modal) modal.style.display = 'none';
  }

  _blankSeries() {
    return {
      id: null,
      name: '',
      match_type_id: 7,        // pickup default
      day_of_week: 2,          // Tuesday default
      start_time: '19:00:00',
      end_time: '20:30:00',
      duration_min: null,
      home_team_id: null,
      away_team_id: null,
      venue_id: null,
      title: '',
      description: '',
      starts_on: new Date().toISOString().slice(0, 10),
      ends_on: null,
      active: true,
    };
  }

  _renderModal() {
    const body = this.find('#series-modal-body');
    if (!body || !this.editing) return;
    const s = this.editing;
    const isNew = s.id == null;

    const dayOptions = this.dowLong
      .map((n, i) => `<option value="${i}" ${i === s.day_of_week ? 'selected' : ''}>${n}</option>`)
      .join('');
    const typeOptions = this.matchTypes
      .map(t => `<option value="${t.id}" ${t.id === s.match_type_id ? 'selected' : ''}>${t.label}</option>`)
      .join('');

    body.innerHTML = `
      <h2 style="margin-top:0;">${isNew ? '+ New Series' : `Edit: ${this._esc(s.name)}`}</h2>
      ${this.errorMsg ? `<div style="color:#b91c1c; margin-bottom: var(--space-3);">${this._esc(this.errorMsg)}</div>` : ''}

      <div style="display:grid; grid-template-columns: 1fr 1fr; gap: var(--space-3);">
        <label style="grid-column:1/-1;">
          Name
          <input type="text" data-field="name" value="${this._esc(s.name || '')}" required
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Day of Week
          <select data-field="day_of_week" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
            ${dayOptions}
          </select>
        </label>

        <label>Match Type
          <select data-field="match_type_id" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
            ${typeOptions}
          </select>
        </label>

        <label>Start Time
          <input type="time" data-field="start_time" step="60"
                 value="${this._esc((s.start_time || '').slice(0,5))}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>End Time (optional)
          <input type="time" data-field="end_time" step="60"
                 value="${this._esc((s.end_time || '').slice(0,5))}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Starts On
          <input type="date" data-field="starts_on" required
                 value="${this._esc(s.starts_on || '')}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Ends On (optional, blank = forever)
          <input type="date" data-field="ends_on"
                 value="${this._esc(s.ends_on || '')}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Home Team ID
          <input type="number" min="1" data-field="home_team_id"
                 value="${s.home_team_id == null ? '' : s.home_team_id}"
                 placeholder="e.g. 908 (mens practice pool)"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Away Team ID (optional)
          <input type="number" min="1" data-field="away_team_id"
                 value="${s.away_team_id == null ? '' : s.away_team_id}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Venue ID (optional)
          <input type="number" min="1" data-field="venue_id"
                 value="${s.venue_id == null ? '' : s.venue_id}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label>Duration (min, optional)
          <input type="number" min="1" data-field="duration_min"
                 value="${s.duration_min == null ? '' : s.duration_min}"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label style="grid-column:1/-1;">Title (event display)
          <input type="text" data-field="title" value="${this._esc(s.title || '')}"
                 placeholder="Falls back to name if blank"
                 style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">
        </label>

        <label style="grid-column:1/-1;">Description
          <textarea data-field="description" rows="3"
                    style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px;">${this._esc(s.description || '')}</textarea>
        </label>

        <label style="grid-column:1/-1; display:flex; align-items:center; gap:8px;">
          <input type="checkbox" data-field="active" ${s.active ? 'checked' : ''}>
          Active (uncheck to disable this template without deleting)
        </label>

        ${!isNew ? `
          <label style="grid-column:1/-1; display:flex; align-items:center; gap:8px;
                        padding: var(--space-2); background:#fef3c7; border-radius:6px;">
            <input type="checkbox" data-field="apply_to_future" checked>
            <span>
              <strong>Also update all upcoming matches</strong> already materialised from this series
              (except any marked as one-off overrides). Uncheck to only affect future weeks.
            </span>
          </label>
        ` : ''}
      </div>

      <div style="display:flex; justify-content:flex-end; gap: var(--space-2); margin-top: var(--space-4);">
        <button class="btn btn-secondary" data-action="modal-cancel">Cancel</button>
        <button class="btn btn-primary" data-action="modal-save" ${this.saving ? 'disabled' : ''}>
          ${this.saving ? '⏳ Saving…' : (isNew ? 'Create' : 'Save Changes')}
        </button>
      </div>
    `;
  }

  // ---------- events ----------

  _onClick(e) {
    if (e.target.closest('.back-btn')) {
      this.navigation.goBack();
      return;
    }
    if (e.target.id === 'new-series-btn') {
      this.errorMsg = null;
      this._openModal('new');
      return;
    }
    if (e.target.id === 'rollover-now-btn') {
      this._runRollover(e.target);
      return;
    }
    if (e.target.id === 'series-modal-backdrop') {
      this._closeModal();
      return;
    }
    const editBtn = e.target.closest('[data-action="edit"]');
    if (editBtn) {
      const id = Number(editBtn.getAttribute('data-series-id'));
      const row = this.rows.find(r => r.id === id);
      if (row) { this.errorMsg = null; this._openModal(row); }
      return;
    }
    const delBtn = e.target.closest('[data-action="delete"]');
    if (delBtn) {
      const id = Number(delBtn.getAttribute('data-series-id'));
      const row = this.rows.find(r => r.id === id);
      if (row) this._confirmDelete(row);
      return;
    }
    if (e.target.matches('[data-action="modal-cancel"]')) {
      this._closeModal();
      return;
    }
    if (e.target.matches('[data-action="modal-save"]')) {
      this._save();
      return;
    }
  }

  _onInput(e) {
    if (!this.editing) return;
    const el = e.target.closest('[data-field]');
    if (!el) return;
    const field = el.getAttribute('data-field');
    let value = el.value;
    if (el.type === 'checkbox') {
      value = el.checked;
    } else if (['home_team_id','away_team_id','venue_id','duration_min','match_type_id','day_of_week'].includes(field)) {
      value = value === '' ? null : Number(value);
    } else if (['start_time','end_time'].includes(field)) {
      // <input type="time"> gives HH:MM; DB wants HH:MM:SS.
      value = value ? (value.length === 5 ? value + ':00' : value) : (field === 'end_time' ? null : '');
    } else if (field === 'ends_on' && value === '') {
      value = null;
    }
    this.editing[field] = value;
  }

  // ---------- CRUD ----------

  async _save() {
    if (!this.editing || this.saving) return;
    const isNew = this.editing.id == null;
    const body = { ...this.editing };
    // For a create request we drop apply_to_future (only meaningful on
    // update).  Backend ignores it either way but keeps the payload clean.
    if (isNew) delete body.apply_to_future;

    // Client-side sanity check — backend also validates.
    if (!body.name || !body.name.trim()) {
      this.errorMsg = 'Name is required.';
      this._renderModal();
      return;
    }
    if (!body.start_time) {
      this.errorMsg = 'Start time is required.';
      this._renderModal();
      return;
    }
    if (!body.starts_on) {
      this.errorMsg = 'Starts On date is required.';
      this._renderModal();
      return;
    }

    this.saving = true;
    this.errorMsg = null;
    this._renderModal();

    try {
      const url    = isNew ? '/api/match-series' : `/api/match-series/${this.editing.id}`;
      const method = isNew ? 'POST' : 'PUT';
      const res = await this.auth.fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);

      const propagated = data.data?.propagated_matches;
      const msg = isNew
        ? `Created "${data.data.name}"`
        : (propagated
            ? `Saved — ${propagated} upcoming match${propagated === 1 ? '' : 'es'} updated too.`
            : `Saved.`);
      this._flash(msg);
      this._closeModal();
      await this._load();
    } catch (err) {
      console.error('[series editor] save failed', err);
      this.errorMsg = err.message || 'Save failed';
      this._renderModal();
    } finally {
      this.saving = false;
    }
  }

  async _confirmDelete(row) {
    const upcoming = row.upcoming_count || 0;
    const cancelFuture = upcoming > 0
      ? confirm(
          `Deactivate series "${row.name}"?\n\n` +
          `${upcoming} upcoming match${upcoming === 1 ? '' : 'es'} already materialised from this series.\n\n` +
          `Click OK to ALSO cancel those upcoming matches.\n` +
          `Click Cancel to keep them running but stop future rollovers from adding more.`
        )
      : confirm(`Deactivate series "${row.name}"? Future rollovers will skip it.`);

    // If user hit cancel on the confirm dialog for the "no upcoming"
    // case, we bail; for the "has upcoming" case cancel means "keep
    // the future matches, but still deactivate the template".  We
    // read that distinction by asking a second question — but that's
    // annoying.  Simpler: if upcoming=0 just deactivate; if upcoming>0
    // the confirm is a yes/no gate on both the deactivate AND the
    // cancel-future.  A "no" here means: skip everything.
    if (upcoming === 0 && !cancelFuture) return;

    const url = `/api/match-series/${row.id}` + (cancelFuture && upcoming > 0 ? '?cancel_future=true' : '');
    try {
      const res = await this.auth.fetch(url, { method: 'DELETE' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      const cancelled = data.cancelled_matches || 0;
      this._flash(
        cancelled
          ? `Deactivated — ${cancelled} upcoming match${cancelled === 1 ? '' : 'es'} cancelled.`
          : 'Deactivated.'
      );
      await this._load();
    } catch (err) {
      console.error('[series editor] delete failed', err);
      alert(`Delete failed: ${err.message}`);
    }
  }

  async _runRollover(btn) {
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Running…'; }
    try {
      const res = await this.auth.fetch('/api/match-series/rollover', { method: 'POST' });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      this._flash(
        `Rollover ok: ${data.matchesInserted} matches, ${data.rsvpsInserted} RSVPs inserted.`
      );
      await this._load();
    } catch (err) {
      console.error('[series editor] rollover failed', err);
      this._flash(`Rollover failed: ${err.message}`, true);
    } finally {
      if (btn) { btn.disabled = false; btn.innerHTML = '⚡ Run Rollover Now'; }
    }
  }

  // ---------- helpers ----------

  _fmtTime(t) {
    // "19:00:00" → "7:00 PM".  Fall back to the raw value if we can't parse.
    if (!t) return '';
    const m = String(t).match(/^(\d{1,2}):(\d{2})/);
    if (!m) return t;
    let h = Number(m[1]);
    const min = m[2];
    const suffix = h >= 12 ? 'PM' : 'AM';
    h = h % 12; if (h === 0) h = 12;
    return `${h}:${min} ${suffix}`;
  }

  _flash(msg, isErr) {
    const el = this.find('#status-msg');
    if (!el) return;
    el.textContent = msg;
    el.style.color = isErr ? '#b91c1c' : '#0f1f3d';
    setTimeout(() => { if (el.textContent === msg) el.textContent = ''; }, 6000);
  }

  _esc(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
