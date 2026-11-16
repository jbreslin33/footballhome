// ✅ Eligibility — dues flags, starter criteria, RSVP timing, the player's own eligibility box (migs 416, 562)
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterEligibility {
  // Not eligible on dues (migration 416): the roster row's duesEligible.
  // Shown, not hidden, so the coach knows why a player is out.  Copy:
  // message_templates my_dues/lineup_flag.
  _duesFlag(p) {
    if (!p || !window.MessageCopy) return '';
    if (p.duesEligible === false) {
      const text = MessageCopy.block('my_dues', 'lineup_flag');
      if (!text) return '';
      return `<span style="font-size:0.62rem; font-weight:800; padding:1px 6px; border-radius:999px; border:1px solid #ef4444; color:#fca5a5; background:rgba(239,68,68,0.18); white-space:nowrap;">⛔ ${this.escapeHtml(text)}</span>`;
    }
    // Dues alternate (mig 613): amber, never a ban.  The server only sets
    // the flag on rows the viewer may see (coach: all; player: their own),
    // so this never shows on a teammate's card.
    if (this.stats.get(Number(p.id))?.duesAlternate) {
      const text = MessageCopy.block('my_dues', 'alternate_chip');
      if (!text) return '';
      // Coaches: tap the chip → contact sheet on the dues note (mig 687).
      const pid = this.isCoach ? this._personIdFor(p.id) : null;
      return `<span ${pid ? `data-gc-dues-note="${pid}" role="button" title="${this.escapeHtml(this._cm('what_dues'))}" ` : ''}style="${pid ? 'cursor:pointer; ' : ''}font-size:0.62rem; font-weight:800; padding:1px 6px; border-radius:999px; border:1px solid #f59e0b; color:#fcd34d; background:rgba(245,158,11,0.15); white-space:nowrap;">💰 ${this.escapeHtml(text)}</span>`;
    }
    return '';
  }

  _rsvpStatusPill(playerId) {
    const RSVP_PILL = {
      yes:   { label: 'Going',     bg: '#166534', fg: '#bbf7d0' },
      no:    { label: 'Not Going', bg: '#7f1d1d', fg: '#fecaca' },
      maybe: { label: 'Maybe',     bg: '#78350f', fg: '#fde68a' },
      coaching: { label: (window.MessageCopy && MessageCopy.block('my_role', 'choice_coach')) || 'Coaching only', bg: '#1e3a8a', fg: '#bfdbfe' },
    };
    const rsvp = this.stats.get(playerId)?.gameRsvp;
    const v = RSVP_PILL[rsvp] || { label: 'No RSVP', bg: '#374151', fg: '#d1d5db' };
    return `<span title="RSVP for this game" style="font-size:0.6rem; font-weight:700; padding:1px 6px; border-radius:999px; background:${v.bg}; color:${v.fg}; white-space:nowrap;">${v.label}</span>`;
  }

  // What a player reads under the Starters & Bench card: the "not
  // published" notice while no starter is set (byZone.starter.length is
  // the only signal — there is no publish flag), otherwise the
  // alternates, who are not part of the post and so not on the card.
  // Alphabetical by last name, "so no one gets mad" (owner directive).
  // ── Starter eligibility (migration 456) ───────────────────────────────
  // What a player reads at the top of their Game Center: an eligible /
  // not-yet pill, the practices that count for this game (the last N, or
  // the weekday-game extended window), and the ones still ahead with Going
  // / Out buttons so they can fix it right here (owner 2026-09-26: "show
  // pill if player is eligible or not. and show available practices for
  // them to get there … allow them to rsvp to the practice in game center
  // to remedy it").  Every sentence is a message_templates row, kind
  // 'eligibility'.
  _eligCopy(tier, tokens = {}) {
    return window.MessageCopy ? MessageCopy.block('eligibility', tier, tokens) : '';
  }

  // 💰 Dues alternate strip right above the lineup graphic (owner
  // 2026-10-20: "in the lineup graphic like right above it or across it").
  // myPlayerId keys the viewer's OWN stats row — the only non-coach row the
  // server ever flags — so the strip renders for the delinquent player
  // alone, never on a teammate's screen.
  _duesAlternateStripHtml() {
    const s = this.myPlayerId != null ? this.stats.get(this.myPlayerId) : null;
    if (!s || !s.duesAlternate || !window.MessageCopy) return '';
    const amount = s.duesBalanceUsd != null ? `$${Number(s.duesBalanceUsd).toFixed(2)}` : '';
    const text = MessageCopy.block('my_dues', 'alternate_game', { amount });
    if (!text) return '';
    return `<div style="max-width:540px; margin:0 auto 8px; padding:7px 10px; border-radius:8px; border:1px solid rgba(245,158,11,0.6);
                 background:rgba(245,158,11,0.15); color:#fcd34d; font-size:0.72rem; font-weight:700; line-height:1.35;">💰 ${this.escapeHtml(text)}</div>`;
  }

  // Dues alternate (mig 613): the PRIVATE warning on the player's own
  // eligibility card — the owner's "warn them … right on the game".  Only
  // the viewer's own stats row ever carries duesAlternate (server-side),
  // so no teammate reads it.  Copy my_dues/alternate_game, {amount}.
  _duesAlternateBox(s, box) {
    if (!s || !s.duesAlternate || !window.MessageCopy) return '';
    const amount = s.duesBalanceUsd != null ? `$${Number(s.duesBalanceUsd).toFixed(2)}` : '';
    const text = MessageCopy.block('my_dues', 'alternate_game', { amount });
    if (!text) return '';
    return box(MessageCopy.block('my_dues', 'alternate_heading') || '',
      `<div style="font-size:0.78rem; font-weight:600; color:#fcd34d; display:flex; gap:8px; align-items:flex-start;">
         <span style="flex:0 0 auto;">💰</span><span>${this.escapeHtml(text)}</span>
       </div>`);
  }

  // Practice Criteria state for one stats row (mig 457/458): green = met
  // (exceeding when over the minimum, "projected to exceed" when met with
  // more Going ahead), yellow = projected to meet from Going RSVPs, red =
  // short.  The state name is the copy tier suffix: pill_<state> on the
  // viewer's card, row_<state> on the roster list.
  _criteriaState(s) {
    const needed    = s.needed != null ? Number(s.needed) : 2;
    const attended  = Number(s.practicesAttended || 0);
    const projected = Number(s.practicesProjected || 0);
    const remaining = Math.max(0, needed - attended);
    const future    = Array.isArray(s.practices) ? s.practices.filter(p => p.future) : [];
    const GREEN = ['#166534', '#bbf7d0'], YELLOW = ['#854d0e', '#fef08a'], RED = ['#7f1d1d', '#fecaca'];
    let state, colour;
    if (attended > needed)                       { state = 'exceeding';           colour = GREEN; }
    else if (attended === needed && projected)   { state = 'exceeding_projected'; colour = GREEN; }
    else if (attended >= needed)                 { state = 'met';                 colour = GREEN; }
    else if (attended + projected >= needed)     { state = 'projected';           colour = YELLOW; }
    else if (future.length)                      { state = 'needs';               colour = RED; }
    else                                         { state = 'not_met';             colour = RED; }
    const tokens = {
      attended: String(attended), needed: String(needed), remaining: String(remaining),
      plural: remaining === 1 ? '' : 's', projected: String(projected),
      lookback: String(s.lookback != null ? s.lookback : (this.eligibilityPolicy && this.eligibilityPolicy.lookback) || 5),
      // Week rule (mig 562): only the game week's typical practice days
      // count, and the bar drops one per day that didn't happen.
      typical: String(s.typicalDays != null ? s.typicalDays : 5),
      held: String(s.heldDays != null ? s.heldDays : ''),
      missed: String(s.missedDays != null ? s.missedDays : 0),
      base: String(s.baseNeeded != null ? s.baseNeeded : needed),
    };
    return { state, colour, tokens, needed, attended, projected, remaining, future };
  }

  // Game RSVP Criteria for one stats row (mig 507): the game's own RSVP
  // had to be in by its deadline to start — on_time = answered in time (a
  // later change keeps it), pending = not answered, deadline still ahead,
  // late = missed it.  null when no deadline applies to this game or
  // player.  The state is the copy tier suffix: rsvp_pill_<state> /
  // rsvp_row_<state>.
  _rsvpTimingState(s) {
    // pending is red, not yellow: with no answer in, the player is
    // projected NOT eligible (owner 2026-10-01: "i want it clear also even
    // now that a player has no rsvp and thus is projected to be ineligible").
    const COLOURS = { on_time: ['#166534', '#bbf7d0'], pending: ['#7f1d1d', '#fecaca'], late: ['#7f1d1d', '#fecaca'] };
    if (!s || !COLOURS[s.rsvpTiming]) return null;
    const DOW = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const d = s.rsvpDeadlineDay ? new Date(s.rsvpDeadlineDay + 'T12:00:00') : null;
    const day = d && !isNaN(d) ? `${DOW[d.getDay()]} ${d.getMonth() + 1}/${d.getDate()}` : '';
    return { state: s.rsvpTiming, colour: COLOURS[s.rsvpTiming], tokens: { day } };
  }

  // Both criteria rolled into one verdict for the card's header (owner
  // 2026-10-01: "eligibility at top as header"): eligible, projected
  // (yellow — on track if they attend what they said Going to), projected
  // NOT (red — something is still missing but can be fixed), not eligible
  // (red — a criterion can no longer be met).  Copy tier: overall_<state>.
  _overallEligibility(st, rt) {
    const GREEN = ['#166534', '#bbf7d0'], YELLOW = ['#854d0e', '#fef08a'], RED = ['#7f1d1d', '#fecaca'];
    const rsvp = rt ? rt.state : 'on_time';
    const practiceMet = st.attended >= st.needed;
    if (rsvp === 'late' || st.state === 'not_met') return { state: 'not_eligible', colour: RED };
    if (rsvp === 'pending' || st.state === 'needs') return { state: 'projected_not', colour: RED };
    if (practiceMet) return { state: 'eligible', colour: GREEN };
    return { state: 'projected', colour: YELLOW };
  }

  // A player's name marked with that verdict wherever Game Center prints
  // it (owner 2026-10-06: "color names with eligiblity on game center.
  // green if eligible. yellow if projected and red if not projected"):
  // green = criteria met, yellow = projected to meet them, red =
  // projected not to / not eligible.  The name's text takes the colour.
  // On the pitch green letters would vanish into the grass, so there each
  // letter is outlined in white — no box round the name (owner, of
  // highlight boxes: "yikes that looks ugly ... met is green with white
  // border. projected to meet is yellow. projected to not meet is red ...
  // i mean border around each letter not a 'card'").  Red is outlined the
  // same way, being as hard to read on grass; yellow needs none.  ''
  // where there is no verdict — no stats row, or a game everyone plays in.
  _eligVerdict(playerId) {
    if (this.everyonePlays || !this.stats) return null;
    const s = this.stats.get(Number(playerId));
    if (!s) return null;
    return this._overallEligibility(this._criteriaState(s), this._rsvpTimingState(s)).state;
  }

  // The live graphic's names shimmer (owner 11/5: "make the names shimmer
  // on graphic for starters and bench"): a light band sweeps across each
  // name in its eligibility colour (white when there is no verdict).  Only
  // the on-screen card — the html2canvas export draws plain names (live =
  // false), since background-clip:text doesn't survive the capture.
  // Always white since 11/12: the A:/P: + Dues: notes under each name carry
  // the colour now (owner: "now we don't need to color code names right?").
  _cardNameStyle(playerId, { onPitch = false } = {}) {
    GameCenterScreen._shimmerCss();
    const base = '#ffffff';
    const glow = onPitch ? 'filter:drop-shadow(0 0 1px rgba(0,0,0,0.85));' : '';
    return `background-image:linear-gradient(100deg, ${base} 0%, ${base} 40%, #ffffff 50%, ${base} 60%, ${base} 100%);`
      + 'background-size:250% 100%;-webkit-background-clip:text;background-clip:text;'
      + `-webkit-text-fill-color:transparent;color:${base};animation:fhNameShimmer 2.8s linear infinite;${glow}`;
  }

  static _shimmerCss() {
    if (document.getElementById('fh-name-shimmer-css')) return;
    const st = document.createElement('style');
    st.id = 'fh-name-shimmer-css';
    st.textContent = '@keyframes fhNameShimmer{0%{background-position:100% 0}100%{background-position:0% 0}}'
      + '@media (prefers-reduced-motion: reduce){[style*="fhNameShimmer"]{animation:none!important}}';
    document.head.appendChild(st);
  }

  _eligNameStyle(playerId, { onPitch = false } = {}) {
    const v = this._eligVerdict(playerId);
    if (!v) return '';
    const tone = v === 'eligible' ? 'green' : v === 'projected' ? 'yellow' : 'red';
    // Eligible = bright yellow, no edge (owner 11/5, after white / blue /
    // gold tries: "make names brighter yellow and no border").  Projected
    // names are the duller #facc15; red still warns.
    if (tone === 'green') return 'color:#ffea00;';
    if (onPitch) {
      // text-shadow all round rather than -webkit-text-stroke, which eats
      // into letters this small.
      const outline = 'text-shadow:-1px -1px 0 #fff,1px -1px 0 #fff,-1px 1px 0 #fff,1px 1px 0 #fff,0 -1px 0 #fff,0 1px 0 #fff,-1px 0 0 #fff,1px 0 0 #fff;';
      return { green: `color:#22c55e;${outline}`, yellow: 'color:#facc15;', red: `color:#b91c1c;${outline}` }[tone];
    }
    return `color:${{ green: '#4ade80', yellow: '#facc15', red: '#f87171' }[tone]};`;
  }

  // A:1 P:1 / Dues:52 under each name on the on-screen lineup graphic (owner
  // 2026-11-12: "show on players number of practices made and projected …
  // everyone can see in lineup graphic (not for insta though) also for me i
  // need to know dues owed. dues:0, dues:52" / "only admin see dues").
  //   A:1 P:1 — practices Attended + Projected (said Going to); the total
  //             is read off them (owner: "A:1,P:1 its inferred 2") — everyone;
  //             not in an everyone-plays game, which has no criterion
  //   Dues:52 — dues owed (club admins only: PersonStanding is admin-gated
  //              by /api/payments/standing, and the role check hides it from
  //              view-as and the #my door too)
  // The post never carries it — only the live card (live = true) asks.
  // Words: eligibility tiers lineup_note_practice / lineup_note_dues (mig 1299).
  _lineupNote(playerId) {
    const bits = [];
    const s = !this.everyonePlays && this.stats ? this.stats.get(Number(playerId)) : null;
    if (s) {
      const st = this._criteriaState(s);
      // P: = the week's total, attended + projected (owner 2026-11-12:
      // "P: to be total of A + P … Luke … A:2,P:5"; copy mig 1301).
      const tokens = { attended: String(st.attended), projected: String(st.projected),
                       total: String(st.attended + st.projected), needed: String(st.needed) };
      const text = this._eligCopy('lineup_note_practice', tokens) || `A:${tokens.attended} P:${tokens.total}`;
      // Green = on course for the week (attended + projected ≥ needed;
      // needed is 2 of 5 / 1 of 4 / 0 of 3 practice days), red = not
      // (owner 2026-11-12).
      const onCourse = st.attended + st.projected >= st.needed;
      bits.push(`<span title="${this.escapeHtml(this._eligCopy('row_' + st.state, st.tokens) || '')}" style="color:${onCourse ? '#4ade80' : '#f87171'};">${this.escapeHtml(text)}</span>`);
    }
    const d = this._canPostSocial() && window.PersonStanding && PersonStanding.dues
      ? PersonStanding.dues(this._personIdFor(playerId)) : null;
    if (d) {
      const owed = d.free_reason || !d.member ? 0 : Math.max(0, Math.round(Number(d.balance) || 0));
      const amount = String(owed);
      const text = this._eligCopy('lineup_note_dues', { amount }) || `Dues:${amount}`;
      // Green under one month's dues, red at a month or more (owner
      // 2026-11-12: "green if under 35 … red if 35 or more"); the rate is
      // the dues_policies row (MessageCopy.duesPolicy), never a literal.
      const rate = Number(window.MessageCopy && MessageCopy.duesPolicy && MessageCopy.duesPolicy.monthlyDuesUsd);
      const behind = rate > 0 ? owed >= rate : owed > 0;
      bits.push(`<span style="color:${behind ? '#f87171' : '#4ade80'};">${this.escapeHtml(text)}</span>`);
    }
    if (!bits.length) return '';
    return `<div style="font-size:11px;font-weight:700;line-height:1.15;color:rgba(255,255,255,0.85);text-align:center;white-space:nowrap;display:inline-flex;gap:5px;justify-content:center;">${bits.join('')}</div>`;
  }

  // The verdict in words, as the name's tooltip (copy tier overall_<state>).
  _eligNameTitle(playerId) {
    const v = this._eligVerdict(playerId);
    const text = v ? this._eligCopy('overall_' + v) : '';
    return text ? `title="${this.escapeHtml(text)}" ` : '';
  }

  // Everyone's Practice Criteria under the card (owner 2026-09-26: "full
  // detail of everyone but themselves criteria status should be
  // highlighted").  Alphabetical by last name, the viewer's own row lit.
  _renderRosterCriteria() {
    if (!this.roster || !this.roster.length || !this.stats.size) return '';
    const heading = this._eligCopy('roster_heading');
    const rows = [...this.roster]
      .filter(p => this.stats.has(Number(p.id)))
      .sort((a, b) => (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase()));
    if (!rows.length) return '';
    const html = rows.map(p => {
      const s = this.stats.get(Number(p.id));
      const st = this._criteriaState(s);
      const text = this._eligCopy('row_' + st.state, st.tokens);
      const mine = this.myPlayerId != null && Number(p.id) === this.myPlayerId;
      const [bg, fg] = st.colour;
      const rt = this._rsvpTimingState(s);
      const rtText = rt ? this._eligCopy('rsvp_row_' + rt.state, rt.tokens) : '';
      const pill = (label, [pbg, pfg]) => `<span style="padding:2px 9px; border-radius:999px; background:${pbg}; color:${pfg}; font-size:0.68rem; font-weight:700; white-space:nowrap;">${this.escapeHtml(label)}</span>`;
      return `<div style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding:7px var(--space-3); border-bottom:1px solid var(--border-color);
                          ${mine ? 'background:rgba(96,165,250,0.12); box-shadow:inset 3px 0 0 #60a5fa;' : ''}">
        <span ${this._eligNameTitle(p.id)}style="font-size:0.9rem; ${mine ? 'font-weight:700;' : ''} ${this._eligNameStyle(p.id)}">${this.escapeHtml(p.name)}${mine ? ' <span style="font-size:0.65rem; opacity:0.7;">(you)</span>' : ''}</span>
        <span style="flex:0 1 auto; display:flex; flex-wrap:wrap; justify-content:flex-end; gap:4px;">${pill(text || st.state, [bg, fg])}${rtText ? pill(rtText, rt.colour) : ''}</span>
      </div>`;
    }).join('');
    return `
      <details data-ec-fold="criteria" ${this.foldOpen('criteria') ? 'open' : ''} style="max-width:540px; margin:0 auto var(--space-3);">
        <summary style="cursor:pointer; margin: var(--space-3) 0 4px; font-size:0.8rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.8;">${this.escapeHtml(heading || '')} (${rows.length})</summary>
        <div style="border-top:1px solid var(--border-color); border-radius:4px; overflow:hidden;">${html}</div>
      </details>`;
  }

  _renderMyEligibility() {
    if (this.myPlayerId == null) return '';
    const s = this.stats.get(this.myPlayerId);
    if (!s || !Array.isArray(s.practices)) return '';
    const future    = s.practices.filter(p => p.future);
    const DOW = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const when = (p) => {
      const d = new Date(p.startsAt || p.date);
      if (isNaN(d)) return '';
      const h = d.getHours(), m = d.getMinutes();
      const t = `${((h + 11) % 12) + 1}${m ? ':' + String(m).padStart(2, '0') : ''} ${h < 12 ? 'AM' : 'PM'}`;
      return `${DOW[d.getDay()]} ${d.getMonth() + 1}/${d.getDate()} ${t}`;
    };
    const st = this._criteriaState(s);
    const { tokens } = st;
    tokens.cutoff = s.cutoff ? (() => { const d = new Date(s.cutoff + 'T12:00:00'); return `${DOW[d.getDay()]} ${d.getMonth() + 1}/${d.getDate()}`; })() : '';
    const [bg, fg] = st.colour;
    const pillText = this._eligCopy('pill_' + st.state, tokens);
    if (!pillText) return '';   // no copy row → nothing to say (never hard-code it)
    // Week rule (migs 562/804/805): its own explainer — a weekday game
    // this week (none needed), practice days − 3, or none needed.
    // neededReason (mig 806) names the rule fh_starter_needed applied.
    const rule = s.weekMode
      ? this._eligCopy(s.neededReason === 'weekday_game' ? 'rule_week_weekday_game'
          : st.needed === 0 ? 'rule_week_zero'
          : (s.neededReason !== 'days' && Number(s.missedDays) > 0) ? 'rule_week_reduced' : 'rule_week', tokens)
      : this._eligCopy(s.extended ? 'rule_extended' : 'rule', tokens);
    const legend = this._eligCopy('legend');
    // The second criterion: the game's own RSVP in by its deadline (mig 507).
    const rt = this._rsvpTimingState(s);
    const rtPill = rt ? this._eligCopy('rsvp_pill_' + rt.state, rt.tokens) : '';
    const rtRule = rt ? this._eligCopy('rsvp_rule', rt.tokens) : '';

    const chip = (p) => {
      const ok = !!p.attended;
      const label = when(p).replace(/ \d+(:\d+)? [AP]M$/, '');
      // 'Excused' counts toward the criterion (mig 563) but is named, not
      // passed off as Present — the coach marked an absolved absence.
      const status = p.future ? (ok ? 'Going' : (p.rsvp === 'no' ? 'Out' : 'No answer'))
                              : (p.status === 'excused' ? 'Excused' : ok ? 'Present' : 'Absent');
      return `<span title="${this.escapeHtml(status)}" style="display:inline-flex; flex-direction:column; align-items:center; gap:1px; min-width:52px; padding:4px 6px; border-radius:8px; font-size:0.62rem;
        background:${ok ? 'rgba(34,197,94,0.18)' : 'rgba(239,68,68,0.14)'}; border:1px solid ${ok ? '#22c55e' : '#ef4444'}; ${p.future ? 'opacity:0.8;' : ''}">
        <span style="font-weight:700;">${this.escapeHtml(label)}</span><span>${p.future ? '📅 ' : ''}${this.escapeHtml(status)}</span></span>`;
    };
    const remedy = future.length
      ? future.map(p => {
          const going = p.rsvp === 'yes', out = p.rsvp === 'no';
          const b = (resp, on, label, onBg) => `<button type="button" data-elig-rsvp="${resp}" data-fh-event-id="${p.fhEventId}"
              style="padding:4px 10px; border-radius:999px; border:1px solid ${on ? onBg : 'var(--border-color)'}; background:${on ? onBg : 'transparent'};
                     color:${on ? '#fff' : 'var(--text-primary)'}; font-size:0.72rem; font-weight:700; cursor:pointer;">${label}</button>`;
          return `<div style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding:6px 0; border-top:1px solid var(--border-color);">
            <div style="min-width:0;">
              <div style="font-size:0.82rem; font-weight:600;">${this.escapeHtml(when(p))}</div>
              ${p.location ? `<div style="font-size:0.68rem; opacity:0.65; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${this.escapeHtml(p.location)}</div>` : ''}
            </div>
            <div style="display:flex; gap:6px; flex:0 0 auto;">${b('yes', going, 'Going', '#166534')}${b('no', out, 'Out', '#7f1d1d')}</div>
          </div>`;
        }).join('')
      : `<div style="font-size:0.78rem; opacity:0.7; padding:4px 0;">${this.escapeHtml(this._eligCopy('remedy_none'))}</div>`;

    // The game's own Going / Out, so a missing answer is fixed right here.
    const gameRemedy = (() => {
      if (!rt || !s.gameFhEventId) return '';
      const going = s.gameRsvp === 'yes', out = s.gameRsvp === 'no';
      const b = (resp, on, label, onBg) => `<button type="button" data-elig-rsvp="${resp}" data-fh-event-id="${s.gameFhEventId}"
          style="padding:4px 10px; border-radius:999px; border:1px solid ${on ? onBg : 'var(--border-color)'}; background:${on ? onBg : 'transparent'};
                 color:${on ? '#fff' : 'var(--text-primary)'}; font-size:0.72rem; font-weight:700; cursor:pointer;">${label}</button>`;
      return `<div style="display:flex; justify-content:space-between; align-items:center; gap:8px; padding-top:8px; margin-top:8px; border-top:1px solid var(--border-color);">
        <div style="font-size:0.82rem; font-weight:600;">${this.escapeHtml(this._eligCopy('rsvp_remedy_heading'))}</div>
        <div style="display:flex; gap:6px; flex:0 0 auto;">${b('yes', going, 'Going', '#166534')}${b('no', out, 'Out', '#7f1d1d')}</div>
      </div>`;
    })();
    const overall = this._overallEligibility(st, rt);
    const overallText = this._eligCopy('overall_' + overall.state);
    const box = (heading, inner) => `
        <div style="margin-top:10px; padding:10px; border:1px solid var(--border-color); border-radius:8px;">
          ${heading ? `<div style="font-size:0.68rem; letter-spacing:0.05em; text-transform:uppercase; font-weight:700; opacity:0.8; margin-bottom:6px;">${this.escapeHtml(heading)}</div>` : ''}
          ${inner}
        </div>`;
    const pill = (text, [pbg, pfg], attr = '') => `<div ${attr} style="display:inline-block; padding:4px 12px; border-radius:999px; background:${pbg}; color:${pfg}; font-size:0.8rem; font-weight:700;">${this.escapeHtml(text)}</div>`;

    // Header verdict on top, then one box per criterion (owner 2026-10-01:
    // "2 boxes. one for practice criteria and one for rsvp on time for
    // game and have eligibility at top as header").
    return `
      <details class="public-card" data-gc-eligibility data-ec-fold="my_eligibility" ${this.foldOpen('my_eligibility') ? 'open' : ''} style="max-width:540px; margin:0 auto var(--space-3); padding: var(--space-3);">
        <summary style="cursor:pointer; list-style-position:inside;">
          ${this._eligCopy('card_heading') ? `<span style="font-size:0.8rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.8; margin-right:6px;">${this.escapeHtml(this._eligCopy('card_heading'))}</span>` : ''}
          ${overallText ? pill(overallText, overall.colour, `data-gc-elig-overall="${overall.state}"`) : ''}
        </summary>
        <div data-gc-elig-msg style="font-size:0.72rem; min-height:0;"></div>
        ${this._duesAlternateBox(s, box)}
        ${box(this._eligCopy('practice_box_heading'), `
          ${pill(pillText, [bg, fg])}
          ${rule ? `<div style="font-size:0.72rem; opacity:0.7; margin-top:6px;">${this.escapeHtml(rule)}</div>` : ''}
          ${legend ? `<div style="font-size:0.68rem; opacity:0.6; margin-top:4px; display:flex; gap:6px; align-items:flex-start;">
            <span style="flex:0 0 auto; display:inline-flex; gap:2px; margin-top:2px;"><span style="width:8px;height:8px;border-radius:50%;background:#22c55e;display:inline-block;"></span><span style="width:8px;height:8px;border-radius:50%;background:#eab308;display:inline-block;"></span><span style="width:8px;height:8px;border-radius:50%;background:#ef4444;display:inline-block;"></span></span>
            <span>${this.escapeHtml(legend)}</span></div>` : ''}
          <div style="font-size:0.68rem; letter-spacing:0.05em; text-transform:uppercase; opacity:0.7; margin-top:10px;">${this.escapeHtml(this._eligCopy('window_heading'))}</div>
          <div style="display:flex; flex-wrap:wrap; gap:4px; margin-top:4px;">${s.practices.map(chip).join('')}</div>
          <div style="font-size:0.68rem; letter-spacing:0.05em; text-transform:uppercase; opacity:0.7; margin-top:10px;">${this.escapeHtml(this._eligCopy('remedy_heading'))}</div>
          <div>${remedy}</div>`)}
        ${rtPill ? box(this._eligCopy('rsvp_box_heading'), `
          ${pill(rtPill, rt.colour, `data-gc-rsvp-timing="${rt.state}"`)}
          ${rtRule ? `<div style="font-size:0.72rem; opacity:0.7; margin-top:6px;">${this.escapeHtml(rtRule)}</div>` : ''}
          ${gameRemedy}`) : ''}
      </details>`;
  }

  // Going / Out on a practice inside the eligibility card; tapping the
  // answer already given clears it (like #my).  Re-reads the lineup
  // payload afterwards so the pill and chips reflect the new projection.
  async _setEligibilityRsvp(btn) {
    const fhEventId = Number(btn.dataset.fhEventId);
    const response = btn.dataset.eligRsvp === 'no' ? 'no' : 'yes';
    const s = this.myPlayerId != null ? this.stats.get(this.myPlayerId) : null;
    const p = s && Array.isArray(s.practices) ? s.practices.find(x => Number(x.fhEventId) === fhEventId) : null;
    const isGame = !!(s && Number(s.gameFhEventId) === fhEventId);
    const clearing = isGame ? s.gameRsvp === response : !!(p && p.rsvp === response);
    const payload = { fh_event_id: fhEventId };
    if (!clearing) payload.response = response;
    btn.disabled = true;
    try {
      const res = await this.auth.fetch('/api/calendar/rsvp', {
        method: clearing ? 'DELETE' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      if (data.sms_opt_in && window.SmsOptInAsk) SmsOptInAsk.show(data.sms_opt_in);   // 📲 mig 647
      if (data.reg_ask && window.RegAsk) RegAsk.show(data.reg_ask);   // 📝 mig 725
      const again = await this.auth.fetch(`/api/eligibility/lineup/${this.matchId}`);
      const body = await again.json().catch(() => null);
      if (body && body.success && body.data) {
        this.stats = new Map();
        for (const row of (body.data.rosterStats || [])) this.stats.set(Number(row.playerId), row);
      }
      this._render();
    } catch (err) {
      btn.disabled = false;
      const msg = this.element.querySelector('[data-gc-elig-msg]');
      if (msg) msg.innerHTML = `<span style="color:#f87171;">Could not save: ${this.escapeHtml(err.message)}</span>`;
    }
  }

  _renderPlayerNotes(byZone) {
    if (this.everyonePlays) return this._everyoneNoteHtml();
    if (byZone.starter.length === 0) {
      return `
        <div class="public-card" style="text-align:center; opacity:0.85; padding: var(--space-4);">
          🔒 Game Center not published yet
        </div>`;
    }
    const alternates = [...byZone.alternate].sort((a, b) =>
      (a.lastName || a.name || '').toLowerCase().localeCompare((b.lastName || b.name || '').toLowerCase()));
    if (!alternates.length) return '';
    return `
      <details data-ec-fold="player_alternates" ${this.foldOpen('player_alternates') ? 'open' : ''} style="max-width:540px; margin:0 auto;">
        <summary style="cursor:pointer; margin: var(--space-4) 0 4px; font-size:0.8rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.8;">Alternates (${alternates.length})</summary>
        <div style="border-top:1px solid var(--border-color); border-radius:4px; overflow:hidden;">
          ${alternates.map(p => `
            <div style="padding:8px var(--space-3); border-bottom:1px solid var(--border-color);">
              <span ${this._eligNameTitle(p.id)}style="font-size:0.95em; ${this._eligNameStyle(p.id)}">${this.escapeHtml(p.name)}</span> ${this._duesFlag(p)}
            </div>`).join('')}
        </div>
      </details>`;
  }
}

Mixin.into(GameCenterScreen, GameCenterEligibility);
