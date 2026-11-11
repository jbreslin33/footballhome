-- 1243 (2026-11-11) — #apsl-pyramid map: the proposed conferences move into
-- the ☰ menu (owner: "proposed confs gui should be in main gui" / "get rid of
-- clutter!").  The floating panel is gone; the map keeps only the border
-- lines and each proposed conference's name.  The menu rows: tier dot, name,
-- cities · people within 100 km; the judgement is the row's tooltip.
UPDATE message_templates
   SET body = 'Our proposal, not APSL''s. Green ready · yellow borderline · grey watch — people within 100 km vs the smallest live conference ({bar}).',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_intro';
-- Words only the retired panel used.
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier IN ('proposal_live', 'proposal_new', 'proposal_watch', 'proposal_pop');
