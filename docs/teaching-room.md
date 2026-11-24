# Teaching room — a club tactic plan, played by the game engine

Owner, 2026-11-24: "are we ready to have the game show a defensive press for lighthouse? …
so we dont need to touch the games offense right? just overlay a tactic on top? maybe at first
we just allow me to use game engine from another screen that is not the game?" · "i would
rather the game screen stay pure sim of premier league and focus on getting that right" ·
"i want a teaching room/sandbox that does not touch game" · "the sandbox/teaching room uses
the game engine right though? maybe it extends the classes".

## What it is

`/teach.html?plan=<tactic_plans.id>` — opened by **🎓 Watch it play** on Calendar → Game Center
→ 🎯 Tactics (`#game-center/<id>/tactics`). A private room on the game daemon, frozen on their
goal kick:

- **Their side** is the engine's own Premier League build-out. Nothing is told to it.
- **Our side** stands where each man's **job** in the plan puts him, worked out every tick from
  where their men really are, by `shared/tactics/TacticGeometry.hpp` — the same code that draws
  the board. One implementation, two consumers.
- ⏭ **Next pass** plays one pass and freezes. When their pass is struck our men move while it
  travels, on the jobs of the plan's step "ball to their #n". No step drawn for that man → the
  jobs stand, which shows which steps the plan still needs.
- When we win the ball the plan lets go and the engine plays on.

Every one of ours is labelled with his job in the board's words (the job kind's `game_concepts`
row), with a line to his spot and a dashed line to the man the job names. The list beside the
pitch says the same in text and marks what changed at each step.

Without a plan (`/teach.html?us_team=<team>&them_team=<team>`, the board's **🎮 PL sides**
button) both sides are the engine's own, and 📋 copies a frozen moment to the board
(`POST /api/tactic-plans/copies`, one way — see `docs/tactics-trainer.md` step 4).

## The rule: the game is not touched

The game screen (`game.html`) is the pure 2015/16 Premier League sim and stays that way.

- The room is a **child class**: `fh::game::teach::TeachingServer : server::GameServer`
  (`game/src/teach/`). `GameServer` gained one seam — `virtual decide(slot)` (default: the
  brain's own orders) and `virtual conceptOf(slot, orders)` (the label). The live match and a
  plain practice room are plain `GameServer`s; no code path leads from them into `src/teach`.
- `TeachingServer::decide` always asks the engine first, then replaces **only** an outfielder of
  ours while their side has the ball. It keeps the engine's answer for: their whole side, both
  keepers, our man who is first to a loose ball or cutting out a pass, the Law's distance at a
  restart, and all of us once we have the ball.
- Nothing in `src/ai` or `src/core` changed. The determinism goldens are unchanged (the suite
  passes as before). `src/teach` uses floating point — the shared solver's — and sits outside
  the float lint on purpose: a teaching room is a lesson, not a golden.
- Both sides line up in the plan's two formations, numbered as the board numbers them
  (`formation_slot_roles.number`, else `positions_json.position_id`). The team names
  (`message_templates` kind `teach`, tiers `us_team` / `them_team`) only choose kits and players.

## Honest limits

- The engine's build-out against a coached press is not validated. Its own defending is a
  measured average pro block (see `game/DESIGN.md` §8.295–§8.345 for the gaps), so its attackers
  have never been tuned against men standing in their lanes. The first one to three passes from
  the goal kick are the lesson; later ones are illustration.
- Geometry is the board's: a job puts a man on a spot, and he runs there at full pace. Pressing
  **angles** (the curved run that keeps a man in the shadow on the way) are not modelled — he
  arrives on the shadow, he does not run it.
- A tackle is the engine's own roll once a man is in reach of their carrier.
- Not a benchmark. Never read a realism number off a teaching room.

## Where things are

| | |
|---|---|
| Page | `frontend/teach.html`, `frontend/js/teach/teach.js` (top-down canvas; only the wire codec is shared with the game page) |
| Room | `game/src/teach/TeachingServer.{hpp,cpp}`, `TeachingPlan.{hpp,cpp}` (plan loaded once, when the room opens) |
| Socket | `/game?trainer=1&teach=<plan>&home=<us>&away=<them>&gk=away` (`server/Rooms.hpp`) |
| Words | `message_templates` kind `teach`, and kind `tactics` tiers `teach` / `teach_href` (mig 1789) |
| Headless read | `fh-teach-probe <plan_id> [seconds]` — prints each man, on his job or the engine's, metres off his spot |
| Test | `game/tests/test_teaching_room.cpp` |
| Build | the image needs the shared header: `make game-deploy` passes `--build-context shared=./shared` |

## Next, when asked for

- The plan's own goal-kick shape for THEIR side (today they take the engine's shape).
- Start from a formation and a restart with no plan yet (pick jobs in the room).
- Curved pressing runs.
