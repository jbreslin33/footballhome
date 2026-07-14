// Screen base class - all screens extend this
class Screen {
  constructor(navigation, auth) {
    this.navigation = navigation;
    this.auth = auth;
    this.element = null;
    this.isMounted = false;
  }
  
  // Find element within this screen
  find(selector) {
    return this.element ? this.element.querySelector(selector) : null;
  }

  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : String(text);
    return div.innerHTML;
  }

  resolveAssetUrl(url) {
    if (!url) return '';

    const trimmed = String(url).trim();
    if (!trimmed) return '';

    // Handle legacy team logo filenames still present in DB records.
    const assetAliases = {
      '/images/teams/logos/lighthouse-1893-sc.png': '/images/teams/logos/lighthouse-1893.png'
    };
    if (assetAliases[trimmed]) return assetAliases[trimmed];

    // SportsEngine S3 logos do not send CORS headers needed for canvas captures.
    // Route them through backend proxy so both inline UI and generated images work.
    if (/^https:\/\/se-team-service-production\.s3\.amazonaws\.com\//i.test(trimmed)) {
      return `/api/social/logo-proxy?url=${trimmed}`;
    }

    if (/^(https?:|data:|blob:)/i.test(trimmed)) return trimmed;
    return trimmed.startsWith('/') ? trimmed : `/${trimmed.replace(/^\/+/, '')}`;
  }

  buildTeamLogoMarkup(url, options = {}) {
    const {
      className = 'team-logo',
      alt = 'Team logo',
      placeholder = '⚽',
      placeholderClass = 'team-logo-placeholder'
    } = options;

    const resolvedUrl = this.resolveAssetUrl(url);
    const safeAlt = String(alt).replace(/"/g, '&quot;');
    const placeholderHtml = `<div class=&quot;${placeholderClass}&quot;>${placeholder}</div>`;

    if (!resolvedUrl) {
      return `<div class="${placeholderClass}">${placeholder}</div>`;
    }

    return `<img src="${resolvedUrl}" class="${className}" alt="${safeAlt}" onerror="this.onerror=null;this.outerHTML='${placeholderHtml}'">`;
  }
  
  // Safe fetch that ignores results if screen unmounted
  safeFetch(url, onSuccess, onError) {
    return this.auth.fetch(url)
      .then(r => {
        if (!r.ok) throw new Error(`HTTP ${r.status}: ${r.statusText}`);
        return r.json();
      })
      .then(data => {
        if (this.isMounted) {
          onSuccess(data);
        } else {
          console.log('Ignoring fetch result - screen unmounted');
        }
      })
      .catch(error => {
        if (this.isMounted) {
          if (typeof onError === 'function') {
            onError(error);
          } else {
            this.handleError(error, 'fetch');
          }
        }
      });
  }
  
  // Helper: render list with empty state
  renderList(containerId, items, renderItem, emptyMessage = 'No items found') {
    const container = this.find(containerId);
    if (!container) {
      console.error(`Container ${containerId} not found`);
      return;
    }
    
    if (!items || items.length === 0) {
      container.innerHTML = `
        <div class="empty-state">
          <p>${emptyMessage}</p>
        </div>
      `;
      return;
    }
    
    container.innerHTML = items.map(renderItem).join('');
  }
  
  // Error handler (can be overridden by subclasses)
  handleError(error, context = 'screen') {
    console.error(`Error in ${context}:`, error);
    
    if (this.element) {
      const errorDiv = document.createElement('div');
      errorDiv.className = 'error-message';
      errorDiv.innerHTML = `
        <p><strong>Error:</strong> ${error.message}</p>
        <button onclick="location.reload()">Reload Page</button>
      `;
      
      // Find main content area or append to element
      const content = this.find('.card') || this.element;
      content.appendChild(errorDiv);
    }
  }
  
  // Abstract methods - subclasses must implement
  render() {
    throw new Error('Subclass must implement render()');
  }

  // ── Layout policy (2026-07-14 user directive) ──────────────────────
  // "expand across and down with no scroll lol unless we can't fit
  // reasonably on screen … for all screens … solve at OOP level"
  //
  // Historically many screens wrapped their content in a
  //   <div style="max-width: 800px|1200px|1600px; margin: 0 auto;">
  // centered card — a habit from text-first pages that actively hurts
  // workbench-style screens (rosters, admin, matches, kanban) which
  // want every pixel.  Instead of chasing max-widths through 60+
  // screen files, `ScreenManager` calls this on every rendered
  // element right after render() so the constraint is neutralised at
  // the base-class level.
  //
  // What we strip (walked only 3 levels deep — deeper things are
  // content, not layout):
  //   * inline `max-width: Npx|Nrem` where N ≥ 500 (small controls
  //     like inputs/badges with max-width: 200px stay intact)
  //   * inline horizontal auto-margins (`margin: X auto`,
  //     `margin-left: auto`, `margin-right: auto`) — same rationale
  //
  // Opt-out per-element by adding class `narrow` or `js-keep-width`
  // — those two survive untouched.  Modals + overlays (position:
  // fixed / absolute) are also skipped so tooltips/popovers keep
  // their own sizing.
  applyLayoutRules(root) {
    if (!root || typeof root.querySelectorAll !== 'function') return;

    // Walk root itself + up to 3 levels of wrapping divs.  Beyond 3
    // we're into content, not layout containers.
    const candidates = [root];
    const push = (sel) => root.querySelectorAll(sel).forEach(el => candidates.push(el));
    push(':scope > div');
    push(':scope > div > div');
    push(':scope > div > div > div');

    const KEEP_CLASSES = ['narrow', 'js-keep-width'];
    const isOptOut = (el) => KEEP_CLASSES.some(c => el.classList && el.classList.contains(c));

    for (const el of candidates) {
      if (!el || !el.style) continue;
      if (isOptOut(el)) continue;

      // Skip absolutely-positioned things (tooltips, modals, popovers).
      const pos = el.style.position;
      if (pos === 'fixed' || pos === 'absolute') continue;

      // Strip max-width ≥ 500px so container wrappers go edge-to-edge
      // but small controls keep their sizing.
      const mw = el.style.maxWidth;
      const m = mw && mw.match(/^(\d+(?:\.\d+)?)(px|rem)$/);
      if (m) {
        const px = m[2] === 'rem' ? parseFloat(m[1]) * 16 : parseFloat(m[1]);
        if (px >= 500) el.style.maxWidth = 'none';
      }

      // Strip horizontal auto-margin (the "centered container" idiom).
      const marg = el.style.margin || '';
      if (/\bauto\b/.test(marg)) {
        // Rewrite margin so vertical values survive but horizontal
        // becomes 0.  Simplest safe rewrite: leave top/bottom via the
        // resolved margin-top/bottom and clear left/right.
        const cs = getComputedStyle(el);
        const mt = cs.marginTop;
        const mb = cs.marginBottom;
        el.style.margin = '';
        el.style.marginTop = mt;
        el.style.marginBottom = mb;
        el.style.marginLeft = '0';
        el.style.marginRight = '0';
      } else {
        if (el.style.marginLeft === 'auto')  el.style.marginLeft  = '0';
        if (el.style.marginRight === 'auto') el.style.marginRight = '0';
      }
    }
  }

  onEnter(params) {
    // Called when screen becomes visible
    // Subclasses can override
  }

  onExit() {
    // Called when screen is about to be hidden
    // Subclasses can override
  }
}
