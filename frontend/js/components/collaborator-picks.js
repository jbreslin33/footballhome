// CollaboratorPicks — the "🤝 Tag as collaborator" ticks on a post panel
// (mig 1183).  Owner 2026-11-07: "can this be default to tag him on all
// posts? i would have to uncheck him. and we could build a list of others
// later."
//
// The list is social_collaborators (GET /api/social/collaborators): every
// active name shows as a checkbox, ticked when default_on.  body() is what
// the publish POST sends — {collaborators:[ticked names]} — so an unticked
// name stays off that one post.  A screen without these ticks sends no body
// and the server tags the default_on names (SocialController::collaboratorsParam).
// Wording: message_templates social_post/collab_heading, collab_hint.
class CollaboratorPicks {
  static load(auth) {
    if (!CollaboratorPicks._list) {
      CollaboratorPicks._list = auth.fetch('/api/social/collaborators')
        .then(r => r.json())
        .then(b => (b && b.success && Array.isArray(b.data)) ? b.data : [])
        .catch(() => { CollaboratorPicks._list = null; return []; });
    }
    return CollaboratorPicks._list;
  }

  constructor(auth, onChange) {
    this.auth = auth;
    this.onChange = onChange || (() => {});
    this.list = [];
    this.picked = null;   // Set of usernames once the list is in
    CollaboratorPicks.load(auth).then(list => {
      this.list = list;
      if (!this.picked) this.picked = new Set(list.filter(c => c.default_on).map(c => c.username));
      this.onChange();
    });
  }

  copy(tier) { return window.MessageCopy ? MessageCopy.block('social_post', tier) : ''; }

  html(esc, { disabled = false } = {}) {
    if (!this.list.length) return '';
    const heading = this.copy('collab_heading');
    const hint = this.copy('collab_hint');
    return `<div class="collab-picks" style="margin:8px 0; font-size:0.8rem;">
      ${heading ? `<div style="font-weight:700; margin-bottom:3px;">${esc(heading)}</div>` : ''}
      <div style="display:flex; flex-wrap:wrap; gap:4px 14px;">
        ${this.list.map(c => `<label style="display:inline-flex; align-items:center; gap:5px; cursor:pointer;">
          <input type="checkbox" data-collab-pick="${esc(c.username)}" ${this.picked && this.picked.has(c.username) ? 'checked' : ''} ${disabled ? 'disabled' : ''}>
          @${esc(c.username)}</label>`).join('')}
      </div>
      ${hint ? `<div style="font-size:0.7rem; opacity:0.75; margin-top:3px;">${esc(hint)}</div>` : ''}
    </div>`;
  }

  // Wire on a container that holds html(); returns true when it handled e.
  handle(e) {
    const box = e.target.closest && e.target.closest('[data-collab-pick]');
    if (!box || !this.picked) return false;
    const u = box.getAttribute('data-collab-pick');
    if (box.checked) this.picked.add(u); else this.picked.delete(u);
    return true;
  }

  // The publish body: the ticks, or nothing until the list is known (the
  // server then uses the defaults — the same names).
  body() {
    return this.picked ? { collaborators: [...this.picked] } : {};
  }
}

window.CollaboratorPicks = CollaboratorPicks;
