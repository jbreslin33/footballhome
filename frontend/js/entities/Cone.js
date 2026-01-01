class Cone extends FieldEntity {
  constructor(x, y, size = 8) {
    super(x, y);
    this.size = size;
  }

  contains(x, y) {
    return this.distanceTo(x, y) < this.size;
  }

  draw(ctx) {
    const x = this.x;
    const y = this.y;
    const size = this.size;

    // Draw cone as orange triangle
    ctx.fillStyle = '#FF6600';
    ctx.beginPath();
    ctx.moveTo(x, y - size);
    ctx.lineTo(x - size * 0.8, y + size);
    ctx.lineTo(x + size * 0.8, y + size);
    ctx.closePath();
    ctx.fill();

    // Add black outline
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  toJSON() {
    return {
      ...super.toJSON(),
      size: this.size
    };
  }

  static fromJSON(data) {
    return new Cone(data.x, data.y, data.size || 8);
  }
}
