// Base class for all field entities
class FieldEntity {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.id = Date.now() + Math.random();
  }

  contains(x, y) {
    throw new Error('contains() must be implemented by subclass');
  }

  draw(ctx) {
    throw new Error('draw() must be implemented by subclass');
  }

  toJSON() {
    return {
      x: this.x,
      y: this.y,
      id: this.id,
      type: this.constructor.name
    };
  }

  distanceTo(x, y) {
    const dx = this.x - x;
    const dy = this.y - y;
    return Math.sqrt(dx * dx + dy * dy);
  }
}
