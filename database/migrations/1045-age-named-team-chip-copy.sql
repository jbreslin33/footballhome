-- 1045: one age chip per card (owner 2026-11-04: "check that there is ONLY 1
-- age chip and ONLY 1 and its correct on all players everywhere").  Youth
-- teams are named by age ("U8"), so the card's team chip ("🧒 U12") and
-- league-list chip ("📋 U8") read like extra age chips.  An age-named team
-- now gets a word after its name on those chips; the plain U-chip is the
-- age (US Club Soccer 2026-27 chart, mig 1044).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', v.label, 'roster_sheet', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Team boards — card chip: another team named by age', 'chip_age_team', '{team} team', 1022),
    ('Team boards — card chip: league list of a team named by age', 'chip_age_team_list', '{team} list', 1023)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.tier);
