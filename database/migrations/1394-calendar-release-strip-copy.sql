-- 1394 (2026-11-16) — the 📅 Calendar's admin strips speak from the DB.
-- Owner rule "never hardcode copy"; the schedule-release strip (mig 334,
-- lib/calendar-ops.js ReleaseStrip) was still literals carried over from
-- the old #calendar screen, and the clash strip's count line too.
-- Tokens: {week} = release_week filled; {rule} = the policy's label (the
-- [[ … ]] drops when there is none); times are already formatted.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Calendar', v.label, 'calendar', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Release strip — the week''s name ({date} = its Monday)', 'release_week', 'Week of {date}', 10),
    ('Release strip — posted on its normal time', 'release_posted', '✅ {week} is posted. It opened {opened}[[ (rule: {rule})]].', 11),
    ('Release strip — posted early by an admin', 'release_early', '✅ {week} is posted early[[ by {by}]], {at}. Normal post time was {normal}.', 12),
    ('Release strip — not posted yet', 'release_pending', '🕗 {week} posts to players and parents {opens}[[ (rule: {rule})]].', 13),
    ('Release strip — button: post the week now', 'release_open_btn', 'Open now', 14),
    ('Release strip — button busy: posting', 'release_opening', 'Opening…', 15),
    ('Release strip — confirm posting early', 'release_confirm_open', 'Post {week} to players and parents now?', 16),
    ('Release strip — button: close an early post', 'release_close_btn', 'Close it again', 17),
    ('Release strip — button busy: closing', 'release_closing', 'Closing…', 18),
    ('Release strip — confirm closing an early post', 'release_confirm_close', 'Close this week again? Players and parents will stop seeing it until the normal post time.', 19),
    ('Release strip — link: edit the standing rule', 'release_rule_link', 'Change the rule', 20),
    ('Release strip — label before the rule editor', 'release_rule_label', 'Standing rule:', 21),
    ('Release strip — button: save the rule', 'release_save', 'Save', 22),
    ('Release strip — button busy: saving', 'release_saving', 'Saving…', 23),
    ('Release strip — link: cancel editing', 'release_cancel', 'Cancel', 24),
    ('Release strip — a write failed ({error})', 'release_failed', 'Could not update the schedule window: {error}', 25),
    ('Clash strip — how many, how far ahead', 'clash_count', '{n} in the next {days} days', 26)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'calendar' AND m.tier = v.tier);
