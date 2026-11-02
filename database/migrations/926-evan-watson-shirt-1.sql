-- 926-evan-watson-shirt-1.sql
-- Owner 11/2: Evan Watson is a keeper and wears #1 (Men's pool).

INSERT INTO person_uniform_numbers (uniform_set_id, person_id, jersey_number)
SELECT s.id, p.id, '1'
  FROM uniform_sets s
  JOIN persons p ON p.id = 22589
 WHERE s.name = 'Mens';
