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
| 15 | `push_up` | The line STEPS UP as the ball moves away — stay ≤ ~15 m behind the ball, squeeze the team short [DFB/RB school; James: "white line still too far back"] | a line that only retreats |
| 16 | `counter_press` | First ~3 s after LOSING the ball: swarm to win it back before organizing [KNVB moment 3 / gegenpress] | jog back and concede the transition |
| 17 | `balance` | Ball on the far side → weak-side defender tucks toward the centre [FA principles] | stretched square across the back |

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

## Game-model sources — the deep dive

What federations and schools actually teach, mined for registry rows:

- **English FA principles of play** (the 1960s Allen Wade canon, still the
  spine of every coaching badge): attacking = penetration, support,
  mobility, WIDTH, creativity; defending = DELAY, cover, BALANCE,
  compactness, control/restraint. Maps almost 1:1 onto our bits — delay(0),
  cover(2), support(3), width(13) wired; **balance** (weak-side tuck) and
  **restraint** (when NOT to dive) are the gaps this pass fills/queues.
- **KNVB / Dutch school** (van Gaal lineage): the FOUR-MOMENT model —
  attack, defense, attack→defense transition, defense→attack transition.
  Our engine has moments 1-2; the TRANSITIONS are where it's thinnest.
  **counter_press** (the 6-second swarm after losing it) is moment 3's
  signature concept — wired this pass. Moment 4 (fast break on winning it)
  queues as `counter_attack`.
- **German DFB / RB school** (gegenpressing): pressing as the best
  playmaker; counter-press triggers and PUSH-UP — the line steps WITH the
  press so the team stays ≤ ~35 m long. **push_up/squeeze** wired this
  pass (James's live observation: "the white line is still too far back"
  — the line must step up as the ball advances away, not only retreat).
- **Belgian FA model** (the 2000s reboot behind the golden generation):
  1v1 dominance early, zonal play later; age-staged concept introduction —
  direct validation of the band-bundle idea (concepts arrive by level).
- **Horst Wein / FUNiño** and **Tom Byer**: game-forms before tactics,
  technique before game-forms — the u10 bundle SHOULD be nearly empty;
  what kids lack isn't execution of tactics, it's the concepts themselves.
- **Positional play school** (La Masia/Pep lineage, via Inverting the
  Pyramid [Wilson] and Zonal Marking [Cox] for the historical arcs):
  numerical superiority (our organized test), positional superiority
  (free man), qualitative superiority (per-player ability vs marker —
  future matchup logic); zones/half-spaces queue as `occupy_half_space`;
  `third_man` already queued.
- **Italian school** (Viscidi's azzurri youth model): defensive line
  coordination as a TAUGHT skill ladder — step, drop, slide, trap — i.e.
  our line concepts are genuinely separable bits, not one blob.

Queue additions from the dive: `counter_attack` (moment 4), `restraint`
(don't dive — the anti-tackle), `occupy_half_space`, `slide_with_ball`
(lateral line shift), `step_drop_call` (keeper organizes the line),
`block_height` as an explicit team tactic (high/mid/low — the FSM layer).

## Compound concepts — interplay IS the next tier [FH/James]

"An interplay of 2 concepts is probably a concept of itself." Confirmed in
the engine before it was named: the wall pass was never coded — it EMERGES
when give_and_go (the passer keeps moving) meets the receiver's ordinary
pass evaluation. The composition is the concept.

This is how the taxonomy's tiers relate: group tactics are compositions of
individual bits, team tactics are compositions of group ones —
  wall_pass        = give_and_go × support_spot        (both players)
  third_man        = wall_pass × a second mover
  double_team      = cover_man × step                   (now a bit itself)
  press_as_unit    = delay × marking × cover × step     (team-wide, timed)
  offside_trap     = line_hold × coordinated step
  tiki-taka (era)  = triangles × spread_wide × tempo_control
And it is why the §5.1 history ladder is real: an era is an accumulated
stack of compounds, each buildable only after its components existed.

Registry consequence: a compound concept's row carries REQUIRES links to
its component bits (teachable only after them — the same progression a
coaching curriculum uses: technique → pattern → small game). Some
compounds need no code of their own (wall_pass is free once its parts
exist); others add a small coordination behavior on top. Detecting that a
compound has EMERGED in play (two bits firing in sequence) is also the
recognition layer's future replay-annotation hook: "that was a 1-2 — Lily
just learned it."

## Mechanics of the registry

- Per-SLOT `u32` bitmask in the live match, admin-editable in-game
  (PLAYER_SETTINGS frame); level bands set the default bundle
  (`conceptBundle()` in Levels.hpp) so unedited teams behave exactly per
  their band. Per-PERSON persistence (game_player_concepts rows keyed on
  persons.id) lands with team/lobby selection — the mask is the runtime
  form either way.
- Knowledge is GRADED 0-100 (James: "implement them on a 0 to 100
  scale"): the rating is consistency (sustained duties roll noise <
  rating per application) and magnitude (spatial concepts lerp their
  distances — push_up squeezes the line 25 m → 12 m across the scale).
  IMPULSES (dives) keep the eagerness per-tick RATE — rating-as-%/tick on
  a tackle measured an 8,500-tackle match before that lesson was learned. "Knows to switch play, can't hit the pass" = bit 6
  set, kick_angle_err high. The recognition layer (§5.2 — seeing the cue
  early vs late) is the third axis, still ahead.
- Teaching loop: a drill/painted scenario targets one concept; completing
  it sets the bit (or raises the recognition); the match shows the
  difference. The replay can name which missing bit caused a goal.
