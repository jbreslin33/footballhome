// OnboardingChecklist — 🎓 the person's own volunteer → paid path, in the
// 🚦 band's popup (mig 1526).  Owner 2026-11-19: the club's new-coach email
// as a checklist "on their calendar as outstanding items like missing rsvps
// … but has actionable links" → "this way they feel like they have path to
// get paid and thus are motivated to volunteer".
//
//   🙋 Step 1 · Cleared to volunteer   clearances + ID (every step a row:
//                                      state, what it costs, how, [Apply ›] [✅ I sent it])
//   💵 Step 2 · Ready to be paid       W-9, direct deposit — for a volunteer
//                                      shown as what comes next (no buttons)
//
//   GET  /api/my/onboarding            { onboarding: {track, steps, left, total} | null }
//   POST /api/my/onboarding {code, sent}
//
//   const c = new OnboardingChecklist(el, { fetchJson, escapeHtml, onChange(data) });
//   c.set(data); c.render();
// Words: message_templates kind onboarding.
class OnboardingChecklist {
  constructor(el, ctx) {
    this.el = el;
    this.ctx = ctx;
    this.data = null;
    this.busy = new Set();
    this.err = '';
    if (el) {
      el.addEventListener('click', (e) => {
        const b = e.target.closest('[data-onb-sent]');
        if (b && !b.disabled) { this.markSent(b.getAttribute('data-onb-sent'), b.getAttribute('data-onb-on') === '1'); return; }
        const up = e.target.closest('[data-onb-upload]');
        if (up && !up.disabled) { const inp = el.querySelector(`input[data-onb-file="${up.getAttribute('data-onb-upload')}"]`); if (inp) inp.click(); return; }
        const rm = e.target.closest('[data-onb-rmfile]');
        if (rm && !rm.disabled) this.removeFile(Number(rm.getAttribute('data-onb-rmfile')));
      });
      el.addEventListener('change', (e) => {
        const inp = e.target.closest('input[data-onb-file]');
        if (inp && inp.files && inp.files[0]) { const f = inp.files[0]; inp.value = ''; this.upload(inp.getAttribute('data-onb-file'), f); }
      });
    }
  }

  // A picked file → { filename, file: data URL }.  Big photos are shrunk on
  // the phone first (longest side 2000 px, JPEG) so a camera shot uploads
  // fast and the compliance email stays small; PDFs go as they are.
  static readFile(file) {
    const asDataUrl = (blob) => new Promise((res, rej) => {
      const r = new FileReader(); r.onload = () => res(r.result); r.onerror = () => rej(new Error('Could not read the file')); r.readAsDataURL(blob);
    });
    const name = file.name || 'upload';
    if (!/^image\/(jpeg|png|webp)$/.test(file.type) || file.size < 1.5 * 1024 * 1024) return asDataUrl(file).then(d => ({ filename: name, file: d }));
    return new Promise((resolve) => {
      const url = URL.createObjectURL(file);
      const img = new Image();
      img.onload = () => {
        const k = Math.min(1, 2000 / Math.max(img.width, img.height));
        const c = document.createElement('canvas');
        c.width = Math.round(img.width * k); c.height = Math.round(img.height * k);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);
        resolve({ filename: name.replace(/\.[^.]+$/, '') + '.jpg', file: c.toDataURL('image/jpeg', 0.85) });
      };
      img.onerror = () => { URL.revokeObjectURL(url); asDataUrl(file).then(d => resolve({ filename: name, file: d })); };
      img.src = url;
    });
  }

  // The file chips under a step: name (+ ✕ while it can still be taken back).
  static filesHtml(files, esc, { removable, viewable } = {}) {
    if (!Array.isArray(files) || !files.length) return '';
    return `<div style="display:flex; gap:5px; flex-wrap:wrap;">${files.map(f => `
        <span style="display:inline-flex; align-items:center; gap:5px; max-width:100%; padding:3px 8px; border-radius:999px; border:1px solid rgba(255,255,255,0.25); font-size:0.76rem;">
          <span style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:180px;">📄 ${esc(f.filename)}</span>${f.emailed_at ? ' ✉️' : ''}
          ${viewable ? `<button type="button" data-onb-view="${f.id}" style="min-height:0; padding:0 4px; border:0; background:none; color:inherit; cursor:pointer; font:inherit;">${esc(OnboardingChecklist.t('view_file', {}, '👁'))}</button>` : ''}
          ${removable && (viewable || !f.emailed_at) ? `<button type="button" data-onb-rmfile="${f.id}" style="min-height:0; padding:0 4px; border:0; background:none; color:#fca5a5; cursor:pointer; font:inherit; font-weight:800;">${esc(OnboardingChecklist.t('remove_file', {}, '✕'))}</button>` : ''}
        </span>`).join('')}</div>`;
  }

  async upload(code, file) {
    if (!code || this.busy.has(code)) return;
    this.busy.add(code);
    this.err = '';
    this.render();
    try {
      const f = await OnboardingChecklist.readFile(file);
      const body = await this.ctx.fetchJson('/api/my/onboarding/upload', { method: 'POST', body: JSON.stringify({ code, filename: f.filename, file: f.file }) });
      this.data = body.onboarding || null;
      if (this.ctx.onChange) this.ctx.onChange(this.data);
    } catch (err) {
      this.err = err.message;
    }
    this.busy.delete(code);
    this.render();
  }

  async removeFile(id) {
    if (!id || this.busy.has(`f${id}`)) return;
    this.busy.add(`f${id}`);
    this.err = '';
    try {
      const body = await this.ctx.fetchJson('/api/my/onboarding/file-remove', { method: 'POST', body: JSON.stringify({ id }) });
      this.data = body.onboarding || null;
      if (this.ctx.onChange) this.ctx.onChange(this.data);
    } catch (err) {
      this.err = err.message;
    }
    this.busy.delete(`f${id}`);
    this.render();
  }

  static t(tier, tokens, fb) {
    const has = window.MessageCopy && MessageCopy.has && MessageCopy.has('onboarding', tier);
    return has ? MessageCopy.block('onboarding', tier, tokens || {})
      : String(fb).replace(/\{(\w+)\}/g, (m, k) => (tokens && k in tokens ? tokens[k] : m));
  }

  static money(n) { return `$${(Number(n) || 0).toFixed(2).replace(/\.00$/, '')}`; }

  // The state chip: ⬜ To do · 🟡 Sent — club checking · ✅ Done · ⛔ Renew.
  static stateHtml(st, esc) {
    const t = OnboardingChecklist.t;
    const m = {
      todo:  ['state_todo', '⬜ To do', '#fca5a5'],
      sent:  ['state_sent', '🟡 Sent — club checking', '#facc15'],
      done:  ['state_done', '✅ Done', '#4ade80'],
      renew: ['state_renew', '⛔ Renew — expired', '#f87171'],
    }[st] || ['state_todo', '⬜ To do', '#fca5a5'];
    return `<span style="font-size:0.74rem; font-weight:800; color:${m[2]}; white-space:nowrap;">${esc(t(m[0], {}, m[1]))}</span>`;
  }

  set(data) { this.data = data || null; this.render(); }

  async markSent(code, on) {
    if (!code || this.busy.has(code)) return;
    this.busy.add(code);
    this.err = '';
    this.render();
    try {
      const body = await this.ctx.fetchJson('/api/my/onboarding', { method: 'POST', body: JSON.stringify({ code, sent: on }) });
      this.data = body.onboarding || null;
      if (this.ctx.onChange) this.ctx.onChange(this.data);
    } catch (err) {
      this.err = err.message;
    }
    this.busy.delete(code);
    this.render();
  }

  render() {
    if (!this.el) return;
    const esc = (s) => this.ctx.escapeHtml(s == null ? '' : String(s));
    const t = OnboardingChecklist.t;
    const d = this.data;
    if (!d) { this.el.innerHTML = ''; return; }
    const paid = d.track === 'paid';
    const steps = Array.isArray(d.steps) ? d.steps : [];
    const row = (s, live, n) => {
      const cost = s.cost_usd == null ? '' : Number(s.cost_usd) > 0
        ? t('cost', { amount: OnboardingChecklist.money(s.cost_usd) }, '{amount}') : t('cost_free', {}, 'Free');
      const busy = this.busy.has(s.code);
      // 📎 Upload is the way in (owner 11/19 "collect it all"); Undo only
      // for a step marked sent before uploads existed.
      const files = Array.isArray(s.files) ? s.files : [];
      const canUpload = live && s.state !== 'done';
      const canUndo = live && s.state === 'sent' && !files.length;
      const link = s.link_url && /^https:\/\//.test(s.link_url)
        ? `<a href="${esc(s.link_url)}" target="_blank" rel="noopener" style="display:inline-block; padding:5px 11px; border-radius:999px; background:#1d4ed8; color:#fff; font-weight:800; font-size:0.8rem; text-decoration:none;">${esc(s.link_label || '›')}</a>` : '';
      const btns = [
        live ? link : '',
        canUpload ? `<button type="button" data-onb-upload="${esc(s.code)}" ${busy ? 'disabled' : ''} style="min-height:0; padding:5px 11px; border-radius:999px; border:1px solid #22c55e; background:${files.length ? 'transparent' : '#16a34a'}; color:${files.length ? '#22c55e' : '#fff'}; font:inherit; font-weight:800; font-size:0.8rem; cursor:pointer;">${esc(busy ? t('uploading', {}, 'Uploading…') : files.length ? t('upload_more', {}, '📎 Add another') : t('upload', {}, '📎 Upload'))}</button><input type="file" data-onb-file="${esc(s.code)}" accept="image/*,application/pdf" hidden>` : '',
        canUndo ? `<button type="button" data-onb-sent="${esc(s.code)}" data-onb-on="0" ${busy ? 'disabled' : ''} style="min-height:0; padding:5px 11px; border-radius:999px; border:1px solid #6b7280; background:transparent; color:#d1d5db; font:inherit; font-weight:700; font-size:0.78rem; cursor:pointer;">${esc(t('undo_sent', {}, 'Undo'))}</button>` : '',
      ].filter(Boolean).join('');
      const exp = s.state === 'done' && s.expires_at ? ` · ${esc(new Date(s.expires_at).toLocaleDateString('en-US', { month: 'short', year: 'numeric' }))}` : '';
      return `<div style="display:flex; flex-direction:column; gap:4px; padding:9px 11px; border-radius:10px; border:1px solid ${s.state === 'done' ? 'rgba(74,222,128,0.45)' : 'rgba(255,255,255,0.18)'}; background:rgba(255,255,255,0.03); ${live ? '' : 'opacity:0.6;'}">
          <div style="display:flex; align-items:baseline; gap:8px; flex-wrap:wrap;">
            <span style="flex:1; min-width:160px; font-weight:800; font-size:0.9rem;"><span style="opacity:0.6;">${n}.</span> ${esc(s.label)}</span>
            ${live ? `${OnboardingChecklist.stateHtml(s.state, esc)}${exp}` : ''}
          </div>
          ${(s.how || cost) && s.state !== 'done' ? `<div style="font-size:0.8rem; opacity:0.88; line-height:1.35;">${cost ? `<b>${esc(cost)}</b>${s.how ? ' · ' : ''}` : ''}${esc(s.how || '')}</div>` : ''}
          ${s.note && s.state !== 'done' ? `<div style="font-size:0.8rem; color:#fca5a5; font-weight:700;">${esc(s.note)}</div>` : ''}
          ${live ? OnboardingChecklist.filesHtml(files, esc, { removable: s.state !== 'done' }) : ''}
          ${btns ? `<div style="display:flex; gap:6px; flex-wrap:wrap;">${btns}</div>` : ''}
        </div>`;
    };
    const stage = (key, list, live, sub, start) => !list.length ? '' : `
        <div style="margin-top:10px;">
          <div style="font-weight:900; font-size:0.92rem; color:#f5d442;">${esc(t(`stage_${key}`, {}, key === 'paid' ? '💵 Step 2 · Ready to be paid' : '🙋 Step 1 · Cleared to volunteer'))}</div>
          ${sub ? `<div style="font-size:0.78rem; opacity:0.8; margin-top:1px;">${esc(sub)}</div>` : ''}
          <div style="display:flex; flex-direction:column; gap:6px; margin-top:6px;">${list.map((s, i) => row(s, live, start + i + 1)).join('')}</div>
        </div>`;
    const vol = steps.filter(s => s.stage === 'volunteer');
    const pay = steps.filter(s => s.stage === 'paid');
    this.el.innerHTML = `
      <div style="font-size:0.85rem; line-height:1.4; opacity:0.92;">${esc(paid ? t('intro_paid', {}, 'Finish every step so the club can pay you.')
        : t('intro_volunteer', {}, "Step 1 clears you to coach and volunteer with our kids. Step 2 is the paperwork for a paid role — finish step 1 and you're ready when one opens."))}</div>
      ${stage('volunteer', vol, true, '', 0)}
      ${stage('paid', pay, paid, paid ? '' : t('stage_paid_next', {}, 'Next, when the club offers you a paid role'), vol.length)}
      ${this.err ? `<div style="margin-top:8px; font-size:0.8rem; color:#fca5a5;">${esc(this.err)}</div>` : ''}
      <div style="margin-top:12px; font-size:0.78rem; opacity:0.75;">${esc(t('questions', {}, 'Questions or need help with a clearance? Message the club.'))}</div>`;
  }
}

window.OnboardingChecklist = OnboardingChecklist;
