-- 1411 (2026-11-16) — 💵 Men's money: season pills, one table.
-- Owner: "its sitll confusing. there are 2 sectoins the new one and the old
-- one. why not put the fall, psring, winter , summer in the new one and get
-- rid of old one" + "allow pills to show fall, witner spring etc or just totla
-- for year" + "instead of 2 diff sections".
-- Page only (FinancesScreen._menMoneyHtml / _pmSplit): Whole year · Fall ·
-- Winter · Spring · Summer pills on the Men's money table; the per-season
-- program table under Men's is gone (other programs keep it). Words only.
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — men''s money: year pill', 'pm_year', 'Whole year', 410),
    ('Finances — men''s money: year cost column', 'pm_col_year_cost', 'Whole year', 411),
    ('Finances — men''s money: year amount', 'pm_year_amount', '{amount} a year', 412),
    ('Finances — men''s money: fund need season', 'pm_fund_need_season', '{need} in {season} from dues (after LeagueApps'' cut)', 413),
    ('Finances — men''s money: seasons note', 'pm_seasons_note', 'A season shows the costs that happen in it: per-game costs in the months the games are played, entry and player fees when the league season starts, weekly and yearly costs spread over their months. Dues, CASA and the grant follow the programs (fall real, the rest planned). When money is paid = Cash Flow Forecast.', 414)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
