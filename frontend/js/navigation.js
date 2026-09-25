// NavigationStateMachine - single source of truth for navigation
class NavigationStateMachine {
  constructor(screenManager, auth) {
    this.screenManager = screenManager;
    this.auth = auth;
    this.currentState = null;
    this.currentParams = {};

    // In-app back stack — one { screen, params } per browser history entry
    // behind the current one.  It mirrors window.history exactly: every
    // goTo() pushes here AND in the browser (even the same screen again
    // with new params — the browser gets an entry either way), and every
    // browser entry carries a copy of the stack behind it, so a reload or
    // the browser's own back/forward buttons (which wipe or bypass this
    // array) can never leave the two out of step.
    //
    // Why (2026-09-25): the owner reloaded on #attendance, pressed the
    // browser's back button (the pre-reload #attendance entry came back,
    // this array stayed empty), then the in-app ← — and the "no history"
    // fallback was the LOGIN screen.  It read as "it logged me out" though
    // the token was never touched.  Now the stack survives all of that,
    // and an empty stack goes home (role selection), never to login while
    // a session exists.
    this.history = [];

    // goBack() in flight: the entry we popped, until the browser's popstate
    // renders it (or the fallback timer does when no popstate comes).
    this._pendingBack = null;
    this._pendingBackTimer = null;

    // Global context - persists across navigation
    this.context = {
      user: null,   // Set on login
      role: null,   // Set on role selection
      team: null    // Set on team selection
    };

    // Listen for browser back/forward buttons (and our own goBack()).
    window.addEventListener('popstate', (event) => {
      const pending = this._pendingBack;
      this._clearPendingBack();
      if (event.state && event.state.screen) {
        this.handleBrowserNavigation(event.state);
      } else if (pending) {
        // The entry behind us carried no state (a hash set by hand, the
        // very first page load) — render what the in-app stack said was
        // there instead of leaving the screen untouched.
        this._showEntry(pending);
      }
    });
  }

  // Update the context header display
  updateContextHeader() {
    const header = document.getElementById('context-header');
    const userEl = document.getElementById('context-user');
    const roleEl = document.getElementById('context-role');
    const teamEl = document.getElementById('context-team');

    // Show header if we have any context
    const hasContext = this.context.user || this.context.role || this.context.team;
    header.style.display = hasContext ? 'block' : 'none';

    // Update each field
    userEl.textContent = this.context.user?.email || '';
    roleEl.textContent = this.context.role ? this.context.role.charAt(0).toUpperCase() + this.context.role.slice(1) : '';
    teamEl.textContent = this.context.team?.name || '';
  }

  // The stack as it is stored on a browser history entry: plain
  // { screen, params } pairs (params were already structured-cloned into
  // their own entry, so they clone here too), capped so a long session
  // cannot grow each entry without bound.
  _stackSnapshot() {
    const keep = 40;
    const from = Math.max(0, this.history.length - keep);
    return this.history.slice(from).map((e) => ({ screen: e.screen, params: e.params || {} }));
  }

  _historyState(state, params) {
    return {
      screen: state,
      context: { ...this.context },
      params: params,
      stack: this._stackSnapshot(),
    };
  }

  _hashFor(state, params) {
    // When a screen has a sub-view concept (e.g. game-model-admin's
    // `entity`), fold it into the hash so the visible URL actually
    // reflects what's on screen instead of always reading the same bare
    // `#state` for every sub-view.
    return params && params.entity ? `#${state}/${params.entity}` : `#${state}`;
  }

  goTo(state, params = {}) {
    // Store current state in history — every time, same screen or not,
    // because the browser gets an entry every time (see constructor).
    if (this.currentState) {
      this.history.push({ screen: this.currentState, params: this.currentParams || {} });
      if (this.history.length > 200) this.history.shift();
    }

    // Update context with any params
    if (params.team) {
      this.context.team = params.team;
    }
    if (params.user) {
      this.context.user = params.user;
    }
    if (params.role) {
      this.context.role = params.role;
    }

    // Update context header display
    this.updateContextHeader();

    // Update current state
    this.currentState = state;
    this.currentParams = params;

    // Push state to browser history.
    const hash = this._hashFor(state, params);
    try {
      window.history.pushState(this._historyState(state, params), '', hash);
    } catch (e) {
      // Params that cannot be structured-cloned (a DOM node, a function)
      // would otherwise throw here and never show the screen.  Keep the
      // entry, drop the params from it.
      console.warn('Navigation: params not storable in history, entry kept without them', e);
      window.history.pushState(this._historyState(state, {}), '', hash);
    }

    // Tell screen manager to show the screen
    this.screenManager.show(state, params);

    console.log(`Navigation: ${state}`, { context: this.context, history: this.history });
  }

  goBack() {
    if (this.history.length === 0) {
      // Nothing behind us in this session.  Home for a signed-in user;
      // login only when there is no session to go home to.
      const home = (this.auth && this.auth.isLoggedIn()) ? 'role-selection' : 'login';
      console.log(`No history, going to ${home}`);
      if (home === 'login') this.context.user = null;
      this.goTo(home);
      return;
    }

    // Clear context based on current screen before going back
    this.clearContextForScreen(this.currentState);

    // Pop previous state from history
    const previous = this.history.pop();
    this.currentState = previous.screen;
    this.currentParams = previous.params || {};

    console.log(`Navigation: back to ${previous.screen}`, { context: this.context, history: this.history });

    // Update context header
    this.updateContextHeader();

    // Let the browser walk back one entry; its popstate renders that
    // entry with the context, params and stack saved on it — one render,
    // not the double load (context-as-params + popstate) this used to do.
    // If no popstate arrives (the browser has nothing behind us), render
    // the popped entry ourselves.
    this._pendingBack = previous;
    this._pendingBackTimer = setTimeout(() => {
      if (this._pendingBack !== previous) return;
      this._clearPendingBack();
      this._showEntry(previous);
    }, 300);
    window.history.back();
  }

  _clearPendingBack() {
    this._pendingBack = null;
    if (this._pendingBackTimer) {
      clearTimeout(this._pendingBackTimer);
      this._pendingBackTimer = null;
    }
  }

  // Render a popped stack entry when the browser could not (no entry
  // behind us, or one without state).  replaceState so the URL and the
  // entry's stored state match what is on screen.
  _showEntry(entry) {
    const params = entry.params || {};
    this.currentState = entry.screen;
    this.currentParams = params;
    try {
      window.history.replaceState(this._historyState(entry.screen, params), '', this._hashFor(entry.screen, params));
    } catch (_) { /* nothing to do — the screen still shows */ }
    this.screenManager.show(entry.screen, params);
  }

  // Handle browser back/forward button navigation
  handleBrowserNavigation(state) {
    console.log('Browser navigation detected:', state);

    // A signed-in user never lands back on the login (or the OAuth
    // hand-off) screen by walking history — those entries predate the
    // session.  Home instead.
    if ((state.screen === 'login' || state.screen === 'oauth-success')
        && this.auth && this.auth.isLoggedIn()) {
      this.goTo('role-selection');
      return;
    }

    // Restore context from history state
    if (state.context) {
      this.context = state.context;
    }

    // Update internal state — including the in-app back stack as it was
    // when this entry was created, so the ← button keeps working after
    // browser back/forward or a reload.
    this.currentState = state.screen;
    this.currentParams = state.params || {};
    this.history = Array.isArray(state.stack)
      ? state.stack.map((e) => ({ screen: e.screen, params: e.params || {} }))
      : [];

    // Update context header
    this.updateContextHeader();

    // Show the screen
    this.screenManager.show(state.screen, this.currentParams);
  }

  // Clear context set by specific screens when navigating back
  clearContextForScreen(screenName) {
    switch(screenName) {
      case 'practice-options':
        // Going back from practice options clears team (set by team-selection)
        this.context.team = null;
        break;
      case 'practice-management':
      case 'practice-form':
      case 'practice-list':
        // Going back from these screens - nothing to clear (team stays)
        break;
      case 'role-selection':
        // Going back from role selection clears user (would go to login)
        this.context.user = null;
        break;
    }
  }

  // Clear history (useful after logout)
  clearHistory() {
    this.history = [];
    this.currentState = null;
    this.currentParams = {};
    this._clearPendingBack();
  }
}
