// ScreenManager - manages screen transitions with DOM replacement
class ScreenManager {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    if (!this.container) {
      throw new Error(`Container element #${containerId} not found`);
    }
    
    this.screens = {};
    this.currentScreen = null;
    this.isTransitioning = false;
  }
  
  register(name, screenInstance) {
    this.screens[name] = screenInstance;
  }
  
  show(name, params = {}) {
    // Prevent rapid transitions
    if (this.isTransitioning) {
      console.warn('Transition already in progress, ignoring');
      return;
    }
    
    this.isTransitioning = true;
    
    try {
      // Exit current screen
      if (this.currentScreen) {
        try {
          this.currentScreen.isMounted = false;
          this.currentScreen.onExit();
        } catch (exitError) {
          console.error('Error in onExit:', exitError);
          this.currentScreen.handleError(exitError, 'onExit');
        }
      }
      
      // Clear DOM completely
      this.container.innerHTML = '';
      
      // Get new screen
      const screen = this.screens[name];
      if (!screen) {
        throw new Error(`Screen "${name}" not registered`);
      }
      
      // Render new screen
      let element;
      try {
        element = screen.render();
      } catch (renderError) {
        console.error('Error in render:', renderError);
        screen.handleError(renderError, 'render');
        this.isTransitioning = false;
        return;
      }
      
      // Append to DOM
      this.container.appendChild(element);
      
      // Enter new screen
      try {
        screen.isMounted = true;
        screen.onEnter(params);
      } catch (enterError) {
        console.error('Error in onEnter:', enterError);
        screen.handleError(enterError, 'onEnter');
      }
      
      this.currentScreen = screen;
      
    } catch (error) {
      console.error('Fatal screen transition error:', error);
      this.showFatalError(error);
    } finally {
      this.isTransitioning = false;
    }
  }
  
  showFatalError(error) {
    this.container.innerHTML = `
      <div class="screen screen-error">
        <div class="card">
          <h2>Oops!</h2>
          <p>Something went wrong: ${error.message}</p>
          <button onclick="location.reload()">Reload Page</button>
        </div>
      </div>
    `;
  }
}
