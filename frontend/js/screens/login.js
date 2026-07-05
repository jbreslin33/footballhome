// LoginScreen — two-path sign-in.
//
// Layout:
//   1. Big Google button on top (auto-hidden if server env not configured).
//   2. Big "Sign in with email & password" button that reveals the
//      classic email/password form.
//   3. Below the form: "Forgot / set password" link that reveals an
//      inline email field and posts /api/auth/forgot-password.  Server
//      always answers 200 with the same message — no enumeration.
//
// Behaviour when Google isn't wired: the classic panel auto-expands so
// the user never sees a lone secondary button with no obvious next
// step.
//
// Design constraints:
//   - No cached HTML: the whole SPA runs on Cache-Control: no-store.
//   - Google button hidden until /api/auth/google/status returns
//     configured:true — otherwise the /login redirect would 500.
class LoginScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-login';
    div.innerHTML = `
      <div class="screen-header">
        <h1>⚽ Football Home</h1>
        <p class="subtitle">Team practice management made easy</p>
      </div>

      <div class="card" style="max-width: 420px; margin: var(--space-4) auto;">
        <h2 style="margin-bottom: var(--space-4);">Sign in</h2>

        <!-- Google button.
             Rendered hidden; _probeGoogleStatus() reveals it only after
             /api/auth/google/status confirms creds are configured. -->
        <a href="/api/auth/google/login"
           id="google-login-btn"
           class="btn btn-primary w-full"
           style="display:none; margin-bottom: var(--space-3); align-items:center; justify-content:center; gap: var(--space-2); font-size: 1rem; padding: var(--space-3);">
          <svg width="20" height="20" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="background:white; border-radius: 3px; padding: 2px;">
            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
          </svg>
          <span>Continue with Google</span>
        </a>

        <!-- Alternate path.  Clicking reveals the classic form. -->
        <button type="button"
                id="show-classic-btn"
                class="btn btn-secondary w-full"
                style="align-items:center; justify-content:center; gap: var(--space-2); font-size: 1rem; padding: var(--space-3);">
          ✉️ <span>Sign in with email &amp; password</span>
        </button>

        <!-- Classic email/password form — hidden until user chooses it,
             or auto-expanded when Google isn't available. -->
        <div id="classic-panel" style="display:none; margin-top: var(--space-4);">
          <form id="login-form">
            <div class="form-group">
              <label for="username" class="form-label">Email</label>
              <input type="email" id="username" name="username" class="form-input"
                     required autocomplete="username"
                     placeholder="you@example.com">
            </div>

            <div class="form-group">
              <label for="password" class="form-label">Password</label>
              <input type="password" id="password" name="password" class="form-input"
                     required autocomplete="current-password">
            </div>

            <button type="submit" class="btn btn-primary w-full">Login</button>
          </form>

          <!-- Forgot / set password toggle.  Same UI also covers first-
               time password setup — the back-end just overwrites
               password_hash regardless of prior state. -->
          <div style="margin-top: var(--space-3); text-align: center;">
            <a href="#" id="forgot-toggle"
               style="color: var(--text-secondary); font-size: 0.9rem; text-decoration: underline;">
              Forgot password? / Need to set a password?
            </a>
          </div>

          <div id="forgot-panel" style="display:none; margin-top: var(--space-3); padding: var(--space-3); background: var(--bg-secondary, #f5f7fb); border-radius: 6px;">
            <p style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem; color: var(--text-secondary);">
              Enter the email on your Football Home account.  We'll send
              you a link to set a new password.  The link expires in
              60&nbsp;minutes.
            </p>
            <form id="forgot-form" style="display:flex; gap: var(--space-2); flex-wrap: wrap;">
              <input type="email" id="forgot-email" class="form-input"
                     required autocomplete="email"
                     placeholder="you@example.com"
                     style="flex: 1 1 200px;">
              <button type="submit" class="btn btn-primary" style="flex: 0 0 auto;">
                Send reset link
              </button>
            </form>
            <p id="forgot-result" style="margin: var(--space-2) 0 0 0; font-size: 0.9rem;"></p>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    // Probe Google before deciding whether to auto-expand the classic
    // panel.  If Google isn't configured we don't want the user to see
    // one secondary button with no obvious next step.
    this._probeGoogleStatus();

    const showClassic = this.find('#show-classic-btn');
    if (showClassic) {
      showClassic.addEventListener('click', () => this._openClassicPanel());
    }

    const form = this.find('#login-form');
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        const username = this.find('#username').value;
        const password = this.find('#password').value;
        this.handleLogin(username, password);
      });
    }

    const forgotToggle = this.find('#forgot-toggle');
    if (forgotToggle) {
      forgotToggle.addEventListener('click', (e) => {
        e.preventDefault();
        const panel = this.find('#forgot-panel');
        if (!panel) return;
        panel.style.display = (panel.style.display === 'none' || !panel.style.display) ? 'block' : 'none';
        if (panel.style.display === 'block') {
          // Prefill the reset field with whatever the user typed above.
          const emailInput = this.find('#username');
          const forgotInput = this.find('#forgot-email');
          if (emailInput && forgotInput && emailInput.value && !forgotInput.value) {
            forgotInput.value = emailInput.value;
          }
          if (forgotInput) forgotInput.focus();
        }
      });
    }

    const forgotForm = this.find('#forgot-form');
    if (forgotForm) {
      forgotForm.addEventListener('submit', (e) => {
        e.preventDefault();
        this._handleForgotSubmit();
      });
    }
  }

  _openClassicPanel() {
    const panel = this.find('#classic-panel');
    const btn   = this.find('#show-classic-btn');
    if (panel) panel.style.display = 'block';
    if (btn)   btn.style.display   = 'none';
    const email = this.find('#username');
    if (email) {
      try { email.focus(); email.select(); } catch (_) {}
    }
  }

  async _probeGoogleStatus() {
    let googleAvailable = false;
    try {
      const res = await fetch('/api/auth/google/status', {
        headers: { 'Cache-Control': 'no-store' },
      });
      if (res.ok) {
        const data = await res.json();
        googleAvailable = !!(data && data.configured === true);
      }
    } catch (_) {
      // Network/parse failure — treat as not available.
    }

    if (googleAvailable) {
      const btn = this.find('#google-login-btn');
      if (btn) btn.style.display = 'flex';
      // Leave the classic panel collapsed so Google is the obvious primary.
    } else {
      // No Google option — go straight to the classic panel so users
      // don't stare at a lone secondary button.
      this._openClassicPanel();
    }
  }

  async _handleForgotSubmit() {
    const emailInput = this.find('#forgot-email');
    const result     = this.find('#forgot-result');
    const submitBtn  = this.find('#forgot-form button[type="submit"]');

    const email = (emailInput ? emailInput.value : '').trim();
    if (!email) return;

    if (result) {
      result.style.color = 'var(--text-secondary)';
      result.textContent = 'Sending…';
    }
    if (submitBtn) submitBtn.disabled = true;

    try {
      const res = await fetch('/api/auth/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store',
        },
        body: JSON.stringify({ email }),
      });
      // Server returns 200 with a generic message regardless of
      // whether the email exists.  Any 2xx is success; anything else
      // becomes a generic failure message.
      if (res.ok) {
        let msg = "If that address is registered, we've emailed a reset link. Check your inbox (and spam).";
        try {
          const data = await res.json();
          if (data && data.message) msg = data.message;
        } catch (_) {}
        if (result) {
          result.style.color = '#0a7d33';
          result.textContent = msg;
        }
      } else {
        if (result) {
          result.style.color = '#b00020';
          result.textContent = 'Sorry — something went wrong. Please try again in a minute.';
        }
      }
    } catch (_) {
      if (result) {
        result.style.color = '#b00020';
        result.textContent = 'Network error. Check your connection and try again.';
      }
    } finally {
      if (submitBtn) submitBtn.disabled = false;
    }
  }

  handleLogin(username, password) {
    const submitBtn = this.find('#login-form button[type="submit"]');
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
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Login';
        }
        this.handleError(err, 'login');
      });
  }
}
