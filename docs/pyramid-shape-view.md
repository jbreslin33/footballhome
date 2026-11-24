# 🔺 Spin the pyramid (`#apsl-pyramid`, view `shape`, mig 1849)

Owner, 2026-11-24: "is a flat 2d view the best way to show all of this? i feel like a spinning
pyramind would be way to go? or multi sided shape. each side is a 'league'" · "when we face apsl we
should see mls 1, …, apsl 4th level, liga 1s 5th, liga 2s 6th all facing us on that side" ·
"separate pyraminds" (per calendar) · "2d view of standings for that league off to side with line
to face when its not facing us".

`frontend/js/components/pyramid-shape-view.js` (`PyramidShapeView`), a view over `PyramidModel`
that reuses the flow view's boxes (`proLeagueHtml`, `chartHtml`, `besideLeagueHtml`).

- **One pyramid per calendar** (`season_calendars`): the row of buttons at the top picks it. A
  league is only on the shape of its own calendar.
- **Levels, top first:** each `pro_league_tiers` level above the APSL that has a league on, then
  the bottom ring — the APSL chart (when the root's calendar matches) and each national league
  beside it. A league switched off (its own pill) leaves; an emptied level goes and the numbers
  below move up.
- **Sides:** as many as the bottom ring has leagues (never fewer than four), at every level, so a
  side is a whole column. One league at a level repeats on every side; two alternate.
- **The bottom ring is several levels deep:** a league's first division is one level and each row
  of leagues that feed it is the next level down, a step wider (APSL conferences, then the
  Liga 1s, the Liga 2s …). Each level shows its *band* of the league's one chart, cut half-way
  through the gap between rows, so the chart's own promotion arrows leave the top of one level
  and arrive at the foot of the level above. A league with no such level leaves its side open.
- **An empty division step:** a pro division with no league on the shown calendar keeps its
  level, marked empty, when divisions above and below it have one (mig 1850).
- **On the shape:** small switches for the pro levels and each cup, beside the calendar buttons —
  the same switches as ☰ Show on screen.
- **Opening view:** the page opens on this view (stored view key `apsl-pyramid-view2`).
- **Size:** a level is as wide as its biggest league needs (a very wide one at 0.6 scale, a narrow
  one up to 1.6×) and at least 1.18× the level above.
- **Hands:** drag sideways to spin, up/down to slide, wheel / ± to zoom (`scale3d` — depth too),
  ‹ › one side. Letting go settles square on the nearest side. A tap brings the side round and
  opens the league flat in the right-hand panel; a line ties the panel to its side, dashed when
  the side has turned away.
- **How it is built:** CSS 3D on real elements (`rotateY` + `translateZ`), no canvas. Sizes are
  measured flat first (and the chart's arrows drawn then), then folded.

The FIFA Club World Cup (tier −1) and the Concacaf Champions Cup (tier 0) each have their own
pill; off, everything under them moves up a level.

Open: a very large league (UPSL) makes the bottom ring far wider than the tower; an overlay for a
huge side instead of drawing it on the face was discussed and left for later.
