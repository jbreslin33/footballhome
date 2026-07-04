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
      body = `<div style="padding:4px 0; font-weight:700; opacity:0.9;">No recent payments</div>`;
    } else {
      const rows = list.slice(0, 3).map((lp) => {
        const paidAt = parseIsoUtc(lp && lp.paidAt);
        if (!paidAt) return '';
        const amt  = fmtLastAmount(lp.amount);
        const date = fmtLastDate(paidAt);
        const ago  = daysSince(paidAt, now);
        const tip  = lp.txnType ? `${lp.txnType}: ${amt} on ${date}` : `${amt} on ${date}`;
        return `
          <tr title="${escapeAttr(tip)}">
            <td style="padding:2px 8px 2px 0; text-align:left; font-weight:800;">${amt}</td>
            <td style="padding:2px 8px; text-align:left;">${date}</td>
            <td style="padding:2px 0 2px 8px; text-align:right; color:${dim};">${ago}</td>
          </tr>`;
      }).join('');
      body = `
        <table style="border-collapse:collapse; font-variant-numeric:tabular-nums; width:100%;">
          <tbody>${rows}</tbody>
        </table>`;
    }

    return `
      <div class="bb-last-paid-box"
           style="flex-basis:100%; width:100%; display:block; box-sizing:border-box;
                  margin-top:4px; padding:5px 8px;
                  border:1px solid ${border}; border-radius:4px;
                  background:${bg}; color:${fg};
                  font-size:0.75rem; line-height:1.3; letter-spacing:0.02em;">
        <div style="font-size:0.6rem; font-weight:800; opacity:0.75;
                    letter-spacing:0.1em; margin-bottom:2px;">RECENT PAYMENTS</div>
        ${body}
      </div>
    `;
  }
  // ──────────────────────────────────────────────────────────────────────

  const escapeAttr = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  function render(p) {
    if (!p || !p.leagueAppsUserId) return '';
    // Single financial section on the card — the "Recent payments" box.
    // The old next-bill pill + mark-billed button were removed
    // 2026-07-02 (user: "just one financial section").  wire() below
    // still binds handlers for `.bb-badge` / `.bb-mark-billed` in case
    // they're re-introduced later, but nothing renders them today.
    return renderLastPaid(p);
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

  return { render, wire, renderLastPaid };})();
