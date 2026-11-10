-- 1228: Adult dues notices say why dues matter (owner 2026-11-10: "feel
-- like we need point out our dues are lowest at this level but important
-- to pay referees, league fees, player registrations, tournament fees,
-- uniform fees, equipment fees").  The six *_selection notices (Men +
-- Women) get the line after the selection paragraph, before the 🙋
-- volunteer offer.  Youth already carry their own "keep the club running"
-- line (mig 1214/1220).

BEGIN;

UPDATE message_templates
   SET body = replace(body, E'\n\n[[{volunteer}',
                      E'\n\nOur dues are the lowest at this level, but they''re what pays for referees, league fees, player registrations, tournament fees, uniforms and equipment.\n\n[[{volunteer}')
 WHERE kind = 'payment_notice_email' AND tier LIKE 'behind\_%\_selection' AND is_active
   AND body NOT LIKE '%lowest at this level%';

UPDATE message_templates
   SET body = replace(body, '[[ {volunteer}]]',
                      ' Our dues are the lowest at this level, but they pay for referees, league fees, player registrations, tournaments, uniforms and equipment.[[ {volunteer}]]')
 WHERE kind = 'payment_notice_sms' AND tier LIKE 'behind\_%\_selection' AND is_active
   AND body NOT LIKE '%lowest at this level%';

DO $$ BEGIN
    IF (SELECT count(*) FROM message_templates
         WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND tier LIKE 'behind\_%\_selection'
           AND is_active AND body LIKE '%lowest at this level%') <> 6 THEN
        RAISE EXCEPTION 'dues-why line did not land on all six selection notices';
    END IF;
END $$;

COMMIT;
