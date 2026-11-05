-- 1096: Game Center's 🎟 Call-up pool fold — owner 2026-11-05 (APSL at
-- Vidas): "why on apsl is a bunch of guys no response … those guys are
-- supposed to be inactive right? then i could call them up … except like
-- victor".  Players on a game only through a call-up-only team (APSL
-- Reserves, team_callup_policies) and not called up leave No Response /
-- Remind all for a closed fold with 🎟 CALL IN; the lineup data now names
-- those teams (callupOnlyTeamIds).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Section — call-up pool (call-up-only team, not called up)', 'event_center', 'sec_callup_pool', NULL,
       '🎟 Call-up pool', 60, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'event_center' AND tier = 'sec_callup_pool');
