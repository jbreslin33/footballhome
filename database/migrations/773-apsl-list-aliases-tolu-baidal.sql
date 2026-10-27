-- 773 (2026-10-27) — two APSL TeamPass list spellings that are our players.
-- The #teams OFFICIAL ROSTER section (mig 770/772) showed them as
-- "not in Football Home":
--   "Oluwtolupe Asekun-Masha" = Tolu Asekun-Masha (22598) — full first name, league typo
--   "Victor Baidel"           = Victor Baidal (22301)     — one letter
-- (22599 is an empty second "Tolu Asekun-Masha" row with no teams — not used.)

INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT 1, fh_name_key(v.n), v.p, v.note
  FROM (VALUES ('Oluwtolupe Asekun-Masha', 22598, 'TeamPass has his full first name Oluwtolupe; we have Tolu'),
               ('Victor Baidel', 22301, 'TeamPass spells it Baidel, we have Baidal')) AS v(n, p, note)
ON CONFLICT (source_id, name_key) DO NOTHING;

-- re-run the match trigger over the stored list
UPDATE official_roster_names SET full_name = full_name WHERE source_id = 1;

-- the grant the next 🌐 pull would make (mig 769 rule)
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
