// LighthouseBeam — the club's lighthouse-with-rotating-beam artwork,
// shared between the Instagram post generator (SocialPostCard.js) and
// any live view that wants the same graphic (2026-08-22, owner: "use
// the one from the socials section of site. its better. its gotta be
// good!"). One drawing routine, reused everywhere, instead of a second,
// visually weaker CSS approximation living in game-lineup.js.
//
// draw(ctx, lhX, lhY, scale) — draws the lighthouse (tower with gold
// "1893" bands, lantern room, dome, rocky cliff, ocean) onto a 2D canvas
// context. lhX/lhY is the lantern's center position; scale defaults to 2
// (the "2x canvas for sharpness" convention SocialPostCard.js uses) but
// can be set lower for a small decorative element.
//
// animate(canvas, opts) — starts a requestAnimationFrame loop that
// clears the canvas each frame, draws a rotating light-beam cone
// clipped to the canvas bounds, then draws the lighthouse on top.
// Returns { stop() }. opts: { lhX, lhY, rotPeriodSec = BEAM_ROTATION_SECONDS,
// beamSpread = 0.18, scale = 2, beamLen, drawLighthouse = true,
// onFrame(ctx, w, h) } — onFrame, if given, runs BEFORE the
// beam/lighthouse each frame (e.g. to draw a base card image first, as
// SocialPostCard.js's own preview does).
//
// beamLen sets how far the cone reaches (and, with it, how far the
// gradient takes to fade out); it defaults to max(w,h) * 1.2, which is
// right for a canvas roughly as tall as it is wide but washes the beam
// out on a very tall one — pass an explicit length there.
//
// drawLighthouse:false emits ONLY the beam, for callers that want the
// beam painted on a separate layer stacked ABOVE their content while
// the lighthouse artwork itself stays behind it (game-lineup.js does
// this — the tower would otherwise cover the away crest and name).
(function (global) {
  function draw(ctx, lhX, lhY, scale) {
    const s = scale || 2;
    ctx.save();

    // === DIMENSIONS ===
    const topW = 26 * s, botW = 38 * s, towerH = 150 * s;
    const topY = lhY + 8 * s;
    const botY = lhY + towerH;

    const towerPath = () => {
      ctx.beginPath();
      ctx.moveTo(lhX - topW / 2, topY);
      ctx.lineTo(lhX + topW / 2, topY);
      ctx.lineTo(lhX + botW / 2, botY);
      ctx.lineTo(lhX - botW / 2, botY);
      ctx.closePath();
    };

    // === TOWER BODY (white) ===
    towerPath();
    ctx.fillStyle = '#ffffff';
    ctx.fill();

    // 4 royal blue bands with gold "1893" digits
    const digits = ['1', '8', '9', '3'];
    const bandH = 18 * s;
    const bandZone = towerH * 0.82;
    const bandGap = (bandZone - bandH * 4) / 5;
    for (let i = 0; i < 4; i++) {
      const bandY = topY + bandGap * (i + 1) + bandH * i;
      const fracTop = (bandY - topY) / towerH;
      const fracBot = (bandY + bandH - topY) / towerH;
      const wTop = topW + (botW - topW) * fracTop;
      const wBot = topW + (botW - topW) * fracBot;

      ctx.save();
      towerPath();
      ctx.clip();
      ctx.beginPath();
      ctx.moveTo(lhX - wTop / 2, bandY);
      ctx.lineTo(lhX + wTop / 2, bandY);
      ctx.lineTo(lhX + wBot / 2, bandY + bandH);
      ctx.lineTo(lhX - wBot / 2, bandY + bandH);
      ctx.closePath();
      ctx.fillStyle = '#0033a0';
      ctx.fill();

      const fontSize = Math.round(14 * s);
      ctx.font = `900 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = '#f5d442';
      ctx.fillText(digits[i], lhX, bandY + bandH / 2);
      ctx.restore();
    }

    // Thin outline on tower
    towerPath();
    ctx.strokeStyle = 'rgba(255,255,255,0.6)';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === GALLERY PLATFORM ===
    const platW = topW + 12 * s;
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1 * s;
    ctx.strokeRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);

    // Gallery railing posts
    const railH = 10 * s;
    const railY = topY - 3 * s - railH;
    const numPosts = 7;
    for (let i = 0; i < numPosts; i++) {
      const px = lhX - platW / 2 + 3 * s + i * ((platW - 6 * s) / (numPosts - 1));
      ctx.beginPath();
      ctx.moveTo(px, topY - 3 * s);
      ctx.lineTo(px, railY);
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 1 * s;
      ctx.stroke();
    }
    ctx.beginPath();
    ctx.moveTo(lhX - platW / 2 + 2 * s, railY);
    ctx.lineTo(lhX + platW / 2 - 2 * s, railY);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === LANTERN ROOM ===
    const lanternW = 20 * s, lanternH = 16 * s;
    const lanternTop = railY - lanternH;

    ctx.fillStyle = '#f5d442';
    ctx.fillRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1.5 * s;
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop);
    ctx.lineTo(lhX, lanternTop + lanternH);
    ctx.moveTo(lhX - lanternW / 2, lanternTop + lanternH / 2);
    ctx.lineTo(lhX + lanternW / 2, lanternTop + lanternH / 2);
    ctx.stroke();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2 * s;
    ctx.strokeRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);

    // === DOME ===
    const domeW = lanternW + 4 * s;
    ctx.beginPath();
    ctx.moveTo(lhX - domeW / 2, lanternTop);
    ctx.quadraticCurveTo(lhX, lanternTop - 22 * s, lhX + domeW / 2, lanternTop);
    ctx.closePath();
    ctx.fillStyle = '#0033a0';
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // Finial (gold ball + spike)
    ctx.beginPath();
    ctx.arc(lhX, lanternTop - 18 * s, 3 * s, 0, Math.PI * 2);
    ctx.fillStyle = '#f5d442';
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop - 21 * s);
    ctx.lineTo(lhX, lanternTop - 28 * s);
    ctx.strokeStyle = '#f5d442';
    ctx.lineWidth = 2 * s;
    ctx.stroke();

    // === LANTERN GLOW ===
    const glowCY = lanternTop + lanternH / 2;
    const glowGrad = ctx.createRadialGradient(lhX, glowCY, 0, lhX, glowCY, 24 * s);
    glowGrad.addColorStop(0, 'rgba(255, 230, 0, 0.7)');
    glowGrad.addColorStop(0.4, 'rgba(255, 223, 0, 0.2)');
    glowGrad.addColorStop(1, 'rgba(255, 223, 0, 0)');
    ctx.beginPath();
    ctx.arc(lhX, glowCY, 24 * s, 0, Math.PI * 2);
    ctx.fillStyle = glowGrad;
    ctx.fill();

    // === DOOR ===
    ctx.beginPath();
    ctx.arc(lhX, botY - 16 * s, 7 * s, Math.PI, 0);
    ctx.lineTo(lhX + 7 * s, botY);
    ctx.lineTo(lhX - 7 * s, botY);
    ctx.closePath();
    ctx.fillStyle = '#0033a0';
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === ROCKY CLIFF ===
    const rockY = botY + 2 * s;
    const rockW = 50 * s;
    const rockH = 28 * s;

    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + rockH);
    ctx.lineTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.lineTo(lhX + rockW, rockY + rockH);
    ctx.closePath();
    ctx.fillStyle = '#2c2c2c';
    ctx.fill();

    ctx.save();
    ctx.globalAlpha = 0.3;
    const rockShapes = [
      { x: lhX - 20 * s, y: rockY + 6 * s, rx: 10 * s, ry: 5 * s },
      { x: lhX + 15 * s, y: rockY + 8 * s, rx: 8 * s, ry: 4 * s },
      { x: lhX - 5 * s, y: rockY + 14 * s, rx: 12 * s, ry: 5 * s },
      { x: lhX + 30 * s, y: rockY + 12 * s, rx: 9 * s, ry: 5 * s },
      { x: lhX - 35 * s, y: rockY + 12 * s, rx: 11 * s, ry: 4 * s },
    ];
    for (const r of rockShapes) {
      ctx.beginPath();
      ctx.ellipse(r.x, r.y, r.rx, r.ry, 0, 0, Math.PI * 2);
      ctx.fillStyle = '#444444';
      ctx.fill();
    }
    ctx.restore();

    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.strokeStyle = '#666666';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === OCEAN WAVES ===
    const oceanY = rockY + rockH - 4 * s;
    const oceanW = 60 * s;

    const oceanGrad = ctx.createLinearGradient(0, oceanY, 0, oceanY + 20 * s);
    oceanGrad.addColorStop(0, '#1a6baa');
    oceanGrad.addColorStop(1, '#0d4a7a');
    ctx.fillStyle = oceanGrad;
    ctx.fillRect(lhX - oceanW, oceanY, oceanW * 2, 22 * s);

    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.lineWidth = 1.5 * s;
    for (let row = 0; row < 3; row++) {
      const wy = oceanY + 4 * s + row * 6 * s;
      ctx.beginPath();
      for (let x = lhX - oceanW; x < lhX + oceanW; x += 12 * s) {
        const amp = 2 * s;
        ctx.moveTo(x, wy);
        ctx.quadraticCurveTo(x + 3 * s, wy - amp, x + 6 * s, wy);
        ctx.quadraticCurveTo(x + 9 * s, wy + amp, x + 12 * s, wy);
      }
      ctx.stroke();
    }

    ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.lineWidth = 2 * s;
    ctx.beginPath();
    for (let x = lhX - rockW; x < lhX + rockW; x += 8 * s) {
      ctx.moveTo(x, oceanY + 1 * s);
      ctx.quadraticCurveTo(x + 2 * s, oceanY - 2 * s, x + 4 * s, oceanY + 1 * s);
    }
    ctx.stroke();

    ctx.restore();
  }

  function animate(canvas, opts) {
    opts = opts || {};
    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;
    const scale = opts.scale || 2;
    const lhX = opts.lhX != null ? opts.lhX : w - 100;
    const lhY = opts.lhY != null ? opts.lhY : h - 340;
    const beamLen = opts.beamLen != null ? opts.beamLen : Math.max(w, h) * 1.2;
    const beamSpread = opts.beamSpread != null ? opts.beamSpread : 0.18;
    const rotPeriod = opts.rotPeriodSec || BEAM_ROTATION_SECONDS;
    const rotSpeed = (2 * Math.PI) / rotPeriod;
    // Callers that re-mount the canvas across re-renders (e.g. a full
    // innerHTML rebuild) can pass their own persisted startTime so the
    // beam angle never visibly jumps.
    const startTime = opts.startTime || performance.now();
    let frameId = null;

    const drawFrame = (now) => {
      const elapsed = (now - startTime) / 1000;
      const angle = (elapsed * rotSpeed) % (Math.PI * 2);
      ctx.clearRect(0, 0, w, h);

      if (opts.onFrame) opts.onFrame(ctx, w, h);

      ctx.save();
      ctx.beginPath();
      ctx.rect(0, 0, w, h);
      ctx.clip();

      const beamAngle = angle + Math.PI * 0.25;
      const a1 = beamAngle - beamSpread;
      const a2 = beamAngle + beamSpread;
      const tipX1 = lhX + Math.cos(a1) * beamLen;
      const tipY1 = lhY + Math.sin(a1) * beamLen;
      const tipX2 = lhX + Math.cos(a2) * beamLen;
      const tipY2 = lhY + Math.sin(a2) * beamLen;

      const grad = ctx.createRadialGradient(lhX, lhY, 10, lhX, lhY, beamLen * 0.7);
      grad.addColorStop(0, 'rgba(255, 230, 0, 0.55)');
      grad.addColorStop(0.3, 'rgba(255, 223, 0, 0.25)');
      grad.addColorStop(1, 'rgba(255, 223, 0, 0)');

      ctx.beginPath();
      ctx.moveTo(lhX, lhY);
      ctx.lineTo(tipX1, tipY1);
      ctx.lineTo(tipX2, tipY2);
      ctx.closePath();
      ctx.fillStyle = grad;
      ctx.fill();

      const ca1 = beamAngle - beamSpread * 0.4;
      const ca2 = beamAngle + beamSpread * 0.4;
      const coreLen = beamLen * 0.6;
      ctx.beginPath();
      ctx.moveTo(lhX, lhY);
      ctx.lineTo(lhX + Math.cos(ca1) * coreLen, lhY + Math.sin(ca1) * coreLen);
      ctx.lineTo(lhX + Math.cos(ca2) * coreLen, lhY + Math.sin(ca2) * coreLen);
      ctx.closePath();
      const coreGrad = ctx.createRadialGradient(lhX, lhY, 5, lhX, lhY, coreLen * 0.5);
      coreGrad.addColorStop(0, 'rgba(255, 240, 50, 0.5)');
      coreGrad.addColorStop(1, 'rgba(255, 240, 50, 0)');
      ctx.fillStyle = coreGrad;
      ctx.fill();

      ctx.restore();

      if (opts.drawLighthouse !== false) draw(ctx, lhX, lhY, scale);

      frameId = requestAnimationFrame(drawFrame);
    };
    frameId = requestAnimationFrame(drawFrame);

    return { stop: () => { if (frameId) cancelAnimationFrame(frameId); } };
  }

  // How long the posted Instagram clip runs (2026-08-24, owner: "can we
  // set insta post to 30 seconds").
  const POST_CLIP_SECONDS = 30;

  // How long one full 360 degree sweep takes, everywhere — the posted
  // clip, the preview it's recorded from, and the live decorative beams
  // (2026-08-24, owner: "it seems slow lets try exactly 15 seconds to
  // complete 360 so it does it 2x in 30 seconds").
  //
  // These two are separate numbers but NOT independent: POST_CLIP_SECONDS
  // must stay a whole multiple of this one, or the recording stops
  // part-way through a sweep and the clip jumps when Instagram loops it.
  // 30 / 15 = 2 clean rotations. Change one, check the other.
  const BEAM_ROTATION_SECONDS = 15;

  global.LighthouseBeam = { draw, animate, POST_CLIP_SECONDS, BEAM_ROTATION_SECONDS };
})(window);
