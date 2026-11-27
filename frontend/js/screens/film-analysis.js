// film-analysis.js — 🎥 #film-analysis[/<clip id>] (migration 1993).
//
// Owner 2026-11-27: "can you analyze game film and track analytics on fh"
// … "make the replay and put analysis on the page with it. for however
// long the clip is in future that analysis is on same page".
//
// One page for every analysed clip, any length: pick a clip → the replay
// (boxes, ball ring, pitch lines drawn by scripts/film/), a top-down
// mini-pitch that follows the replay's time, and the clip's numbers
// (computed server-side, models/FilmAnalysis).  Wording: message_templates
// kind 'film_analysis'.
class FilmAnalysisScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clips = null; this.clip = null; this.err = ''; this.clipId = null;
    this._videoUrl = null; this._raf = null;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('film_analysis', tier, tokens) : ''; }
  _mmss(s) { s = Math.max(0, Math.round(Number(s) || 0)); return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fa-wrap { max-width: 980px; margin: 0 auto; }
        .fa-intro { opacity: .75; font-size: .9rem; margin: 0 0 var(--space-3); }
        .fa-h { font-weight: 800; font-size: .78rem; letter-spacing: .06em; text-transform: uppercase; opacity: .6; margin: var(--space-4) 0 6px; }
        .fa-clips { display: flex; flex-wrap: wrap; gap: 8px; }
        .fa-clip { padding: 6px 14px; border-radius: 999px; border: 1px solid var(--border-color, #374151); background: none; color: inherit; cursor: pointer; font-size: .88rem; }
        .fa-clip.on { background: var(--primary-color, #2563eb); border-color: var(--primary-color, #2563eb); color: #fff; font-weight: 700; }
        .fa-video { width: 100%; border-radius: 8px; background: #000; display: block; }
        .fa-sub { font-size: .8rem; opacity: .65; margin-top: 4px; }
        .fa-sub a { color: inherit; }
        .fa-pitch { width: 100%; display: block; border-radius: 8px; }
        .fa-legend { display: flex; flex-wrap: wrap; gap: 14px; font-size: .8rem; opacity: .8; margin-top: 6px; }
        .fa-legend i { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 5px; vertical-align: -1px; }
        .fa-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 8px; }
        .fa-stat { border: 1px solid var(--border-color, #374151); border-radius: 8px; padding: 8px 10px; }
        .fa-stat b { display: block; font-size: 1.25rem; }
        .fa-stat span { font-size: .78rem; opacity: .7; }
        .fa-table { width: 100%; border-collapse: collapse; font-size: .88rem; }
        .fa-table th, .fa-table td { text-align: right; padding: 6px 8px; border-top: 1px solid var(--border-color, #374151); }
        .fa-table th:first-child, .fa-table td:first-child { text-align: left; }
        .fa-caveat { font-size: .8rem; opacity: .6; margin-top: var(--space-3); }
      </style>
      <div class="screen-content fa-wrap">
        <div id="fa-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    return div;
  }

  onEnter(params = {}) {
    this.clipId = params.entity ? Number(params.entity) : null;
    this.load();
  }

  onExit() {
    if (this._raf) cancelAnimationFrame(this._raf);
    this._raf = null;
    if (this._videoUrl) { URL.revokeObjectURL(this._videoUrl); this._videoUrl = null; }
  }

  async load() {
    this.err = '';
    try {
      const res = await this.auth.fetch('/api/film-analysis');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.clips = body.clips || [];
      if (!this.clipId && this.clips.length) this.clipId = this.clips[0].id;
      if (this.clipId) await this.loadClip(this.clipId, false);
    } catch (err) { this.err = err.message || 'Failed to load.'; }
    if (this.isMounted) this._renderBody();
  }

  async loadClip(id, rerender = true) {
    this.clipId = id; this.clip = null;
    if (this._videoUrl) { URL.revokeObjectURL(this._videoUrl); this._videoUrl = null; }
    if (rerender) this._renderBody();
    try {
      const res = await this.auth.fetch(`/api/film-analysis/${id}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.clip = body;
      // Replay bytes come through the signed-in fetch (club_files 'members').
      if (body.clip && body.clip.replay_file_id) {
        const v = await this.auth.fetch(`/api/files/dl/${body.clip.replay_file_id}`);
        if (v.ok) this._videoUrl = URL.createObjectURL(await v.blob());
      }
    } catch (err) { this.err = err.message || 'Failed to load the clip.'; }
    if (rerender && this.isMounted) this._renderBody();
  }

  _renderBody() {
    const el = this.find('#fa-body');
    if (!el) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (this.err) { el.innerHTML = `<div class="error">${esc(this.err)}</div>`; return; }
    if (!this.clips) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    let html = `<p class="fa-intro">${esc(this._copy('intro'))}</p>`;
    if (!this.clips.length) { el.innerHTML = html + `<div style="opacity:.7;">${esc(this._copy('none') || 'No clips analysed yet.')}</div>`; return; }
    html += `<div class="fa-h">${esc(this._copy('clips') || 'Clips')}</div><div class="fa-clips">` +
      this.clips.map(c => `<button class="fa-clip${c.id === this.clipId ? ' on' : ''}" data-clip="${c.id}">${esc(c.title)} · ${esc(this._mmss(c.start))}–${esc(this._mmss(c.end))}</button>`).join('') +
      '</div>';
    const d = this.clip;
    if (!d) { el.innerHTML = html + '<div class="loading" style="margin-top:12px;">Loading…</div>'; this._wireClips(el); return; }
    const c = d.clip, s = d.stats || {};
    const ytStart = c.source_url && /youtu/.test(c.source_url)
      ? `${c.source_url}${c.source_url.includes('?') ? '&' : '?'}t=${Math.floor(c.start)}s` : c.source_url;
    html += `<div class="fa-h">${esc(this._copy('replay') || 'Replay')}</div>`;
    html += this._videoUrl ? `<video class="fa-video" id="fa-video" src="${this._videoUrl}" controls playsinline muted loop></video>` : '';
    html += `<div class="fa-sub">${esc(this._copy('window', { start: this._mmss(c.start), end: this._mmss(c.end), seconds: Math.round(c.end - c.start), frames: s.frames || 0 }))}
             ${ytStart ? ` · <a href="${esc(ytStart)}" target="_blank" rel="noopener">${esc(this._copy('film_link', { start: this._mmss(c.start) }) || 'Watch the film')}</a>` : ''}</div>`;

    html += `<div class="fa-h">${esc(this._copy('pitch') || 'On the pitch')}</div>
             <canvas class="fa-pitch" id="fa-pitch"></canvas>
             <div class="fa-legend">${this._legend(d.kits)}</div>`;

    html += `<div class="fa-h">${esc(this._copy('numbers') || 'Numbers')}</div><div class="fa-grid">
      ${this._stat(`${s.ball_found_pct ?? 0}%`, this._copy('ball_found'))}
      ${this._stat(`${s.ball_distance_m ?? 0} m`, this._copy('ball_distance'))}
      ${this._stat((s.ball_thirds_pct || []).map(v => `${v}%`).join(' · ') || '—', this._copy('ball_thirds'))}
      ${this._stat(`${s.camera_solved_pct ?? 0}%`, this._copy('camera'))}
    </div>`;
    const teams = (s.teams || []).filter(t => t.kit !== 'unknown');
    if (teams.length) {
      const label = (k) => {
        const kit = (d.kits || []).find(x => x.kit === k);
        if (kit) return kit.label + (kit.is_ours === null ? ` ${this._copy('kit_unconfirmed')}` : '');
        return k === 'goalkeeper' ? 'Goalkeepers' : k;
      };
      const cell = (v) => v == null ? '—' : esc(v);
      html += `<table class="fa-table" style="margin-top:10px;"><thead><tr><th></th>
          <th>${esc(this._copy('seen'))}</th><th>${esc(this._copy('avg_pos'))}</th>
          <th>${esc(this._copy('width'))}</th><th>${esc(this._copy('depth'))}</th><th>${esc(this._copy('nearest'))}</th></tr></thead><tbody>` +
        teams.map(t => `<tr><td>${esc(label(t.kit))}</td><td>${cell(t.seen_per_frame)}</td><td>${cell(t.avg_x)}</td>
          <td>${cell(t.width)}</td><td>${cell(t.depth)}</td><td>${t.nearest_pct == null ? '—' : esc(t.nearest_pct) + '%'}</td></tr>`).join('') +
        '</tbody></table>';
    }
    html += `<div class="fa-caveat">${esc(this._copy('caveat'))}</div>`;
    el.innerHTML = html;
    this._wireClips(el);
    this._startPitch();
  }

  _stat(value, label) { return `<div class="fa-stat"><b>${this.escapeHtml(String(value))}</b><span>${this.escapeHtml(label || '')}</span></div>`; }

  _colour(kind, kit) {
    if (kind === 'referee') return '#ef4444';
    if (kind === 'goalkeeper') return '#f59e0b';
    if (kit === 'white') return '#f8fafc';
    if (kit === 'dark') return '#1e3a8a';
    return '#9ca3af';
  }

  _legend(kits) {
    const items = (kits || []).map(k => [this._colour('player', k.kit), k.label]);
    items.push([this._colour('goalkeeper'), 'Goalkeeper'], [this._colour('referee'), 'Referee'], ['#facc15', 'Ball']);
    return items.map(([c, l]) => `<span><i style="background:${c}; border:1px solid #64748b;"></i>${this.escapeHtml(l)}</span>`).join('');
  }

  _wireClips(el) {
    el.querySelectorAll('[data-clip]').forEach(b => b.addEventListener('click', () => {
      const id = Number(b.dataset.clip);
      if (id === this.clipId) return;
      this.navigation.goTo('film-analysis', { entity: String(id) });
    }));
  }

  // Mini-pitch: draws the frame nearest the replay's current time.
  _startPitch() {
    if (this._raf) cancelAnimationFrame(this._raf);
    const cv = this.find('#fa-pitch'); const d = this.clip;
    if (!cv || !d) return;
    const [L, W] = d.clip.pitch; const frames = d.frames || [];
    const video = this.find('#fa-video');
    const draw = () => {
      if (!this.isMounted || !cv.isConnected) return;
      const cssW = cv.clientWidth || 600, pad = 14;
      const scale = (cssW - pad * 2) / L, cssH = W * scale + pad * 2;
      const dpr = window.devicePixelRatio || 1;
      if (cv.width !== Math.round(cssW * dpr) || cv.height !== Math.round(cssH * dpr)) {
        cv.width = Math.round(cssW * dpr); cv.height = Math.round(cssH * dpr); cv.style.height = `${cssH}px`;
      }
      const g = cv.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0);
      // Pitch: x along the length (left → right), y across with the camera's
      // near touchline (negative y) at the BOTTOM, as the film shows it.
      const X = (x) => pad + (x + L / 2) * scale, Y = (y) => pad + (W / 2 - y) * scale;
      g.fillStyle = '#166534'; g.fillRect(0, 0, cssW, cssH);
      g.strokeStyle = 'rgba(255,255,255,.75)'; g.lineWidth = 1.5;
      g.strokeRect(X(-L / 2), Y(W / 2), L * scale, W * scale);
      g.beginPath(); g.moveTo(X(0), Y(W / 2)); g.lineTo(X(0), Y(-W / 2)); g.stroke();
      g.beginPath(); g.arc(X(0), Y(0), 9.15 * scale, 0, Math.PI * 2); g.stroke();
      for (const sgn of [-1, 1]) {
        const gx = sgn * L / 2;
        g.strokeRect(Math.min(X(gx), X(gx - sgn * 16.5)), Y(20.16), 16.5 * scale, 40.32 * scale);
        g.strokeRect(Math.min(X(gx), X(gx - sgn * 5.5)), Y(9.16), 5.5 * scale, 18.32 * scale);
      }
      // camera
      const cam = d.clip.camera;
      if (cam && cam[1]) { g.fillStyle = '#e5e7eb'; g.font = '12px sans-serif'; g.fillText('🎥', X(cam[0]) - 7, Math.min(cssH - 2, Y(cam[1]))); }
      if (frames.length) {
        const t = video ? video.currentTime : 0;
        let lo = 0, hi = frames.length - 1;
        while (lo < hi) { const m = (lo + hi + 1) >> 1; if (frames[m].t <= t) lo = m; else hi = m - 1; }
        const f = frames[lo];
        for (const [kind, kit, , x, y] of f.p) {
          g.beginPath(); g.arc(X(x), Y(y), 5, 0, Math.PI * 2);
          g.fillStyle = this._colour(kind, kit); g.fill();
          g.strokeStyle = '#0f172a'; g.lineWidth = 1; g.stroke();
        }
        if (f.b) {
          g.beginPath(); g.arc(X(f.b[0]), Y(f.b[1]), 4, 0, Math.PI * 2);
          g.fillStyle = '#facc15'; g.fill(); g.strokeStyle = '#000'; g.stroke();
        }
        g.fillStyle = 'rgba(255,255,255,.85)'; g.font = '12px sans-serif';
        g.fillText(this._mmss(d.clip.start + f.t), pad + 4, pad + 14);
      }
      this._raf = requestAnimationFrame(draw);
    };
    draw();
  }
}
window.FilmAnalysisScreen = FilmAnalysisScreen;
