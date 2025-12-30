// TacticalBoardScreen - Interactive tactical board with player positions
class TacticalBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.canvas = null;
    this.ctx = null;
    this.homePlayers = [];
    this.opponentPlayers = [];
    this.selectedPlayer = null;
    this.selectedBall = null;
    this.isDragging = false;
    this.arrows = [];
    this.drawingArrow = null;
    this.balls = [];
    this.mode = 'move'; // 'move', 'draw', or 'ball'
    this.scale = 1;
    this.activeTeam = 'home'; // 'home' or 'opponent'
    this.fieldHeight = 0;
    this.fieldWidth = 0;
    this.editingPlayer = null;
    this.editInputs = null;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-tactical-board';
    
    div.innerHTML = `
      <div class="screen-header" style="margin-bottom: var(--space-3);">
        <h1 style="margin: 0;">Tactical Board</h1>
      </div>
      
      <div class="toolbar" style="display: flex; gap: var(--space-2); margin-bottom: var(--space-3);">
            <button class="btn btn-secondary load-btn">📂 Load</button>
            <button class="btn btn-secondary save-btn">💾 Save</button>
            <button class="btn btn-secondary link-btn">🔗 Link</button>
            <button class="btn btn-secondary clear-btn">🗑️ Clear</button>
            <button class="btn btn-secondary export-btn">📷 Export Image</button>
            <button class="btn btn-secondary back-btn" style="margin-left: auto;">⬅️ Back</button>
          </div>
      
      <div style="display: flex; gap: var(--space-3); padding: var(--space-3); height: calc(100vh - 120px);">
        <!-- Toolbar -->
        <div style="width: 200px; display: flex; flex-direction: column; gap: var(--space-2);">
          <div class="card">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Tools</h3>
            <button class="btn btn-sm mode-btn" data-mode="move" style="width: 100%; justify-content: flex-start;">
              🖱️ Move
            </button>
            <button class="btn btn-sm mode-btn" data-mode="draw" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              ✏️ Draw Arrows
            </button>
            <button class="btn btn-sm mode-btn" data-mode="ball" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              ⚽ Draw Ball
            </button>
            <button class="btn btn-sm mode-btn" data-mode="draw-player" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              👤 Draw Player
            </button>
            <button class="btn btn-sm mode-btn" data-mode="delete" style="width: 100%; justify-content: flex-start; margin-top: var(--space-1);">
              🗑️ Delete
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
          
          <!-- Player Details (Hidden by default) -->
          <div id="player-details" class="card" style="display: none; margin-top: var(--space-2);">
            <h3 style="margin: 0 0 var(--space-2) 0; font-size: 0.9rem;">Selected Player</h3>
            <div class="form-group">
              <label>Name</label>
              <input type="text" id="player-name-input" class="form-control form-control-sm">
            </div>
            <div class="form-group">
              <label>Number</label>
              <input type="number" id="player-number-input" class="form-control form-control-sm">
            </div>
            <div class="form-group">
              <label>Assign Roster Player</label>
              <select id="roster-select" class="form-control form-control-sm">
                <option value="">-- Select --</option>
              </select>
            </div>
            <button id="update-player-btn" class="btn btn-sm btn-primary" style="width: 100%; margin-top: var(--space-2);">Update</button>
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
    // Get context from params or navigation context
    const team = this.navigation.context.team;
    const club = this.navigation.context.club;
    
    console.log('TacticalBoard onEnter params:', params);
    
    // Store context info
    this.teamId = team?.id || params?.teamId || null;
    this.teamName = team?.name || params?.teamName || null;
    this.clubId = club?.id || params?.clubId || team?.clubId || null;
    
    // Store specific contexts (match, practice)
    this.matchId = params?.matchId || null;
    this.matchTitle = params?.matchTitle || null;
    this.practiceId = params?.practiceId || null;
    this.practiceTitle = params?.practiceTitle || null;
    
    // Validate we have at least one context
    if (!this.teamId && !this.clubId && !this.matchId && !this.practiceId) {
      console.error('No context provided for tactical board');
      alert('No team, club, match, or practice selected');
      this.navigation.goBack();
      return;
    }
    
    // Update header title based on most specific context
    const titleEl = this.find('h1');
    if (this.matchTitle) {
      titleEl.textContent = `Tactics: ${this.matchTitle}`;
    } else if (this.practiceTitle) {
      titleEl.textContent = `Tactics: ${this.practiceTitle}`;
    } else if (this.practiceId) {
      titleEl.textContent = `Tactics: Practice Session`;
    } else if (this.teamName) {
      titleEl.textContent = `Tactical Board: ${this.teamName}`;
    } else {
      titleEl.textContent = `Tactical Board: Club Level`;
    }
    
    // Initialize canvas after a brief delay to ensure DOM is ready
    setTimeout(() => {
      console.log('Initializing canvas...');
      this.initCanvas();
      
      // Setup event listeners
      this.setupEventListeners();
      
      // Show startup menu if we have a context
      if (this.matchId || this.practiceId || this.teamId) {
        this.showStartupMenu();
      }
      
      // Set initial mode and team
      this.setMode('move');
      this.setActiveTeam('home');
      
      // Start with empty field - user can load roster or add players manually
      this.drawAll();
      
      // Load team roster for dropdown
      this.fetchTeamRoster();
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
    this.find('.load-btn').addEventListener('click', () => {
      this.showLoadBoardDialog();
    });
    
    // Save button
    this.find('.save-btn').addEventListener('click', () => {
      this.saveTacticalBoard();
    });
    
    // Link button
    this.find('.link-btn').addEventListener('click', () => {
      this.showLinkDialog();
    });

    // Clear button
    this.find('.clear-btn').addEventListener('click', () => {
      if(confirm('Are you sure you want to clear the board?')) {
        this.homePlayers = [];
        this.opponentPlayers = [];
        this.arrows = [];
        this.balls = [];
        this.drawAll();
      }
    });

    // Export button
    this.find('.export-btn').addEventListener('click', () => {
      const link = document.createElement('a');
      link.download = `tactical-board-${new Date().toISOString().slice(0,10)}.png`;
      link.href = this.canvas.toDataURL();
      link.click();
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
    this.canvas.addEventListener('dblclick', (e) => this.handleCanvasDoubleClick(e));
    
    // Player details events
    this.find('#update-player-btn').addEventListener('click', () => {
      this.updateSelectedPlayer();
    });
    
    this.find('#roster-select').addEventListener('change', (e) => {
      const playerId = e.target.value;
      if (playerId && this.rosterData) {
        const player = this.rosterData.find(p => p.id === playerId);
        if (player) {
          this.find('#player-name-input').value = `${player.firstName} ${player.lastName}`;
          this.find('#player-number-input').value = player.jerseyNumber || '';
        }
      }
    });
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
  
  deleteElementAt(x, y) {
    // Check if clicking on a ball first
    const ballIndex = this.balls.findIndex(b => {
      const dx = b.x - x;
      const dy = b.y - y;
      return Math.sqrt(dx * dx + dy * dy) < 15;
    });
    
    if (ballIndex !== -1) {
      this.balls.splice(ballIndex, 1);
      this.drawAll();
      return;
    }
    
    // Check if clicking on a player
    const allPlayers = this.getAllPlayers();
    const playerIndex = allPlayers.findIndex(p => {
      const dx = p.x - x;
      const dy = p.y - y;
      return Math.sqrt(dx * dx + dy * dy) < 20;
    });
    
    if (playerIndex !== -1) {
      const player = allPlayers[playerIndex];
      if (player.team === 'home') {
        const idx = this.homePlayers.indexOf(player);
        if (idx !== -1) this.homePlayers.splice(idx, 1);
      } else {
        const idx = this.opponentPlayers.indexOf(player);
        if (idx !== -1) this.opponentPlayers.splice(idx, 1);
      }
      this.updatePlayerList();
      this.drawAll();
      return;
    }
    
    // Check if clicking on an arrow
    const arrowIndex = this.findArrowAt(x, y);
    if (arrowIndex !== -1) {
      this.arrows.splice(arrowIndex, 1);
      this.drawAll();
    }
  }
  
  findArrowAt(x, y, threshold = 10) {
    // Find the closest arrow to the click point within threshold
    let closest = -1;
    let minDistance = threshold;
    
    this.arrows.forEach((arrow, index) => {
      const distance = this.distanceToLine(x, y, arrow.startX, arrow.startY, arrow.endX, arrow.endY);
      if (distance < minDistance) {
        minDistance = distance;
        closest = index;
      }
    });
    
    return closest;
  }
  
  distanceToLine(px, py, x1, y1, x2, y2) {
    // Calculate distance from point (px, py) to line segment from (x1, y1) to (x2, y2)
    const dx = x2 - x1;
    const dy = y2 - y1;
    const lengthSquared = dx * dx + dy * dy;
    
    if (lengthSquared === 0) {
      // Line segment is a point
      return Math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
    }
    
    // Calculate t (parameter along line segment)
    let t = ((px - x1) * dx + (py - y1) * dy) / lengthSquared;
    t = Math.max(0, Math.min(1, t));
    
    // Find closest point on line segment
    const closestX = x1 + t * dx;
    const closestY = y1 + t * dy;
    
    // Return distance to closest point
    return Math.sqrt((px - closestX) * (px - closestX) + (py - closestY) * (py - closestY));
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
    
    
    if (availableWidth / availableHeight > aspectRatio) {
      // Height constrained
      this.fieldHeight = availableHeight;
      this.fieldWidth = this.fieldHeight * aspectRatio;
    } else {
      // Width constrained
      this.fieldWidth = availableWidth;
      this.fieldHeight = this.fieldWidth / aspectRatio;
    }
    const fieldWidth = this.fieldWidth;
    const fieldHeight = this.fieldHeight;
    const offsetX = (w - this.fieldWidth) / 2;
    const offsetY = (h - this.fieldHeight) / 2;
    
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
    const size = 10;
    allPlayers.forEach(player => {
      // Draw player circle
      ctx.fillStyle = player.color;
      ctx.beginPath();
      ctx.arc(player.x, player.y, size, 0, Math.PI * 2);
      ctx.fill();
      
      // Always draw a border for visibility (especially for white players)
      ctx.strokeStyle = this.selectedPlayer === player ? 'yellow' : '#333';
      ctx.lineWidth = this.selectedPlayer === player ? 3 : 2;
      ctx.beginPath();
      ctx.arc(player.x, player.y, size, 0, Math.PI * 2);
      ctx.stroke();
      
      // Draw jersey number (black for white players, white for others)
      ctx.fillStyle = player.color === '#FFFFFF' ? '#000000' : '#FFFFFF';
      ctx.font = 'bold 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(player.jerseyNumber, player.x, player.y);
      
      // Draw name below (with background for visibility)
      if (player.name) {
        ctx.font = '11px sans-serif';
        const textWidth = ctx.measureText(player.name).width;
        ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
        ctx.fillRect(player.x - textWidth/2 - 2, player.y + 22, textWidth + 4, 14);
        ctx.fillStyle = 'white';
        ctx.fillText(player.name, player.x, player.y + 29);
      }
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
  
  drawBalls() {
    const ctx = this.ctx;
    
    // Draw all balls
    this.balls.forEach(ball => {
      ctx.fillStyle = '#FFD700';
      ctx.beginPath();
      ctx.arc(ball.x, ball.y, 6, 0, Math.PI * 2);
      ctx.fill();
      
      // Add black pattern lines for soccer ball look
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.arc(ball.x, ball.y, 6, 0, Math.PI * 2);
      ctx.stroke();
      
      // Draw pentagon pattern
      for (let i = 0; i < 5; i++) {
        const angle = (i * Math.PI * 2) / 5;
        const x1 = ball.x + Math.cos(angle) * 4;
        const y1 = ball.y + Math.sin(angle) * 4;
        const angle2 = ((i + 2) * Math.PI * 2) / 5;
        const x2 = ball.x + Math.cos(angle2) * 4;
        const y2 = ball.y + Math.sin(angle2) * 4;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
      }
    });
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
    this.drawBalls();
    this.drawPlayers();
  }
  
  handleMouseDown(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    if (this.mode === 'move') {
      // Check if clicking on a ball first
      this.selectedBall = this.balls.find(b => {
        const dx = b.x - x;
        const dy = b.y - y;
        return Math.sqrt(dx * dx + dy * dy) < 15;
      });
      
      if (this.selectedBall) {
        this.isDragging = true;
        this.selectedPlayer = null;
        const detailsPanel = document.getElementById('player-details');
        if (detailsPanel) detailsPanel.style.display = 'none';
        return;
      }
      
      // Check if clicking on a player from all players
      const allPlayers = this.getAllPlayers();
      this.selectedPlayer = allPlayers.find(p => {
        const dx = p.x - x;
        const dy = p.y - y;
        return Math.sqrt(dx * dx + dy * dy) < 20;
      });
      
      if (this.selectedPlayer) {
        this.isDragging = true;
        this.selectedBall = null;
        this.populatePlayerDetails(this.selectedPlayer);
      } else {
        this.selectedBall = null;
        const detailsPanel = document.getElementById('player-details');
        if (detailsPanel) detailsPanel.style.display = 'none';
      }
    } else if (this.mode === 'draw') {
      // Start drawing arrow
      this.drawingArrow = {
        startX: x,
        startY: y,
        currentX: x,
        currentY: y
      };
    } else if (this.mode === 'ball') {
      // Place ball at click location
      this.balls.push({
        x: x,
        y: y
      });
      this.drawAll();
    } else if (this.mode === 'draw-player') {
      // Place player at click location
      const color = this.activeTeam === 'home' ? '#0066CC' : '#FFFFFF';
      const players = this.getActivePlayers();
      const jerseyNumber = players.length + 1;
      
      players.push({
        id: Date.now(),
        name: '',
        jerseyNumber: jerseyNumber,
        x: x,
        y: y,
        color: color,
        team: this.activeTeam
      });
      
      this.updatePlayerList();
      this.drawAll();
    } else if (this.mode === 'delete') {
      // Delete ball, player, or arrow at click location
      this.deleteElementAt(x, y);
    }
  }
  
  handleMouseMove(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    if (this.mode === 'move' && this.isDragging) {
      if (this.selectedBall) {
        this.selectedBall.x = x;
        this.selectedBall.y = y;
        this.drawAll();
      } else if (this.selectedPlayer) {
        this.selectedPlayer.x = x;
        this.selectedPlayer.y = y;
        this.drawAll();
      }
    } else if (this.mode === 'draw' && this.drawingArrow) {
      this.drawingArrow.currentX = x;
      this.drawingArrow.currentY = y;
      this.drawAll();
    }
  }
  
  handleMouseUp(e) {
    if (this.mode === 'move') {
      this.isDragging = false;
      this.selectedBall = null;
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
  
  handleCanvasDoubleClick(e) {
    // Close any existing edit inputs
    this.closePlayerEdit();
    
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    // Find if double-clicking on a player
    const allPlayers = this.getAllPlayers();
    const player = allPlayers.find(p => {
      const dx = p.x - x;
      const dy = p.y - y;
      return Math.sqrt(dx * dx + dy * dy) < 20;
    });
    
    if (player) {
      this.openPlayerEdit(player, e);
    }
  }
  
  openPlayerEdit(player, event) {
    this.editingPlayer = player;
    const rect = this.canvas.getBoundingClientRect();
    
    // Create container for inputs
    const container = document.createElement('div');
    container.style.cssText = `
      position: fixed;
      left: ${rect.left + player.x - 50}px;
      top: ${rect.top + player.y - 50}px;
      display: flex;
      gap: 8px;
      z-index: 1000;
      background: white;
      padding: 8px;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    `;
    
    // Name input
    const nameInput = document.createElement('input');
    nameInput.type = 'text';
    nameInput.value = player.name || '';
    nameInput.placeholder = 'Name';
    nameInput.style.cssText = `
      width: 80px;
      padding: 4px;
      border: 1px solid #ccc;
      border-radius: 3px;
      font-size: 12px;
    `;
    
    // Number input
    const numberInput = document.createElement('input');
    numberInput.type = 'number';
    numberInput.value = player.jerseyNumber || '';
    numberInput.placeholder = '#';
    numberInput.style.cssText = `
      width: 40px;
      padding: 4px;
      border: 1px solid #ccc;
      border-radius: 3px;
      font-size: 12px;
    `;
    
    container.appendChild(nameInput);
    container.appendChild(numberInput);
    document.body.appendChild(container);
    
    // Focus on name input
    nameInput.focus();
    nameInput.select();
    
    // Save and close helpers
    const saveAndClose = () => {
      player.name = nameInput.value || player.name;
      player.jerseyNumber = parseInt(numberInput.value) || player.jerseyNumber;
      this.closePlayerEdit();
      this.drawAll();
    };
    
    // Enter to save
    const handleKeyDown = (e) => {
      if (e.key === 'Enter') {
        saveAndClose();
      } else if (e.key === 'Escape') {
        this.closePlayerEdit();
      }
    };
    
    nameInput.addEventListener('keydown', handleKeyDown);
    numberInput.addEventListener('keydown', handleKeyDown);
    
    // Use focusout on the container instead of blur on individual inputs
    // This way switching between inputs won't trigger save/close
    container.addEventListener('focusout', () => {
      // Use setTimeout to allow focus to move to the other input first
      setTimeout(() => {
        if (document.activeElement !== nameInput && document.activeElement !== numberInput) {
          saveAndClose();
        }
      }, 50);
    });
    
    this.editInputs = {
      container,
      nameInput,
      numberInput,
      cleanup: () => {
        nameInput.removeEventListener('keydown', handleKeyDown);
        numberInput.removeEventListener('keydown', handleKeyDown);
      }
    };
  }
  
  closePlayerEdit() {
    if (this.editInputs) {
      this.editInputs.cleanup();
      document.body.removeChild(this.editInputs.container);
      this.editInputs = null;
    }
    this.editingPlayer = null;
  }
  
  applyFormation(formation) {
    console.log('Applying formation:', formation);
    const w = this.canvas.width;
    const h = this.canvas.height;
    const margin = {x:(w - this.fieldWidth) / 2,  y:(h - this.fieldHeight) / 2};
    let positions = [];
    
    if (formation === '4-4-2') {
      positions = [
        // GK
        { x: 0, y: 0.5},
        // Defense
        { x:  0.2, y: 0.25 },
        { x: 0.2, y: 0.42 },
        { x:  0.2, y: 0.58 },
        { x: 0.2, y:  0.75 },
        // Midfield
        { x: 0.48, y: 0.25 },
        { x: 0.48, y:  0.42 },
        { x: 0.48, y: 0.58 },
        { x: 0.48, y: 0.75 },
        // Attack
        { x: 0.75, y: 0.4 },
        { x: 0.75, y: 0.6 }
      ];
    } else if (formation === '4-3-3') {
      positions = [
        // GK
        { x: 0, y: 0.5},
        // Defense
        { x: 0.2, y:  0.25 },
        { x: 0.2, y:0.42 },
        { x: 0.2, y: 0.58 },
        { x: 0.2, y:  0.75 },
        // Midfield
        { x:  0.48, y:  0.33 },
        { x: 0.48, y: 0.5 },
        { x: 0.48, y:  0.67 },
        // Attack
        { x: 0.75, y: 0.25 },
        { x: 0.75, y: 0.5 },
        { x: 0.75, y: 0.75 }
      ];
    } else if (formation === '3-5-2') {
      positions = [
        // GK
        { x: 0, y: 0.5 },
        // Defense
        { x: 0.2, y: 0.33 },
        { x: 0.2, y: 0.5 },
        { x: 0.2, y: 0.67 },
        // Midfield
        { x: 0.48, y: 0.2 },
        { x: 0.48, y: 0.35 },
        { x: 0.48, y: 0.5 },
        { x: 0.48, y: 0.65 },
        { x: 0.48, y: 0.8 },
        // Attack
        { x: 0.75, y: 0.4 },
        { x: 0.75, y: 0.6 }
      ];
    }
    if (this.activeTeam === 'opponent') {
      for (let pos of positions) {
        pos.x = 1 - pos.x;
        pos.y = 1 - pos.y;
      }
    }
    for (let pos of positions) {
        pos.x = margin.x + pos.x * this.fieldWidth;
        pos.y = margin.y + pos.y * this.fieldHeight;
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
      
      // Prepare players array
      const allPlayers = [
        ...this.homePlayers.map(p => ({ ...p, team: 'home', id: p.playerId })),
        ...this.opponentPlayers.map(p => ({ ...p, team: 'opponent', id: p.playerId }))
      ];

      // Determine board type
      let boardTypeId = 2; // Default to practice
      if (this.matchId) boardTypeId = 1; // Match
      else if (this.practiceId) boardTypeId = 2; // Practice
      else if (this.clubId && !this.teamId) boardTypeId = 3; // Club-wide
      
      // Prepare board data with players and arrows embedded
      const boardData = {
        name: boardName,
        description: description || '',
        boardTypeId: boardTypeId,
        formationHome: this.getFormationString('home') || '',
        formationOpponent: this.getFormationString('opponent') || '',
        canvasWidth: Math.floor(this.canvas.width),
        canvasHeight: Math.floor(this.canvas.height),
        isPublic: false,
        isTemplate: false,
        players: allPlayers,
        arrows: this.arrows,
        teamId: this.teamId,
        matchId: this.matchId,
        practiceId: this.practiceId,
        clubId: this.clubId
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
      
      alert(`Board "${boardName}" saved successfully!\n\nBoard ID: ${boardId}`);
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
          jerseyNumber: player.jerseyNumber,
          name: player.name || '',
          color: player.color,
          playerId: player.playerId
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
      this.drawAll();
      
      alert(`Board "${board.name}" loaded successfully!`);
      
    } catch (error) {
      console.error('Error loading board:', error);
      alert(`Failed to load board: ${error.message}`);
    }
  }
  
  async loadBoardsList() {
    try {
      // 1. Load context-specific boards
      let endpoint = '';
      if (this.matchId) {
        endpoint = `/api/tactical-boards/match/${this.matchId}`;
      } else if (this.practiceId) {
        endpoint = `/api/tactical-boards/practice/${this.practiceId}`;
      } else if (this.teamId) {
        endpoint = `/api/tactical-boards/team/${this.teamId}`;
      } else if (this.clubId) {
        endpoint = `/api/tactical-boards/club/${this.clubId}`;
      }
      
      const contextResponse = await fetch(`http://localhost:3001${endpoint}`, {
        headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
      });
      const contextBoards = contextResponse.ok ? await contextResponse.json() : [];
      
      // 2. Load all club boards (for the "Other Boards" list)
      // We only do this if we have a clubId available
      let clubBoards = [];
      if (this.clubId) {
        const clubResponse = await fetch(`http://localhost:3001/api/tactical-boards/club/${this.clubId}`, {
          headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
        });
        if (clubResponse.ok) {
          clubBoards = await clubResponse.json();
        }
      }
      
      // Filter out duplicates (boards that are already in contextBoards)
      const contextBoardIds = new Set(contextBoards.map(b => b.id));
      const otherBoards = clubBoards.filter(b => !contextBoardIds.has(b.id));
      
      return { contextBoards, otherBoards };
      
    } catch (error) {
      console.error('Error loading boards list:', error);
      return { contextBoards: [], otherBoards: [] };
    }
  }
  
  async showLoadBoardDialog(mode = 'both') {
    try {
      const { contextBoards, otherBoards } = await this.loadBoardsList();
      
      if (contextBoards.length === 0 && otherBoards.length === 0) {
        alert('No saved boards found.');
        return;
      }

      // Filter based on mode
      const displayContextBoards = (mode === 'both' || mode === 'linked') ? contextBoards : [];
      const displayOtherBoards = (mode === 'both' || mode === 'all') ? otherBoards : [];
      
      if (mode === 'linked' && displayContextBoards.length === 0) {
        alert('No boards linked specifically to this context.');
        return;
      }
      
      // Create a custom modal for better UX than prompt()
      const modal = document.createElement('div');
      modal.style.cssText = `
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center;
        z-index: 1000;
      `;
      
      const content = document.createElement('div');
      content.style.cssText = `
        background: white; padding: 20px; border-radius: 8px; width: 500px; max-height: 80vh; overflow-y: auto;
      `;
      
      content.innerHTML = `
        <h2 style="margin-top: 0;">Load Tactical Board</h2>
        
        ${displayContextBoards.length > 0 ? `
          <h3 style="font-size: 1rem; color: var(--primary-color); border-bottom: 1px solid #eee; padding-bottom: 5px;">
            Linked to this Context
          </h3>
          <div class="board-list" style="margin-bottom: 20px;">
            ${displayContextBoards.map(b => `
              <div class="board-item" data-id="${b.id}" style="padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <div style="font-weight: bold;">${b.name}</div>
                  <div style="font-size: 0.8rem; color: #666;">${new Date(b.createdAt).toLocaleDateString()}</div>
                </div>
                <button class="btn btn-sm btn-primary">Load</button>
              </div>
            `).join('')}
          </div>
        ` : (mode === 'linked' ? '<p>No linked boards found.</p>' : '')}
        
        ${displayOtherBoards.length > 0 ? `
          <h3 style="font-size: 1rem; color: var(--gray-600); border-bottom: 1px solid #eee; padding-bottom: 5px; margin-top: 20px;">
            ${mode === 'all' ? 'All Club Boards' : 'Other Club Boards'}
          </h3>
          <div class="board-list">
            ${displayOtherBoards.map(b => `
              <div class="board-item" data-id="${b.id}" style="padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <div style="font-weight: bold;">${b.name}</div>
                  <div style="font-size: 0.8rem; color: #666;">
                    ${new Date(b.createdAt).toLocaleDateString()} • 
                    ${b.matchId ? 'Match' : b.practiceId ? 'Practice' : b.teamId ? 'Team' : 'Club'}
                  </div>
                </div>
                <button class="btn btn-sm btn-secondary">Load</button>
              </div>
            `).join('')}
          </div>
        ` : ''}
        
        <div style="margin-top: 20px; text-align: right;">
          <button id="close-modal-btn" class="btn btn-secondary">Cancel</button>
        </div>
      `;
      
      modal.appendChild(content);
      document.body.appendChild(modal);
      
      // Event listeners
      modal.addEventListener('click', (e) => {
        const boardItem = e.target.closest('.board-item');
        if (boardItem) {
          const boardId = boardItem.dataset.id;
          this.loadTacticalBoard(boardId);
          document.body.removeChild(modal);
        }
        
        if (e.target.id === 'close-modal-btn' || e.target === modal) {
          document.body.removeChild(modal);
        }
      });
      
    } catch (error) {
      console.error('Error showing load dialog:', error);
      alert('Failed to load boards list');
    }
  }

  showStartupMenu() {
    const modal = document.createElement('div');
    modal.className = 'tactical-board-startup-modal';
    modal.style.cssText = `
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.8); display: flex; justify-content: center; align-items: center;
      z-index: 2000;
    `;
    
    const content = document.createElement('div');
    content.style.cssText = `
      background: white; padding: 30px; border-radius: 12px; width: 400px; text-align: center;
      box-shadow: 0 4px 20px rgba(0,0,0,0.3);
    `;
    
    let contextName = 'Club Level';
    if (this.matchId) contextName = 'Match';
    else if (this.practiceId) contextName = 'Practice';
    else if (this.teamId) contextName = 'Team';
    
    content.innerHTML = `
      <h2 style="margin-top: 0; margin-bottom: 20px;">Tactical Board</h2>
      <p style="color: #666; margin-bottom: 30px;">${contextName} Context</p>
      
      <div style="display: flex; flex-direction: column; gap: 15px;">
        <button id="startup-create" class="btn btn-primary btn-lg" style="width: 100%;">
          ✨ Create New Board
        </button>
        
        <button id="startup-load-linked" class="btn btn-secondary btn-lg" style="width: 100%;">
          📂 Load from ${contextName}
        </button>
        
        <button id="startup-load-all" class="btn btn-outline-secondary" style="width: 100%;">
          🌐 Load from All Contexts
        </button>
      </div>
    `;
    
    modal.appendChild(content);
    document.body.appendChild(modal);
    
    // Event listeners
    content.querySelector('#startup-create').addEventListener('click', () => {
      document.body.removeChild(modal);
    });
    
    content.querySelector('#startup-load-linked').addEventListener('click', () => {
      document.body.removeChild(modal);
      this.showLoadBoardDialog('linked');
    });
    
    content.querySelector('#startup-load-all').addEventListener('click', () => {
      document.body.removeChild(modal);
      this.showLoadBoardDialog('all');
    });
  }

  showLinkDialog() {
    alert('Link to Context feature coming soon!');
  }
  
  async fetchTeamRoster() {
    try {
      if (!this.teamId) return;
      
      const response = await fetch(`http://localhost:3001/api/teams/${this.teamId}/roster`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (!response.ok) {
        throw new Error('Failed to load roster');
      }
      
      const result = await response.json();
      const roster = result.data || [];
      const select = document.getElementById('roster-select');
      if (!select) return;
      
      select.innerHTML = '<option value="">-- Select Player --</option>';
      
      roster.forEach(player => {
        const option = document.createElement('option');
        option.value = player.id;
        option.textContent = `#${player.jerseyNumber || '?'} ${player.firstName} ${player.lastName}`;
        select.appendChild(option);
      });
      
    } catch (error) {
      console.error('Error loading roster:', error);
    }
  }

  updateSelectedPlayer() {
    if (!this.selectedPlayer) return;
    
    const nameInput = document.getElementById('player-name');
    const numberInput = document.getElementById('player-number');
    const colorInput = document.getElementById('player-color');
    const rosterSelect = document.getElementById('roster-select');
    
    if (nameInput) this.selectedPlayer.name = nameInput.value;
    if (numberInput) this.selectedPlayer.jerseyNumber = numberInput.value;
    if (colorInput) this.selectedPlayer.color = colorInput.value;
    
    if (rosterSelect && rosterSelect.value) {
      this.selectedPlayer.playerId = rosterSelect.value;
      // Also update name/number from roster if selected
      const selectedOption = rosterSelect.options[rosterSelect.selectedIndex];
      if (selectedOption) {
        // Parse name/number from option text "#10 John Doe"
        const text = selectedOption.textContent;
        const match = text.match(/#(\S+)\s+(.+)/);
        if (match) {
          this.selectedPlayer.jerseyNumber = match[1];
          this.selectedPlayer.name = match[2];
          
          // Update inputs to match
          if (nameInput) nameInput.value = this.selectedPlayer.name;
          if (numberInput) numberInput.value = this.selectedPlayer.jerseyNumber;
        }
      }
    } else {
      this.selectedPlayer.playerId = null;
    }
    
    this.drawAll();
  }

  populatePlayerDetails(player) {
    const detailsPanel = document.getElementById('player-details');
    if (!detailsPanel) return;
    
    detailsPanel.style.display = 'block';
    
    const nameInput = document.getElementById('player-name');
    const numberInput = document.getElementById('player-number');
    const colorInput = document.getElementById('player-color');
    const rosterSelect = document.getElementById('roster-select');
    
    if (nameInput) nameInput.value = player.name || '';
    if (numberInput) numberInput.value = player.jerseyNumber || '';
    if (colorInput) colorInput.value = player.color || '#ffffff';
    if (rosterSelect) rosterSelect.value = player.playerId || '';
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
