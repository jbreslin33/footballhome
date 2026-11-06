// TacticGeometry — where our players stand from their jobs (mig 1121).
//
// The ONE rule set for a tactic plan state, in step with the game engine:
// both read tactic_job_kinds.dist_m / press_m and compute the same spots.
// THE CONTRACT is game/DESIGN.md §8.137 (the game session's file — a club
// session sends it the change rather than editing game/).  Change a rule
// here → that section and the engine change with it, or the app and the
// game teach different things.
//
// Units: the API's 0–100 pitch from OUR view (x left → right as we attack,
// y 0 = our goal line).  Distances are metres on a 68 × 105 pitch, so
// points convert to metres before any length is taken.
//
//   mark (A)              dist_m goal-side of A, toward the centre of our goal
//   cover_shadow (A, B)   B has the ball → press_m from the ball on the
//                         ball–A line (pressing, A in his shadow);
//                         else dist_m off A toward the ball (in the lane)
//   hold_between (A, B)   the midpoint of A and B, dist_m goal-side
//   straddle (A, partner) two of ours bookend A: each dist_m to his side of
//                         A across the ball→A line, press_m ball-side; the
//                         one whose formation spot is further left takes
//                         the left side (mig 1133)
//   no job                his formation spot
//   keeper                (50, the block height's gk_y)
const TacticGeometry = {
  W: 68, L: 105,
  OUR_GOAL: { x: 50, y: 0 },

  toM(p) { return { x: p.x * this.W / 100, y: p.y * this.L / 100 }; },
  toPct(m) {
    const clamp = v => Math.max(0, Math.min(100, v));
    return { x: clamp(m.x * 100 / this.W), y: clamp(m.y * 100 / this.L) };
  },

  // from + (toward − from) normalised × metres, in pitch %.
  step(from, toward, metres) {
    const a = this.toM(from), b = this.toM(toward);
    const dx = b.x - a.x, dy = b.y - a.y;
    const len = Math.hypot(dx, dy) || 1;
    return this.toPct({ x: a.x + dx / len * metres, y: a.y + dy / len * metres });
  },

  // state: { ball_with, opponents: [{number,x,y}], jobs: [{position_id,kind,target_a,target_b}] }
  // kinds: { code → {dist_m, press_m} }; base: [{position_id,x,y}] our formation spots.
  // → { ball: {x,y}, players: [{position_id, x, y}] } for positions 1–11 in id order.
  solve(state, kinds, base, gkY) {
    const opp = new Map((state.opponents || []).map(o => [Number(o.number), o]));
    const ballMan = opp.get(Number(state.ball_with));
    const ball = ballMan ? { x: ballMan.x, y: ballMan.y } : { x: 50, y: 95 };
    const jobs = new Map((state.jobs || []).map(j => [Number(j.position_id), j]));
    const players = [];
    for (let pid = 1; pid <= 11; pid++) {
      const home = (base || []).find(b => Number(b.position_id) === pid) || { x: 50, y: 30 };
      let spot = { x: home.x, y: home.y };
      if (pid === 1) spot = { x: 50, y: gkY != null ? gkY : home.y };
      const job = jobs.get(pid);
      const kind = job && kinds[job.kind];
      const a = job && opp.get(Number(job.target_a));
      const b = job && job.target_b != null ? opp.get(Number(job.target_b)) : null;
      if (kind && a) {
        if (job.kind === 'mark') spot = this.step(a, this.OUR_GOAL, kind.dist_m);
        else if (job.kind === 'cover_shadow') {
          spot = Number(job.target_b) === Number(state.ball_with) && b
            ? this.step(ball, a, kind.press_m != null ? kind.press_m : 1.5)
            : this.step(a, ball, kind.dist_m);
        } else if (job.kind === 'hold_between' && b) {
          spot = this.step({ x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }, this.OUR_GOAL, kind.dist_m);
        } else if (job.kind === 'straddle' && job.partner_position_id != null) {
          const mate = (base || []).find(x => Number(x.position_id) === Number(job.partner_position_id));
          spot = this.straddleSpot(a, ball, kind, !mate || home.x <= mate.x);
        }
      }
      players.push({ position_id: pid, x: spot.x, y: spot.y });
    }
    return { ball, players };
  },

  // One side of a straddle: across the ball→A line (the side with the
  // smaller x when left), press_m toward the ball.
  // When he has the ball (within 0.5 m) "toward the ball" has no
  // direction: use toward the centre of their goal (50, 100) instead —
  // agreed with the game session 11/6, same rule in game/DESIGN.md.
  straddleSpot(a, ball, kind, left) {
    const am = this.toM(a);
    let bm = this.toM(ball);
    if (Math.hypot(bm.x - am.x, bm.y - am.y) < 0.5) bm = this.toM({ x: 50, y: 100 });
    let ux = bm.x - am.x, uy = bm.y - am.y;
    const len = Math.hypot(ux, uy) || 1;
    ux /= len; uy /= len;
    let px = -uy, py = ux;                       // perpendicular
    if (px > 0 || (px === 0 && py > 0)) { px = -px; py = -py; }   // point it left
    const side = left ? 1 : -1, d = kind.dist_m, f = kind.press_m != null ? kind.press_m : 0;
    return this.toPct({ x: am.x + ux * f + px * d * side, y: am.y + uy * f + py * d * side });
  },

  // Their numbers no job of ours points at, and those two or more jobs
  // target.  A cover-shadow covers both men: the one in his shadow and the
  // one he presses when the ball gets there.
  coverage(state) {
    const count = new Map();
    for (const j of state.jobs || []) {
      // A straddle pair covers its man once (counted on the lower number).
      if (j.kind === 'straddle' && j.partner_position_id != null && Number(j.partner_position_id) < Number(j.position_id)) continue;
      const t = new Set([j.target_a]);
      if ((j.kind === 'hold_between' || j.kind === 'cover_shadow') && j.target_b != null) t.add(j.target_b);
      for (const n of t) count.set(Number(n), (count.get(Number(n)) || 0) + 1);
    }
    const nums = (state.opponents || []).map(o => Number(o.number)).sort((x, y) => x - y);
    return {
      free: nums.filter(n => !count.has(n)),
      doubled: nums.filter(n => (count.get(n) || 0) > 1),
    };
  },

  lerp(a, b, t) { return { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t }; },
};

window.TacticGeometry = TacticGeometry;
