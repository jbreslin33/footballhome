# 🗻 Spin the pyramid (`#apsl-pyramid`, view `shape`, migs 1849–1868)

Owner, 2026-11-24: "is a flat 2d view the best way to show all of this? i feel like a spinning
pyramind would be way to go? or multi sided shape. each side is a 'league'" · "when we face apsl we
should see mls 1, …, apsl 4th level, liga 1s 5th, liga 2s 6th all facing us on that side" ·
"separate pyraminds" (per calendar) · "2d view of standings for that league off to side with line
to face when its not facing us".

Two files:

- `frontend/js/components/pyramid-shape-view.js` (`PyramidShapeView`) — the view over
  `PyramidModel`: what goes on the pyramid, the buttons, the panel. It lays the flow view's own
  boxes (`proLeagueHtml`, `chartHtml`, `besideLeagueHtml`) out flat and hidden, measures them,
  and hands the result to —
- `frontend/js/components/pyramid-solid-view.js` (`PyramidSolid`) — draws the pyramid in
  three.js 0.160 (the module the game uses, imported from the CDN when the view first opens).

## What is on it

- **One pyramid per calendar** (`season_calendars`): the row of buttons at the top picks it. A
  league is only on the pyramid of its own calendar.
- **Levels, top first:** each `pro_league_tiers` level above the APSL that has a league on, then
  the APSL — its conferences, then each row of leagues that feed them, each row a level — and
  each national league beside it. A league switched off (its own pill) leaves; an emptied level
  goes and the numbers below move up.
- **An empty division step:** a pro division with no league on the shown calendar keeps its
  level, marked empty, when divisions above and below it have one (mig 1850).
- **One league, one side** (owner: "no need to draw somethnig on multiple sides. mls side shouod
  be apsl side … that is why we put them on our 'face'" — the APSL is the open league that makes
  agreements with the leagues above it). The APSL's side carries the whole column from the Club
  World Cup down; a level's next league goes on the next side; the other sides are bare.
- **The UPSL is switched off** (mig 1858, `pro_leagues.is_active`; owner: "screw upsl"). Its rows
  and club lists are kept.
- **Every table in full on its level:** pos · club · GP · GD · Pts, the 2D chart's zone colour per
  row (read from each row's `--zc`), one column per table, gold table name. A cup (a list of
  clubs, no standings) shows its clubs. A level is as tall as its longest table needs at the width
  it has there, worked out top-down (`_planTables`), so the steps are uneven.
- **Promotion / relegation arrows on the walls:** the APSL chart's links
  (`model.layout(confs).edges`) as thin tubes from the top of a table to the foot of the table or
  conference above, the 2D chart's curve; a green head where it promotes, red where it relegates
  (`_arrows`). All levels lie on one slope, so a point on a side is (x across, h down) and a line
  runs on from level to level. Only the APSL's side has them, and only on its calendar. Thin and
  narrow-headed (owner: "make them thinnger and smaller arross").
- **On screen:** the calendar buttons; small switches for the pro levels and each cup; 🗻 3D
  pyramid / ▦ 2D chart (the flow view, which has the same two buttons back); ‹ › − + Fit.

## Hands

One rule at every zoom, like a map (owner: "we need it easier to spin and zoom etc. the controls
are awkward"; hint mig 1867):

- drag: sideways turns, up/down moves along the levels, both at once; a flick keeps turning
- right-drag, shift-drag or two fingers: pan any way; two fingers also pinch to zoom
- wheel, pinch, trackpad pinch: zoom toward the pointer (exponential, smooth on both)
- a trackpad's sideways swipe turns; ctrl-/alt-drag tilts
- tap a level: its league opens flat in the right-hand panel, scrolled to that level, the side lit
  gold, the pyramid moved left, a line from the panel to the level (dashed when it faces away);
  a tap waits 260 ms so a double-tap can zoom ×2.2 there instead
- keys (once the pyramid has focus): ← → a side (bare sides passed over), ↑ ↓ move, + − zoom, 0/F fit
- letting go of a turn settles square on a side only when zoomed out (not closer than 0.8 × fit);
  pans are clamped so the pyramid never leaves the screen

## Cost

It draws only when something moved (a drag, an ease, a resize) — no idle frame loop. Each league's
side is one canvas texture (≤ 4096 px wide), drawn once. The owner kept this build because "it runs
fine and doesn't sllow iin browser and slow sysetem".

## History (2026-11-24)

Seven builds were tried side by side and six dropped (mig 1868): four in CSS 3D with the page's
boxes folded onto the walls — 🧊 Boxy (straight walls), 🔺 Pyramid (sloped), 🔺 Raised text and
🔺 Settles flat — then three three.js solids — 🗻 Solid (a few big words per level), 🗻 + teams
(every club's name) and 🗻 + standings (kept). The CSS builds fought blur (scaled layers,
perspective magnifying the facing wall), slanted text that was hard to read ("the slant makes it
hard ter read"), and the cost of tens of thousands of elements on the walls. Lessons that still
hold: draw the text into a texture once rather than transforming live DOM, build only what is
seen, and keep the controls the same at every zoom.
