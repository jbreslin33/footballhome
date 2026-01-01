class Player extends FieldEntity {
  constructor(x, y, jerseyNumber = '', name = '', team = 'home', playerId = null) {
    super(x, y);
    this.jerseyNumber = jerseyNumber;
    this.name = name;
    this.team = team;
    this.playerId = playerId;
    this.radius = 20;
    this.color = team === 'home' ? '#0066CC' : '#FFFFFF';
  }

  contains(x, y) {
    return this.distanceTo(x, y) <= this.radius;
  }

  draw(ctx, isSelected = false) {
    // Draw player circle
    ctx.fillStyle = this.color;
    ctx.beginPath();
    ctx.arc(this.x, this.y, 10, 0, Math.PI * 2);
    ctx.fill();
    
    // Always draw a border for visibility (especially for white players)
    ctx.strokeStyle = isSelected ? 'yellow' : '#333';
    ctx.lineWidth = isSelected ? 3 : 2;
    ctx.beginPath();
    ctx.arc(this.x, this.y, 10, 0, Math.PI * 2);
    ctx.stroke();
    
    // Draw jersey number (black for white players, white for others)
    ctx.fillStyle = this.color === '#FFFFFF' ? '#000000' : '#FFFFFF';
    ctx.font = 'bold 14px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.jerseyNumber, this.x, this.y);
    
    // Draw name below (with background for visibility)
    if (this.name) {
      ctx.font = '11px sans-serif';
      const textWidth = ctx.measureText(this.name).width;
      ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      ctx.fillRect(this.x - textWidth/2 - 2, this.y + 22, textWidth + 4, 14);
      ctx.fillStyle = 'white';
      ctx.fillText(this.name, this.x, this.y + 29);
    }
  }

  toJSON() {
    return {
      ...super.toJSON(),
      jerseyNumber: this.jerseyNumber,
      name: this.name,
      team: this.team,
      playerId: this.playerId,
      color: this.color
    };
  }

  static fromJSON(data) {
    return new Player(data.x, data.y, data.jerseyNumber, data.name, data.team, data.playerId);
  }
}
