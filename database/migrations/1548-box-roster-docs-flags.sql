-- 1548 (2026-11-19) — #teams box corner flags: ROSTER and DOCS in red.
--
-- Owner: "why do teams 'player' cards have XCASA and XAPSL on them. what
-- is purpose lol" → "i think a flag at top of card that is DOCS in red?
-- its obvois if liga 1 team its for CASA reg and apsl same. the minus -
-- for not on roster sould be ROSTER in red label instead in same basic
-- spot".
--
-- The team-card box's top-right corner carries red word tags:
--   ROSTER  not on this team's official roster (was ⛔; server notOnRoster)
--   DOCS    no registration with THIS card's league — CASA on the Liga 1
--           card, APSL on APSL / Reserves (registrations[].teamIds); a
--           filled APSL form not yet listed counts as docs in
-- ❌CASA / ❌APSL / 📎APSL leave the box's bottom line.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Roster sheet', v.label, 'roster_sheet', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('tc_flag_roster', 'Team card box: corner flag — not on the official roster', 'ROSTER', 900),
    ('tc_flag_docs',   'Team card box: corner flag — no league registration (the card''s league)', 'DOCS', 901)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.tier);
