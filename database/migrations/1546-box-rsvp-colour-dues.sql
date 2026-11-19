-- 1546 (2026-11-19) — #teams team-card box: RSVP by colour, dues as date + amount.
--
-- Owner: "for rsvp R: it should be green if they set availabity in last 7
-- days. it should be yellow if winthnig 14 days. red if past 14 … then
-- all we need is RSVP and no date right?" → "just the letters RSVP" →
-- "the color code is enough info for front of card right?" → "we dont
-- need ghost status as RSVP color will tell us".  And dues: "paid is
-- enough we don't need circle too. we need actually date and amount. in
-- green it dont even need to say paid. then if owed it needs to show date
-- of last payment and AMOUNT OWED all in red".
--
-- Box line (PersonStanding.boxLine): top = RSVP coloured by his own newest
-- answer (created_via manual — the same rule as "never answered"); bottom
-- = green "11/10 $35" (last payment) or red "11/10 $70" (last payment date,
-- amount owed).  The ghost word and the RSVP date leave the box; the date
-- stays on the hover.  Thresholds = rsvp_box_policy below, not code.

BEGIN;

CREATE TABLE IF NOT EXISTS rsvp_box_policy (
  id          boolean PRIMARY KEY DEFAULT true CHECK (id),
  green_days  integer NOT NULL,
  yellow_days integer NOT NULL
);
COMMENT ON TABLE rsvp_box_policy IS
  'mig 1546: the #teams box RSVP colour — own answer within green_days = green, within yellow_days = yellow, older or never = red. One row.';
INSERT INTO rsvp_box_policy (green_days, yellow_days) VALUES (7, 14) ON CONFLICT DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Person standing', v.label, 'person_standing', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('box_rsvp',            'Team card box: RSVP (coloured by the last own answer)', 'RSVP', 70),
    ('box_rsvp_tip',        'Team card box: RSVP — hover', 'Last answered {date} ({days} days ago)', 71),
    ('box_rsvp_never_tip',  'Team card box: RSVP, never answered — hover', 'Has never answered an RSVP themselves', 72),
    ('box_paid_amount',     'Team card box: paid up — last payment ({date}, {amount})', '{date} {amount}', 73),
    ('box_owes_since',      'Team card box: owes — last payment date + amount owed ({date}, {amount})', '{date} {amount}', 74),
    ('box_owes_since_tip',  'Team card box: owes — hover', 'Owes {amount}. Last payment {date}.', 75),
    ('box_owes_never_tip',  'Team card box: owes, never paid — hover', 'Owes {amount}. No payment on record.', 76)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);

COMMIT;
