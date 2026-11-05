// SectionContact — the one message list a 📇 Contact popup offers, per
// section (owner 2026-11-03: "all contact pop ups were supposed to be
// consistent within men or boys or girls etc" … "no more ways outside of
// contact button to contact. contact popup is all inclusive").
//
// Every screen that contacts a player builds its popup's messages here,
// so Men's / Women's / Boys / Girls get the same list wherever the
// button sits (#teams, Event Center, Game Center …).  A screen only adds
// its own context message(s) in front — the RSVP reminder for this
// event, the game link — which are preselected; the section list
// follows unchanged:
//
//   💬 Message (hello) · the section's own forms · 🔗 Sign-in link ·
//   👋 Welcome · ✏️ Blank
//
//   mens   → every "Men's Club" registration row (Liga 1 / APSL reg) and
//            📣 Invite to Football Home
//   womens → 📝 Register
//   boys / girls → the "Youth Travel" rows: 📄 docs reminder, then
//            ⚽ Boys AND ⚽ Girls registration (mig 998) — both on every
//            youth card, for when the kid's gender isn't known
//
// All words are message_templates rows (MessageCopy, and kind
// 'registration' through RosterScreenBase.loadCardTemplates).  Call
// SectionContact.load(auth) once before drawing (screens already await
// their copy).  Youth messages go to a parent: recipients carry
// forPersonId = the kid, and the hello names the child.
(function () {
  const REG_CATEGORY = { mens: "Men's Club", boys: 'Youth Travel', girls: 'Youth Travel' };
  const isYouth = (s) => s === 'boys' || s === 'girls';
  const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('contact_popup', tier)) || fb;

  // Normalise the section names screens carry ('Mens', "Men's", 'mens' …).
  function sectionOf(raw) {
    const s = String(raw || '').toLowerCase().replace(/[^a-z]/g, '');
    if (s.startsWith('men')) return 'mens';
    if (s.startsWith('women')) return 'womens';
    if (s.startsWith('boy')) return 'boys';
    if (s.startsWith('girl')) return 'girls';
    return '';
  }

  function load(auth) {
    if (typeof RosterScreenBase === 'undefined' || !auth) return Promise.resolve();
    const cats = [...new Set(Object.values(REG_CATEGORY))];
    return Promise.all(cats.map(c => RosterScreenBase.loadCardTemplates(auth, c).catch(() => [])));
  }

  function regRows(section) {
    const cat = REG_CATEGORY[section];
    if (!cat || typeof RosterScreenBase === 'undefined') return [];
    return RosterScreenBase.cardTemplates(cat) || [];
  }

  async function mint(screen, url, payload, channel) {
    const res = await screen.auth.fetch(url, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload),
    });
    if (!res.ok) throw new Error((await res.text()).slice(0, 200) || `HTTP ${res.status}`);
    const data = await res.json();
    const href = channel === 'email' ? (data.gmail_href || data.mailto_href) : data.sms_href;
    if (!href) throw new Error('No message came back');
    return { ...data, href };
  }

  // The 👋 Welcome (/api/welcomes) — recipient may be a parent;
  // the player is named in the copy.
  function welcomeMessage(screen, playerId, { needsDocs = false, onSent = null } = {}) {
    return {
      key: 'welcome',
      label: cp('msg_welcome', '👋 Welcome'),
      resolve: (r, channel) => mint(screen, '/api/welcomes', {
        person_id: r.personId,
        player_person_id: r.personId !== playerId ? playerId : null,
        channel,
        contact: channel === 'email' ? r.email : r.phone,
        needs_docs: !!needsDocs,
      }, channel),
      onSent,
    };
  }

  // ctx = { screen, playerId, first (the player's first name),
  //         parentFirst (youth: the parent's), needsDocs, onWelcomeSent,
  //         context: [messages first, preselected] }
  function messages(rawSection, ctx = {}) {
    const section = sectionOf(rawSection);
    const first = ctx.first || '';
    // Forms not fetched yet → start it (cached); screens that await load()
    // first never miss them.
    if (REG_CATEGORY[section] && !regRows(section).length && ctx.screen && ctx.screen.auth) load(ctx.screen.auth);
    const list = [...(ctx.context || [])];

    const hello = isYouth(section)
      ? ContactPopup.helloMessage('parent', ctx.parentFirst || '', { child: first })
      : ContactPopup.helloMessage('adult', first);
    if (hello) list.push(hello);

    regRows(section).forEach(x => list.push({ key: `reg:${x.label}`, label: x.label, subject: x.subject, body: x.body }));
    if (section === 'mens') {
      const inv = window.MessageCopy && MessageCopy.render('fh_invite_email', 'adult', { first });
      if (inv) list.push({ key: 'invite', label: cp('msg_invite', '📣 Invite to Football Home'), subject: inv.subject, body: inv.body,
                           smsBody: MessageCopy.block('fh_invite_sms', 'adult', { first }) });
    }
    if (section === 'womens') {
      const reg = window.MessageCopy && MessageCopy.render('womens_register', 'adult', { first });
      if (reg) list.push({ key: 'register', label: cp('msg_register', '📝 Register'), subject: reg.subject, body: reg.body });
    }

    // Sign-in and welcome are minted for a person — none for a contact
    // FH has no person row for (the youth-roster parent from LA).
    if (ctx.playerId) list.push(ContactPopup.signInMessage());
    if (ctx.screen && ctx.playerId) list.push(welcomeMessage(ctx.screen, ctx.playerId, { needsDocs: ctx.needsDocs, onSent: ctx.onWelcomeSent }));
    list.push(ContactPopup.blankMessage());

    const seen = new Set();
    return list.filter(m => m && !seen.has(m.key) && seen.add(m.key));
  }

  // 🎟 Call-up (mig 1068, owner 2026-11-05: "why is the call up not just
  // the contact card with call up message selected"): sending it POSTs the
  // invite — the fh_event_invites row is what lets the call-up see the
  // game — and the server writes the words with the recipient's own
  // sign-in link.  Each parent separately (recipient_person_ids).  'copy'
  // invites and hands back the text for someone with no phone or email.
  function callupMessage(screen, fhEventId, playerId, { resend = false, onSent = null } = {}) {
    return {
      key: 'callup',
      label: resend ? cp('msg_callup_resend', '🎟 Call-up (re-send)') : cp('msg_callup', '🎟 Call up to this game'),
      purpose: `callup:${fhEventId}`,
      copyOk: true,
      resolve: async (r, channel) => {
        const res = await screen.auth.fetch(`/api/calendar/events/${fhEventId}/invites`, {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            person_id: playerId, channel,
            contact: channel === 'email' ? (r.email || '') : channel === 'sms' ? (r.phone || '') : '',
            ...(r.rid ? { recipient_person_ids: [r.rid] } : {}),
          }),
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.message || data.error || `HTTP ${res.status}`);
        const x = (data.sends && data.sends[0]) || data;
        const href = channel === 'email' ? (x.gmail_href || x.mailto_href) : channel === 'sms' ? x.sms_href : '';
        if (channel !== 'copy' && !href) throw new Error('No message came back');
        return { ...x, href };
      },
      onSent,
    };
  }

  // The 📇 button for one call-up row (an open invite or someone who could
  // be invited, GET …/invites): the call-up preselected, then the
  // section's list.  row.recipients = every parent of a kid (mig 682).
  // label: the button's words — '🎟 CALL IN' on an 💤 Inactive card (mig 1076).
  function callupButton(screen, fhEventId, row, { section, resend = false, onSent = null, label = '' } = {}) {
    if (!window.ContactPopup || !fhEventId || !row) return '';
    const pid = Number(row.person_id);
    const name = `${row.first_name || ''} ${row.last_name || ''}`.trim();
    let recipients = (row.recipients || []).map(x => ({
      personId: x.recipient_person_id, rid: x.recipient_person_id, name: x.name || name,
      phone: x.phone || null, email: x.email || null, forPersonId: pid }));
    if (!recipients.length) recipients = [{ personId: pid, rid: null, name, phone: row.phone || null, email: row.email || null, forPersonId: pid }];
    const parentRow = recipients.find(x => x.personId !== pid);
    return ContactPopup.button({
      key: `callup:${fhEventId}:${pid}`, screen, recipients,
      messages: messages(section, {
        screen, playerId: pid, first: row.first_name || '',
        parentFirst: parentRow ? String(parentRow.name || '').split(' ')[0] : '',
        context: [callupMessage(screen, fhEventId, pid, { resend, onSent })],
      }),
      defaultKey: 'callup',
      title: `Contact ${name}`,
      ...(label ? { label } : {}),
    });
  }

  window.SectionContact = { load, messages, sectionOf, isYouth, welcomeMessage, callupMessage, callupButton };
})();
