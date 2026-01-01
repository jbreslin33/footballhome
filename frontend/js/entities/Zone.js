class Zone extends FieldEntity {
  constructor(startX, startY, endX, endY, color = 'rgba(255, 255, 0, 0.3)', borderColor = 'rgba(255, 255, 0, 0.8)') {
    const x = Math.min(startX, endX);
    const y = Math.min(startY, endY);
    super(x, y);
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.color = color;
    this.borderColor = borderColor;
    this.resizeMode = false;
  }

  contains(x, y) {
    const minX = Math.min(this.startX, this.endX);
    const maxX = Math.max(this.startX, this.endX);
    const minY = Math.min(this.startY, this.endY);
    const maxY = Math.max(this.startY, this.endY);
    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }

  draw(ctx) {
    const x = Math.min(this.startX, this.endX);
    const y = Math.min(this.startY, this.endY);
    const width = Math.abs(this.endX - this.startX);
    const height = Math.abs(this.endY - this.startY);
    
    ctx.fillStyle = this.color;
    ctx.fillRect(x, y, width, height);
    
    // Draw border
    ctx.strokeStyle = this.borderColor;
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, width, height);
    
    // Draw resize handles if in resize mode
    if (this.resizeMode) {
      const handleSize = 8;
      ctx.fillStyle = '#FFFFFF';
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 2;
      
      // Four corner handles
      const corners = [
        { x: this.startX, y: this.startY },
        { x: this.endX, y: this.startY },
        { x: this.endX, y: this.endY },
        { x: this.startX, y: this.endY }
      ];
      
      corners.forEach(corner => {
        ctx.fillRect(corner.x - handleSize/2, corner.y - handleSize/2, handleSize, handleSize);
        ctx.strokeRect(corner.x - handleSize/2, corner.y - handleSize/2, handleSize, handleSize);
      });
    }
  }

  getCornerAt(x, y, handleSize = 8) {
    const corners = [
      { x: this.startX, y: this.startY, type: 'start' },
      { x: this.endX, y: this.startY, type: 'endX-startY' },
      { x: this.endX, y: this.endY, type: 'end' },
      { x: this.startX, y: this.endY, type: 'startX-endY' }
    ];
    
    for (const corner of corners) {
      if (Math.abs(x - corner.x) <= handleSize/2 && Math.abs(y - corner.y) <= handleSize/2) {
        return corner.type;
      }
    }
    return null;
  }

  toJSON() {
    return {
      ...super.toJSON(),
      startX: this.startX,
      startY: this.startY,
      endX: this.endX,
      endY: this.endY,
      color: this.color,
      borderColor: this.borderColor
    };
  }

  static fromJSON(data) {
    return new Zone(data.startX, data.startY, data.endX, data.endY, data.color, data.borderColor);
  }
}
