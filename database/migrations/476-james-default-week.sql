-- 476 (2026-09-27) — James Breslin's usual week.
-- Owner: "for me it should default to monday 4 to 7, tuesday and thursday
-- 630 to 9. wed 4 to 9. fri 5 to 9. sat 11 to 1"  (pm throughout; Sat 11 am – 1 pm).
INSERT INTO invoice_default_shifts (issuer_id, weekday, start_at, end_at)
SELECT i.id, d.weekday, d.start_at, d.end_at
  FROM invoice_issuers i
  CROSS JOIN (VALUES
    (1, TIME '16:00', TIME '19:00'),
    (2, TIME '18:30', TIME '21:00'),
    (3, TIME '16:00', TIME '21:00'),
    (4, TIME '18:30', TIME '21:00'),
    (5, TIME '17:00', TIME '21:00'),
    (6, TIME '11:00', TIME '13:00')) AS d(weekday, start_at, end_at)
 WHERE i.person_id = 1
   AND NOT EXISTS (SELECT 1 FROM invoice_default_shifts x WHERE x.issuer_id = i.id AND x.weekday = d.weekday);
