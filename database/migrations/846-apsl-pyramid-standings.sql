-- 846 (2026-10-29) — #apsl-pyramid "Standings" view: copy.
--
-- Owner 2026-10-29: "commit and continue" — the next greyed view pill.
-- Every table in one list (the flow chart's order), full columns, a find
-- box that narrows to a team's tables.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('table_head_full', 'APSL pyramid — full table column heads', '# - GP W D L GF GA GD Pts', 56),
    ('tables_search',   'APSL pyramid — standings: find box',     'Find a team…', 120),
    ('tables_none',     'APSL pyramid — standings: no match',     'No table has a team by that name', 121),
    ('tables_other',    'APSL pyramid — standings: unlinked',     '{conference} · other tables in these leagues', 122),
    ('tables_cups',     'APSL pyramid — standings: root cups',    '{league} cups', 123)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
