-- 📑 Proposals: a PDF link, live on the page (James 11/23 "also need pdf link
-- live on page" + "pdf should update every time we ujpdate proposal").
-- scripts/proposal-pdf.sh prints each public proposal's page to
-- /proposals/<code>.pdf and remakes it whenever the proposal changes (run
-- every minute from cron; it only works when something changed). This
-- migration adds the two labels the links use.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Proposals', v.l, 'proposals', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('pdf_link',     'Before the PDF link (in the app)',        'PDF link', 17),
    ('pdf_download', 'PDF button on the public page',           'PDF', 18)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'proposals' AND m.tier = v.t);
