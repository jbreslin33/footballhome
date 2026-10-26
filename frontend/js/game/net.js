// frontend/js/game/net.js
//
// WebSocket connection to the fh-game match daemon. Auth rides in the
// subprotocol header — `fh-game.v1.bearer.<JWT>` — reusing the club app's
// session token from localStorage, exactly like v1's sim client did. [v1]

(function () {
  'use strict';

  class GameNet {
    // handlers: { onHello(h), onSnapshot(s), onClose(reason) }
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
        `fh-game.v1.bearer.${token}`
      );
      this.ws.binaryType = 'arraybuffer';

      this.ws.onmessage = (ev) => {
        const view = new DataView(ev.data);
        for (const f of GameWire.decodeFrame(ev.data)) {
          if (f.type === GameWire.FrameType.HELLO) {
            this.handlers.onHello(GameWire.decodeHello(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.SNAPSHOT) {
            this.handlers.onSnapshot(
              GameWire.decodeSnapshot(view, f.payloadAt)
            );
          } else if (f.type === GameWire.FrameType.ROSTER) {
            this.handlers.onRoster(GameWire.decodeRoster(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.PRESETS) {
            if (this.handlers.onPresets)
              this.handlers.onPresets(GameWire.decodePresets(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.CONCEPTS) {
            // G4.37 (1.6): the curriculum's names by id from the club DB —
            // replaces the built-in list in place (id = index; "" = hole).
            const names = GameWire.decodePresets(view, f.payloadAt);
            GameWire.CONCEPTS.splice(0, GameWire.CONCEPTS.length, ...names);
          } else if (f.type === GameWire.FrameType.BRAIN) {
            if (this.handlers.onBrain) this.handlers.onBrain(GameWire.decodeBrain(view, f.payloadAt, f.payloadLen));
          } else if (f.type === GameWire.FrameType.SPEED) {
            if (this.handlers.onSpeed) this.handlers.onSpeed(GameWire.decodeSpeed(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.PHASES) {
            if (this.handlers.onPhases) this.handlers.onPhases(GameWire.decodePresets(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.BRAIN_LEGEND) {
            if (this.handlers.onBrainLegend) this.handlers.onBrainLegend(GameWire.decodePresets(view, f.payloadAt));
          } else if (f.type === GameWire.FrameType.TEAMS) {
            if (this.handlers.onTeams)
              this.handlers.onTeams(GameWire.decodeTeams(view, f.payloadAt, f.payloadLen));
          } else if (f.type === GameWire.FrameType.EVENT) {
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

    claim(slot) {
      this.send(GameWire.encodeClaim(slot, true));
    }
    release(slot) {
      this.send(GameWire.encodeClaim(slot, false));
    }
    intent(slot, x, y, action) {
      this.send(GameWire.encodeIntent(slot, x, y, action));
    }
    setConcepts(slot, ratings) {
      this.send(GameWire.encodePlayerSettings(slot, ratings));
    }
    reloadRosters() {
      this.send(GameWire.encodeReloadRosters());
    }
    setAttributes(slot, ratings) {
      this.send(GameWire.encodePlayerAttributes(slot, ratings));
    }
    setLevels(homeId, awayId) {
      this.send(GameWire.encodeMatchSettings(homeId, awayId));
    }
    brainWatch(on) {
      this.send(GameWire.encodeBrainWatch(on));
    }
    applyPreset(team, presetId) {
      this.send(GameWire.encodeApplyPreset(team, presetId));
    }
    setSpeed(pct) {
      this.send(GameWire.encodeSpeed(pct));
    }
    runPhase(team, phaseId) {
      this.send(GameWire.encodeRunPhase(team, phaseId));
    }
  }

  window.GameNet = GameNet;
})();
