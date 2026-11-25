# Taxonomy and engine: one system

Owner, 2026-11-24: "being aware of a concept in the engine and using it in game if data supports
it is valid right? we need the engine to be aware of all of 'football' and its concepts right? it
doesn't mean u use it all?" · "your trying to invent football concepts with game right now …
instead of picking off the shelf a concept" · "this is what engine would select from right? the
engine doesn't have extra stuff lol we are not aware of?" · "we need both in sync 1 system all
concepts" · "this is a holistic system that feeds off each other" · "enforce then".

## The idea

The club's catalogue of football (`game_concepts` and its neighbours) and the game engine
(`game/src/ai`) are one list seen from two sides. Nothing the engine does is unknown to the
catalogue; nothing in the catalogue is hidden from view when the engine does not act on it yet.
The window is ⚽ Football → 🧬 Taxonomy (`#football-taxonomy`).

Three layers (the working rule since 11/24):

1. **Catalogue** — every concept, as rows.
2. **Capability** — the engine can execute it properly; built and tested by itself; off by default.
3. **Usage** — how often and when a side does it: for the Premier League sides only from data
   (it may be zero), for the teaching room from the plan.

And the chain a player runs: **recognise → choose → execute**, three separate things that fail
in three different ways. Recognition includes how soon. Every situation has a ladder of answers
from naive to expert; the naive habits are concepts too.

## What is enforced

A **behaviour** is a distinct football thing a player or the team reads or does. Each has:

| | Where | Checked by |
|---|---|---|
| a tag `// [behaviour: <code>]` above it | the engine source | `game/scripts/check_behaviours.sh`, in the image build (fails the build) |
| a line | `game/src/ai/behaviours.list` | the same script |
| a row | `game_engine_behaviours` | `scripts/taxonomy/check_engine_sync.py`, first step of `make game-deploy` |

So a new behaviour ships with all three or not at all, and a removed one takes its line and its
row with it.

Each row has a **standing**:

- `concept` — a catalogue concept names it (`concept_id`).
- `unnamed` — real football with no catalogue row yet (`suggested` = a name to consider).
- `fudge` — a mechanical patch with no football meaning. A fudge is debt: fix the cause or
  give it a football reason.

`is_read` marks a recognition (who wins the race, is the pass safe, which phase).

## Adding or changing a behaviour

1. Write it, with `// [behaviour: your_code]` on the line above.
2. Add `your_code` to `game/src/ai/behaviours.list`.
3. Add its `game_engine_behaviours` row by migration: what it does, its standing, its concept.
   No concept fits → first ask whether a catalogue concept should have been picked off the
   shelf instead of inventing one; if it is genuinely new football, add the concept row too.
4. Open ⚽ Football → 🧬 Taxonomy: it re-reads the code on load and shows the new behaviour, its
   class and its source (the tag is the anchor), or says exactly what is out of step.

## Not done yet

- **Tags are comments.** They prove a behaviour is declared, not that it runs. The next step is
  behaviours as classes selected by code (the tactics board's `JobRule` / `RuleBook` in
  `shared/tactics/TacticGeometry.hpp` is the pattern): a `Concept` parent, a child per
  mechanism, a row per concept that says whether a side uses it and how often.
- **21 behaviours in `DefendingBlock.cpp` are `pending`** in the list: the file was mid-trial
  when the tags went in. Their rows exist; the tags are owed.
- **The mappings are a first pass** from a full read of the code on 11/24. 85 behaviours are
  `unnamed` and wait for the owner's call.
- **Recognition is not a layer yet.** The engine reads perfectly and instantly for everyone.

## Where a concept lives: the three chips (migs 1827 / 1828)

Owner, 2026-11-24: "i need on each concept card wherther icons for if used in game, db,
engine" · "clicking each one takes you to pertiientn info" · "db icon should show me talbe and
relationships and normalzation" · "engine ashould talk about and demo how its used … show the
players moving and demonstrating the concept in a popup game on a loop" · "the popup game shold
run the engine full".

Every concept card (and its sheet) carries three chips, lit or dim:

| Chip | Lit when | Opens |
|---|---|---|
| 🗄 DB | always (a `game_concepts` row) | the database sheet: the table with its key and foreign keys, this row, the rows it points to, every table that points at it with its rows, and the tables with nothing for it yet. `GET /api/tactic-plans/taxonomy/db?concept=` (`TacticPlans::conceptDb`) reads it from the Postgres catalogue, so a new table or column shows without a code change. Staff only. |
| 🎮 Game | a `game_engine_behaviours` row names it, or a `game_engine_acts` row | the game sheet: what the engine does with it, and ▶ the concept loop |
| ⚙️ C++ | a behaviour of it exists, or one of its board jobs has a placement class | the class sheet (parents, children, source); several classes → the concept sheet's 🧱 list |

**The concept loop** — `/game.html?concept=<game_concepts id>`, opened as a popup window (the
site answers `X-Frame-Options DENY`, so it is not an iframe). It is the ordinary live match: the
whole engine, both sides. `frontend/js/game/client.js` ("Concept loop") watches the BRAIN feed;
each time a player starts playing the concept, 3 s before to 5 s after becomes a clip, replayed
on a loop from the viewer's 2-minute history with only that player's label on, while the match
runs on and newer examples queue (twice round, then on to the next). The bar's words are the
taxonomy page's `loop_*` rows, handed to the popup by `postMessage`.

Limit, today: the engine names a concept per player only for the acts in `game_engine_acts`
(six: block spot, recover, cover, press the ball, chase the ball, mark). For every other played
concept the popup shows the match with no loop and says so. Closing that needs the engine to
report which *behaviour* each player is running (its `[behaviour: code]`), in `game/src` — the
game session's files.

## Marking: the first concept built whole (mig 1830)

Owner, 2026-11-24, on the proof of concept: "if the player is in man-oriented marking that is a
state of marking? then we should have sub states where he does certain things to accomplish it
and both state machines should show" · "a player should have multiple state machines" · "focus
on 1 player and all his state machines" · "build it for marking first" · "this is going to be in
engine too right? we are working together with engine".

`game/src/ai/concepts/Marking.{hpp,cpp}` — an engine capability, fixed point, deterministic, off
by default (nothing in `Brain` or `DefendingBlock` calls it). The pattern for every concept after:

| | In marking | Generally |
|---|---|---|
| **Recognise** | an EYES machine (ball / man / both, by field of view; a shoulder check on a rhythm) writes a MEMORY: his man and the ball, each with the tick he saw it | what a player has not seen he does not know |
| **Choose** | eight steps, each with a cue read from his memory and a score; the best one becomes his state once it has held for his reaction time | the options and scores are kept for the viewer |
| **Execute** | the step's own spot and pace | |

The states as a stack — **Marking › kind › step**:

- *kind* is inheritance (`game_concept_links.kind = 'kind-of'`): man-oriented and zonal share
  every step and differ in one rule — he leaves, follow him in / pass him on.
- *step* is a sub-state (`'step-of'`): find your man, where to stand, track the runner, follow
  the dropper, pass him on, jump the pass, no turn, contain. Each is a catalogue concept and a
  behaviour code in `behaviours.list`.
- *alongside* run the eyes, and movement.

The look also found a mislabel: the engine's own `MarkMan` is zonal and was named by the
man-oriented concept. `zonal-marking` (concept 189) now names it.

**Where to see it.** The teaching room runs the mind for every plan job placed by the `mark`
rule; tap one of ours on `/teach.html` and the panel shows his stack, his eyes, what he knows
and how old it is (with a hollow ring on the pitch where he THINKS his man is), the options he
weighed, and what he has done. `&marking=zonal` switches the kind. Server → page: the `MIND`
frame (JSON, `TeachingServer::mindJson`), asked for with `MIND_WATCH`.

**Not fitted.** The priorities and distances are [FH] coaching values. They are the numbers data
should set when a side's use of each step is measured — and until then the Premier League match
does not use the mind.

## Always in step: sync on load, with a timestamp (mig 1836)

Owner, 2026-11-24: "i need to see all the concepts the sim and the db and c++ have on that page
because if the game engine is using something then that is part of taxonomy … and find if its
dup" · "the taxonomy needs to always check c++ and db and game etc when loading every time OR …
have a sync button" · "with timestamp" · "a sync on load is fine and a sync button is fine".

- **Every load of the page, and 🔄 Sync now**, runs `backend/src/models/TaxonomySync`: the
  backend reads the engine source (mounted read-only at `/engine`, `docker-compose.yml`), checks
  the `[behaviour: …]` tags, `behaviours.list` and `game_engine_behaviours` against each other,
  and — only when the source changed — refreshes the page's copy of the code (sources, classes,
  each behaviour's line and class). The result and its time are the one row of `taxonomy_sync`,
  shown at the top of the page; any difference is listed by name.
- **The game.** `make game-deploy` stamps `taxonomy_sync.game_built_at`; the page says whether
  the running game is older than the engine code.
- **Everything is on the page.** The engine's behaviours that no concept names are entries on
  the Concepts tab ("in the engine, not in the catalogue"), each with the concepts it might
  already be. **👯 Possible duplicates** lists those and the pairs of concepts one behaviour
  fits both of — candidates; a merge or a delete is the owner's call and lands as a migration.
- **🎮 has three states** (`game_engine_behaviours.in_sim`): lit = the sim runs it; dashed =
  built and tested, no side uses it yet; grey = nothing.

## Every concept has a fate

Owner, 2026-11-24: "they did not press as much in our data years as they do now. that is why we
have the concepts in but they may not be used much or at all but important its all there as
football waiting to be used … or discarded … but not ignored."

And then: "discarded means 0 used but not thrown out unless we think its dup or not real concept."

So a real concept is in one of two states: **used** (at the rate that season's data supports)
or **at zero** (kept — built or waiting to be — and unused; that is what "discarded" means
here). A concept row is **deleted** only when it is a duplicate of another or not a real
football concept. Never for being unused, and never unreachable. The marking mind is
the first: `physics.mark.mind` — no row = the sim's fitted marking, 1 = its markers run the mind.
A first 4-match on/off read was mixed (who gets tight and switches toward real; crosses, goals
and closing pace away), so it sits at zero until the harness fits its steps one at a time.

## Direct opponent, then pressing distance (migs 1853 / 1855)

Owner, 2026-11-24: "lets focus on stay in pressing distance and fully finish it" · "for the
concept he needs a direct opponent right? even if its a temp direct opponent because of
movement" · "yes build direct opponent first".

**Direct opponent** — `game/src/ai/concepts/DirectOpponent`. The side without the ball pairs
every outfielder with one of theirs: the man nearest his place in the defensive shape, nobody
taken twice, a pair kept until another of ours is 4 m better placed, the deepest of ours the
spare man, their furthest man left free. A recognition; the sim runs it every tick and it
moves nobody. Frame `PAIRS` (0x4B) carries it to the page.

**Stay in pressing distance** — `game/src/ai/concepts/PressingDistance`, on top of the pairs.

| | |
|---|---|
| **Recognise** | his REACH: how far he can cover (0.3 s reaction, then 6 m/s, "on him" = within 1.5 m) while a pass from where the ball is now travels to his man, at the engine's own pass speed for that length. His man inside his reach = in pressing distance. So the right gap is not a number: the further the ball is from his man, the further off he may stand. Also counted: the other opponents he could get to (the help). |
| **Choose** | `physics.pressdist.hold`, 0 … 1 — the share of the missing distance he takes back. **No row = 0**: read only, the sim as fitted. |
| **Execute** | from his place in the shape (not from his feet), the step toward his man that leaves the gap equal to his reach; never more than 6 m off his place. `HoldBlockSpot` applies it; the trainer's label is the act `press_distance`. |

The reaction, pace and arrive distance are [FH] coaching values. The man on the ball is not
this concept, and the look found a mislabel: the engine's `press_ball` (the one presser) was
named by pressing-distance. It is now `close-down` ("Close down the man on the ball"), a new
catalogue row.

**Where to see it.** `/concept.html?concept=<pressing-distance id>`. The test of pressing
distance is a pass to a man somebody has, so that is what an example is: the page watches the
live match for a pass that arrives with a man who has a defender on him, and shows the
defender's reach as a circle (frame `REACH`, 0x4C) — live and dashed before the pass, frozen
at the moment it is struck, green when his man is inside it. The caption gives the gap, the
reach and the answer, then how far he was from his man as the ball arrived. It keeps both
answers coming: never a third example in a row with the same one.

**The harness read, 11/24** (dial 0 v 1, the same 8 matches each, seeds 7000 / 7100 × 4, scratch DB):

| | off | on | real |
|---|---|---|---|
| nearest defender to an attacker 52 m+ from the goal he attacks, ball near (m) | 6.5 | 6.1–6.2 | 5.2 |
| … one within 2 m of him (%) | 8.6–8.9 | 9.0–9.5 | 12.4 |
| … same band, ball far (m) | 9.2 | 8.6–8.9 | 7.4 |
| attacker 18–35 m out, ball near (m) | 3.2 | 3.1 | 3.8 |
| nearest opponent to a receiver at his touch, all (median m) | 5.8–6.0 | 5.65–5.7 | 7.4 |
| … controlled touches (median m) | 6.6–6.9 | 6.4–6.7 | 9.25 |

Mixed, and small. High up the pitch the sim's defenders stand too far off their men and the
step brings them toward real; near our goal and at the receiver's touch the sim is already
tighter than real and the step takes it further off. So the dial **stays at zero**. The next
trial is the step only where the gap is (the man 52 m+ from the goal he attacks), not everywhere.

**Owed.** That banded trial; and whether the pace and reaction should be the man's own attributes.

## Cover shadow (mig 1857)

The concept after pressing distance. The catalogue's cue: "Pressing their centre back: run at
him along the line to his nearest receiver, so that pass is blocked by your body."

`game/src/ai/concepts/CoverShadow`:

| | |
|---|---|
| **Recognise** | every outfielder of the side without the ball: which opponents stand in his shadow — further from the ball than he is, with him within 1.2 m (his body and a stride either side) of the straight line from the ball to that man. And for whoever closes the ball down: the pass to block — the carrier's nearest mate within 30 m who is level with him or nearer our goal. |
| **Choose** | `physics.shadow.press`, 0 … 1. **No row = 0**: read only. |
| **Execute** | in `PressBall`: his stand-off spot moves off the carrier's line to our goal onto the carrier's line to that receiver, the same distance off him, by the dial's share. The trainer's label is the act `press_shadow`. |

**Where to see it.** `/concept.html?concept=<cover-shadow id>`. An example is a man closing
the ball down (the engine's `close-down` label). His shadow is drawn as a dark wedge from the
ball through him (frame `SHADOW`, 0x4D, carries who is in it and the pass to block); men in it
are tagged, and when the nearest pass is not in it the line to that receiver is drawn white and
tagged open. With the dial at zero that is what the sim's presser mostly shows: he comes
goal-side and the pass beside him is open — the catalogue's "lacking", on screen.

**Owed.** The harness read with `physics.shadow.press` above 0; the same shadow used by a
man who is not pressing (`shadow-second-man`, `shadow-the-line`), which needs him to choose a
second man — the read for it is already there (`hiddenBy`).

## Direct opponent by the matchup; concepts watched switched on (mig 1866)

Owner, 2026-11-24, on the first build: "direct opponent would never be that far away lol. a
direct opponent is normally 9 vs 4,5  10 v 6 2 v 7 11v3 8v8 but of course in the heat of
battle you have to adjust to the ball area" · "i am not seeing the concept ran?"

**The pairing**, `game/src/ai/concepts/DirectOpponent`, in three steps for the side without
the ball:

1. **The battle** — everyone within 18 m of the ball pairs with the opponents actually in that
   scene, nearest first, nobody twice.
2. **The matchup** — everyone else by position number, from `game_direct_opponents` (the
   owner's pairs of 10/24, back in after the clean slate): 9 on their 4 or 5, 4 and 5 on their
   9 (the nearer marks, the other is the spare man), 10 on 6, 6 on 10, 8 on 8, full-backs and
   wingers on each other **along the same touchline**, whichever of 7 / 11 a formation calls
   the left.
3. **No matchup** — only a man whose number finds nobody in their shape takes the nearest man
   left, and only within 20 m; otherwise he has nobody.

A pair is kept until another is 4 m better. The pairs reach the engine as model params
(`concept.direct.pair_<n>_<m>`, MatchSetup), like the Laws' distances. Measured on the live
match for a minute: matchup pairs median 8 m apart (max 27), battle pairs 4.7 m; the commonest
pairs 2v11, 7v3, 3v7, 11v2, 5v9, 8v8, 6v10.

**Watching a concept switched on.** `game_concept_dials` holds the model param(s) that switch
a concept on. `/game?trainer=1&concept=<id>` opens a private room of the full engine (Leicester
v Arsenal, the live match's sides) with those dials on for both teams; the clip viewer opens
it for pressing distance and cover shadow, plays it, and cuts its examples from the men doing
the concept (the acts `press_distance` and `press_shadow`). A green banner says it is that room,
not the real sim. A concept with a dial gets one row here and the viewer can show it.

## The brain panel: what the engine is doing, layer by layer (migs 1872 / 1874)

Owner, 2026-11-24: "is he in 'stay in pressing distance' the whole time … can you be in 2
states of same machine … we need this explained on the graphic" · "it needs to be crystal
clear what is going on in the 'brain' and what we are seeing".

The clip viewer's 🧠 tab draws the layers the engine really has, one lane each across the
example, with a white playhead:

| Lane | What it is | How many | At a time |
|---|---|---|---|
| **Team** | the team's phase (`ai::Phase`, frame `PHASE` 0x4E) | 6 | one, shared by all eleven |
| **Him** | his state (`PlayerState`, frame `STATES` 0x4F — the engine's real state, mapped to `game_engine_terms.code` by `engine_name`) | 11 | one — never two of the same machine |
| **Using** | the concept he applies inside that state (the trainer act) — changes HOW he does the state; not a state | — | none or one |
| **Knows** | reads that always run: his man (and why), can he reach him, who is hidden behind him | — | all at once; they decide nothing |

Above the lanes: RIGHT NOW in words, and one status line for THIS concept: active, or not
active and why (his team has the ball / he is in another state — pressing distance lives
only in "Hold his place", the cover shadow only in "Press the man on the ball" / his man is
already in reach). Caption line 1 on the pitch says the same three layers.

Before the `STATES` frame the page guessed his state from his order of the tick; with the
ball loose that showed "We have the ball" beside "Hold his place in the defensive shape".
The guess is now only a fallback before the first frame arrives.

## Player brain as parallel machines (agreed 11/25; the viewer shows it first, mig 1882)

Owner, 2026-11-25: "i could be in state of 352(212) as the 1 in middle of 212. could be in man
marking direct opponent … but also could be in my team has ball … i could be in cover shadow
and press or recover … because my line was broken" · "formation is one state, man marking or
zonal is another state machine? then under each there needs to be a state machine for diff
concepts and maybe multi state machines? like cover shadow or not. maybe there is no cover
shadow to do" · "wouldn't it be better ai coding to use state machines" · "can we allow for
temp 'extra' state machine at a certain level? … they would complement or fight each other but
run" · "ok yes like it. but for display … display the ones that are on".

**The design** (statecharts: machines in parallel, each in exactly one state):

- Team: **phase** (6).
- Per player: **formation** (his place; in it / stepped out / getting back), **marking scheme**
  (man-oriented / zonal / free, with the scheme's own steps under it), **one machine per
  concept**, and the **action** his body does (with commitment, not re-chosen every tick).
- Every concept machine has a **"nothing to do"** state and sleeps there until its trigger
  (no shadow to do, line not broken …). Several can be awake at once — that is how two
  same-level things happen together. A machine is *created* for a moment only for situations
  tied to particular players (a 2-v-1); everything else is always there, asleep.
- Awake machines **propose** (a spot, a facing, a pace, maybe a body action); a **resolver**
  combines them: complementing proposals merge (the cover shadow bends the press's path),
  conflicting ones go by priority, and the body does one action at a time. Priority, proposed
  11/25 and the owner's to change (copy row `machine_order`): recover › press › loose ball ›
  double-team › marking › cover shadow › cover › pressing distance › (hold formation).

**Today** the engine has the team phase, ONE job machine per player (11 states) and an action
chosen fresh every tick; the rest is squeezed into the job state (the "concept" label flickers
inside "Hold his place"). The clip viewer already draws the agreed stack, read from what the
engine sends: core (team phase, his job, his action) and only the machines AWAKE now, in
priority order, the first marked as the one that wins if they fight; the timeline has a row per
machine that woke up in the example. **Next:** the engine runs real machines, one at a time
with the game session — marking scheme and cover shadow first — each checked against the
real-match data.

### The first engine machines (mig 1883)

`game/src/ai/concepts/Machines` — `PlayerMachines`, held by the defending block, updated at the
end of `Brain::think` after the job states (`machine_tick`), one `MachineSense` per player:

| Machine | States (0 = asleep) | Proposes |
|---|---|---|
| Marking scheme | watching his man · zonal on #x · free (spare man) | nothing yet — "mark his man" still executes |
| Cover shadow | hiding (passive) · pressing on the lane | `bendPress`: the presser onto the lane to the man he hides (`physics.shadow.press`) |
| Pressing distance | stepping into reach | `bendHold`: his place toward his man (`physics.pressdist.hold`) |

An awake machine is committed for `hold_ticks` (0.3 s) unless what it lives in has gone
(`machine_commit`). The two bends that sat inline in `HoldBlockSpot` and `PressBall` are these
proposals now, applied where the job sets its target; the trainer acts (`press_distance`,
`press_shadow`) are read from the machines. With no dial rows the goldens are unchanged
(3v3 `0x440f6541eceb348b`, 11v11 `0xa30722dbc1ad79fe`). Frame `MACHINES` (0x50) sends the awake
ones; `game_engine_terms` kinds `machine` / `machine_state` name them. The viewer marks
engine-run machines ⚙; recover, press, loose ball, double-team and cover are still read from the
job state.

**Next:** those five become machines too; then the first machine that REPLACES the job's orders,
and with it the resolver's rule for two that fight (the order in `machine_order`).

### All eight machines in the engine; states named; the label a table (mig 1888)

Owner, 2026-11-25: "how is the concept not in the state the whole time? when they don't have ball
and defending … is it a state or not" · "just name the state the player is in a table field. then
if you want to editorialise who he is marking or whatever then use other fields".

- **Pressing distance is ON the whole time** his side defends and he has a man (not the presser,
  not the loose ball's man); **stepping** is a deeper state inside it (dial above 0 only).
- The five that were the page's guess are engine machines too: **recover** (his place 5 m+
  behind him), **press**, **loose ball**, **double-team**, **cover** (the deeper CB). Recognitions
  for now — the job states execute.
- **Commitment only on the way down:** a machine goes deeper at once (on → stepping) but keeps
  a state 0.3 s before dropping to a lower one.
- Every machine and state has a name in `game_engine_terms` (kinds `machine`, `machine_state`).
- The player's label is a **table: Machine | State | Man | Detail** — the state's name in its own
  field; who he is minding and the numbers (e.g. "16.6 m away · can reach 14.1 m · OUT of reach")
  in the others. Every machine that is on gets a row; tap a row for its meaning.

With no dial rows the goldens are unchanged.

### The resolver; recover takes his spot (mig 1891)

The first machine that **replaces** the job's orders, and the rule for two that fight:

- `kPriority` in `Machines.hpp` is `machine_order` (recover › press › loose ball › double-team ›
  marking › cover shadow › cover › pressing distance); `test_machines` pins the two equal.
- A machine either **takes his spot** (its proposal is the target) or **bends** one. The resolver
  (`driver`, `machine_resolver`): the highest awake spot-taker drives; a lower machine's bend of
  that spot is dropped (they fight). A bend of the job's own target — the cover shadow on the
  press — still applies (they complement).
- **Recover** is the first spot-taker (`recover_takes_his_spot`): his place 5 m+ goal-side of
  him, `HoldBlockSpot` asks the machines first and recover sends him straight back to his place;
  pressing distance does not pull him toward his man until he is back (and recover's 0.3 s
  commitment is up).

With no dial rows pressing distance never bends, so the goldens are unchanged; with
`physics.pressdist.hold` on, a man caught behind now gets back before he steps to his man.

**Next:** press, loose ball and double-team leave the job states and become spot-takers in the
same way, so the job machine shrinks to "in the block or not".
