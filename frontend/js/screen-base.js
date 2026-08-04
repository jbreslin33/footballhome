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

  // Gmail compose URL for "email" contact buttons. Always pins `authuser`
  // to the club mailbox so compose opens against that account instead of
  // whichever Google account the browser considers active/default — a bug
  // that keeps recurring because screens hand-roll this URL individually.
  // Every screen extends Screen, so building it here makes the fix apply
  // by default to new buttons instead of relying on copy/paste.
  //
  // Android (2026-08-04, revised): mail.google.com is a verified Android
  // App Link, so this URL gets intercepted into the native Gmail app
  // instead of opening as a web page — and that app's own deep-link
  // parser for mail.google.com only understands to/su/body, silently
  // dropping cc/bcc (compose opens with nothing pre-filled beyond
  // whatever `to` was). Tried forcing the navigation through Chrome via
  // an intent://...;package=com.android.chrome;... wrapper to keep it on
  // the *web* compose view (which does support bcc) — unreliable in
  // practice, still landed in the native app on a real test device.
  // mailto: sidesteps all of this: it's a standard RFC 6068 URI that
  // Android routes straight to Gmail's compose (ACTION_SENDTO) intent,
  // which *does* honor cc/bcc/subject/body correctly. The one thing
  // mailto: can't do is pin the sending account — there's no mailto:
  // equivalent of authuser — so on Android the coach may need to tap
  // Gmail's own "From" field to switch to soccer@lighthouse1893.org.
  buildGmailComposeHref({ to, cc, bcc, subject = '', body = '', authuser = 'soccer@lighthouse1893.org' } = {}) {
    if (!to && !cc && !bcc) return null;

    if (/Android/i.test(navigator.userAgent || '')) {
      // mailto: is RFC 6068 — needs %20-style percent-encoding, not the
      // application/x-www-form-urlencoded "+"-for-space that
      // URLSearchParams produces. Gmail's compose intent takes "+"
      // literally, so subject/body showed up full of plus signs.
      const pairs = [];
      if (cc)      pairs.push(`cc=${encodeURIComponent(cc)}`);
      if (bcc)     pairs.push(`bcc=${encodeURIComponent(bcc)}`);
      if (subject) pairs.push(`subject=${encodeURIComponent(subject)}`);
      if (body)    pairs.push(`body=${encodeURIComponent(body)}`);
      const qs = pairs.join('&');
      return `mailto:${to || ''}${qs ? '?' + qs : ''}`;
    }

    const params = { view: 'cm', fs: '1', tf: '1', authuser, su: subject, body };
    if (to)  params.to  = to;
    if (cc)  params.cc  = cc;
    if (bcc) params.bcc = bcc;
    return `https://mail.google.com/mail/?${new URLSearchParams(params).toString()}`;
  }

  // Navigates to a Gmail compose href from JS (vs. a plain <a href>
  // button, which the browser navigates on tap without any JS needed).
  openGmailCompose(href) {
    if (!href) return;
    if (href.startsWith('mailto:')) {
      window.location.href = href;
    } else {
      window.open(href, '_blank', 'noopener');
    }
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
  
  // Full-size photo viewer usable by any screen — attach
  // data-lightbox-src="<url>" to a thumbnail and wire a click handler that
  // calls this. Closes on backdrop click, the ✕ button, or Escape.
  openImageLightbox(imageUrl) {
    if (!imageUrl) return;
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed; inset:0; z-index:1000; background:rgba(0,0,0,0.85); display:flex; align-items:center; justify-content:center; padding:var(--space-4); cursor:zoom-out;';
    overlay.innerHTML = `
      <img src="${this.escapeHtml(imageUrl)}" alt="" style="max-width:100%; max-height:100%; object-fit:contain; border-radius:var(--radius-sm); box-shadow:0 10px 40px rgba(0,0,0,0.5);">
      <button type="button" aria-label="Close" style="position:fixed; top:var(--space-3); right:var(--space-3); background:rgba(0,0,0,0.6); color:#fff; border:1px solid rgba(255,255,255,0.4); border-radius:50%; width:2.2rem; height:2.2rem; font-size:1.1rem; line-height:1; cursor:pointer;">✕</button>
    `;
    const close = () => {
      overlay.remove();
      document.removeEventListener('keydown', onKeyDown);
    };
    const onKeyDown = (e) => {
      if (e.key === 'Escape') close();
    };
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('button')) close();
    });
    document.addEventListener('keydown', onKeyDown);
    document.body.appendChild(overlay);
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
