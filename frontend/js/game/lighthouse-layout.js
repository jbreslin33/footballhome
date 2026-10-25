// frontend/js/game/lighthouse-layout.js
//
// Lighthouse Field TODAY — the hand-edited layer over the OpenStreetMap
// outlines (lighthouse-site.js, which are old for the pitches) and the
// imagery-detected trees (lighthouse-trees.js). Everything here is
// metres from LIGHTHOUSE_SITE.origin (x east, z south) unless noted.
// James steers this file: today's pitch layout, the kids' 7v7 field,
// what the buildings really are. Values marked CONFIRM are measured
// from satellite imagery (Esri z19, ~0.23 m/px) and need his eye.

window.LIGHTHOUSE_LAYOUT = {
  // THE PLANNED PITCH (James, 10/22): 115 x 74 yd (105.16 x 67.67 m — the
  // game's 105 x 68 to within 33 cm, so game and real pitch are one).
  // "Kissing the softball field is safest" (James): the old-timers' high
  // ground slid toward the softball diamond lands on spot 3, so the plan is
  // the driest placement exactly 10 ft off the softball infield dirt —
  // centre (30, -33.5), 155° (lidar water search over 145-163°): 10.6 ft
  // off the softball dirt, 59 ft off its 3B fence, 49 ft off the vendor
  // fence, 18.5 yd off the main infield, 39 m from the cemetery tree line,
  // clear of today's flooding cemetery goalmouth and the dirt road.
  gamePitch: { x: 30, z: -33.5, rotDeg: 155 },
  realPitch: { x: 30, z: -33.5, rotDeg: 155, length: 105.16, width: 67.67 },
  gamePitchCandidate: '3',
  // Optional interceptor drains (French drain / swale) 3 m outside the
  // pitch: along the cemetery-side touchline and across the rodeo end,
  // catching cemetery-slope runoff before it crosses; they empty into the
  // main channel that already drains to Erie Ave.
  drains: [
    { name: 'interceptor, cemetery-side touchline', pts: [[64.8, -90.4], [-35.9, -43.4]] },
    { name: 'interceptor, rodeo end', pts: [[94.7, -26.3], [64.8, -90.4]] },
  ],
  // Superseded: the painted pitch on today's imagery — ~90 x 60.5 m, axis
  // 61.5°, centre (-15.7, -33.4).
  // The pitch in use today (James, 10/22): the Google-painted 11v11's
  // touchlines (traced, 60 m apart, 61.3°) run on straight until the south
  // goal line is 10 ft off the vendor fence — 99.9 m (109 yd) long, right
  // up against the main diamond's infield. Drawn in yellow.
  // 10/24 (James: "make yellow 110 by 74 as that is current pitch ... keep
  // kissing the baseball infield ... same orientation ... extend it towards
  // rodeo"): was 99.9 x 60.0 m at (-11.5, -28.0). The infield touchline
  // and the south (vendor-fence) goal line stay put; +7.67 m of width goes
  // toward the rodeo, +0.68 m of length onto the north goal line.
  oldPitch: { x: -8.30, z: -30.14, rotDeg: 61.3, length: 100.58, width: 67.67 },
  // FLOOD (removed 10/22): James's hand-drawn flood areas (cemetery-end
  // 6-yd box, wet strip by the yellow sideline) came out — the box floods
  // because cars compact it (stop driving there), and the lidar already
  // scores the real runoff. In git history before this change.

  // Fences, traced on the City 2025 orthoimagery (same numbers as the
  // planner). The vendor fence is pole bases: straight along the main
  // diamond's 1st-base line, then bending ~6° south at x ≈ -20 (west bases
  // half-hidden in building shadow — read at their north-most). The rodeo
  // fence is a long curve bowing west.
  // group 'softball': the removed softball diamond's fences, still up until
  // the grounds crew pulls them (James 10/24: "until fences are removed we
  // need keep fence but allow fence to be toggled off") — DESIGN's ⛓
  // SOFTBALL FENCE pill hides them and drops their 10 ft rule.
  fences: [
    { name: 'softball 1st-base fence', group: 'softball', kind: 'chain', h: 2.4, pts: [[91.9, 19.8], [97.6, 9.4], [103.0, -1.9]] },
    { name: 'softball 3rd-base fence', group: 'softball', kind: 'chain', h: 2.4, pts: [[82.9, 22.2], [60.1, 9.6]] },
    { name: 'softball backstop', group: 'softball', kind: 'chain', h: 4, pts: [[82.9, 22.2], [87.4, 21.0], [91.9, 19.8]] },
    // group 'rodeo': may be moved slightly (James 10/24) — ⛓ RODEO FENCE
    // pill. Every other fence is static.
    { name: 'rodeo fence', group: 'rodeo', kind: 'chain', h: 1.8, pts: [[88.6, -95.7], [91.7, -87.0], [93.2, -80.1], [96.6, -75.1],
      [98.2, -70.9], [100.5, -66.3], [103.5, -60.2], [106.6, -55.6], [111.1, -50.3], [114.9, -45.7],
      [119.5, -41.1], [124.1, -35.8], [128.7, -29.7]] },
    { name: 'metal vendor-protector fence', kind: 'metal', h: 2.4, pts: [[-60, 32.4], [-36.2, 32.5], [-29.1, 32.7],
      [-20.1, 32.1], [-15.28, 33.07], [-12.03, 33.58], [-8.81, 33.96], [-5.76, 34.24], [-2.51, 34.44],
      [0.79, 34.77], [3.85, 35.1], [7.16, 35.41], [10.33, 35.74]] },
  ],

  // Ball fields, MEASURED on satellite imagery (5 m grid on Esri z19):
  // home plate, bearing = direction home → 2nd base (degrees from east
  // toward south; −45 = north-east), base = base-path length, infield =
  // 'grass' (baseball cut) or 'dirt' (softball skin), arc = dirt-arc
  // radius from home plate. Replaces guessing from OSM's whole-field
  // outlines, which put the infields in the wrong spots.
  diamonds: [
    { name: 'main (baseball)', home: [-68.5, 29.5], bearing: -45, base: 27.43, infield: 'grass', arc: 47 },
    // East softball + the small one by the playground: the grounds crew is
    // removing them, but they're drawn until then (James 10/24: "need
    // softball baseball infields to show but not be factor in fit") — no
    // infield is a planner rule (pitch-planner.js INFO).
    { name: 'east (softball)', home: [85.9, 13.4], bearing: -107, base: 18.29, infield: 'dirt', arc: 28 },
    { name: 'by the playground (small)', home: [61, 66], bearing: -135, base: 18.29, infield: 'dirt', arc: 22 }, // CONFIRM orientation
  ],

  // Kids' fields — to be placed with James (size, spot, orientation).
  // e.g. { name: '7v7', x: .., z: .., length: 55, width: 36, rotDeg: .. }
  // TODAY'S PLAYING FIELD, traced from the paint on Google's imagery
  // (10/22): 80.5 x 30.7 m, long sides parallel to the softball 3rd-base
  // fence — where the players actually play.
  kidsFields: [{ name: 'today\'s playing field (Google paint)', x: 48.0, z: 28.0, length: 80.5, width: 30.7, rotDeg: 28.5 }],
  // Map labels copied from Google Maps' satellite view, at the exact spot
  // Google prints them (measured on two zoom levels, agree within 0.5 m),
  // painted flat on the grass north-up to help orient the game view.
  labels: [{ text: '260', x: 32.8, z: -54.9, size: 8 }],
  // CANDIDATE SPOTS for the 115 x 74 yd pitch (water search, 10/22): every
  // legal placement (>= 10 ft off both fences, >= 15 yd off the main
  // infield, off dirt, clear of trees + rodeo fence) scored on the lidar
  // per m²: 3 x pond + 1.5 x runoff crossing + 0.5 x too-flat (< 0.5 %).
  // Rating 0-10 = water only, among these candidates at their CURRENT
  // spots (wettest = 0, driest = 10); "% pond" = standing water / pitch
  // (runoff crossing is ~5.5 % on every spot, so it hid the spread). Plan A, pushed
  // onto the low flat vendor end, is the WETTEST of all 1,278 legal spots.
  candidates: [
    // James: same orientation as today's Google-painted pitch (61°), slid
    // up and left (seen from the barn) until it just kisses the flooding
    // cemetery-end 6-yard box of today's pitch (5 cm clear). Needs the 10 ft
    // softball-diamond buffer dropped: 4.9 ft off the softball infield dirt,
    // 21.9 ft off its 3B fence, 10.2 ft off the vendor fence, 18.1 yd off
    // the main infield, 23.9 m from the cemetery.
    { id: 'Y', label: 'Y 6.2/10 · 2.1% pond', name: "today's yellow angle, kissing the 6-yd box", color: 0xffe14d, x: 9.75, z: -30.25, rotDeg: 61, length: 105.16, width: 67.67,
      water: { pond: 150, flow: 399, flat: 918 }, cemetery: 23.9, infieldYd: 18.1 },
    { id: 'A', label: 'A 0/10 · 2.5% pond', name: 'plan A (fences)', color: 0xffffff, x: 25.15, z: -19.65, rotDeg: 94, length: 105.16, width: 67.67,
      water: { pond: 175, flow: 386, flat: 1336 }, cemetery: 35.5, infieldYd: 16.6 },
    { id: '1', label: '1 9.3/10 · 1.6% pond', name: "old-timers' spot, highest ground", color: 0xff3b3b, x: 23.82, z: -54.7, rotDeg: 152, length: 105.16, width: 67.67,
      water: { pond: 111, flow: 396, flat: 897 }, cemetery: 4.6, infieldYd: 26.9 },
    { id: '2', label: '2 8.7/10 · 1.7% pond', name: 'dry + room', color: 0x7dff3b, x: 24, z: -42, rotDeg: 155, length: 105.16, width: 67.67,
      water: { pond: 120, flow: 391, flat: 905 }, cemetery: 29.4, infieldYd: 16.5 },
    { id: '3', label: '3 10/10 · 1.3% pond', name: 'THE PLAN: kissing the softball field', color: 0x00e5ff, x: 30, z: -33.5, rotDeg: 155, length: 105.16, width: 67.67,
      water: { pond: 95, flow: 394, flat: 935 }, cemetery: 36.4, infieldYd: 19.7 },
    { id: '4', label: '4 8.7/10 · 1.6% pond', name: 'today\'s angle — over the flooded 6-yd box', color: 0xff9a1a, x: 6, z: -36, rotDeg: 55, length: 105.16, width: 67.67,
      water: { pond: 115, flow: 437, flat: 800 }, cemetery: 16.3, infieldYd: 18.9 },
    { id: '5', label: '5 8.9/10 · 1.7% pond', name: 'north-south — over the flooded 6-yd box', color: 0xff3bd5, x: 27, z: -45, rotDeg: 85, length: 105.16, width: 67.67,
      water: { pond: 123, flow: 353, flat: 985 }, cemetery: 15.1, infieldYd: 27.7 },
    { id: '6', label: '6 8/10 · 1.8% pond', name: 'softball-fence angle — over the flooded 6-yd box', color: 0xa07bff, x: 27, z: -45, rotDeg: 35, length: 105.16, width: 67.67,
      water: { pond: 129, flow: 400, flat: 885 }, cemetery: 11.9, infieldYd: 37.6 }
  ],
  // Built-in spots for the pitch planner's 📌 buttons (pitch-planner.js);
  // spots James saves himself live in his browser. The driest legal spot
  // of each size is ⭐ BEST (lighthouse-planner-data.js ranges[size].at).
  planSpots: [],
  // Planned 7v7 pitches, 70 x 35 yd (64.0 x 32.0 m), laid ACROSS the
  // planned 11v11, one in each half (the usual small-sided layout): each
  // runs touchline to touchline (1.8 m spare each side), centred in its
  // half (10.3 m clear of halfway and of the 11v11 goal line).
  sevens: [
    { name: '7v7, rodeo-end half', x: 53.8, z: -44.6, rotDeg: 245, length: 64.01, width: 32.0 },
    { name: '7v7, main-diamond-end half', x: 6.2, z: -22.4, rotDeg: 245, length: 64.01, width: 32.0 },
    // A proposed stand-alone 7v7 ('K', 10/22) sat on the playground and
    // the Whitaker stand — retired; place 7v7s with 📐 PLAN (pitch-planner.js).
  ],
  // Cemetery boundary fence (New Cathedral Cemetery), along the OSM
  // cemetery outline.
  cemeteryFence: { height: 2.0 },

  // The five movable 3-row bleachers, in GAME-PITCH coordinates
  // (x along the pitch, z across; touchlines at z = ±34). Imagery shows
  // them parked in a row by the Erie Ave side (≈ x -12…5, z 36.5 in
  // site metres) when not set out.
  bleachers: [
    { x: -26, z: -37.5, len: 7.5, face: 0 },
    { x: 0, z: -37.5, len: 7.5, face: 0 },
    { x: 26, z: -37.5, len: 7.5, face: 0 },
    { x: -18, z: 37.5, len: 6, face: 180 },
    { x: 18, z: 37.5, len: 6, face: 180 },
  ],

  // THE BARN — really an event hall (James, 10/22), between the village
  // road and Erie Ave (Google pins "Li'Vere Candles & Co" on it). City 2025
  // imagery, shadows lifted: 17.0 m east–west x 11.1 m, turned 12.4° (east
  // end further south); gable roof whose ridge runs north–south across the
  // short side, so the gable ends face the road and Erie. gableBarn's
  // ridge is its w axis, hence w 11.1 and rotDeg 12.4 + 90.
  barn: { x: -39.87, z: 51.95, w: 11.1, d: 17.0, rotDeg: 102.4, roof: 'dark', walls: 'tan' },
  // Lighthouse Village (City 2025 imagery): south of the metal fence, the
  // vendor stall row faces the road in front of the barn. The long roof
  // runs x -56…-28; three small grey-roofed stalls sit at its east end;
  // the white-roofed building closes the road's east end. Entries marked
  // CONFIRM are measured but James still has to name them.
  buildings: [{ name: 'vendor stall row', x: -42, z: 36, w: 28, d: 4, h: 3, color: 0x7a5c44 },
              { name: 'vendor stall', x: -27.5, z: 36.0, w: 2.8, d: 2.2, h: 2.5, color: 0x8a8f96 },
              { name: 'vendor stall', x: -24.55, z: 36.0, w: 2.8, d: 2.2, h: 2.5, color: 0x8a8f96 },
              { name: 'white-roofed building, road end', x: 19.8, z: 43.5, w: 6, d: 7, h: 3,
                rotDeg: 5, color: 0xd9d6cf },
              // White-roofed block just east of the hall (2.8 x 12.3 m).
              { name: 'snack bar + bathrooms (CONFIRM)', x: -25.4, z: 54.6, w: 2.8, d: 12.3, h: 3,
                color: 0xd9d6cf },
              // Long dark roof by the parking-lot entrance (28.6 x ~3 m).
              { name: 'long dark roof by the entrance — the dugout? (CONFIRM)', x: -89.3, z: 47.2,
                w: 28.6, d: 3, h: 2.6, rotDeg: 7.6, color: 0x4a3b30 },
              // Plank-topped wooden structure on the playground's east side.
              { name: 'wooden structure — the dugout? (CONFIRM)', x: 37.05, z: 55.9, w: 3.1, d: 5, h: 2.6,
                color: 0x9a7650 },
              // By Whitaker Ave: trailers / stands parallel to the avenue.
              { name: 'Whitaker trailer (blue-grey roof)', x: 99.5, z: 37, w: 19, d: 3.5, h: 3,
                rotDeg: 120, color: 0x8d99a3 },
              { name: 'Whitaker stand (red roof)', x: 107, z: 41, w: 14, d: 4.5, h: 3,
                rotDeg: 120, color: 0x8a4a3a },
              { name: 'Whitaker stand (tan roof)', x: 85, z: 66, w: 12.6, d: 3.5, h: 3,
                rotDeg: 119, color: 0xc9a27a }],
  // Pop-up canopies ("gazebos"), roof slab on four legs. CONFIRM which set
  // James means: white ones by the entrance-side Erie walk, coloured ones
  // south of the playground, green ones by Whitaker.
  canopies: [
    { name: 'white canopies (gazebos?)', x: -78.4, z: 59.2, w: 8, d: 3.7, color: 0xf2f2f0 },
    { name: 'coloured canopies (gazebos?)', x: 41.8, z: 74, w: 5.7, d: 5.7, color: 0x8a6fb0 },
    { name: 'green canopies', x: 95.3, z: 64.7, w: 8, d: 6.8, color: 0x3f8a5a },
  ],
  // Fenced playground / picnic pad by Erie (was mistaken for a barn +
  // paddock on older imagery): asphalt pad, sand pit, fence on three sides
  // (the south side is lost under the trees).
  playground: {
    fence: [[9.8, 63.5], [9.8, 49.3], [39, 52.1], [36.3, 64.8]],
    pad: [[19.1, 51.0], [33.4, 52.1], [34.0, 62.5], [18.7, 61.4]],
    sand: [[11.1, 52.7], [17.0, 52.5], [18.9, 54.6], [18.0, 63.3], [10.9, 63.3]],
  },
  // The LAST vendor stall (east end, by the end of the metal fence) is a
  // carnival basketball game (James): open to the road, hoops on its back
  // wall. Footprint measured on City 2025 imagery (2.9 x 2.2 m).
  booths: [{ name: 'carnival basketball game', kind: 'basketball', x: -21.55, z: 36.0, w: 2.9, d: 2.2,
             h: 2.6, face: 'south' }],
  // Flat ground polygons (layer 'road' asphalt or 'path' concrete). The
  // village road: between the stalls and the barn, then east along the
  // fence to the white building; a lot opens south off it at x -12…3.
  roads: [
    { name: 'village road', kind: 'road', pts: [[-56, 38.2], [-24, 37.2], [16.5, 40.7], [16.5, 46.8],
      [3.2, 45.6], [3.2, 50], [-12, 50], [-12, 44.2], [-20, 43.4], [-54, 43.6]] },
    { name: 'concrete apron', kind: 'path', pts: [[-20.5, 34.9], [10, 38.1], [16.5, 39.9], [16.5, 40.7], [-24, 37.2]] },
  ],
  // Dusty dirt road between the grass and the cemetery tree line (City
  // 2025 imagery, centreline): from the parking-lot side in the south-west,
  // up the west edge, then north-east along the cemetery trees and on past
  // the rodeo end. ~6.5 m wide; the south-west spur ~5 m.
  tracks: [
    { name: 'cemetery-edge dirt road', w: 6.5, pts: [[-104.5, -47.6], [-97.7, -57.5], [-79.5, -70.4],
      [-64.4, -78.7], [-53, -82.5], [-41.7, -90], [-30.3, -97.6], [-13.6, -105.1], [0.2, -109.3],
      [13.1, -112.7], [28.4, -116.1], [43.6, -119.5], [58.8, -123], [74.1, -126.4], [78, -128],
      [97, -135.5], [119.8, -138.5]] },
    { name: 'dirt road, south-west spur', w: 5, pts: [[-110, -30], [-108.3, -37], [-104.5, -47.6]] },
  ],
  // PROPOSED (James 10/24): a lane for wide trucks — a bypass when the
  // tan road is blocked, or two-way traffic — on the tan road's field
  // side behind the yellow (oldPitch) pitch. It contours with the tree
  // line there ("needs to contour with tree line and merge into tan road
  // before and after trees"): inner edge root m outside the trunks, never
  // within keep m of the yellow, reach = how far behind the pitch counts.
  // w = 14 ft (8.5 ft truck + mirrors). Its fence (10 ft rule) runs off
  // the lane's field edge. field.js draws it; 🚗 PROPOSED LANE pill.
  // (Drafts: on the road's north side = the cemetery; then straight behind
  // the goal line.)
  proposedLanes: [
    { name: 'proposed lane behind the yellow pitch', along: 'cemetery-edge dirt road', near: 'oldPitch', reach: 30,
      gap: 0.5, w: 4.27, root: 1, keep: 1,
      fence: { name: 'proposed lane fence (field side)', off: 0.3, kind: 'chain', h: 1.8 } },
  ],
  // Low three-rail wooden fence between the metal fence and the road (a
  // gap with two heavy posts at x ≈ 10–13), continuing east to x ≈ 43.
  railFences: [
    { name: 'village rail fence', color: 0x5a4636, pts: [[-20.1, 34.6], [10.2, 37.9]] },
    { name: 'village rail fence east', color: 0x5a4636, pts: [[12.9, 38.1], [26, 40.4], [42.8, 42.6]] },
  ],

  // Rodeo area (north-east). Imagery: a round pen (Esri: ~20 m across;
  // Google's newer imagery shows white panels + little bleachers), an
  // oval pen beside it, and a small red-roofed shed north-west of it.
  rodeo: {
    ring: { x: 146.8, z: -111.1, r: 12 },                       // CONFIRM size
    ovalPen: { x: 161.7, z: -128.1, w: 16, d: 11.4, rotDeg: -30 },
    ringBleachers: true,
  },
  sheds: [{ x: 137.9, z: -131.0, w: 14.3, d: 6.9, rotDeg: -5, roof: 'red' }],
  trailers: [{ x: 146.1, z: -127.0, w: 8, d: 2.5, rotDeg: -20 }],

  // Horses (LOD detail — only drawn up close), by the rodeo.
  horses: [
    { x: 140, z: -124, rotDeg: 90, coat: 0x8a5a3a },
    { x: 150, z: -108, rotDeg: 200, coat: 0x4a3326 },
  ],
};
