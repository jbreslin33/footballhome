// frontend/js/game/net.js
//
// WebSocket connection to the fh-game match daemon. Auth rides in the
// subprotocol header — `fh-game.v2.bearer.<JWT>` — reusing the club app's
// session token from localStorage. [v1]
// 2.0 (G5.23): the old brain's frames (levels, presets/models, concepts,
// demands, params, phases, per-player ratings and attributes) are gone.

(function () {
  'use strict';

  class GameNet {
    // handlers: { onHello, onSnapshot, onRoster, onEvent, onClose, onBrain?,
    //             onSpeed?, onBrainLegend?, onTeams?, onTeamList? }
    constructor(handlers) {
      this.handlers = handlers;
      this.ws = null;
    }

    connect() {
      const token = localStorage.getItem('token');
      if (!token) {
        window.location.href = '/'; // not signed in — go log in
        return;
      }
      const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
      this.ws = new WebSocket(
        `${scheme}://${location.host}/game`,
        `fh-game.v2.bearer.${token}`
      );
      this.ws.binaryType = 'arraybuffer';

      this.ws.onmessage = (ev) => {
        const view = new DataView(ev.data);
        const T = GameWire.FrameType;
        for (const f of GameWire.decodeFrame(ev.data)) {
          if (f.type === T.HELLO) {
            this.handlers.onHello(GameWire.decodeHello(view, f.payloadAt));
          } else if (f.type === T.SNAPSHOT) {
            this.handlers.onSnapshot(GameWire.decodeSnapshot(view, f.payloadAt));
          } else if (f.type === T.ROSTER) {
            this.handlers.onRoster(GameWire.decodeRoster(view, f.payloadAt, f.payloadLen));
          } else if (f.type === T.BRAIN) {
            if (this.handlers.onBrain) this.handlers.onBrain(GameWire.decodeBrain(view, f.payloadAt));
          } else if (f.type === T.SPEED) {
            if (this.handlers.onSpeed) this.handlers.onSpeed(GameWire.decodeSpeed(view, f.payloadAt));
          } else if (f.type === T.BRAIN_LEGEND) {
            if (this.handlers.onBrainLegend) this.handlers.onBrainLegend(GameWire.decodeNames(view, f.payloadAt));
          } else if (f.type === T.TEAM_LIST) {
            if (this.handlers.onTeamList) this.handlers.onTeamList(GameWire.decodeNames(view, f.payloadAt));
          } else if (f.type === T.TEAMS) {
            if (this.handlers.onTeams) this.handlers.onTeams(GameWire.decodeTeams(view, f.payloadAt, f.payloadLen));
          } else if (f.type === T.EVENT) {
            this.handlers.onEvent(GameWire.decodeEvent(view, f.payloadAt));
          }
          // Unknown frame types are ignored (PROTOCOL.md §9).
        }
      };
      this.ws.onclose = () => this.handlers.onClose('closed');
      this.ws.onerror = () => this.handlers.onClose('error');
    }

    send(buf) {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) this.ws.send(buf);
    }

    claim(slot) { this.send(GameWire.encodeClaim(slot, true)); }
    release(slot) { this.send(GameWire.encodeClaim(slot, false)); }
    intent(slot, x, y, action) { this.send(GameWire.encodeIntent(slot, x, y, action)); }
    reloadRosters() { this.send(GameWire.encodeReloadRosters()); }
    brainWatch(on) { this.send(GameWire.encodeBrainWatch(on)); }
    setSpeed(pct) { this.send(GameWire.encodeSpeed(pct)); }
    newMatch(home, away) { this.send(GameWire.encodeNewMatch(home, away)); }
  }

  window.GameNet = GameNet;
})();
