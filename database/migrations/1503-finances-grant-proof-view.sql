-- 🧩 Programs = the grant-proof view (James 11/18 "my main thing is to see if
-- we can pay for everything WITHOUT grants lol like how much do we need grant
-- as a crutch and which progams do we need more members"). Columns: Money in
-- (dues + CASA) · Costs (own + club-wide share) · BEFORE GRANT · Grant · After
-- grant · what closes the gap (+N players at its dues, or +$/mo each).
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — grant-proof: col program', 'pg_gp_col_program', 'Program', 360),
    ('Finances — grant-proof: col players', 'pg_gp_col_players', 'Players', 361),
    ('Finances — grant-proof: col in', 'pg_gp_col_in', 'Money in', 362),
    ('Finances — grant-proof: col costs', 'pg_gp_col_costs', 'Costs', 363),
    ('Finances — grant-proof: col before', 'pg_gp_col_pre', 'BEFORE GRANT', 364),
    ('Finances — grant-proof: col grant', 'pg_gp_col_grant', 'Grant', 365),
    ('Finances — grant-proof: col after', 'pg_gp_col_post', 'After grant', 366),
    ('Finances — grant-proof: col fix', 'pg_gp_col_fix', 'To pay its way without the grant', 367),
    ('Finances — grant-proof: ok', 'pg_gp_ok', '✓ grant-proof', 368),
    ('Finances — grant-proof: more players', 'pg_gp_more', '+{n} players', 369),
    ('Finances — grant-proof: raise', 'pg_gp_raise', 'or +{amount}/mo each', 370),
    ('Finances — grant-proof: short', 'pg_gp_short', '✗ short', 371),
    ('Finances — grant-proof: headline short', 'pg_gp_head_short', 'Without the grant the club is {short} short. The grant ({grant}) covers it — {pct}% of the grant is a crutch.', 372),
    ('Finances — grant-proof: headline ok', 'pg_gp_head_ok', 'The club pays for everything without the grant ({spare} to spare). The grant ({grant}) is extra.', 373),
    ('Finances — grant-proof: note', 'pg_gp_note', 'BEFORE GRANT = dues + CASA rental − every cost (its own + its share of club-wide costs). Extra players assume no extra team is needed. Tap a program for its lines.', 374),
    ('Finances — grant-proof: detail line', 'pg_gp_before', 'BALANCE BEFORE GRANT', 375)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
