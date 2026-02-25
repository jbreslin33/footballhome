-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - CASA
-- Player roster data from team pages
-- Total Records: 631
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30000, 'Sammy', 'Amin', '2003-10-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30000, 30000, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30001, 'Jeffrey', 'Asiedu', '2004-02-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30001, 30001, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30002, 'Theo', 'Biddle', '2000-07-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30002, 30002, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30003, 'Tyler', 'Caton', '1995-04-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30003, 30003, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30004, 'Jorge', 'Cervantes', '2002-05-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30004, 30004, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30005, 'Manuel', 'Chacon Fallas', '1998-12-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30005, 30005, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30006, 'Miguel', 'Cortes', '1991-10-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30006, 30006, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30007, 'Tyler', 'Dautrich', '1992-08-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30007, 30007, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30008, 'Cameron', 'Dennis', '1995-11-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30008, 30008, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30009, 'Aaron', 'Endres', '1999-03-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30009, 30009, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30010, 'Evan', 'Kent', '2003-07-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30010, 30010, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30011, 'Lekan', 'King', '1992-09-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30011, 30011, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30012, 'Mateo', 'Loyo', '2004-11-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30012, 30012, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30013, 'Christopher', 'Manful', '2001-07-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30013, 30013, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30014, 'Sammy', 'Monistere', '1993-09-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30014, 30014, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30015, 'Rocco', 'Monteiro', '2004-02-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30015, 30015, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30016, 'Eli', 'Moraru', '2000-06-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30016, 30016, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30017, 'Zachery', 'Moyer', '2002-06-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30017, 30017, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30018, 'Michael', 'Oh', '1992-10-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30018, 30018, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30019, 'David', 'Olukoya', '2005-05-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30019, 30019, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30020, 'Tamer', 'Ozturk', '2000-02-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30020, 30020, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30021, 'Joao', 'Patelli Ramos dos Santos', '2000-10-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30021, 30021, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30022, 'Ethan', 'Reta', '2005-01-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30022, 30022, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30023, 'Gonzalo', 'Reyes', '2002-02-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30023, 30023, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30024, 'justin', 'reynoso', '2006-09-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30024, 30024, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30025, 'Cole', 'Roddy', '2002-04-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30025, 30025, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30026, 'Adam', 'Silberg', '2000-09-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30026, 30026, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30027, 'Ethan', 'Spence', '2001-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30027, 30027, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30028, 'Kevin', 'Taipe', '2004-10-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30028, 30028, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30029, 'Djalilou', 'Adam-Djobo', '1990-12-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30029, 30029, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30030, 'Mitchel', 'Alfaro', '1998-02-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30030, 30030, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30031, 'Luke', 'Archibald', '2000-05-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30031, 30031, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30032, 'Noah', 'Blodget', '1996-02-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30032, 30032, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30033, 'Gonazalo', 'Chiang', '1999-12-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30033, 30033, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30034, 'Hayden', 'Cote', '2006-12-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30034, 30034, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30035, 'Brandon', 'Da Silva', '2007-03-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30035, 30035, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30036, 'Brandon', 'DeAngelo', '2003-07-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30036, 30036, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30037, 'Khadim', 'Drame', '1994-03-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30037, 30037, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30038, 'Emin', 'Gunaydin', '2000-11-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30038, 30038, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30039, 'Vincent', 'Guzzo', '1995-02-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30039, 30039, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30040, 'Rabah', 'Hameg', '1997-06-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30040, 30040, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30041, 'Anthony', 'Jenkins', '2000-09-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30041, 30041, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30042, 'Sincere', 'Kato', '2003-07-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30042, 30042, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30043, 'Cooper', 'Lang', '1999-06-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30043, 30043, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30044, 'Alex', 'Lewis', '1990-05-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30044, 30044, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30045, 'Lucien', 'Maslin', '2005-05-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30045, 30045, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30046, 'Dayvon', 'Mbu', '2002-11-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30046, 30046, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30047, 'Kevin', 'Munive', '2003-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30047, 30047, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30048, 'Matthew', 'Pastore', '1995-08-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30048, 30048, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30049, 'Ethan', 'Spinatto', '2005-05-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30049, 30049, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30050, 'Travis', 'Spotts', '1997-02-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30050, 30050, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30051, 'Marc', 'M’bia M’bida-Essind Pastor', '2002-06-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30051, 30051, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30052, 'Logan', 'Shaw', '2007-02-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30052, 30052, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30053, 'Adrian', 'Rodriquez', '2008-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30053, 30053, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30054, 'Veysel', 'Tut', '2005-09-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30054, 30054, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30055, 'John', 'Waddell', '2005-11-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30055, 30055, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30056, 'Issac', 'Agyapong', '1994-09-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30056, 30056, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30057, 'Abdul Razak', 'Alhassan', '2005-05-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30057, 30057, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30058, 'Hassan', 'Bah', '1995-11-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30058, 30058, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30059, 'Abu', 'Bangura', '1998-08-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30059, 30059, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30060, 'Mustapha', 'Bangura', '1989-10-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30060, 30060, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30061, 'Abubakarr', 'Bangura', '2001-12-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30061, 30061, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30062, 'Demba', 'Camara', '1996-08-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30062, 30062, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30063, 'Cephas', 'Forson', '1993-05-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30063, 30063, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30064, 'Richardo', 'Gaye', '1996-10-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30064, 30064, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30065, 'John', 'Gwah', '1996-01-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30065, 30065, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30066, 'Abraham', 'Kamara', '2007-05-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30066, 30066, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30067, 'Francis', 'Kamara', '1996-12-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30067, 30067, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30068, 'Mohamed', 'Kamara', '2004-01-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30068, 30068, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30069, 'Alpha', 'Kanu', '1994-08-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30069, 30069, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30070, 'Nyakeh', 'Kiawoh', '1997-10-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30070, 30070, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30071, 'Sory', 'Konneh', '1979-07-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30071, 30071, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30072, 'Idrissa', 'Konobundor', '2007-05-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30072, 30072, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30073, 'Yayah', 'Koroma', '2000-05-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30073, 30073, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30074, 'Alpha', 'Koroma', '2004-06-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30074, 30074, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30075, 'Moses', 'Kpalu', '1980-04-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30075, 30075, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30076, 'Foday', 'Kuyateh', '1997-01-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30076, 30076, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30077, 'Badamasie', 'Mujtabah', '1994-11-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30077, 30077, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30078, 'Benedict', 'Olaloye', '2003-04-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30078, 30078, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30079, 'Emmanuel', 'Onwubiko', '1996-10-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30079, 30079, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30080, 'Samuel', 'Sandi', '2003-06-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30080, 30080, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30081, 'Alim', 'Sesay', '2006-12-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30081, 30081, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30082, 'Abdul', 'Sesay', '1988-08-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30082, 30082, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30083, 'Favor', 'WeahJr', '1997-02-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30083, 30083, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30084, 'Sulaiman', 'Adegoke', '2002-02-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30084, 30084, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30085, 'Promise', 'Adeyi', '2003-04-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30085, 30085, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30086, 'Ashkon', 'Ashrafiuon', '1998-10-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30086, 30086, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30087, 'Thomas', 'Attamante', '1993-09-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30087, 30087, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30088, 'Mama', 'Bah', '2000-08-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30088, 30088, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30089, 'Cee', 'Brown', '1992-07-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30089, 30089, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30090, 'John', 'Costello', '1994-08-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30090, 30090, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30091, 'patrick', 'cronin', '1998-02-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30091, 30091, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30092, 'Jorge', 'Diaz', '1994-04-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30092, 30092, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30093, 'T-Ben', 'Donnie', '1994-07-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30093, 30093, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30094, 'Oluwaseun', 'Falayi', '2002-10-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30094, 30094, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30095, 'Alfred Wakai', 'Gibson jr', '1992-11-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30095, 30095, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30096, 'Peter', 'Jakubik', '2002-11-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30096, 30096, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30097, 'Mark', 'Manis', '1972-03-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30097, 30097, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30098, 'Kevin', 'Sadeghipour', '1990-02-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30098, 30098, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30099, 'Zouma', 'Sanya', '1999-06-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30099, 30099, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30100, 'Christopher', 'Selekpoh', '2004-09-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30100, 30100, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30101, 'CJ', 'Smolyn', '1997-11-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30101, 30101, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30102, 'Fawaz', 'Somoye', '2005-03-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30102, 30102, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30103, 'Sebastain', 'Stelmach', '1996-03-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30103, 30103, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30104, 'Tonny', 'Temple', '2000-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30104, 30104, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30105, 'Christian', 'Toussaint', '1999-10-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30105, 30105, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30106, 'Henry', 'Tye', '1993-04-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30106, 30106, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30107, 'Bill', 'Wilson', '2002-10-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30107, 30107, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30108, 'Kevin', 'Bowers', '1999-02-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30108, 30108, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30109, 'Emile', 'Diderot', '1998-08-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30109, 30109, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30110, 'Joseph', 'Duddy', '1999-02-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30110, 30110, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30111, 'Ayoub', 'Fask', '2004-03-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30111, 30111, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30112, 'Alexander', 'Graul', '1998-01-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30112, 30112, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30113, 'Brendan', 'Hanratty', '1998-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30113, 30113, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30114, 'Kevin', 'Hanuscin', '1999-09-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30114, 30114, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30115, 'Malcolm', 'Kane', '1995-08-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30115, 30115, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30116, 'Nicholas', 'LeFevre', '1998-09-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30116, 30116, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30117, 'Juan', 'López', '2001-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30117, 30117, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30118, 'Jimmy', 'Manning', '2004-07-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30118, 30118, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30119, 'Alejandro', 'Medina', '1997-02-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30119, 30119, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30120, 'Diego', 'Moreira Pereira', '1992-09-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30120, 30120, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30121, 'Jose', 'Moura Filho', '2006-01-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30121, 30121, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30122, 'Khalidi', 'Ponela', '2004-12-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30122, 30122, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30123, 'Alec', 'Power', '1999-04-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30123, 30123, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30124, 'Jim', 'Power', '1967-05-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30124, 30124, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30125, 'Myles', 'Addy', '1988-10-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30125, 30125, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30126, 'Charles', 'Afful', '1997-02-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30126, 30126, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30127, 'Ahmed', 'Ali', '1997-09-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30127, 30127, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30128, 'Fred', 'Amadi', '1977-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30128, 30128, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30129, 'Edmond', 'Ansah', '2001-05-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30129, 30129, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30130, 'Joe', 'Attakora', '1991-06-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30130, 30130, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30131, 'Christian', 'Bamba', '1995-11-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30131, 30131, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30132, 'Al hassane', 'Belemou', '1993-03-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30132, 30132, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30133, 'Prince', 'Boafo', '1995-06-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30133, 30133, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30134, 'Dilan', 'Carrasco-Palma', '2006-10-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30134, 30134, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30135, 'Michael', 'Danquah', '1995-06-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30135, 30135, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30136, 'Bartels', 'Danquah', '2004-05-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30136, 30136, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30137, 'Joshua', 'Deets', '2002-01-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30137, 30137, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30138, 'Landon', 'Goodison', '2007-03-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30138, 30138, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30139, 'Bernard', 'Kyei-Mensah', '1993-04-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30139, 30139, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30140, 'Imoro', 'latif', '1998-03-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30140, 30140, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30141, 'Trinidad', 'Maldonado', '2006-11-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30141, 30141, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30142, 'Landon', 'Neison', '2007-01-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30142, 30142, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30143, 'Richard', 'Sarpong', '1993-04-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30143, 30143, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30144, 'Kwamina', 'Thompson', '1990-03-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30144, 30144, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30145, 'Patrick', 'Tierney', '2003-12-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30145, 30145, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30146, 'Logan', 'Brock', '2006-10-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30146, 30146, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30147, 'Eljo', 'Agolli', '2003-01-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30147, 30147, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30148, 'Carlos', 'Aroche', '2002-12-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30148, 30148, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30149, 'Jayden', 'Barragan', '2004-10-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30149, 30149, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30150, 'Christian', 'Cardenas', '2002-11-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30150, 30150, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30151, 'Ermal', 'Caushi', '1986-02-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30151, 30151, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30152, 'Ilir', 'Cepani', '1984-11-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30152, 30152, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30153, 'Klevisi', 'Dervishi', '2005-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30153, 30153, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30154, 'Sidiki', 'Fofana', '2002-01-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30154, 30154, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30155, 'Evlad', 'Fonda', '2002-02-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30155, 30155, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30156, 'Zakaria', 'Gueddar', '2007-04-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30156, 30156, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30157, 'Gavin', 'Hagen', '2004-02-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30157, 30157, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30158, 'Mario', 'Kureta', '1997-04-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30158, 30158, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30159, 'Olen', 'Laze', '1984-05-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30159, 30159, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30160, 'Mario', 'Morina', '1995-05-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30160, 30160, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30161, 'Ramadan', 'Nazeraj', '1983-01-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30161, 30161, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30162, 'Youssef', 'Omer', '2004-08-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30162, 30162, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30163, 'Eldion', 'Pajollari', '1984-05-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30163, 30163, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30164, 'Albion', 'Pajollari', '2006-10-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30164, 30164, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30165, 'Elsion', 'Pajollari', '1987-02-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30165, 30165, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30166, 'Brahim', 'Saouid', '2002-08-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30166, 30166, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30167, 'Temur', 'Temirov', '2006-07-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30167, 30167, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30168, 'Achilles', 'Triantafyllos', '2004-10-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30168, 30168, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30169, 'Brendan', 'Werner', '2002-02-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30169, 30169, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30170, 'Victor', 'Baidel', '2004-09-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30170, 30170, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30171, 'Weder', 'Barretos', '2000-11-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30171, 30171, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30172, 'Aboubacar', 'Bayo', '2006-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30172, 30172, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30173, 'Igor', 'Bonfim', '1991-10-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30173, 30173, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30174, 'Samuel', 'Botelho', '1997-01-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30174, 30174, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30175, 'Inaldo', 'Botelho', '1991-05-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30175, 30175, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30176, 'Luke', 'Breslin', '2005-08-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30176, 30176, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30177, 'Walter', 'Candido', '1992-08-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30177, 30177, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30178, 'Christopher', 'Da Silva', '2004-05-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30178, 30178, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30179, 'Nycolas', 'De Jesus', '1998-03-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30179, 30179, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30180, 'Lucas', 'De Morais', '1995-01-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30180, 30180, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30181, 'Abdoul', 'Diallo', '2006-06-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30181, 30181, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30182, 'Cloves', 'Filho', '1997-12-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30182, 30182, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30183, 'Abouya', 'Gangue', '2003-10-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30183, 30183, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30184, 'Andy', 'Hizdri', '2005-02-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30184, 30184, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30185, 'Alexander', 'Lara', '1997-08-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30185, 30185, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30186, 'Pedro', 'Lara', '1999-02-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30186, 30186, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30187, 'Reginaldo', 'Leite', '1981-10-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30187, 30187, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30188, 'Valentino', 'Martinez', '2002-10-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30188, 30188, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30189, 'David', 'Masi', '2002-07-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30189, 30189, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30190, 'John', 'Oladele', '2000-06-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30190, 30190, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30191, 'Junior', 'Oliveira', '1993-09-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30191, 30191, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30192, 'Christian', 'Oliveira', '1998-10-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30192, 30192, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30193, 'Jemirkel', 'Ornaque', '1995-08-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30193, 30193, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30194, 'Marcos', 'Ribeiro', '2000-09-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30194, 30194, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30195, 'Denis', 'Sousa', '1999-12-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30195, 30195, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30196, 'Esnayder', 'Josue', '1998-04-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30196, 30196, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30197, 'Majid', 'Kawa', '2001-12-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30197, 30197, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30198, 'Hamid', 'Afolabi', '2003-01-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30198, 30198, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30199, 'Bassam', 'Ahmed', '2005-03-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30199, 30199, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30200, 'Clement', 'Atebi', '2007-09-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30200, 30200, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30201, 'Nicholas', 'Bowman', '2001-07-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30201, 30201, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30202, 'Donavan', 'Brady', '1999-04-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30202, 30202, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30203, 'Uriel', 'Cabello', '1994-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30203, 30203, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30204, 'Clarence', 'Cole', '2005-03-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30204, 30204, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30205, 'Joseph', 'Cunningham', '1996-06-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30205, 30205, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30206, 'Erick', 'David', '2004-07-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30206, 30206, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30207, 'Tushaar', 'Godbole', '1995-04-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30207, 30207, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30208, 'Benjamin', 'Goudvis', '2000-05-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30208, 30208, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30209, 'Jesse', 'Haines', '1999-03-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30209, 30209, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30210, 'Evan', 'Hodulik', '1994-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30210, 30210, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30211, 'Francis', 'Kanu', '1999-07-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30211, 30211, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30212, 'Alex', 'Kebuz', '2004-08-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30212, 30212, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30213, 'Sean', 'Khazael', '1994-02-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30213, 30213, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30214, 'Osman', 'Lopez', '2003-12-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30214, 30214, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30215, 'Payman', 'Mirzaei', '1996-09-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30215, 30215, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30216, 'Jevin', 'Nathaniel', '1996-04-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30216, 30216, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30217, 'Armando', 'Samukai', '2002-09-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30217, 30217, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30218, 'Michael', 'Sottle', '1997-08-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30218, 30218, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30219, 'Boubacar', 'Traire', '2004-02-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30219, 30219, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30220, 'Hassane', 'Abdellaoui', '1999-07-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30220, 30220, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30221, 'Erwa', 'Babiker', '1996-01-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30221, 30221, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30222, 'Oumar', 'Barry', '2003-10-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30222, 30222, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30223, 'Logan', 'Bersani', '1998-06-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30223, 30223, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30224, 'James', 'Breslin', '1972-07-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30224, 30224, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30225, 'Luis', 'De Jesus', '2007-04-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30225, 30225, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30226, 'Marco', 'Delgado', '2001-12-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30226, 30226, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30227, 'Edwin', 'Garcia', '2006-02-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30227, 30227, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30228, 'John', 'Gonzalez', '2000-01-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30228, 30228, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30229, 'Sangin', 'Hedayatullah', '2007-07-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30229, 30229, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30230, 'Miles', 'Henry', '2000-06-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30230, 30230, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30231, 'Arif', 'Hossain', '2003-12-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30231, 30231, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30232, 'Zuhab', 'Imran', '2006-10-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30232, 30232, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30233, 'Carl', 'Laroche', '1996-10-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30233, 30233, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30234, 'Jervin', 'Lemus', '2007-06-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30234, 30234, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30235, 'Christian', 'Lopez', '2007-06-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30235, 30235, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30236, 'John', 'Madureira', '2006-12-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30236, 30236, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30237, 'Elmer', 'Mendoza', '2003-08-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30237, 30237, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30238, 'Dylan', 'Moreno', '2005-02-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30238, 30238, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30239, 'Ibrahim', 'Nassar', '1993-06-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30239, 30239, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30240, 'Babacar', 'Ndiaye', '2005-02-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30240, 30240, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30241, 'Zion', 'Nwalipenja', '2005-01-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30241, 30241, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30242, 'Fabian', 'Padilla', '1995-11-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30242, 30242, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30243, 'Caleb', 'Rojas', '2001-12-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30243, 30243, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30244, 'Anthony', 'Sagustume', '1995-07-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30244, 30244, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30245, 'Ali', 'Salah', '2007-03-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30245, 30245, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30246, 'Daniel', 'Salmanca', '2007-07-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30246, 30246, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30247, 'Leo', 'Santa', '1977-12-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30247, 30247, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30248, 'Christopher', 'Solis', '2005-10-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30248, 30248, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30249, 'Fritz', 'Amazan', '2000-06-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30249, 30249, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30250, 'David', 'Aquino', '2004-04-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30250, 30250, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30251, 'Christian', 'Aurand', '2000-11-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30251, 30251, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30252, 'TJ', 'Butler', '2002-02-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30252, 30252, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30253, 'Troy', 'Eutermoser', '1996-06-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30253, 30253, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30254, 'Alex', 'Freeman', '2004-06-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30254, 30254, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30255, 'William', 'Hanratty', '2000-01-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30255, 30255, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30256, 'Ryan', 'Kerr', '2004-03-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30256, 30256, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30257, 'Jake', 'Kucowski', '2000-08-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30257, 30257, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30258, 'Rood charleson', 'Labossiere', '1995-04-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30258, 30258, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30259, 'Ed-steeve', 'Madere', '2001-08-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30259, 30259, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30260, 'Daniel', 'Maggio', '1999-02-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30260, 30260, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30261, 'Christopher', 'McDonnell', '1998-09-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30261, 30261, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30262, 'Merabi', 'Megreladze', '1999-10-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30262, 30262, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30263, 'Marc Jerry', 'Midy', '2002-08-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30263, 30263, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30264, 'Giorgi', 'Nikabadze', '2003-10-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30264, 30264, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30265, 'Fran', 'Pitonyak', '1982-08-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30265, 30265, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30266, 'Chris', 'Rutledge', '1994-03-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30266, 30266, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30267, 'Revazi', 'Tcheshmaritashvili', '1993-05-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30267, 30267, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30268, 'Nick', 'Webster', '1992-11-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30268, 30268, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30269, 'Costas', 'Angelis', '1999-06-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30269, 30269, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30270, 'Jesus', 'Colin', '2004-10-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30270, 30270, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30271, 'Bryan', 'Da Silva', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30271, 30271, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30272, 'Yoofi', 'Danquah', '2004-05-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30272, 30272, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30273, 'Bryan', 'De Quadros', '2004-12-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30273, 30273, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30274, 'Robert', 'Ertel', '1993-09-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30274, 30274, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30275, 'Julio', 'Evangilista', '2006-10-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30275, 30275, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30276, 'Ahmed', 'Faik', '1991-04-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30276, 30276, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30277, 'Kaua', 'Freitas', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30277, 30277, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30278, 'Kareem', 'Green', '1998-10-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30278, 30278, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30279, 'Nigel', 'Johnson', '1997-12-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30279, 30279, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30280, 'Paul', 'Kwoyelo', '1990-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30280, 30280, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30281, 'Jonatan', 'Lopez', '2004-11-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30281, 30281, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30282, 'Zach', 'Morrison', '2002-02-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30282, 30282, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30283, 'Diego', 'Murillo', '2005-07-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30283, 30283, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30284, 'Paolo', 'Musumeci', '2004-04-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30284, 30284, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30285, 'Zabi', 'Naseri', '1994-02-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30285, 30285, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30286, 'Roni', 'Rountree', '2000-11-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30286, 30286, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30287, 'Luca', 'Ruggiero', '1991-08-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30287, 30287, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30288, 'Mohammad', 'Sanim', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30288, 30288, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30289, 'Aaron', 'Sexton', '1997-06-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30289, 30289, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30290, 'Lamin', 'Sidibeh', '1989-05-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30290, 30290, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30291, 'Anis', 'Slimane', '2000-06-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30291, 30291, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30292, 'Casey', 'Sorell', '2000-10-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30292, 30292, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30293, 'Cavit', 'ULA', '1996-05-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30293, 30293, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30294, 'Thiago', 'Vazquez', '2003-02-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30294, 30294, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30295, 'Sergio', 'Villanueva', '2001-03-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30295, 30295, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30296, 'Michael', 'Wambold', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30296, 30296, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30297, 'Phillip', 'Washington', '2001-07-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30297, 30297, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30298, 'Michael', 'Abarca', '1991-02-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30298, 30298, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30299, 'Victor', 'Agudelo', '1984-12-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30299, 30299, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30300, 'Jonatan', 'Alberto', '1985-05-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30300, 30300, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30301, 'Colon', 'Anthony', '2003-11-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30301, 30301, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30302, 'Diego', 'Beltran Vega', '1984-08-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30302, 30302, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30303, 'Johan', 'Bolton', '1989-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30303, 30303, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30304, 'Manuel', 'Camayo', '1988-09-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30304, 30304, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30305, 'Errol', 'Castro', '1990-12-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30305, 30305, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30306, 'Carlos', 'Chacon', '1999-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30306, 30306, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30307, 'Jose', 'Duarte', '1981-03-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30307, 30307, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30308, 'Arnoldo', 'Emeiler', '2000-07-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30308, 30308, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30309, 'Balron', 'Escobar', '2002-09-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30309, 30309, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30310, 'Marcelo', 'Gamboa', '1995-10-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30310, 30310, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30311, 'Miguel', 'Garcia', '1997-10-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30311, 30311, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30312, 'Juan Carlos', 'Guevara', '1985-03-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30312, 30312, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30313, 'Gustavo', 'Guitierez Cuervo', '1992-04-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30313, 30313, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30314, 'Fabricio', 'Guzman', '2004-07-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30314, 30314, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30315, 'Smaikel Sibaja', 'Guzman', '1998-09-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30315, 30315, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30316, 'Eder', 'Guzman', '1982-01-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30316, 30316, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30317, 'Danior', 'Hernandez', '1995-02-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30317, 30317, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30318, 'Yerald', 'Jimenez', '2001-02-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30318, 30318, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30319, 'Maicol', 'Martinez', '1982-12-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30319, 30319, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30320, 'Obed', 'Mayorga Curtis', '1987-10-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30320, 30320, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30321, 'Melber', 'Ortega', '2001-10-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30321, 30321, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30322, 'Gelder', 'Ortiz', '1994-05-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30322, 30322, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30323, 'Joseph', 'Piedra Retana', '1998-01-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30323, 30323, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30324, 'Luis', 'Retana', '2000-10-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30324, 30324, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30325, 'Ronny', 'Rodriquez', '1993-12-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30325, 30325, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30326, 'Alexander', 'Rodriquez', '1999-12-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30326, 30326, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30327, 'Andres', 'Rojas', '2003-08-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30327, 30327, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30328, 'Kenneth', 'Salazar', '2000-01-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30328, 30328, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30329, 'Adilcer', 'Santiago', '2003-08-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30329, 30329, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30330, 'Axel', 'Villanueva', '1993-10-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30330, 30330, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30331, 'Sergio', 'Zuluaga', '1996-12-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30331, 30331, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30332, 'Alexander', 'Garcia', '2006-06-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30332, 30332, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30333, 'Jeshohaih', 'Hernandez', '2005-09-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30333, 30333, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30334, 'Adam', 'Leal', '2006-02-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30334, 30334, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30335, 'Alexander', 'Patton', '2006-02-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30335, 30335, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30336, 'Fred', 'Renzulli', '2002-11-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30336, 30336, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30337, 'Jackson', 'Stuetz', '2006-07-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30337, 30337, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30338, 'Joseph', 'Romano', '2004-02-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30338, 30338, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30339, 'Hector Ivan', 'Acosta', '1994-07-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30339, 30339, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30340, 'Yousef', 'Atrous', '2001-04-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30340, 30340, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30341, 'James', 'Barden', '2000-04-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30341, 30341, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30342, 'Oseche', 'Buliro', '2003-10-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30342, 30342, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30343, 'John', 'Burke', '2000-09-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30343, 30343, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30344, 'Kevin', 'Callanan', '1998-11-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30344, 30344, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30345, 'Michael', 'Chang', '1999-12-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30345, 30345, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30346, 'Andrew', 'Cooke', '2001-09-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30346, 30346, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30347, 'Alex', 'Cooper-Hohn', '2001-06-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30347, 30347, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30348, 'Leon', 'Djusberg', '2000-03-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30348, 30348, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30349, 'Trey', 'Donovan', '2000-11-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30349, 30349, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30350, 'Irobosa', 'Enabulele', '2000-07-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30350, 30350, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30351, 'Jack', 'Garrity', '2002-04-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30351, 30351, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30352, 'Kevin', 'Gilligan', '1999-11-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30352, 30352, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30353, 'Ian', 'Goodine', '1999-06-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30353, 30353, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30354, 'Trevor', 'Grafton', '2005-01-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30354, 30354, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30355, 'Nicholas', 'Harper', '2000-03-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30355, 30355, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30356, 'Josh', 'Harper', '2000-03-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30356, 30356, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30357, 'James', 'Helf', '1998-02-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30357, 30357, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30358, 'Lewis', 'Mustoe', '1998-03-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30358, 30358, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30359, 'Osasenaga', 'Owens', '2002-02-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30359, 30359, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30360, 'Nathan', 'Plano', '1999-03-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30360, 30360, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30361, 'Jack', 'Sarkisian', '1999-04-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30361, 30361, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30362, 'Joaquin', 'Silvani', '2002-11-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30362, 30362, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30363, 'Stanislaus', 'Sokolov', '1999-05-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30363, 30363, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30364, 'Kohei', 'Tomita', '1999-06-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30364, 30364, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30365, 'Tomas', 'Trejo', '2001-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30365, 30365, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30366, 'Caleb', 'Weinstock', '1999-12-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30366, 30366, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30367, 'Moycir', 'Amarante', '2003-10-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30367, 30367, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30368, 'Ryan', 'Beardsley', '2001-10-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30368, 30368, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30369, 'Thomas', 'Bell', '1994-11-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30369, 30369, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30370, 'Jaime', 'Cortez', '2006-09-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30370, 30370, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30371, 'Jah', 'Cyrus', '1993-04-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30371, 30371, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30372, 'Raney', 'Figueiredo', '2005-09-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30372, 30372, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30373, 'Paolo', 'Filippi', '1997-12-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30373, 30373, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30374, 'Alpha', 'Fofanah', '1997-09-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30374, 30374, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30375, 'Patrick', 'Freire', '2005-10-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30375, 30375, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30376, 'Matheus', 'Gomes', '2007-02-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30376, 30376, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30377, 'Ronnie', 'Gomez', '1997-02-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30377, 30377, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30378, 'Matthew', 'Kearney', '1992-04-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30378, 30378, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30379, 'Ousmane', 'Keita', '1995-10-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30379, 30379, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30380, 'William', 'Martinez', '2006-07-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30380, 30380, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30381, 'Ryan', 'McGourty', '2005-04-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30381, 30381, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30382, 'Zion', 'Monteiro', '2004-03-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30382, 30382, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30383, 'Alejandro', 'Monterroso', '2006-12-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30383, 30383, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30384, 'Gracian', 'Moreira', '2004-06-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30384, 30384, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30385, 'Carlos', 'Neves', '2005-02-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30385, 30385, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30386, 'Lucas', 'Oliveira', '2006-10-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30386, 30386, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30387, 'Felipe', 'Palacio', '2001-11-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30387, 30387, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30388, 'Markelos', 'Papa', '2007-03-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30388, 30388, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30389, 'Angelos', 'Papa', '2003-06-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30389, 30389, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30390, 'Michael', 'Rendon', '1995-01-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30390, 30390, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30391, 'Edson', 'Robledano', '1992-03-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30391, 30391, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30392, 'gustavo', 'sampaio', '2007-07-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30392, 30392, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30393, 'Tjamael', 'Sillah', '2004-01-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30393, 30393, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30394, 'William', 'Sousa', '2003-06-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30394, 30394, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30395, 'Vlad', 'Ventura', '1998-06-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30395, 30395, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30396, 'Albert', 'Williams', '1994-02-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30396, 30396, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30397, 'Marouen', 'Ben Guebila', '1986-09-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30397, 30397, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30398, 'Muhammad Uzair', 'Butt', '1998-05-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30398, 30398, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30399, 'Fredy', 'Castillo Hernandez', '1989-07-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30399, 30399, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30400, 'Ethan', 'Champlin', '2003-04-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30400, 30400, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30401, 'Kevin', 'De Leon', '2002-06-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30401, 30401, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30402, 'Ian', 'Dhar', '2003-02-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30402, 30402, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30403, 'William', 'Garcia', '1984-11-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30403, 30403, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30404, 'Joshua', 'Hardester', '1981-09-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30404, 30404, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30405, 'Norman', 'Jimenez Laverde', '1989-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30405, 30405, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30406, 'Andrew', 'Lee', '1999-07-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30406, 30406, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30407, 'Mateus', 'Loesch', '1992-10-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30407, 30407, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30408, 'Austin', 'MBaye', '2002-05-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30408, 30408, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30409, 'Sam', 'McGrath', '1995-06-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30409, 30409, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30410, 'Mike', 'Mizhirumbay', '2004-03-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30410, 30410, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30411, 'Leo', 'Mosquera', '1990-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30411, 30411, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30412, 'Matt', 'Mourges', '1993-08-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30412, 30412, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30413, 'Kevin', 'Ortiz', '1992-03-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30413, 30413, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30414, 'Jose', 'Osorto', '1997-12-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30414, 30414, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30415, 'Haorui', 'Qin', '2007-06-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30415, 30415, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30416, 'Daniel', 'Ra', '1992-10-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30416, 30416, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30417, 'Ethan', 'Rowe', '1999-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30417, 30417, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30418, 'Rafael', 'Santos', '1989-04-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30418, 30418, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30419, 'Harrison', 'Snodgrass', '1993-06-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30419, 30419, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30420, 'Marshall', 'Tekell', '1996-01-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30420, 30420, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30421, 'Jose', 'Velazquez', '1997-12-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30421, 30421, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30422, 'Gabriel', 'Barbosa', '2004-01-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30422, 30422, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30423, 'Juliano', 'Bento', '1996-09-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30423, 30423, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30424, 'Andrés', 'Bustamante', '1996-02-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30424, 30424, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30425, 'Itamar', 'Caldeira', '2000-05-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30425, 30425, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30426, 'Vinicius', 'De Oliveira', '2005-04-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30426, 30426, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30427, 'William', 'Dos Santos', '2000-07-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30427, 30427, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30428, 'Leonardo', 'Fortunato', '1994-12-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30428, 30428, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30429, 'Lucas', 'Franco', '1998-08-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30429, 30429, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30430, 'Javier', 'Garcia', '2000-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30430, 30430, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30431, 'edson', 'junior', '2003-01-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30431, 30431, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30432, 'Diego', 'Lorett', '1997-03-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30432, 30432, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30433, 'Vitor', 'Magalhaes', '2004-03-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30433, 30433, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30434, 'Juann', 'Melo', '2001-10-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30434, 30434, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30435, 'Frank', 'Messina', '1997-04-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30435, 30435, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30436, 'Sidnei', 'Monteiro', '1982-02-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30436, 30436, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30437, 'Jefferson', 'Oliveira', '1995-07-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30437, 30437, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30438, 'Lenine', 'Pereira', '1995-12-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30438, 30438, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30439, 'Wenderson Kenedy', 'Pereira', '1999-10-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30439, 30439, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30440, 'Gustavo', 'Ribeiro', '2000-11-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30440, 30440, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30441, 'Marek', 'Rutkowki', '2005-08-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30441, 30441, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30442, 'Malek', 'Sakhri', '2006-01-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30442, 30442, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30443, 'Souare', 'Saliou', '2001-02-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30443, 30443, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30444, 'Silvio', 'Silva', '2002-08-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30444, 30444, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30445, 'Marcos', 'Souto', '2002-10-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30445, 30445, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30446, 'Jhordan', 'Souza', '1998-05-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30446, 30446, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30447, 'Carlos', 'Teixeira', '2000-02-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30447, 30447, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30448, 'Elton j', 'Teixeira', '1991-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30448, 30448, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30449, 'Willian', 'Zanetti', '2001-04-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30449, 30449, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30450, 'Elohim', 'Alves', '2004-02-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30450, 30450, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30451, 'Luis', 'Araujo', '2003-12-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30451, 30451, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30452, 'Wesley', 'Borges', '1985-05-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30452, 30452, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30453, 'Adriel', 'Cordeiro', '1989-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30453, 30453, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30454, 'Wagner', 'Da Silva', '1998-11-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30454, 30454, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30455, 'Luan', 'De Souza', '1992-01-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30455, 30455, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30456, 'Carlos', 'De Souza', '1977-01-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30456, 30456, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30457, 'Israel', 'Duarte', '2001-04-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30457, 30457, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30458, 'Gabriel', 'Fernandes', '2001-09-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30458, 30458, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30459, 'Marcelino', 'Ferreira', '2003-06-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30459, 30459, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30460, 'Walafy', 'Leonor', '1993-09-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30460, 30460, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30461, 'Felipe', 'Lopes', '2006-05-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30461, 30461, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30462, 'Gustavo', 'Lopes', '2002-06-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30462, 30462, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30463, 'Raimon', 'marques', '1990-04-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30463, 30463, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30464, 'Rafael', 'Medeiros', '1996-02-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30464, 30464, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30465, 'Leandro', 'Pereira Ramos.', '1992-10-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30465, 30465, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30466, 'Leandro', 'Pires', '1995-01-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30466, 30466, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30467, 'Douglas', 'Pires', '1989-09-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30467, 30467, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30468, 'Leandro', 'Ramos', '1988-04-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30468, 30468, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30469, 'Caique', 'Reginaldo', '1995-02-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30469, 30469, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30470, 'Eduardo', 'Reis', '1999-01-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30470, 30470, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30471, 'Maxsuel', 'Ribeiro', '1995-10-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30471, 30471, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30472, 'Luis', 'Santos', '1996-08-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30472, 30472, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30473, 'Vanilson', 'Santos', '1998-09-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30473, 30473, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30474, 'Deyvit', 'Silva', '1994-11-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30474, 30474, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30475, 'Wenderson', 'Silva', '1999-05-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30475, 30475, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30476, 'Pedro', 'Silva', '1993-06-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30476, 30476, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30477, 'Eder', 'Amado', '1989-11-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30477, 30477, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30478, 'Helton', 'Brandao', '2003-02-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30478, 30478, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30479, 'Yuri', 'Brandao', '1996-06-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30479, 30479, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30480, 'Derik', 'Brito', '2002-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30480, 30480, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30481, 'Erick', 'Brito', '2002-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30481, 30481, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30482, 'Belvick', 'da Silva', '2000-09-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30482, 30482, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30483, 'Brandon', 'Daluz', '2003-10-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30483, 30483, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30484, 'Jaylon', 'Darosa', '2002-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30484, 30484, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30485, 'Janilson', 'Debrito', '2007-11-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30485, 30485, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30486, 'Jayden', 'Depina', '2003-11-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30486, 30486, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30487, 'Lucas', 'Fernandes', '2002-04-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30487, 30487, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30488, 'Luis', 'Fortes', '2006-04-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30488, 30488, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30489, 'Ty', 'Gomes', '2000-12-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30489, 30489, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30490, 'Jorge', 'Goncalves', '1999-12-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30490, 30490, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30491, 'Ricardo', 'Monteiro', '2004-10-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30491, 30491, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30492, 'Carlos', 'Morais', '2003-06-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30492, 30492, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30493, 'Gracian', 'Moreira', '2004-06-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30493, 30493, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30494, 'Dany', 'Pina', '1994-11-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30494, 30494, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30495, 'Johnathan', 'Pires', '1996-06-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30495, 30495, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30496, 'Danny', 'Resende', '2002-03-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30496, 30496, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30497, 'Anthony', 'Rodrigues', '2003-04-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30497, 30497, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30498, 'Jonathan', 'Rodrigues', '2000-12-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30498, 30498, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30499, 'Jeremias', 'Rosa', '2003-05-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30499, 30499, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30500, 'Kevin', 'Soares', '1995-08-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30500, 30500, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30501, 'Junior', 'Tavares', '2001-07-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30501, 30501, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30502, 'Edmilson', 'Vaz Tavares', '1998-07-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30502, 30502, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30503, 'Vanilton', 'Xavier', '2003-08-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30503, 30503, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30504, 'Mohammed', 'Abdulrahman', '1998-01-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30504, 30504, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30505, 'Omar', 'Ahmed', '2002-08-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30505, 30505, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30506, 'Zain', 'AL-Ashoor', '1999-02-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30506, 30506, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30507, 'Elhadj', 'Bah', '2003-03-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30507, 30507, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30508, 'Ethan', 'Buss', '2006-08-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30508, 30508, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30509, 'Shamanuel', 'Dominique', '2004-10-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30509, 30509, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30510, 'Filip', 'Dordevic', '2002-02-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30510, 30510, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30511, 'Habib', 'Emami', '1997-06-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30511, 30511, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30512, 'Yeremosi', 'Foste', '2005-11-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30512, 30512, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30513, 'Terah', 'Garnett', '1992-11-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30513, 30513, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30514, 'Ermias', 'Getnet', '1997-09-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30514, 30514, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30515, 'Jesse', 'Gutierrez', '1999-10-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30515, 30515, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30516, 'Mohammed', 'Hassan', '1997-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30516, 30516, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30517, 'Miguel', 'Ikomo', '1995-10-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30517, 30517, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30518, 'Stylianos', 'Ioannou', '2005-03-29') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30518, 30518, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30519, 'Samuel', 'Kihorezo', '2000-02-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30519, 30519, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30520, 'Joshua', 'Logan', '1998-09-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30520, 30520, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30521, 'Abdoul', 'Mamaoudou', '2002-02-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30521, 30521, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30522, 'John', 'Moore', '1989-10-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30522, 30522, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30523, 'Moussa', 'Oumarou', '2006-01-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30523, 30523, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30524, 'Edicson', 'Sabogal', '2004-01-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30524, 30524, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30525, 'Fernando', 'Salazar', '2005-11-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30525, 30525, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30526, 'Gerrit', 'Stech', '2002-02-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30526, 30526, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30527, 'Shengda', 'Sun Lopez', '2004-01-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30527, 30527, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30528, 'Daniel', 'Tema', '2002-08-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30528, 30528, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30529, 'Makan', 'Traore', '2003-11-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30529, 30529, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30530, 'Robby', 'Waller', '1990-04-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30530, 30530, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30531, 'Jereme', 'Wells', '1996-10-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30531, 30531, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30532, 'Shenoda', 'Youssef', '1997-08-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30532, 30532, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30533, 'Robby', 'Waller', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30533, 30533, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30534, 'Harein', 'Abeysekera', '2005-05-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30534, 30534, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30535, 'Sebastian', 'Carrilo', '2003-09-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30535, 30535, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30536, 'Drake', 'DeJute', '2004-04-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30536, 30536, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30537, 'Kabeer', 'Ferhan', '2006-03-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30537, 30537, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30538, 'Jackson', 'Hellmann', '2005-06-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30538, 30538, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30539, 'Marc', 'Iglesias', '2007-07-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30539, 30539, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30540, 'Yussif Attabio', 'Ismail', '2003-05-23') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30540, 30540, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30541, 'An', 'Jaeyun', '2001-09-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30541, 30541, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30542, 'Parth', 'Karki', '2007-06-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30542, 30542, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30543, 'Sergio', 'Marin Miralles', '2004-05-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30543, 30543, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30544, 'Calix', 'Milligan', '2004-07-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30544, 30544, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30545, 'Adeon', 'Muyskens', '2003-02-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30545, 30545, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30546, 'Faisal', 'Niazi', '2004-02-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30546, 30546, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30547, 'Vincent', 'Okyere', '2007-02-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30547, 30547, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30548, 'Devin', 'Putnam', '2005-03-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30548, 30548, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30549, 'Bernard', 'Sakyi', '2003-12-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30549, 30549, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30550, 'Jordan', 'Samuels', '2003-04-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30550, 30550, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30551, 'Sanzhar', 'Sarynzhiev', '2007-03-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30551, 30551, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30552, 'Sam', 'Scherzer', '2007-02-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30552, 30552, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30553, 'Gabriel Antonio', 'Silva Gomes', '2006-04-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30553, 30553, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30554, 'Benjamin', 'Winograd', '2005-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30554, 30554, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30555, 'Muhyadin', 'Yusuf', '2003-05-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30555, 30555, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30556, 'Alex', 'Jacobs', '2004-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30556, 30556, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30557, 'Christopher', 'Wann', '2006-02-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30557, 30557, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30558, 'Mohammed', 'Al Qudsi', '1997-08-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30558, 30558, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30559, 'Gurnoor', 'Bagri', '2008-01-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30559, 30559, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30560, 'Quinn', 'Bertoncini-Troutman', '2006-08-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30560, 30560, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30561, 'Braedon', 'Bickford', '2006-11-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30561, 30561, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30562, 'Albert', 'Corea', '2004-07-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30562, 30562, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30563, 'Dylan', 'Crills', '2007-09-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30563, 30563, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30564, 'Amini', 'Diye', '2007-02-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30564, 30564, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30565, 'Vincent', 'Edmond', '2007-12-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30565, 30565, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30566, 'Chri', 'Ehgay', '2004-10-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30566, 30566, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30567, 'Ian', 'Frisbie', '2005-04-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30567, 30567, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30568, 'Mason', 'Harris', '2005-12-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30568, 30568, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30569, 'Bita', 'Imani', '2007-06-10') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30569, 30569, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30570, 'Michael', 'Kasampilo', '2004-06-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30570, 30570, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30571, 'Asende', 'Lubende', '2000-12-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30571, 30571, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30572, 'Faustin', 'Mucunguzi', '2003-01-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30572, 30572, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30573, 'Jack', 'Ngoy', '2005-12-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30573, 30573, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30574, 'Ibrahim', 'Ntege', '2004-06-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30574, 30574, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30575, 'Brandon', 'Perez', '2004-09-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30575, 30575, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30576, 'Lata', 'Petros', '1997-09-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30576, 30576, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30577, 'Gavin', 'Roberts', '2006-09-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30577, 30577, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30578, 'Ben', 'Singizwa', '2005-07-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30578, 30578, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30579, 'Babo', 'Tereffe', '1999-04-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30579, 30579, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30580, 'Gavin', 'Wiley', '1998-06-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30580, 30580, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30581, 'Antonio', 'Alonso-Hernandez', '2006-09-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30581, 30581, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30582, 'Daniel', 'Arraiz', '2003-11-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30582, 30582, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30583, 'Daviont', 'Baker-Alston', '2005-02-07') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30583, 30583, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30584, 'Lucas', 'Cherniak', '2004-03-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30584, 30584, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30585, 'Andrew', 'Cui', '2007-01-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30585, 30585, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30586, 'Blake', 'Deluca', '2004-09-13') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30586, 30586, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30587, 'Matthew', 'DiCarlo', '2005-08-17') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30587, 30587, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30588, 'Sleem', 'Emam', '2006-05-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30588, 30588, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30589, 'Rhenan', 'Ferreira', '2006-03-31') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30589, 30589, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30590, 'Aiden', 'Fogarty', '2006-03-28') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30590, 30590, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30591, 'Leonardo', 'Guzman', '2006-08-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30591, 30591, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30592, 'Luke', 'Jones', '2005-03-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30592, 30592, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30593, 'Samuel', 'Kaganzev', '2006-05-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30593, 30593, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30594, 'William', 'Maurek', '2005-11-16') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30594, 30594, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30595, 'Jared', 'Mikloski', '2006-07-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30595, 30595, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30596, 'Logan', 'Rogers', '2007-04-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30596, 30596, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30597, 'Ethan', 'Schrampf', '2005-09-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30597, 30597, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30598, 'Alex', 'Schrampf', '2006-12-26') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30598, 30598, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30599, 'Caden', 'Thompson', '2007-03-19') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30599, 30599, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30600, 'David', 'Turchi', '2006-04-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30600, 30600, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30601, 'Johnny', 'Turchi', '2006-04-20') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30601, 30601, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30602, 'Jacob', 'Warner', '2006-08-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30602, 30602, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30603, 'Koye', 'Whitman', '2003-09-08') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30603, 30603, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30604, 'Tim', 'Zellner', '2006-08-18') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30604, 30604, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30605, 'Erick', 'Bernal', '1998-01-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30605, 30605, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30606, 'Jordan', 'Brubaker', '1993-01-03') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30606, 30606, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30607, 'Ian', 'Byrnes', '1995-12-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30607, 30607, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30608, 'Julian', 'Carvajal', '1990-12-15') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30608, 30608, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30609, 'Joel', 'Chachapoya', '1996-07-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30609, 30609, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30610, 'Andrea', 'DiSomma', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30610, 30610, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30611, 'Tyler', 'Hambright', '2004-11-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30611, 30611, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30612, 'Jessie', 'Herb', '1996-05-14') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30612, 30612, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30613, 'Shaquille', 'Hudson', '1991-03-12') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30613, 30613, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30614, 'Asher', 'Klahold', '1993-09-22') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30614, 30614, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30615, 'Jordan', 'McMullen', '1997-08-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30615, 30615, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30616, 'Alex', 'Morales', '2000-01-11') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30616, 30616, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30617, 'Garmonger', 'Morris', '1990-10-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30617, 30617, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30618, 'Caden', 'Mullen', '2005-06-02') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30618, 30618, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30619, 'Zach', 'Oster', '1993-12-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30619, 30619, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30620, 'Nikita', 'Patrushev', '1998-07-01') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30620, 30620, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30621, 'Joshua', 'Patrushey', NULL) 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30621, 30621, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30622, 'Andrey', 'Patrushey', '1999-11-09') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30622, 30622, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30623, 'Aaron', 'Pearson', '1986-09-24') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30623, 30623, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30624, 'Josiah', 'Schendel', '1994-11-06') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30624, 30624, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30625, 'Chris', 'Sosa', '1994-11-30') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30625, 30625, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30626, 'Daniel', 'Sosa', '1991-08-21') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30626, 30626, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30627, 'Ashton', 'Taughinbaugh', '1987-09-05') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30627, 30627, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30628, 'Michael', 'Tolley', '1997-09-04') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30628, 30628, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30629, 'Andrew', 'Weaver', '1996-03-27') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30629, 30629, 2) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO persons (id, first_name, last_name, birth_date) 
VALUES (30630, 'Tye', 'White', '2005-06-25') 
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id) 
VALUES (30630, 30630, 2) 
ON CONFLICT (id) DO NOTHING;

