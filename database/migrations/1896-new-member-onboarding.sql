-- 1896 (2026-11-25) — 🆕 New-member onboarding: a status report in the 🚦
-- band on every load (admins) + a 🆕 New members pill on #onboarding.
-- Owner 2026-11-25: "warn in todo if they have not been onboarded" →
-- "green onboard is 1 day right, yellow after a day, red after a week" →
-- "they are not onboarded fully until they rsvp" + "and get charged pro rate"
-- → "we need an onboading page right?" → "i should get an onbording status
-- report in the todo at top on every load".
--
-- Who: every person with a current PLAYING LeagueApps membership
-- (leagueapps_programs.variant = 'active' — pickup never counts) registered
-- on/after counts_from.  Onboarded = BOTH
--   1. answered at least one RSVP (fh_event_rsvps row for them — a parent
--      answering for a kid counts, the row is the kid's), and
--   2. charged the prorate: billed past the $1 card fee, or NA_FREE, or a
--      club volunteer, or ✓ Done on the 💵 Prorate box (prorate_dismissals)
--      — the same rule that takes them off the 💵 box (mig 1603).
-- Colour by time since registering: 🟢 < green_hours, 🟡 up to red_hours,
-- 🔴 after.  ✓ Done (new_member_onboard_dismissals) takes someone off.
-- The band box is always there for admins: 🟢 "all N onboarded" when clear.

CREATE TABLE IF NOT EXISTS new_member_onboard_policy (
    id           integer PRIMARY KEY CHECK (id = 1),
    counts_from  date    NOT NULL,
    green_hours  integer NOT NULL CHECK (green_hours > 0),
    red_hours    integer NOT NULL CHECK (red_hours > green_hours),
    note         text
);
INSERT INTO new_member_onboard_policy (id, counts_from, green_hours, red_hours, note)
VALUES (1, '2026-09-06', 24, 168, 'owner 2026-11-25: green 1 day, yellow after a day, red after a week; counts from the welcome cutoff')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS new_member_onboard_dismissals (
    person_id          integer PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    dismissed_by_user  integer REFERENCES users(id) ON DELETE SET NULL,
    dismissed_at       timestamptz NOT NULL DEFAULT now()
);

-- Beside the other new-member boxes (welcome_owed 8, prorate_owed 9).
INSERT INTO status_items (code, severity, window_hours, sort_order, is_active)
SELECT 'new_members', 'action', NULL, 8, true
 WHERE NOT EXISTS (SELECT 1 FROM status_items WHERE code = 'new_members');

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1160 + v.n, true
  FROM (VALUES
    (1, 'Band: onboarding report, someone left ({left} not onboarded of {total}, {list} = 🔴/🟡/🟢 names)', 'seg_new_members',     '🆕 Onboarding — {left} of {total} not onboarded: {list}'),
    (2, 'Band: onboarding report, everyone onboarded ({total})',                                         'seg_new_members_ok',  '🆕 Onboarding — all {total} new members onboarded ✓'),
    (3, 'Band: onboarding report button',                                                                'act_new_members',     'Onboard ›')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, v.body, 900 + v.n, true
  FROM (VALUES
    (1,  '#onboarding: new members pill ({n} not onboarded)',            'pill_new',          '🆕 New members ({n})'),
    (2,  '#onboarding: new members line under the pills',                'new_note',          'Every new LeagueApps member. Onboarded = answered an RSVP AND charged the prorate. 🟢 under {green}, 🟡 after, 🔴 after {red}.'),
    (3,  '#onboarding: new member — RSVP answered ({date})',             'new_rsvp_yes',      '✅ RSVP {date}'),
    (4,  '#onboarding: new member — no RSVP yet',                        'new_rsvp_no',       '⬜ No RSVP yet'),
    (5,  '#onboarding: new member — prorate charged ({amount})',         'new_prorate_yes',   '✅ Prorate {amount}'),
    (6,  '#onboarding: new member — prorate not charged',                'new_prorate_no',    '⬜ Prorate not charged'),
    (7,  '#onboarding: new member — registered ({date}, {days} days)',   'new_reg_on',        'registered {date} · {days}d'),
    (8,  '#onboarding: new member — no team',                            'new_no_team',       'no team'),
    (9,  '#onboarding: new member — ✓ Done (off the list)',              'new_done',          '✓ Done'),
    (10, '#onboarding: new members — everyone onboarded',                'new_empty',         'Every new member is onboarded. ✓'),
    (11, '#onboarding: new members — show the onboarded ones too ({n})', 'new_show_all',      'Show onboarded ({n})'),
    (12, '#onboarding: new members — hide the onboarded ones',           'new_hide_all',      'Hide onboarded'),
    (13, '#onboarding: new member — onboarded',                          'new_onboarded',     '✅ Onboarded')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);
