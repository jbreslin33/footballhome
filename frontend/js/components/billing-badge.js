// BillingBadge — shared UI for the "next bill date + amount" + "Mark
// billed" action used on the Men's Roster and Youth Roster screens.
//
// Player object must carry:
//   leagueAppsUserId : number
//   nextBillDate     : 'YYYY-MM-DD'
//   nextBillAmount   : number   (0 = free agent)
//   isDefault        : boolean  (true if the row is a schema default, not yet customised)
//
// Usage:
//   <inline html>  BillingBadge.render(player)
//   <wiring>       BillingBadge.wire(rootEl, authFetch, onChange)
//
// Click model:
//   .bb-badge       → opens inline edit popup (date + amount)
//   .bb-mark-billed → POSTs /api/person-billing/mark-billed, then onChange()
//
window.BillingBadge = (() => {
  const fmtAmount = (n) => {
    const v = Number(n);
    if (!isFinite(v)) return '$?';
    if (Number.isInteger(v)) return `$${v}`;
    return `$${v.toFixed(2)}`;
  };

  // 'YYYY-MM-DD' → 'M/D' (no year — saves space; year shown in tooltip).
  const shortDate = (iso) => {
    if (!iso || !/^\d{4}-\d{2}-\d{2}$/.test(iso)) return iso || '';
    const [, m, d] = iso.match(/^\d{4}-(\d{2})-(\d{2})$/);
    return `${parseInt(m, 10)}/${parseInt(d, 10)}`;
  };

  const longDate = (iso) => {
    if (!iso || !/^\d{4}-\d{2}-\d{2}$/.test(iso)) return iso || '';
    const d = new Date(`${iso}T00:00:00Z`);
    if (isNaN(d.getTime())) return iso;
    return d.toLocaleDateString('en-US', {
      month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC',
    });
  };

  // Returns 'past' / 'today' / 'soon' (within 7 days) / 'future'.
  const dueState = (iso) => {
    if (!iso) return 'future';
    const today = new Date(); today.setUTCHours(0, 0, 0, 0);
    const d     = new Date(`${iso}T00:00:00Z`);
    if (isNaN(d.getTime())) return 'future';
    const diffDays = Math.round((d - today) / 86400000);
    if (diffDays < 0)  return 'past';
    if (diffDays === 0) return 'today';
    if (diffDays <= 7)  return 'soon';
    return 'future';
  };

  // ── Last-paid mini-table ──────────────────────────────────────────────
  // Data source: /api/mens-roster + /api/youth-roster expose
  //   p.lastPayments : [{ amount:number, paidAt:ISO8601, txnType:string }, ...]
  //                    newest-first, up to 3 rows per player.
  //
  // Sync from LeagueApps runs every roster page load (user directive
  // 2026-07-02).  Display is a boxed 3-column mini table:
  //     amount | date | days-since
  //
  // Colour rule (user directive 2026-07-02):
  //   Green — at least one of the recent payments is EITHER
  //             $35 paid in the current monthly window
  //               [previous 1st Friday, next 1st Friday)
  //           OR
  //             $8.75 / $9 paid on the most recent past Friday
  //   Red   — otherwise
  //
  // Layout: renders as a block that takes the full card width on its own
  // row (flex-basis:100%) so the numbers are legible at a glance.

  const EXPECTED_MONTHLY_AMOUNT = 35;
  const REDUCED_FRIDAY_AMOUNTS  = [8.75, 9];

  const parseIsoUtc = (s) => {
    if (!s || typeof s !== 'string') return null;
    const d = new Date(s);
    return isNaN(d.getTime()) ? null : d;
  };

  const fmtLastAmount = (n) => {
    const v = Number(n);
    if (!isFinite(v)) return '$?';
    return Number.isInteger(v) ? `$${v}` : `$${v.toFixed(2)}`;
  };

  const fmtLastDate = (d) => {
    if (!d) return '';
    const y = d.getUTCFullYear();
    const m = d.getUTCMonth() + 1;
    const day = d.getUTCDate();
    return `${m}/${day}/${y}`;
  };

  const daysSince = (d, nowDate = new Date()) => {
    if (!d) return '';
    const ms = nowDate.getTime() - d.getTime();
    const days = Math.floor(ms / 86400000);
    if (days < 0) return '0d';
    return `${days}d`;
  };

  // First Friday of the given (UTC year, monthIdx0).
  const firstFridayOf = (y, m) => {
    const first = new Date(Date.UTC(y, m, 1));
    const daysToFri = (5 - first.getUTCDay() + 7) % 7;
    return new Date(Date.UTC(y, m, 1 + daysToFri));
  };

  // Monthly window driven by the "1st Friday" calendar:
  //   • If today's UTC date is on/before THIS month's 1st Friday, we are
  //     still in the "prev-to-current" cycle → window = [prevFF, thisFF].
  //   • Otherwise (past this month's 1st Friday) roll forward
  //     → window = [thisFF, nextFF].
  // End boundary is exclusive at (endFF + 1 day) so a payment stamped any
  // time on the boundary Friday counts as inside the window.
  const monthlyWindow = (nowDate) => {
    const y = nowDate.getUTCFullYear();
    const m = nowDate.getUTCMonth();
    const thisFF = firstFridayOf(y, m);
    const todayMid = new Date(Date.UTC(y, m, nowDate.getUTCDate()));
    const beforeCycle = todayMid.getTime() <= thisFF.getTime();
    const prevFF = firstFridayOf(m === 0 ? y - 1 : y, m === 0 ? 11 : m - 1);
    const nextFF = firstFridayOf(m === 11 ? y + 1 : y, m === 11 ? 0 : m + 1);
    const start = beforeCycle ? prevFF : thisFF;
    const endFF = beforeCycle ? thisFF : nextFF;
    const end   = new Date(endFF.getTime() + 86400000);
    return { start, end };
  };

  // Most recent past Friday (or today if today IS Friday) at UTC midnight.
  const lastFridayMidnight = (nowDate) => {
    const dow = nowDate.getUTCDay();  // 0=Sun … 5=Fri … 6=Sat
    const back = (dow - 5 + 7) % 7;
    return new Date(Date.UTC(
      nowDate.getUTCFullYear(),
      nowDate.getUTCMonth(),
      nowDate.getUTCDate() - back
    ));
  };

  const nearAmount = (a, target) => Math.abs(Number(a) - target) < 0.005;

  const isPaidGreen = (payments, nowDate = new Date()) => {
    if (!Array.isArray(payments) || !payments.length) return false;
    const { start, end } = monthlyWindow(nowDate);
    const friStart = lastFridayMidnight(nowDate);
    const friEnd   = new Date(friStart.getTime() + 86400000);
    for (const lp of payments) {
      const d = parseIsoUtc(lp && lp.paidAt);
      if (!d) continue;
      const amt = Number(lp && lp.amount);
      if (nearAmount(amt, EXPECTED_MONTHLY_AMOUNT)
          && d >= start && d < end) {
        return true;
      }
      if (REDUCED_FRIDAY_AMOUNTS.some((x) => nearAmount(amt, x))
          && d >= friStart && d < friEnd) {
        return true;
      }
    }
    return false;
  };

  function renderLastPaid(p) {
    if (!p) return '';
    const list = Array.isArray(p.lastPayments) ? p.lastPayments : [];
    const now  = new Date();
    const green = isPaidGreen(list, now);

    // Palette: green = paid-up, red = not paid-up (covers empty list too).
    const bg     = green ? '#052e1a' : '#3a1f1f';
    const fg     = green ? '#bbf7d0' : '#fecaca';
    const border = green ? '#166534' : '#b91c1c';
    const dim    = green ? '#86efac' : '#fca5a5';

    let body;
    if (list.length === 0) {
      body = `<div style="padding:2px 0; font-weight:700; opacity:0.9;">No recent payments</div>`;
    } else {
      // Column separators (thin vertical rules) instead of stretching the
      // 3 cells across the whole card — user directive 2026-07-04 pm:
      // "only 3 cols so it does not need to use full width of card just
      // have it segmented with lines".
      const divCol = `border-left:1px solid ${border};`;
      const rows = list.slice(0, 3).map((lp) => {
        const paidAt = parseIsoUtc(lp && lp.paidAt);
        if (!paidAt) return '';
        const amt  = fmtLastAmount(lp.amount);
        const date = fmtLastDate(paidAt);
        const ago  = daysSince(paidAt, now);
        const tip  = lp.txnType ? `${lp.txnType}: ${amt} on ${date}` : `${amt} on ${date}`;
        return `
          <tr title="${escapeAttr(tip)}">
            <td style="padding:1px 6px 1px 0; font-weight:800; white-space:nowrap;">${amt}</td>
            <td style="padding:1px 6px; ${divCol} white-space:nowrap;">${date}</td>
            <td style="padding:1px 0 1px 6px; ${divCol} color:${dim}; white-space:nowrap;">${ago}</td>
          </tr>`;
      }).join('');
      // width:auto so the table hugs its content instead of spreading
      // across the card.  font-size drops a hair to keep the block tight.
      body = `
        <table style="border-collapse:collapse; font-variant-numeric:tabular-nums; width:auto; font-size:0.7rem;">
          <tbody>${rows}</tbody>
        </table>`;
    }

    return `
      <div class="bb-last-paid-box"
           style="display:inline-flex; align-items:center; gap:5px; box-sizing:border-box;
                  padding:0 5px;
                  border:1px solid ${border}; border-radius:3px;
                  background:${bg}; color:${fg};
                  font-size:0.66rem; line-height:1.35; letter-spacing:0.02em;
                  vertical-align:middle;">
        <span style="font-size:0.55rem; font-weight:800; opacity:0.75;
                     letter-spacing:0.08em; white-space:nowrap;">RECENT PAY</span>
        ${body}
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  // ── 3-month calendar bucket table ─────────────────────────────────────
  // User directive 2026-07-05: "show me always what they paid over the
  // last 3 months broken into months in a table."
  //
  // Data source: p.paymentsWindow — array of {amount, paidAt (ISO UTC),
  // programId}, already narrowed to a 3-month rolling window by the
  // server (see MensRoster.cpp).  We re-bucket client-side by
  // America/NY calendar month so the columns match what a coach sees on
  // a real-world calendar.
  //
  // Column layout (today = July 5 example):
  //     [ May ] [ Jun ] [ Jul ]
  //     [ $35 ] [ $35 ] [ $0  ]
  //
  // On Aug 1 the columns flip to [Jun][Jul][Aug].  User called out that
  // Aug 1-6 is a "grace zone" — Aug column will show $0 because the 1st
  // Friday of Aug (=Aug 7) hasn't billed yet.  We tint that grace-zone
  // cell gray instead of red so it doesn't scream "past due".
  //
  // Cell colouring:
  //     sum >= $35                     → green      (paid)
  //     0  <  sum <  $35               → amber      (partial)
  //     sum == 0  AND 1st-Friday past  → red        (missed)
  //     sum == 0  AND 1st-Friday future→ gray/grace (not yet due)

  const NY_TZ = 'America/New_York';

  // Return YYYY-MM-DD for `d` in America/NY (using Intl to avoid manual
  // DST math).  For today's local NY midnight we compare with payment
  // dates converted the same way.
  const nyIsoDate = (d) => {
    const fmt = new Intl.DateTimeFormat('en-CA', {
      timeZone: NY_TZ, year: 'numeric', month: '2-digit', day: '2-digit',
    });
    // en-CA formats as "YYYY-MM-DD".
    return fmt.format(d);
  };

  // Extract (year, monthIdx0) in America/NY from a Date.
  const nyYearMonth = (d) => {
    const iso = nyIsoDate(d);
    const y = parseInt(iso.slice(0, 4),  10);
    const m = parseInt(iso.slice(5, 7),  10) - 1;
    return { y, m };
  };

  // Short month label ("May", "Jun", …).
  const MONTH_LABELS = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
  const monthLabel = (y, m) => MONTH_LABELS[m];

  // First Friday of (year, monthIdx0) as a UTC Date at 00:00Z.
  // Reuses the same helper as monthlyWindow() above.

  // "Has the 1st Friday of (y,m) already happened, judged in America/NY?"
  const firstFridayHasPassed = (y, m, nowDate) => {
    const ff = firstFridayOf(y, m);
    // Compare in America/NY: convert both to NY iso date strings.
    const ffIso    = nyIsoDate(ff);
    const todayIso = nyIsoDate(nowDate);
    return todayIso >= ffIso;
  };

  // ── Shared bucket builder (used by 3-month table + INVOICE pill) ─────
  //
  // Late-payment coverage rule (user directive 2026-07-06):
  //   A payment made on day >= 16 of month M is treated as also covering
  //   month M+1 (in addition to M itself).  Rationale: parents who paid
  //   in the back half of June are effectively pre-paying July's dues,
  //   so we should NOT re-invoice them for July.  Once we move to full
  //   pro-rate this rule goes away; for now it's the pragmatic bridge.
  //
  // Each bucket returns:
  //   y, m               (year, month index 0..11 in America/NY)
  //   inMonth            sum of amounts with paidAt IN this calendar month
  //   inMonthCount       count of those payments
  //   lateFromPrev       sum of amounts CARRIED IN from a >=16th payment
  //                      of the previous month (may be empty)
  //   lateFromPrevLabel  label of the carrying-in month, e.g. "Jun"
  //   effective          inMonth + lateFromPrev (used for colour + INVOICE
  //                      shortfall calc)
  //
  const LATE_PAY_DAY_THRESHOLD = 16;

  const bucketsFor3Month = (p) => {
    const now = new Date();
    const cur = nyYearMonth(now);
    const buckets = [];
    for (let back = 2; back >= 0; back--) {
      const total = cur.m - back;
      const y = cur.y + Math.floor(total / 12);
      const m = ((total % 12) + 12) % 12;
      buckets.push({
        y, m,
        inMonth:           0,
        inMonthCount:      0,
        lateFromPrev:      0,
        lateFromPrevLabel: '',
      });
    }
    const findBucket = (y, m) => buckets.find((x) => x.y === y && x.m === m);
    const nextYM = (y, m) => (m === 11 ? { y: y + 1, m: 0 } : { y, m: m + 1 });

    const list = Array.isArray(p && p.paymentsWindow) ? p.paymentsWindow : [];
    for (const lp of list) {
      const iso = lp && lp.paidAt;
      if (!iso || typeof iso !== 'string') continue;
      const d = new Date(iso);
      if (isNaN(d.getTime())) continue;
      const amt = Number(lp.amount);
      if (!isFinite(amt) || amt <= 0) continue;

      // Primary month bucket — where the payment actually landed.
      const ny = nyYearMonth(d);
      const b  = findBucket(ny.y, ny.m);
      if (b) { b.inMonth += amt; b.inMonthCount++; }

      // Day-of-month in America/NY.  Same Intl trick as nyIsoDate.
      const dayStr = new Intl.DateTimeFormat('en-CA', {
        timeZone: NY_TZ, day: '2-digit',
      }).format(d);
      const dayNum = parseInt(dayStr, 10);

      if (dayNum >= LATE_PAY_DAY_THRESHOLD) {
        const nx = nextYM(ny.y, ny.m);
        const nb = findBucket(nx.y, nx.m);
        if (nb) {
          nb.lateFromPrev      += amt;
          nb.lateFromPrevLabel  = monthLabel(ny.y, ny.m);
        }
      }
    }

    for (const b of buckets) {
      b.effective = b.inMonth + b.lateFromPrev;
    }
    return buckets;
  };

  function render3MonthTable(p) {
    if (!p) return '';
    const buckets = bucketsFor3Month(p);

    // Column styling per state — driven by *effective* (in-month +
    // late-from-prev carry-in) so a Jun-16 payment turns July green.
    //   effective == 0        → red
    //   0 < effective < $35   → yellow
    //   effective >= $35      → green
    const cellFor = (b) => {
      const paid    = b.effective >= EXPECTED_MONTHLY_AMOUNT - 0.01;
      const partial = b.effective > 0 && !paid;
      if (paid)    return { bg:'#052e1a', fg:'#bbf7d0', border:'#166534', tag:'paid' };
      if (partial) return { bg:'#3a2f0f', fg:'#fde68a', border:'#a16207', tag:'partial' };
      return         { bg:'#3a1f1f', fg:'#fecaca', border:'#b91c1c', tag:'zero' };
    };

    const fmtSum = (n) => {
      if (n <= 0)             return '$0';
      if (Number.isInteger(n)) return `$${n}`;
      return `$${n.toFixed(2)}`;
    };

    const cells = buckets.map((b) => {
      const c     = cellFor(b);
      const label = monthLabel(b.y, b.m);
      // Main line — the money that actually landed in this calendar
      // month.  Even if a carry-in from the prev month brought us into
      // the green, we still want the coach to see "this month's real
      // deposit was $0".
      const mainAmt = fmtSum(b.inMonth);

      // Late-carry sub-line: only rendered when we pulled coverage
      // forward from a >=16th payment last month.  This is the
      // "**Late Jun**" tag the user asked for.
      let carryLine = '';
      const carryTipParts = [];
      if (b.lateFromPrev > 0) {
        const carryAmt = fmtSum(b.lateFromPrev);
        carryLine = `
          <div style="font-size:0.5rem; font-weight:800; letter-spacing:0.06em;
                      line-height:1.05; opacity:0.9; margin-top:1px;">
            +${carryAmt} Late ${escapeAttr(b.lateFromPrevLabel)}
          </div>`;
        carryTipParts.push(`carry-in from ${b.lateFromPrevLabel} (paid on/after day ${LATE_PAY_DAY_THRESHOLD}): ${carryAmt}`);
      }

      const tipParts = [
        `${label} ${b.y}: paid ${mainAmt} (${b.inMonthCount} payment${b.inMonthCount === 1 ? '' : 's'})`,
        ...carryTipParts,
        `effective ${fmtSum(b.effective)} — ${c.tag}`,
      ];
      const tip = tipParts.join(' · ');

      return `
        <div title="${escapeAttr(tip)}"
             style="flex:1 1 0; min-width:42px; padding:3px 7px; text-align:center;
                    background:${c.bg}; color:${c.fg};
                    border:1px solid ${c.border}; border-radius:3px;
                    font-variant-numeric:tabular-nums;">
          <div style="font-size:0.62rem; font-weight:800; letter-spacing:0.08em; opacity:0.85;">${label}</div>
          <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">${mainAmt}</div>
          ${carryLine}
        </div>`;
    }).join('');

    return `
      <div class="bb-3mo-box"
           style="display:inline-flex; align-items:stretch; gap:3px; box-sizing:border-box;
                  padding:2px; border-radius:4px; vertical-align:middle;">
        ${cells}
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  // ── Projected prorate cell (mid-cycle signups) ───────────────────────
  //
  // User directive 2026-07-07: any member who registered "between"
  // 1st Fridays (i.e. mid-cycle, not on a 1st Friday itself) and has
  // only paid the $1 registration fee owes a prorated invoice covering
  // the rest of THEIR signup cycle.  Show that projected number as a
  // cell on the roster card so the coach can add the charge in LA
  // right away — the player then goes on the normal $35/mo cadence
  // starting the NEXT 1st Friday after their signup.
  //
  // Cycle math (anchored to the player's OWN reg date, not today):
  //   • lastFri = last 1st Friday on or before reg date
  //   • nextFri = next 1st Friday strictly after reg date
  //   • cycleDays  = round((nextFri - lastFri) / 1 day)     (28–35)
  //   • daysRemain = ceil((nextFri - reg) / 1 day)
  //   • prorate    = $35 × (daysRemain / cycleDays)
  //
  // Gates (all must hold):
  //   1. p.laRegisteredAt is present and parseable.
  //   2. Reg date is NOT itself a 1st Friday (a 1st-Friday signup pays
  //      a full $35 for their fresh cycle — no prorate needed).
  //   3. Total payments SINCE reg date are < $35.  The $1 registration
  //      fee keeps brand-new signups under the threshold; once a real
  //      monthly payment lands, the cell auto-hides.
  const projectedProrate = (p) => {
    const iso = p && p.laRegisteredAt;
    if (!iso || typeof iso !== 'string') return null;

    const regDate = new Date(iso);
    if (isNaN(regDate.getTime())) return null;
    // Normalize registration to local midnight (LA timestamps carry a
    // UTC hh:mm we don't need for whole-day cycle math).
    const reg = new Date(regDate.getFullYear(), regDate.getMonth(), regDate.getDate());

    // 1st Friday of (year, monthIdx).  monthIdx may be -1 or 12 —
    // Date normalizes the rollover.
    const firstFridayOf = (y, m) => {
      const d = new Date(y, m, 1);
      const off = (5 - d.getDay() + 7) % 7;   // Fri = 5
      return new Date(y, m, 1 + off);
    };

    // Cycle boundaries around the player's OWN reg date:
    //   • reg BEFORE this month's 1st Fri → last was prev month's Fri, next is this
    //   • reg ON this month's 1st Fri     → no prorate (they pay full $35 for the fresh cycle)
    //   • reg AFTER this month's 1st Fri  → last was this Fri, next is next month's
    const regFri = firstFridayOf(reg.getFullYear(), reg.getMonth());
    let lastFri, nextFri;
    if (reg < regFri) {
      lastFri = firstFridayOf(reg.getFullYear(), reg.getMonth() - 1);
      nextFri = regFri;
    } else if (reg.getTime() === regFri.getTime()) {
      return null;
    } else {
      lastFri = regFri;
      nextFri = firstFridayOf(reg.getFullYear(), reg.getMonth() + 1);
    }

    const DAY = 86400000;
    const cycleDays  = Math.round((nextFri - lastFri) / DAY);
    const daysRemain = Math.max(0, Math.ceil((nextFri - reg) / DAY));
    if (daysRemain === 0 || cycleDays === 0) return null;

    // Current-cycle gate (2026-07-09 per owner directive: "Eren Cedeno
    // and others in this situation don't need pro rate for July
    // remember if they never paid more than $1 or $0 and they
    // registered before July 3rd. they just get billed straight $35").
    // Prorate anchored to the player's reg date is only meaningful
    // when nextFri (the boundary that ends *their* partial cycle) is
    // still in the future.  A player who registered in a prior cycle
    // is now on the full-cycle plan and owes the standard $35, so
    // return null here to suppress the stale prorate badge/message.
    const nowMs = Date.now();
    if (nextFri.getTime() < nowMs) return null;

    // Suppress once the player has paid ≥ $35 since reg.  Only counts
    // positive, valid payments landing on or after reg date — historical
    // pre-reg payments (family alias, credit balances) don't apply.
    const list = Array.isArray(p && p.paymentsWindow) ? p.paymentsWindow : [];
    let paidSinceReg = 0;
    for (const lp of list) {
      const at = lp && lp.paidAt;
      if (!at || typeof at !== 'string') continue;
      const d = new Date(at);
      if (isNaN(d.getTime())) continue;
      if (d < reg) continue;
      const amt = Number(lp.amount);
      if (!isFinite(amt) || amt <= 0) continue;
      paidSinceReg += amt;
    }
    if (paidSinceReg >= EXPECTED_MONTHLY_AMOUNT - 0.01) return null;

    // Anything already paid since reg (typically the $1 card-capture
    // fee) counts toward this cycle's dues per owner directive
    // 2026-07-09 ("it should be counted as part of the $35").  Subtract
    // it from the raw prorate so the manual LA charge equals what the
    // player still owes for the partial cycle — not the full window.
    const rawAmount = EXPECTED_MONTHLY_AMOUNT * daysRemain / cycleDays;
    const netAmount = Math.max(0, rawAmount - paidSinceReg);
    const amount    = Math.round(netAmount * 100) / 100;

    return {
      amount,
      rawAmount:   Math.round(rawAmount * 100) / 100,
      paidSinceReg: Math.round(paidSinceReg * 100) / 100,
      regDate: reg,
      lastFri,
      nextFri,
      cycleDays,
      daysRemain,
    };
  };

  function renderProrateCell(p) {
    if (!p) return '';
    const pr = projectedProrate(p);

    // Always-visible cell (2026-07-07 per owner directive: "just put
    // prorate on everyone and if not supposed to be pro rated then
    // show $0").  This also serves as a self-diagnostic — if the cell
    // ever fails to appear on a card, we know instantly the roster
    // JS is stale, rather than debugging silent-null gates.
    const fmtAmt = (n) => (Number.isInteger(n) ? `$${n}` : `$${n.toFixed(2)}`);

    if (!pr) {
      // Not eligible — muted slate cell showing $0.  Tooltip explains
      // WHY prorate is $0 so the coach can distinguish "already paid",
      // "reg date missing", and "reg was on 1st Friday" without
      // hunting.
      let reason = 'no prorate owed';
      const iso  = p && p.laRegisteredAt;
      if (!iso || typeof iso !== 'string') {
        reason = 'no LA registration date on record';
      } else {
        const regDate = new Date(iso);
        if (isNaN(regDate.getTime())) {
          reason = 'LA registration date unparseable';
        } else {
          const list = Array.isArray(p.paymentsWindow) ? p.paymentsWindow : [];
          const paidSinceReg = list.reduce((s, lp) => {
            if (!lp || !lp.paidAt) return s;
            const d = new Date(lp.paidAt);
            if (isNaN(d.getTime()) || d < regDate) return s;
            const amt = Number(lp.amount);
            return s + (isFinite(amt) && amt > 0 ? amt : 0);
          }, 0);
          if (paidSinceReg >= EXPECTED_MONTHLY_AMOUNT - 0.01) {
            reason = `full $${EXPECTED_MONTHLY_AMOUNT}+ already paid since reg (${fmtAmt(paidSinceReg)})`;
          } else {
            // Only other reason projectedProrate returns null: reg
            // date falls exactly on a 1st Friday.
            reason = 'signed up on the 1st Friday — full $' + EXPECTED_MONTHLY_AMOUNT + ' cycle, no prorate';
          }
        }
      }

      const tip = `Projected prorate: $0 — ${reason}.`;
      const bg     = '#1e293b';   // slate-800
      const fg     = '#94a3b8';   // slate-400
      const border = '#334155';   // slate-700
      return `
        <div class="bb-prorate-cell" title="${escapeAttr(tip)}"
             style="display:inline-flex; flex-direction:column; align-items:center;
                    justify-content:center; min-width:52px; padding:3px 7px;
                    margin-right:3px; box-sizing:border-box;
                    border:1px solid ${border}; background:${bg}; color:${fg};
                    border-radius:3px; font-variant-numeric:tabular-nums;
                    vertical-align:middle;">
          <div style="font-size:0.55rem; font-weight:800; letter-spacing:0.06em; opacity:0.85;">PRORATE</div>
          <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">$0</div>
          <div style="font-size:0.5rem; font-weight:700; opacity:0.7; letter-spacing:0.04em;">n/a</div>
        </div>
      `;
    }

    const shown  = fmtAmt(pr.amount);
    const nextFriShort = pr.nextFri.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const regShort     = pr.regDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

    // Tip explains: raw prorate = $35 × daysRemain/cycleDays, then
    // subtract anything already paid since reg (typically $1 signup
    // fee) so the net = what the coach still needs to add on LA.
    const rawShown  = fmtAmt(pr.rawAmount);
    const paidNote  = pr.paidSinceReg > 0
      ? ` − ${fmtAmt(pr.paidSinceReg)} already paid since reg = ${shown}`
      : '';
    const tip =
      `Projected prorate: signed up ${regShort}, ` +
      `${pr.daysRemain}/${pr.cycleDays} days remaining until next 1st Friday (${nextFriShort}) · ` +
      `$${EXPECTED_MONTHLY_AMOUNT} × ${pr.daysRemain}/${pr.cycleDays} = ${rawShown}${paidNote}. ` +
      `Add this as a manual charge on the player's LA registration NOW; ` +
      `their normal $${EXPECTED_MONTHLY_AMOUNT}/mo bills begin on ${nextFriShort}.`;

    // Amber styling — matches the "partial" state used by the 3-month cells.
    const bg     = '#3a2f0f';
    const fg     = '#fde68a';
    const border = '#a16207';

    return `
      <div class="bb-prorate-cell" title="${escapeAttr(tip)}"
           style="display:inline-flex; flex-direction:column; align-items:center;
                  justify-content:center; min-width:52px; padding:3px 7px;
                  margin-right:3px; box-sizing:border-box;
                  border:1px solid ${border}; background:${bg}; color:${fg};
                  border-radius:3px; font-variant-numeric:tabular-nums;
                  vertical-align:middle;">
        <div style="font-size:0.55rem; font-weight:800; letter-spacing:0.06em; opacity:0.9;">PRORATE</div>
        <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">${shown}</div>
        <div style="font-size:0.5rem; font-weight:700; opacity:0.8; letter-spacing:0.04em;">thru ${escapeAttr(nextFriShort)}</div>
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  // ── LA registration date pill ────────────────────────────────────────
  //
  // User directive 2026-07-06: show each player's LA registration date
  // on the roster card for every club.  Sourced from the authoritative
  // `p.laRegisteredAt` (server-provided ISO from
  // person_la_memberships.la_registered_at).  Renders as a small
  // slate-grey pill "REG  Jul 6, 2026".  Silent-null when the timestamp
  // is missing (older members whose sync predates the la_registered_at
  // column, etc.).
  function renderRegistrationDate(p) {
    if (!p) return '';
    const iso = p.laRegisteredAt;
    if (!iso || typeof iso !== 'string') return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';

    // Format as "MMM D, YYYY" in America/NY so the label reflects the
    // player's local registration day, not UTC.
    const fmt = new Intl.DateTimeFormat('en-US', {
      timeZone: NY_TZ, month: 'short', day: 'numeric', year: 'numeric',
    });
    const shown = fmt.format(d);

    const bg     = '#1e293b';
    const fg     = '#cbd5e1';
    const border = '#475569';

    const tip = `Registered on LeagueApps: ${shown}`;

    return `
      <div class="bb-reg-cell" title="${escapeAttr(tip)}"
           style="display:inline-flex; flex-direction:column; align-items:center;
                  justify-content:center; min-width:52px; padding:3px 7px;
                  margin-right:3px; box-sizing:border-box;
                  border:1px solid ${border}; background:${bg}; color:${fg};
                  border-radius:3px; font-variant-numeric:tabular-nums;
                  vertical-align:middle;">
        <div style="font-size:0.55rem; font-weight:800; letter-spacing:0.08em; opacity:0.85;">REG</div>
        <div style="font-size:0.72rem; font-weight:700; line-height:1.15; white-space:nowrap;">${escapeAttr(shown)}</div>
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  // ── TO INVOICE pill ───────────────────────────────────────────────────
  // User directive 2026-07-05 pm ("checks-and-balance ping-pong"):
  //   even if the LA invoice hasn't been updated yet, our rules say a
  //   player owes $35 for every past-or-current month with no matching
  //   $35+ payment on record.  This pill totals that shortfall so the
  //   admin sees at a glance how much they still need to add to LA
  //   invoices for this player — independent of what LA's balance says.
  //
  // Computation:
  //   For each of the same 3 (y, m) buckets shown in the calendar table:
  //     shortfall = max(0, EXPECTED_MONTHLY_AMOUNT - sum)
  //   Total = sum of shortfalls across those months.
  //
  // Note: the 3rd bucket is the CURRENT month.  Even if today is early
  //   in the month (before the 1st Friday) we still count it as owed —
  //   matching the user's "visual scream" preference on the 3-month
  //   cells.  If they want a grace zone later we can add it in one spot.
  //
  // Colour rule:
  //   total > 0 → red   (needs invoicing)
  //   total = 0 → green (nothing to invoice — all months paid)
  function renderUnbilled(p) {
    if (!p) return '';
    // Uses the shared bucket helper so late-payment coverage (>=16th of
    // prev month) turns the shortfall into $0 for the current month.
    const buckets = bucketsFor3Month(p);

    let total = 0;
    const parts = [];
    for (const b of buckets) {
      const shortfall = Math.max(0, EXPECTED_MONTHLY_AMOUNT - b.effective);
      const label = monthLabel(b.y, b.m);
      if (shortfall > 0) {
        total += shortfall;
        parts.push(`${label}: needs $${shortfall.toFixed(shortfall % 1 ? 2 : 0)}`);
      } else if (b.lateFromPrev > 0 && b.inMonth <= 0) {
        parts.push(`${label}: covered by Late ${b.lateFromPrevLabel}`);
      } else {
        parts.push(`${label}: covered`);
      }
    }

    const owes = total > 0.005;
    const bg     = owes ? '#3a1f1f' : '#052e1a';
    const fg     = owes ? '#fecaca' : '#bbf7d0';
    const border = owes ? '#b91c1c' : '#166534';

    const shown = Number.isInteger(total) ? `$${total}` : `$${total.toFixed(2)}`;
    const label = owes ? 'INVOICE' : 'BILLED';
    const tip   = (owes
                    ? `Add ${shown} to this player's LeagueApps invoice (checks-and-balance total across the last 3 months, with late-payment coverage applied).`
                    : 'All 3 months are covered — no unbilled dues.')
                  + '\n' + parts.join(' · ');

    return `
      <div class="bb-unbilled-box" title="${escapeAttr(tip)}"
           style="display:inline-flex; flex-direction:column; align-items:center; justify-content:center;
                  min-width:52px; padding:3px 7px; box-sizing:border-box;
                  border:1px solid ${border}; background:${bg}; color:${fg};
                  border-radius:3px; font-variant-numeric:tabular-nums; vertical-align:middle;">
        <div style="font-size:0.55rem; font-weight:800; letter-spacing:0.08em; opacity:0.85;">${label}</div>
        <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">${shown}</div>
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  const escapeAttr = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  // ── Current balance pill ──────────────────────────────────────────────
  // Data source: p.outstandingBalance — the raw LA registration balance
  // (see MensRoster.cpp line 233).  User directive 2026-07-05 pm:
  // "we dont need recent pay now because the 3 latest month cells show
  // that. what we do need is a current balance right?"
  //
  // BAL cell — visually matches the 3-month cells (small label on top,
  // big value below) so all financial info lives in one strip.
  //
  // Colour rule (user directive 2026-07-05 pm — "make it all one pill
  // for bal due and bal, use bal for both"):
  //   balance <  0                      → blue   (credit on file)
  //   balance == 0 AND days == 0        → green  (paid up)
  //   balance >  0 OR  days  >= 1       → red    (owes / late)
  //   balance == null AND paymentStatus is unknown → hidden
  //
  // When there's any overdue day count (p.daysOverdue >= 1) OR an
  // unpaid balance, an extra tiny "Nd LATE" (or "UNPAID") line renders
  // inside the same pill so the coach sees late-status in the same
  // spot as the balance number.
  function renderBalance(p) {
    if (!p) return '';
    const rawBal = (p.outstandingBalance == null) ? null : Number(p.outstandingBalance);
    if (rawBal == null || !isFinite(rawBal)) return '';
    const zero   = Math.abs(rawBal) < 0.005;
    const credit = !zero && rawBal < 0;
    const days   = Math.max(0, parseInt(p.daysOverdue, 10) || 0);
    // 2026-07-09 owner directive ("bal due of greater than 0 showing up
    // as green" for Raynel Hernandez / Jamauri Bradham): a positive LA
    // balance always means red, even when paymentStatus === 'PAID'.
    // The old rule gated on !paidStatus, which masked coach-edited
    // balances on already-paid registrations.  LA's Balance Due column
    // is now the authoritative "does this player owe money" signal.
    const owes   = (!zero && rawBal > 0) || days >= 1;

    let bg='#052e1a', fg='#bbf7d0', border='#166534';   // green / paid-up
    if (owes)        { bg='#3a1f1f'; fg='#fecaca'; border='#b91c1c'; }
    else if (credit) { bg='#0f223a'; fg='#bfdbfe'; border='#1d4ed8'; }

    const amt   = Math.abs(rawBal);
    const shown = zero ? '$0'
                       : (Number.isInteger(amt) ? `$${amt}` : `$${amt.toFixed(2)}`);

    // Third line — only rendered when there's something to say beyond
    // the amount itself (overdue days, or unpaid balance without a day
    // count).  Keeps the cell short when everything is fine.
    let lateLine = '';
    if (days >= 1) {
      lateLine = `<div style="font-size:0.55rem; font-weight:800; letter-spacing:0.06em; line-height:1.1; opacity:0.9;">${days}d LATE</div>`;
    } else if (owes) {
      // balance > 0 but our calendar says days = 0 (e.g. mark-billed
      // advanced next_bill_date before the LA charge cleared).
      lateLine = `<div style="font-size:0.55rem; font-weight:800; letter-spacing:0.06em; line-height:1.1; opacity:0.9;">UNPAID</div>`;
    }

    const tipParts = [];
    if (zero)        tipParts.push('Current LA balance: $0 (paid up)');
    else if (credit) tipParts.push(`Current LA balance: ${shown} credit on file`);
    else             tipParts.push(`Current LA balance: ${shown} owed`);
    if (days >= 1)   tipParts.push(`${days} day${days === 1 ? '' : 's'} past due`);
    if (p.nextBillDate) tipParts.push(`next bill ${p.nextBillDate}`);
    const tip = tipParts.join(' · ');

    return `
      <div class="bb-balance-box" title="${escapeAttr(tip)}"
           style="display:inline-flex; flex-direction:column; align-items:center; justify-content:center;
                  min-width:42px; padding:3px 7px; box-sizing:border-box;
                  border:1px solid ${border}; background:${bg}; color:${fg};
                  border-radius:3px; font-variant-numeric:tabular-nums; vertical-align:middle;">
        <div style="font-size:0.62rem; font-weight:800; letter-spacing:0.08em; opacity:0.85;">BAL</div>
        <div style="font-size:0.95rem; font-weight:800; line-height:1.15;">${shown}</div>
        ${lateLine}
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  // ── Last PAY-reminder pill (2026-07-06) ──────────────────────────────
  //
  // Shows the admin the last time we tapped the SMS / Email PAY button
  // for this player so nobody double-pings a parent or forgets who was
  // already contacted.  Data source: p.lastPayReminder = { method, sentAt }
  // — populated by the roster backend from pay_reminder_log.  Renders
  // an empty slot span (always present) so the roster screen can swap
  // the pill in place after logging a new click.
  function renderLastPayReminder(p) {
    const uid  = p && p.leagueAppsUserId ? p.leagueAppsUserId : '';
    const html = p && p.lastPayReminder ? renderLastPayReminderInline(p.lastPayReminder) : '';
    return `<span class="bb-pay-reminder-slot" data-uid="${escapeAttr(String(uid))}">${html}</span>`;
  }

  function renderLastPayReminderInline(last) {
    if (!last || !last.method || !last.sentAt) return '';
    const method = last.method === 'sms' ? 'SMS' : (last.method === 'email' ? 'Email' : '');
    if (!method) return '';
    const icon = last.method === 'sms' ? '📩' : '✉';
    const ago  = timeAgoShort(last.sentAt);
    if (!ago) return '';
    const bg     = '#0f172a';
    const fg     = '#94a3b8';
    const border = '#334155';
    let abs = last.sentAt;
    try {
      const d = new Date(last.sentAt);
      if (!isNaN(d.getTime())) {
        abs = new Intl.DateTimeFormat('en-US', {
          timeZone: NY_TZ, month: 'short', day: 'numeric',
          hour: 'numeric', minute: '2-digit',
        }).format(d);
      }
    } catch { /* keep raw iso */ }
    const tip = `Last ${method} reminder sent ${abs}`;
    return `
      <span class="bb-pay-reminder" title="${escapeAttr(tip)}"
            style="display:inline-flex; align-items:center; gap:3px;
                   padding:2px 6px; margin-right:3px;
                   border:1px solid ${border}; background:${bg}; color:${fg};
                   border-radius:3px; font-size:0.65rem; font-weight:700;
                   letter-spacing:0.02em; vertical-align:middle;
                   font-variant-numeric:tabular-nums; white-space:nowrap;">
        ${icon} ${method} · ${escapeAttr(ago)}
      </span>
    `;
  }

  // Short relative time formatter: "just now" / "5m ago" / "3h ago" /
  // "yesterday" / "3d ago" / "MMM D".  Used only for the pay-reminder
  // pill so admin sees at a glance how fresh the last ping is.
  function timeAgoShort(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    const diffMs = Date.now() - d.getTime();
    if (diffMs < 0) return 'just now';
    const mins = Math.floor(diffMs / 60000);
    if (mins < 1)  return 'just now';
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    const days = Math.floor(hrs / 24);
    if (days === 1) return 'yesterday';
    if (days < 7)   return `${days}d ago`;
    try {
      return new Intl.DateTimeFormat('en-US', {
        timeZone: NY_TZ, month: 'short', day: 'numeric',
      }).format(d);
    } catch { return `${days}d ago`; }
  }

  // ── FH last activity pill (2026-07-06) ──────────────────────────────
  //
  // Shows "when did this player last do anything on footballhome.org"
  // sourced from MAX(sessions.last_used_at) per person (see
  // MensRoster.cpp).  Colours:
  //   • never   → grey "FH · Never" (player has never signed in)
  //   • <7d ago → slate "FH · <ago>" (healthy)
  //   • ≥7d ago → red   "FH · <ago>" (dormant; per user directive)
  //
  // The value is bulk-emitted on every row as p.fhLastActivityAt
  // (ISO 8601 UTC string) or null.
  function renderFhLastActivity(p) {
    if (!p) return '';
    const iso = p.fhLastActivityAt || null;

    if (!iso) {
      const bg     = '#0f172a';
      const fg     = '#64748b';
      const border = '#334155';
      const tip    = 'This player has never signed in to footballhome.org';
      return `
        <span class="bb-fh-activity bb-fh-activity--never" title="${escapeAttr(tip)}"
              style="display:inline-flex; align-items:center; gap:3px;
                     padding:2px 6px; border:1px solid ${border};
                     background:${bg}; color:${fg};
                     border-radius:3px; font-size:0.65rem; font-weight:700;
                     letter-spacing:0.02em; vertical-align:middle;
                     font-variant-numeric:tabular-nums; white-space:nowrap;">
          FH · Never
        </span>
      `;
    }

    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    const days   = (Date.now() - d.getTime()) / 86400000;
    const stale  = days >= 7;
    const ago    = timeAgoShort(iso);

    // Slate (fresh) vs red (stale ≥7d) per user directive.
    const bg     = stale ? '#7f1d1d' : '#0f172a';
    const fg     = stale ? '#fecaca' : '#cbd5e1';
    const border = stale ? '#dc2626' : '#334155';
    let abs = iso;
    try {
      abs = new Intl.DateTimeFormat('en-US', {
        timeZone: NY_TZ, month: 'short', day: 'numeric',
        hour: 'numeric', minute: '2-digit',
      }).format(d);
    } catch { /* keep raw iso */ }
    const tip = `Last footballhome.org activity ${abs}`;
    return `
      <span class="bb-fh-activity ${stale ? 'bb-fh-activity--stale' : 'bb-fh-activity--fresh'}"
            title="${escapeAttr(tip)}"
            style="display:inline-flex; align-items:center; gap:3px;
                   padding:2px 6px; border:1px solid ${border};
                   background:${bg}; color:${fg};
                   border-radius:3px; font-size:0.65rem; font-weight:700;
                   letter-spacing:0.02em; vertical-align:middle;
                   font-variant-numeric:tabular-nums; white-space:nowrap;">
        FH · ${escapeAttr(ago)}
      </span>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  function render(p) {
    if (!p || !p.leagueAppsUserId) return '';
    // Compact financial strip:
    //   [REG date] + [optional PRORATE cell for new signups]
    //   + 3-month calendar buckets + current LA balance.
    //
    // 2026-07-06 pm — REG cell added per user directive: show each
    // player's LA registration date on cards across all clubs
    // (mens / boys / youth).  Data comes from
    // p.laRegisteredAt (backend: person_la_memberships.la_registered_at).
    //
    // 2026-07-06 pm — PRORATE cell added: for a player who just
    // registered this calendar month AND signed up on/after the
    // NEW_SIGNUP_CUTOFF_ISO (2026-07-06), display the projected
    // prorated invoice amount so the coach knows what to add as a
    // manual charge in LA.  Auto-hides once $35 has been collected
    // for the month.  Existing players (registered before the cutoff)
    // never show this cell — they fall under the legacy weekly-prorate
    // model already invoiced by LA.
    //
    // 2026-07-06 — INVOICE pill removed per user directive: BAL DUE is
    // the sole source of truth (LA), and once the user maintains LA
    // invoices per the $35/mo rule, INVOICE and BAL DUE converge to the
    // same number.  Rather than show two versions of the same idea we
    // just show LA's number.  renderUnbilled() is left exported for any
    // future "reconciliation warning" screen but is no longer on the card.
    //
    // (Old RECENT PAY pill dropped 2026-07-05: the 3-month cells now
    //  carry the same info in a more compact form.)
    return renderRegistrationDate(p)
         + renderProrateCell(p)
         + render3MonthTable(p)
         + renderBalance(p);
  }

  // Bind delegated click handler.  authFetch is the screen's auth.fetch
  // (so the JWT goes along).  onChange() is called after a successful
  // POST so the caller can re-render.
  function wire(rootEl, authFetch, onChange) {
    if (!rootEl || rootEl.__bbWired) return;
    rootEl.__bbWired = true;
    rootEl.addEventListener('click', async (e) => {
      const editBtn = e.target.closest('.bb-badge');
      const markBtn = e.target.closest('.bb-mark-billed');
      if (editBtn) {
        await openEdit(editBtn, authFetch, onChange);
      } else if (markBtn) {
        await doMarkBilled(markBtn, authFetch, onChange);
      }
    });
  }

  async function openEdit(btn, authFetch, onChange) {
    const userId = parseInt(btn.dataset.userId, 10);
    if (!userId) return;
    const curDate   = btn.dataset.nextBillDate || '';
    const curAmount = btn.dataset.nextBillAmount || '';

    // Prompt-based picker — minimal but works on desktop + mobile.
    // (A modal would be nicer; left as a future polish.)
    const dateStr = window.prompt(
      'Next bill date (YYYY-MM-DD):\n\nTip: set to the day you will invoice this player in LeagueApps.',
      curDate,
    );
    if (dateStr === null) return;
    const date = dateStr.trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      alert(`"${date}" is not a valid YYYY-MM-DD date.`);
      return;
    }

    const amtStr = window.prompt(
      'Next bill amount in USD:\n\nUse 0 for free agents (Casa Soccer League covers them).',
      curAmount,
    );
    if (amtStr === null) return;
    const amount = Number(amtStr.trim());
    if (!isFinite(amount) || amount < 0) {
      alert(`"${amtStr}" is not a valid non-negative number.`);
      return;
    }

    btn.disabled = true; btn.style.opacity = '0.5';
    try {
      const res = await authFetch('/api/person-billing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          leagueAppsUserId: userId,
          nextBillDate:     date,
          nextBillAmount:   amount,
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      if (typeof onChange === 'function') await onChange();
    } catch (err) {
      btn.disabled = false; btn.style.opacity = '';
      alert(`Could not save billing: ${err.message}`);
    }
  }

  async function doMarkBilled(btn, authFetch, onChange) {
    const userId = parseInt(btn.dataset.userId, 10);
    if (!userId) return;
    if (!confirm('Mark this player as billed and roll the next bill date forward one month?')) {
      return;
    }
    btn.disabled = true; btn.style.opacity = '0.5';
    try {
      const res = await authFetch('/api/person-billing/mark-billed', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ leagueAppsUserId: userId }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      if (typeof onChange === 'function') await onChange();
    } catch (err) {
      btn.disabled = false; btn.style.opacity = '';
      alert(`Could not mark billed: ${err.message}`);
    }
  }

  return { render, wire, renderLastPaid, render3MonthTable, renderUnbilled, renderBalance, renderProrateCell, projectedProrate, renderRegistrationDate, renderLastPayReminder, renderLastPayReminderInline, renderFhLastActivity };})();
