// PersonActions ──────────────────────────────────────────────────────
//
// One shared component that renders the standard action-button
// cluster attached to every "person card" across the app:
//
//   View   → open the universal PersonScreen (view mode)
//   Edit   → open the universal PersonScreen (edit mode intent)
//
// Product rule: clicking a player/person on any admin screen uses
// this same View/Edit interface (PersonScreen) — not per-screen
// modals or one-off profile UIs.  Lineup/zone/RSVP controls stay
// local; identity and person-graph edits go through Person.
//
// Usage
// ─────
//   // 1) Once, at app bootstrap (see app.js):
//   PersonActions.installGlobalHandler(navigation);
//
//   // 2) In any card renderer:
//   return `
//     <div class="my-card">
//       <strong>${p.fullName}</strong>
//       ${PersonActions.buttonsHtml(p, { returnTo: 'boys-roster' })}
//     </div>
//   `;
//
// Options
// ───────
//   returnTo       screen slug to hint the person page's back-nav
//                  (defaults to whatever the browser history knows).
//   showProfile    include the View button (default true).
//   showEdit       include the Edit button (default true).
//   size           'sm' (default; matches roster chip sizing) | 'md'
//   btnBaseStyle   extra CSS appended to each button's inline style.
//
// EDIT mode note
// ──────────────
//   PersonScreen remembers `edit=1` from the Edit button.  Both
//   buttons land on the same Person hub; Edit signals the operator
//   intent to change FH-owned fields as that surface grows.

class PersonActions {
  static buttonsHtml(person, opts = {}) {
    if (!person) return '';
    const laUid = person.leagueAppsUserId ?? person.laUserId ?? '';
    const pid   = person.personId ?? person.person_id ?? '';
    if (!laUid && !pid) return '';

    const name = person.firstName || person.fullName || person.name || 'person';
    const returnTo = opts.returnTo || '';
    const size = opts.size || 'sm';
    const showProfile = opts.showProfile !== false;
    const showEdit    = opts.showEdit    !== false;

    const baseSm = 'padding:0 5px; font-size:0.66rem; font-weight:800; '
                 + 'letter-spacing:0.02em; border-radius:3px; line-height:1.35; '
                 + 'white-space:nowrap; border:none; cursor:pointer;';
    const baseMd = 'padding:3px 10px; font-size:0.78rem; font-weight:700; '
                 + 'letter-spacing:0.02em; border-radius:4px; line-height:1.4; '
                 + 'white-space:nowrap; border:none; cursor:pointer;';
    const base = (size === 'md' ? baseMd : baseSm) + (opts.btnBaseStyle || '');

    const keyAttrs = [
      laUid ? `data-la-user-id="${PersonActions.esc(laUid)}"` : '',
      pid   ? `data-person-id="${PersonActions.esc(pid)}"`    : '',
      returnTo ? `data-return-to="${PersonActions.esc(returnTo)}"` : '',
    ].filter(Boolean).join(' ');

    const parts = [];
    if (showProfile) {
      parts.push(
        `<button type="button" class="person-action" data-action="profile" ${keyAttrs}`
        + ` title="View ${PersonActions.esc(name)}"`
        + ` style="${base} background:#0891b2; color:#fff;">View</button>`
      );
    }
    if (showEdit) {
      parts.push(
        `<button type="button" class="person-action" data-action="edit" ${keyAttrs}`
        + ` title="Edit ${PersonActions.esc(name)}"`
        + ` style="${base} background:#f59e0b; color:#111;">Edit</button>`
      );
    }
    return parts.join('');
  }

  static esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  // Install exactly one delegated click listener on `document` that
  // routes every `.person-action` button click through navigation.
  // Capture-phase so we intercept the click BEFORE any per-screen
  // handler (drag-reorder, contact popover, etc.) can consume it.
  // Idempotent — no-op if already installed.
  static installGlobalHandler(navigation) {
    if (window._personActionsInstalled) return;
    window._personActionsInstalled = true;
    document.addEventListener('click', (e) => {
      const btn = e.target && e.target.closest
        ? e.target.closest('.person-action')
        : null;
      if (!btn) return;
      // Stop the click from also triggering the card's own click
      // handler (payments/members drill-down, roster drag-release,
      // etc.).  The action button is authoritative.
      e.preventDefault();
      e.stopPropagation();

      const action   = btn.dataset.action   || 'profile';
      const laUid    = btn.dataset.laUserId || '';
      const pid      = btn.dataset.personId || '';
      const returnTo = btn.dataset.returnTo || '';

      const params = {};
      if (laUid) params.leagueAppsUserId = laUid;
      if (pid)   params.personId = pid;
      if (action === 'edit') params.edit = '1';
      if (returnTo) params.returnTo = returnTo;

      if (navigation && typeof navigation.goTo === 'function') {
        navigation.goTo('person', params);
      } else {
        // Fallback: hash routing.  Only reached if the component was
        // rendered before app bootstrap installed the handler.
        const qs = new URLSearchParams(params).toString();
        window.location.hash = `person${qs ? '?' + qs : ''}`;
      }
    }, true);
  }
}

window.PersonActions = PersonActions;
