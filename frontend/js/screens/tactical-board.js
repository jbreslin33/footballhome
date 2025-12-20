// TacticalBoardScreen - Interactive tactical board with player positions
class TacticalBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.canvas = null;
    this.ctx = null;
    this.players = [];
    this.selectedPlayer = null;
    this.isDragging = false;
    this.arrows = [];
    this.drawingArrow = null;
    this.mode = 'move'; // 'move' or 'draw'
    this.scale = 1;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-tactical-board';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Tactical Board</h1>
        <div style="display: flex; gap: var(--space-2);">
          <button class="btn btn-secondary save-btn">💾 Save</button>
          <button class="btn btn-secondary share-btn">📤 Share</button>
        </div>
      </div>
      
      <div style="display: flex; gap: var(--space-3); padding: var(--space-3); height: calc(100vh - 120px);">
        <!-- Toolbar -->
        <div style="width: 200px; display: flex; flex-direction: column; gap: var(--space-2);">
          <div class="card">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Tools</h3>
            <button class="btn btn-sm mode-btn" data-mode="move" style="width: 100%; justify-content: flex-start;">
              🖱️ Move Players
            </button>
            <button class="btn btn-sm mode-btn" data-mode="draw" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              ✏️ Draw Arrows
            </button>
            <button class="btn btn-sm clear-arrows-btn" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              🗑️ Clear Arrows
            </button>
          </div>
          
          <div class="card">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Formations</h3>
            <button class="btn btn-sm formation-btn" data-formation="4-4-2" style="width: 100%;">4-4-2</button>
            <button class="btn btn-sm formation-btn" data-formation="4-3-3" style="width: 100%; margin-top: var(--space-1);">4-3-3</button>
            <button class="btn btn-sm formation-btn" data-formation="3-5-2" style="width: 100%; margin-top: var(--space-1);">3-5-2</button>
          </div>
          
          <div class="card" style="flex: 1; overflow-y: auto;">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Players</h3>
            <div id="player-list"></div>
          </div>
        </div>
        
        <!-- Canvas -->
        <div style="flex: 1; position: relative; background: #1a4d2e; border-radius: 8px; overflow: hidden;">
          <canvas id="tactical-canvas" style="display: block; width: 100%; height: 100%; cursor: crosshair;"></canvas>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    // Get team from context
    const team = this.navigation.context.team;
    if (!team) {
      alert('No team selected');
      this.navigation.goBack();
      return;
    }
    
    // Initialize canvas
    this.initCanvas();
    
    // Load team roster
    this.loadRoster(team.id);
    
    // Setup event listeners
    this.setupEventListeners();
    
    // Set initial mode
    this.setMode('move');
  }
  
  initCanvas() {
    this.canvas = this.find('#tactical-canvas');
    this.ctx = this.canvas.getContext('2d');
    
    // Set canvas size to match container
    const container = this.canvas.parentElement;
    this.canvas.width = container.clientWidth;
    this.canvas.height = container.clientHeight;
    
    // Handle resize
    window.addEventListener('resize', () => this.handleResize());
    
    // Draw initial field
    this.drawField();
  }
  
  handleResize() {
    if (!this.canvas) return;
    const container = this.canvas.parentElement;
    this.canvas.width = container.clientWidth;
    this.canvas.height = container.clientHeight;
    this.drawAll();
  }
  
  setupEventListeners() {
    // Back button
    this.find('.back-btn').addEventListener('click', () => {
      this.navigation.goBack();
    });
    
    // Save button
    this.find('.save-btn').addEventListener('click', () => {
      this.saveTacticalBoard();
    });
    
    // Share button
    this.find('.share-btn').addEventListener('click', () => {
      this.shareTacticalBoard();
    });
    
    // Mode buttons
    this.element.querySelectorAll('.mode-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const mode = e.currentTarget.dataset.mode;
        this.setMode(mode);
      });
    });
    
    // Clear arrows
    this.find('.clear-arrows-btn').addEventListener('click', () => {
      this.arrows = [];
      this.drawAll();
    });
    
    // Formation buttons
    this.element.querySelectorAll('.formation-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const formation = e.currentTarget.dataset.formation;
        this.applyFormation(formation);
      });
    });
    
    // Canvas mouse events
    this.canvas.addEventListener('mousedown', (e) => this.handleMouseDown(e));
    this.canvas.addEventListener('mousemove', (e) => this.handleMouseMove(e));
    this.canvas.addEventListener('mouseup', (e) => this.handleMouseUp(e));
    this.canvas.addEventListener('mouseleave', (e) => this.handleMouseUp(e));
  }
  
  setMode(mode) {
    this.mode = mode;
    
    // Update button styles
    this.element.querySelectorAll('.mode-btn').forEach(btn => {
      if (btn.dataset.mode === mode) {
        btn.classList.add('btn-primary');
        btn.classList.remove('btn-secondary');
      } else {
        btn.classList.remove('btn-primary');
        btn.classList.add('btn-secondary');
      }
    });
    
    // Update cursor
    this.canvas.style.cursor = mode === 'move' ? 'pointer' : 'crosshair';
  }
  
  loadRoster(teamId) {
    const endpoint = `/api/teams/${teamId}/roster`;
    this.safeFetch(endpoint, response => {
      const roster = response.data || [];
      
      // Initialize players on field
      this.players = roster
        .filter(p => p.roster_status === 'active')
        .map((p, index) => ({
          id: p.player_id,
          name: p.preferred_name || p.first_name,
          jerseyNumber: p.jersey_number || index + 1,
          x: this.canvas.width / 2,
          y: this.canvas.height / 2 + (index * 30) - 150,
          color: '#FF6B35'
        }));
      
      // Update player list
      this.updatePlayerList();
      
      // Draw initial state
      this.drawAll();
    });
  }
  
  updatePlayerList() {
    const listContainer = this.find('#player-list');
    listContainer.innerHTML = this.players
      .map(p => `
        <div style="padding: var(--space-1); border-bottom: 1px solid var(--color-border); display: flex; align-items: center; gap: var(--space-2);">
          <div style="width: 24px; height: 24px; background: ${p.color}; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.7rem; font-weight: bold; color: white;">
            ${p.jerseyNumber}
          </div>
          <span style="font-size: 0.85rem;">${p.name}</span>
        </div>
      `)
      .join('');
  }
  
  drawField() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;
    
    // Clear canvas
    ctx.fillStyle = '#1a4d2e';
    ctx.fillRect(0, 0, w, h);
    
    // Field lines
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 2;
    
    // Outline
    ctx.strokeRect(20, 20, w - 40, h - 40);
    
    // Center line
    ctx.beginPath();
    ctx.moveTo(w / 2, 20);
    ctx.lineTo(w / 2, h - 20);
    ctx.stroke();
    
    // Center circle
    ctx.beginPath();
    ctx.arc(w / 2, h / 2, 60, 0, Math.PI * 2);
    ctx.stroke();
    
    // Penalty areas
    const penaltyWidth = 200;
    const penaltyHeight = 150;
    
    // Left penalty area
    ctx.strokeRect(20, (h - penaltyHeight) / 2, penaltyWidth, penaltyHeight);
    
    // Right penalty area
    ctx.strokeRect(w - 20 - penaltyWidth, (h - penaltyHeight) / 2, penaltyWidth, penaltyHeight);
  }
  
  drawPlayers() {
    const ctx = this.ctx;
    
    this.players.forEach(player => {
      // Draw player circle
      ctx.fillStyle = player.color;
      ctx.beginPath();
      ctx.arc(player.x, player.y, 20, 0, Math.PI * 2);
      ctx.fill();
      
      // Draw border if selected
      if (this.selectedPlayer === player) {
        ctx.strokeStyle = 'yellow';
        ctx.lineWidth = 3;
        ctx.stroke();
      }
      
      // Draw jersey number
      ctx.fillStyle = 'white';
      ctx.font = 'bold 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(player.jerseyNumber, player.x, player.y);
      
      // Draw name below
      ctx.font = '11px sans-serif';
      ctx.fillText(player.name, player.x, player.y + 30);
    });
  }
  
  drawArrows() {
    const ctx = this.ctx;
    
    // Draw completed arrows
    this.arrows.forEach(arrow => {
      this.drawArrow(arrow.startX, arrow.startY, arrow.endX, arrow.endY, arrow.color || '#FFD700');
    });
    
    // Draw arrow being drawn
    if (this.drawingArrow) {
      this.drawArrow(
        this.drawingArrow.startX,
        this.drawingArrow.startY,
        this.drawingArrow.currentX,
        this.drawingArrow.currentY,
        '#FFD700'
      );
    }
  }
  
  drawArrow(startX, startY, endX, endY, color) {
    const ctx = this.ctx;
    const headLength = 15;
    const angle = Math.atan2(endY - startY, endX - startX);
    
    ctx.strokeStyle = color;
    ctx.fillStyle = color;
    ctx.lineWidth = 3;
    
    // Draw line
    ctx.beginPath();
    ctx.moveTo(startX, startY);
    ctx.lineTo(endX, endY);
    ctx.stroke();
    
    // Draw arrowhead
    ctx.beginPath();
    ctx.moveTo(endX, endY);
    ctx.lineTo(
      endX - headLength * Math.cos(angle - Math.PI / 6),
      endY - headLength * Math.sin(angle - Math.PI / 6)
    );
    ctx.lineTo(
      endX - headLength * Math.cos(angle + Math.PI / 6),
      endY - headLength * Math.sin(angle + Math.PI / 6)
    );
    ctx.closePath();
    ctx.fill();
  }
  
  drawAll() {
    this.drawField();
    this.drawArrows();
    this.drawPlayers();
  }
  
  handleMouseDown(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    if (this.mode === 'move') {
      // Check if clicking on a player
      this.selectedPlayer = this.players.find(p => {
        const dx = p.x - x;
        const dy = p.y - y;
        return Math.sqrt(dx * dx + dy * dy) < 20;
      });
      
      if (this.selectedPlayer) {
        this.isDragging = true;
      }
    } else if (this.mode === 'draw') {
      // Start drawing arrow
      this.drawingArrow = {
        startX: x,
        startY: y,
        currentX: x,
        currentY: y
      };
    }
  }
  
  handleMouseMove(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    if (this.mode === 'move' && this.isDragging && this.selectedPlayer) {
      this.selectedPlayer.x = x;
      this.selectedPlayer.y = y;
      this.drawAll();
    } else if (this.mode === 'draw' && this.drawingArrow) {
      this.drawingArrow.currentX = x;
      this.drawingArrow.currentY = y;
      this.drawAll();
    }
  }
  
  handleMouseUp(e) {
    if (this.mode === 'move') {
      this.isDragging = false;
    } else if (this.mode === 'draw' && this.drawingArrow) {
      // Complete arrow
      const rect = this.canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      
      this.arrows.push({
        startX: this.drawingArrow.startX,
        startY: this.drawingArrow.startY,
        endX: x,
        endY: y,
        color: '#FFD700'
      });
      
      this.drawingArrow = null;
      this.drawAll();
    }
  }
  
  applyFormation(formation) {
    const w = this.canvas.width;
    const h = this.canvas.height;
    const margin = 80;
    
    let positions = [];
    
    if (formation === '4-4-2') {
      positions = [
        // GK
        { x: margin, y: h / 2 },
        // Defense
        { x: w * 0.2, y: h * 0.25 },
        { x: w * 0.2, y: h * 0.42 },
        { x: w * 0.2, y: h * 0.58 },
        { x: w * 0.2, y: h * 0.75 },
        // Midfield
        { x: w * 0.5, y: h * 0.25 },
        { x: w * 0.5, y: h * 0.42 },
        { x: w * 0.5, y: h * 0.58 },
        { x: w * 0.5, y: h * 0.75 },
        // Attack
        { x: w * 0.75, y: h * 0.4 },
        { x: w * 0.75, y: h * 0.6 }
      ];
    } else if (formation === '4-3-3') {
      positions = [
        // GK
        { x: margin, y: h / 2 },
        // Defense
        { x: w * 0.2, y: h * 0.25 },
        { x: w * 0.2, y: h * 0.42 },
        { x: w * 0.2, y: h * 0.58 },
        { x: w * 0.2, y: h * 0.75 },
        // Midfield
        { x: w * 0.5, y: h * 0.33 },
        { x: w * 0.5, y: h * 0.5 },
        { x: w * 0.5, y: h * 0.67 },
        // Attack
        { x: w * 0.75, y: h * 0.25 },
        { x: w * 0.75, y: h * 0.5 },
        { x: w * 0.75, y: h * 0.75 }
      ];
    } else if (formation === '3-5-2') {
      positions = [
        // GK
        { x: margin, y: h / 2 },
        // Defense
        { x: w * 0.2, y: h * 0.33 },
        { x: w * 0.2, y: h * 0.5 },
        { x: w * 0.2, y: h * 0.67 },
        // Midfield
        { x: w * 0.5, y: h * 0.2 },
        { x: w * 0.5, y: h * 0.35 },
        { x: w * 0.5, y: h * 0.5 },
        { x: w * 0.5, y: h * 0.65 },
        { x: w * 0.5, y: h * 0.8 },
        // Attack
        { x: w * 0.75, y: h * 0.4 },
        { x: w * 0.75, y: h * 0.6 }
      ];
    }
    
    // Apply positions to players
    this.players.forEach((player, index) => {
      if (positions[index]) {
        player.x = positions[index].x;
        player.y = positions[index].y;
      }
    });
    
    this.drawAll();
  }
  
  saveTacticalBoard() {
    // TODO: Implement save to backend
    const data = {
      players: this.players,
      arrows: this.arrows
    };
    
    console.log('Saving tactical board:', data);
    alert('Save functionality coming soon!');
  }
  
  shareTacticalBoard() {
    // TODO: Implement share (generate image or PDF)
    alert('Share functionality coming soon!');
  }
  
  onExit() {
    // Clean up
    window.removeEventListener('resize', () => this.handleResize());
  }
}
