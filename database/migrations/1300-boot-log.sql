-- 1300 (2026-11-12): a screen's loading shown like a Linux boot
-- (frontend/js/components/boot-log.js).  Owner: "i need a 'loading' and a bar
-- or something to come up when loading event center and an event. its just
-- blank while loading. i always like idea of showing process in screen like a
-- linux boot".  Opening a screen starts a boot; each API fetch it makes is a
-- [ .... ] → [  OK  ] line with its time, under a bar; fades when done.
-- Tiers: title / ready / fail (tokens screen, done, total, pct); screen_<name>
-- = the screen's name; any other tier = an API path with ids dropped and
-- '/' → '_' (a path with no row prints its own segments).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.l, 'boot_log', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Boot log — header while loading',          'title',                   '⏳ Loading {screen} · {done} of {total} · {pct}%', 1),
    ('Boot log — last line, all loaded',         'ready',                   '{screen} ready',                                  2),
    ('Boot log — last line, something failed',   'fail',                    '{screen} loaded — something didn''t load',        3),
    ('Boot log — screen: Event Center',          'screen_event_center',     'Event Center',          10),
    ('Boot log — screen: an opened event',       'screen_event',            'Event',                 11),
    ('Boot log — screen: game event',            'screen_game_center',      'Event',                 12),
    ('Boot log — screen: Tuition',               'screen_tuition',          'Tuition',               13),
    ('Boot log — screen: Main menu',             'screen_main_menu',        'Main menu',             14),
    ('Boot log — line: the week''s events',      'calendar_upcoming',       'Events this week',      30),
    ('Boot log — line: one event',               'calendar_events',         'Event details',         31),
    ('Boot log — line: lineup + eligibility',    'eligibility_lineup',      'Lineup + eligibility',  32),
    ('Boot log — line: positions',               'eligibility_positions',   'Positions',             33),
    ('Boot log — line: match',                   'matches',                 'Match',                 34),
    ('Boot log — line: wording',                 'messages_templates_copy', 'Wording',               35),
    ('Boot log — line: dues standing',           'payments_standing',       'Dues + last RSVP',      36),
    ('Boot log — line: schedule window',         'schedule_window',         'Schedule release',      37),
    ('Boot log — line: drive times',             'calendar_drive-times',    'Drive times',           38),
    ('Boot log — line: jobs',                    'jobs_event',              'Jobs',                  39),
    ('Boot log — line: your fines',              'my_fines',                'Your fines',            40),
    ('Boot log — line: GroupMe',                 'my_groupme_feed',         'GroupMe',               41),
    ('Boot log — line: opponent contacts',       'opponents_for-match',     'Opponent contacts',     42),
    ('Boot log — line: RSVP reminders',          'rsvp-board_reminders',    'RSVP reminders',        43)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'boot_log' AND m.tier = v.t);
INSERT INTO schema_migrations (filename) VALUES ('1300-boot-log.sql') ON CONFLICT DO NOTHING;
COMMIT;
