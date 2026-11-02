-- Migs 938-940 changed RSVP reminders by mistake: the owner meant #promo-posts
-- (mig 943).  The reminders go back to their plain tiers.
DELETE FROM message_templates
 WHERE kind = 'rsvp_reminder'
   AND tier IN ('group_parent_practice', 'parent_practice', 'multi_practice');
