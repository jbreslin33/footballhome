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

Used (at the rate that season's data supports), available at zero (built, wired into the sim
behind a setting, unused), or discarded with a reason. Never unreachable. The marking mind is
the first: `physics.mark.mind` — no row = the sim's fitted marking, 1 = its markers run the mind.
A first 4-match on/off read was mixed (who gets tight and switches toward real; crosses, goals
and closing pace away), so it sits at zero until the harness fits its steps one at a time.
