-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Team Logos
-- Idempotent: safe to re-run on every DB init
-- Covers APSL Delaware River Conference + CASA teams sharing same clubs
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- APSL Delaware River Conference
UPDATE teams SET logo_url = '/images/teams/logos/wc-predators.jpg' WHERE name = 'WC Predators' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/alloy-sc.jpg' WHERE name = 'Alloy Soccer Club' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/oaklyn-united.jpg' WHERE name = 'Oaklyn United FC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/real-central-nj.png' WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/philly-heritage.jpeg' WHERE name = 'Philadelphia Heritage SC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/vidas-united.jpg' WHERE name = 'Vidas United FC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/jersey-shore-boca.jpg' WHERE name = 'Jersey Shore Boca' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/gak.png' WHERE name = 'GAK' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/medford-strikers.png' WHERE name = 'Medford Strikers' AND source_system_id = 1;
UPDATE teams SET logo_url = '/images/teams/logos/sewell-old-boys.jpg' WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1;

-- CASA teams (share logos with parent clubs)
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse Boys Club' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/lighthouse-1893.png' WHERE name = 'Lighthouse Boys Club U23' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/oaklyn-united.jpg' WHERE name = 'Oaklyn United FC II' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia Sierra Stars' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/philly-soccer-club.png' WHERE name = 'Philadelphia SC Select' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/sewell-old-boys.jpg' WHERE name = 'Sewell''s Old Boys' AND source_system_id = 2;
UPDATE teams SET logo_url = '/images/teams/logos/alloy-sc.jpg' WHERE name = 'Alloy Soccer Club Reserves' AND source_system_id = 2;
