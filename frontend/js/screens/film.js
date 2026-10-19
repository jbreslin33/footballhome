// film.js — #film: APSL game film (migration 599).  Owner 2026-10-19:
// "can we take this doc and put the links on football home. players
// should not edit the original doc but you should be able to figure out
// waht game it is by the date and official apsl website scheudle and the
// 'home' team as its home team responsibity to upload game film."
//
// Read-only mirror of the league's shared film sheet.  The backend
// matches each link to the game FUZZILY (home team + around the matchday
// window + our APSL feed — "the date may not always match up").  Our own
// games carry the matchup and date; the rest of the league's film lists
// by matchday and home team.  Wording: message_templates kind 'film'.
class FilmScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.rows = null; this.err = ''; this.loading = false;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('film', tier, tokens) : ''; }
  _md(iso) { if (!iso) return ''; const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})/); return m ? `${+m[2]}/${+m[3]}` : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fl-day { font-weight:800; font-size:0.8rem; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; margin:var(--space-3) 0 4px; }
        .fl-row { display:flex; gap:10px; align-items:center; padding:7px 4px; border-top:1px solid var(--border-color, #374151); font-size:0.92rem; }
        .fl-row.ours { font-weight:700; }
        .fl-row .who { flex:1; min-width:0; }
        .fl-row .sub { font-size:0.78rem; opacity:0.65; font-weight:400; }
        .fl-watch { display:inline-block; padding:5px 14px; border-radius:999px; border:1px solid var(--primary-color, #2563eb); color:#bfdbfe; text-decoration:none; font-size:0.85rem; font-weight:700; white-space:nowrap; }
        .fl-watch:hover { background:var(--primary-color, #2563eb); color:#fff; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="fl-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="fl-title">🎥 Game film</h1><div id="fl-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-secondary" id="fl-refresh" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
      </div>
      <div class="screen-content" style="max-width:860px; margin:0 auto;">
        <div id="fl-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#fl-back').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#fl-refresh').addEventListener('click', () => this.load());
    return div;
  }

  onEnter() {
    const t = this.find('#fl-title'), s = this.find('#fl-sub');
    if (t) t.textContent = this._copy('title') || '🎥 Game film';
    if (s) s.textContent = this._copy('subtitle');
    this.load();
  }

  async load() {
    this.loading = true; this.err = ''; this._renderBody();
    try {
      const res = await this.auth.fetch('/api/film');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.rows = body.rows || [];
    } catch (err) { this.rows = null; this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) this._renderBody();
  }

  _renderBody() {
    const el = this.find('#fl-body');
    if (!el) return;
    if (this.loading) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.err) { el.innerHTML = `<div class="error">${this.escapeHtml(this.err)}</div>`; return; }
    const rows = this.rows || [];
    if (!rows.length) { el.innerHTML = `<div style="opacity:0.7;">${this.escapeHtml(this._copy('empty') || 'No film posted yet.')}</div>`; return; }
    const esc = (t) => this.escapeHtml(t);
    const watch = esc(this._copy('watch') || 'Watch');
    // Newest matchday first, as the API orders it; one header per matchday.
    let html = '', lastMd = null;
    for (const r of rows) {
      const md = r.matchday || `${this._md(r.from)} – ${this._md(r.till)}`;
      if (md !== lastMd) {
        lastMd = md;
        html += `<div class="fl-day">${esc(md)} · ${esc(this._md(r.from))}–${esc(this._md(r.till))}</div>`;
      }
      // Three tiers since mig 607: our game (bold, named as Lighthouse vs
      // X), any other RESOLVED game (both sides named from the league-wide
      // feeds — "they may not know easy who the away team was"), and a row
      // the schedule couldn't place (home team only, as the sheet states).
      const ours = !!(r.game && r.game.opponent);
      const matched = !ours && !!(r.game && r.game.home && r.game.away);
      const label = ours
        ? esc(this._copy('ours', { day: r.game.day_label, opponent: r.game.opponent }) || `${r.game.day_label} · Lighthouse vs ${r.game.opponent}`)
        : matched
          ? esc(this._copy('matched', { day: r.game.day_label, home: r.game.home, away: r.game.away }) || `${r.game.day_label} · ${r.game.home} vs ${r.game.away}`)
          : esc(this._copy('unmatched', { home: r.home_team }) || `${r.home_team} (home team)`);
      html += `
        <div class="fl-row${ours ? ' ours' : ''}">
          <span class="who">${ours ? '🏟 ' : ''}${label}${ours || matched ? ` <span class="sub">${esc(r.home_team)} filmed</span>` : ''}</span>
          <a class="fl-watch" href="${esc(r.url)}" target="_blank" rel="noopener">🎥 ${watch}</a>
        </div>`;
    }
    el.innerHTML = html;
  }
}
window.FilmScreen = FilmScreen;
