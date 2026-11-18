// MensGameScreen — a men's game: the base game (GameCenterScreen) plus the
// practice accountability the men's culture runs on (owner 11/18 "why are
// you not making changes to youth games … this tells me we are not staying
// on oop concepts" → "youth need to extend game and men need to extend game"
// → "each extends game and adds or hides").
//
//   adds    the week's practice criterion on the live card: a box per player
//           with the mini calendar + total (Starter Eligibility, migs
//           562/805/1497/1504/1505), the viewer's own "You: Made … ·
//           Projected … · Need …" line, the calendar key; the Starter
//           Eligibility panels under the graphic (mine + everyone's)
//
// Picked by GameCenterScreen.stateFor(ev) (a Mens team on the event).
class MensGameScreen extends GameCenterScreen {
  static get STATE() { return 'game-men'; }

  // Under each name: the week as a mini calendar + total (or the words
  // where a row has no practice list).
  _practiceNoteBits(playerId) {
    const out = [];
    const s = !this.everyonePlays && this.stats ? this.stats.get(Number(playerId)) : null;
    if (s) {
      const st = this._criteriaState(s);
      // P: = the week's total, attended + projected (owner 2026-11-12:
      // "P: to be total of A + P … Luke … A:2,P:5"; copy mig 1301).
      // Plain words for the week (owner 11/18 "a simple way to show what
      // practices they made and if they are on pace or made threshold
      // depending on that week"): ✓ Made it (1/1) · On pace · 0/1 · Needs 1.
      // needed is the week's own (barn night counts when attended, mig 1497).
      const made = st.attended >= st.needed;
      const onPace = !made && st.attended + st.projected >= st.needed;
      const left = Math.max(0, st.needed - st.attended - st.projected);
      // "1 of 5" (owner 11/18): made / the week's chances, barn night included.
      const tokens = { attended: String(st.attended), projected: String(st.projected),
                       total: String(st.attended + st.projected), needed: String(st.needed), left: String(left),
                       chances: st.tokens.chances, proj_total: String(st.attended + st.projected) };
      const colour = made ? '#4ade80' : onPace ? '#facc15' : '#f87171';
      const strip = this._weekStripHtml(s, { made, colour, tokens });
      if (strip) out.push(strip);
      else {
        const tier = made ? 'lineup_note_made' : onPace ? 'lineup_note_on_pace' : 'lineup_note_short';
        const text = this._eligCopy(tier, tokens)
          || (made ? `✓ ${tokens.attended} of ${tokens.chances}` : `${tokens.attended} of ${tokens.chances} · need ${tokens.needed}`);
        // Two lines when the copy has a line break: actual, then projected
        // (owner 11/18 "clear … between actual and projected and actual total
        // and projected total for all players").
        out.push(`<span title="${this.escapeHtml(this._eligCopy('row_' + st.state, st.tokens) || '')}" style="color:${colour}; font-weight:700; text-align:center;">${String(text).split('\n').map(l => this.escapeHtml(l)).join('<br>')}</span>`);
      }
    }
    return out;
  }

  // The week as a mini calendar, no words (owner 11/18 "would it be better
  // with a mini calendar on each box with green check mark for made it. and
  // yellow for projected … and total at end either green or yellow or red"
  // → "then we wouldn't need words?").  One cell per day in the week's
  // window (barn night included), weekday letter over a mark:
  //   ✓ green   made (marked present / late / excused)
  //   ● yellow  still ahead, said Going (projected)
  //   ✗ red     said Not going, or said Going and wasn't marked present
  //   · grey    no answer
  // then the total: ✓made/need green, else (made + Going)/need yellow / red.
  // The key is one line on the card (eligibility strip_legend).
  _weekStripHtml(s, { made, colour, tokens }) {
    const list = Array.isArray(s && s.practices) ? s.practices : [];
    if (!list.length) return '';
    const days = new Map();
    for (const p of list) {
      const at = new Date(p.startsAt || p.date);
      if (isNaN(at)) continue;
      const key = at.toLocaleDateString('en-CA', { timeZone: 'America/New_York' });
      if (!days.has(key)) days.set(key, { at, sessions: [] });
      days.get(key).sessions.push(p);
    }
    const cells = [...days.entries()].sort((a, b) => a[0].localeCompare(b[0])).map(([, d]) => {
      const ss = d.sessions;
      const st = ss.some(p => !p.future && p.attended) ? 'made'
        : ss.some(p => p.future && p.rsvp === 'yes') ? 'proj'
        : ss.some(p => p.rsvp === 'no' || (!p.future && p.rsvp === 'yes')) ? 'miss' : 'none';
      const [mark, fg, bg] = { made: ['✓', '#052e16', '#4ade80'], proj: ['●', '#422006', '#facc15'],
                               miss: ['✗', '#fff', '#dc2626'], none: ['·', 'rgba(255,255,255,0.7)', 'rgba(255,255,255,0.18)'] }[st];
      const letter = d.at.toLocaleDateString('en-US', { weekday: 'narrow', timeZone: 'America/New_York' });
      const kinds = [...new Set(ss.map(p => p.kind).filter(Boolean))].join(', ');
      return `<span title="${this.escapeHtml(`${d.at.toLocaleDateString('en-US', { weekday: 'short', month: 'numeric', day: 'numeric', timeZone: 'America/New_York' })} ${kinds}`)}" style="display:inline-flex; flex-direction:column; align-items:center; gap:1px;">
          <span style="font-size:8px; font-weight:800; opacity:0.75; line-height:1;">${this.escapeHtml(letter)}</span>
          <span style="width:14px; height:14px; border-radius:3px; background:${bg}; color:${fg}; font-size:10px; font-weight:900; line-height:14px; text-align:center;">${mark}</span>
        </span>`;
    }).join('');
    const total = made ? `✓${tokens.attended}/${tokens.needed}` : `${tokens.proj_total}/${tokens.needed}`;
    return `<span style="display:inline-flex; align-items:flex-end; gap:2px;">${cells}
        <span style="margin-left:3px; padding:0 4px; height:14px; line-height:14px; border-radius:3px; background:${colour}; color:#0f172a; font-size:10px; font-weight:900;">${this.escapeHtml(total)}</span></span>`;
  }

  // The box colour for a player on the live card (owner 11/18 "would it help
  // to get rid of player 'circle' and make a 'box' to put the info in" →
  // "practice accountability is critical to our culture … front and center
  // … so players know where they and others stand"): green made it, yellow
  // on pace (made + said Going), red short.  null = no criterion here.
  _lineupBoxColor(playerId) {
    const s = !this.everyonePlays && this.stats ? this.stats.get(Number(playerId)) : null;
    if (!s) return null;
    const st = this._criteriaState(s);
    return st.attended >= st.needed ? '#4ade80' : st.attended + st.projected >= st.needed ? '#facc15' : '#f87171';
  }

  // One line above the lineup, about the viewer only (owner 11/18 "for a
  // player they only need to know about themselves … in a line above the
  // lineup"): You · 0 of 5 · need 1 — the week's chances incl. barn night
  // (mig 1499).  Staff get the per-name notes instead.  Copy: eligibility
  // tiers lineup_you_made / lineup_you_on_pace / lineup_you_short (mig 1500).
  _myPracticeLine() {
    if (this.everyonePlays || this.myPlayerId == null || !this.stats) return '';
    if (this._staffView() || this._canPostSocial()) return '';
    const s = this.stats.get(this.myPlayerId);
    if (!s) return '';
    const st = this._criteriaState(s);
    const made = st.attended >= st.needed;
    const onPace = !made && st.attended + st.projected >= st.needed;
    const tokens = Object.assign({}, st.tokens, { left: String(Math.max(0, st.needed - st.attended - st.projected)),
                                                  proj_total: String(st.attended + st.projected) });
    // {what} names the chances (owner 11/18): "(4 practices + barn night)"
    // or just "practices" — copy tiers chances_extra / chances_plain (mig 1501).
    tokens.what = this._eligCopy(Number(tokens.extra) > 0 ? 'chances_extra' : 'chances_plain', tokens);
    const tier = made ? 'lineup_you_made' : onPace ? 'lineup_you_on_pace' : 'lineup_you_short';
    const text = this._eligCopy(tier, tokens);
    if (!text) return '';   // no copy row → say nothing (never hard-code it)
    const [bg, fg] = made ? ['#166534', '#bbf7d0'] : onPace ? ['#854d0e', '#fef08a'] : ['#7f1d1d', '#fecaca'];
    return `<div data-gc-my-practice style="margin:0 auto; padding:7px 12px; border-radius:10px; background:${bg}; color:${fg}; font-size:14px; font-weight:700; text-align:center;">${String(text).split('\n').map((l, i) => i ? `<div style="font-size:11px; font-weight:600; opacity:0.85; margin-top:2px;">${this.escapeHtml(l)}</div>` : this.escapeHtml(l)).join('')}</div>`;
  }

  _cardLegend() {
    return !this.everyonePlays && this.stats && this.stats.size ? (this._eligCopy('strip_legend') || '') : '';
  }

  // The Starter Eligibility panels join the lineup body (after carpool).
  lineupPlayerPanels(byZone, coach) {
    const list = super.lineupPlayerPanels(byZone, coach);
    const at = list.findIndex(p => p.key === 'carpool') + 1;
    list.splice(at, 0,
      new Panel({ key: 'my_eligibility', applies: (s) => !s.everyonePlays, html: (s) => s._renderMyEligibility() }),
      new Panel({ key: 'roster_criteria', applies: (s) => !s.everyonePlays, html: (s) => s._renderRosterCriteria() }));
    return list;
  }
}

window.MensGameScreen = MensGameScreen;
