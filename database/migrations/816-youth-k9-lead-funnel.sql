-- 816 (2026-10-29) — the live youth ad is Grades K–9 (mig 783), but #leads
-- filed it under the old "Youth (Grades 1–6)" funnel.  Owner: "still not
-- showing k to 9 ad. or its misnamed".  The K–9 forms (1765217041432039,
-- 1104907468985240) now carry the funnel label "Youth (Grades K–9)"; the
-- old 1–6 ads keep theirs.  Lead copy is looked up by funnel label as the
-- tier, so every 1–6 youth row gets a K–9 twin.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, m.label, m.kind, 'Youth (Grades K–9)', m.subject, m.body, m.sort_order, m.is_active, m.client_side, m.is_public
  FROM message_templates m
 WHERE m.tier = 'Youth (Grades 1–6)'
   AND NOT EXISTS (SELECT 1 FROM message_templates k WHERE k.kind = m.kind AND k.tier = 'Youth (Grades K–9)');
