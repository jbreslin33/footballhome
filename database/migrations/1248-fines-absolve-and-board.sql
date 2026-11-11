-- 1248 (2026-11-11) — Absolve a fine; #fines in the Tuition format.
--
-- Owner 2026-11-11: "on fines page i want to be able to absolve" / "i want
-- the fines pill to act JUST like tuition pill. same format" / "boys girls
-- etc even though we are not fining them … in fines case i guess its 2
-- cats for amount you owe or not" / "i want consistency on the tuition and
-- fines page" / fines stay their own page, separate from tuition.
--
-- fine_absolutions: one row per fine let off (person, event, kind), with a
-- reason; undo stamps undone_at (history stays).  fh_person_fines leaves an
-- absolved fine out, so it is gone from #fines, the Tuition card boxes, #my
-- and every bill at once.  fh_person_absolved_fines lists them for undo.

CREATE TABLE fine_absolutions (
    id                  bigserial PRIMARY KEY,
    person_id           integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    fh_event_id         bigint  NOT NULL,
    fine_kind           text    NOT NULL REFERENCES fine_kinds(code),
    reason              text    NOT NULL DEFAULT '',
    created_by_user_id  integer,
    created_at          timestamptz NOT NULL DEFAULT now(),
    undone_at           timestamptz,
    undone_by_user_id   integer
);
CREATE UNIQUE INDEX fine_absolutions_one_open
    ON fine_absolutions (person_id, fh_event_id, fine_kind) WHERE undone_at IS NULL;
COMMENT ON TABLE fine_absolutions IS
    'mig 1248: a fine the owner let off (#fines ⋯ sheet, Fines tab). fh_person_fines skips open rows; undo = undone_at.';

CREATE OR REPLACE FUNCTION public.fh_person_fines(p_person_ids integer[], p_from timestamp with time zone)
 RETURNS TABLE(person_id integer, fh_event_id bigint, team_id integer, starts_at timestamp with time zone, event_kind text, opponent text, fine_kind text, amount_usd numeric, response text, attendance text)
 LANGUAGE sql
 STABLE
AS $function$
    SELECT f.* FROM fh_person_fines_all(p_person_ids, p_from) f
     WHERE fh_fine_waived_at(f.person_id, f.starts_at) IS NULL
       AND NOT EXISTS (SELECT 1 FROM fine_absolutions a
                        WHERE a.person_id = f.person_id AND a.fh_event_id = f.fh_event_id
                          AND a.fine_kind = f.fine_kind AND a.undone_at IS NULL)
$function$;

CREATE OR REPLACE FUNCTION public.fh_person_absolved_fines(p_person_ids integer[], p_from timestamp with time zone)
 RETURNS TABLE(absolution_id bigint, person_id integer, fh_event_id bigint, starts_at timestamp with time zone,
               event_kind text, opponent text, fine_kind text, amount_usd numeric, reason text, absolved_at timestamptz)
 LANGUAGE sql
 STABLE
AS $function$
    SELECT a.id, f.person_id, f.fh_event_id, f.starts_at, f.event_kind, f.opponent, f.fine_kind, f.amount_usd,
           a.reason, a.created_at
      FROM fh_person_fines_all(p_person_ids, p_from) f
      JOIN fine_absolutions a ON a.person_id = f.person_id AND a.fh_event_id = f.fh_event_id
                             AND a.fine_kind = f.fine_kind AND a.undone_at IS NULL
     WHERE fh_fine_waived_at(f.person_id, f.starts_at) IS NULL
$function$;

-- The page's words (kind fines).  Section bars, stats, views, card, sheet.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Fines', v.label, 'fines', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('sec_owes',        'Section bar — players who owe fines',               'OWES FINES', 100),
    ('sec_clear',       'Section bar — players who owe nothing',             'NOTHING OWED', 101),
    ('no_rules',        'Section with no fine rules ({section})',            'No fine rules for {section} — nobody here is fined.', 102),
    ('view_players',    'View tab — players',                               '👥 Players', 110),
    ('view_fines',      'View tab — every fine',                            '🧾 Fines', 111),
    ('view_to_bill',    'View tab — what goes on the next bill',            '🚩 To bill', 112),
    ('stats_players',   'Stats row title — players',                        'PLAYERS', 120),
    ('stats_money',     'Stats row title — money',                          'FINES', 121),
    ('stats_kinds',     'Stats row title — by kind',                        'BY KIND', 122),
    ('stat_fineable',   'Stat — fineable players',                          'Fineable', 123),
    ('stat_owes',       'Stat — players who owe',                           '🔴 Owe', 124),
    ('stat_clear',      'Stat — players who owe nothing',                   '🟢 Nothing owed', 125),
    ('stat_disputed',   'Stat — pending disputes',                          '⚖️ Disputed', 126),
    ('stat_absolved',   'Stat — fines absolved',                            '🕊 Absolved', 127),
    ('stat_owed',       'Stat — owed (finished periods)',                   '🔴 Owed', 128),
    ('stat_so_far',     'Stat — this period so far',                        'This period so far', 129),
    ('stat_on_la',      'Stat — periods on LeagueApps',                     'On LA', 130),
    ('owes_hero',       'Card — owed label',                                'OWES', 140),
    ('clear_hero',      'Card — nothing owed',                              'Nothing owed', 141),
    ('so_far_line',     'Card — current period so far ({period} {amount})', '{period} so far: {amount}', 142),
    ('absolve',         'Sheet — absolve one fine button',                  '🕊 Absolve', 150),
    ('absolve_period',  'Sheet — absolve a whole period ({period})',        '🕊 Absolve all of {period}', 151),
    ('absolve_prompt',  'Sheet — reason prompt',                            'Why let this go? (shows in the history)', 152),
    ('absolved_title',  'Sheet — absolved list heading',                    '🕊 Absolved', 153),
    ('undo',            'Sheet — undo an absolve',                          'Undo', 154),
    ('absolved_line',   'Absolved fine line ({reason})',                    'let off — {reason}', 155),
    ('bill_line',       'To bill — a player''s line ({period} {amount})',   '{period}: {amount}', 160),
    ('to_bill_empty',   'To bill — nothing waiting',                        'Nothing waiting to go on a bill.', 161)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'fines' AND t.tier = v.tier);

-- Fines is one page of 💰 Money; the old period pills are gone (the card
-- names each period).
UPDATE message_templates SET is_active = false WHERE kind = 'fines' AND tier = 'month_all';
