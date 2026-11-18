// YouthGameScreen — a youth game (Boys / Girls): the base game
// (GameCenterScreen) with the men-only parts never added and the fluff
// hidden (owner 11/18 "it should have all on graphic like men and get rid of
// the fluff … each extends game and adds or hides").
//
//   hides   the "everyone who is Going plays — no bench" note under the
//           graphic (the graphic already shows who plays)
//
// Picked by GameCenterScreen.stateFor(ev) (a Boys / Girls team on the event).
class YouthGameScreen extends GameCenterScreen {
  static get STATE() { return 'game-youth'; }

  lineupPlayerPanels(byZone, coach) {
    return super.lineupPlayerPanels(byZone, coach).filter(p => p.key !== 'player_notes');
  }
}

window.YouthGameScreen = YouthGameScreen;
