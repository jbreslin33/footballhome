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
  
  // Safe fetch that ignores results if screen unmounted
  safeFetch(url, onSuccess) {
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
          this.handleError(error, 'fetch');
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
