-- 1836 (2026-11-24): 🧬 Taxonomy — everything the engine does is on the page, and the duplicates show.
--
-- Owner 11/24: "i need to see all the concepts the sim and the db and c++ have on that page
-- because if the game engine is using something then that is part of taxonomy and we need to
-- include it and find if its dup that is first thing we prob need" · "we can actually have
-- players in game use the concepts as we go and light up the icon for game on the concept as
-- we go" · "we may end up deleting dups".
--
--   1. The Concepts tab now also lists the engine's behaviours that no catalogue concept names
--      (game_engine_behaviours.status unnamed / fudge) as entries of their own — "in the
--      engine, not in the catalogue yet" — each with the catalogue concepts nearest to it.
--   2. A duplicates view: an engine-only entry beside the concepts it may already be; and
--      pairs of catalogue concepts that one behaviour was judged to fit both of.  Evidence to
--      decide on — a merge or a delete is the owner's call and lands as a migration.
--   3. 🎮 has three states.  in_sim says whether the sim itself runs the behaviour today;
--      false = built and tested but not used by the sim yet (the marking mind until
--      physics.mark.mind is on).  The chip lights fully when the sim uses a concept.
ALTER TABLE game_engine_behaviours ADD COLUMN IF NOT EXISTS in_sim boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN game_engine_behaviours.in_sim IS
    'The sim itself runs this behaviour today. false = built and tested, a side can be given it, but no side uses it yet (flip it in the migration that turns its setting on).';
UPDATE game_engine_behaviours SET in_sim = false WHERE file LIKE '%/ai/concepts/Marking.%';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('reach pill: engine only', 'reach_engine', '⚠️ In the engine, not in the catalogue', 150),
    ('reach pill: possible duplicates', 'reach_dups', '👯 Possible duplicates', 151),
    ('section: engine-only entries', 'h_engine_only', 'In the engine, not in the catalogue yet', 152),
    ('engine-only card: a fudge', 'eo_fudge', 'A fudge — no football meaning', 153),
    ('engine-only card: no concept ({n} = behaviours)', 'eo_unnamed', 'No concept row yet · engine behaviours: {n}', 154),
    ('engine-only card: nearest concepts', 'eo_near', 'Could already be:', 155),
    ('engine-only card: nothing near', 'eo_none', 'Nothing in the catalogue is close.', 156),
    ('duplicates: intro', 'dup_intro', 'Candidates only — evidence to decide on. Merging or deleting is a decision, made one pair at a time.', 157),
    ('duplicates: engine entry vs concepts', 'dup_h_engine', 'The engine does it under no name — is it one of these?', 158),
    ('duplicates: concept pairs', 'dup_h_pairs', 'Two concepts that one engine behaviour fits — the same idea twice?', 159),
    ('duplicates: the behaviour that fits both ({n})', 'dup_pair_why', 'engine behaviours that fit both: {n}', 160),
    ('duplicates: none', 'dup_none', 'No candidates.', 161),
    ('game chip, built but not used: tip', 'where_game_built', 'Built and tested — the sim is not using it yet', 162),
    ('count line with engine-only ({n} shown, {total} concepts, {e} engine-only)', 'count_all', '{n} shown · {total} concepts in the catalogue · {e} more only in the engine', 163)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

--   4. Always in step, with a timestamp (owner: "the taxonomy needs to always check c++ and db
--      and game etc when loading every time OR … have a sync button" · "with timestamp" · "a
--      sync on load is fine and a sync button is fine").  The backend reads the engine source
--      (mounted read-only at /engine) on every load of the page and on 🔄 Sync now
--      (backend/src/models/TaxonomySync) and records here what it found.  game_built_at is
--      stamped by `make game-deploy`.
CREATE TABLE IF NOT EXISTS taxonomy_sync (
    id               smallint PRIMARY KEY CHECK (id = 1),
    checked_at       timestamptz,       -- the last check
    changed_at       timestamptz,       -- the last time the engine source had changed (classes / source refreshed)
    source_hash      text,
    source_newest_at timestamptz,       -- the newest engine source file
    in_sync          boolean,
    tagged           integer,           -- `// [behaviour: …]` codes in the source
    listed           integer,           -- game/src/ai/behaviours.list
    db_rows          integer,           -- game_engine_behaviours
    diff             jsonb,             -- { tag_not_listed, listed_not_tagged, code_not_db, db_not_code }
    game_built_at    timestamptz        -- when the running game's image was built (make game-deploy)
);
INSERT INTO taxonomy_sync (id) VALUES (1) ON CONFLICT DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — sync line: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('in sync ({when}, {n} behaviours)', 'sync_ok', '✅ C++, database and list agree — {n} behaviours · checked {when}', 170),
    ('out of sync ({when})', 'sync_bad', '⚠️ Out of step — checked {when}', 171),
    ('never checked', 'sync_never', 'Not checked yet — the engine source is not visible to the web server.', 172),
    ('game is behind the code ({when})', 'sync_game_stale', '🎮 The running game was built {when} and is OLDER than the engine code — deploy the game to play what the page shows.', 174),
    ('game is current ({when})', 'sync_game_ok', '🎮 The running game was built {when}, from this code.', 175),
    ('button', 'sync_now', '🔄 Sync now', 176),
    ('button, waiting', 'sync_wait', '🔄 Checking…', 177),
    ('diff: tagged in code, not in the list ({list})', 'sync_d_tag_not_listed', 'In the code but not in behaviours.list: {list}', 178),
    ('diff: listed, tagged nowhere ({list})', 'sync_d_listed_not_tagged', 'In behaviours.list but tagged nowhere in the code: {list}', 179),
    ('diff: in the engine, no row ({list})', 'sync_d_code_not_db', 'In the engine with no database row: {list}', 180),
    ('diff: a row for nothing ({list})', 'sync_d_db_not_code', 'In the database but not in the engine: {list}', 181),
    ('time: seconds ago ({n})', 'ago_s', '{n} s ago', 182),
    ('time: minutes ago ({n})', 'ago_m', '{n} min ago', 183),
    ('time: hours ago ({n})', 'ago_h', '{n} h ago', 184),
    ('time: at ({t})', 'ago_at', 'at {t}', 185)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The engine tab's intro named a commit; the page reads the working code now, so it says when.
UPDATE message_templates SET body = 'Everything the game engine does today: {n} behaviours, read straight from its code. They use {used} of the {total} concepts. A behaviour with no concept is a gap in the catalogue; a concept with no behaviour is knowledge the engine does not act on yet.'
 WHERE kind = 'taxonomy' AND tier = 'engine_intro2';
UPDATE message_templates SET body = 'The source for this is not in the database yet. Press 🔄 Sync now.'
 WHERE kind = 'taxonomy' AND tier = 'no_source';
