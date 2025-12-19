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
      // Store the token
      localStorage.setItem('jwt_token', token);
      
      // Fetch user data to populate context
      const response = await this.auth.fetch('/api/auth/me', {
        method: 'GET'
      });
      
      if (!response.ok) {
        throw new Error('Failed to fetch user data');
      }
      
      const data = await response.json();
      this.navigation.context.user = data.user;
      
      // Navigate to role selection
      this.navigation.goTo('role-selection');
      
    } catch (err) {
      console.error('OAuth login error:', err);
      alert('Login failed: ' + err.message);
      this.navigation.goTo('login');
    }
  }
}
