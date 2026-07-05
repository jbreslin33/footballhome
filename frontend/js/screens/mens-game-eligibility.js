// MensGameEligibilityScreen — Projected game-day lineups for the planned
// 35-player APSL and 35-player Liga 1 rosters.  Liga 2 is a placeholder
// target (0) — not fielded this season.
//
// ── Match-day rules (baked in, league-specific) ─────────────────────
//   APSL   — 11 starters + 9-man bench = 20 dressed cap · 7 subs allowed
//            (2 dressed but can't play) · pro-sub rules, no re-entry.
//   Liga 1 — 11 starters + 7-man bench = 18 dressed cap (internal) ·
//            rolling subs, no re-entry restriction.
//
// ── Starter selection policy (user directive 2026-07-03) ────────────
//   1. APSL starters (11) come from the APSL pool FIRST, at ANY
//      attendance tier — even an APSL player with 0-of-last-5 practices
//      is preferred over a Liga 1 player.  Tier order within APSL:
//      starter-eligible → next-in-line → unselected.
//   2. If APSL doesn't have 11 available bodies, Liga 1 backfills starter
//      slots (starter-eligible → next → unselected).
//   3. APSL bench (9) is filled from APSL leftover first, then Liga 1
//      call-ups.  "All Liga 1 players are technically call-up eligible."
//   4. Liga 1 gets whoever's left after APSL takes.
//
// ── Availability model ──────────────────────────────────────────────
//   • Roster pool per team = min(assigned, target).  Surplus doesn't
//     create slots (35 is the cap).
//   • Each player is Bernoulli(p_avail) independent to show up on game
//     day; p_avail defaults to 66.7% and already absorbs typical
//     injuries / illness / travel / work.  Optional injury-surge knob
//     stacks multiplicatively.
//   • Attendance-tier split (typical adult mens amateur team, all knobs):
//        starter-eligible (≥2 of last 5) — 55%
//        next-in-line     (=1 of last 5) — 25%
//        unselected       (=0 of last 5) — 20%
//   • Expected count in tier × available = n · tier_frac · p_eff, with
//     Binomial σ = √(n·q·(1−q)), q = tier_frac · p_eff.
//   • User directive: do NOT read historical practice / RSVP / match
//     data.  It's corrupted from GM↔player linkage gaps.  All knobs
//     are pure assumptions until data is trusted.
//
// This screen is READ-ONLY analytics — no writes.
class MensGameEligibilityScreen extends Screen {

  // outStarters/outBench = 10/8 (APSL) and 10/6 (Liga 1) — the outfield
  // portion of each lineup.  Each match dresses 1 GK starter + 1 GK bench.
  // Keeper count is per-team.  All keepers are eligible for the APSL GK
  // slot (Liga 1 keepers can play up); only Liga 1 keepers may take the
  // Liga 1 GK slot (no play-down).
  //
  // Keeper allocation (2026-07-04): 1 APSL-only keeper + 3 Liga 1 keepers
  // = 4 total.  Skew to Liga 1 keeps flexibility; all 4 eligible for APSL.
  static RULES = {
    apsl:  { starters: 11, benchSize: 9, subsMax: 7,   dressedCap: 20, playable: 18,
             outStarters: 10, outBench: 8, keepers: 1,
             subMode: 'Pro subs · no re-entry · 2 dressed can\'t play' },
    liga1: { starters: 11, benchSize: 7, subsMax: null, dressedCap: 18, playable: null,
             outStarters: 10, outBench: 6, keepers: 3,
             subMode: 'Rolling subs · 18-dressed internal cap' },
    liga2: { starters: null, benchSize: 0, subsMax: null, dressedCap: 0, playable: null,
             outStarters: 0, outBench: 0, keepers: 0,
             subMode: 'Not fielded this season' },
  };

  // Star-bar visual per attendance tier.  Practices attended:
  //   starter-eligible (≥2 of last 5) → shown as ★★★ (guessing 3)
  //   next-in-line     (=1 of last 5) → ★
  //   unselected       (=0 of last 5) → · (dot)
  static TIER_META = {
    starter: { code: 'S', label: 'starter-eligible', practices: '2–5', stars: '★★★', color: '#16a34a' },
    next:    { code: 'N', label: 'next-in-line',     practices: '1',   stars: '★',   color: '#f59e0b' },
    zero:    { code: 'U', label: 'unselected',       practices: '0',   stars: '·',   color: '#94a3b8' },
    keeper:  { code: 'K', label: 'keeper',           practices: 'GK',  stars: '🧤',   color: '#2563eb' },
  };

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎯 Mens Game-Day Analytics</h1>
        <p class="subtitle">Projected APSL &amp; Liga 1 lineups + attendance-tier breakdown</p>
      </div>

      <div style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;">

        <div id="mge-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">
          Loading roster…
        </div>
        <div id="mge-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>

        <div id="mge-body" style="display:none;">

          <!-- Rules callout -->
          <div style="margin-bottom: var(--space-3); padding: var(--space-3);
               border-radius: var(--radius-md); background: var(--bg-secondary);
               border-left: 4px solid #2563eb;">
            <div style="font-weight:600; margin-bottom: var(--space-1);">
              ⚖️ Rules &amp; policy
            </div>
            <ul style="margin: var(--space-1) 0 0 var(--space-4); padding:0;
                       opacity:0.9; font-size: 0.9rem; line-height: 1.5;">
              <li><b>APSL match-day</b>: 11 start (1 GK + 10 outfield) + 9 bench (1 GK + 8 outfield) = 20 dressed cap · 7 subs playable, 2 don't play · no re-entry.</li>
              <li><b>Liga 1 match-day</b>: 11 start (1 GK + 10 outfield) + 7 bench (1 GK + 6 outfield) = 18 dressed cap · rolling subs.</li>
              <li><b>Keepers</b>: recruited separately (see knobs). All keepers are eligible for the APSL GK slot (play-up allowed); Liga 1 GK slots only from Liga 1 keepers. Keepers <b>may dress for both</b> APSL and Liga 1 on the same matchday.</li>
              <li><b>Outfield players</b> can only dress for one team per matchday — a Liga 1 outfielder called up to APSL is out of the Liga 1 pool that day.</li>
              <li><b>Starter selection</b>: APSL outfield players (any tier) start APSL before any Liga 1 call-up. Even a 0-of-5 APSL player beats a 2-of-5 Liga 1 player for a starter slot.</li>
              <li><b>Liga 1 fills APSL bench</b>: after APSL fills its own 20 slots, Liga 1 call-ups take remaining bench slots — all Liga 1 players are call-up eligible regardless of tier.</li>
              <li><b>Attendance tiers</b> (outfield only): ≥2 of last 5 = starter-eligible (★★★), =1 = next-in-line (★), =0 = unselected (·). Tier is a preference within a team, not a hard gate. Keepers are specialist role, no tier competition.</li>
              <li><b>Permanent promotions/demotions</b> happen on the Mens Roster screen — reassign a player and the projection updates automatically.</li>
            </ul>
          </div>

          <!-- Knobs: per-team assumptions (APSL is a higher-commitment tier
               than Liga 1, so each has its own dials). -->
          <div style="margin-bottom: var(--space-3); display:grid;
               grid-template-columns: 1fr 1fr; gap: var(--space-3);">
            ${this._knobPanelHtml('apsl',  '🏆 APSL assumptions',   '#dc2626', { field: 34, keepers: 1, avail: 70, inj: 0, elig: 60, nxt: 25 })}
            ${this._knobPanelHtml('liga1', '⚽ Liga 1 assumptions', '#7c3aed', { field: 32, keepers: 3, avail: 60, inj: 0, elig: 45, nxt: 25 })}
          </div>

          <!-- Two-column projection: APSL left, Liga 1 right -->
          <div id="mge-cards" style="display:grid;
               grid-template-columns: 1fr 1fr;
               gap: var(--space-3); margin-bottom: var(--space-3);"></div>

          <!-- Liga 2 footnote card -->
          <div id="mge-liga2" style="margin-bottom: var(--space-4);"></div>

          <!-- Sensitivity -->
          <div style="margin-bottom: var(--space-4); padding: var(--space-3);
               border-radius: var(--radius-md); background: var(--bg-secondary);
               border: 1px solid var(--color-border);">
            <div style="font-weight:600; margin-bottom: var(--space-2);">
              📈 Sensitivity — projected STARTERS filled at different availability rates
            </div>
            <div style="overflow-x:auto;">
              <table id="mge-sens" style="width:100%; border-collapse: collapse; font-size: 0.9rem;">
                <thead>
                  <tr>
                    <th style="text-align:left;  padding: var(--space-2); border-bottom:1px solid var(--color-border);">Team</th>
                    <th style="text-align:right; padding: var(--space-2); border-bottom:1px solid var(--color-border);">50%</th>
                    <th style="text-align:right; padding: var(--space-2); border-bottom:1px solid var(--color-border);">60%</th>
                    <th style="text-align:right; padding: var(--space-2); border-bottom:1px solid var(--color-border);">66.7%</th>
                    <th style="text-align:right; padding: var(--space-2); border-bottom:1px solid var(--color-border);">75%</th>
                    <th style="text-align:right; padding: var(--space-2); border-bottom:1px solid var(--color-border);">85%</th>
                  </tr>
                </thead>
                <tbody></tbody>
              </table>
              <div style="opacity:0.6; font-size:0.8rem; margin-top: var(--space-2);">
                Cell shows starter slots filled after priority-selection. ⚠ = below 11.
              </div>
            </div>
          </div>

        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId   = params?.clubId;
    this.clubName = params?.clubName;
    this._data    = null;

    const backBtn = this.element.querySelector('.back-btn');
    if (backBtn) {
      backBtn.onclick = () => this.navigation.goTo('admin-club', {
        clubId: this.clubId, clubName: this.clubName,
      });
    }

    ['apsl', 'liga1'].forEach(prefix => {
      ['field', 'keepers', 'avail', 'inj', 'elig', 'nxt'].forEach(key => {
        const el = this.find('#mge-' + prefix + '-' + key);
        if (el) el.addEventListener('input', () => this._recompute());
      });
    });

    this._load();
  }

  async _load() {
    // No data fetch — this screen is a pure PROJECTION of a fully-recruited
    // 35+35 roster.  Do NOT read our current roster or attendance data;
    // that data is not yet trusted (GM↔player linkage is incomplete).
    this.find('#mge-loading').style.display = 'none';
    this.find('#mge-body').style.display    = 'block';
    this._recompute();
  }

  // ── Math ────────────────────────────────────────────────────────────
  _stdNormalCdf(z) {
    const sign = z < 0 ? -1 : 1;
    const x = Math.abs(z) / Math.SQRT2;
    const t = 1 / (1 + 0.3275911 * x);
    const y = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * Math.exp(-x * x);
    return 0.5 * (1 + sign * y);
  }

  _getKnobs() {
    const one = (prefix) => {
      const elig = Number(this.find('#mge-' + prefix + '-elig').value) / 100;
      let   nxt  = Number(this.find('#mge-' + prefix + '-nxt').value)  / 100;
      if (elig + nxt > 1) nxt = Math.max(0, 1 - elig);
      const keepers = Math.max(0, Number(this.find('#mge-' + prefix + '-keepers').value));
      let   field   = Math.max(0, Number(this.find('#mge-' + prefix + '-field').value));
      // Enforce field + keepers ≤ 35 (the roster target).  If the user
      // pushed one slider past the cap, clamp field silently.
      if (field + keepers > 35) field = Math.max(0, 35 - keepers);
      return {
        p:       Number(this.find('#mge-' + prefix + '-avail').value) / 100,
        inj:     Number(this.find('#mge-' + prefix + '-inj').value)   / 100,
        keepers, field,
        signed:  field + keepers,
        elig, nxt,
        zero: Math.max(0, 1 - elig - nxt),
      };
    };
    return { apsl: one('apsl'), liga1: one('liga1') };
  }

  // HTML for a per-team knob panel (called from render()).
  _knobPanelHtml(prefix, title, borderColor, defaults) {
    return `
      <div style="padding: var(--space-3); border-radius: var(--radius-md);
           background: var(--bg-secondary); border: 1px solid var(--color-border);
           border-top: 4px solid ${borderColor};">
        <div style="font-weight:600; margin-bottom: var(--space-2);">${title}</div>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: var(--space-2);">
          <label style="display:flex; flex-direction:column; gap: 2px; grid-column: 1 / -1;">
            <span style="font-size:0.85rem;">Field players signed: <b id="mge-${prefix}-field-lbl">${defaults.field}</b></span>
            <input id="mge-${prefix}-field" type="range" min="0" max="35" step="1" value="${defaults.field}">
            <span style="font-size:0.7rem; opacity:0.6;">Outfield roster count (excludes keepers).</span>
          </label>
          <label style="display:flex; flex-direction:column; gap: 2px; grid-column: 1 / -1;">
            <span style="font-size:0.85rem;">Keepers signed: <b id="mge-${prefix}-keepers-lbl">${defaults.keepers}</b></span>
            <input id="mge-${prefix}-keepers" type="range" min="0" max="5" step="1" value="${defaults.keepers}">
            <span style="font-size:0.7rem; opacity:0.6;">Field + keepers capped at 35. Liga 1 keepers can play up to APSL GK; APSL keepers can't play down. Keepers may dress for both teams same matchday.</span>
          </label>
          <label style="display:flex; flex-direction:column; gap: 2px;">
            <span style="font-size:0.85rem;">Availability: <b id="mge-${prefix}-avail-lbl">${defaults.avail}%</b></span>
            <input id="mge-${prefix}-avail" type="range" min="30" max="95" step="1" value="${defaults.avail}">
            <span style="font-size:0.7rem; opacity:0.6;">P(signed-up player shows up).</span>
          </label>
          <label style="display:flex; flex-direction:column; gap: 2px;">
            <span style="font-size:0.85rem;">Injury surge: <b id="mge-${prefix}-inj-lbl">${defaults.inj}%</b></span>
            <input id="mge-${prefix}-inj" type="range" min="0" max="40" step="1" value="${defaults.inj}">
            <span style="font-size:0.7rem; opacity:0.6;">Leave 0 unless modelling a wave.</span>
          </label>
          <label style="display:flex; flex-direction:column; gap: 2px;">
            <span style="font-size:0.85rem;">Starter-elig (≥2/5): <b id="mge-${prefix}-elig-lbl">${defaults.elig}%</b></span>
            <input id="mge-${prefix}-elig" type="range" min="10" max="100" step="1" value="${defaults.elig}">
            <span style="font-size:0.7rem; opacity:0.6;">Share hitting ≥2 practices.</span>
          </label>
          <label style="display:flex; flex-direction:column; gap: 2px;">
            <span style="font-size:0.85rem;">Next-in-line (=1/5): <b id="mge-${prefix}-nxt-lbl">${defaults.nxt}%</b></span>
            <input id="mge-${prefix}-nxt" type="range" min="0" max="60" step="1" value="${defaults.nxt}">
            <span style="font-size:0.7rem; opacity:0.6;">Remainder = unselected.</span>
          </label>
        </div>
      </div>
    `;
  }

  // Hardcoded team definitions — no live roster data used.  Match-day
  // projections are pure assumptions until our player data is trusted.
  _teamStats(teamId, fallbackTarget) {
    const R = MensGameEligibilityScreen.RULES;
    const defs = {
      35:  { label: 'APSL',   color: '#dc2626', target: 35, keepers: R.apsl.keepers  },
      120: { label: 'Liga 1', color: '#7c3aed', target: 35, keepers: R.liga1.keepers },
      121: { label: 'Liga 2', color: '#94a3b8', target: 0,  keepers: 0 },
    };
    const d = defs[teamId] || { label: `Team ${teamId}`, color: '#2563eb', target: fallbackTarget, keepers: 0 };
    return { teamId, ...d };
  }

  // Expected available count in each tier × available for a team.
  // `k.field` is outfield sign-ups (0..35); `k.keepers` is keeper
  // sign-ups (0..5); the two combined are capped at 35 upstream.
  // Attendance tiers apply to OUTFIELD only.
  _project(team, k) {
    const nGK  = Math.max(0, k.keepers);
    const nOut = Math.max(0, k.field);
    const effP = k.p * (1 - k.inj);
    const mk   = (n, frac) => {
      const q = effP * frac;
      return {
        mean: n * q,
        std:  Math.sqrt(Math.max(0, n * q * (1 - q))),
      };
    };
    return {
      nOut, nGK, signed: nOut + nGK, effP,
      starter: mk(nOut, k.elig),
      next:    mk(nOut, k.nxt),
      zero:    mk(nOut, k.zero),
      keeper:  {
        mean: nGK * effP,
        std:  Math.sqrt(Math.max(0, nGK * effP * (1 - effP))),
      },
    };
  }

  // Round non-negative real-valued shares to integer counts summing to `total`
  // using largest-remainder (Hamilton) method.  Preserves ordering priorities.
  _roundToTotal(vals, total) {
    // vals: [{name, value}]
    if (total <= 0) return vals.map(v => ({ ...v, count: 0 }));
    const sum = vals.reduce((a, v) => a + v.value, 0);
    if (sum <= 0) return vals.map(v => ({ ...v, count: 0 }));
    // Scale so sum matches total (if sum was less than total, cap; if more, we still
    // proportional-allocate but cap each bucket at its raw value later).
    const scale = total / sum;
    const raw   = vals.map(v => ({ ...v, scaled: v.value * scale }));
    const floors = raw.map(v => ({ ...v, count: Math.floor(v.scaled), frac: v.scaled - Math.floor(v.scaled) }));
    let remainder = Math.round(total - floors.reduce((a, v) => a + v.count, 0));
    // Distribute remainder to largest fractional parts.
    const order = floors.map((v, i) => ({ i, frac: v.frac })).sort((a, b) => b.frac - a.frac);
    for (let j = 0; j < order.length && remainder > 0; j++) { floors[order[j].i].count += 1; remainder--; }
    // Preserve any extra fields on the input objects (source, tier, …).
    return floors.map(f => { const { scaled, frac, ...rest } = f; return rest; });
  }

  // Priority-fill selection.  Returns the lineup slot allocation for both
  // teams.  Slot 1 of each 11-man Starting XI is the GK; slot 12 (first
  // bench slot) is the GK bench.  Remaining slots are outfield.
  //
  // Priority order for each draw:
  //   APSL slots ← APSL players (any tier) → Liga 1 call-ups
  //   Liga 1 slots ← Liga 1 players only (no play-down from APSL)
  //   APSL GK slots ← APSL keeper(s) → Liga 1 keepers (all eligible)
  //   Liga 1 GK slots ← Liga 1 keepers only
  _selectLineup(apsl, liga1, k) {
    const R = MensGameEligibilityScreen.RULES;
    const pA = this._project(apsl,  k.apsl);
    const pL = this._project(liga1, k.liga1);

    // Outfield priority pool (attendance-tiered).  SHARED across teams —
    // if APSL takes a Liga 1 outfield player, they can't also start for
    // Liga 1 that matchday.
    const outPools = [
      { source: 'APSL',   tier: 'starter', remaining: pA.starter.mean },
      { source: 'APSL',   tier: 'next',    remaining: pA.next.mean    },
      { source: 'APSL',   tier: 'zero',    remaining: pA.zero.mean    },
      { source: 'Liga 1', tier: 'starter', remaining: pL.starter.mean },
      { source: 'Liga 1', tier: 'next',    remaining: pL.next.mean    },
      { source: 'Liga 1', tier: 'zero',    remaining: pL.zero.mean    },
    ];

    // Keepers are exempt from the "don't start on both" rule — they're
    // specialists who can dress for BOTH matchdays.  Give APSL and Liga 1
    // independent (non-depleting) views of the keeper pools.
    const gkPoolsApsl = [
      { source: 'APSL',   tier: 'keeper', remaining: pA.keeper.mean },
      { source: 'Liga 1', tier: 'keeper', remaining: pL.keeper.mean },
    ];
    const gkPoolsLiga1 = [
      { source: 'Liga 1', tier: 'keeper', remaining: pL.keeper.mean },
    ];

    // Draw `need` bodies from `pools` in priority order, optionally
    // restricted to a single source (used for Liga 1 draws — no play-down).
    // Modifies pools[].remaining in place.
    const drawFrom = (pools, need, sourceOnly) => {
      const taken = pools.map(p => ({ ...p, taken: 0 }));
      for (let i = 0; i < taken.length && need > 0; i++) {
        if (sourceOnly && taken[i].source !== sourceOnly) continue;
        const t = Math.min(need, taken[i].remaining);
        taken[i].taken       = t;
        pools[i].remaining  -= t;
        need                -= t;
      }
      return { taken, shortage: Math.max(0, need) };
    };

    // Order matters: APSL takes first (GK + outfield), then Liga 1.
    // Keeper draws use per-team pools (see above) so a keeper can dress
    // for both APSL and Liga 1 same matchday.
    const apslGkStart   = drawFrom(gkPoolsApsl,  1);
    const apslOutStart  = drawFrom(outPools, R.apsl.outStarters);
    const apslGkBench   = drawFrom(gkPoolsApsl,  1);
    const apslOutBench  = drawFrom(outPools, R.apsl.outBench);
    const liga1GkStart  = drawFrom(gkPoolsLiga1, 1);
    const liga1OutStart = drawFrom(outPools, R.liga1.outStarters, 'Liga 1');
    const liga1GkBench  = drawFrom(gkPoolsLiga1, 1);
    const liga1OutBench = drawFrom(outPools, R.liga1.outBench,   'Liga 1');

    // Convert a draw into integer slot rows.
    const buildRows = (draw, size) => {
      const nonzero = draw.taken.filter(e => e.taken > 0.001);
      const poolSum = nonzero.reduce((a, e) => a + e.taken, 0);
      const target  = Math.min(size, Math.round(poolSum));
      const rounded = this._roundToTotal(
        nonzero.map(e => ({ name: `${e.source}|${e.tier}`, value: e.taken, source: e.source, tier: e.tier })),
        target
      );
      const rows = [];
      for (const r of rounded) {
        for (let i = 0; i < r.count; i++) rows.push({ source: r.source, tier: r.tier });
      }
      while (rows.length < size) rows.push({ source: null, tier: null });
      return rows;
    };

    return {
      apsl:  {
        // Slot 1 = GK, slots 2..11 = outfield starters.
        starters: [...buildRows(apslGkStart,  1),
                   ...buildRows(apslOutStart, R.apsl.outStarters)],
        // Slot 12 = GK bench, slots 13..20 = outfield bench.
        bench:    [...buildRows(apslGkBench,  1),
                   ...buildRows(apslOutBench, R.apsl.outBench)],
        shortageStart: apslGkStart.shortage + apslOutStart.shortage,
        shortageBench: apslGkBench.shortage + apslOutBench.shortage,
      },
      liga1: {
        starters: [...buildRows(liga1GkStart,  1),
                   ...buildRows(liga1OutStart, R.liga1.outStarters)],
        bench:    [...buildRows(liga1GkBench,  1),
                   ...buildRows(liga1OutBench, R.liga1.outBench)],
        shortageStart: liga1GkStart.shortage + liga1OutStart.shortage,
        shortageBench: liga1GkBench.shortage + liga1OutBench.shortage,
      },
      pApsl: pA, pLiga1: pL,
      // Snapshot of pool state after every draw — used to compute
      // alternates.  APSL alternates come from `gkPoolsApsl` (APSL-view
      // keeper leftovers) + outPools APSL leftovers.  Liga 1 alternates
      // come from `gkPoolsLiga1` (Liga 1-view) + outPools Liga 1 leftovers.
      poolsRemainingApsl:  [...gkPoolsApsl,  ...outPools].map(p => ({ ...p })),
      poolsRemainingLiga1: [...gkPoolsLiga1, ...outPools].map(p => ({ ...p })),
    };
  }

  // P(Binomial(n, p) ≥ k) via normal approx with continuity correction.
  _pAtLeast(k, n, p) {
    if (k <= 0)  return 1;
    if (k > n)   return 0;
    if (p <= 0)  return 0;
    if (p >= 1)  return 1;
    const mu    = n * p;
    const sigma = Math.sqrt(Math.max(1e-9, n * p * (1 - p)));
    const z     = (k - 0.5 - mu) / sigma;
    return 1 - this._stdNormalCdf(z);
  }

  // Build the alternate-slot list for a team.  Alternates are players who
  // show up but don't dress (over the cap).  Slot number is absolute
  // (dressedCap+1 … target).  Each row has source, tier, and P(filled).
  _buildAlternates(teamSrc, target, dressedCap, poolsRemaining, pEff) {
    const remaining = poolsRemaining.filter(p => p.source === teamSrc);
    const count     = target - dressedCap;
    if (count <= 0) return [];
    const nonzero   = remaining.filter(p => p.remaining > 0.001);
    const poolSum   = nonzero.reduce((a, r) => a + r.remaining, 0);
    const numFilled = Math.min(count, Math.round(poolSum));
    const rounded   = this._roundToTotal(
      nonzero.map(r => ({ name: r.tier, value: r.remaining, source: r.source, tier: r.tier })),
      numFilled
    );
    const rows = [];
    for (const r of rounded) {
      for (let i = 0; i < r.count; i++) rows.push({ source: r.source, tier: r.tier });
    }
    while (rows.length < count) rows.push({ source: null, tier: null });
    return rows.map((r, i) => ({
      ...r,
      absSlot:  dressedCap + i + 1,
      pFilled:  this._pAtLeast(dressedCap + i + 1, target, pEff),
    }));
  }

  _recompute() {
    const k = this._getKnobs();

    // Per-team label updates.  If the field/keeper combo was clamped by
    // _getKnobs, snap the field slider back to the clamped value so the
    // UI stays honest.
    ['apsl', 'liga1'].forEach(prefix => {
      const kt = k[prefix];
      const fieldEl = this.find('#mge-' + prefix + '-field');
      if (fieldEl && Number(fieldEl.value) !== kt.field) fieldEl.value = kt.field;
      this.find('#mge-' + prefix + '-field-lbl').textContent   = kt.field + '';
      this.find('#mge-' + prefix + '-keepers-lbl').textContent = kt.keepers + '';
      this.find('#mge-' + prefix + '-avail-lbl').textContent   = (kt.p    * 100).toFixed(0) + '%';
      this.find('#mge-' + prefix + '-inj-lbl').textContent     = (kt.inj  * 100).toFixed(0) + '%';
      this.find('#mge-' + prefix + '-elig-lbl').textContent    = (kt.elig * 100).toFixed(0) + '%';
      this.find('#mge-' + prefix + '-nxt-lbl').textContent     = (kt.nxt  * 100).toFixed(0) + '% · unsel ' + (kt.zero * 100).toFixed(0) + '%';
    });

    const R = MensGameEligibilityScreen.RULES;
    const apsl  = this._teamStats(35,  35);
    const liga1 = this._teamStats(120, 35);
    const liga2 = this._teamStats(121, 0);

    const sel = this._selectLineup(apsl, liga1, k);

    // Coverage per team.
    const apslCov = this._coverage({
      starters: sel.apsl.starters,
      bench:    sel.apsl.bench,
      shortStart: sel.apsl.shortageStart,
      rules:    R.apsl,
    });
    const liga1Cov = this._coverage({
      starters: sel.liga1.starters,
      bench:    sel.liga1.bench,
      shortStart: sel.liga1.shortageStart,
      rules:    R.liga1,
    });

    // Two-column APSL | Liga 1
    const apslPeff  = k.apsl.p  * (1 - k.apsl.inj);
    const liga1Peff = k.liga1.p * (1 - k.liga1.inj);
    // Alternate slot range is bounded by signed-up count (can't have more
    // people show up than have signed up).
    const apslAlts  = this._buildAlternates('APSL',   k.apsl.signed,  R.apsl.dressedCap,  sel.poolsRemainingApsl,  apslPeff);
    const liga1Alts = this._buildAlternates('Liga 1', k.liga1.signed, R.liga1.dressedCap, sel.poolsRemainingLiga1, liga1Peff);

    const cards = this.find('#mge-cards');
    cards.innerHTML = [
      this._renderCard({ icon:'🏆', team:apsl,  rules:R.apsl,  lineup:sel.apsl,  coverage:apslCov,  alternates: apslAlts,  signed: k.apsl.signed,  field: k.apsl.field,  keepers: k.apsl.keepers,  otherLabel:'Liga 1' }),
      this._renderCard({ icon:'⚽', team:liga1, rules:R.liga1, lineup:sel.liga1, coverage:liga1Cov, alternates: liga1Alts, signed: k.liga1.signed, field: k.liga1.field, keepers: k.liga1.keepers, otherLabel:'APSL'   }),
    ].join('');

    // Liga 2 footnote
    this.find('#mge-liga2').innerHTML = `
      <div style="padding: var(--space-2) var(--space-3); border-radius: var(--radius-sm);
           background: var(--bg-secondary); border: 1px solid var(--color-border);
           opacity: 0.7; font-size: 0.9rem;">
        ⚽ <b>${liga2.label}</b> — not fielded this season.
      </div>
    `;

    // Sensitivity — starter slots filled at each availability rate, holding
    // the other team's assumptions constant.
    const rates = [0.50, 0.60, 0.667, 0.75, 0.85];
    const tbody = this.find('#mge-sens tbody');
    tbody.innerHTML = [
      { label: apsl.label,  side: 'apsl'  },
      { label: liga1.label, side: 'liga1' },
    ].map(row => {
      const cells = rates.map(rate => {
        const k2 = {
          apsl:  row.side === 'apsl'  ? { ...k.apsl,  p: rate } : k.apsl,
          liga1: row.side === 'liga1' ? { ...k.liga1, p: rate } : k.liga1,
        };
        const sel2 = this._selectLineup(apsl, liga1, k2);
        const filled = sel2[row.side].starters.filter(s => s.source).length;
        const short = filled < R.apsl.starters;
        return `<td style="text-align:right; padding: var(--space-2);
                border-bottom:1px solid var(--color-border);
                color:${short ? 'var(--color-error)' : 'inherit'};">
                ${filled}${short ? ' ⚠' : ''}</td>`;
      }).join('');
      return `<tr>
        <td style="padding: var(--space-2); border-bottom:1px solid var(--color-border);">
          ${row.label}
        </td>${cells}
      </tr>`;
    }).join('');
  }

  // Coverage badges: starters covered + dressed cap covered.
  _coverage({ starters, bench, shortStart, rules }) {
    const filledStart  = starters.filter(s => s.source).length;
    const filledBench  = bench.filter(s => s.source).length;
    const filledDressed = filledStart + filledBench;
    const need = rules.starters;
    const cap  = rules.dressedCap;

    const lines = [];

    // Starters
    if (filledStart >= need && shortStart === 0) {
      lines.push({ icon: '✅', color: '#16a34a',
                   text: `${need} starters covered` });
    } else if (filledStart >= need) {
      // Filled by rounding but with mean-shortage — borderline.
      lines.push({ icon: '⚠️', color: '#f59e0b',
                   text: `${need} starters borderline` });
    } else {
      lines.push({ icon: '❌', color: '#dc2626',
                   text: `Short ${need - filledStart} of ${need} starters` });
    }

    // Dressed
    if (filledDressed >= cap) {
      lines.push({ icon: '✅', color: '#16a34a',
                   text: `${cap}-dressed cap filled` });
    } else if (filledDressed >= need) {
      lines.push({ icon: '⚠️', color: '#f59e0b',
                   text: `${filledDressed} / ${cap} dressed · still legal to play` });
    } else {
      lines.push({ icon: '❌', color: '#dc2626',
                   text: `Only ${filledDressed} dressed — cannot field` });
    }

    return { lines, subMode: rules.subMode };
  }

  _renderCard({ icon, team, rules, lineup, coverage, alternates, signed, field, keepers, otherLabel }) {

    // Group starters and bench by (source, tier) for the summary bar.
    const groupCounts = (rows) => {
      const g = {};
      rows.forEach(r => {
        if (!r.source) return;
        const key = `${r.source}|${r.tier}`;
        g[key] = (g[key] || 0) + 1;
      });
      return g;
    };
    const startGroups = groupCounts(lineup.starters);
    const benchGroups = groupCounts(lineup.bench);

    const renderGroups = (groups) => {
      const parts = Object.entries(groups).map(([k, v]) => {
        const [src, tier] = k.split('|');
        const meta = MensGameEligibilityScreen.TIER_META[tier];
        const badge = src === team.label.replace(/^[^\s]+\s/, '').split(' ')[0]
          ? '' : (src === 'APSL' || src === 'Liga 1' ? src : src);
        return `<span style="display:inline-block; padding: 2px 8px; margin: 2px;
                border-radius: 12px; font-size: 0.8rem;
                background: ${meta.color}22; color: ${meta.color};">
                ${v}× ${src} ${meta.stars}
                <span style="opacity:0.7;">${meta.practices}</span>
                </span>`;
      });
      return parts.join('') || '<span style="opacity:0.5; font-size:0.85rem;">— empty —</span>';
    };

    // Slot list — numbered 1..N.  For alternate rows (row.pFilled defined)
    // we show a P(filled) column on the right, colored by likelihood.
    const slotRow = (n, row) => {
      const pCol = (row.pFilled != null)
        ? (() => {
            const pct = Math.round(row.pFilled * 100);
            const col = pct >= 66 ? '#16a34a' : (pct >= 33 ? '#f59e0b' : '#dc2626');
            return `<span style="width: 3.5em; text-align:right; color:${col}; font-weight:600;">${pct}%</span>`;
          })()
        : '<span style="width: 3.5em;"></span>';
      if (!row.source) {
        return `<div style="display:flex; justify-content:space-between; align-items:center;
                padding: 2px 4px; opacity: 0.35; font-size:0.85rem;">
                <span style="width: 1.5em;">${n}</span>
                <span style="flex:1; text-align:center;">— unlikely to be needed —</span>
                ${pCol}</div>`;
      }
      const meta = MensGameEligibilityScreen.TIER_META[row.tier];
      const srcTag = row.source === 'Liga 1' ? '<span style="color:#7c3aed; font-weight:600;">L1</span>'
                                             : '<span style="color:#dc2626; font-weight:600;">A</span>';
      return `<div style="display:flex; justify-content:space-between; align-items:center;
              padding: 2px 4px; font-size:0.85rem;
              border-bottom: 1px dashed var(--color-border);">
              <span style="width: 1.5em; opacity:0.6;">${n}</span>
              <span style="width: 2em;">${srcTag}</span>
              <span style="flex:1; text-align:center; color:${meta.color};">${meta.stars}</span>
              <span style="width: 3em; text-align:right; opacity:0.7;">${meta.practices}</span>
              ${pCol}
              </div>`;
    };

    const startersHtml = lineup.starters.map((r, i) => slotRow(i + 1, r)).join('');
    const benchHtml    = lineup.bench.map((r, i) => slotRow(rules.starters + i + 1, r)).join('');
    const altsHtml     = (alternates || []).map(a => slotRow(a.absSlot, a)).join('');

    const covHtml = coverage ? `
      <div style="margin-top: var(--space-2); display:flex; flex-direction:column; gap: var(--space-1);">
        ${coverage.lines.map(l => `
          <div style="padding: var(--space-2); border-radius: var(--radius-sm);
               background:${l.color}22; color:${l.color}; font-weight:600; font-size:0.9rem;">
            ${l.icon} ${l.text}
          </div>`).join('')}
        <div style="opacity:0.6; font-size:0.75rem; text-align:center;">
          ${coverage.subMode}
        </div>
      </div>` : '';

    return `
      <div style="border:1px solid var(--color-border); border-radius: var(--radius-md);
           background: var(--bg-secondary); padding: var(--space-3);
           border-top: 4px solid ${team.color};">

        <div style="display:flex; align-items:center; justify-content:space-between;
             margin-bottom: var(--space-1); flex-wrap:wrap; gap: var(--space-1);">
          <div style="font-weight:700; font-size:1.05rem;">${icon} ${team.label}</div>
          <div style="opacity:0.7; font-size:0.8rem;">
            <b>${field}</b> field + <b>${keepers}</b> GK = <b>${signed}</b> / ${team.target}
            ${signed < team.target ? `<span style="color:#f59e0b;"> · ${team.target - signed} short</span>` : ''}
          </div>
        </div>

        <div style="opacity:0.6; font-size:0.75rem; margin-bottom: var(--space-2);">
          ${rules.starters} start (1 GK + ${rules.outStarters} outfield) · ${rules.benchSize}-man bench (1 GK + ${rules.outBench} outfield) · ${rules.dressedCap} dressed cap
        </div>

        <!-- Composition summary -->
        <div style="margin-bottom: var(--space-2);">
          <div style="font-weight:600; font-size:0.85rem; margin-bottom: 2px;">📋 Starters (${lineup.starters.filter(s=>s.source).length}/${rules.starters})</div>
          <div>${renderGroups(startGroups)}</div>
        </div>
        <div style="margin-bottom: var(--space-2);">
          <div style="font-weight:600; font-size:0.85rem; margin-bottom: 2px;">🪑 Bench (${lineup.bench.filter(s=>s.source).length}/${rules.benchSize})</div>
          <div>${renderGroups(benchGroups)}</div>
        </div>

        <!-- Slot-by-slot lineup with practice attendance -->
        <div style="margin-top: var(--space-2); padding: var(--space-2);
             border-radius: var(--radius-sm); background: var(--bg-primary);
             border: 1px solid var(--color-border);">
          <div style="display:flex; justify-content:space-between; font-size:0.75rem;
               opacity:0.6; padding: 2px 4px; border-bottom:1px solid var(--color-border);">
            <span style="width: 1.5em;">#</span>
            <span style="width: 2em;">Src</span>
            <span style="flex:1; text-align:center;">Tier</span>
            <span style="width: 3em; text-align:right;">Pract.</span>
            <span style="width: 3.5em; text-align:right;">P(fill)</span>
          </div>
          <div style="font-weight:600; font-size:0.75rem; opacity:0.7;
               margin-top: var(--space-1);">Starting XI</div>
          ${startersHtml}
          <div style="font-weight:600; font-size:0.75rem; opacity:0.7;
               margin-top: var(--space-1);">Bench</div>
          ${benchHtml}
          <div style="font-weight:600; font-size:0.75rem; opacity:0.7;
               margin-top: var(--space-1);">Alternates <span style="font-weight:400; opacity:0.7;">(show up but don't dress — chance slot is reached)</span></div>
          ${altsHtml}
        </div>

        ${covHtml}
      </div>
    `;
  }

  _stat(label, big, sub) {
    return `
      <div style="padding: var(--space-2); border-radius: var(--radius-sm);
           background: var(--bg-primary); border: 1px solid var(--color-border);">
        <div style="opacity:0.7; font-size:0.85rem;">${label}</div>
        <div style="font-size:1.3rem; font-weight:700;">${big}</div>
        <div style="opacity:0.7; font-size:0.85rem;">${sub}</div>
      </div>
    `;
  }

  _fmt(x) {
    if (!Number.isFinite(x)) return '—';
    return (Math.round(x * 10) / 10).toFixed(1);
  }
}
