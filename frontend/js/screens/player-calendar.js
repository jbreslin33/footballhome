// PlayerCalendarScreen — simplified player-only roster view.
// Read-only, no contact actions, no unassigned bucket, and only the
// APSL / Liga 1 columns are shown.
class PlayerCalendarScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.loading = false;
    this.error = null;
    this.data = null;
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-player-calendar';
    el.innerHTML = `
      <div class="screen-header" style="padding: 6px 10px 8px; gap: 8px; align-items:center; flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn" style="padding: 3px 7px; line-height:1;">←</button>
        <div>
          <h1 style="font-size: 0.95rem; margin: 0; line-height:1;">Player Calendar</h1>
          <p class="subtitle" id="pc-subtitle" style="margin: 2px 0 0; font-size: 0.68rem; line-height:1;">Loading roster…</p>
        </div>
      </div>

      <div style="padding: 0 10px 10px;">
        <div id="pc-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">Loading…</div>
        <div id="pc-error" style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="pc-list" style="display:none;"></div>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
    this.load();
  }

  async load() {
    const loading = this.find('#pc-loading');
    const errEl = this.find('#pc-error');
    const listEl = this.find('#pc-list');
    if (loading) loading.style.display = '';
    if (errEl) errEl.style.display = 'none';
    if (listEl) listEl.style.display = 'none';

    this.loading = true;
    this.error = null;
    try {
      const res = await this.auth.fetch('/api/mens-roster');
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      this.data = await res.json();
      this.renderRoster(this.data);
    } catch (err) {
      console.error('[player-calendar] load failed:', err);
      this.error = err.message || 'Failed to load roster.';
      if (errEl) {
        errEl.textContent = this.error;
        errEl.style.display = '';
      }
    } finally {
      this.loading = false;
      if (loading) loading.style.display = 'none';
    }
  }

  renderRoster(data) {
    const listEl = this.find('#pc-list');
    if (!listEl) return;

    const visibleColumns = (data.columns || []).filter((c) => {
      const teamId = Number(c.teamId);
      return teamId === 35 || teamId === 120;
    });

    const html = visibleColumns.map((col) => {
      const players = (data.buckets && data.buckets[String(col.teamId)]) || [];
      const rows = players.map((p) => this.renderPlayer(p)).join('');
      return `
        <section style="margin-bottom: 10px; background: var(--bg-secondary); border: 1px solid var(--color-border); border-radius: var(--radius-md); overflow: hidden;">
          <div style="padding: 8px 10px; border-bottom: 1px solid var(--color-border); background: rgba(255,255,255,0.03); font-weight: 700; font-size: 0.82rem;">
            ${this._escape(col.label || `Team ${col.teamId}`)}
          </div>
          <div style="display:flex; flex-direction:column; gap: 6px; padding: 8px 10px;">
            ${rows || '<div style="opacity:0.55; font-size:0.8rem;">No players</div>'}
          </div>
        </section>
      `;
    }).join('');

    listEl.innerHTML = html;
    listEl.style.display = '';
    const subtitle = this.find('#pc-subtitle');
    if (subtitle) {
      subtitle.textContent = `${(data.total || 0)} players · APSL + Liga 1`;
    }
  }

  renderPlayer(p) {
    const name = this._escape(`${p.firstName || ''} ${p.lastName || ''}`.trim() || p.fullName || 'Player');
    const dob = this._formatDob(p.birthDate);
    return `
      <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; padding: 6px 0; border-bottom: 1px solid rgba(255,255,255,0.06);">
        <div style="font-size:0.82rem; font-weight:600;">${name}</div>
        <div style="font-size:0.78rem; opacity:0.75; white-space:nowrap;">${this._escape(dob)}</div>
      </div>
    `;
  }

  _formatDob(value) {
    if (!value) return 'DOB —';
    const d = new Date(`${value}T00:00:00Z`);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
  }

  _escape(s) {
    if (s == null) return '';
    return String(s)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
  }
}
