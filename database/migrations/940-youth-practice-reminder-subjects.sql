-- Migs 938/939 left the email subject empty: same subject as the plain tier.
UPDATE message_templates n
   SET subject = o.subject, updated_at = now()
  FROM message_templates o
 WHERE n.kind = 'rsvp_reminder' AND o.kind = 'rsvp_reminder' AND o.is_active
   AND (n.tier, o.tier) IN (('group_parent_practice','group_parent'),
                            ('parent_practice','parent'),
                            ('multi_practice','multi'));
