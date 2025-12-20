// TacticalBoardScreen - Interactive tactical board with player positions
class TacticalBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.canvas = null;
    this.ctx = null;
    this.homePlayers = [];
    this.opponentPlayers = [];
    this.selectedPlayer = null;
    this.isDragging = false;
    this.arrows = [];
    this.drawingArrow = null;
    this.mode = 'move'; // 'move' or 'draw'
    this.scale = 1;
    this.activeTeam = 'home'; // 'home' or 'opponent'
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-tactical-board';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Tactical Board</h1>
        <div style="display: flex; gap: var(--space-2);">
          <button class="btn btn-secondary load-board-btn">📂 Load</button>
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
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Team</h3>
            <button class="btn btn-sm team-btn" data-team="home" style="width: 100%;">🔵 Home Team</button>
            <button class="btn btn-sm team-btn" data-team="opponent" style="width: 100%; margin-top: var(--space-1);">🔴 Opponent</button>
          </div>
          
          <div class="card">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Formations</h3>
            <button class="btn btn-sm formation-btn" data-formation="4-4-2" style="width: 100%;">4-4-2</button>
            <button class="btn btn-sm formation-btn" data-formation="4-3-3" style="width: 100%; margin-top: var(--space-1);">4-3-3</button>
            <button class="btn btn-sm formation-btn" data-formation="3-5-2" style="width: 100%; margin-top: var(--space-1);">3-5-2</button>
          </div>
          
          <div class="card">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Players</h3>
            <button class="btn btn-sm add-player-btn" style="width: 100%;">➕ Add Player</button>
            <button class="btn btn-sm load-roster-btn" style="width: 100%; margin-top: var(--space-1);">📥 Load Roster</button>
            <button class="btn btn-sm clear-players-btn" style="width: 100%; margin-top: var(--space-1);">🗑️ Clear All</button>
          </div>
          
          <div class="card" style="flex: 1; overflow-y: auto;">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Player List</h3>
            <div id="player-list" style="max-height: 300px; overflow-y: auto;"></div>
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
    console.log('TacticalBoard onEnter - team:', team);
    
    if (!team) {
      console.error('No team in context');
      alert('No team selected');
      this.navigation.goBack();
      return;
    }
    
    // Store team info
    this.teamId = team.id;
    this.teamName = team.name;
    
    // Initialize canvas after a brief delay to ensure DOM is ready
    setTimeout(() => {
      console.log('Initializing canvas...');
      this.initCanvas();
      
      // Setup event listeners
      this.setupEventListeners();
      
      // Set initial mode and team
      this.setMode('move');
      this.setActiveTeam('home');
      
      // Start with empty field - user can load roster or add players manually
      this.drawAll();
    }, 100);
  }
  
  initCanvas() {
    this.canvas = this.find('#tactical-canvas');
    console.log('Canvas element:', this.canvas);
    
    if (!this.canvas) {
      console.error('Canvas element not found!');
      return;
    }
    
    this.ctx = this.canvas.getContext('2d');
    console.log('Canvas context:', this.ctx);
    
    // Set canvas size to match container
    const container = this.canvas.parentElement;
    this.canvas.width = container.clientWidth;
    this.canvas.height = container.clientHeight;
    console.log('Canvas size:', this.canvas.width, 'x', this.canvas.height);
    
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
    
    // Load button
    this.find('.load-board-btn').addEventListener('click', () => {
      this.showLoadBoardDialog();
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
    
    // Team selection buttons
    this.element.querySelectorAll('.team-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const team = e.currentTarget.dataset.team;
        this.setActiveTeam(team);
      });
    });
    
    // Formation buttons
    this.element.querySelectorAll('.formation-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const formation = e.currentTarget.dataset.formation;
        this.applyFormation(formation);
      });
    });
    
    // Player management buttons
    this.find('.add-player-btn').addEventListener('click', () => {
      this.addPlayer();
    });
    
    this.find('.load-roster-btn').addEventListener('click', () => {
      this.loadRoster(this.teamId);
    });
    
    this.find('.clear-players-btn').addEventListener('click', () => {
      if (confirm(`Clear all ${this.activeTeam} players?`)) {
        this.clearPlayers();
      }
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
  
  setActiveTeam(team) {
    this.activeTeam = team;
    console.log('Active team set to:', team);
    
    // Update button styles
    this.element.querySelectorAll('.team-btn').forEach(btn => {
      if (btn.dataset.team === team) {
        btn.classList.add('btn-primary');
        btn.classList.remove('btn-secondary');
      } else {
        btn.classList.remove('btn-primary');
        btn.classList.add('btn-secondary');
      }
    });
    
    this.updatePlayerList();
  }
  
  getActivePlayers() {
    return this.activeTeam === 'home' ? this.homePlayers : this.opponentPlayers;
  }
  
  getAllPlayers() {
    return [...this.homePlayers, ...this.opponentPlayers];
  }
  
  addPlayer() {
    const name = prompt('Player name:');
    if (!name) return;
    
    const number = prompt('Jersey number:', String(this.getActivePlayers().length + 1));
    if (!number) return;
    
    const color = this.activeTeam === 'home' ? '#0066CC' : '#FFFFFF';  // Blue for home, white for away
    const players = this.getActivePlayers();
    
    players.push({
      id: Date.now(),
      name: name,
      jerseyNumber: parseInt(number) || players.length + 1,
      x: this.canvas.width / 2,
      y: this.canvas.height / 2,
      color: color,
      team: this.activeTeam
    });
    
    this.updatePlayerList();
    this.drawAll();
  }
  
  clearPlayers() {
    if (this.activeTeam === 'home') {
      this.homePlayers = [];
    } else {
      this.opponentPlayers = [];
    }
    this.updatePlayerList();
    this.drawAll();
  }
  
  loadRoster(teamId) {
    const endpoint = `/api/teams/${teamId}/roster`;
    console.log('Fetching roster from:', endpoint);
    
    this.safeFetch(endpoint, response => {
      console.log('Roster response:', response);
      const roster = response.data || [];
      console.log('Roster data:', roster);
      
      // Clear current home players
      this.homePlayers = [];
      
      // Initialize players on field
      roster
        .filter(p => p.roster_status === 'active')
        .forEach((p, index) => {
          this.homePlayers.push({
            id: p.player_id,
            name: p.preferred_name || p.first_name,
            jerseyNumber: p.jersey_number || index + 1,
            x: this.canvas.width / 2,
            y: this.canvas.height / 2 + (index * 30) - 150,
            color: '#0066CC',  // Blue for home team
            team: 'home'
          });
        });
      
      console.log('Home players loaded:', this.homePlayers.length);
      
      // Update player list
      this.updatePlayerList();
      
      // Draw initial state
      this.drawAll();
    });
  }
  
  updatePlayerList() {
    const listContainer = this.find('#player-list');
    const players = this.getActivePlayers();
    
    if (players.length === 0) {
      listContainer.innerHTML = '<div style="padding: var(--space-2); text-align: center; opacity: 0.6; font-size: 0.85rem;">No players</div>';
      return;
    }
    
    listContainer.innerHTML = players
      .map((p, index) => `
        <div class="player-item" data-player-id="${p.id}" style="padding: var(--space-1); border-bottom: 1px solid var(--color-border); display: flex; align-items: center; gap: var(--space-2); cursor: pointer;">
          <div style="width: 24px; height: 24px; background: ${p.color}; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.7rem; font-weight: bold; color: white;">
            ${p.jerseyNumber}
          </div>
          <span style="font-size: 0.85rem; flex: 1;">${p.name}</span>
          <button class="delete-player-btn" data-index="${index}" style="background: none; border: none; cursor: pointer; font-size: 1.2rem; opacity: 0.5;" title="Delete">🗑️</button>
        </div>
      `)
      .join('');
    
    // Add delete handlers
    listContainer.querySelectorAll('.delete-player-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const index = parseInt(e.currentTarget.dataset.index);
        this.deletePlayer(index);
      });
    });
    
    // Add click to edit handlers
    listContainer.querySelectorAll('.player-item').forEach((item, index) => {
      item.addEventListener('click', () => {
        this.editPlayer(index);
      });
    });
  }
  
  deletePlayer(index) {
    const players = this.getActivePlayers();
    players.splice(index, 1);
    this.updatePlayerList();
    this.drawAll();
  }
  
  editPlayer(index) {
    const players = this.getActivePlayers();
    const player = players[index];
    
    const name = prompt('Player name:', player.name);
    if (name) player.name = name;
    
    const number = prompt('Jersey number:', player.jerseyNumber);
    if (number) player.jerseyNumber = parseInt(number) || player.jerseyNumber;
    
    this.updatePlayerList();
    this.drawAll();
  }
  
  drawField() {
    const ctx = this.ctx;
    const w = this.canvas.width;
    const h = this.canvas.height;
    
    // Clear canvas with grass color
    ctx.fillStyle = '#1a4d2e';
    ctx.fillRect(0, 0, w, h);
    
    // FIFA regulation pitch is 105m x 68m (ratio 1.544:1)
    // Calculate field dimensions maintaining aspect ratio with padding
    const padding = 40;
    const availableWidth = w - (padding * 2);
    const availableHeight = h - (padding * 2);
    const aspectRatio = 105 / 68;
    
    let fieldWidth, fieldHeight;
    if (availableWidth / availableHeight > aspectRatio) {
      // Height constrained
      fieldHeight = availableHeight;
      fieldWidth = fieldHeight * aspectRatio;
    } else {
      // Width constrained
      fieldWidth = availableWidth;
      fieldHeight = fieldWidth / aspectRatio;
    }
    
    const offsetX = (w - fieldWidth) / 2;
    const offsetY = (h - fieldHeight) / 2;
    
    // Field lines (white)
    ctx.strokeStyle = 'white';
    ctx.lineWidth = 2;
    ctx.fillStyle = 'white';
    
    // Outer boundary
    ctx.strokeRect(offsetX, offsetY, fieldWidth, fieldHeight);
    
    // Halfway line
    ctx.beginPath();
    ctx.moveTo(offsetX + fieldWidth / 2, offsetY);
    ctx.lineTo(offsetX + fieldWidth / 2, offsetY + fieldHeight);
    ctx.stroke();
    
    // Center circle (9.15m radius = ~8.7% of field width)
    const centerCircleRadius = fieldWidth * 0.087;
    ctx.beginPath();
    ctx.arc(offsetX + fieldWidth / 2, offsetY + fieldHeight / 2, centerCircleRadius, 0, Math.PI * 2);
    ctx.stroke();
    
    // Center spot
    ctx.beginPath();
    ctx.arc(offsetX + fieldWidth / 2, offsetY + fieldHeight / 2, 3, 0, Math.PI * 2);
    ctx.fill();
    
    // Penalty areas (40.3m wide x 16.5m deep)
    const penaltyAreaWidth = fieldWidth * (16.5 / 105);
    const penaltyAreaHeight = fieldHeight * (40.3 / 68);
    const penaltyAreaY = offsetY + (fieldHeight - penaltyAreaHeight) / 2;
    
    // Left penalty area
    ctx.strokeRect(offsetX, penaltyAreaY, penaltyAreaWidth, penaltyAreaHeight);
    
    // Right penalty area
    ctx.strokeRect(offsetX + fieldWidth - penaltyAreaWidth, penaltyAreaY, penaltyAreaWidth, penaltyAreaHeight);
    
    // Goal areas (18.3m wide x 5.5m deep)
    const goalAreaWidth = fieldWidth * (5.5 / 105);
    const goalAreaHeight = fieldHeight * (18.3 / 68);
    const goalAreaY = offsetY + (fieldHeight - goalAreaHeight) / 2;
    
    // Left goal area
    ctx.strokeRect(offsetX, goalAreaY, goalAreaWidth, goalAreaHeight);
    
    // Right goal area
    ctx.strokeRect(offsetX + fieldWidth - goalAreaWidth, goalAreaY, goalAreaWidth, goalAreaHeight);
    
    // Penalty spots (11m from goal line = 10.5% of field width)
    const penaltySpotDistance = fieldWidth * (11 / 105);
    
    // Left penalty spot
    ctx.beginPath();
    ctx.arc(offsetX + penaltySpotDistance, offsetY + fieldHeight / 2, 3, 0, Math.PI * 2);
    ctx.fill();
    
    // Right penalty spot
    ctx.beginPath();
    ctx.arc(offsetX + fieldWidth - penaltySpotDistance, offsetY + fieldHeight / 2, 3, 0, Math.PI * 2);
    ctx.fill();
    
    // Penalty arcs (9.15m radius from penalty spot, only the part outside penalty box)
    const penaltyArcRadius = centerCircleRadius;
    
    // Calculate the angle where the arc intersects the penalty box edge
    // The penalty box edge is at penaltyAreaWidth from the goal line
    // The penalty spot is at penaltySpotDistance from the goal line
    // So the distance from penalty spot to box edge is: penaltyAreaWidth - penaltySpotDistance
    const distanceToBoxEdge = penaltyAreaWidth - penaltySpotDistance;
    
    // If the arc radius is greater than distance to box edge, calculate the angle
    if (penaltyArcRadius > distanceToBoxEdge) {
      const angleAtBoxEdge = Math.acos(distanceToBoxEdge / penaltyArcRadius);
      
      // Left penalty arc (only draw the part outside the penalty box)
      ctx.beginPath();
      ctx.arc(offsetX + penaltySpotDistance, offsetY + fieldHeight / 2, penaltyArcRadius, -angleAtBoxEdge, angleAtBoxEdge);
      ctx.stroke();
      
      // Right penalty arc (only draw the part outside the penalty box)
      ctx.beginPath();
      ctx.arc(offsetX + fieldWidth - penaltySpotDistance, offsetY + fieldHeight / 2, penaltyArcRadius, Math.PI - angleAtBoxEdge, Math.PI + angleAtBoxEdge);
      ctx.stroke();
    }
    
    // Corner arcs (1m radius)
    const cornerRadius = fieldWidth * (1 / 105);
    
    // Bottom-left corner
    ctx.beginPath();
    ctx.arc(offsetX, offsetY + fieldHeight, cornerRadius, -Math.PI / 2, 0);
    ctx.stroke();
    
    // Top-left corner
    ctx.beginPath();
    ctx.arc(offsetX, offsetY, cornerRadius, 0, Math.PI / 2);
    ctx.stroke();
    
    // Bottom-right corner
    ctx.beginPath();
    ctx.arc(offsetX + fieldWidth, offsetY + fieldHeight, cornerRadius, Math.PI, Math.PI * 1.5);
    ctx.stroke();
    
    // Top-right corner
    ctx.beginPath();
    ctx.arc(offsetX + fieldWidth, offsetY, cornerRadius, Math.PI / 2, Math.PI);
    ctx.stroke();
    
    // Goals (7.32m wide x 2.44m deep)
    const goalWidth = fieldHeight * (7.32 / 68);
    const goalDepth = fieldWidth * (2.44 / 105);
    const goalY = offsetY + (fieldHeight - goalWidth) / 2;
    
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.7)';
    ctx.lineWidth = 3;
    
    // Left goal
    ctx.strokeRect(offsetX - goalDepth, goalY, goalDepth, goalWidth);
    
    // Right goal
    ctx.strokeRect(offsetX + fieldWidth, goalY, goalDepth, goalWidth);
  }
  
  drawPlayers() {
    const ctx = this.ctx;
    const allPlayers = this.getAllPlayers();
    
    allPlayers.forEach(player => {
      // Draw player circle
      ctx.fillStyle = player.color;
      ctx.beginPath();
      ctx.arc(player.x, player.y, 20, 0, Math.PI * 2);
      ctx.fill();
      
      // Always draw a border for visibility (especially for white players)
      ctx.strokeStyle = this.selectedPlayer === player ? 'yellow' : '#333';
      ctx.lineWidth = this.selectedPlayer === player ? 3 : 2;
      ctx.beginPath();
      ctx.arc(player.x, player.y, 20, 0, Math.PI * 2);
      ctx.stroke();
      
      // Draw jersey number (black for white players, white for others)
      ctx.fillStyle = player.color === '#FFFFFF' ? '#000000' : '#FFFFFF';
      ctx.font = 'bold 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(player.jerseyNumber, player.x, player.y);
      
      // Draw name below (with background for visibility)
      ctx.font = '11px sans-serif';
      const textWidth = ctx.measureText(player.name).width;
      ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      ctx.fillRect(player.x - textWidth/2 - 2, player.y + 22, textWidth + 4, 14);
      ctx.fillStyle = 'white';
      ctx.fillText(player.name, player.x, player.y + 29);
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
      // Check if clicking on a player from all players
      const allPlayers = this.getAllPlayers();
      this.selectedPlayer = allPlayers.find(p => {
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
    console.log('Applying formation:', formation);
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
    
    const players = this.getActivePlayers();
    const color = this.activeTeam === 'home' ? '#0066CC' : '#FFFFFF';  // Blue for home, white for away
    
    // If we don't have enough players, create them
    while (players.length < positions.length) {
      const playerNum = players.length + 1;
      const positionName = playerNum === 1 ? 'GK' : playerNum <= 5 ? 'DEF' : playerNum <= 9 ? 'MID' : 'ATT';
      players.push({
        id: Date.now() + players.length,
        name: `${positionName} ${playerNum}`,
        jerseyNumber: playerNum,
        x: this.canvas.width / 2,
        y: this.canvas.height / 2,
        color: color,
        team: this.activeTeam
      });
    }
    
    // Apply positions to players
    players.forEach((player, index) => {
      if (positions[index]) {
        player.x = positions[index].x;
        player.y = positions[index].y;
      }
    });
    
    console.log(`Formation ${formation} applied with ${players.length} players`);
    this.updatePlayerList();
    this.drawAll();
  }
  
  async saveTacticalBoard() {
    try {
      // Get board metadata
      const boardName = prompt('Enter board name:', `Tactical Board - ${new Date().toLocaleDateString()}`);
      if (!boardName) return;
      
      const description = prompt('Enter description (optional):', '');
      
      // Prepare board data with players and arrows embedded
      const boardData = {
        name: boardName,
        description: description || '',
        boardTypeId: 2, // Practice session
        formationHome: this.getFormationString('home') || '',
        formationOpponent: this.getFormationString('opponent') || '',
        canvasWidth: Math.floor(this.canvas.width),
        canvasHeight: Math.floor(this.canvas.height),
        isPublic: false,
        isTemplate: false
      };
      
      console.log('Saving board:', JSON.stringify(boardData, null, 2));
      
      // Get auth token from localStorage (same pattern as roster-management.js)
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('Not authenticated. Please log in first.');
      }
      
      // Create the board
      const response = await fetch('http://localhost:3001/api/tactical-boards', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(boardData)
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Server error:', errorText);
        let errorMessage = 'Failed to create board';
        try {
          const error = JSON.parse(errorText);
          errorMessage = error.error || errorMessage;
        } catch (e) {
          errorMessage = errorText || errorMessage;
        }
        throw new Error(errorMessage);
      }
      
      const result = await response.json();
      const boardId = result.id;
      
      console.log('Board created with ID:', boardId);
      
      // Note: For full functionality, we'd need additional endpoints to save:
      // - Players (POST /api/tactical-boards/:boardId/players)
      // - Arrows (POST /api/tactical-boards/:boardId/arrows)  
      // - Team link (POST /api/tactical-boards/:boardId/entities)
      // These can be added to the backend later
      
      alert(`Board "${boardName}" saved successfully!\n\nBoard ID: ${boardId}\n\nNote: Player positions and arrows are saved locally. Backend integration for these will be added soon.`);
      this.currentBoardId = boardId;
      
      // Save to localStorage as backup
      this.saveToLocalStorage(boardId);
      
    } catch (error) {
      console.error('Error saving board:', error);
      alert(`Failed to save board: ${error.message}`);
    }
  }
  
  saveToLocalStorage(boardId) {
    const data = {
      boardId,
      homePlayers: this.homePlayers,
      opponentPlayers: this.opponentPlayers,
      arrows: this.arrows,
      timestamp: Date.now()
    };
    localStorage.setItem(`tactical-board-${boardId}`, JSON.stringify(data));
  }
  
  loadFromLocalStorage(boardId) {
    const data = localStorage.getItem(`tactical-board-${boardId}`);
    if (data) {
      return JSON.parse(data);
    }
    return null;
  }
  
  getFormationString(team) {
    const players = team === 'home' ? this.homePlayers : this.opponentPlayers;
    // Simple formation detection based on player count
    if (players.length === 11) return '4-4-2';
    if (players.length === 10) return '4-3-3';
    return 'custom';
  }
  
  async loadTacticalBoard(boardId) {
    try {
      console.log('Loading board:', boardId);
      
      const response = await fetch(`http://localhost:3001/api/tactical-boards/${boardId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to load board');
      }
      
      const board = await response.json();
      console.log('Loaded board:', board);
      
      // Clear current board
      this.homePlayers = [];
      this.opponentPlayers = [];
      this.arrows = [];
      
      // Load players
      for (const player of board.players) {
        const playerObj = {
          x: parseFloat(player.positionX),
          y: parseFloat(player.positionY),
          number: player.jerseyNumber,
          name: player.name
        };
        
        if (player.team === 'home') {
          this.homePlayers.push(playerObj);
        } else {
          this.opponentPlayers.push(playerObj);
        }
      }
      
      // Load arrows
      for (const arrow of board.arrows) {
        this.arrows.push({
          startX: parseFloat(arrow.startX),
          startY: parseFloat(arrow.startY),
          endX: parseFloat(arrow.endX),
          endY: parseFloat(arrow.endY),
          color: arrow.color || '#000000'
        });
      }
      
      this.currentBoardId = boardId;
      this.draw();
      
      alert(`Board "${board.name}" loaded successfully!`);
      
    } catch (error) {
      console.error('Error loading board:', error);
      alert(`Failed to load board: ${error.message}`);
    }
  }
  
  async loadBoardsList() {
    try {
      if (!this.teamId) return [];
      
      const response = await fetch(`http://localhost:3001/api/tactical-boards/team/${this.teamId}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to load boards list');
      }
      
      const boards = await response.json();
      return boards;
      
    } catch (error) {
      console.error('Error loading boards list:', error);
      return [];
    }
  }
  
  async showLoadBoardDialog() {
    try {
      const boards = await this.loadBoardsList();
      
      if (boards.length === 0) {
        alert('No saved boards found for this team.');
        return;
      }
      
      // Create a simple selection dialog
      let message = 'Select a board to load:\n\n';
      boards.forEach((board, index) => {
        message += `${index + 1}. ${board.name} (${new Date(board.createdAt).toLocaleDateString()})\n`;
      });
      message += '\nEnter the number:';
      
      const selection = prompt(message);
      if (!selection) return;
      
      const index = parseInt(selection) - 1;
      if (index >= 0 && index < boards.length) {
        await this.loadTacticalBoard(boards[index].id);
      } else {
        alert('Invalid selection');
      }
      
    } catch (error) {
      console.error('Error showing load dialog:', error);
      alert('Failed to load boards list');
    }
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
