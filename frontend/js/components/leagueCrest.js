// LeagueCrest — turns the free-text `League:` tag ops type into a Google
// Calendar event description into the crest image that stands for it
// (2026-08-24, owner: "in gcal we have a league: var so we should use
// that to inform what league graphic to show ... i am working on the
// real central game and it is set to League: APSL so it should show
// apsl graphic").
//
// The tag travels: gcal description -> gcal-classify.js's DSL parser ->
// fh_events.league (migration 297) -> EventController's `league_tag` on
// GET /api/matches/:id -> matchDetails.league_tag here. Migration 297
// exists precisely so views stop inferring the league from scraped
// opponent names, so this module only ever reads the tag — it never
// falls back to guessing from a team name or source system.
//
// resolve(tag) -> { label, src } | null. `label` is the tag verbatim
// (ops' own wording is the display wording); `src` is the crest path, or
// null when the tag names a league we have no image for — callers should
// treat a null src as "no crest to show" rather than substituting a
// default, since a wrong league crest on a match graphic is worse than
// none. Returns null outright for an absent/blank tag.
(function (global) {
  // First match wins, so order matters where one name contains another.
  // Patterns are deliberately loose on the surrounding wording: ops type
  // whatever reads naturally ("APSL", "APSL Delaware River",
  // "CASA Select Liga 1"), and only the league identity in it matters.
  const CRESTS = [
    [/casa|liga\s*[12]/i, 'casa.png'],
    [/\bapsl\b|delaware\s*river/i, 'apsl.png'],
    [/\bicsl\b/i, 'icsl.png'],
    [/\btcwsl\b/i, 'tcwsl.png'],
    [/\bepysa\b/i, 'epysa.png'],
    [/\bepsa\b/i, 'epsa.png'],
    [/open\s*cup/i, 'us-open-cup.png'],
    [/\bconcacaf\b/i, 'concacaf.png'],
    [/\busys\b/i, 'usys.png'],
    [/\bfifa\b/i, 'fifa.png'],
    [/us\s*soccer|\bussf\b/i, 'ussoccer.png'],
  ];

  function resolve(tag) {
    const label = (tag == null ? '' : String(tag)).trim();
    if (!label) return null;
    for (const [pattern, file] of CRESTS) {
      if (pattern.test(label)) return { label, src: `/images/leagues/${file}` };
    }
    return { label, src: null };
  }

  global.LeagueCrest = { resolve };
})(window);
