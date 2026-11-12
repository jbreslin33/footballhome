// FinesCollected — fines money that has come in, by calendar month (mig 1294).
//
// Owner 2026-11-12: "i think we need tuitions + fines = total. with all laid
// out" / "for total collected and this month and avg" / "i guess we could do
// just fines on fine screen".  #tuition splits its LA money into Tuition +
// Fines = Total; #fines shows the Fines part alone.
//
// LeagueApps payments carry no description, so the fines part is worked out
// from GET /api/fines: a period's fines count as collected once they are on
// the player's LA bill (posting 'posted', or 'drift' = what was put on) AND
// his dues balance is $0 (the same rule #fines uses for ✅ Paid).  The money
// lands in the month the charge went on LA (posting.postedOn) — first-Friday
// bills are run that day.  A player still behind on dues has his posted
// fines counted as owed, not collected, until he is clear.
class FinesCollected {
  static CODE_KEY = { M: 'mens', W: 'womens', B: 'boys', G: 'girls' };

  // board = GET /api/fines payload; keys = section keys ('mens', …) or null
  // for every section.  → { 'YYYY-MM': amount }
  static byMonth(board, keys) {
    const out = {};
    for (const p of ((board && board.people) || [])) {
      if (keys && !keys.includes(FinesCollected.CODE_KEY[p.section_code])) continue;
      if (Number(p.la_balance) > 0.005) continue;
      for (const m of (p.months || [])) {
        const ps = m.posting;
        if (!ps || !ps.postedOn || (ps.status !== 'posted' && ps.status !== 'drift')) continue;
        const amt = Number(ps.postedAmount) || 0;
        if (amt <= 0) continue;
        const ym = String(ps.postedOn).slice(0, 7);
        out[ym] = (out[ym] || 0) + amt;
      }
    }
    return out;
  }

  // This calendar month, club time — 'YYYY-MM'.
  static nowKey() {
    const parts = new Intl.DateTimeFormat('en-US', { timeZone: 'America/New_York', year: 'numeric', month: '2-digit' }).formatToParts(new Date());
    return `${parts.find(p => p.type === 'year').value}-${parts.find(p => p.type === 'month').value}`;
  }

  // → { collected, thisMonth, avg, months }.  months = the denominator for
  // the average: given (so #tuition's Tuition + Fines = Total holds), else
  // from the first month with fines collected to now, inclusive.
  static totals(byMonth, months) {
    const keys = Object.keys(byMonth || {}).sort();
    const collected = keys.reduce((a, k) => a + byMonth[k], 0);
    const now = FinesCollected.nowKey();
    let n = Number(months) || 0;
    if (!n && keys.length) {
      const [y0, m0] = keys[0].split('-').map(Number), [y1, m1] = now.split('-').map(Number);
      n = Math.max(1, (y1 - y0) * 12 + (m1 - m0) + 1);
    }
    return { collected, thisMonth: byMonth[now] || 0, avg: n ? collected / n : 0, months: n };
  }
}
window.FinesCollected = FinesCollected;
