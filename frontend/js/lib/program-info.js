// Lighthouse 1893 program description — SINGLE SOURCE OF TRUTH for the
// membership/teams/schedule/billing copy quoted across every surface:
// the Leads screen's "LA Program Description" + "More info" snippets
// (leads.js), and the public program-info pages (public-program-info.js)
// linked from flyer QR codes. Edit copy here — it propagates everywhere
// that calls buildProgramDescription().
window.LighthouseProgramInfo = (function () {
  // Registration links come from the DB (leagueapps_programs.registration_url
  // via GET /api/public/leagueapps-registration-links), not hardcoded here —
  // hardcoded copies of these URLs are what caused APSL Trials / LIGA 1
  // Trials leads to get a bare, non-working link (2026-08-21). REGISTER_LINKS
  // starts empty and is populated by loadRegisterLinks(); callers that need
  // it before render must await that promise first.
  let REGISTER_LINKS = {};
  let registerLinksPromise = null;

  // category ('men'/'women'/'boys'/'girls') -> REGISTER_LINKS key. Only
  // 'active' variant rows are used here — the youth/adult recruiting copy
  // always points at the regular membership, never the pickup tier.
  const CATEGORY_KEY = { men: 'mens', women: 'womens', boys: 'boys', girls: 'girls' };

  function loadRegisterLinks() {
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

  function escapeHtml(str) {
    return String(str == null ? '' : str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  // isYouth / isWomensClub / isMensClub are mutually exclusive; all false
  // falls back to the generic adult-men schedule (Brazil/PR/U23/APSL
  // funnels in leads.js — not currently surfaced on a public page).
  function buildProgramDescription({ isYouth, isWomensClub, isMensClub }) {
    // Only Youth/Men's run on the recurring LeagueApps membership model.
    // Women's Club registration with Lighthouse is free — cost instead
    // comes from per-game ref fees plus a separate league registration
    // (see billingBlock below) — so `monthly` has no meaning there.
    const monthly = '35';
    const membership = isYouth ? "Your player's membership" : 'Your membership';
    const kit = isYouth ? 'their uniform' : 'your uniform';
    // Short cost label for chip/button UI, and a one-line label for
    // register buttons/flyers — single source of truth so every surface
    // (LA Program Description chip, public program page, flyers) quotes
    // the same figure instead of re-deriving it.
    const feeShort = isWomensClub ? 'Free' : `$${monthly}/mo`;
    const feeLabel = isWomensClub
      ? 'Free to register — $35 league fee + refs per game'
      : `$1 to register, then $${monthly}/mo`;

    let practiceBlockHtml, practiceBlockText, gamesLine;
    if (isYouth) {
      practiceBlockHtml =
        `<li><strong>Practice:</strong>` +
          `<ul>` +
            `<li>2nd grade and younger &mdash; Mondays &amp; Wednesdays, 4:30&ndash;5:30pm</li>` +
            `<li>3rd grade and older &mdash; Mondays, Wednesdays &amp; Fridays, 5:30&ndash;7pm</li>` +
          `</ul>` +
        `</li>` +
        `<li><strong>Why multiple days:</strong> We know families are busy, so we offer practice several days a week &mdash; the goal is that every player can make at least one. There's no requirement to attend all of them; come to as many as work for your schedule.</li>`;
      practiceBlockText =
        `  • Practice:\n` +
        `      – 2nd grade and younger — Mondays & Wednesdays, 4:30–5:30pm\n` +
        `      – 3rd grade and older — Mondays, Wednesdays & Fridays, 5:30–7pm\n` +
        `  • Why multiple days: We know families are busy, so we offer practice several days a week — the goal is that every player can make at least one. There's no requirement to attend all of them; come to as many as work for your schedule.\n`;
      gamesLine = 'Sunday mornings to early afternoon';
    } else if (isWomensClub) {
      practiceBlockHtml = '';
      practiceBlockText = '';
      gamesLine = 'Sundays, late morning to early afternoon — September through November, winter break, then resuming late March through June';
    } else {
      practiceBlockHtml =
        `<li><strong>Practice:</strong> Wednesday, Thursday &amp; Friday, 7:00&ndash;8:30pm</li>` +
        `<li><strong>Pickup:</strong> Tuesday, 7:00&ndash;8:30pm; Saturday, 11:00am&ndash;12:30pm</li>` +
        `<li><strong>Purpose of 5 weekly sessions:</strong> Five sessions a week fit real work schedules &mdash; aim for any 2 of the 5 and you're a regular &mdash; and cover all the fitness a player needs. Practices focus on tactical concepts. Pickups focus on creativity and applying those tactical concepts. Both let players work their technical actions in real game environments &mdash; not around a cone that can't defend. Together they cover the four pillars of player development: <strong>technical, tactical, physical, and psychological.</strong></li>`;
      practiceBlockText =
        `  • Practice: Wednesday, Thursday & Friday, 7:00–8:30pm\n` +
        `  • Pickup: Tuesday, 7:00–8:30pm; Saturday, 11:00am–12:30pm\n` +
        `  • Purpose of 5 weekly sessions: Five sessions a week fit real work schedules — aim for any 2 of the 5 and you're a regular — and cover all the fitness a player needs. Practices focus on tactical concepts. Pickups focus on creativity and applying those tactical concepts. Both let players work their technical actions in real game environments — not around a cone that can't defend. Together they cover the four pillars of player development: technical, tactical, physical, and psychological.\n`;
      gamesLine = 'Sundays';
    }
    const outdoorLine = 'Lighthouse Sports Complex, 199 E Erie Avenue, Philadelphia PA 19140';
    const indoorLine = 'Lighthouse Community Center, 141 W Somerset Street, Philadelphia PA 19133';

    let teamsBlockHtml = '';
    let teamsBlockText = '';
    if (isYouth) {
      teamsBlockHtml =
        `<h3>Teams</h3>` +
        `<p><strong>Lighthouse League</strong> is our in-house program &mdash; games played primarily at the Lighthouse fields, with occasional events elsewhere. It's for players and families looking for a <strong>local, low-to-no-travel soccer experience</strong>, and it's open to every member regardless of skill level, age, or experience.</p>` +
        `<p>For players who want to travel to games as part of their season, we also field select travel squads (Fall 2026):</p>` +
        `<ul>` +
          `<li><strong>U8, U10, U12</strong> &mdash; competing in a boys-division travel league. We encourage and have girls playing on these squads while we grow the girls program.</li>` +
        `</ul>` +
        `<p>We add travel teams for additional age bands as interest and readiness grow.</p>`;
      teamsBlockText =
        `TEAMS:\n` +
        `Lighthouse League is our in-house program — games played primarily at the Lighthouse fields, with occasional events elsewhere. It's for players and families looking for a local, low-to-no-travel soccer experience, and it's open to every member regardless of skill level, age, or experience.\n\n` +
        `For players who want to travel to games as part of their season, we also field select travel squads (Fall 2026):\n` +
        `  • U8, U10, U12 — competing in a boys-division travel league. We encourage and have girls playing on these squads while we grow the girls program.\n\n` +
        `We add travel teams for additional age bands as interest and readiness grow.\n\n`;
    } else if (isMensClub) {
      teamsBlockHtml =
        `<h3>Teams</h3>` +
        `<p><strong>Trials have begun</strong> for the <strong>U.S. Open Cup</strong>, <strong>APSL 1st Team</strong>, and <strong>U.S. National Amateur Cup</strong>. Join the Men's Club to be considered.</p>` +
        `<ul>` +
          `<li><strong>U.S. Open Cup</strong> &mdash; the oldest and most prestigious soccer competition in the U.S. (est. 1914). Open, single-elimination &mdash; MLS, USL Championship, USL League One, MLS Next Pro, and qualifying amateur clubs compete for the Lamar Hunt U.S. Open Cup.</li>` +
          `<li><strong>U.S. National Amateur Cup</strong> &mdash; U.S. Soccer's national championship for amateur clubs (est. 1923). Regional qualifiers feed a national bracket to crown the top amateur side in the country.</li>` +
          `<li><strong>APSL (American Premier Soccer League)</strong> &mdash; a national semi-pro league operating below the professional divisions of the U.S. Soccer pyramid (MLS, USL Championship, USL League One). The APSL 1st Team is Lighthouse's pathway into U.S. Open Cup and U.S. National Amateur Cup rosters.</li>` +
        `</ul>` +
        `<p>Our competitive squads (Fall 2026):</p>` +
        `<ul>` +
          `<li><strong>APSL</strong></li>` +
          `<li><strong>Liga 1</strong></li>` +
          `<li><strong>Liga 2</strong></li>` +
        `</ul>` +
        `<p><strong>Lighthouse League</strong> is our in-house program at the Lighthouse fields &mdash; for members who want a <strong>local, low-to-no-travel soccer experience</strong>, and for anyone not selected to a competitive squad. <strong>We don't cut members.</strong></p>`;
      teamsBlockText =
        `TEAMS:\n` +
        `Trials have begun for the U.S. Open Cup, APSL 1st Team, and U.S. National Amateur Cup. Join the Men's Club to be considered.\n` +
        `  • U.S. Open Cup — the oldest and most prestigious soccer competition in the U.S. (est. 1914). Open, single-elimination — MLS, USL Championship, USL League One, MLS Next Pro, and qualifying amateur clubs compete for the Lamar Hunt U.S. Open Cup.\n` +
        `  • U.S. National Amateur Cup — U.S. Soccer's national championship for amateur clubs (est. 1923). Regional qualifiers feed a national bracket to crown the top amateur side in the country.\n` +
        `  • APSL (American Premier Soccer League) — a national semi-pro league operating below the professional divisions of the U.S. Soccer pyramid (MLS, USL Championship, USL League One). The APSL 1st Team is Lighthouse's pathway into U.S. Open Cup and U.S. National Amateur Cup rosters.\n\n` +
        `Our competitive squads (Fall 2026):\n` +
        `  • APSL\n` +
        `  • Liga 1\n` +
        `  • Liga 2\n\n` +
        `Lighthouse League is our in-house program at the Lighthouse fields — for members who want a local, low-to-no-travel soccer experience, and for anyone not selected to a competitive squad. We don't cut members.\n\n`;
    } else if (isWomensClub) {
      teamsBlockHtml =
        `<h3>Teams</h3>` +
        `<p>Our competitive squad (Fall 2026):</p>` +
        `<ul>` +
          `<li><strong>Tri County Women</strong> (Women's Tri County Soccer League, Division 2)</li>` +
        `</ul>`;
      teamsBlockText =
        `TEAMS:\n` +
        `Our competitive squad (Fall 2026):\n` +
        `  • Tri County Women (Women's Tri County Soccer League, Division 2)\n\n`;
    }

    // Membership & Billing — Youth/Men's run on the recurring LeagueApps
    // membership model (card on file, auto-charged monthly). Women's Club
    // registration with Lighthouse is free; cost instead comes from
    // per-game ref fees plus a separate league registration, so it gets
    // its own copy — no card-on-file / auto-charge language applies.
    let membershipBlockHtml, membershipBlockText, billingBlockHtml, billingBlockText;
    if (isWomensClub) {
      membershipBlockHtml =
        `<h3>Membership</h3>` +
        `<p>Registration with Lighthouse is <strong>free</strong> &mdash; there's no LeagueApps membership fee, and ${kit} is supplied at no cost by the club.</p>`;
      membershipBlockText =
        `MEMBERSHIP:\n` +
        `Registration with Lighthouse is free — there's no LeagueApps membership fee, and ${kit} is supplied at no cost by the club.\n\n`;
      billingBlockHtml =
        `<h3>Billing</h3>` +
        `<p>Games cost a few dollars per player to cover referee fees, paid at the field.</p>` +
        `<p>Separately, players register directly with the <strong>Women's Tri County Soccer League</strong> on their site for <strong>$35</strong>.</p>`;
      billingBlockText =
        `BILLING:\n` +
        `Games cost a few dollars per player to cover referee fees, paid at the field.\n\n` +
        `Separately, players register directly with the Women's Tri County Soccer League on their site for $35.\n\n`;
    } else {
      membershipBlockHtml =
        `<h3>Membership</h3>` +
        `<p>For 133 years, Lighthouse has operated on a membership model to build community and belonging &mdash; because a community is stronger when it's organized together. ${membership} runs year-round and covers all four seasons (Winter, Spring, Summer, Fall), training, matches, tournaments, and ${kit}. There are no per-season, per-tournament, indoor, or uniform fees.</p>`;
      membershipBlockText =
        `MEMBERSHIP:\n` +
        `For 133 years, Lighthouse has operated on a membership model to build community and belonging — because a community is stronger when it's organized together. ${membership} runs year-round and covers all four seasons (Winter, Spring, Summer, Fall), training, matches, tournaments, and ${kit}. There are no per-season, per-tournament, indoor, or uniform fees.\n\n`;
      billingBlockHtml =
        `<h3>Billing</h3>` +
        `<p>Registration is $1 at signup. After registration, we send a single prorated invoice covering the rest of the current month.</p>` +
        `<p>From then on, the normal $${monthly}/month membership is invoiced on the <strong>first Friday of each month</strong>.</p>` +
        `<p><strong>Membership requires a valid card on file with sufficient funds</strong> so we can auto-charge monthly dues. Cards saved at registration are charged automatically through LeagueApps and a receipt is emailed for each charge. Members can pause or cancel anytime.</p>`;
      billingBlockText =
        `BILLING:\n` +
        `Registration is $1 at signup. After registration, we send a single prorated invoice covering the rest of the current month.\n\n` +
        `From then on, the normal $${monthly}/month membership is invoiced on the first Friday of each month.\n\n` +
        `Membership requires a valid card on file with sufficient funds so we can auto-charge monthly dues. Cards saved at registration are charged automatically through LeagueApps and a receipt is emailed for each charge. Members can pause or cancel anytime.\n\n`;
    }

    const laDescHtml =
      `<p><strong>Lighthouse 1893</strong> is the oldest nonprofit community organization in Philadelphia, serving the neighborhood for over 133 years. Our mission with soccer is to keep the game <strong>affordable, accessible, local, and high-quality</strong> for every family in our community.</p>` +
      `<p>Our history speaks to that quality. Lighthouse teams have won <strong>5 U-19 national championships</strong> and sent <strong>7 players to the U.S. Soccer Hall of Fame, 2 to the FIFA World Cup, and 4 to the U.S. Olympics</strong> &mdash; and, more importantly, through its <strong>Boys Club, Girls Club, Men's Club, and Women's Club</strong>, Lighthouse has spent 133 years developing generations of neighbors into people of the highest character who go on to serve their families, careers, and communities. <strong>It's a club for life in the neighborhood.</strong> Today, we bring modern coaching and player-development methodology honed over 133 years to every player, from first-time beginners to advanced competitors.</p>` +
      membershipBlockHtml +
      teamsBlockHtml +
      `<h3>Schedule</h3>` +
      `<ul>` +
      practiceBlockHtml +
      `<li><strong>Games:</strong> ${escapeHtml(gamesLine)}</li>` +
      `<li><strong>Home Outdoor Facility:</strong> ${escapeHtml(outdoorLine)}</li>` +
      `<li><strong>Home Indoor Facility:</strong> ${escapeHtml(indoorLine)}</li>` +
      `</ul>` +
      billingBlockHtml +
      `<h3>Changes &amp; questions</h3>` +
      (isWomensClub
        ? `<p>Questions? Email <a href="mailto:soccer@lighthouse1893.org">soccer@lighthouse1893.org</a>.</p>`
        : `<p>To pause or cancel a membership, or ask a question, email <a href="mailto:soccer@lighthouse1893.org">soccer@lighthouse1893.org</a>.</p>`);

    const laDescText =
      `Lighthouse 1893 is the oldest nonprofit community organization in Philadelphia, serving the neighborhood for over 133 years. Our mission with soccer is to keep the game affordable, accessible, local, and high-quality for every family in our community.\n\n` +
      `Our history speaks to that quality. Lighthouse teams have won 5 U-19 national championships and sent 7 players to the U.S. Soccer Hall of Fame, 2 to the FIFA World Cup, and 4 to the U.S. Olympics — and, more importantly, through its Boys Club, Girls Club, Men's Club, and Women's Club, Lighthouse has spent 133 years developing generations of neighbors into people of the highest character who go on to serve their families, careers, and communities. It's a club for life in the neighborhood. Today, we bring modern coaching and player-development methodology honed over 133 years to every player, from first-time beginners to advanced competitors.\n\n` +
      membershipBlockText +
      teamsBlockText +
      `SCHEDULE:\n` +
      practiceBlockText +
      `  • Games: ${gamesLine}\n` +
      `  • Home Outdoor Facility: ${outdoorLine}\n` +
      `  • Home Indoor Facility: ${indoorLine}\n\n` +
      billingBlockText +
      `CHANGES & QUESTIONS:\n` +
      (isWomensClub
        ? `Questions? Email soccer@lighthouse1893.org.`
        : `To pause or cancel a membership, or ask a question, email soccer@lighthouse1893.org.`);

    return { html: laDescHtml, text: laDescText, monthly, feeShort, feeLabel };
  }

  return {
    get REGISTER_LINKS() { return REGISTER_LINKS; },
    loadRegisterLinks,
    buildProgramDescription,
  };
})();
