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
  // THE PLANNED PITCH (James, 10/22): 115 x 74 yd (105.16 x 67.67 m —
  // the game's 105 x 68 to within 33 cm, so game and real pitch are one).
  // Placed by search (game/scripts-style solver in the session notes) under
  // his constraints: touchlines EXACTLY 10 ft (no closer) from the metal
  // foul-ball fence and the softball 3RD-BASE fence; >= 15 yd from the main
  // diamond's infield dirt (floods); off all infield dirt; clear of trees +
  // the rodeo fence; pushed toward the rodeo and the barn (away from the
  // worn cemetery-end goalmouth). Result: due north–south (90.25°), 10.1 ft
  // from both fences, 19.6 yd from the main infield. The METAL FENCE line
  // is a placeholder until laser-measured on site (it sets the N–S
  // position); the softball fence is measured (0.07 m/px imagery).
  gamePitch: { x: 24.75, z: -22.75, rotDeg: 90.25 },
  realPitch: { x: 24.75, z: -22.75, rotDeg: 90.25, length: 105.16, width: 67.67 },
  // Superseded: the painted pitch on today's imagery — ~90 x 60.5 m, axis
  // 61.5°, centre (-15.7, -33.4).
  oldPitch: { x: -15.7, z: -33.4, rotDeg: 61.5, length: 90, width: 60.5 },

  // Fences (Google imagery, 0.07–0.14 m/px). The softball fences are
  // symmetric about home→2nd: the 3rd-base fence is the 1st-base fence
  // (clearly visible, 23.69 m) mirrored — the two backstop corners sit
  // exactly symmetric about that axis (offset 0.000 m along it).
  fences: [
    { name: 'softball 1st-base fence', kind: 'chain', h: 2.4, pts: [[91.55, 18.77], [97.46, 8.34], [103.02, -1.95]] },
    { name: 'softball 3rd-base fence (mirrored)', kind: 'chain', h: 2.4, pts: [[82.86, 21.54], [61.51, 11.29]] },
    { name: 'softball backstop', kind: 'chain', h: 4, pts: [[82.86, 21.54], [87.2, 22.4], [91.55, 18.77]] },
    { name: 'rodeo fence', kind: 'chain', h: 1.8, pts: [[93.3, -87.5], [137.1, -20.1]] },
    { name: 'metal foul-ball fence (PLACEHOLDER — laser-measure)', kind: 'metal', h: 2.4, pts: [[-35, 33], [45, 33]] },
  ],

  // Ball fields, MEASURED on satellite imagery (5 m grid on Esri z19):
  // home plate, bearing = direction home → 2nd base (degrees from east
  // toward south; −45 = north-east), base = base-path length, infield =
  // 'grass' (baseball cut) or 'dirt' (softball skin), arc = dirt-arc
  // radius from home plate. Replaces guessing from OSM's whole-field
  // outlines, which put the infields in the wrong spots.
  diamonds: [
    { name: 'main (baseball)', home: [-69, 28], bearing: -45, base: 27.43, infield: 'grass', arc: 47 },
    { name: 'east (softball)', home: [83.2, 13.2], bearing: -104.5, base: 18.29, infield: 'dirt', arc: 28 },
    { name: 'by the paddock (small)', home: [61, 66], bearing: -135, base: 18.29, infield: 'dirt', arc: 22 }, // CONFIRM orientation
  ],

  // Kids' fields — to be placed with James (size, spot, orientation).
  // e.g. { name: '7v7', x: .., z: .., length: 55, width: 36, rotDeg: .. }
  // Second set of painted lines (Google imagery): a long touchline ~81 m
  // toward the softball fence, a parallel line ~32 m away, rotated ~30°.
  // Probably the youth / 7v7 layout — James to name and size it.
  kidsFields: [{ name: 'painted lines B (7v7?)', x: 44.7, z: 25.9, length: 81, width: 31.8, rotDeg: 29.9 }],
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

  // THE BARN (James: "biggest building on complex", "baseball field is
  // near barn"): the dark-roofed building by Erie with the dirt paddock on
  // its west side, beside the SE diamond. Esri imagery 14.9 x 9.1; Google's
  // newer imagery ~16 x 12 with its lean-to.
  barn: { x: 24.9, z: 54.7, w: 16, d: 11, rotDeg: -8, roof: 'dark', walls: 'red' },
  paddock: { x: 13.0, z: 56.5, w: 6.9, d: 10.3 },
  greenShed: { x: 43.2, z: 57.0, w: 3.4, d: 17, rotDeg: 0 },
  // The other big building, south of the main diamond (Google labels it
  // "Li'Vere Candles & Co"); ~17.6 x 12, dark roof.
  buildings: [{ name: 'east-of-League-Park block', x: -39.8, z: 48.8, w: 17.6, d: 12, h: 6,
                rotDeg: -8, color: 0x7a6658 }],

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

  // Horses (LOD detail — only drawn up close): at the barn's paddock and
  // by the rodeo.
  horses: [
    { x: 11, z: 54, rotDeg: 20, coat: 0x6b3e26 },
    { x: 15, z: 59, rotDeg: 150, coat: 0x2a1d15 },
    { x: 13, z: 52, rotDeg: -70, coat: 0xb08a5a },
    { x: 140, z: -124, rotDeg: 90, coat: 0x8a5a3a },
    { x: 150, z: -108, rotDeg: 200, coat: 0x4a3326 },
  ],
};
