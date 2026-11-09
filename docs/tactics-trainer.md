# Tactics trainer — the game engine teaches tactics, Premier League sides first

Owner, 2026-11-09: "why can't we use the game engine to do the tactics … can we extend game to
show players tactics?" · "as the game matures so will the tactics trainer — it can be premier
league teams that 'teach' the tactics" · "i would like to train from the game too. have that
option" · "maybe we skip the lh one and focus on teaching the ones from premier league. then when
they are mature we add lh specific? this way the premier league stuff is not contaminated" · "yes".

## The rule: Premier League is clean, information flows one way

- The PL 15/16 sides defend as the engine models them (real data, pro only — mig 1042). They are
  the teachers. **Nothing from the club's tactic plans ever feeds a PL side.**
- The club's plans (Game Center 🎯 Tactics, `tactic_plans` …) are hand-drawn and partly
  estimated. They stay on the board until the PL trainer is mature.
- If Lighthouse ever comes back, it's PL → Lighthouse only, never the reverse.
- `tactic_buildout_shapes` holds measured shapes only (mig 1198 removed two [FH] estimates);
  estimates live inside a plan's own `tactic_state_opponents`.

## Build order

Game session owns 1–3 (`game/`, `frontend/game*`); the club session owns the board.

1. **Each man says what he's doing.** At every tick the engine knows which game concept each
   outfield man is running out of possession (cover-shadow on #6, mark #9, press, line-hold …).
   Expose it to the client as the `game_concepts` id (+ target numbers), so the trainer labels men
   in the same vocabulary as the board — one vocabulary, no copy.
2. **Practice match with PL sides**, separate from the one live match (one clock, one `SPEED`):
   pick two PL sides and a moment (their goal kick first — Law 16 restart), watch, slow down.
3. **Freeze and step**: pause, every man labelled with his concept and target, step pass by pass,
   play on live. Freeze frame / play-practice-play is the design input (coaching methodology).
   A lesson may say "measured" only for what was measured: PL data = StatsBomb events (pressure
   and ball-win locations, no off-ball tracking); off-ball shape is from DFL (Bundesliga).
Lighthouse is out of scope for now (owner: "don't worry about lh"). No plan reader, no
copy-into-our-plan, nothing club-side in the engine until the owner asks.

The board gets a 🎮 3D view pill once step 2 exists (deep link from the game session).
