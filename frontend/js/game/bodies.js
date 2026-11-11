// frontend/js/game/bodies.js — real skinned bodies on the procedural rig (graphics tier 2, James 11/11
// "how realistic can we get the mesh/graphics"). Pure dressing, like players.js.
//
// The body: Quaternius "Universal Base Characters" Superhero male (CC0; game-assets/ubc/README.md),
// 12.5k triangles, a 65-bone humanoid skeleton. players.js's jointed rig stays the animator — the
// gait, the foot IK, every overlay — and becomes an invisible driver: each frame each rig joint's
// rotation, as a change from the rest pose, is copied onto its bone (retargeting by delta rotation
// in the figure's frame, so the two skeletons' different bone axes never matter), and the pelvis
// bone follows the rig pelvis's bob / lean / slide drop. The body is scaled so thigh + shin = the
// rig's 0.82 m: the IK's planted feet land where the body's feet are. Kit: the skin texture is
// overpainted by region (shirt / shorts / socks / boots), chosen per vertex from its dominant bone
// and bind-pose height, in the figure's kit colours.
//
//   ?bodies=one   one home outfielder (slot 1) gets the body — a side-by-side test
//   ?bodies=all   every player
// FH original (the retarget and the region paint); the body is Quaternius's.
(function () {
  'use strict';
  const q = new URLSearchParams(location.search).get('bodies');
  if (!q || !window.PlayerFigure || !window.THREE_ADDONS || !THREE_ADDONS.GLTFLoader) return;
  const want = (fig) => !fig.official && (q === 'all' || (q === 'one' && fig.slot === 1));

  const URL_BODY = 'game-assets/ubc/body_male.gltf';
  const RIG_LEG = 0.42 + 0.40;            // players.js: hip → knee → ankle
  const P = PlayerFigure.prototype;
  const figures = new Set();
  let proto = null;                       // { scene, scale, region attribute done }

  // ── kit regions, once on the shared geometry ─────────────────────────
  // 0 skin · 1 shirt · 2 shorts · 3 socks · 4 boots, from the vertex's heaviest bone and its
  // bind-pose height (the body stands 1.81 m in its own metres, T-pose, y up).
  function paintRegions(mesh) {
    const g = mesh.geometry;
    if (g.getAttribute('aRegion')) return;
    const names = mesh.skeleton.bones.map((b) => b.name);
    const si = g.getAttribute('skinIndex'), sw = g.getAttribute('skinWeight'), pos = g.getAttribute('position');
    const out = new Float32Array(pos.count);
    for (let i = 0; i < pos.count; i++) {
      let best = 0, bw = -1;
      for (let k = 0; k < 4; k++) { const w = sw.getComponent(i, k); if (w > bw) { bw = w; best = si.getComponent(i, k); } }
      const n = names[best] || '', y = pos.getY(i), ax = Math.abs(pos.getX(i));
      let r = 0;
      if (/^(foot|ball)/.test(n) && y < 0.13) r = 4;
      else if (/^(calf|foot)/.test(n) && y < 0.47) r = 3;
      else if (/^(thigh|pelvis)/.test(n) && y > 0.66 && y < 1.0) r = 2;
      else if (/^(spine|clavicle|pelvis)/.test(n) && y >= 0.92 && y < 1.50) r = 1;
      else if (/^upperarm/.test(n) && ax < 0.36) r = 1;      // short sleeves
      out[i] = r;
    }
    g.setAttribute('aRegion', new THREE.BufferAttribute(out, 1));
  }

  function kitMaterial(base, kit) {
    const m = base.clone();
    const u = {
      kitShirt: { value: new THREE.Color(kit.shirt) }, kitShorts: { value: new THREE.Color(kit.shorts) },
      kitSocks: { value: new THREE.Color(kit.socks) }, kitBoots: { value: new THREE.Color(kit.boots) },
    };
    m.onBeforeCompile = (sh) => {
      Object.assign(sh.uniforms, u);
      sh.vertexShader = 'attribute float aRegion;\nvarying float vRegion;\n' +
        sh.vertexShader.replace('#include <begin_vertex>', '#include <begin_vertex>\n  vRegion = aRegion;');
      sh.fragmentShader = 'uniform vec3 kitShirt, kitShorts, kitSocks, kitBoots;\nvarying float vRegion;\n' +
        sh.fragmentShader.replace('#include <map_fragment>', [
          '#include <map_fragment>',
          '  if (vRegion > 0.5) {',
          '    vec3 k = vRegion < 1.5 ? kitShirt : vRegion < 2.5 ? kitShorts : vRegion < 3.5 ? kitSocks : kitBoots;',
          '    diffuseColor.rgb = k * (0.9 + 0.2 * dot(diffuseColor.rgb, vec3(0.333)));',   // a hint of the form
          '  }'].join('\n'))
        // cloth hangs over the muscles: the normal map mostly gone on the kit
        .replace('#include <normal_fragment_maps>',
          '#include <normal_fragment_maps>\n  if (vRegion > 0.5) normal = normalize(mix(normal, nonPerturbedNormal, 0.8));');
    };
    m.customProgramCacheKey = () => 'fh-kit-body';
    return m;
  }

  // ── attach / retarget ────────────────────────────────────────────────
  const tq = new THREE.Quaternion(), tq2 = new THREE.Quaternion(), rootInv = new THREE.Quaternion();
  const tv = new THREE.Vector3();
  function rel(root, obj, out) {           // obj's rotation in the figure's frame
    root.getWorldQuaternion(rootInv).invert();
    return obj.getWorldQuaternion(out).premultiply(rootInv);
  }
  function relPos(root, obj, out) { return root.worldToLocal(obj.getWorldPosition(out)); }

  function attach(fig) {
    if (!proto || !want(fig) || fig.body) return;
    const SU = THREE_ADDONS.SkeletonUtils;
    const model = SU.clone(proto.scene);
    model.scale.setScalar(proto.scale);
    model.rotation.y = proto.yaw;
    fig.root.add(model);
    let skinned = null; const bones = {};
    model.traverse((o) => {
      if (o.isSkinnedMesh && (!skinned || o.geometry.attributes.position.count > skinned.geometry.attributes.position.count)) skinned = o;
      if (o.isBone) bones[o.name] = o;
      if (o.isMesh) { o.castShadow = true; o.frustumCulled = false; }
    });
    skinned.material = kitMaterial(skinned.material, fig.kit);
    // the rig at rest: the pairs, their rest rotations, sides matched by where they stand
    fig.root.updateMatrixWorld(true);
    const side = (o) => Math.sign(relPos(fig.root, o, new THREE.Vector3()).x);
    const pick = (stem, o) => (side(bones[stem + '_l']) === side(o) ? bones[stem + '_l'] : bones[stem + '_r']);
    // [rig joint, bone, where the rig segment points to (a point on the rig), the bone's child]:
    // the body is bound in a T-pose, the rig rests with arms down — each bone's rest is first
    // swung to point along its rig segment, so "rest" means the same pose on both.
    const at = (o, x, y, z) => () => o.localToWorld(new THREE.Vector3(x, y, z));
    const pairs = [[fig.pelvis, bones.pelvis], [fig.chest, bones.spine_01], [fig.neck, bones.neck_01]];
    for (const a of fig.arms) {
      const up = pick('upperarm', a.sh), lo = pick('lowerarm', a.elbow);
      pairs.push([a.sh, up, at(a.elbow, 0, 0, 0), lo], [a.elbow, lo, at(a.elbow, 0, -0.26, 0), lo && lo.children.find((c) => c.isBone)]);
    }
    for (const l of fig.legs) {
      const th = pick('thigh', l.hip), ca = pick('calf', l.knee), fo = pick('foot', l.ankle);
      pairs.push([l.hip, th, at(l.knee, 0, 0, 0), ca], [l.knee, ca, at(l.ankle, 0, 0, 0), fo],
                 [l.ankle, fo, at(l.ankle, 0, -0.04, 0.14), fo && fo.children.find((c) => c.isBone)]);
    }
    const dir = (from, to) => relPos(fig.root, to, new THREE.Vector3()).sub(relPos(fig.root, from, new THREE.Vector3())).normalize();
    const map = pairs.filter(([a, b]) => a && b).map(([a, b, rigTo, child]) => {
      const boneRest = rel(fig.root, b, new THREE.Quaternion());
      if (rigTo && child) {
        const pt = rigTo(); fig.root.worldToLocal(pt);
        const rd = pt.sub(relPos(fig.root, a, new THREE.Vector3())).normalize();
        boneRest.premultiply(new THREE.Quaternion().setFromUnitVectors(dir(b, child), rd));
      }
      return { rig: a, bone: b, rigRestInv: rel(fig.root, a, new THREE.Quaternion()).invert(), boneRest };
    });
    fig.body = {
      model, map, pelvisBone: bones.pelvis,
      rigPelvisRest: relPos(fig.root, fig.pelvis, new THREE.Vector3()),
      bonePelvisRest: relPos(fig.root, bones.pelvis, new THREE.Vector3()),
    };
    // the capsule figure stays the animator, unseen (its name tag stays)
    fig.root.traverse((o) => { if (o.isMesh && !isIn(o, model)) o.visible = false; });
  }
  function isIn(o, top) { for (let p = o; p; p = p.parent) if (p === top) return true; return false; }

  function retarget(fig) {
    const b = fig.body;
    fig.root.updateMatrixWorld(true);
    // pelvis: the rig's bob / lean / drop, as a move off the rest spot
    relPos(fig.root, fig.pelvis, tv).sub(b.rigPelvisRest).add(b.bonePelvisRest);
    fig.root.localToWorld(tv);
    b.pelvisBone.parent.worldToLocal(tv);
    b.pelvisBone.position.copy(tv);
    for (const m of b.map) {               // parents first (the list's order)
      rel(fig.root, m.rig, tq).multiply(m.rigRestInv).multiply(m.boneRest);   // the bone's rotation in the figure's frame
      rel(fig.root, m.bone.parent, tq2).invert();
      m.bone.quaternion.copy(tq2.multiply(tq));
      m.bone.updateMatrixWorld(true);
    }
  }

  // ── hooks ────────────────────────────────────────────────────────────
  const buildBody = P.buildBody, update = P.update;
  P.buildBody = function (...a) {
    this.body = null;                      // buildBody clears the root, body and all
    const r = buildBody.apply(this, a);
    figures.add(this);
    attach(this);
    return r;
  };
  P.update = function (...a) {
    const r = update.apply(this, a);
    if (this.body) retarget(this);
    return r;
  };

  new THREE_ADDONS.GLTFLoader().load(URL_BODY, (gltf) => {
    let skinned = null;
    gltf.scene.traverse((o) => { if (o.isSkinnedMesh && (!skinned || o.geometry.attributes.position.count > skinned.geometry.attributes.position.count)) skinned = o; });
    if (!skinned) { console.warn('bodies: no skinned mesh in', URL_BODY); return; }
    paintRegions(skinned);
    gltf.scene.updateMatrixWorld(true);
    const bones = {}; gltf.scene.traverse((o) => { if (o.isBone) bones[o.name] = o; });
    const p = (n) => bones[n].getWorldPosition(new THREE.Vector3());
    const leg = p('thigh_l').distanceTo(p('calf_l')) + p('calf_l').distanceTo(p('foot_l'));
    proto = { scene: gltf.scene, scale: RIG_LEG / leg, yaw: 0 };
    console.log('bodies: loaded, leg', leg.toFixed(3), 'm → scale', proto.scale.toFixed(3));
    for (const f of figures) attach(f);
  }, undefined, (e) => console.warn('bodies: load failed', e));
})();
