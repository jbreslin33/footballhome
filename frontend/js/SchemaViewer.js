// Custom Schema Diagram Viewer using Canvas
class SchemaViewer {
  constructor(container, tables) {
    this.container = container;
    this.tables = tables;
    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');
    this.scale = 1;
    this.offsetX = 0;
    this.offsetY = 0;
    this.isDragging = false;
    this.dragStartX = 0;
    this.dragStartY = 0;
    this.selectedTable = null;
    this.onTableClick = null;
    
    // Layout tables in a grid
    this.layoutTables();
    
    // Setup canvas
    this.container.appendChild(this.canvas);
    this.resize();
    
    // Event listeners
    window.addEventListener('resize', () => this.resize());
    this.canvas.addEventListener('mousedown', (e) => this.handleMouseDown(e));
    this.canvas.addEventListener('mousemove', (e) => this.handleMouseMove(e));
    this.canvas.addEventListener('mouseup', () => this.handleMouseUp());
    this.canvas.addEventListener('wheel', (e) => this.handleWheel(e));
    this.canvas.addEventListener('click', (e) => this.handleClick(e));
    
    this.draw();
  }
  
  layoutTables() {
    const cols = Math.ceil(Math.sqrt(this.tables.length));
    const spacing = 300;
    
    this.tables.forEach((table, i) => {
      const col = i % cols;
      const row = Math.floor(i / cols);
      table.x = col * spacing + 100;
      table.y = row * spacing + 100;
      table.width = 250;
      table.height = 50 + table.columns.length * 20;
    });
  }
  
  resize() {
    this.canvas.width = this.container.clientWidth;
    this.canvas.height = this.container.clientHeight;
    this.draw();
  }
  
  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    ctx.save();
    ctx.translate(this.offsetX, this.offsetY);
    ctx.scale(this.scale, this.scale);
    
    // Draw foreign key relationships first (behind boxes)
    this.drawRelationships();
    
    // Draw tables
    this.tables.forEach(table => this.drawTable(table));
    
    ctx.restore();
  }
  
  drawRelationships() {
    const ctx = this.ctx;
    const tableMap = {};
    this.tables.forEach(t => tableMap[t.name] = t);
    
    ctx.strokeStyle = '#94a3b8';
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);
    
    this.tables.forEach(table => {
      table.foreign_keys.forEach(fk => {
        const target = tableMap[fk.foreign_table];
        if (!target) return;
        
        const startX = table.x + table.width / 2;
        const startY = table.y + table.height;
        const endX = target.x + target.width / 2;
        const endY = target.y;
        
        ctx.beginPath();
        ctx.moveTo(startX, startY);
        ctx.lineTo(endX, endY);
        ctx.stroke();
        
        // Arrow head
        const angle = Math.atan2(endY - startY, endX - startX);
        const arrowSize = 10;
        ctx.beginPath();
        ctx.moveTo(endX, endY);
        ctx.lineTo(
          endX - arrowSize * Math.cos(angle - Math.PI / 6),
          endY - arrowSize * Math.sin(angle - Math.PI / 6)
        );
        ctx.lineTo(
          endX - arrowSize * Math.cos(angle + Math.PI / 6),
          endY - arrowSize * Math.sin(angle + Math.PI / 6)
        );
        ctx.closePath();
        ctx.fillStyle = '#94a3b8';
        ctx.fill();
      });
    });
    
    ctx.setLineDash([]);
  }
  
  drawTable(table) {
    const ctx = this.ctx;
    const isSelected = this.selectedTable === table.name;
    
    // Box
    ctx.fillStyle = '#ffffff';
    ctx.strokeStyle = isSelected ? '#2563eb' : '#64748b';
    ctx.lineWidth = isSelected ? 3 : 2;
    ctx.fillRect(table.x, table.y, table.width, table.height);
    ctx.strokeRect(table.x, table.y, table.width, table.height);
    
    // Header
    ctx.fillStyle = isSelected ? '#2563eb' : '#475569';
    ctx.fillRect(table.x, table.y, table.width, 30);
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 14px monospace';
    ctx.fillText(table.name, table.x + 10, table.y + 20);
    
    // Columns
    ctx.fillStyle = '#1e293b';
    ctx.font = '12px monospace';
    table.columns.forEach((col, i) => {
      const y = table.y + 50 + i * 20;
      const icon = col.primary_key ? '🔑 ' : '  ';
      const text = `${icon}${col.name}`;
      ctx.fillText(text, table.x + 10, y);
    });
  }
  
  handleMouseDown(e) {
    this.isDragging = true;
    this.dragStartX = e.clientX - this.offsetX;
    this.dragStartY = e.clientY - this.offsetY;
  }
  
  handleMouseMove(e) {
    if (this.isDragging) {
      this.offsetX = e.clientX - this.dragStartX;
      this.offsetY = e.clientY - this.dragStartY;
      this.draw();
    }
  }
  
  handleMouseUp() {
    this.isDragging = false;
  }
  
  handleWheel(e) {
    e.preventDefault();
    const delta = e.deltaY > 0 ? 0.9 : 1.1;
    this.zoom(delta);
  }
  
  handleClick(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left - this.offsetX) / this.scale;
    const y = (e.clientY - rect.top - this.offsetY) / this.scale;
    
    const clickedTable = this.tables.find(t => 
      x >= t.x && x <= t.x + t.width &&
      y >= t.y && y <= t.y + t.height
    );
    
    if (clickedTable) {
      this.selectedTable = clickedTable.name;
      if (this.onTableClick) {
        this.onTableClick(clickedTable);
      }
      this.draw();
    }
  }
  
  zoom(factor) {
    this.scale *= factor;
    this.scale = Math.max(0.1, Math.min(5, this.scale));
    this.draw();
  }
  
  fitToScreen() {
    if (this.tables.length === 0) return;
    
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    this.tables.forEach(t => {
      minX = Math.min(minX, t.x);
      minY = Math.min(minY, t.y);
      maxX = Math.max(maxX, t.x + t.width);
      maxY = Math.max(maxY, t.y + t.height);
    });
    
    const width = maxX - minX;
    const height = maxY - minY;
    const scaleX = (this.canvas.width - 100) / width;
    const scaleY = (this.canvas.height - 100) / height;
    this.scale = Math.min(scaleX, scaleY);
    
    this.offsetX = (this.canvas.width - width * this.scale) / 2 - minX * this.scale;
    this.offsetY = (this.canvas.height - height * this.scale) / 2 - minY * this.scale;
    
    this.draw();
  }
  
  reset() {
    this.scale = 1;
    this.offsetX = 0;
    this.offsetY = 0;
    this.draw();
  }
}
