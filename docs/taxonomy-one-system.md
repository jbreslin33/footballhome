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
4. After it lands: `python3 scripts/taxonomy/export_engine_index.py | sudo podman exec -i
   footballhome_db psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1 -1` so the page
   shows the current classes, source and line numbers (the tag is the anchor).

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
