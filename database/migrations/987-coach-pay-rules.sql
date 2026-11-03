-- 987 (2026-11-03) — what each coach is paid for by default.
-- Owner 2026-11-03: "my coaching should only be mens practice and apsl and
-- liga 1 games. by default." / "jamie is just women. luke and anthony are
-- youth games and practices".
--   coach_pay_rules   an invoice issuer with rows is projected only for events
--                     of that kind on those teams (fh_event_teams); no rows =
--                     every team they coach, as before.  Hours put on a sheet
--                     by hand still count wherever their event is.
--   cash_flow_issuer_scope()  where a coach's usual hours and any hours with
--                     no event land on #finances: their rules' section, else
--                     club-wide.
BEGIN;
CREATE TABLE IF NOT EXISTS coach_pay_rules (
    issuer_id  INTEGER NOT NULL REFERENCES invoice_issuers(id) ON DELETE CASCADE,
    event_kind TEXT NOT NULL CHECK (event_kind IN ('practice', 'match')),
    team_id    INTEGER NOT NULL REFERENCES teams(id),
    PRIMARY KEY (issuer_id, event_kind, team_id)
);
COMMENT ON TABLE coach_pay_rules IS 'mig 987: the events a coach is paid for by default (kind × team).';
INSERT INTO coach_pay_rules (issuer_id, event_kind, team_id)
SELECT v.i, k.kind, v.t
  FROM (VALUES (1, 35), (1, 120),                                   -- James: men's (APSL + Liga 1)
               (3, 901),                                            -- Jamie: women
               (2, 912), (2, 913), (2, 914), (2, 932),              -- Luke: youth
               (4, 912), (4, 913), (4, 914), (4, 932)) AS v(i, t)   -- Anthony: youth
 CROSS JOIN (VALUES ('practice'), ('match')) AS k(kind)
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_coach_paid_for(p_issuer int, p_event bigint, p_kind text) RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT EXISTS (SELECT 1 FROM coach_pay_rules WHERE issuer_id = p_issuer)
      OR EXISTS (SELECT 1 FROM coach_pay_rules r JOIN fh_event_teams fet ON fet.team_id = r.team_id
                  WHERE r.issuer_id = p_issuer AND r.event_kind = p_kind AND fet.fh_event_id = p_event) $$;

CREATE OR REPLACE FUNCTION cash_flow_issuer_scope(p_issuer int) RETURNS text LANGUAGE sql STABLE AS $$
  WITH s AS (SELECT DISTINCT cs.code FROM coach_pay_rules r JOIN teams t ON t.id = r.team_id JOIN club_sections cs ON cs.id = t.club_section_id
              WHERE r.issuer_id = p_issuer)
  SELECT COALESCE(CASE WHEN (SELECT count(*) FROM s) = 1 THEN (SELECT sc.code FROM cash_flow_scopes sc WHERE sc.section_code = (SELECT code FROM s)) END, 'club') $$;
COMMIT;
