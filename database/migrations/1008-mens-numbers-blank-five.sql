-- 1008 (2026-11-03) — Men's shirt numbers: five players have no number
-- yet.  Owner: "the following have no number yet so fix them to blank for
-- now: johnson, acevedo, brain ramos-leiva, benzig, isaac".
-- Blank = no person_uniform_numbers row in the Mens set (the same as
-- clearing the box on #kit), so 4, 10, 39, 55 and 42 are free again.
DELETE FROM person_uniform_numbers n
 USING persons p
 WHERE p.id = n.person_id AND n.uniform_set_id = 1
   AND (n.person_id, n.jersey_number) IN ((22497, '4'),    -- Johnson Chieu
                                          (22397, '10'),   -- Anthony Acevedo
                                          (22427, '39'),   -- Brian Ramos-Leiva
                                          (22241, '55'),   -- Joey Benzing
                                          (22228, '42'));  -- Isaac Anderson
