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
    this.playersPlayedText = '';
    this.postTypeName = null;
    this.matchContext = null;
    this.postTypeId = null;
    this.saving = false;
    this.rosterData = null;
    this.generatedImageUrl = null;
    this.baseImage = null;       // base card without beam (Image object)
    this.animCanvas = null;      // live animated canvas
    this._stopLighthouseAnim = null; // stop fn from LighthouseBeam.animate()
    this.animStartTime = null;   // persisted start time so beam angle survives re-renders
    this.imageError = false;
    this.imageErrorMessage = null; // actual err.message shown on screen when generation fails
    this.cardWidth = 540;
    this.cardHeight = 540;
  }

  resolveAssetUrl(url) {
    if (!url) return '';

    const trimmed = String(url).trim();
    if (!trimmed) return '';

    // Route known external logo hosts through our own proxy (2026-08-22:
    // apslsoccer.com — Lighthouse's own crest — and r2.thesportsdb.com —
    // e.g. Real Central NJ, via opponent_logo_cache) so html2canvas's
    // cross-origin <img> fetch always gets CORS headers instead of either
    // rendering as a blank box or hanging the whole image-generation step
    // waiting on a server that never sends Access-Control-Allow-Origin.
    // Keep this list in sync with SocialController::handleLogoProxy's
    // allowlist — covers every host actually in teams.logo_url /
    // opponent_logo_cache today (verified via DB query).
    if (/^https:\/\/(se-team-service-production\.s3\.amazonaws\.com|www\.apslsoccer\.com|r2\.thesportsdb\.com)\//i.test(trimmed)) {
      return `/api/social/logo-proxy?url=${trimmed}`;
    }

    if (/^(https?:|data:|blob:)/i.test(trimmed)) return trimmed;
    return trimmed.startsWith('/') ? trimmed : `/${trimmed.replace(/^\/+/, '')}`;
  }

  // Pre-fetch a proxied logo as an authenticated blob and hand back a
  // blob: URL (2026-08-22, owner: "still getting image generation
  // failed. still has all these white slots for no reason") — the real
  // bug behind BOTH complaints: /api/social/logo-proxy requires a Bearer
  // token (SocialController::requireAdminLevel), but a plain <img src>
  // can never send one, so every proxied crest (apslsoccer.com,
  // thesportsdb.com) has always 401'd inside html2canvas's clone and
  // silently fallen back to the placeholder icon — that's the blank/
  // wrong-looking "white slot" box. Fetching with this.auth.fetch()
  // (which does attach the header) sidesteps that entirely. Only
  // proxy-eligible hosts need this — everything else still resolves
  // synchronously via resolveAssetUrl.
  async resolveImageForCanvas(url) {
    if (!url) return '';
    const trimmed = String(url).trim();
    if (!trimmed) return '';
    if (/^https:\/\/(se-team-service-production\.s3\.amazonaws\.com|www\.apslsoccer\.com|r2\.thesportsdb\.com)\//i.test(trimmed)) {
      // Hard timeout (2026-08-22, owner: "image gen failed again") — this
      // fetch has no built-in timeout of its own, and it runs BEFORE
      // generateImage()'s existing html2canvas timeout even starts, so a
      // stalled outbound request to the external logo host (our own
      // server's fetch, not the browser's) would otherwise hang the whole
      // generation with no escape. Falling back to the placeholder icon
      // beats hanging forever.
      const withTimeout = (promise, ms) => Promise.race([
        promise,
        new Promise((_, reject) => setTimeout(() => reject(new Error('Logo proxy fetch timed out')), ms)),
      ]);
      try {
        const res = await withTimeout(
          this.auth.fetch(`/api/social/logo-proxy?url=${encodeURIComponent(trimmed)}`),
          8000
        );
        if (!res.ok) return '';
        const blob = await withTimeout(res.blob(), 8000);
        // data: URI, not a blob: object URL (2026-08-23, owner: "failed
        // to execute create pattern on canvas etc") — that's the actual
        // browser exception this was throwing: html2canvas's internal
        // image-ready check doesn't reliably wait for blob: URLs to
        // finish loading/decoding the way it does for normal URLs and
        // data: URIs, so it could hand a still-zero-size <img> to
        // ctx.createPattern(), which throws exactly that error. A data:
        // URI is available synchronously once this promise resolves —
        // no separate async decode step for html2canvas to race with.
        return await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = () => reject(new Error('Failed to read logo blob'));
          reader.readAsDataURL(blob);
        });
      } catch (e) {
        console.error('Logo proxy fetch failed:', e);
        return '';
      }
    }
    // Any OTHER external (cross-origin) URL must never reach html2canvas
    // directly (2026-08-23, owner: "same" — the createPattern error was
    // still happening after fixing the known 3 proxy hosts) — the
    // allowlist above only covers hosts seen in the DB at the time it
    // was written; a newly-scraped opponent_logo_cache row can point
    // anywhere. An un-proxied cross-origin <img> taints/breaks inside
    // html2canvas's capture the exact same way the original apslsoccer.com
    // gap did, throwing that same createPattern exception. Fall back to
    // the placeholder icon instead of ever risking that — a missing crest
    // beats a broken whole-image generation.
    if (/^https?:\/\//i.test(trimmed) && !trimmed.startsWith(location.origin + '/')) {
      return '';
    }
    return this.resolveAssetUrl(trimmed);
  }

  // Sub-pixel gradient guard (2026-08-24, owner: "got this on post to
  // instagram ... InvalidStateError: Failed to execute 'createPattern'
  // ... width or height of 0") — the real mechanism, finally pinned by
  // reading html2canvas 1.4.1's renderBackgroundImage(): it paints a CSS
  // gradient by creating a scratch canvas sized to the element's
  // background area, and its only guard is `width > 0 && height > 0`.
  // But it assigns those FRACTIONAL CSS pixels straight to
  // canvas.width/height, which truncate — so any size between 0 and 1
  // sails past the guard and yields a 0x0 canvas, and createPattern()
  // throws exactly that InvalidStateError.
  //
  // How the card gets there: the post card is a fixed-height flex
  // column, so the moment its content overflows (a match with lots of
  // goalscorers, a long venue, an extra accolade line) every flex item
  // shrinks a little — and a 1px gradient divider only has to lose a
  // hundredth of a pixel to become 0.99 and blow up the whole capture.
  // That's why this error kept coming back on some matches and not
  // others. The dividers now carry flex-shrink:0 so they can't get
  // there; this pass is the backstop for any gradient added later.
  //
  // Nudging the element back up to a whole pixel is preferred over
  // dropping its background — the divider stays visible. Only if it
  // still measures sub-pixel does the background go, because an
  // invisible hairline beats a failed post.
  hardenGradientsForCapture(root) {
    if (!root) return;
    const patched = [];
    for (const el of [root, ...root.querySelectorAll('*')]) {
      const cs = window.getComputedStyle(el);
      if (!cs.backgroundImage || cs.backgroundImage === 'none') continue;
      if (cs.display === 'none') continue;
      // Set unconditionally, and as an INLINE style, because that is the
      // part that survives into html2canvas's clone. The measurements
      // below happen in the live document; the clone lays out in its own
      // iframe and can land on slightly different sizes, so a guard that
      // only reacted to what we can measure here would miss a divider
      // that goes sub-pixel over there. flex-shrink:0 removes the
      // mechanism itself in both documents.
      el.style.flexShrink = '0';
      const before = el.getBoundingClientRect();
      if (before.width >= 1 && before.height >= 1) continue;
      if (before.width === 0 && before.height === 0) continue; // not laid out at all
      if (before.height < 1) el.style.minHeight = '1px';
      if (before.width < 1) el.style.minWidth = '1px';
      const after = el.getBoundingClientRect();
      let dropped = false;
      if (after.width < 1 || after.height < 1) {
        el.style.backgroundImage = 'none';
        dropped = true;
      }
      patched.push(`<${el.tagName.toLowerCase()}> ${before.width.toFixed(2)}x${before.height.toFixed(2)}` +
        ` -> ${after.width.toFixed(2)}x${after.height.toFixed(2)}${dropped ? ' (background dropped)' : ''}`);
    }
    if (patched.length) {
      console.warn('[SocialPostCard] sub-pixel gradient element(s) html2canvas would have thrown on:', patched);
    }
  }

  // Length of the posted clip, and how long one beam sweep takes inside
  // it — see LighthouseBeam for why the clip must stay a whole multiple
  // of the rotation (today: 30s of clip, 2 x 15s sweeps).
  postClipSeconds() {
    return (window.LighthouseBeam && window.LighthouseBeam.POST_CLIP_SECONDS) || 30;
  }

  beamRotationSeconds() {
    return (window.LighthouseBeam && window.LighthouseBeam.BEAM_ROTATION_SECONDS) || 15;
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

    const allEventsPromise = this.postTypeName === 'post_game'
      ? this.auth.fetch(`/api/stats/matches/${this.matchId}/events`).then(r => r.json()).catch(() => ({ data: [] }))
      : Promise.resolve({ data: [] });

    Promise.all([
      this.auth.fetch(`/api/social/match/${this.matchId}/team/${this.teamId}`).then(r => r.json()),
      this.auth.fetch('/api/social/post-types').then(r => r.json()),
      statsPromise,
      allEventsPromise
    ]).then(([postsData, typesData, statsData, eventsData]) => {
      if (postsData.success) {
        const posts = postsData.data || [];
        this.post = posts.find(p => p.post_type === this.postTypeName) || null;
      }
      if (typesData.success) {
        const pt = (typesData.data || []).find(t => t.name === this.postTypeName);
        if (pt) this.postTypeId = pt.id;
      }
      this.matchStats = (statsData && statsData.success) ? (statsData.data || []) : [];

      // Auto-populate playersPlayedText from lineup (starters + subs) for our team
      if (this.postTypeName === 'post_game' && !this.playersPlayedText) {
        const allEvents = (eventsData && eventsData.data) ? eventsData.data : [];
        const teamName = (this.matchContext.home_team_id && String(this.matchContext.home_team_id) === String(this.teamId))
          ? this.matchContext.home_team_name
          : this.matchContext.away_team_name;
        const normalize = s => (s || '').toLowerCase().trim();

        const ourStarters = allEvents
          .filter(e => e.event_type === 'starter' && normalize(e.team_name) === normalize(teamName))
          .map(e => e.player_name);
        const ourSubs = allEvents
          .filter(e => e.event_type === 'sub_listed' && normalize(e.team_name) === normalize(teamName))
          .map(e => e.player_name);

        const lines = [];
        if (ourStarters.length > 0) lines.push(...ourStarters);
        if (ourSubs.length > 0) {
          if (lines.length > 0) lines.push('--- Subs ---');
          lines.push(...ourSubs);
        }
        if (lines.length > 0) this.playersPlayedText = lines.join('\n');
      }

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

  // Parse freeform scorers text into box score format:
  // "23' John Smith" → ⚽ John Smith
  // Two lines with same name → ⚽⚽ John Smith
  // "67' Bob Jones yellow" → 🟨 Bob Jones
  parseScorersBoxScore(text) {
    if (!text || !text.trim()) return '';
    const lines = text.trim().split('\n').map(s => s.trim()).filter(Boolean);
    const goalMap = new Map(); // key: lowercase name → {name, count, isOG}
    const cardLines = [];

    for (const line of lines) {
      // Strip leading time prefix e.g. "23' " or "45+"
      const clean = line.replace(/^\d+[+']?\s*/, '').trim();
      if (/yellow|🟨/i.test(clean)) {
        const name = clean.replace(/\(?yellow\s*card?\)?|🟨/gi, '').replace(/[()]/g, '').trim();
        if (name) cardLines.push({ type: 'yellow', name });
      } else if (/\bred\b|🟥/i.test(clean)) {
        const name = clean.replace(/\(?red\s*card?\)?|🟥/gi, '').replace(/[()]/g, '').trim();
        if (name) cardLines.push({ type: 'red', name });
      } else {
        const isOG = /\bOG\b|\bown\s*goal\b/i.test(clean);
        const name = clean.replace(/\bOG\b|\bown\s*goal\b/gi, '').replace(/\(assist:[^)]*\)/gi, '').replace(/[()]/g, '').trim();
        if (!name) continue;
        const key = name.toLowerCase();
        if (goalMap.has(key)) {
          goalMap.get(key).count++;
        } else {
          goalMap.set(key, { name, count: 1, isOG });
        }
      }
    }

    const result = [];
    for (const [, { name, count, isOG }] of goalMap) {
      result.push(`${'⚽'.repeat(count)}${isOG ? ' (OG)' : ''} ${name}`);
    }
    for (const { type, name } of cardLines) {
      result.push(`${type === 'yellow' ? '🟨' : '🟥'} ${name}`);
    }
    return result.join('\n');
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
    // For calendar-synced matches with no away_team linked, parse from title
    if (awayName === 'Away' && m.title && / vs /i.test(m.title)) {
      awayName = m.title.split(/ vs /i)[1]?.trim() || 'Away';
    }

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
    // Prefer the authoritative League: gcal tag (migration 297) — see
    // generateImage()'s matching hasLeagueTag branch — over
    // competition_name, which is often just the source system's raw
    // name (e.g. "INTERNAL" for scraped/manual matches, not a real
    // league label). source_name is empty for calendar-synced (women's)
    // matches — no APSL/CASA default there.
    const league = (m.league_tag && m.league_tag.trim()) || m.competition_name || (m.source_name ? 'APSL' : '');
    const isCASA = /casa/i.test(league);
    const leagueTag = league ? (isCASA ? '#CASA' : '#APSL') : '';
    const leagueLine = league ? `\n${league} ⚽` : '';

    switch (this.postTypeName) {
      case 'pre_match_announcement':
        return `⚔️ STARTERS & BENCH\n\n${homeName} vs ${awayName}${leagueLine}\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893${leagueTag ? ' ' + leagueTag : ''} #PhillySoccer #StartingXI`;
      case 'game_day': {
        const gameDayLabel = this.getGameDayLabel(rawDate);
        const gameDayEmoji = gameDayLabel === 'GAME DAY' ? '' : gameDayLabel === 'TOMORROW' ? 'See you there! 💪' : 'Mark your calendars! 📌';
        return `⚽ ${gameDayLabel}!\n\n${homeName} vs ${awayName}${leagueLine}\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}${gameDayEmoji ? '\n\n' + gameDayEmoji : ''}\n\n#Lighthouse1893${leagueTag ? ' ' + leagueTag : ''} #GameDay #PhillySoccer`;
      }
      case 'lineup':
        return `📋 MATCH DAY SQUAD\n\n${homeName} vs ${awayName}${leagueLine}\n📅 ${dateStr}\n⏰ ${timeStr}\n📍 ${venue}\n\n#Lighthouse1893${leagueTag ? ' ' + leagueTag : ''} #MatchDaySquad #PhillySoccer`;
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
          // Group goals by player, show ⚽⚽ for multiples
          const goals = stats.filter(s => s.event_type === 'goal' || s.event_type === 'own_goal');
          const cards = stats.filter(s => s.event_type === 'yellow_card' || s.event_type === 'red_card');
          const eventLines = [];
          if (goals.length > 0) {
            const goalMap = new Map();
            goals.forEach(g => {
              const key = String(g.player_id || g.player_name);
              if (goalMap.has(key)) {
                goalMap.get(key).count++;
              } else {
                goalMap.set(key, { name: g.player_name, count: 1, isOG: g.event_type === 'own_goal', assist: g.assist_player_name });
              }
            });
            for (const [, { name, count, isOG, assist }] of goalMap) {
              const og = isOG ? ' (OG)' : '';
              const ast = assist ? ` (assist: ${assist})` : '';
              eventLines.push(`${'⚽'.repeat(count)}${og} ${name}${ast}`);
            }
          }
          if (cards.length > 0) {
            cards.forEach(c => {
              eventLines.push(`${c.event_type === 'yellow_card' ? '🟨' : '🟥'} ${c.player_name}`);
            });
          }
          if (eventLines.length > 0) statsLines = '\n\n' + eventLines.join('\n');
        } else if (this.scorersText && this.scorersText.trim()) {
          // Manual scorers — parse into box score format
          const boxScore = this.parseScorersBoxScore(this.scorersText);
          if (boxScore) statsLines = '\n\n' + boxScore;
        }
        return `${result}\n\n${homeName} ${hs} - ${as} ${awayName}${leagueLine}\n📅 ${dateStr}\n📍 ${venue}${statsLines}\n\n#Lighthouse1893${leagueTag ? ' ' + leagueTag : ''} #PhillySoccer`;
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
    } else if (this.imageError) {
      imageHtml = `
        <div class="spc-image spc-image-placeholder" id="spc-image-area">
          <div class="spc-image-placeholder-inner">
            <span style="font-size:1.5em;">⚠️</span>
            <span>Image generation failed — tap Regenerate below</span>
            ${this.imageErrorMessage ? `<span style="font-size:0.75em; opacity:0.8; font-family:monospace;">${this.escapeHtml(this.imageErrorMessage)}</span>` : ''}
          </div>
        </div>`;
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
            <label class="spc-scorers-label">⚽ Scorers &amp; cards (one per line → caption)</label>
            <textarea class="spc-scorers" rows="3" placeholder="e.g. 23' John Smith&#10;67' John Smith&#10;45' Bob Jones yellow">${this.escapeHtml(this.scorersText || '')}</textarea>
          </div>
          <div class="spc-scorers-row">
            <label class="spc-scorers-label">👥 Players who played (one per line → graphic)</label>
            <textarea class="spc-players-played" rows="5" placeholder="e.g. John Smith&#10;Jane Doe&#10;Bob Jones">${this.escapeHtml(this.playersPlayedText || '')}</textarea>
          </div>` : ''}
          <textarea class="spc-caption" rows="6" ${isPosted ? 'disabled' : ''}>${this.escapeHtml(caption)}</textarea>
          <div class="spc-char-count"><span class="spc-char-num">${caption.length}</span> / 2,200</div>
        </div>
        <div class="spc-actions">
          ${!isPosted ? `
            <button class="spc-btn spc-btn-regen">🔄 Regenerate</button>
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

    // Re-attach the animated canvas to the fresh #spc-image-area div this
    // render() call just created (2026-08-22, owner: "image gen failed
    // again" — reproduced live: after Schedule/Save, the preview that had
    // been rendering fine goes completely blank). render() always rebuilds
    // the DOM from a string, which discards whatever <canvas> a prior
    // startAnimatedPreview() call inserted — this.animCanvas/this.baseImage
    // (the JS objects) survive fine, but nothing ever re-mounts the canvas
    // element unless this runs again. The old `!hasContent` guard was
    // backwards: hasContent just means a draft post ROW exists in the DB
    // (true almost immediately after load, well before any image is
    // actually uploaded), so it skipped the remount in nearly every real
    // case. Condition now mirrors the imageHtml branch above exactly:
    // remount whenever we're showing the generated-but-not-yet-uploaded
    // image (this.baseImage set, and NOT already displaying a real
    // uploaded p.image_url).
    if (this.baseImage && !(hasContent && p.image_url)) {
      this.startAnimatedPreview();
    }

    // Auto-generate image if none exists
    if (!(hasContent && p.image_url) && !this.baseImage) {
      this.generateImage();
    }
  }

  // Retries once before ever showing the user a stuck error state
  // (2026-08-23, owner: repeated "image gen failed" on both matches
  // that I could never once reproduce myself despite exhaustive
  // testing — genuinely intermittent, so a silent retry is the
  // pragmatic mitigation while the real root cause stays unconfirmed).
  // _generateImageOnce() does the actual work and re-throws on failure
  // instead of setting error state itself, so this wrapper decides
  // whether to retry or finally give up.
  async generateImage() {
    const maxAttempts = 2;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await this._generateImageOnce();
        return;
      } catch (err) {
        console.error(`Image generation failed (attempt ${attempt}/${maxAttempts}):`, err);
        if (attempt >= maxAttempts) {
          this.imageError = true;
          this.imageErrorMessage = (err && err.message) ? String(err.message) : 'Unknown error';
          this.render();
          return;
        }
        await new Promise(resolve => setTimeout(resolve, 800));
      }
    }
  }

  async _generateImageOnce() {
    if (typeof html2canvas === 'undefined') return;

    const m = this.matchContext;
    const homeName = this.titleCase(m.home_team_name || m.homeTeam || 'Home');
    let awayName = this.titleCase(m.away_team_name || m.awayTeam || '');
    // For calendar-synced matches with no away_team linked, parse from title
    if (!awayName && m.title && / vs /i.test(m.title)) {
      awayName = this.titleCase(m.title.split(/ vs /i)[1]?.trim() || '');
    }
    awayName = awayName || 'Away';
    // Parallel, not sequential — each proxied logo fetch can take up to
    // its own 8s timeout on a slow connection (owner, 2026-08-23: "it
    // fails to show image on the post to insta from main"), and
    // awaiting them one after another nearly doubles the worst-case wait
    // before generateImage() either succeeds or times out — exactly the
    // kind of real-world mobile-network delay that's hard to reproduce
    // on a fast connection but very plausible on-site at a game.
    const [homeLogo, awayLogo] = await Promise.all([
      this.resolveImageForCanvas(m.home_team_logo || ''),
      // away_team_logo already carries the fallback chain (opponent
      // aliases, name match, logo cache, then the league's own crest for
      // an opponent with no teams row) — EventController resolves all of
      // it. This used to substitute a hardcoded tcwsl.png here, which
      // branded every untagged informal match a women's league game.
      this.resolveImageForCanvas(m.away_team_logo || ''),
    ]);
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
    // League detection (2026-08-22, owner: "apsl should be apsl delaware
    // river... unless we need a league: var in desc for gcal which i
    // think we do lol. that would inform a lot of things!") — m.league_tag
    // is the authoritative `League:` gcal tag (migration 297), set once by
    // ops on the calendar event and read verbatim here instead of guessed.
    // Falls back to the old team-name/competition scan only for matches
    // nobody has tagged yet.
    const hasLeagueTag = !!(m.league_tag && m.league_tag.trim());
    const competitionText = `${m.competition_name || ''} ${m.division_name || ''} ${m.home_team_name || ''} ${m.away_team_name || ''}`;
    const isCasa = hasLeagueTag
      ? /casa|liga\s*[12]/i.test(m.league_tag)
      : ((m.source_name === 'casa') || /casa|liga\s*[12]/i.test(competitionText));
    const isCustomMatch = !m.source_name; // calendar-synced or manually created (no source system)

    // Fetch accolades for both teams — optional, so a hard timeout here
    // too (owner, 2026-08-23: "it fails to show image on the post to
    // insta from main") rather than letting a slow/stalled request block
    // the whole generation before it even reaches the logo/html2canvas
    // steps that already have their own timeouts.
    const withTimeoutMs = (promise, ms) => Promise.race([
      promise,
      new Promise((_, reject) => setTimeout(() => reject(new Error('Accolades fetch timed out')), ms)),
    ]);
    const homeTeamId = m.home_team_id || null;
    const awayTeamId = m.away_team_id || null;
    let homeAccolades = [], awayAccolades = [];
    try {
      const fetches = [];
      if (homeTeamId) fetches.push(this.auth.fetch(`/api/teams/${homeTeamId}/accolades`).then(r => r.json()));
      else fetches.push(Promise.resolve({ data: [] }));
      if (awayTeamId) fetches.push(this.auth.fetch(`/api/teams/${awayTeamId}/accolades`).then(r => r.json()));
      else fetches.push(Promise.resolve({ data: [] }));
      const [homeRes, awayRes] = await withTimeoutMs(Promise.all(fetches), 8000);
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
    // Determine league display name — trust ops' own wording when tagged.
    let league;
    if (hasLeagueTag) {
      league = m.league_tag.trim();
    } else if (isCasa) {
      const div = `${m.division_name || ''} ${m.competition_name || ''} ${m.home_team_name || ''} ${m.away_team_name || ''}`;
      const isLiga2 = String(m.home_team_id) === '121' || String(m.away_team_id) === '121' || /liga\s*2/i.test(div);
      if (isLiga2) league = 'Philadelphia CASA Select Liga 2';
      else league = 'Philadelphia CASA Select Liga 1';
    } else if (isCustomMatch) {
      league = ''; // Calendar-synced match — no league association
    } else {
      league = 'Delaware River Conference';
    }

    // Crest is a straight DB read off the match (migration 298); the
    // display name above is derived separately, and the two are
    // deliberately independent — an untagged match can still carry its
    // source system's crest.
    const crest = window.LeagueCrest ? window.LeagueCrest.resolve(m) : null;
    const leagueLogoSrc = (crest && crest.src) || null;

    // Build post-type-specific content
    let headerText = '', middleHtml = '', rosterHtml = '', leagueBadgeHtml = '';
    switch (this.postTypeName) {
      case 'game_day':
        headerText = this.getGameDayLabel(rawDate);
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, leagueLogoSrc, false);
        break;
      case 'lineup':
        headerText = 'MATCH DAY SQUAD';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, leagueLogoSrc, true);
        rosterHtml = this.buildImageRoster();
        break;
      case 'pre_match_announcement':
        headerText = 'STARTERS & BENCH';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo, homeAccolades, awayAccolades);
        leagueBadgeHtml = this.buildLeagueBadge(league, leagueLogoSrc, true);
        rosterHtml = this.buildImageStartersBench();
        break;
      case 'post_game':
        headerText = 'FULL TIME';
        middleHtml = this.buildImageScore(homeName, awayName, m, homeLogo, awayLogo);
        leagueBadgeHtml = this.buildLeagueBadge(league, leagueLogoSrc, false);
        break;
      default:
        headerText = 'MATCH DAY';
        middleHtml = this.buildImageMatchup(homeName, awayName, dateStr, timeStr, venueStr, homeLogo, awayLogo);
    }

    // Build goal scorers block for post_game graphic
    let goalScorerHtml = '';
    if (this.postTypeName === 'post_game') {
      const stats = this.matchStats || [];
      const ourGoals = stats.filter(s =>
        (s.event_type === 'goal' || s.event_type === 'own_goal') &&
        String(s.team_id) === String(this.teamId)
      );
      if (ourGoals.length > 0) {
        const goalMap = new Map();
        ourGoals.forEach(g => {
          const key = String(g.player_id);
          if (goalMap.has(key)) {
            goalMap.get(key).count++;
            goalMap.get(key).minutes.push(g.minute);
          } else {
            goalMap.set(key, { name: g.player_name, count: 1, minutes: [g.minute], isOG: g.event_type === 'own_goal' });
          }
        });
        const lines = Array.from(goalMap.values()).map(({ name, count, minutes, isOG }) => {
          const og = isOG ? ' <span style="opacity:0.6;font-size:0.85em;">(OG)</span>' : '';
          const mins = minutes.map(min => `${min}'`).join(', ');
          return `<div style="font-size:12px;color:rgba(255,255,255,0.95);line-height:1.7;">${'⚽'.repeat(count)} ${this.escapeHtml(name)}${og} <span style="opacity:0.6;font-size:0.9em;">${mins}</span></div>`;
        });
        goalScorerHtml = `
          <div style="width:100%;text-align:left;margin-bottom:10px;">
            <div style="font-size:10px;text-transform:uppercase;letter-spacing:2px;color:#f5d442;font-weight:700;margin-bottom:4px;">Goalscorers</div>
            ${lines.join('')}
          </div>
        `;
      }
    }

    // Build players-played block for post_game graphic (2-column grid)
    let playersPlayedHtml = '';
    if (this.postTypeName === 'post_game' && this.playersPlayedText && this.playersPlayedText.trim()) {
      const players = this.playersPlayedText.trim().split('\n').map(s => s.trim()).filter(Boolean);
      const mid = Math.ceil(players.length / 2);
      const left = players.slice(0, mid);
      const right = players.slice(mid);
      const rowsHtml = left.map((p, i) =>
        `<div style="font-size:11px;color:rgba(255,255,255,0.88);line-height:1.6;">${this.escapeHtml(p)}</div>` +
        `<div style="font-size:11px;color:rgba(255,255,255,0.88);line-height:1.6;">${right[i] ? this.escapeHtml(right[i]) : ''}</div>`
      ).join('');
      playersPlayedHtml = `
        <div style="width:100%;text-align:left;margin-bottom:12px;">
          <div style="font-size:10px;text-transform:uppercase;letter-spacing:2px;color:#f5d442;font-weight:700;margin-bottom:5px;">👥 Squad</div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:1px 12px;width:100%;">${rowsHtml}</div>
        </div>
      `;
    }

    // Adjust size: taller for lineup with roster, or post_game with players/scorers
    const hasRoster = rosterHtml.length > 0;
    const hasPlayersPlayed = playersPlayedHtml.length > 0;
    const hasGoalScorers = goalScorerHtml.length > 0;
    const cardHeight = hasRoster ? 700 : (hasPlayersPlayed ? 640 : hasGoalScorers ? 580 : 540);

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

        ${goalScorerHtml}

        ${playersPlayedHtml}

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
    this.hardenGradientsForCapture(wrapper.firstElementChild);

    // Hard timeout (2026-08-22, owner: "the generate image is frozen...
    // it needs to work!") — html2canvas awaits every <img> in the card
    // loading, and a cross-origin logo host with no CORS headers (or one
    // that's just slow) can leave that wait hanging with no error and no
    // built-in timeout, stranding the "Generating image..." placeholder
    // forever. This can't fully replace fixing the actual host (see
    // resolveAssetUrl's logo-proxy allowlist above), but it guarantees
    // the UI always recovers to a visible error + Regenerate instead of
    // hanging silently for any host we haven't allowlisted yet.
    const withTimeout = (promise, ms) => Promise.race([
      promise,
      new Promise((_, reject) => setTimeout(() => reject(new Error(`Image generation timed out after ${ms / 1000}s`)), ms)),
    ]);

    try {
      const canvas = await withTimeout(
        html2canvas(wrapper.firstElementChild, { backgroundColor: null, scale: 2, useCORS: true }),
        15000
      );
      // Store base image (card without beam)
      this.cardWidth = 540;
      this.cardHeight = cardHeight;
      const baseImg = new Image();
      baseImg.src = canvas.toDataURL('image/png');
      await new Promise(resolve => { baseImg.onload = resolve; });
      this.baseImage = baseImg;
      this.generatedImageUrl = baseImg.src; // fallback
      this.imageError = false;
      this.imageErrorMessage = null;
      // Start animated preview
      this.startAnimatedPreview();
    } catch (err) {
      // Re-thrown to the generateImage() retry wrapper above — it
      // decides whether to try again or finally surface the error.
      throw err;
    } finally {
      document.body.removeChild(wrapper);
    }
  }

  startAnimatedPreview() {
    if (this._stopLighthouseAnim) this._stopLighthouseAnim();
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

    // Preserve startTime across re-renders so the beam angle never jumps.
    if (!this.animStartTime) this.animStartTime = performance.now();

    // Shared lighthouse-with-rotating-beam artwork (2026-08-22, owner:
    // "use the one from the socials section of site. its better") — same
    // module game-lineup.js's live views now use, so there's exactly one
    // drawing of this graphic instead of two drifting copies.
    this._stopLighthouseAnim = window.LighthouseBeam.animate(cvs, {
      startTime: this.animStartTime,
      // owner, 2026-08-22: "you need to time the beam so the post time
      // shown matches the 360 arc of beam to it matches" — the posted
      // clip (see postNow() below) is recorded off THIS canvas, so the
      // rotation has to divide the recording length evenly or the video
      // stops part-way through a sweep and jumps when Instagram loops it.
      // A period that doesn't divide cleanly was the original bug; one
      // that merely got slower (the earlier 40s pass) made it worse. Both
      // numbers now come off LighthouseBeam, where the relationship
      // between them is spelled out.
      rotPeriodSec: this.beamRotationSeconds(),
      onFrame: (ctx, w, h) => {
        if (this.baseImage) ctx.drawImage(this.baseImage, 0, 0, w, h);
      },
    }).stop;
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
      // Whole number of beam rotations — seamless when Instagram loops it
      setTimeout(() => recorder.stop(), this.postClipSeconds() * 1000);
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
        <div style="margin-top:4px;flex-shrink:0;padding:4px 8px;background:linear-gradient(135deg,rgba(245,212,66,0.15),rgba(255,215,0,0.08));border:1px solid rgba(245,212,66,0.3);border-radius:6px;max-width:160px;">
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
      <div style="height:1px;min-height:1px;flex-shrink:0;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:0 auto 10px;"></div>
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

  // League badge on the post graphic. The two halves come from different
  // places on purpose: `league` is the display wording (ops' own gcal
  // tag when the match has one, the legacy CASA/Delaware-River
  // derivation when it doesn't), while `logoSrc` is the crest the DB
  // resolved for this match — organizations.logo_url by way of
  // gcal_league_aliases, see leagueCrest.js. Before that it was a hard
  // CASA-or-APSL coin flip in JavaScript, so a match in any other league
  // published branded APSL (2026-08-24, owner: "we already should have
  // them in db").
  //
  // A match the DB gives no crest for renders text-only rather than
  // substituting a default image: an unbranded badge is a cosmetic gap,
  // a wrong league crest on a published Instagram post is not.
  buildLeagueBadge(league, logoSrc, compact) {
    if (!league) return '';
    if (compact) {
      // Small inline badge for lineup / starters & bench
      return `
        <div style="display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:10px;">
          ${logoSrc ? `<img src="${logoSrc}" style="width:22px;height:22px;object-fit:contain;" />` : ''}
          <span style="font-size:11px;font-weight:700;letter-spacing:1.5px;color:#ffffff;">${this.escapeHtml(league)}</span>
        </div>
      `;
    }
    // Full-size standalone logo + conference text for game_day / post_game
    return `
      <div style="display:flex;flex-direction:column;align-items:center;margin-bottom:8px;gap:4px;">
        ${logoSrc ? `<div style="width:52px;height:52px;display:flex;align-items:center;justify-content:center;background:#ffffff;border-radius:10px;border:1px solid rgba(255,255,255,0.18);">
          <img src="${logoSrc}" style="max-width:42px;max-height:46px;object-fit:contain;" />
        </div>` : ''}
        <span style="font-size:11px;font-weight:700;letter-spacing:2px;color:#ffffff;text-transform:uppercase;">${this.escapeHtml(league)}</span>
      </div>
    `;
  }

  buildVenueString(m) {
    // Full street address (owner: "on all views show address of game") —
    // venue_location is EventController's free-text fallback (the linked
    // Google Calendar event's location, same source the My page already
    // shows) for matches with no structured `venues` table row, which is
    // most scraped/informal league games. Prefer it outright: it's
    // already a complete address, so appending the structured fields
    // below would just duplicate it.
    if (m.venue_location) return m.venue_location;
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

  // Starters & Bench post (2026-08-24, owner: "how come starters & Bench
  // does not have players! like in the lineup view?") — this graphic
  // built no roster block at ALL, so it published as a matchup card with
  // an empty body while the 20-Man Squad post beside it listed everyone.
  //
  // The names were never missing from the data; the zone was. The screen
  // reads `row.zone` off the eligibility lineup, keeps only
  // starter-or-bench as a yes/no in a flat selectedIds Set, and drops
  // which one it was — so the card had no way to split the two even
  // though the whole point of this post type is the split. rosterData
  // .zones (game-day-roster.js) carries it through now.
  //
  // Falls back to the flat SQUAD list when zones are absent, so an older
  // caller that passes only {players, selectedIds} still renders names
  // rather than the blank card this is fixing.
  //
  // Starters print like a team sheet: keeper first, then shirt numbers
  // ascending, then anyone with no number alphabetically. The number is
  // usually absent in practice — the pitch graphic's 1-11 are position
  // ids, not jersey numbers, and players merged in from the eligibility
  // endpoint carry no jersey at all — so the last-name tiebreak is the
  // rule that actually does the work here, with the numbers taking over
  // for squads that have them. Bench is straight alphabetical by last
  // name, matching the player lineup view's "so no one gets mad" rule:
  // there is no fairness case for ranking a bench, least of all on a
  // public post.
  buildImageStartersBench() {
    if (!this.rosterData || !this.rosterData.players || !this.rosterData.selectedIds) return '';
    const zones = this.rosterData.zones;
    if (!zones || !zones.size) return this.buildImageRoster();

    const selectedIds = this.rosterData.selectedIds;
    const inZone = (z) => this.rosterData.players.filter(p =>
      selectedIds.has(p.playerId) && zones.get(String(p.playerId)) === z);

    const byLastName = (a, b) =>
      String(a.lastName || '').toLowerCase().localeCompare(String(b.lastName || '').toLowerCase());
    const teamSheetOrder = (a, b) => {
      if (!!a.isKeeper !== !!b.isKeeper) return a.isKeeper ? -1 : 1;
      const na = parseInt(a.jerseyNumber, 10), nb = parseInt(b.jerseyNumber, 10);
      if (!isNaN(na) && !isNaN(nb) && na !== nb) return na - nb;
      if (!isNaN(na) !== !isNaN(nb)) return isNaN(na) ? 1 : -1;
      return byLastName(a, b);
    };

    const starters = inZone('starter').sort(teamSheetOrder);
    const bench = inZone('bench').sort(byLastName);
    if (starters.length === 0 && bench.length === 0) return '';

    const section = (title, list) => list.length ? `
      <div style="text-align:left;">
        <div style="font-size:10px;text-transform:uppercase;letter-spacing:3px;color:#f5d442;margin-bottom:6px;font-weight:700;">${title}</div>
        ${list.map(p => this.buildImagePlayerRow(p)).join('')}
      </div>` : '';

    return `
      <div style="height:1px;min-height:1px;flex-shrink:0;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:12px auto;"></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:0 16px;width:100%;">
        ${section(`STARTING XI`, starters)}
        ${section(`BENCH`, bench)}
      </div>
    `;
  }

  // One "#7 Name GK" line, shared by both roster blocks so the two post
  // types can never drift apart on jersey/keeper formatting.
  buildImagePlayerRow(p) {
    const jersey = p.jerseyNumber ? `<span style="color:#ffffff;font-weight:700;font-size:0.9em;min-width:24px;display:inline-block;">#${p.jerseyNumber}</span>` : '';
    const gk = p.isKeeper ? ' <span style="font-size:0.7em;background:rgba(255,255,255,0.15);color:#ffffff;padding:0 4px;border-radius:3px;font-weight:700;">GK</span>' : '';
    return `<div style="display:flex;align-items:center;gap:6px;font-size:11px;padding:1px 0;color:rgba(255,255,255,0.9);">${jersey}<span>${this.escapeHtml(p.firstName)} ${this.escapeHtml(p.lastName)}</span>${gk}</div>`;
  }

  buildImageRoster() {
    if (!this.rosterData || !this.rosterData.players || !this.rosterData.selectedIds) return '';
    const players = this.rosterData.players;
    const selectedIds = this.rosterData.selectedIds;
    const selected = players.filter(p => selectedIds.has(p.playerId));
    if (selected.length === 0) return '';

    const rows = selected.map(p => this.buildImagePlayerRow(p)).join('');

    return `
      <div style="height:1px;min-height:1px;flex-shrink:0;background:linear-gradient(90deg,transparent,rgba(255,255,255,0.15),transparent);width:80%;margin:12px auto;"></div>
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
      let scorersRegen = null;
      scorersInput.addEventListener('input', () => {
        this.scorersText = scorersInput.value;
        if (textarea) {
          textarea.value = this.buildCaption();
          if (charCount) charCount.textContent = textarea.value.length;
        }
        // Debounce: regenerate graphic 800ms after user stops typing
        clearTimeout(scorersRegen);
        scorersRegen = setTimeout(() => {
          this.generateImage();
        }, 800);
      });
    }

    const playersPlayedInput = this.container.querySelector('.spc-players-played');
    if (playersPlayedInput) {
      let playersRegen = null;
      playersPlayedInput.addEventListener('input', () => {
        this.playersPlayedText = playersPlayedInput.value;
        clearTimeout(playersRegen);
        playersRegen = setTimeout(() => {
          this.generateImage();
        }, 800);
      });
    }

    const regenBtn = this.container.querySelector('.spc-btn-regen');
    if (regenBtn) {
      regenBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        const ta = this.container.querySelector('.spc-caption');
        const cc = this.container.querySelector('.spc-char-num');
        if (ta) {
          ta.value = this.buildCaption();
          if (cc) cc.textContent = ta.value.length;
        }
        this.generateImage();
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
        dlBtn.textContent = `⏳ Recording ${this.postClipSeconds()}s...`;
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
    // Name the wait: recording is real-time, so at 30s a bare "Recording
    // video..." looks like the button has hung.
    if (postBtn) { postBtn.disabled = true; postBtn.textContent = `⏳ Recording ${this.postClipSeconds()}s video...`; }

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
            // Headroom for the 30s clip (2026-08-24). This whole blob is
            // base64'd into a JSON body, which inflates it by 4/3, and
            // nginx caps /api/ at 10m (frontend/nginx.conf) — at the old
            // 1.2Mbps ceiling a full 30s would land around 6MB encoded,
            // uncomfortably close to that wall. 900kbps keeps the worst
            // case near 4MB. It costs nothing visually: the card is a
            // near-static image with one soft moving gradient, VP9 spends
            // far less than the ceiling on it, and the backend re-encodes
            // to H.264 CRF 23 anyway (SocialController.cpp).
            videoBitsPerSecond: 900000
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
          // Whole number of beam rotations — see LighthouseBeam.
          // Watch the bitrate above if this ever grows again: the payload
          // is a base64 JSON body and nginx 413s past 10m.
          setTimeout(() => recorder.stop(), this.postClipSeconds() * 1000);
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
