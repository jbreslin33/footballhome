-- Designated players: Amadou Kamagate, Henry Gamez, Oumar Sylla, Igor Santos Bonfim
-- IDs are stable (from 021-players-complete.sql seed data)
UPDATE players SET is_designated = true WHERE id IN (1369, 10865, 1374, 3483);
