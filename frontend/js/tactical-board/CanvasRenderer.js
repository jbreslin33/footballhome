// Minimal placeholder CanvasRenderer
class CanvasRenderer {
  constructor(canvas) { this.canvas = canvas; this.ctx = canvas ? canvas.getContext('2d') : null; }
  clear() { if (this.ctx) this.ctx.clearRect(0,0,this.canvas.width,this.canvas.height); }
  draw() {}
}

window.CanvasRenderer = CanvasRenderer;
