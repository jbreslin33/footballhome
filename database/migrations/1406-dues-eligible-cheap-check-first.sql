-- 1406: fh_dues_eligible_at asks the cheap question first (owner 11/16
-- "speed up the fines part too").  It is "the policy doesn't block OR the
-- balance is under the line"; the policy side walks the person's teams and
-- their dues policy per row (~0.4 ms), the balance side is one indexed log
-- read.  Most players are under the line, so checking that first lets the
-- OR stop there: fines' 327 judged rows 149 ms → 40 ms (13 rows still need
-- the policy).  Same answer — neither side can be NULL (EXISTS / COALESCE).
CREATE OR REPLACE FUNCTION public.fh_dues_eligible_at(p_person_id integer, p_club_id integer, p_at timestamp with time zone)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  SELECT COALESCE(fh_dues_balance_at(p_person_id, p_at) < fh_dues_line_usd(p_club_id), true)
      OR NOT fh_dues_blocks_eligibility(p_person_id, p_club_id, (p_at AT TIME ZONE 'America/New_York')::date)
$function$;
