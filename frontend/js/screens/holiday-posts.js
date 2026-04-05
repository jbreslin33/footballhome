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

  // Elegant decorative elements for each holiday
  getHolidayDecor(name) {
    const decor = {
      'New Year':          { accent: '#f5d442', symbol: '✦', topLine: '— ✦ —' },
      "Valentine's Day":   { accent: '#e8485a', symbol: '♥', topLine: '— ♥ —' },
      "St. Patrick's Day": { accent: '#3cb371', symbol: '✦', topLine: '— ☘ —' },
      'Easter':            { accent: '#d4a843', symbol: '✦', topLine: '— ✦ —' },
      'Memorial Day':      { accent: '#ffffff', symbol: '★', topLine: '— ★ —' },
      'Independence Day':  { accent: '#e8485a', symbol: '★', topLine: '★  ★  ★' },
      'Labor Day':         { accent: '#f5d442', symbol: '✦', topLine: '— ✦ —' },
      'Halloween':         { accent: '#f5a623', symbol: '✦', topLine: '— ✦ —' },
      'Thanksgiving':      { accent: '#d4843a', symbol: '✦', topLine: '— ✦ —' },
      'Christmas':         { accent: '#cc2936', symbol: '★', topLine: '— ★ —' },
    };
    return decor[name] || { accent: '#f5d442', symbol: '✦', topLine: '— ✦ —' };
  }

  drawHolidayCard(index, holiday) {
    const scale = 2;
    const canvas = document.createElement('canvas');
    canvas.width = 1080 * scale;
    canvas.height = 1080 * scale;
    const ctx = canvas.getContext('2d');
    ctx.scale(scale, scale);
    const w = 1080, h = 1080;

    // Aged parchment background
    const parchGrad = ctx.createRadialGradient(w / 2, h / 2, 50, w / 2, h / 2, 700);
    parchGrad.addColorStop(0, '#f5e6c8');
    parchGrad.addColorStop(0.6, '#e8d5a8');
    parchGrad.addColorStop(1, '#d4be82');
    ctx.fillStyle = parchGrad;
    ctx.fillRect(0, 0, w, h);

    // Aged paper texture — seeded random for consistency
    const seed = index * 9973 + 42;
    const rng = (i) => { let x = Math.sin(seed + i) * 10000; return x - Math.floor(x); };
    for (let i = 0; i < 1200; i++) {
      const x = rng(i * 4) * w;
      const y = rng(i * 4 + 1) * h;
      const r = rng(i * 4 + 2) * 3 + 0.5;
      const alpha = rng(i * 4 + 3) * 0.07;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(120, 90, 40, ${alpha})`;
      ctx.fill();
    }

    // Faint horizontal paper grain lines
    for (let y = 0; y < h; y += 6) {
      const alpha = rng(y + 5000) * 0.025;
      ctx.strokeStyle = `rgba(100, 70, 30, ${alpha})`;
      ctx.lineWidth = 0.5;
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(w, y);
      ctx.stroke();
    }

    // Darkened edges (vignette) for aged look
    const vigGrad = ctx.createRadialGradient(w / 2, h / 2, 280, w / 2, h / 2, 760);
    vigGrad.addColorStop(0, 'rgba(0, 0, 0, 0)');
    vigGrad.addColorStop(0.7, 'rgba(80, 50, 20, 0.12)');
    vigGrad.addColorStop(1, 'rgba(60, 30, 10, 0.35)');
    ctx.fillStyle = vigGrad;
    ctx.fillRect(0, 0, w, h);

    const ink = '#1a0f00';     // Dark brown ink
    const gold = '#8b6914';    // Antique gold
    const faintInk = 'rgba(26, 15, 0, 0.35)';

    // Ornate outer border — royal blue with gold inner rule
    ctx.strokeStyle = '#4169E1';
    ctx.lineWidth = 6;
    ctx.strokeRect(36, 36, w - 72, h - 72);
    ctx.strokeStyle = '#4169E1';
    ctx.lineWidth = 2;
    ctx.strokeRect(48, 48, w - 96, h - 96);

    // Victorian corner flourishes (larger, more elaborate)
    this.drawCornerFlourish(ctx, 48, 48, 1, 1, ink);
    this.drawCornerFlourish(ctx, w - 48, 48, -1, 1, ink);
    this.drawCornerFlourish(ctx, 48, h - 48, 1, -1, ink);
    this.drawCornerFlourish(ctx, w - 48, h - 48, -1, -1, ink);

    ctx.textAlign = 'center';

    // Top ornamental rule
    this.drawOrnamentalRule(ctx, w / 2, 110, 320, '#4169E1');

    // "Est. 1893" banner
    ctx.fillStyle = '#4169E1';
    ctx.font = 'italic 24px Georgia, "Times New Roman", serif';
    ctx.fillText('— Est. 1893 —', w / 2, 155);

    // Victorian pen-and-ink sketch for this holiday
    this.drawHolidaySketch(ctx, w / 2, 340, holiday.name, ink, gold);

    // Main greeting — drop shadow for depth
    ctx.textAlign = 'center';
    ctx.font = 'bold italic 78px Georgia, "Times New Roman", serif';
    const greetingLines = this.splitGreeting(holiday.greeting, ctx, w - 200);
    const greetingY = greetingLines.length === 1 ? 570 : 545;
    // Shadow
    greetingLines.forEach((line, i) => {
      ctx.fillStyle = 'rgba(26, 15, 0, 0.1)';
      ctx.fillText(line, w / 2 + 2, greetingY + i * 95 + 2);
    });
    // Main text
    greetingLines.forEach((line, i) => {
      ctx.fillStyle = '#4169E1';
      ctx.fillText(line, w / 2, greetingY + i * 95);
    });

    // Decorative flourish below greeting
    const flourishY = greetingY + greetingLines.length * 95 + 25;
    this.drawOrnamentalRule(ctx, w / 2, flourishY, 250, '#4169E1');

    // Subtle gold wash behind club name area
    const washGrad = ctx.createLinearGradient(0, h - 280, 0, h - 40);
    washGrad.addColorStop(0, 'rgba(139, 105, 20, 0)');
    washGrad.addColorStop(0.3, 'rgba(139, 105, 20, 0.04)');
    washGrad.addColorStop(0.7, 'rgba(139, 105, 20, 0.04)');
    washGrad.addColorStop(1, 'rgba(139, 105, 20, 0)');
    ctx.fillStyle = washGrad;
    ctx.fillRect(100, h - 280, w - 200, 240);

    // "With Warm Regards from"
    ctx.fillStyle = '#4169E1';
    ctx.font = 'italic 28px Georgia, "Times New Roman", serif';
    ctx.fillText('With Warm Regards from', w / 2, h - 240);

    // Club name — proper Victorian title with letter spacing
    ctx.fillStyle = '#4169E1';
    ctx.font = 'bold 44px Georgia, "Times New Roman", serif';
    ctx.fillText('LIGHTHOUSE', w / 2, h - 185);

    // "1893" year
    ctx.fillStyle = '#4169E1';
    ctx.font = 'italic 30px Georgia, "Times New Roman", serif';
    ctx.fillText('1893', w / 2, h - 145);

    // Soccer ball as centerpiece divider
    ctx.font = '36px Georgia, serif';
    ctx.fillText('⚽', w / 2, h - 102);

    // "Club" below the ball
    ctx.fillStyle = '#4169E1';
    ctx.font = 'italic 34px Georgia, "Times New Roman", serif';
    ctx.fillText('Club', w / 2, h - 62);

    this.finalizeCard(canvas, index);
  }

  // Victorian corner flourish — clean bracket ornament
  drawCornerFlourish(ctx, x, y, dx, dy, color) {
    ctx.save();
    ctx.strokeStyle = color;
    ctx.fillStyle = color;
    ctx.lineWidth = 2;
    // Horizontal arm
    ctx.beginPath();
    ctx.moveTo(x + dx * 2, y + dy * 2);
    ctx.lineTo(x + dx * 50, y + dy * 2);
    ctx.stroke();
    // Vertical arm
    ctx.beginPath();
    ctx.moveTo(x + dx * 2, y + dy * 2);
    ctx.lineTo(x + dx * 2, y + dy * 50);
    ctx.stroke();
    // Diamond at the corner
    ctx.save();
    ctx.translate(x + dx * 2, y + dy * 2);
    ctx.rotate(Math.PI / 4);
    ctx.fillRect(-4, -4, 8, 8);
    ctx.restore();
    ctx.restore();
  }

  // Ornamental horizontal rule with diamond center
  drawOrnamentalRule(ctx, cx, cy, halfWidth, color) {
    ctx.save();
    ctx.strokeStyle = color;
    ctx.fillStyle = color;
    ctx.lineWidth = 1.5;
    // Left line
    ctx.beginPath();
    ctx.moveTo(cx - halfWidth, cy);
    ctx.lineTo(cx - 14, cy);
    ctx.stroke();
    // Right line
    ctx.beginPath();
    ctx.moveTo(cx + 14, cy);
    ctx.lineTo(cx + halfWidth, cy);
    ctx.stroke();
    // Center diamond
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(Math.PI / 4);
    ctx.fillRect(-5, -5, 10, 10);
    ctx.restore();
    // End diamonds (smaller)
    [-halfWidth, halfWidth].forEach(offset => {
      ctx.save();
      ctx.translate(cx + offset, cy);
      ctx.rotate(Math.PI / 4);
      ctx.fillRect(-3, -3, 6, 6);
      ctx.restore();
    });
    ctx.restore();
  }

  // Victorian pen-and-ink sketches — thin line art like 1890s engravings
  drawHolidaySketch(ctx, cx, cy, name, ink, gold) {
    ctx.save();
    ctx.strokeStyle = ink;
    ctx.fillStyle = ink;
    ctx.lineWidth = 1.8;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    switch (name) {
      case 'New Year':       this.sketchBells(ctx, cx, cy); break;
      case "Valentine's Day": this.sketchHeart(ctx, cx, cy); break;
      case "St. Patrick's Day": this.sketchShamrock(ctx, cx, cy); break;
      case 'Easter':         this.sketchSpring(ctx, cx, cy); break;
      case 'Memorial Day':   this.sketchWreath(ctx, cx, cy); break;
      case 'Independence Day': this.sketchLibertyBell(ctx, cx, cy); break;
      case 'Labor Day':      this.sketchAnvil(ctx, cx, cy); break;
      case 'Halloween':      this.sketchPumpkin(ctx, cx, cy); break;
      case 'Thanksgiving':   this.sketchWheatSheaf(ctx, cx, cy); break;
      case 'Christmas':      this.sketchTree(ctx, cx, cy); break;
    }
    ctx.restore();
  }

  // Bells with ribbon bow (New Year)
  sketchBells(ctx, cx, cy) {
    // Left bell
    ctx.beginPath();
    ctx.moveTo(cx - 55, cy - 50);
    ctx.quadraticCurveTo(cx - 70, cy - 10, cx - 75, cy + 30);
    ctx.quadraticCurveTo(cx - 78, cy + 50, cx - 50, cy + 55);
    ctx.lineTo(cx - 20, cy + 55);
    ctx.quadraticCurveTo(cx + 5, cy + 50, cx, cy + 30);
    ctx.quadraticCurveTo(cx - 5, cy - 10, cx - 20, cy - 50);
    ctx.stroke();
    // Clapper
    ctx.beginPath();
    ctx.arc(cx - 38, cy + 50, 5, 0, Math.PI * 2);
    ctx.stroke();
    // Right bell
    ctx.beginPath();
    ctx.moveTo(cx + 55, cy - 50);
    ctx.quadraticCurveTo(cx + 70, cy - 10, cx + 75, cy + 30);
    ctx.quadraticCurveTo(cx + 78, cy + 50, cx + 50, cy + 55);
    ctx.lineTo(cx + 20, cy + 55);
    ctx.quadraticCurveTo(cx - 5, cy + 50, cx, cy + 30);
    ctx.quadraticCurveTo(cx + 5, cy - 10, cx + 20, cy - 50);
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(cx + 38, cy + 50, 5, 0, Math.PI * 2);
    ctx.stroke();
    // Ribbon bow at top
    ctx.beginPath();
    ctx.moveTo(cx, cy - 55);
    ctx.quadraticCurveTo(cx - 35, cy - 75, cx - 50, cy - 55);
    ctx.quadraticCurveTo(cx - 35, cy - 50, cx, cy - 55);
    ctx.quadraticCurveTo(cx + 35, cy - 50, cx + 50, cy - 55);
    ctx.quadraticCurveTo(cx + 35, cy - 75, cx, cy - 55);
    ctx.stroke();
    // Ribbon tails
    ctx.beginPath();
    ctx.moveTo(cx - 50, cy - 55);
    ctx.quadraticCurveTo(cx - 55, cy - 35, cx - 60, cy - 25);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(cx + 50, cy - 55);
    ctx.quadraticCurveTo(cx + 55, cy - 35, cx + 60, cy - 25);
    ctx.stroke();
  }

  // Ornate heart with flourish (Valentine's)
  sketchHeart(ctx, cx, cy) {
    ctx.beginPath();
    ctx.moveTo(cx, cy + 50);
    ctx.bezierCurveTo(cx - 100, cy - 10, cx - 60, cy - 70, cx, cy - 30);
    ctx.bezierCurveTo(cx + 60, cy - 70, cx + 100, cy - 10, cx, cy + 50);
    ctx.stroke();
    // Inner heart (double-line effect)
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(cx, cy + 35);
    ctx.bezierCurveTo(cx - 80, cy - 5, cx - 48, cy - 55, cx, cy - 20);
    ctx.bezierCurveTo(cx + 48, cy - 55, cx + 80, cy - 5, cx, cy + 35);
    ctx.stroke();
    // Arrow through heart
    ctx.lineWidth = 1.8;
    ctx.beginPath();
    ctx.moveTo(cx - 80, cy - 25);
    ctx.lineTo(cx + 80, cy + 10);
    ctx.stroke();
    // Arrowhead
    ctx.beginPath();
    ctx.moveTo(cx + 80, cy + 10);
    ctx.lineTo(cx + 65, cy + 2);
    ctx.moveTo(cx + 80, cy + 10);
    ctx.lineTo(cx + 72, cy + 22);
    ctx.stroke();
    // Feather end
    ctx.beginPath();
    ctx.moveTo(cx - 80, cy - 25);
    ctx.lineTo(cx - 88, cy - 35);
    ctx.moveTo(cx - 80, cy - 25);
    ctx.lineTo(cx - 90, cy - 20);
    ctx.stroke();
  }

  // Shamrock / clover (St. Patrick's)
  sketchShamrock(ctx, cx, cy) {
    const drawLeaf = (angle) => {
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(angle);
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.bezierCurveTo(-30, -20, -35, -55, -10, -65);
      ctx.bezierCurveTo(0, -70, 0, -70, 10, -65);
      ctx.bezierCurveTo(35, -55, 30, -20, 0, 0);
      ctx.stroke();
      ctx.restore();
    };
    drawLeaf(0);                    // Top
    drawLeaf(2.1);                  // Bottom-right
    drawLeaf(-2.1);                 // Bottom-left
    // Stem
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.quadraticCurveTo(cx + 5, cy + 30, cx + 3, cy + 65);
    ctx.stroke();
    // Leaf veins (thin)
    ctx.lineWidth = 0.8;
    [0, 2.1, -2.1].forEach(angle => {
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(angle);
      ctx.beginPath();
      ctx.moveTo(0, -5);
      ctx.lineTo(0, -50);
      ctx.stroke();
      ctx.restore();
    });
  }

  // Simple tulip (Easter/Spring)
  sketchSpring(ctx, cx, cy) {
    const royalBlue = '#4169E1';
    const gold = '#FFD700';
    const leafGreen = '#2E5D3A';

    // Stem
    ctx.lineWidth = 2;
    ctx.strokeStyle = leafGreen;
    ctx.beginPath();
    ctx.moveTo(cx, cy + 60);
    ctx.quadraticCurveTo(cx + 3, cy + 10, cx, cy - 20);
    ctx.stroke();
    // Left leaf
    ctx.lineWidth = 1.5;
    ctx.fillStyle = leafGreen;
    ctx.beginPath();
    ctx.moveTo(cx, cy + 30);
    ctx.quadraticCurveTo(cx - 35, cy + 10, cx - 30, cy - 10);
    ctx.quadraticCurveTo(cx - 20, cy + 5, cx, cy + 30);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // Right leaf
    ctx.beginPath();
    ctx.moveTo(cx, cy + 40);
    ctx.quadraticCurveTo(cx + 35, cy + 20, cx + 30, cy);
    ctx.quadraticCurveTo(cx + 20, cy + 15, cx, cy + 40);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // Tulip petals
    ctx.lineWidth = 1.8;
    ctx.strokeStyle = this.inkColor;
    // Left petal — royal blue (main)
    ctx.fillStyle = royalBlue;
    ctx.beginPath();
    ctx.moveTo(cx - 3, cy - 20);
    ctx.quadraticCurveTo(cx - 30, cy - 40, cx - 22, cy - 72);
    ctx.quadraticCurveTo(cx - 12, cy - 62, cx, cy - 55);
    ctx.quadraticCurveTo(cx - 5, cy - 38, cx - 3, cy - 20);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // Right petal — royal blue (main)
    ctx.beginPath();
    ctx.moveTo(cx + 3, cy - 20);
    ctx.quadraticCurveTo(cx + 30, cy - 40, cx + 22, cy - 72);
    ctx.quadraticCurveTo(cx + 12, cy - 62, cx, cy - 55);
    ctx.quadraticCurveTo(cx + 5, cy - 38, cx + 3, cy - 20);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // Center petal — yellow (small, visible between the two main petals)
    ctx.fillStyle = gold;
    ctx.beginPath();
    ctx.moveTo(cx - 4, cy - 22);
    ctx.quadraticCurveTo(cx - 7, cy - 50, cx, cy - 78);
    ctx.quadraticCurveTo(cx + 7, cy - 50, cx + 4, cy - 22);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    // Restore ink color
    ctx.strokeStyle = this.inkColor;
  }

  // Laurel wreath (Memorial Day)
  sketchWreath(ctx, cx, cy) {
    const r = 55;
    // Draw wreath as paired leaves around a circle
    for (let i = 0; i < 16; i++) {
      const angle = (Math.PI * 2 / 16) * i;
      const lx = cx + Math.cos(angle) * r;
      const ly = cy + Math.sin(angle) * r;
      ctx.save();
      ctx.translate(lx, ly);
      ctx.rotate(angle + Math.PI / 2);
      // Leaf shape
      ctx.beginPath();
      ctx.moveTo(0, -12);
      ctx.quadraticCurveTo(7, -6, 7, 0);
      ctx.quadraticCurveTo(7, 6, 0, 12);
      ctx.quadraticCurveTo(-7, 6, -7, 0);
      ctx.quadraticCurveTo(-7, -6, 0, -12);
      ctx.stroke();
      // Center vein
      ctx.lineWidth = 0.8;
      ctx.beginPath();
      ctx.moveTo(0, -10);
      ctx.lineTo(0, 10);
      ctx.stroke();
      ctx.lineWidth = 1.8;
      ctx.restore();
    }
    // Star in center
    this.drawStar(ctx, cx, cy, 18, 8, 5);
  }

  // Simple 5-pointed star outline
  drawStar(ctx, cx, cy, outerR, innerR, points) {
    ctx.beginPath();
    for (let i = 0; i < points * 2; i++) {
      const r = i % 2 === 0 ? outerR : innerR;
      const angle = (Math.PI / points) * i - Math.PI / 2;
      const x = cx + Math.cos(angle) * r;
      const y = cy + Math.sin(angle) * r;
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.stroke();
  }

  // Liberty Bell (Independence Day)
  sketchLibertyBell(ctx, cx, cy) {
    // Bell body
    ctx.beginPath();
    ctx.moveTo(cx - 20, cy - 60);
    ctx.quadraticCurveTo(cx - 50, cy - 30, cx - 55, cy + 10);
    ctx.quadraticCurveTo(cx - 60, cy + 40, cx - 50, cy + 55);
    ctx.lineTo(cx + 50, cy + 55);
    ctx.quadraticCurveTo(cx + 60, cy + 40, cx + 55, cy + 10);
    ctx.quadraticCurveTo(cx + 50, cy - 30, cx + 20, cy - 60);
    ctx.stroke();
    // Top bracket / yoke
    ctx.lineWidth = 2.5;
    ctx.beginPath();
    ctx.moveTo(cx - 25, cy - 60);
    ctx.lineTo(cx - 25, cy - 75);
    ctx.lineTo(cx + 25, cy - 75);
    ctx.lineTo(cx + 25, cy - 60);
    ctx.stroke();
    ctx.lineWidth = 1.8;
    // Crack line
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.moveTo(cx + 5, cy - 40);
    ctx.lineTo(cx - 2, cy - 15);
    ctx.lineTo(cx + 4, cy + 10);
    ctx.lineTo(cx - 1, cy + 30);
    ctx.stroke();
    ctx.lineWidth = 1.8;
    // Clapper
    ctx.beginPath();
    ctx.arc(cx, cy + 48, 6, 0, Math.PI * 2);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(cx, cy + 42);
    ctx.lineTo(cx, cy + 10);
    ctx.stroke();
    // Decorative band
    ctx.lineWidth = 0.8;
    ctx.beginPath();
    ctx.moveTo(cx - 48, cy + 42);
    ctx.lineTo(cx + 48, cy + 42);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(cx - 45, cy + 36);
    ctx.lineTo(cx + 45, cy + 36);
    ctx.stroke();
  }

  // Anvil with hammer (Labor Day)
  sketchAnvil(ctx, cx, cy) {
    // Anvil body
    ctx.beginPath();
    ctx.moveTo(cx - 50, cy + 10);
    ctx.lineTo(cx - 50, cy - 10);
    ctx.lineTo(cx - 30, cy - 10);
    ctx.lineTo(cx - 30, cy - 30);
    ctx.lineTo(cx + 40, cy - 30);
    ctx.lineTo(cx + 55, cy - 15);
    ctx.lineTo(cx + 55, cy - 10);
    ctx.lineTo(cx + 35, cy - 10);
    ctx.lineTo(cx + 35, cy + 10);
    ctx.closePath();
    ctx.stroke();
    // Base
    ctx.beginPath();
    ctx.moveTo(cx - 40, cy + 10);
    ctx.lineTo(cx - 35, cy + 40);
    ctx.lineTo(cx + 30, cy + 40);
    ctx.lineTo(cx + 25, cy + 10);
    ctx.stroke();
    // Hammer (resting diagonally)
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(cx - 40, cy - 60);
    ctx.lineTo(cx + 15, cy - 35);
    ctx.stroke();
    // Hammer head
    ctx.lineWidth = 1.8;
    ctx.beginPath();
    ctx.moveTo(cx - 50, cy - 55);
    ctx.lineTo(cx - 45, cy - 70);
    ctx.lineTo(cx - 30, cy - 63);
    ctx.lineTo(cx - 35, cy - 48);
    ctx.closePath();
    ctx.stroke();
  }

  // Jack-o-lantern (Halloween)
  sketchPumpkin(ctx, cx, cy) {
    // Main pumpkin shape — oval with segments
    ctx.beginPath();
    ctx.ellipse(cx, cy, 65, 50, 0, 0, Math.PI * 2);
    ctx.stroke();
    // Vertical segment lines
    ctx.lineWidth = 1;
    [-30, 0, 30].forEach(offset => {
      ctx.beginPath();
      ctx.moveTo(cx + offset, cy - 48);
      ctx.quadraticCurveTo(cx + offset + (offset > 0 ? 5 : offset < 0 ? -5 : 0), cy, cx + offset, cy + 48);
      ctx.stroke();
    });
    ctx.lineWidth = 1.8;
    // Eyes (triangles)
    ctx.beginPath();
    ctx.moveTo(cx - 25, cy - 15); ctx.lineTo(cx - 12, cy - 15); ctx.lineTo(cx - 18, cy - 28); ctx.closePath();
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(cx + 25, cy - 15); ctx.lineTo(cx + 12, cy - 15); ctx.lineTo(cx + 18, cy - 28); ctx.closePath();
    ctx.stroke();
    // Mouth (jagged)
    ctx.beginPath();
    ctx.moveTo(cx - 30, cy + 10);
    ctx.lineTo(cx - 18, cy + 20);
    ctx.lineTo(cx - 8, cy + 10);
    ctx.lineTo(cx + 2, cy + 20);
    ctx.lineTo(cx + 12, cy + 10);
    ctx.lineTo(cx + 22, cy + 20);
    ctx.lineTo(cx + 32, cy + 10);
    ctx.stroke();
    // Stem
    ctx.beginPath();
    ctx.moveTo(cx - 5, cy - 48);
    ctx.quadraticCurveTo(cx, cy - 68, cx + 8, cy - 62);
    ctx.lineTo(cx + 3, cy - 48);
    ctx.stroke();
  }

  // Wheat sheaf (Thanksgiving)
  sketchWheatSheaf(ctx, cx, cy) {
    const stalks = 7;
    // Draw stalks fanning out
    for (let i = 0; i < stalks; i++) {
      const angle = -0.5 + (1.0 / (stalks - 1)) * i;
      const topX = cx + Math.sin(angle) * 65;
      const topY = cy - 55;
      ctx.beginPath();
      ctx.moveTo(cx + Math.sin(angle) * 5, cy + 50);
      ctx.quadraticCurveTo(cx + Math.sin(angle) * 30, cy - 10, topX, topY);
      ctx.stroke();
      // Wheat kernels at top (little ovals)
      ctx.lineWidth = 1.2;
      for (let k = 0; k < 3; k++) {
        const ky = topY - k * 10;
        const kx = topX + Math.sin(angle) * k * 3;
        ctx.beginPath();
        ctx.save();
        ctx.translate(kx, ky);
        ctx.rotate(angle);
        ctx.ellipse(0, 0, 3, 7, 0, 0, Math.PI * 2);
        ctx.stroke();
        ctx.restore();
      }
      ctx.lineWidth = 1.8;
    }
    // Ribbon tie at base
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(cx - 20, cy + 25);
    ctx.quadraticCurveTo(cx, cy + 18, cx + 20, cy + 25);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(cx - 20, cy + 30);
    ctx.quadraticCurveTo(cx, cy + 23, cx + 20, cy + 30);
    ctx.stroke();
  }

  // Evergreen tree with star (Christmas)
  sketchTree(ctx, cx, cy) {
    // Star at top
    this.drawStar(ctx, cx, cy - 65, 12, 5, 5);
    // Tree tiers (3 layers)
    const tiers = [
      { y: cy - 50, w: 30, h: 35 },
      { y: cy - 22, w: 48, h: 35 },
      { y: cy + 8,  w: 65, h: 38 },
    ];
    tiers.forEach(t => {
      ctx.beginPath();
      ctx.moveTo(cx, t.y);
      ctx.lineTo(cx + t.w, t.y + t.h);
      ctx.lineTo(cx - t.w, t.y + t.h);
      ctx.closePath();
      ctx.stroke();
    });
    // Trunk
    ctx.beginPath();
    ctx.moveTo(cx - 10, cy + 46);
    ctx.lineTo(cx - 10, cy + 65);
    ctx.lineTo(cx + 10, cy + 65);
    ctx.lineTo(cx + 10, cy + 46);
    ctx.stroke();
    // Small ornament dots
    ctx.lineWidth = 1;
    [[cx - 15, cy], [cx + 12, cy - 8], [cx - 8, cy + 25], [cx + 20, cy + 28], [cx, cy - 25]].forEach(([x, y]) => {
      ctx.beginPath();
      ctx.arc(x, y, 3, 0, Math.PI * 2);
      ctx.stroke();
    });
  }

  // Split greeting text into lines that fit within maxWidth
  splitGreeting(text, ctx, maxWidth) {
    const words = text.split(' ');
    if (words.length <= 2) return [text];
    const lines = [];
    let current = '';
    for (const word of words) {
      const test = current ? current + ' ' + word : word;
      if (ctx.measureText(test).width > maxWidth && current) {
        lines.push(current);
        current = word;
      } else {
        current = test;
      }
    }
    if (current) lines.push(current);
    return lines;
  }

  finalizeCard(canvas, index) {
    const dataUrl = canvas.toDataURL('image/jpeg', 0.92);
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
