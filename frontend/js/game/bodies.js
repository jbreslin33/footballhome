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
//   default       the capsule men (11/12, James: "the animation is really bad … go back to simpler
//                 mesh and lets just get the movement and kicking etc natural")
//   ?bodies=all   every player, fallback ignored
//   ?bodies=one   one home outfielder (slot 1) — a side-by-side test
//   ?bodies=anim  every player, moved by animation clips (G5.105, James 11/13 "really don't like the
//                 player movement … full realism?"): Quaternius "Universal Animation Library"
//                 (CC0; game-assets/ual/README.md) idle / walk / jog / sprint, blended by the engine's
//                 speed, the stride rate from players.js's gait, the walk/jog mix matching the stride
//                 length so the feet don't slide; the hips turn to the run, the spine and head back to
//                 his facing; past ~110° off it he backpedals (the clips played backwards). Kicks,
//                 touches, headers, dives, slides, stumbles, celebrations and keepers: the rig, as before,
//                 cross-faded in over ~0.1 s.
// FH original (the retarget and the region paint); the body is Quaternius's.
(function () {
  'use strict';
  // OFF by default since 11/12 (capsules); on 11/11-11/12. ?bodies=all forces bodies even where this
  // device fell back; ?bodies=one = slot 1 only. A device whose frames ran too slow with bodies
  // remembers it (localStorage fh.game.bodies = 'off') and gets capsules until ?bodies=all.
  const AUTO_KEY = 'fh.game.bodies';
  const q = new URLSearchParams(location.search).get('bodies') || 'off';
  if (q === 'off' || !window.PlayerFigure || !window.THREE_ADDONS || !THREE_ADDONS.GLTFLoader) return;
  const forced = new URLSearchParams(location.search).get('bodies') === 'all';
  const ANIM = q === 'anim';
  const want = (fig) => !fig.official && (q === 'all' || ANIM || (q === 'one' && fig.slot === 1));
  const URL_CLIPS = 'game-assets/ual/locomotion.glb?v=20261113h';
  // G5.105: each clip's stride (one loop = two steps, m) and the UAL pelvis rest height (m), read off
  // the pack's root-motion file (walk 0.97 m/s, jog 5.36, sprint 8.25).
  const CLIP = { idle: 'Idle_Loop', walk: 'Walk_Loop', jog: 'Jog_Fwd_Loop', sprint: 'Sprint_Loop' };
  // G5.106: CMU motion capture retargeted onto this body (game/scripts/retarget_cmu.py; README in ual/):
  // side-steps, a defensive shuffle (mirrored for the left) and a backward walk. ?cmu=0 leaves them out.
  const URL_CMU = 'game-assets/ual/cmu_moves.glb?v=20261113c';   // bump with every rebuild
  const CMU = ['side_l', 'side_r', 'shuffle_l', 'shuffle_r', 'back'];
  const USE_CMU = new URLSearchParams(location.search).get('cmu') !== '0';
  const FORCE = new URLSearchParams(location.search).get('clip');   // ?clip=<name>: every man plays that one clip (a test)
  // each one's recorded speed along its direction (m/s, printed by retarget_cmu.py): its playback rate
  // follows his speed that way, 0.6-2× (DESIGN §8.207)
  const CMU_MPS = { side_l: 0.58, side_r: 0.48, shuffle_l: 3.10, shuffle_r: 3.10, back: 0.82 };
  // G5.107: kicks — CMU 10_01 (a pass, toe 11.4 m/s) and 10_05 (a hit, 15.6 m/s), right foot, mirrored for the
  // left; one shot each, the toe's peak speed (contact) KICK_CONTACT s in. ?kicks=0 = the rig's kick.
  const KICKS = ['kick_pass_r', 'kick_pass_l', 'kick_power_r', 'kick_power_l'];
  const KICK_CONTACT = 0.60, KICK_POWER = 0.45;
  const USE_KICKS = new URLSearchParams(location.search).get('kicks') !== '0';
  // G5.108: cuts — CMU 78_04 "SuperTightLeft" (+64°) and 78_05 "SuperTightRight" (−80°), one shot each, the
  // turn's peak CUT_AT s in, heading taken out (the engine turns him). Fired when his travel turns faster than
  // CUT_RATE rad/s above CUT_SPEED m/s (live: ~1.2 a man a minute), at most one each CUT_COOL s. ?cuts=0 = off.
  const CUTS = ['cut_l', 'cut_r'];
  const CUT_AT = 0.4, CUT_RATE = 2.0, CUT_SPEED = 1.8, CUT_COOL = 0.8;
  const USE_CUTS = new URLSearchParams(location.search).get('cuts') !== '0';
  // G5.109: the slide tackle — Quaternius UAL 2 Slide_Start / Slide_Loop / Slide_Exit (CC0, same rig). The
  // engine's "down in a tackle" flag (bit 2) lasts 0.17 s (won) or 0.5 s (missed) after the lunge: on it the
  // dive plays from SLIDE_FROM at SLIDE_RATE×, the loop holds while it lasts, then the exit (0.5 s) gets him
  // up. ?slides=0 = the rig's slide.
  const URL_SLIDE = 'game-assets/ual/ual2.glb?v=20261113h';
  const SLIDES = { slide_start: 'Slide_Start', slide_loop: 'Slide_Loop', slide_exit: 'Slide_Exit' };
  const SLIDE_FROM = 0.35, SLIDE_RATE = 1.8;
  const USE_SLIDES = new URLSearchParams(location.search).get('slides') !== '0';
  // G5.110: headers, stumbles, celebrations from clips (UAL 1 Jump_Start / Jump_Loop / Jump_Land / Hit_Chest,
  // UAL 2 Yes; CC0, same rig). players.js's header timeline (0.75 s: crouch 0-0.12, air 0.12-0.56 with the
  // ball met at the top, land) maps onto the jump; his lift (hd.up) is added (the clips' jump height is in
  // their root motion, not here); the head snaps through the ball at the top. The dispossessed flag (bit 3,
  // 10 ticks = 0.33 s) plays Hit_Chest (0.33 s). celebrate() (3.5 s) plays Yes, less of it as he runs.
  const EXTRA1 = { jump_start: 'Jump_Start', jump_loop: 'Jump_Loop', jump_land: 'Jump_Land', hit: 'Hit_Chest' };
  const USE_EXTRA = new URLSearchParams(location.search).get('extra') !== '0';
  const STRIDE_WALK = 1.30, STRIDE_JOG = 5.0, UAL_PELVIS = 0.9167;
  const JOG_FLOOR = +(new URLSearchParams(location.search).get('jogfloor') ?? 0);   // the jog's least share once running (?jogfloor= to try)

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
    let anim = null;
    if (ANIM && proto.clips) {
      const mixer = new THREE.AnimationMixer(model);
      const act = {};
      for (const [k, c] of Object.entries(proto.clips)) { act[k] = mixer.clipAction(c); act[k].play(); act[k].setEffectiveWeight(0); }
      anim = { mixer, act, ph: 0, lastPh: fig.phase || 0, idleT: (fig.slot * 0.37) % 2.5, yawOff: 0, ov: 0,
               twist: ['spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head'].map((n) => bones[n]).filter(Boolean),
               pelvisPos: new THREE.Vector3(), saved: [],
               feet: ['l', 'r'].map((sd) => ({ thigh: bones['thigh_' + sd], calf: bones['calf_' + sd], foot: bones['foot_' + sd],
                                              ball: bones['ball_' + sd], lock: null, tgt: null, w: 0 })).filter((f) => f.thigh && f.calf && f.foot && f.ball) };
    }
    fig.body = {
      model, map, restInv, pelvisBone: bones.pelvis, anim,
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

  // ── G5.105: the clips ─────────────────────────────────────────────────
  const smooth = (x) => { const t = Math.min(1, Math.max(0, x)); return t * t * (3 - 2 * t); };
  const wrapA = (a) => Math.atan2(Math.sin(a), Math.cos(a));
  const UP = new THREE.Vector3(0, 1, 0), tw = new THREE.Quaternion(), tw2 = new THREE.Quaternion();
  const TWIST = [0.2, 0.2, 0.25, 0.2, 0.15];   // of the hips' turn given back, spine up to the head [FH]
  function overlayOn(fig, A) {
    const W = fig.w || {};
    const kickClip = fig.kk && A && A.act.kick_pass_r && (fig.kk.amp || 1) >= 0.99;   // a full kick plays its clip
    const slideClip = A && A.act.slide_loop;                                        // the slide plays its clips
    const extra = A && A.act.jump_loop;                                             // headers / stumbles / celebrations too
    // G5.111: a keeper is on the clips too; the rig only for his dive and with the ball in his hands
    return !!((fig.keeper && (fig.dv || fig.hadBall || !A || !A.act.jump_loop)) || (fig.kk && !kickClip && fig.kk.t >= 0) || (fig.rc && fig.rc.t >= 0) || (fig.hd && !extra) || fig.dv || (!slideClip && (W.slide || 0) > 0.05) || (!extra && (W.stumble || 0) > 0.05) || (!(A && A.act.cele) && (W.cele || 0) > 0.05));
  }
  // G5.105b: foot lock. A foot the clip puts down (its ball joint under LOCK_ON m) is pinned where it landed;
  // a two-bone solve (thigh, calf) holds it there, the foot's own turn kept, until the clip lifts it (over
  // LOCK_OFF m) or it would stretch more than LOCK_MAX m, then eased off over ~0.1 s. [FH; the solve is the
  // law of cosines in the leg's own plane]
  const LOCK_ON = 0.04, LOCK_OFF = 0.075, LOCK_MAX = 0.45;
  const FOOTLOCK = new URLSearchParams(location.search).get('footlock') !== '0';
  const fv1 = new THREE.Vector3(), fv2 = new THREE.Vector3(), fv3 = new THREE.Vector3(), fv4 = new THREE.Vector3(), fv5 = new THREE.Vector3();
  const fq1 = new THREE.Quaternion(), fq2 = new THREE.Quaternion(), fq3 = new THREE.Quaternion();
  function setWorldQ(bone, qw) {                       // a bone's world rotation → its local one
    bone.parent.getWorldQuaternion(fq3).invert();
    bone.quaternion.copy(fq3.multiply(qw));
    bone.updateMatrixWorld(true);
  }
  function legTo(F, T) {
    F.foot.getWorldQuaternion(fq1);                    // the foot keeps its turn
    const h = F.thigh.getWorldPosition(fv1), k = F.calf.getWorldPosition(fv2), a = F.foot.getWorldPosition(fv3);
    const la = h.distanceTo(k), lb = k.distanceTo(a);
    const dT = Math.min(la + lb - 1e-3, Math.max(Math.abs(la - lb) + 1e-3, h.distanceTo(T)));
    const u = fv4.copy(h).sub(k), w = fv5.copy(a).sub(k);
    const cur = u.angleTo(w);
    const want = Math.acos(Math.min(1, Math.max(-1, (la * la + lb * lb - dT * dT) / (2 * la * lb))));
    const n = u.clone().cross(w);
    if (n.lengthSq() > 1e-10) {
      n.normalize();
      F.calf.getWorldQuaternion(fq2).premultiply(tw.setFromAxisAngle(n, want - cur));
      setWorldQ(F.calf, fq2);
    }
    const a2 = F.foot.getWorldPosition(fv3);
    tw.setFromUnitVectors(fv4.copy(a2).sub(h).normalize(), fv5.copy(T).sub(h).normalize());
    F.thigh.getWorldQuaternion(fq2).premultiply(tw);
    setWorldQ(F.thigh, fq2);
    setWorldQ(F.foot, fq1);
    F.ball.updateMatrixWorld(true);
  }
  function footLock(A, dt) {
    for (const F of A.feet) {
      const by = F.ball.getWorldPosition(fv1).y;
      const at = F.foot.getWorldPosition(new THREE.Vector3());
      if (!F.lock && by < LOCK_ON && A.ov < 0.3) { F.lock = at.clone(); F.tgt = F.lock; }
      else if (F.lock && (by > LOCK_OFF || at.distanceTo(F.lock) > LOCK_MAX || A.ov >= 0.3)) F.lock = null;
      F.w = F.lock ? Math.min(1, F.w + dt * 25) : Math.max(0, F.w - dt * 10);
      if (F.w > 0 && F.tgt) legTo(F, at.lerp(F.tgt, F.w));
      if (F.w <= 0) F.tgt = null;
    }
  }
  function animate(fig, dt, ctx) {
    const b = fig.body, A = b.anim;
    const s = fig.speed || 0, vx = (ctx && ctx.vx) || 0, vy = (ctx && ctx.vy) || 0;
    const sp = Math.hypot(vx, vy);
    const m = smooth((s - 0.25) / 0.6);
    // the overlays (kick, touch, header, dive, slide, stumble, celebrate, keeper): the rig
    A.ov += ((overlayOn(fig, A) ? 1 : 0) - A.ov) * Math.min(1, dt * 12);
    // G5.107: a full kick → its clip, timed so the clip's contact lands on the engine's
    const K = fig.kk;
    if (A.act.kick_pass_r && K && (K.amp || 1) >= 0.99 && K !== A.kickSrc) {
      A.kickSrc = K;
      // G5.112: by the engine's kick — a shot or a lofted ball swings hard, a short pass doesn't; a ground
      // kick (a drive or a long pass) by its pace. No kind (an older server): by the ball's speed.
      const hard = K.kind === 3 || K.kind === 2 ? true : K.kind === 0 ? false : K.power > KICK_POWER;
      A.kick = { name: (hard ? 'kick_power_' : 'kick_pass_') + (K.leg === 1 ? 'l' : 'r'),
                 t: KICK_CONTACT - (K.contact - K.t) };   // G5.113: below 0 = armed early, the clip waits
    }
    if (A.kick) { A.kick.t += dt; if (A.kick.t >= A.act[A.kick.name].getClip().duration) A.kick = null; }
    A.kw = (A.kw || 0) + ((A.kick && A.kick.t >= 0 ? 1 : 0) - (A.kw || 0)) * Math.min(1, dt * (A.kick ? 18 : 6));
    // G5.109: the slide tackle — dive, hold, get up
    if (A.act.slide_loop) {
      const down = !!(((ctx && ctx.flags) || 0) & 4);
      if (down && (!A.sl || A.sl.ph === 'exit')) A.sl = { ph: 'start', t: SLIDE_FROM * A.act.slide_start.getClip().duration };
      if (A.sl) {
        const d = (k) => A.act[k].getClip().duration;
        if (A.sl.ph === 'start') { A.sl.t += dt * SLIDE_RATE; if (A.sl.t >= d('slide_start')) A.sl = { ph: 'loop', t: 0 }; }
        else if (A.sl.ph === 'loop') { A.sl.t = (A.sl.t + dt) % d('slide_loop'); }
        if (!down && A.sl.ph !== 'exit' && !(A.sl.ph === 'start')) A.sl = { ph: 'exit', t: 0 };
        else if (A.sl.ph === 'exit') { A.sl.t += dt; if (A.sl.t >= d('slide_exit')) A.sl = null; }
      }
      A.slw = (A.slw || 0) + ((A.sl ? 1 : 0) - (A.slw || 0)) * Math.min(1, dt * (A.sl ? 20 : 8));
    }
    // G5.110: header / stumble / celebration
    const hd = A.act.jump_loop ? fig.hd : null;
    A.hw = (A.hw || 0) + ((hd ? 1 : 0) - (A.hw || 0)) * Math.min(1, dt * (hd ? 25 : 10));
    if (hd) A.hdLast = { t: hd.t, up: hd.up };
    const stumble = A.act.hit && !!(((ctx && ctx.flags) || 0) & 8);
    if (stumble && !A.stum) A.stum = { t: 0 };
    if (A.stum) { A.stum.t += dt; if (A.stum.t >= A.act.hit.getClip().duration + 0.1) A.stum = null; }
    A.stw = (A.stw || 0) + ((A.stum ? 1 : 0) - (A.stw || 0)) * Math.min(1, dt * (A.stum ? 20 : 8));
    const cele = A.act.cele && (fig.celebrateT || 0) > 0;
    A.cel = (A.cel || 0) + ((cele ? 1 : 0) - (A.cel || 0)) * Math.min(1, dt * 5);
    A.celT = cele ? (A.celT || 0) + dt : 0;
    // G5.108: a sharp turn at speed → a cut (his travel's turn rate, smoothed over ~0.1 s; rate > 0 = to his left)
    if (A.act.cut_l) {
      const va = Math.atan2(vx, vy);
      if (sp > 0.5 && A.va !== undefined && dt > 1e-4) A.tr = (A.tr || 0) * 0.7 + 0.3 * wrapA(va - A.va) / dt;
      if (sp > 0.5) A.va = va;
      A.cool = Math.max(0, (A.cool || 0) - dt);
      if (!A.cut && !A.kick && A.ov < 0.3 && s > CUT_SPEED && Math.abs(A.tr || 0) > CUT_RATE && A.cool <= 0) {
        A.cut = { name: A.tr > 0 ? 'cut_l' : 'cut_r', t: CUT_AT - 0.12 }; A.cool = CUT_COOL + 0.8;
      }
      if (A.cut) { A.cut.t += dt; if (A.cut.t >= A.act[A.cut.name].getClip().duration || (A.kick && A.kick.t >= 0)) A.cut = null; }
      A.cw = (A.cw || 0) + ((A.cut ? 1 : 0) - (A.cw || 0)) * Math.min(1, dt * (A.cut ? 14 : 6));
    }
    // where he goes against where he faces
    // rel > 0: going to his left (the model faces +z, its left is +x)
    const rel = sp > 0.3 ? wrapA(Math.atan2(vx, vy) - fig.yaw) : 0;
    // G5.106: slow, he keeps facing the play and steps that way (CMU side-steps / shuffle / back walk);
    // quick, he turns and runs (tm). Real men backpedal and shuffle up to ~3-4 m/s, then turn. [FH]
    const dirOK = !!A.act.back;
    const tm = dirOK ? smooth((s - 3.0) / 1.5) : 1;
    const back = !dirOK && Math.abs(rel) > 1.9 && s < 5.5;   // no CMU clips: the old reversed forward clips
    const dirSign = back ? -1 : 1;
    const want = (back ? wrapA(rel - Math.PI) : rel) * m * (1 - A.ov) * (dirOK ? Math.max(tm, A.cw || 0) : 1) * (1 - (A.kw || 0)) * (1 - (A.slw || 0));
    A.yawOff += wrapA(want - A.yawOff) * Math.min(1, dt * 8);
    b.model.rotation.y = proto.yaw + A.yawOff;
    // the stride: players.js's gait phase (real cadence by speed), forwards or back
    const dPh = (((fig.phase || 0) - A.lastPh) % 1 + 1) % 1;
    A.lastPh = fig.phase || 0;
    A.ph = ((A.ph + dirSign * dPh) % 1 + 1) % 1;
    const cad = dt > 1e-4 ? dPh / dt : 0;                 // loops a second
    const L = cad > 0.05 ? s / cad : 0;                   // metres a loop at his speed
    const run = smooth((s - 1.9) / 0.7);
    const wj = Math.max(Math.min(1, Math.max(0, (L - STRIDE_WALK) / (STRIDE_JOG - STRIDE_WALK))), JOG_FLOOR * run);
    const ws = smooth((s - 5.5) / 2.0) * (back ? 0 : 1);
    const fw = { walk: 1 - wj, jog: wj * (1 - ws), sprint: wj * ws };   // the forward set
    const w = { idle: 1 - m };
    if (dirOK) {
      // the direction weights off his facing: forward / back / left / right, summing to 1
      const c = Math.cos(rel), sn = Math.sin(rel);
      let wF = Math.max(0, c), wB = Math.max(0, -c), wL = Math.max(0, sn), wR = Math.max(0, -sn);
      const tot = wF + wB + wL + wR || 1; wF /= tot; wB /= tot; wL /= tot; wR /= tot;
      const sh = smooth((Math.abs(s * sn) - 0.9) / 1.2);   // side-step → defensive shuffle by sideways speed
      const d = m * (1 - tm), f = m * tm;
      for (const k of ['walk', 'jog', 'sprint']) w[k] = f * fw[k] + d * wF * fw[k];
      w.back = d * wB;
      w.side_l = d * wL * (1 - sh); w.shuffle_l = d * wL * sh;
      w.side_r = d * wR * (1 - sh); w.shuffle_r = d * wR * sh;
    } else for (const k of ['walk', 'jog', 'sprint']) w[k] = m * fw[k];
    if ((A.cw || 0) > 0.001) {                             // a cut over the locomotion
      for (const k of Object.keys(w)) w[k] *= 1 - A.cw;
      if (A.cut) w[A.cut.name] = A.cw;
    }
    if (A.kw > 0.001) {                                    // the kick over everything else
      for (const k of Object.keys(w)) w[k] *= 1 - A.kw;
      if (A.kick) w[A.kick.name] = A.kw;
    }
    if ((A.cel || 0) > 0.001) {                            // celebrating: less of it the faster he runs
      const c = A.cel * (1 - 0.7 * m);
      for (const k of Object.keys(w)) w[k] *= 1 - c;
      w.cele = c;
    }
    if ((A.stw || 0) > 0.001) {                            // knocked off the ball
      for (const k of Object.keys(w)) w[k] *= 1 - A.stw;
      w.hit = A.stw;
    }
    if ((A.hw || 0) > 0.001 && A.hdLast) {                 // the header's jump, by players.js's timeline
      const t = A.hdLast.t, hw = A.hw;
      for (const k of Object.keys(w)) w[k] *= 1 - hw;
      const ph = t < 0.2 ? 'jump_start' : t < 0.56 ? 'jump_loop' : 'jump_land';
      w[ph] = hw;
      A.hdPh = ph; A.hdClipT = ph === 'jump_start' ? (t / 0.2) * 0.43 : ph === 'jump_loop' ? (t - 0.2) : Math.min(0.5, (t - 0.56) * 1.2);
    }
    if ((A.slw || 0) > 0.001) {                            // the slide over everything
      for (const k of Object.keys(w)) w[k] *= 1 - A.slw;
      if (A.sl) w['slide_' + A.sl.ph] = A.slw;
    }
    if (FORCE && A.act[FORCE]) { for (const k of Object.keys(w)) w[k] = 0; w[FORCE] = 1; }
    A.idleT = (A.idleT + dt) % A.act.idle.getClip().duration;
    const cph = A.cph || (A.cph = {});
    const along = { side_l: s * Math.abs(Math.sin(rel)), side_r: s * Math.abs(Math.sin(rel)), shuffle_l: s * Math.abs(Math.sin(rel)),
                    shuffle_r: s * Math.abs(Math.sin(rel)), back: s * Math.max(0, -Math.cos(rel)) };
    for (const [k, a] of Object.entries(A.act)) {
      a.setEffectiveWeight(w[k] || 0);
      if (k === 'idle') a.time = A.idleT;
      else if (k === 'jump_start' || k === 'jump_loop' || k === 'jump_land') a.time = A.hdPh === k ? Math.min(A.hdClipT, a.getClip().duration - 1e-3) : 0;
      else if (k === 'hit') a.time = A.stum ? Math.min(A.stum.t, a.getClip().duration - 1e-3) : 0;
      else if (k === 'cele') a.time = FORCE === k ? (performance.now() / 1000) % a.getClip().duration : (A.celT || 0) % a.getClip().duration;
      else if (k in SLIDES) a.time = A.sl && 'slide_' + A.sl.ph === k ? Math.min(A.sl.t, a.getClip().duration - 1e-3)
                                                                       : (FORCE === k ? (performance.now() / 1000) % a.getClip().duration : 0);
      else if (CUTS.includes(k)) a.time = A.cut && A.cut.name === k ? Math.min(A.cut.t, a.getClip().duration - 1e-3)
                                                                     : (FORCE === k ? (performance.now() / 1000) % a.getClip().duration : 0);
      else if (KICKS.includes(k)) a.time = A.kick && A.kick.name === k ? Math.min(Math.max(0, A.kick.t), a.getClip().duration - 1e-3)
                                                                       : (FORCE === k ? (performance.now() / 1000) % a.getClip().duration : 0);
      else if (k in CMU_MPS) {
        const rate = Math.min(2, Math.max(0.6, along[k] / CMU_MPS[k]));
        cph[k] = ((cph[k] || 0) + dt * rate / a.getClip().duration) % 1;
        a.time = cph[k] * a.getClip().duration;
      } else a.time = A.ph * a.getClip().duration;
    }
    A.mixer.update(0);
    // the header's lift (and the head through the ball at the top)
    let lift = 0, snap = 0;
    if ((A.hw || 0) > 0.001 && A.hdLast) {
      const t = A.hdLast.t;
      if (t >= 0.12 && t < 0.56) lift = A.hdLast.up * Math.sin(Math.PI * (t - 0.12) / 0.44);
      snap = t < 0.26 ? -0.3 * smooth((t - 0.1) / 0.16) : t < 0.42 ? -0.3 + 0.8 * smooth((t - 0.26) / 0.1) : 0.5 * (1 - smooth((t - 0.42) / 0.2));
      lift *= A.hw; snap *= A.hw;
    }
    b.model.position.y = lift;
    b.model.updateMatrixWorld(true);
    if (Math.abs(snap) > 1e-3 && A.twist.length >= 5) {
      const right = fv1.set(1, 0, 0).applyQuaternion(b.model.getWorldQuaternion(fq1));    // his +x: a + turn tips the head forward
      for (const [i, f] of [[3, 0.45], [4, 0.55]]) {                                      // neck, head
        const bone = A.twist[i];
        tw.setFromAxisAngle(right, snap * f);
        bone.getWorldQuaternion(tw2).premultiply(tw);
        bone.parent.getWorldQuaternion(tq).invert();
        bone.quaternion.copy(tq.multiply(tw2));
        bone.updateMatrixWorld(true);
      }
    }
    // the spine and head give the hips' turn back: chest and eyes on his facing
    const give = -A.yawOff * (1 - A.ov);
    if (Math.abs(give) > 1e-3) {
      for (let i = 0; i < A.twist.length; i++) {
        const bone = A.twist[i];
        tw.setFromAxisAngle(UP, give * TWIST[i]);
        bone.getWorldQuaternion(tw2).premultiply(tw);
        bone.parent.getWorldQuaternion(tq).invert();
        bone.quaternion.copy(tq.multiply(tw2));
        bone.updateMatrixWorld(true);
      }
    }
    // G5.111: the keeper's set position — the rig's arms (forward, elbows bent) over the clip, standing
    A.ka = (A.ka || 0) + (((fig.keeper && s < 1.5) ? 1 : 0) - (A.ka || 0)) * Math.min(1, dt * 6);
    if (A.ka > 0.01 && A.ov < 0.99) {
      const sv = A.savedK || (A.savedK = []);
      b.map.forEach((mm, i) => { (sv[i] || (sv[i] = new THREE.Quaternion())).copy(mm.bone.quaternion); });
      const pp = b.pelvisBone.position.clone();
      retarget(fig);
      b.map.forEach((mm, i) => {
        if (/^(clavicle|upperarm|lowerarm|hand)_/.test(mm.bone.name)) mm.bone.quaternion.copy(sv[i].slerp(mm.bone.quaternion, A.ka));
        else mm.bone.quaternion.copy(sv[i]);
      });
      b.pelvisBone.position.copy(pp);
      b.model.updateMatrixWorld(true);
    }
    if (FOOTLOCK && A.feet.length) footLock(A, dt);
    // cross-fade to the rig for the overlays
    if (A.ov > 0.01) {
      const sv = A.saved;
      b.map.forEach((mm, i) => { (sv[i] || (sv[i] = new THREE.Quaternion())).copy(mm.bone.quaternion); });
      A.pelvisPos.copy(b.pelvisBone.position);
      retarget(fig);
      b.map.forEach((mm, i) => { mm.bone.quaternion.copy(sv[i].slerp(mm.bone.quaternion, A.ov)); });
      b.pelvisBone.position.lerpVectors(A.pelvisPos, b.pelvisBone.position.clone(), A.ov);
      b.model.updateMatrixWorld(true);
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
    if (this.body && this.body.anim) animate(this, a[0] || 0, a[1]);
    else if (this.body) retarget(this);
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
    // G5.105: the clips — rotations only (the two rigs' bones differ in length), plus the pelvis's height
    const pelvisScale = bones.pelvis.position.z / UAL_PELVIS;
    const clipsP = !ANIM ? Promise.resolve(null) : loader.loadAsync(URL_CLIPS).then((g) => {
      const out = {};
      for (const [k, n] of Object.entries(CLIP)) {
        const c = g.animations.find((x) => x.name === n);
        if (!c) { console.warn('bodies: clip missing', n); return null; }
        c.tracks = c.tracks.filter((t) => t.name.endsWith('.quaternion') || t.name === 'pelvis.position');
        // the pelvis sits as high as his leg (the clip's pelvis is the UAL mannequin's; z is up under root)
        for (const t of c.tracks) if (t.name === 'pelvis.position') for (let i = 2; i < t.values.length; i += 3) t.values[i] *= pelvisScale;
        out[k] = c;
      }
      if (USE_EXTRA && Object.values(EXTRA1).every((n) => g.animations.some((x) => x.name === n)))
        for (const [k, n] of Object.entries(EXTRA1)) {
          const c = g.animations.find((x) => x.name === n);
          c.tracks = c.tracks.filter((t) => t.name.endsWith('.quaternion') || t.name === 'pelvis.position');
          for (const t of c.tracks) if (t.name === 'pelvis.position') for (let i = 2; i < t.values.length; i += 3) t.values[i] *= pelvisScale;
          out[k] = c;
        }
      return out;
    }).then((out) => (!out || !USE_CMU) ? out : loader.loadAsync(URL_CMU).then((g) => {
      for (const k of CMU) {
        const c = g.animations.find((x) => x.name === k);
        if (!c) { console.warn('bodies: CMU clip missing', k); return out; }
      }
      for (const k of CMU) out[k] = g.animations.find((x) => x.name === k);
      if (USE_KICKS && KICKS.every((k) => g.animations.some((x) => x.name === k)))
        for (const k of KICKS) out[k] = g.animations.find((x) => x.name === k);
      if (USE_CUTS && CUTS.every((k) => g.animations.some((x) => x.name === k)))
        for (const k of CUTS) out[k] = g.animations.find((x) => x.name === k);
      return out;
    }).catch((e) => { console.warn('bodies: CMU clips failed', e); return out; }))
      .then((out) => (!out || !USE_SLIDES) ? out : loader.loadAsync(URL_SLIDE).then((g) => {
        for (const [k, n] of Object.entries(SLIDES)) {
          const c = g.animations.find((x) => x.name === n);
          if (!c) { console.warn('bodies: slide clip missing', n); return out; }
        }
        for (const [k, n] of Object.entries(SLIDES)) {
          const c = g.animations.find((x) => x.name === n);
          c.tracks = c.tracks.filter((t) => t.name.endsWith('.quaternion') || t.name === 'pelvis.position');
          for (const t of c.tracks) if (t.name === 'pelvis.position') for (let i = 2; i < t.values.length; i += 3) t.values[i] *= pelvisScale;
          out[k] = c;
        }
        const yes = g.animations.find((x) => x.name === 'Yes');
        if (USE_EXTRA && yes) {
          yes.tracks = yes.tracks.filter((t) => t.name.endsWith('.quaternion') || t.name === 'pelvis.position');
          for (const t of yes.tracks) if (t.name === 'pelvis.position') for (let i = 2; i < t.values.length; i += 3) t.values[i] *= pelvisScale;
          out.cele = yes;
        }
        return out;
      }).catch((e) => { console.warn('bodies: slide clips failed', e); return out; }))
      .catch((e) => { console.warn('bodies: clips failed', e); return null; });
    Promise.all(URL_HAIR.map((u) => loader.loadAsync(u).then((h) => {
      let m = null; h.scene.traverse((o) => { if (o.isMesh && !m) m = o; });
      h.scene.updateMatrixWorld(true);
      return [u, { geometry: m.geometry, material: m.material, toHead: headInv.clone().multiply(m.matrixWorld) }];
    }).catch((e) => { console.warn('bodies: hair failed', u, e); return [u, null]; }))).then((pairs) => {
      const hair = {};
      for (const [u, v] of pairs) if (v) hair[u.replace(/^.*\/|\.gltf$/g, '')] = v;
      const any = Object.values(hair)[0];
      proto = { scene: gltf.scene, scale: 1, yaw: 0, hair, clips: null, hairMat: any ? any.material : new THREE.MeshStandardMaterial(),
                boots: extra.boots, back: extra.back,
                legA: p('thigh_l').distanceTo(p('calf_l')), legB: p('calf_l').distanceTo(p('foot_l')) };
      console.log('bodies: loaded, thigh', proto.legA.toFixed(3), 'shin', proto.legB.toFixed(3), 'm, full size · hair', pairs.filter((x) => x[1]).length);
      clipsP.then((clips) => {
        proto.clips = clips;
        if (ANIM && !clips) console.warn('bodies: no clips — the rig drives the bodies');
        for (const f of figures) attach(f);
      });
    });
  }, undefined, (e) => console.warn('bodies: load failed', e));
})();
