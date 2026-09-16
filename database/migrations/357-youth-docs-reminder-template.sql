-- 357 — Boys/Girls 📄 DOCS reminder moves out of boys-roster.js into
-- message_templates, following the Mens registration nudges (mig 356).
--
-- Owner 2026-09-16: "move the boys docs reminder to db too".
--
-- kind='registration' is the per-card "fill out this form" nudge kind
-- the roster boards read (the DOCS row under a travel column and the
-- 📄 DOCS button on each card that still needs docs).  Boys and Girls
-- share one row under category 'Youth Travel' — GirlsRosterScreen
-- extends BoysRosterScreen and always sent the same text.
--
-- Also adds message_templates.icon: the column DOCS row renders the
-- preset's icon on its buttons (renderMessageButtons), and that was
-- hard-coded beside the copy.  Nullable; the Mens rows get 📋 so the
-- data is complete, though their buttons draw 💬/✉ instead.
--
-- Body keeps its blank line before the link: sms:/mailto bodies carry
-- it verbatim, so the link sits on its own line in the parent's client.
BEGIN;

ALTER TABLE message_templates ADD COLUMN IF NOT EXISTS icon TEXT;

UPDATE message_templates SET icon = '📋', updated_at = NOW()
 WHERE kind = 'registration' AND icon IS NULL;

INSERT INTO message_templates (category, label, kind, tier, icon, subject, body, sort_order)
VALUES (
    'Youth Travel',
    'Docs reminder',
    'registration',
    'card',
    '📄',
    'Lighthouse Soccer — travel team docs needed',
    E'Dear Lighthouse Soccer Parents, in order to play in the Philadelphia Parks & Rec Soccer League (All games in Philadelphia) you must please right away fill out this form that has you simply upload picture of birth certificate and head shot of child. We have a limited number of spots on travel so we are filling the spots as parents fill out form.\n\nhttps://forms.gle/n2bj8aHiTRqLs6cg9',
    0
);

DO $$
DECLARE n INT; bad TEXT;
BEGIN
    SELECT count(*) INTO n
      FROM message_templates
     WHERE kind = 'registration' AND is_active
       AND lower(regexp_replace(category, '[^[:alnum:]]+', '', 'g')) = 'youthtravel';
    IF n <> 1 THEN
        RAISE EXCEPTION 'expected 1 active Youth Travel docs template, found %', n;
    END IF;
    SELECT string_agg(label, ', ') INTO bad
      FROM message_templates
     WHERE kind = 'registration' AND is_active
       AND (icon IS NULL OR body NOT LIKE '%https://%' OR coalesce(subject, '') = '');
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'registration template missing icon, link or subject: %', bad;
    END IF;
END $$;

COMMIT;
