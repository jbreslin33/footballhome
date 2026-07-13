// FilterBar ────────────────────────────────────────────────────────────────
// Standardized chip-row filter component for screens.
//
// Design goal (2026-07-12 directive): every screen that lets an admin
// slice a big list (Members, Payments, and eventually Clubs / Teams /
// Rosters) uses the SAME chip styling + click semantics.  Screens
// declare *what* the chips are; FilterBar owns *how* they render and
// how clicks are wired.
//
// Anatomy
// ───────
//   FilterBar renders a stack of ROWS into a single host <div>.  Each
//   row answers ONE question ("which category?", "which status?", …)
//   and holds a set of CHIPS that are mutually exclusive within that
//   row.  A row's `selected` value can be null → "all / none selected"
//   → no chip is highlighted.
//
// Chip spec (per row):
//   { id: string, label: string, count?: number, disabled?: bool }
// Row spec:
//   {
//     name:     string,            // key in the state object
//     chips:    Chip[],            // pre-sorted; order = render order
//     selected: string|null,       // currently-selected chip id
//     onSelect: (id, row) => void  // called after state updates
//     clears?:  string[]           // other row `name`s to null out
//   }
//
// Consumers create a FilterBar once, then call `.setRows([...])`
// whenever the data behind the chips changes (e.g. after a re-sync).
// Clicking a chip:
//   1. toggles: if the chip is already active, the row is cleared;
//      otherwise the row's selection is set to that chip id.
//   2. any `clears` rows are set to null (so picking a specific
//      program clears an active category chip, and vice-versa).
//   3. `row.onSelect(id, row)` fires so the screen can rerender.
//
// Ships as a global class (no ES modules — matches the rest of the
// frontend script layout).  See index.html script order.
class FilterBar {
  /**
   * @param {Object} opts
   * @param {HTMLElement} opts.host   Container to render into.  Cleared
   *                                  on every setRows() call.
   * @param {string} [opts.compact]   'compact' → smaller pills for
   *                                  dense screens (payments).  Default
   *                                  '' = standard size.
   */
  constructor(opts) {
    if (!opts || !opts.host) {
      throw new Error('FilterBar: `host` element is required');
    }
    this.host    = opts.host;
    this.compact = opts.compact === 'compact';
    this.rows    = [];
    // Single delegated click handler on the host — chips are re-rendered
    // often and we don't want to leak listeners.
    this._onClick = this._onClick.bind(this);
    this.host.addEventListener('click', this._onClick);
  }

  /**
   * Replace all rows with a new set and re-render.  Idempotent — safe
   * to call after every data refresh.
   * @param {Array} rows  See file header for row spec.
   */
  setRows(rows) {
    this.rows = Array.isArray(rows) ? rows : [];
    this.render();
  }

  /** Return the current selection as a plain object keyed by row name. */
  getState() {
    const out = {};
    for (const r of this.rows) out[r.name] = r.selected ?? null;
    return out;
  }

  /**
   * Directly set a row's selection without invoking its onSelect.
   * Useful for legacy nav params that seed initial state before the
   * FilterBar is rendered.
   */
  setSelected(rowName, value) {
    const row = this.rows.find(r => r.name === rowName);
    if (!row) return;
    row.selected = value ?? null;
    this.render();
  }

  /** Re-render the chip rows into the host, replacing prior markup. */
  render() {
    const rowsHtml = this.rows.map((row) => this._renderRow(row)).join('');
    this.host.innerHTML = rowsHtml;
  }

  /** Detach the delegated click handler.  Screens rarely need this. */
  destroy() {
    this.host.removeEventListener('click', this._onClick);
    this.host.innerHTML = '';
    this.rows = [];
  }

  // ── internals ────────────────────────────────────────────────────

  _renderRow(row) {
    const chips = (row.chips || []).map((chip) => {
      const active = row.selected === chip.id;
      return this._renderChip(row.name, chip, active);
    }).join(' ');
    return `<div class="fb-row" data-fb-row="${this._esc(row.name)}"
                 style="display:flex; flex-wrap:wrap; gap:6px;
                        margin-bottom:6px;">${chips}</div>`;
  }

  _renderChip(rowName, chip, active) {
    const size = this.compact
      ? 'padding:4px 10px; font-size:0.75rem;'
      : 'padding:6px 12px; font-size:0.85rem;';
    const base =
      `${size} border-radius:999px; cursor:pointer;` +
      ` font-weight:600; border:1px solid var(--color-border);` +
      ` line-height:1.1;`;
    const activeCss = 'background:var(--color-primary, #2563eb); color:#fff;';
    const idleCss   = 'background:var(--bg-secondary); color:var(--text-primary);';
    const disabledCss = chip.disabled
      ? 'opacity:0.4; cursor:not-allowed;' : '';
    const countHtml = (chip.count == null)
      ? ''
      : ` <span style="opacity:0.7; font-weight:400;">(${chip.count})</span>`;
    return `<button type="button" data-fb-row="${this._esc(rowName)}"
                    data-fb-chip="${this._esc(chip.id)}"
                    ${chip.disabled ? 'disabled' : ''}
                    style="${base} ${active ? activeCss : idleCss} ${disabledCss}">
              ${this._esc(chip.label)}${countHtml}
            </button>`;
  }

  _onClick(e) {
    const btn = e.target.closest('[data-fb-chip]');
    if (!btn || btn.disabled) return;
    const rowName = btn.getAttribute('data-fb-row');
    const chipId  = btn.getAttribute('data-fb-chip');
    const row = this.rows.find(r => r.name === rowName);
    if (!row) return;

    // Toggle: clicking an already-active chip clears the row.
    const nextValue = (row.selected === chipId) ? null : chipId;
    row.selected = nextValue;

    // If this row `clears` other rows, wipe them so filters stay
    // mutually exclusive across dimensions.
    if (Array.isArray(row.clears)) {
      for (const otherName of row.clears) {
        const other = this.rows.find(r => r.name === otherName);
        if (other) other.selected = null;
      }
    }

    this.render();
    if (typeof row.onSelect === 'function') {
      try { row.onSelect(nextValue, row); }
      catch (err) { console.error('FilterBar onSelect threw:', err); }
    }
  }

  _esc(s) {
    return String(s ?? '')
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
}

// Expose globally so screens can reach it without imports.
window.FilterBar = FilterBar;
