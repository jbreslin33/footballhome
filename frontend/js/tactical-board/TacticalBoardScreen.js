// Minimal TacticalBoardScreen placeholder so the app can initialize
class TacticalBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.element = null;
  }
  render() {
    if (!this.element) {
      this.element = document.createElement('div');
      this.element.className = 'screen tactical-board';
      this.element.innerHTML = `
        <div class="card">
          <h2>Tactical Board (placeholder)</h2>
          <p>The full tactical board scripts are not loaded; this is a lightweight placeholder.</p>
        </div>
      `;
    }
    return this.element;
  }
}

window.TacticalBoardScreen = TacticalBoardScreen;
