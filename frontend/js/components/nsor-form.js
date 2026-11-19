// NsorForm — ✍️ the NSOR application filled in on FootballHome (mig 1558).
// Owner 2026-11-19: "i thought for nsor we let them fill out on fh and do
// email for them? like for invoices" → "where can we get blank one online
// and get it to fh".
//
// The volunteer types the fields (pre-filled from what FootballHome knows)
// and signs with a finger; this fills the OFFICIAL blank — DHS form CY 1001
// (5/24) from pa.gov, served as /forms/nsor-cy1001-blank.pdf — in the browser
// with pdf-lib, and hands back a flattened PDF (data URL).  The server
// (POST /api/my/onboarding/nsor-send) stores it on the step and emails it to
// RA-PWNSOR@pa.gov, subject "NSOR Verification <last name>".  The SSN and
// date of birth exist only inside that PDF.
//
// The form's fields (checked against the printed labels, 11/19):
//   Name · SSN · DOB · Phone · Address (street) · Text Field 5 (city, state,
//   ZIP) · Text Field 7 (email) · Text Field 9 (signature line) ·
//   Text Field 10 (date) · Check Box 2 (working for a provider) ·
//   Check Box 4 (volunteer).
//
//   const f = new NsorForm(el, { prefill, track, t, esc, onCancel, onSend(payload) });
//   f.render();
class NsorForm {
  static BLANK = '/forms/nsor-cy1001-blank.pdf';
  static LIB = '/js/vendor/pdf-lib-1.17.1.min.js';

  constructor(el, opts) {
    this.el = el;
    this.o = opts;
    const p = opts.prefill || {};
    const street = [p.address1, p.address2].filter(Boolean).join(' ');
    this.v = {
      last: p.last_name || '', first: p.first_name || '', mi: '', ssn: '', dob: p.dob || '',
      phone: NsorForm.fmtPhone(p.phone || ''), street, city: p.city || '', state: p.state || 'PA', zip: p.zip || '',
      email: p.email || '',
    };
    this.signed = false;
    this.err = '';
    this.busy = false;
  }

  static digits(s) { return String(s || '').replace(/\D/g, ''); }
  static fmtPhone(s) { const d = NsorForm.digits(s).replace(/^1(?=\d{10}$)/, ''); return d.length === 10 ? `${d.slice(0, 3)}-${d.slice(3, 6)}-${d.slice(6)}` : s; }
  static fmtSsn(s) { const d = NsorForm.digits(s); return d.length === 9 ? `${d.slice(0, 3)}-${d.slice(3, 5)}-${d.slice(5)}` : s; }
  static validDob(s) {
    const m = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec(String(s).trim());
    if (!m) return false;
    const d = new Date(Number(m[3]), Number(m[1]) - 1, Number(m[2]));
    return d.getMonth() === Number(m[1]) - 1 && d.getFullYear() > 1900 && d < new Date();
  }

  // What is still missing, in the form's own words.
  // Which fields are still empty or wrong: [{ key, label }] (key 'sig' = the signature).
  bad() {
    const v = this.v, t = this.o.t, out = [];
    const need = (ok, key, tier, fb) => { if (!ok) out.push({ key, label: t(tier, {}, fb) }); };
    need(v.last.trim(), 'last', 'nsor_f_last', 'Last name');
    need(v.first.trim(), 'first', 'nsor_f_first', 'First name');
    need(NsorForm.validDob(v.dob), 'dob', 'nsor_f_dob', 'Date of birth');
    need(NsorForm.digits(v.ssn).length === 9, 'ssn', 'nsor_f_ssn', 'Social Security number');
    need(NsorForm.digits(v.phone).replace(/^1(?=\d{10}$)/, '').length === 10, 'phone', 'nsor_f_phone', 'Daytime phone');
    need(v.street.trim(), 'street', 'nsor_f_street', 'Street address (apt #)');
    need(v.city.trim(), 'city', 'nsor_f_city', 'City');
    need(/^[A-Za-z]{2}$/.test(v.state.trim()), 'state', 'nsor_f_state', 'State');
    need(/^\d{5}(-\d{4})?$/.test(v.zip.trim()), 'zip', 'nsor_f_zip', 'ZIP');
    need(/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(v.email.trim()), 'email', 'nsor_f_email', 'Email');
    need(this.signed, 'sig', 'nsor_f_sign', 'Signature');
    return out;
  }
  missing() { return this.bad().map(b => b.label); }

  render() {
    const { t, esc } = this.o;
    const v = this.v;
    const input = (key, tier, fb, attrs = '') => `
      <label style="display:flex; flex-direction:column; gap:2px; font-size:0.78rem; font-weight:700;">${esc(t(tier, {}, fb))}
        <input data-nsor="${key}" value="${esc(v[key])}" ${attrs} style="padding:8px 9px; border-radius:7px; border:1px solid rgba(255,255,255,0.3); background:rgba(0,0,0,0.25); color:inherit; font:inherit; font-size:0.95rem; font-weight:600;"></label>`;
    const miss = this.missing();
    this.el.innerHTML = `
      <div style="font-weight:900; font-size:1rem; margin-bottom:4px;">${esc(t('nsor_title', {}, '✍️ NSOR form'))}</div>
      <div style="font-size:0.8rem; opacity:0.85; line-height:1.35; margin-bottom:10px;">${esc(t('nsor_intro', {}, "Type your details exactly as on your ID, then sign. We fill in the official state form and email it to the state for you. Your SSN is only on the form — FootballHome doesn't keep it."))}</div>
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px;">
        ${input('last', 'nsor_f_last', 'Last name', 'autocomplete="family-name"')}
        ${input('first', 'nsor_f_first', 'First name', 'autocomplete="given-name"')}
        ${input('mi', 'nsor_f_mi', 'Middle initial', 'maxlength="1"')}
        ${input('dob', 'nsor_f_dob', 'Date of birth', 'inputmode="numeric" placeholder="MM/DD/YYYY" autocomplete="bday"')}
        <div style="grid-column:1 / -1;">${input('ssn', 'nsor_f_ssn', 'Social Security number', 'inputmode="numeric" placeholder="XXX-XX-XXXX" autocomplete="off"')}</div>
        <div style="grid-column:1 / -1;">${input('phone', 'nsor_f_phone', 'Daytime phone', 'inputmode="tel" placeholder="XXX-XXX-XXXX" autocomplete="tel"')}</div>
        <div style="grid-column:1 / -1;">${input('street', 'nsor_f_street', 'Street address (apt #)', 'autocomplete="street-address"')}</div>
        ${input('city', 'nsor_f_city', 'City', 'autocomplete="address-level2"')}
        <div style="display:grid; grid-template-columns:70px 1fr; gap:8px;">${input('state', 'nsor_f_state', 'State', 'maxlength="2"')}${input('zip', 'nsor_f_zip', 'ZIP', 'inputmode="numeric"')}</div>
        <div style="grid-column:1 / -1;">${input('email', 'nsor_f_email', 'Email (the state sends your letter here)', 'type="email" autocomplete="email"')}</div>
      </div>
      <div style="margin-top:10px; font-size:0.78rem; font-weight:700;">${esc(t('nsor_f_sign', {}, 'Sign here with your finger'))}
        <button type="button" data-nsor-clear style="float:right; min-height:0; padding:1px 8px; border-radius:999px; border:1px solid rgba(255,255,255,0.35); background:transparent; color:inherit; font:inherit; font-size:0.75rem; cursor:pointer;">${esc(t('nsor_clear_sign', {}, 'Clear'))}</button></div>
      <canvas data-nsor-sig width="600" height="160" style="margin-top:4px; width:100%; height:110px; border-radius:8px; background:#fff; touch-action:none; cursor:crosshair;"></canvas>
      <div style="margin-top:8px; font-size:0.72rem; opacity:0.8; line-height:1.35;">${esc(t('nsor_affirm', {}, 'I affirm the above information is accurate and complete to the best of my knowledge and belief, and submitted as true and correct under penalty of law per Section 4904 of the Pennsylvania Crimes Code.'))}</div>
      <div data-nsor-miss style="margin-top:8px; font-size:0.82rem; color:#f87171; font-weight:800;">${miss.length && this.tried ? esc(t('nsor_missing', { list: miss.join(', ') }, 'Still needed: {list}')) : ''}</div>
      ${this.err ? `<div style="margin-top:6px; font-size:0.82rem; color:#fca5a5; font-weight:700;">${esc(this.err)}</div>` : ''}
      <div style="display:flex; gap:8px; margin-top:10px; flex-wrap:wrap;">
        <button type="button" data-nsor-send ${this.busy ? 'disabled' : ''} style="min-height:0; padding:9px 14px; border-radius:999px; border:0; background:#16a34a; color:#fff; font:inherit; font-weight:900; cursor:pointer;">${esc(this.busy ? t('nsor_sending', {}, 'Sending…') : t('nsor_send', {}, '✉️ Sign & send to the state'))}</button>
        <button type="button" data-nsor-cancel style="min-height:0; padding:9px 14px; border-radius:999px; border:1px solid rgba(255,255,255,0.35); background:transparent; color:inherit; font:inherit; font-weight:700; cursor:pointer;">${esc(t('nsor_cancel', {}, 'Back'))}</button>
      </div>`;
    this._wire();
    this._paintBad();
  }

  // Red on every field still empty or wrong (owner 11/19 "it should warn if
  // not all filled out. with red highlight"): all of them once Send was
  // tapped, before that only the ones the person has left.
  _paintBad() {
    const bad = new Set(this.bad().map(b => b.key));
    this.touched = this.touched || new Set();
    this.el.querySelectorAll('input[data-nsor]').forEach(inp => {
      const red = bad.has(inp.dataset.nsor) && (this.tried || this.touched.has(inp.dataset.nsor));
      inp.style.border = red ? '2px solid #ef4444' : '1px solid rgba(255,255,255,0.3)';
      inp.style.background = red ? 'rgba(239,68,68,0.15)' : 'rgba(0,0,0,0.25)';
    });
    const sig = this.el.querySelector('[data-nsor-sig]');
    if (sig) sig.style.outline = bad.has('sig') && this.tried ? '3px solid #ef4444' : 'none';
  }

  _wire() {
    const el = this.el;
    el.querySelectorAll('input[data-nsor]').forEach(inp => {
      inp.addEventListener('input', () => { this.v[inp.dataset.nsor] = inp.value; this._refreshMissing(); });
      inp.addEventListener('blur', () => { (this.touched = this.touched || new Set()).add(inp.dataset.nsor); this._paintBad(); });
    });
    el.querySelector('[data-nsor-cancel]').addEventListener('click', () => this.o.onCancel && this.o.onCancel());
    el.querySelector('[data-nsor-send]').addEventListener('click', () => this._send());
    const c = el.querySelector('[data-nsor-sig]');
    const ctx = c.getContext('2d');
    ctx.lineWidth = 3; ctx.lineCap = 'round'; ctx.lineJoin = 'round'; ctx.strokeStyle = '#0b1f5c';
    if (this.sigData) { const img = new Image(); img.onload = () => ctx.drawImage(img, 0, 0); img.src = this.sigData; }
    let drawing = false, strokes = 0;
    const at = (e) => { const r = c.getBoundingClientRect(); return [(e.clientX - r.left) * c.width / r.width, (e.clientY - r.top) * c.height / r.height]; };
    c.addEventListener('pointerdown', (e) => { drawing = true; c.setPointerCapture(e.pointerId); const [x, y] = at(e); ctx.beginPath(); ctx.moveTo(x, y); });
    c.addEventListener('pointermove', (e) => { if (!drawing) return; const [x, y] = at(e); ctx.lineTo(x, y); ctx.stroke(); strokes++; });
    const end = () => {
      if (!drawing) return;
      drawing = false;
      if (strokes > 4) { this.signed = true; this.sigData = c.toDataURL('image/png'); this._refreshMissing(); }
    };
    c.addEventListener('pointerup', end); c.addEventListener('pointercancel', end);
    el.querySelector('[data-nsor-clear]').addEventListener('click', () => {
      ctx.clearRect(0, 0, c.width, c.height); this.signed = false; this.sigData = null; strokes = 0; this._refreshMissing();
    });
  }

  _refreshMissing() {
    const miss = this.missing();
    const box = this.el.querySelector('[data-nsor-miss]');
    if (box) box.textContent = miss.length && this.tried ? this.o.t('nsor_missing', { list: miss.join(', ') }, 'Still needed: {list}') : '';
    this._paintBad();
  }

  static loadLib() {
    if (window.PDFLib) return Promise.resolve(window.PDFLib);
    if (!NsorForm._lib) NsorForm._lib = new Promise((res, rej) => {
      const s = document.createElement('script');
      s.src = NsorForm.LIB; s.onload = () => res(window.PDFLib); s.onerror = () => { NsorForm._lib = null; rej(new Error('Could not load the form tools')); };
      document.head.appendChild(s);
    });
    return NsorForm._lib;
  }

  // The filled, flattened official form as a data URL.
  async buildPdf() {
    const v = this.v;
    const PDFLib = await NsorForm.loadLib();
    const blank = await fetch(NsorForm.BLANK).then(r => { if (!r.ok) throw new Error('Could not load the blank form'); return r.arrayBuffer(); });
    const doc = await PDFLib.PDFDocument.load(blank);
    const form = doc.getForm();
    const set = (name, text) => form.getTextField(name).setText(text);
    const up = (s) => String(s || '').trim();
    set('Name', `${up(v.last)}, ${up(v.first)}${up(v.mi) ? `, ${up(v.mi).toUpperCase()}` : ''}`);
    set('SSN', NsorForm.fmtSsn(v.ssn));
    const [mm, dd, yyyy] = up(v.dob).split('/');
    set('DOB', `${mm.padStart(2, '0')}/${dd.padStart(2, '0')}/${yyyy}`);
    set('Phone', NsorForm.fmtPhone(v.phone));
    set('Address', up(v.street));
    set('Text Field 5', `${up(v.city)}, ${up(v.state).toUpperCase()} ${up(v.zip)}`);
    set('Text Field 7', up(v.email));
    const now = new Date();
    set('Text Field 10', `${String(now.getMonth() + 1).padStart(2, '0')}/${String(now.getDate()).padStart(2, '0')}/${now.getFullYear()}`);
    // Purpose, one box: a volunteer → Volunteer; on the paid track → working for a provider.
    form.getCheckBox(this.o.track === 'paid' ? 'Check Box 2' : 'Check Box 4').check();
    // The signature on the signature line (Text Field 9 is at 100,41 · 256×19).
    const png = await doc.embedPng(this.sigData);
    const dims = png.scaleToFit(250, 26);
    doc.getPages()[0].drawImage(png, { x: 102, y: 40, width: dims.width, height: dims.height });
    form.flatten();
    return doc.saveAsBase64({ dataUri: true });
  }

  async _send() {
    if (this.busy) return;
    const bad = this.bad();
    if (bad.length) {
      // Nothing goes out: every gap turns red and the first one comes into view.
      this.tried = true;
      this._refreshMissing();
      const first = bad[0].key === 'sig' ? this.el.querySelector('[data-nsor-sig]') : this.el.querySelector(`input[data-nsor="${bad[0].key}"]`);
      if (first) { first.scrollIntoView({ behavior: 'smooth', block: 'center' }); if (first.focus && bad[0].key !== 'sig') first.focus({ preventScroll: true }); }
      return;
    }
    this.busy = true; this.err = '';
    this._refreshMissing();
    const btn = this.el.querySelector('[data-nsor-send]');
    if (btn) btn.textContent = this.o.t('nsor_sending', {}, 'Sending…');
    try {
      const file = await this.buildPdf();
      const v = this.v;
      await this.o.onSend({ file, last_name: v.last.trim(), full_name: `${v.first.trim()} ${v.last.trim()}`, email: v.email.trim() });
    } catch (err) {
      this.err = err.message || 'Could not send';
      this.busy = false;
      this.render();
    }
  }
}

window.NsorForm = NsorForm;
