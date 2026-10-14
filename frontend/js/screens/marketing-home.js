// MarketingHomeScreen — the single home for Recruitment (Leads) and
// Communications (Messages/Socials/Posters). Club Admin no longer
// duplicates any of this — it's reachable only from here, via the
// role-selection "Marketing" button (shown to the marketing-only role
// and to broader admin levels alike). Backend still enforces access
// independently per endpoint (Controller::requireAdminLevel).
class MarketingHomeScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-marketing-home';

    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>Marketing</h1>
        <p class="subtitle">Leads and outbound communications</p>
      </div>

      <div style="padding: var(--space-4);">
        <h3 style="margin-bottom: var(--space-2); opacity: 0.9;">🎯 Recruitment</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Ad interest form submissions, funnel touch-history, and conversion analytics from first touch through LA registration.
        </p>
        <div id="section-recruitment" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);"></div>

        <h3 style="margin: var(--space-5) 0 var(--space-2); opacity: 0.9;">📣 Communications</h3>
        <p style="opacity: 0.7; margin-bottom: var(--space-3); font-size: 0.9rem;">
          Outbound club voice: recipient-first messages, public social posts, and reusable poster/flyer assets.
        </p>
        <div id="section-communications"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    const renderInto = (elId, tiles) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = tiles.map(tile => `
        <button class="btn btn-lg btn-secondary sub-nav-btn"
                data-section="${tile.id}"
                style="height: auto; padding: var(--space-3); text-align: left;">
          <div style="font-size: 2rem; margin-bottom: var(--space-1);">${tile.icon}</div>
          <div style="font-weight: 600; margin-bottom: var(--space-1);">${tile.label}</div>
          <div style="opacity: 0.7; font-size: 0.85rem;">${tile.description}</div>
        </button>
      `).join('');
    };

    const renderGroupsInto = (elId, groups) => {
      const el = this.find(elId);
      if (!el) return;
      el.innerHTML = groups.map(group => `
        <div style="margin-bottom: var(--space-4);">
          <div style="font-weight: 700; margin-bottom: var(--space-2); opacity: 0.88;">${group.label}</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-2);">
            ${group.tiles.map(tile => `
              <button class="btn btn-lg btn-secondary sub-nav-btn"
                      data-section="${tile.id}"
                      style="height: auto; padding: var(--space-3); text-align: left;">
                <div style="font-size: 2rem; margin-bottom: var(--space-1);">${tile.icon}</div>
                <div style="font-weight: 600; margin-bottom: var(--space-1);">${tile.label}</div>
                <div style="opacity: 0.7; font-size: 0.85rem;">${tile.description}</div>
              </button>
            `).join('')}
          </div>
        </div>
      `).join('');
    };

    const recruitmentTiles = [
      { id: 'leads', target: 'leads', params: {}, icon: '📋', label: 'Leads', description: 'Ad interest form submissions' },
      { id: 'leads-analytics', target: 'leads-analytics', params: {}, icon: '📊', label: 'Leads Analytics', description: 'What touches actually turn into LA registrations' },
    ];
    renderInto('#section-recruitment', recruitmentTiles);

    const communicationGroups = [
      {
        label: 'Messages',
        tiles: [
          { id: 'messages', target: 'messages', params: {}, icon: '💬', label: 'Messages', description: 'Canned responses, welcomes, broadcasts, and follow-up copy per team' },
        ],
      },
      {
        label: 'Socials',
        tiles: [
          { id: 'event-calendar', target: 'calendar', params: {}, icon: '📅', label: 'Event Calendar', description: 'Google Calendar events — make an Instagram post or a flyer straight from any event' },
          { id: 'match-posts', icon: '🗓️', label: 'Match-Day Posts', description: 'Pre-match, lineup & result posts per team — pick a team to open its match social calendar' },
          { id: 'holiday-posts', target: 'holiday-posts', params: {}, icon: '🎉', label: 'Holiday Posts', description: 'Instagram holiday posts' },
          { id: 'promo-posts', target: 'promo-posts', params: {}, icon: '📢', label: 'Promo Posts', description: 'Instagram promotional posts' },
          { id: 'content-posts', target: 'content-posts', params: {}, icon: '📷', label: 'Content Posts', description: 'Upload photos & videos to Instagram' },
          { id: 'ad-preview', target: 'ad-preview', params: {}, icon: '📱', label: 'Ad Preview', description: 'See exactly what your ads look like' },
        ],
      },
      {
        label: 'Posters & Assets',
        tiles: [
          { id: 'flyers', target: 'flyers', params: {}, icon: '🖨️', label: 'Flyers', description: 'Printable recruitment flyers with QR codes' },
          { id: 'public-exhibits', icon: '🖼️', label: 'Public Exhibits', description: 'Publicly shareable poster boards & history pages' },
          { id: 'exhibit-social', icon: '📲', label: 'Exhibit → Social', description: 'Export poster assets as IG carousel, 4:5 single, or long poster renders' },
        ],
      },
    ];
    renderGroupsInto('#section-communications', communicationGroups);

    this._dashTiles = [...recruitmentTiles, ...communicationGroups.flatMap(g => g.tiles)];

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const subNavBtn = e.target.closest('.sub-nav-btn');
      if (subNavBtn) {
        const section = subNavBtn.getAttribute('data-section');

        if (section === 'public-exhibits') {
          window.open('/exhibit/lighthouse-history.html', '_blank', 'noopener');
          return;
        }
        if (section === 'exhibit-social') {
          window.open('/exhibit/slideshow.html?p=1', '_blank', 'noopener');
          return;
        }
        if (section === 'match-posts') {
          this.openMatchPostsPicker();
          return;
        }

        const tile = (this._dashTiles || []).find(t => t.id === section);
        if (tile && tile.target) {
          // Downstream screens (leads, messages, holiday-posts, …) read
          // params.clubId/clubName — same hardcoded Lighthouse club the
          // Club Admin flow uses (role-selection.js loadClubAdmin()).
          this.navigation.goTo(tile.target, {
            clubId: 134,
            clubName: 'Lighthouse 1893 SC',
            ...tile.params,
          });
        }
      }
    });
  }

  // match-social (game-day/lineup/result posts) is per-team, so this
  // tile opens a team picker rather than navigating straight there —
  // same clubId=134 the rest of this screen's tiles use.
  async openMatchPostsPicker() {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML = `
      <div class="modal-content" style="max-width: 420px;">
        <div class="modal-header">
          <h2>🗓️ Match-Day Posts</h2>
          <button class="modal-close" data-action="close">&times;</button>
        </div>
        <p style="opacity: 0.7; font-size: 0.9rem; margin-top: -8px;">Pick a team to open its match social calendar.</p>
        <div id="mp-team-list">
          <div class="loading-state"><div class="spinner"></div><p>Loading teams…</p></div>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('[data-action="close"]')) close();
    });

    try {
      const res = await this.auth.fetch('/api/clubs/134?gender=all');
      const payload = await res.json();
      const club = payload?.data || payload;
      const teams = (Array.isArray(club?.teams) ? club.teams : [])
        .filter(t => !t.is_pool && t.is_active !== false)
        .sort((a, b) => String(a.name || '').localeCompare(String(b.name || '')));

      const listEl = overlay.querySelector('#mp-team-list');
      if (!listEl) return;

      if (teams.length === 0) {
        listEl.innerHTML = '<div class="empty-state"><p>No teams found.</p></div>';
        return;
      }

      listEl.innerHTML = teams.map(t => `
        <button class="btn btn-secondary mp-team-btn" data-team-id="${t.id}"
                style="display:block; width:100%; text-align:left; margin-bottom: 8px; padding: var(--space-3);">
          ${this.escapeHtml(t.name || 'Team')}
        </button>
      `).join('');

      listEl.querySelectorAll('.mp-team-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          const team = teams.find(t => String(t.id) === btn.dataset.teamId);
          if (!team) return;
          close();
          this.navigation.goTo('match-social', { team: { id: team.id, name: team.name } });
        });
      });
    } catch (err) {
      console.warn('[marketing-home] team load failed:', err);
      const listEl = overlay.querySelector('#mp-team-list');
      if (listEl) listEl.innerHTML = '<div class="empty-state"><p>Failed to load teams.</p></div>';
    }
  }
}
