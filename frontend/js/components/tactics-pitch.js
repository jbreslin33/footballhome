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
  // chipFor(positionId) → { number, name }  (name '' = slot empty)
  constructor({ situation, chipFor, editable = false, onChange = null }) {
    this.situation = situation;
    this.chipFor = chipFor;
    this.editable = editable;
    this.onChange = onChange;
    this._drag = null;
  }

  static esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }

  // Markings as an SVG in pitch units (68 × 105 m), stretched to the box.
  static markingsSvg() {
    const L = 'stroke="rgba(255,255,255,0.55)" stroke-width="0.5" fill="none"';
    return `<svg viewBox="0 0 68 105" preserveAspectRatio="none" style="position:absolute; inset:0; width:100%; height:100%;" aria-hidden="true">
      <rect x="0.5" y="0.5" width="67" height="104" ${L}/>
      <line x1="0" y1="52.5" x2="68" y2="52.5" ${L}/>
      <circle cx="34" cy="52.5" r="9.15" ${L}/>
      <rect x="13.84" y="0.5" width="40.32" height="16.5" ${L}/>
      <rect x="24.84" y="0.5" width="18.32" height="5.5" ${L}/>
      <rect x="13.84" y="88" width="40.32" height="16.5" ${L}/>
      <rect x="24.84" y="99" width="18.32" height="5.5" ${L}/>
    </svg>`;
  }

  _pieceHtml(kind, idx, p) {
    const pos = `left:${p.x}%; top:${100 - p.y}%;`;
    const grab = this.editable ? 'cursor:grab; touch-action:none;' : '';
    const base = `position:absolute; ${pos} transform:translate(-50%,-50%); ${grab} user-select:none; -webkit-user-select:none;`;
    if (kind === 'ball') {
      return `<div data-tp-kind="ball" data-tp-idx="0" style="${base} width:14px; height:14px; border-radius:50%; background:#fff; border:2px solid #111; box-shadow:0 1px 3px rgba(0,0,0,0.6); z-index:3;"></div>`;
    }
    if (kind === 'opp') {
      return `<div data-tp-kind="opp" data-tp-idx="${idx}" style="${base} z-index:1; display:flex; flex-direction:column; align-items:center;">
        <div style="width:22px; height:22px; border-radius:50%; background:#dc2626; border:2px solid #fff; box-sizing:border-box;"></div>
        <div style="font-size:9px; font-weight:700; color:#fecaca; text-shadow:0 1px 2px #000; line-height:1.1; margin-top:1px;">${TacticsPitch.esc(p.label)}</div>
      </div>`;
    }
    const chip = this.chipFor(p.position_id) || { number: p.position_id, name: '' };
    return `<div data-tp-kind="us" data-tp-idx="${idx}" style="${base} z-index:2; display:flex; flex-direction:column; align-items:center; width:72px;">
      <div style="width:28px; height:28px; border-radius:50%; background:#1d4ed8; border:2px solid #fff; box-sizing:border-box; color:#facc15; font-weight:800; font-size:13px; line-height:24px; text-align:center;">${TacticsPitch.esc(chip.number)}</div>
      <div style="font-size:10px; font-weight:700; color:#fff; text-shadow:0 1px 2px #000; line-height:1.1; margin-top:1px; text-align:center; overflow-wrap:anywhere;">${TacticsPitch.esc(chip.name)}</div>
    </div>`;
  }

  html() {
    const s = this.situation;
    const pieces = [
      ...(s.opponents || []).map((o, i) => this._pieceHtml('opp', i, o)),
      ...(s.players || []).map((p, i) => this._pieceHtml('us', i, p)),
      s.ball ? this._pieceHtml('ball', 0, s.ball) : '',
    ].join('');
    return `<div data-tp-pitch style="position:relative; width:100%; max-width:420px; margin:0 auto; aspect-ratio:68 / 105; background:#15803d; border-radius:6px; overflow:hidden; ${this.editable ? 'outline:2px dashed #facc15; outline-offset:2px;' : ''}">
      ${TacticsPitch.markingsSvg()}${pieces}
    </div>`;
  }

  _target(kind, idx) {
    const s = this.situation;
    if (kind === 'ball') return s.ball;
    if (kind === 'opp') return (s.opponents || [])[idx];
    return (s.players || [])[idx];
  }

  // Renders into el and, when editable, wires pointer dragging.
  mount(el) {
    el.innerHTML = this.html();
    if (!this.editable) return;
    const pitch = el.querySelector('[data-tp-pitch]');
    const clamp = v => Math.max(0, Math.min(100, Math.round(v * 2) / 2));
    pitch.addEventListener('pointerdown', (e) => {
      const node = e.target.closest('[data-tp-kind]');
      if (!node) return;
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
      d.target.x = clamp(((e.clientX - d.rect.left) / d.rect.width) * 100);
      d.target.y = clamp(100 - ((e.clientY - d.rect.top) / d.rect.height) * 100);
      d.node.style.left = `${d.target.x}%`;
      d.node.style.top = `${100 - d.target.y}%`;
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
