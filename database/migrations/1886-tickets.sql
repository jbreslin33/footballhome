-- 1886 (2026-11-24) — 🎟 Tickets: season and single-game tickets for
-- Lighthouse home games, sold in LeagueApps or at the gate, scanned by QR.
--
-- Owner 11/24: "can we sell season tickets and singlge game tickets via fh
-- and la? so la would be used to collect but fh would give bar code for scan
-- and track etc" · "we can accept cash at the gate and we can accept venmo,
-- cashapp zelle too but they have to show it to us lol" · LA products, not
-- programs (LA docs: "Quantity is captured by default"); first product
-- 127755 "Season Ticket" $12.50, all APSL regular-season home games (5
-- left), owner bought 2 on 11/24.
--
-- How it works:
--   ticket_products  what is sold: a season ticket (every home match of its
--                    league in its window) or a single-game ticket (good for
--                    the one game written on the ticket).  la_product_id ties
--                    a LeagueApps eCommerce product to it.
--   tickets          one row per purchase: admits = how many people it lets
--                    in per game (LA order quantity, or the gate count).
--                    token = the secret in the QR and the private link
--                    /t/?k=<token>.  source_code = where it was paid.
--   ticket_holders   who bought it: LA buyer (la_user_id, from the LA
--                    members API) or a gate buyer who gave a name/phone.
--                    Matched to persons when the LA user is a club member.
--                    PII lives here only, never in a migration.
--   ticket_scans     every admit at the gate (who scanned, which game, how
--                    many people).  A ticket admits at most `admits` people
--                    per game.
--   gate_counts      the +1 / −1 counter for people let in without a ticket.
--   ticket_gate_staff  who besides club admins may work the gate page.
-- LA orders are pulled by the backend (TicketOrderSync) from
-- /v2/sites/{site}/export/product-orders?program-id=0 every few minutes.

BEGIN;

CREATE TABLE IF NOT EXISTS ticket_sources (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    icon        text NOT NULL,
    is_gate     boolean NOT NULL DEFAULT false,   -- offered on the gate page's Sell form
    sort_order  int  NOT NULL DEFAULT 100
);
COMMENT ON TABLE ticket_sources IS 'mig 1886: where a ticket was paid (LeagueApps, gate cash/Venmo/Cash App/Zelle, free).';

INSERT INTO ticket_sources (code, label, icon, is_gate, sort_order) VALUES
    ('leagueapps', 'LeagueApps', '🌐', false, 1),
    ('cash',       'Cash',       '💵', true,  2),
    ('venmo',      'Venmo',      '📱', true,  3),
    ('cashapp',    'Cash App',   '📱', true,  4),
    ('zelle',      'Zelle',      '📱', true,  5),
    ('free',       'Free',       '🎁', true,  6)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS ticket_products (
    id             serial PRIMARY KEY,
    code           text NOT NULL UNIQUE,
    label          text NOT NULL,
    kind           text NOT NULL CHECK (kind IN ('season', 'single')),
    price          numeric(8,2) NOT NULL,
    league         text,                 -- season: home matches of this fh_events.league
    valid_from     date,                 -- season window (inclusive)
    valid_to       date,
    la_product_id  text UNIQUE,          -- LeagueApps eCommerce product id
    buy_url        text,                 -- where the public /tickets page sends buyers
    is_on_sale     boolean NOT NULL DEFAULT true,   -- listed on /tickets
    is_active      boolean NOT NULL DEFAULT true,
    sort_order     int NOT NULL DEFAULT 100,
    created_at     timestamptz NOT NULL DEFAULT now(),
    CHECK (kind <> 'season' OR (league IS NOT NULL AND valid_from IS NOT NULL AND valid_to IS NOT NULL))
);
COMMENT ON TABLE ticket_products IS 'mig 1886: what is sold. season = every home match of `league` from valid_from to valid_to; single = the one game on the ticket.';

INSERT INTO ticket_products (code, label, kind, price, league, valid_from, valid_to, la_product_id, buy_url, is_on_sale, sort_order) VALUES
    ('season-2026-27-apsl', 'Season Ticket — APSL home games', 'season', 12.50, 'APSL',
     DATE '2026-11-24', DATE '2027-07-31', '127755',
     'https://lighthouse1893.leagueapps.com/products/127755-season-ticket', true, 1),
    ('single-game', 'Single game', 'single', 5.00, NULL, NULL, NULL, NULL, NULL, false, 2)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS ticket_holders (
    id          serial PRIMARY KEY,
    la_user_id  bigint UNIQUE,
    person_id   int REFERENCES persons(id),
    first_name  text,
    last_name   text,
    email       text,
    phone       text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE ticket_holders IS 'mig 1886: ticket buyers. LA buyers keyed by la_user_id (contact from the LA members API); gate buyers by what they gave. person_id when they are a club member.';

CREATE TABLE IF NOT EXISTS tickets (
    id                   serial PRIMARY KEY,
    product_id           int NOT NULL REFERENCES ticket_products(id),
    holder_id            int REFERENCES ticket_holders(id),
    source_code          text NOT NULL REFERENCES ticket_sources(code),
    fh_event_id          bigint REFERENCES fh_events(id),   -- single-game tickets: the game
    admits               int NOT NULL DEFAULT 1 CHECK (admits > 0),
    amount               numeric(8,2) NOT NULL DEFAULT 0,
    token                text NOT NULL UNIQUE DEFAULT replace(gen_random_uuid()::text, '-', ''),
    la_product_order_id  bigint UNIQUE,
    sold_by_person_id    int REFERENCES persons(id),
    created_at           timestamptz NOT NULL DEFAULT now(),
    voided_at            timestamptz
);
COMMENT ON TABLE tickets IS 'mig 1886: one per purchase; admits = people per game; token = QR + private link /t/?k=<token>.';
CREATE INDEX IF NOT EXISTS tickets_event_idx ON tickets (fh_event_id) WHERE fh_event_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS ticket_scans (
    id                    serial PRIMARY KEY,
    ticket_id             int NOT NULL REFERENCES tickets(id),
    fh_event_id           bigint NOT NULL REFERENCES fh_events(id),
    admitted              int NOT NULL CHECK (admitted > 0),
    scanned_by_person_id  int REFERENCES persons(id),
    scanned_at            timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE ticket_scans IS 'mig 1886: every admit at the gate.';
CREATE INDEX IF NOT EXISTS ticket_scans_event_idx ON ticket_scans (fh_event_id, ticket_id);

CREATE TABLE IF NOT EXISTS gate_counts (
    id           serial PRIMARY KEY,
    fh_event_id  bigint NOT NULL REFERENCES fh_events(id),
    person_id    int REFERENCES persons(id),
    n            int NOT NULL CHECK (n IN (1, -1)),
    counted_at   timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE gate_counts IS 'mig 1886: +1/−1 for people let in without a ticket.';

CREATE TABLE IF NOT EXISTS ticket_gate_staff (
    person_id  int PRIMARY KEY REFERENCES persons(id),
    added_at   timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE ticket_gate_staff IS 'mig 1886: may work the #tickets gate page besides club admins.';

CREATE TABLE IF NOT EXISTS ticket_order_sync_state (
    id          int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    last_run_at timestamptz,
    last_error  text
);
INSERT INTO ticket_order_sync_state (id) VALUES (1) ON CONFLICT DO NOTHING;

-- 📍 Menu: Money → 🎟 Tickets.
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, is_active)
SELECT 'tickets', 'money', 'Tickets', '🎟', 'admin', 10, ARRAY['tickets'], true
WHERE NOT EXISTS (SELECT 1 FROM menu_pages WHERE code = 'tickets');

-- Wording.  client_side rows = the #tickets screen; is_public rows = the
-- standalone ticket page /t/ and the public /tickets/ page.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Tickets', v.label, 'tickets', v.tier, v.body, v.o, true, v.pub
  FROM (VALUES
    ('Tickets — pill: gate',            'pill_gate',      'Gate', 1, false),
    ('Tickets — pill: tickets',         'pill_list',      'Tickets', 2, false),
    ('Tickets — no home games',         'no_games',       'No home games in the next two weeks.', 3, false),
    ('Tickets — pick a game',           'pick_game',      'Game', 4, false),
    ('Tickets — scan button',           'scan',           '📷 Scan ticket', 5, false),
    ('Tickets — stop scanning',         'scan_stop',      'Stop', 6, false),
    ('Tickets — camera unavailable',    'camera_none',    'The camera is not available. Type the code from the ticket instead.', 7, false),
    ('Tickets — type code',             'code_ph',        'Ticket code', 8, false),
    ('Tickets — check code',            'code_go',        'Check', 9, false),
    ('Tickets — admitted',              'ok',             '✅ Let in {n}', 10, false),
    ('Tickets — already used',          'used',           '❌ Already used for this game', 11, false),
    ('Tickets — not valid',             'invalid',        '❌ Not a valid ticket', 12, false),
    ('Tickets — wrong game',            'wrong_game',     '❌ Not valid for this game', 13, false),
    ('Tickets — voided',                'voided',         '❌ This ticket was cancelled', 14, false),
    ('Tickets — walk-ups',              'walkups',        'Let in without a ticket', 15, false),
    ('Tickets — sell heading',          'sell',           'Sell at the gate', 16, false),
    ('Tickets — sell people',           'sell_people',    'People', 17, false),
    ('Tickets — sell amount',           'sell_amount',    'Amount $', 18, false),
    ('Tickets — sell name',             'sell_name',      'Name (optional)', 19, false),
    ('Tickets — sell phone',            'sell_phone',     'Phone (optional)', 20, false),
    ('Tickets — sell check',            'sell_check',     'Check the payment on their phone (Venmo, Cash App, Zelle) before tapping Paid.', 21, false),
    ('Tickets — sell button',           'sell_go',        'Paid — let in', 22, false),
    ('Tickets — sold',                  'sold',           '✅ Sold and let in {n}', 23, false),
    ('Tickets — count heading',         'count',          'At the gate', 24, false),
    ('Tickets — count tickets',         'count_tickets',  'With a ticket', 25, false),
    ('Tickets — count walk-ups',        'count_walkups',  'Without a ticket', 26, false),
    ('Tickets — count total',           'count_total',    'Total in', 27, false),
    ('Tickets — money heading',         'money',          'Gate money by who sold it', 28, false),
    ('Tickets — money none',            'money_none',     'Nothing sold at the gate yet.', 29, false),
    ('Tickets — list empty',            'list_empty',     'No tickets yet.', 30, false),
    ('Tickets — list synced',           'list_synced',    'LeagueApps orders checked', 31, false),
    ('Tickets — copy link',             'copy_link',      'Copy link', 32, false),
    ('Tickets — copied',                'copied',         'Copied', 33, false),
    ('Tickets — admits',                'admits',         'admits {n}', 34, false),
    -- Public: the ticket page /t/?k= and the /tickets/ page.
    ('Tickets — public: club',          'pub_club',       'Lighthouse 1893 SC', 50, true),
    ('Tickets — public: show at gate',  'pub_show',       'Show this code at the gate.', 51, true),
    ('Tickets — public: admits',        'pub_admits',     'Admits {n} per game', 52, true),
    ('Tickets — public: games',         'pub_games',      'Home games', 53, true),
    ('Tickets — public: used',          'pub_used',       'Used', 54, true),
    ('Tickets — public: missing',       'pub_missing',    'This ticket link is not valid. Ask us at the gate.', 55, true),
    ('Tickets — public: voided',        'pub_voided',     'This ticket was cancelled.', 56, true),
    ('Tickets — public: no games yet',  'pub_no_games',   'The schedule for the rest of the season is coming. Your ticket works at every home game on it.', 57, true),
    ('Tickets — public: venue',         'pub_venue',      'Lighthouse Field, 101 East Erie Avenue, Philadelphia', 58, true),
    ('Tickets — public: buy heading',   'pub_buy_title',  'Tickets', 59, true),
    ('Tickets — public: buy intro',     'pub_buy_intro',  'Support the club. Come to our home games at Lighthouse Field, 101 East Erie Avenue, Philadelphia. Youth under 18 free with an adult.', 60, true),
    ('Tickets — public: buy button',    'pub_buy',        'Buy', 61, true),
    ('Tickets — public: buy none',      'pub_buy_none',   'Nothing on sale right now. Pay at the gate.', 62, true),
    ('Tickets — public: buy note',      'pub_buy_note',   'You pay through LeagueApps, our club''s registration site. Your QR ticket is sent to you after you pay.', 63, true)
  ) AS v(label, tier, body, o, pub)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tickets' AND m.tier = v.tier);

COMMIT;
