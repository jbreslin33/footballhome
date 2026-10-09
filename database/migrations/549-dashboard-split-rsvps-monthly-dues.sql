-- 549 (2026-10-09) — #dashboard: games and practices as two RSVP cells, and
-- the month's dues total for all members on the Dues cell.
-- Owner: "separate game and practice rsvps. missing monthly total in dues
-- for all."  Nothing new is read: the page splits the released-week list
-- GET /api/dashboard already returns by event kind, and the monthly total
-- is PaymentsOverview's all-members projection (mig 489).  The words live
-- here; the old single-cell rows (rsvp_title / rsvp_sub) go inactive.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('rsvp_games_title',     'Game RSVPs cell — title',                     '⚽ Game RSVPs', 841),
    ('rsvp_games_sub',       'Game RSVPs cell — line under the title',      'Released games this week; players still to answer', 842),
    ('rsvp_practices_title', 'Practice RSVPs cell — title',                 '🏃 Practice RSVPs', 843),
    ('rsvp_practices_sub',   'Practice RSVPs cell — line under the title',  'Released practices this week; players still to answer', 844),
    ('pay_month',            'Dues cell — heading over the month lines',    'This month', 845),
    ('pay_monthly',          'Dues cell — monthly dues total label',        'Due each month, all members', 846),
    ('pay_monthly_current',  'Dues cell — of that, from the up to date ({amount})', '{amount} from those up to date', 847)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);
UPDATE message_templates SET is_active = false WHERE kind = 'dashboard' AND tier IN ('rsvp_title', 'rsvp_sub');
