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

    // 🎭 View-as = really that person (owner 11/18 "view as needs to be
    // that person except … the way out"): every API call carries
    // X-View-As and the server runs it as their own login, reads only
    // (backend core/ViewAs).  Client-side, `user` IS theirs too, so every
    // role check on every screen follows.  The admin's own user waits in
    // `realUser` / localStorage 'user'; the banner's Exit is the way out.
    this.realUser = this.user;
    if (this.viewAsPersonId) {
      try { this.user = JSON.parse(localStorage.getItem('viewAsUser') || 'null'); } catch (_) { this.user = null; }
      if (!this.user) { this._wipeViewAs(); this.user = this.realUser; }
    }
  }

  // Every client trace of view-as (owner 11/18 "kill off any remnant").
  _wipeViewAs() {
    this.viewAsPersonId = null;
    this.viewAsPersonName = '';
    for (const k of ['viewAsPersonId', 'viewAsPersonName', 'viewAsUser']) {
      try { localStorage.removeItem(k); } catch (_) { /* fine */ }
    }
  }

  // Enter view-as: only a club/super admin (the server checks again on
  // every call).  Asks the server who that person is, as them; resolves
  // to null on success (page reloads as them) or the reason it can't.
  async enterViewAs(personId, personName) {
    const id = Number(personId) || 0;
    const role = this.realUser && this.realUser.role;
    if (!id || !['club', 'super'].includes(role) || this.viewAsPersonId) return 'Not allowed.';
    const res = await fetch(this.apiBase + '/api/auth/me', {
      cache: 'no-store', headers: { 'Authorization': `Bearer ${this.token}`, 'X-View-As': String(id) },
    }).catch(() => null);
    const body = res ? await res.json().catch(() => ({})) : {};
    const user = body && body.data && body.data.user;
    if (!res || !res.ok || !user) return (body && body.message) || 'Could not view as this person.';
    localStorage.setItem('viewAsPersonId', String(id));
    localStorage.setItem('viewAsPersonName', String(personName || user.name || ''));
    localStorage.setItem('viewAsUser', JSON.stringify(user));
    location.hash = 'calendar';
    location.reload();
    return null;
  }

  // The way out: wipe every trace, back to the admin's own login, fresh page.
  exitViewAs() {
    this._wipeViewAs();
    this.user = this.realUser;
    location.hash = 'calendar';
    location.reload();
  }

  // Enter view-as mode.  Persists to localStorage so a refresh keeps
  // you in the impersonated view (the banner is your reminder).
  setViewAs(personId, personName) { return this.enterViewAs(personId, personName); }

  clearViewAs() {
    this._wipeViewAs();
    this.user = this.realUser;
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
    this.realUser = null;
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

    // ── View-as: every call runs as the viewed person ───────────
    // The server (core/ViewAs) swaps in their own login for GETs and
    // refuses every write while this header rides along.
    if (this.viewAsPersonId) headers['X-View-As'] = String(this.viewAsPersonId);
    const effectivePath = path;

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
