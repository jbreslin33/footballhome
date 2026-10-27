---
name: casa-insta-scores
description: Check CASA Select Liga 1/2 clubs' Instagram pages for scores of played games that still have no score on SportsEngine. Use when James says "check all casa scores from insta" (or any ask to check CASA scores / results on Instagram).
---

# Check all CASA scores from Instagram

SportsEngine stays the source of truth (`#casa-scores`, mig 520). This only
finds scores clubs have posted on Instagram so James can enter or chase them.
Handles live in `club_social_handles` (mig 699), edited on `#casa-contacts`.

## 1. The games and handles (read-only)

```bash
sudo -n podman exec footballhome_db psql -U footballhome_user -d footballhome -P pager=off -c "
SELECT f.id, f.division_label, to_char(f.starts_at AT TIME ZONE 'America/New_York','Dy Mon FMDD FMHH12:MI AM') AS kickoff,
       f.home_name, hh.handle AS home_ig, f.away_name, ah.handle AS away_ig
  FROM league_fixtures f JOIN league_fixture_sources s ON s.id = f.source_id
  LEFT JOIN club_social_handles hh ON hh.club_id = f.home_club_id AND hh.platform = 'instagram'
  LEFT JOIN club_social_handles ah ON ah.club_id = f.away_club_id AND ah.platform = 'instagram'
 WHERE s.league_label = 'CASA' AND s.is_active AND f.removed_at IS NULL AND s.score_due_after_minutes IS NOT NULL
   AND f.starts_at + make_interval(mins => s.score_due_after_minutes) < now()
   AND f.status NOT IN ('postponed','cancelled','canceled','forfeit') AND (f.home_score IS NULL OR f.away_score IS NULL)
 ORDER BY f.starts_at;" < /dev/null
```

`league_fixtures` refreshes from SportsEngine whenever `#casa-scores` opens. If
the list looks stale, open that page first (or say so in the report).

## 2. The browser: the CASA Chrome profile

The server already checks on a schedule (mig 749: `scripts/casa-insta-scores.js`,
`casa-insta-scores.timer` — Sun 6 PM & 11:59 PM, Mon 6 AM, noon Mon–Sat); its
finds sit in `casa_insta_posts` and show on `#casa-scores`. Look there first —
this manual check is for when that run reports a problem or James wants eyes on it.
For a terminal run without Chrome: `node scripts/casa-insta-scores.js --test=<fixture id>`
(reads and prints, writes nothing).

The manual browser is James's **CASA** Chrome profile (virtual desktop 3, "c"),
VPN on. Load the claude-in-chrome tools in one
ToolSearch, `list_connected_browsers`, `select_browser` the CASA one, then
`tabs_context_mcp` and work in a new tab. If the CASA profile isn't connected,
or instagram.com won't load (VPN down), stop and tell James. Don't retry in a
loop.

## 3. Each club, once

For every distinct club with a handle (skip Lighthouse, our own club), open
`https://www.instagram.com/<handle>/` and look at the posts from the game day
through 3 days after. Final-score graphics are usually images, so read the
picture as well as the caption. Match a post to a game by opponent and date,
never by layout guesswork. A post that doesn't clearly name both the opponent
and the score isn't a score.

A club with no handle: search Instagram for it and list the likely handle as a
**suggestion** for James to confirm. Don't save it without James's OK. Once he
confirms, save it through the Instagram field on the club's `#casa-contacts`
card (a `POST /api/opponents/club-social`), not psql.

## 4. Report

One table: game (date, division, home v away) · score found · whose post
(handle + post link) · confidence (both clubs agree / one club / none found).
Then the games with nothing found and the clubs missing a handle. Flag any
place where the two clubs' posts disagree. Do not text or email anyone, and
do not write scores anywhere. James enters them on SportsEngine or chases them
from `#casa-scores`.
