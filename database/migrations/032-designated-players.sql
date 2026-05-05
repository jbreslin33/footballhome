-- Set designated players
-- Amadou Kamagate (id=1369), Henry Gamez (id=10865), Oumar Sylla (id=1374), Igor Santos Bonfim (id=3483)
UPDATE players SET is_designated = true
WHERE id IN (1369, 10865, 1374, 3483);
