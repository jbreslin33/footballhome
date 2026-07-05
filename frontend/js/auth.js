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
  }
  
  // Fetch wrapper that adds auth header + globally recovers from 401.
  //
  // Any 401 response to a non-login call is treated as "your session is
  // dead" (JWT expired, JWT_SECRET rotated, backend restarted with an
  // ephemeral secret, etc.).  We clear localStorage and route to login
  // via the hash router so the user re-authenticates cleanly instead
  // of seeing a raw "Unauthorized" that persists across page reloads.
  fetch(path, options = {}) {
    const headers = {
      ...options.headers
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return fetch(this.apiBase + path, {
      ...options,
      headers
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
