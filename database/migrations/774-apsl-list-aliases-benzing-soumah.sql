-- 774 (2026-10-27) — two more APSL TeamPass spellings that are our players
-- (still "not in Football Home" on #teams after mig 773):
--   "Joseph Benzig" = Joey Benzing (22241)    — full first name, league drops the n
--   "Isiaga Soumah" = Issiaga Soumah (14496)  — one letter
-- (22476 is a first-name-less "Soumah" row with no teams — not used.)

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT 1, fh_name_key(v.n), v.p, v.note
  FROM (VALUES ('Joseph Benzig', 22241, 'TeamPass has Joseph Benzig; we have Joey Benzing'),
               ('Isiaga Soumah', 14496, 'TeamPass spells it Isiaga, we have Issiaga')) AS v(n, p, note)
ON CONFLICT (source_id, name_key) DO NOTHING;

UPDATE official_roster_names SET full_name = full_name WHERE source_id = 1;

UPDATE team_persons tp
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
  FROM official_roster_sources s
 WHERE s.id = 1 AND tp.team_id = s.team_id AND tp.removed_at IS NULL
   AND (tp.roster_status_id IS NULL OR tp.roster_status_id IN
         (SELECT id FROM roster_statuses WHERE code IN
           ('not_on_roster','awaiting_approval','needs_itc','submitted_itc',
            'needs_transfer','awaiting_transfer','awaiting_roster_spot',
            'needs_docs','has_docs')))
   AND tp.person_id IN (SELECT n.person_id FROM official_roster_names n
                         WHERE n.source_id = s.id AND n.person_id IS NOT NULL);
