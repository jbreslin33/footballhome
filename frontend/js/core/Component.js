/**
 * Base Component class for creating reusable UI components
 * 
 * Usage:
 * class MyComponent extends Component {
 *   constructor(container, props) {
 *     super(container, props);
 *   }
 *   
 *   render() {
 *     return '<div>My Component</div>';
 *   }
 * }
 */
class Component {
    constructor(container, props = {}) {
        this.container = container;
        this.props = props;
        this.element = null;
        this.stateMachine = null;
        this.eventListeners = [];
        
        // Auto-render if container is provided
        if (this.container) {
            this.mount();
        }
    }
    
    /**
     * Render method - must be overridden by subclasses
     */
    render() {
        throw new Error('render() method must be implemented by subclass');
    }
    
    /**
     * Mount the component to the DOM
     */
    mount() {
        const html = this.render();
        
        if (typeof html === 'string') {
            this.container.innerHTML = html;
            this.element = this.container.firstElementChild || this.container;
        } else if (html instanceof HTMLElement) {
            this.container.appendChild(html);
            this.element = html;
        }
        
        // Setup event listeners after mounting
        this.setupEventListeners();
        
        // Call lifecycle method
        this.onMounted();
    }
    
    /**
     * Unmount component and cleanup
     */
    unmount() {
        this.cleanup();
        
        if (this.element && this.element.parentNode) {
            this.element.parentNode.removeChild(this.element);
        }
        
        this.onUnmounted();
    }
    
    /**
     * Update component with new props
     */
    update(newProps = {}) {
        this.props = { ...this.props, ...newProps };
        this.cleanup();
        this.mount();
    }
    
    /**
     * Setup event listeners - override in subclasses
     */
    setupEventListeners() {
        // Override in subclasses
    }
    
    /**
     * Add event listener with automatic cleanup
     */
    addEventListener(element, event, handler, options = {}) {
        const boundHandler = handler.bind(this);
        element.addEventListener(event, boundHandler, options);
        
        // Track for cleanup
        this.eventListeners.push({
            element,
            event,
            handler: boundHandler,
            options
        });
        
        return boundHandler;
    }
    
    /**
     * Find element within component
     */
    querySelector(selector) {
        return this.element ? this.element.querySelector(selector) : null;
    }
    
    /**
     * Find elements within component
     */
    querySelectorAll(selector) {
        return this.element ? this.element.querySelectorAll(selector) : [];
    }
    
    /**
     * Set component state attribute (for CSS styling)
     */
    setState(state) {
        if (this.element) {
            this.element.setAttribute('data-state', state);
        }
    }
    
    /**
     * Get component state
     */
    getState() {
        return this.element ? this.element.getAttribute('data-state') : null;
    }
    
    /**
     * Add CSS class to component
     */
    addClass(className) {
        if (this.element) {
            this.element.classList.add(className);
        }
    }
    
    /**
     * Remove CSS class from component
     */
    removeClass(className) {
        if (this.element) {
            this.element.classList.remove(className);
        }
    }
    
    /**
     * Toggle CSS class on component
     */
    toggleClass(className, force = null) {
        if (this.element) {
            return this.element.classList.toggle(className, force);
        }
        return false;
    }
    
    /**
     * Show component
     */
    show() {
        if (this.element) {
            this.element.style.display = '';
        }
    }
    
    /**
     * Hide component
     */
    hide() {
        if (this.element) {
            this.element.style.display = 'none';
        }
    }
    
    /**
     * Cleanup event listeners
     */
    cleanup() {
        this.eventListeners.forEach(({ element, event, handler, options }) => {
            element.removeEventListener(event, handler, options);
        });
        this.eventListeners = [];
    }
    
    /**
     * Lifecycle method - called after component is mounted
     */
    onMounted() {
        // Override in subclasses
    }
    
    /**
     * Lifecycle method - called before component is unmounted
     */
    onUnmounted() {
        // Override in subclasses
    }
    
    /**
     * Attach a state machine to this component
     */
    attachStateMachine(stateMachine) {
        this.stateMachine = stateMachine;
        
        // Listen for state changes and update component state
        this.stateMachine.onStateChange((transition) => {
            this.setState(transition.to);
            this.onStateChange(transition);
        });
        
        // Set initial state
        this.setState(this.stateMachine.getState());
    }
    
    /**
     * Handle state machine state changes - override in subclasses
     */
    onStateChange(transition) {
        // Override in subclasses
        console.log(`Component state changed: ${transition.from} -> ${transition.to}`);
    }
    
    /**
     * Emit custom events
     */
    emit(eventName, detail = null) {
        if (this.element) {
            const event = new CustomEvent(eventName, {
                detail,
                bubbles: true,
                cancelable: true
            });
            this.element.dispatchEvent(event);
        }
    }
    
    /**
     * Listen for custom events on this component
     */
    on(eventName, handler) {
        if (this.element) {
            return this.addEventListener(this.element, eventName, handler);
        }
    }
}