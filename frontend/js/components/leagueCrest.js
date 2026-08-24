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
  //
  // Each league carries its spelled-out name as well as its acronym:
  // the tag is whatever ops typed on the calendar, and "Tri County
  // Women's Soccer League" is at least as likely as "TCWSL". Missing
  // those spellings didn't fail loudly — it silently returned src:null
  // and the badge just lost its crest.
  const CRESTS = [
    [/casa|liga\s*[12]/i, 'casa.png'],
    [/\bapsl\b|delaware\s*river|atlantic\s*premier/i, 'apsl.png'],
    [/\bicsl\b|inter[\s-]*county/i, 'icsl.png'],
    [/\btcwsl\b|tri[\s-]*county/i, 'tcwsl.png'],
    // "Pennsylvania" is spelled penn-, not pa-, so both of these accept
    // the abbreviation and the full word explicitly. Youth first: it is
    // the more specific of the two and the adult pattern would otherwise
    // claim "Eastern Pennsylvania Youth Soccer" for the wrong crest.
    [/\bepysa\b|eastern\s*(pa\b|penn\w*)\s*youth/i, 'epysa.png'],
    [/\bepsa\b|eastern\s*(pa\b|penn\w*)/i, 'epsa.png'],
    [/open\s*cup/i, 'us-open-cup.png'],
    [/\bconcacaf\b/i, 'concacaf.png'],
    [/\busys\b|us\s*youth\s*soccer/i, 'usys.png'],
    [/\bfifa\b/i, 'fifa.png'],
    // Region 1 before the generic US Soccer / USSF pattern below, which
    // would otherwise swallow "USSF Region 1" and show the national crest.
    [/region\s*1|\bussf[\s-]*r1\b/i, 'ussf-region1.jpg'],
    [/us\s*soccer|\bussf\b/i, 'ussoccer.png'],
    // Philadelphia Parks & Recreation — the city rec league the youth
    // sides play in. "PPR" is the mark on the crest itself, so ops may
    // well type it.
    [/parks\s*(&|and)?\s*rec|\bppr\b/i, 'phila-parks-rec.jpg'],
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
