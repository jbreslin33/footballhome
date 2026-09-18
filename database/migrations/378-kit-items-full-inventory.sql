-- 378: Kit board — the full kit inventory for every team
--
-- #kit tracked only the training shirt and pinnie. The club hands out a
-- whole kit: shin pads, socks, shorts and jerseys in both colours. These are
-- kit_items rows (mig 373), so every team's board grows the columns with no
-- screen change. The two existing items keep their code and id — issues
-- already ticked stay ticked — and only take their proper names.

BEGIN;

INSERT INTO kit_items (code, label, icon, sort_order) VALUES
    ('shin_pads',     'Shin Pads',     '🛡️',   10),
    ('socks_blue',    'Blue Socks',    '🔵🧦', 20),
    ('socks_white',   'White Socks',   '⚪🧦', 30),
    ('shorts_blue',   'Blue Shorts',   '🔵🩳', 40),
    ('shorts_white',  'White Shorts',  '⚪🩳', 50),
    ('jersey_blue',   'Blue Jersey',   '🔵👕', 60),
    ('jersey_white',  'White Jersey',  '⚪👕', 70)
ON CONFLICT (code) DO NOTHING;

UPDATE kit_items SET label = 'Blue Training Shirt', sort_order = 80
 WHERE code = 'training_shirt';

UPDATE kit_items SET label = 'Red/White Pinnie', sort_order = 90
 WHERE code = 'training_pinnie';

COMMIT;
