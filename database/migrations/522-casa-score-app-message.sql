-- 522 (2026-10-05) — CASA score chase: the "get the app and enter it
-- yourself" message.  Owner, when the chase (mig 520) went in: "later we can
-- put in a 'hey download the app and put in your scores' buttons" … "now add
-- the download the app and enter your scores button".
--
-- #casa-scores gets a message picker above the games: "Ask for the score"
-- (score_request, the reply-to-me bridge) or "Get the app" (score_app — the
-- end goal: the team's manager enters the score in the SportsEngine app).
-- The per-person and per-team Text / Email buttons send whichever is picked;
-- each send is logged with its tier, so a card says which one a person got.
-- Tokens as score_request: {contact_first} {sender} {home} {away}
-- {division} {date} {from_email}.
CREATE OR REPLACE FUNCTION pg_temp.casa_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'CASA', p_label, 'casa', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = p_tier);
$$;
SELECT pg_temp.casa_tpl('scores_pick_request', 'CASA scores — picker: ask for the score', NULL, 'Ask for the score', 42);
SELECT pg_temp.casa_tpl('scores_pick_app',     'CASA scores — picker: get the app',       NULL, 'Get the app & enter it', 43);
SELECT pg_temp.casa_tpl('scores_tag_app',      'CASA scores — tally word for the app message', NULL, 'app', 44);
SELECT pg_temp.casa_tpl('score_app',           'CASA — enter your score in the app (email)', 'CASA Select {division} — please enter your score: {home} v {away}',
'Hi {contact_first},

{sender} here, CASA Select Philadelphia commissioner. We still need the score for {home} v {away} ({division}, {date}).

The quickest way is to enter it yourself in the free SportsEngine app, and from now on we are asking every team to do that by Sunday night:

1. Download the SportsEngine app
   iPhone: https://apps.apple.com/us/app/sportsengine/id499597400
   Android: https://play.google.com/store/apps/details?id=com.sportngin.android
2. Sign in with the email you registered your team with
3. Open your team, tap the game on the schedule and enter the final score

If the app does not let you enter it, reply here with the score and tell me what you see, and I will sort out your access.

Thanks,
{sender}
{from_email}', 45);
SELECT pg_temp.casa_tpl('score_app_sms',       'CASA — enter your score in the app (text)', NULL,
'Hi {contact_first}, {sender} from CASA Select here. We still need the score for {home} v {away} on {date}. Please enter it in the free SportsEngine app: sign in with the email you registered your team with, open your team, tap the game and enter the final score. iPhone: https://apps.apple.com/us/app/sportsengine/id499597400 Android: https://play.google.com/store/apps/details?id=com.sportngin.android If it will not let you, text me the score and I will fix your access. Thanks', 46);
