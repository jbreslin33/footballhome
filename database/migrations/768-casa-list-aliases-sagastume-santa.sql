-- 768 (2026-10-27) — two CASA Liga 1 list spellings that are our players.
--
-- Mig 767 let the CASA list decide the ⚠ registration gap; that surfaced
-- two names the exact match misses (mig 645's alias table is the fix):
--   "Anthony Sagastume"      = Anthony Sagustume (3508) — one letter
--   "LEONARDO Santa Castano" = Leo Santa (3511) — full name + second surname

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT 2, fh_name_key(v.n), v.p, v.note
  FROM (VALUES ('Anthony Sagastume', 3508, 'CASA sheet spells it Sagastume, we have Sagustume'),
               ('LEONARDO Santa Castano', 3511, 'CASA sheet has his full name Leonardo Santa Castano')) AS v(n, p, note)
ON CONFLICT (source_id, name_key) DO NOTHING;
