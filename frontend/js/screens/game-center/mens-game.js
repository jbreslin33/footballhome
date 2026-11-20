// MensGameScreen — a men's game: the base game (GameCenterScreen) plus the
// practice accountability the men's culture runs on (owner 11/18 "why are
// you not making changes to youth games … this tells me we are not staying
// on oop concepts" → "youth need to extend game and men need to extend game"
// → "each extends game and adds or hides").
//
//   adds    the week's practice criterion on the live card: the base game's
//           box per player with the mini calendar, coloured by the verdict (Starter Eligibility, migs
//           562/805/1497/1504/1505), the explanation box (why this
//           week needs what it needs + the calendar key); the Starter
//           Eligibility panels under the graphic (mine + everyone's)
//
// Picked by GameCenterScreen.stateFor(ev) (a Mens team on the event).
class MensGameScreen extends GameCenterScreen {
  static get STATE() { return 'game-men'; }

  // Under each name: the week as a mini calendar + total (or the words
  // where a row has no practice list).
  // 🪑 Regulars / Reserves (mig 1530): men's games have the second tier.
  _hasReserves() { return true; }

  _practiceNoteBits(playerId) {
    // No criterion on this game → the base game's plain strip.
    if (this.everyonePlays) return super._practiceNoteBits(playerId);
    const out = [];
    const s = this.stats ? this.stats.get(Number(playerId)) : null;
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

  // The box colour for a player on the live card (owner 11/18 "would it help
  // to get rid of player 'circle' and make a 'box' to put the info in" →
  // "practice accountability is critical to our culture … front and center
  // … so players know where they and others stand"): green made it, yellow
  // on pace (made + said Going), red short.  null = no criterion here.
  _lineupBoxColor(playerId) {
    if (this.everyonePlays) return super._lineupBoxColor(playerId);
    const s = this.stats ? this.stats.get(Number(playerId)) : null;
    if (!s) return null;
    const st = this._criteriaState(s);
    return st.attended >= st.needed ? '#4ade80' : st.attended + st.projected >= st.needed ? '#facc15' : '#f87171';
  }

  // The explanation box on the card, the same for everyone (owner 11/18 "we
  // don't need to tell the player in the you section what their status is
  // because it should be in the graphic like others. so its not a you
  // section it should be an explanation section"): WHY the week needs what
  // it needs (you_week_barn on a barn-night week — "barn night is 21+ only
  // … 4-practice week … counts as a practice too" — else you_week_plain),
  // then the key to the boxes (strip_legend).  The week's facts are the
  // same on every row, so any stats row answers.
  _cardLegend() {
    if (this.everyonePlays) return super._cardLegend();
    if (!this.stats || !this.stats.size) return '';
    const s = this.stats.values().next().value;
    const st = this._criteriaState(s);
    const tokens = Object.assign({}, st.tokens, { needed_s: st.needed === 1 ? '' : 's' });
    const barn = Number(tokens.extra) > 0 && /barn night/i.test(tokens.extra_label || '');
    return [this._eligCopy(barn ? 'you_week_barn' : 'you_week_plain', tokens), this._eligCopy('strip_legend')]
      .filter(Boolean).join('\n');
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
