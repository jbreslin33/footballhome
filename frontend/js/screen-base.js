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
  
  onEnter(params) {
    // Called when screen becomes visible
    // Subclasses can override
  }
  
  onExit() {
    // Called when screen is about to be hidden
    // Subclasses can override
  }
}
