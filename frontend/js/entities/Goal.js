class Goal extends FieldEntity {
  constructor(x, y, angle = 0, width = 40, height = 20) {
    super(x, y);
    this.angle = angle;
    this.width = width;
    this.height = height;
  }

  contains(x, y) {
    const gw = this.width;
    const gh = this.height;
    return x >= (this.x - gw/2) && x <= (this.x + gw/2) && 
           y >= (this.y - gh/2) && y <= (this.y + gh/2);
  }

  draw(ctx, isEditing = false) {
    const w = this.width;
    const h = this.height;
    const x = this.x;
    const y = this.y;
    const angle = this.angle;

    // Save context and apply rotation
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(angle);

    // Draw posts
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    // Left post
    ctx.beginPath();
    ctx.moveTo(-w/2, -h/2);
    ctx.lineTo(-w/2, h/2);
    ctx.stroke();

    // Right post
    ctx.beginPath();
    ctx.moveTo(w/2, -h/2);
    ctx.lineTo(w/2, h/2);
    ctx.stroke();

    // Crossbar
    ctx.beginPath();
    ctx.moveTo(-w/2, -h/2);
    ctx.lineTo(w/2, -h/2);
    ctx.stroke();

    // Slight shadow/backing for visibility
    ctx.strokeStyle = 'rgba(0,0,0,0.25)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(-w/2 - 1, h/2 + 1);
    ctx.lineTo(w/2 + 1, h/2 + 1);
    ctx.stroke();

    ctx.restore();

    // If this goal is being edited, draw rotation indicator above it
    if (isEditing) {
      ctx.fillStyle = '#FFD700';
      ctx.font = '20px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      ctx.fillText('🔄', x, y - h/2 - 10);
    }
  }

  toJSON() {
    return {
      ...super.toJSON(),
      angle: this.angle,
      width: this.width,
      height: this.height
    };
  }

  static fromJSON(data) {
    return new Goal(data.x, data.y, data.angle || 0, data.width || 40, data.height || 20);
  }
}
