// MainMenu — six groups on #main-menu, a group's pages as pills.
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
//   MainMenu.onScreen(screenName)       → draw the top bar (#menu-pills): groups row +
//                                         the group's pages row; ScreenManager calls it after every show
//
// Last-used page per group: localStorage (a per-device convenience).
class MainMenu {
  static _data = null;        // { groups, pages }
  static _access = null;      // { admin, marketing, coach }
  static _promise = null;
  static ADMIN_LEVELS = ['club', 'sport_division', 'team', 'super', 'system', 'league'];
  // Pages that never set navigation.context.role (the old tile list).
  static NOT_ROLES = ['calendar', 'reports', 'rsvps', 'security', 'logos', 'files', 'invoices', 'opponents', 'casa',
                      'game-center', 'event-center', 'kit', 'teams', 'league-schedules', 'apsl',
                      'game-model', 'game-model-admin', 'tactical-board', 'tactical-live', 'football-taxonomy'];

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
      // 🎭 View-as (owner 11/18): `user` is the viewed person's and
      // /api/auth/me/roles answers as them (core/ViewAs) — their menu, exactly.
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
      case 'named':     return true;   // mig 1928: /api/menu already left it out for anyone not listed
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

  // 🗻 Groups whose pill shows its pages row first (mig 1915, main_menu.pills_first_groups):
  // the pyramid page hides the bar, so its All · MLS · USL … pills are picked here, on
  // the page you are on.  _peek = { group, screen } until a page opens or the screen changes.
  static _peek = null;
  static _pillsFirst(code) {
    const list = (window.MessageCopy && MessageCopy.has && MessageCopy.has('main_menu', 'pills_first_groups'))
      ? String(MessageCopy.block('main_menu', 'pills_first_groups')).split(/\s+/) : [];
    return list.includes(code);
  }

  static openGroup(code) {
    const g = MainMenu.groups().find(x => x.code === code);
    if (!g) return;
    if (g.pages.length >= 2 && MainMenu._pillsFirst(code)) {
      const screen = window.app && window.app.navigation && window.app.navigation.currentState;
      MainMenu._peek = { group: code, screen };
      MainMenu.onScreen(screen);
      return;
    }
    let page = g.pages[0];
    // Players land on the first page (📅 Calendar group → the Calendar); staff where they were.
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
    MainMenu._peek = null;
    if (page) MainMenu._remember(page);
    // 🗻 Pyramids (mig 1913): a menu_pages row pyramid-<league> opens the spinning
    // pyramid on that league — the same address as its public link,
    // #apsl-pyramid/<league>.  A new league = a row, no code.
    if (/^pyramid-[a-z0-9-]+$/.test(code)) return nav.goTo('apsl-pyramid', { entity: code.slice('pyramid-'.length) });
    const user = MainMenu._user();
    const ctx = nav.context;
    // Same as the old tiles: the code becomes the header's role, except
    // for pages that are screens, not hats.
    if (!MainMenu.NOT_ROLES.includes(code)) ctx.role = code;
    switch (code) {
      case 'admin':       return nav.goTo('admin-level-selection');
      case 'club-admin':  return nav.goTo('admin-club', { clubId: 134, clubName: 'Lighthouse 1893 SC' });
      case 'financial':   return nav.goTo('tuition');
      case 'player':      return nav.goTo('my');
      case 'game-center': return nav.goTo('event-center', { pick: true, kind: 'all' });
      case 'marketing':   return nav.goTo('marketing-home');
      // 📣 Marketing's own pills (mig 1349) wear the marketing hat, as when
      // they were tiles on marketing-home.
      case 'ad-preview':
      case 'messages':
      case 'leads':       ctx.role = 'marketing'; return nav.goTo(code);
      case 'teams':
        // The Teams board scopes its cards by the viewer's hat.
        ctx.role = (MainMenu.ADMIN_LEVELS.includes(user.role) || user.role === 'marketing') ? 'club-admin' : 'coach';
        return nav.goTo(code);
      default:
        // Every other page's screen state is its code.
        return nav.goTo(code);
    }
  }

  // ── The top bar: groups, then the group's pages ─────────────────────
  // Owner 2026-11-16: "the main menu doesn't make sense anymore … i have
  // to hit back all the time … having 7 pills at top of site is way to
  // go. then i can switch do diff 'sections' faster and their sub menus".
  // Row 1 = every group the viewer has a page in (+ 👤 Account, the old
  // #main-menu: sign out, view-as).  Row 2 = the current group's pages
  // when it has two or more.  A screen no page claims (an opened event, a
  // person) keeps the last group lit.
  static _group = null;
  static async onScreen(screen) {
    const host = document.getElementById('menu-pills');
    if (!host) return;
    const hide = () => { host.style.display = 'none'; host.innerHTML = ''; };
    if (!screen || screen === 'login' || screen === 'oauth-success') return hide();
    try { await MainMenu.load(); } catch (_) { return hide(); }
    // Staff or not is known now — the User · Role · Team line follows it.
    try { if (MainMenu._nav && MainMenu._nav.updateContextHeader) MainMenu._nav.updateContextHeader(); } catch (_) { /* fine */ }
    // A newer show() may have run while the menu loaded.
    const current = window.app && window.app.navigation && window.app.navigation.currentState;
    if (current && current !== screen) return;
    const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    const copy = (tier, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('main_menu', tier)) ? MessageCopy.block('main_menu', tier) : fb;
    // Phone: icon only, the name in title / aria-label, rows wrap — no
    // side-scrolling for the menu on any page (owner 11/18 "we need icons for
    // phone so we don't have to scroll across for menu items on any page").
    MainMenu._phoneStyle();
    const lbl = (icon, name) => [icon, name];
    const split = (text) => { const m = /^(\S+)\s+(.*)$/.exec(String(text || '')); return m ? [m[1], m[2]] : ['', String(text || '')]; };
    const pill = (attrs, [icon, name], on, big) => `<button type="button" ${attrs} ${on ? 'data-menu-on' : ''} title="${esc(name)}" aria-label="${esc(name)}"
        style="flex:0 0 auto; padding:${big ? '6px 12px' : '4px 11px'}; border-radius:999px; cursor:pointer; font-weight:${big ? 800 : 700};
               font-size:${big ? '0.86rem' : '0.8rem'}; white-space:nowrap;
               background:${on ? (big ? '#0ea5e9' : 'rgba(14,165,233,0.22)') : 'transparent'}; color:${on && big ? '#fff' : 'var(--fg, #e5e7eb)'};
               border:1px solid ${on ? '#0ea5e9' : 'var(--border-color, #374151)'};"><span class="menu-ico">${esc(icon)}</span><span class="menu-lbl"> ${esc(name)}</span></button>`;
    const row = (inner, extra = '') => `<div class="menu-row" style="display:flex; gap:6px; overflow-x:auto; scrollbar-width:none; padding:2px 0; ${extra}">${inner}</div>`;
    // PlayerViewer: no full bar — just its menuBarPages (📅 Calendar) as the
    // admin's big pill, and only away from the Calendar, where it would go
    // nowhere (lib/viewer.js, owner 11/18 "calender 'menu' item like we have
    // on admin when your in game … game or practice. event basically").
    const acct = window.Viewer ? Viewer.account() : null;
    if (acct && !acct.showsMenuBar) {
      // On their Calendar the 📅 pill would go nowhere, so it is left out;
      // 👤 Account (menuBarAccount, owner 11/24) rides every page.
      const home = (acct.homeScreens || []).includes(screen);
      const codes = (acct.menuBarPages || []).filter(c => !(home && c === 'calendar'));
      const mine = ((MainMenu._data && MainMenu._data.pages) || [])
        .filter(p => codes.includes(p.code) && MainMenu._sees(p))
        .sort((a, b) => codes.indexOf(a.code) - codes.indexOf(b.code));
      const onAccount = screen === 'main-menu';
      const acctPill = acct.menuBarAccount
        ? pill('data-menu-account', lbl(...split(copy('account_pill', '👤 Account'))), onAccount, true) : '';
      if (!mine.length && !acctPill) return hide();
      // Lit: the page you are on; else (inside an event) the first one, the Calendar.
      const here = mine.find(p => (p.screens || []).includes(screen));
      host.innerHTML = row(mine.map((p, i) => pill(`data-menu-page="${esc(p.code)}"`, lbl(p.icon, p.label), here ? p === here : (!onAccount && !home && i === 0), true)).join('') + acctPill);
      host.style.display = 'block';
      MainMenu._wire(host);
      return;
    }
    const groups = MainMenu.groups();
    if (!groups.length) return hide();
    const page = MainMenu._pageFor(screen);
    if (page) { MainMenu._remember(page); MainMenu._group = page.group; }
    if (MainMenu._peek && MainMenu._peek.screen !== screen) MainMenu._peek = null;
    const peek = MainMenu._peek && groups.find(g => g.code === MainMenu._peek.group);
    const account = screen === 'main-menu' && !peek;
    const group = peek || (account ? null : groups.find(g => g.code === MainMenu._group) || null);
    const top = groups.map(g => pill(`data-menu-group="${esc(g.code)}"`, lbl(g.icon, g.label), group && g.code === group.code, true)).join('')
      + pill('data-menu-account', lbl(...split(copy('account_pill', '👤 Account'))), account, true);
    const pages = group && group.pages.length >= 2
      ? row(group.pages.map(p => pill(`data-menu-page="${esc(p.code)}"`, lbl(p.icon, p.label), page && p.code === page.code, false)).join(''),
            'margin-top:6px; padding-top:6px; border-top:1px dashed var(--border-color, #374151);')
      : '';
    host.innerHTML = row(top) + pages;
    host.style.display = 'block';
    // Keep the lit pills in view on a phone.
    // (scrollLeft only — scrollIntoView would also move the page.)
    host.querySelectorAll('[data-menu-on]').forEach(b => {
      const r = b.parentElement;
      if (r) r.scrollLeft = Math.max(0, b.offsetLeft - r.offsetLeft - (r.clientWidth - b.offsetWidth) / 2);
    });
    MainMenu._wire(host);
  }

  static _phoneStyle() {
    if (document.getElementById('menu-phone-style')) return;
    const st = document.createElement('style');
    st.id = 'menu-phone-style';
    st.textContent = `@media (max-width: 640px) {
      #menu-pills { padding:6px 8px !important; }
      #menu-pills .menu-row { flex-wrap:wrap; overflow-x:visible !important; justify-content:center; gap:4px !important; }
      #menu-pills .menu-lbl { display:none; }
      #menu-pills button { padding:7px 0 !important; font-size:1.1rem !important; line-height:1; width:38px !important; min-width:0 !important; min-height:38px; }
    }`;
    document.head.appendChild(st);
  }

  static _wire(host) {
    if (!host._wired) {
      host._wired = true;
      host.addEventListener('click', (e) => {
        if (e.target.closest('[data-menu-account]')) { const n = MainMenu._nav; if (n) n.goTo('main-menu'); return; }
        const g = e.target.closest('[data-menu-group]');
        if (g) { MainMenu.openGroup(g.getAttribute('data-menu-group')); return; }
        const b = e.target.closest('[data-menu-page]');
        if (b) MainMenu.open(b.getAttribute('data-menu-page'));
      });
    }
  }
}

window.MainMenu = MainMenu;
// Entering / leaving view-as redraws the menu as the new viewer.
window.addEventListener('viewAsChanged', () => MainMenu.reset());
