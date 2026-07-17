// Auth class - handles authentication and API requests
class Auth {
  constructor(apiBase = '') {
    this.apiBase = apiBase; // Empty string = same domain (nginx proxies /api)
    this.token = localStorage.getItem('token');
    this.user = null;
    
    // Load user from localStorage if token exists
    const userJson = localStorage.getItem('user');
    if (userJson) {
      try {
        this.user = JSON.parse(userJson);
      } catch (e) {
        console.error('Failed to parse stored user:', e);
      }
    }

    // ── View-as / impersonation (2026-07-11) ─────────────────────
    // When a club admin picks a member from the "View as..." dropdown
    // on the role-selection screen, we store the target person_id here
    // (and their display name for the persistent banner).  The fetch
    // wrapper below then appends `?asPersonId=<id>` to any /api/my/*
    // request so the backend renders the app as that person.  Writes
    // (POST/PUT/DELETE) are refused by the backend when this param is
    // set — see MyController::applyImpersonation.
    const vaId = localStorage.getItem('viewAsPersonId');
    this.viewAsPersonId   = vaId ? Number(vaId) : null;
    this.viewAsPersonName = localStorage.getItem('viewAsPersonName') || '';
  }

  // Enter view-as mode.  Persists to localStorage so a refresh keeps
  // you in the impersonated view (the banner is your reminder).
  setViewAs(personId, personName) {
    const id = Number(personId) || 0;
    if (!id) { this.clearViewAs(); return; }
    this.viewAsPersonId   = id;
    this.viewAsPersonName = String(personName || '');
    localStorage.setItem('viewAsPersonId',   String(id));
    localStorage.setItem('viewAsPersonName', this.viewAsPersonName);
    this._notifyViewAsChanged();
  }

  clearViewAs() {
    this.viewAsPersonId   = null;
    this.viewAsPersonName = '';
    localStorage.removeItem('viewAsPersonId');
    localStorage.removeItem('viewAsPersonName');
    this._notifyViewAsChanged();
  }

  getViewAs() {
    return this.viewAsPersonId
      ? { personId: this.viewAsPersonId, personName: this.viewAsPersonName }
      : null;
  }

  _notifyViewAsChanged() {
    // Fire a DOM event so the top-of-page banner (in index.html) and
    // any currently-mounted screen can refresh in-place.
    try {
      window.dispatchEvent(new CustomEvent('viewAsChanged', {
        detail: this.getViewAs(),
      }));
    } catch (_e) { /* IE11 not supported */ }
  }
  
  isLoggedIn() {
    return !!this.token;
  }
  
  getUser() {
    return this.user;
  }
  
  getToken() {
    return this.token;
  }
  
  login(username, password) {
    return this.fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: username, password })
    })
    .then(async (r) => {
      let responseBody = null;
      try {
        responseBody = await r.json();
      } catch (_) {
        // Non-JSON responses are unexpected, keep a null body fallback.
      }

      if (!r.ok) {
        const message = responseBody?.message || `Login failed (HTTP ${r.status})`;
        throw new Error(message);
      }

      return responseBody;
    })
    .then(response => {
      // Backend returns {success, message, data: {user, token}}
      if (!response.success || !response.data) {
        throw new Error(response.message || 'Login failed');
      }
      
      this.token = response.data.token;
      this.user = response.data.user;
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
      return response.data;
    });
  }
  
  logout() {
    this.token = null;
    this.user = null;
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    // Also clear any active view-as impersonation so the next login
    // starts clean.  Otherwise the banner would linger showing a
    // person the new caller might not even be allowed to impersonate.
    this.clearViewAs();
  }
  
  // Fetch wrapper that adds auth header + globally recovers from 401.
  //
  // Any 401 response to a non-login call is treated as "your session is
  // dead" (JWT expired, JWT_SECRET rotated, backend restarted with an
  // ephemeral secret, etc.).  We clear localStorage and route to login
  // via the hash router so the user re-authenticates cleanly instead
  // of seeing a raw "Unauthorized" that persists across page reloads.
  fetch(path, options = {}) {
    // Global no-cache policy (2026-07-07):  every API request must
    // hit the network fresh — no browser HTTP cache, no
    // conditional-GET revalidation, no bfcache reuse.  Callers can
    // still override by passing an explicit `cache` in options if a
    // specific endpoint ever needs otherwise (none do today).
    const headers = {
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Pragma':        'no-cache',
      ...options.headers,
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    // ── View-as URL injection ───────────────────────────────────
    // When impersonating, append `?asPersonId=<id>` to the READ paths
    // that honour it server-side.  Writes NEVER get the override — an
    // admin viewing as a player must not accidentally RSVP as them
    // (see MyController::applyImpersonation +
    // CalendarController::applyImpersonation).
    //
    // Honouring endpoints (all read-only):
    //   /api/my/*                           — MyController
    //   /api/calendar/upcoming              — CalendarController
    //   /api/calendar/my-standing (GET only)— CalendarController
    let effectivePath = path;
    const method = (options.method || 'GET').toUpperCase();
    const wantsImpersonation = this.viewAsPersonId && (
      path.startsWith('/api/my/') ||
      (method === 'GET' && (
        path.startsWith('/api/calendar/upcoming') ||
        path.startsWith('/api/calendar/my-standing')
      ))
    );
    if (wantsImpersonation) {
      const sep = path.includes('?') ? '&' : '?';
      effectivePath = path + sep + 'asPersonId=' + encodeURIComponent(this.viewAsPersonId);
    }

    return fetch(this.apiBase + effectivePath, {
      cache: 'no-store',
      ...options,
      headers,
    }).then((res) => {
      if (res.status === 401 && !path.startsWith('/api/auth/login')) {
        this.logout();
        if (typeof window !== 'undefined' && !location.hash.startsWith('#login')) {
          location.hash = 'login';
        }
      }
      return res;
    });
  }
}
