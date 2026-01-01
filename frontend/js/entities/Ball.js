class Ball extends FieldEntity {
  constructor(x, y) {
    super(x, y);
    this.radius = 15;
  }

  contains(x, y) {
    return this.distanceTo(x, y) <= this.radius;
  }

  draw(ctx) {
    ctx.fillStyle = '#FFD700';
    ctx.beginPath();
    ctx.arc(this.x, this.y, 6, 0, Math.PI * 2);
    ctx.fill();
    
    // Add black pattern lines for soccer ball look
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.arc(this.x, this.y, 6, 0, Math.PI * 2);
    ctx.stroke();
    
    // Draw pentagon pattern
    for (let i = 0; i < 5; i++) {
      const angle = (i * Math.PI * 2) / 5;
      const x1 = this.x + Math.cos(angle) * 4;
      const y1 = this.y + Math.sin(angle) * 4;
      const angle2 = ((i + 2) * Math.PI * 2) / 5;
      const x2 = this.x + Math.cos(angle2) * 4;
      const y2 = this.y + Math.sin(angle2) * 4;
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.stroke();
    }
  }

  static fromJSON(data) {
    return new Ball(data.x, data.y);
  }
}
