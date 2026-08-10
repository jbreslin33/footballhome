/*
 * Football Home service worker — push-only (2026-08-09).
 *
 * Re-enabled after the 2026-07-07 disable ("get rid of all cache; only
 * login should be saved on browser") to support Web Push notifications
 * (RSVP reminders, men's chat). The no-cache directive still applies:
 * this file does NOT call cache.put() anywhere, has no fetch handler,
 * and does nothing but relay push events into OS notifications. Every
 * network request still goes straight to the network, exactly as if
 * there were no service worker at all — the SW only exists so the
 * browser has somewhere to deliver a push event in the background.
 *
 * Do NOT add a fetch handler or cache.put() here without the owner's
 * explicit sign-off (same rule as before).
 */

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Take control of any open tabs immediately so a page that was open
  // before this SW version installed still gets push delivery without
  // needing a reload.
  event.waitUntil(self.clients.claim());
});

// Push payload is JSON: { title, body, url? } — written by
// WebPushService::sendToPerson on the backend (see
// backend/src/services/WebPushService.cpp).
self.addEventListener('push', (event) => {
  let payload = { title: 'Football Home', body: '' };
  try {
    if (event.data) payload = Object.assign(payload, event.data.json());
  } catch (_) {
    // Non-JSON payload (shouldn't happen — we always send JSON) — fall
    // back to plain text so a malformed push still shows *something*
    // instead of silently dropping.
    try { payload.body = event.data ? event.data.text() : ''; } catch (_) { /* no-op */ }
  }

  const title = payload.title || 'Football Home';
  const options = {
    body: payload.body || '',
    icon: '/images/lighthouse-1893-crest.png',
    badge: '/images/lighthouse-1893-crest.png',
    data: { url: payload.url || '/' },
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

// Tapping a notification focuses an existing footballhome.org tab if
// one is open (navigating it to the notification's url), otherwise
// opens a new one.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || '/';

  event.waitUntil((async () => {
    const clientsList = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of clientsList) {
      if ('focus' in client) {
        await client.focus();
        if ('navigate' in client) {
          try { await client.navigate(targetUrl); } catch (_) { /* no-op */ }
        }
        return;
      }
    }
    if (self.clients.openWindow) {
      await self.clients.openWindow(targetUrl);
    }
  })());
});
