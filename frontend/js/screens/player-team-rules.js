// PlayerTeamRulesScreen — simple static player-facing team rules view.
class PlayerTeamRulesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-player-team-rules';
    el.innerHTML = `
      <div class="screen-header" style="padding: 6px 10px 8px; gap: 8px; align-items:center; flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn" style="padding: 3px 7px; line-height:1;">←</button>
        <div>
          <h1 style="font-size: 0.95rem; margin: 0; line-height:1;">Team Rules</h1>
          <p class="subtitle" style="margin: 2px 0 0; font-size: 0.68rem; line-height:1;">Season expectations and selection policy</p>
        </div>
      </div>

      <div style="padding: 0 10px 14px; line-height: 1.5;">
        <div style="background: linear-gradient(135deg, rgba(255,255,255,0.04), rgba(255,255,255,0.02)); border: 1px solid var(--color-border); border-radius: var(--radius-md); padding: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.16);">
          <div style="display:flex; align-items:flex-start; gap:8px; margin-bottom: 10px; padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.12);">
            <div style="font-size: 1rem; line-height: 1;">⚽</div>
            <div>
              <p style="margin: 0 0 4px; font-weight: 700;">Hi Team,</p>
              <p style="margin: 0; font-size: 0.82rem; opacity: 0.82;">A clear guide for the week ahead — practice, roster decisions, and availability.</p>
            </div>
          </div>

          <div style="background: rgba(251, 191, 36, 0.1); border: 1px solid rgba(251, 191, 36, 0.24); border-radius: 10px; padding: 10px; margin-bottom: 10px;">
            <p style="margin: 0; font-size: 0.82rem;">Please review the rules below for weekly selection, availability, and long-term team expectations.</p>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">1. Dues</h2>
            <p style="margin: 0 0 8px;"><strong>Dues are $35/month.</strong> Dues are due on the <strong>1st Friday of each month</strong>.</p>
            <p style="margin: 0 0 8px;">Starting on the <strong>2nd Friday of each month</strong>, a <strong>$5 late charge</strong> will be added to the invoice if the card fails or dues are not paid.</p>
            <p style="margin: 0 0 8px;">If a player cannot pay dues in full, there are alternatives available, including but not limited to <strong>coaching youth players before men’s practice at Lighthouse</strong>, <strong>coaching youth games</strong>, <strong>team manager duties</strong>, <strong>practice assistant</strong> responsibilities, such as arriving early to practice and helping set up the session, and <strong>social media assistant</strong> responsibilities.</p>
            <p style="margin: 0;"><strong>Please make sure a valid credit card is on file.</strong></p>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">2. Etiquette</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Only the captain may discuss calls with referees.</strong> Players who speak to the referees without being the captain will be <strong>immediately benched</strong>.</li>
              <li><strong>Players are not to ask during matches about their own playing time.</strong> When called to the bench, players should not show disrespect to the player coming on by questioning the decision.</li>
              <li><strong>Respect all levels of play.</strong> Players should be respectful of the different ability levels at the club, and that expectation goes both ways. Players should not complain about another player’s ability level.</li>
              <li><strong>Training focus will vary.</strong> Players should understand that higher-level players may be the focus of training at times, and that is part of the club’s development approach.</li>
            </ul>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">3. RSVP &amp; Availability</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Set availability every week:</strong> All players must keep their availability current for games, practices, and pickup sessions.</li>
              <li><strong>Weekly deadlines matter:</strong> Availability should be updated before the stated weekly cutoff so selection and planning remain accurate.</li>
              <li><strong>APSL Reserve Team Policy:</strong> <strong>Liga 1 is the official APSL Reserve Team.</strong> ALL Liga 1 players are expected to RSVP for APSL games in case call-ups are needed.</li>
              <li><strong>Goalkeepers Note:</strong> <strong>All goalkeepers are listed on the Liga 1 roster</strong> (<a href="#player-roster" style="color: #93c5fd;">player roster</a>) so they remain fully eligible for both APSL and Liga 1 fixtures.</li>
              <li><strong>Mandatory Policy:</strong> Setting accurate availability at <a href="#my" style="color: #93c5fd;">My</a> by the weekly deadline is strictly required. Missing or inaccurate RSVPs for an event will result in a <strong>$1 fine for each event</strong> and may also affect playing time.</li>
            </ul>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">4. Practice Rules</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Practice Attendance:</strong> A player may arrive late or leave early from practice without penalty. Showing up for practice still counts as a practice.</li>
              <li><strong>Practice still matters:</strong> Attendance is still part of the evaluation process for selection and roster decisions.</li>
              <li><strong>Practice cancellations are rare:</strong> We usually move practice due to weather or field availability because we have indoor facilities, rather than canceling it outright.</li>
              <li><strong>No leaving feet at practice except keepers.</strong> Players will sit out if they leave their feet.</li>
              <li><strong>Clean play expected:</strong> Players will sit out if they are fouling needlessly.</li>
              <li><strong>Defensive style at Lighthouse:</strong> We do not hack or push from behind. When defending behind a player with the ball, we are to stop the turn rather than foul the player. This is a skill to promote. We hustle and get in front of the ball to stop progress cleanly, not from behind or the side.</li>
            </ul>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">5. 20-Man Selection</h2>
            <p style="margin: 0 0 8px;">To keep squad structure transparent and competitive:</p>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>APSL &amp; Liga 1 Squad Selection:</strong> Players are assigned to either the <strong>APSL Squad</strong> or the <strong>Liga 1 Squad</strong>. You can view current team assignments on the official <a href="#player-roster" style="color: #93c5fd;">Player Roster</a>.</li>
              <li><strong>Week-to-Week Movement:</strong> Squad assignments are <strong>not permanent</strong>. Selection is evaluated on a <strong>week-to-week basis</strong>, and players can be promoted or moved between squads based strictly on performance, commitment, and merit.</li>
            </ul>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">6. Initial Starters &amp; Bench Selection</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Lineup &amp; Bench Priority:</strong> Within each squad, starting 11 and bench spots are earned based on <strong>ability + practice attendance</strong> in this order:</li>
            </ul>
            <ol style="margin: 6px 0 0 20px; padding: 0;">
              <li><strong>Best players with 2 practices</strong></li>
              <li><strong>Best players with 1 practice</strong></li>
              <li><strong>Players with 0 practices</strong> <em>(only if needed to fill remaining roster spots)</em></li>
            </ol>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">7. Game-Day Rules</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Selection Process:</strong> Initial starting lineup selection is <strong>Step 1</strong>. Final selection takes place at the <strong>beginning of warmups</strong>, which start <strong>45 minutes before APSL matches</strong> and <strong>30 minutes before Liga 1 matches</strong>.</li>
              <li><strong>Warmup Replacement Rule:</strong> If a player is <strong>not in warmup when it begins</strong>, they will be replaced in the lineup by <strong>another player in warmup</strong>, regardless of practice attendance, because the coach needs a positional replacement.</li>
            </ul>
          </div>

          <div style="margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.12); border-radius: 10px; background: rgba(255,255,255,0.03);">
            <h2 style="font-size: 0.9rem; margin: 0 0 6px;">📅 Weekly Selection Timeline</h2>
            <ul style="margin: 0 0 0 18px; padding: 0;">
              <li><strong>Thursday @ Midnight:</strong> <strong>HARD DEADLINE</strong> to set availability on <a href="#my" style="color: #93c5fd;">My</a> for Sunday’s match.</li>
              <li><strong>Friday:</strong> Official <strong>20-man roster</strong> is selected and announced.</li>
              <li><strong>Saturday:</strong> <strong>Starting 11</strong> is finalized.</li>
            </ul>
          </div>

          <p style="margin: 12px 0 0; font-weight: 700;">Consistency, honesty, and commitment are expected every week.</p>
        </div>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
