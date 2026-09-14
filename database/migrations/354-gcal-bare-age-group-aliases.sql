-- 354 — Bare age-group tags for youth games (owner 2026-09-13).
--
-- Game entries in gcal read "Team: U8" / "Team: U10" / "Team: U12" with
-- no travel/intramural qualifier.  Only the qualified forms were aliased
-- (migration 121 shape), so the 9/19 PPR games at Torresdale and East
-- Falls classified with zero team links and never reached a feed.
--
-- PPR league games are played by the travel squads only — intramural
-- teams never face another club — so the bare tag is unambiguous.
-- Girls play on the boys teams; "Club: Boys, Girls" resolves through the
-- boys row, so no girls|… rows are needed.  APPEND-ONLY table.
BEGIN;

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('boys', 'u8',  912, 'Bare age group → U8 Travel: PPR games are travel-only (migration 354)'),
    ('boys', 'u10', 913, 'Bare age group → U10 Travel: PPR games are travel-only (migration 354)'),
    ('boys', 'u12', 914, 'Bare age group → U12 Travel: PPR games are travel-only (migration 354)')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
