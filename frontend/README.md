# Football Home - Vanilla JS Frontend

A vanilla JavaScript frontend implementation of the Football Home application, built with:

- **Finite State Machine (FSM)** architecture for predictable state management
- **Class inheritance** for reusable UI components
- **Pure CSS** design system without external frameworks
- **Event-driven architecture** with custom events
- **API integration** with C++ backend

## 🚀 **Quick Start**

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001

## 🏗️ **Architecture Overview**

### **Core Classes**

```
StateMachine - FSM implementation for state management
Component - Base class for UI components with lifecycle methods
AuthService - API integration and authentication logic
LoginForm - Login component extending Component with FSM
App - Main application orchestrator
```

### **State Management Flow**

```
User Action → FSM Event → State Transition → UI Update
    ↑                                           ↓
    ←─────── Event Listeners ←── DOM Events ←──┘
```

### **Login FSM States**

```
idle → validating → submitting → success
  ↑         ↓            ↓         
  ←─── error ←──────────←─────
```

## 📂 **File Structure**

```
frontend/
├── index.html              # Entry point
├── css/
│   └── main.css           # Pure CSS design system
├── js/
│   ├── app.js             # Application bootstrap
│   ├── auth.js            # Authentication service
│   ├── navigation.js      # Navigation state machine
│   ├── screen-base.js     # Base Screen class
│   ├── screen-manager.js  # Screen lifecycle manager
│   ├── screens/           # Screen implementations
│   ├── entities/          # Field entities (Player, Ball, etc.)
│   └── tactical-board/    # Tactical board feature
├── Dockerfile             # Container configuration
└── nginx.conf            # Web server config
```

## 🎯 **Key Features Demonstrated**

### **✅ Finite State Machine**
- Clean state transitions with explicit events
- State-driven UI updates via CSS `data-state` attributes
- Predictable flow: idle → validating → submitting → success/error

### **✅ Component Inheritance**
- Base `Component` class with common functionality
- Lifecycle methods (`onMounted`, `onUnmounted`)
- Event listener management with automatic cleanup
- State machine integration

### **✅ Pure CSS Design**
- CSS custom properties for theming
- Utility classes for rapid development
- State-responsive styling
- No external dependencies

### **✅ Event-Driven Architecture**
- Custom events for component communication
- DOM event handling with proper cleanup
- Publisher-subscriber pattern for loose coupling

## 🔌 **API Integration**

Uses the C++ backend API:

```javascript
// Login example
const authService = new AuthService('http://localhost:3001');
const result = await authService.login(email, password);

if (result.success) {
  // Handle success
} else {
  // Handle error
}
```

## 🧪 **Testing the Login**

1. **Visit**: http://localhost:3000
2. **Test FSM**: Watch browser console for state transitions
3. **Valid Login**: Use existing user credentials
4. **Invalid Data**: Try empty fields to see validation states
5. **Network Errors**: Disconnect to see error handling

## 🔍 **Development Console**

Open browser DevTools to see FSM logging:

```
🏈 Football Home Vanilla JS App initialized
FSM initialized with state: idle
LoginForm: idle -> validating
FSM: validating --[VALIDATION_SUCCESS]--> submitting  
FSM: submitting --[LOGIN_SUCCESS]--> success
```

## ⚡ **Performance Benefits**

- **Small bundle size** - No framework overhead
- **Fast startup** - Direct DOM manipulation
- **Low memory usage** - No virtual DOM
- **Predictable performance** - Explicit state management

## 🔧 **Development**

### **Adding New Components**

```javascript
class MyComponent extends Component {
  render() {
    return '<div class="my-component">Hello World</div>';
  }
  
  setupEventListeners() {
    const button = this.querySelector('button');
    this.addEventListener(button, 'click', this.handleClick);
  }
  
  handleClick() {
    this.emit('myEvent', { data: 'example' });
  }
}
```

### **FSM Integration**

```javascript
const fsm = new StateMachine({
  initial: 'idle',
  states: {
    idle: { on: { START: 'loading' } },
    loading: { 
      on: { SUCCESS: 'complete', ERROR: 'error' },
      onEntry: () => console.log('Loading started')
    }
  }
});

component.attachStateMachine(fsm);
```

## 🚀 **Future Enhancements**

Potential additions to explore:
- **Router**: Client-side routing with FSM
- **Data Layer**: State management for data fetching
- **Animation**: CSS transitions tied to FSM states
- **Forms**: Reusable form components with validation
- **Testing**: Unit tests for components and FSM

---

This vanilla JS implementation demonstrates that web applications can be built with pure JavaScript while maintaining clean architecture, predictable state management, and excellent performance.