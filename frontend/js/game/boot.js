// frontend/js/game/boot.js — picks the VIEW, then loads the game's classic scripts in order.
//
// Two views of the same match (James 11/16: "nhl 94 style now and later add the 3d client …
// allow for both views"): 2D = the top-down canvas view (renderer2d.js), no three.js at all;
// 3D = three.js 0.160 as an ES module (the import map in game.html), exposed as the global THREE
// the 3D scripts expect (a mutable copy: renderer.js swaps CanvasTexture for an sRGB one), plus the
// addons on THREE_ADDONS (graphics tier 2, 11/11: glTF bodies, post-processing).
// ?view=2d|3d wins; else this device's last choice (localStorage fh.game.view); else 2D.
// The 2D / 3D button (client.js) stores the choice and reloads; the server match carries on.

const qs = new URLSearchParams(location.search).get('view');
let view = qs === '2d' || qs === '3d' ? qs : null;
if (!view) {
  try { view = localStorage.getItem('fh.game.view'); } catch (e) { /* this visit only */ }
}
if (view !== '3d') view = '2d';
window.GAME_VIEW = view;
document.body.classList.add('view-' + view);

const COMMON_HEAD = [
  'js/game/wire.js?v=20261110feet1',
  'js/game/net.js?v=20261124sim',
];
const SCRIPTS_3D = [
  'js/game/players.js?v=20261113runup',
  'js/game/bodies.js?v=20261113runup',
  'js/game/field.js?v=20261107ground',   // with no Lighthouse site data loaded it builds nothing: a plain pitch
  'js/game/camera.js?v=20261116circ',
  'js/game/renderer.js?v=20261116circ',
  'js/game/view-menu.js?v=20261124pure',
];
const SCRIPTS_2D = [
  'js/game/renderer2d.js?v=20261116circ',
  'js/game/view-menu.js?v=20261124pure',   // ☰ Menu holds every control in 2D too (James 11/17)
];
const CLIENT = 'js/game/client.js?v=20261124pure2';

if (view === '3d') {
  const T = await import('three');
  const { GLTFLoader } = await import('three/addons/loaders/GLTFLoader.js');
  const SkeletonUtils = await import('three/addons/utils/SkeletonUtils.js');
  const { ConvexGeometry } = await import('three/addons/geometries/ConvexGeometry.js');
  window.THREE = Object.assign({}, T);
  window.THREE_ADDONS = { GLTFLoader, SkeletonUtils, ConvexGeometry };
} else {
  // ☰ Menu (view-menu.js) applies the HUD once the client builds it, as in 3D.
}

const SCRIPTS = [...COMMON_HEAD, ...(view === '3d' ? SCRIPTS_3D : SCRIPTS_2D), CLIENT];
for (const src of SCRIPTS) {
  await new Promise((ok, fail) => {
    const s = document.createElement('script');
    s.src = src;
    s.onload = ok;
    s.onerror = () => fail(new Error('game: could not load ' + src));
    document.body.appendChild(s);
  });
}
