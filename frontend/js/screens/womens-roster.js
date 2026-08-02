// WomensRosterScreen — women-focused wrapper over the shared youth roster
// board.  The card renderer and roster interaction logic are inherited from
// BoysRosterScreen (which already uses the shared compact-card OOP base), so
// this screen only changes the copy and the default route label.
class WomensRosterScreen extends BoysRosterScreen {
  render() {
    const el = super.render();
    const h1 = el.querySelector('.screen-header h1');
    if (h1) h1.textContent = '🎽 Women\'s Team Players Board';
    const sub = el.querySelector('.screen-header .subtitle');
    if (sub) sub.textContent = 'Live from LeagueApps — Women\'s team players board';
    return el;
  }
}
