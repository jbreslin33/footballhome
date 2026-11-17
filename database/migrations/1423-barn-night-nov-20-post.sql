-- 1423 (2026-11-16) — Friday Night @ The Barn (Nov 20) Instagram post
-- (owner: "make a barn night post … just post i can always delete it").
-- Flyer uploaded to #files (club_files 54, barn.png) → images/posts JPEG.
-- Tickets link lives in the Linktree in bio (owner added it). Scheduled
-- now; SocialController's minute tick publishes it.
INSERT INTO promotional_posts (title, caption, image_url, status, heading, scheduled_at)
SELECT 'Friday Night @ The Barn — Fri Nov 20',
       E'🎶 FRIDAY NIGHT @ THE BARN — FRIDAY, NOV 20 · DOORS 7 PM\n\nJoin us at The Lighthouse Sports & Entertainment Complex for a night of dancing, local food, and great music with DJ Toney Tone and DJ Jon G! Unwind with friends while supporting the youth programs and community events that make The Lighthouse a special part of Philadelphia.\n\n🎟 $15 online in advance · $30 at the door\n🪑 Limited table add-ons seat four and include a bucket of six beers or seltzers. Table reservations close Nov 19 at 11:59 PM or when sold out. General admission is required for every guest, including those with table reservations.\n\n🔞 21+ only. No BYOB or outside food, drinks, or ice; bags will be checked upon entry.\n\nEvery ticket helps us continue serving our community. Thank you for being part of our mission! 💙\n\n🔗 Tickets + tables: link in the Linktree in our bio\n\nSee you at The Barn!\nThe Lighthouse Team\n\n📍 101 E. Erie Ave, Philadelphia, PA\n\n#Lighthouse1893 #FridayNightAtTheBarn #PhillyEvents #NorthPhilly #PhillyDJ #Fundraiser',
       'https://footballhome.org/images/posts/barn-night-2026-11-20.jpg', 'scheduled',
       'Friday Night @ The Barn', now()
 WHERE NOT EXISTS (SELECT 1 FROM promotional_posts WHERE image_url LIKE '%barn-night-2026-11-20%');
