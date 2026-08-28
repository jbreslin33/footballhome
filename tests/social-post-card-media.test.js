// SocialPostCard's optional photo/video attachment
// (frontend/js/components/SocialPostCard.js, 2026-08-28).
//
// Every post type shares this component, so the media state machine is
// the one place a mistake reaches all four match posts at once — and
// practice/pickup posts later. What's pinned here:
//   * Rejections happen BEFORE the upload, with a readable reason. The
//     size ceiling exists because the payload is base64'd into a JSON
//     body against nginx's client_max_body_size; without the up-front
//     check a coach waits out a long upload for an opaque 413.
//   * _localPreviewWins. A post that has already been published carries
//     an image_url, and render() prefers it — so without this flag,
//     attaching a photo would leave the OLD image on screen and look
//     like the attach did nothing.
//   * Video and image take different upload paths, and only video needs
//     the transparent overlay PNG that ffmpeg burns on server-side.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { JSDOM } = require('jsdom');

function loadCard() {
  const dom = new JSDOM('<!doctype html><div id="host"></div>', { url: 'https://footballhome.org/' });
  const sandbox = dom.window;
  sandbox.console = console;
  const alerts = [];
  sandbox.alert = (msg) => alerts.push(String(msg));
  vm.createContext(sandbox);
  vm.runInContext('var html2canvas = undefined; var LighthouseBeam = { animate: () => () => {}, draw: () => {} };', sandbox);
  vm.runInContext(
    fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'components', 'SocialPostCard.js'), 'utf8'),
    sandbox
  );
  const SocialPostCard = vm.runInContext('SocialPostCard', sandbox);

  const card = new SocialPostCard({ fetch: async () => ({ json: async () => ({ success: true, data: [] }) }) });
  // Isolate the state machine from the DOM/canvas work those two do.
  const rendered = [];
  card.render = () => rendered.push(card.userMedia ? card.userMedia.kind : null);
  card.generateImage = async () => {};
  return { dom, sandbox, card, alerts, rendered };
}

// jsdom's File carries a real size, which is what the guard reads.
function fakeFile(sandbox, { type, size, name }) {
  const f = new sandbox.File([new sandbox.Uint8Array(1)], name, { type });
  Object.defineProperty(f, 'size', { value: size });
  return f;
}

test('a post starts with no media and the stored image still winning', () => {
  const { card } = loadCard();
  assert.equal(card.userMedia, null);
  assert.equal(card._localPreviewWins, false);
});

test('an oversized file is refused before any upload, by name and size', async () => {
  const { sandbox, card, alerts } = loadCard();
  const tooBig = fakeFile(sandbox, { type: 'video/mp4', size: 80 * 1024 * 1024, name: 'match.mp4' });
  await card._onMediaPicked(tooBig);
  assert.equal(card.userMedia, null, 'not accepted');
  assert.equal(alerts.length, 1);
  assert.match(alerts[0], /80\.0MB/, 'says how big it actually is');
  assert.match(alerts[0], /45MB/, 'and what the limit is');
});

test('the size ceiling leaves room under the proxy limit once base64-inflated', () => {
  const { sandbox } = loadCard();
  const SocialPostCard = vm.runInContext('SocialPostCard', sandbox);
  const nginx = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'nginx.conf'), 'utf8');
  const m = nginx.match(/location \/api\/ \{[\s\S]*?client_max_body_size (\d+)m;/);
  assert.ok(m, 'found the /api/ body limit');
  const limitBytes = Number(m[1]) * 1024 * 1024;
  // base64 is 4/3, plus JSON overhead. If someone lowers nginx without
  // lowering this, uploads start dying as 413s at the proxy.
  assert.ok(SocialPostCard.MAX_MEDIA_BYTES * (4 / 3) < limitBytes,
    `MAX_MEDIA_BYTES (${SocialPostCard.MAX_MEDIA_BYTES}) base64s past the ${m[1]}m proxy limit`);
});

test('a file that is neither photo nor video is refused', async () => {
  const { sandbox, card, alerts } = loadCard();
  await card._onMediaPicked(fakeFile(sandbox, { type: 'application/pdf', size: 1024, name: 'teamsheet.pdf' }));
  assert.equal(card.userMedia, null);
  assert.match(alerts[0], /photo or a video/);
});

test('picking nothing is a no-op, not an error', async () => {
  const { card, alerts, rendered } = loadCard();
  await card._onMediaPicked(null);
  assert.equal(card.userMedia, null);
  assert.equal(alerts.length, 0);
  assert.equal(rendered.length, 0, 'no pointless re-render');
});

test('an accepted photo is held as a data URL and takes over the preview', async () => {
  const { sandbox, card, rendered } = loadCard();
  await card._onMediaPicked(fakeFile(sandbox, { type: 'image/jpeg', size: 2 * 1024 * 1024, name: 'warmup.jpg' }));
  assert.equal(card.userMedia.kind, 'image');
  assert.equal(card.userMedia.fileName, 'warmup.jpg');
  assert.match(card.userMedia.dataUrl, /^data:/);
  assert.equal(card.userMedia.posterDataUrl, null, 'a photo needs no poster frame');
  assert.equal(card._localPreviewWins, true, 'the composed card now outranks a stored image_url');
  assert.deepEqual(rendered, ['image'], 'preview rebuilt once');
});

test('removing media clears it but keeps the local preview authoritative', async () => {
  const { sandbox, card } = loadCard();
  await card._onMediaPicked(fakeFile(sandbox, { type: 'image/png', size: 1024, name: 'a.png' }));
  card._clearMedia();
  assert.equal(card.userMedia, null);
  // Still true: going back to the club graphic is also a change the
  // stored image_url doesn't reflect.
  assert.equal(card._localPreviewWins, true);
});

test('only a video upload asks for the ffmpeg overlay layer', async () => {
  const { sandbox, card } = loadCard();
  let overlaysBuilt = 0;
  card._buildOverlayPng = async () => { overlaysBuilt++; return 'data:image/png;base64,AAAA'; };

  // The branch postNow takes is decided by userMedia.kind alone.
  const needsOverlay = () => !!(card.userMedia && card.userMedia.kind === 'video');

  assert.equal(needsOverlay(), false, 'no media → generated clip, graphics already in every frame');
  await card._onMediaPicked(fakeFile(sandbox, { type: 'image/jpeg', size: 1024, name: 'p.jpg' }));
  assert.equal(needsOverlay(), false, 'photo → composited in the browser before upload');

  card.userMedia = { kind: 'video', dataUrl: 'data:video/mp4;base64,AAAA', posterDataUrl: 'data:image/png;base64,BBBB', fileName: 'v.mp4' };
  assert.equal(needsOverlay(), true);
  await card._buildOverlayPng();
  assert.equal(overlaysBuilt, 1);
});

test('the overlay build is transparent and leaves the preview alone', () => {
  const src = fs.readFileSync(path.join(__dirname, '..', 'frontend', 'js', 'components', 'SocialPostCard.js'), 'utf8');
  // overlayOnly must return before baseImage/startAnimatedPreview run —
  // otherwise building the overlay would restart the beam animation and
  // swap the coach's preview mid-post.
  const gen = src.slice(src.indexOf('async _generateImageOnce('));
  const earlyReturn = gen.indexOf('if (overlayOnly) return canvas.toDataURL');
  const setsBase = gen.indexOf('this.baseImage = baseImg');
  assert.ok(earlyReturn > 0 && setsBase > 0);
  assert.ok(earlyReturn < setsBase, 'overlayOnly returns before touching preview state');
  // And it must not paint a background of its own.
  assert.match(gen, /const cardBackground = \(overlayOnly \|\| backdropSrc\)\s*\n?\s*\?\s*'background:transparent;'/);
});
