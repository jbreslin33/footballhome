#!/usr/bin/env node
// Snoops the sim WS for a match, prints HELLO_ACK caps + first N snapshot
// summaries (num entities, ball present?, ball posX/posY/velX/velY, owner).
// Args: <sim-ip> <match-id> <snapshots-to-print>

const crypto = require('crypto');
const WebSocket = require('ws');

const ip     = process.argv[2] || '10.89.0.205';
const match  = parseInt(process.argv[3] || '274', 10);
const nsnaps = parseInt(process.argv[4] || '3', 10);

const secret = process.env.JWT_SECRET;
if (!secret) { console.error('need JWT_SECRET'); process.exit(2); }

// HS256 JWT the sim's JwtVerifier accepts. Claims (sub / mid / iat / exp)
// match backend/src/controllers/SimLobbyController.cpp::handleJoinMatch and
// sim/src/auth/JwtVerifier.
function b64url(buf) {
  return Buffer.from(buf).toString('base64')
    .replace(/=+$/,'').replace(/\+/g,'-').replace(/\//g,'_');
}
const now = Math.floor(Date.now() / 1000);
const hdr  = { alg: 'HS256', typ: 'JWT' };
const body = { person_id: 1, iat: now, exp: now + 300 };
const p    = b64url(JSON.stringify(hdr)) + '.' + b64url(JSON.stringify(body));
const sig  = crypto.createHmac('sha256', secret).update(p).digest();
const jwt  = p + '.' + b64url(sig);

const url = `ws://${ip}:9100/`;
console.log(`connect ${url} match=${match}`);
const ws = new WebSocket(url, ['fh-sim.v1.bearer.' + jwt]);
ws.binaryType = 'arraybuffer';

let count = 0;
ws.on('open',  () => console.log('open  proto=' + ws.protocol.slice(0, 40) + '...'));
ws.on('error', (e) => { console.error('error', e.message); process.exit(3); });
ws.on('close', (c, r) => { console.log('close', c, String(r)); process.exit(0); });
ws.on('message', (data) => {
  const buf = Buffer.isBuffer(data) ? data : Buffer.from(data);
  // Re-view as DataView for consistent little-endian reads.
  const ab = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
  const dv = new DataView(ab);
  const ver = dv.getUint8(0), mtype = dv.getUint8(1), plen = dv.getUint16(2, true);
  if (mtype === 0x02) {   // HELLO_ACK
    const caps = dv.getUint16(4 + 14, true);
    console.log(`HELLO_ACK plen=${plen} caps=0x${caps.toString(16)}`);
  } else if (mtype === 0x10) {   // SNAPSHOT
    const base = 4;
    const tick = dv.getUint32(base + 0, true);
    const nent = dv.getUint16(base + 8, true);
    const entEnd = 10 + nent * 30;
    const rem = plen - entEnd;
    let ballStr = 'no-trailer';
    if (rem > 0) {
      const tl = dv.getUint16(4 + entEnd, true);
      if (tl === 0) ballStr = 'trailer=empty';
      else if (tl < 30) ballStr = `trailer=malformed len=${tl}`;
      else {
        const bo = 4 + entEnd + 2;
        const px = dv.getFloat32(bo + 0, true);
        const py = dv.getFloat32(bo + 4, true);
        const vx = dv.getFloat32(bo + 12, true);
        const vy = dv.getFloat32(bo + 16, true);
        const own = dv.getUint16(bo + 28, true);
        ballStr = `BALL pos=(${px.toFixed(2)},${py.toFixed(2)}) vel=(${vx.toFixed(2)},${vy.toFixed(2)}) owner=0x${own.toString(16)}`;
      }
    }
    console.log(`SNAP tick=${tick} plen=${plen} entities=${nent} ${ballStr}`);
    if (++count >= nsnaps) { ws.close(); }
  } else if (mtype === 0x03) {
    console.log(`SCENARIO_META plen=${plen} mode=${dv.getUint8(4)} nverts=${dv.getUint16(5,true)}`);
  } else if (mtype === 0x40) {
    console.log(`EVENT plen=${plen}`);
  } else {
    console.log(`msg type=0x${mtype.toString(16)} plen=${plen}`);
  }
});
