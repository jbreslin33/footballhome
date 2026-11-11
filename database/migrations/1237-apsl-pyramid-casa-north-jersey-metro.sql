-- 1237 (2026-11-11) — #apsl-pyramid: CASA Select North Jersey feeds the
-- Metropolitan Conference only.
--
-- Owner 2026-11-11: "CASA North Jersey should only be related to
-- metropolitan".  Mig 823 named all four CASA Select regions Delaware River
-- feeders and mig 864 added North Jersey Liga 1 → Metropolitan as a second
-- link.  Now: parent = Metropolitan (its column on the chart), and the
-- Liga 1 → Delaware River link goes.  Liga 2 → Liga 1 → Liga 3 chain stays.
-- (The other three CASA Select regions stay Delaware River.)

UPDATE pyramid_competitions c
   SET parent_id = m.id
  FROM pyramid_competitions m
 WHERE m.kind = 'conference' AND m.name = 'Metropolitan Conference'
   AND c.name = 'CASA Select North Jersey'
   AND c.parent_id IS DISTINCT FROM m.id;

-- Its top table links into Metropolitan (kept / added) …
INSERT INTO pyramid_links (lower_source_id, lower_division, upper_competition_id)
SELECT s.id, 'Liga 1', m.id
  FROM pyramid_sources s
  JOIN pyramid_competitions c ON c.id = s.competition_id AND c.name = 'CASA Select North Jersey'
  JOIN pyramid_competitions m ON m.kind = 'conference' AND m.name = 'Metropolitan Conference'
ON CONFLICT DO NOTHING;

-- … and into no other conference.
DELETE FROM pyramid_links l
 USING pyramid_sources s, pyramid_competitions c, pyramid_competitions uc
 WHERE s.id = l.lower_source_id AND c.id = s.competition_id
   AND c.name = 'CASA Select North Jersey'
   AND uc.id = l.upper_competition_id
   AND uc.name <> 'Metropolitan Conference';
