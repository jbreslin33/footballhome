// frontend/js/game/bodies.js — real skinned bodies on the procedural rig (graphics tier 2, James 11/11
// "how realistic can we get the mesh/graphics"). Pure dressing, like players.js.
//
// The body: Quaternius "Universal Base Characters" Superhero male (CC0; game-assets/ubc/README.md),
// 12.5k triangles, a 65-bone humanoid skeleton. players.js's jointed rig stays the animator — the
// gait, the foot IK, every overlay — and becomes an invisible driver: each frame each rig joint's
// rotation, as a change from the rest pose, is copied onto its bone (retargeting by delta rotation
// in the figure's frame, so the two skeletons' different bone axes never matter), and the pelvis
// bone follows the rig pelvis's bob / lean / slide drop. The rig takes the body's own thigh and
// shin (PlayerFigure.setProportions): the IK's planted feet land where the body's feet are, and
// the body stands at its full 1.81 m. Kit: the skin texture is
// overpainted by region (shirt / shorts / socks / boots), chosen per vertex from its dominant bone
// and bind-pose height, in the figure's kit colours.
//
//   default       every player (11/11), unless this device fell back (too slow) — then capsules
//   ?bodies=off   the capsule men      ?bodies=all   every player, fallback ignored
//   ?bodies=one   one home outfielder (slot 1) — a side-by-side test
// FH original (the retarget and the region paint); the body is Quaternius's.
(function () {
  'use strict';
  // On by default (11/11). ?bodies=off = the capsule men; ?bodies=all forces bodies even where this
  // device fell back; ?bodies=one = slot 1 only. A device whose frames ran too slow with bodies
  // remembers it (localStorage fh.game.bodies = 'off') and gets capsules until ?bodies=all.
  const AUTO_KEY = 'fh.game.bodies';
  let fellBack = false;
  try { fellBack = localStorage.getItem(AUTO_KEY) === 'off'; } catch (_) { /* no storage */ }
  const q = new URLSearchParams(location.search).get('bodies') || (fellBack ? 'off' : 'all');
  if (q === 'off' || !window.PlayerFigure || !window.THREE_ADDONS || !THREE_ADDONS.GLTFLoader) return;
  const forced = new URLSearchParams(location.search).get('bodies') === 'all';
  const want = (fig) => !fig.official && (q === 'all' || (q === 'one' && fig.slot === 1));

  const URL_BODY = 'game-assets/ubc/body_male.gltf';
  // The pack's hair: modelled in the body's space; a grey texture made to be tinted. Bald = buzzed.
  // looks by slot: each a list of the pack's pieces (the beard goes with the buzz cut)
  const LOOKS = [['hair_parted'], ['hair_buzzed'], ['hair_parted'], ['hair_buzzed', 'hair_beard'], ['hair_buzzed']];
  const URL_HAIR = [...new Set(LOOKS.flat())].map((n) => `game-assets/ubc/${n}.gltf`);
  const HAIR_TEX = 0x8f908d, SKIN_TEX = 0xa0734f;   // the textures' mean colours (sRGB)
  // a tint that turns the texture's mean colour into his: wanted ÷ mean, per channel, in linear light
  function tintOver(want, mean) {
    const w = new THREE.Color(want), m = new THREE.Color(mean);
    return new THREE.Color(Math.min(3, w.r / m.r), Math.min(3, w.g / m.g), Math.min(3, w.b / m.b));
  }
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
      else if (/^(spine|clavicle)/.test(n) && y < 1.60) r = 1;          // over the shoulders (the neck bone stays skin)
      else if (/^pelvis/.test(n) && y >= 0.92) r = 1;
      else if (/^upperarm/.test(n) && ax < 0.36) r = 1;      // short sleeves
      out[i] = r;
    }
    g.setAttribute('aRegion', new THREE.BufferAttribute(out, 1));
  }

  // ── relaxed hands: the T-pose's straight fingers curled once, before any clone ──
  // Each finger joint turns toward the palm (palms face down in the bind pose) about its own
  // direction × down: knuckle 0.35, middle 0.55, tip 0.4 rad; the thumb 0.2 each. [FH]
  function relaxHands(scene) {
    const bones = {}; scene.traverse((o) => { if (o.isBone) bones[o.name] = o; });
    const down = new THREE.Vector3(0, -1, 0), a = new THREE.Vector3(), c = new THREE.Vector3();
    const qw = new THREE.Quaternion(), qb = new THREE.Quaternion(), qp = new THREE.Quaternion();
    for (const side of ['l', 'r']) for (const [f, angs] of [['index', [0.35, 0.55, 0.4]], ['middle', [0.35, 0.55, 0.4]],
                                                            ['ring', [0.4, 0.6, 0.4]], ['pinky', [0.45, 0.6, 0.4]], ['thumb', [0.2, 0.2, 0.2]]]) {
      for (let k = 0; k < 3; k++) {
        const b = bones[`${f}_0${k + 1}_${side}`]; if (!b) continue;
        const ch = b.children.find((x) => x.isBone); if (!ch) continue;
        scene.updateMatrixWorld(true);
        b.getWorldPosition(a); ch.getWorldPosition(c);
        const axis = c.sub(a).normalize().cross(down).normalize();
        if (axis.lengthSq() < 0.5) continue;
        qw.setFromAxisAngle(axis, angs[k]);
        b.parent.getWorldQuaternion(qp).invert();
        b.getWorldQuaternion(qb);
        b.quaternion.copy(qp.multiply(qw).multiply(qb));
      }
    }
    scene.updateMatrixWorld(true);
  }

  // ── a footballer, not a superhero: slim the bind mesh once ──────────
  // Each vertex is pulled toward its bones' axes (bone → its child, bind pose), by a factor per
  // bone, blended by its skin weights so nothing creases. Arms and the shoulder / trapezius mass
  // most, the torso and thighs a little, head / hands / feet not at all. [FH]
  const SLIM = [[/^(upperarm|lowerarm)/, 0.8], [/^clavicle/, 0.78], [/^neck/, 0.88], [/^spine_03/, 0.86],
                [/^spine_0[12]/, 0.9], [/^pelvis/, 0.95], [/^thigh/, 0.9], [/^calf/, 0.94]];
  function slimBody(mesh) {
    const g = mesh.geometry;
    if (g.userData.fhSlim) return;
    g.userData.fhSlim = true;
    const bones = mesh.skeleton.bones;
    const axis = bones.map((b) => {
      const f = (SLIM.find(([re]) => re.test(b.name)) || [null, 1])[1];
      const kid = b.children.find((c) => c.isBone);
      const a = b.getWorldPosition(new THREE.Vector3());
      const e = kid ? kid.getWorldPosition(new THREE.Vector3()) : a.clone();
      return { f, a, d: e.sub(a), len2: Math.max(1e-6, e.lengthSq()) };
    });
    const si = g.getAttribute('skinIndex'), sw = g.getAttribute('skinWeight'), pos = g.getAttribute('position');
    const p = new THREE.Vector3(), q = new THREE.Vector3(), out = new THREE.Vector3();
    for (let i = 0; i < pos.count; i++) {
      p.fromBufferAttribute(pos, i);
      out.set(0, 0, 0); let wsum = 0;
      for (let k = 0; k < 4; k++) {
        const w = sw.getComponent(i, k); if (w <= 0) continue;
        const ax = axis[si.getComponent(i, k)];
        const t = Math.min(1, Math.max(0, q.copy(p).sub(ax.a).dot(ax.d) / ax.len2));
        q.copy(ax.d).multiplyScalar(t).add(ax.a);             // the nearest point on the bone
        out.addScaledVector(q.add(p.clone().sub(q).multiplyScalar(ax.f)), w);
        wsum += w;
      }
      if (wsum > 0) pos.setXYZ(i, out.x / wsum, out.y / wsum, out.z / wsum);
    }
    pos.needsUpdate = true;
    g.computeBoundingSphere();
  }

  // ── boots and the number, read off the slimmed bind mesh ────────────
  // Boots: each foot's convex hull (its foot / toe vertices under 14 cm), puffed 4%, pinned to the
  // foot bone — a smooth boot over the modelled toes. The number: a patch on the upper back, pinned
  // to spine_03 at the back's own depth there. [FH]
  function bootsAndBack(mesh, bones) {
    const g = mesh.geometry, names = mesh.skeleton.bones.map((b) => b.name);
    const si = g.getAttribute('skinIndex'), sw = g.getAttribute('skinWeight'), pos = g.getAttribute('position'), reg = g.getAttribute('aRegion');
    const pts = { l: [], r: [] }; let backZ = Infinity;
    for (let i = 0; i < pos.count; i++) {
      const x = pos.getX(i), y = pos.getY(i), z = pos.getZ(i);
      if (reg.getX(i) === 1 && y > 1.28 && y < 1.42 && Math.abs(x) < 0.08) backZ = Math.min(backZ, z);
      if (y >= 0.14) continue;
      let best = 0, bw = -1;
      for (let k = 0; k < 4; k++) { const w = sw.getComponent(i, k); if (w > bw) { bw = w; best = si.getComponent(i, k); } }
      const m = /^(foot|ball)_(l|r)$/.exec(names[best] || '');
      if (m) pts[m[2]].push(new THREE.Vector3(x, y, z));
    }
    const boots = {};
    for (const s of ['l', 'r']) {
      if (pts[s].length < 8) continue;
      const geo = new THREE_ADDONS.ConvexGeometry(pts[s]);
      geo.computeBoundingBox();
      const c = geo.boundingBox.getCenter(new THREE.Vector3());
      geo.translate(-c.x, -c.y, -c.z); geo.scale(1.04, 1.06, 1.04); geo.translate(c.x, c.y + 0.002, c.z);
      geo.applyMatrix4(bones['foot_' + s].matrixWorld.clone().invert());   // into the foot bone's frame
      geo.computeVertexNormals();
      boots['foot_' + s] = geo;
    }
    const back = isFinite(backZ)
      ? bones.spine_03.matrixWorld.clone().invert().multiply(new THREE.Matrix4().makeTranslation(0, 1.35, backZ - 0.012))
      : null;
    return { boots, back };
  }
  function numberPatch(n, kit) {
    const c = document.createElement('canvas');
    c.width = c.height = 128;
    const x = c.getContext('2d');
    x.fillStyle = '#' + (kit.trim ?? 0xffffff).toString(16).padStart(6, '0');
    x.font = 'bold 92px system-ui, sans-serif';
    x.textAlign = 'center'; x.textBaseline = 'middle';
    x.fillText(String(n), 64, 70);
    const m = new THREE.Mesh(new THREE.PlaneGeometry(0.24, 0.24),
      new THREE.MeshStandardMaterial({ map: new THREE.CanvasTexture(c), transparent: true, roughness: 0.8, depthWrite: false,
                                       polygonOffset: true, polygonOffsetFactor: -2 }));
    m.rotation.y = Math.PI;   // faces −z: the back
    return m;
  }

  function kitMaterial(base, kit, skinTint) {
    const m = base.clone();
    const u = {
      kitShirt: { value: new THREE.Color(kit.shirt) }, kitShorts: { value: new THREE.Color(kit.shorts) },
      kitSocks: { value: new THREE.Color(kit.socks) }, kitBoots: { value: new THREE.Color(kit.boots) },
      skinTint: { value: skinTint },
    };
    m.onBeforeCompile = (sh) => {
      Object.assign(sh.uniforms, u);
      sh.vertexShader = 'attribute float aRegion;\nvarying float vRegion;\n' +
        sh.vertexShader.replace('#include <begin_vertex>', '#include <begin_vertex>\n  vRegion = aRegion;');
      sh.fragmentShader = 'uniform vec3 kitShirt, kitShorts, kitSocks, kitBoots, skinTint;\nvarying float vRegion;\n' +
        sh.fragmentShader.replace('#include <map_fragment>', [
          '#include <map_fragment>',
          '  if (vRegion < 0.5) diffuseColor.rgb *= skinTint;',   // his skin tone over the texture's mid-tone
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
  const tq = new THREE.Quaternion(), tq2 = new THREE.Quaternion(), tq3 = new THREE.Quaternion(), rootInv = new THREE.Quaternion();
  const tv = new THREE.Vector3();
  function rel(root, obj, out) {           // obj's rotation in the figure's frame
    root.getWorldQuaternion(rootInv).invert();
    return obj.getWorldQuaternion(out).premultiply(rootInv);
  }
  function relPos(root, obj, out) { return root.worldToLocal(obj.getWorldPosition(out)); }

  function attach(fig) {
    if (!proto || disabled || !want(fig) || fig.body) return;
    const SU = THREE_ADDONS.SkeletonUtils;
    const model = SU.clone(proto.scene);
    model.scale.setScalar(proto.scale);
    // the rig takes the body's own leg (no shrinking the body to the rig): its thigh and shin, and
    // the pelvis standing as high over the 0.085 m ankle plant as the capsule rig's did
    fig.setProportions(proto.legA, proto.legB, proto.legA + proto.legB + 0.085 + 0.06 - 0.015);
    model.rotation.y = proto.yaw;
    fig.root.add(model);
    let skinned = null; const bones = {};
    model.traverse((o) => {
      if (o.isSkinnedMesh && (!skinned || o.geometry.attributes.position.count > skinned.geometry.attributes.position.count)) skinned = o;
      if (o.isBone) bones[o.name] = o;
      if (o.isMesh) { o.castShadow = true; o.frustumCulled = false; }
    });
    skinned.material = kitMaterial(skinned.material, fig.kit, tintOver(fig.skinHex ?? 0xc68642, SKIN_TEX));
    // hair: one of the pack's cuts by slot, pinned to the head bone at its bind offset, in his colour
    for (const [bn, geo] of Object.entries(proto.boots)) {
      if (!bones[bn]) continue;
      const boot = new THREE.Mesh(geo, new THREE.MeshStandardMaterial({ color: fig.kit.boots ?? 0x111111, roughness: 0.45 }));
      boot.castShadow = true; boot.frustumCulled = false;
      bones[bn].add(boot);
    }
    if (proto.back && bones.spine_03 && !fig.official) {
      const holder = new THREE.Group();
      holder.matrixAutoUpdate = false; holder.matrix.copy(proto.back);
      holder.add(numberPatch(fig.number || fig.slot % 11 + 1, fig.kit));
      bones.spine_03.add(holder);
    }
    const hairMat = proto.hairMat.clone();
    hairMat.color = tintOver(fig.hairHex ?? 0x2b1b10, HAIR_TEX);
    for (const n of (bones.Head ? LOOKS[fig.slot % LOOKS.length] : [])) {
      const cut = proto.hair[n];
      if (!cut) continue;
      const h = new THREE.Mesh(cut.geometry, hairMat);
      h.matrixAutoUpdate = false; h.matrix.copy(cut.toHead);
      h.castShadow = true; h.frustumCulled = false;
      bones.Head.add(h);
    }
    // the rig at rest: the pairs, their rest rotations, sides matched by where they stand. The body
    // often arrives mid-stride, so the rig's joints are zeroed while rest is read, then put back.
    const joints = [fig.pelvis, fig.chest, fig.neck, ...fig.arms.flatMap((a) => [a.sh, a.elbow]),
                    ...fig.legs.flatMap((l) => [l.hip, l.knee, l.ankle])].filter(Boolean);
    const saved = joints.map((j) => j.quaternion.clone());
    const pelvisAt = fig.pelvis.position.clone();
    joints.forEach((j) => j.quaternion.identity());
    fig.pelvis.position.set(0, fig.pelvisH, 0);
    fig.root.updateMatrixWorld(true);
    const side = (o) => Math.sign(relPos(fig.root, o, new THREE.Vector3()).x);
    const pick = (stem, o) => (side(bones[stem + '_l']) === side(o) ? bones[stem + '_l'] : bones[stem + '_r']);
    // Each bone's target is a rotation-from-rest in the figure's frame (a "delta"), times its rest.
    // Most take their rig joint's delta; the spine, collarbones, neck and head blend between two
    // (11/11, James "players look stiff"): the chest's turn spread up spine_01 / 02 / 03 (35 / 70 /
    // 100% of it over the pelvis), each collarbone 20% of its arm's swing, the neck half the head's.
    const restInv = new Map();
    for (const j of joints) restInv.set(j, rel(fig.root, j, new THREE.Quaternion()).invert());
    const at = (o, x, y, z) => () => o.localToWorld(new THREE.Vector3(x, y, z));
    const dir = (from, to) => relPos(fig.root, to, new THREE.Vector3()).sub(relPos(fig.root, from, new THREE.Vector3())).normalize();
    // the body is bound in a T-pose, the rig rests with arms down — a limb bone's rest is first
    // swung to point along its rig segment, so "rest" means the same pose on both
    const restOf = (bone, rig, rigTo, child) => {
      const q = rel(fig.root, bone, new THREE.Quaternion());
      if (rigTo && child) {
        const pt = rigTo(); fig.root.worldToLocal(pt);
        const rd = pt.sub(relPos(fig.root, rig, new THREE.Vector3())).normalize();
        q.premultiply(new THREE.Quaternion().setFromUnitVectors(dir(bone, child), rd));
      }
      return q;
    };
    const kid = (b) => b && b.children.find((c) => c.isBone);
    const map = [];
    const add = (bone, delta, rig, rigTo, child) => { if (bone) map.push({ bone, delta, boneRest: restOf(bone, rig, rigTo, child) }); };
    const D = (j) => ['d', j], B = (a, b2, f) => ['b', a, b2, f];
    add(bones.pelvis, D(fig.pelvis));
    add(bones.spine_01, B(fig.pelvis, fig.chest, 0.35));
    add(bones.spine_02, B(fig.pelvis, fig.chest, 0.7));
    add(bones.spine_03, D(fig.chest));
    for (const a of fig.arms) add(pick('clavicle', a.sh), B(fig.chest, a.sh, 0.2));
    add(bones.neck_01, B(fig.chest, fig.neck, 0.5));
    add(bones.Head, D(fig.neck));
    for (const a of fig.arms) {
      const up = pick('upperarm', a.sh), lo = pick('lowerarm', a.elbow);
      add(up, D(a.sh), a.sh, at(a.elbow, 0, 0, 0), lo);
      add(lo, D(a.elbow), a.elbow, at(a.elbow, 0, -0.26, 0), kid(lo));
    }
    for (const l of fig.legs) {
      const th = pick('thigh', l.hip), ca = pick('calf', l.knee), fo = pick('foot', l.ankle);
      add(th, D(l.hip), l.hip, at(l.knee, 0, 0, 0), ca);
      add(ca, D(l.knee), l.knee, at(l.ankle, 0, 0, 0), fo);
      add(fo, D(l.ankle), l.ankle, at(l.ankle, 0, -0.04, 0.14), kid(fo));
    }
    fig.body = {
      model, map, restInv, pelvisBone: bones.pelvis,
      rigPelvisRest: relPos(fig.root, fig.pelvis, new THREE.Vector3()),
      bonePelvisRest: relPos(fig.root, bones.pelvis, new THREE.Vector3()),
    };
    joints.forEach((j, i) => j.quaternion.copy(saved[i]));
    fig.pelvis.position.copy(pelvisAt);
    fig.root.updateMatrixWorld(true);
    // the capsule figure stays the animator, unseen (its name tag stays)
    const hidden = [];
    fig.root.traverse((o) => { if (o.isMesh && o.visible && !isIn(o, model)) { o.visible = false; hidden.push(o); } });
    fig.body.hidden = hidden;
    watchFrames();
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
    const cache = b.cache || (b.cache = new Map());
    cache.clear();
    const delta = (j) => {                 // the rig joint's rotation from rest, in the figure's frame
      let q = cache.get(j);
      if (!q) { q = rel(fig.root, j, new THREE.Quaternion()).multiply(b.restInv.get(j)); cache.set(j, q); }
      return q;
    };
    for (const m of b.map) {               // parents first (the list's order)
      const d = m.delta;
      if (d[0] === 'd') tq.copy(delta(d[1]));
      else {                               // blend: a's delta, then f of the way on to b's
        const qa = delta(d[1]);
        tq2.copy(qa).invert().multiply(delta(d[2]));
        tq.copy(qa).multiply(tq3.identity().slerp(tq2, d[3]));
      }
      tq.multiply(m.boneRest);             // the bone's rotation in the figure's frame
      rel(fig.root, m.bone.parent, tq2).invert();
      m.bone.quaternion.copy(tq2.multiply(tq));
      m.bone.updateMatrixWorld(true);
    }
  }

  // Back to the capsule man: the body off, his capsules on, the capsule rig's own proportions.
  function detach(fig) {
    const b = fig.body;
    if (!b) return;
    fig.root.remove(b.model);
    for (const o of b.hidden) o.visible = true;
    fig.body = null;
    fig.setProportions(0.42, 0.40, 0.95);
  }

  // ── the safety net: too slow with bodies → capsules ──────────────────
  // Over the first 15 s with bodies on screen (visible tab; gaps over 250 ms — a tab switch, a
  // stall — ignored), if the median frame takes over 45 ms (~22 fps), every body goes and this
  // device remembers. ?bodies=all ignores it.
  let watching = false;
  function watchFrames() {
    if (watching || forced) return;
    watching = true;
    const dts = []; let last = 0; const t0 = performance.now();
    const step = (now) => {
      if (document.visibilityState === 'visible' && last && now - last < 250) dts.push(now - last);
      last = now;
      if (now - t0 < 15000 || dts.length < 60) { requestAnimationFrame(step); return; }
      dts.sort((a, b) => a - b);
      const med = dts[dts.length >> 1];
      if (med > 45) {
        console.warn('bodies: median frame', med.toFixed(1), 'ms with bodies on — back to the capsule figures on this device (?bodies=all to force)');
        for (const f of figures) detach(f);
        disabled = true;
        try { localStorage.setItem(AUTO_KEY, 'off'); } catch (_) { /* this visit only */ }
      } else {
        console.log('bodies: median frame', med.toFixed(1), 'ms — bodies stay');
      }
    };
    requestAnimationFrame(step);
  }
  let disabled = false;
  // console / test handle: what the safety net does, on demand
  window.__bodies = { figures, detachAll() { for (const f of figures) detach(f); disabled = true; } };

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
    gltf.scene.updateMatrixWorld(true);
    relaxHands(gltf.scene);
    paintRegions(skinned);
    slimBody(skinned);
    const bnames = {}; gltf.scene.traverse((o) => { if (o.isBone) bnames[o.name] = o; });
    const extra = bootsAndBack(skinned, bnames);
    const bones = {}; gltf.scene.traverse((o) => { if (o.isBone) bones[o.name] = o; });
    const p = (n) => bones[n].getWorldPosition(new THREE.Vector3());
    const headInv = bones.Head.matrixWorld.clone().invert();
    const loader = new THREE_ADDONS.GLTFLoader();
    Promise.all(URL_HAIR.map((u) => loader.loadAsync(u).then((h) => {
      let m = null; h.scene.traverse((o) => { if (o.isMesh && !m) m = o; });
      h.scene.updateMatrixWorld(true);
      return [u, { geometry: m.geometry, material: m.material, toHead: headInv.clone().multiply(m.matrixWorld) }];
    }).catch((e) => { console.warn('bodies: hair failed', u, e); return [u, null]; }))).then((pairs) => {
      const hair = {};
      for (const [u, v] of pairs) if (v) hair[u.replace(/^.*\/|\.gltf$/g, '')] = v;
      const any = Object.values(hair)[0];
      proto = { scene: gltf.scene, scale: 1, yaw: 0, hair, hairMat: any ? any.material : new THREE.MeshStandardMaterial(),
                boots: extra.boots, back: extra.back,
                legA: p('thigh_l').distanceTo(p('calf_l')), legB: p('calf_l').distanceTo(p('foot_l')) };
      console.log('bodies: loaded, thigh', proto.legA.toFixed(3), 'shin', proto.legB.toFixed(3), 'm, full size · hair', pairs.filter((x) => x[1]).length);
      for (const f of figures) attach(f);
    });
  }, undefined, (e) => console.warn('bodies: load failed', e));
})();
