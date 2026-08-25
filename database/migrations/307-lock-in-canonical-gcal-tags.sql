-- 307 — One spelling per team. Prune the unused alias variants.
--
-- Why (2026-08-25, owner: "lets get rid of the also accepted it will get
-- confusing. lets lock in actual vars").
--
-- gcal_team_aliases had accumulated three spellings per youth team — the
-- bare age ('u8'), a '<age> boys' form, and now the full team name ('u8
-- travel'). Choice is the problem, not the feature: the Travel/Intramural
-- split (migration 306) made the bare forms actively misleading, because
-- 'u8' resolves to U8 Travel ALONE and silently excludes the house team.
-- An ops person typing the tag they have always typed now reaches half
-- the kids they mean to.
--
-- The canonical tag is the team's own name, lowercased. Nothing else.
--
-- ── What this migration does NOT delete, and why ──────────────────────
-- Five bare tags are load-bearing this minute. The two live recurring
-- youth practices carry `Team: u6, u8` (711 future instances) and
-- `Team: u10, u12, u19` (710), so deleting u6/u8/u10/u12/u19 today would
-- unattach 1,421 practices and every kid would lose them from their
-- schedule. They come out in a follow-up, AFTER those two calendar series
-- are retagged with the full names — that edit happens in Google
-- Calendar, not here, and gcal-classify.js rebuilds fh_event_teams from
-- the tags on its next run.
--
-- Everything removed below was verified against every non-deleted
-- gcal_event: no event, past or future, uses any of these spellings. The
-- mens events already tag 'apsl' and 'liga 1', which are canonical, so
-- the mens side needs no calendar edit at all.
--
-- The singular club aliases go with them. Migration 286 added 'boy' /
-- 'men' / 'women' twins so `Club: Boy` would work, but no event has ever
-- used one, and the same argument applies: one spelling.

BEGIN;

-- Guard: refuse to remove a spelling any surviving calendar event relies
-- on. Cheaper than discovering it from 1,400 empty practice rosters.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(DISTINCT a.team_alias, ', ')
      INTO bad
      FROM gcal_team_aliases a
      JOIN gcal_events ge
        ON ge.deleted_at IS NULL
       AND ge.description ~* ('Team:[^' || chr(10) || chr(13) || ']*(^|[,: ])'
                              || regexp_replace(a.team_alias, '([.*+?()\[\]{}|^$\\])', '\\\1', 'g')
                              || '\s*($|,)')
     WHERE a.team_alias IN ('u8 boys','u10 boys','u12 boys','u6 boys',
                            'u16 boys','u19 boys','u16','liga1','tricounty');
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'alias still used by a calendar event: %', bad;
    END IF;
END $$;

-- Redundant team spellings — every one unused by any event.
DELETE FROM gcal_team_aliases
 WHERE team_alias IN ('u8 boys','u10 boys','u12 boys','u6 boys',
                      'u16 boys','u19 boys',   -- '<age> boys' forms
                      'u16',                   -- bare form, nothing tags it
                      'liga1',                 -- events use 'liga 1'
                      'tricounty');            -- events use 'tri county'

-- Singular club spellings — never used.
DELETE FROM gcal_team_aliases WHERE club_alias IN ('boy','men','women');

COMMIT;
