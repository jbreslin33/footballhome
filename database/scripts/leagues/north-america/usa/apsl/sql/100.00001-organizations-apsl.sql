-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Organizations - APSL
-- Total Records: 53
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO organizations (id, name) SELECT 100, 'Falcons FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Falcons FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 101, 'Scrub Nation' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Scrub Nation') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 102, 'Praia Kapital' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Praia Kapital') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 103, 'South Coast Union' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'South Coast Union') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 104, 'Project Football' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Project Football') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 105, 'Invictus FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Invictus FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 106, 'Fitchburg FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Fitchburg FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 107, 'Somerville United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Somerville United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 108, 'KO Elites' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'KO Elites') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 109, 'Glastonbury Celtic' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Glastonbury Celtic') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 110, 'Wildcat FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Wildcat FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 111, 'Hermandad Connecticut' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Hermandad Connecticut') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 112, 'NY Greek Americans' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'NY Greek Americans') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 113, 'Hoboken FC 1912' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Hoboken FC 1912') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 114, 'NY Pancyprian Freedoms' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'NY Pancyprian Freedoms') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 115, 'Lansdowne Yonkers FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lansdowne Yonkers FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 116, 'Doxa FCW' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Doxa FCW') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 117, 'Leros SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Leros SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 118, 'NY International FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'NY International FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 119, 'Richmond County FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Richmond County FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 120, 'Zum Schneider FC 03' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Zum Schneider FC 03') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 121, 'Central Park Rangers FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Central Park Rangers FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 122, 'SC Vistula Garfield' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'SC Vistula Garfield') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 123, 'NY Athletic Club' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'NY Athletic Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 124, 'WC Predators' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'WC Predators') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 125, 'Alloy Soccer Club' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Alloy Soccer Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 126, 'Oaklyn United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Oaklyn United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 127, 'Real Central NJ Soccer' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Real Central NJ Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 128, 'Philadelphia Heritage SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia Heritage SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 129, 'Philadelphia Soccer Club' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Philadelphia Soccer Club') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 130, 'Vidas United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Vidas United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 131, 'GAK' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'GAK') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 132, 'Lighthouse 1893 SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Lighthouse 1893 SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 133, 'Jersey Shore Boca' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Jersey Shore Boca') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 134, 'Sewell Old Boys FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Sewell Old Boys FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 135, 'Medford Strikers' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Medford Strikers') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 136, 'Nova FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Nova FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 137, 'VA Marauders FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'VA Marauders FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 138, 'Wave FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Wave FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 139, 'PFA EPSL' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'PFA EPSL') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 140, 'Grove Soccer' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Grove Soccer') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 141, 'Christos FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Christos FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 142, 'Delmarva Thunder' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Delmarva Thunder') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 143, 'PW Nova' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'PW Nova') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 144, 'Terminus FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Terminus FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 145, 'Prima FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Prima FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 146, 'Majestic SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Majestic SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 147, 'Peachtree FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Peachtree FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 148, 'Bel Calcio FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Bel Calcio FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 149, 'Buckhead SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Buckhead SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 150, 'Alliance SC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Alliance SC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 151, 'SC Gwinnett' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'SC Gwinnett') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO organizations (id, name) SELECT 152, 'Georgia United FC' WHERE NOT EXISTS (SELECT 1 FROM organizations WHERE name = 'Georgia United FC') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
