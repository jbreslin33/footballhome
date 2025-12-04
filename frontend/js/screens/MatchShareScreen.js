// MatchShareScreen - Generate social media images for matches
class MatchShareScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-match-share';
    div.innerHTML = `
      <div class="screen-header">
        <button id="back-btn" class="btn btn-secondary">← Back</button>
        <h1>📸 Create Match Post</h1>
        <p class="subtitle">Generate an image for Instagram/Social Media</p>
      </div>
      
      <div class="share-container" style="padding: var(--space-4); max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: var(--space-6);">
        
        <!-- Controls -->
        <div class="share-controls card">
          <h3>Customize</h3>
          <div class="form-group">
            <label class="form-label">Theme Color</label>
            <div style="display: flex; gap: 10px;">
              <button class="color-btn" data-color="#111827" style="background: #111827; width: 30px; height: 30px; border-radius: 50%; border: 2px solid #ddd;"></button>
              <button class="color-btn" data-color="#2563eb" style="background: #2563eb; width: 30px; height: 30px; border-radius: 50%; border: none;"></button>
              <button class="color-btn" data-color="#dc2626" style="background: #dc2626; width: 30px; height: 30px; border-radius: 50%; border: none;"></button>
              <button class="color-btn" data-color="#16a34a" style="background: #16a34a; width: 30px; height: 30px; border-radius: 50%; border: none;"></button>
              <button class="color-btn" data-color="#d97706" style="background: #d97706; width: 30px; height: 30px; border-radius: 50%; border: none;"></button>
            </div>
          </div>
          <div class="form-group">
             <label class="form-label">Headline Text</label>
             <input type="text" id="headline-input" class="form-input" value="MATCH DAY">
          </div>
        </div>

        <!-- Preview Area (This is what gets captured) -->
        <div id="capture-area-wrapper" style="display: flex; justify-content: center; background: #f3f4f6; padding: 20px; border-radius: 8px; overflow: auto;">
            <div id="capture-area" class="instagram-post" style="width: 1080px; height: 1080px; background: #111827; color: white; position: relative; flex-shrink: 0; transform: scale(0.3); transform-origin: top center; margin-bottom: -700px;">
                
                <!-- Background Pattern/Texture -->
                <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; opacity: 0.1; background-image: radial-gradient(#ffffff 1px, transparent 1px); background-size: 20px 20px;"></div>
                
                <!-- Content -->
                <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 100px 60px 60px 60px;">
                    
                    <!-- Header -->
                    <h1 id="post-headline" style="font-size: 120px; font-weight: 900; letter-spacing: 10px; margin-bottom: 80px; text-transform: uppercase; text-shadow: 0 4px 10px rgba(0,0,0,0.5); line-height: 1;">MATCH DAY</h1>
                    
                    <!-- Logos Container -->
                    <div style="display: flex; align-items: center; justify-content: center; gap: 60px; margin-bottom: 100px; width: 100%;">
                        
                        <!-- Home Team -->
                        <div style="display: flex; flex-direction: column; align-items: center; width: 350px;">
                            <div id="home-logo-container" style="width: 280px; height: 280px; display: flex; align-items: center; justify-content: center; background: white; border-radius: 50%; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
                                <!-- Img injected here -->
                            </div>
                            <h2 id="home-name" style="font-size: 40px; margin-top: 30px; text-align: center; font-weight: 700;">Home Team</h2>
                        </div>

                        <!-- VS -->
                        <div style="font-size: 80px; font-weight: 900; color: rgba(255,255,255,0.5); font-style: italic;">VS</div>

                        <!-- Away Team -->
                        <div style="display: flex; flex-direction: column; align-items: center; width: 350px;">
                            <div id="away-logo-container" style="width: 280px; height: 280px; display: flex; align-items: center; justify-content: center; background: white; border-radius: 50%; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
                                <!-- Img injected here -->
                            </div>
                            <h2 id="away-name" style="font-size: 40px; margin-top: 30px; text-align: center; font-weight: 700;">Away Team</h2>
                        </div>

                    </div>

                    <!-- Details Box -->
                    <div style="background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); padding: 40px 80px; border-radius: 20px; border: 2px solid rgba(255,255,255,0.2); text-align: center; width: 80%;">
                        <div style="display: flex; align-items: center; justify-content: center; gap: 20px; margin-bottom: 20px;">
                            <span style="font-size: 50px;">📅</span>
                            <span id="post-date" style="font-size: 50px; font-weight: 600;">Date</span>
                        </div>
                        <div style="display: flex; align-items: center; justify-content: center; gap: 20px; margin-bottom: 20px;">
                            <span style="font-size: 50px;">🕐</span>
                            <span id="post-time" style="font-size: 50px; font-weight: 600;">Time</span>
                        </div>
                        <div style="display: flex; align-items: center; justify-content: center; gap: 20px;">
                            <span style="font-size: 50px;">📍</span>
                            <span id="post-venue" style="font-size: 40px; font-weight: 500;">Venue Name</span>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div style="margin-top: 80px; font-size: 30px; opacity: 0.7; letter-spacing: 2px;">
                        FOOTBALLHOME.ORG
                    </div>

                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 20px;">
            <button id="download-btn" class="btn btn-lg btn-success" style="width: 100%; max-width: 400px;">
                ⬇️ Download Image
            </button>
        </div>

      </div>
    `;
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    const match = this.navigation.context.match;
    if (!match) {
      console.error('No match provided for share screen');
      this.navigation.goBack();
      return;
    }

    this.renderMatchData(match);
    this.setupEventListeners();
  }

  renderMatchData(match) {
    // Date formatting
    const eventDate = new Date(match.event_date);
    const dateStr = eventDate.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
    const timeStr = eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    // Update DOM
    this.find('#post-date').textContent = dateStr;
    this.find('#post-time').textContent = timeStr;
    this.find('#post-venue').textContent = match.venue_name || 'TBD';
    
    // Teams
    // Note: We need to handle cases where team names might be in the title "Home vs Away"
    // But ideally we have home_team_name and away_team_name from the API join
    // For now, let's try to use specific fields if available, or parse title
    
    // Assuming the controller join gives us these, or we parse title
    let homeName = "Home Team";
    let awayName = "Away Team";
    
    if (match.title && match.title.includes(' vs ')) {
        const parts = match.title.split(' vs ');
        homeName = parts[0];
        awayName = parts[1];
    }

    this.find('#home-name').textContent = homeName;
    this.find('#away-name').textContent = awayName;

    // Logos
    const homeContainer = this.find('#home-logo-container');
    const awayContainer = this.find('#away-logo-container');

    if (match.home_team_logo) {
        homeContainer.innerHTML = `<img src="${match.home_team_logo}" style="width: 100%; height: 100%; object-fit: contain;">`;
    } else {
        homeContainer.innerHTML = `<span style="font-size: 100px;">🏠</span>`;
    }

    if (match.away_team_logo) {
        awayContainer.innerHTML = `<img src="${match.away_team_logo}" style="width: 100%; height: 100%; object-fit: contain;">`;
    } else {
        awayContainer.innerHTML = `<span style="font-size: 100px;">✈️</span>`;
    }
  }

  setupEventListeners() {
    // Back button
    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'back-btn' || e.target.closest('#back-btn')) {
        this.navigation.goBack();
      }
    });

    // Color pickers
    const captureArea = this.find('#capture-area');
    this.element.querySelectorAll('.color-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const color = btn.getAttribute('data-color');
            captureArea.style.background = color;
        });
    });

    // Headline input
    const headlineInput = this.find('#headline-input');
    const headlineText = this.find('#post-headline');
    headlineInput.addEventListener('input', (e) => {
        headlineText.textContent = e.target.value;
    });

    // Download button
    this.find('#download-btn').addEventListener('click', () => {
        this.downloadImage();
    });
  }

  async downloadImage() {
    const btn = this.find('#download-btn');
    const originalText = btn.innerHTML;
    btn.innerHTML = '⏳ Generating...';
    btn.disabled = true;

    try {
        if (typeof html2canvas === 'undefined') {
            throw new Error('html2canvas library not loaded');
        }

        const element = this.find('#capture-area');
        
        // We need to temporarily reset the transform to capture it correctly at full resolution
        const originalTransform = element.style.transform;
        const originalMargin = element.style.marginBottom;
        
        element.style.transform = 'none';
        element.style.marginBottom = '0';
        
        // Wait a tick for styles to apply
        await new Promise(resolve => setTimeout(resolve, 100));

        const canvas = await html2canvas(element, {
            scale: 1, // 1080x1080 is already set in CSS
            useCORS: true, // Important for loading images from other domains
            backgroundColor: null
        });

        // Restore styles
        element.style.transform = originalTransform;
        element.style.marginBottom = originalMargin;

        // Trigger download
        const link = document.createElement('a');
        link.download = `match-day-${Date.now()}.png`;
        link.href = canvas.toDataURL('image/png');
        link.click();

    } catch (err) {
        console.error('Screenshot failed:', err);
        alert('Failed to generate image. Please try again.');
    } finally {
        btn.innerHTML = originalText;
        btn.disabled = false;
    }
  }
}
