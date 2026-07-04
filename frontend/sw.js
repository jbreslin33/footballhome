/*
 * Football Home service worker.
 *
 * Sole purpose: make the site installable as a PWA (Chrome/Edge/Android
 * require a service worker with a `fetch` handler for the install
 * prompt to show).
 *
 * Per project policy we DO NOT cache anything — every request goes
 * straight to the network. No `caches.open`, no `cache.put`, no
 * `cache.match`.  If the network fails, the browser sees the normal
 * offline error just like it would without a service worker.
 *
 * If you ever want to add offline support, do it in a separate SW
 * version and be explicit about which assets you're willing to cache;
 * do NOT flip this file to a stale-while-revalidate strategy without
 * also revisiting the no-store nginx headers.
 */

const SW_VERSION = '2026-07-03a';

self.addEventListener('install', (event) => {
  // Activate this SW immediately, replacing any older version.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Take control of open tabs on first install without a reload.
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  // Pure network passthrough — no cache read, no cache write.
  // The handler must exist for install eligibility; it can be a no-op
  // that just delegates to the browser's default behavior.
  event.respondWith(fetch(event.request));
});
