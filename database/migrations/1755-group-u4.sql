-- 1755 (2026-11-23): groups run U4 … U16; older youth are Men / Women.
--
-- Owner 2026-11-23: "groups can do u4 to u16 then u17 u18 u19 can be men?"
-- fh_finance_program already sends a boy older than the oldest youth group to
-- Men's and a girl to Women's, and a child younger than the youngest group to
-- the youngest.  So the only change is the new youngest group, U4 (like U5).

BEGIN;

INSERT INTO finance_programs (club_id, code, label, kind, age_from, age_to, pays_dues, sort_order, is_active, roster_size)
SELECT club_id, 'u4', 'U4', kind, 4, 4, pays_dues, 104, true, roster_size
  FROM finance_programs WHERE code = 'u5'
   AND NOT EXISTS (SELECT 1 FROM finance_programs WHERE code = 'u4');

INSERT INTO schema_migrations (filename) VALUES ('1755-group-u4.sql') ON CONFLICT DO NOTHING;
COMMIT;
