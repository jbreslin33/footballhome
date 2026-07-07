/*
 * Football Home service worker — DISABLED (2026-07-07).
 *
 * Prior versions of this file registered a passthrough SW so the site
 * would qualify as an installable PWA.  Per project owner directive
 * ("get rid of all cache; only login should be saved on browser"),
 * PWA install is disabled and the SW is being retired.
 *
 * This file remains at /sw.js so that any browser that installed the
 * previous SW (SW_VERSION 2026-07-03a or earlier) will fetch this new
 * copy during its normal update-check, activate it, then self-
 * unregister.  After that the browser goes back to a plain network
 * path with no SW in the middle of any request.
 *
 * If you re-enable PWA install later, revert this file to the
 * passthrough SW AND re-add the `navigator.serviceWorker.register`
 * block in index.html.  Do NOT introduce cache.put() without the
 * owner's explicit sign-off.
 */

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    // Delete every Cache Storage bucket this origin owns.
    try {
      const names = await caches.keys();
      await Promise.all(names.map((n) => caches.delete(n).catch(() => {})));
    } catch (_) { /* no-op */ }

    // Take control of any open tabs so we can immediately unregister
    // without waiting for the next navigation.
    try { await self.clients.claim(); } catch (_) { /* no-op */ }

    // Unregister self.  Existing tabs keep working — the browser
    // falls back to plain network fetches.
    try { await self.registration.unregister(); } catch (_) { /* no-op */ }
  })());
});

// No fetch handler on purpose: without one the browser bypasses the
// SW entirely for network requests even before the unregister
// completes.
