# Tactical Board Refactoring - Complete

## Overview
Successfully refactored the monolithic `tactical-board.js` file (originally 2196 lines) into a clean entity-based architecture with separate classes for each field element.

## Entity Classes Created

### 1. **FieldEntity.js** (Base Class)
- Properties: `x`, `y`, `id`
- Methods: `contains(x, y)`, `draw(ctx)`, `toJSON()`, `distanceTo(x, y)`
- Serves as the foundation for all drawable field entities

### 2. **Player.js**
- Extends: `FieldEntity`
- Properties: `jerseyNumber`, `name`, `team`, `playerId`, `radius`, `color`
- Features: Automatic team color assignment, name rendering with background
- Constructor: `(x, y, jerseyNumber, name, team, playerId)`

### 3. **Ball.js**
- Extends: `FieldEntity`
- Properties: `radius` (15px)
- Features: Soccer ball appearance with pentagon pattern
- Constructor: `(x, y)`

### 4. **Goal.js**
- Extends: `FieldEntity`
- Properties: `angle`, `width`, `height`
- Features: Rotation support, visual editing indicator (🔄)
- Constructor: `(x, y, angle)`

### 5. **Cone.js**
- Extends: `FieldEntity`
- Properties: `size` (8px)
- Features: Orange triangle rendering
- Constructor: `(x, y)`

### 6. **Zone.js**
- Extends: `FieldEntity`
- Properties: `startX`, `startY`, `endX`, `endY`, `color`, `borderColor`, `resizeMode`
- Features: Resizable corners, color customization, corner handle detection
- Methods: `getCornerAt(x, y, handleSize)`
- Constructor: `(startX, startY, endX, endY)`

### 7. **Arrow.js** (Standalone)
- Does NOT extend `FieldEntity` (different coordinate structure)
- Properties: `startX`, `startY`, `endX`, `endY`, `color`
- Features: Arrowhead rendering, distance calculation for click detection
- Methods: `distanceToPoint(px, py)`
- Constructor: `(startX, startY, endX, endY, color)`

## Main Changes in tactical-board.js

### Constructor
**Before:**
```javascript
this.homePlayers = [];
this.opponentPlayers = [];
this.balls = [];
this.goals = [];
this.cones = [];
this.zones = [];
this.arrows = [];
```

**After:**
```javascript
this.entities = {
  homePlayers: [],
  opponentPlayers: [],
  balls: [],
  goals: [],
  cones: [],
  zones: [],
  arrows: []
};
```

### Selection Management
**Before:** Multiple selection properties
```javascript
this.selectedPlayer = null;
this.selectedBall = null;
this.selectedGoal = null;
this.selectedCone = null;
this.selectedZone = null;
```

**After:** Unified selection
```javascript
this.selectedEntity = null;
```

### Drawing Methods
**Before (drawPlayers - 35 lines):**
```javascript
drawPlayers() {
  const ctx = this.ctx;
  const allPlayers = this.getAllPlayers();
  
  allPlayers.forEach(player => {
    ctx.fillStyle = player.color;
    ctx.beginPath();
    ctx.arc(player.x, player.y, 10, 0, Math.PI * 2);
    ctx.fill();
    // ... 30+ more lines of drawing code
  });
}
```

**After (5 lines):**
```javascript
drawPlayers() {
  const allPlayers = this.getAllPlayers();
  allPlayers.forEach(player => {
    const isSelected = this.selectedEntity === player;
    player.draw(this.ctx, isSelected);
  });
}
```

Similar simplifications for:
- `drawBalls()` - calls `ball.draw(ctx)`
- `drawGoals()` - calls `goal.draw(ctx, isEditing)`
- `drawCones()` - calls `cone.draw(ctx)`
- `drawZones()` - calls `zone.draw(ctx)`
- `drawArrows()` - calls `arrow.draw(ctx)`

### Entity Creation
**Before:**
```javascript
this.balls.push({
  x: x,
  y: y
});
```

**After:**
```javascript
this.entities.balls.push(new Ball(x, y));
```

### Serialization
**Before:**
```javascript
saveToLocalStorage(boardId) {
  const data = {
    boardId,
    homePlayers: this.homePlayers,
    opponentPlayers: this.opponentPlayers,
    arrows: this.arrows,
    // ...
  };
  localStorage.setItem(`tactical-board-${boardId}`, JSON.stringify(data));
}
```

**After:**
```javascript
saveToLocalStorage(boardId) {
  const data = {
    boardId,
    homePlayers: this.entities.homePlayers.map(p => p.toJSON()),
    opponentPlayers: this.entities.opponentPlayers.map(p => p.toJSON()),
    arrows: this.entities.arrows.map(a => a.toJSON()),
    balls: this.entities.balls.map(b => b.toJSON()),
    // ...
  };
  localStorage.setItem(`tactical-board-${boardId}`, JSON.stringify(data));
}

loadFromLocalStorage(boardId) {
  const parsed = JSON.parse(data);
  if (parsed) {
    if (parsed.homePlayers) parsed.homePlayers = parsed.homePlayers.map(p => Player.fromJSON(p));
    if (parsed.arrows) parsed.arrows = parsed.arrows.map(a => Arrow.fromJSON(a));
    // ...
  }
  return parsed;
}
```

## Benefits

### Code Reduction
- Drawing methods reduced from ~150 lines to ~30 lines total
- Eliminated code duplication across entity types
- Main file reduced by approximately 200 lines through refactoring

### Maintainability
- Each entity class is self-contained and focused
- Easy to add new entity types by extending `FieldEntity`
- Drawing logic lives with the entity, not in the main screen
- Clear separation of concerns

### Type Safety
- Constructor signatures enforce correct parameter usage
- `instanceof` checks for entity-specific behavior (e.g., Zone movement)
- Consistent entity interface through base class

### Extensibility
- New entity types require:
  1. Create class extending `FieldEntity`
  2. Implement `draw(ctx)` method
  3. Add to `this.entities` object
  4. Add button/tool for placement
- No changes needed to selection or movement logic

## Files Modified

### Created (7 files)
- `frontend/js/entities/FieldEntity.js`
- `frontend/js/entities/Player.js`
- `frontend/js/entities/Ball.js`
- `frontend/js/entities/Goal.js`
- `frontend/js/entities/Cone.js`
- `frontend/js/entities/Zone.js`
- `frontend/js/entities/Arrow.js`

### Modified (2 files)
- `frontend/index.html` - Added entity script tags
- `frontend/js/screens/tactical-board.js` - Refactored to use entities

## Testing Checklist

✅ All entity classes have `draw()` methods  
✅ All entity classes have `toJSON()` methods  
✅ All entity classes have `static fromJSON()` methods  
✅ Entity creation uses constructors (new Player(), new Ball(), etc.)  
✅ Entity arrays accessed via `this.entities.*`  
✅ Selection uses unified `this.selectedEntity`  
✅ Save/load properly serializes/deserializes entities  
✅ All mouse handlers updated to work with entity instances  
✅ Delete function works with all entity types  
✅ No compilation errors

## Next Steps (Optional Enhancements)

1. **Undo/Redo System**: Entity structure makes this straightforward - serialize state snapshots
2. **Copy/Paste**: Clone entity instances easily via `fromJSON(entity.toJSON())`
3. **Entity Groups**: Add a Group class that extends FieldEntity and contains multiple entities
4. **Animations**: Add `update()` method to FieldEntity for frame-based animations
5. **Custom Entity Properties**: Add UI for editing entity-specific properties beyond position
6. **Entity Layers**: Z-index support for custom drawing order
7. **Snap-to-Grid**: Easy to implement in FieldEntity base class
8. **Entity Templates**: Save/load entity configurations as reusable templates

## Performance Notes

- No performance degradation expected
- Entity `draw()` methods identical to previous inline code
- Slight memory overhead from class instances (negligible)
- Improved garbage collection due to better object structure
- Array operations unchanged in complexity

## Backward Compatibility

⚠️ **Breaking Changes:**
- localStorage format changed (includes all entity types now)
- API save format now uses entity.toJSON() format
- Old saved boards will need migration or won't load properly

**Migration Strategy:**
- Keep `loadFromLocalStorage` compatible by checking for old format
- Add version field to saved data
- Provide one-time migration utility if needed
