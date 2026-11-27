-- 1946 (2026-11-26) — 👋 Welcome: no schedule in the message, just the app.
-- Owner: "lets get rid of typical practice schedule in message. feel like
-- it will freak out parents and players lol. just leave the welcome
-- messages to say the schedule is on the app and here is app link and
-- once u click it it saves on phone. and that u dont have to make all
-- events but we ask that u set availability to all so coaches can plan".
--
-- The four skeletons (email + SMS, adult + parent) drop {events_block}
-- and {schedule_block}; WelcomeMessage::render still fills them, but no
-- skeleton asks for them now, so nothing about days/times goes out.
-- The block rows stay (inactive copy is harmless; re-add the tokens to
-- bring them back).  {docs_block} (birth cert + headshot) stays.

UPDATE message_templates SET body = $b$Hi {first},

Welcome to Lighthouse 1893 — we're glad you're playing with us.

Your schedule is on our app, footballhome.org. Tap the link below on your phone — no password needed:
{link}

Once you've tapped it, you stay signed in on that phone. Add it to your home screen and it works like an app.

You don't have to make every event — but we ask that you set your availability for all of them (Yes or No) so the coaches can plan.

The link expires in 72 hours. If it has expired by the time you open it, just reply and I'll send a fresh one.

{docs_block}

Reply anytime with questions.

— {sender}
Soccer Director
Lighthouse 1893 SC$b$
 WHERE kind = 'welcome' AND tier = 'adult';

UPDATE message_templates SET body = $b$Hi {first},

Welcome to Lighthouse 1893 — we're glad {child} is playing with us.

{child}'s schedule is on our app, footballhome.org. Tap the link below on your phone — no password needed:
{link}

Once you've tapped it, you stay signed in on that phone. Add it to your home screen and it works like an app.

{child} doesn't have to make every event — but we ask that you set {child}'s availability for all of them (Yes or No) so the coaches can plan.

The link expires in 72 hours. If it has expired by the time you open it, just reply and I'll send a fresh one.

{docs_block}

Reply anytime with questions.

— {sender}
Soccer Director
Lighthouse 1893 SC$b$
 WHERE kind = 'welcome' AND tier = 'parent';

UPDATE message_templates SET body = $b$Hi {first} — welcome to Lighthouse 1893! Your schedule is on our app: {link}

No password needed — tap it once and it stays signed in on your phone.

You don't have to make every event, but please set your availability for all of them so the coaches can plan.

{docs_block}$b$
 WHERE kind = 'welcome_sms' AND tier = 'adult';

UPDATE message_templates SET body = $b$Hi {first} — welcome to Lighthouse 1893! {child}'s schedule is on our app: {link}

No password needed — tap it once and it stays signed in on your phone.

{child} doesn't have to make every event, but please set {child}'s availability for all of them so the coaches can plan.

{docs_block}$b$
 WHERE kind = 'welcome_sms' AND tier = 'parent';
