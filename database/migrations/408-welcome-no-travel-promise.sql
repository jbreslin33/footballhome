-- 408 — Welcome copy stops promising travel.
--
-- Owner 2026-09-23: "We need to not promise travel but just say that
-- player will be placed when appropriate on a travel or intramural team."
--
-- Two welcome blocks (message_templates, kinds from migration 364) said
-- more than we can commit to at welcome time:
--   • welcome_docs told the parent "{child} is on a travel team" and that
--     "travel spots are confirmed as forms come in".  The docs ask stays
--     (the league needs them before any travel game), but the placement
--     line now says travel OR intramural, when appropriate.
--   • welcome_no_team (parent) only said events appear once the child is
--     on a team; it now says what that placement is.
-- The adult welcome_no_team is untouched — men's/women's have no
-- intramural side.
UPDATE message_templates SET updated_at = now(), body =
  'One more thing: the Philadelphia Parks & Rec league needs a copy of {child}''s birth certificate and a headshot before anyone can play in travel games. Please upload both here when you get a chance. {child} will be placed on a travel or intramural team when appropriate, and having the documents in keeps every option open:
{form:youth_travel_docs}'
 WHERE kind = 'welcome_docs' AND tier = 'parent';

UPDATE message_templates SET updated_at = now(), body =
  '{child} isn''t placed on a team yet, so the page will look empty for now. {child} will be placed on a travel or intramural team when appropriate, and events appear as soon as that happens. Each week''s RSVPs open {release_day} at {release_time}.'
 WHERE kind = 'welcome_no_team' AND tier = 'parent';
