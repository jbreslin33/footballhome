-- 1348 (2026-11-13): Temple 7s = ONE option entry with a team count.
--
-- Owner: "make it an option, off by default like liga 2" then "allow for x
-- amount of teams to enter".
--   team_season_entries.team_count  how many sides the club enters in that
--       competition; the plan's quantities are PER TEAM (1 entry, 5 refs) and
--       the year = rate × quantity × team_count.  NULL = one team, no box.
--       Installments are per team too (× team_count on the grid).
--   Temple 7s: teams B and C (mig 1347) folded into one 'Lighthouse Temple 7s',
--       team_count 3, is_option (off until switched on, like Liga 2).

BEGIN;

ALTER TABLE team_season_entries ADD COLUMN IF NOT EXISTS team_count int CHECK (team_count BETWEEN 0 AND 20);
COMMENT ON COLUMN team_season_entries.team_count IS 'Sides entered; plan quantities + installments are per team, × team_count. NULL = one team, no box (mig 1348)';

DELETE FROM team_season_entries e USING teams t WHERE t.id = e.team_id AND t.slug IN ('lighthouse-temple-7s-b', 'lighthouse-temple-7s-c');
DELETE FROM teams WHERE slug IN ('lighthouse-temple-7s-b', 'lighthouse-temple-7s-c');
UPDATE teams SET name = 'Lighthouse Temple 7s', slug = 'lighthouse-temple-7s', label = '7️⃣ Temple 7s', short_label = 'Temple 7s', updated_at = now()
 WHERE slug = 'lighthouse-temple-7s-a';
UPDATE team_season_entries e SET team_count = 3, is_option = true, note = 'Winter 2027'
  FROM teams t WHERE t.id = e.team_id AND t.slug = 'lighthouse-temple-7s';
UPDATE team_season_installments i SET note = 'Early bird deadline, per team'
  FROM team_season_entries e JOIN teams t ON t.id = e.team_id
 WHERE i.entry_id = e.id AND t.slug = 'lighthouse-temple-7s';

CREATE OR REPLACE VIEW team_fee_plan_lines AS
 SELECT p.id AS plan_id, e.id AS entry_id, e.team_id, t.name AS team, l.name AS league, s.name AS season,
        CASE WHEN pd.id IS NULL THEN d.name ELSE (pd.name || ' › '::text) || d.name END AS entry_division,
        fd.name AS fee_division, c.code AS category, c.sort_order AS category_order,
        k.code AS fee_kind, k.label AS fee_label, k.sort_order AS kind_order, k.is_refundable, f.tier, f.unit,
        f.amount_usd AS rate, p.quantity,
        round(f.amount_usd * p.quantity * COALESCE(e.team_count, 1), 2) AS proposed,
        p.is_assumed OR f.is_assumed AS is_assumed, p.note,
        e.team_count
   FROM team_fee_plans p
     JOIN team_season_entries e ON e.id = p.entry_id
     JOIN teams t ON t.id = e.team_id
     JOIN seasons s ON s.id = p.season_id
     JOIN leagues l ON l.id = s.league_id
     JOIN league_fees f ON f.id = p.league_fee_id
     JOIN fee_kinds k ON k.code = f.fee_kind
     JOIN invoice_line_categories c ON c.code = k.category
     LEFT JOIN league_divisions d ON d.id = e.division_id
     LEFT JOIN league_divisions pd ON pd.id = d.parent_id
     LEFT JOIN league_divisions fd ON fd.id = f.division_id;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan team count box', 'finances', 'plan_team_count', 'teams', true, 101, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1348-temple-7s-option-team-count.sql') ON CONFLICT DO NOTHING;
COMMIT;
