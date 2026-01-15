// Minimal placeholder StateManager
class StateManager {
  constructor() {
    this.state = {};
  }
  load(id) { return Promise.resolve(null); }
  save(id, data) { return Promise.resolve(true); }
}

window.StateManager = StateManager;
