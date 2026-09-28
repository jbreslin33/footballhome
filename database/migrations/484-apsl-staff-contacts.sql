-- 484 (2026-09-28) — APSL opponent staff with phones and emails.
-- The public apslsoccer.com team pages show staff names only (mig 483 loaded
-- those).  Signed in to TeamPass as the club (owner did the sign-in), the
-- same pages list each staff member's email and mobile — owner: "you can
-- get contact info by clicking our opponents in the schedule".  Delaware
-- River Conference A + B, 15 clubs, read 2026-09-28.  Matches the name-only
-- rows from 483 and fills them in; new people are added.  Phones normalised
-- to (xxx) xxx-xxxx.
CREATE OR REPLACE FUNCTION pg_temp.club_of(p_alias text) RETURNS int LANGUAGE sql AS $$
  SELECT COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_alias)) LIMIT 1),
                  (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_alias)) ORDER BY id LIMIT 1));
$$;
CREATE OR REPLACE FUNCTION pg_temp.staff(p_alias text, p_name text, p_role text, p_email text, p_phone text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE cid int; xid int;
BEGIN
  cid := pg_temp.club_of(p_alias);
  IF cid IS NULL THEN RAISE EXCEPTION 'no club for %', p_alias; END IF;
  SELECT id INTO xid FROM club_contacts WHERE club_id = cid AND is_active AND p_email <> '' AND LOWER(email) = LOWER(p_email) LIMIT 1;
  IF xid IS NULL THEN SELECT id INTO xid FROM club_contacts WHERE club_id = cid AND is_active AND LOWER(COALESCE(name,'')) = LOWER(p_name) LIMIT 1; END IF;
  IF xid IS NULL THEN
    INSERT INTO club_contacts (club_id, name, role, phone, email, source) VALUES (cid, p_name, p_role, NULLIF(p_phone,''), NULLIF(LOWER(p_email),''), 'teampass');
  ELSE
    UPDATE club_contacts SET name = p_name, role = p_role, phone = COALESCE(NULLIF(p_phone,''), phone), email = COALESCE(NULLIF(LOWER(p_email),''), email),
                             source = 'teampass', updated_at = now() WHERE id = xid;
  END IF;
END $$;

-- Feelsgood FC (apslsoccer.com/APSL/Team/165602)
SELECT pg_temp.staff('Feelsgood FC', 'Kevin McCartney', 'Manager', 'kcmcreative@gmail.com', '(732) 677-9152');
-- Oaklyn United FC (apslsoccer.com/APSL/Team/165441)
SELECT pg_temp.staff('Oaklyn United FC', 'Alex Lewis', 'Manager', 'oaklynunitedfc@gmail.com', '(609) 680-5679');
SELECT pg_temp.staff('Oaklyn United FC', 'Matt Perrella', 'Manager', 'perrellam18@gmail.com', '');
SELECT pg_temp.staff('Oaklyn United FC', 'Matt Pastore', 'Coach', 'mpastore822@gmail.com', '(856) 304-7330');
SELECT pg_temp.staff('Oaklyn United FC', 'Noah Blodget', 'Coach', 'noah.blodget@gmail.com', '(215) 920-5232');
SELECT pg_temp.staff('Oaklyn United FC', 'Kevin Nuss', 'Coach', 'nussyk1@gmail.com', '(856) 265-6465');
-- Vereinigung Erzgebirge Majors (apslsoccer.com/APSL/Team/168335)
SELECT pg_temp.staff('Vereinigung Erzgebirge Majors', 'Rob Oldfield', 'Manager', 'oldfield.rob10@gmail.com', '(215) 260-9792');
SELECT pg_temp.staff('Vereinigung Erzgebirge Majors', 'Eric Roby', 'Assistant Coach', 'ericmroby@gmail.com', '(954) 290-4761');
SELECT pg_temp.staff('Vereinigung Erzgebirge Majors', 'Christopher Baker', 'Captain', 'crbaker29@gmail.com', '(215) 622-1820');
SELECT pg_temp.staff('Vereinigung Erzgebirge Majors', 'Kevin Smolyn', 'Captain', 'kevinsmolyn24@gmail.com', '(215) 667-0439');
SELECT pg_temp.staff('Vereinigung Erzgebirge Majors', 'Billy Gorman', 'Manager', 'gormanbilly15@gmail.com', '');
-- Persepolis United FC (apslsoccer.com/APSL/Team/165603)
SELECT pg_temp.staff('Persepolis United FC', 'Mark Manis', 'Head Coach', 'markm2012@rocketmail.com', '(423) 823-8596');
SELECT pg_temp.staff('Persepolis United FC', 'Stephen Mensah', 'Assistant Coach', 'stevmen606@gmail.com', '(267) 683-3091');
SELECT pg_temp.staff('Persepolis United FC', 'Hashem Ashrafiuon', 'Assistant Coach', 'ashrafiuon@gmail.com', '(610) 453-4616');
SELECT pg_temp.staff('Persepolis United FC', 'Ashkon Ashrafiuon', 'Captain', 'aashrafiuon@gmail.com', '(610) 592-4363');
SELECT pg_temp.staff('Persepolis United FC', 'T-Ben Donnie', 'Captain', 'mjsathletics24@gmail.com', '(267) 498-3158');
SELECT pg_temp.staff('Persepolis United FC', 'Payman Mirzaei', 'Team Admin', 'mirzaeipayman@gmail.com', '(610) 888-9570');
-- Real Central NJ Soccer (apslsoccer.com/APSL/Team/165453)
SELECT pg_temp.staff('Real Central NJ Soccer', 'Ira Jersey', 'Head Coach', 'ira@realcentralnj.soccer', '(201) 906-6158');
SELECT pg_temp.staff('Real Central NJ Soccer', 'Jake Nerwinski', 'Assistant Coach', 'nerwinskijake@gmail.com', '(732) 948-8738');
SELECT pg_temp.staff('Real Central NJ Soccer', 'Bonniwell Graham', 'Assistant Coach', 'bg13nj@gmail.com', '(609) 216-3207');
SELECT pg_temp.staff('Real Central NJ Soccer', 'Jason Konrad', 'Assistant Coach', 'jason.konrad@gmail.com', '');
SELECT pg_temp.staff('Real Central NJ Soccer', 'Hilary Jersey', 'Team Admin', 'hzackroff71@gmail.com', '(609) 557-7340');
-- Medford Strikers (apslsoccer.com/APSL/Team/165433)
SELECT pg_temp.staff('Medford Strikers', 'James Galanis', 'Head Coach', 'galanis10@me.com', '(609) 254-0335');
SELECT pg_temp.staff('Medford Strikers', 'William Reid', 'Coach', 'doc@medfordstrikers.com', '(609) 233-7442');
SELECT pg_temp.staff('Medford Strikers', 'Mousa Issa', 'Coach', 'moissa@yahoo.com', '(609) 351-6991');
SELECT pg_temp.staff('Medford Strikers', 'Guilherme Leonardi', 'Coach', 'jrsoccernj@gmail.com', '(609) 760-0839');
-- Vidas United FC (apslsoccer.com/APSL/Team/165466)
SELECT pg_temp.staff('Vidas United FC', 'Nolan Bair', 'Manager', 'nbair@vidasunitedfc.com', '(717) 538-4730');
SELECT pg_temp.staff('Vidas United FC', 'Awwal Ayinde', 'Head Coach', 'adegoke.ayinde@yahoo.com', '(856) 504-4143');
SELECT pg_temp.staff('Vidas United FC', 'Mohammed Ibrahim', 'Assistant Coach', 'mibrahim30223@gmail.com', '');
SELECT pg_temp.staff('Vidas United FC', 'Emani Arroyo', 'Captain', 'earroyo06080@gmail.com', '(267) 591-8682');
SELECT pg_temp.staff('Vidas United FC', 'Sasha Simon', 'Captain', 'alexsimon7@gmail.com', '(773) 971-0832');
SELECT pg_temp.staff('Vidas United FC', 'Haider Irshad', 'Volunteer', 'operations@vidasunitedfc.com', '(646) 668-1192');
-- Philadelphia Ukrainian Nationals (apslsoccer.com/APSL/Team/168338)
SELECT pg_temp.staff('Philadelphia Ukrainian Nationals', 'Roman Chuprynyak', 'Manager', 'rchuprynyak@gmail.com', '(267) 231-4971');
SELECT pg_temp.staff('Philadelphia Ukrainian Nationals', 'Neema Mohajery', 'Manager', 'nmohajery@gmail.com', '(215) 804-9313');
SELECT pg_temp.staff('Philadelphia Ukrainian Nationals', 'Joseph Ross', 'Coach', 'jmr0365@gmail.com', '(267) 640-6137');
SELECT pg_temp.staff('Philadelphia Ukrainian Nationals', 'Pietro Sgueglia', 'Coach', 'psgueglia@gmail.com', '(518) 573-9384');
SELECT pg_temp.staff('Philadelphia Ukrainian Nationals', 'Brian Weinhardt', 'Coach', 'weinhardt.brian@gmail.com', '(610) 324-3438');
-- Westtown FC (apslsoccer.com/APSL/Team/168337)
SELECT pg_temp.staff('Westtown FC', 'Micah Knaub', 'Manager', 'micah@westtownfc.com', '(610) 999-9549');
SELECT pg_temp.staff('Westtown FC', 'Neil Pearson', 'Head Coach', 'neil2coach@gmail.com', '(215) 272-2263');
SELECT pg_temp.staff('Westtown FC', 'Kendall Walkes', 'Assistant Coach', 'kwalkes10@gmail.com', '');
SELECT pg_temp.staff('Westtown FC', 'Brian Betz', 'Assistant Coach', 'bbetz@neuraldriveperformance.com', '');
SELECT pg_temp.staff('Westtown FC', 'Ben Chambers', 'Assistant Coach', 'brchambers78@gmail.com', '');
SELECT pg_temp.staff('Westtown FC', 'Nick Haynes', 'Team Admin', 'tfk9@icloud.com', '(267) 281-0375');
-- Sewell Old Boys FC (apslsoccer.com/APSL/Team/165458)
SELECT pg_temp.staff('Sewell Old Boys FC', 'Nicholas Campbell', 'Manager', 'sewelloldboysfc@gmail.com', '(856) 693-2492');
-- Philadelphia Heritage SC (apslsoccer.com/APSL/Team/165445)
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Ryan Pereus', 'Manager', 'rsvp@heritagesoccerclub.com', '(215) 907-2941');
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Bliss Harris', 'Assistant Coach', 'myiphoneforbliss@icloud.com', '(267) 974-7449');
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Matt Bergmaier', 'Manager', 'mberg@heritagesoccerclub.com', '');
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Brendan Gorman', 'Captain', 'brendangorman4@gmail.com', '(215) 290-5450');
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Sean Ahern', 'Captain', 'sahern07@gmail.com', '(609) 705-0746');
SELECT pg_temp.staff('Philadelphia Heritage SC', 'Gary Dudek', 'Assistant Coach', 'garyd119@comcast.net', '');
-- WC Predators (apslsoccer.com/APSL/Team/165469)
SELECT pg_temp.staff('WC Predators', 'Ridge Robinson', 'Manager', 'ridgescores@gmail.com', '(720) 206-5091');
SELECT pg_temp.staff('WC Predators', 'Blaise Santangelo', 'Coach', 'blsantangelo@comcast.net', '(610) 405-5947');
SELECT pg_temp.staff('WC Predators', 'Vincent D''Ambrosio', 'Manager', 'vincesoccer19gk@gmail.com', '(610) 324-7871');
SELECT pg_temp.staff('WC Predators', 'Harry Ischiropoulos', 'Assistant Coach', 'ischiropoulos@email.chop.edu', '(267) 210-1559');
SELECT pg_temp.staff('WC Predators', 'Tom Brooks', 'Assistant Coach', 'thomasgbrooks2@gmail.com', '(610) 368-1603');
SELECT pg_temp.staff('WC Predators', 'Anthony Noel', 'Assistant Coach', 'anoel02@gmail.com', '(215) 219-9306');
-- Colonial SC (apslsoccer.com/APSL/Team/168339)
SELECT pg_temp.staff('Colonial SC', 'Christian Knittel', 'Manager', 'christian.knittel12@gmail.com', '(610) 329-6639');
-- Jersey Shore Boca (apslsoccer.com/APSL/Team/165426)
SELECT pg_temp.staff('Jersey Shore Boca', 'Aaron Gilman', 'Head Coach', 'bocagilman@aol.com', '(609) 713-8403');
SELECT pg_temp.staff('Jersey Shore Boca', 'Billy Bartels', 'Captain', 'bartelsbilly@yahoo.com', '(732) 272-4267');
SELECT pg_temp.staff('Jersey Shore Boca', 'Alex Matos', 'Captain', 'alex.matos2498@gmail.com', '(732) 814-0412');
SELECT pg_temp.staff('Jersey Shore Boca', 'Grady Edwards', 'Captain', 'grayman12@comcast.net', '(609) 709-8640');
SELECT pg_temp.staff('Jersey Shore Boca', 'Guy Lockwood', 'Board', 'glockwood13@msn.com', '(609) 384-7139');
-- Philadelphia Soccer Club (apslsoccer.com/APSL/Team/165447)
SELECT pg_temp.staff('Philadelphia Soccer Club', 'Aaron Sexton', 'Manager', 'psc.adults@gmail.com', '(267) 540-3242');
SELECT pg_temp.staff('Philadelphia Soccer Club', 'Scott McCoubrey', 'Head Coach', '', '');
SELECT pg_temp.staff('Philadelphia Soccer Club', 'Benjamin Richter', 'Captain', 'br8224@pcom.edu', '');
SELECT pg_temp.staff('Philadelphia Soccer Club', 'Nick Webster', 'Coach', 'weblil3@aim.com', '(215) 313-2050');
