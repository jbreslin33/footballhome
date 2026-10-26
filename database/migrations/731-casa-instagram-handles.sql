-- 731: first CASA Instagram handles (mig 699) — public club accounts found
-- 2026-10-26 from club sites / Linktree / APSL team pages; owner OK'd them
-- "for now".  Danubia = the Men's Elite account (its CASA side), VE = the
-- soccer account (veclub31 is the whole social club).  Still missing:
-- Desert Hawks, Nomads FC, Persepolis FC, Philadelphia Lions, Phoenix,
-- Phoenix SCM — add on #casa-contacts as they turn up.

INSERT INTO club_social_handles (club_id, platform, handle)
SELECT c.id, 'instagram', v.handle
  FROM (VALUES ('Oaklyn United FC',          'oaklynunitedfc'),
               ('Philadelphia Heritage SC',  'philaheritagesc'),
               ('Philadelphia Sierra Stars', 'sierrastarsphilly'),
               ('WC Predators',              'west_chester_united_sc'),
               ('Vereinigung Erzgebirge',    'vesoccer'),
               ('Danubia Soccer Club',       'danubia_soccer'),
               ('Street Soccer USA Philly',  'streetsoccerphila'),
               ('Philadelphia SC Select',    'philasc_msoc')) v(club, handle)
  JOIN clubs c ON c.name = v.club
ON CONFLICT (club_id, platform) DO NOTHING;
