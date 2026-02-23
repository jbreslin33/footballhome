-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Match Events - CSL
-- Goals, assists, cards, etc. from match event pages
-- Total Records: 1119
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Match: 29595_945EE3D52AAD29285F299F1E05DC0D02
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21102,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29595_945EE3D52AAD29285F299F1E05DC0D02' AND m.source_system_id = 3;

-- Match: 29672_C544E9C36068D72CA98273481E1E65B9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20081,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29672_C544E9C36068D72CA98273481E1E65B9' AND m.source_system_id = 3;

-- Match: 30046_25074C43FC4CC0F29512E8C605D34014
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20846,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '30046_25074C43FC4CC0F29512E8C605D34014' AND m.source_system_id = 3;

-- Match: 30278_79B05AA4EF7017975AF439175494B64A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21554,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30278_79B05AA4EF7017975AF439175494B64A' AND m.source_system_id = 3;

-- Match: 29592_9EFC5733940940A0730AE5E827C72FED
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21647,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians' AND t.source_system_id = 3
WHERE m.external_id = '29592_9EFC5733940940A0730AE5E827C72FED' AND m.source_system_id = 3;

-- Match: 29669_7971F5C5E1231A9D42E844FC21B7F168
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29669_7971F5C5E1231A9D42E844FC21B7F168' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29669_7971F5C5E1231A9D42E844FC21B7F168' AND m.source_system_id = 3;

-- Match: 30274_B4E4718F2057F53CA0162B4A06CEE93B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20773,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30274_B4E4718F2057F53CA0162B4A06CEE93B' AND m.source_system_id = 3;

-- Match: 30277_746959662D786D4EBB7BBCC155224381
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20148,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Aurora FC' AND t.source_system_id = 3
WHERE m.external_id = '30277_746959662D786D4EBB7BBCC155224381' AND m.source_system_id = 3;

-- Match: 30272_7841CE829BDC65C7F6E28B45B034765F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21315,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30272_7841CE829BDC65C7F6E28B45B034765F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21335,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30272_7841CE829BDC65C7F6E28B45B034765F' AND m.source_system_id = 3;

-- Match: 29597_9FA6C468DC2949252928A696E4E0D5EC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20379,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'CD Iberia' AND t.source_system_id = 3
WHERE m.external_id = '29597_9FA6C468DC2949252928A696E4E0D5EC' AND m.source_system_id = 3;

-- Match: 29674_5FD7434BE6ADEF8F575A67CE64C9A61C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20240,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
WHERE m.external_id = '29674_5FD7434BE6ADEF8F575A67CE64C9A61C' AND m.source_system_id = 3;

-- Match: 30273_61D7E85F55A88B8026C05C3C67A4A1C9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21831,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30273_61D7E85F55A88B8026C05C3C67A4A1C9' AND m.source_system_id = 3;

-- Match: 29671_2C2BA76FF0F204D6509D2A8E7BA0C447
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29671_2C2BA76FF0F204D6509D2A8E7BA0C447' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29671_2C2BA76FF0F204D6509D2A8E7BA0C447' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20513,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29671_2C2BA76FF0F204D6509D2A8E7BA0C447' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20518,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29671_2C2BA76FF0F204D6509D2A8E7BA0C447' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20520,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29671_2C2BA76FF0F204D6509D2A8E7BA0C447' AND m.source_system_id = 3;

-- Match: 30471_FC8730311963736F34BCCB84DDE481E8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20545,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
WHERE m.external_id = '30471_FC8730311963736F34BCCB84DDE481E8' AND m.source_system_id = 3;

-- Match: 30275_647896089F36762FD5287D8E53EEAE99
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20606,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30275_647896089F36762FD5287D8E53EEAE99' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20612,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30275_647896089F36762FD5287D8E53EEAE99' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20618,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30275_647896089F36762FD5287D8E53EEAE99' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20618,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30275_647896089F36762FD5287D8E53EEAE99' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22370,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30275_647896089F36762FD5287D8E53EEAE99' AND m.source_system_id = 3;

-- Match: 30045_33CFE16A601C63E43CA88C0EC1F751BF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '30045_33CFE16A601C63E43CA88C0EC1F751BF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '30045_33CFE16A601C63E43CA88C0EC1F751BF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21431,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '30045_33CFE16A601C63E43CA88C0EC1F751BF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '30045_33CFE16A601C63E43CA88C0EC1F751BF' AND m.source_system_id = 3;

-- Match: 29591_4B3849B2D9D64902849BD15B5C6C636B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22254,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29591_4B3849B2D9D64902849BD15B5C6C636B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22254,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29591_4B3849B2D9D64902849BD15B5C6C636B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22254,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29591_4B3849B2D9D64902849BD15B5C6C636B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29591_4B3849B2D9D64902849BD15B5C6C636B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29591_4B3849B2D9D64902849BD15B5C6C636B' AND m.source_system_id = 3;

-- Match: 29668_8C948C397D18FA95342886D1E809A18D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22442,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29668_8C948C397D18FA95342886D1E809A18D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29668_8C948C397D18FA95342886D1E809A18D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29668_8C948C397D18FA95342886D1E809A18D' AND m.source_system_id = 3;

-- Match: 29381_50298FFE57832316B4C2E127AF231B32
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29381_50298FFE57832316B4C2E127AF231B32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29381_50298FFE57832316B4C2E127AF231B32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21190,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29381_50298FFE57832316B4C2E127AF231B32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21191,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29381_50298FFE57832316B4C2E127AF231B32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21194,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29381_50298FFE57832316B4C2E127AF231B32' AND m.source_system_id = 3;

-- Match: 29593_B101E7056C6E26BEBE0017E4F6B0E35F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21009,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29593_B101E7056C6E26BEBE0017E4F6B0E35F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29593_B101E7056C6E26BEBE0017E4F6B0E35F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22183,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '29593_B101E7056C6E26BEBE0017E4F6B0E35F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '29593_B101E7056C6E26BEBE0017E4F6B0E35F' AND m.source_system_id = 3;

-- Match: 30509_B78D34815F4F95AA618B23A133DF9A3C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30509_B78D34815F4F95AA618B23A133DF9A3C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21224,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30509_B78D34815F4F95AA618B23A133DF9A3C' AND m.source_system_id = 3;

-- Match: 29382_C76D97BE737D8A6B838AEC6EB8FB6794
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21901,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21344,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Athletic Club' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21346,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Athletic Club' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21360,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Athletic Club' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21366,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Athletic Club' AND t.source_system_id = 3
WHERE m.external_id = '29382_C76D97BE737D8A6B838AEC6EB8FB6794' AND m.source_system_id = 3;

-- Match: 29590_4428CBC56B17464B495E6CEF540A5B5C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21465,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29590_4428CBC56B17464B495E6CEF540A5B5C' AND m.source_system_id = 3;

-- Match: 29667_A397574604ECE689D2239CE379B67D4E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21491,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29667_A397574604ECE689D2239CE379B67D4E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21491,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29667_A397574604ECE689D2239CE379B67D4E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29667_A397574604ECE689D2239CE379B67D4E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29667_A397574604ECE689D2239CE379B67D4E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29667_A397574604ECE689D2239CE379B67D4E' AND m.source_system_id = 3;

-- Match: 30472_1BFF75B1124AF04FC3C0B002423B0110
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22003,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30472_1BFF75B1124AF04FC3C0B002423B0110' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30472_1BFF75B1124AF04FC3C0B002423B0110' AND m.source_system_id = 3;

-- Match: 29596_798C18AEFDE0EE3C21C560C3B76EE6E4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21727,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21728,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21730,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21730,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21749,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29596_798C18AEFDE0EE3C21C560C3B76EE6E4' AND m.source_system_id = 3;

-- Match: 29673_8FCDB2DE8519AFA0D0AADF4175D9591A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22414,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29673_8FCDB2DE8519AFA0D0AADF4175D9591A' AND m.source_system_id = 3;

-- Match: 30510_7F82A3F941B3185DF819CD001A3E126D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30510_7F82A3F941B3185DF819CD001A3E126D' AND m.source_system_id = 3;

-- Match: 30048_4204A3F471376215934B37308C0AF89A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22142,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '30048_4204A3F471376215934B37308C0AF89A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '30048_4204A3F471376215934B37308C0AF89A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22170,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '30048_4204A3F471376215934B37308C0AF89A' AND m.source_system_id = 3;

-- Match: 29670_2530BBD0E245551132FDEA235BDA5E04
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22462,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22467,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22467,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22484,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22234,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22240,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29670_2530BBD0E245551132FDEA235BDA5E04' AND m.source_system_id = 3;

-- Match: 29604_3A3AED68309B19E6A76C30B518072C38
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21730,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29604_3A3AED68309B19E6A76C30B518072C38' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21751,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29604_3A3AED68309B19E6A76C30B518072C38' AND m.source_system_id = 3;

-- Match: 29388_0064F311CE7CEBA5281443396C611D1B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29388_0064F311CE7CEBA5281443396C611D1B' AND m.source_system_id = 3;

-- Match: 30281_64841F122E2163D91DB6882BC28E8C89
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30281_64841F122E2163D91DB6882BC28E8C89' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30281_64841F122E2163D91DB6882BC28E8C89' AND m.source_system_id = 3;

-- Match: 30522_928F0A2D71B05002A161D8E5AAB1DDD0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30522_928F0A2D71B05002A161D8E5AAB1DDD0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30522_928F0A2D71B05002A161D8E5AAB1DDD0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21228,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30522_928F0A2D71B05002A161D8E5AAB1DDD0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21228,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30522_928F0A2D71B05002A161D8E5AAB1DDD0' AND m.source_system_id = 3;

-- Match: 29386_D5C18BFB51E4470A3F3FC857BB64CE8F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29386_D5C18BFB51E4470A3F3FC857BB64CE8F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29386_D5C18BFB51E4470A3F3FC857BB64CE8F' AND m.source_system_id = 3;

-- Match: 29600_875799F81F94B4F6CBE57ACFD7125A68
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21458,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29600_875799F81F94B4F6CBE57ACFD7125A68' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21473,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29600_875799F81F94B4F6CBE57ACFD7125A68' AND m.source_system_id = 3;

-- Match: 29677_07EC417D5E9745D86186C64DD683ADDC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21483,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29677_07EC417D5E9745D86186C64DD683ADDC' AND m.source_system_id = 3;

-- Match: 30280_4167A1096DE711ED75D2D3ECA7563466
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21335,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30280_4167A1096DE711ED75D2D3ECA7563466' AND m.source_system_id = 3;

-- Match: 29680_C76B83579E3E26A8955A5EAC1A51773F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29680_C76B83579E3E26A8955A5EAC1A51773F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29680_C76B83579E3E26A8955A5EAC1A51773F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20508,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29680_C76B83579E3E26A8955A5EAC1A51773F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20523,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29680_C76B83579E3E26A8955A5EAC1A51773F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29680_C76B83579E3E26A8955A5EAC1A51773F' AND m.source_system_id = 3;

-- Match: 30473_FF36AA84B2A40453D2344F66A8404149
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20531,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
WHERE m.external_id = '30473_FF36AA84B2A40453D2344F66A8404149' AND m.source_system_id = 3;

-- Match: 30282_2874DFC536875E0D5ABAB477438F44BB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20604,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30282_2874DFC536875E0D5ABAB477438F44BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20613,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30282_2874DFC536875E0D5ABAB477438F44BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20613,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30282_2874DFC536875E0D5ABAB477438F44BB' AND m.source_system_id = 3;

-- Match: 30521_7CCB4E1C81BAB44743AC969FB778F2A3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30521_7CCB4E1C81BAB44743AC969FB778F2A3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30521_7CCB4E1C81BAB44743AC969FB778F2A3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30521_7CCB4E1C81BAB44743AC969FB778F2A3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30521_7CCB4E1C81BAB44743AC969FB778F2A3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20629,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30521_7CCB4E1C81BAB44743AC969FB778F2A3' AND m.source_system_id = 3;

-- Match: 31547_05825F54697AD2E49A93E812DAFCFE0B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31547_05825F54697AD2E49A93E812DAFCFE0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31547_05825F54697AD2E49A93E812DAFCFE0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31547_05825F54697AD2E49A93E812DAFCFE0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21440,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31547_05825F54697AD2E49A93E812DAFCFE0B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20839,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '31547_05825F54697AD2E49A93E812DAFCFE0B' AND m.source_system_id = 3;

-- Match: 29599_28A8FE9D6C91F9FF80DCD3945C2C4CFA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20902,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29599_28A8FE9D6C91F9FF80DCD3945C2C4CFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29599_28A8FE9D6C91F9FF80DCD3945C2C4CFA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20926,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29599_28A8FE9D6C91F9FF80DCD3945C2C4CFA' AND m.source_system_id = 3;

-- Match: 29676_8270324FC8BA4EB7963F8F3A90895757
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20930,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29676_8270324FC8BA4EB7963F8F3A90895757' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20930,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29676_8270324FC8BA4EB7963F8F3A90895757' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20942,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29676_8270324FC8BA4EB7963F8F3A90895757' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20958,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29676_8270324FC8BA4EB7963F8F3A90895757' AND m.source_system_id = 3;

-- Match: 29601_9AE7CD79700966E883474025369AD51E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29601_9AE7CD79700966E883474025369AD51E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21017,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29601_9AE7CD79700966E883474025369AD51E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21017,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29601_9AE7CD79700966E883474025369AD51E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21018,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29601_9AE7CD79700966E883474025369AD51E' AND m.source_system_id = 3;

-- Match: 29602_A635B01A507C9E40493FAB563A20A858
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21106,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29602_A635B01A507C9E40493FAB563A20A858' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29602_A635B01A507C9E40493FAB563A20A858' AND m.source_system_id = 3;

-- Match: 29679_70EB3999E1CE8417A204C2A56121ABC1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21132,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29679_70EB3999E1CE8417A204C2A56121ABC1' AND m.source_system_id = 3;

-- Match: 29390_DD1A7530625AEF736F14BCBE5EBC7BCA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21262,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29390_DD1A7530625AEF736F14BCBE5EBC7BCA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29390_DD1A7530625AEF736F14BCBE5EBC7BCA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29390_DD1A7530625AEF736F14BCBE5EBC7BCA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29390_DD1A7530625AEF736F14BCBE5EBC7BCA' AND m.source_system_id = 3;

-- Match: 29387_CE08272B581B17D7A077576C9B32C4E8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21360,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Athletic Club' AND t.source_system_id = 3
WHERE m.external_id = '29387_CE08272B581B17D7A077576C9B32C4E8' AND m.source_system_id = 3;

-- Match: 31549_A3573BB06D3EE4026096C5891AE90D5E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31549_A3573BB06D3EE4026096C5891AE90D5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31549_A3573BB06D3EE4026096C5891AE90D5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31549_A3573BB06D3EE4026096C5891AE90D5E' AND m.source_system_id = 3;

-- Match: 30474_7CCDC72CED573B206A186DD1312F39DF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30474_7CCDC72CED573B206A186DD1312F39DF' AND m.source_system_id = 3;

-- Match: 29678_6FA8D6301345A7E38193D631355278DA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22463,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29678_6FA8D6301345A7E38193D631355278DA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22466,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29678_6FA8D6301345A7E38193D631355278DA' AND m.source_system_id = 3;

-- Match: 29598_F980B22F9A38DABE6086231F787264EE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22186,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '29598_F980B22F9A38DABE6086231F787264EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '29598_F980B22F9A38DABE6086231F787264EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '29598_F980B22F9A38DABE6086231F787264EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22257,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29598_F980B22F9A38DABE6086231F787264EE' AND m.source_system_id = 3;

-- Match: 29675_772AB6F783F83F1AD8438F3D649F3C47
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22236,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29675_772AB6F783F83F1AD8438F3D649F3C47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22442,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29675_772AB6F783F83F1AD8438F3D649F3C47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29675_772AB6F783F83F1AD8438F3D649F3C47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29675_772AB6F783F83F1AD8438F3D649F3C47' AND m.source_system_id = 3;

-- Match: 29612_5DB0479F69EF3494F6FFFE84A8A9F4B4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29612_5DB0479F69EF3494F6FFFE84A8A9F4B4' AND m.source_system_id = 3;

-- Match: 31609_BB6BFFA58FA81A72BC1508B7A0AF4438
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20835,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '31609_BB6BFFA58FA81A72BC1508B7A0AF4438' AND m.source_system_id = 3;

-- Match: 31611_402CF54B0A6BF76ECB055B2DE5C47FA2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22148,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22163,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22165,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '31611_402CF54B0A6BF76ECB055B2DE5C47FA2' AND m.source_system_id = 3;

-- Match: 29405_FFA2F5F65EB7ED4745483D8898C2E384
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21890,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29405_FFA2F5F65EB7ED4745483D8898C2E384' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21908,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29405_FFA2F5F65EB7ED4745483D8898C2E384' AND m.source_system_id = 3;

-- Match: 29609_50C53367DCD6301ADEABC9877E5F7A07
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29609_50C53367DCD6301ADEABC9877E5F7A07' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29609_50C53367DCD6301ADEABC9877E5F7A07' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20320,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29609_50C53367DCD6301ADEABC9877E5F7A07' AND m.source_system_id = 3;

-- Match: 29686_85494C1DC8E5E69937EB039DA591E13E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29686_85494C1DC8E5E69937EB039DA591E13E' AND m.source_system_id = 3;

-- Match: 29613_8B8E3B02D35BE1659BAFDC81046241D7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21728,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29613_8B8E3B02D35BE1659BAFDC81046241D7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21730,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29613_8B8E3B02D35BE1659BAFDC81046241D7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29613_8B8E3B02D35BE1659BAFDC81046241D7' AND m.source_system_id = 3;

-- Match: 31607_FF9E07C2033B69A2DDFCFD245F3BCC89
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21435,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31607_FF9E07C2033B69A2DDFCFD245F3BCC89' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21435,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31607_FF9E07C2033B69A2DDFCFD245F3BCC89' AND m.source_system_id = 3;

-- Match: 30523_57497814210963DFEA9D03F28918C67D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21794,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30523_57497814210963DFEA9D03F28918C67D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30523_57497814210963DFEA9D03F28918C67D' AND m.source_system_id = 3;

-- Match: 29687_180A5FC6E6370BAA23602874230C5D0E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20501,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29687_180A5FC6E6370BAA23602874230C5D0E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20502,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29687_180A5FC6E6370BAA23602874230C5D0E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20502,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29687_180A5FC6E6370BAA23602874230C5D0E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20517,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29687_180A5FC6E6370BAA23602874230C5D0E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29687_180A5FC6E6370BAA23602874230C5D0E' AND m.source_system_id = 3;

-- Match: 30290_169264A136483E01416FB20BEE5036A2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20603,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30290_169264A136483E01416FB20BEE5036A2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20603,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30290_169264A136483E01416FB20BEE5036A2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20612,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30290_169264A136483E01416FB20BEE5036A2' AND m.source_system_id = 3;

-- Match: 30524_94A26E7E54249439D90E11F719FB5B9E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20626,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30524_94A26E7E54249439D90E11F719FB5B9E' AND m.source_system_id = 3;

-- Match: 29606_BDCC6355C762D93F82D3D14B417C66DC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20902,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29606_BDCC6355C762D93F82D3D14B417C66DC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29606_BDCC6355C762D93F82D3D14B417C66DC' AND m.source_system_id = 3;

-- Match: 29683_02A81FA8187535F299EBC956369DCF57
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20930,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29683_02A81FA8187535F299EBC956369DCF57' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20942,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29683_02A81FA8187535F299EBC956369DCF57' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20958,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29683_02A81FA8187535F299EBC956369DCF57' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20958,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29683_02A81FA8187535F299EBC956369DCF57' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20958,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29683_02A81FA8187535F299EBC956369DCF57' AND m.source_system_id = 3;

-- Match: 29608_2307D43A08BF749CEA23EA17AA20A29E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29608_2307D43A08BF749CEA23EA17AA20A29E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21026,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29608_2307D43A08BF749CEA23EA17AA20A29E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21027,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29608_2307D43A08BF749CEA23EA17AA20A29E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29608_2307D43A08BF749CEA23EA17AA20A29E' AND m.source_system_id = 3;

-- Match: 30291_1F5B5F59DFDDAC53541DC518AA7D8AB1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30291_1F5B5F59DFDDAC53541DC518AA7D8AB1' AND m.source_system_id = 3;

-- Match: 30293_169620C132DBDC89C6A87E375E7F5552
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30293_169620C132DBDC89C6A87E375E7F5552' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21814,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30293_169620C132DBDC89C6A87E375E7F5552' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21823,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30293_169620C132DBDC89C6A87E375E7F5552' AND m.source_system_id = 3;

-- Match: 29402_16BB802A83CE825CA91E754F25AA3233
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29402_16BB802A83CE825CA91E754F25AA3233' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29402_16BB802A83CE825CA91E754F25AA3233' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21201,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29402_16BB802A83CE825CA91E754F25AA3233' AND m.source_system_id = 3;

-- Match: 29458_5D1F0096321FF3EE70D53F7995D6578B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21285,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29458_5D1F0096321FF3EE70D53F7995D6578B' AND m.source_system_id = 3;

-- Match: 29684_63882DCCBF1C5E0DA3162DCBE9365104
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29684_63882DCCBF1C5E0DA3162DCBE9365104' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21672,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29684_63882DCCBF1C5E0DA3162DCBE9365104' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29684_63882DCCBF1C5E0DA3162DCBE9365104' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29684_63882DCCBF1C5E0DA3162DCBE9365104' AND m.source_system_id = 3;

-- Match: 29690_DC170286B8526DAAE4F8F7A38F190024
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21752,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '29690_DC170286B8526DAAE4F8F7A38F190024' AND m.source_system_id = 3;

-- Match: 29685_2DFAE63790FCC03805D6AB94832540AF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22462,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29685_2DFAE63790FCC03805D6AB94832540AF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22462,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29685_2DFAE63790FCC03805D6AB94832540AF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22462,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29685_2DFAE63790FCC03805D6AB94832540AF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22466,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29685_2DFAE63790FCC03805D6AB94832540AF' AND m.source_system_id = 3;

-- Match: 31615_EDDFAE7FBE165CBCDC5074C99A6E5D9F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22216,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '31615_EDDFAE7FBE165CBCDC5074C99A6E5D9F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '31615_EDDFAE7FBE165CBCDC5074C99A6E5D9F' AND m.source_system_id = 3;

-- Match: 29409_11C40CA67C679B6BFDE64DCB197977AD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29409_11C40CA67C679B6BFDE64DCB197977AD' AND m.source_system_id = 3;

-- Match: 29464_AE2AB35112B6BC51193E743C444CDDB7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20878,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
WHERE m.external_id = '29464_AE2AB35112B6BC51193E743C444CDDB7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20884,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
WHERE m.external_id = '29464_AE2AB35112B6BC51193E743C444CDDB7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20897,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
WHERE m.external_id = '29464_AE2AB35112B6BC51193E743C444CDDB7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20900,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Sandzak II' AND t.source_system_id = 3
WHERE m.external_id = '29464_AE2AB35112B6BC51193E743C444CDDB7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21935,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '29464_AE2AB35112B6BC51193E743C444CDDB7' AND m.source_system_id = 3;

-- Match: 30298_1B0A3BAAD3516297D4E6A7D498B98B06
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30298_1B0A3BAAD3516297D4E6A7D498B98B06' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30298_1B0A3BAAD3516297D4E6A7D498B98B06' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30298_1B0A3BAAD3516297D4E6A7D498B98B06' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20145,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Aurora FC' AND t.source_system_id = 3
WHERE m.external_id = '30298_1B0A3BAAD3516297D4E6A7D498B98B06' AND m.source_system_id = 3;

-- Match: 29463_0BA3FE51D0E4669269D7E8286A209D47
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20291,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29463_0BA3FE51D0E4669269D7E8286A209D47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29463_0BA3FE51D0E4669269D7E8286A209D47' AND m.source_system_id = 3;

-- Match: 29616_935DBABA85486A735994C08EC23CC6BC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20311,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29616_935DBABA85486A735994C08EC23CC6BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29616_935DBABA85486A735994C08EC23CC6BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20315,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29616_935DBABA85486A735994C08EC23CC6BC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20330,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29616_935DBABA85486A735994C08EC23CC6BC' AND m.source_system_id = 3;

-- Match: 29619_0C5A8556D53483AF252EF263A31FC6F2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20785,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29619_0C5A8556D53483AF252EF263A31FC6F2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20785,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29619_0C5A8556D53483AF252EF263A31FC6F2' AND m.source_system_id = 3;

-- Match: 29697_78FFDDE47F128D021C910FA152039D69
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20501,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20501,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20501,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20517,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20517,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20523,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29697_78FFDDE47F128D021C910FA152039D69' AND m.source_system_id = 3;

-- Match: 29406_BC71C604A61AA5EE0DEE79B990651BE1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29406_BC71C604A61AA5EE0DEE79B990651BE1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29406_BC71C604A61AA5EE0DEE79B990651BE1' AND m.source_system_id = 3;

-- Match: 30297_A8775CE85B4E1AE3E3738EE17492B4EE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20616,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30297_A8775CE85B4E1AE3E3738EE17492B4EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20616,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
WHERE m.external_id = '30297_A8775CE85B4E1AE3E3738EE17492B4EE' AND m.source_system_id = 3;

-- Match: 29620_D0492CB54B83F8CFF20F8C9CF2459913
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20673,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
WHERE m.external_id = '29620_D0492CB54B83F8CFF20F8C9CF2459913' AND m.source_system_id = 3;

-- Match: 31613_0EA24D973766CD0DE467B8389F16C71C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31613_0EA24D973766CD0DE467B8389F16C71C' AND m.source_system_id = 3;

-- Match: 31616_2C691726031823B5098440D4E93855EC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20839,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '31616_2C691726031823B5098440D4E93855EC' AND m.source_system_id = 3;

-- Match: 29615_7B1BA9E37C118FB0553C8B69112B0253
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20902,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29615_7B1BA9E37C118FB0553C8B69112B0253' AND m.source_system_id = 3;

-- Match: 29693_5AC48EDFF5705E915A45BCBDB2A224AC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29693_5AC48EDFF5705E915A45BCBDB2A224AC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29693_5AC48EDFF5705E915A45BCBDB2A224AC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20942,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29693_5AC48EDFF5705E915A45BCBDB2A224AC' AND m.source_system_id = 3;

-- Match: 29617_6A3DE1594F9D3D7DB022DC54AAD31F52
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22257,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29617_6A3DE1594F9D3D7DB022DC54AAD31F52' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22257,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '29617_6A3DE1594F9D3D7DB022DC54AAD31F52' AND m.source_system_id = 3;

-- Match: 29410_A81521B99722F75D03DD0A2CCDE11ADE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29410_A81521B99722F75D03DD0A2CCDE11ADE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29410_A81521B99722F75D03DD0A2CCDE11ADE' AND m.source_system_id = 3;

-- Match: 29465_AA2DC7CF6E9574245A0DA209FB67891C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22314,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29465_AA2DC7CF6E9574245A0DA209FB67891C' AND m.source_system_id = 3;

-- Match: 30295_E873A2DE64FEBD3D8946B19FE87918ED
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30295_E873A2DE64FEBD3D8946B19FE87918ED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30295_E873A2DE64FEBD3D8946B19FE87918ED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30295_E873A2DE64FEBD3D8946B19FE87918ED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30295_E873A2DE64FEBD3D8946B19FE87918ED' AND m.source_system_id = 3;

-- Match: 29614_349326E6BFFA8219A7C013D8AE6FD25C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21473,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29614_349326E6BFFA8219A7C013D8AE6FD25C' AND m.source_system_id = 3;

-- Match: 29692_843939481C3EAF832909839378848457
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22252,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29692_843939481C3EAF832909839378848457' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21493,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29692_843939481C3EAF832909839378848457' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29692_843939481C3EAF832909839378848457' AND m.source_system_id = 3;

-- Match: 30480_49D65F211F27AF144A9F8F80FFC33783
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30480_49D65F211F27AF144A9F8F80FFC33783' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30480_49D65F211F27AF144A9F8F80FFC33783' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22005,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30480_49D65F211F27AF144A9F8F80FFC33783' AND m.source_system_id = 3;

-- Match: 30526_D8DFD99A348B7DFD581AE55FF8305890
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30526_D8DFD99A348B7DFD581AE55FF8305890' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30526_D8DFD99A348B7DFD581AE55FF8305890' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30526_D8DFD99A348B7DFD581AE55FF8305890' AND m.source_system_id = 3;

-- Match: 29695_783958FE6D54814DA772CA21C34B9513
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22444,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29695_783958FE6D54814DA772CA21C34B9513' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29695_783958FE6D54814DA772CA21C34B9513' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29695_783958FE6D54814DA772CA21C34B9513' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29695_783958FE6D54814DA772CA21C34B9513' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22457,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29695_783958FE6D54814DA772CA21C34B9513' AND m.source_system_id = 3;

-- Match: 30303_51E6C49665C49CEF35A2C1B398E3F137
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20754,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30303_51E6C49665C49CEF35A2C1B398E3F137' AND m.source_system_id = 3;

-- Match: 29624_701C3F32A2A171D58431870FDC1AEFE3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29624_701C3F32A2A171D58431870FDC1AEFE3' AND m.source_system_id = 3;

-- Match: 29627_91F904BAD1AD3B007A9C69E6D45FE284
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20674,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
WHERE m.external_id = '29627_91F904BAD1AD3B007A9C69E6D45FE284' AND m.source_system_id = 3;

-- Match: 29705_A719B1D044CB52B7F877DF5C9550A573
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29705_A719B1D044CB52B7F877DF5C9550A573' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29705_A719B1D044CB52B7F877DF5C9550A573' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20513,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29705_A719B1D044CB52B7F877DF5C9550A573' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20517,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29705_A719B1D044CB52B7F877DF5C9550A573' AND m.source_system_id = 3;

-- Match: 30484_880F8EF99A5293014C46C9B1AF1704BA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22019,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30484_880F8EF99A5293014C46C9B1AF1704BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22019,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30484_880F8EF99A5293014C46C9B1AF1704BA' AND m.source_system_id = 3;

-- Match: 30482_D1E5845490EB8BBC3542E9548B334512
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20625,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30482_D1E5845490EB8BBC3542E9548B334512' AND m.source_system_id = 3;

-- Match: 31618_87292BD1ABAAAE80AC6AC24B0447AAED
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22216,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '31618_87292BD1ABAAAE80AC6AC24B0447AAED' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22219,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '31618_87292BD1ABAAAE80AC6AC24B0447AAED' AND m.source_system_id = 3;

-- Match: 29628_5147D6542FCC01EEBA73C26F21FCA559
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22349,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '29628_5147D6542FCC01EEBA73C26F21FCA559' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29628_5147D6542FCC01EEBA73C26F21FCA559' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29628_5147D6542FCC01EEBA73C26F21FCA559' AND m.source_system_id = 3;

-- Match: 29706_E339BA5D847AD0F9D1416575AE24D995
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22411,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29706_E339BA5D847AD0F9D1416575AE24D995' AND m.source_system_id = 3;

-- Match: 29623_E82DEBF058F4BE7A9A2A7A362359171C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20915,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29623_E82DEBF058F4BE7A9A2A7A362359171C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20927,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29623_E82DEBF058F4BE7A9A2A7A362359171C' AND m.source_system_id = 3;

-- Match: 29414_2D960C7E1542E7AF2A03C82AF57DEF95
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22285,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29414_2D960C7E1542E7AF2A03C82AF57DEF95' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22291,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29414_2D960C7E1542E7AF2A03C82AF57DEF95' AND m.source_system_id = 3;

-- Match: 30307_2D338EA0F37BE62DCE6A34C2F5A1B21A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30307_2D338EA0F37BE62DCE6A34C2F5A1B21A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30307_2D338EA0F37BE62DCE6A34C2F5A1B21A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30307_2D338EA0F37BE62DCE6A34C2F5A1B21A' AND m.source_system_id = 3;

-- Match: 30306_57BE8B7C4AB60AEBAEBB7E2838CB7F24
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30306_57BE8B7C4AB60AEBAEBB7E2838CB7F24' AND m.source_system_id = 3;

-- Match: 29626_144865859AEFF9758AF200C2A6303215
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21729,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29626_144865859AEFF9758AF200C2A6303215' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29626_144865859AEFF9758AF200C2A6303215' AND m.source_system_id = 3;

-- Match: 29704_6303E41E25E0F73D26A116D66A1335A1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21128,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29704_6303E41E25E0F73D26A116D66A1335A1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21752,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '29704_6303E41E25E0F73D26A116D66A1335A1' AND m.source_system_id = 3;

-- Match: 29466_416F392E6C9417ADCBB1C6B717F3A510
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21919,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '29466_416F392E6C9417ADCBB1C6B717F3A510' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21285,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29466_416F392E6C9417ADCBB1C6B717F3A510' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29466_416F392E6C9417ADCBB1C6B717F3A510' AND m.source_system_id = 3;

-- Match: 31620_9347A548224C48798BFBA3E0BA3C8F36
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21435,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31620_9347A548224C48798BFBA3E0BA3C8F36' AND m.source_system_id = 3;

-- Match: 29622_087E3D5204C93F1A96DE007D027092B0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21473,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29622_087E3D5204C93F1A96DE007D027092B0' AND m.source_system_id = 3;

-- Match: 29700_524AFAAF0CBC90CDEC81B928C46767E0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21483,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29700_524AFAAF0CBC90CDEC81B928C46767E0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29700_524AFAAF0CBC90CDEC81B928C46767E0' AND m.source_system_id = 3;

-- Match: 29632_6526CA2F710C9BF33DE8D91897276BF4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20311,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29632_6526CA2F710C9BF33DE8D91897276BF4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29632_6526CA2F710C9BF33DE8D91897276BF4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20315,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29632_6526CA2F710C9BF33DE8D91897276BF4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20317,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29632_6526CA2F710C9BF33DE8D91897276BF4' AND m.source_system_id = 3;

-- Match: 29710_A722047FB1F037BE1F16FEE1EA2B1A5E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22479,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
WHERE m.external_id = '29710_A722047FB1F037BE1F16FEE1EA2B1A5E' AND m.source_system_id = 3;

-- Match: 29635_79B5EA48A566E44AE690143661495554
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29635_79B5EA48A566E44AE690143661495554' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29635_79B5EA48A566E44AE690143661495554' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29635_79B5EA48A566E44AE690143661495554' AND m.source_system_id = 3;

-- Match: 31661_91D54F848F9FAE02C420FEB2D51D5FEE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20835,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '31661_91D54F848F9FAE02C420FEB2D51D5FEE' AND m.source_system_id = 3;

-- Match: 29712_D17E879C3F9D36968FA0EE95DBBED237
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22420,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29712_D17E879C3F9D36968FA0EE95DBBED237' AND m.source_system_id = 3;

-- Match: 29419_E454E539E0832DE27E6DACC48F9E8423
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29419_E454E539E0832DE27E6DACC48F9E8423' AND m.source_system_id = 3;

-- Match: 29474_400BED3D1074B4BAEBBB3B5DE8BEA143
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20285,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29474_400BED3D1074B4BAEBBB3B5DE8BEA143' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20291,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29474_400BED3D1074B4BAEBBB3B5DE8BEA143' AND m.source_system_id = 3;

-- Match: 29637_31E180B82478946FFF951B7B32662960
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29637_31E180B82478946FFF951B7B32662960' AND m.source_system_id = 3;

-- Match: 31660_C91CED24CD679C9EE4D76704C0EF16A2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31660_C91CED24CD679C9EE4D76704C0EF16A2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31660_C91CED24CD679C9EE4D76704C0EF16A2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21717,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31660_C91CED24CD679C9EE4D76704C0EF16A2' AND m.source_system_id = 3;

-- Match: 29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21890,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21890,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21891,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29416_8E5AC11FFEEF8A75BFBC9DC17E6E5092' AND m.source_system_id = 3;

-- Match: 29636_56C90CE69EC5C915A161243C2DB8A862
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21729,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29636_56C90CE69EC5C915A161243C2DB8A862' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21743,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29636_56C90CE69EC5C915A161243C2DB8A862' AND m.source_system_id = 3;

-- Match: 30310_89E7D5837EE2DA5F2808121FA36978AA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30310_89E7D5837EE2DA5F2808121FA36978AA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30310_89E7D5837EE2DA5F2808121FA36978AA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30310_89E7D5837EE2DA5F2808121FA36978AA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30310_89E7D5837EE2DA5F2808121FA36978AA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30310_89E7D5837EE2DA5F2808121FA36978AA' AND m.source_system_id = 3;

-- Match: 29417_3CBC6ED33BEC2A66EB33B48F95598F56
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29417_3CBC6ED33BEC2A66EB33B48F95598F56' AND m.source_system_id = 3;

-- Match: 29418_E75744F56F72E9B8C3AD70BBEC7527C0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21283,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29418_E75744F56F72E9B8C3AD70BBEC7527C0' AND m.source_system_id = 3;

-- Match: 29473_AD8157CD5BB001571D5C67BBEE2E2967
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29473_AD8157CD5BB001571D5C67BBEE2E2967' AND m.source_system_id = 3;

-- Match: 29715_8B07326195A10013DE06B1EE90DEF338
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21128,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29715_8B07326195A10013DE06B1EE90DEF338' AND m.source_system_id = 3;

-- Match: 30534_EB870917F79B342D5B4D842B143B26EF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30534_EB870917F79B342D5B4D842B143B26EF' AND m.source_system_id = 3;

-- Match: 31663_B946A683FD1799ABB0F180BE42E42C3A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21431,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31663_B946A683FD1799ABB0F180BE42E42C3A' AND m.source_system_id = 3;

-- Match: 29631_2A29A38582D6C5697359CDE3DB81CB3E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21458,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29631_2A29A38582D6C5697359CDE3DB81CB3E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21476,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29631_2A29A38582D6C5697359CDE3DB81CB3E' AND m.source_system_id = 3;

-- Match: 29709_3D542F17688D2C736BE0658CAE7FCC07
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21483,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29709_3D542F17688D2C736BE0658CAE7FCC07' AND m.source_system_id = 3;

-- Match: 29711_E220C3E40A68BF8F400419CD4BE8A504
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29711_E220C3E40A68BF8F400419CD4BE8A504' AND m.source_system_id = 3;

-- Match: 29420_27FD4F4039878B4803F52104B6A26C12
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29420_27FD4F4039878B4803F52104B6A26C12' AND m.source_system_id = 3;

-- Match: 30315_A2197893EFC9F82A27275D4D4AE1A4EE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21528,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30315_A2197893EFC9F82A27275D4D4AE1A4EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30315_A2197893EFC9F82A27275D4D4AE1A4EE' AND m.source_system_id = 3;

-- Match: 30317_A907D709F22295000A8D1465D7FE8DA8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30317_A907D709F22295000A8D1465D7FE8DA8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30317_A907D709F22295000A8D1465D7FE8DA8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30317_A907D709F22295000A8D1465D7FE8DA8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21328,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30317_A907D709F22295000A8D1465D7FE8DA8' AND m.source_system_id = 3;

-- Match: 30537_172F078501A5795EFFBEAF5C3FE529E4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30537_172F078501A5795EFFBEAF5C3FE529E4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21794,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30537_172F078501A5795EFFBEAF5C3FE529E4' AND m.source_system_id = 3;

-- Match: 29721_ECA89244827840CC2D31218B4464B845
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29721_ECA89244827840CC2D31218B4464B845' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20512,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29721_ECA89244827840CC2D31218B4464B845' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20523,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29721_ECA89244827840CC2D31218B4464B845' AND m.source_system_id = 3;

-- Match: 29425_0B9B59B7F8A81113AB60AEE7CCBB85FD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29425_0B9B59B7F8A81113AB60AEE7CCBB85FD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21193,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29425_0B9B59B7F8A81113AB60AEE7CCBB85FD' AND m.source_system_id = 3;

-- Match: 29641_3615FA4956EA261FB09251865E83AF95
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29641_3615FA4956EA261FB09251865E83AF95' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29641_3615FA4956EA261FB09251865E83AF95' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20324,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29641_3615FA4956EA261FB09251865E83AF95' AND m.source_system_id = 3;

-- Match: 31665_F235BDE8828976520D133B3B1B8E584C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20839,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Partizani NY' AND t.source_system_id = 3
WHERE m.external_id = '31665_F235BDE8828976520D133B3B1B8E584C' AND m.source_system_id = 3;

-- Match: 30321_B294EB017400510E98C479FDE9D639F8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30321_B294EB017400510E98C479FDE9D639F8' AND m.source_system_id = 3;

-- Match: 29643_9B486E2812569B0FC36656A2AB9E68EE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21104,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29643_9B486E2812569B0FC36656A2AB9E68EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21113,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29643_9B486E2812569B0FC36656A2AB9E68EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29643_9B486E2812569B0FC36656A2AB9E68EE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29643_9B486E2812569B0FC36656A2AB9E68EE' AND m.source_system_id = 3;

-- Match: 31666_A61E8AF1AF11101B97CABB570B3192C6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31666_A61E8AF1AF11101B97CABB570B3192C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21717,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31666_A61E8AF1AF11101B97CABB570B3192C6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21722,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31666_A61E8AF1AF11101B97CABB570B3192C6' AND m.source_system_id = 3;

-- Match: 29722_F41C9A080FB4E6D0990FDD6F4498BCE0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21128,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29722_F41C9A080FB4E6D0990FDD6F4498BCE0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29722_F41C9A080FB4E6D0990FDD6F4498BCE0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29722_F41C9A080FB4E6D0990FDD6F4498BCE0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29722_F41C9A080FB4E6D0990FDD6F4498BCE0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '29722_F41C9A080FB4E6D0990FDD6F4498BCE0' AND m.source_system_id = 3;

-- Match: 29639_C6ACFCB0081AE17DC074B0DAC27B2F79
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21465,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29639_C6ACFCB0081AE17DC074B0DAC27B2F79' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21465,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29639_C6ACFCB0081AE17DC074B0DAC27B2F79' AND m.source_system_id = 3;

-- Match: 29718_A20F02ABB366FC70581D503A8E4F4EF6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20930,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20942,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20945,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20950,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20955,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21483,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21483,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29718_A20F02ABB366FC70581D503A8E4F4EF6' AND m.source_system_id = 3;

-- Match: 30539_1B76206881F8CD20B49951F37C4783D2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22005,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30539_1B76206881F8CD20B49951F37C4783D2' AND m.source_system_id = 3;

-- Match: 30538_E5E4D0AB555BCAC0D2F5919F0F8C3303
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21228,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30538_E5E4D0AB555BCAC0D2F5919F0F8C3303' AND m.source_system_id = 3;

-- Match: 31668_61AD8A7A764B2B5E7D49206B0954B8AF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '31668_61AD8A7A764B2B5E7D49206B0954B8AF' AND m.source_system_id = 3;

-- Match: 29479_8695F72B96AFBC6E7EF22EEA3E1B0C9C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21917,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '29479_8695F72B96AFBC6E7EF22EEA3E1B0C9C' AND m.source_system_id = 3;

-- Match: 29719_B939ED7F1E8590EBC49D96C4607184A6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21670,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29719_B939ED7F1E8590EBC49D96C4607184A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29719_B939ED7F1E8590EBC49D96C4607184A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21679,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29719_B939ED7F1E8590EBC49D96C4607184A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29719_B939ED7F1E8590EBC49D96C4607184A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29719_B939ED7F1E8590EBC49D96C4607184A6' AND m.source_system_id = 3;

-- Match: 29645_9B011F7CE3CEE7D828183809119C9D09
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21728,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29645_9B011F7CE3CEE7D828183809119C9D09' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29645_9B011F7CE3CEE7D828183809119C9D09' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21749,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '29645_9B011F7CE3CEE7D828183809119C9D09' AND m.source_system_id = 3;

-- Match: 29724_63DFFADF86C2453A5E59511FFB43E0EC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21766,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '29724_63DFFADF86C2453A5E59511FFB43E0EC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21778,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '29724_63DFFADF86C2453A5E59511FFB43E0EC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21778,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '29724_63DFFADF86C2453A5E59511FFB43E0EC' AND m.source_system_id = 3;

-- Match: 29723_9DC907530679D67A9B9285CCCACA2297
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22411,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29723_9DC907530679D67A9B9285CCCACA2297' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29723_9DC907530679D67A9B9285CCCACA2297' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29723_9DC907530679D67A9B9285CCCACA2297' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22420,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29723_9DC907530679D67A9B9285CCCACA2297' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22432,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29723_9DC907530679D67A9B9285CCCACA2297' AND m.source_system_id = 3;

-- Match: 29385_C986A61E0DEE02B65F2FAC01414EEE6B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20258,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29385_C986A61E0DEE02B65F2FAC01414EEE6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29385_C986A61E0DEE02B65F2FAC01414EEE6B' AND m.source_system_id = 3;

-- Match: 29650_C5260B32782F04023731ED4DA23058CA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22334,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '29650_C5260B32782F04023731ED4DA23058CA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22339,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '29650_C5260B32782F04023731ED4DA23058CA' AND m.source_system_id = 3;

-- Match: 29729_B8F79D505C0AFBCA5A125717C2833C25
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22411,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29729_B8F79D505C0AFBCA5A125717C2833C25' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29729_B8F79D505C0AFBCA5A125717C2833C25' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29729_B8F79D505C0AFBCA5A125717C2833C25' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '29729_B8F79D505C0AFBCA5A125717C2833C25' AND m.source_system_id = 3;

-- Match: 29652_485C93F10C61CB17037B3DE5ACB3E670
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20218,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '29652_485C93F10C61CB17037B3DE5ACB3E670' AND m.source_system_id = 3;

-- Match: 29731_301A133B17A47B0BC5511059B074C72E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20658,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
WHERE m.external_id = '29731_301A133B17A47B0BC5511059B074C72E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20658,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
WHERE m.external_id = '29731_301A133B17A47B0BC5511059B074C72E' AND m.source_system_id = 3;

-- Match: 29429_F9E49D882ACC8BC9B1C15E8026E06D97
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29429_F9E49D882ACC8BC9B1C15E8026E06D97' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29429_F9E49D882ACC8BC9B1C15E8026E06D97' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29429_F9E49D882ACC8BC9B1C15E8026E06D97' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20275,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29429_F9E49D882ACC8BC9B1C15E8026E06D97' AND m.source_system_id = 3;

-- Match: 29484_DBDBDD22464E028685819B3CCF818CC8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29484_DBDBDD22464E028685819B3CCF818CC8' AND m.source_system_id = 3;

-- Match: 29647_D2B22B9A3CE80F4558E03745EB034FE1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29647_D2B22B9A3CE80F4558E03745EB034FE1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20313,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29647_D2B22B9A3CE80F4558E03745EB034FE1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29647_D2B22B9A3CE80F4558E03745EB034FE1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '29647_D2B22B9A3CE80F4558E03745EB034FE1' AND m.source_system_id = 3;

-- Match: 29653_F0EA2CA8FE50E4510C8578BC7D049C8B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20801,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29653_F0EA2CA8FE50E4510C8578BC7D049C8B' AND m.source_system_id = 3;

-- Match: 29730_31B30AF3F6C7024C9C89C97553876046
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29730_31B30AF3F6C7024C9C89C97553876046' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29730_31B30AF3F6C7024C9C89C97553876046' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29730_31B30AF3F6C7024C9C89C97553876046' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20523,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '29730_31B30AF3F6C7024C9C89C97553876046' AND m.source_system_id = 3;

-- Match: 29732_A88DC73AA2209CDD3844ACD036C0948F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20812,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '29732_A88DC73AA2209CDD3844ACD036C0948F' AND m.source_system_id = 3;

-- Match: 29485_BD6B0B68E5AB7E7C8A6E38C72B13A491
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29485_BD6B0B68E5AB7E7C8A6E38C72B13A491' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29485_BD6B0B68E5AB7E7C8A6E38C72B13A491' AND m.source_system_id = 3;

-- Match: 29649_6FBED22A5D0DF7748172FF3F59F0D5D2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20902,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29649_6FBED22A5D0DF7748172FF3F59F0D5D2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20927,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29649_6FBED22A5D0DF7748172FF3F59F0D5D2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20927,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '29649_6FBED22A5D0DF7748172FF3F59F0D5D2' AND m.source_system_id = 3;

-- Match: 30326_CB837A8DBDE472E45810649132F1EBEF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30326_CB837A8DBDE472E45810649132F1EBEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30326_CB837A8DBDE472E45810649132F1EBEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30326_CB837A8DBDE472E45810649132F1EBEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30326_CB837A8DBDE472E45810649132F1EBEF' AND m.source_system_id = 3;

-- Match: 29427_F5D4DA066E30D44B1BEAAC64AB2D66F1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29427_F5D4DA066E30D44B1BEAAC64AB2D66F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21191,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29427_F5D4DA066E30D44B1BEAAC64AB2D66F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29427_F5D4DA066E30D44B1BEAAC64AB2D66F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29427_F5D4DA066E30D44B1BEAAC64AB2D66F1' AND m.source_system_id = 3;

-- Match: 30493_1BC933B02CD7AEDDDACAEFBCEE7E995C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21211,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30493_1BC933B02CD7AEDDDACAEFBCEE7E995C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21218,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30493_1BC933B02CD7AEDDDACAEFBCEE7E995C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30493_1BC933B02CD7AEDDDACAEFBCEE7E995C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30493_1BC933B02CD7AEDDDACAEFBCEE7E995C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21223,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30493_1BC933B02CD7AEDDDACAEFBCEE7E995C' AND m.source_system_id = 3;

-- Match: 29482_688926D0E9B49CDEA6DC3EC8C8435F17
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21928,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '29482_688926D0E9B49CDEA6DC3EC8C8435F17' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21938,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '29482_688926D0E9B49CDEA6DC3EC8C8435F17' AND m.source_system_id = 3;

-- Match: 29428_31098D71EFD25803BF9BBCE772E4C14E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29428_31098D71EFD25803BF9BBCE772E4C14E' AND m.source_system_id = 3;

-- Match: 30327_FE1DCE83C57307B40EDCA27366FDFF6B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21533,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21544,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21548,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21552,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30327_FE1DCE83C57307B40EDCA27366FDFF6B' AND m.source_system_id = 3;

-- Match: 29725_55CCCF816C01D508AA4AEAA7778AE99F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21672,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29725_55CCCF816C01D508AA4AEAA7778AE99F' AND m.source_system_id = 3;

-- Match: 31673_C5993A8FCC479E77CFEA56D26456295F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '31673_C5993A8FCC479E77CFEA56D26456295F' AND m.source_system_id = 3;

-- Match: 30542_46390AD34DC336E75B4C970C13368DFF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30542_46390AD34DC336E75B4C970C13368DFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22011,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30542_46390AD34DC336E75B4C970C13368DFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30542_46390AD34DC336E75B4C970C13368DFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30542_46390AD34DC336E75B4C970C13368DFF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21806,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30542_46390AD34DC336E75B4C970C13368DFF' AND m.source_system_id = 3;

-- Match: 30328_29A6DE8AE1E28C4EFDAE6B7201AEB0C0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21817,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30328_29A6DE8AE1E28C4EFDAE6B7201AEB0C0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21830,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30328_29A6DE8AE1E28C4EFDAE6B7201AEB0C0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21831,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '30328_29A6DE8AE1E28C4EFDAE6B7201AEB0C0' AND m.source_system_id = 3;

-- Match: 29727_EF7C48907C56B41EF8759485F28698C9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22437,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29727_EF7C48907C56B41EF8759485F28698C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22437,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29727_EF7C48907C56B41EF8759485F28698C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22454,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29727_EF7C48907C56B41EF8759485F28698C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22454,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29727_EF7C48907C56B41EF8759485F28698C9' AND m.source_system_id = 3;

-- Match: 29445_9245B09CE88C04B6A940D7BE447487EC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29445_9245B09CE88C04B6A940D7BE447487EC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29445_9245B09CE88C04B6A940D7BE447487EC' AND m.source_system_id = 3;

-- Match: 29497_EB3AD9A5E9397E89CF7A075244269B8B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22322,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29497_EB3AD9A5E9397E89CF7A075244269B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22322,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29497_EB3AD9A5E9397E89CF7A075244269B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22322,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29497_EB3AD9A5E9397E89CF7A075244269B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22324,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29497_EB3AD9A5E9397E89CF7A075244269B8B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22325,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '29497_EB3AD9A5E9397E89CF7A075244269B8B' AND m.source_system_id = 3;

-- Match: 29500_128AAA0F0F479A03F5387C54421C62BF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20282,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29500_128AAA0F0F479A03F5387C54421C62BF' AND m.source_system_id = 3;

-- Match: 29434_547D67297B0FE7317270FB0782E7B6F3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20258,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29434_547D67297B0FE7317270FB0782E7B6F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20258,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '29434_547D67297B0FE7317270FB0782E7B6F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22291,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29434_547D67297B0FE7317270FB0782E7B6F3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22294,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29434_547D67297B0FE7317270FB0782E7B6F3' AND m.source_system_id = 3;

-- Match: 29489_5B6D6C0043D01E70E8A0633D0652D4A6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29489_5B6D6C0043D01E70E8A0633D0652D4A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29489_5B6D6C0043D01E70E8A0633D0652D4A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29489_5B6D6C0043D01E70E8A0633D0652D4A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20308,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29489_5B6D6C0043D01E70E8A0633D0652D4A6' AND m.source_system_id = 3;

-- Match: 29660_08C23D3BEC45958CA1AB9EA8BDE69220
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29660_08C23D3BEC45958CA1AB9EA8BDE69220' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20789,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29660_08C23D3BEC45958CA1AB9EA8BDE69220' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29660_08C23D3BEC45958CA1AB9EA8BDE69220' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29660_08C23D3BEC45958CA1AB9EA8BDE69220' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '29660_08C23D3BEC45958CA1AB9EA8BDE69220' AND m.source_system_id = 3;

-- Match: 29739_9D9BC4660B5F0AF6FA2C7D13E974F97A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20820,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '29739_9D9BC4660B5F0AF6FA2C7D13E974F97A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20833,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '29739_9D9BC4660B5F0AF6FA2C7D13E974F97A' AND m.source_system_id = 3;

-- Match: 30335_9E80A79EA5EC374D1FBB0ACDC72666F1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20762,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20762,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20762,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20765,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20783,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Falco FC' AND t.source_system_id = 3
WHERE m.external_id = '30335_9E80A79EA5EC374D1FBB0ACDC72666F1' AND m.source_system_id = 3;

-- Match: 29654_2C6AF0BE49448EF2B0F4E1FD9B3754EF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21458,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29654_2C6AF0BE49448EF2B0F4E1FD9B3754EF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21464,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '29654_2C6AF0BE49448EF2B0F4E1FD9B3754EF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29654_2C6AF0BE49448EF2B0F4E1FD9B3754EF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '29654_2C6AF0BE49448EF2B0F4E1FD9B3754EF' AND m.source_system_id = 3;

-- Match: 29658_601CD2D749110A8A07C808D1D90C990A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21098,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29658_601CD2D749110A8A07C808D1D90C990A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21100,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29658_601CD2D749110A8A07C808D1D90C990A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21111,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29658_601CD2D749110A8A07C808D1D90C990A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21115,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29658_601CD2D749110A8A07C808D1D90C990A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '29658_601CD2D749110A8A07C808D1D90C990A' AND m.source_system_id = 3;

-- Match: 29432_39631F758CD87EE667103BEF6E7F2A1D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29432_39631F758CD87EE667103BEF6E7F2A1D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21201,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29432_39631F758CD87EE667103BEF6E7F2A1D' AND m.source_system_id = 3;

-- Match: 30544_C6818B46AA5BA4B37677A3B2E8875E0A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30544_C6818B46AA5BA4B37677A3B2E8875E0A' AND m.source_system_id = 3;

-- Match: 29488_808FAD6C2FACEA7698B4D4DA0ACB47A6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21308,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '29488_808FAD6C2FACEA7698B4D4DA0ACB47A6' AND m.source_system_id = 3;

-- Match: 29733_FAEA489F19590D9DC6F5A0FD42587570
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '29733_FAEA489F19590D9DC6F5A0FD42587570' AND m.source_system_id = 3;

-- Match: 29734_6D8B0F807512565C949A4DEE44487C2C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29734_6D8B0F807512565C949A4DEE44487C2C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21672,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29734_6D8B0F807512565C949A4DEE44487C2C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29734_6D8B0F807512565C949A4DEE44487C2C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29734_6D8B0F807512565C949A4DEE44487C2C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '29734_6D8B0F807512565C949A4DEE44487C2C' AND m.source_system_id = 3;

-- Match: 29735_63E2FE46020CB3C20198B7998F124E49
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22437,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29735_63E2FE46020CB3C20198B7998F124E49' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22437,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29735_63E2FE46020CB3C20198B7998F124E49' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22451,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29735_63E2FE46020CB3C20198B7998F124E49' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22451,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29735_63E2FE46020CB3C20198B7998F124E49' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22451,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '29735_63E2FE46020CB3C20198B7998F124E49' AND m.source_system_id = 3;

-- Match: 29441_048A6D79AD487982829C2B5FA686D4F9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21187,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29441_048A6D79AD487982829C2B5FA686D4F9' AND m.source_system_id = 3;

-- Match: 29442_93946A7DD506AE3178F7872915F4983B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22294,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '29442_93946A7DD506AE3178F7872915F4983B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21890,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29442_93946A7DD506AE3178F7872915F4983B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21899,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29442_93946A7DD506AE3178F7872915F4983B' AND m.source_system_id = 3;

-- Match: 30296_71382651723D301A66F9C14A5671BFB3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21544,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30296_71382651723D301A66F9C14A5671BFB3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21554,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '30296_71382651723D301A66F9C14A5671BFB3' AND m.source_system_id = 3;

-- Match: 29491_E7C93FC482693CB85D2A947D07F0DFD2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20282,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29491_E7C93FC482693CB85D2A947D07F0DFD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20285,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29491_E7C93FC482693CB85D2A947D07F0DFD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20295,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29491_E7C93FC482693CB85D2A947D07F0DFD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20295,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29491_E7C93FC482693CB85D2A947D07F0DFD2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '29491_E7C93FC482693CB85D2A947D07F0DFD2' AND m.source_system_id = 3;

-- Match: 30341_9BF306D147703A6EC1A7E6B7F09F895B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30341_9BF306D147703A6EC1A7E6B7F09F895B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30341_9BF306D147703A6EC1A7E6B7F09F895B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '30341_9BF306D147703A6EC1A7E6B7F09F895B' AND m.source_system_id = 3;

-- Match: 30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22005,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20650,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20650,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20650,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '30496_9BBBC71DF78C8DEBA0F2E0F6D3BC476A' AND m.source_system_id = 3;

-- Match: 30494_C76FB4A478BB2CABA72655C2AC880B8D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21782,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21793,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30494_C76FB4A478BB2CABA72655C2AC880B8D' AND m.source_system_id = 3;

-- Match: 29437_3424C38D9EB272F26B76F4C50207EEC3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21896,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29437_3424C38D9EB272F26B76F4C50207EEC3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29437_3424C38D9EB272F26B76F4C50207EEC3' AND m.source_system_id = 3;

-- Match: 41547_57F56C752FF53F7ABAA8EC9EDCE86741
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20265,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20265,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20274,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20279,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20279,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20279,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41547_57F56C752FF53F7ABAA8EC9EDCE86741' AND m.source_system_id = 3;

-- Match: 41594_64F45B10906C8BB249F40B2D24FEAB5F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41594_64F45B10906C8BB249F40B2D24FEAB5F' AND m.source_system_id = 3;

-- Match: 41548_A2F65691806231B2EA67449B0F9F5AD6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21895,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41548_A2F65691806231B2EA67449B0F9F5AD6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21896,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41548_A2F65691806231B2EA67449B0F9F5AD6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21898,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41548_A2F65691806231B2EA67449B0F9F5AD6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41548_A2F65691806231B2EA67449B0F9F5AD6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41548_A2F65691806231B2EA67449B0F9F5AD6' AND m.source_system_id = 3;

-- Match: 41595_E82FE23CE1E416BDC81620E2CC93D73E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21917,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41595_E82FE23CE1E416BDC81620E2CC93D73E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41595_E82FE23CE1E416BDC81620E2CC93D73E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21935,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41595_E82FE23CE1E416BDC81620E2CC93D73E' AND m.source_system_id = 3;

-- Match: 30553_54316F9D801209115DDD731B4CDD6112
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30553_54316F9D801209115DDD731B4CDD6112' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30553_54316F9D801209115DDD731B4CDD6112' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30553_54316F9D801209115DDD731B4CDD6112' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '30553_54316F9D801209115DDD731B4CDD6112' AND m.source_system_id = 3;

-- Match: 30551_1C119A568868674A01B91ADF65940831
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30551_1C119A568868674A01B91ADF65940831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30551_1C119A568868674A01B91ADF65940831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30551_1C119A568868674A01B91ADF65940831' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21790,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '30551_1C119A568868674A01B91ADF65940831' AND m.source_system_id = 3;

-- Match: 30550_C44E6D473C6D439F81B20E157C436385
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30550_C44E6D473C6D439F81B20E157C436385' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22019,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '30550_C44E6D473C6D439F81B20E157C436385' AND m.source_system_id = 3;

-- Match: 41554_1F5688808559B37D0557101A5282377C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20279,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41554_1F5688808559B37D0557101A5282377C' AND m.source_system_id = 3;

-- Match: 41601_3F508A88715ECDC775B349B8AE872978
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20281,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41601_3F508A88715ECDC775B349B8AE872978' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20295,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41601_3F508A88715ECDC775B349B8AE872978' AND m.source_system_id = 3;

-- Match: 43743_4FEA45830A785CBED3BB5AD488E30341
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20004,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43743_4FEA45830A785CBED3BB5AD488E30341' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20042,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43743_4FEA45830A785CBED3BB5AD488E30341' AND m.source_system_id = 3;

-- Match: 43744_7275D30AFAF21D253D08EED45B49656B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20047,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20049,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20054,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20054,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20058,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20064,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43744_7275D30AFAF21D253D08EED45B49656B' AND m.source_system_id = 3;

-- Match: 42116_09439C56F250D71E2BEA02A76295881B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '42116_09439C56F250D71E2BEA02A76295881B' AND m.source_system_id = 3;

-- Match: 31463_804C40E1950DC316E23AC4703C372E6D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20635,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '31463_804C40E1950DC316E23AC4703C372E6D' AND m.source_system_id = 3;

-- Match: 41799_304B61071AE691E9127755EC2F75108B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21490,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41799_304B61071AE691E9127755EC2F75108B' AND m.source_system_id = 3;

-- Match: 40389_3D6F2E7E997FFC9CF9FC9614504402C9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22339,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '40389_3D6F2E7E997FFC9CF9FC9614504402C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22339,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '40389_3D6F2E7E997FFC9CF9FC9614504402C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22339,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '40389_3D6F2E7E997FFC9CF9FC9614504402C9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22344,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '40389_3D6F2E7E997FFC9CF9FC9614504402C9' AND m.source_system_id = 3;

-- Match: 40387_3E968F4EA504C89B21945CF656235B99
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21743,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40387_3E968F4EA504C89B21945CF656235B99' AND m.source_system_id = 3;

-- Match: 41804_CFF5F06C581E29ECE8C17EC9C0F42719
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20501,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41804_CFF5F06C581E29ECE8C17EC9C0F42719' AND m.source_system_id = 3;

-- Match: 31465_1CDE1991774E9E1EC880F83BEE6E44B6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21802,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31465_1CDE1991774E9E1EC880F83BEE6E44B6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21806,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31465_1CDE1991774E9E1EC880F83BEE6E44B6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21806,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31465_1CDE1991774E9E1EC880F83BEE6E44B6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31465_1CDE1991774E9E1EC880F83BEE6E44B6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31465_1CDE1991774E9E1EC880F83BEE6E44B6' AND m.source_system_id = 3;

-- Match: 41550_81BDFEE3C057F871C137FD437938E4B4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '41550_81BDFEE3C057F871C137FD437938E4B4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21280,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '41550_81BDFEE3C057F871C137FD437938E4B4' AND m.source_system_id = 3;

-- Match: 42119_636508DB11D522E6C3AE22C03322DA9C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21831,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42119_636508DB11D522E6C3AE22C03322DA9C' AND m.source_system_id = 3;

-- Match: 40388_62C1F4802E9B2C92712A1EF9FEFC78A9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20673,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
WHERE m.external_id = '40388_62C1F4802E9B2C92712A1EF9FEFC78A9' AND m.source_system_id = 3;

-- Match: 40386_42C93FF77E9FF65D10F2207B75FC7736
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21106,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40386_42C93FF77E9FF65D10F2207B75FC7736' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21107,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40386_42C93FF77E9FF65D10F2207B75FC7736' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21110,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40386_42C93FF77E9FF65D10F2207B75FC7736' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21115,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40386_42C93FF77E9FF65D10F2207B75FC7736' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40386_42C93FF77E9FF65D10F2207B75FC7736' AND m.source_system_id = 3;

-- Match: 41803_19D8714E0CDB0576C4D30335917BCF21
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20808,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41803_19D8714E0CDB0576C4D30335917BCF21' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20822,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41803_19D8714E0CDB0576C4D30335917BCF21' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20825,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41803_19D8714E0CDB0576C4D30335917BCF21' AND m.source_system_id = 3;

-- Match: 41761_0C724682B26FF9C6D29DA363FB4B006D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20923,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '41761_0C724682B26FF9C6D29DA363FB4B006D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '41761_0C724682B26FF9C6D29DA363FB4B006D' AND m.source_system_id = 3;

-- Match: 41800_CF42A41F50186A2B8B9B6CAB5BE8D904
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22438,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41800_CF42A41F50186A2B8B9B6CAB5BE8D904' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22440,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41800_CF42A41F50186A2B8B9B6CAB5BE8D904' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41800_CF42A41F50186A2B8B9B6CAB5BE8D904' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41800_CF42A41F50186A2B8B9B6CAB5BE8D904' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41800_CF42A41F50186A2B8B9B6CAB5BE8D904' AND m.source_system_id = 3;

-- Match: 41763_E8B284C0C935155BA847EE2E6356088E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41763_E8B284C0C935155BA847EE2E6356088E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21016,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41763_E8B284C0C935155BA847EE2E6356088E' AND m.source_system_id = 3;

-- Match: 31467_D28382AB4E3210227A17E2639611292A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '31467_D28382AB4E3210227A17E2639611292A' AND m.source_system_id = 3;

-- Match: 41552_3AE556115456DE39921B5231B6154CB5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41552_3AE556115456DE39921B5231B6154CB5' AND m.source_system_id = 3;

-- Match: 41599_6B2B254755291D7BF9F3D1775CE98AE8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41599_6B2B254755291D7BF9F3D1775CE98AE8' AND m.source_system_id = 3;

-- Match: 41975_AF2D2E51D403736C0B95B818B1EFC560
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41975_AF2D2E51D403736C0B95B818B1EFC560' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41975_AF2D2E51D403736C0B95B818B1EFC560' AND m.source_system_id = 3;

-- Match: 41553_25C53D592816F6B89336C083D16A3EF2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22281,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41553_25C53D592816F6B89336C083D16A3EF2' AND m.source_system_id = 3;

-- Match: 41762_4BBF50B41029C9782AA6DBBDE64CE370
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22185,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '41762_4BBF50B41029C9782AA6DBBDE64CE370' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '41762_4BBF50B41029C9782AA6DBBDE64CE370' AND m.source_system_id = 3;

-- Match: 41801_1F9AE93AE36F88221ACFEC3B476AAF4C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41801_1F9AE93AE36F88221ACFEC3B476AAF4C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21694,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41801_1F9AE93AE36F88221ACFEC3B476AAF4C' AND m.source_system_id = 3;

-- Match: 41806_CCB459DF7FB78541D892D867F3F32BAD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22418,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '41806_CCB459DF7FB78541D892D867F3F32BAD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22434,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '41806_CCB459DF7FB78541D892D867F3F32BAD' AND m.source_system_id = 3;

-- Match: 43742_D3ED8F6371192E620FD3CF2298845D45
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22624,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43742_D3ED8F6371192E620FD3CF2298845D45' AND m.source_system_id = 3;

-- Match: 42126_3B0375AC5B9A371116C564CF46C71A96
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21536,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
WHERE m.external_id = '42126_3B0375AC5B9A371116C564CF46C71A96' AND m.source_system_id = 3;

-- Match: 41766_CD568DD5DC975AE311AB01BC698F6FF6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
WHERE m.external_id = '41766_CD568DD5DC975AE311AB01BC698F6FF6' AND m.source_system_id = 3;

-- Match: 41767_7A7741B93B6EB8893695B2D41B373801
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21017,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41767_7A7741B93B6EB8893695B2D41B373801' AND m.source_system_id = 3;

-- Match: 41810_AE1A01D23C1FDC3ED50AF94267A59E4F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22234,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41810_AE1A01D23C1FDC3ED50AF94267A59E4F' AND m.source_system_id = 3;

-- Match: 43806_A56466AE7AFB25907803EC759CEC6871
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20002,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43806_A56466AE7AFB25907803EC759CEC6871' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43806_A56466AE7AFB25907803EC759CEC6871' AND m.source_system_id = 3;

-- Match: 43805_9277EDFB5422C73F8566E146234833DB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20046,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43805_9277EDFB5422C73F8566E146234833DB' AND m.source_system_id = 3;

-- Match: 43804_77F9A68263CC5390BE25311F37299A4B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22609,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43804_77F9A68263CC5390BE25311F37299A4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22625,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43804_77F9A68263CC5390BE25311F37299A4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22625,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43804_77F9A68263CC5390BE25311F37299A4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20053,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43804_77F9A68263CC5390BE25311F37299A4B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20055,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43804_77F9A68263CC5390BE25311F37299A4B' AND m.source_system_id = 3;

-- Match: 40395_2535F0465C08E0872C27AC5F59EF3B47
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40395_2535F0465C08E0872C27AC5F59EF3B47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40395_2535F0465C08E0872C27AC5F59EF3B47' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40395_2535F0465C08E0872C27AC5F59EF3B47' AND m.source_system_id = 3;

-- Match: 41811_139082D92A7C882FB577D9867EDE9DAF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41811_139082D92A7C882FB577D9867EDE9DAF' AND m.source_system_id = 3;

-- Match: 41558_7632C7027CCA269A614F8ECB7087ECAC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20269,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC' AND t.source_system_id = 3
WHERE m.external_id = '41558_7632C7027CCA269A614F8ECB7087ECAC' AND m.source_system_id = 3;

-- Match: 41605_56C27F7AB8CE383A5E7E4E66FE63341A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20295,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41605_56C27F7AB8CE383A5E7E4E66FE63341A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41605_56C27F7AB8CE383A5E7E4E66FE63341A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41605_56C27F7AB8CE383A5E7E4E66FE63341A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20268,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Borgetto FC II' AND t.source_system_id = 3
WHERE m.external_id = '41605_56C27F7AB8CE383A5E7E4E66FE63341A' AND m.source_system_id = 3;

-- Match: 41765_FA18E2B9CF7CEFC52B13D853FE1C04DF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20317,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '41765_FA18E2B9CF7CEFC52B13D853FE1C04DF' AND m.source_system_id = 3;

-- Match: 31469_EBBF3C57740D4F181A62E617C6A2F17D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '31469_EBBF3C57740D4F181A62E617C6A2F17D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '31469_EBBF3C57740D4F181A62E617C6A2F17D' AND m.source_system_id = 3;

-- Match: 41979_601BBF58806C4D84201FC82D86FFCB0C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41979_601BBF58806C4D84201FC82D86FFCB0C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21435,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41979_601BBF58806C4D84201FC82D86FFCB0C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22297,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41979_601BBF58806C4D84201FC82D86FFCB0C' AND m.source_system_id = 3;

-- Match: 40396_B87FF08F221384FC5C16A84D0300EF4D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40396_B87FF08F221384FC5C16A84D0300EF4D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20801,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40396_B87FF08F221384FC5C16A84D0300EF4D' AND m.source_system_id = 3;

-- Match: 41812_AACD9C68FDE35F233BEBC1F5C24DA80D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20812,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41812_AACD9C68FDE35F233BEBC1F5C24DA80D' AND m.source_system_id = 3;

-- Match: 41977_D9A8C5C16087E059FBB3BB64EB4D4F32
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22202,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '41977_D9A8C5C16087E059FBB3BB64EB4D4F32' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '41977_D9A8C5C16087E059FBB3BB64EB4D4F32' AND m.source_system_id = 3;

-- Match: 41559_B57503E979E572F4ADDC05C78E8B6452
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41559_B57503E979E572F4ADDC05C78E8B6452' AND m.source_system_id = 3;

-- Match: 41606_3A367D4B9905D157894B86C993463C60
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21917,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41606_3A367D4B9905D157894B86C993463C60' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41606_3A367D4B9905D157894B86C993463C60' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21937,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41606_3A367D4B9905D157894B86C993463C60' AND m.source_system_id = 3;

-- Match: 41604_7F92B6B1B61810A4287652AE04BFB728
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20977,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
WHERE m.external_id = '41604_7F92B6B1B61810A4287652AE04BFB728' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20982,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
WHERE m.external_id = '41604_7F92B6B1B61810A4287652AE04BFB728' AND m.source_system_id = 3;

-- Match: 41555_6EDBF45AF3453EEBBEBCA16948C031E7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41555_6EDBF45AF3453EEBBEBCA16948C031E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41555_6EDBF45AF3453EEBBEBCA16948C031E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41555_6EDBF45AF3453EEBBEBCA16948C031E7' AND m.source_system_id = 3;

-- Match: 41602_54AD990E89E7A2FE5A599521B44688EA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22324,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '41602_54AD990E89E7A2FE5A599521B44688EA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41602_54AD990E89E7A2FE5A599521B44688EA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21301,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41602_54AD990E89E7A2FE5A599521B44688EA' AND m.source_system_id = 3;

-- Match: 41981_5210DBC70B08527EF8622E2A204EBEAE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21698,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41981_5210DBC70B08527EF8622E2A204EBEAE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41981_5210DBC70B08527EF8622E2A204EBEAE' AND m.source_system_id = 3;

-- Match: 41807_9B01E04B7FEC4BB00F8FC2FD1EBB775E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41807_9B01E04B7FEC4BB00F8FC2FD1EBB775E' AND m.source_system_id = 3;

-- Match: 40397_0B7873AEBE63338BC9EB950C0069701A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21736,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21746,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21749,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22346,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC' AND t.source_system_id = 3
WHERE m.external_id = '40397_0B7873AEBE63338BC9EB950C0069701A' AND m.source_system_id = 3;

-- Match: 41813_9B7639FF7E477939E5A1F33F62AB3A50
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21773,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41813_9B7639FF7E477939E5A1F33F62AB3A50' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20142,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan FC II' AND t.source_system_id = 3
WHERE m.external_id = '41813_9B7639FF7E477939E5A1F33F62AB3A50' AND m.source_system_id = 3;

-- Match: 31472_32C28DF56279DDFCB75242B748B866E7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21783,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31472_32C28DF56279DDFCB75242B748B866E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21783,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31472_32C28DF56279DDFCB75242B748B866E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21785,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31472_32C28DF56279DDFCB75242B748B866E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31472_32C28DF56279DDFCB75242B748B866E7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '31472_32C28DF56279DDFCB75242B748B866E7' AND m.source_system_id = 3;

-- Match: 42123_96D465CFBD7297D1679D655DB34452CE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42123_96D465CFBD7297D1679D655DB34452CE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21831,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42123_96D465CFBD7297D1679D655DB34452CE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21831,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42123_96D465CFBD7297D1679D655DB34452CE' AND m.source_system_id = 3;

-- Match: 43809_166751F4C8A86C9B19C555A9CBAC2649
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20002,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43809_166751F4C8A86C9B19C555A9CBAC2649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20012,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43809_166751F4C8A86C9B19C555A9CBAC2649' AND m.source_system_id = 3;

-- Match: 43808_2893D10872957A4F727EB4CE2FF3A051
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20056,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43808_2893D10872957A4F727EB4CE2FF3A051' AND m.source_system_id = 3;

-- Match: 43807_9C61D32CD4B0636211BF95BD96113176
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22609,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43807_9C61D32CD4B0636211BF95BD96113176' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22622,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43807_9C61D32CD4B0636211BF95BD96113176' AND m.source_system_id = 3;

-- Match: 41862_54DEFC12DC055AFFEF520DDAD3F8C892
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20506,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41862_54DEFC12DC055AFFEF520DDAD3F8C892' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20506,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41862_54DEFC12DC055AFFEF520DDAD3F8C892' AND m.source_system_id = 3;

-- Match: 42135_800E64B11D44ED97E1F8BA0535136F22
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21817,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42135_800E64B11D44ED97E1F8BA0535136F22' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21817,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42135_800E64B11D44ED97E1F8BA0535136F22' AND m.source_system_id = 3;

-- Match: 41821_97D6E1B7B0339768580E20A5FC7D3B5D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21123,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41821_97D6E1B7B0339768580E20A5FC7D3B5D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41821_97D6E1B7B0339768580E20A5FC7D3B5D' AND m.source_system_id = 3;

-- Match: 43811_9F92E475395A0F0213948E0B7821C4BB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20051,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20053,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20056,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20056,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20058,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20064,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43811_9F92E475395A0F0213948E0B7821C4BB' AND m.source_system_id = 3;

-- Match: 43810_A73A3A1B69AAB4833C9B2C2EB9CC3DDD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20046,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43810_A73A3A1B69AAB4833C9B2C2EB9CC3DDD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22624,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43810_A73A3A1B69AAB4833C9B2C2EB9CC3DDD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22624,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
WHERE m.external_id = '43810_A73A3A1B69AAB4833C9B2C2EB9CC3DDD' AND m.source_system_id = 3;

-- Match: 42130_E9A87A4BAA8B83FAE384BA7BC6ACDD12
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42130_E9A87A4BAA8B83FAE384BA7BC6ACDD12' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42130_E9A87A4BAA8B83FAE384BA7BC6ACDD12' AND m.source_system_id = 3;

-- Match: 60205_29047E3FDF2BECD3AF4F75B2AA5A009F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20626,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60205_29047E3FDF2BECD3AF4F75B2AA5A009F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20635,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60205_29047E3FDF2BECD3AF4F75B2AA5A009F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60205_29047E3FDF2BECD3AF4F75B2AA5A009F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60205_29047E3FDF2BECD3AF4F75B2AA5A009F' AND m.source_system_id = 3;

-- Match: 40403_C2C211808EBC390D2ADA4CA5ADC4D180
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20227,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40403_C2C211808EBC390D2ADA4CA5ADC4D180' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20227,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40403_C2C211808EBC390D2ADA4CA5ADC4D180' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20227,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40403_C2C211808EBC390D2ADA4CA5ADC4D180' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20232,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40403_C2C211808EBC390D2ADA4CA5ADC4D180' AND m.source_system_id = 3;

-- Match: 41822_88950B19BFD800020BE34749A1E9B2EF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20236,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC II' AND t.source_system_id = 3
WHERE m.external_id = '41822_88950B19BFD800020BE34749A1E9B2EF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21770,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41822_88950B19BFD800020BE34749A1E9B2EF' AND m.source_system_id = 3;

-- Match: 41561_AD7260D90992A60C928BE3081B177CB2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21262,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '41561_AD7260D90992A60C928BE3081B177CB2' AND m.source_system_id = 3;

-- Match: 41771_F8C62ED804CC2D4390E3A129A9ADD7F0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20318,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '41771_F8C62ED804CC2D4390E3A129A9ADD7F0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20322,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '41771_F8C62ED804CC2D4390E3A129A9ADD7F0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20330,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Brooklyn City FC' AND t.source_system_id = 3
WHERE m.external_id = '41771_F8C62ED804CC2D4390E3A129A9ADD7F0' AND m.source_system_id = 3;

-- Match: 41819_F3F55D84FE2B8EA02A34D95BD2D17325
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41819_F3F55D84FE2B8EA02A34D95BD2D17325' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41819_F3F55D84FE2B8EA02A34D95BD2D17325' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41819_F3F55D84FE2B8EA02A34D95BD2D17325' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20520,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41819_F3F55D84FE2B8EA02A34D95BD2D17325' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20523,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41819_F3F55D84FE2B8EA02A34D95BD2D17325' AND m.source_system_id = 3;

-- Match: 41560_3FE28AF8F8629358F72842B35AFB1C3C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41560_3FE28AF8F8629358F72842B35AFB1C3C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41560_3FE28AF8F8629358F72842B35AFB1C3C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21911,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41560_3FE28AF8F8629358F72842B35AFB1C3C' AND m.source_system_id = 3;

-- Match: 41985_4E3B8CCD1081468B8328FB8390D786BA
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22201,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '41985_4E3B8CCD1081468B8328FB8390D786BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22209,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '41985_4E3B8CCD1081468B8328FB8390D786BA' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '41985_4E3B8CCD1081468B8328FB8390D786BA' AND m.source_system_id = 3;

-- Match: 41820_EA24BC4BC2EE335D22F658D712E8A3EB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22527,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'CD Iberia II' AND t.source_system_id = 3
WHERE m.external_id = '41820_EA24BC4BC2EE335D22F658D712E8A3EB' AND m.source_system_id = 3;

-- Match: 41986_4DDC0E2BDE1058D3CBB54F33917B647F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41986_4DDC0E2BDE1058D3CBB54F33917B647F' AND m.source_system_id = 3;

-- Match: 41768_42D823E82FBBAF41728EBA0EF44D0063
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21012,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41768_42D823E82FBBAF41728EBA0EF44D0063' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41768_42D823E82FBBAF41728EBA0EF44D0063' AND m.source_system_id = 3;

-- Match: 41815_7548A321E580D9499C6490376E437F60
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20937,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '41815_7548A321E580D9499C6490376E437F60' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20946,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '41815_7548A321E580D9499C6490376E437F60' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20947,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '41815_7548A321E580D9499C6490376E437F60' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20947,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
WHERE m.external_id = '41815_7548A321E580D9499C6490376E437F60' AND m.source_system_id = 3;

-- Match: 60131_9B16853A62BC9FBCE1A20BECC0A6A7AB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21793,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21793,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21793,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21801,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60131_9B16853A62BC9FBCE1A20BECC0A6A7AB' AND m.source_system_id = 3;

-- Match: 42134_D9452C48CBDF8DEE421231C4C77C8852
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21332,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21334,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21334,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '42134_D9452C48CBDF8DEE421231C4C77C8852' AND m.source_system_id = 3;

-- Match: 41770_E8526F9739FE767CD62C7F848756278B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41770_E8526F9739FE767CD62C7F848756278B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41770_E8526F9739FE767CD62C7F848756278B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41770_E8526F9739FE767CD62C7F848756278B' AND m.source_system_id = 3;

-- Match: 41817_3AA03902B4CBF991A7C0FAE16B5C1DBE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41817_3AA03902B4CBF991A7C0FAE16B5C1DBE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41817_3AA03902B4CBF991A7C0FAE16B5C1DBE' AND m.source_system_id = 3;

-- Match: 41816_C4746C452050E663C5CDEA782F0B8D18
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21688,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41816_C4746C452050E663C5CDEA782F0B8D18' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21688,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41816_C4746C452050E663C5CDEA782F0B8D18' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21688,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41816_C4746C452050E663C5CDEA782F0B8D18' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41816_C4746C452050E663C5CDEA782F0B8D18' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21693,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41816_C4746C452050E663C5CDEA782F0B8D18' AND m.source_system_id = 3;

-- Match: 60203_B2680021326EE33E0A1C45B3AFBDB8A9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60203_B2680021326EE33E0A1C45B3AFBDB8A9' AND m.source_system_id = 3;

-- Match: 42170_1C740B7737D460D5B7E3E8B869E5079A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42170_1C740B7737D460D5B7E3E8B869E5079A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21335,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42170_1C740B7737D460D5B7E3E8B869E5079A' AND m.source_system_id = 3;

-- Match: 40427_2964F1778664D18EBE66AA4731F6B140
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20225,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40427_2964F1778664D18EBE66AA4731F6B140' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20227,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40427_2964F1778664D18EBE66AA4731F6B140' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20227,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Block FC' AND t.source_system_id = 3
WHERE m.external_id = '40427_2964F1778664D18EBE66AA4731F6B140' AND m.source_system_id = 3;

-- Match: 41826_0441895A68A54964AB0BD1CCA642ED26
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22440,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41826_0441895A68A54964AB0BD1CCA642ED26' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41826_0441895A68A54964AB0BD1CCA642ED26' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41826_0441895A68A54964AB0BD1CCA642ED26' AND m.source_system_id = 3;

-- Match: 43813_53069B435E5DBE9949355576E7D0B4F1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20004,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43813_53069B435E5DBE9949355576E7D0B4F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20008,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43813_53069B435E5DBE9949355576E7D0B4F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20009,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43813_53069B435E5DBE9949355576E7D0B4F1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20024,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43813_53069B435E5DBE9949355576E7D0B4F1' AND m.source_system_id = 3;

-- Match: 43814_3B324795D7B3F41C45CF4C3E2607F649
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20031,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20031,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20043,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20043,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20046,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43814_3B324795D7B3F41C45CF4C3E2607F649' AND m.source_system_id = 3;

-- Match: 43815_A27B1157BC62CBE09EE6A0749C5D0242
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20049,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43815_A27B1157BC62CBE09EE6A0749C5D0242' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20051,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43815_A27B1157BC62CBE09EE6A0749C5D0242' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20054,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43815_A27B1157BC62CBE09EE6A0749C5D0242' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20064,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43815_A27B1157BC62CBE09EE6A0749C5D0242' AND m.source_system_id = 3;

-- Match: 42137_B09AA1BC306FAB66DF571B6186DDD750
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21323,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42137_B09AA1BC306FAB66DF571B6186DDD750' AND m.source_system_id = 3;

-- Match: 60380_9D0E0B5438782944EB5135CC119F71B0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60380_9D0E0B5438782944EB5135CC119F71B0' AND m.source_system_id = 3;

-- Match: 41988_9333DE9FFD6CEC0D2C6A7D542CB5DB6B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41988_9333DE9FFD6CEC0D2C6A7D542CB5DB6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41988_9333DE9FFD6CEC0D2C6A7D542CB5DB6B' AND m.source_system_id = 3;

-- Match: 40430_082D636810DA7B14B328AAC5E3ADD71C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21743,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40430_082D636810DA7B14B328AAC5E3ADD71C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40430_082D636810DA7B14B328AAC5E3ADD71C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40430_082D636810DA7B14B328AAC5E3ADD71C' AND m.source_system_id = 3;

-- Match: 41830_5F1126600B594A1C50FDA4779BAF992A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21768,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41830_5F1126600B594A1C50FDA4779BAF992A' AND m.source_system_id = 3;

-- Match: 41990_9E26F0257A8B61A892FC49C72DF3CECF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41990_9E26F0257A8B61A892FC49C72DF3CECF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41990_9E26F0257A8B61A892FC49C72DF3CECF' AND m.source_system_id = 3;

-- Match: 40429_F470CE01B4F3D58E85B6C7562293CFD4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21107,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40429_F470CE01B4F3D58E85B6C7562293CFD4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21107,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40429_F470CE01B4F3D58E85B6C7562293CFD4' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21116,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40429_F470CE01B4F3D58E85B6C7562293CFD4' AND m.source_system_id = 3;

-- Match: 41568_A2253ABA1787A487A589184116F7ACD3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41568_A2253ABA1787A487A589184116F7ACD3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41568_A2253ABA1787A487A589184116F7ACD3' AND m.source_system_id = 3;

-- Match: 41567_6B5CD3043422E415D42982FEACF6512B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '41567_6B5CD3043422E415D42982FEACF6512B' AND m.source_system_id = 3;

-- Match: 41772_AF5E31E4B6F661EBDCB179129B02A22C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41772_AF5E31E4B6F661EBDCB179129B02A22C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21458,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41772_AF5E31E4B6F661EBDCB179129B02A22C' AND m.source_system_id = 3;

-- Match: 41823_FDB920E78F289A1CFF8A60627265E5C2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21490,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41823_FDB920E78F289A1CFF8A60627265E5C2' AND m.source_system_id = 3;

-- Match: 41565_5F79506BB3697B989472F349BE3AB24E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41565_5F79506BB3697B989472F349BE3AB24E' AND m.source_system_id = 3;

-- Match: 41991_751E4986D40F41ABF0D05F6E665139A6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '41991_751E4986D40F41ABF0D05F6E665139A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '41991_751E4986D40F41ABF0D05F6E665139A6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '41991_751E4986D40F41ABF0D05F6E665139A6' AND m.source_system_id = 3;

-- Match: 40402_C704AD2C02EDEB684F273198AEAAB794
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21094,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40402_C704AD2C02EDEB684F273198AEAAB794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40402_C704AD2C02EDEB684F273198AEAAB794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40402_C704AD2C02EDEB684F273198AEAAB794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40402_C704AD2C02EDEB684F273198AEAAB794' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21122,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40402_C704AD2C02EDEB684F273198AEAAB794' AND m.source_system_id = 3;

-- Match: 41836_FF312410F5863748D4960DC832C189CD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20808,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41836_FF312410F5863748D4960DC832C189CD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20822,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41836_FF312410F5863748D4960DC832C189CD' AND m.source_system_id = 3;

-- Match: 43817_51DF6CB08C3278C8135F7D1BB6156948
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20049,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43817_51DF6CB08C3278C8135F7D1BB6156948' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20069,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43817_51DF6CB08C3278C8135F7D1BB6156948' AND m.source_system_id = 3;

-- Match: 43816_6B92C85C5FAD59AE0A81B0738EC90DA9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20031,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20031,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20031,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20045,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20045,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43816_6B92C85C5FAD59AE0A81B0738EC90DA9' AND m.source_system_id = 3;

-- Match: 40434_042C9D5BE75A296E7EEA9FA412654598
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21732,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40434_042C9D5BE75A296E7EEA9FA412654598' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40434_042C9D5BE75A296E7EEA9FA412654598' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21740,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40434_042C9D5BE75A296E7EEA9FA412654598' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40434_042C9D5BE75A296E7EEA9FA412654598' AND m.source_system_id = 3;

-- Match: 40432_9C26E023D0FBC124FC4BAADDEDC9E27A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21096,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40432_9C26E023D0FBC124FC4BAADDEDC9E27A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21101,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40432_9C26E023D0FBC124FC4BAADDEDC9E27A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40432_9C26E023D0FBC124FC4BAADDEDC9E27A' AND m.source_system_id = 3;

-- Match: 60135_ED8F03481DCC12842586EBE276EB68A1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21787,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60135_ED8F03481DCC12842586EBE276EB68A1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60135_ED8F03481DCC12842586EBE276EB68A1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60135_ED8F03481DCC12842586EBE276EB68A1' AND m.source_system_id = 3;

-- Match: 41835_8F2AC5C98459A1AA716695D08512934D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41835_8F2AC5C98459A1AA716695D08512934D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41835_8F2AC5C98459A1AA716695D08512934D' AND m.source_system_id = 3;

-- Match: 41993_2013E55B11C7202A2CC181C9F681CB67
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41993_2013E55B11C7202A2CC181C9F681CB67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41993_2013E55B11C7202A2CC181C9F681CB67' AND m.source_system_id = 3;

-- Match: 41570_F91B7CF8F8B0FB0FCF04C03A422C03B7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41570_F91B7CF8F8B0FB0FCF04C03A422C03B7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41570_F91B7CF8F8B0FB0FCF04C03A422C03B7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22284,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41570_F91B7CF8F8B0FB0FCF04C03A422C03B7' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22294,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41570_F91B7CF8F8B0FB0FCF04C03A422C03B7' AND m.source_system_id = 3;

-- Match: 41574_B748E91BB33D9355726ADBB82C4ABAEF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '41574_B748E91BB33D9355726ADBB82C4ABAEF' AND m.source_system_id = 3;

-- Match: 41621_CD7E9410CD302B662D46E805854B5FBE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41621_CD7E9410CD302B662D46E805854B5FBE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41621_CD7E9410CD302B662D46E805854B5FBE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21294,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41621_CD7E9410CD302B662D46E805854B5FBE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41621_CD7E9410CD302B662D46E805854B5FBE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21937,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41621_CD7E9410CD302B662D46E805854B5FBE' AND m.source_system_id = 3;

-- Match: 41777_8932E95A30E0EEF8EA991FBC932E8A5B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21476,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41777_8932E95A30E0EEF8EA991FBC932E8A5B' AND m.source_system_id = 3;

-- Match: 41832_73B522C7C7B0FB9FCD61609998C82C1E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41832_73B522C7C7B0FB9FCD61609998C82C1E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41832_73B522C7C7B0FB9FCD61609998C82C1E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41832_73B522C7C7B0FB9FCD61609998C82C1E' AND m.source_system_id = 3;

-- Match: 60385_ADC3B87BD80B5126147E30CFC2AE132D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22011,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60385_ADC3B87BD80B5126147E30CFC2AE132D' AND m.source_system_id = 3;

-- Match: 41994_938AA46938B876FFABE6322E9D804E39
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21697,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41994_938AA46938B876FFABE6322E9D804E39' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21707,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41994_938AA46938B876FFABE6322E9D804E39' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41994_938AA46938B876FFABE6322E9D804E39' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41994_938AA46938B876FFABE6322E9D804E39' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '41994_938AA46938B876FFABE6322E9D804E39' AND m.source_system_id = 3;

-- Match: 41833_13D45141325008B9E4B033045408628D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22442,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41833_13D45141325008B9E4B033045408628D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22444,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41833_13D45141325008B9E4B033045408628D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41833_13D45141325008B9E4B033045408628D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22455,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41833_13D45141325008B9E4B033045408628D' AND m.source_system_id = 3;

-- Match: 40440_C7C34A838E23D045CE41E9F64103648B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20795,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40440_C7C34A838E23D045CE41E9F64103648B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40440_C7C34A838E23D045CE41E9F64103648B' AND m.source_system_id = 3;

-- Match: 41846_A042174D8FF611175060E6855C1EB4AB
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20829,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20505,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20510,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41846_A042174D8FF611175060E6855C1EB4AB' AND m.source_system_id = 3;

-- Match: 40437_1EBF611498C68796DDBBFF59DAF63E64
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21121,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40437_1EBF611498C68796DDBBFF59DAF63E64' AND m.source_system_id = 3;

-- Match: 41843_1DE168AD3192A7340D277143B670CA9D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21143,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41843_1DE168AD3192A7340D277143B670CA9D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21150,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41843_1DE168AD3192A7340D277143B670CA9D' AND m.source_system_id = 3;

-- Match: 43821_9C25E7D248E87073CB66EDF844706A3D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43821_9C25E7D248E87073CB66EDF844706A3D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20024,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43821_9C25E7D248E87073CB66EDF844706A3D' AND m.source_system_id = 3;

-- Match: 43820_7068752922D9E8D2AFF9ADA624135E5E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43820_7068752922D9E8D2AFF9ADA624135E5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20049,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43820_7068752922D9E8D2AFF9ADA624135E5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20054,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43820_7068752922D9E8D2AFF9ADA624135E5E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20058,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43820_7068752922D9E8D2AFF9ADA624135E5E' AND m.source_system_id = 3;

-- Match: 42153_FD9945A4CEA8943E6D2C41BBE21AB3C5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '42153_FD9945A4CEA8943E6D2C41BBE21AB3C5' AND m.source_system_id = 3;

-- Match: 60390_BE595C05ED6D6B2DAF80859E8A7AD80D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20635,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20635,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20648,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21994,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60390_BE595C05ED6D6B2DAF80859E8A7AD80D' AND m.source_system_id = 3;

-- Match: 41781_06C61B3F8A721E24757AAC2428BC94F5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21008,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
WHERE m.external_id = '41781_06C61B3F8A721E24757AAC2428BC94F5' AND m.source_system_id = 3;

-- Match: 41578_8EE10801CAC662C67F29592B07B4F8C8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21197,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41578_8EE10801CAC662C67F29592B07B4F8C8' AND m.source_system_id = 3;

-- Match: 41998_32290786F5A1389984658EA3E86D7A09
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21431,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '41998_32290786F5A1389984658EA3E86D7A09' AND m.source_system_id = 3;

-- Match: 41783_353D41A51550EC4F23293684BBC94F6B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41783_353D41A51550EC4F23293684BBC94F6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21453,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41783_353D41A51550EC4F23293684BBC94F6B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21460,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41783_353D41A51550EC4F23293684BBC94F6B' AND m.source_system_id = 3;

-- Match: 41842_F4DBCE28E96FD236DFFF07D6CF6D87B3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41842_F4DBCE28E96FD236DFFF07D6CF6D87B3' AND m.source_system_id = 3;

-- Match: 41840_29B1F68250FC55E0C020DE15A036CB19
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21693,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41840_29B1F68250FC55E0C020DE15A036CB19' AND m.source_system_id = 3;

-- Match: 41782_532C5516BA2F8BE41546812BD993BE23
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22254,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '41782_532C5516BA2F8BE41546812BD993BE23' AND m.source_system_id = 3;

-- Match: 41865_061A78C6176E6DE95A27109CB9558F70
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41865_061A78C6176E6DE95A27109CB9558F70' AND m.source_system_id = 3;

-- Match: 43822_CA107CDD2905F7CC3DB83D40B0511A9D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20051,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43822_CA107CDD2905F7CC3DB83D40B0511A9D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20051,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43822_CA107CDD2905F7CC3DB83D40B0511A9D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20056,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43822_CA107CDD2905F7CC3DB83D40B0511A9D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20056,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43822_CA107CDD2905F7CC3DB83D40B0511A9D' AND m.source_system_id = 3;

-- Match: 40452_DCE523463EC5CE8ED3069D8092A79D7F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40452_DCE523463EC5CE8ED3069D8092A79D7F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40452_DCE523463EC5CE8ED3069D8092A79D7F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20807,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan' AND t.source_system_id = 3
WHERE m.external_id = '40452_DCE523463EC5CE8ED3069D8092A79D7F' AND m.source_system_id = 3;

-- Match: 41854_9DC85F85AA0D4B60FD8B6183FE2F843C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20812,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41854_9DC85F85AA0D4B60FD8B6183FE2F843C' AND m.source_system_id = 3;

-- Match: 41852_07864D83B7860084F74B0D45F8BFF432
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21128,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41852_07864D83B7860084F74B0D45F8BFF432' AND m.source_system_id = 3;

-- Match: 43824_4E18346663948B1DC0B5961148120DB5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20002,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43824_4E18346663948B1DC0B5961148120DB5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20023,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43824_4E18346663948B1DC0B5961148120DB5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20024,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43824_4E18346663948B1DC0B5961148120DB5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20024,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43824_4E18346663948B1DC0B5961148120DB5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20024,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43824_4E18346663948B1DC0B5961148120DB5' AND m.source_system_id = 3;

-- Match: 43823_4A5CDBF027E0304565792B0E2F39FA11
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20029,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Astoria Knights II' AND t.source_system_id = 3
WHERE m.external_id = '43823_4A5CDBF027E0304565792B0E2F39FA11' AND m.source_system_id = 3;

-- Match: 42158_2565F8BA42663C465C9B47E6E5DF39C4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42158_2565F8BA42663C465C9B47E6E5DF39C4' AND m.source_system_id = 3;

-- Match: 41851_037D258BC62E0C95AFC6BD7BACB021AE
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41851_037D258BC62E0C95AFC6BD7BACB021AE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20506,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41851_037D258BC62E0C95AFC6BD7BACB021AE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20506,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41851_037D258BC62E0C95AFC6BD7BACB021AE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41851_037D258BC62E0C95AFC6BD7BACB021AE' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20518,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41851_037D258BC62E0C95AFC6BD7BACB021AE' AND m.source_system_id = 3;

-- Match: 41785_FDDB4ABD756046298B133AADC1A379DD
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22254,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '41785_FDDB4ABD756046298B133AADC1A379DD' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22265,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC' AND t.source_system_id = 3
WHERE m.external_id = '41785_FDDB4ABD756046298B133AADC1A379DD' AND m.source_system_id = 3;

-- Match: 41848_B4A56150C3550E6B2AF93C72DB1AD461
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22440,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Yemen United SC II' AND t.source_system_id = 3
WHERE m.external_id = '41848_B4A56150C3550E6B2AF93C72DB1AD461' AND m.source_system_id = 3;

-- Match: 42002_3A53FF472D87990F8820BCEEC1B5CD4F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '42002_3A53FF472D87990F8820BCEEC1B5CD4F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '42002_3A53FF472D87990F8820BCEEC1B5CD4F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21718,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
WHERE m.external_id = '42002_3A53FF472D87990F8820BCEEC1B5CD4F' AND m.source_system_id = 3;

-- Match: 41580_D16CAC0B14DAAA514FF48DED7CE36E89
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21185,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '41580_D16CAC0B14DAAA514FF48DED7CE36E89' AND m.source_system_id = 3;

-- Match: 60395_1BE5A978E5A78B1CA6042FBB0CE7CF96
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20627,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60395_1BE5A978E5A78B1CA6042FBB0CE7CF96' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20639,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60395_1BE5A978E5A78B1CA6042FBB0CE7CF96' AND m.source_system_id = 3;

-- Match: 41853_0AF83F64881510CD3AD5030FC4261EB1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21766,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41853_0AF83F64881510CD3AD5030FC4261EB1' AND m.source_system_id = 3;

-- Match: 41631_82B305CAE8B506AC9D879281100B5619
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41631_82B305CAE8B506AC9D879281100B5619' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21290,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41631_82B305CAE8B506AC9D879281100B5619' AND m.source_system_id = 3;

-- Match: 41786_DA00F019CB98B8237852C880D40FC2C4
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21476,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41786_DA00F019CB98B8237852C880D40FC2C4' AND m.source_system_id = 3;

-- Match: 42003_731710B35159CFC3CED607AE6A4C54C2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21445,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42003_731710B35159CFC3CED607AE6A4C54C2' AND m.source_system_id = 3;

-- Match: 41849_5E94A821754F8F085C2694E67031B1D0
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21504,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41849_5E94A821754F8F085C2694E67031B1D0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21504,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41849_5E94A821754F8F085C2694E67031B1D0' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21504,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41849_5E94A821754F8F085C2694E67031B1D0' AND m.source_system_id = 3;

-- Match: 60392_C776E6D76DF499AFB3E4E322BD827E8E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60392_C776E6D76DF499AFB3E4E322BD827E8E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60392_C776E6D76DF499AFB3E4E322BD827E8E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60392_C776E6D76DF499AFB3E4E322BD827E8E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22005,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60392_C776E6D76DF499AFB3E4E322BD827E8E' AND m.source_system_id = 3;

-- Match: 41847_745BD67F7E7647A082E8AE5CC2F3A658
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41847_745BD67F7E7647A082E8AE5CC2F3A658' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41847_745BD67F7E7647A082E8AE5CC2F3A658' AND m.source_system_id = 3;

-- Match: 60140_8175D1E578F567D6213655CEC9147269
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21784,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21803,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21804,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '60140_8175D1E578F567D6213655CEC9147269' AND m.source_system_id = 3;

-- Match: 41581_B1869DC16CC3FC0BBEA30DE7371F574F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21894,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41581_B1869DC16CC3FC0BBEA30DE7371F574F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41581_B1869DC16CC3FC0BBEA30DE7371F574F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41581_B1869DC16CC3FC0BBEA30DE7371F574F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41581_B1869DC16CC3FC0BBEA30DE7371F574F' AND m.source_system_id = 3;

-- Match: 41628_CC06BD59E4C1D9EFD9F7C0A65E270E26
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21933,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41628_CC06BD59E4C1D9EFD9F7C0A65E270E26' AND m.source_system_id = 3;

-- Match: 41579_6DD2EBE770EC64CB805B9CEF40FFB351
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21889,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41579_6DD2EBE770EC64CB805B9CEF40FFB351' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41579_6DD2EBE770EC64CB805B9CEF40FFB351' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21911,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41579_6DD2EBE770EC64CB805B9CEF40FFB351' AND m.source_system_id = 3;

-- Match: 42151_7778F1F8DD89FC0CD9095A61FFC5C429
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42151_7778F1F8DD89FC0CD9095A61FFC5C429' AND m.source_system_id = 3;

-- Match: 60381_6FDB4098141A5FF8F0155DE0AA70E91E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20629,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Cozmoz FC' AND t.source_system_id = 3
WHERE m.external_id = '60381_6FDB4098141A5FF8F0155DE0AA70E91E' AND m.source_system_id = 3;

-- Match: 41791_DEFD7BB7BA7E4AE8D1855FBA9F3E266E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '41791_DEFD7BB7BA7E4AE8D1855FBA9F3E266E' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22188,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC' AND t.source_system_id = 3
WHERE m.external_id = '41791_DEFD7BB7BA7E4AE8D1855FBA9F3E266E' AND m.source_system_id = 3;

-- Match: 41858_89EE20F4EEFA3C6359F70826EA82BE02
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22230,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41858_89EE20F4EEFA3C6359F70826EA82BE02' AND m.source_system_id = 3;

-- Match: 42007_FBBFCFE0A52DB719B2662940FEE37644
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42007_FBBFCFE0A52DB719B2662940FEE37644' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42007_FBBFCFE0A52DB719B2662940FEE37644' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20692,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42007_FBBFCFE0A52DB719B2662940FEE37644' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21436,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42007_FBBFCFE0A52DB719B2662940FEE37644' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21450,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42007_FBBFCFE0A52DB719B2662940FEE37644' AND m.source_system_id = 3;

-- Match: 43827_F062C5433AE335908B9D3668010F4C0E
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20060,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43827_F062C5433AE335908B9D3668010F4C0E' AND m.source_system_id = 3;

-- Match: 42163_6B6BFE354CDC98EF69D5F54E6516878D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42163_6B6BFE354CDC98EF69D5F54E6516878D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21316,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Albanians FC' AND t.source_system_id = 3
WHERE m.external_id = '42163_6B6BFE354CDC98EF69D5F54E6516878D' AND m.source_system_id = 3;

-- Match: 42169_C35420D58F3D04AFA1D215FEF739702B
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42169_C35420D58F3D04AFA1D215FEF739702B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21809,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42169_C35420D58F3D04AFA1D215FEF739702B' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21817,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Panatha USA' AND t.source_system_id = 3
WHERE m.external_id = '42169_C35420D58F3D04AFA1D215FEF739702B' AND m.source_system_id = 3;

-- Match: 41860_3DCA70A1961210747D5F435C594B84C5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20833,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'FC Japan II' AND t.source_system_id = 3
WHERE m.external_id = '41860_3DCA70A1961210747D5F435C594B84C5' AND m.source_system_id = 3;

-- Match: 41587_51B4052E2136165E0238D32375AD3AEF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22277,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
WHERE m.external_id = '41587_51B4052E2136165E0238D32375AD3AEF' AND m.source_system_id = 3;

-- Match: 41855_12D58B4D07D5AF9BC7A2E99E38E023C7
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21671,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '41855_12D58B4D07D5AF9BC7A2E99E38E023C7' AND m.source_system_id = 3;

-- Match: 40456_8C16BF5E88E017CBC4E4EC7D332B292A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21107,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40456_8C16BF5E88E017CBC4E4EC7D332B292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21116,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40456_8C16BF5E88E017CBC4E4EC7D332B292A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21116,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
WHERE m.external_id = '40456_8C16BF5E88E017CBC4E4EC7D332B292A' AND m.source_system_id = 3;

-- Match: 41859_68C395C41F1A8C87F9C8E26FECC188D6
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21756,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41859_68C395C41F1A8C87F9C8E26FECC188D6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21756,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41859_68C395C41F1A8C87F9C8E26FECC188D6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21767,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41859_68C395C41F1A8C87F9C8E26FECC188D6' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21151,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
WHERE m.external_id = '41859_68C395C41F1A8C87F9C8E26FECC188D6' AND m.source_system_id = 3;

-- Match: 41588_277602167A590B71ED775EF6D126D9E3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21909,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '41588_277602167A590B71ED775EF6D126D9E3' AND m.source_system_id = 3;

-- Match: 42008_B3C41D58D02B046D23002E5CCCC5C142
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22201,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42008_B3C41D58D02B046D23002E5CCCC5C142' AND m.source_system_id = 3;

-- Match: 41626_3833BB50033AE3B2C93CA46628590AC8
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21918,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41626_3833BB50033AE3B2C93CA46628590AC8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41626_3833BB50033AE3B2C93CA46628590AC8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21935,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41626_3833BB50033AE3B2C93CA46628590AC8' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21937,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41626_3833BB50033AE3B2C93CA46628590AC8' AND m.source_system_id = 3;

-- Match: 43829_AE7F54B8AAB90B5FEC1CEFA386496CF2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43829_AE7F54B8AAB90B5FEC1CEFA386496CF2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20015,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43829_AE7F54B8AAB90B5FEC1CEFA386496CF2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20028,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Riverside Squires' AND t.source_system_id = 3
WHERE m.external_id = '43829_AE7F54B8AAB90B5FEC1CEFA386496CF2' AND m.source_system_id = 3;

-- Match: 42013_186F1408D434EF47E397ACA0529D6893
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42013_186F1408D434EF47E397ACA0529D6893' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21430,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Galicia' AND t.source_system_id = 3
WHERE m.external_id = '42013_186F1408D434EF47E397ACA0529D6893' AND m.source_system_id = 3;

-- Match: 42175_3B8E488108A92E5B6C93165B5AB4ACE9
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22376,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Legacy FC' AND t.source_system_id = 3
WHERE m.external_id = '42175_3B8E488108A92E5B6C93165B5AB4ACE9' AND m.source_system_id = 3;

-- Match: 43830_028A20F05AEF51A048E90EBC14D6C8D2
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20048,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43830_028A20F05AEF51A048E90EBC14D6C8D2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20049,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43830_028A20F05AEF51A048E90EBC14D6C8D2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20051,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43830_028A20F05AEF51A048E90EBC14D6C8D2' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20053,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Caribbean FCA' AND t.source_system_id = 3
WHERE m.external_id = '43830_028A20F05AEF51A048E90EBC14D6C8D2' AND m.source_system_id = 3;

-- Match: 41869_24FF5E34FEC8775FC116886868527FCC
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41869_24FF5E34FEC8775FC116886868527FCC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20506,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41869_24FF5E34FEC8775FC116886868527FCC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20507,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41869_24FF5E34FEC8775FC116886868527FCC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20520,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41869_24FF5E34FEC8775FC116886868527FCC' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  20526,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
WHERE m.external_id = '41869_24FF5E34FEC8775FC116886868527FCC' AND m.source_system_id = 3;

-- Match: 42174_A463E9AC522C83F07D34D68E78D5B2B3
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21041,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
WHERE m.external_id = '42174_A463E9AC522C83F07D34D68E78D5B2B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21041,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
WHERE m.external_id = '42174_A463E9AC522C83F07D34D68E78D5B2B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21041,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
WHERE m.external_id = '42174_A463E9AC522C83F07D34D68E78D5B2B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21041,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
WHERE m.external_id = '42174_A463E9AC522C83F07D34D68E78D5B2B3' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21041,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Laberia FC' AND t.source_system_id = 3
WHERE m.external_id = '42174_A463E9AC522C83F07D34D68E78D5B2B3' AND m.source_system_id = 3;

-- Match: 42014_FF2FBCA2A77B1DA3C2D8F81DE5948CEF
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22212,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42014_FF2FBCA2A77B1DA3C2D8F81DE5948CEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42014_FF2FBCA2A77B1DA3C2D8F81DE5948CEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42014_FF2FBCA2A77B1DA3C2D8F81DE5948CEF' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22217,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
WHERE m.external_id = '42014_FF2FBCA2A77B1DA3C2D8F81DE5948CEF' AND m.source_system_id = 3;

-- Match: 29449_3E0A7E17875308B973F238CB0217B678
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21185,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29449_3E0A7E17875308B973F238CB0217B678' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21187,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29449_3E0A7E17875308B973F238CB0217B678' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21193,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29449_3E0A7E17875308B973F238CB0217B678' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21195,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers' AND t.source_system_id = 3
WHERE m.external_id = '29449_3E0A7E17875308B973F238CB0217B678' AND m.source_system_id = 3;

-- Match: 71096_F7B4D93ACA9B9644B50CAADA877EF837
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21210,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21222,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
WHERE m.external_id = '71096_F7B4D93ACA9B9644B50CAADA877EF837' AND m.source_system_id = 3;

-- Match: 41640_E130B2FB75BC9358251C608F77B6E0F1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41640_E130B2FB75BC9358251C608F77B6E0F1' AND m.source_system_id = 3;

-- Match: 41795_F8AD8F625CC960FF4AC534F1D92D3F29
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21458,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41795_F8AD8F625CC960FF4AC534F1D92D3F29' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21467,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41795_F8AD8F625CC960FF4AC534F1D92D3F29' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21476,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC' AND t.source_system_id = 3
WHERE m.external_id = '41795_F8AD8F625CC960FF4AC534F1D92D3F29' AND m.source_system_id = 3;

-- Match: 41866_018DDB9A7E762FB495F80833F1D8642A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21496,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41866_018DDB9A7E762FB495F80833F1D8642A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21503,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY International FC II' AND t.source_system_id = 3
WHERE m.external_id = '41866_018DDB9A7E762FB495F80833F1D8642A' AND m.source_system_id = 3;

-- Match: 40463_1B553DDD7575C47B1C405492BBA8F381
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21737,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40463_1B553DDD7575C47B1C405492BBA8F381' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21744,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40463_1B553DDD7575C47B1C405492BBA8F381' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21749,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40463_1B553DDD7575C47B1C405492BBA8F381' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40463_1B553DDD7575C47B1C405492BBA8F381' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21750,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC' AND t.source_system_id = 3
WHERE m.external_id = '40463_1B553DDD7575C47B1C405492BBA8F381' AND m.source_system_id = 3;

-- Match: 41870_E6897858ADCE52F2930437A841CB5F67
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21752,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21756,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21756,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21759,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21762,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21776,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21776,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC II' AND t.source_system_id = 3
WHERE m.external_id = '41870_E6897858ADCE52F2930437A841CB5F67' AND m.source_system_id = 3;

-- Match: 29450_22FC8DCA682BFC3F628196DD672A6C14
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21906,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC' AND t.source_system_id = 3
WHERE m.external_id = '29450_22FC8DCA682BFC3F628196DD672A6C14' AND m.source_system_id = 3;

-- Match: 41641_D310552B5377995ED83B0486922C6D3C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21925,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41641_D310552B5377995ED83B0486922C6D3C' AND m.source_system_id = 3;

-- Match: 60399_DD1BDA2B231649BF3C7DD1EE96C3BA0F
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60399_DD1BDA2B231649BF3C7DD1EE96C3BA0F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21994,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60399_DD1BDA2B231649BF3C7DD1EE96C3BA0F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21994,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60399_DD1BDA2B231649BF3C7DD1EE96C3BA0F' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22005,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60399_DD1BDA2B231649BF3C7DD1EE96C3BA0F' AND m.source_system_id = 3;

-- Match: 41622_50BD8923F1CC7B0E367ADF596D693814
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22325,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
WHERE m.external_id = '41622_50BD8923F1CC7B0E367ADF596D693814' AND m.source_system_id = 3;

-- Match: 71536_95A4FD0E45144233DEA2DA3D7F894CF5
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21798,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '71536_95A4FD0E45144233DEA2DA3D7F894CF5' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21803,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
WHERE m.external_id = '71536_95A4FD0E45144233DEA2DA3D7F894CF5' AND m.source_system_id = 3;

-- Match: 60400_1A6A1CEA9DFFA37BB03844CC1F17349C
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21992,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60400_1A6A1CEA9DFFA37BB03844CC1F17349C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22011,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60400_1A6A1CEA9DFFA37BB03844CC1F17349C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60400_1A6A1CEA9DFFA37BB03844CC1F17349C' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22014,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
WHERE m.external_id = '60400_1A6A1CEA9DFFA37BB03844CC1F17349C' AND m.source_system_id = 3;

-- Match: 41642_6D05002761D1217649F39122B27FA700
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21918,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41642_6D05002761D1217649F39122B27FA700' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21928,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41642_6D05002761D1217649F39122B27FA700' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21937,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Richmond County FC II' AND t.source_system_id = 3
WHERE m.external_id = '41642_6D05002761D1217649F39122B27FA700' AND m.source_system_id = 3;

-- Match: 29455_73B057BDCF6AD57756F4EFF39341BA93
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21262,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29455_73B057BDCF6AD57756F4EFF39341BA93' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21262,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29455_73B057BDCF6AD57756F4EFF39341BA93' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21264,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC' AND t.source_system_id = 3
WHERE m.external_id = '29455_73B057BDCF6AD57756F4EFF39341BA93' AND m.source_system_id = 3;

-- Match: 41646_EF3954562ECDBEA645B75589D97748B1
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41646_EF3954562ECDBEA645B75589D97748B1' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21300,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Missile FC II' AND t.source_system_id = 3
WHERE m.external_id = '41646_EF3954562ECDBEA645B75589D97748B1' AND m.source_system_id = 3;

-- Match: 71516_70A2B34682DB6ED0110A7E27DA28509A
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21680,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '71516_70A2B34682DB6ED0110A7E27DA28509A' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21689,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '71516_70A2B34682DB6ED0110A7E27DA28509A' AND m.source_system_id = 3;

-- Match: 71520_23C58356A2413B5240FD6124F34E066D
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22148,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '71520_23C58356A2413B5240FD6124F34E066D' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  22148,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'Tibet FC' AND t.source_system_id = 3
WHERE m.external_id = '71520_23C58356A2413B5240FD6124F34E066D' AND m.source_system_id = 3;

-- Match: 72497_0C20C04AE6D27A2FE6C913F88A9FE067
INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '72497_0C20C04AE6D27A2FE6C913F88A9FE067' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21677,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '72497_0C20C04AE6D27A2FE6C913F88A9FE067' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21688,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '72497_0C20C04AE6D27A2FE6C913F88A9FE067' AND m.source_system_id = 3;

INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
SELECT
  m.id,
  21688,
  t.id,
  (SELECT id FROM match_event_types WHERE name = 'goal'),
  0,
  NULL
FROM matches m
JOIN teams t ON t.name = 'NY Ukrainians II' AND t.source_system_id = 3
WHERE m.external_id = '72497_0C20C04AE6D27A2FE6C913F88A9FE067' AND m.source_system_id = 3;

