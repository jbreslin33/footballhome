-- 1094: ready-to-go cancellation emails on EVERY game's 📇 Contact panel,
-- every team (owner 2026-11-05: "there should always be a default email
-- ready to go to forfeit a game for lack of players. cancel due to
-- weather. or cancel due to field availability … on all games! for all
-- teams").  Opponent message choices = kind 'opponent' rows with a
-- subject (OpponentsController::tiers), so these appear in the panel's
-- message picker for any game, to the other club and the league block.
-- Tokens: {contact_first} {sender} {home_away} {club} {date} {time} {venue}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Opponents', v.label, 'opponent', v.tier, v.subject, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Opponent — Forfeit (not enough players)', 'cancel_forfeit',
     'Lighthouse 1893 SC {home_away} {club}, {date} — we have to forfeit',
     E'Hi {contact_first},\n\n{sender} from Lighthouse 1893 SC. Unfortunately we won''t have enough players for our game {home_away} {club} on {date} at {time}, so we have to forfeit. Sorry for the short notice, and thank you for understanding.\n\nThanks,\n{sender}',
     5),
    ('Opponent — Cancel (weather)', 'cancel_weather',
     'Lighthouse 1893 SC {home_away} {club}, {date} — cancelled for weather',
     E'Hi {contact_first},\n\n{sender} from Lighthouse 1893 SC. Because of the weather we need to cancel our game {home_away} {club} on {date} at {time}, {venue}. We''d like to reschedule — send a couple of dates and times that work for you and we''ll sort it with the league.\n\nThanks,\n{sender}',
     6),
    ('Opponent — Cancel (field not available)', 'cancel_field',
     'Lighthouse 1893 SC {home_away} {club}, {date} — field not available',
     E'Hi {contact_first},\n\n{sender} from Lighthouse 1893 SC. The field for our game {home_away} {club} on {date} at {time} ({venue}) is no longer available, so we need to cancel. We''d like to reschedule — send a couple of dates and times that work for you and we''ll sort it with the league.\n\nThanks,\n{sender}',
     7)
  ) AS v(label, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'opponent' AND m.tier = v.tier);

-- The ⛔ row atop the 📇 panel: one email to the other club, the league
-- directors and the league's officers (ref assignor) — no subject, so not
-- in the message picker.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Opponents', v.label, 'opponent', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Game Center — cancel-this-game row title ({n} emails)', 'cancel_title',
     '⛔ Cancel this game — one email to the other club, the league and the ref assignor ({n})', 880),
    ('Game Center — cancel row, nobody to email', 'cancel_none',
     'No email on file for the other club or the league yet — add one below.', 881)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'opponent' AND m.tier = v.tier);
