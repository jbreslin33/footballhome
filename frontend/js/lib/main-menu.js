// MainMenu — six groups on #role-selection, a group's pages as pills.
//
// Owner 2026-11-11: "main menu … is too cluttered … x amount of basic
// standard categories on main menu and then from there … pills" / "rsvp
// and this week are same thing" / "yes build it".
//
// Rows: menu_groups + menu_pages (mig 1244), GET /api/menu.  A page's
// `audience` is who saw its old tile — unchanged:
//   everyone · coach (coaches + admins) · admin · marketing (+ admins)
// Each page still gates itself on the server; this only decides what to
// draw.
//
//   MainMenu.load(auth)                 → Promise (groups, pages, access)
//   MainMenu.groups()                   → [{ code, label, icon, pages:[visible] }] (empty groups dropped)
//   MainMenu.openGroup(code)            → the group's last-used page (players: the first)
//   MainMenu.open(pageCode)             → go to that page (the old tile's route)
//   MainMenu.onScreen(screenName)       → draw / hide the pill strip (#menu-pills);
//                                         ScreenManager calls it after every show
//
// Last-used page per group: localStorage (a per-device convenience).
class MainMenu {
  static _data = null;        // { groups, pages }
  static _access = null;      // { admin, marketing, coach }
  static _promise = null;
  static ADMIN_LEVELS = ['club', 'sport_division', 'team', 'super', 'system', 'league'];
  // Pages that never set navigation.context.role (the old tile list).
  static NOT_ROLES = ['calendar', 'reports', 'rsvps', 'security', 'logos', 'files', 'invoices', 'opponents', 'casa',
                      'game-center', 'event-center', 'kit', 'teams', 'tactical', 'league-schedules', 'apsl'];

  static get _nav()  { return window.app && window.app.navigation; }
  static get _auth() { return window.app && window.app.auth; }

  static _user(auth) {
    const a = auth || MainMenu._auth;
    return (a && a.user) || (MainMenu._nav && MainMenu._nav.context && MainMenu._nav.context.user) || {};
  }

  static load(auth) {
    auth = auth || MainMenu._auth;
    if (!auth || !auth.isLoggedIn()) return Promise.resolve(null);
    if (MainMenu._promise) return MainMenu._promise;
    MainMenu._promise = (async () => {
      const user = MainMenu._user(auth);
      const admin = MainMenu.ADMIN_LEVELS.includes(user.role);
      let coach = admin;
      const [menuRes, rolesRes] = await Promise.all([
        auth.fetch('/api/menu'),
        admin ? Promise.resolve(null) : auth.fetch('/api/auth/me/roles').catch(() => null),
      ]);
      if (!menuRes.ok) throw new Error(`HTTP ${menuRes.status}`);
      const body = await menuRes.json();
      if (rolesRes && rolesRes.ok) {
        const rb = await rolesRes.json().catch(() => ({}));
        const roles = (rb && rb.data && Array.isArray(rb.data.roles)) ? rb.data.roles : [];
        // A coach, or anyone with an admins row, saw the coach tiles.
        coach = roles.some(r => r && (r.type === 'coach' || r.type === 'admin'));
      }
      MainMenu._access = { admin, coach, marketing: admin || user.role === 'marketing' };
      MainMenu._data = (body && body.data) || { groups: [], pages: [] };
      return MainMenu._data;
    })().catch((err) => { MainMenu._promise = null; throw err; });
    return MainMenu._promise;
  }

  // A sign-out / view-as change: read again next time.
  static reset() { MainMenu._promise = null; MainMenu._data = null; MainMenu._access = null; }

  static _sees(page) {
    const a = MainMenu._access || {};
    switch (page.audience) {
      case 'everyone':  return true;
      case 'coach':     return !!(a.coach || a.admin);
      case 'marketing': return !!a.marketing;
      default:          return !!a.admin;
    }
  }

  static isStaff() { const a = MainMenu._access || {}; return !!(a.admin || a.coach || a.marketing); }

  static groups() {
    const d = MainMenu._data;
    if (!d) return [];
    return (d.groups || []).map(g => ({
      ...g, pages: (d.pages || []).filter(p => p.group === g.code && MainMenu._sees(p)),
    })).filter(g => g.pages.length);
  }

  static _pageFor(screen) {
    const d = MainMenu._data;
    if (!d || !screen) return null;
    return (d.pages || []).find(p => (p.screens || []).includes(screen) && MainMenu._sees(p)) || null;
  }

  static _lastKey(group) { return `fh.menu.last.${group}`; }
  static _remember(page) {
    try { localStorage.setItem(MainMenu._lastKey(page.group), page.code); } catch (_) { /* fine */ }
  }

  static openGroup(code) {
    const g = MainMenu.groups().find(x => x.code === code);
    if (!g) return;
    let page = g.pages[0];
    // Players land on the first page (This Week → RSVP); staff where they were.
    if (MainMenu.isStaff()) {
      let last = null;
      try { last = localStorage.getItem(MainMenu._lastKey(code)); } catch (_) { /* fine */ }
      page = g.pages.find(p => p.code === last && !p.href) || page;
    }
    MainMenu.open(page.code);
  }

  // The old tile routes (RoleSelectionScreen.handleRoleSelection until
  // mig 1244), one place for the menu buttons and the pills.
  static open(code) {
    const nav = MainMenu._nav;
    const page = MainMenu._data && (MainMenu._data.pages || []).find(p => p.code === code);
    if (page && page.href) {
      if (page.download) {
        const a = document.createElement('a');
        a.href = page.href; a.download = ''; document.body.appendChild(a); a.click(); a.remove();
      } else if (page.newTab) {
        window.open(page.href, '_blank', 'noopener');
      } else {
        window.location.href = page.href;
      }
      return;
    }
    if (!nav) return;
    if (page) MainMenu._remember(page);
    const user = MainMenu._user();
    const ctx = nav.context;
    // Same as the old tiles: the code becomes the header's role, except
    // for pages that are screens, not hats.
    if (!MainMenu.NOT_ROLES.includes(code)) ctx.role = code;
    switch (code) {
      case 'admin':       return nav.goTo('admin-level-selection');
      case 'club-admin':  return nav.goTo('admin-club', { clubId: 134, clubName: 'Lighthouse 1893 SC' });
      case 'financial':   return nav.goTo('payments');
      case 'player':      return nav.goTo('my');
      case 'game-center': return nav.goTo('event-center', { pick: true, kind: 'all' });
      case 'marketing':   return nav.goTo('marketing-home');
      case 'teams':
      case 'tactical':
        // The Teams board scopes its cards by the viewer's hat.
        ctx.role = (MainMenu.ADMIN_LEVELS.includes(user.role) || user.role === 'marketing') ? 'club-admin' : 'coach';
        return nav.goTo(code);
      default:
        // Every other page's screen state is its code.
        return nav.goTo(code);
    }
  }

  // ── The pill strip ──────────────────────────────────────────────────
  static async onScreen(screen) {
    const host = document.getElementById('menu-pills');
    if (!host) return;
    const hide = () => { host.style.display = 'none'; host.innerHTML = ''; };
    if (!screen || screen === 'role-selection' || screen === 'login' || screen === 'oauth-success') return hide();
    try { await MainMenu.load(); } catch (_) { return hide(); }
    // A newer show() may have run while the menu loaded.
    const current = window.app && window.app.navigation && window.app.navigation.currentState;
    if (current && current !== screen) return;
    const page = MainMenu._pageFor(screen);
    if (!page) return hide();
    const group = MainMenu.groups().find(g => g.code === page.group);
    if (!group) return hide();
    // A player's group of one (Files, Game) needs no strip.
    if (group.pages.length < 2) return hide();
    MainMenu._remember(page);
    const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    const copy = (tier, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('main_menu', tier)) ? MessageCopy.block('main_menu', tier) : fb;
    const pill = (attrs, label, on) => `<button type="button" ${attrs}
        style="flex:0 0 auto; padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.82rem; white-space:nowrap;
               background:${on ? '#0ea5e9' : 'transparent'}; color:${on ? '#fff' : 'var(--fg, #e5e7eb)'};
               border:1px solid ${on ? '#0ea5e9' : 'var(--border-color, #374151)'};">${label}</button>`;
    host.innerHTML = `
      ${pill('data-menu-home', esc(copy('home_pill', '☰ Menu')), false)}
      <span style="flex:0 0 auto; align-self:center; font-weight:800; opacity:0.6; font-size:0.8rem; margin:0 2px 0 6px;">${esc(group.icon)} ${esc(group.label)}</span>
      ${group.pages.map(p => pill(`data-menu-page="${esc(p.code)}"`, `${esc(p.icon)} ${esc(p.label)}`, p.code === page.code)).join('')}`;
    host.style.display = 'flex';
    if (!host._wired) {
      host._wired = true;
      host.addEventListener('click', (e) => {
        if (e.target.closest('[data-menu-home]')) { const n = MainMenu._nav; if (n) n.goTo('role-selection'); return; }
        const b = e.target.closest('[data-menu-page]');
        if (b) MainMenu.open(b.getAttribute('data-menu-page'));
      });
    }
  }
}

window.MainMenu = MainMenu;
