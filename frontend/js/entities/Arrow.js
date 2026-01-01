class Arrow {
  constructor(startX, startY, endX, endY, color = '#FFD700') {
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.color = color;
    this.id = Date.now() + Math.random();
  }

  draw(ctx) {
    const headLength = 15;
    const angle = Math.atan2(this.endY - this.startY, this.endX - this.startX);
    
    ctx.strokeStyle = this.color;
    ctx.fillStyle = this.color;
    ctx.lineWidth = 3;
    
    // Draw line
    ctx.beginPath();
    ctx.moveTo(this.startX, this.startY);
    ctx.lineTo(this.endX, this.endY);
    ctx.stroke();
    
    // Draw arrowhead
    ctx.beginPath();
    ctx.moveTo(this.endX, this.endY);
    ctx.lineTo(
      this.endX - headLength * Math.cos(angle - Math.PI / 6),
      this.endY - headLength * Math.sin(angle - Math.PI / 6)
    );
    ctx.lineTo(
      this.endX - headLength * Math.cos(angle + Math.PI / 6),
      this.endY - headLength * Math.sin(angle + Math.PI / 6)
    );
    ctx.closePath();
    ctx.fill();
  }

  distanceToPoint(px, py) {
    const dx = this.endX - this.startX;
    const dy = this.endY - this.startY;
    const lengthSquared = dx * dx + dy * dy;
    
    if (lengthSquared === 0) {
      return Math.sqrt((px - this.startX) * (px - this.startX) + (py - this.startY) * (py - this.startY));
    }
    
    let t = ((px - this.startX) * dx + (py - this.startY) * dy) / lengthSquared;
    t = Math.max(0, Math.min(1, t));
    
    const closestX = this.startX + t * dx;
    const closestY = this.startY + t * dy;
    
    return Math.sqrt((px - closestX) * (px - closestX) + (py - closestY) * (py - closestY));
  }

  toJSON() {
    return {
      startX: this.startX,
      startY: this.startY,
      endX: this.endX,
      endY: this.endY,
      color: this.color,
      id: this.id
    };
  }

  static fromJSON(data) {
    const arrow = new Arrow(data.startX, data.startY, data.endX, data.endY, data.color);
    arrow.id = data.id;
    return arrow;
  }
}
