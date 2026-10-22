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
  // Where the GAME's 105 x 68 pitch sits. PLACEHOLDER: centred on the
  // larger OSM soccer outline (way 762100601 — 96 x 51.5 m, an OLD
  // outline) along its long axis. rotDeg = long axis, degrees from east
  // toward south. CONFIRM with James.
  gamePitch: { x: -10.6, z: -19.8, rotDeg: 58.1 },

  // Kids' fields — to be placed with James (size, spot, orientation).
  // e.g. { name: '7v7', x: .., z: .., length: 55, width: 36, rotDeg: .. }
  kidsFields: [],

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

  // Rodeo area (north-east). Imagery: a round pen (Esri: ~20 m across;
  // Google's newer imagery shows white panels + little bleachers), an
  // oval pen beside it, and a red-roofed barn north-west of the ring.
  rodeo: {
    ring: { x: 146.8, z: -111.1, r: 12 },                       // CONFIRM size
    ovalPen: { x: 161.7, z: -128.1, w: 16, d: 11.4, rotDeg: -30 },
    ringBleachers: true,
  },
  barn: { x: 137.9, z: -131.0, w: 14.3, d: 6.9, rotDeg: -5, roof: 'red', walls: 'red' }, // CONFIRM which building is "the barn"
  trailers: [{ x: 146.1, z: -127.0, w: 8, d: 2.5, rotDeg: -20 }],

  // By Erie Ave: the dark-roofed block with a dirt paddock on its west
  // side (stables?) and a long green shed. CONFIRM what they are.
  stable: { x: 24.9, z: 54.7, w: 14.9, d: 9.1, rotDeg: -8 },
  paddock: { x: 13.0, z: 56.5, w: 6.9, d: 10.3 },
  greenShed: { x: 43.2, z: 57.0, w: 3.4, d: 17, rotDeg: 0 },

  // Horses (LOD detail — only drawn up close): at the stables/paddock
  // and by the rodeo barn.
  horses: [
    { x: 11, z: 54, rotDeg: 20, coat: 0x6b3e26 },
    { x: 15, z: 59, rotDeg: 150, coat: 0x2a1d15 },
    { x: 13, z: 52, rotDeg: -70, coat: 0xb08a5a },
    { x: 140, z: -124, rotDeg: 90, coat: 0x8a5a3a },
    { x: 150, z: -108, rotDeg: 200, coat: 0x4a3326 },
  ],
};
