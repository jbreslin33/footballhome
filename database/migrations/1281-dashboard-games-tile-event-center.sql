-- 1281 (2026-11-11) — #dashboard games tile says Event Center, not Game Center.
--
-- Owner 2026-11-11: "there should be no game center. its just event
-- center".  The tile now opens Event Center on 🏟️ Games (was the old
-- Game Center game picker); its title follows.

UPDATE message_templates SET body = '📋 Event Center · Games'
 WHERE kind = 'dashboard' AND tier = 'gc_title' AND body = '🏟️ Game Center';
