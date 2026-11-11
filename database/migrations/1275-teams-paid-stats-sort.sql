-- 1275: #teams paid line per team column + 💰 Paid status / 🌐 Official
-- order sorts (owner 2026-11-11: "show stats of paid status for youth
-- teams by age and allow for sort by paid status" / "heck do that for men
-- etc too" / "same with roster pill" / "then have for roster 'official
-- order' sort pill" / "which comes right from webite of league").
--
-- Every team column (all sections, Roster AND Team pills) opens with
-- ✅ paid (%) · 🔴 owe $ · ⚪ no LA for the players it shows — the same
-- LeagueApps balance the card's Dues pill reads (pending bank payments
-- already taken off, mig 690).  Sort row gains 💰 Paid status (owes
-- first, biggest balance first, then no LA, then paid) and, on the Roster
-- pill, 🌐 Official order = official_roster_names.sort_order, the order
-- the league website lists (the 🌐 mirror).  Frontend only
-- (RosterScreenBase.paidStatsHtml / orderColumnPlayers); wording here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_paid_ok',       'Team column paid line — paid ({n} {pct})',        '✅ {n} paid ({pct}%)',  1030),
    ('board_paid_owe',      'Team column paid line — owe ({n} {usd})',         '🔴 {n} owe {usd}',      1031),
    ('board_paid_none',     'Team column paid line — no LA registration ({n})', '⚪ {n} no LA',          1032),
    ('board_paid_tip',      'Team column paid line — hover tip',                'Dues from LeagueApps for the players this column shows', 1033),
    ('board_sort_alpha',    'Team boards sort pill — A–Z',                      'A–Z last name',         1034),
    ('board_sort_rank',     'Team boards sort pill — coach rank',               'Rank',                  1035),
    ('board_sort_paid',     'Team boards sort pill — paid status',              '💰 Paid status',        1036),
    ('board_sort_official', 'Team boards sort pill — league website order (Roster pill only)', '🌐 Official order', 1037)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
