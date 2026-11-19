-- 1513: Mars Milligan (22445) back to Healthy — owner 11/18 "take mars off injured list".
-- Same as the #teams health dropdown → Healthy (PersonHealth::set): end the open injury now.
UPDATE person_injuries SET ends_at = now()
 WHERE person_id = 22445 AND starts_at <= now() AND (ends_at IS NULL OR ends_at > now());
