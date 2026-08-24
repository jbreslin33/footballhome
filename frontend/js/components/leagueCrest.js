// LeagueCrest — the one place a match turns into the league crest that
// stands for it.
//
// The crest is DB data, not a frontend lookup (2026-08-24, owner: "we
// already should have them in db"). organizations.logo_url has carried
// the APSL and CASA artwork since the schema was seeded; migration 298
// added the club's other two leagues — Tri County Women's Soccer League
// ("Tri COunty is tcwsl") and Philadelphia Parks & Recreation — and the
// gcal_league_aliases table that maps the hand-typed `League:` tag to
// the organization owning the crest.
//
// So the whole path is: gcal description -> gcal-classify.js's DSL
// parser -> fh_events.league (migration 297) -> gcal_league_aliases ->
// organizations.logo_url -> EventController's `league_logo_url` on GET
// /api/matches/:id -> here. This module reads that answer; it never
// derives one. The first cut of it shipped a regex table matching league
// names to image paths — a second copy of a column the database already
// had, where adding a league left the crest silently wrong until someone
// edited JavaScript. Adding one is now an INSERT.
//
// resolve(match) -> { label, src } | null.
//   label — the `League:` tag verbatim, since ops' own wording is the
//           display wording. May be '' for a match that gets a crest
//           from its source system but carries no tag.
//   src   — the crest URL, or null when nothing in the DB gives this
//           match one. Callers must treat a null src as "no crest to
//           show" rather than substituting a default: a wrong league
//           crest on a published match graphic is worse than none.
// Returns null outright when the match has neither a tag nor a crest.
(function (global) {
  function resolve(match) {
    if (!match) return null;
    const label = (match.league_tag == null ? '' : String(match.league_tag)).trim();
    const src = (match.league_logo_url == null ? '' : String(match.league_logo_url)).trim();
    if (!label && !src) return null;
    return { label, src: src || null };
  }

  global.LeagueCrest = { resolve };
})(window);
