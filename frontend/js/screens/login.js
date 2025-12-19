// LoginScreen - username/password authentication
class LoginScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-login';
    div.innerHTML = `
      <div class="screen-header">
        <h1>⚽ Football Home</h1>
        <p class="subtitle">Team practice management made easy</p>
      </div>
      
      <div class="card" style="max-width: 400px; margin: var(--space-4) auto;">
        <h2 style="margin-bottom: var(--space-4);">Login</h2>
        
        <!-- Google Sign In Button -->
        <a href="http://localhost:3001/api/auth/google/login" class="btn btn-secondary w-full" style="margin-bottom: var(--space-3); display: flex; align-items: center; justify-content: center; gap: var(--space-2);">
          <svg width="18" height="18" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
          </svg>
          Sign in with Google
        </a>
        
        <div style="text-align: center; margin: var(--space-3) 0; color: var(--text-secondary); position: relative;">
          <hr style="position: absolute; width: 100%; top: 50%; border: none; border-top: 1px solid var(--border-color);">
          <span style="background: white; padding: 0 var(--space-2); position: relative; z-index: 1;">or</span>
        </div>
        
        <form id="login-form">
          <div class="form-group">
            <label for="username" class="form-label">Email</label>
            <input type="email" id="username" name="username" class="form-input" required autocomplete="username" value="soccer@lighthouse1893.org">
          </div>
          
          <div class="form-group">
            <label for="password" class="form-label">Password</label>
            <input type="password" id="password" name="password" class="form-input" required autocomplete="current-password" value="1893Soccer!">
          </div>
          
          <button type="submit" class="btn btn-primary w-full">Login</button>
        </form>
      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Handle login form submission
    const form = this.find('#login-form');
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        const username = this.find('#username').value;
        const password = this.find('#password').value;
        
        this.handleLogin(username, password);
      });
    }
  }
  
  handleLogin(username, password) {
    // Disable submit button during login
    const submitBtn = this.find('button[type="submit"]');
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.textContent = 'Logging in...';
    }
    
    this.auth.login(username, password)
      .then(data => {
        this.navigation.context.user = data.user;
        this.navigation.goTo('role-selection');
      })
      .catch(err => {
        // Re-enable submit button on error
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Login';
        }
        this.handleError(err, 'login');
      });
  }
}
