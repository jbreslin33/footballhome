-- 1603 (2026-11-20) — 💵 New members to prorate, in the 🚦 band until billed.
-- Owner: "i need also todo at top for new players tuition. so you should
-- find new players who we did not prorate yet. like they should have more
-- then $1 billed out right?" + "it should calc pro rate like on tution page
-- and bascially tell me how much and button take me to la like on tution
-- to inovice them" + "once you detect a prorate charge … NOT 35 after $1
-- then its def pro rate".
--
-- Who: GET /api/prorates/due (ProrateLog::dueList) — a current ACTIVE LA
-- membership billed ≤ $1 in total (just the card fee), not NA_FREE, not a
-- club volunteer, not ✓ Done.  Any charge past $1 — a prorate or a full
-- $35 — takes them off at the next LA sync.  The amount = BillingBadge.
-- projectedProrate (Tuition page's Prorate cell).  🔗 Open in LA = the
-- Tuition page's member link.
CREATE TABLE IF NOT EXISTS prorate_dismissals (
    person_id          INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    dismissed_by_user  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    dismissed_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO status_items (code, severity, window_hours, sort_order, is_active)
SELECT 'prorate_owed', 'action', NULL, 9, true
 WHERE NOT EXISTS (SELECT 1 FROM status_items WHERE code = 'prorate_owed');

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1120 + v.n, true
  FROM (VALUES
    (1,  'Band: prorate box ({n} to bill, {list} = names)',         'seg_prorate_owed',  '💵 Prorate — {n} new to bill: {list}'),
    (2,  'Band: prorate box button',                                'act_prorate_owed',  'Bill ›'),
    (3,  'Prorate popup title',                                     'sheet_prorate',     '💵 New members to bill in LeagueApps'),
    (4,  'Prorate popup: line under the title',                     'prorate_intro',     'Only the $1 card fee billed so far. Add the charge in LA — they leave this list at the next sync once anything past $1 is billed. ✓ Done takes someone off without billing.'),
    (5,  'Prorate popup: the amount ({amount}, {days} of {cycle} days, {paid} paid)', 'prorate_amount', 'Prorate {amount} — {days} of {cycle} days, {paid} paid'),
    (6,  'Prorate popup: past their first cycle — full month',      'prorate_full',      'Full month {amount} — first cycle already over'),
    (7,  'Prorate popup: open the member in LA',                    'prorate_open_la',   '🔗 Open in LA'),
    (8,  'Prorate popup: mark one done without billing',            'prorate_done',      '✓ Done'),
    (9,  'Prorate popup: mark everyone done',                       'prorate_done_all',  '✓ Done all ({n})'),
    (10, 'Prorate popup: nobody left',                              'prorate_empty',     'Every new member has been billed. ✓'),
    (11, 'Prorate popup: registered on ({date})',                   'prorate_reg_on',    'registered {date}')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

-- Where 🔗 Open in LA goes (the Tuition page's link), so no page hardcodes it.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', 'Prorate popup: LA member page ({uid} = LA user id)', 'event_center', 'prorate_la_url',
       'https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId={uid}', 1140, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'prorate_la_url');
