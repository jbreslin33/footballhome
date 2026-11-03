// GcalRefresh — ask the server to pull Google Calendar now, without
// waiting for it (owner 2026-11-03: "i don't want to slow the load down …
// fire in background and load from db").
//
// The screen renders from the DB exactly as before; this POST only
// queues a pull on the host (POST /api/calendar/gcal-refresh → the user
// systemd gcal-refresh.path; at most once a minute server-wide).  When it
// was queued, onLanded runs twice — ~12 s and ~30 s later, after the pull
// usually finishes — so the screen can refetch and repaint only if
// something changed.  Never awaited, never throws.
(function () {
  function ping(auth, onLanded) {
    if (!auth || !auth.fetch) return;
    auth.fetch('/api/calendar/gcal-refresh', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' })
      .then(res => (res.ok ? res.json() : null))
      .then(body => {
        if (!body || !body.queued || typeof onLanded !== 'function') return;
        setTimeout(() => { try { onLanded(); } catch (_e) {} }, 12000);
        setTimeout(() => { try { onLanded(); } catch (_e) {} }, 30000);
      })
      .catch(() => {});
  }
  window.GcalRefresh = { ping };
})();
