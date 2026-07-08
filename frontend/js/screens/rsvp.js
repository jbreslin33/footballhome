// RsvpScreen — public-style screen behind a magic-link session.
//
// Activated via the hash route #rsvp/<chatEventId>.  The magic-link verify
// endpoint sets the fh_sess cookie before redirecting here, so on mount we
// rely on cookie auth (no JWT) for /api/auth/me, /api/events/:id, /api/rsvp.
//
// Lifecycle:
//   1. onEnter   → fetch /api/auth/me → fetch /api/events/:id → render
//   2. user taps [Going] / [Maybe] / [Not going] (+ optional note)
//   3. submit    → POST /api/rsvp → show confirmation card
//
// All fetches use plain `fetch(..., { credentials: 'include' })` because
// this screen is auth-less from the SPA's point of view; the session lives
// entirely in the HttpOnly cookie set by /api/auth/magic-link/verify.
class RsvpScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.chatEventId  = null;
    this.me           = null;
    this.event        = null;
    this.myRsvp       = null;
    this.selected     = null; // 'yes' | 'maybe' | 'no'
    this.note         = '';
    this.busy         = false;
    this.errorMessage = null;
  }

  onEnter(params = {}) {
    this.chatEventId = params.chatEventId != null
      ? parseInt(params.chatEventId, 10)
      : null;
    if (!this.chatEventId) {
      this.errorMessage = 'No event specified in the link.';
      this._renderError();
      return;
    }
    this._bootstrap();
  }

  onExit() {}

  render() {
    const el = document.createElement('div');
    el.className = 'screen rsvp-screen';
    el.innerHTML = `
      <div id="rsvp-shell" style="
        max-width: 480px;
        margin: 0 auto;
        padding: var(--space-4, 16px);
        color: var(--text-primary);
      ">
        <div id="rsvp-loading" style="text-align:center; padding: 40px 0;">
          Loading…
        </div>
      </div>
    `;
    this.element = el;
    return el;
  }

  async _bootstrap() {
    try {
      // Session check — establishes that the cookie is valid + tells us
      // which person we're acting as (for the greeting).
      const meRes = await fetch('/api/auth/me', { credentials: 'include' });
      if (meRes.status === 401) {
        this.errorMessage = "Your sign-in link has expired. Ask an admin to send you a new one.";
        this._renderError();
        return;
      }
      if (!meRes.ok) throw new Error(`HTTP ${meRes.status}`);
      this.me = (await meRes.json()).person;

      const evRes = await fetch(`/api/events/${this.chatEventId}`, { credentials: 'include' });
      if (!evRes.ok) throw new Error(`Could not load event (HTTP ${evRes.status})`);
      const evData = await evRes.json();
      this.event   = evData.event;
      this.myRsvp  = evData.my_rsvp;
      this.selected = this.myRsvp?.status || null;
      this.note     = this.myRsvp?.response_note || '';

      this._renderForm();
    } catch (err) {
      console.error('rsvp bootstrap failed:', err);
      this.errorMessage = err.message || 'Something went wrong.';
      this._renderError();
    }
  }

  _renderError() {
    const shell = this.find('#rsvp-shell');
    if (!shell) return;
    shell.innerHTML = `
      <div style="background: var(--bg-secondary, rgba(255,255,255,0.05));
                  border:1px solid var(--border-color, rgba(255,255,255,0.1));
                  padding: 24px; border-radius: 8px; text-align: center;">
        <div style="font-size: 2em; margin-bottom: 12px;">⚠️</div>
        <div style="margin-bottom: 16px;">${this.escapeHtml(this.errorMessage || 'Unknown error')}</div>
        <a href="https://footballhome.org" style="color: var(--accent-color, #3b82f6);">
          Go to Football Home
        </a>
      </div>
    `;
  }

  _renderForm() {
    const shell = this.find('#rsvp-shell');
    if (!shell) return;
    const ev = this.event || {};
    const me = this.me || {};

    const optionBtn = (val, label, bg) => {
      const isSel    = this.selected === val;
      const isSaving = this.busy && this.selected === val;
      return `
        <button
          data-rsvp-choice="${val}"
          ${this.busy ? 'disabled' : ''}
          style="
            flex: 1;
            padding: 14px 8px;
            border-radius: 8px;
            border: 2px solid ${isSel ? bg : 'transparent'};
            background: ${isSel ? bg : 'var(--bg-secondary, rgba(255,255,255,0.06))'};
            color: ${isSel ? '#0b1220' : 'var(--text-primary)'};
            font-size: 1em; font-weight: 700;
            cursor: ${this.busy ? 'wait' : 'pointer'};
            opacity: ${this.busy && !isSaving ? '0.5' : '1'};
            transition: background 0.15s ease, border-color 0.15s ease;
          "
        >${isSaving ? '⏳ Saving…' : label}</button>`;
    };

    const teamLine = ev.team_name
      ? `<div style="opacity:0.7; font-size: 0.9em;">${this.escapeHtml(ev.team_name)}</div>`
      : '';

    // Club-brand banner derived from the team's gender_category so a Boys
    // event shows "Lighthouse Boys Club 1897", a Womens event shows
    // "Lighthouse Womens Club 1895", etc.  If category is unknown we skip
    // the banner rather than guess.
    const CLUB_BRAND = {
      mens:   'Lighthouse Mens Club 1893',
      womens: 'Lighthouse Womens Club 1895',
      boys:   'Lighthouse Boys Club 1897',
      girls:  'Lighthouse Girls Club 1898',
    };
    const brand = CLUB_BRAND[(ev.gender_category || '').toLowerCase()];
    const brandBanner = brand
      ? `<div style="
           text-align:center;
           font-family: Georgia, 'Times New Roman', serif;
           font-size: 0.95em;
           letter-spacing: 2px;
           text-transform: uppercase;
           color: #f5d442;
           font-weight: 700;
           padding: 10px 8px;
           background: #12233f;
           border-radius: 8px;
           margin-bottom: 16px;
         ">${this.escapeHtml(brand)}</div>`
      : '';

    shell.innerHTML = `
      ${brandBanner}
      <div style="margin-bottom: 20px;">
        <div style="font-size: 1.1em;">Hi ${this.escapeHtml(me.first_name || 'there')} 👋</div>
        <div style="margin-top: 4px; opacity: 0.7;">Tap a button — your RSVP is saved instantly.</div>
      </div>

      <div style="background: var(--bg-secondary, rgba(255,255,255,0.05));
                  border:1px solid var(--border-color, rgba(255,255,255,0.1));
                  padding: 16px; border-radius: 8px; margin-bottom: 20px;">
        <div style="font-size: 1.15em; font-weight: 700; margin-bottom: 4px;">
          ${this.escapeHtml(ev.title || 'Event')}
        </div>
        ${ev.when ? `<div style="opacity:0.85;">${this.escapeHtml(ev.when)}</div>` : ''}
        ${ev.location ? `<div style="opacity:0.7; font-size: 0.9em;">${this.escapeHtml(ev.location)}</div>` : ''}
        ${teamLine}
      </div>

      <div style="display: flex; gap: 8px; margin-bottom: 8px;">
        ${optionBtn('yes',   '✅ Going',     '#22c55e')}
        ${optionBtn('maybe', '🤔 Maybe',     '#eab308')}
        ${optionBtn('no',    '❌ Not going', '#ef4444')}
      </div>

      <div id="rsvp-result" style="text-align:center; min-height: 22px; font-size:0.9em; margin-bottom: 8px;"></div>

      <label style="display:block; font-size:0.9em; opacity:0.8; margin-bottom:6px; margin-top: 8px;">
        Optional note (visible to your team admins)
      </label>
      <textarea
        id="rsvp-note"
        rows="3"
        placeholder="e.g. running late, can play either half…"
        style="
          width:100%; padding:10px; border-radius:6px;
          background: var(--bg-secondary, rgba(255,255,255,0.06));
          border: 1px solid var(--border-color, rgba(255,255,255,0.12));
          color: var(--text-primary);
          font-family: inherit;
          font-size: 0.95em;
          box-sizing: border-box;
          resize: vertical;
        "
      >${this.escapeHtml(this.note || '')}</textarea>
      <div id="rsvp-note-status" style="font-size:0.8em; opacity:0.6; min-height: 16px; margin-top:4px;"></div>
    `;

    this._attachFormListeners();
  }

  _attachFormListeners() {
    if (!this.element) return;
    const root = this.element;

    // Single-tap save — no submit button.  Click any of the 3 choices and
    // we POST immediately with the current note (if any).
    root.querySelectorAll('[data-rsvp-choice]').forEach(btn => {
      btn.addEventListener('click', () => {
        if (this.busy) return;
        const choice = btn.dataset.rsvpChoice;
        if (choice === this.selected) {
          // tapping the already-selected choice still re-saves (picks up
          // any unsent note edits).
        }
        this.selected = choice;
        this._submit();
      });
    });

    // Auto-save the note 800ms after the user stops typing, but only if a
    // status has already been chosen (otherwise there's nothing to attach
    // the note to).
    const noteEl = this.find('#rsvp-note');
    if (noteEl) {
      noteEl.addEventListener('input', () => {
        this.note = noteEl.value.slice(0, 1000);
        clearTimeout(this._noteSaveTimer);
        this._noteSaveTimer = setTimeout(() => {
          if (this.selected && !this.busy) this._submit({ silent: true, source: 'note' });
        }, 800);
      });
      noteEl.addEventListener('blur', () => {
        clearTimeout(this._noteSaveTimer);
        if (this.selected && !this.busy) this._submit({ silent: true, source: 'note' });
      });
    }
  }

  async _submit({ silent = false, source = 'status' } = {}) {
    if (!this.selected || this.busy) return;
    this.busy = true;

    const result      = this.find('#rsvp-result');
    const noteStatus  = this.find('#rsvp-note-status');

    // For status-button clicks, re-render to show the spinner on the tapped
    // button.  Note auto-saves stay quiet (just a small "Saving…" indicator
    // under the textarea) so typing isn't interrupted.
    if (!silent && source === 'status') {
      this._renderForm();
    } else if (noteStatus) {
      noteStatus.textContent = 'Saving…';
      noteStatus.style.color = '';
    }

    try {
      const res = await fetch('/api/rsvp', {
        method:      'POST',
        credentials: 'include',
        headers:     { 'Content-Type': 'application/json' },
        body:        JSON.stringify({
          chat_event_id: this.chatEventId,
          status:        this.selected,
          note:          this.note || null,
        }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      this.busy = false;

      if (source === 'status') {
        const okMsg = {
          yes:   '✅ Saved — see you there!',
          maybe: '🤔 Saved — we’ll keep a spot.',
          no:    '👍 Saved — thanks for letting us know.',
        }[this.selected] || '✅ Saved.';
        this._renderForm();
        const r = this.find('#rsvp-result');
        if (r) {
          r.style.color = '#22c55e';
          r.textContent = okMsg;
        }
      } else {
        // note autosave — show subtle indicator only
        const r = this.find('#rsvp-note-status');
        if (r) {
          r.style.color = '#22c55e';
          r.textContent = '✓ Note saved';
          setTimeout(() => { if (r) r.textContent = ''; }, 2000);
        }
      }
    } catch (err) {
      this.busy = false;
      console.error('rsvp submit failed:', err);
      if (source === 'status') {
        this._renderForm();
        const r = this.find('#rsvp-result');
        if (r) {
          r.style.color = '#ef4444';
          r.textContent = `Could not save: ${err.message}`;
        }
      } else {
        const r = this.find('#rsvp-note-status');
        if (r) {
          r.style.color = '#ef4444';
          r.textContent = `Could not save note: ${err.message}`;
        }
      }
    }
  }
}
