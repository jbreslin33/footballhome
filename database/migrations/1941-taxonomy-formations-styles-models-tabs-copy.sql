-- 1941 (2026-11-26): 🧬 Taxonomy → 🧩 Formations · 🎨 Styles · 🗺 Game models tabs — their words (owner 11/26 "start with
-- formations but do all … keep me posted"). Content is the tables' own (migs 1938–1940).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('tab: formations', 'tab_formations', '🧩 Formations', 640),
    ('tab: styles', 'tab_styles', '🎨 Styles', 641),
    ('tab: game models', 'tab_models', '🗺 Game models', 642),
    ('formations intro', 'fm_intro', 'Every named system, each source''s name for it linked to it: how many sources name it, how many real starts (StatsBomb Premier League 2015/16, 760 team-matches), how many of our board layouts play it, how many sim teams use it. Tap one for every source and its variants.', 643),
    ('formations: base', 'fm_ph_base', 'Systems', 644),
    ('formations: in possession', 'fm_ph_in_possession', 'Shapes with the ball', 645),
    ('formations: historic', 'fm_ph_historic', 'Historic', 646),
    ('formation meta ({s}, {u}, {b}, {t})', 'fm_meta', '{s} sources · {u} real starts · {b} boards · {t} sim teams', 647),
    ('formation variant ({p})', 'fm_variant', 'a kind of {p}', 648),
    ('formation sheet: boards', 'fm_boards', 'Our board layouts', 649),
    ('formation uses ({n})', 'fm_uses', '{n} starts', 650),
    ('styles intro', 'st_intro', 'A playing style is a set of settings: where the team sits on each axis below. The named styles football talks about are combinations of them — each card shows its settings (● leaning, ●● strongly). Tap one for every source that names it and the game models that play it.', 651),
    ('styles: named', 'st_named', 'Named styles', 652),
    ('styles: axes', 'st_axes', 'The settings (axes)', 653),
    ('style meta ({s})', 'st_meta', '{s} sources', 654),
    ('style axis meta ({s}, {n}, {m})', 'st_axis_meta', '{s} sources name it · in {n} named styles · measured by {m}', 655),
    ('style sheet: profile', 'st_profile', 'Settings', 656),
    ('game models intro', 'gm_intro', 'Every game model we hold — ours with the federations'' and the clubs'' — each with whose it is, its playing style, its formation, and per moment its plan and the principles it puts first. Tap one for the whole model.', 657),
    ('game models: club', 'gm_kind_club', 'Clubs and coaches (ours first)', 658),
    ('game models: federation', 'gm_kind_federation', 'Federations', 659),
    ('game models: school', 'gm_kind_school', 'Leagues and schools', 660),
    ('game models: no style', 'gm_no_style', 'style and shape not set yet', 661),
    ('game model: whose', 'gm_whose', 'Whose', 662),
    ('game model: concepts', 'gm_concepts', 'Concepts it asks for (engine)', 663)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
