// frontend/js/game/site-boot.js — loads the Lighthouse site page's scripts in order
// (lighthouse-site.html). three.js 0.160 as an ES module, exposed as the global THREE the 3D
// scripts expect, as game/boot.js does for the match's 3D view.
const T = await import('three');
const { GLTFLoader } = await import('three/addons/loaders/GLTFLoader.js');
const SkeletonUtils = await import('three/addons/utils/SkeletonUtils.js');
const { ConvexGeometry } = await import('three/addons/geometries/ConvexGeometry.js');
window.THREE = Object.assign({}, T);
window.THREE_ADDONS = { GLTFLoader, SkeletonUtils, ConvexGeometry };

const SCRIPTS = [
  'js/game/players.js?v=20261113runup',
  'js/game/bodies.js?v=20261113runup',
  'js/game/lighthouse-site.js?v=20261022s',
  'js/game/lighthouse-trees.js?v=20261022zi',
  'js/game/lighthouse-contours.js?v=20261022zs',
  'js/game/lighthouse-drainage.js?v=20261022zzd',
  'js/game/lighthouse-layout.js?v=20261025b',
  'js/game/field.js?v=20261107ground',
  'js/game/camera.js?v=20261116circ',
  'js/game/renderer.js?v=20261116circ',
  'js/game/lighthouse-planner-data.js?v=20261022d',
  'js/game/pitch-planner.js?v=20261029a',
  'js/game/site-client.js?v=20261124a',
];
for (const src of SCRIPTS) {
  await new Promise((ok, fail) => {
    const s = document.createElement('script');
    s.src = src;
    s.onload = ok;
    s.onerror = () => fail(new Error('site: could not load ' + src));
    document.body.appendChild(s);
  });
}
