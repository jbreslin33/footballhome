# Soccer concept taxonomy — the knowledge registry

The living curriculum (DESIGN.md §5.2): every concept is a nameable piece
of soccer understanding a player HAS or LACKS, independent of physical
ability. In the engine a concept gates a decision branch; on the teaching
side it is a thing a coach can rate, drill, and point at in a replay.
Wired concepts carry their bit id; the rest are the build queue, ordered
roughly by the §5.1 history/level ladder (which is also the dependency
order). Sources: standard coaching frameworks (the four-moment model,
play-practice-play progressions), [Buckland], [HELIOS], and James's
touchline laws — [FH] marks engine-original formulations.

## Wired today (bit ids are wire format — append-only)

| bit | concept | definition (the cue → the answer) | lacking it looks like |
|----|----------|-----------------------------------|----------------------|
| 0 | `delay_transition` | Ball lost → first defender jockeys goal-side to buy time; the STEP waits for numbers + a free man [FH/James] | dives in instantly on every turnover |
| 1 | `man_marking` | Organized defense → take a dangerous opponent, stay goal-side touch-close | ball-watching; opponents free between lines |
| 2 | `cover_man` | Second defender sits on the ball→goal line behind the press | beaten press = breakaway |
| 3 | `support_spot` | Nearest teammate to the carrier moves to an open spot ahead [Buckland] | statues; carrier has no options |
| 4 | `back_outlet` | Second support offers behind the ball — the safety valve of the triangle | no way out of pressure |
| 5 | `run_in_behind` | Most advanced attacker attacks the space past the last line, RIDING it onside | nobody stretches the defense |
| 6 | `play_over_top` | Carrier sees a runner beyond the line → lofted ball over the block (§5.2's high-line example) | ground passes into traffic only |
| 7 | `keeper_sweep` | Keeper owns free balls in the defensive third | through balls die un-contested; keeper rooted (every U-10 keeper) |
| 8 | `shot_placement` | Shoot inside the far post, away from the keeper | shoots at the keeper's chest |
| 9 | `line_hold` | Back line holds ≥ ~25 m from the ball instead of man-following into the goalmouth; makes run-timing (and later the trap) real [FH, measured] | the retreat spiral |
| 10 | `jockey_angle` | Delay shaded a step infield — show the carrier the TOUCHLINE | jockeys square-on; carrier picks either side |
| 11 | `recover_goal_side` | Beaten → sprint the cover line between ball and goal, never chase the ball | kids chasing the play from behind |
| 12 | `double_team` | Carrier pinned wide → cover man converges; the touchline is the third defender | wide carriers escape 1v1 forever |
| 13 | `spread_wide` | In possession, wide players HOLD width — the attack un-bunches [FH/James: the offense's bunching is what stops goals] | attack narrows itself into the block |
| 14 | `give_and_go` | Pass and MOVE: burst beyond your receiver; the 1-2 emerges from his normal pass choice | pass-and-stand |

## Build queue (planned; each lands with the behavior that consumes it)

**Individual, attacking** — `first_touch_direction` (touch into space, not
underfoot), `shield_ball` (body between man and ball), `scan_before_receive`
(shoulder checks → perception bonus for one tick), `half_turn_receive`
(open body shape to play forward), `beat_man_1v1` (v1's Feint behavior,
archived and tested).

**Individual, defending** — `tackle_timing` (dive on the heavy touch, not
on faith), `block_shot_line` (defend the shooting lane inside the box).

**Group (2–4 players)** — `wall_pass` (the return-ball half of give-and-go
under an opponent), 
`third_man` (the free man the second pass finds — v1 behavior archived),
`overlap` / `underlap`, `press_trigger` (bad touch / back-pass / sideline =
GO — v1's original M5 goal), `cover_shadow` (press while blocking the
pass lane behind you — v1 archived), `switch_play` (deep block +
ball-side overload → long diagonal; §5.2's second example).

**Team** — `compact_block` (defend in ≤35 m of depth), `press_as_unit`
(stepping together on triggers), `play_out_back` (keeper + back line vs
the press), `counter_press` (lose it → 6-second swarm-to-win-it-back),
`rest_defense` (attacking shape that pre-covers the counter),
`offside_trap` (line steps ON the pass cue — needs `line_hold` +
coordination), `tempo_control` (when to kill the game).

**Keeper** — `narrow_angle`, `distribute_quickly` (counter launch),
`command_box` (crosses — needs aerial balls first).

## Mechanics of the registry

- Per-SLOT `u32` bitmask in the live match, admin-editable in-game
  (PLAYER_SETTINGS frame); level bands set the default bundle
  (`conceptBundle()` in Levels.hpp) so unedited teams behave exactly per
  their band. Per-PERSON persistence (game_player_concepts rows keyed on
  persons.id) lands with team/lobby selection — the mask is the runtime
  form either way.
- A concept is binary knowledge; HOW WELL it executes stays in ability
  params and noise. "Knows to switch play, can't hit the pass" = bit 6
  set, kick_angle_err high. The recognition layer (§5.2 — seeing the cue
  early vs late) is the third axis, still ahead.
- Teaching loop: a drill/painted scenario targets one concept; completing
  it sets the bit (or raises the recognition); the match shows the
  difference. The replay can name which missing bit caused a goal.
