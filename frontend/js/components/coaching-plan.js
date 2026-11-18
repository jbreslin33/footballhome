// CoachingPlanTable — 🧑‍🏫 every paid coach's hours and money for a budget
// year, per season (migration 1491; owner 2026-11-18 "show me table with all
// coaches hours for the current year" + "stored in db as normalized … oop").
//
// Display only: the numbers come from GET /api/finances/coaching
// (models/CoachingPlan.cpp — practice slots, early arrival, games), never
// worked out here.  Words: message_templates kind finances, tiers cp_*.
//
//   const t = new CoachingPlanTable({ auth, copy, esc, money, onLoaded })
//   t.html(year)   the table if loaded, else a "Loading…" line (and loads it;
//                  onLoaded() runs when it lands so the screen repaints)
(function (global) {
  'use strict';

  class CoachingPlanTable {
    constructor({ auth, copy, esc, money, onLoaded }) {
      this.auth = auth;
      this.copy = copy;          // (tier, tokens) → DB words or ''
      this.esc = esc;
      this.money = money;
      this.onLoaded = onLoaded;
      this.byYear = {};          // year → json | { error }
      this.loading = {};
    }

    word(tier, fb, tokens) { return this.copy(tier, tokens) || fb; }

    html(year) {
      const d = this.byYear[year];
      if (!d) { this.load(year); return `<div class="fn-note">${this.esc(this.word('cp_loading', 'Loading coaches…'))}</div>`; }
      if (d.error) return `<div class="error-message">${this.esc(d.error)}</div>`;
      return this.table(d);
    }

    async load(year) {
      if (this.loading[year]) return;
      this.loading[year] = true;
      try {
        const res = await this.auth.fetch(`/api/finances/coaching?year=${encodeURIComponent(year)}`);
        const body = await res.json().catch(() => ({}));
        this.byYear[year] = res.ok ? body : { error: body.error || body.message || `HTTP ${res.status}` };
      } catch (e) {
        this.byYear[year] = { error: String(e && e.message || e) };
      } finally {
        this.loading[year] = false;
        if (this.onLoaded) this.onLoaded();
      }
    }

    // One row per coach: each season's hours (practice + early + games), the
    // year's hours and money.  The cell's title spells out the split.
    table(d) {
      const esc = this.esc, M0 = this.money;
      const seasons = d.seasons || [], coaches = d.coaches || [];
      if (!coaches.length) return `<div class="fn-note">${esc(this.word('cp_none', 'No paid coaching planned.'))}</div>`;
      const h = (v) => (Math.round(Number(v || 0) * 100) / 100).toString();
      const parts = (s) => [['practice', this.word('cp_practice', 'Practice')], ['arrival', this.word('cp_arrival', 'Early arrival')], ['game', this.word('cp_game', 'Games')]]
        .filter(([k]) => Number(s[k] || 0) > 0).map(([k, l]) => `${l} ${h(s[k])} h`).join(' · ');
      const head = `<tr><th style="text-align:left;">${esc(this.word('cp_coach', 'Coach'))}</th>${seasons.map(s => `<th>${esc(s.label)}</th>`).join('')}
        <th>${esc(this.word('cp_hours', 'Hours'))}</th><th>${esc(this.word('cp_amount', 'Pay'))}</th></tr>`;
      const tot = { hours: 0, amount: 0, by: {} };
      const rows = coaches.map(c => {
        tot.hours += Number(c.hours || 0); tot.amount += Number(c.amount || 0);
        const cells = seasons.map(s => {
          const x = (c.by_season || {})[s.code] || {};
          tot.by[s.code] = (tot.by[s.code] || 0) + Number(x.hours || 0);
          return `<td title="${esc(parts(x))}">${Number(x.hours || 0) > 0 ? `${h(x.hours)} h` : '–'}</td>`;
        }).join('');
        return `<tr class="item"><td style="text-align:left;">${esc(c.name)} <span class="fn-tick">${esc(M0(c.rate))}/h</span></td>${cells}
          <td style="font-weight:700;">${h(c.hours)} h</td><td class="fn-out" style="font-weight:700;">${M0(c.amount)}</td></tr>`;
      }).join('');
      const sum = `<tr class="sum"><td style="text-align:left;">${esc(this.word('cp_total', 'All coaches'))}</td>${seasons.map(s => `<td>${h(tot.by[s.code] || 0)} h</td>`).join('')}
        <td>${h(tot.hours)} h</td><td class="fn-out">${M0(tot.amount)}</td></tr>`;
      return `<div class="fn-card" style="margin:4px 0 8px 0;"><div class="fn-title">${esc(this.word('cp_title', '🧑‍🏫 Coaches · {year}', { year: d.year }))}</div>
        <div class="fn-note">${esc(this.word('cp_note', 'Practice slots × coaches, early arrival before the first session of the day, and games.'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table"><thead>${head}</thead><tbody>${rows}${sum}</tbody></table></div></div>`;
    }
  }

  global.CoachingPlanTable = CoachingPlanTable;
})(window);
