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

  // Where each piece DRAWS: its true spot, nudged apart until no piece
  // covers another — the pill AND the words under it (owner 11/6: "players
  // should not cover over other player pills"; 11/7: "you still have words
  // hidden. the players need to be able to read the tactical state of their
  // player").  Display only — the situation's numbers (what is saved and
  // what the game plays) never change.
  //
  // Works in screen units u = 1% of the pitch's short side (the --u the
  // pieces are sized in), so every footprint below is the drawn size: a box
  // from the top of the pill down past its last line of text.  Overlapping
  // boxes split apart along the shallower axis; the ball holds still.
  _footprint(kind, p) {
    // Sizes in u, never under the px floors the pieces are drawn with
    // (small phones: the floor wins).  _uPx = one u in px, measured on mount.
    const u = this._uPx || 4.2;
    const sz = (rel, minPx) => Math.max(rel, minPx / u);
    const textW = (str, fs) => String(str == null ? '' : str).length * fs * 0.56;   // bold sans ≈ 0.56 em a character
    if (kind === 'ball') { const b = sz(3, 9); return { w: b, h: b, chip: b }; }
    if (kind === 'opp') {
      const label = p.label != null ? p.label : p.number, c = sz(3.6, 11), fs = sz(2, 8);
      return { w: Math.max(c, textW(label, fs)), h: c + fs * 1.15, chip: c };
    }
    const chip = this.chipFor(p.position_id) || {};
    const c = sz(4.6, 15), fn = sz(2.1, 8), fj = sz(2, 8);
    const COL = sz(16, 56);                            // the label column's width
    const lines = (str, fs) => (str ? Math.max(1, Math.ceil(textW(str, fs) / COL)) : 0);
    const w = Math.max(c, Math.min(COL, Math.max(textW(chip.name, fn), textW(chip.job, fj))));
    return { w, h: c + 0.3 + lines(chip.name, fn) * fn * 1.12 + lines(chip.job, fj) * fj * 1.12, chip: c };
  }

  _layout(situation) {
    const s = situation || this.situation;
    const SY = 105 / 68, land = this.orientation === 'landscape';
    const W = land ? 100 * SY : 100, H = land ? 100 : 100 * SY;           // the box in u
    const toScr = (p) => land ? { x: p.y * SY, y: p.x } : { x: p.x, y: (100 - p.y) * SY };
    const toPlan = (q) => land ? { x: q.y, y: q.x / SY } : { x: q.x, y: 100 - q.y / SY };
    const GAP = 0.5;
    const hold = s.holdY != null && s.holdY < 100 ? Number(s.holdY) : null;
    const items = [];
    const add = (kind, i, p) => {
      const f = this._footprint(kind, p), sc = toScr(p);
      // Box centre: the pill's centre is the spot, the words hang below it.
      items.push({ key: `${kind}:${i}`, kind, w: f.w + GAP, h: f.h + GAP, off: (f.h - f.chip) / 2, x: sc.x, y: sc.y + (f.h - f.chip) / 2 });
    };
    (s.opponents || []).forEach((p, i) => add('opp', i, p));
    (s.players || []).forEach((p, i) => add('us', i, p));
    if (s.ball) add('ball', 0, s.ball);
    for (let pass = 0; pass < 40; pass++) {
      let moved = false;
      for (let i = 0; i < items.length; i++) {
        for (let j = i + 1; j < items.length; j++) {
          const a = items[i], b = items[j];
          const ox = (a.w + b.w) / 2 - Math.abs(b.x - a.x), oy = (a.h + b.h) / 2 - Math.abs(b.y - a.y);
          if (ox <= 0 || oy <= 0) continue;
          const wa = a.kind === 'ball' ? 0 : (b.kind === 'ball' ? 1 : 0.5), wb = 1 - wa;
          // Push along the shallower overlap — less travel from the true spot.
          if (ox < oy) {
            const d = (b.x - a.x) || (i % 2 ? 1e-3 : -1e-3), sgn = Math.sign(d);
            a.x -= sgn * ox * wa; b.x += sgn * ox * wb;
          } else {
            const d = (b.y - a.y) || (i % 2 ? 1e-3 : -1e-3), sgn = Math.sign(d);
            a.y -= sgn * oy * wa; b.y += sgn * oy * wb;
          }
          moved = true;
        }
      }
      // Keep every box on the pitch, and ours behind the restart's hold line
      // (goal kick: their 18) — spreading the words never breaks the Law.
      for (const it of items) {
        it.x = Math.max(it.w / 2, Math.min(W - it.w / 2, it.x));
        it.y = Math.max(it.h / 2, Math.min(H - it.h / 2, it.y));
        if (hold != null && it.kind === 'us') {
          if (land) it.x = Math.min(it.x, hold * SY);
          else it.y = Math.max(it.y, (100 - hold) * SY + it.off);
        }
      }
      if (!moved) break;
    }
    const out = new Map();
    for (const it of items) {
      const p = toPlan({ x: it.x, y: it.y - it.off });
      const top = hold != null && it.kind === 'us' ? hold : 100;
      out.set(it.key, { x: Math.max(0, Math.min(100, p.x)), y: Math.max(0, Math.min(top, p.y)) });
    }
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
      ${chip.job ? `<div style="font-size:max(8px, calc(var(--u) * 2)); font-weight:700; color:#fde68a; text-shadow:0 1px 2px #000; line-height:1.1; text-align:center;">${TacticsPitch.esc(chip.job)}</div>` : ''}
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
      ${TacticsPitch.markingsSvg(land)}${this._holdLineHtml(s, land)}${pieces}
    </div>`;
  }

  // The restart's hold line (goal kick: their 18) as a dashed red line —
  // nobody of ours is drawn past it until the ball is played.
  _holdLineHtml(s, land) {
    if (s.holdY == null || s.holdY >= 100) return '';
    const y = Number(s.holdY);
    const at = land ? `left:${y}%; top:0; bottom:0; border-left:2px dashed #f87171;`
                    : `top:${100 - y}%; left:0; right:0; border-top:2px dashed #f87171;`;
    return `<div data-tp-hold style="position:absolute; ${at} z-index:1; pointer-events:none; opacity:0.9;"></div>`;
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

  // One u in px from the pitch's drawn size; re-spreads the pieces when it
  // changed (first mount, or the big view refitting the pitch).
  remeasure() {
    const pitch = this._el && this._el.querySelector('[data-tp-pitch]');
    if (!pitch) return;
    const r = pitch.getBoundingClientRect();
    const uPx = Math.min(r.width, r.height) / 100;
    if (uPx > 0 && Math.abs(uPx - (this._uPx || 4.2)) > 0.2) { this._uPx = uPx; this.update(this.situation); }
  }

  // Renders into el; wires taps and, when editable, pointer dragging.
  mount(el) {
    el.innerHTML = this.html();
    this._el = el;
    const pitch = el.querySelector('[data-tp-pitch]');
    this.remeasure();
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
