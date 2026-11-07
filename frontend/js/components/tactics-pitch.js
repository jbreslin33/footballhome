// TacticsPitch — one coach-drawn situation on a pitch (mig 1120).
//
// Owner 2026-11-06: "can we use the current graphic to show or add a pill
// for game to show the tactics depending on where opponents and ball are"
// → coach-drawn situations per formation, starting with 3-5-2 (3-R2).
//
// Pure DOM, absolutely placed pieces on a vertical pitch: our goal at the
// bottom, attacking up.  Coordinates are the API's 0–100 (x left → right,
// y from our goal line up), so left = x%, top = (100 − y)%.  Blue chips =
// us (shirt number, the day's name under it), red = them (role label),
// white = the ball.  Editable (coaches): drag any piece; the situation
// object is updated in place and onChange() fires on each drop — saving
// is the caller's job.
class TacticsPitch {
  // situation: { ball, players: [{position_id,x,y}], opponents: [{label,x,y}] }
  // chipFor(positionId) → { number, name, job? }  (name '' = slot empty;
  //   job = a short line under the name, e.g. "shadow 6 · press 4")
  // dragKinds: which pieces drag when editable ('us' | 'opp' | 'ball').
  // onPieceClick(kind, idx): a tap (not a drag) on a piece — the plan view
  //   uses it on theirs to play the ball to that man.
  // orientation: 'portrait' (our goal at the bottom, attacking up) or
  //   'landscape' (our goal on the left, attacking right) — owner 11/7:
  //   "should be choice of orientations".  Only the drawing turns; the
  //   situation's numbers stay plan coordinates.
  // big: the full-screen view — the pitch fills the box it is given instead
  //   of the 420 px column.  Pieces are sized off the pitch's short side, so
  //   they grow with it (owner 11/7: "player number pills need to be smaller").
  constructor({ situation, chipFor, editable = false, onChange = null, dragKinds = ['us', 'opp', 'ball'], onPieceClick = null,
                orientation = 'portrait', big = false }) {
    this.orientation = orientation === 'landscape' ? 'landscape' : 'portrait';
    this.big = !!big;
    this.situation = situation;
    this.chipFor = chipFor;
    this.editable = editable;
    this.onChange = onChange;
    this.dragKinds = new Set(dragKinds);
    this.onPieceClick = onPieceClick;
    this._drag = null;
    this._el = null;
  }

  static esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }

  // Markings as an SVG in pitch units (68 × 105 m), stretched to the box.
  // Landscape turns the same drawing a quarter: our goal (bottom) → left.
  static markingsSvg(landscape = false) {
    const L = 'stroke="rgba(255,255,255,0.55)" stroke-width="0.5" fill="none"';
    return `<svg viewBox="${landscape ? '0 0 105 68' : '0 0 68 105'}" preserveAspectRatio="none" style="position:absolute; inset:0; width:100%; height:100%;" aria-hidden="true">${landscape ? '<g transform="translate(105,0) rotate(90)">' : '<g>'}
      <rect x="0.5" y="0.5" width="67" height="104" ${L}/>
      <line x1="0" y1="52.5" x2="68" y2="52.5" ${L}/>
      <circle cx="34" cy="52.5" r="9.15" ${L}/>
      <rect x="13.84" y="0.5" width="40.32" height="16.5" ${L}/>
      <rect x="24.84" y="0.5" width="18.32" height="5.5" ${L}/>
      <rect x="13.84" y="88" width="40.32" height="16.5" ${L}/>
      <rect x="24.84" y="99" width="18.32" height="5.5" ${L}/>
    </g></svg>`;
  }

  // Where each piece DRAWS: its true spot, nudged apart from any piece it
  // would cover (owner 11/6: "players should not cover over other player
  // pills. you can't tell guy under").  Display only — the situation's
  // numbers (what is saved and what the game plays) never change.  Works in
  // a square-ish unit space (y stretched by 105/68) so a chip's footprint
  // is round; the ball holds still, two people both give way.
  _layout(situation) {
    const s = situation || this.situation;
    const SY = 105 / 68, D = 5.6, DB = 3.4;   // % of the 68 m side ≈ the chip sizes below
    const items = [
      ...(s.opponents || []).map((p, i) => ({ key: `opp:${i}`, kind: 'opp', x: p.x, y: p.y * SY })),
      ...(s.players || []).map((p, i) => ({ key: `us:${i}`, kind: 'us', x: p.x, y: p.y * SY })),
      ...(s.ball ? [{ key: 'ball:0', kind: 'ball', x: s.ball.x, y: s.ball.y * SY }] : []),
    ];
    for (let pass = 0; pass < 12; pass++) {
      let moved = false;
      for (let i = 0; i < items.length; i++) {
        for (let j = i + 1; j < items.length; j++) {
          const a = items[i], b = items[j];
          const min = a.kind === 'ball' || b.kind === 'ball' ? DB : D;
          let dx = b.x - a.x, dy = b.y - a.y, d = Math.hypot(dx, dy);
          if (d >= min) continue;
          if (d < 1e-6) { dx = (i % 2 ? 1 : -1); dy = 0.3; d = Math.hypot(dx, dy); }
          const push = (min - d) / d;
          const wa = a.kind === 'ball' ? 0 : (b.kind === 'ball' ? 1 : 0.5), wb = 1 - wa;
          a.x -= dx * push * wa; a.y -= dy * push * wa;
          b.x += dx * push * wb; b.y += dy * push * wb;
          moved = true;
        }
      }
      if (!moved) break;
    }
    const out = new Map();
    for (const it of items) out.set(it.key, { x: Math.max(1.5, Math.min(98.5, it.x)), y: Math.max(1, Math.min(99, it.y / SY)) });
    return out;
  }

  // Plan point → where it sits in the box, in %.  Portrait: x across, our
  // goal at the bottom.  Landscape: our goal on the left, and "left as we
  // attack" (x = 0) at the top.
  _screen(p) {
    return this.orientation === 'landscape' ? { left: p.y, top: p.x } : { left: p.x, top: 100 - p.y };
  }

  // Box % → plan point (dragging).
  _plan(leftPct, topPct) {
    return this.orientation === 'landscape' ? { x: topPct, y: leftPct } : { x: leftPct, y: 100 - topPct };
  }

  _pieceHtml(kind, idx, p) {
    const at = (this._drawAt && this._drawAt.get(`${kind}:${idx}`)) || p;
    const sc = this._screen(at);
    const pos = `left:${sc.left}%; top:${sc.top}%;`;
    const grab = this.editable && this.dragKinds.has(kind) ? 'cursor:grab; touch-action:none;'
      : (this.onPieceClick && kind !== 'ball' ? 'cursor:pointer;' : '');
    const base = `position:absolute; ${pos} transform:translate(-50%,-50%); ${grab} user-select:none; -webkit-user-select:none;`;
    if (kind === 'ball') {
      return `<div data-tp-kind="ball" data-tp-idx="0" style="${base} width:calc(var(--u) * 3); height:calc(var(--u) * 3); min-width:9px; min-height:9px; border-radius:50%; background:#fff; border:2px solid #111; box-sizing:border-box; box-shadow:0 1px 3px rgba(0,0,0,0.6); z-index:3;"></div>`;
    }
    if (kind === 'opp') {
      return `<div data-tp-kind="opp" data-tp-idx="${idx}" style="${base} z-index:1; display:flex; flex-direction:column; align-items:center;">
        <div style="width:calc(var(--u) * 3.6); height:calc(var(--u) * 3.6); min-width:11px; min-height:11px; border-radius:50%; background:#dc2626; border:1.5px solid #fff; box-sizing:border-box;"></div>
        <div style="font-size:max(8px, calc(var(--u) * 2)); font-weight:700; color:#fecaca; text-shadow:0 1px 2px #000; line-height:1.1; margin-top:1px;">${TacticsPitch.esc(p.label != null ? p.label : p.number)}</div>
      </div>`;
    }
    const chip = this.chipFor(p.position_id) || { number: p.position_id, name: '' };
    return `<div data-tp-kind="us" data-tp-idx="${idx}" style="${base} z-index:2; display:flex; flex-direction:column; align-items:center; width:calc(var(--u) * 16); min-width:56px;">
      <div style="width:calc(var(--u) * 4.6); height:calc(var(--u) * 4.6); min-width:15px; min-height:15px; border-radius:50%; background:#1d4ed8; border:1.5px solid #fff; box-sizing:border-box; color:#facc15; font-weight:800; font-size:max(8px, calc(var(--u) * 2.5)); display:flex; align-items:center; justify-content:center; line-height:1;">${TacticsPitch.esc(chip.number)}</div>
      <div style="font-size:max(8px, calc(var(--u) * 2.1)); font-weight:700; color:#fff; text-shadow:0 1px 2px #000; line-height:1.1; margin-top:1px; text-align:center; overflow-wrap:anywhere;">${TacticsPitch.esc(chip.name)}</div>
      ${chip.job ? `<div style="font-size:max(7px, calc(var(--u) * 1.8)); font-weight:700; color:#fde68a; text-shadow:0 1px 2px #000; line-height:1.1; text-align:center;">${TacticsPitch.esc(chip.job)}</div>` : ''}
    </div>`;
  }

  html() {
    const s = this.situation;
    this._drawAt = this._layout(s);
    const pieces = [
      ...(s.opponents || []).map((o, i) => this._pieceHtml('opp', i, o)),
      ...(s.players || []).map((p, i) => this._pieceHtml('us', i, p)),
      s.ball ? this._pieceHtml('ball', 0, s.ball) : '',
    ].join('');
    // --u = 1% of the pitch's short side (container units: the pitch is the
    // pieces' container).  Normal: an upright pitch in a 420 px column, a
    // sideways one in a 640 px row.  Big: as large as the box allows.
    const land = this.orientation === 'landscape';
    const size = this.big
      ? (land ? 'width:min(100%, calc(var(--tp-fit-h, 80vh) * 105 / 68));' : 'width:min(100%, calc(var(--tp-fit-h, 80vh) * 68 / 105));')
      : (land ? 'width:100%; max-width:640px;' : 'width:100%; max-width:420px;');
    return `<div data-tp-pitch style="position:relative; ${size} margin:0 auto; aspect-ratio:${land ? '105 / 68' : '68 / 105'}; container-type:inline-size; --u:${land ? 'calc(100cqw * 68 / 10500)' : '1cqw'}; background:#15803d; border-radius:6px; overflow:hidden; ${this.editable ? 'outline:2px dashed #facc15; outline-offset:2px;' : ''}">
      ${TacticsPitch.markingsSvg(land)}${pieces}
    </div>`;
  }

  _target(kind, idx) {
    const s = this.situation;
    if (kind === 'ball') return s.ball;
    if (kind === 'opp') return (s.opponents || [])[idx];
    return (s.players || [])[idx];
  }

  // Moves the existing pieces to a new situation with the same pieces in
  // the same order (no re-render) — the animation's frame step.
  update(situation) {
    this.situation = situation;
    if (!this._el) return;
    const at = this._layout(situation);
    for (const node of this._el.querySelectorAll('[data-tp-kind]')) {
      const p = at.get(`${node.dataset.tpKind}:${node.dataset.tpIdx}`);
      if (!p) continue;
      const sc = this._screen(p);
      node.style.left = `${sc.left}%`;
      node.style.top = `${sc.top}%`;
    }
  }

  // Renders into el; wires taps and, when editable, pointer dragging.
  mount(el) {
    el.innerHTML = this.html();
    this._el = el;
    const pitch = el.querySelector('[data-tp-pitch]');
    if (this.onPieceClick && !this.editable) {
      pitch.addEventListener('click', (e) => {
        const node = e.target.closest('[data-tp-kind]');
        if (node) this.onPieceClick(node.dataset.tpKind, Number(node.dataset.tpIdx));
      });
    }
    if (!this.editable) return;
    const clamp = v => Math.max(0, Math.min(100, Math.round(v * 2) / 2));
    pitch.addEventListener('pointerdown', (e) => {
      const node = e.target.closest('[data-tp-kind]');
      if (!node || !this.dragKinds.has(node.dataset.tpKind)) return;
      const target = this._target(node.dataset.tpKind, Number(node.dataset.tpIdx));
      if (!target) return;
      e.preventDefault();
      node.setPointerCapture(e.pointerId);
      node.style.cursor = 'grabbing';
      this._drag = { node, target, rect: pitch.getBoundingClientRect() };
    });
    pitch.addEventListener('pointermove', (e) => {
      const d = this._drag;
      if (!d) return;
      const at = this._plan(((e.clientX - d.rect.left) / d.rect.width) * 100, ((e.clientY - d.rect.top) / d.rect.height) * 100);
      d.target.x = clamp(at.x);
      d.target.y = clamp(at.y);
      const sc = this._screen(d.target);
      d.node.style.left = `${sc.left}%`;
      d.node.style.top = `${sc.top}%`;
    });
    const end = () => {
      const d = this._drag;
      if (!d) return;
      d.node.style.cursor = 'grab';
      this._drag = null;
      if (this.onChange) this.onChange();
    };
    pitch.addEventListener('pointerup', end);
    pitch.addEventListener('pointercancel', end);
  }
}

window.TacticsPitch = TacticsPitch;
