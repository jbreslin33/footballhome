-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Match Events - CSL
-- Goals, assists, cards, etc. from match event pages
-- Total Records: 797
--
-- Architecture: Name-based player lookups (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Match: 227496_6ED7A3C7C6F97034D16A42A2F3C90FE2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227496_6ED7A3C7C6F97034D16A42A2F3C90FE2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227496_6ED7A3C7C6F97034D16A42A2F3C90FE2' AND m.source_system_id = 3;

-- Match: 227551_FF3E2F38BCB715F41F50D94D8E9A741C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ibrahima' AND per.last_name = 'Barry'
WHERE m.external_id = '227551_FF3E2F38BCB715F41F50D94D8E9A741C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
WHERE m.external_id = '227551_FF3E2F38BCB715F41F50D94D8E9A741C' AND m.source_system_id = 3;

-- Match: 230064_C7AEC6345FA9CE65DB80FB61EB173999
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kenshiro' AND per.last_name = 'Kunishima'
WHERE m.external_id = '230064_C7AEC6345FA9CE65DB80FB61EB173999' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jason' AND per.last_name = 'Lawyer'
WHERE m.external_id = '230064_C7AEC6345FA9CE65DB80FB61EB173999' AND m.source_system_id = 3;

-- Match: 227499_6DDF3347739D8AC3968218D03CA6C76A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Codispoti'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Curbelo'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Evan' AND per.last_name = 'Jones'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Koshurba'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Koshurba'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amar' AND per.last_name = 'Mame Mor'
WHERE m.external_id = '227499_6DDF3347739D8AC3968218D03CA6C76A' AND m.source_system_id = 3;

-- Match: 230156_367C9C4FC522B18B97ADF5A3A75CAC29
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Fortich'
WHERE m.external_id = '230156_367C9C4FC522B18B97ADF5A3A75CAC29' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kouakou' AND per.last_name = 'Joel'
WHERE m.external_id = '230156_367C9C4FC522B18B97ADF5A3A75CAC29' AND m.source_system_id = 3;

-- Match: 233857_822700CBA55CEE6792208A015A89707A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Orayker' AND per.last_name = 'Escalona'
WHERE m.external_id = '233857_822700CBA55CEE6792208A015A89707A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Tejada'
WHERE m.external_id = '233857_822700CBA55CEE6792208A015A89707A' AND m.source_system_id = 3;

-- Match: 230067_01C39E6D085EFB03EAA45D27FEFAA259
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230067_01C39E6D085EFB03EAA45D27FEFAA259' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230067_01C39E6D085EFB03EAA45D27FEFAA259' AND m.source_system_id = 3;

-- Match: 230150_135F9055AD2952171A941450834126CD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mo' AND per.last_name = 'Jiyid'
WHERE m.external_id = '230150_135F9055AD2952171A941450834126CD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lukas' AND per.last_name = 'Kilian'
WHERE m.external_id = '230150_135F9055AD2952171A941450834126CD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Franco' AND per.last_name = 'Osco'
WHERE m.external_id = '230150_135F9055AD2952171A941450834126CD' AND m.source_system_id = 3;

-- Match: 230157_4EEB61594D091A8B0C0DDC302C9CFE80
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alon' AND per.last_name = 'Zuman'
WHERE m.external_id = '230157_4EEB61594D091A8B0C0DDC302C9CFE80' AND m.source_system_id = 3;

-- Match: 230068_122294F87D11928EC0E3820AB3AE4F81
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Pena'
WHERE m.external_id = '230068_122294F87D11928EC0E3820AB3AE4F81' AND m.source_system_id = 3;

-- Match: 233707_0344E4569260D968ABBCA8B7BBD81469
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233707_0344E4569260D968ABBCA8B7BBD81469' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '233707_0344E4569260D968ABBCA8B7BBD81469' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Junior Mafia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Clinton' AND per.last_name = 'Adu-Agyei'
WHERE m.external_id = '233707_0344E4569260D968ABBCA8B7BBD81469' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Junior Mafia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Clinton' AND per.last_name = 'Adu-Agyei'
WHERE m.external_id = '233707_0344E4569260D968ABBCA8B7BBD81469' AND m.source_system_id = 3;

-- Match: 227554_1E31CA502CED313AF7BAE33F2C0918C7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Waleed' AND per.last_name = 'Alouat'
WHERE m.external_id = '227554_1E31CA502CED313AF7BAE33F2C0918C7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Gomez'
WHERE m.external_id = '227554_1E31CA502CED313AF7BAE33F2C0918C7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Leonardo' AND per.last_name = 'Hinds'
WHERE m.external_id = '227554_1E31CA502CED313AF7BAE33F2C0918C7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dalibor' AND per.last_name = 'Tolicki'
WHERE m.external_id = '227554_1E31CA502CED313AF7BAE33F2C0918C7' AND m.source_system_id = 3;

-- Match: 227497_3A3E3DFFD3767C119ACB2BCCEE3A80AC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Antoine' AND per.last_name = 'Laurient'
WHERE m.external_id = '227497_3A3E3DFFD3767C119ACB2BCCEE3A80AC' AND m.source_system_id = 3;

-- Match: 227552_FBC1F5EF0F09D6FFEAAFE12881002E97
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yonatan' AND per.last_name = 'Reiter'
WHERE m.external_id = '227552_FBC1F5EF0F09D6FFEAAFE12881002E97' AND m.source_system_id = 3;

-- Match: 233855_D0AF804FFE2D4E1D702CD66965E5F795
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Daveed'
WHERE m.external_id = '233855_D0AF804FFE2D4E1D702CD66965E5F795' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '233855_D0AF804FFE2D4E1D702CD66965E5F795' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '233855_D0AF804FFE2D4E1D702CD66965E5F795' AND m.source_system_id = 3;

-- Match: 233854_57AD4440ABB7E4FB3868805F6338ED04
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdellahi' AND per.last_name = 'Limam Cherive'
WHERE m.external_id = '233854_57AD4440ABB7E4FB3868805F6338ED04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdellahi' AND per.last_name = 'Limam Cherive'
WHERE m.external_id = '233854_57AD4440ABB7E4FB3868805F6338ED04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Karl' AND per.last_name = 'McGinnis'
WHERE m.external_id = '233854_57AD4440ABB7E4FB3868805F6338ED04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '233854_57AD4440ABB7E4FB3868805F6338ED04' AND m.source_system_id = 3;

-- Match: 230069_8A8DC5C707EF8C8468E0FF7AB582AB56
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Patricio' AND per.last_name = 'Alvarez'
WHERE m.external_id = '230069_8A8DC5C707EF8C8468E0FF7AB582AB56' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duanne' AND per.last_name = 'Johnson'
WHERE m.external_id = '230069_8A8DC5C707EF8C8468E0FF7AB582AB56' AND m.source_system_id = 3;

-- Match: 233856_2B5D1845BBE522DAC1B154E43C17CAE0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeancarlo' AND per.last_name = 'Vasquez'
WHERE m.external_id = '233856_2B5D1845BBE522DAC1B154E43C17CAE0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Blaiberg' AND per.last_name = 'Chicoma'
WHERE m.external_id = '233856_2B5D1845BBE522DAC1B154E43C17CAE0' AND m.source_system_id = 3;

-- Match: 233706_2D593462F36B331D0595A9628C144C4C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233706_2D593462F36B331D0595A9628C144C4C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233706_2D593462F36B331D0595A9628C144C4C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233706_2D593462F36B331D0595A9628C144C4C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Carlos' AND per.last_name = 'Patino'
WHERE m.external_id = '233706_2D593462F36B331D0595A9628C144C4C' AND m.source_system_id = 3;

-- Match: 230153_0D5C313AAF42CC769312A78CE67ED9A6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Puesan'
WHERE m.external_id = '230153_0D5C313AAF42CC769312A78CE67ED9A6' AND m.source_system_id = 3;

-- Match: 230160_BCE778E0BD00BB48758E5269F3A076F3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ez' AND per.last_name = 'Malik'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bejhon' AND per.last_name = 'Alerte'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tyler' AND per.last_name = 'Archampong'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tyler' AND per.last_name = 'Archampong'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nezar' AND per.last_name = 'Hanafy'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nezar' AND per.last_name = 'Hanafy'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anthony' AND per.last_name = 'Mensah Jr.'
WHERE m.external_id = '230160_BCE778E0BD00BB48758E5269F3A076F3' AND m.source_system_id = 3;

-- Match: 230154_902DBF4A5C368FEBDDF3FE6AF84CCBD5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Waled' AND per.last_name = 'Alraes'
WHERE m.external_id = '230154_902DBF4A5C368FEBDDF3FE6AF84CCBD5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ahmed' AND per.last_name = 'Abida'
WHERE m.external_id = '230154_902DBF4A5C368FEBDDF3FE6AF84CCBD5' AND m.source_system_id = 3;

-- Match: 230161_029A4142DCBB1C42562E61A14A6639B1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ahmed' AND per.last_name = 'Alghaim'
WHERE m.external_id = '230161_029A4142DCBB1C42562E61A14A6639B1' AND m.source_system_id = 3;

-- Match: 230152_F985950511324120877EE8F8FD862ED3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ethan' AND per.last_name = 'Ellsworth'
WHERE m.external_id = '230152_F985950511324120877EE8F8FD862ED3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ethan' AND per.last_name = 'Ellsworth'
WHERE m.external_id = '230152_F985950511324120877EE8F8FD862ED3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Levan' AND per.last_name = 'Gulbatashvili'
WHERE m.external_id = '230152_F985950511324120877EE8F8FD862ED3' AND m.source_system_id = 3;

-- Match: 230159_2D35D6793B4C035129DA282378ACAA97
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Toby' AND per.last_name = 'Luongo'
WHERE m.external_id = '230159_2D35D6793B4C035129DA282378ACAA97' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Patrick' AND per.last_name = 'Nair'
WHERE m.external_id = '230159_2D35D6793B4C035129DA282378ACAA97' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haysten' AND per.last_name = 'Perez'
WHERE m.external_id = '230159_2D35D6793B4C035129DA282378ACAA97' AND m.source_system_id = 3;

-- Match: 227503_5FDBDC8C08D1F89D28B6E8F13B9206F9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Arman' AND per.last_name = 'Celebi'
WHERE m.external_id = '227503_5FDBDC8C08D1F89D28B6E8F13B9206F9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Curbelo'
WHERE m.external_id = '227503_5FDBDC8C08D1F89D28B6E8F13B9206F9' AND m.source_system_id = 3;

-- Match: 227558_AC96BB2514B5FDD9192470309541EF1C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Stavris' AND per.last_name = 'Damianos'
WHERE m.external_id = '227558_AC96BB2514B5FDD9192470309541EF1C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Stavris' AND per.last_name = 'Damianos'
WHERE m.external_id = '227558_AC96BB2514B5FDD9192470309541EF1C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Gomez'
WHERE m.external_id = '227558_AC96BB2514B5FDD9192470309541EF1C' AND m.source_system_id = 3;

-- Match: 227502_C95EC37CD4E1EC0CDFDA142C1EC32544
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Salman' AND per.last_name = 'Khan'
WHERE m.external_id = '227502_C95EC37CD4E1EC0CDFDA142C1EC32544' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Grendi' AND per.last_name = 'Rrasa'
WHERE m.external_id = '227502_C95EC37CD4E1EC0CDFDA142C1EC32544' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227502_C95EC37CD4E1EC0CDFDA142C1EC32544' AND m.source_system_id = 3;

-- Match: 227557_14B7EB8AD0B20774B64E24E5CF1B0643
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227557_14B7EB8AD0B20774B64E24E5CF1B0643' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227557_14B7EB8AD0B20774B64E24E5CF1B0643' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alpha' AND per.last_name = 'Bah'
WHERE m.external_id = '227557_14B7EB8AD0B20774B64E24E5CF1B0643' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Breno' AND per.last_name = 'DaCosta'
WHERE m.external_id = '227557_14B7EB8AD0B20774B64E24E5CF1B0643' AND m.source_system_id = 3;

-- Match: 231177_289E61D2280143806B1100C67FD90F7B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulrahman' AND per.last_name = 'Mansoor'
WHERE m.external_id = '231177_289E61D2280143806B1100C67FD90F7B' AND m.source_system_id = 3;

-- Match: 238206_38890C622A1E41D9A0384E2B5EEB531B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Rodriguez'
WHERE m.external_id = '238206_38890C622A1E41D9A0384E2B5EEB531B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238206_38890C622A1E41D9A0384E2B5EEB531B' AND m.source_system_id = 3;

-- Match: 230071_2924F1EBEB1787715FB84FDA6563ABD4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duanne' AND per.last_name = 'Johnson'
WHERE m.external_id = '230071_2924F1EBEB1787715FB84FDA6563ABD4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duanne' AND per.last_name = 'Johnson'
WHERE m.external_id = '230071_2924F1EBEB1787715FB84FDA6563ABD4' AND m.source_system_id = 3;

-- Match: 230070_65C24AD33E8B6605E1C8F72CA4F17CED
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230070_65C24AD33E8B6605E1C8F72CA4F17CED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230070_65C24AD33E8B6605E1C8F72CA4F17CED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230070_65C24AD33E8B6605E1C8F72CA4F17CED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yuri' AND per.last_name = 'Krym'
WHERE m.external_id = '230070_65C24AD33E8B6605E1C8F72CA4F17CED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230070_65C24AD33E8B6605E1C8F72CA4F17CED' AND m.source_system_id = 3;

-- Match: 231172_61582F48F46B361041047F2DCE483BC4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Parker' AND per.last_name = 'Stone'
WHERE m.external_id = '231172_61582F48F46B361041047F2DCE483BC4' AND m.source_system_id = 3;

-- Match: 231162_820AA5F892F770375EDF0BC9E3FA56CF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicolas' AND per.last_name = 'Garcia'
WHERE m.external_id = '231162_820AA5F892F770375EDF0BC9E3FA56CF' AND m.source_system_id = 3;

-- Match: 231178_452D8A94A7493B61BFB1B29A59932D1A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Masashi' AND per.last_name = 'Kanazawa'
WHERE m.external_id = '231178_452D8A94A7493B61BFB1B29A59932D1A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dean' AND per.last_name = 'Terki'
WHERE m.external_id = '231178_452D8A94A7493B61BFB1B29A59932D1A' AND m.source_system_id = 3;

-- Match: 227501_AFD7ADAB2CEE655985BA6071C15DDD03
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Trujillo'
WHERE m.external_id = '227501_AFD7ADAB2CEE655985BA6071C15DDD03' AND m.source_system_id = 3;

-- Match: 227556_DF598C8BAC1760554BBDF1BB7C862E5F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darius' AND per.last_name = 'Beglarbegi'
WHERE m.external_id = '227556_DF598C8BAC1760554BBDF1BB7C862E5F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amine' AND per.last_name = 'Nassif'
WHERE m.external_id = '227556_DF598C8BAC1760554BBDF1BB7C862E5F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amine' AND per.last_name = 'Nassif'
WHERE m.external_id = '227556_DF598C8BAC1760554BBDF1BB7C862E5F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Daniel' AND per.last_name = 'Torres'
WHERE m.external_id = '227556_DF598C8BAC1760554BBDF1BB7C862E5F' AND m.source_system_id = 3;

-- Match: 238207_B27D865736E40B19A031F32C4BC401E7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdellahi' AND per.last_name = 'Limam Cherive'
WHERE m.external_id = '238207_B27D865736E40B19A031F32C4BC401E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ebrima' AND per.last_name = 'Sanyang'
WHERE m.external_id = '238207_B27D865736E40B19A031F32C4BC401E7' AND m.source_system_id = 3;

-- Match: 231157_F76052CA31FF884126101388D02DAB32
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ethan' AND per.last_name = 'Ellsworth'
WHERE m.external_id = '231157_F76052CA31FF884126101388D02DAB32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231157_F76052CA31FF884126101388D02DAB32' AND m.source_system_id = 3;

-- Match: 238212_8EC20A1CA5DC2A4A1FDC441C8C09FEFF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeancarlo' AND per.last_name = 'Vasquez'
WHERE m.external_id = '238212_8EC20A1CA5DC2A4A1FDC441C8C09FEFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeovaughn' AND per.last_name = 'Hewitt'
WHERE m.external_id = '238212_8EC20A1CA5DC2A4A1FDC441C8C09FEFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238212_8EC20A1CA5DC2A4A1FDC441C8C09FEFF' AND m.source_system_id = 3;

-- Match: 233713_478A5E517E1B4B5FE1F517EB2058D36F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Charlie' AND per.last_name = 'Duarte'
WHERE m.external_id = '233713_478A5E517E1B4B5FE1F517EB2058D36F' AND m.source_system_id = 3;

-- Match: 233710_A4954417A11EC0F2B10FAF21219ECB01
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Junior' AND per.last_name = 'Bernardez'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233710_A4954417A11EC0F2B10FAF21219ECB01' AND m.source_system_id = 3;

-- Match: 231160_6C9D6C3781B1EB20DF8BDE3F88E6E485
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bartosz' AND per.last_name = 'Drabek'
WHERE m.external_id = '231160_6C9D6C3781B1EB20DF8BDE3F88E6E485' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Damian' AND per.last_name = 'Rembisz'
WHERE m.external_id = '231160_6C9D6C3781B1EB20DF8BDE3F88E6E485' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Julian' AND per.last_name = 'Solarski'
WHERE m.external_id = '231160_6C9D6C3781B1EB20DF8BDE3F88E6E485' AND m.source_system_id = 3;

-- Match: 231176_BD26BB027D92CAF2CF0293B6D9C08263
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tyler' AND per.last_name = 'Archampong'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jaziel' AND per.last_name = 'Carrillo'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yusuf' AND per.last_name = 'Jauneh'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anthony' AND per.last_name = 'Mensah Jr.'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '231176_BD26BB027D92CAF2CF0293B6D9C08263' AND m.source_system_id = 3;

-- Match: 231158_FB1D3C46B089CA71102EE869C0099A6A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sader' AND per.last_name = 'Matar'
WHERE m.external_id = '231158_FB1D3C46B089CA71102EE869C0099A6A' AND m.source_system_id = 3;

-- Match: 231173_CFD8987AA77838841B025E2C0E73F4B5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sepehr' AND per.last_name = 'Hoghooghi'
WHERE m.external_id = '231173_CFD8987AA77838841B025E2C0E73F4B5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Zachary' AND per.last_name = 'Stoloff'
WHERE m.external_id = '231173_CFD8987AA77838841B025E2C0E73F4B5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ryan' AND per.last_name = 'Choi'
WHERE m.external_id = '231173_CFD8987AA77838841B025E2C0E73F4B5' AND m.source_system_id = 3;

-- Match: 231164_CF5E14E5EA6D48F472135C7E0C2AB33C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Javier' AND per.last_name = 'Campos'
WHERE m.external_id = '231164_CF5E14E5EA6D48F472135C7E0C2AB33C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aaron' AND per.last_name = 'Powell'
WHERE m.external_id = '231164_CF5E14E5EA6D48F472135C7E0C2AB33C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Woodruff'
WHERE m.external_id = '231164_CF5E14E5EA6D48F472135C7E0C2AB33C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Woodruff'
WHERE m.external_id = '231164_CF5E14E5EA6D48F472135C7E0C2AB33C' AND m.source_system_id = 3;

-- Match: 231180_B0841FB1D482AD79E3CC02C906041176
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Giovanny' AND per.last_name = 'Lares'
WHERE m.external_id = '231180_B0841FB1D482AD79E3CC02C906041176' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Giovanny' AND per.last_name = 'Lares'
WHERE m.external_id = '231180_B0841FB1D482AD79E3CC02C906041176' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mathew' AND per.last_name = 'Forte'
WHERE m.external_id = '231180_B0841FB1D482AD79E3CC02C906041176' AND m.source_system_id = 3;

-- Match: 231185_90953511509488647A66E19E8A629DF5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '231185_90953511509488647A66E19E8A629DF5' AND m.source_system_id = 3;

-- Match: 231168_A2D76DA49759984CAD053D0A0F491CB3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pavel' AND per.last_name = 'Klimiankou'
WHERE m.external_id = '231168_A2D76DA49759984CAD053D0A0F491CB3' AND m.source_system_id = 3;

-- Match: 231184_F6BBBF20017AA3FDA19AC1F1BA706DD7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Piotr' AND per.last_name = 'Galanek'
WHERE m.external_id = '231184_F6BBBF20017AA3FDA19AC1F1BA706DD7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Piotr' AND per.last_name = 'Galanek'
WHERE m.external_id = '231184_F6BBBF20017AA3FDA19AC1F1BA706DD7' AND m.source_system_id = 3;

-- Match: 227506_44CA2565E13A2EDC30BF2348447F82B5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ian' AND per.last_name = 'Calcaterra'
WHERE m.external_id = '227506_44CA2565E13A2EDC30BF2348447F82B5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Miguel' AND per.last_name = 'Torres'
WHERE m.external_id = '227506_44CA2565E13A2EDC30BF2348447F82B5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Trujillo'
WHERE m.external_id = '227506_44CA2565E13A2EDC30BF2348447F82B5' AND m.source_system_id = 3;

-- Match: 227505_D40D8244FDFA0B85410475EE604E7DA2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227505_D40D8244FDFA0B85410475EE604E7DA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alieu' AND per.last_name = 'Wally'
WHERE m.external_id = '227505_D40D8244FDFA0B85410475EE604E7DA2' AND m.source_system_id = 3;

-- Match: 227560_C4D18C16E16255D7763C94D829CB3201
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pape' AND per.last_name = 'Seye'
WHERE m.external_id = '227560_C4D18C16E16255D7763C94D829CB3201' AND m.source_system_id = 3;

-- Match: 231166_08053A4BC40DFF772302DBDE9E215FC7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ander' AND per.last_name = 'Badiola Pradera'
WHERE m.external_id = '231166_08053A4BC40DFF772302DBDE9E215FC7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicolas' AND per.last_name = 'Garcia'
WHERE m.external_id = '231166_08053A4BC40DFF772302DBDE9E215FC7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '231166_08053A4BC40DFF772302DBDE9E215FC7' AND m.source_system_id = 3;

-- Match: 238217_741FC8BF421ED0014E800336534BF466
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeovaughn' AND per.last_name = 'Hewitt'
WHERE m.external_id = '238217_741FC8BF421ED0014E800336534BF466' AND m.source_system_id = 3;

-- Match: 230101_82232A5B99A37872E426006782C5118C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joseph' AND per.last_name = 'Allen'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Palacios'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230101_82232A5B99A37872E426006782C5118C' AND m.source_system_id = 3;

-- Match: 230103_2AD02ABA8706D40FB56B43D8665B2AE9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '230103_2AD02ABA8706D40FB56B43D8665B2AE9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
WHERE m.external_id = '230103_2AD02ABA8706D40FB56B43D8665B2AE9' AND m.source_system_id = 3;

-- Match: 227509_C542BD58FC257474275FCDF5BF01DF5D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227509_C542BD58FC257474275FCDF5BF01DF5D' AND m.source_system_id = 3;

-- Match: 227561_2C56D2044D12ECD13E2558D65045EF6F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jon' AND per.last_name = 'Ibanez'
WHERE m.external_id = '227561_2C56D2044D12ECD13E2558D65045EF6F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jonathan' AND per.last_name = 'Lee'
WHERE m.external_id = '227561_2C56D2044D12ECD13E2558D65045EF6F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oliver' AND per.last_name = 'Wilkins'
WHERE m.external_id = '227561_2C56D2044D12ECD13E2558D65045EF6F' AND m.source_system_id = 3;

-- Match: 233718_EFEFB8AB34474C6D87AB978BE979C692
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Junior Mafia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Clinton' AND per.last_name = 'Adu-Agyei'
WHERE m.external_id = '233718_EFEFB8AB34474C6D87AB978BE979C692' AND m.source_system_id = 3;

-- Match: 227507_D9F288959C72823A3AEA7640A46D79CC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dominic' AND per.last_name = 'Corridore'
WHERE m.external_id = '227507_D9F288959C72823A3AEA7640A46D79CC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Ruiz Obando'
WHERE m.external_id = '227507_D9F288959C72823A3AEA7640A46D79CC' AND m.source_system_id = 3;

-- Match: 233717_A3AAB631D7431C5387158E05516155B8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oury' AND per.last_name = 'Sylla'
WHERE m.external_id = '233717_A3AAB631D7431C5387158E05516155B8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Touray'
WHERE m.external_id = '233717_A3AAB631D7431C5387158E05516155B8' AND m.source_system_id = 3;

-- Match: 231167_A6482E9E77F7A06B52DE5898CBCDDB0B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Elmehdi' AND per.last_name = 'Lamghari'
WHERE m.external_id = '231167_A6482E9E77F7A06B52DE5898CBCDDB0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nate' AND per.last_name = 'Frizzi'
WHERE m.external_id = '231167_A6482E9E77F7A06B52DE5898CBCDDB0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231167_A6482E9E77F7A06B52DE5898CBCDDB0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ben' AND per.last_name = 'Lindau'
WHERE m.external_id = '231167_A6482E9E77F7A06B52DE5898CBCDDB0B' AND m.source_system_id = 3;

-- Match: 231183_1BC4923DDA1B7539F3A77E1A10673791
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Douglas' AND per.last_name = 'Franco'
WHERE m.external_id = '231183_1BC4923DDA1B7539F3A77E1A10673791' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Othman' AND per.last_name = 'Lantir'
WHERE m.external_id = '231183_1BC4923DDA1B7539F3A77E1A10673791' AND m.source_system_id = 3;

-- Match: 238215_B762230C8F3B66B24F8CE185CA43D4EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oumar' AND per.last_name = 'Diallo'
WHERE m.external_id = '238215_B762230C8F3B66B24F8CE185CA43D4EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lucas' AND per.last_name = 'Bourbon'
WHERE m.external_id = '238215_B762230C8F3B66B24F8CE185CA43D4EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brandon' AND per.last_name = 'Diaz'
WHERE m.external_id = '238215_B762230C8F3B66B24F8CE185CA43D4EB' AND m.source_system_id = 3;

-- Match: 231170_46FF922EB1BCF08AFB3313157C0C9439
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cody' AND per.last_name = 'Sedler'
WHERE m.external_id = '231170_46FF922EB1BCF08AFB3313157C0C9439' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Lundstrom'
WHERE m.external_id = '231170_46FF922EB1BCF08AFB3313157C0C9439' AND m.source_system_id = 3;

-- Match: 233715_25EA80D97851F4F51123459D53C5774F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Bentivoglio'
WHERE m.external_id = '233715_25EA80D97851F4F51123459D53C5774F' AND m.source_system_id = 3;

-- Match: 233733_BD0FB1D90991AE453D0E79CA559C974C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Luke' AND per.last_name = 'Cibelli'
WHERE m.external_id = '233733_BD0FB1D90991AE453D0E79CA559C974C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233733_BD0FB1D90991AE453D0E79CA559C974C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233733_BD0FB1D90991AE453D0E79CA559C974C' AND m.source_system_id = 3;

-- Match: 238222_CE589E778E3311C0F472F4769BDAC85C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Myko' AND per.last_name = 'Pierre'
WHERE m.external_id = '238222_CE589E778E3311C0F472F4769BDAC85C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Myko' AND per.last_name = 'Pierre'
WHERE m.external_id = '238222_CE589E778E3311C0F472F4769BDAC85C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Myko' AND per.last_name = 'Pierre'
WHERE m.external_id = '238222_CE589E778E3311C0F472F4769BDAC85C' AND m.source_system_id = 3;

-- Match: 227513_6EE4949BC0F180C48FB4F9876DF5C895
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
WHERE m.external_id = '227513_6EE4949BC0F180C48FB4F9876DF5C895' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Koshurba'
WHERE m.external_id = '227513_6EE4949BC0F180C48FB4F9876DF5C895' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdusalam' AND per.last_name = 'Bajaha'
WHERE m.external_id = '227513_6EE4949BC0F180C48FB4F9876DF5C895' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227513_6EE4949BC0F180C48FB4F9876DF5C895' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227513_6EE4949BC0F180C48FB4F9876DF5C895' AND m.source_system_id = 3;

-- Match: 227568_F9F3935E48DE4658D9F04DD1D0D0045A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Petkovic'
WHERE m.external_id = '227568_F9F3935E48DE4658D9F04DD1D0D0045A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
WHERE m.external_id = '227568_F9F3935E48DE4658D9F04DD1D0D0045A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
WHERE m.external_id = '227568_F9F3935E48DE4658D9F04DD1D0D0045A' AND m.source_system_id = 3;

-- Match: 231291_227490480660A1DCAAE331EB2FB197B4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Zack' AND per.last_name = 'Rosenfeld'
WHERE m.external_id = '231291_227490480660A1DCAAE331EB2FB197B4' AND m.source_system_id = 3;

-- Match: 232491_4D0DF80BB3C5C43D75152099F4C782F7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Carlos' AND per.last_name = 'Calzadilla'
WHERE m.external_id = '232491_4D0DF80BB3C5C43D75152099F4C782F7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christopher' AND per.last_name = 'Edo-Osagie'
WHERE m.external_id = '232491_4D0DF80BB3C5C43D75152099F4C782F7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christopher' AND per.last_name = 'Edo-Osagie'
WHERE m.external_id = '232491_4D0DF80BB3C5C43D75152099F4C782F7' AND m.source_system_id = 3;

-- Match: 230106_562DFD00EEF3ACDE65804BFC8C4874FC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Turizo'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Turizo'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '230106_562DFD00EEF3ACDE65804BFC8C4874FC' AND m.source_system_id = 3;

-- Match: 233730_018145D20D6BCA6C17EBC2BED5214A56
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '233730_018145D20D6BCA6C17EBC2BED5214A56' AND m.source_system_id = 3;

-- Match: 227512_1D83272BCF27FFD5F2BA67C22025E24E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Arman' AND per.last_name = 'Celebi'
WHERE m.external_id = '227512_1D83272BCF27FFD5F2BA67C22025E24E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '227512_1D83272BCF27FFD5F2BA67C22025E24E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alem' AND per.last_name = 'Kolenovic'
WHERE m.external_id = '227512_1D83272BCF27FFD5F2BA67C22025E24E' AND m.source_system_id = 3;

-- Match: 227511_8E6EB8CD7FA352B547EA6506A834BE7C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Barrientos'
WHERE m.external_id = '227511_8E6EB8CD7FA352B547EA6506A834BE7C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'James' AND per.last_name = 'Reed'
WHERE m.external_id = '227511_8E6EB8CD7FA352B547EA6506A834BE7C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brayden' AND per.last_name = 'Schwartz'
WHERE m.external_id = '227511_8E6EB8CD7FA352B547EA6506A834BE7C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ardit' AND per.last_name = 'Belegu'
WHERE m.external_id = '227511_8E6EB8CD7FA352B547EA6506A834BE7C' AND m.source_system_id = 3;

-- Match: 227566_CD22E546487020FFE7CC926C71DE0B90
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darius' AND per.last_name = 'Beglarbegi'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darius' AND per.last_name = 'Beglarbegi'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amine' AND per.last_name = 'Nassif'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oliver' AND per.last_name = 'Wilkins'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oliver' AND per.last_name = 'Wilkins'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sultanmurat' AND per.last_name = 'Ye Leu'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Barnabas' AND per.last_name = 'Novak'
WHERE m.external_id = '227566_CD22E546487020FFE7CC926C71DE0B90' AND m.source_system_id = 3;

-- Match: 238221_3AF0A8D75605B912DD7AFF8E5A16D792
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amer' AND per.last_name = 'Hossain'
WHERE m.external_id = '238221_3AF0A8D75605B912DD7AFF8E5A16D792' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joshua' AND per.last_name = 'Lau'
WHERE m.external_id = '238221_3AF0A8D75605B912DD7AFF8E5A16D792' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238221_3AF0A8D75605B912DD7AFF8E5A16D792' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238221_3AF0A8D75605B912DD7AFF8E5A16D792' AND m.source_system_id = 3;

-- Match: 231296_F96A379E06A9085C20902D409F7FB3B2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231296_F96A379E06A9085C20902D409F7FB3B2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '231296_F96A379E06A9085C20902D409F7FB3B2' AND m.source_system_id = 3;

-- Match: 232496_6C830E08972370A47DE498DDD56A66F3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tyler' AND per.last_name = 'Archampong'
WHERE m.external_id = '232496_6C830E08972370A47DE498DDD56A66F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232496_6C830E08972370A47DE498DDD56A66F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232496_6C830E08972370A47DE498DDD56A66F3' AND m.source_system_id = 3;

-- Match: 231293_57276CECB7C58574DFCAE2CF77295B60
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231293_57276CECB7C58574DFCAE2CF77295B60' AND m.source_system_id = 3;

-- Match: 231295_9484C75BDC3B5C575247A980BB9A0C48
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Justin' AND per.last_name = 'Lee'
WHERE m.external_id = '231295_9484C75BDC3B5C575247A980BB9A0C48' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dylan' AND per.last_name = 'Morales'
WHERE m.external_id = '231295_9484C75BDC3B5C575247A980BB9A0C48' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Pearson'
WHERE m.external_id = '231295_9484C75BDC3B5C575247A980BB9A0C48' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Pearson'
WHERE m.external_id = '231295_9484C75BDC3B5C575247A980BB9A0C48' AND m.source_system_id = 3;

-- Match: 230107_5AD186BE817D0CBF8D8B8E7B18C15B0D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Artur' AND per.last_name = 'Prelvukaj'
WHERE m.external_id = '230107_5AD186BE817D0CBF8D8B8E7B18C15B0D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
WHERE m.external_id = '230107_5AD186BE817D0CBF8D8B8E7B18C15B0D' AND m.source_system_id = 3;

-- Match: 231294_19AC82D9A13F1D8F6A953C6C52722779
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gyslain' AND per.last_name = 'Ndayikengurukiye'
WHERE m.external_id = '231294_19AC82D9A13F1D8F6A953C6C52722779' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Elmehdi' AND per.last_name = 'Lamghari'
WHERE m.external_id = '231294_19AC82D9A13F1D8F6A953C6C52722779' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chris' AND per.last_name = 'Toledo'
WHERE m.external_id = '231294_19AC82D9A13F1D8F6A953C6C52722779' AND m.source_system_id = 3;

-- Match: 232494_FD6F2F9EAD133EBF4E5D56CA19C75EFC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sepehr' AND per.last_name = 'Hoghooghi'
WHERE m.external_id = '232494_FD6F2F9EAD133EBF4E5D56CA19C75EFC' AND m.source_system_id = 3;

-- Match: 233731_73404A00E8BB1C9CD94125E6FBA80D3F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233731_73404A00E8BB1C9CD94125E6FBA80D3F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233731_73404A00E8BB1C9CD94125E6FBA80D3F' AND m.source_system_id = 3;

-- Match: 238226_003C5D4930B48142C9E11A2648F26624
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jesus' AND per.last_name = 'Perez'
WHERE m.external_id = '238226_003C5D4930B48142C9E11A2648F26624' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Robert' AND per.last_name = 'Tobin'
WHERE m.external_id = '238226_003C5D4930B48142C9E11A2648F26624' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andres' AND per.last_name = 'Valencia'
WHERE m.external_id = '238226_003C5D4930B48142C9E11A2648F26624' AND m.source_system_id = 3;

-- Match: 231297_B953F9EEDA4A9A3E02EA37DF0F8E4E04
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bartosz' AND per.last_name = 'Drabek'
WHERE m.external_id = '231297_B953F9EEDA4A9A3E02EA37DF0F8E4E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Julian' AND per.last_name = 'Solarski'
WHERE m.external_id = '231297_B953F9EEDA4A9A3E02EA37DF0F8E4E04' AND m.source_system_id = 3;

-- Match: 232497_EA89C79CC3181CE339175AFFD381CF22
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'jacek' AND per.last_name = 'korba'
WHERE m.external_id = '232497_EA89C79CC3181CE339175AFFD381CF22' AND m.source_system_id = 3;

-- Match: 232493_631040920BA320412DF645EEC0552215
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Fortich'
WHERE m.external_id = '232493_631040920BA320412DF645EEC0552215' AND m.source_system_id = 3;

-- Match: 232498_7F4E48A57DC7F4C1E0769C577DD43DDC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Gjushi'
WHERE m.external_id = '232498_7F4E48A57DC7F4C1E0769C577DD43DDC' AND m.source_system_id = 3;

-- Match: 231303_BC8E67746B667188604AFF41AF250DE6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bartosz' AND per.last_name = 'Drabek'
WHERE m.external_id = '231303_BC8E67746B667188604AFF41AF250DE6' AND m.source_system_id = 3;

-- Match: 227516_F7BAD16F0B5AD0994876847F982620C2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227516_F7BAD16F0B5AD0994876847F982620C2' AND m.source_system_id = 3;

-- Match: 238539_F8C5BD32DE7A5CBF6E3A752C25CA5F56
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Azad' AND per.last_name = 'Abdulkarim'
WHERE m.external_id = '238539_F8C5BD32DE7A5CBF6E3A752C25CA5F56' AND m.source_system_id = 3;

-- Match: 230111_E9E74EF2C64158C7DE375DA7DC79463D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Palacios'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Palacios'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Neil' AND per.last_name = 'Schaefer-Riveros'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Neil' AND per.last_name = 'Schaefer-Riveros'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Turizo'
WHERE m.external_id = '230111_E9E74EF2C64158C7DE375DA7DC79463D' AND m.source_system_id = 3;

-- Match: 227515_1F8F63E531FCC18D034000822A07A858
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227515_1F8F63E531FCC18D034000822A07A858' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227515_1F8F63E531FCC18D034000822A07A858' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Banta' AND per.last_name = 'Tambadou'
WHERE m.external_id = '227515_1F8F63E531FCC18D034000822A07A858' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alieu' AND per.last_name = 'Wally'
WHERE m.external_id = '227515_1F8F63E531FCC18D034000822A07A858' AND m.source_system_id = 3;

-- Match: 227570_6E8533C823A70B172C72EB891B0C000F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Jabbi'
WHERE m.external_id = '227570_6E8533C823A70B172C72EB891B0C000F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
WHERE m.external_id = '227570_6E8533C823A70B172C72EB891B0C000F' AND m.source_system_id = 3;

-- Match: 238544_B27FA7ADC1D674CABE137732D956862D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Orayker' AND per.last_name = 'Escalona'
WHERE m.external_id = '238544_B27FA7ADC1D674CABE137732D956862D' AND m.source_system_id = 3;

-- Match: 227517_159BAF31A38C2E2EAE75B4D64860917E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Codispoti'
WHERE m.external_id = '227517_159BAF31A38C2E2EAE75B4D64860917E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lawrence' AND per.last_name = 'Mullen'
WHERE m.external_id = '227517_159BAF31A38C2E2EAE75B4D64860917E' AND m.source_system_id = 3;

-- Match: 227572_D82CAA0E360A6D25AA02C6638F592DB8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Stavris' AND per.last_name = 'Damianos'
WHERE m.external_id = '227572_D82CAA0E360A6D25AA02C6638F592DB8' AND m.source_system_id = 3;

-- Match: 230115_3EE69EE3480C302A4419B0A2FB861831
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Michael' AND per.last_name = 'Gayle'
WHERE m.external_id = '230115_3EE69EE3480C302A4419B0A2FB861831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'James'
WHERE m.external_id = '230115_3EE69EE3480C302A4419B0A2FB861831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'James'
WHERE m.external_id = '230115_3EE69EE3480C302A4419B0A2FB861831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marlon' AND per.last_name = 'Johnson'
WHERE m.external_id = '230115_3EE69EE3480C302A4419B0A2FB861831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mehdi' AND per.last_name = 'Souiade'
WHERE m.external_id = '230115_3EE69EE3480C302A4419B0A2FB861831' AND m.source_system_id = 3;

-- Match: 233738_13E2C7001E7E5A52BF1E956CB8D24088
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Billy' AND per.last_name = 'Cundall'
WHERE m.external_id = '233738_13E2C7001E7E5A52BF1E956CB8D24088' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicolas' AND per.last_name = 'Gonzalez'
WHERE m.external_id = '233738_13E2C7001E7E5A52BF1E956CB8D24088' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233738_13E2C7001E7E5A52BF1E956CB8D24088' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233738_13E2C7001E7E5A52BF1E956CB8D24088' AND m.source_system_id = 3;

-- Match: 227574_A15ACCAE98917302EEFB33810C865CB1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darius' AND per.last_name = 'Beglarbegi'
WHERE m.external_id = '227574_A15ACCAE98917302EEFB33810C865CB1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sultanmurat' AND per.last_name = 'Ye Leu'
WHERE m.external_id = '227574_A15ACCAE98917302EEFB33810C865CB1' AND m.source_system_id = 3;

-- Match: 227571_2152D809FADFA0CC929B813C90795620
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mate' AND per.last_name = 'Novak'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mate' AND per.last_name = 'Novak'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mate' AND per.last_name = 'Novak'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mate' AND per.last_name = 'Novak'
WHERE m.external_id = '227571_2152D809FADFA0CC929B813C90795620' AND m.source_system_id = 3;

-- Match: 238545_5961B37CE8021403BC16C2F3084E44DB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joseph' AND per.last_name = 'Pellumbi'
WHERE m.external_id = '238545_5961B37CE8021403BC16C2F3084E44DB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeancarlo' AND per.last_name = 'Vasquez'
WHERE m.external_id = '238545_5961B37CE8021403BC16C2F3084E44DB' AND m.source_system_id = 3;

-- Match: 230113_DE4210F1CDEBEECA9080D53F6EE956D6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kwamina' AND per.last_name = 'Afful'
WHERE m.external_id = '230113_DE4210F1CDEBEECA9080D53F6EE956D6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Patricio' AND per.last_name = 'Alvarez'
WHERE m.external_id = '230113_DE4210F1CDEBEECA9080D53F6EE956D6' AND m.source_system_id = 3;

-- Match: 231304_8F66F11AB5E75185C90EDEDF42790696
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Kehrl'
WHERE m.external_id = '231304_8F66F11AB5E75185C90EDEDF42790696' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Walker' AND per.last_name = 'Mainwaring'
WHERE m.external_id = '231304_8F66F11AB5E75185C90EDEDF42790696' AND m.source_system_id = 3;

-- Match: 232504_43DE6E4E42EE79D5A83B6F0DAC6AD840
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'James' AND per.last_name = 'Hartwell'
WHERE m.external_id = '232504_43DE6E4E42EE79D5A83B6F0DAC6AD840' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Zachary' AND per.last_name = 'Stoloff'
WHERE m.external_id = '232504_43DE6E4E42EE79D5A83B6F0DAC6AD840' AND m.source_system_id = 3;

-- Match: 231300_7562F7B42475D1189D0FC13C7567DDE9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nate' AND per.last_name = 'Frizzi'
WHERE m.external_id = '231300_7562F7B42475D1189D0FC13C7567DDE9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231300_7562F7B42475D1189D0FC13C7567DDE9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yehya' AND per.last_name = 'Etsh'
WHERE m.external_id = '231300_7562F7B42475D1189D0FC13C7567DDE9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Erik' AND per.last_name = 'Gomez'
WHERE m.external_id = '231300_7562F7B42475D1189D0FC13C7567DDE9' AND m.source_system_id = 3;

-- Match: 233734_590DCE4CF2B07C036D21DE409E913E1A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233734_590DCE4CF2B07C036D21DE409E913E1A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yankuba' AND per.last_name = 'Konteh'
WHERE m.external_id = '233734_590DCE4CF2B07C036D21DE409E913E1A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yankuba' AND per.last_name = 'Konteh'
WHERE m.external_id = '233734_590DCE4CF2B07C036D21DE409E913E1A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Touray'
WHERE m.external_id = '233734_590DCE4CF2B07C036D21DE409E913E1A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'RODAS'
WHERE m.external_id = '233734_590DCE4CF2B07C036D21DE409E913E1A' AND m.source_system_id = 3;

-- Match: 232502_85845C521CA72B6B21E109450A70CB66
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Othman' AND per.last_name = 'Lantir'
WHERE m.external_id = '232502_85845C521CA72B6B21E109450A70CB66' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noorullah' AND per.last_name = 'Mashriqi'
WHERE m.external_id = '232502_85845C521CA72B6B21E109450A70CB66' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noorullah' AND per.last_name = 'Mashriqi'
WHERE m.external_id = '232502_85845C521CA72B6B21E109450A70CB66' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noorullah' AND per.last_name = 'Mashriqi'
WHERE m.external_id = '232502_85845C521CA72B6B21E109450A70CB66' AND m.source_system_id = 3;

-- Match: 238542_95992206C14F1D74EA465F19AA24EAFA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeovaughn' AND per.last_name = 'Hewitt'
WHERE m.external_id = '238542_95992206C14F1D74EA465F19AA24EAFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeovaughn' AND per.last_name = 'Hewitt'
WHERE m.external_id = '238542_95992206C14F1D74EA465F19AA24EAFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238542_95992206C14F1D74EA465F19AA24EAFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238542_95992206C14F1D74EA465F19AA24EAFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238542_95992206C14F1D74EA465F19AA24EAFA' AND m.source_system_id = 3;

-- Match: 232500_8547C2EE94D99238F047FAFFA4DB95FB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jared' AND per.last_name = 'Masinton'
WHERE m.external_id = '232500_8547C2EE94D99238F047FAFFA4DB95FB' AND m.source_system_id = 3;

-- Match: 231305_37D6FE0467192834E1C665F9EFEEB893
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Omar' AND per.last_name = 'Baddeley'
WHERE m.external_id = '231305_37D6FE0467192834E1C665F9EFEEB893' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Evan' AND per.last_name = 'Lundstrom'
WHERE m.external_id = '231305_37D6FE0467192834E1C665F9EFEEB893' AND m.source_system_id = 3;

-- Match: 231313_D7340169BDC266FFE4910DC29C860E76
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Josh' AND per.last_name = 'Go'
WHERE m.external_id = '231313_D7340169BDC266FFE4910DC29C860E76' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Josh' AND per.last_name = 'Go'
WHERE m.external_id = '231313_D7340169BDC266FFE4910DC29C860E76' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231313_D7340169BDC266FFE4910DC29C860E76' AND m.source_system_id = 3;

-- Match: 238549_A015C2C87A5D5E48AE9C5A53DEF80969
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238549_A015C2C87A5D5E48AE9C5A53DEF80969' AND m.source_system_id = 3;

-- Match: 232513_514A733EC3B798D2D94F9CCDB643BBE2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Adrian' AND per.last_name = 'Alston-Moore'
WHERE m.external_id = '232513_514A733EC3B798D2D94F9CCDB643BBE2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Adrian' AND per.last_name = 'Alston-Moore'
WHERE m.external_id = '232513_514A733EC3B798D2D94F9CCDB643BBE2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gabriel' AND per.last_name = 'Barnes'
WHERE m.external_id = '232513_514A733EC3B798D2D94F9CCDB643BBE2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gabriel' AND per.last_name = 'Barnes'
WHERE m.external_id = '232513_514A733EC3B798D2D94F9CCDB643BBE2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dennis' AND per.last_name = 'Skenderi'
WHERE m.external_id = '232513_514A733EC3B798D2D94F9CCDB643BBE2' AND m.source_system_id = 3;

-- Match: 238548_5074A43453A48055A0A1F9936F8F4F64
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marco' AND per.last_name = 'Dotti'
WHERE m.external_id = '238548_5074A43453A48055A0A1F9936F8F4F64' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Rodriguez'
WHERE m.external_id = '238548_5074A43453A48055A0A1F9936F8F4F64' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Rodriguez'
WHERE m.external_id = '238548_5074A43453A48055A0A1F9936F8F4F64' AND m.source_system_id = 3;

-- Match: 233741_1D64B86A817B690CECC24765E05AFD47
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Cela'
WHERE m.external_id = '233741_1D64B86A817B690CECC24765E05AFD47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ousman' AND per.last_name = 'Kabba'
WHERE m.external_id = '233741_1D64B86A817B690CECC24765E05AFD47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233741_1D64B86A817B690CECC24765E05AFD47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233741_1D64B86A817B690CECC24765E05AFD47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Touray'
WHERE m.external_id = '233741_1D64B86A817B690CECC24765E05AFD47' AND m.source_system_id = 3;

-- Match: 230118_515BB7C7FD98392CC89E175A143215F3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Arevalo'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Arevalo'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230118_515BB7C7FD98392CC89E175A143215F3' AND m.source_system_id = 3;

-- Match: 227520_A60AF60F75E7ADDA6AAC33539FE1E117
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdusalam' AND per.last_name = 'Bajaha'
WHERE m.external_id = '227520_A60AF60F75E7ADDA6AAC33539FE1E117' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Musa' AND per.last_name = 'Konteh'
WHERE m.external_id = '227520_A60AF60F75E7ADDA6AAC33539FE1E117' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ismaila' AND per.last_name = 'Trawally'
WHERE m.external_id = '227520_A60AF60F75E7ADDA6AAC33539FE1E117' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alieu' AND per.last_name = 'Wally'
WHERE m.external_id = '227520_A60AF60F75E7ADDA6AAC33539FE1E117' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vitor' AND per.last_name = 'De Oliveira'
WHERE m.external_id = '227520_A60AF60F75E7ADDA6AAC33539FE1E117' AND m.source_system_id = 3;

-- Match: 227575_4C6200AEE9ED018D4964FA5E94ED2EB0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yaya' AND per.last_name = 'Danso'
WHERE m.external_id = '227575_4C6200AEE9ED018D4964FA5E94ED2EB0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadu' AND per.last_name = 'Gaku'
WHERE m.external_id = '227575_4C6200AEE9ED018D4964FA5E94ED2EB0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
WHERE m.external_id = '227575_4C6200AEE9ED018D4964FA5E94ED2EB0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Breno' AND per.last_name = 'DaCosta'
WHERE m.external_id = '227575_4C6200AEE9ED018D4964FA5E94ED2EB0' AND m.source_system_id = 3;

-- Match: 227522_7EC9E7E6ED242D0152E703374EC91A00
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pavel' AND per.last_name = 'Kondratyev'
WHERE m.external_id = '227522_7EC9E7E6ED242D0152E703374EC91A00' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pavel' AND per.last_name = 'Kondratyev'
WHERE m.external_id = '227522_7EC9E7E6ED242D0152E703374EC91A00' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pavel' AND per.last_name = 'Kondratyev'
WHERE m.external_id = '227522_7EC9E7E6ED242D0152E703374EC91A00' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Miguel' AND per.last_name = 'Torres'
WHERE m.external_id = '227522_7EC9E7E6ED242D0152E703374EC91A00' AND m.source_system_id = 3;

-- Match: 227577_28225B1548E340E8B6347F17AA1194B2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sultanmurat' AND per.last_name = 'Ye Leu'
WHERE m.external_id = '227577_28225B1548E340E8B6347F17AA1194B2' AND m.source_system_id = 3;

-- Match: 230119_F8CC0AEDAA7627F8871E6F639CCC36C8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230119_F8CC0AEDAA7627F8871E6F639CCC36C8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'John' AND per.last_name = 'Wilkison'
WHERE m.external_id = '230119_F8CC0AEDAA7627F8871E6F639CCC36C8' AND m.source_system_id = 3;

-- Match: 231309_78C37201D695A4650B17E28807D32A9F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dylan' AND per.last_name = 'Morales'
WHERE m.external_id = '231309_78C37201D695A4650B17E28807D32A9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '231309_78C37201D695A4650B17E28807D32A9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Pearson'
WHERE m.external_id = '231309_78C37201D695A4650B17E28807D32A9F' AND m.source_system_id = 3;

-- Match: 227524_0A2981B46B9375BDC6BF6D20EDD41ADB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227524_0A2981B46B9375BDC6BF6D20EDD41ADB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Arman' AND per.last_name = 'Celebi'
WHERE m.external_id = '227524_0A2981B46B9375BDC6BF6D20EDD41ADB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '227524_0A2981B46B9375BDC6BF6D20EDD41ADB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '227524_0A2981B46B9375BDC6BF6D20EDD41ADB' AND m.source_system_id = 3;

-- Match: 233743_1D256CB927224D95AEF7B18AF6EA161E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'RODAS'
WHERE m.external_id = '233743_1D256CB927224D95AEF7B18AF6EA161E' AND m.source_system_id = 3;

-- Match: 227523_2FD3035B339B7F27A010E26A499FCE77
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Codispoti'
WHERE m.external_id = '227523_2FD3035B339B7F27A010E26A499FCE77' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Aguilera Juarez'
WHERE m.external_id = '227523_2FD3035B339B7F27A010E26A499FCE77' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Merchant'
WHERE m.external_id = '227523_2FD3035B339B7F27A010E26A499FCE77' AND m.source_system_id = 3;

-- Match: 227578_51C24B07137BAD44B73E2B9D2376614C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Gomez'
WHERE m.external_id = '227578_51C24B07137BAD44B73E2B9D2376614C' AND m.source_system_id = 3;

-- Match: 231314_7A55A64AE986753927B52E806B5FEFEE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Khaled' AND per.last_name = 'Abdella'
WHERE m.external_id = '231314_7A55A64AE986753927B52E806B5FEFEE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Omer' AND per.last_name = 'Abdella'
WHERE m.external_id = '231314_7A55A64AE986753927B52E806B5FEFEE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chris' AND per.last_name = 'Toledo'
WHERE m.external_id = '231314_7A55A64AE986753927B52E806B5FEFEE' AND m.source_system_id = 3;

-- Match: 232514_CB01B7414EC9A9BE59A52EDE59F16846
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tyler' AND per.last_name = 'Archampong'
WHERE m.external_id = '232514_CB01B7414EC9A9BE59A52EDE59F16846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chris' AND per.last_name = 'Chery'
WHERE m.external_id = '232514_CB01B7414EC9A9BE59A52EDE59F16846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noorullah' AND per.last_name = 'Mashriqi'
WHERE m.external_id = '232514_CB01B7414EC9A9BE59A52EDE59F16846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noorullah' AND per.last_name = 'Mashriqi'
WHERE m.external_id = '232514_CB01B7414EC9A9BE59A52EDE59F16846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cristopher' AND per.last_name = 'Novillo'
WHERE m.external_id = '232514_CB01B7414EC9A9BE59A52EDE59F16846' AND m.source_system_id = 3;

-- Match: 238552_5EBB899E39EAC9E96B12270C4CE2124B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brandon' AND per.last_name = 'Diaz'
WHERE m.external_id = '238552_5EBB899E39EAC9E96B12270C4CE2124B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joseph' AND per.last_name = 'Pellumbi'
WHERE m.external_id = '238552_5EBB899E39EAC9E96B12270C4CE2124B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marcial' AND per.last_name = 'Vasquez'
WHERE m.external_id = '238552_5EBB899E39EAC9E96B12270C4CE2124B' AND m.source_system_id = 3;

-- Match: 231308_6DF126D695BF89DDA3CC9C2EBC7E64F1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Austin' AND per.last_name = 'Font'
WHERE m.external_id = '231308_6DF126D695BF89DDA3CC9C2EBC7E64F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bartosz' AND per.last_name = 'Drabek'
WHERE m.external_id = '231308_6DF126D695BF89DDA3CC9C2EBC7E64F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bartosz' AND per.last_name = 'Drabek'
WHERE m.external_id = '231308_6DF126D695BF89DDA3CC9C2EBC7E64F1' AND m.source_system_id = 3;

-- Match: 232508_8BC689AFD6CF9A3C558D8DD0155D805A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Piotr' AND per.last_name = 'Galanek'
WHERE m.external_id = '232508_8BC689AFD6CF9A3C558D8DD0155D805A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Pawel' AND per.last_name = 'Zalewski'
WHERE m.external_id = '232508_8BC689AFD6CF9A3C558D8DD0155D805A' AND m.source_system_id = 3;

-- Match: 231311_D53E8EFB45E0A815D5756254C6399678
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Samba' AND per.last_name = 'Gnokane'
WHERE m.external_id = '231311_D53E8EFB45E0A815D5756254C6399678' AND m.source_system_id = 3;

-- Match: 233742_18914AC01108642A88A74F5362DB92DF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Jeronimo'
WHERE m.external_id = '233742_18914AC01108642A88A74F5362DB92DF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233742_18914AC01108642A88A74F5362DB92DF' AND m.source_system_id = 3;

-- Match: 238554_29CF8A51BC7A3D758A3FAF1F3E860E11
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Dorda'
WHERE m.external_id = '238554_29CF8A51BC7A3D758A3FAF1F3E860E11' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Myko' AND per.last_name = 'Pierre'
WHERE m.external_id = '238554_29CF8A51BC7A3D758A3FAF1F3E860E11' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Daniel' AND per.last_name = 'Tully'
WHERE m.external_id = '238554_29CF8A51BC7A3D758A3FAF1F3E860E11' AND m.source_system_id = 3;

-- Match: 238556_6F296F18DAE2A46337652862BB3A9BB5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Orayker' AND per.last_name = 'Escalona'
WHERE m.external_id = '238556_6F296F18DAE2A46337652862BB3A9BB5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Ramos'
WHERE m.external_id = '238556_6F296F18DAE2A46337652862BB3A9BB5' AND m.source_system_id = 3;

-- Match: 233747_E306F39FF980354D9399C49EF0907E0C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Bentivoglio'
WHERE m.external_id = '233747_E306F39FF980354D9399C49EF0907E0C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233747_E306F39FF980354D9399C49EF0907E0C' AND m.source_system_id = 3;

-- Match: 238555_B23DB26CA19B65ADCD4147B1795F3561
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marvin' AND per.last_name = 'Lambert'
WHERE m.external_id = '238555_B23DB26CA19B65ADCD4147B1795F3561' AND m.source_system_id = 3;

-- Match: 230121_F1580EA6AC279266CFF719BCBE98380A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bill' AND per.last_name = 'Damion'
WHERE m.external_id = '230121_F1580EA6AC279266CFF719BCBE98380A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '230121_F1580EA6AC279266CFF719BCBE98380A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mehdi' AND per.last_name = 'Souiade'
WHERE m.external_id = '230121_F1580EA6AC279266CFF719BCBE98380A' AND m.source_system_id = 3;

-- Match: 230124_599A08BA93E11328611903FC3D439CC6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yuri' AND per.last_name = 'Krym'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230124_599A08BA93E11328611903FC3D439CC6' AND m.source_system_id = 3;

-- Match: 231315_BB65AE3F6A4AEE17DD5039463D8CDAC7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicholas' AND per.last_name = 'Bosnic'
WHERE m.external_id = '231315_BB65AE3F6A4AEE17DD5039463D8CDAC7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Woodruff'
WHERE m.external_id = '231315_BB65AE3F6A4AEE17DD5039463D8CDAC7' AND m.source_system_id = 3;

-- Match: 232515_12C63386380164F1186CD8D3A6E2A970
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Teodoro' AND per.last_name = 'Topa'
WHERE m.external_id = '232515_12C63386380164F1186CD8D3A6E2A970' AND m.source_system_id = 3;

-- Match: 227526_5F4B8BA1C95581646AE57CD933AF5ABF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ian' AND per.last_name = 'Calcaterra'
WHERE m.external_id = '227526_5F4B8BA1C95581646AE57CD933AF5ABF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Evan' AND per.last_name = 'Jones'
WHERE m.external_id = '227526_5F4B8BA1C95581646AE57CD933AF5ABF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lawrence' AND per.last_name = 'Mullen'
WHERE m.external_id = '227526_5F4B8BA1C95581646AE57CD933AF5ABF' AND m.source_system_id = 3;

-- Match: 227581_1D17F7E2D6455C78803F9D2CF169677A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jonathan' AND per.last_name = 'Lee'
WHERE m.external_id = '227581_1D17F7E2D6455C78803F9D2CF169677A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dalibor' AND per.last_name = 'Tolicki'
WHERE m.external_id = '227581_1D17F7E2D6455C78803F9D2CF169677A' AND m.source_system_id = 3;

-- Match: 227529_8F4CB7F0110943971E7ED37BB8FF5AF8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Aguilera Juarez'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Bullington'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thabke' AND per.last_name = 'Tenzing'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227529_8F4CB7F0110943971E7ED37BB8FF5AF8' AND m.source_system_id = 3;

-- Match: 227582_1215D7310149AD83D8A0EF2B917D7812
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Breno' AND per.last_name = 'DaCosta'
WHERE m.external_id = '227582_1215D7310149AD83D8A0EF2B917D7812' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Henry' AND per.last_name = 'Jardines Bravo'
WHERE m.external_id = '227582_1215D7310149AD83D8A0EF2B917D7812' AND m.source_system_id = 3;

-- Match: 230123_B0E983394036E8B4B59A972D6F2F4981
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
WHERE m.external_id = '230123_B0E983394036E8B4B59A972D6F2F4981' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
WHERE m.external_id = '230123_B0E983394036E8B4B59A972D6F2F4981' AND m.source_system_id = 3;

-- Match: 231318_FF0EF602442FEBA6E108B9501BC3D483
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nate' AND per.last_name = 'Frizzi'
WHERE m.external_id = '231318_FF0EF602442FEBA6E108B9501BC3D483' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nate' AND per.last_name = 'Frizzi'
WHERE m.external_id = '231318_FF0EF602442FEBA6E108B9501BC3D483' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231318_FF0EF602442FEBA6E108B9501BC3D483' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'João' AND per.last_name = 'Da Rocha Leite Pinto Salgado'
WHERE m.external_id = '231318_FF0EF602442FEBA6E108B9501BC3D483' AND m.source_system_id = 3;

-- Match: 231316_DEA87BFCC32FE555D58784EA2DCDA854
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Austin' AND per.last_name = 'Font'
WHERE m.external_id = '231316_DEA87BFCC32FE555D58784EA2DCDA854' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Kehrl'
WHERE m.external_id = '231316_DEA87BFCC32FE555D58784EA2DCDA854' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '231316_DEA87BFCC32FE555D58784EA2DCDA854' AND m.source_system_id = 3;

-- Match: 232516_1645E9BD4CE1CF27FD2053D41B46AE34
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'James' AND per.last_name = 'Hartwell'
WHERE m.external_id = '232516_1645E9BD4CE1CF27FD2053D41B46AE34' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'James' AND per.last_name = 'Hartwell'
WHERE m.external_id = '232516_1645E9BD4CE1CF27FD2053D41B46AE34' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Zachary' AND per.last_name = 'Stoloff'
WHERE m.external_id = '232516_1645E9BD4CE1CF27FD2053D41B46AE34' AND m.source_system_id = 3;

-- Match: 230125_4F2E7B4061702AF411F47BBA6A0B767D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230125_4F2E7B4061702AF411F47BBA6A0B767D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU OG''S' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tamimou' AND per.last_name = 'Issifou'
WHERE m.external_id = '230125_4F2E7B4061702AF411F47BBA6A0B767D' AND m.source_system_id = 3;

-- Match: 233748_E06FBC05C69DB12B3B1CFA46FF0421FD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Carlos' AND per.last_name = 'Patino'
WHERE m.external_id = '233748_E06FBC05C69DB12B3B1CFA46FF0421FD' AND m.source_system_id = 3;

-- Match: 231322_DFB8C30602492825E5C2158B3B70F7F5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bangally' AND per.last_name = 'Conteh'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Dukuray'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Dukuray'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Rabiou' AND per.last_name = 'Kassim'
WHERE m.external_id = '231322_DFB8C30602492825E5C2158B3B70F7F5' AND m.source_system_id = 3;

-- Match: 231321_371EDC12E52E5EEA059288BD41BDAC27
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Niko' AND per.last_name = 'Filippi'
WHERE m.external_id = '231321_371EDC12E52E5EEA059288BD41BDAC27' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sader' AND per.last_name = 'Matar'
WHERE m.external_id = '231321_371EDC12E52E5EEA059288BD41BDAC27' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Charles' AND per.last_name = 'Scruton'
WHERE m.external_id = '231321_371EDC12E52E5EEA059288BD41BDAC27' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Burhan' AND per.last_name = 'Alamisi'
WHERE m.external_id = '231321_371EDC12E52E5EEA059288BD41BDAC27' AND m.source_system_id = 3;

-- Match: 232521_16A4F1AB8A7352DA6FE53CEFF79C4248
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Inti' AND per.last_name = 'Robinson Campbell'
WHERE m.external_id = '232521_16A4F1AB8A7352DA6FE53CEFF79C4248' AND m.source_system_id = 3;

-- Match: 232518_599D5A4D1683E9879D43F757A68157AB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jared' AND per.last_name = 'Masinton'
WHERE m.external_id = '232518_599D5A4D1683E9879D43F757A68157AB' AND m.source_system_id = 3;

-- Match: 231328_04212FE1B59310243867155AC22279D5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '231328_04212FE1B59310243867155AC22279D5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '231328_04212FE1B59310243867155AC22279D5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Julen' AND per.last_name = 'Torre'
WHERE m.external_id = '231328_04212FE1B59310243867155AC22279D5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Julen' AND per.last_name = 'Torre'
WHERE m.external_id = '231328_04212FE1B59310243867155AC22279D5' AND m.source_system_id = 3;

-- Match: 232528_17B5863F11146A753532A42A8A0B4910
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Michel' AND per.last_name = 'Castillo'
WHERE m.external_id = '232528_17B5863F11146A753532A42A8A0B4910' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chucho' AND per.last_name = 'Peña'
WHERE m.external_id = '232528_17B5863F11146A753532A42A8A0B4910' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Teodoro' AND per.last_name = 'Topa'
WHERE m.external_id = '232528_17B5863F11146A753532A42A8A0B4910' AND m.source_system_id = 3;

-- Match: 233774_9714EFDA472335F060CC50A66FCEE8E1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233774_9714EFDA472335F060CC50A66FCEE8E1' AND m.source_system_id = 3;

-- Match: 232529_4D0506BBD06BF190B020292609EC5D1C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdel' AND per.last_name = 'Elakrmi'
WHERE m.external_id = '232529_4D0506BBD06BF190B020292609EC5D1C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdel' AND per.last_name = 'Elakrmi'
WHERE m.external_id = '232529_4D0506BBD06BF190B020292609EC5D1C' AND m.source_system_id = 3;

-- Match: 227533_54E829C6F18F89D1B1CFD0B6F3A8A181
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Disiervi'
WHERE m.external_id = '227533_54E829C6F18F89D1B1CFD0B6F3A8A181' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Hesse'
WHERE m.external_id = '227533_54E829C6F18F89D1B1CFD0B6F3A8A181' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227533_54E829C6F18F89D1B1CFD0B6F3A8A181' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227533_54E829C6F18F89D1B1CFD0B6F3A8A181' AND m.source_system_id = 3;

-- Match: 238562_1E68DC08B6E971FC0B9371B4D455D210
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Maximiliano' AND per.last_name = 'Suarez'
WHERE m.external_id = '238562_1E68DC08B6E971FC0B9371B4D455D210' AND m.source_system_id = 3;

-- Match: 230128_92212E608D2D884992A4E9CB422F5704
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '230128_92212E608D2D884992A4E9CB422F5704' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Pena'
WHERE m.external_id = '230128_92212E608D2D884992A4E9CB422F5704' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Pena'
WHERE m.external_id = '230128_92212E608D2D884992A4E9CB422F5704' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Dario' AND per.last_name = 'Trujillo'
WHERE m.external_id = '230128_92212E608D2D884992A4E9CB422F5704' AND m.source_system_id = 3;

-- Match: 227532_ECCB4D6DF374E677508E9D7575A3AA6F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227532_ECCB4D6DF374E677508E9D7575A3AA6F' AND m.source_system_id = 3;

-- Match: 231327_2962C100D8D5408796518EE687A4D123
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Franco' AND per.last_name = 'Osco'
WHERE m.external_id = '231327_2962C100D8D5408796518EE687A4D123' AND m.source_system_id = 3;

-- Match: 227534_FAA9952BABE59D877067445829C2734C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
WHERE m.external_id = '227534_FAA9952BABE59D877067445829C2734C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
WHERE m.external_id = '227534_FAA9952BABE59D877067445829C2734C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Koshurba'
WHERE m.external_id = '227534_FAA9952BABE59D877067445829C2734C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Koshurba'
WHERE m.external_id = '227534_FAA9952BABE59D877067445829C2734C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brian' AND per.last_name = 'Vasquez'
WHERE m.external_id = '227534_FAA9952BABE59D877067445829C2734C' AND m.source_system_id = 3;

-- Match: 227589_9185651208C38D90D98D12F4B926E267
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Leonardo' AND per.last_name = 'Hinds'
WHERE m.external_id = '227589_9185651208C38D90D98D12F4B926E267' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darrian' AND per.last_name = 'Chambers'
WHERE m.external_id = '227589_9185651208C38D90D98D12F4B926E267' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Elias' AND per.last_name = 'Venegas'
WHERE m.external_id = '227589_9185651208C38D90D98D12F4B926E267' AND m.source_system_id = 3;

-- Match: 231324_75AD900DFCA53BEDB9A5D21A82292C9F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Greg' AND per.last_name = 'Diedhiou'
WHERE m.external_id = '231324_75AD900DFCA53BEDB9A5D21A82292C9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Greg' AND per.last_name = 'Diedhiou'
WHERE m.external_id = '231324_75AD900DFCA53BEDB9A5D21A82292C9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Greg' AND per.last_name = 'Diedhiou'
WHERE m.external_id = '231324_75AD900DFCA53BEDB9A5D21A82292C9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Carlos' AND per.last_name = 'Perez'
WHERE m.external_id = '231324_75AD900DFCA53BEDB9A5D21A82292C9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Omar' AND per.last_name = 'Torres'
WHERE m.external_id = '231324_75AD900DFCA53BEDB9A5D21A82292C9F' AND m.source_system_id = 3;

-- Match: 232524_B34B5C7735CBE31F8AC18A5ADCA41461
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Othman' AND per.last_name = 'Lantir'
WHERE m.external_id = '232524_B34B5C7735CBE31F8AC18A5ADCA41461' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Othman' AND per.last_name = 'Lantir'
WHERE m.external_id = '232524_B34B5C7735CBE31F8AC18A5ADCA41461' AND m.source_system_id = 3;

-- Match: 238564_BA0BCDE067F9D3B43592EB15CC80D6DE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jared' AND per.last_name = 'Jungjohann'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jared' AND per.last_name = 'Jungjohann'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jared' AND per.last_name = 'Jungjohann'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joshua' AND per.last_name = 'Lau'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joshua' AND per.last_name = 'Lau'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Rodriguez'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aidan' AND per.last_name = 'Wirrick'
WHERE m.external_id = '238564_BA0BCDE067F9D3B43592EB15CC80D6DE' AND m.source_system_id = 3;

-- Match: 233772_07C9C3EC5B702F3E960CFB72D2631C2E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233772_07C9C3EC5B702F3E960CFB72D2631C2E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Carlos' AND per.last_name = 'Patino'
WHERE m.external_id = '233772_07C9C3EC5B702F3E960CFB72D2631C2E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Touray'
WHERE m.external_id = '233772_07C9C3EC5B702F3E960CFB72D2631C2E' AND m.source_system_id = 3;

-- Match: 231326_E4B7791D32D1F32803EF12AB09F5A91F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Erik' AND per.last_name = 'Gomez'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jaquan' AND per.last_name = 'Linton'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Tall'
WHERE m.external_id = '231326_E4B7791D32D1F32803EF12AB09F5A91F' AND m.source_system_id = 3;

-- Match: 231325_A49E7BADC86DA8B1279478208AE8FF01
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mohammed' AND per.last_name = 'Alkamel'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Dukuray'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Moussa' AND per.last_name = 'Sinera'
WHERE m.external_id = '231325_A49E7BADC86DA8B1279478208AE8FF01' AND m.source_system_id = 3;

-- Match: 232525_B363F61992538032FD6420F4963572AB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anthony' AND per.last_name = 'Mensah Jr.'
WHERE m.external_id = '232525_B363F61992538032FD6420F4963572AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anthony' AND per.last_name = 'Mensah Jr.'
WHERE m.external_id = '232525_B363F61992538032FD6420F4963572AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232525_B363F61992538032FD6420F4963572AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232525_B363F61992538032FD6420F4963572AB' AND m.source_system_id = 3;

-- Match: 238565_DE528C7F614F0624FB739723EE775B4D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Giacomo' AND per.last_name = 'Agostini'
WHERE m.external_id = '238565_DE528C7F614F0624FB739723EE775B4D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jesus' AND per.last_name = 'Andrade'
WHERE m.external_id = '238565_DE528C7F614F0624FB739723EE775B4D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Dorda'
WHERE m.external_id = '238565_DE528C7F614F0624FB739723EE775B4D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Shariq' AND per.last_name = 'Rizvi'
WHERE m.external_id = '238565_DE528C7F614F0624FB739723EE775B4D' AND m.source_system_id = 3;

-- Match: 231338_2A6D036AAEF32048A23798DDBC5421CC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Greg' AND per.last_name = 'Diedhiou'
WHERE m.external_id = '231338_2A6D036AAEF32048A23798DDBC5421CC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Richson' AND per.last_name = 'Owusu'
WHERE m.external_id = '231338_2A6D036AAEF32048A23798DDBC5421CC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Omar' AND per.last_name = 'Torres'
WHERE m.external_id = '231338_2A6D036AAEF32048A23798DDBC5421CC' AND m.source_system_id = 3;

-- Match: 227535_8E02B7A333B1EFBAB9FC432B884A657B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alberto' AND per.last_name = 'Bobadilla'
WHERE m.external_id = '227535_8E02B7A333B1EFBAB9FC432B884A657B' AND m.source_system_id = 3;

-- Match: 227590_99C7AFBBFD5158F63E8AA6608742565E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227590_99C7AFBBFD5158F63E8AA6608742565E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amidou' AND per.last_name = 'Kane'
WHERE m.external_id = '227590_99C7AFBBFD5158F63E8AA6608742565E' AND m.source_system_id = 3;

-- Match: 231337_7D4546F992B1E6D3D29D62C7DAA479D6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Francois' AND per.last_name = 'Savignac'
WHERE m.external_id = '231337_7D4546F992B1E6D3D29D62C7DAA479D6' AND m.source_system_id = 3;

-- Match: 238569_62DBEFCA7A474109E0AB72BED4BB1AFD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'C.A. Islas Malvinas' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Orayker' AND per.last_name = 'Escalona'
WHERE m.external_id = '238569_62DBEFCA7A474109E0AB72BED4BB1AFD' AND m.source_system_id = 3;

-- Match: 227536_490D4A1DB9456AC01E02DF5924C07BA3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lukasz' AND per.last_name = 'Bielen'
WHERE m.external_id = '227536_490D4A1DB9456AC01E02DF5924C07BA3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Antoine' AND per.last_name = 'Laurient'
WHERE m.external_id = '227536_490D4A1DB9456AC01E02DF5924C07BA3' AND m.source_system_id = 3;

-- Match: 230134_7DA4ABBA83F2922E7A27C39FF734B123
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230134_7DA4ABBA83F2922E7A27C39FF734B123' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Panayiotis' AND per.last_name = 'Onisiforou'
WHERE m.external_id = '230134_7DA4ABBA83F2922E7A27C39FF734B123' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230134_7DA4ABBA83F2922E7A27C39FF734B123' AND m.source_system_id = 3;

-- Match: 231333_062590CD9D96A6A0F206F39093937FD2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Josh' AND per.last_name = 'Go'
WHERE m.external_id = '231333_062590CD9D96A6A0F206F39093937FD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231333_062590CD9D96A6A0F206F39093937FD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231333_062590CD9D96A6A0F206F39093937FD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231333_062590CD9D96A6A0F206F39093937FD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Saúl'
WHERE m.external_id = '231333_062590CD9D96A6A0F206F39093937FD2' AND m.source_system_id = 3;

-- Match: 232533_F4BAD76AB3AC0561CCEAF1754AA84229
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdel' AND per.last_name = 'Elakrmi'
WHERE m.external_id = '232533_F4BAD76AB3AC0561CCEAF1754AA84229' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Teodoro' AND per.last_name = 'Topa'
WHERE m.external_id = '232533_F4BAD76AB3AC0561CCEAF1754AA84229' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Teodoro' AND per.last_name = 'Topa'
WHERE m.external_id = '232533_F4BAD76AB3AC0561CCEAF1754AA84229' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Lower East II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alon' AND per.last_name = 'Zuman'
WHERE m.external_id = '232533_F4BAD76AB3AC0561CCEAF1754AA84229' AND m.source_system_id = 3;

-- Match: 233778_B988578528FA0D0C6782C27245C96E55
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233778_B988578528FA0D0C6782C27245C96E55' AND m.source_system_id = 3;

-- Match: 227537_06C0FDEDB9D8835197117C970EA70EE0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '227537_06C0FDEDB9D8835197117C970EA70EE0' AND m.source_system_id = 3;

-- Match: 227538_B2A6AB7A2607FD2CF8913344E5685E8D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Barrientos'
WHERE m.external_id = '227538_B2A6AB7A2607FD2CF8913344E5685E8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Barrientos'
WHERE m.external_id = '227538_B2A6AB7A2607FD2CF8913344E5685E8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kyle' AND per.last_name = 'Unger'
WHERE m.external_id = '227538_B2A6AB7A2607FD2CF8913344E5685E8D' AND m.source_system_id = 3;

-- Match: 227593_461CAF3D0B972B23AE46F4E68929E676
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cherif' AND per.last_name = 'Barry'
WHERE m.external_id = '227593_461CAF3D0B972B23AE46F4E68929E676' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Darrian' AND per.last_name = 'Chambers'
WHERE m.external_id = '227593_461CAF3D0B972B23AE46F4E68929E676' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Henry' AND per.last_name = 'Jardines Bravo'
WHERE m.external_id = '227593_461CAF3D0B972B23AE46F4E68929E676' AND m.source_system_id = 3;

-- Match: 230132_EFECD32D643905855A795CCD1F9126B4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Boris' AND per.last_name = 'Kapelnik'
WHERE m.external_id = '230132_EFECD32D643905855A795CCD1F9126B4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Boris' AND per.last_name = 'Kapelnik'
WHERE m.external_id = '230132_EFECD32D643905855A795CCD1F9126B4' AND m.source_system_id = 3;

-- Match: 233777_8EC78F1271E416FDD50D529A881CF846
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Bentivoglio'
WHERE m.external_id = '233777_8EC78F1271E416FDD50D529A881CF846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Federico' AND per.last_name = 'Bentivoglio'
WHERE m.external_id = '233777_8EC78F1271E416FDD50D529A881CF846' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Luke' AND per.last_name = 'Cibelli'
WHERE m.external_id = '233777_8EC78F1271E416FDD50D529A881CF846' AND m.source_system_id = 3;

-- Match: 233776_C587919C3ADF0AC870545C078A8F4DD3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Hernandez'
WHERE m.external_id = '233776_C587919C3ADF0AC870545C078A8F4DD3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'HENRY' AND per.last_name = 'MOROCHO'
WHERE m.external_id = '233776_C587919C3ADF0AC870545C078A8F4DD3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'HENRY' AND per.last_name = 'MOROCHO'
WHERE m.external_id = '233776_C587919C3ADF0AC870545C078A8F4DD3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'RODAS'
WHERE m.external_id = '233776_C587919C3ADF0AC870545C078A8F4DD3' AND m.source_system_id = 3;

-- Match: 238568_CCF89A6CC7BDFF15F2C61997E32E5B8B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joshua' AND per.last_name = 'Lau'
WHERE m.external_id = '238568_CCF89A6CC7BDFF15F2C61997E32E5B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joshua' AND per.last_name = 'Lau'
WHERE m.external_id = '238568_CCF89A6CC7BDFF15F2C61997E32E5B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Dorda'
WHERE m.external_id = '238568_CCF89A6CC7BDFF15F2C61997E32E5B8B' AND m.source_system_id = 3;

-- Match: 232536_8974F09529348AD4BDAD4772D8312D63
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232536_8974F09529348AD4BDAD4772D8312D63' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '232536_8974F09529348AD4BDAD4772D8312D63' AND m.source_system_id = 3;

-- Match: 232535_7CD0F74E76ABDD360C206EC6C52F83EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Moreno' AND per.last_name = 'Marku'
WHERE m.external_id = '232535_7CD0F74E76ABDD360C206EC6C52F83EB' AND m.source_system_id = 3;

-- Match: 231331_7EE19ACD7DDEF2C280DA27A319436667
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Levan' AND per.last_name = 'Gulbatashvili'
WHERE m.external_id = '231331_7EE19ACD7DDEF2C280DA27A319436667' AND m.source_system_id = 3;

-- Match: 227544_B16BD20DB2E5F4BECCF6C776C1AAC872
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jakub' AND per.last_name = 'Madej'
WHERE m.external_id = '227544_B16BD20DB2E5F4BECCF6C776C1AAC872' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Merchant'
WHERE m.external_id = '227544_B16BD20DB2E5F4BECCF6C776C1AAC872' AND m.source_system_id = 3;

-- Match: 227541_C28B069AF07F71A63401359FFE31BED1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Salman' AND per.last_name = 'Khan'
WHERE m.external_id = '227541_C28B069AF07F71A63401359FFE31BED1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227541_C28B069AF07F71A63401359FFE31BED1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227541_C28B069AF07F71A63401359FFE31BED1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '227541_C28B069AF07F71A63401359FFE31BED1' AND m.source_system_id = 3;

-- Match: 233789_8514B7FD8C1B26CEC0765BC0BABE11B3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '233789_8514B7FD8C1B26CEC0765BC0BABE11B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '233789_8514B7FD8C1B26CEC0765BC0BABE11B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '233789_8514B7FD8C1B26CEC0765BC0BABE11B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '233789_8514B7FD8C1B26CEC0765BC0BABE11B3' AND m.source_system_id = 3;

-- Match: 227599_05C9DE1A2357A59EF0E657C835720763
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hubert' AND per.last_name = 'Fryzel'
WHERE m.external_id = '227599_05C9DE1A2357A59EF0E657C835720763' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Goldman'
WHERE m.external_id = '227599_05C9DE1A2357A59EF0E657C835720763' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Goldman'
WHERE m.external_id = '227599_05C9DE1A2357A59EF0E657C835720763' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gustavo' AND per.last_name = 'Torrealba'
WHERE m.external_id = '227599_05C9DE1A2357A59EF0E657C835720763' AND m.source_system_id = 3;

-- Match: 238575_D1449A680EAB0DF30F1A127EBFBB1245
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Justin' AND per.last_name = 'Nelson'
WHERE m.external_id = '238575_D1449A680EAB0DF30F1A127EBFBB1245' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238575_D1449A680EAB0DF30F1A127EBFBB1245' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238575_D1449A680EAB0DF30F1A127EBFBB1245' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238575_D1449A680EAB0DF30F1A127EBFBB1245' AND m.source_system_id = 3;

-- Match: 230139_9EC2FC15844B0053BA092036F9451843
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joseph' AND per.last_name = 'Allen'
WHERE m.external_id = '230139_9EC2FC15844B0053BA092036F9451843' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Benik' AND per.last_name = 'Ambar'
WHERE m.external_id = '230139_9EC2FC15844B0053BA092036F9451843' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230139_9EC2FC15844B0053BA092036F9451843' AND m.source_system_id = 3;

-- Match: 231345_BACC8148CCE26DCEA8A48B05238CB55B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lawrence' AND per.last_name = 'Nikaj'
WHERE m.external_id = '231345_BACC8148CCE26DCEA8A48B05238CB55B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lawrence' AND per.last_name = 'Nikaj'
WHERE m.external_id = '231345_BACC8148CCE26DCEA8A48B05238CB55B' AND m.source_system_id = 3;

-- Match: 232545_F3769904133CDDB8133DB266606E93BA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Gjushi'
WHERE m.external_id = '232545_F3769904133CDDB8133DB266606E93BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Gjushi'
WHERE m.external_id = '232545_F3769904133CDDB8133DB266606E93BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Moreno' AND per.last_name = 'Marku'
WHERE m.external_id = '232545_F3769904133CDDB8133DB266606E93BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Moreno' AND per.last_name = 'Marku'
WHERE m.external_id = '232545_F3769904133CDDB8133DB266606E93BA' AND m.source_system_id = 3;

-- Match: 230138_A82BC8179AB57770A9CAA1DE3599555A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bill' AND per.last_name = 'Damion'
WHERE m.external_id = '230138_A82BC8179AB57770A9CAA1DE3599555A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Michael' AND per.last_name = 'Gayle'
WHERE m.external_id = '230138_A82BC8179AB57770A9CAA1DE3599555A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '230138_A82BC8179AB57770A9CAA1DE3599555A' AND m.source_system_id = 3;

-- Match: 227543_FFF8D7A1B4DACD887D230A90DF6FB212
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '227543_FFF8D7A1B4DACD887D230A90DF6FB212' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '227543_FFF8D7A1B4DACD887D230A90DF6FB212' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amar' AND per.last_name = 'Hrustemovic'
WHERE m.external_id = '227543_FFF8D7A1B4DACD887D230A90DF6FB212' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brayden' AND per.last_name = 'Schwartz'
WHERE m.external_id = '227543_FFF8D7A1B4DACD887D230A90DF6FB212' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Trujillo'
WHERE m.external_id = '227543_FFF8D7A1B4DACD887D230A90DF6FB212' AND m.source_system_id = 3;

-- Match: 227598_C9696057B3FBDECB5A1EA038C9CF4B07
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Keanaan' AND per.last_name = 'Malke'
WHERE m.external_id = '227598_C9696057B3FBDECB5A1EA038C9CF4B07' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Daniel' AND per.last_name = 'Torres'
WHERE m.external_id = '227598_C9696057B3FBDECB5A1EA038C9CF4B07' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Oliver' AND per.last_name = 'Wilkins'
WHERE m.external_id = '227598_C9696057B3FBDECB5A1EA038C9CF4B07' AND m.source_system_id = 3;

-- Match: 233791_5BE84688CEE4B1CE6EAAA4037B969935
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alkid' AND per.last_name = 'Kacorri'
WHERE m.external_id = '233791_5BE84688CEE4B1CE6EAAA4037B969935' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria SBU Dawgz' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Touray'
WHERE m.external_id = '233791_5BE84688CEE4B1CE6EAAA4037B969935' AND m.source_system_id = 3;

-- Match: 231343_CCD74B0CF201BDCD3E24A451E3FFBE8C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ander' AND per.last_name = 'Badiola Pradera'
WHERE m.external_id = '231343_CCD74B0CF201BDCD3E24A451E3FFBE8C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '231343_CCD74B0CF201BDCD3E24A451E3FFBE8C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '231343_CCD74B0CF201BDCD3E24A451E3FFBE8C' AND m.source_system_id = 3;

-- Match: 232543_8B680CD25815B94983C681244544EB2C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chucho' AND per.last_name = 'Peña'
WHERE m.external_id = '232543_8B680CD25815B94983C681244544EB2C' AND m.source_system_id = 3;

-- Match: 231341_8B7B6C9820B24BCC3612C9BF385BBA5E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alpha' AND per.last_name = 'Diallo'
WHERE m.external_id = '231341_8B7B6C9820B24BCC3612C9BF385BBA5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '231341_8B7B6C9820B24BCC3612C9BF385BBA5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231341_8B7B6C9820B24BCC3612C9BF385BBA5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '231341_8B7B6C9820B24BCC3612C9BF385BBA5E' AND m.source_system_id = 3;

-- Match: 238577_D2212A863AAC3FE52C48BC5A7A35694D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jean' AND per.last_name = 'Valni'
WHERE m.external_id = '238577_D2212A863AAC3FE52C48BC5A7A35694D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Blaiberg' AND per.last_name = 'Chicoma'
WHERE m.external_id = '238577_D2212A863AAC3FE52C48BC5A7A35694D' AND m.source_system_id = 3;

-- Match: 232542_99EB560FD621962E01CD1B3D4E58D774
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chris' AND per.last_name = 'Chery'
WHERE m.external_id = '232542_99EB560FD621962E01CD1B3D4E58D774' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Othman' AND per.last_name = 'Lantir'
WHERE m.external_id = '232542_99EB560FD621962E01CD1B3D4E58D774' AND m.source_system_id = 3;

-- Match: 233792_3CD2379A007ECE43EEF6EA864025A1E7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233792_3CD2379A007ECE43EEF6EA864025A1E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tommaso' AND per.last_name = 'Martorella'
WHERE m.external_id = '233792_3CD2379A007ECE43EEF6EA864025A1E7' AND m.source_system_id = 3;

-- Match: 232541_256F788168B848EABDA41983C627A6D9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yusuf' AND per.last_name = 'Jauneh'
WHERE m.external_id = '232541_256F788168B848EABDA41983C627A6D9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jorge' AND per.last_name = 'Marin-Salazar'
WHERE m.external_id = '232541_256F788168B848EABDA41983C627A6D9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anthony' AND per.last_name = 'Mensah Jr.'
WHERE m.external_id = '232541_256F788168B848EABDA41983C627A6D9' AND m.source_system_id = 3;

-- Match: 231344_1F9482F6D2452B2512C9B21B5E41157A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'João' AND per.last_name = 'Da Rocha Leite Pinto Salgado'
WHERE m.external_id = '231344_1F9482F6D2452B2512C9B21B5E41157A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Samba' AND per.last_name = 'Gnokane'
WHERE m.external_id = '231344_1F9482F6D2452B2512C9B21B5E41157A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Samba' AND per.last_name = 'Gnokane'
WHERE m.external_id = '231344_1F9482F6D2452B2512C9B21B5E41157A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lukas' AND per.last_name = 'Kilian'
WHERE m.external_id = '231344_1F9482F6D2452B2512C9B21B5E41157A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ethan' AND per.last_name = 'Ellsworth'
WHERE m.external_id = '231344_1F9482F6D2452B2512C9B21B5E41157A' AND m.source_system_id = 3;

-- Match: 232544_091EC0E6672A81759BA98E4EB64DCD8F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Mesa'
WHERE m.external_id = '232544_091EC0E6672A81759BA98E4EB64DCD8F' AND m.source_system_id = 3;

-- Match: 238225_935747739042D23C6822A8FA8AFDBA5E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jean' AND per.last_name = 'Valni'
WHERE m.external_id = '238225_935747739042D23C6822A8FA8AFDBA5E' AND m.source_system_id = 3;

-- Match: 230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Vasilis' AND per.last_name = 'Antoniou'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Martin' AND per.last_name = 'Di Fede'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '230143_22E3BAB9F83BBA87A11EFD8F3FD52BA9' AND m.source_system_id = 3;

-- Match: 233797_4975ED98A1339F54E297A8561D8E7748
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'David' AND per.last_name = 'Lopez'
WHERE m.external_id = '233797_4975ED98A1339F54E297A8561D8E7748' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Braza Futbol' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Victor' AND per.last_name = 'Mankattaa'
WHERE m.external_id = '233797_4975ED98A1339F54E297A8561D8E7748' AND m.source_system_id = 3;

-- Match: 238216_9BC72817B18725C454529EBA7248778D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238216_9BC72817B18725C454529EBA7248778D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238216_9BC72817B18725C454529EBA7248778D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '238216_9BC72817B18725C454529EBA7248778D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aidan' AND per.last_name = 'Wirrick'
WHERE m.external_id = '238216_9BC72817B18725C454529EBA7248778D' AND m.source_system_id = 3;

-- Match: 262487_E2A0B2A5EF195255E6878833B06B3C31
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Edward' AND per.last_name = 'Nika'
WHERE m.external_id = '262487_E2A0B2A5EF195255E6878833B06B3C31' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vllaznia NYC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Edward' AND per.last_name = 'Nika'
WHERE m.external_id = '262487_E2A0B2A5EF195255E6878833B06B3C31' AND m.source_system_id = 3;

-- Match: 262266_0C47652216B75399CC3C73BDFEE849EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Paul' AND per.last_name = 'Nittoli'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Paul' AND per.last_name = 'Nittoli'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Palacios'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Christian' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mauricio' AND per.last_name = 'Turizo'
WHERE m.external_id = '262266_0C47652216B75399CC3C73BDFEE849EB' AND m.source_system_id = 3;

-- Match: 261813_D5A7633D69004CEB1F30C7B462467F7D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Eric' AND per.last_name = 'Gooden'
WHERE m.external_id = '261813_D5A7633D69004CEB1F30C7B462467F7D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '261813_D5A7633D69004CEB1F30C7B462467F7D' AND m.source_system_id = 3;

-- Match: 261208_1205F3D0147C0A0D167828A09B007435
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '261208_1205F3D0147C0A0D167828A09B007435' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '261208_1205F3D0147C0A0D167828A09B007435' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Matthew' AND per.last_name = 'Hesse'
WHERE m.external_id = '261208_1205F3D0147C0A0D167828A09B007435' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
WHERE m.external_id = '261208_1205F3D0147C0A0D167828A09B007435' AND m.source_system_id = 3;

-- Match: 261265_F711674160DD64D8BBC76E2B05014154
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yonatan' AND per.last_name = 'Reiter'
WHERE m.external_id = '261265_F711674160DD64D8BBC76E2B05014154' AND m.source_system_id = 3;

-- Match: 261209_8F6FDF05ECB94A00B8CF15C6640A59FE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Salman' AND per.last_name = 'Khan'
WHERE m.external_id = '261209_8F6FDF05ECB94A00B8CF15C6640A59FE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Salman' AND per.last_name = 'Khan'
WHERE m.external_id = '261209_8F6FDF05ECB94A00B8CF15C6640A59FE' AND m.source_system_id = 3;

-- Match: 261811_6C14EA117DBCCE255C1A4886DF51C9EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Junior Mafia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Kwaku'
WHERE m.external_id = '261811_6C14EA117DBCCE255C1A4886DF51C9EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Junior Mafia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hamza' AND per.last_name = 'Yussif'
WHERE m.external_id = '261811_6C14EA117DBCCE255C1A4886DF51C9EB' AND m.source_system_id = 3;

-- Match: 262421_C4D4F3121E9FC0BC16D473BC4A4C392C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Javier' AND per.last_name = 'Campos'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Lizarazo'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Allan' AND per.last_name = 'Marquez'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdul' AND per.last_name = 'Mohammed'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '262421_C4D4F3121E9FC0BC16D473BC4A4C392C' AND m.source_system_id = 3;

-- Match: 262493_E614156D940CD0B8BDF4872A422AC52A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Chris' AND per.last_name = 'Chery'
WHERE m.external_id = '262493_E614156D940CD0B8BDF4872A422AC52A' AND m.source_system_id = 3;

-- Match: 261814_14EAB5223075A197608FF52C5182201F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Demetrios' AND per.last_name = 'Berdousis'
WHERE m.external_id = '261814_14EAB5223075A197608FF52C5182201F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yassin' AND per.last_name = 'Sabbar'
WHERE m.external_id = '261814_14EAB5223075A197608FF52C5182201F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Yassin' AND per.last_name = 'Sabbar'
WHERE m.external_id = '261814_14EAB5223075A197608FF52C5182201F' AND m.source_system_id = 3;

-- Match: 261207_0427678360869234043E3CD8F44C5B22
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
WHERE m.external_id = '261207_0427678360869234043E3CD8F44C5B22' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
WHERE m.external_id = '261207_0427678360869234043E3CD8F44C5B22' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'George' AND per.last_name = 'Najm'
WHERE m.external_id = '261207_0427678360869234043E3CD8F44C5B22' AND m.source_system_id = 3;

-- Match: 261264_A99250CE49BE3F59993A2912B79A7569
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Waleed' AND per.last_name = 'Alouat'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Stavris' AND per.last_name = 'Damianos'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Stavris' AND per.last_name = 'Damianos'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Petkovic'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Petkovic'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marko' AND per.last_name = 'Petkovic'
WHERE m.external_id = '261264_A99250CE49BE3F59993A2912B79A7569' AND m.source_system_id = 3;

-- Match: 262419_C27B09DCDEE8F0D85E82A0694A9C763B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aidan' AND per.last_name = 'McKenna'
WHERE m.external_id = '262419_C27B09DCDEE8F0D85E82A0694A9C763B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Puesan'
WHERE m.external_id = '262419_C27B09DCDEE8F0D85E82A0694A9C763B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brendan' AND per.last_name = 'Schwartz'
WHERE m.external_id = '262419_C27B09DCDEE8F0D85E82A0694A9C763B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brendan' AND per.last_name = 'Schwartz'
WHERE m.external_id = '262419_C27B09DCDEE8F0D85E82A0694A9C763B' AND m.source_system_id = 3;

-- Match: 262491_F349F9B41F1002E90366F85D556A0994
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mustafa' AND per.last_name = 'Salane'
WHERE m.external_id = '262491_F349F9B41F1002E90366F85D556A0994' AND m.source_system_id = 3;

-- Match: 262417_6B37E49E64E02383470096EA90D8EA4B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '262417_6B37E49E64E02383470096EA90D8EA4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cheikh' AND per.last_name = 'Diaw'
WHERE m.external_id = '262417_6B37E49E64E02383470096EA90D8EA4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Buba' AND per.last_name = 'Sumareh'
WHERE m.external_id = '262417_6B37E49E64E02383470096EA90D8EA4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lukas' AND per.last_name = 'Kilian'
WHERE m.external_id = '262417_6B37E49E64E02383470096EA90D8EA4B' AND m.source_system_id = 3;

-- Match: 262489_B432952F41BBC132E19117FA623039EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '262489_B432952F41BBC132E19117FA623039EB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fausto' AND per.last_name = 'Rodriguez'
WHERE m.external_id = '262489_B432952F41BBC132E19117FA623039EB' AND m.source_system_id = 3;

-- Match: 262490_FDEEF50B8B6CE9610D645F0E9B896CE6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdel' AND per.last_name = 'Elakrmi'
WHERE m.external_id = '262490_FDEEF50B8B6CE9610D645F0E9B896CE6' AND m.source_system_id = 3;

-- Match: 263341_29D47374101176A45CF3765EA8FBBB1C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jesus' AND per.last_name = 'Andrade'
WHERE m.external_id = '263341_29D47374101176A45CF3765EA8FBBB1C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mark' AND per.last_name = 'Gallagher'
WHERE m.external_id = '263341_29D47374101176A45CF3765EA8FBBB1C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mark' AND per.last_name = 'Gallagher'
WHERE m.external_id = '263341_29D47374101176A45CF3765EA8FBBB1C' AND m.source_system_id = 3;

-- Match: 262494_E9AB5AD112290C2A7437A156F5AAE3D0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulrahman' AND per.last_name = 'Mansoor'
WHERE m.external_id = '262494_E9AB5AD112290C2A7437A156F5AAE3D0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abulrahman' AND per.last_name = 'Mansoor'
WHERE m.external_id = '262494_E9AB5AD112290C2A7437A156F5AAE3D0' AND m.source_system_id = 3;

-- Match: 263342_438B2B30168151BFE8F2182352211AFF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Abdellahi' AND per.last_name = 'Limam Cherive'
WHERE m.external_id = '263342_438B2B30168151BFE8F2182352211AFF' AND m.source_system_id = 3;

-- Match: 227549_4E5FFC567E356A81F70803A789A646B6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Goldman'
WHERE m.external_id = '227549_4E5FFC567E356A81F70803A789A646B6' AND m.source_system_id = 3;

-- Match: 261210_B0F5CE8C668D274EE0445381F1369F27
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Bopp'
WHERE m.external_id = '261210_B0F5CE8C668D274EE0445381F1369F27' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Borys' AND per.last_name = 'Shtefan'
WHERE m.external_id = '261210_B0F5CE8C668D274EE0445381F1369F27' AND m.source_system_id = 3;

-- Match: 261267_90F0799D9CD96F7B53E82F1C4F0A245F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mohamed' AND per.last_name = 'Traore'
WHERE m.external_id = '261267_90F0799D9CD96F7B53E82F1C4F0A245F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mohamed' AND per.last_name = 'Traore'
WHERE m.external_id = '261267_90F0799D9CD96F7B53E82F1C4F0A245F' AND m.source_system_id = 3;

-- Match: 263343_7B432EE25343B8AE764E266E37876523
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Dorda'
WHERE m.external_id = '263343_7B432EE25343B8AE764E266E37876523' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alejandro' AND per.last_name = 'Dorda'
WHERE m.external_id = '263343_7B432EE25343B8AE764E266E37876523' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gabriel' AND per.last_name = 'Gomes Rocha'
WHERE m.external_id = '263343_7B432EE25343B8AE764E266E37876523' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gabriel' AND per.last_name = 'Gomes Rocha'
WHERE m.external_id = '263343_7B432EE25343B8AE764E266E37876523' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Gabriel' AND per.last_name = 'Gomes Rocha'
WHERE m.external_id = '263343_7B432EE25343B8AE764E266E37876523' AND m.source_system_id = 3;

-- Match: 263346_56034C370D638900BE9E0A69B971DFD5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic Bhoys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kemar' AND per.last_name = 'Brown'
WHERE m.external_id = '263346_56034C370D638900BE9E0A69B971DFD5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic Bhoys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Tius' AND per.last_name = 'Johnson'
WHERE m.external_id = '263346_56034C370D638900BE9E0A69B971DFD5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic Bhoys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Samir' AND per.last_name = 'Sherpa'
WHERE m.external_id = '263346_56034C370D638900BE9E0A69B971DFD5' AND m.source_system_id = 3;

-- Match: 261212_F7871F7578E7B5F89B1FDBE78523460B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Codispoti'
WHERE m.external_id = '261212_F7871F7578E7B5F89B1FDBE78523460B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andrea' AND per.last_name = 'Codispoti'
WHERE m.external_id = '261212_F7871F7578E7B5F89B1FDBE78523460B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lawrence' AND per.last_name = 'Mullen'
WHERE m.external_id = '261212_F7871F7578E7B5F89B1FDBE78523460B' AND m.source_system_id = 3;

-- Match: 262272_621803CB6491ECBC6C8A8E2CAF0798C6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Benik' AND per.last_name = 'Ambar'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Benik' AND per.last_name = 'Ambar'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Manuel' AND per.last_name = 'Eljaiek'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Paul' AND per.last_name = 'Nittoli'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Juan' AND per.last_name = 'Palacios'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Old Boys' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Anastasios' AND per.last_name = 'Polydefkis'
WHERE m.external_id = '262272_621803CB6491ECBC6C8A8E2CAF0798C6' AND m.source_system_id = 3;

-- Match: 262496_982A018456D892AAD9D371A940A785AB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jorge' AND per.last_name = 'Marin-Salazar'
WHERE m.external_id = '262496_982A018456D892AAD9D371A940A785AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Sporting Astoria South Bronx United II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joston' AND per.last_name = 'Nunez'
WHERE m.external_id = '262496_982A018456D892AAD9D371A940A785AB' AND m.source_system_id = 3;

-- Match: 262273_08DAA190C3EB355542A2377E78006CB3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Patricio' AND per.last_name = 'Alvarez'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Patricio' AND per.last_name = 'Alvarez'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Michael' AND per.last_name = 'Gayle'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Michael' AND per.last_name = 'Gayle'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Heaven'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Duane' AND per.last_name = 'Pena'
WHERE m.external_id = '262273_08DAA190C3EB355542A2377E78006CB3' AND m.source_system_id = 3;

-- Match: 261817_913DDC4F023DBC2DFB66FD5A002D1154
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FanDuel FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Thomas' AND per.last_name = 'Lodge'
WHERE m.external_id = '261817_913DDC4F023DBC2DFB66FD5A002D1154' AND m.source_system_id = 3;

-- Match: 261213_B36703388C3416B1268DC01EB525DBAD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
WHERE m.external_id = '261213_B36703388C3416B1268DC01EB525DBAD' AND m.source_system_id = 3;

-- Match: 261211_9423A1DCEDAE710DCA401248819C545B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Noam' AND per.last_name = 'Davidov'
WHERE m.external_id = '261211_9423A1DCEDAE710DCA401248819C545B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brayden' AND per.last_name = 'Schwartz'
WHERE m.external_id = '261211_9423A1DCEDAE710DCA401248819C545B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brayden' AND per.last_name = 'Schwartz'
WHERE m.external_id = '261211_9423A1DCEDAE710DCA401248819C545B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Kyle' AND per.last_name = 'Unger'
WHERE m.external_id = '261211_9423A1DCEDAE710DCA401248819C545B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Brian' AND per.last_name = 'Vasquez'
WHERE m.external_id = '261211_9423A1DCEDAE710DCA401248819C545B' AND m.source_system_id = 3;

-- Match: 261268_A9A6E439F18B3339ABADC60DA89D37B3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicholas' AND per.last_name = 'Iozzo'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicholas' AND per.last_name = 'Iozzo'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicholas' AND per.last_name = 'Iozzo'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Loncar'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Loncar'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Loncar'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ivan' AND per.last_name = 'Loncar'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Amine' AND per.last_name = 'Nassif'
WHERE m.external_id = '261268_A9A6E439F18B3339ABADC60DA89D37B3' AND m.source_system_id = 3;

-- Match: 261214_54FFA163BD0083C4BAF50F017EF7F00B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '261214_54FFA163BD0083C4BAF50F017EF7F00B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
WHERE m.external_id = '261214_54FFA163BD0083C4BAF50F017EF7F00B' AND m.source_system_id = 3;

-- Match: 261271_5377F8AD62DDE887B568396B511BAFAF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Polonia SC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cristian' AND per.last_name = 'Artica'
WHERE m.external_id = '261271_5377F8AD62DDE887B568396B511BAFAF' AND m.source_system_id = 3;

-- Match: 262425_63C0839D0F3A426902AE3734F6A4951A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Ander' AND per.last_name = 'Badiola Pradera'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Diego' AND per.last_name = 'Campos'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Javier' AND per.last_name = 'Campos'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Benjamin' AND per.last_name = 'Cuadra'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mo' AND per.last_name = 'Jiyid'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mo' AND per.last_name = 'Jiyid'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Lukas' AND per.last_name = 'Kilian'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'ERFC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jess' AND per.last_name = 'Walkin'
WHERE m.external_id = '262425_63C0839D0F3A426902AE3734F6A4951A' AND m.source_system_id = 3;

-- Match: 262497_67E3DC0558C1EEBD80B5101C9A0C57E5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicolo' AND per.last_name = 'Currarino'
WHERE m.external_id = '262497_67E3DC0558C1EEBD80B5101C9A0C57E5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aliou' AND per.last_name = 'Tamba'
WHERE m.external_id = '262497_67E3DC0558C1EEBD80B5101C9A0C57E5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Aliou' AND per.last_name = 'Tamba'
WHERE m.external_id = '262497_67E3DC0558C1EEBD80B5101C9A0C57E5' AND m.source_system_id = 3;

-- Match: 262426_11179D996BE02F971F40B6FD87E767BB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Alexander' AND per.last_name = 'Johnston'
WHERE m.external_id = '262426_11179D996BE02F971F40B6FD87E767BB' AND m.source_system_id = 3;

-- Match: 263345_FB8D6EBAD6A07F1BA4ECD0CFA6666189
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Nicolas' AND per.last_name = 'Prietogamba'
WHERE m.external_id = '263345_FB8D6EBAD6A07F1BA4ECD0CFA6666189' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jean' AND per.last_name = 'Valni'
WHERE m.external_id = '263345_FB8D6EBAD6A07F1BA4ECD0CFA6666189' AND m.source_system_id = 3;

-- Match: 262429_F4F8D02CF61C327792F4097576377308
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Bright' AND per.last_name = 'Anim'
WHERE m.external_id = '262429_F4F8D02CF61C327792F4097576377308' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Finest FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Greg' AND per.last_name = 'Diedhiou'
WHERE m.external_id = '262429_F4F8D02CF61C327792F4097576377308' AND m.source_system_id = 3;

-- Match: 263347_1F918DD3A7C1B27E7ACAB2EC52411096
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Sanjar' AND per.last_name = 'Hamrakulov'
WHERE m.external_id = '263347_1F918DD3A7C1B27E7ACAB2EC52411096' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '263347_1F918DD3A7C1B27E7ACAB2EC52411096' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Ollama FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jacopo' AND per.last_name = 'Viali'
WHERE m.external_id = '263347_1F918DD3A7C1B27E7ACAB2EC52411096' AND m.source_system_id = 3;

-- Match: 262428_D161B46580B066F15187EC01D2FB1DA1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
WHERE m.external_id = '262428_D161B46580B066F15187EC01D2FB1DA1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jonathan' AND per.last_name = 'Villacis'
WHERE m.external_id = '262428_D161B46580B066F15187EC01D2FB1DA1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Burhan' AND per.last_name = 'Alamisi'
WHERE m.external_id = '262428_D161B46580B066F15187EC01D2FB1DA1' AND m.source_system_id = 3;

-- Match: 263348_7106038F14F31FB4960DD856B82115BC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Joseph' AND per.last_name = 'Pellumbi'
WHERE m.external_id = '263348_7106038F14F31FB4960DD856B82115BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Robert' AND per.last_name = 'Tobin'
WHERE m.external_id = '263348_7106038F14F31FB4960DD856B82115BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Andres' AND per.last_name = 'Valencia'
WHERE m.external_id = '263348_7106038F14F31FB4960DD856B82115BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Gjoa' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Jeancarlo' AND per.last_name = 'Vasquez'
WHERE m.external_id = '263348_7106038F14F31FB4960DD856B82115BC' AND m.source_system_id = 3;

-- Match: 262427_57113E96B7F0FC5946123E19E40BDB50
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Levan' AND per.last_name = 'Gulbatashvili'
WHERE m.external_id = '262427_57113E96B7F0FC5946123E19E40BDB50' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Onur' AND per.last_name = 'Ilingi'
WHERE m.external_id = '262427_57113E96B7F0FC5946123E19E40BDB50' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Cyril' AND per.last_name = 'Grant'
WHERE m.external_id = '262427_57113E96B7F0FC5946123E19E40BDB50' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Vibes FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Max' AND per.last_name = 'Matsumoto'
WHERE m.external_id = '262427_57113E96B7F0FC5946123E19E40BDB50' AND m.source_system_id = 3;

-- Match: 263344_B297C2242A4B276C257FA3A780B0DF2C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Titans FC' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Peterson' AND per.last_name = 'Cornely'
WHERE m.external_id = '263344_B297C2242A4B276C257FA3A780B0DF2C' AND m.source_system_id = 3;

-- Match: 227602_8C2E67AF83688B7E80A781DD8F37860A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Adel' AND per.last_name = 'Hackivic'
WHERE m.external_id = '227602_8C2E67AF83688B7E80A781DD8F37860A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Adel' AND per.last_name = 'Hackivic'
WHERE m.external_id = '227602_8C2E67AF83688B7E80A781DD8F37860A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  pl.id,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
JOIN players pl ON true
JOIN persons per ON pl.person_id = per.id
  AND per.first_name = 'Mirza' AND per.last_name = 'Hot'
WHERE m.external_id = '227602_8C2E67AF83688B7E80A781DD8F37860A' AND m.source_system_id = 3;

