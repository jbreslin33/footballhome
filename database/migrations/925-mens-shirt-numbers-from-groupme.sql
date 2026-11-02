-- 925-mens-shirt-numbers-from-groupme.sql
--
-- Men's shirt numbers read off the GroupMe groups (latest post wins, per
-- person and per number): the 11/1 new-kit thread in Lighthouse Mens Club
-- 1893, the 10/20 and 10/11 posts, over the 10/3 #kit rows. Owner 11/2:
-- Gian stays 6, Luke is 14.  Same rows #kit and the #teams card write.
--
-- Left with no number because someone newer holds it:
--   Lucca Santos 22698 (posted 19; Marco has that shirt, Ali Salah's reply)
--   Caleb Rojas 3507   (was 14; owner gave 14 to Luke)
--   Erick David 22739  (posted 77 on 10/20; Andy Hizdri took 77 on 11/1)
-- Mar-May APSL posts are all superseded for people still on a men's roster.

BEGIN;

CREATE TEMP TABLE new_numbers (person_id int, jersey_number varchar(3)) ON COMMIT DROP;
INSERT INTO new_numbers VALUES
    (3477,  '5'),   -- Owen Magee
    (22433, '30'),  -- Sheldon Rhoden
    (3498,  '77'),  -- Andy Hizdri
    (22598, '31'),  -- Tolu Asekun-Masha
    (3488,  '17'),  -- Aboubacar Bayo
    (14496, '11'),  -- Issiaga Soumah
    (3509,  '20'),  -- Ali Salah
    (22688, '44'),  -- Ali Kol
    (22228, '42'),  -- Isaac Anderson
    (3500,  '15'),  -- David Masi
    (3508,  '21'),  -- Anthony Sagustume
    (22298, '9'),   -- Lusayo Mwakatika
    (22255, '40'),  -- Daouda Elegbe
    (1275,  '16'),  -- Amir Khan
    (22311, '22'),  -- Dylan Martinez
    (22551, '33'),  -- Sean McConnell
    (22241, '55'),  -- Joey Benzing
    (22257, '18'),  -- Jadon Hewitt
    (22269, '97'),  -- Moussa Camara
    (22683, '24'),  -- Allen Morfoh
    (22497, '4'),   -- Johnson Chieu
    (22427, '39'),  -- Brian Ramos-Leiva
    (3511,  '64'),  -- Leo Santa
    (3463,  '14'),  -- Luke Breslin
    (3492,  '19');  -- Marco Delgado

DELETE FROM person_uniform_numbers u
 USING uniform_sets s
 WHERE s.id = u.uniform_set_id AND s.name = 'Mens'
   AND (u.person_id = 3507
        OR u.person_id IN (SELECT person_id FROM new_numbers)
        OR u.jersey_number IN (SELECT jersey_number FROM new_numbers));

INSERT INTO person_uniform_numbers (uniform_set_id, person_id, jersey_number)
SELECT s.id, n.person_id, n.jersey_number
  FROM new_numbers n
  JOIN persons p ON p.id = n.person_id
  JOIN uniform_sets s ON s.name = 'Mens';

COMMIT;
