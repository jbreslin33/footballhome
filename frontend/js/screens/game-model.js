// GameModelScreen — club-wide game model + weekly session planning
class GameModelScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-game-model';

    const principles = [
      {
        title: 'Build from the back',
        summary: 'Start every attack with clean structure, clear passing angles, and a calm first action.',
        subPrinciples: [
          'The goalkeeper is part of the build and must be comfortable in circulation.',
          'The back line should create passing lanes and avoid rushed vertical play.',
          'Second-build actions must be available to escape pressure and keep tempo.',
        ],
        subSubPrinciples: [
          'Use the keeper and 6 as the first two connecting pieces.',
          'When the press is aggressive, play around it rather than through it.',
          'Break lines with a simple pattern before moving to the next phase.',
        ],
      },
      {
        title: 'Create overloads in the middle',
        summary: 'Our best attacks come from central overloads that create a free player or a line-break opportunity.',
        subPrinciples: [
          'The 8s and 10 must rotate to create rhythm and spacing.',
          'Wide players must support the central build without becoming isolated.',
          'The team should be comfortable using a 2-3-5 or 3-2-5 shape depending on the phase.',
        ],
        subSubPrinciples: [
          'The third-man run is the default pattern when the first pass is not enough.',
          'The receiver should look to play forward, not backward, when the shape is open.',
          'Use the pivot to connect play and reset the rhythm quickly.',
        ],
      },
      {
        title: 'Attack with purpose in the final third',
        summary: 'Every entry into the final third should either create a chance, force a defensive rotation, or create a numerical advantage.',
        subPrinciples: [
          'The final action must be quick and decisive once the zone is open.',
          'Wide overloads should create a cutback or a cross into the box.',
          'The front line should press the back line and occupy the defenders with timing.',
        ],
        subSubPrinciples: [
          'The first cross should not always be the first option; the second pass is often better.',
          'The striker must be ready to attack the space created by the run of the fullback.',
          'The team should create one clear attacking action before the ball is recycled.',
        ],
      },
      {
        title: 'Defend compact and aggressive',
        summary: 'The team should defend with compactness, pressure near the ball, and a clear trigger for the press.',
        subPrinciples: [
          'The first line should press with intent but remain connected to the second line.',
          'The back line should be ready to step together when the ball is played wide.',
          'Recover shape quickly after the first action so we are not exposed in transition.',
        ],
        subSubPrinciples: [
          'The trigger is the first touch or the first bad pass from the opponent.',
          'We force play wide before we chase it centrally.',
          'The counter-press should begin immediately after the ball is lost.',
        ],
      },
      {
        title: 'Be ruthless with standards',
        summary: 'The identity of the team is built through daily repetition, high standards, and clear communication.',
        subPrinciples: [
          'Every player must understand the role in the phase they are in.',
          'The team should be able to communicate clearly in pressure moments.',
          'The training environment should prepare the players for game speed and decision-making.',
        ],
        subSubPrinciples: [
          'The pass is not complete until the player receives it in a good position.',
          'Every repetition should be judged against the game model, not just the drill result.',
          'The coaching point should come from the game moment, not the exercise alone.',
        ],
      },
    ];

    const weeklyPlan = [
      {
        day: 'Tuesday',
        focus: 'Base session — same weekly structure, but adapted by player numbers.',
        anchor: 'The Tuesday template is the standard session for the week and should stay consistent until we intentionally change it.',
        variations: [
          { label: 'Small group', detail: '8–12 players: more touches, more decision points, more individual coaching, shorter transitions.' },
          { label: 'Mid group', detail: '13–18 players: use two grids or two teams to keep the game alive and maintain intensity.' },
          { label: 'Large group', detail: '19+ players: split the group into two units and rotate the work so the principles stay clear.' },
        ],
        principles: ['Build from the back', 'Create overloads in the middle', 'Defend compact and aggressive'],
      },
      {
        day: 'Wednesday',
        focus: 'Anchor day — same as last Wednesday until we consciously change it.',
        anchor: 'This is the day we protect as the recurring reference point for the week, like a pro club week-to-week blueprint.',
        variations: [
          { label: 'Small group', detail: 'Use a 7v7 or 8v8 game with clear positional instructions and a strong contrast between build and press.' },
          { label: 'Mid group', detail: 'Run the same exercise as a 10v10 or 11v11 game and keep the same structure as the smaller version.' },
          { label: 'Large group', detail: 'Split into two blocks and keep one shared coaching point for the whole group so the session remains coherent.' },
        ],
        principles: ['Build from the back', 'Attack with purpose in the final third', 'Be ruthless with standards'],
      },
      {
        day: 'Thursday',
        focus: 'Transition and game-speed detail day.',
        anchor: 'This day sharpens the team’s reactions after the first action is lost or won.',
        variations: [
          { label: 'Small group', detail: 'Keep the game small and increase the number of live transitions to sharpen reactions.' },
          { label: 'Mid group', detail: 'Use a larger field and a clear recovery rule after each transition.' },
          { label: 'Large group', detail: 'Use two working blocks and a short reset to keep the recovery point clear.' },
        ],
        principles: ['Defend compact and aggressive', 'Create overloads in the middle', 'Be ruthless with standards'],
      },
      {
        day: 'Friday',
        focus: 'Match prep and attacking patterns.',
        anchor: 'Friday focuses on the exact patterns we want to see in the next game, with less random work and more game-like repetition.',
        variations: [
          { label: 'Small group', detail: 'Use a tighter game with more focused positional repetitions and fewer players standing around.' },
          { label: 'Mid group', detail: 'Set the game up with a clear attacking pattern and a clear recovery pattern.' },
          { label: 'Large group', detail: 'Split the group and anchor the same pattern in two parallel blocks.' },
        ],
        principles: ['Attack with purpose in the final third', 'Build from the back', 'Be ruthless with standards'],
      },
      {
        day: 'Saturday',
        focus: 'Game rehearsal and match-load day.',
        anchor: 'Saturday is lighter and more specific — the team should feel ready, coordinated, and clear in shape.',
        variations: [
          { label: 'Small group', detail: 'Keep it competitive and short, with a strong focus on final-third decision-making.' },
          { label: 'Mid group', detail: 'Make the match-like condition the key part of the session rather than a long warm-up.' },
          { label: 'Large group', detail: 'Use two sides so everyone gets football and the same game moments stay in view.' },
        ],
        principles: ['Attack with purpose in the final third', 'Defend compact and aggressive', 'Create overloads in the middle'],
      },
      {
        day: 'Sunday',
        focus: 'Game day.',
        anchor: 'Sunday is the live proof of the model; the session plan should support the game, not override it.',
        variations: [
          { label: 'Small group', detail: 'Use the exact game model and keep the shape simple and intentional.' },
          { label: 'Mid group', detail: 'The values stay the same; the only change is the game rhythm and the player load.' },
          { label: 'Large group', detail: 'Use the same principles, but guide the team through the game with clear communication and pacing.' },
        ],
        principles: ['All principles', 'Game rhythm', 'Standards'],
      },
    ];

    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Game Model &amp; Weekly Session Plan</h1>
        <p class="subtitle">Club-admin view for the model, the principles, and the weekly practice rhythm</p>
      </div>

      <div style="padding: var(--space-4); display: grid; gap: var(--space-4);">
        <section style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: var(--space-4);">
          <div style="display: flex; justify-content: space-between; align-items: center; gap: var(--space-3); flex-wrap: wrap; margin-bottom: var(--space-3);">
            <div>
              <h2 style="margin: 0 0 var(--space-1) 0;">Game model</h2>
              <p style="margin: 0; opacity: 0.8;">The principles, sub-principles, and sub-sub-principles that shape the team’s identity.</p>
            </div>
            <div style="background: var(--bg-primary); border-radius: var(--radius-pill); padding: 0.35rem 0.8rem; font-size: 0.9rem; font-weight: 600;">
              Semi-pro weekly rhythm
            </div>
          </div>

          <div style="display: grid; gap: var(--space-3);">
            ${principles.map((principle) => `
              <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
                <h3 style="margin: 0 0 var(--space-2) 0;">${this.escapeHtml(principle.title)}</h3>
                <p style="margin: 0 0 var(--space-2) 0; opacity: 0.8;">${this.escapeHtml(principle.summary)}</p>
                <div style="display: grid; gap: var(--space-2);">
                  <div>
                    <div style="font-weight: 700; margin-bottom: var(--space-1);">Sub-principles</div>
                    <ul style="margin: 0; padding-left: 1.2rem; display: grid; gap: 0.25rem;">
                      ${principle.subPrinciples.map((item) => `<li>${this.escapeHtml(item)}</li>`).join('')}
                    </ul>
                  </div>
                  <div>
                    <div style="font-weight: 700; margin-bottom: var(--space-1);">Sub-sub-principles</div>
                    <ul style="margin: 0; padding-left: 1.2rem; display: grid; gap: 0.25rem;">
                      ${principle.subSubPrinciples.map((item) => `<li>${this.escapeHtml(item)}</li>`).join('')}
                    </ul>
                  </div>
                </div>
              </article>
            `).join('')}
          </div>
        </section>

        <section style="background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: var(--space-4);">
          <div style="margin-bottom: var(--space-3);">
            <h2 style="margin: 0 0 var(--space-1) 0;">Weekly session plan</h2>
            <p style="margin: 0; opacity: 0.8;">The plan covers the model across Tue–Sun. Tuesday and Wednesday keep a stable template, and each day has player-count versions.</p>
          </div>

          <div style="display: grid; gap: var(--space-3);">
            ${weeklyPlan.map((dayPlan) => `
              <article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);">
                <div style="display: flex; justify-content: space-between; align-items: center; gap: var(--space-3); flex-wrap: wrap; margin-bottom: var(--space-2);">
                  <div>
                    <h3 style="margin: 0;">${this.escapeHtml(dayPlan.day)}</h3>
                    <p style="margin: 0.2rem 0 0 0; opacity: 0.8;">${this.escapeHtml(dayPlan.focus)}</p>
                  </div>
                  <div style="font-size: 0.9rem; opacity: 0.8;">${this.escapeHtml(dayPlan.anchor)}</div>
                </div>

                <div style="display: grid; gap: var(--space-2);">
                  <div>
                    <div style="font-weight: 700; margin-bottom: var(--space-1);">Principles covered</div>
                    <div style="display: flex; flex-wrap: wrap; gap: 0.4rem;">
                      ${dayPlan.principles.map((principle) => `<span style="background: rgba(59,130,246,0.16); border: 1px solid rgba(59,130,246,0.3); border-radius: 999px; padding: 0.25rem 0.55rem; font-size: 0.85rem;">${this.escapeHtml(principle)}</span>`).join('')}
                    </div>
                  </div>
                  <div>
                    <div style="font-weight: 700; margin-bottom: var(--space-1);">Player-count versions</div>
                    <div style="display: grid; gap: 0.5rem;">
                      ${dayPlan.variations.map((variation) => `
                        <div style="border-left: 3px solid var(--accent-color, #3b82f6); padding-left: 0.7rem;">
                          <strong>${this.escapeHtml(variation.label)}:</strong> ${this.escapeHtml(variation.detail)}
                        </div>
                      `).join('')}
                    </div>
                  </div>
                </div>
              </article>
            `).join('')}
          </div>
        </section>
      </div>
    `;

    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName || 'Club';

    this.find('.back-btn')?.addEventListener('click', () => {
      this.navigation.goBack();
    });
  }
}
