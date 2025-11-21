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
    .then(r => {
      if (!r.ok) throw new Error('Login failed');
      return r.json();
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
  
  // Fetch wrapper that adds auth header
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
    });
  }
}
