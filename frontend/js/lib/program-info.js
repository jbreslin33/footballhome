// Lighthouse 1893 program description — the membership / teams / schedule /
// billing copy quoted by the Leads screen's "LA Program Description" +
// "More info" snippets (leads.js), #flyers, and the public program-info
// pages (public-program-info.js) linked from flyer QR codes.
//
// No wording lives here (owner 2026-09-17: "all messages in db").  The copy
// is message_templates rows flagged is_public (migration 370), served
// without a login by GET /api/public/program-copy.  Change the wording by
// migration.  This file loads the rows, picks the audience's, and turns
// the rows' small markup into HTML and plain text:
//   ### Heading      - bullet        (two spaces)- sub-bullet
//   **bold**         blank line = new paragraph
window.LighthouseProgramInfo = (function () {
  // Registration links come from the DB (leagueapps_programs.registration_url
  // via GET /api/public/leagueapps-registration-links), not hardcoded here —
  // hardcoded copies of these URLs are what caused APSL Trials / LIGA 1
  // Trials leads to get a bare, non-working link (2026-08-21). REGISTER_LINKS
  // starts empty and is populated by loadRegisterLinks(); callers that need
  // it before render must await that promise first.
  let REGISTER_LINKS = {};
  let registerLinksPromise = null;
  let COPY = new Map();            // "kind|tier" -> body
  let outreachEmail = '';
  let copyPromise = null;

  // category ('men'/'women'/'boys'/'girls') -> REGISTER_LINKS key. Only
  // 'active' variant rows are used here — the youth/adult recruiting copy
  // always points at the regular membership, never the pickup tier.
  const CATEGORY_KEY = { men: 'mens', women: 'womens', boys: 'boys', girls: 'girls' };

  function loadLinks() {
    if (!registerLinksPromise) {
      registerLinksPromise = fetch('/api/public/leagueapps-registration-links')
        .then(res => {
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          return res.json();
        })
        .then(payload => {
          const rows = payload && payload.data ? payload.data : [];
          const links = {};
          for (const row of rows) {
            if (row.variant !== 'active') continue;
            const key = CATEGORY_KEY[row.category];
            if (key) links[key] = row.registrationUrl;
          }
          REGISTER_LINKS = links;
          return REGISTER_LINKS;
        })
        .catch(err => {
          console.error('Failed to load LeagueApps registration links:', err);
          return REGISTER_LINKS;
        });
    }
    return registerLinksPromise;
  }

  function loadCopy() {
    if (!copyPromise) {
      copyPromise = fetch('/api/public/program-copy')
        .then(res => {
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          return res.json();
        })
        .then(payload => {
          const data = (payload && payload.data) || {};
          const copy = new Map();
          for (const t of (Array.isArray(data.templates) ? data.templates : [])) {
            const key = `${t.kind}|${t.tier}`;
            if (!copy.has(key)) copy.set(key, t.body || '');
          }
          COPY = copy;
          outreachEmail = data.outreach_email || '';
        })
        .catch(err => {
          console.error('Failed to load program copy:', err);
          copyPromise = null;   // retry on the next screen load
        });
    }
    return copyPromise;
  }

  // Every caller already awaits this before it renders, so it brings the
  // copy along with the links.  Resolves to REGISTER_LINKS.
  function loadRegisterLinks() {
    return Promise.all([loadLinks(), loadCopy()]).then(() => REGISTER_LINKS);
  }

  function escapeHtml(str) {
    return String(str == null ? '' : str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  // Same {token} / [[optional section]] syntax as MessageCopy — which may
  // not be loaded on a public page, so the few lines live here too.
  function fill(text, tokens) {
    const names = Object.keys(tokens);
    const val = (n) => (tokens[n] == null ? '' : String(tokens[n]));
    let out = String(text || '').replace(/\[\[([\s\S]*?)\]\]/g, (_, inner) => {
      if (names.some(n => inner.includes(`{${n}}`) && !val(n))) return '';
      return names.reduce((s, n) => s.split(`{${n}}`).join(val(n)), inner);
    });
    for (const n of names) out = out.split(`{${n}}`).join(val(n));
    return out;
  }

  // The first row of `kind` under the audience's tiers, filled — '' if none.
  function row(kind, tiers, tokens) {
    for (const tier of tiers) {
      if (COPY.has(`${kind}|${tier}`)) return fill(COPY.get(`${kind}|${tier}`), tokens);
    }
    return '';
  }

  // **bold** and e-mail addresses inside one line of markup.
  function inlineHtml(line) {
    return escapeHtml(line)
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/[\w.+-]+@[\w-]+(?:\.[\w-]+)+/g, (m) => {
        const addr = m.replace(/\.$/, '');
        return `<a href="mailto:${addr}">${addr}</a>${m.slice(addr.length)}`;
      });
  }
  const inlineText = (line) => line.replace(/\*\*(.+?)\*\*/g, '$1');

  // markup -> { html, text }
  function renderMarkup(src) {
    const html = [];
    const text = [];
    let depth = 0;                       // open <ul> levels
    let openLi = false;
    const closeLists = (to = 0) => {
      while (depth > to) {
        if (openLi) html.push('</li>');
        html.push('</ul>');
        depth--;
        openLi = depth > 0;
      }
    };
    for (const raw of String(src || '').split('\n')) {
      const line = raw.replace(/\s+$/, '');
      const bullet = /^( *)- (.*)$/.exec(line);
      if (bullet) {
        const level = bullet[1].length >= 2 ? 2 : 1;
        if (level > depth) { html.push('<ul>'); depth++; openLi = false; }
        else {
          closeLists(level);
          if (openLi) html.push('</li>');
        }
        html.push(`<li>${inlineHtml(bullet[2])}`);
        openLi = true;
        text.push((level === 2 ? '      – ' : '  • ') + inlineText(bullet[2]));
        continue;
      }
      closeLists();
      if (!line) { if (text.length && text[text.length - 1] !== '') text.push(''); continue; }
      const heading = /^### (.*)$/.exec(line);
      if (heading) {
        html.push(`<h3>${inlineHtml(heading[1])}</h3>`);
        text.push(`${heading[1].toUpperCase()}:`);
      } else {
        html.push(`<p>${inlineHtml(line)}</p>`);
        text.push(inlineText(line));
      }
    }
    closeLists();
    return { html: html.join(''), text: text.join('\n').trim() };
  }

  // isYouth / isWomensClub / isMensClub are mutually exclusive; all false
  // is the generic adult-men description (Brazil/PR/U23/APSL funnels in
  // leads.js — not currently surfaced on a public page).  Everything is ''
  // until loadRegisterLinks() has resolved.
  function buildProgramDescription({ isYouth, isWomensClub, isMensClub }) {
    const tiers = isYouth ? ['youth', 'all']
      : isWomensClub ? ['women', 'all']
      : isMensClub ? ['men', 'adult', 'all']
      : ['adult', 'all'];
    const tokens = {
      outreach_email: outreachEmail,
      fee:            row('lead_fee', tiers, {}),
      pricing:        row('lead_pricing', tiers, {}),
      venue_outdoor:  row('lead_venue', ['outdoor'], {}),
      venue_indoor:   row('lead_venue', ['indoor'], {}),
    };
    // Small facts first — the blocks quote them, the skeleton quotes the blocks.
    for (const kind of ['program_member', 'program_kit', 'program_fee_short', 'program_games']) {
      tokens[kind] = row(kind, tiers, tokens);
    }
    for (const kind of ['program_intro', 'program_membership', 'program_teams',
                        'program_schedule', 'program_billing', 'program_changes']) {
      tokens[kind] = row(kind, tiers, tokens);
    }
    const { html, text } = renderMarkup(row('program_description', tiers, tokens));
    return {
      html,
      text,
      feeShort: tokens.program_fee_short,
      feeLabel: row('program_fee_label', tiers, tokens),
    };
  }

  // One public page whose whole body is a single is_public row of `kind`
  // (tier 'all') — the legal pages footballhome.org/privacy and /terms
  // (migration 420, frontend/legal.html).  Resolves to { html, text }.
  function buildPublicPage(kind) {
    return loadCopy().then(() => renderMarkup(row(kind, ['all'], { outreach_email: outreachEmail })));
  }

  return {
    get REGISTER_LINKS() { return REGISTER_LINKS; },
    loadRegisterLinks,
    buildProgramDescription,
    buildPublicPage,
  };
})();
