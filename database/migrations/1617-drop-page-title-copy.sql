-- 🧹 Page titles, subtitles and ← Back removed from every screen (James 11/20
-- "stuff like this and the back button are not needeed now that we are menu
-- based right?" + "the pill highligted tells us where we are and back is not
-- needed as we just hit another pill to navigatge" + "this needs to be removed
-- on entire site" + "hiding? why not remove root and stem!!!" + "i don't like
-- old code laying around ever"). These copy rows only fed those headers; no
-- code reads them now.
DELETE FROM message_templates WHERE (kind, tier) IN (
  ('finances', 'title'),
  ('finances', 'subtitle'),
  ('fines', 'title'),
  ('fines', 'subtitle'),
  ('in_house_proposal', 'title'),
  ('in_house_proposal', 'subtitle'),
  ('invoices', 'subtitle'),
  ('league_schedules', 'title'),
  ('league_schedules', 'subtitle'),
  ('main_menu', 'subtitle'),
  ('onboarding', 'title'),
  ('onboarding', 'sub'),
  ('opponent', 'subtitle'),
  ('proposals', 'title'),
  ('proposals', 'subtitle'),
  ('tactical_live', 'title'),
  ('sms_opt_in', 'title'),
  ('sms_opt_in', 'subtitle'),
  ('apsl', 'hub_title'),
  ('apsl', 'hub_subtitle'),
  ('apsl', 'messages_title'),
  ('casa', 'hub_title'),
  ('casa', 'hub_subtitle'),
  ('casa', 'contacts_subtitle'),
  ('casa', 'schedule_title'),
  ('casa', 'schedule_subtitle'),
  ('casa', 'scores_title'),
  ('casa', 'scores_subtitle'),
  ('attendance_calls_page', 'title'),
  ('attendance_calls_page', 'subtitle'),
  ('awards', 'title'),
  ('awards', 'sub'),
  ('awards', 'sub2'),
  ('coach_schedule', 'title'),
  ('coach_schedule', 'sub'),
  ('contacts', 'title'),
  ('contacts', 'subtitle'),
  ('cup_roster', 'title'),
  ('cup_roster', 'subtitle'),
  ('dashboard', 'title'),
  ('dashboard', 'subtitle'),
  ('files', 'subtitle'),
  ('film', 'title'),
  ('film', 'subtitle'),
  ('event_center', 'list_sub'),
  ('event_center', 'title')
);
-- #dashboard's 🧭 All tools button went with the role tiles (11/16); its
-- label row was still being looked up for an element that no longer exists.
DELETE FROM message_templates WHERE kind = 'dashboard' AND tier = 'all_tools';
