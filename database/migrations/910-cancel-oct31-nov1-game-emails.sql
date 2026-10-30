-- Weekend of Oct 31 / Nov 1: four cancellation emails, unsent, as ✉️ draft
-- buttons on the Game Center 📇 panel (mig 728). Each goes to the league
-- contact, the other team's coach and the ref assignor. Addresses stay in
-- club_contacts, this file carries contact ids only.
--   128 U8 Boys Red director, 153 Parkwood Spiders coach
--   130 U10 Boys Blue director, 168 Academy Sabers coach, 167 Parkwood Vikings coach
--   200 TCWSL Game Commissioner, 62 + 63 Gaels captains
--   201 / 202 ref assignor on the PPR / TCWSL office
BEGIN;

WITH new_draft AS (
  INSERT INTO contact_email_drafts (contact_id, match_id, label, subject, body, created_by_user_id) VALUES
  (128, 9360, 'Cancel U8 vs Parkwood Sat (both games)',
   'Lighthouse U8 Boys Red: cancelling both games vs Parkwood Spiders, Sat Oct 31',
   $$Hi all,

Unfortunately Lighthouse has to cancel both of our U8 Boys Red games against the Parkwood Spiders this Saturday, October 31 (8:00 AM and 9:00 AM, Field 7 at Parkwood).

Our numbers this weekend are extremely low. We only have 3 players. We're not sure why, maybe parents are busy with Halloween.

Sorry for the short notice. Gordon, please take the referees off both games. Let us know how the league would like to handle them from here.

Thanks,
James Breslin
Lighthouse 1893 SC$$, 1),

  (130, 9311, 'Cancel U10 at Academy Sabres Sat',
   'Lighthouse U10 Boys Blue: cancelling Sat Oct 31 game at Academy Sabres',
   $$Hi all,

Unfortunately Lighthouse has to cancel our U10 Boys Blue game at Academy Sabres this Saturday, October 31 at 9:00 AM.

Our numbers this weekend are extremely low. We only have 3 players. We're not sure why, maybe parents are busy with Halloween.

Sorry for the short notice. Gordon, please take the referees off this game. Let us know how the league would like to handle it from here.

Thanks,
James Breslin
Lighthouse 1893 SC$$, 1),

  (130, 9312, 'Cancel U10 at Parkwood Sun',
   'Lighthouse U10 Boys Blue: cancelling Sun Nov 1 game at Parkwood Vikings',
   $$Hi all,

Unfortunately Lighthouse has to cancel our U10 Boys Blue game at the Parkwood Vikings this Sunday, November 1 at 11:00 AM (Field 4 at Parkwood).

Our numbers this weekend are extremely low. We only have 3 players. We're not sure why, maybe parents are busy with Halloween.

Sorry for the short notice. Gordon, please take the referees off this game. Let us know how the league would like to handle it from here.

Thanks,
James Breslin
Lighthouse 1893 SC$$, 1),

  (200, 9342, 'Cancel Tri County at Gaels Sun',
   'Lighthouse Womens Club 1895: cancelling Sun Nov 1 game at Gaels',
   $$Hi all,

Unfortunately Lighthouse Womens Club 1895 has to cancel our Tri County game at Gaels this Sunday, November 1 at 10:00 AM at Rosemont College.

Our numbers this weekend are extremely low. We only have 6 players. We're not sure why, maybe people are busy with Halloween.

Sorry for the short notice. Gordon, please take the referees off this game. Let us know how the league would like to handle it from here.

Thanks,
James Breslin
Lighthouse 1893 SC$$, 1)
  RETURNING id, match_id
)
INSERT INTO contact_email_draft_recipients (draft_id, contact_id)
SELECT n.id, r.contact_id
  FROM new_draft n
  JOIN (VALUES (9360, 128), (9360, 153), (9360, 201),
               (9311, 130), (9311, 168), (9311, 201),
               (9312, 130), (9312, 167), (9312, 201),
               (9342, 200), (9342, 62), (9342, 63), (9342, 202)) r(match_id, contact_id)
    ON r.match_id = n.match_id;

COMMIT;
