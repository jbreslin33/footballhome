// LoginScreen - username/password authentication
class LoginScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-login';
    div.innerHTML = `
      <div class="card">
        <h2>Football Home Login</h2>
        <form id="login-form">
          <div class="form-group">
            <label for="username">Email</label>
            <input type="email" id="username" name="username" class="form-input" required autocomplete="username">
          </div>
          
          <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" class="form-input" required autocomplete="current-password">
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
