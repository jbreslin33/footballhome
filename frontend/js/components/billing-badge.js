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

  const escapeAttr = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  function render(p) {
    if (!p || !p.leagueAppsUserId) return '';
    const amount = Number(p.nextBillAmount);
    const isFA   = amount === 0;
    const state  = dueState(p.nextBillDate);

    // Colour scheme:
    //   FA      → slate (informational)
    //   past    → red (overdue)
    //   today   → orange (act now)
    //   soon    → amber (heads-up)
    //   future  → muted green/grey (fine)
    let bg, fg, border;
    if (isFA) {
      bg = '#1e293b'; fg = '#cbd5e1'; border = '#475569';
    } else if (state === 'past') {
      bg = '#3a1f1f'; fg = '#fca5a5'; border = '#b91c1c';
    } else if (state === 'today') {
      bg = '#3a2a14'; fg = '#fdba74'; border = '#ea580c';
    } else if (state === 'soon') {
      bg = '#3a3214'; fg = '#fde68a'; border = '#ca8a04';
    } else {
      bg = '#1f2937'; fg = '#cbd5e1'; border = '#374151';
    }

    const label = isFA
      ? `FA · ${shortDate(p.nextBillDate)}`
      : `${fmtAmount(amount)} · ${shortDate(p.nextBillDate)}`;

    const tip = isFA
      ? `Free agent (no charge). Next review: ${longDate(p.nextBillDate)}. Click to edit.`
      : `Next bill: ${fmtAmount(amount)} on ${longDate(p.nextBillDate)}. Click to edit.`;

    const markTip = `Mark billed: roll ${longDate(p.nextBillDate)} forward one month.`;

    return `
      <span style="display:inline-flex; gap:2px; align-items:center;">
        <button class="bb-badge" type="button"
                data-user-id="${p.leagueAppsUserId}"
                data-next-bill-date="${escapeAttr(p.nextBillDate)}"
                data-next-bill-amount="${escapeAttr(amount)}"
                title="${escapeAttr(tip)}"
                style="padding:2px 6px; font-size:0.65rem; font-weight:700;
                       border-radius:4px 0 0 4px; cursor:pointer; line-height:1.3;
                       letter-spacing:0.02em; white-space:nowrap;
                       background:${bg}; color:${fg}; border:1px solid ${border};">
          💲 ${label}
        </button>
        <button class="bb-mark-billed" type="button"
                data-user-id="${p.leagueAppsUserId}"
                title="${escapeAttr(markTip)}"
                style="padding:2px 5px; font-size:0.65rem; font-weight:700;
                       border-radius:0 4px 4px 0; cursor:pointer; line-height:1.3;
                       background:transparent; color:${fg}; border:1px solid ${border}; border-left:none;">
          ✓
        </button>
      </span>
    `;
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

  return { render, wire };
})();
