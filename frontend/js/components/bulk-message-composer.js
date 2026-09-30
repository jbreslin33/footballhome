// BulkMessageComposer ───────────────────────────────────────────────────
//
// The "compose in Football Home, then hand off to Gmail / Messages" box
// behind every bulk ✉ / 💬 button: the roster boards' column and board
// buttons (RosterScreenBase.renderMessageButtons) and Game Center's
// "message the game" buttons (owner 2026-09-30: "email in bulk everyone
// from a game … going, going and undecided, then an all button").  It was
// lifted out of roster-screen-base.js unchanged so both use one box.
//
// Compose in FH, then hand off (owner 2026-08-27: "unless we can make
// message on fh and that gets pasted too?").
//
// The two halves travel by different channels and don't collide:
//   body       → the sms: URL (`sms:?&body=...`, no recipients) or the
//                Gmail compose `body` param.
//   recipients → the clipboard, for the operator to paste into To:.
// The clipboard can only hold one thing, which is exactly why the body
// goes in the URL instead.
//
// `screen` is the calling Screen — the URLs come from its
// buildGmailComposeHref / openGmailCompose / buildSmsComposeHref
// (screen-base.js says why those must not be hand-rolled).  `entry` is
// { scope, preset }, `info` is RosterMessaging.collect()'s result, and
// `onSent(count)` fires once the hand-off has happened.
// ─────────────────────────────────────────────────────────────────────────
(function (global) {
  'use strict';

  // A hidden anchor click: the one way that reliably opens an external
  // scheme (sms:, mailto:) from a button handler on every platform.
  function openExternal(url) {
    const a = document.createElement('a');
    a.href = url;
    a.style.display = 'none';
    document.body.appendChild(a);
    a.click();
    setTimeout(() => a.remove(), 0);
  }

  function open({ screen, entry, kind, info, onSent }) {
    document.querySelectorAll('.rb-msg-overlay').forEach(n => n.remove());

    const isEmail = kind === 'email';
    const count   = isEmail ? info.emails.length : info.phones.length;
    const missing = isEmail ? info.noEmail.length : info.noPhone.length;

    const overlay = document.createElement('div');
    overlay.className = 'rb-msg-overlay';
    overlay.style.cssText =
      'position:fixed; inset:0; z-index:9999; background:rgba(0,0,0,0.55);' +
      'display:flex; align-items:center; justify-content:center; padding:16px;';

    overlay.innerHTML = `
      <div class="rb-msg-panel" style="background:var(--bg-primary,#0f172a); color:inherit; border:1px solid var(--border-color,#334155);
                  border-radius:var(--radius-md,8px); width:min(520px,100%); max-height:90vh; overflow:auto; padding:16px;">
        <div style="display:flex; justify-content:space-between; align-items:baseline; gap:8px; margin-bottom:4px;">
          <strong style="font-size:1rem;">${isEmail ? '✉ Email' : '💬 Text'} — ${entry.preset && entry.preset.label ? `${entry.preset.label}, ` : ''}${entry.scope}</strong>
          <button type="button" data-msg-cancel style="background:none; border:none; color:inherit; font-size:1.2rem; cursor:pointer; opacity:0.7;">×</button>
        </div>
        <div style="font-size:0.8rem; opacity:0.75; margin-bottom:12px;">
          ${count} recipient${count === 1 ? '' : 's'}${isEmail ? ' (BCC)' : ''}${missing ? ` · ${missing} with no ${isEmail ? 'email' : 'number'}` : ''}
        </div>
        ${isEmail ? `
          <input type="text" data-msg-subject value="${(entry.preset && entry.preset.subject) || ((MessageCopy.render('bulk_subject', 'default', { scope: entry.scope }) || {}).subject || '')}"
                 style="width:100%; box-sizing:border-box; margin-bottom:8px; padding:8px; border-radius:6px;
                        border:1px solid var(--border-color,#334155); background:var(--bg-secondary,#1e293b); color:inherit;">
        ` : ''}
        <textarea data-msg-body rows="6" placeholder="Type your message…"
                  style="width:100%; box-sizing:border-box; padding:8px; border-radius:6px; resize:vertical;
                         border:1px solid var(--border-color,#334155); background:var(--bg-secondary,#1e293b); color:inherit;"></textarea>
        ${isEmail ? '' : `
          <div data-msg-count style="font-size:0.72rem; opacity:0.6; margin-top:4px;">0 characters</div>`}
        <div style="font-size:0.75rem; opacity:0.7; margin:12px 0; line-height:1.45;">
          ${isEmail
            ? 'Opens a Gmail draft with your message and the recipients in BCC. Nothing sends until you press Send in Gmail.'
            : `Opens Messages with all ${count} recipient${count === 1 ? '' : 's'} and your text filled in — check the <strong>To:</strong> field looks right, then send. The numbers are also copied, so if the app drops any you can clear To: and paste the full list.`}
        </div>
        <div style="display:flex; gap:8px; justify-content:flex-end;">
          <button type="button" data-msg-cancel
                  style="padding:8px 14px; border-radius:6px; cursor:pointer; border:1px solid var(--border-color,#334155); background:transparent; color:inherit;">Cancel</button>
          <button type="button" data-msg-go
                  style="padding:8px 14px; border-radius:6px; cursor:pointer; border:none; background:#10b981; color:#0f172a; font-weight:700;">
            ${isEmail ? 'Open Gmail draft' : 'Open Messages'}
          </button>
        </div>
      </div>`;

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('[data-msg-cancel]')) { e.preventDefault(); close(); }
    });
    document.addEventListener('keydown', function esc(ev) {
      if (ev.key === 'Escape') { close(); document.removeEventListener('keydown', esc); }
    });

    const bodyEl = overlay.querySelector('[data-msg-body]');
    // A preset seeds the box; it stays fully editable so the operator can
    // add a line before sending.
    if (entry.preset && entry.preset.body) bodyEl.value = entry.preset.body;
    const countEl = overlay.querySelector('[data-msg-count]');
    if (countEl) {
      const updateCount = () => {
        const n = bodyEl.value.length;
        // 160 GSM-7 chars per segment; past that carriers split the send.
        const segs = n === 0 ? 0 : Math.ceil(n / 160);
        countEl.textContent = `${n} character${n === 1 ? '' : 's'}${segs > 1 ? ` · ${segs} texts` : ''}`;
      };
      bodyEl.addEventListener('input', updateCount);
      updateCount();
    }

    overlay.querySelector('[data-msg-go]').addEventListener('click', (e) => {
      e.preventDefault();
      const body = bodyEl.value;

      // Both channels go through the canonical Screen helpers rather
      // than a hand-rolled URL. screen-base.js:20 says why in as many
      // words: these keep getting hand-rolled per screen and keep
      // breaking. Concretely, a hand-rolled Gmail URL misses `tf=1`
      // (without which Gmail silently DROPS bcc and you get a blank
      // compose) and misses the Android mailto: branch (mail.google.com
      // is an Android App Link, and the native app's parser drops bcc).
      if (isEmail) {
        const subject = (overlay.querySelector('[data-msg-subject]') || {}).value
                     || ((MessageCopy.render('bulk_subject', 'default', { scope: entry.scope }) || {}).subject || '');
        const href = screen.buildGmailComposeHref({
          bcc: info.emails.join(','),
          subject,
          body,
        });
        close();
        screen.openGmailCompose(href);
        if (onSent) onSent(info.emails.length);
        return;
      }

      const numbers = info.phones.join(RosterMessaging.PHONE_SEPARATOR);

      // Recipients ride the URL — buildSmsComposeHref's comment notes
      // both Google Messages and iOS Messages take a comma-separated
      // list — so there's nothing to paste in the normal case.
      //
      // The clipboard copy stays as a fallback: a long list is where
      // messaging apps quietly drop recipients, and if that happens the
      // operator can clear To: and paste the full set instead of
      // discovering later that half the parents never got it.
      //
      // ORDER IS LOAD-BEARING (owner 2026-08-27: "it says it copied ...
      // but nothing shows on my phone"). Opening an external scheme
      // needs a live user activation and `await` spends it, so the
      // navigation must fire in this same tick — the same trap
      // boys-roster.js:1133 documents for the PAY button.
      const copyPromise = (navigator.clipboard && navigator.clipboard.writeText)
        ? navigator.clipboard.writeText(numbers).catch(() => {})
        : Promise.resolve();

      openExternal(screen.buildSmsComposeHref({ to: numbers, body }));

      close();
      if (onSent) onSent(info.phones.length);
      copyPromise.then(() => { /* clipboard is a fallback, not the path */ });
    });

    document.body.appendChild(overlay);
    bodyEl.focus();
  }

  global.BulkMessageComposer = { open, openExternal };
})(window);
