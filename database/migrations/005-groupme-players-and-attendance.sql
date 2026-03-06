-- Migration 005: Add GroupMe chat participants as persons/players/roster
-- and create training_attendance from RSVPs for match 522 (Philly BlackStars vs Lighthouse Boys Club, 2026-03-08)
--
-- GroupMe name → person mapping built from chat_event_rsvps in chats 2, 4, 5.
-- Players on team 186 (Boys Club) and team 190 (Boys Club U23) share eligibility per league rules.

BEGIN;

-- ============================================================================
-- 1. Create NEW persons (GroupMe participants not in DB at all)
-- ============================================================================
INSERT INTO persons (first_name, last_name) VALUES
  ('Anthony', 'Sagastume'),
  ('Elmer', 'Diaz'),
  ('Hedayatullah', ''),
  ('Gian', ''),
  ('Bennel', 'Saygurn'),
  ('Leo', 'S'),
  ('John', 'Caely'),
  ('Wilmer', 'Jr'),
  ('Musa', ''),
  ('Eduardo', ''),
  ('Emmanuel', ''),
  ('Ernesto', 'Montecer')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 2. Create player records for new persons
-- ============================================================================
INSERT INTO players (person_id, source_system_id)
SELECT pe.id, 2  -- source_system_id=2 (CASA)
FROM persons pe
WHERE (pe.first_name, pe.last_name) IN (
  ('Anthony', 'Sagastume'),
  ('Elmer', 'Diaz'),
  ('Hedayatullah', ''),
  ('Gian', ''),
  ('Bennel', 'Saygurn'),
  ('Leo', 'S'),
  ('John', 'Caely'),
  ('Wilmer', 'Jr'),
  ('Musa', ''),
  ('Eduardo', ''),
  ('Emmanuel', ''),
  ('Ernesto', 'Montecer')
)
AND NOT EXISTS (SELECT 1 FROM players p WHERE p.person_id = pe.id);

-- ============================================================================
-- 3. Add ALL GroupMe participants to team 186 roster (if not already there)
--    This includes: new persons, team 190 players, team 35 players
-- ============================================================================

-- 3a. Add new persons' players to roster
INSERT INTO rosters (team_id, player_id, joined_at)
SELECT 186, p.id, NOW()
FROM players p
JOIN persons pe ON p.person_id = pe.id
WHERE (pe.first_name, pe.last_name) IN (
  ('Anthony', 'Sagastume'),
  ('Elmer', 'Diaz'),
  ('Hedayatullah', ''),
  ('Gian', ''),
  ('Bennel', 'Saygurn'),
  ('Leo', 'S'),
  ('John', 'Caely'),
  ('Wilmer', 'Jr'),
  ('Musa', ''),
  ('Eduardo', ''),
  ('Emmanuel', ''),
  ('Ernesto', 'Montecer')
)
AND NOT EXISTS (SELECT 1 FROM rosters r WHERE r.team_id = 186 AND r.player_id = p.id AND r.left_at IS NULL)
ON CONFLICT DO NOTHING;

-- 3b. Add team 190 (Boys Club U23) players to team 186 roster
-- These players shared per league rules
INSERT INTO rosters (team_id, player_id, joined_at)
SELECT 186, p.id, NOW()
FROM players p
JOIN persons pe ON p.person_id = pe.id
WHERE pe.id IN (
  4478,  -- Ali Salah
  4476,  -- Caleb Rojas
  4468,  -- Christian/Cristian Lopez
  4460,  -- Edwin Garcia
  4475,  -- Fabian Padilla
  1363,  -- John Gonzalez
  4469,  -- John Madureira
  4455,  -- Oumar Barry
  4474,  -- Zion Nwalipenja
  4473,  -- Babacar Ndiaye
  4459,  -- Marco Delgado
  1,     -- James Breslin
  4482,  -- Idris Washington
  4467,  -- Jervin Lemus
  4458   -- Luis De Jesus
)
AND NOT EXISTS (SELECT 1 FROM rosters r WHERE r.team_id = 186 AND r.player_id = p.id AND r.left_at IS NULL)
ON CONFLICT DO NOTHING;

-- 3c. Add team 35 (APSL Lighthouse) players who appear in GroupMe
INSERT INTO rosters (team_id, player_id, joined_at)
SELECT 186, p.id, NOW()
FROM players p
JOIN persons pe ON p.person_id = pe.id
WHERE pe.id IN (
  1360,  -- Christopher Fletcher
  1366,  -- Otmane Houasli
  1352   -- Arsene Bado
)
AND NOT EXISTS (SELECT 1 FROM rosters r WHERE r.team_id = 186 AND r.player_id = p.id AND r.left_at IS NULL)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. Link chat event 5 to match 522 (Liga 1 vs Philly Black Stars, 2026-03-08)
-- ============================================================================
UPDATE chat_events SET match_id = 522 WHERE id = 5 AND match_id IS NULL;

-- ============================================================================
-- 5. Map chat_event_rsvps.person_id for ALL RSVPs across chats 2, 4, 5
--    This is the critical link so the eligibility engine can join RSVPs to players
-- ============================================================================

-- Mapping table: external_username → person_id
-- Players already on team 186 roster:
-- Use a safe update approach: only set person_id if it won't violate
-- the unique constraint (chat_event_id, person_id). Aliases for same
-- person in same event get skipped.
DO $$
DECLARE
  mapping RECORD;
BEGIN
  -- Build mapping: (external_username, person_id)
  FOR mapping IN
    SELECT * FROM (VALUES
      -- Players already on team 186 roster
      ('Abdoul Diallo', 4411),
      ('Aboubacar Bayo', 4402),
      ('Victor Baidel', 4400),
      ('VictorB', 4400),
      ('Bility⚽️', 4400),
      ('Igor Bonfim', 4403),
      ('Inaldo Francisco Botelho', 4405),
      ('Luke Breslin', 4406),
      ('Walter', 4407),
      ('Chris', 4408),
      ('Cloves Junior', 4412),
      ('Gangue Abouya', 4413),
      ('Andy Hizdri', 4414),
      ('Andy 2', 4414),
      ('Alexander Lara', 4415),
      ('Valentino Martinez', 4418),
      ('David Masi', 4419),
      ('David 2', 4419),
      ('ᴅᴀᴠɪᴅ', 4419),
      ('John Oladele', 4420),
      ('Jemirkel Ornaque', 4423),
      ('Jemirkel', 4423),
      ('Marcos Ribeiro', 4424),
      ('Denis Jhony', 4425),
      ('Majid Hamid⚽️', 1370),
      -- Players from team 190 (Boys Club U23)
      ('Ali Salah', 4478),
      ('Caleb Rojas', 4476),
      ('Cristian Lopez', 4468),
      ('Edwin Garcia', 4460),
      ('Fabian  Padilla', 4475),
      ('Fabian Fabi Padilla', 4475),
      ('John Gonzalez', 1363),
      ('John Madureira', 4469),
      ('Oumar Barry', 4455),
      ('Zion Nwalipenja', 4474),
      ('Babacar Ndiaye', 4473),
      ('Marco Delgado', 4459),
      ('Marco N', 4459),
      ('James Breslin', 1),
      ('Idris', 4482),
      ('Jervin Claros Lemus', 4467),
      ('Luis De Jesus', 4458),
      -- Players from team 35 (APSL Lighthouse)
      ('Chris Fletcher', 1360),
      ('Otmane Houasli', 1366),
      ('Arsene', 1352),
      -- Abdul Ali from training
      ('Abdul Ali', (SELECT id FROM persons WHERE first_name='Arsene' AND last_name='Bado' LIMIT 1))
    ) AS t(uname, pid)
  LOOP
    UPDATE chat_event_rsvps
    SET person_id = mapping.pid
    WHERE external_username = mapping.uname
      AND person_id IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM chat_event_rsvps dup
        WHERE dup.chat_event_id = chat_event_rsvps.chat_event_id
          AND dup.person_id = mapping.pid
      );
  END LOOP;

  -- NEW persons (dynamic IDs) - same safe update
  FOR mapping IN
    SELECT * FROM (VALUES
      ('Anthony Sagastume', (SELECT id FROM persons WHERE first_name='Anthony' AND last_name='Sagastume' LIMIT 1)),
      ('Elmer Diaz', (SELECT id FROM persons WHERE first_name='Elmer' AND last_name='Diaz' LIMIT 1)),
      ('Hedayatullah', (SELECT id FROM persons WHERE first_name='Hedayatullah' AND last_name='' LIMIT 1)),
      ('Gian', (SELECT id FROM persons WHERE first_name='Gian' AND last_name='' LIMIT 1)),
      ('Bennel Saygurn', (SELECT id FROM persons WHERE first_name='Bennel' AND last_name='Saygurn' LIMIT 1)),
      ('Bennel Saygen', (SELECT id FROM persons WHERE first_name='Bennel' AND last_name='Saygurn' LIMIT 1)),
      ('Leo S', (SELECT id FROM persons WHERE first_name='Leo' AND last_name='S' LIMIT 1)),
      ('John  Caely', (SELECT id FROM persons WHERE first_name='John' AND last_name='Caely' LIMIT 1)),
      ('Wilmer JR', (SELECT id FROM persons WHERE first_name='Wilmer' AND last_name='Jr' LIMIT 1)),
      ('Musa', (SELECT id FROM persons WHERE first_name='Musa' AND last_name='' LIMIT 1)),
      ('Eduardo', (SELECT id FROM persons WHERE first_name='Eduardo' AND last_name='' LIMIT 1)),
      ('Emmanuel', (SELECT id FROM persons WHERE first_name='Emmanuel' AND last_name='' LIMIT 1)),
      ('ernesto montecer', (SELECT id FROM persons WHERE first_name='Ernesto' AND last_name='Montecer' LIMIT 1))
    ) AS t(uname, pid)
  LOOP
    IF mapping.pid IS NOT NULL THEN
      UPDATE chat_event_rsvps
      SET person_id = mapping.pid
      WHERE external_username = mapping.uname
        AND person_id IS NULL
        AND NOT EXISTS (
          SELECT 1 FROM chat_event_rsvps dup
          WHERE dup.chat_event_id = chat_event_rsvps.chat_event_id
            AND dup.person_id = mapping.pid
        );
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- 6. Create training_attendance records from RSVPs
--    Events before match 522 (2026-03-08), last 5 sessions:
--    Event 12: Saturday Pickup Mar 7 (chat 5)
--    Event 10: Friday Training Mar 6 (chat 4)
--    Event 9: Thursday Training Mar 6 (chat 4)
--    Event 4: Liga 1 vs West Chester Mar 6 (chat 2, game)
--    Event 8: Wednesday Training Mar 5 (chat 4)
--    Also include: Event 7 (Tue Mar 4), Event 6 (Fri Feb 27), Event 3,2 (Mar 1)
--    The engine will pick the last 5 based on its lookback window.
-- ============================================================================

-- For each RSVP with person_id set and rsvp_status_id=1 (yes), create attendance
INSERT INTO training_attendance (player_id, chat_event_id, attended, source)
SELECT DISTINCT p.id, cer.chat_event_id, true, 'groupme_rsvp'
FROM chat_event_rsvps cer
JOIN persons pe ON cer.person_id = pe.id
JOIN players p ON p.person_id = pe.id
JOIN rosters r ON r.player_id = p.id AND r.team_id = 186 AND r.left_at IS NULL
WHERE cer.chat_event_id IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  AND cer.person_id IS NOT NULL
  AND COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) = 1  -- yes
  AND NOT EXISTS (
    SELECT 1 FROM training_attendance ta 
    WHERE ta.player_id = p.id AND ta.chat_event_id = cer.chat_event_id
  );

-- Also record non-attendance for "no" RSVPs (rsvp_status_id=2)
INSERT INTO training_attendance (player_id, chat_event_id, attended, source)
SELECT DISTINCT p.id, cer.chat_event_id, false, 'groupme_rsvp'
FROM chat_event_rsvps cer
JOIN persons pe ON cer.person_id = pe.id
JOIN players p ON p.person_id = pe.id
JOIN rosters r ON r.player_id = p.id AND r.team_id = 186 AND r.left_at IS NULL
WHERE cer.chat_event_id IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  AND cer.person_id IS NOT NULL
  AND COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) = 2  -- no
  AND NOT EXISTS (
    SELECT 1 FROM training_attendance ta 
    WHERE ta.player_id = p.id AND ta.chat_event_id = cer.chat_event_id
  );

COMMIT;
