// frontend/js/game/boot.js — loads three.js as an ES module (0.160, the import map in game.html),
// exposes it as the global THREE the game's classic scripts expect (a mutable copy: renderer.js
// swaps CanvasTexture for an sRGB one), plus the addons on THREE_ADDONS, then loads those scripts
// in order. Graphics tier 2, step 1 (James 11/11): the module build is what gives us the glTF
// loader (real skinned bodies) and post-processing (ambient occlusion, bloom).
import * as T from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

window.THREE = Object.assign({}, T);
window.THREE_ADDONS = { GLTFLoader };

const SCRIPTS = [
  'js/game/wire.js?v=20261110feet1',
  'js/game/net.js?v=20261109step',
  'js/game/players.js?v=20261110foot1',
  'js/game/lighthouse-site.js?v=20261022s',
  'js/game/lighthouse-trees.js?v=20261022zi',
  'js/game/lighthouse-contours.js?v=20261022zs',
  'js/game/lighthouse-drainage.js?v=20261022zzd',
  'js/game/lighthouse-layout.js?v=20261025b',
  'js/game/field.js?v=20261107ground',
  'js/game/camera.js?v=20261030watch',
  'js/game/renderer.js?v=20261111r160',
  'js/game/view-menu.js?v=20261110view',
  'js/game/input.js?v=20261022e',
  'js/game/lighthouse-planner-data.js?v=20261022d',
  'js/game/pitch-planner.js?v=20261029a',
  'js/game/client.js?v=20261110view',
];
for (const src of SCRIPTS) {
  await new Promise((ok, fail) => {
    const s = document.createElement('script');
    s.src = src;
    s.onload = ok;
    s.onerror = () => fail(new Error('game: could not load ' + src));
    document.body.appendChild(s);
  });
}
