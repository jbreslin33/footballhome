// OAuthSuccessScreen - handles OAuth callback redirect
class OAuthSuccessScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-oauth-success';
    div.innerHTML = `
      <div class="screen-header">
        <h1>⚽ Football Home</h1>
        <p class="subtitle">Completing sign in...</p>
      </div>
      
      <div class="card" style="max-width: 400px; margin: var(--space-4) auto; text-align: center;">
        <div class="loading-spinner" style="margin: var(--space-4) auto;"></div>
        <p>Signing you in with Google...</p>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Extract token from URL
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get('token');
    
    if (!token) {
      console.error('No token received from OAuth callback');
      alert('Login failed: No authentication token received');
      this.navigation.goTo('login');
      return;
    }
    
    // Store the token and fetch user data
    this.completeOAuthLogin(token);
  }
  
  async completeOAuthLogin(token) {
    try {
      // Clear any stale magic-link cookie on this device before the JWT
      // request goes out — if a different user's fh_sess cookie is
      // hanging around we do NOT want it silently overriding our fresh
      // OAuth identity.  Both the client-side cookie wipe and the
      // Set-Cookie header the backend now returns are needed: some
      // mobile browsers ignore server Set-Cookie on cross-origin 302s.
      try {
        document.cookie = 'fh_sess=; Path=/; Max-Age=0; SameSite=Lax';
      } catch (_) { /* cookies disabled — the Bearer path still works */ }

      // Store the token (using 'token' key to match Auth class)
      localStorage.setItem('token', token);

      // Update the auth instance with the new token
      this.auth.token = token;

      // Fetch user data to populate context
      const response = await this.auth.fetch('/api/auth/me', {
        method: 'GET'
      });

      if (!response.ok) {
        throw new Error('Failed to fetch user data');
      }

      const data = await response.json();

      // Backend returns { success, data: { user } } on the Bearer path.
      // Older cookie-path shape { person, sessionId } is a bug we've
      // fixed on the backend, but be defensive here — if the shape is
      // wrong, log it and bail cleanly instead of crashing on undefined.
      const user = (data && data.data && data.data.user) || null;
      if (!user) {
        console.error('OAuth /me returned unexpected shape:', data);
        throw new Error('Unexpected response from server. Please try again.');
      }

      // Store user data
      this.auth.user = user;
      localStorage.setItem('user', JSON.stringify(user));

      this.navigation.context.user = user;

      // Navigate to role selection
      this.navigation.goTo('role-selection');

    } catch (err) {
      console.error('OAuth login error:', err);
      alert('Login failed: ' + err.message);
      this.navigation.goTo('login');
    }
  }
}
