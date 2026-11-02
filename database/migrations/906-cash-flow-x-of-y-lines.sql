-- 906 (2026-10-30) — #cash-flow: spread lines say which ones land in the month.
--
-- Owner: "for player adds and things like that show in format for month x of x
-- right? or x,y,z of a right?"  Player adds move to whole players a month (15
-- over 7 months: 3, then 2 a month), so a month reads "1, 2, 3 of 15" and the
-- totals stay $600, $75 and $375.

DELETE FROM cash_flow_planned WHERE label ~ 'player adds, 15 at';

INSERT INTO cash_flow_planned (ym, label, amount, scope)
SELECT m.ym, p.name || ' player adds ' || array_to_string(m.nums, ', ') || ' of 15 at $' || p.each,
       cardinality(m.nums) * p.each, p.scope
  FROM (VALUES ('APSL', 40, 'apsl'), ('Reserves', 5, 'apsl'), ('Liga 1', 25, 'liga1')) AS p(name, each, scope)
 CROSS JOIN (VALUES ('2026-11', ARRAY[1, 2, 3]), ('2026-12', ARRAY[4, 5]), ('2027-01', ARRAY[6, 7]),
                    ('2027-02', ARRAY[8, 9]), ('2027-03', ARRAY[10, 11]), ('2027-04', ARRAY[12, 13]),
                    ('2027-05', ARRAY[14, 15])) AS m(ym, nums);

UPDATE cash_flow_planned SET label = v.new
  FROM (VALUES
    ('APSL league balance, $250 Mondays × 5',               'APSL league balance, payments 1, 2, 3, 4, 5 of 9 at $250'),
    ('APSL league balance, $250 Mondays × 3 and last $230', 'APSL league balance, payments 6, 7, 8, 9 of 9 (last one $230)'),
    ('Liga 1 league payment, Dec 27',                        'Liga 1 league payment 1 of 3, Dec 27'),
    ('Liga 1 league payment, Feb 25',                        'Liga 1 league payment 2 of 3, Feb 25'),
    ('Liga 1 league payment, Apr 26',                        'Liga 1 league payment 3 of 3, Apr 26'),
    ('Youth referee fees, $75 a week × 5',                   'Youth referee fees, weeks 1, 2, 3, 4, 5 of 9 at $75'),
    ('Youth referee fees, $75 a week × 4',                   'Youth referee fees, weeks 6, 7, 8, 9 of 9 at $75'),
    ('Field paint, 3 orders',                                'Field paint, orders 1, 2, 3 of 3')
  ) AS v(old, new)
 WHERE cash_flow_planned.label = v.old;
