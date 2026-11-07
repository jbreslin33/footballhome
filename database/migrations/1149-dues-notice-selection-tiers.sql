-- 1149: dues notices follow the club's actual dues policy (owner
-- 2026-11-06: "contact messages need to be consistent with overall
-- policy … for men … being behind on dues could affect being selected for
-- starting lineup or even bench"; "don't mention being out right banned.
-- don't mention it affecting practice — its a soft cut"; "we cut when we
-- have a replacement").  The ban is off (mig 513 superseded 10/3); on a
-- section whose policy alternates (mig 613 — Men today) any balance puts
-- a man at the bottom of the selection list.  Members under that rule get
-- the *_selection tier of each notice: selection only — no ban, no
-- practice, no "pay $1 to stay under the line".

-- Whether the alternate-on-balance rule covers this person, regardless of
-- balance (the notice is only drawn when they owe).  fh_dues_alternate =
-- balance > 0 AND this.
CREATE OR REPLACE FUNCTION fh_dues_selection_policy(p_person_id integer, p_club_id integer DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND fh_dues_policy_alternates(p_club_id, t.club_section_id))
$$;

CREATE OR REPLACE FUNCTION fh_dues_alternate(p_person_id integer, p_club_id integer DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(fh_dues_balance_usd(p_person_id), 0) > 0
     AND fh_dues_selection_policy(p_person_id, p_club_id)
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, v.kind, v.tier, v.subject, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Payment email — under a month owed (selection policy)', 'payment_notice_email', 'behind_1_selection',
     '{club} — dues owed',
     E'Hi {first},\n\nYou''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard}\n\nWhile dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first. Paying it off moves you back up.[[ Your next month posts {deadline}.]] Even {partial_amounts} shows us you''re still active — pay what you can.\n\nThanks,\nTreasurer, Lighthouse 1893',
     411),
    ('Payment email — 1 full month behind (selection policy)', 'payment_notice_email', 'behind_2_selection',
     '{club} — dues {months_label} behind, action needed',
     E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard}\n\nWhile dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first, which could lead to being listed as an alternate. Paying it off moves you straight back up.[[ Your next month posts {deadline}, which puts you at {pause_amount} owed.]] Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.\n\nThanks,\nTreasurer, Lighthouse 1893',
     412),
    ('Payment email — at/over the line (selection policy)', 'payment_notice_email', 'behind_3_selection',
     '{club} — dues {months_label} behind, please pay',
     E'Hi {first},\n\nYou''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. While dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first, which could lead to being listed as an alternate. Paying it off moves you straight back up.\n\nPlease pay here: {form:la_dashboard}\n[[Your next month posts {deadline}. ]]Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.\n\nThanks,\nTreasurer, Lighthouse 1893',
     413),
    ('Payment text — under a month owed (selection policy)', 'payment_notice_sms', 'behind_1_selection', NULL,
     'Hi {first}, you''re behind on Lighthouse 1893 dues[[ ({amount} owed)]]. Please pay now: {form:la_dashboard} While dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first. Paying it off moves you back up.[[ Next month posts {deadline}.]] Even {partial_amounts} shows us you''re still active.',
     421),
    ('Payment text — 1 full month behind (selection policy)', 'payment_notice_sms', 'behind_2_selection', NULL,
     'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]] and this needs sorting out. Pay here: {form:la_dashboard} While dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first, which could lead to being listed as an alternate. Paying it off moves you straight back up.[[ Next month posts {deadline}, which puts you at {pause_amount} owed.]] Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
     422),
    ('Payment text — at/over the line (selection policy)', 'payment_notice_sms', 'behind_3_selection', NULL,
     'Hi {first}, you''re {months_label} behind on Lighthouse 1893 dues[[ ({amount} owed)]]. While dues are owed you''re at the bottom of the selection list for starters and bench on men''s games — paid-up players get picked first, which could lead to being listed as an alternate. Paying it off moves you straight back up. Pay here: {form:la_dashboard}[[ Next month posts {deadline}.]] Even {partial_amounts} shows us you''re still active — pay what you can and reply with a plan.',
     423)
  ) AS v(label, kind, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
