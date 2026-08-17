-- ═══════════════════════════════════════════════════════════════════════
-- 286-gcal-men-boy-girl-aliases.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- gcal_team_aliases only ever got the singular+plural treatment for
-- Women (migration 122 added both 'women' and 'womens'). 'Mens' and
-- 'Boys' never got a 'Men'/'Boy' twin, so ops typing `Club: Men` (or
-- `Club: Boy`) into a gcal description silently fails to attach a
-- roster. This mirrors every gcal_team_aliases row that currently
-- points at an ACTIVE team with a singular club_alias twin, same
-- team_id, same team_alias spelling.
--
-- Verified against live `teams`/`gcal_team_aliases` state, not just
-- migration history — several rows implied by earlier migrations
-- (122/232/275/276) turned out stale by the time this ran:
--   * mens 'practice'/'pickup' (908/909) and 'liga 2'/'liga2' (121)
--     are now is_active=false — not mirrored.
--   * 'adult' (122) and the legacy 'u8'/'u12'/'u16' rows (916/917/911)
--     are retired — not mirrored (already excluded before).
--   * boys 'u19'/'u19 boys' point at team 932, which is is_active=false
--     — not mirrored, despite being the "real" catch-all row.
--   * No gender_category='girls' team exists in `teams` at all right
--     now (the 232 migration's girls pool rows never landed / were
--     removed later) — nothing to mirror for 'girl'.
--   * Team display names dropped "Boys" (migration 277), so a
--     name-based lookup for 'U6 Boys'/'U19 Boys' would silently match
--     zero rows; team_ids are hardcoded from a live query instead.

BEGIN;

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('men', 'apsl',   35,  'Alt club spelling — accepts `Club: Men`'),
    ('men', 'liga 1', 120, 'Alt club spelling'),
    ('men', 'liga1',  120, 'Alt club spelling'),

    ('boy', 'u8 boys',  912, 'Alt club spelling — accepts `Club: Boy`'),
    ('boy', 'u10',      913, 'Alt club spelling'),
    ('boy', 'u10 boys', 913, 'Alt club spelling'),
    ('boy', 'u12 boys', 914, 'Alt club spelling'),
    ('boy', 'u6',       931, 'Alt club spelling'),
    ('boy', 'u6 boys',  931, 'Alt club spelling')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
