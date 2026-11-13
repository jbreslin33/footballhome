-- 1328 (2026-11-13): Year plan cost per PAYING MEMBER of the section.
-- Owner: "consider it all mens and thus shared cost of all men. this way if
-- we add a liga 2 team it smooths out more."  Under any pill: its total ÷ the
-- section's paying members (Summary's count), against a year of dues.
UPDATE message_templates
   SET body = 'Shared by {players} paying {section} members: {cost} each — {pct} of {dues} a year in dues',
       label = 'Finances — Year plan per paying member'
 WHERE kind = 'finances' AND tier = 'plan_per_player';
INSERT INTO schema_migrations (filename) VALUES ('1328-plan-per-paying-member.sql') ON CONFLICT DO NOTHING;
