// MessageCopy — the browser half of "all messages in the DB".
//
// Owner 2026-09-17: "we need all messages in db no hard code not even for
// nudges."  No outbound wording lives in the screens: a button names a
// (kind, tier), hands over its facts as tokens, and gets subject + body
// back.  The rows are message_templates with client_side = true
// (migration 367), loaded once per session from
// GET /api/messages/templates/copy.
//
// Same syntax as the backend MessageCopy model (migration 366):
//   {token}       the token's value; when empty, the kind='fallback' word
//                 whose tier is the token name ("Hi there,") — or nothing.
//   [[ … ]]       optional section: kept only when every {token} inside
//                 has a value.  Fallback words never apply inside one.
//   {form:<code>} club_forms links — already resolved by the server.
//
// Until load() resolves (or if it fails) render() returns null, and the
// callers draw no button: a message with no copy is never sent.
class MessageCopy {
  static _templates = new Map();   // "kind|tier" -> {subject, body}
  static _promise   = null;
  static outreachEmail = '';       // clubs.outreach_email — Gmail authuser
  // dues_policies (migration 401): the monthly rate and the months-behind
  // pause threshold.  null until load() resolves — callers must not
  // substitute a number of their own.
  static duesPolicy = { monthlyDuesUsd: null, pauseAfterMonths: null };

  static load(auth) {
    if (!MessageCopy._promise) {
      MessageCopy._promise = (async () => {
        try {
          const res = await auth.fetch('/api/messages/templates/copy');
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const payload = await res.json();
          const data = (payload && payload.data) || {};
          MessageCopy._templates = new Map();
          for (const t of (Array.isArray(data.templates) ? data.templates : [])) {
            const key = `${t.kind}|${t.tier}`;
            // First row per (kind, tier) wins — the server sorts them.
            if (!MessageCopy._templates.has(key)) {
              MessageCopy._templates.set(key, { subject: t.subject || '', body: t.body || '' });
            }
          }
          MessageCopy.outreachEmail = data.outreach_email || '';
          const dp = data.dues_policy || {};
          MessageCopy.duesPolicy = {
            monthlyDuesUsd:   Number.isFinite(Number(dp.monthly_dues_usd))   ? Number(dp.monthly_dues_usd)   : null,
            pauseAfterMonths: Number.isFinite(Number(dp.pause_after_months)) ? Number(dp.pause_after_months) : null,
          };
        } catch (err) {
          console.warn('message copy unavailable:', err);
          MessageCopy._promise = null;   // retry on the next screen load
        }
      })();
    }
    return MessageCopy._promise;
  }

  static has(kind, tier) { return MessageCopy._templates.has(`${kind}|${tier}`); }

  // The kind='sms_link_hint' sentence, '' until loaded.
  static get smsLinkHint() {
    const t = MessageCopy._templates.get('sms_link_hint|all');
    return t ? t.body : '';
  }

  // The body of a row on its own — '' when missing/inactive.
  static block(kind, tier, tokens = {}) {
    const r = MessageCopy.render(kind, tier, tokens);
    return r ? r.body : '';
  }

  // → {subject, body} or null when the row is missing.
  static render(kind, tier, tokens = {}) {
    const t = MessageCopy._templates.get(`${kind}|${tier}`);
    if (!t) return null;
    return { subject: MessageCopy._fill(t.subject, tokens), body: MessageCopy._fill(t.body, tokens) };
  }

  // Fill free-standing text with the same syntax — for copy that was
  // rendered once with some tokens left in place (the #leads chips keep
  // {first} until a lead is known).
  static fill(text, tokens = {}) { return MessageCopy._fill(text, tokens); }

  static _fill(text, tokens) {
    const val = (name) => {
      const v = tokens[name];
      return v == null ? '' : String(v);
    };
    const names = Object.keys(tokens);
    // 1. Optional sections.
    let out = String(text || '').replace(/\[\[([\s\S]*?)\]\]/g, (_, inner) => {
      const missing = names.some(n => inner.includes(`{${n}}`) && !val(n));
      if (missing) return '';
      return names.reduce((s, n) => s.split(`{${n}}`).join(val(n)), inner);
    });
    // 2. Everything else, with the DB's fallback word for an empty value.
    for (const n of names) {
      if (!out.includes(`{${n}}`)) continue;
      const fb = MessageCopy._templates.get(`fallback|${n}`);
      out = out.split(`{${n}}`).join(val(n) || (fb ? fb.body : ''));
    }
    // A dropped section leaves blank lines behind.  Leading/trailing
    // newlines are kept on purpose: CONTACT openers end with a blank line
    // for the admin to type under.
    return out.replace(/\n{3,}/g, '\n\n');
  }
}

window.MessageCopy = MessageCopy;
