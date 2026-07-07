// MensEventsRemindersScreen — one place to see every upcoming men's
// event (games + practice + pickup) and fire off "please RSVP" nudges
// to non-responders.  Backed by:
//
//   GET  /api/mens/upcoming-events        — flat, date-sorted list of
//     every non-cancelled match on a mens home team (game teams +
//     pool teams 908/909).
//   POST /api/matches/:id/remind          — reuses the existing bulk
//     reminder pipeline (same eligibility rules, rate-limit, magic
//     link generation) that Match RSVP Management uses.
//
// The reply modal is a clone of the one in match-rsvp-management —
// coach taps ONE row's "Send" and the OS composer opens with the
// prefilled SMS body + magic RSVP link.  We keep the modal self-
// contained here so the two screens stay independent.
class MensEventsRemindersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events = [];
    this._filter = 'upcoming'; // 'upcoming' (>= today) is the only option for now
    this._bulkTotal = 0;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-mens-events-reminders';
    div.innerHTML = `
      <div class="screen-header" style="display:flex;align-items:center;gap:var(--space-3);padding:var(--space-3);">
        <button class="btn btn-secondary btn-sm back-btn">← Back</button>
        <h1 style="margin:0;font-size:1.5rem;">📢 Mens Reminders</h1>
        <span style="flex:1"></span>
        <span id="mer-count" style="font-size:0.95rem;color:var(--text-muted);"></span>
      </div>

      <div style="padding:0 var(--space-3) var(--space-3);max-width:1000px;margin:0 auto;">
        <p style="opacity:0.8;font-size:1rem;margin:0 0 var(--space-3);line-height:1.4;">
          Every upcoming men's event — games, practice, pickup — across all mens teams.
          Tap <b>📢 Remind non-responders</b> on any row to generate SMS deep-links for
          each player who hasn't RSVP'd yet.  Rate-limited to one nudge per player per
          event every 5 minutes.
        </p>

        <div id="mer-loading" style="text-align:center;padding:var(--space-4);color:var(--text-muted);">
          Loading events…
        </div>

        <div id="mer-list" style="display:none;flex-direction:column;gap:10px;"></div>

        <div id="mer-empty" style="display:none;text-align:center;padding:var(--space-4);color:var(--text-muted);">
          <div style="font-size:2rem;margin-bottom:8px;">📭</div>
          <div>No upcoming men's events on the schedule.</div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }

      const remindBtn = e.target.closest('.mer-remind-btn');
      if (remindBtn) {
        const matchId = remindBtn.getAttribute('data-match-id');
        const channel = remindBtn.getAttribute('data-channel') || 'sms';
        this.sendReminders(matchId, channel, remindBtn);
        return;
      }

      // Bulk-remind modal — per-row Send.
      const bulkSendBtn = e.target.closest('.bulk-send-btn');
      if (bulkSendBtn) {
        e.stopPropagation();
        const href = bulkSendBtn.getAttribute('data-href');
        if (href) {
          bulkSendBtn.classList.add('bulk-sent');
          bulkSendBtn.textContent = '✓ Sent';
          bulkSendBtn.style.background = 'rgba(34,139,34,0.85)';
          bulkSendBtn.style.color = 'white';
          this._updateBulkProgress();
          setTimeout(() => { window.location.href = href; }, 60);
        }
        return;
      }

      if (e.target.id === 'bulk-remind-close' || e.target.id === 'bulk-remind-backdrop') {
        e.stopPropagation();
        this.hideBulkRemindModal();
        return;
      }
    });

    this.load();
  }

  async load() {
    try {
      const resp = await this.auth.fetch('/api/mens/upcoming-events', {
        headers: { 'Cache-Control': 'no-cache' }
      });
      const payload = await resp.json();
      const arr = (payload && payload.data) ? payload.data : (Array.isArray(payload) ? payload : []);
      this.events = arr;

      this.find('#mer-loading').style.display = 'none';
      if (this.events.length === 0) {
        this.find('#mer-empty').style.display = 'block';
      } else {
        this.find('#mer-count').textContent =
          `${this.events.length} event${this.events.length === 1 ? '' : 's'}`;
        this.renderList();
      }
    } catch (err) {
      console.error('Failed to load mens events:', err);
      this.find('#mer-loading').innerHTML =
        `<p style="color:#f87171;">❌ Failed to load: ${err.message || err}</p>`;
    }
  }

  renderList() {
    const list = this.find('#mer-list');
    list.style.display = 'flex';

    // Group by ISO date so the coach sees "Tue Jul 7 ─── …" separators.
    let lastDate = null;
    const parts = [];

    this.events.forEach((ev) => {
      if (ev.date !== lastDate) {
        lastDate = ev.date;
        parts.push(`
          <div style="margin-top:14px;font-size:0.85rem;font-weight:700;color:var(--text-muted);
                      text-transform:uppercase;letter-spacing:0.05em;padding:6px 4px;">
            ${this._escape(ev.date_str || ev.date)}
          </div>
        `);
      }
      parts.push(this._renderRow(ev));
    });

    list.innerHTML = parts.join('');
  }

  _renderRow(ev) {
    const badge = this._typeBadge(ev.type, ev.match_type_id);
    const time = ev.time_str ? `<span style="color:var(--text-muted);">${this._escape(ev.time_str)}</span>` : '';
    const title = this._escape(ev.title || 'Untitled');
    const home = this._escape(ev.home_team_name || '');
    const away = ev.away_team_name ? ` <span style="color:var(--text-muted);">vs ${this._escape(ev.away_team_name)}</span>` : '';
    const venue = ev.venue_name ? ` · ${this._escape(ev.venue_name)}` : '';

    return `
      <div style="display:flex;align-items:center;gap:14px;padding:14px 16px;
                  border-radius:10px;background:rgba(15,23,42,0.55);
                  border:1px solid rgba(148,163,184,0.25);">
        <div style="flex:1;min-width:0;">
          <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:4px;">
            ${badge}
            <div style="font-weight:700;font-size:1.05rem;">${title}</div>
            ${time}
          </div>
          <div style="font-size:0.9rem;color:var(--text-muted);">
            ${home}${away}${venue}
          </div>
        </div>
        <button class="mer-remind-btn"
                data-match-id="${ev.id}"
                data-channel="sms"
                style="all:unset;cursor:pointer;padding:10px 14px;border-radius:8px;
                       background:rgba(245,200,66,0.18);color:#f5c842;font-weight:700;
                       border:1px solid rgba(245,200,66,0.5);white-space:nowrap;">
          📢 Remind
        </button>
      </div>
    `;
  }

  _typeBadge(type, mtId) {
    // Fall back to match_type_id → label if `type` string is missing.
    const t = (type || '').toLowerCase() || (
      mtId === 3 ? 'practice' :
      mtId === 7 ? 'pickup'   :
      mtId === 1 ? 'game'     :
      mtId === 4 ? 'scrimmage':
      mtId === 6 ? 'cup'      :
      mtId === 2 ? 'custom'   :
      mtId === 5 ? 'tournament' : ''
    );
    const styles = {
      practice:  { bg:'rgba(59,130,246,0.18)',  fg:'#93c5fd', label:'🏃 Practice' },
      pickup:    { bg:'rgba(168,85,247,0.18)',  fg:'#c4b5fd', label:'⚡ Pickup'   },
      league:    { bg:'rgba(34,197,94,0.18)',   fg:'#86efac', label:'⚽ Game'     },
      cup:       { bg:'rgba(34,197,94,0.18)',   fg:'#86efac', label:'🏆 Cup'      },
      scrimmage: { bg:'rgba(148,163,184,0.20)', fg:'#cbd5e1', label:'⚔️ Scrimmage'},
      tournament:{ bg:'rgba(234,179,8,0.18)',   fg:'#fde68a', label:'🏆 Tournament'},
      custom:    { bg:'rgba(148,163,184,0.20)', fg:'#cbd5e1', label:'📅 Event'    },
      game:      { bg:'rgba(34,197,94,0.18)',   fg:'#86efac', label:'⚽ Game'     },
    };
    const s = styles[t] || styles.custom;
    return `<span style="padding:3px 9px;border-radius:9999px;font-size:0.78rem;
                          background:${s.bg};color:${s.fg};font-weight:700;
                          white-space:nowrap;">${s.label}</span>`;
  }

  async sendReminders(matchId, channel, btnEl) {
    if (!matchId) return;

    if (!confirm(`Generate ${channel.toUpperCase()} reminders for every non-responder on this event?\n\n` +
                 `You'll get a modal with one Send button per player — tap each to open your ` +
                 `Messages app with the RSVP link prefilled.  Rate-limit: 5 minutes.`)) {
      return;
    }

    const original = btnEl ? btnEl.innerHTML : '';
    if (btnEl) {
      btnEl.disabled = true;
      btnEl.innerHTML = '⏳ Generating…';
    }

    try {
      const resp = await this.auth.fetch(`/api/matches/${matchId}/remind`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel })
      });
      const data = await resp.json();
      if (!resp.ok) throw new Error(data.error || `HTTP ${resp.status}`);

      const recipients = data.recipients || [];
      if (recipients.length === 0) {
        const parts = [];
        if (data.skipped_rate_limited) parts.push(`${data.skipped_rate_limited} already reminded in the last 5 min`);
        if (data.skipped_no_contact)   parts.push(`${data.skipped_no_contact} with no ${channel === 'sms' ? 'SMS phone' : 'email'} on file`);
        alert(parts.length
          ? `No new reminders generated. Skipped: ${parts.join('; ')}.`
          : 'No non-responders found to remind (everyone has already RSVP\'d).');
        return;
      }

      this.showBulkRemindModal(recipients, data);
    } catch (err) {
      console.error('sendReminders failed:', err);
      alert(`Failed: ${err.message || err}`);
    } finally {
      if (btnEl) {
        btnEl.disabled = false;
        btnEl.innerHTML = original;
      }
    }
  }

  showBulkRemindModal(recipients, meta) {
    this.hideBulkRemindModal();

    const LH_NAVY   = '#0f1f3d';
    const LH_YELLOW = '#f5c842';

    const rowsHtml = recipients.map((r, i) => {
      const name    = this._escape(r.name || 'Unknown');
      const contact = this._escape(r.contact || '');
      const href    = this._escape(r.sms_href || r.mailto_href || '');
      return `
        <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;
                    border-bottom:1px solid rgba(15,31,61,0.12);background:white;">
          <div style="width:24px;text-align:right;color:${LH_NAVY};opacity:0.55;font-size:0.85em;">${i + 1}.</div>
          <div style="flex:1;min-width:0;">
            <div style="font-weight:700;color:${LH_NAVY};">${name}</div>
            <div style="font-size:0.85em;color:#4b5563;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${contact}</div>
          </div>
          <button class="bulk-send-btn"
                  data-href="${href}"
                  style="padding:8px 14px;background:${LH_YELLOW};color:${LH_NAVY};
                         border:none;border-radius:6px;font-weight:700;cursor:pointer;
                         font-size:0.95em;white-space:nowrap;"
                  title="Open Messages with the reminder prefilled">
            📱 Send
          </button>
        </div>
      `;
    }).join('');

    const skippedParts = [];
    if (meta && meta.skipped_rate_limited) skippedParts.push(`${meta.skipped_rate_limited} skipped (already reminded in last 5 min)`);
    if (meta && meta.skipped_no_contact)   skippedParts.push(`${meta.skipped_no_contact} skipped (no contact on file)`);
    const skippedNote = skippedParts.length
      ? `<div style="padding:8px 12px;background:rgba(245,200,66,0.15);color:${LH_NAVY};
                     font-size:0.85em;border-top:1px solid rgba(15,31,61,0.12);">${skippedParts.join(' · ')}</div>`
      : '';

    const overlay = document.createElement('div');
    overlay.id = 'bulk-remind-overlay';
    overlay.style.cssText = 'position:fixed;inset:0;z-index:1100;display:flex;align-items:flex-end;justify-content:center;';
    overlay.innerHTML = `
      <div id="bulk-remind-backdrop" style="position:absolute;inset:0;background:rgba(0,0,0,0.55);"></div>
      <div style="position:relative;width:100%;max-width:560px;max-height:90vh;background:white;
                  border-radius:16px 16px 0 0;display:flex;flex-direction:column;overflow:hidden;
                  box-shadow:0 -8px 24px rgba(0,0,0,0.25);">
        <div style="padding:14px 16px;background:${LH_NAVY};color:${LH_YELLOW};
                    display:flex;align-items:center;justify-content:space-between;gap:10px;">
          <div style="min-width:0;">
            <div style="font-weight:700;font-size:1.05em;">📱 Bulk RSVP Reminders</div>
            <div id="bulk-remind-progress" style="font-size:0.8em;opacity:0.9;margin-top:2px;">0 of ${recipients.length} sent</div>
          </div>
          <button id="bulk-remind-close"
                  style="background:transparent;color:${LH_YELLOW};border:1px solid ${LH_YELLOW};
                         border-radius:6px;padding:6px 12px;cursor:pointer;font-weight:700;">Done</button>
        </div>
        <div style="padding:10px 12px;background:rgba(245,200,66,0.12);color:${LH_NAVY};
                    font-size:0.85em;border-bottom:1px solid rgba(15,31,61,0.12);">
          Tap <b>📱 Send</b> next to each player to open Messages.  Each link is one-tap RSVP and expires in 48 hours.
        </div>
        <div style="flex:1;overflow-y:auto;-webkit-overflow-scrolling:touch;">
          ${rowsHtml}
        </div>
        ${skippedNote}
      </div>
    `;
    document.body.appendChild(overlay);
    this._bulkTotal = recipients.length;
  }

  hideBulkRemindModal() {
    const overlay = document.getElementById('bulk-remind-overlay');
    if (overlay && overlay.parentNode) overlay.parentNode.removeChild(overlay);
    this._bulkTotal = 0;
  }

  _updateBulkProgress() {
    const overlay = document.getElementById('bulk-remind-overlay');
    if (!overlay) return;
    const sent = overlay.querySelectorAll('.bulk-send-btn.bulk-sent').length;
    const total = this._bulkTotal || overlay.querySelectorAll('.bulk-send-btn').length;
    const label = overlay.querySelector('#bulk-remind-progress');
    if (label) label.textContent = `${sent} of ${total} sent`;
  }

  _escape(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
