-- 1592 — youth LA description: the programme first, the history last.
--
-- Owner 2026-11-19: "i think we move the program specific stuff to top and
-- histor etc to bottom".  A youth-tier skeleton (program-info.js looks up
-- youth → all, so men / women keep the 'all' skeleton unchanged):
-- Schedule → Teams → Membership → Billing → Changes & questions →
-- About Lighthouse 1893 (the intro, now under its own heading).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Programme description — skeleton (youth)', 'program_description', 'youth', NULL,
       E'### Schedule\n[[{program_schedule}\n]]- **Games:** {program_games}\n- **Home Outdoor Facility:** {venue_outdoor}\n- **Home Indoor Facility:** {venue_indoor}\n\n'
       '[[{program_teams}\n\n]]'
       '{program_membership}\n\n'
       '{program_billing}\n\n'
       '### Changes & questions\n{program_changes}\n\n'
       '### About Lighthouse 1893\n{program_intro}',
       400, true, false, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'program_description' AND tier = 'youth');
