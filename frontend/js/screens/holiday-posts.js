// HolidayPostsScreen - Pre-built holiday posts with Lighthouse branding for Instagram
class HolidayPostsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.dbPosts = {};       // keyed by "name|date"
    this.generatedImages = {}; // keyed by index
  }

  // All holidays for the year, sorted by date
  getHolidays() {
    const year = new Date().getFullYear();
    const holidays = [
      { name: 'New Year',           date: `${year}-01-01`,   emoji: '🎆', greeting: "Happy New Year!",              caption: `🎆 Happy New Year from Lighthouse 1893 Soccer Club! Wishing everyone a fantastic ${year} season ahead! ⚽🎉\n\n#Lighthouse1893 #HappyNewYear #PhillySoccer #NewYear${year}` },
      { name: "Valentine's Day",    date: `${year}-02-14`,   emoji: '❤️', greeting: "Happy Valentine's Day!",        caption: "❤️ Happy Valentine's Day from Lighthouse 1893! We love the beautiful game ⚽💙\n\n#Lighthouse1893 #ValentinesDay #PhillySoccer #LoveTheGame" },
      { name: "St. Patrick's Day",  date: `${year}-03-17`,   emoji: '☘️', greeting: "Happy St. Patrick's Day!",      caption: "☘️ Happy St. Patrick's Day from Lighthouse 1893 Soccer Club! ⚽🍀\n\n#Lighthouse1893 #StPatricksDay #PhillySoccer" },
      { name: 'Easter',             date: `${year}-04-20`,   emoji: '🐣', greeting: "Happy Easter!",                 caption: "🐣 Happy Easter from Lighthouse 1893 Soccer Club! Wishing everyone a wonderful day! ⚽🌷\n\n#Lighthouse1893 #HappyEaster #PhillySoccer #Easter2026" },
      { name: 'Memorial Day',       date: `${year}-05-25`,   emoji: '🇺🇸', greeting: "Happy Memorial Day!",          caption: "🇺🇸 Honoring those who served. Happy Memorial Day from Lighthouse 1893 Soccer Club ⚽\n\n#Lighthouse1893 #MemorialDay #PhillySoccer" },
      { name: 'Independence Day',   date: `${year}-07-04`,   emoji: '🎇', greeting: "Happy 4th of July!",            caption: "🎇 Happy Independence Day from Lighthouse 1893 Soccer Club! ⚽🇺🇸\n\n#Lighthouse1893 #4thOfJuly #PhillySoccer #IndependenceDay" },
      { name: 'Labor Day',          date: `${year}-09-07`,   emoji: '💪', greeting: "Happy Labor Day!",              caption: "💪 Happy Labor Day from Lighthouse 1893! Enjoy the day off — back on the pitch soon! ⚽\n\n#Lighthouse1893 #LaborDay #PhillySoccer" },
      { name: 'Halloween',          date: `${year}-10-31`,   emoji: '🎃', greeting: "Happy Halloween!",              caption: "🎃 Happy Halloween from Lighthouse 1893 Soccer Club! ⚽👻\n\n#Lighthouse1893 #Halloween #PhillySoccer #SpookySeason" },
      { name: 'Thanksgiving',       date: `${year}-11-27`,   emoji: '🦃', greeting: "Happy Thanksgiving!",           caption: "🦃 Happy Thanksgiving from Lighthouse 1893! Grateful for our team, supporters, and the beautiful game ⚽\n\n#Lighthouse1893 #Thanksgiving #PhillySoccer #Grateful" },
      { name: 'Christmas',          date: `${year}-12-25`,   emoji: '🎄', greeting: "Merry Christmas!",              caption: "🎄 Merry Christmas from Lighthouse 1893 Soccer Club! Wishing everyone joy and peace ⚽🎅\n\n#Lighthouse1893 #MerryChristmas #PhillySoccer #HappyHolidays" },
    ];

    // Sort so next upcoming holiday is first
    const today = new Date().toISOString().slice(0, 10);
    const upcoming = holidays.filter(h => h.date >= today);
    const past = holidays.filter(h => h.date < today);
    return [...upcoming, ...past];
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-holiday-posts';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎉 Holiday Posts</h1>
        <p class="subtitle">Lighthouse 1893 Instagram holiday posts</p>
      </div>
      <div id="holiday-list" style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div class="loading-state"><div class="spinner"></div><p>Loading...</p></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const publishBtn = e.target.closest('.publish-btn');
      if (publishBtn) {
        const idx = parseInt(publishBtn.dataset.idx);
        this.publishHoliday(idx);
        return;
      }
    });

    this.loadAndRender();
  }

  async loadAndRender() {
    // Fetch any already-saved posts from DB to show their status
    try {
      const response = await this.auth.fetch('/api/social/holidays');
      if (response.ok) {
        const result = await response.json();
        if (result.success && result.data) {
          this.dbPosts = {};
          result.data.forEach(p => {
            this.dbPosts[p.holiday_name + '|' + p.holiday_date] = p;
          });
        }
      }
    } catch (e) { /* ignore, just show holidays without DB status */ }

    this.renderHolidays();
  }

  renderHolidays() {
    const list = this.find('#holiday-list');
    const holidays = this.getHolidays();
    const today = new Date().toISOString().slice(0, 10);

    list.innerHTML = holidays.map((h, i) => {
      const dbPost = this.dbPosts[h.name + '|' + h.date];
      const isPosted = dbPost && dbPost.status === 'posted';
      const isError = dbPost && dbPost.status === 'error';
      const isPast = h.date < today;

      const dateObj = new Date(h.date + 'T00:00:00');
      const dateStr = dateObj.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
      const daysAway = Math.ceil((dateObj - new Date(today + 'T00:00:00')) / 86400000);
      const timeLabel = daysAway === 0 ? '🔴 TODAY' : daysAway > 0 ? `${daysAway} days away` : `${Math.abs(daysAway)} days ago`;

      let statusBadge = '';
      if (isPosted) {
        statusBadge = `<span style="background:#4CAF50;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">✅ POSTED</span>`;
      } else if (isError) {
        statusBadge = `<span style="background:#f44336;color:white;padding:2px 10px;border-radius:12px;font-size:0.8rem;">⚠️ ERROR</span>`;
      }

      return `
        <div class="card" style="padding: var(--space-3); margin-bottom: var(--space-3); ${isPast && !isPosted ? 'opacity: 0.5;' : ''}">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div>
              <span style="font-size: 1.5rem; margin-right: 8px;">${h.emoji}</span>
              <strong style="font-size: 1.1rem;">${h.greeting}</strong>
              <span style="opacity: 0.6; margin-left: 8px; font-size: 0.9rem;">${dateStr}</span>
              <span style="opacity: 0.5; margin-left: 8px; font-size: 0.8rem;">${timeLabel}</span>
            </div>
            ${statusBadge}
          </div>

          <!-- Preview image -->
          <div id="preview-${i}" style="text-align: center; margin-bottom: 12px;">
            <img id="img-${i}" style="max-width: 100%; height: auto; border-radius: 8px; border: 2px solid var(--border-color);">
          </div>

          <!-- Caption preview -->
          <details style="margin-bottom: 12px;">
            <summary style="cursor: pointer; font-weight: 600; opacity: 0.8;">📝 Caption</summary>
            <p style="white-space: pre-wrap; opacity: 0.85; margin-top: 8px; padding: 12px; background: var(--bg-secondary); border-radius: 8px; font-size: 0.9rem;">${h.caption}</p>
          </details>

          ${isError && dbPost.error_message ? `<div style="color: #f44336; font-size: 0.85rem; margin-bottom: 8px;">⚠️ ${dbPost.error_message}</div>` : ''}

          <div style="display: flex; gap: 8px; align-items: center;">
            ${isPosted
              ? `<span style="color: #4CAF50; font-weight: 600;">✅ Published${dbPost.posted_at ? ' ' + new Date(dbPost.posted_at).toLocaleDateString() : ''}</span>`
              : `<button class="btn btn-primary publish-btn" data-idx="${i}" style="padding: 10px 20px;">🚀 Post to Instagram</button>`
            }
          </div>
        </div>
      `;
    }).join('');

    // Generate images
    holidays.forEach((h, i) => this.drawHolidayCard(i, h));
  }

  drawHolidayCard(index, holiday) {
    const scale = 2;
    const canvas = document.createElement('canvas');
    canvas.width = 1080 * scale;
    canvas.height = 1080 * scale;
    const ctx = canvas.getContext('2d');
    ctx.scale(scale, scale);
    const w = 1080, h = 1080;

    // Background gradient
    const grad = ctx.createLinearGradient(0, 0, w * 0.6, h);
    grad.addColorStop(0, '#0033a0');
    grad.addColorStop(0.3, '#003fbf');
    grad.addColorStop(0.55, '#0044cc');
    grad.addColorStop(1, '#002080');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);

    // Gold border
    ctx.strokeStyle = '#f5d442';
    ctx.lineWidth = 8;
    ctx.strokeRect(4, 4, w - 8, h - 8);

    // Holiday emoji (large, centered)
    ctx.font = '500px serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(holiday.emoji, w / 2, 420);
    ctx.textBaseline = 'alphabetic';

    // Greeting text
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 72px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    this.wrapText(ctx, holiday.greeting, w / 2, 750, w - 120, 80);

    // "from" text
    ctx.fillStyle = '#ffffff';
    ctx.font = '32px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('from', w / 2, h - 110);

    // Club name
    ctx.fillStyle = '#f5d442';
    ctx.font = 'bold 28px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('LIGHTHOUSE 1893 ⚽ CLUB', w / 2, h - 60);

    // Convert to static image
    const dataUrl = canvas.toDataURL('image/png');
    this.imageDataUrls = this.imageDataUrls || {};
    this.imageDataUrls[index] = dataUrl;
    const img = this.find(`#img-${index}`);
    if (img) img.src = dataUrl;
  }

  drawEasterEgg(ctx, cx, cy) {
    ctx.save();

    // --- Bottom half of soccer-ball egg (cracked) ---
    const eggW = 160, eggH = 200;

    // Egg bottom half - white with soccer pentagon pattern
    ctx.beginPath();
    ctx.ellipse(cx, cy + 40, eggW, eggH, 0, 0.1, Math.PI);
    ctx.closePath();
    ctx.fillStyle = '#ffffff';
    ctx.fill();
    ctx.strokeStyle = '#333333';
    ctx.lineWidth = 3;
    ctx.stroke();

    // Soccer ball pentagons on egg bottom
    const pentagons = [
      { x: cx - 60, y: cy + 100, r: 28 },
      { x: cx + 50, y: cy + 80, r: 24 },
      { x: cx - 10, y: cy + 160, r: 26 },
      { x: cx + 80, y: cy + 150, r: 20 },
      { x: cx - 80, y: cy + 160, r: 20 },
    ];
    pentagons.forEach(p => {
      ctx.beginPath();
      for (let i = 0; i < 5; i++) {
        const angle = (Math.PI * 2 / 5) * i - Math.PI / 2;
        const px = p.x + Math.cos(angle) * p.r;
        const py = p.y + Math.sin(angle) * p.r;
        i === 0 ? ctx.moveTo(px, py) : ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.fillStyle = '#222222';
      ctx.fill();
      ctx.strokeStyle = '#333333';
      ctx.lineWidth = 2;
      ctx.stroke();
    });

    // Soccer seam lines on egg
    ctx.strokeStyle = '#999999';
    ctx.lineWidth = 2;
    [[cx - 100, cy + 60, cx - 30, cy + 70], [cx + 30, cy + 60, cx + 100, cy + 80],
     [cx - 40, cy + 120, cx + 40, cy + 110], [cx - 70, cy + 180, cx + 60, cy + 190]].forEach(([x1, y1, x2, y2]) => {
      ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke();
    });

    // --- Cracked top edge (jagged line across the opening) ---
    ctx.beginPath();
    ctx.moveTo(cx - eggW + 10, cy + 40);
    const crackPoints = [
      cx - 120, cy + 10,  cx - 80, cy + 50,  cx - 50, cy + 5,
      cx - 20, cy + 45,   cx + 10, cy,        cx + 40, cy + 40,
      cx + 70, cy + 5,    cx + 100, cy + 50,  cx + 130, cy + 15,
      cx + eggW - 10, cy + 40
    ];
    for (let i = 0; i < crackPoints.length; i += 2) {
      ctx.lineTo(crackPoints[i], crackPoints[i + 1]);
    }
    ctx.strokeStyle = '#555555';
    ctx.lineWidth = 4;
    ctx.stroke();

    // --- Chick body (yellow, sitting in the egg) ---
    // Body
    ctx.beginPath();
    ctx.ellipse(cx, cy - 10, 90, 75, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#FFD700';
    ctx.fill();
    ctx.strokeStyle = '#DAA520';
    ctx.lineWidth = 3;
    ctx.stroke();

    // Head
    ctx.beginPath();
    ctx.arc(cx, cy - 110, 65, 0, Math.PI * 2);
    ctx.fillStyle = '#FFD700';
    ctx.fill();
    ctx.strokeStyle = '#DAA520';
    ctx.lineWidth = 3;
    ctx.stroke();

    // Eyes
    ctx.fillStyle = '#222222';
    ctx.beginPath();
    ctx.arc(cx - 22, cy - 120, 10, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(cx + 22, cy - 120, 10, 0, Math.PI * 2);
    ctx.fill();
    // Eye highlights
    ctx.fillStyle = '#ffffff';
    ctx.beginPath();
    ctx.arc(cx - 19, cy - 123, 4, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(cx + 25, cy - 123, 4, 0, Math.PI * 2);
    ctx.fill();

    // Beak (orange triangle)
    ctx.beginPath();
    ctx.moveTo(cx - 12, cy - 100);
    ctx.lineTo(cx + 12, cy - 100);
    ctx.lineTo(cx, cy - 82);
    ctx.closePath();
    ctx.fillStyle = '#FF6600';
    ctx.fill();

    // Little wings
    ctx.fillStyle = '#FFC200';
    // Left wing
    ctx.beginPath();
    ctx.ellipse(cx - 85, cy - 10, 35, 20, -0.3, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#DAA520';
    ctx.lineWidth = 2;
    ctx.stroke();
    // Right wing
    ctx.beginPath();
    ctx.ellipse(cx + 85, cy - 10, 35, 20, 0.3, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Tuft of feathers on head
    ctx.strokeStyle = '#DAA520';
    ctx.lineWidth = 3;
    ctx.beginPath(); ctx.moveTo(cx - 5, cy - 175); ctx.lineTo(cx - 15, cy - 210); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx, cy - 175); ctx.lineTo(cx, cy - 215); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx + 5, cy - 175); ctx.lineTo(cx + 15, cy - 210); ctx.stroke();

    ctx.restore();
  }

  wrapText(ctx, text, x, y, maxWidth, lineHeight) {
    const words = text.split(' ');
    let line = '';
    let ly = y;
    for (const word of words) {
      const test = line + word + ' ';
      if (ctx.measureText(test).width > maxWidth && line) {
        ctx.fillText(line.trim(), x, ly);
        line = word + ' ';
        ly += lineHeight;
      } else {
        line = test;
      }
    }
    ctx.fillText(line.trim(), x, ly);
  }

  async publishHoliday(index) {
    const holidays = this.getHolidays();
    const h = holidays[index];
    if (!confirm(`Post "${h.greeting}" to Instagram now?`)) return;

    const btn = this.element.querySelector(`.publish-btn[data-idx="${index}"]`);
    if (btn) { btn.disabled = true; btn.textContent = '⏳ Saving...'; }

    try {
      // 1. Save to DB
      const saveResp = await this.auth.fetch('/api/social/holidays', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ holiday_name: h.name, holiday_date: h.date, caption: h.caption })
      });
      if (!saveResp.ok) throw new Error(`Save HTTP ${saveResp.status}`);
      const saveResult = await saveResp.json();
      if (!saveResult.success) throw new Error(saveResult.message || 'Save failed');
      const postId = saveResult.data.id;

      if (btn) btn.textContent = '⏳ Uploading image...';

      // 2. Upload the generated image
      const dataUrl = (this.imageDataUrls && this.imageDataUrls[index]) || '';
      if (!dataUrl) throw new Error('Image not ready yet — please wait a moment and try again');
      const uploadResp = await this.auth.fetch(`/api/social/holidays/${postId}/media`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: dataUrl })
      });
      if (!uploadResp.ok) throw new Error(`Upload HTTP ${uploadResp.status}`);
      const uploadResult = await uploadResp.json();
      if (!uploadResult.success) throw new Error(uploadResult.message || 'Upload failed');

      if (btn) btn.textContent = '⏳ Publishing...';

      // 3. Publish to Instagram
      const pubResp = await this.auth.fetch(`/api/social/holidays/${postId}/publish`, {
        method: 'POST'
      });
      if (!pubResp.ok) throw new Error(`Publish HTTP ${pubResp.status}`);
      const pubResult = await pubResp.json();
      if (!pubResult.success) throw new Error(pubResult.message || 'Publish failed');

      alert('✅ Posted to Instagram!');
      await this.loadAndRender();
    } catch (error) {
      alert('Error: ' + error.message);
      await this.loadAndRender();
    }
  }
}
