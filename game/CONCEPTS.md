# Soccer concept taxonomy — the knowledge registry

> **Since G4.37 the curriculum lives in the club DB:** `game_concepts` +
> `game_concept_requires` (mig 650, DESIGN §8.33) are the record — ids,
> lesson text, level, prerequisites, sources. This file is the design
> notes and reasoning behind those rows. Add a lesson by migration row.

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
| 18 | `man_orientation` [S] | Mark YOUR man tight and FOLLOW him, anywhere [Bielsa/Gasperini]; 0 = zonal goal-side marking | positional/zonal marking only |
| 19 | `verticality` [S] | Play forward FIRST: accept tighter lanes, lower the gain threshold [Bielsa/Zeman]; 0 = safe-side selection | sideways-safe passing |
| 20 | `intercept` | Read the pass: meet a rolling free ball at the earliest-reach point on its friction path (G4.14; rolls per second) | chase the ball's current spot, always a step behind |
| 21 | `restraint` | Don't dive: the anti-tackle [queue → wired G4.16]. Dive eagerness scales to ~x0.2 at 100 — world matches measured 245 dive attempts vs the ~35 of a real one | rash per-tick diving at the full swarm rate |
| 22 | `tackle_timing` | Dive on the exposed ball, not on faith [queue → wired G4.17]: the carried ball rides ahead of the carrier's FACING, so the ball-side dive pokes the ball and the from-behind lunge goes through the man — rated players suppress the latter to ~x0.1 at 100 | lunges from behind at the same rate as from the front |
| 23 | `counter_attack` [S] | Moment 4 [KNVB]: ball won in OUR half → for 2 s + rating ticks the carrier's gain threshold collapses (≥ verticality-100 forwardness) and a SECOND runner joins the run in behind (G4.18). Style, not skill: band-wide it measured world 3.1 → 5.0 goals, all scrambles; head-to-head it changed nothing in the break funnel because possession churns every ~2–5 s. Re-measured after G4.19 (possession now ~10 s): still no gain reaching the final third and concedes more — a real break needs the carrier to RUN WITH THE BALL into space (queued `slide_with_ball`/carry-into-space), so no preset rows yet | wins it and recycles; nobody breaks
| 24 | `safe_pass` | Keep the ball [Buckland, G4.19]: the passer runs the interceptor's closing-speed math on the pass's friction path (opponent reach before the receiver's = unsafe; lofted balls over the line exempt); pressed with nothing forward → RECYCLE the safest pass any direction (the G4.8 back outlet finally receives); clear the ball only in your own defensive third. Rolls per second | passes into readers; boots it away under any pressure (world measured 2,459 possession changes/match, 2.2 s each)
| 25 | `shot_selection` | Shoot on CHANCE QUALITY, not range [G4.21; FH after the xG literature]: visible goal angle (radians, via fx_atan2) halved per outfield body inside the shooter→post→post triangle; shoot at ≥ 0.30 rad (≥ 0.18 pressed), always inside 8 m. Rolls per second | shoots the first tick inside 22 m, whatever's in the way |

| 26 | `libero` [S] | The free +1 behind man-oriented marking [Bielsa]: marks nobody, shadows the ball across 2-5 m behind the deepest teammate, meets a long ball where it lands (G4.33, class `ai::Libero`) | a spare defender who just stands in the line |
| 27 | `cover_shadow` [S] | The 9 presses their building CB along the line to his nearest midfield receiver, the pass in his shadow [Bielsa/Klopp] (G4.33, `ai::CoverShadow`) | running straight at the carrier, leaving the 6 open |
| 28 | `line_step` [S] | Palla coperta / scoperta [Sacchi; FA / KNVB / DFB back four]: the line STEPS UP while the ball travels or the carrier is turned back / pressed, and HOLDS when a free opponent receives facing forward (G4.33, `ai::LineStep`) | a line that only drops, or steps up into the long ball |
| 29 | `pass_ladder` [S] | Look forward in order [Bielsa-Leeds ch4]: behind their back line (central, then wide) → the pocket in front of it → past their first line; rank receivers by rung, play a high enough rung at once with no gain threshold (G4.35, `ai::PassLadder`) | the most-progress receiver, and only if it gains 8 m |
| 30 | `blind_side_run` [S] | Wait onside on the far shoulder of your line defender; go in behind when the carrier is free and he can't see you; come back if the pass didn't come [Bielsa-Leeds f7/21/81/82] (G4.36, `ai::BlindSideRun`; not in a preset yet — DESIGN §8.32) | ride the line, run when the ball is already in flight |

From G4.33 concepts are CLASSES (`ai::Concept` and subclasses, game/src/ai/Concept.hpp) and their numbers are rows in `game_model_params` (mig 642). The 26 older concepts move into classes one at a time, each move held to the goldens.

## Build queue (planned; each lands with the behavior that consumes it)

**Individual, attacking** — `first_touch_direction` (touch into space, not
underfoot), `shield_ball` (body between man and ball), `scan_before_receive`
(shoulder checks → perception bonus for one tick), `half_turn_receive`
(open body shape to play forward), `beat_man_1v1` (v1's Feint behavior,
archived and tested).

**Team, shape** — `match_up` [Bielsa; James 10/22: "us matching in our -1,
+1 bielsa system so would end up a 433 but flexible"]: read the opponent's
shape and SET ours from it — +1 at the back (one more defender than their
forwards: their lone 9 → our two CBs, one spare), man-oriented match-ups
through the middle, -1 up top (one fewer attacker than their back line).
Today that answer is hand-picked as the formation (APSL 4-3-3 vs the Ukies'
4-2-3-1, mig 636); the concept makes the team derive and re-derive it live
when the opponent changes shape — a recognition (`opponent_shape`) plus a
team-layer response, rated per team.

**Team, roles from the 4-2-3-1 and Bielsa research (G4.34)** — what the
presets can't express yet, each a future `ai::Concept` class with its
numbers in `game_model_params`: `pivot_drop` (one 6 drops between the
CBs to build with a numerical edge [sportmonks]), `pivot_step` (one pivot
steps up to press beside the 10 while the other covers across [Premier
League explainer]), `inside_forward` (wide players cut inside on their
unnatural side, full-backs give the width [Premier League]), `ten_arrives`
(the 10 arrives behind the lone 9), `overlap` / `underlap` (Bielsa's
full-back runs around / inside the winger), `rotation` (Bielsa's
positional interchanges that break man-marking).

**The Lighthouse game model from the Leeds book (G4.35 research)** —
[Bielsa-Leeds]: *Marcelo Bielsa*, a tactical analysis of Leeds United
2019/20 (Kindle B08TDTYFPG; ch = chapter, f = figure). James: "this lh
game model but we will add to it". Read cover to cover 10/23; paraphrased,
never quoted. Ordered by build value — how often the book shows it and
how much else depends on it. Each is a future `ai::Concept` class with
its numbers in `game_model_params` and a Bielsa preset row.

*Foundations (everything below leans on these):*
- `pass_ladder` [ch4] — **BUILT G4.35 (bit 29, mig 646; DESIGN §8.31).**
  The passer's progression order: (1) behind their
  back line, central → (2) behind it, wide → (3) in front of it, central
  → (4) in front of it, wide → (5) between their first and middle lines,
  central → (6) the same, wide; then lateral/back only to reach a man who
  HAS a vertical lane. Each rung is gated by the existing `safe_pass`
  interceptor math. Built as the receiver RANKING + an at-once fire rule;
  the lateral-to-find-a-lane step is still to come.
- `rotation` [ch5, f5/27–31/62/80, all five goals] — the most-shown
  pattern. Trigger: carrier has time but no clean vertical. A MOVER leaves
  his slot (drop / out wide / across) only where his marker will follow;
  the nearest teammate FILLS the vacated slot and becomes the target. The
  6 is the anchor and never rotates [ch10]. Note: rotations bite harder
  against man-markers — our own Bielsa defence is the most exposed to it.
- `blind_side_run` [f7/21/35/46/48/51/65/78/81/82] — **BUILT G4.36 (bit
  30, mig 648; DESIGN §8.32) but not switched on: lands in front of the
  line until `release_timing` exists.** The runner sits on
  the far shoulder of his defender and goes when the defender's facing
  turns to the ball, or on a cue: the 9 checks toward the ball then spins
  in behind; a line defender stepping out to the ball = run into the hole
  he left; a teammate turning forward on the ball = go. Angle the run to
  stay onside and away from contact.

*Out of possession [ch2–3]:*
- `match_up` — CBs = their strikers + 1 (back three vs two strikers);
  the spare is the libero (have). The 9 marks nobody unless the block is
  pinned deep [f9].
- `press_minus_one` [f14–16/36] — press their build-up line with one
  fewer (2 CBs → the 9; 3 → the 9 + the wide forward on the side his
  angle leaves open); everyone else tight on his man.
- Press triggers [f16–17/41/55/64]: `touchline_trap` (pass to a man on
  the touchline → two press, a third cuts the down-the-line pass, all
  angled to keep their own man in their cover shadow), `back_to_goal`
  (receiver facing his own goal → three nearest close, the 9 screens the
  back pass), `loose_pass` (heavy touch / bad pass → nearest two jump),
  `press_through` (after a lay-off the presser carries on to the next
  carrier [f60/64]).
- `cover_shadow` generalised [ch11] — ANY presser who leaves his man
  curves his run to keep that man behind him (today only the 9 does).
- `chain_recover` [f11/18–19] — beaten: the nearest player AHEAD of the
  ball sprints back goal-side of the carrier and the next man forward
  takes his orphaned opponent; back line and libero never step out for it.
- `find_your_man` [ch2, f12] — on losing the ball: near your man → tight;
  far → slide sideways onto the lane between ball and him.

*Transitions:*
- `screen_transition` [ch1, f59] — the 6 is first into the space in front
  of the back line on a turnover, and steps to a carrier entering zone 14.
- `regain_spread` [f13/37] — on winning it the wide men sprint back to the
  touchlines and forward ("make the pitch big"); the 9 pre-sits in a
  pocket and attacks the gap between their CBs at once [f83–84].
- `second_ball` [f66/79] — midfielders attack a dropping clearance; the
  nearest wide man or 8 supports underneath the 9 for his knock-down.

*In possession, shape:*
- `pivot_drop` [ch1, f57, ch10] — when their first-line pressers ≥ our CBs,
  the 6 drops BESIDE a CB (left side, so the LB pushes on), not between.
- `eights_high` / `empty_centre` [ch1/5/7] — both 8s go up toward the 9 as
  soon as we build; the centre is only used by rotating INTO it.
- `inverted_fullback` [ch9] — the full-back takes the lane his winger
  leaves: winger wide → FB inside beside the 6 (esp. ball on the far
  side); winger carries inside → FB overlaps outside [f52].
- `hold_width_weak_side` + `switch_play` [ch6, f34/45] — the far winger
  never drifts ballward; once the block has shifted across, the diagonal
  to his 1v1 outranks a short vertical.
- `box_occupancy` [f75/84, goals 1–3] — flood the middle of the box; the
  9 at the far post, the far full-back arrives at the back post, an 8
  arrives late at the edge for the cut-back.

*In possession, on the ball:*
- `drive_into_space` [f31/44/48/50/53/58, goal 4] — when a rotation empties
  a lane, the carrier (CBs and full-backs included) runs the ball into it,
  forcing another defender out of his slot.
- `release_timing` [f54/67/71] — hold the ball until the runner reaches
  the release point, then play; play first time when the run is already on
  [f72].
- `body_feint_pass` [f46/61/63/69/73] — show one pass (usually the switch),
  defenders shade to it, play another; `no_look_pass` [f70] is its
  variant. Needs defenders that read the passer's facing.
- `change_of_pace` [f76–77] — the winger waits for the defender to commit,
  then bursts past (feeds the queued `beat_man_1v1`).

*Player traits, not concepts (player rows):* composure / press resistance
(White, Klich, Hernandez beat pressers instead of clearing [f49/65]),
discipline (Harrison holds width; Klich over-commits [f18]), take-on bias,
preferred foot. Calibration targets per 90 from the book's season data
sit in the research notes (e.g. wide forward dribble success ~55%, cross
success ~27%, CB ~7.5 progressive passes).

**Individual, defending** — `block_shot_line` (no delay within shooting
range + a body in the lane; built in G4.22, parked on branch
`game/g4-block-shot-wip` until ball-winning lands — DESIGN.md §8.17),
`win_duel` (dispossess a moving dribbler: the G4.22 root cause).

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

Queue additions from the dive: `counter_attack` (moment 4 — wired G4.18 as [S]), `occupy_half_space`, `slide_with_ball`
(lateral line shift), `step_drop_call` (keeper organizes the line),
`block_height` as an explicit team tactic (high/mid/low — the FSM layer).

## Schools & auteurs — a school is a PRESET VECTOR [FH]

A named coach's "philosophy" decomposes into values on registry dials plus
(sometimes) one signature mechanic. STYLE concepts (class S below) default
to 0 at every band — they are chosen identities, not skill-ladder items; a
U-10 team can be coached Bielsa-ish, badly.

- **Bielsa** (and Leeds-era murderball): man_orientation 95 (mark YOUR man
  everywhere), counter_press 90, verticality 90 (forward first, risk the
  lane), spread_wide 85, push_up 85, universal running (future stamina
  dial at 100). Signature wired this pass: man_orientation + verticality.
- **Michels/Cruyff → Guardiola** (total football → positional play):
  spread_wide 90, support 95, third_man/occupy_half_space (queued),
  push_up 80, counter_press 80 (the 6-second rule is Pep's),
  verticality LOW (~35 — the point is control), tempo_control (queued).
- **Sacchi** (the 4-4-2 pressing block): compactness ≤25 m (block_height
  mid), line_hold 95, push_up 90, balance 95, marking ZONAL
  (man_orientation 0), press_as_unit (queued) — the whole team moves on
  one string.
- **Klopp/Rangnick** (gegenpress): counter_press 100, verticality 80,
  push_up 85, transition speed over possession (counter_attack queued).
- **Mourinho** (low-block transition): push_up 25, line_hold 90, balance
  90, cover 95, counter_attack 95 (queued), verticality 85 IN TRANSITION
  only (phase-dependent styles need the tactic FSM).
- **Simeone** (5-4-1/4-4-2 mid-block): balance 95, compact two banks,
  double_team 90 on the touchline trap, delay 95, restraint (queued) 90.
- **Lobanovskyi** (universality, the scientific school): every player
  high on EVERY concept — the vector is flat and high; his legacy is the
  measurement idea itself (our harness is Lobanovskyian).
- **Zeman** (vertical chaos): verticality 100, push_up 95, placement 90,
  defense left as an exercise — the fun preset.
- **Gasperini** (man-orientation all over): man_orientation 100 with the
  back line too — the stress test for marking vs runs interplay.
- **De Zerbi** (bait-press build): keeper_sweep 95 + build-out pauses
  (tempo_control + play_out_back, queued) — luring the press to beat it.
- **Herrera** (catenaccio): the historical libero = cover_man 100 as a
  PERMANENT role — era content for the §5.1 ladder.

**THE CLUB PRESET — "Lighthouse" [FH]:** the club's own game model is
Bielsa-based with modifications (James), formalized in the U.S. Soccer
U17+ framework extraction at `docs/game-model/` (verbatim principles →
sub-principles — the intended Game Model DB source). First-pass vector
from its stated principles: "advance quickly / high energy / high tempo"
→ verticality 85, counter_press 85; "create attacking shape, stretch,
pin their back line" → spread_wide 90, run_in_behind 85, push_up 85;
"minimum 5 ahead of the ball + support behind for circulation" →
support 90, back_outlet 80; marking stays nearer zonal than full Bielsa
(man_orientation ~55 — the "modification"). Landed as DB rows (mig 630):
every Lighthouse rating row cites its verbatim source line.

Teams WEAR a preset (mig 631): `game_demo_teams.style_preset` names one
and the daemon overlays it at boot and across band changes — Lighthouse
XI boots playing the club game model, no admin tap needed.

Preset rows LANDED (mig 630, `game_style_presets` +
`game_style_preset_ratings`): a preset is an OVERLAY — it carries ratings
only for the dials the school names (concept NAMES, not bit ids; an
explicit 0 row is meaningful — Sacchi zeroes man-mark), and applying one
leaves every unnamed concept at the player's current value, so "Bielsa
base + modifications" composes. The daemon loads the catalog at boot,
serves names via the PRESETS frame (0x35), and APPLY_PRESET (0x36,
admin) paints one team in one tap — the edit mode's preset bar. Formation
+ level overlay per preset remain future columns; queued concepts join
their preset rows when their bits land.

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
