-- 657 (2026-10-23) — game: hand edits survive the squad loader.
--
-- James: "then i and u can edit over time" / "victor baidal is probably
-- faster than 90% of pros … but he lacks other things pros have".
-- game/scripts/load_squads.py writes DERIVED ratings (record + lineups);
-- anything else — the in-game editor (/api/game/player), James, Claude — is
-- EDITED and the loader never overwrites it. The column defaults to
-- 'edited', so the backend's editor save needs no change.
ALTER TABLE game_demo_player_attributes
    ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'edited' CHECK (source IN ('derived', 'edited'));
COMMENT ON COLUMN game_demo_player_attributes.source IS 'derived = load_squads.py (record + lineups; replaced on re-run); edited = set by a person (kept) (mig 657).';
UPDATE game_demo_player_attributes SET source = 'derived';
