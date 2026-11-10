-- 1231: 🙋 The volunteer offer rides on EVERY adult collection message
-- (owner 2026-11-10: "we need the volunteer stuff all on all collection
-- notices even 35 bucks etc").  The six #payments notices have it since
-- mig 1222; now also:
--
--  * dues_sms adult / adult_prorate — the roster 💸 PAY text ("your
--    {month} dues ($35) didn't clear"); /api/mens-roster rows carry
--    volunteerOffer (RosterBoardExtras).
--  * dues_alternate_note adult — Game Center's 💰 dues note; the server
--    fills {volunteer} (RsvpBoardController::handleDuesNote).
--
-- {volunteer} is the payment_notice_volunteer line, empty — and dropped —
-- for anyone without volunteer days (youth, women).  The alternate note's
-- "Any payment moves you back up" was untrue (any balance keeps him down,
-- and LA members can only pay in full, mig 1211) → "Paying it off moves
-- you back up".

BEGIN;

UPDATE message_templates SET body = replace(body, '{form:la_dashboard}. Thanks!', '{form:la_dashboard}.[[ {volunteer}]] Thanks!')
 WHERE kind = 'dues_sms' AND tier IN ('adult', 'adult_prorate') AND is_active AND body NOT LIKE '%{volunteer}%';

UPDATE message_templates SET body = replace(replace(body,
         'Any payment moves you back up: {link}', 'Paying it off moves you back up: {link}'),
         '{link} - {sender}', '{link}[[ {volunteer}]] - {sender}')
 WHERE kind = 'dues_alternate_note' AND tier = 'adult' AND is_active AND body NOT LIKE '%{volunteer}%';

DO $$ BEGIN
    IF (SELECT count(*) FROM message_templates
         WHERE is_active AND body LIKE '%{volunteer}%'
           AND ((kind = 'dues_sms' AND tier IN ('adult', 'adult_prorate')) OR (kind = 'dues_alternate_note' AND tier = 'adult'))) <> 3 THEN
        RAISE EXCEPTION 'volunteer line did not land on all three adult collection messages';
    END IF;
END $$;

COMMIT;
