-- Migration 2196: 🎓 Scholarship on every screen, not just #tuition.
-- Owner 11/27 "yes we need vol or scholarship etc" — the player card's dues
-- pill, the team-card box and the ⋯ sheet say 🙋 Volunteer / 🎓 Scholarship.
-- fh_dues_free_reason learns 'scholarship': every open club membership
-- (active / pickup) is a free LA registration (NA_FREE). Volunteers and
-- the injured keep their own reason first. Balance is $0 for them already.
BEGIN;
CREATE OR REPLACE FUNCTION fh_dues_scholarship(p_person integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT bool_and(m.la_payment_status = 'NA_FREE')
      FROM person_la_memberships m
      JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
     WHERE m.person_id = p_person AND m.ended_at IS NULL
       AND lp.variant IN ('active', 'pickup')
    HAVING count(*) > 0
$$;

CREATE OR REPLACE FUNCTION fh_dues_free_reason(p_person integer)
RETURNS text LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN fh_is_volunteer(p_person)              THEN 'volunteer'
                WHEN EXISTS (SELECT 1 FROM person_injuries i
                               JOIN health_statuses h ON h.id = i.health_status_id AND h.waives_dues
                              WHERE i.person_id = p_person AND i.starts_at <= now()
                                AND (i.ends_at IS NULL OR i.ends_at > now())) THEN 'injured'
                WHEN COALESCE(fh_dues_scholarship(p_person), false) THEN 'scholarship' END
$$;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.category, v.label, v.kind, v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Player cards',    'Dues: scholarship',                     'person_standing', 'dues_scholarship',     '🎓 Scholarship', 13),
    ('Person standing', 'Team card box: scholarship (no dues)',  'person_standing', 'box_dues_scholarship', '🎓 schol', 80),
    ('Player sheet',    'Player sheet — scholarship',            'player_sheet',    'scholarship_on',       '🎓 Scholarship — free registration, no dues', 92)
  ) AS v(category, label, kind, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = v.kind AND t.tier = v.tier AND t.is_active);
COMMIT;
