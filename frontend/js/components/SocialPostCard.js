// SocialPostCard - Instagram-style social media post preview card
// Auto-generates caption from match context on load. Editable inline.
class SocialPostCard {
  constructor(auth) {
    this.auth = auth;
    this.post = null;
    this.container = null;
    this.matchId = null;
    this.teamId = null;
    this.scorersText = '';
    this.postTypeName = null;
    this.matchContext = null;
    this.postTypeId = null;
    this.saving = false;
    this.rosterData = null;
    this.generatedImageUrl = null;
    this.baseImage = null;       // base card without beam (Image object)
    this.animCanvas = null;      // live animated canvas
    this.animFrameId = null;     // requestAnimationFrame ID
    this.animStartTime = null;   // persisted start time so beam angle survives re-renders
    this.cardWidth = 540;
    this.cardHeight = 540;
  }

  resolveAssetUrl(url) {
    if (!url) return '';

    const trimmed = String(url).trim();
    if (!trimmed) return '';

    if (/^https:\/\/se-team-service-production\.s3\.amazonaws\.com\//i.test(trimmed)) {
      return `/api/social/logo-proxy?url=${trimmed}`;
    }

    if (/^(https?:|data:|blob:)/i.test(trimmed)) return trimmed;
    return trimmed.startsWith('/') ? trimmed : `/${trimmed.replace(/^\/+/, '')}`;
  }

  buildLogoInnerHtml(url, fallback = '⚽') {
    const resolvedUrl = this.resolveAssetUrl(url);
    if (!resolvedUrl) {
      return `<span style="font-size:2em;">${fallback}</span>`;
    }

    const fallbackHtml = `<span style=&quot;font-size:2em;&quot;>${fallback}</span>`;
    return `<img src="${this.escapeHtml(resolvedUrl)}" alt="" style="max-width:100%;max-height:100%;object-fit:contain;" onerror="this.onerror=null;this.outerHTML='${fallbackHtml}'">`;
  }

  init(container, matchId, teamId, postTypeName, matchContext, rosterData) {
    this.container = container;
    this.matchId = matchId;
    this.teamId = teamId;
    this.postTypeName = postTypeName;
    this.matchContext = matchContext || {};
    this.rosterData = rosterData || null;
    this.load();
  }

  load() {
    this.container.innerHTML = '<div style="padding:16px;opacity:0.5;font-size:0.85em;">Loading...</div>';

    const statsPromise = this.postTypeName === 'post_game'
      ? this.auth.fetch(`/api/social/match/${this.matchId}/stats`).then(r => r.json()).catch(() => ({ success: false, data: [] }))
      : Promise.resolve({ success: false, data: [] });

    Promise.all([
      this.auth.fetch(`/api/social/match/${this.matchId}/team/${this.teamId}`).then(r => r.json()),
      this.auth.fetch('/api/social/post-types').then(r => r.json()),
      statsPromise
    ]).then(([postsData, typesData, statsData]) => {
      if (postsData.success) {
        const posts = postsData.data || [];
        this.post = posts.find(p => p.post_type === this.postTypeName) || null;
      }
      if (typesData.success) {
        const pt = (typesData.data || []).find(t => t.name === this.postTypeName);
        if (pt) this.postTypeId = pt.id;
      }
      this.matchStats = (statsData && statsData.success) ? (statsData.data || []) : [];

      // Auto-generate if no existing post
      if (!this.post || this.post.post_id === null) {
        this.autoGenerate();
      } else {
        this.render();
      }
    }).catch((err) => {
      this.container.innerHTML = `<div style="padding:16px;color:#f44336;">Error loading post: ${err.message}</div>`;
    });
  }

  autoGenerate() {
    const caption = this.buildCaption();
    if (!this.postTypeId || !caption) {
      this.render();
      return;
    }
    this.auth.fetch('/api/social/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        match_id: this.matchId,
        team_id: this.teamId,
        post_type_id: this.postTypeId,
        caption: caption,
        status: 'draft'
      })
    }).then(r => r.json()).then(data => {
      if (data.success) {
        // Re-fetch to get the full post data
        this.auth.fetch(`/api/social/match/${this.matchId}/team/${this.teamId}`)
          .then(r => r.json())
          .then(postsData => {
            if (postsData.success) {
              this.post = (postsData.data || []).find(p => p.post_type === this.postTypeName) || null;
            }
            this.render();
          });
      } else {
        this.render();
      }
    }).catch(() => this.render());
  }

  buildCaption() {
    const m = this.matchContext;
    let homeName = 'Home';
    let awayName = 'Away';

    if (m.home_team_name) { homeName = m.home_team_name; }
    else if (m.homeTeam) { homeName = m.homeTeam; }
    else if (m.title && m.title.includes(' vs ')) {
      const parts = m.title.split(' vs ');
      homeName = parts[0].trim();
      awayName = parts[1].trim();
    }
    if (m.away_team_name) awayName = m.away_team_name;
    else if (m.awayTeam) awayName = m.awayTeam;

    homeName = this.titleCase(homeName);
    awayName = this.titleCase(awayName);

    const rawDate = m.event_date || m.date || m.match_date;
    let dateStr = '';
    let timeStr = '';
    if (rawDate) {
      const d = this.parseMatchDisplayDate(rawDate);
      if (d) {
        dateStr = d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
        timeStr = d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
      }
    }
    const venue = this.buildVenueString(m) || this.titleCase(m.venue_name || 'TBD');
    const league = m.competition_name || 'APSL';
    const isCASA = /casa/i.test(league);
    const leagueTag = isCASA ? '#CASA' : '#APSL';

    switch (this.postTypeName) {
      case 'pre_match_announcement':
        return `⚔️ STARTERS & BENCH\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893 ${leagueTag} #PhillySoccer #StartingXI`;
      case 'game_day': {
        const gameDayLabel = this.getGameDayLabel(rawDate);
        const gameDayEmoji = gameDayLabel === 'GAME DAY' ? '' : gameDayLabel === 'TOMORROW' ? 'See you there! 💪' : 'Mark your calendars! 📌';
        return `⚽ ${gameDayLabel}!\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}${gameDayEmoji ? '\n\n' + gameDayEmoji : ''}\n\n#Lighthouse1893 ${leagueTag} #GameDay #PhillySoccer`;
      }
      case 'lineup':
        return `📋 MATCH DAY SQUAD\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893 ${leagueTag} #MatchDaySquad #PhillySoccer`;
      case 'post_game': {
        const hs = m.home_team_score ?? m.home_score ?? '?';
        const as = m.away_team_score ?? m.away_score ?? '?';
        // Determine result from Lighthouse's perspective (we may be home or away)
        const isHome = String(m.home_team_id) === String(this.teamId);
        const ourScore = isHome ? Number(hs) : Number(as);
        const theirScore = isHome ? Number(as) : Number(hs);
        const result = ourScore > theirScore ? '🟢 WIN' : ourScore < theirScore ? '🔴 LOSS' : '🟡 DRAW';
        let statsLines = '';
        const stats = this.matchStats || [];
        if (stats.length > 0) {
          // Group goals by team
          const goals = stats.filter(s => s.event_type === 'goal' || s.event_type === 'own_goal');
          const cards = stats.filter(s => s.event_type === 'yellow_card' || s.event_type === 'red_card');
          if (goals.length > 0) {
            statsLines += '\n\n⚽ Goals:';
            goals.forEach(g => {
              const og = g.event_type === 'own_goal' ? ' (OG)' : '';
              const assist = g.assist_player_name ? ` (assist: ${g.assist_player_name})` : '';
              statsLines += `\n  ${g.minute}' ${g.player_name}${og}${assist} (${g.team_name})`;
            });
          }
          if (cards.length > 0) {
            const yellows = cards.filter(c => c.event_type === 'yellow_card');
            const reds = cards.filter(c => c.event_type === 'red_card');
            if (yellows.length > 0) statsLines += `\n\n🟨 Yellow cards: ${yellows.map(c => c.player_name).join(', ')}`;
            if (reds.length > 0) statsLines += `\n\n🟥 Red cards: ${reds.map(c => c.player_name).join(', ')}`;
          }
        } else if (this.scorersText && this.scorersText.trim()) {
          // Manual scorers fallback
          statsLines = `\n\n⚽ Goals:\n  ${this.scorersText.trim().split('\n').map(s => s.trim()).filter(Boolean).join('\n  ')}`;
        }
        return `${result}\n\n${homeName} ${hs} - ${as} ${awayName}\n${league} ⚽\n📅 ${dateStr}\n📍 ${venue}${statsLines}\n\n#Lighthouse1893 ${leagueTag} #PhillySoccer #MatchResult`;
      }
      default:
        return '';
    }
  }

  render() {
    const p = this.post;
    const hasContent = p && p.post_id !== null;
    const isPosted = p && p.status === 'posted';
    const isScheduled = p && p.status === 'scheduled';

    const labels = {
      pre_match_announcement: '⚔️ Starters & Bench',
      game_day: '⚽ Game Announcement',
      lineup: '📋 20-Man Squad',
      post_game: '🏆 Match Result'
    };
    const accentColors = {
      pre_match_announcement: '#3b82f6',
      game_day: '#f59e0b',
      lineup: '#8b5cf6',
      post_game: '#22c55e'
    };
    const label = labels[this.postTypeName] || this.postTypeName;
    const accent = accentColors[this.postTypeName] || '#6b7280';

    // Caption for textarea
    const rawCaption = (hasContent && p.caption) ? p.caption : this.buildCaption();
    const caption = this.normalizeLegacyCaptionText(this.normalizeLegacyCaptionVenue(this.normalizeLegacyCaptionTime(rawCaption)));

    // Status badge
    let badge = '';
    if (isPosted) {
      badge = '<span class="spc-badge spc-badge-posted">✅ Posted</span>';
    } else if (isScheduled) {
      badge = `<span class="spc-badge spc-badge-scheduled">📅 Scheduled ${this.formatDate(p.scheduled_at)}</span>`;
    } else if (hasContent) {
      badge = '<span class="spc-badge spc-badge-draft">Draft</span>';
    }

    // Image area
    let imageHtml = '';
    if (hasContent && p.image_url) {
      imageHtml = `<div class="spc-image"><img src="${this.escapeHtml(p.image_url)}" alt="Post image"></div>`;
    } else if (this.baseImage) {
      // Animated canvas will be inserted here
      imageHtml = `<div class="spc-image" id="spc-image-area"></div>`;
    } else {
      imageHtml = `
        <div class="spc-image spc-image-placeholder" id="spc-image-area">
          <div class="spc-image-placeholder-inner">
            <span style="font-size:1.5em;">⏳</span>
            <span>Generating image...</span>
          </div>
        </div>`;
    }

    this.container.innerHTML = `
      <div class="spc-card" style="--spc-accent:${accent};">
        <div class="spc-header">
          <div class="spc-header-left">
            <div class="spc-avatar">📸</div>
            <div>
              <div class="spc-account">lighthouse1893sc</div>
              <div class="spc-post-type">${this.escapeHtml(label)}</div>
            </div>
          </div>
          ${badge}
        </div>
        ${imageHtml}
        <div class="spc-body">
          ${this.postTypeName === 'post_game' && !isPosted ? `
          <div class="spc-scorers-row">
            <label class="spc-scorers-label">⚽ Scorers (one per line)</label>
            <textarea class="spc-scorers" rows="3" placeholder="e.g. 23' John Smith\n67' Jane Doe (assist: Alex)">${this.escapeHtml(this.scorersText || '')}</textarea>
          </div>` : ''}
          <textarea class="spc-caption" rows="6" ${isPosted ? 'disabled' : ''}>${this.escapeHtml(caption)}</textarea>
          <div class="spc-char-count"><span class="spc-char-num">${caption.length}</span> / 2,200</div>
        </div>
        <div class="spc-actions">
          ${!isPosted ? `
            <button class="spc-btn spc-btn-download-video">📹 Download Video</button>
            <button class="spc-btn spc-btn-save" ${this.saving ? 'disabled' : ''}>💾 Save</button>
            <div class="spc-schedule-row">
              <input type="datetime-local" class="spc-schedule-input" value="${isScheduled && p.scheduled_at ? this.toLocalISOString(p.scheduled_at) : ''}" />
              <button class="spc-btn spc-btn-schedule">📅 Schedule</button>
            </div>
            <button class="spc-btn spc-btn-post">🚀 Post Now</button>
          ` : ''}
        </div>
      </div>
    `;

    this.attachListeners();

    // If we already have the base image, restart animation on the new canvas element
    if (this.baseImage && !hasContent) {
      this.startAnimatedPreview();
    }

    // Auto-generate image if none exists
    if (!(hasContent && p.image_url) && !this.baseImage) {
      this.generateImage();
    }
  }

  async generateImage() {
    if (typeof html2canvas === 'undefined') return;

    const m = this.matchContext;
    const homeName = this.titleCase(m.home_team_name || m.homeTeam || 'Home');
    const awayName = this.titleCase(m.away_team_name || m.awayTeam || 'Away');
    const homeLogo = this.resolveAssetUrl(m.home_team_logo || '');
    const awayLogo = this.resolveAssetUrl(m.away_team_logo || '');
    const rawDate = m.event_date || m.date || m.match_date;
    let dateStr = '', timeStr = '';
    if (rawDate) {
      const d = this.parseMatchDisplayDate(rawDate);
      if (d) {
        dateStr = d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
        timeStr = d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
      }
    }
    const venueStr = this.buildVenueString(m);
    const competitionText = `${m.competition_name || ''} ${m.division_name || ''}`;
    const isCasa = (m.source_name === 'casa') || /casa|liga\s*[12]/i.test(competitionText);

    // Fetch accolades for both teams
    const homeTeamId = m.home_team_id || null;
    const awayTeamId = m.away_team_id || null;
    let homeAccolades = [], awayAccolades = [];
    try {
      const fetches = [];
      if (homeTeamId) fetches.push(this.auth.fetch(`/api/teams/${homeTeamId}/accolades`).then(r => r.json()));
      else fetches.push(Promise.resolve({ data: [] }));
      if (awayTeamId) fetches.push(this.auth.fetch(`/api/teams/${awayTeamId}/accolades`).then(r => r.json()));
      else fetches.push(Promise.resolve({ data: [] }));
      const [homeRes, awayRes] = await Promise.all(fetches);
      homeAccolades = (homeRes.data || []).filter(a => a.type === 'achievement');
      awayAccolades = (awayRes.data || []).filter(a => a.type === 'achievement');
      // Grab our tagline
      this.teamTagline = (homeRes.data || []).concat(awayRes.data || [])
        .filter(a => a.type === 'tagline' && [homeTeamId, awayTeamId].includes(this.teamId))
        .map(a => a.accolade)[0] || '';
      // If our team is home, use homeRes tagline; if away, use awayRes tagline
      const ourRes = (String(this.teamId) === String(homeTeamId)) ? homeRes : awayRes;
      const ourTaglines = (ourRes.data || []).filter(a => a.type === 'tagline');
      if (ourTaglines.length) this.teamTagline = ourTaglines[0].accolade;
    } catch (e) { /* accolades are optional */ }
    // Determine league display name
    let league;
    if (isCasa) {
      const div = `${m.division_name || ''} ${m.competition_name || ''}`;
      if (/liga\s*2/i.test(div)) league = 'Philadelphia CASA Select Liga 2';
      else league = 'Philadelphia CASA Select Liga 1';
    } else {
      league = 'Delaware River Conference';
    }

    // Build post-type-specific content
    let headerText = '', middleHtml = '', rosterHtml = '', leagueBadgeHtml = '';
    switch (this.postTypeName) {
      case 'game_day':
        headerText = this.getGameDayLabel(rawDate);
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, false);
        break;
      case 'lineup':
        headerText = 'MATCH DAY SQUAD';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, true);
        rosterHtml = this.buildImageRoster();
        break;
      case 'pre_match_announcement':
        headerText = 'STARTERS & BENCH';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, true);
        break;
      case 'post_game':
        headerText = 'FULL TIME';
        middleHtml = this.buildImageScore(homeName, awayName, m, homeLogo, awayLogo);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, false);
        break;
      default:
        headerText = 'MATCH DAY';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo);
    }

    // Build scorers block for post_game graphic
    let scorersHtml = '';
    if (this.postTypeName === 'post_game' && this.scorersText && this.scorersText.trim()) {
      const lines = this.scorersText.trim().split('\n').map(s => s.trim()).filter(Boolean);
      const lineItems = lines.map(l => `<div style="font-size:12px;color:rgba(255,255,255,0.92);letter-spacing:0.3px;line-height:1.5;">${this.escapeHtml(l)}</div>`).join('');
      scorersHtml = `
        <div style="width:100%;text-align:left;margin-bottom:14px;">
          <div style="font-size:10px;text-transform:uppercase;letter-spacing:2px;color:#f5d442;font-weight:700;margin-bottom:5px;">⚽ Goals</div>
          ${lineItems}
        </div>
      `;
    }

    // Adjust size: taller for lineup with roster list
    const hasRoster = rosterHtml.length > 0;
    const cardHeight = hasRoster ? 700 : 540;

    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'position:fixed;left:-9999px;top:0;z-index:-1;pointer-events:none;';

    wrapper.innerHTML = `
      <div style="
        width:540px; height:${cardHeight}px;
        background:linear-gradient(160deg, #0033a0 0%, #003fbf 30%, #0044cc 55%, #002080 100%);
        color:#fff; text-align:center; position:relative; overflow:hidden;
        font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
        display:flex; flex-direction:column; justify-content:flex-start; align-items:center;
        padding:${hasRoster ? '20px 28px 16px' : '20px 30px 16px'};
        box-sizing:border-box;
        border:4px solid #f5d442;
      ">

        <!-- Header -->
        <div style="font-size:12px;text-transform:uppercase;letter-spacing:5px;color:#ffffff;margin-bottom:${hasRoster ? '8px' : leagueBadgeHtml ? '8px' : '12px'};font-weight:700;">
          ${this.escapeHtml(headerText)}
        </div>

        ${leagueBadgeHtml}

        ${middleHtml}

        ${scorersHtml}

        ${rosterHtml}

        <!-- Footer -->
        <div style="margin-top:auto;padding-top:0;display:flex;align-items:flex-end;justify-content:flex-start;width:100%;">
          <div style="display:flex;flex-direction:column;align-items:flex-start;gap:3px;">
            <div style="display:flex;align-items:center;gap:10px;">
              <img src="/images/sponsors/welovejunk.png" style="height:80px;object-fit:contain;" />
              <span style="font-size:11px;letter-spacing:0.5px;color:rgba(255,255,255,0.95);text-transform:uppercase;font-weight:700;">Sponsored by<br/>We Love Junk</span>
            </div>
            <span style="font-size:11px;letter-spacing:2px;color:#f5d442;text-transform:uppercase;font-weight:700;">LIGHTHOUSE 1893</span>
            ${this.teamTagline ? `<span style="font-size:8px;font-style:italic;letter-spacing:0.5px;color:rgba(255,255,255,0.7);">"${this.escapeHtml(this.teamTagline)}"</span>` : ''}
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(wrapper);

    try {
      const canvas = await html2canvas(wrapper.firstElementChild, { backgroundColor: null, scale: 2, useCORS: true });
      // Store base image (card without beam)
      this.cardWidth = 540;
      this.cardHeight = cardHeight;
      const baseImg = new Image();
      baseImg.src = canvas.toDataURL('image/png');
      await new Promise(resolve => { baseImg.onload = resolve; });
      this.baseImage = baseImg;
      this.generatedImageUrl = baseImg.src; // fallback
      // Start animated preview
      this.startAnimatedPreview();
    } catch (err) {
      console.error('Image generation failed:', err);
    } finally {
      document.body.removeChild(wrapper);
    }
  }

  startAnimatedPreview() {
    if (this.animFrameId) cancelAnimationFrame(this.animFrameId);
    const imageArea = this.container.querySelector('#spc-image-area');
    if (!imageArea) return;

    // Create canvas at 2x for sharpness, displayed at 1x
    const dpr = 2;
    const cvs = document.createElement('canvas');
    cvs.width = this.cardWidth * dpr;
    cvs.height = this.cardHeight * dpr;
    cvs.style.width = '100%';
    cvs.style.maxWidth = this.cardWidth + 'px';
    cvs.style.height = 'auto';
    cvs.style.display = 'block';
    cvs.style.borderRadius = '4px';
    this.animCanvas = cvs;

    imageArea.className = 'spc-image';
    imageArea.innerHTML = '';
    imageArea.appendChild(cvs);

    const ctx = cvs.getContext('2d');
    const w = cvs.width;
    const h = cvs.height;
    // Lighthouse position (bottom-right corner of card, in 2x coords)
    const lhX = w - 100;  // lantern X
    const lhY = h - 340; // lantern Y (near top of lighthouse)
    const beamLen = Math.max(w, h) * 1.2;
    const beamSpread = 0.18; // half-angle of beam in radians (~10 degrees)
    const rotPeriod = 30; // seconds for one full 360° sweep
    const rotSpeed = (2 * Math.PI) / rotPeriod; // radians per second
    // Preserve startTime across re-renders so the beam angle never jumps
    if (!this.animStartTime) this.animStartTime = performance.now();
    const startTime = this.animStartTime;

    const drawFrame = (now) => {
      const elapsed = (now - startTime) / 1000;
      const angle = (elapsed * rotSpeed) % (Math.PI * 2);
      ctx.clearRect(0, 0, w, h);

      // Draw base card image
      if (this.baseImage) {
        ctx.drawImage(this.baseImage, 0, 0, w, h);
      }

      // Save context for beam clipping to card area
      ctx.save();
      ctx.beginPath();
      ctx.rect(0, 0, w, h);
      ctx.clip();

      // Draw light beam (rotating cone)
      // Start beam pointing down-right (off-screen) so loop seam is invisible
      const beamAngle = angle + Math.PI * 0.25; // offset: starts at ~45° down-right (off canvas)
      const a1 = beamAngle - beamSpread;
      const a2 = beamAngle + beamSpread;
      const tipX1 = lhX + Math.cos(a1) * beamLen;
      const tipY1 = lhY + Math.sin(a1) * beamLen;
      const tipX2 = lhX + Math.cos(a2) * beamLen;
      const tipY2 = lhY + Math.sin(a2) * beamLen;

      // Outer glow
      const grad = ctx.createRadialGradient(lhX, lhY, 10, lhX, lhY, beamLen * 0.7);
      grad.addColorStop(0, 'rgba(255, 230, 0, 0.55)');
      grad.addColorStop(0.3, 'rgba(255, 223, 0, 0.25)');
      grad.addColorStop(1, 'rgba(255, 223, 0, 0)');

      ctx.beginPath();
      ctx.moveTo(lhX, lhY);
      ctx.lineTo(tipX1, tipY1);
      ctx.lineTo(tipX2, tipY2);
      ctx.closePath();
      ctx.fillStyle = grad;
      ctx.fill();

      // Bright core (narrower)
      const ca1 = beamAngle - beamSpread * 0.4;
      const ca2 = beamAngle + beamSpread * 0.4;
      const coreLen = beamLen * 0.6;
      ctx.beginPath();
      ctx.moveTo(lhX, lhY);
      ctx.lineTo(lhX + Math.cos(ca1) * coreLen, lhY + Math.sin(ca1) * coreLen);
      ctx.lineTo(lhX + Math.cos(ca2) * coreLen, lhY + Math.sin(ca2) * coreLen);
      ctx.closePath();
      const coreGrad = ctx.createRadialGradient(lhX, lhY, 5, lhX, lhY, coreLen * 0.5);
      coreGrad.addColorStop(0, 'rgba(255, 240, 50, 0.5)');
      coreGrad.addColorStop(1, 'rgba(255, 240, 50, 0)');
      ctx.fillStyle = coreGrad;
      ctx.fill();

      ctx.restore();

      // Draw lighthouse on top
      this.drawLighthouse(ctx, lhX, lhY);

      this.animFrameId = requestAnimationFrame(drawFrame);
    };
    this.animFrameId = requestAnimationFrame(drawFrame);
  }

  drawLighthouse(ctx, lhX, lhY) {
    // lhX, lhY = lantern center position
    const s = 2; // scale factor (we're on 2x canvas)
    ctx.save();

    // === DIMENSIONS ===
    const topW = 26 * s, botW = 38 * s, towerH = 150 * s;
    const topY = lhY + 8 * s;
    const botY = lhY + towerH;

    // Helper: tower trapezoid clip path
    const towerPath = () => {
      ctx.beginPath();
      ctx.moveTo(lhX - topW / 2, topY);
      ctx.lineTo(lhX + topW / 2, topY);
      ctx.lineTo(lhX + botW / 2, botY);
      ctx.lineTo(lhX - botW / 2, botY);
      ctx.closePath();
    };

    // === TOWER BODY (white) ===
    towerPath();
    ctx.fillStyle = '#ffffff';
    ctx.fill();

    // 4 royal blue bands with gold "1893" digits (spread out, last band just above door)
    const digits = ['1', '8', '9', '3'];
    const bandH = 18 * s;
    const bandZone = towerH * 0.82; // bands occupy top 82% of tower
    const bandGap = (bandZone - bandH * 4) / 5;
    for (let i = 0; i < 4; i++) {
      const bandY = topY + bandGap * (i + 1) + bandH * i;
      const fracTop = (bandY - topY) / towerH;
      const fracBot = (bandY + bandH - topY) / towerH;
      const wTop = topW + (botW - topW) * fracTop;
      const wBot = topW + (botW - topW) * fracBot;

      ctx.save();
      towerPath();
      ctx.clip();
      ctx.beginPath();
      ctx.moveTo(lhX - wTop / 2, bandY);
      ctx.lineTo(lhX + wTop / 2, bandY);
      ctx.lineTo(lhX + wBot / 2, bandY + bandH);
      ctx.lineTo(lhX - wBot / 2, bandY + bandH);
      ctx.closePath();
      ctx.fillStyle = '#0033a0';
      ctx.fill();

      // Gold digit
      const fontSize = Math.round(14 * s);
      ctx.font = `900 ${fontSize}px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillStyle = '#f5d442';
      ctx.fillText(digits[i], lhX, bandY + bandH / 2);
      ctx.restore();
    }

    // Thin outline on tower
    towerPath();
    ctx.strokeStyle = 'rgba(255,255,255,0.6)';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === GALLERY PLATFORM ===
    const platW = topW + 12 * s;
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1 * s;
    ctx.strokeRect(lhX - platW / 2, topY - 3 * s, platW, 6 * s);

    // Gallery railing posts
    const railH = 10 * s;
    const railY = topY - 3 * s - railH;
    const numPosts = 7;
    for (let i = 0; i < numPosts; i++) {
      const px = lhX - platW / 2 + 3 * s + i * ((platW - 6 * s) / (numPosts - 1));
      ctx.beginPath();
      ctx.moveTo(px, topY - 3 * s);
      ctx.lineTo(px, railY);
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 1 * s;
      ctx.stroke();
    }
    // Top rail
    ctx.beginPath();
    ctx.moveTo(lhX - platW / 2 + 2 * s, railY);
    ctx.lineTo(lhX + platW / 2 - 2 * s, railY);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === LANTERN ROOM ===
    const lanternW = 20 * s, lanternH = 16 * s;
    const lanternTop = railY - lanternH;

    // Glass panes (gold)
    ctx.fillStyle = '#f5d442';
    ctx.fillRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);
    // Muntin bars
    ctx.strokeStyle = '#0033a0';
    ctx.lineWidth = 1.5 * s;
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop);
    ctx.lineTo(lhX, lanternTop + lanternH);
    ctx.moveTo(lhX - lanternW / 2, lanternTop + lanternH / 2);
    ctx.lineTo(lhX + lanternW / 2, lanternTop + lanternH / 2);
    ctx.stroke();
    // Lantern frame
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2 * s;
    ctx.strokeRect(lhX - lanternW / 2, lanternTop, lanternW, lanternH);

    // === DOME ===
    const domeW = lanternW + 4 * s;
    ctx.beginPath();
    ctx.moveTo(lhX - domeW / 2, lanternTop);
    ctx.quadraticCurveTo(lhX, lanternTop - 22 * s, lhX + domeW / 2, lanternTop);
    ctx.closePath();
    ctx.fillStyle = '#0033a0';
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // Finial (gold ball + spike)
    ctx.beginPath();
    ctx.arc(lhX, lanternTop - 18 * s, 3 * s, 0, Math.PI * 2);
    ctx.fillStyle = '#f5d442';
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(lhX, lanternTop - 21 * s);
    ctx.lineTo(lhX, lanternTop - 28 * s);
    ctx.strokeStyle = '#f5d442';
    ctx.lineWidth = 2 * s;
    ctx.stroke();

    // === LANTERN GLOW ===
    const glowCY = lanternTop + lanternH / 2;
    const glowGrad = ctx.createRadialGradient(lhX, glowCY, 0, lhX, glowCY, 24 * s);
    glowGrad.addColorStop(0, 'rgba(255, 230, 0, 0.7)');
    glowGrad.addColorStop(0.4, 'rgba(255, 223, 0, 0.2)');
    glowGrad.addColorStop(1, 'rgba(255, 223, 0, 0)');
    ctx.beginPath();
    ctx.arc(lhX, glowCY, 24 * s, 0, Math.PI * 2);
    ctx.fillStyle = glowGrad;
    ctx.fill();

    // === DOOR ===
    ctx.beginPath();
    ctx.arc(lhX, botY - 16 * s, 7 * s, Math.PI, 0);
    ctx.lineTo(lhX + 7 * s, botY);
    ctx.lineTo(lhX - 7 * s, botY);
    ctx.closePath();
    ctx.fillStyle = '#0033a0';
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === ROCKY CLIFF ===
    const rockY = botY + 2 * s;
    const rockW = 50 * s;
    const rockH = 28 * s;

    // Main cliff shape (dark craggy rock)
    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + rockH);
    ctx.lineTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.lineTo(lhX + rockW, rockY + rockH);
    ctx.closePath();
    ctx.fillStyle = '#2c2c2c';
    ctx.fill();

    // Rock highlights
    ctx.save();
    ctx.globalAlpha = 0.3;
    const rockShapes = [
      { x: lhX - 20 * s, y: rockY + 6 * s, rx: 10 * s, ry: 5 * s },
      { x: lhX + 15 * s, y: rockY + 8 * s, rx: 8 * s, ry: 4 * s },
      { x: lhX - 5 * s, y: rockY + 14 * s, rx: 12 * s, ry: 5 * s },
      { x: lhX + 30 * s, y: rockY + 12 * s, rx: 9 * s, ry: 5 * s },
      { x: lhX - 35 * s, y: rockY + 12 * s, rx: 11 * s, ry: 4 * s },
    ];
    for (const r of rockShapes) {
      ctx.beginPath();
      ctx.ellipse(r.x, r.y, r.rx, r.ry, 0, 0, Math.PI * 2);
      ctx.fillStyle = '#444444';
      ctx.fill();
    }
    ctx.restore();

    // Rock edge highlight (top edge lighter)
    ctx.beginPath();
    ctx.moveTo(lhX - rockW, rockY + 6 * s);
    ctx.quadraticCurveTo(lhX - rockW * 0.7, rockY - 4 * s, lhX - rockW * 0.4, rockY + 2 * s);
    ctx.lineTo(lhX - rockW * 0.2, rockY - 2 * s);
    ctx.lineTo(lhX, rockY);
    ctx.lineTo(lhX + rockW * 0.15, rockY - 3 * s);
    ctx.lineTo(lhX + rockW * 0.35, rockY + 1 * s);
    ctx.quadraticCurveTo(lhX + rockW * 0.6, rockY - 2 * s, lhX + rockW * 0.8, rockY + 4 * s);
    ctx.lineTo(lhX + rockW, rockY + 8 * s);
    ctx.strokeStyle = '#666666';
    ctx.lineWidth = 1.5 * s;
    ctx.stroke();

    // === OCEAN WAVES ===
    const oceanY = rockY + rockH - 4 * s;
    const oceanW = 60 * s;

    // Ocean background
    const oceanGrad = ctx.createLinearGradient(0, oceanY, 0, oceanY + 20 * s);
    oceanGrad.addColorStop(0, '#1a6baa');
    oceanGrad.addColorStop(1, '#0d4a7a');
    ctx.fillStyle = oceanGrad;
    ctx.fillRect(lhX - oceanW, oceanY, oceanW * 2, 22 * s);

    // Wave lines
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.lineWidth = 1.5 * s;
    for (let row = 0; row < 3; row++) {
      const wy = oceanY + 4 * s + row * 6 * s;
      ctx.beginPath();
      for (let x = lhX - oceanW; x < lhX + oceanW; x += 12 * s) {
        const amp = 2 * s;
        ctx.moveTo(x, wy);
        ctx.quadraticCurveTo(x + 3 * s, wy - amp, x + 6 * s, wy);
        ctx.quadraticCurveTo(x + 9 * s, wy + amp, x + 12 * s, wy);
      }
      ctx.stroke();
    }

    // Foam at rock base
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.lineWidth = 2 * s;
    ctx.beginPath();
    for (let x = lhX - rockW; x < lhX + rockW; x += 8 * s) {
      ctx.moveTo(x, oceanY + 1 * s);
      ctx.quadraticCurveTo(x + 2 * s, oceanY - 2 * s, x + 4 * s, oceanY + 1 * s);
    }
    ctx.stroke();

    ctx.restore();
  }

  async downloadVideo() {
    if (!this.animCanvas) return;
    const cvs = this.animCanvas;
    const stream = cvs.captureStream(30); // 30fps
    const recorder = new MediaRecorder(stream, {
      mimeType: MediaRecorder.isTypeSupported('video/webm;codecs=vp9') ? 'video/webm;codecs=vp9' : 'video/webm'
    });
    const chunks = [];
    recorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
    return new Promise((resolve) => {
      recorder.onstop = () => {
        const blob = new Blob(chunks, { type: recorder.mimeType });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `lighthouse_${this.postTypeName || 'post'}.webm`;
        a.click();
        URL.revokeObjectURL(url);
        resolve();
      };
      recorder.start();
      // Record exactly one full beam rotation (8s) for seamless Instagram loop
      setTimeout(() => recorder.stop(), 8000);
    });
  }

  buildImageMatchup(homeName, awayName, dateStr, timeStr, venue, homeLogo, awayLogo, homeAccolades, awayAccolades) {
    homeAccolades = homeAccolades || [];
    awayAccolades = awayAccolades || [];
    const homeLogoHtml = this.buildLogoInnerHtml(homeLogo);
    const awayLogoHtml = this.buildLogoInnerHtml(awayLogo);

    const buildAccoladeHtml = (accolades) => {
      if (!accolades.length) return '';
      const items = accolades.map(a =>
        `<div style="display:flex;align-items:center;gap:3px;justify-content:center;">
          <span style="font-size:9px;">🏆</span>
          <span>${this.escapeHtml(a.accolade)}</span>
        </div>`
      ).join('');
      return `
        <div style="margin-top:4px;padding:4px 8px;background:linear-gradient(135deg,rgba(245,212,66,0.15),rgba(255,215,0,0.08));border:1px solid rgba(245,212,66,0.3);border-radius:6px;max-width:160px;">
          <div style="font-size:9px;letter-spacing:0.5px;color:rgba(245,212,66,0.9);line-height:1.4;text-align:center;">
            ${items}
          </div>
        </div>`;
    };

    const isHomeOurs = String(this.matchContext.home_team_id) === String(this.teamId);
    const isAwayOurs = String(this.matchContext.away_team_id) === String(this.teamId);

    // Replace "SC" with "⚽ Club" for our team name display
    const formatName = (name) => name.replace(/\bSc$/i, '⚽ Club');

    return `
      <div style="display:flex;align-items:flex-start;justify-content:center;gap:16px;margin-bottom:20px;width:100%;">
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${homeLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:140px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(formatName(homeName))}</div>
          ${buildAccoladeHtml(homeAccolades)}
        </div>
        <div style="flex-shrink:0;padding-top:30px;">
          <div style="font-size:18px;font-weight:800;color:rgba(255,255,255,0.3);letter-spacing:2px;">VS</div>
        </div>
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${awayLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:140px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(formatName(awayName))}</div>
          ${buildAccoladeHtml(awayAccolades)}
        </div>
      </div>
      <div style="height:1px;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:0 auto 10px;"></div>
      <div style="display:flex;flex-direction:column;align-items:center;gap:3px;font-size:12px;color:rgba(255,255,255,0.75);">
        <div style="display:flex;flex-wrap:wrap;justify-content:center;gap:4px 16px;">
          ${dateStr ? `<span>📅 ${this.escapeHtml(dateStr)}</span>` : ''}
          ${timeStr ? `<span>⏰ ${this.escapeHtml(timeStr)}</span>` : ''}
        </div>
        ${venue ? `<div style="text-align:center;line-height:1.3;max-width:90%;">📍 ${this.escapeHtml(venue)}</div>` : ''}
      </div>
    `;
  }

  buildImageScore(homeName, awayName, m, homeLogo, awayLogo) {
    const hs = m.home_team_score ?? m.home_score ?? '?';
    const as = m.away_team_score ?? m.away_score ?? '?';
    const homeLogoHtml = this.buildLogoInnerHtml(homeLogo);
    const awayLogoHtml = this.buildLogoInnerHtml(awayLogo);
    return `
      <div style="display:flex;align-items:center;justify-content:center;gap:20px;margin-bottom:20px;width:100%;">
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${homeLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:130px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(homeName)}</div>
        </div>
        <div style="flex-shrink:0;text-align:center;">
          <div style="font-size:48px;font-weight:800;letter-spacing:4px;color:#ffffff;">${this.escapeHtml(String(hs))} - ${this.escapeHtml(String(as))}</div>
        </div>
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${awayLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:130px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(awayName)}</div>
        </div>
      </div>
    `;
  }

  buildLeagueBadge(league, isCasa, compact) {
    const logoSrc = isCasa ? '/images/leagues/casa.png' : '/images/leagues/apsl.png';
    if (compact) {
      // Small inline badge for lineup / starters & bench
      const bgColor = isCasa ? '#8b0000' : '#0033a0';
      const borderColor = isCasa ? '#cc3333' : '#4488dd';
      return `
        <div style="display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:10px;">
          <img src="${logoSrc}" style="width:22px;height:22px;object-fit:contain;" />
          <span style="font-size:11px;font-weight:700;letter-spacing:1.5px;color:#ffffff;">${this.escapeHtml(league)}</span>
        </div>
      `;
    }
    // Full-size standalone logo + conference text for game_day / post_game
    return `
      <div style="display:flex;flex-direction:column;align-items:center;margin-bottom:8px;gap:4px;">
        <div style="width:52px;height:52px;display:flex;align-items:center;justify-content:center;background:#ffffff;border-radius:10px;border:1px solid rgba(255,255,255,0.18);">
          <img src="${logoSrc}" style="max-width:42px;max-height:46px;object-fit:contain;" />
        </div>
        <span style="font-size:11px;font-weight:700;letter-spacing:2px;color:#ffffff;text-transform:uppercase;">${this.escapeHtml(league)}</span>
      </div>
    `;
  }

  buildVenueString(m) {
    const parts = [];
    if (m.venue_name) parts.push(this.titleCase(m.venue_name));
    if (m.venue_address) parts.push(this.titleCase(m.venue_address));
    if (m.venue_city || m.venue_state) {
      let loc = '';
      if (m.venue_city) loc += this.titleCase(m.venue_city);
      if (m.venue_state) loc += (loc ? ', ' : '') + m.venue_state.toUpperCase();
      if (m.venue_zip) loc += ' ' + m.venue_zip;
      parts.push(loc);
    }
    return parts.join(' \u2022 ');
  }

  titleCase(str) {
    if (!str) return '';
    // Skip words that are already all-caps (abbreviations like SC, FC, NJ, PA, USA)
    // Skip words with internal caps (McDonald, McAnally)
    const skip = /^(of|or|in|at|to|by|an|a)$/i;
    return str.replace(/\b\w+/g, w => {
      if (skip.test(w)) return w.toLowerCase();
      if (w === w.toUpperCase() && w.length <= 4) return w;         // SC, FC, NJ, PA
      if (w !== w.toLowerCase() && w !== w.toUpperCase()) return w;  // McAnally, DeJong
      return w.charAt(0).toUpperCase() + w.slice(1).toLowerCase();
    });
  }

  getGameDayLabel(rawDate) {
    if (!rawDate) return 'MATCH PREVIEW';
    const match = this.parseMatchDisplayDate(rawDate);
    if (!match) return 'MATCH PREVIEW';
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const matchDay = new Date(match.getFullYear(), match.getMonth(), match.getDate());
    const diffDays = Math.round((matchDay - today) / (1000 * 60 * 60 * 24));
    if (diffDays <= 0) return 'GAME DAY';
    if (diffDays === 1) return 'TOMORROW';
    const dayName = match.toLocaleDateString('en-US', { weekday: 'long' }).toUpperCase();
    return `THIS ${dayName}`;
  }

  parseMatchDisplayDate(rawDate) {
    if (!rawDate) return null;
    const s = String(rawDate).trim();

    // Feed timestamps are sometimes tagged +00 but represent local kickoff wall-clock time.
    // For display, keep the same clock time users expect to see.
    if (/(?:Z|\+00(?::?00)?)$/i.test(s)) {
      const m = s.match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?/);
      if (m) {
        const d = new Date(
          Number(m[1]),
          Number(m[2]) - 1,
          Number(m[3]),
          Number(m[4]),
          Number(m[5]),
          Number(m[6] || 0)
        );
        if (!isNaN(d)) return d;
      }
    }

    const d = new Date(s);
    return isNaN(d) ? null : d;
  }

  async waitForMediaReady(timeoutMs = 4000) {
    const start = Date.now();
    while ((Date.now() - start) < timeoutMs) {
      if (this.animCanvas || this.baseImage) return true;
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    return false;
  }

  buildImageRoster() {
    if (!this.rosterData || !this.rosterData.players || !this.rosterData.selectedIds) return '';
    const players = this.rosterData.players;
    const selectedIds = this.rosterData.selectedIds;
    const selected = players.filter(p => selectedIds.has(p.playerId));
    if (selected.length === 0) return '';

    const rows = selected.map(p => {
      const jersey = p.jerseyNumber ? `<span style="color:#ffffff;font-weight:700;font-size:0.9em;min-width:24px;display:inline-block;">#${p.jerseyNumber}</span>` : '';
      const gk = p.isKeeper ? ' <span style="font-size:0.7em;background:rgba(255,255,255,0.15);color:#ffffff;padding:0 4px;border-radius:3px;font-weight:700;">GK</span>' : '';
      return `<div style="display:flex;align-items:center;gap:6px;font-size:11px;padding:1px 0;color:rgba(255,255,255,0.9);">${jersey}<span>${this.escapeHtml(p.firstName)} ${this.escapeHtml(p.lastName)}</span>${gk}</div>`;
    }).join('');

    return `
      <div style="height:1px;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:12px auto;"></div>
      <div style="font-size:10px;text-transform:uppercase;letter-spacing:3px;color:#ffffff;margin-bottom:8px;font-weight:700;">SQUAD</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:2px 16px;text-align:left;width:100%;">
        ${rows}
      </div>
    `;
  }

  attachListeners() {
    const textarea = this.container.querySelector('.spc-caption');
    const charCount = this.container.querySelector('.spc-char-num');
    if (textarea && charCount) {
      textarea.addEventListener('input', () => {
        charCount.textContent = textarea.value.length;
      });
    }

    const scorersInput = this.container.querySelector('.spc-scorers');
    if (scorersInput) {
      scorersInput.addEventListener('input', () => {
        this.scorersText = scorersInput.value;
        if (textarea) {
          textarea.value = this.buildCaption();
          if (charCount) charCount.textContent = textarea.value.length;
        }
        // Regenerate graphic so scorers appear on the image
        this.baseImage = null;
        this.generatedImageUrl = null;
        this.generateCardImage();
      });
    }

    const saveBtn = this.container.querySelector('.spc-btn-save');
    if (saveBtn) {
      saveBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.saveCaption();
      });
    }

    const postBtn = this.container.querySelector('.spc-btn-post');
    if (postBtn) {
      postBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.postNow();
      });
    }

    const schedBtn = this.container.querySelector('.spc-btn-schedule');
    if (schedBtn) {
      schedBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.schedule();
      });
    }

    const dlBtn = this.container.querySelector('.spc-btn-download-video');
    if (dlBtn) {
      dlBtn.addEventListener('click', async (e) => {
        e.stopPropagation();
        dlBtn.disabled = true;
        dlBtn.textContent = '⏳ Recording 5s...';
        await this.downloadVideo();
        dlBtn.textContent = '📹 Download Video';
        dlBtn.disabled = false;
      });
    }
  }

  saveCaption() {
    const textarea = this.container.querySelector('.spc-caption');
    if (!textarea) return;
    const caption = this.normalizeLegacyCaptionText(this.normalizeLegacyCaptionVenue(this.normalizeLegacyCaptionTime(textarea.value.trim())));
    const ptId = this.post?.post_type_id || this.postTypeId;
    if (!ptId) return;

    this.saving = true;
    const saveBtn = this.container.querySelector('.spc-btn-save');
    if (saveBtn) { saveBtn.disabled = true; saveBtn.textContent = '⏳ Saving...'; }

    this.auth.fetch('/api/social/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        match_id: this.matchId,
        team_id: this.teamId,
        post_type_id: ptId,
        caption: caption,
        status: this.post?.status || 'draft'
      })
    }).then(r => r.json()).then(data => {
      this.saving = false;
      if (data.success) {
        if (saveBtn) { saveBtn.textContent = '✅ Saved!'; }
        setTimeout(() => { if (saveBtn) saveBtn.textContent = '💾 Save'; saveBtn.disabled = false; }, 1500);
      } else {
        if (saveBtn) { saveBtn.textContent = '❌ Error'; saveBtn.disabled = false; }
      }
    }).catch(() => {
      this.saving = false;
      if (saveBtn) { saveBtn.textContent = '❌ Error'; saveBtn.disabled = false; }
    });
  }

  async postNow() {
    if (!this.post || !this.post.post_id) return;
    if (!confirm('Post this to Instagram now?')) return;

    const postBtn = this.container.querySelector('.spc-btn-post');
    if (postBtn) { postBtn.disabled = true; postBtn.textContent = '⏳ Recording video...'; }

    try {
      // Persist the visible caption before publish so the post text matches the preview.
      const textarea = this.container.querySelector('.spc-caption');
      const currentCaption = this.normalizeLegacyCaptionText(this.normalizeLegacyCaptionVenue(this.normalizeLegacyCaptionTime(textarea ? textarea.value.trim() : (this.post?.caption || ''))));
      const ptId = this.post?.post_type_id || this.postTypeId;
      if (ptId && currentCaption) {
        await this.auth.fetch('/api/social/posts', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            match_id: this.matchId,
            team_id: this.teamId,
            post_type_id: ptId,
            caption: currentCaption,
            status: this.post?.status || 'draft'
          })
        });
      }

      let mediaData;

      // If preview media is not ready yet, try generating it now.
      if (!this.animCanvas && !this.baseImage) {
        if (postBtn) postBtn.textContent = '⏳ Generating preview...';
        await this.generateImage();
        await this.waitForMediaReady(5000);
      }

      if (this.animCanvas) {
        // Record a compact WebM clip to keep upload payload under proxy limits.
        mediaData = await new Promise((resolve, reject) => {
          const stream = this.animCanvas.captureStream(24);
          const recorder = new MediaRecorder(stream, {
            mimeType: MediaRecorder.isTypeSupported('video/webm;codecs=vp9') ? 'video/webm;codecs=vp9' : 'video/webm',
            videoBitsPerSecond: 1200000
          });
          const chunks = [];
          recorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
          recorder.onstop = () => {
            const blob = new Blob(chunks, { type: recorder.mimeType });
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result); // data:video/webm;base64,...
            reader.onerror = () => reject(new Error('Failed to read video'));
            reader.readAsDataURL(blob);
          };
          recorder.onerror = () => reject(new Error('Recording failed'));
          recorder.start();
          // Keep duration short to avoid 413 (base64 JSON body through nginx).
          setTimeout(() => recorder.stop(), 5000);
        });
      } else if (this.baseImage) {
        // Fallback: static image
        const tmpCvs = document.createElement('canvas');
        tmpCvs.width = this.baseImage.width;
        tmpCvs.height = this.baseImage.height;
        tmpCvs.getContext('2d').drawImage(this.baseImage, 0, 0);
        mediaData = tmpCvs.toDataURL('image/png');
      }

      const hasExistingMedia = !!(this.post && this.post.image_url);
      if (!mediaData && !hasExistingMedia) {
        alert('No media generated yet. Please wait a moment and try again.');
        if (postBtn) { postBtn.disabled = false; postBtn.textContent = '📸 Post Now'; }
        return;
      }

      // Step 1: Upload media to backend if we produced fresh media.
      if (mediaData) {
        if (postBtn) postBtn.textContent = '⏳ Uploading...';
        const uploadRes = await this.auth.fetch(`/api/social/posts/${this.post.post_id}/media`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ data: mediaData })
        });
        const uploadText = await uploadRes.text();
        let uploadData = null;
        try {
          uploadData = uploadText ? JSON.parse(uploadText) : null;
        } catch (_) {
          uploadData = null;
        }
        if (!uploadRes.ok || !uploadData || !uploadData.success) {
          const uploadMsg = (uploadData && uploadData.message)
            ? uploadData.message
            : `HTTP ${uploadRes.status}${uploadText ? `: ${uploadText.slice(0, 200)}` : ''}`;
          alert('Upload failed: ' + uploadMsg);
          return;
        }
      }

      // Step 2: Publish to Instagram
      if (postBtn) postBtn.textContent = '⏳ Publishing to Instagram...';
      const pubRes = await this.auth.fetch(`/api/social/posts/${this.post.post_id}/publish`, {
        method: 'POST'
      });
      const pubText = await pubRes.text();
      let pubData = null;
      try {
        pubData = pubText ? JSON.parse(pubText) : null;
      } catch (_) {
        pubData = null;
      }
      if (!pubRes.ok || !pubData) {
        const pubMsg = `HTTP ${pubRes.status}${pubText ? `: ${pubText.slice(0, 200)}` : ''}`;
        alert('Publish failed: ' + pubMsg);
        return;
      }
      if (pubData.success) {
        alert('Posted to Instagram! 🎉');
        this.load();
      } else {
        alert('Publish failed: ' + pubData.message);
      }
    } catch (err) {
      alert('Error: ' + err.message);
    } finally {
      if (postBtn) { postBtn.disabled = false; postBtn.textContent = '📸 Post Now'; }
    }
  }

  schedule() {
    const ptId = this.post?.post_type_id || this.postTypeId;
    if (!ptId) return;
    const input = this.container.querySelector('.spc-schedule-input');
    if (!input || !input.value) {
      alert('Pick a date and time first.');
      return;
    }
    const datetime = input.value.replace('T', ' ');

    // Save current caption too
    const textarea = this.container.querySelector('.spc-caption');
    const caption = this.normalizeLegacyCaptionText(this.normalizeLegacyCaptionVenue(this.normalizeLegacyCaptionTime(textarea ? textarea.value.trim() : (this.post?.caption || ''))));

    const schedBtn = this.container.querySelector('.spc-btn-schedule');
    if (schedBtn) { schedBtn.disabled = true; schedBtn.textContent = '⏳ Scheduling...'; }

    this.auth.fetch('/api/social/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        match_id: this.matchId,
        team_id: this.teamId,
        post_type_id: ptId,
        caption: caption,
        status: 'scheduled',
        scheduled_at: datetime + ':00'
      })
    }).then(r => r.json()).then(data => {
      if (data.success) this.load();
      else {
        alert('Failed to schedule: ' + data.message);
        if (schedBtn) { schedBtn.disabled = false; schedBtn.textContent = '📅 Schedule'; }
      }
    });
  }

  toLocalISOString(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    if (isNaN(d)) return '';
    const pad = n => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }

  formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  }

  normalizeLegacyCaptionText(caption) {
    if (!caption) return caption;
    // Remove standalone "Let's go! 🔥" lines (and variants)
    return String(caption).replace(/^Let's go! ?🔥\s*\n?/mu, '').replace(/\n\nLet's go! ?🔥/gu, '');
  }

  normalizeLegacyCaptionVenue(caption) {
    if (!caption) return caption;
    const m = this.matchContext;
    if (!m) return caption;
    // Build the full venue string (name + address)
    const fullVenue = this.buildVenueString(m);
    if (!fullVenue) return caption;
    // If the 📍 line already contains the full string, nothing to do
    const lines = String(caption).split('\n');
    let replaced = false;
    const updated = lines.map(line => {
      if (!/^\s*📍\s+/u.test(line)) return line;
      if (line.includes(fullVenue)) return line; // already up to date
      // Replace whatever follows 📍 with the full venue string
      replaced = true;
      return line.replace(/^(\s*📍\s+).+$/, `$1${fullVenue}`);
    });
    return replaced ? updated.join('\n') : caption;
  }

  normalizeLegacyCaptionTime(caption) {
    if (!caption) return caption;

    const rawDate = this.matchContext?.event_date || this.matchContext?.date || this.matchContext?.match_date;
    if (!rawDate) return caption;

    const expected = this.parseMatchDisplayDate(rawDate);
    const legacy = new Date(rawDate);
    if (!expected || isNaN(legacy)) return caption;

    const expectedTime = expected.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    const legacyTime = legacy.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    if (!expectedTime || !legacyTime || expectedTime === legacyTime) return caption;

    const lines = String(caption).split('\n');
    let replaced = false;
    const updated = lines.map(line => {
      if (/^\s*⏰\s+/u.test(line) && line.includes(legacyTime)) {
        replaced = true;
        return line.replace(legacyTime, expectedTime);
      }
      return line;
    });

    return replaced ? updated.join('\n') : caption;
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
