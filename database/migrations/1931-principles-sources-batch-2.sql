-- 1931 (2026-11-26): principles of play — second batch of sources (owner 11/26 "can we find more sources?").
-- Same tables as mig 1930. All verified = false (secondary web sources) until the research session checks the text.
-- Searched, NOTHING usable published: CBF (Brazil), RBFA (Belgium), Canada Soccer (headings only), Gréhaigne (no list),
-- Worthington, Hughes, Teodorescu (cited, not found). JFA: correction notice only — Japan taught Wade's 1968 principles
-- as FOUR attacking + FOUR defending until an April 2022 revision to England's five + five (names not found).

INSERT INTO game_play_principles (code, side, level, title, aka, definition, is_not, sort_order) VALUES
  ('break-organisation', 'attack', 'general', 'Break their organisation', 'rotura da organização; disorder',
   'With the ball, the aim behind every principle: pull their shape out of order so a gap opens.', '', 5),
  ('keep-organisation', 'defend', 'general', 'Keep our organisation', 'estabilidade da organização; order',
   'Without the ball, the aim behind every principle: keep our shape in order so no gap opens.', '', 6),
  ('centre-of-play', 'both', 'general', 'Act at the centre of play', 'intervenção no centro de jogo',
   'The game is decided round the ball: get men there, with it or against it.', '', 7),
  ('reference-points', 'defend', 'sub', 'Reference points', 'ball, space, team-mates, opponent',
   'Each defender places himself by four references — the ball, the space, his team-mates, his opponent — and the order he weighs them is the defending style.', '', 37),
  ('interception', 'defend', 'sub', 'Interception and anticipation', 'intercettamento e anticipo',
   'Read the pass and get to the ball, or in front of the man, before it arrives.', '', 38)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('queiroz-1983', 'book', 'Carlos Queiroz (1983) — general, operational and fundamental principles (cited via Motriz / RB Futebol)', 'https://www.periodicos.rc.biblioteca.unesp.br/index.php/motriz/article/download/2488/2534', false),
  ('castelo-1996', 'book', 'Jorge Castelo (1996), Futebol: a organização do jogo — general and specific principles', 'https://repositorio.ipcb.pt/bitstreams/7d4f0b87-90e8-4732-ac9f-6779203a24ef/download', false),
  ('figc', 'federation', 'FIGC Settore Tecnico, Coverciano — principi di tattica collettiva (course notes and theses on figc.it)', 'https://figc.it/FigcLegacyAssets/SettoreTecnico/allegati/21112017163836.pdf', false)
ON CONFLICT (code) DO NOTHING;

CREATE TEMP TABLE t_terms (src text, term text, lang text, lvl text, side text, canon text, rel text) ON COMMIT DROP;
INSERT INTO t_terms VALUES
  ('queiroz-1983', 'Penetração', 'pt', 'fundamental', 'attack', 'penetration', 'same'),
  ('queiroz-1983', 'Cobertura ofensiva', 'pt', 'fundamental', 'attack', 'support', 'same'),
  ('queiroz-1983', 'Mobilidade', 'pt', 'fundamental', 'attack', 'mobility', 'same'),
  ('queiroz-1983', 'Espaço', 'pt', 'fundamental', 'attack', 'width', 'overlaps'),
  ('queiroz-1983', 'Contenção', 'pt', 'fundamental', 'defend', 'pressure', 'same'),
  ('queiroz-1983', 'Cobertura defensiva', 'pt', 'fundamental', 'defend', 'cover', 'same'),
  ('queiroz-1983', 'Equilíbrio', 'pt', 'fundamental', 'defend', 'balance', 'same'),
  ('queiroz-1983', 'Concentração', 'pt', 'fundamental', 'defend', 'compactness', 'same'),
  ('queiroz-1983', 'Criar superioridade numérica', 'pt', 'general', 'attack', 'superiority', 'same'),
  ('castelo-1996', 'Rotura da organização', 'pt', 'general', 'attack', 'break-organisation', 'same'),
  ('castelo-1996', 'Estabilidade da organização', 'pt', 'general', 'defend', 'keep-organisation', 'same'),
  ('castelo-1996', 'Intervenção no centro de jogo', 'pt', 'general', 'both', 'centre-of-play', 'same'),
  ('castelo-1996', 'Penetração', 'pt', 'fundamental', 'attack', 'penetration', 'same'),
  ('castelo-1996', 'Cobertura ofensiva', 'pt', 'fundamental', 'attack', 'support', 'same'),
  ('castelo-1996', 'Mobilidade', 'pt', 'fundamental', 'attack', 'mobility', 'same'),
  ('castelo-1996', 'Contenção', 'pt', 'fundamental', 'defend', 'pressure', 'same'),
  ('castelo-1996', 'Cobertura defensiva', 'pt', 'fundamental', 'defend', 'cover', 'same'),
  ('castelo-1996', 'Equilíbrio', 'pt', 'fundamental', 'defend', 'balance', 'same'),
  ('figc', 'Smarcamento', 'it', 'fundamental', 'attack', 'mobility', 'same'),
  ('figc', 'Ampiezza', 'it', 'fundamental', 'attack', 'width', 'same'),
  ('figc', 'Marcamento', 'it', 'sub', 'defend', 'mark', 'same'),
  ('figc', 'Intercettamento e anticipo', 'it', 'sub', 'defend', 'interception', 'same'),
  ('figc', 'Difesa della porta', 'it', 'operational', 'defend', 'protect-goal', 'same'),
  ('figc', 'Pressing', 'it', 'fundamental', 'defend', 'pressure', 'same'),
  ('figc', 'Equilibri difensivi', 'it', 'fundamental', 'defend', 'balance', 'same'),
  ('sacchi', 'Reference points: ball, space, team-mates, opponent', 'it', 'sub', 'defend', 'reference-points', 'same'),
  ('knvb', 'Keep the space wide', 'nl', 'fundamental', 'attack', 'width', 'same'),
  ('knvb', 'Depth before width', 'nl', 'fundamental', 'attack', 'penetration', 'overlaps'),
  ('knvb', 'Ball retention', 'nl', 'operational', 'attack', 'keep-ball', 'same'),
  ('knvb', 'Everyone defends', 'nl', 'fundamental', 'defend', 'defensive-unity', 'overlaps'),
  ('knvb', 'Keep their space small', 'nl', 'fundamental', 'defend', 'compactness', 'same'),
  ('football-australia', 'Building up', 'en', 'operational', 'attack', 'progress', 'same'),
  ('football-australia', 'Attacking and scoring', 'en', 'operational', 'attack', 'finish', 'same'),
  ('football-australia', 'Disturbing', 'en', 'operational', 'defend', 'stop-progress', 'same'),
  ('football-australia', 'Defending', 'en', 'operational', 'defend', 'protect-goal', 'same'),
  ('football-australia', 'Make the field small', 'en', 'fundamental', 'defend', 'compactness', 'same'),
  ('fa-england', 'Control and restraint', 'en', 'fundamental', 'defend', 'control-restraint', 'same'),
  ('fa-england', 'Compactness', 'en', 'fundamental', 'defend', 'compactness', 'same');

INSERT INTO game_source_principles (source_id, term, lang, level, side, locator, verified)
SELECT s.id, t.term, t.lang, t.lvl, t.side, coalesce(s.url, ''), false
  FROM t_terms t JOIN game_sources s ON s.code = t.src
ON CONFLICT (source_id, term) DO NOTHING;

INSERT INTO game_common_principle_links (term_id, principle_id, relation)
SELECT pt.id, p.id, t.rel
  FROM t_terms t
  JOIN game_sources s ON s.code = t.src
  JOIN game_source_principles pt ON pt.source_id = s.id AND pt.term = t.term
  JOIN game_play_principles p ON p.code = t.canon
ON CONFLICT DO NOTHING;
