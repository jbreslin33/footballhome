-- 742: an FH Texter reminder opens no compose window, so the card says it
-- went (owner 2026-10-26: "why is text for reminder not doing pop up") —
-- without it a coach taps again and the player gets it twice.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Card note after FH Texter sent a reminder ({device} {n})', 'event_center', 'relay_sent', NULL,
       '📱 Sent from {device}', 1210, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'relay_sent');
