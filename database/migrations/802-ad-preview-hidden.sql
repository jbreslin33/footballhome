-- 802 (2026-10-28) — #ad-preview shows only the ads in the queue (owner:
-- "for ad preview we need to be able to hide ones that are not in our
-- que. it has dups and old stuff").  A row here hides that Meta ad from
-- the default view; the page's "Show hidden" pill brings them back and
-- each card toggles its own row (PUT /api/ads/:adId/hidden).
CREATE TABLE IF NOT EXISTS ad_preview_hidden (
    meta_ad_id         text PRIMARY KEY,
    hidden_at          timestamptz NOT NULL DEFAULT now(),
    hidden_by_user_id  integer REFERENCES users(id)
);

-- Everything in the account today except the three year-round ads
-- (Youth 120250085649420390, Men 120250084463060390, Women
-- 120250084465020390): old seasons, trials, interest forms, the paused
-- club-wide and K–6 youth ads.
INSERT INTO ad_preview_hidden (meta_ad_id) VALUES
  ('120249128805610390'), ('120247201470910390'), ('120248847365450390'),
  ('120248844551620390'), ('120247751578510390'), ('120247751582780390'),
  ('120245826738410390'), ('120245826836390390'), ('120245748851660390'),
  ('120246782574590390'), ('120244607211660390'), ('120246234566750390'),
  ('120246782553060390'), ('120246234599850390'), ('120246234598090390'),
  ('120246234573510390'), ('120244607212540390'), ('120244607213610390'),
  ('120245251868650390'), ('120244401358150390'), ('120244142361160390'),
  ('120244401350930390')
ON CONFLICT (meta_ad_id) DO NOTHING;
