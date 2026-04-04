// SocialPostCard - Instagram-style social media post preview card
// Auto-generates caption from match context on load. Editable inline.
class SocialPostCard {
  constructor(auth) {
    this.auth = auth;
    this.post = null;
    this.container = null;
    this.matchId = null;
    this.teamId = null;
    this.postTypeName = null;
    this.matchContext = null;
    this.postTypeId = null;
    this.saving = false;
    this.rosterData = null;
    this.generatedImageUrl = null;
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

    Promise.all([
      this.auth.fetch(`/api/social/match/${this.matchId}/team/${this.teamId}`).then(r => r.json()),
      this.auth.fetch('/api/social/post-types').then(r => r.json())
    ]).then(([postsData, typesData]) => {
      if (postsData.success) {
        const posts = postsData.data || [];
        this.post = posts.find(p => p.post_type === this.postTypeName) || null;
      }
      if (typesData.success) {
        const pt = (typesData.data || []).find(t => t.name === this.postTypeName);
        if (pt) this.postTypeId = pt.id;
      }

      // Auto-generate if no existing post
      if (!this.post || this.post.post_id === null) {
        this.autoGenerate();
      } else {
        this.render();
      }
    }).catch(() => {
      this.container.innerHTML = '';
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
      const d = new Date(rawDate);
      if (!isNaN(d)) {
        dateStr = d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
        timeStr = d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
      }
    }
    const venue = this.titleCase(m.venue_name || 'TBD');
    const league = m.competition_name || 'APSL';

    switch (this.postTypeName) {
      case 'pre_match_announcement':
        return `⚔️ STARTERS & BENCH\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893 #APSL #PhillySoccer #StartingXI`;
      case 'game_day':
        return `⚽ GAME DAY!\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\nLet's go! 🔥\n\n#Lighthouse1893 #APSL #GameDay #PhillySoccer`;
      case 'lineup':
        return `📋 MATCH DAY SQUAD\n\n${homeName} vs ${awayName}\n${league} ⚽\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893 #APSL #MatchDaySquad #PhillySoccer`;
      case 'post_game': {
        const hs = m.home_team_score ?? m.home_score ?? '?';
        const as = m.away_team_score ?? m.away_score ?? '?';
        const result = Number(hs) > Number(as) ? '🟢 WIN' : Number(hs) < Number(as) ? '🔴 LOSS' : '🟡 DRAW';
        return `${result}\n\n${homeName} ${hs} - ${as} ${awayName}\n${league} ⚽\n📅 ${dateStr}\n\n#Lighthouse1893 #APSL #PhillySoccer #MatchResult`;
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
    const caption = (hasContent && p.caption) ? p.caption : this.buildCaption();

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
    } else if (this.generatedImageUrl) {
      imageHtml = `<div class="spc-image"><img src="${this.generatedImageUrl}" alt="Post image"></div>`;
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
          <textarea class="spc-caption" rows="6" ${isPosted ? 'disabled' : ''}>${this.escapeHtml(caption)}</textarea>
          <div class="spc-char-count"><span class="spc-char-num">${caption.length}</span> / 2,200</div>
        </div>
        <div class="spc-actions">
          ${!isPosted ? `
            <button class="spc-btn spc-btn-save" ${this.saving ? 'disabled' : ''}>💾 Save</button>
            <button class="spc-btn spc-btn-schedule">📅 Schedule</button>
            <button class="spc-btn spc-btn-post">🚀 Post Now</button>
          ` : ''}
        </div>
      </div>
    `;

    this.attachListeners();

    // Auto-generate image if none exists
    if (!(hasContent && p.image_url) && !this.generatedImageUrl) {
      this.generateImage();
    }
  }

  async generateImage() {
    if (typeof html2canvas === 'undefined') return;

    const m = this.matchContext;
    const homeName = this.titleCase(m.home_team_name || m.homeTeam || 'Home');
    const awayName = this.titleCase(m.away_team_name || m.awayTeam || 'Away');
    const homeLogo = m.home_team_logo || '';
    const awayLogo = m.away_team_logo || '';
    const rawDate = m.event_date || m.date || m.match_date;
    let dateStr = '', timeStr = '';
    if (rawDate) {
      const d = new Date(rawDate);
      if (!isNaN(d)) {
        dateStr = d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
        timeStr = d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
      }
    }
    const venueStr = this.buildVenueString(m);
    const isCasa = (m.source_name === 'casa');
    // Determine league display name
    let league;
    if (isCasa) {
      const div = m.division_name || '';
      if (/liga\s*2/i.test(div)) league = 'CASA Select Liga 2';
      else league = 'CASA Select Liga 1';
    } else {
      league = 'Delaware River Conference';
    }

    // Build post-type-specific content
    let headerText = '', middleHtml = '', rosterHtml = '', leagueBadgeHtml = '';
    switch (this.postTypeName) {
      case 'game_day':
        headerText = 'GAME DAY';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, false);
        break;
      case 'lineup':
        headerText = 'MATCH DAY SQUAD';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo);
        leagueBadgeHtml = this.buildLeagueBadge(league, isCasa, true);
        rosterHtml = this.buildImageRoster();
        break;
      case 'pre_match_announcement':
        headerText = 'STARTERS & BENCH';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo);
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
        display:flex; flex-direction:column; justify-content:center; align-items:center;
        padding:${hasRoster ? '30px 28px 20px' : '40px 30px'};
        box-sizing:border-box;
        border:4px solid #f5d442;
      ">

        <!-- Header -->
        <div style="font-size:12px;text-transform:uppercase;letter-spacing:5px;color:#ffffff;margin-bottom:${hasRoster ? '10px' : leagueBadgeHtml ? '10px' : '24px'};font-weight:700;">
          ${this.escapeHtml(headerText)}
        </div>

        ${leagueBadgeHtml}

        ${middleHtml}

        ${rosterHtml}

        <!-- Footer -->
        <div style="margin-top:auto;padding-top:0;display:flex;flex-direction:column;align-items:center;gap:2px;">
          <img src="/images/sponsors/welovejunk.png" style="height:120px;object-fit:contain;" />
          <span style="font-size:9px;letter-spacing:1px;color:#ffffff;text-transform:uppercase;font-weight:600;">Sponsored by We Love Junk Philly</span>
          <span style="font-size:11px;letter-spacing:2px;color:#f5d442;text-transform:uppercase;font-weight:700;">LIGHTHOUSE 1893 ⚽ CLUB</span>
        </div>
      </div>
    `;

    document.body.appendChild(wrapper);

    try {
      const canvas = await html2canvas(wrapper.firstElementChild, { backgroundColor: null, scale: 2, useCORS: true });
      this.generatedImageUrl = canvas.toDataURL('image/png');
      // Update the image area
      const imageArea = this.container.querySelector('#spc-image-area');
      if (imageArea) {
        imageArea.className = 'spc-image';
        imageArea.innerHTML = `<img src="${this.generatedImageUrl}" alt="Post image">`;
      }
    } catch (err) {
      console.error('Image generation failed:', err);
    } finally {
      document.body.removeChild(wrapper);
    }
  }

  buildImageMatchup(homeName, awayName, dateStr, timeStr, venue, homeLogo, awayLogo) {
    const homeLogoHtml = homeLogo
      ? `<img src="${this.escapeHtml(homeLogo)}" alt="" style="max-width:100%;max-height:100%;object-fit:contain;">`
      : `<span style="font-size:2em;">⚽</span>`;
    const awayLogoHtml = awayLogo
      ? `<img src="${this.escapeHtml(awayLogo)}" alt="" style="max-width:100%;max-height:100%;object-fit:contain;">`
      : `<span style="font-size:2em;">⚽</span>`;
    return `
      <div style="display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:20px;width:100%;">
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${homeLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:130px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(homeName)}</div>
        </div>
        <div style="flex-shrink:0;">
          <div style="font-size:18px;font-weight:800;color:rgba(255,255,255,0.3);letter-spacing:2px;">VS</div>
        </div>
        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;">
          <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,0.12);border-radius:12px;border:1px solid rgba(255,255,255,0.18);padding:4px;box-sizing:border-box;">${awayLogoHtml}</div>
          <div style="font-size:13px;font-weight:700;max-width:130px;line-height:1.2;text-transform:uppercase;letter-spacing:0.5px;">${this.escapeHtml(awayName)}</div>
        </div>
      </div>
      <div style="height:1px;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:0 auto 16px;"></div>
      <div style="display:flex;flex-direction:column;align-items:center;gap:4px;font-size:12px;color:rgba(255,255,255,0.75);">
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
    const homeLogoHtml = homeLogo
      ? `<img src="${this.escapeHtml(homeLogo)}" alt="" style="max-width:100%;max-height:100%;object-fit:contain;">`
      : `<span style="font-size:2em;">⚽</span>`;
    const awayLogoHtml = awayLogo
      ? `<img src="${this.escapeHtml(awayLogo)}" alt="" style="max-width:100%;max-height:100%;object-fit:contain;">`
      : `<span style="font-size:2em;">⚽</span>`;
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
      <div style="display:flex;flex-direction:column;align-items:center;margin-bottom:16px;gap:6px;">
        <div style="width:72px;height:72px;display:flex;align-items:center;justify-content:center;background:#ffffff;border-radius:12px;border:1px solid rgba(255,255,255,0.18);">
          <img src="${logoSrc}" style="max-width:56px;max-height:60px;object-fit:contain;" />
        </div>
        <span style="font-size:12px;font-weight:700;letter-spacing:2px;color:#ffffff;text-transform:uppercase;">${this.escapeHtml(league)}</span>
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
  }

  saveCaption() {
    const textarea = this.container.querySelector('.spc-caption');
    if (!textarea) return;
    const caption = textarea.value.trim();
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

  postNow() {
    if (!this.post || !this.post.post_id) return;
    if (!confirm('Post this to Instagram now?')) return;

    this.auth.fetch(`/api/social/posts/${this.post.post_id}/publish`, {
      method: 'POST'
    }).then(r => r.json()).then(data => {
      if (data.success) {
        alert('Marked for posting!');
        this.load();
      } else {
        alert('Failed: ' + data.message);
      }
    });
  }

  schedule() {
    const ptId = this.post?.post_type_id || this.postTypeId;
    if (!ptId) return;
    const datetime = prompt('Schedule post at (YYYY-MM-DD HH:MM):');
    if (!datetime) return;
    if (!/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}$/.test(datetime.trim())) {
      alert('Format: YYYY-MM-DD HH:MM');
      return;
    }

    // Save current caption too
    const textarea = this.container.querySelector('.spc-caption');
    const caption = textarea ? textarea.value.trim() : (this.post?.caption || '');

    this.auth.fetch('/api/social/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        match_id: this.matchId,
        team_id: this.teamId,
        post_type_id: ptId,
        caption: caption,
        status: 'scheduled',
        scheduled_at: datetime.trim() + ':00'
      })
    }).then(r => r.json()).then(data => {
      if (data.success) this.load();
      else alert('Failed to schedule: ' + data.message);
    });
  }

  formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
