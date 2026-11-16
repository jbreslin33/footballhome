-- 1407 (2026-11-16) — 🧩 Programs → Men's: 💵 where the money goes.
-- Owner: "we need the programs broken out furhter. like apsl only. liga 1
-- only. u23 only. cups individual only. then we can get a total and a total
-- for dues for men to fund it" + "clear separation maybe with lines lol or
-- colors" + "still haveing trouble meaking sense of where all monies go for a
-- program and what dues coming in" + "need a pre grant balance so i know if
-- we are grant proof".
-- Page only (FinancesScreen._menMoneyHtml): money in, money out per
-- competition (each cup its own block), the shared Men's costs, balance
-- before the grant, after it, and the dues per man a month that fund it.
-- Words only here.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: title', 'pm_title', '💵 Men''s money · {year}', 380),
    ('Finances — men''s money: note', 'pm_note', 'Where every dollar goes for a year of Men''s, competition by competition, and what comes in. Out = each league''s and cup''s fees × quantity from its fee plan, refs, physio, game coaching; then what every men''s team shares (practice coaching, kits, LeagueApps fees) and Men''s share of the club-wide costs. Per man / mo = the line ÷ 12 ÷ {n} paying men. Grant-proof = the balance before any grant is not negative.', 381),
    ('Finances — men''s money: columns', 'pm_columns', 'Line|Rate × qty|Year|Per man / mo', 382),
    ('Finances — men''s money: in', 'pm_in', 'MONEY IN', 383),
    ('Finances — men''s money: dues', 'pm_dues', 'Dues — {n} paying men × {monthly}/mo', 384),
    ('Finances — men''s money: casa', 'pm_casa', 'CASA field rental — Men''s share', 385),
    ('Finances — men''s money: in total', 'pm_in_total', 'Money in (before any grant)', 386),
    ('Finances — men''s money: out', 'pm_out', 'MONEY OUT — BY COMPETITION', 387),
    ('Finances — men''s money: out rest', 'pm_out_rest', 'MONEY OUT — WHAT EVERY MEN''S TEAM SHARES', 388),
    ('Finances — men''s money: general', 'pm_general', 'Men''s — general (every team)', 389),
    ('Finances — men''s money: cups coaching', 'pm_cups_coaching', 'Game coaching — every cup', 390),
    ('Finances — men''s money: share', 'pm_share', 'Share of club-wide costs (field, balls, seed …)', 391),
    ('Finances — men''s money: share line', 'pm_share_line', 'Split by paying members', 392),
    ('Finances — men''s money: out total', 'pm_out_total', 'Money out — total', 393),
    ('Finances — men''s money: pre grant', 'pm_pre_grant', 'BALANCE BEFORE GRANT', 394),
    ('Finances — men''s money: proof ok', 'pm_proof_ok', '✓ grant-proof', 395),
    ('Finances — men''s money: proof short', 'pm_proof_short', '✗ needs the grant — {amount} short without it', 396),
    ('Finances — men''s money: grant', 'pm_grant', 'Grant — Men''s share (coaching, refs, equipment)', 397),
    ('Finances — men''s money: post grant', 'pm_post_grant', 'BALANCE AFTER GRANT', 398),
    ('Finances — men''s money: fund', 'pm_fund', 'DUES PER MAN A MONTH THAT FUND IT', 399),
    ('Finances — men''s money: fund pre', 'pm_fund_pre', 'Without the grant (grant-proof)', 400),
    ('Finances — men''s money: fund post', 'pm_fund_post', 'With the grant', 401),
    ('Finances — men''s money: fund need', 'pm_fund_need', '{need} a year from dues (after LeagueApps'' cut)', 402),
    ('Finances — men''s money: at paying', 'pm_at', 'at {n} paying now', 403),
    ('Finances — men''s money: at full', 'pm_at_full', 'at {n} — full house', 404),
    ('Finances — men''s money: now', 'pm_now', 'Dues today', 405),
    ('Finances — men''s money: options', 'pm_options', 'OPTIONS — NOT IN THE TOTAL', 406),
    ('Finances — men''s money: option adds', 'pm_option_adds', 'would add, per man a month', 407)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
