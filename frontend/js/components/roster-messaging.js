// RosterMessaging ─────────────────────────────────────────────────────────
//
// Bulk "text everyone / email everyone" for the roster boards (#teams).
// Two scopes, same machinery:
//   • per-team    — the button pair in each team column header
//   • whole board — the button pair in the board toolbar ("ALL BOYS")
//
// Recipient rules (owner, 2026-08-27: "for boys/girls its parents
// obviously"):
//   boys / girls  → the PARENT.  Player phone/email are a fallback only,
//                   matching what the per-card CONTACT button already
//                   does (boys-roster.js renderPlayer).
//   mens / womens → the player themselves.
// Each board supplies that rule via `contactFor(p)`; this module never
// guesses.
//
// ── Why text is clipboard-then-open, not one fat sms: link ───────────────
// An `sms:` URL carrying 38 numbers is handed to the OS and what happens
// next is the device's business.  iOS Messages silently drops recipients
// past a limit, some Android apps take the first handful, desktop Chrome
// ignores it outright.  The failure is invisible: the compose window
// opens looking correct, you send, and you never learn that 12 of 38
// parents got it.  So we copy the deduped list, report the count, and
// open an EMPTY message for the operator to paste into.  One extra tap,
// and the recipient list is visible before sending.  (Owner confirmed
// texting is always from their phone, so the empty-sms: half is a
// no-op on desktop by design.)
//
// ── URL building lives on Screen, not here ───────────────────────────────
// Both handoff URLs are built by Screen.buildGmailComposeHref /
// Screen.buildSmsComposeHref (screen-base.js).  Those carry hard-won
// details this module must not re-derive: Gmail needs `tf=1` or it
// silently drops bcc, and Android needs a mailto: URL because
// mail.google.com is an App Link whose native parser drops bcc too.
// This module only decides WHO is on the list.
// ─────────────────────────────────────────────────────────────────────────
(function (global) {
  'use strict';


  // Digits only, then drop a leading US country code so the same parent
  // stored as "+1 215 555 0100" and "(215) 555-0100" dedupes to one
  // recipient.  Siblings share a parent, so this matters: the Terrero
  // family alone would otherwise be texted three times.
  function normalizePhone(raw) {
    if (!raw || typeof raw !== 'string') return null;
    let d = raw.replace(/\D+/g, '');
    if (d.length === 11 && d.startsWith('1')) d = d.slice(1);
    return d.length === 10 ? d : (d.length >= 7 ? d : null);
  }

  // The form we put on the clipboard.  MUST be dialable and contain no
  // spaces or punctuation beyond a leading '+' (owner 2026-08-27: pasting
  // the display form filled To: but left the app unable to compose).
  // Messaging apps split a pasted recipient list on commas and then
  // parse each entry; an entry like "+1 (215) 555-0100" contains spaces,
  // so it never resolves to a contact chip, the field stays in an
  // invalid state, and the compose box won't take focus.  E.164 digits
  // parse everywhere.
  function dialable(normalized) {
    if (!normalized) return null;
    return normalized.length === 10 ? `+1${normalized}` : `+${normalized}`;
  }

  // No space after the comma — some apps treat ", " as part of the next
  // recipient rather than a separator.
  const PHONE_SEPARATOR = ',';


  function normalizeEmail(raw) {
    if (!raw || typeof raw !== 'string') return null;
    const e = raw.trim().toLowerCase();
    return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(e) ? e : null;
  }

  // players → { phones, emails, reached, missing } with every list
  // deduped and every unreachable player accounted for.  `contactFor`
  // is the board's parent-vs-player rule.
  function collect(players, contactFor) {
    const phones = new Map();   // normalized -> display form
    const emails = new Map();   // normalized -> display form
    const seen   = new Set();   // personId, so a player in two columns counts once
    const noPhone = [];
    const noEmail = [];

    for (const p of (players || [])) {
      if (!p) continue;
      const key = p.personId != null ? `p${p.personId}` : `u${p.leagueAppsUserId || p.fullName}`;
      if (seen.has(key)) continue;
      seen.add(key);

      const c = contactFor(p) || {};
      const ph = normalizePhone(c.phone);
      const em = normalizeEmail(c.email);
      if (ph && !phones.has(ph)) phones.set(ph, dialable(ph));
      if (em && !emails.has(em)) emails.set(em, em);
      if (!ph) noPhone.push(p.fullName || 'unknown');
      if (!em) noEmail.push(p.fullName || 'unknown');
    }

    return {
      phones:  [...phones.values()],
      emails:  [...emails.values()],
      people:  seen.size,
      noPhone,
      noEmail,
    };
  }

  global.RosterMessaging = {
    PHONE_SEPARATOR,
    dialable,
    normalizePhone,
    normalizeEmail,
    collect,
  };
})(window);
