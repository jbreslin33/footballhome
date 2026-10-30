// in-house-proposal.js — #in-house-proposal: the case for youth in-house (mig 900).
//
// A page of copy and nothing else: every word and number is a message_templates
// row, kind 'in_house_proposal'.  A body line starting "- " is a bullet;
// plan_rows is one age per line, cells split by |.
class InHouseProposalScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ihp-wrap { max-width:760px; margin:0 auto; }
        .ihp-strip { display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:var(--space-3); margin-bottom:var(--space-3); }
        .ihp-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .ihp-strip .ihp-card { margin-bottom:0; }
        .ihp-big { font-size:1.6rem; font-weight:800; }
        .ihp-sub { font-size:0.85rem; opacity:0.8; }
        .ihp-head { font-weight:700; font-size:1.05rem; margin-bottom:8px; }
        .ihp-card p { margin:0 0 8px; line-height:1.5; }
        .ihp-card ul { margin:0; padding-left:20px; line-height:1.5; }
        .ihp-card li { margin-bottom:6px; }
        .ihp-scroll { overflow-x:auto; }
        .ihp-table { border-collapse:collapse; font-size:0.85rem; width:100%; }
        .ihp-table th { padding:4px 8px; text-align:left; opacity:0.7; font-weight:600; white-space:nowrap; }
        .ihp-table td { padding:6px 8px; text-align:left; border-top:1px solid var(--border-color, #374151); }
        .ihp-note { opacity:0.7; font-size:0.8rem; margin-top:8px; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="ihp-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="ihp-title"></h1><div id="ihp-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content"><div class="ihp-wrap" id="ihp-body"></div></div>`;
    div.querySelector('#ihp-back').addEventListener('click', () => this.navigation.goBack());
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier) { return window.MessageCopy ? MessageCopy.block('in_house_proposal', tier) : ''; }
  _esc(text) { const d = document.createElement('div'); d.textContent = text; return d.innerHTML; }

  async load() {
    const user = this.navigation.context.user;
    if (!['club', 'sport_division', 'team', 'super', 'system', 'league'].includes(user?.role)) { this.navigation.goBack(); return; }
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    this.find('#ihp-title').textContent = this._copy('title');
    this.find('#ihp-sub').textContent = this._copy('subtitle');
    this.find('#ihp-body').innerHTML = [
      this._section('ask'),
      `<div class="ihp-strip">${[1, 2, 3].map(n => this._stat(n)).join('')}</div>`,
      this._section('family'),
      this._section('slot'),
      this._plan(),
      this._section('risk'),
      this._section('open'),
    ].join('');
  }

  _stat(n) {
    return `<div class="ihp-card"><div class="ihp-big">${this._esc(this._copy(`stat_${n}_value`))}</div><div class="ihp-sub">${this._esc(this._copy(`stat_${n}_label`))}</div></div>`;
  }

  _section(key) {
    return `<div class="ihp-card"><div class="ihp-head">${this._esc(this._copy(`${key}_head`))}</div>${this._body(this._copy(`${key}_body`))}</div>`;
  }

  _body(text) {
    const lines = text.split('\n').filter(l => l.trim());
    const bullets = lines.filter(l => l.startsWith('- ')).map(l => `<li>${this._esc(l.slice(2))}</li>`).join('');
    const paras = lines.filter(l => !l.startsWith('- ')).map(l => `<p>${this._esc(l)}</p>`).join('');
    return paras + (bullets ? `<ul>${bullets}</ul>` : '');
  }

  _plan() {
    const cells = (line, tag) => line.split('|').map(c => `<${tag}>${this._esc(c)}</${tag}>`).join('');
    const rows = this._copy('plan_rows').split('\n').filter(l => l.trim()).map(l => `<tr>${cells(l, 'td')}</tr>`).join('');
    return `<div class="ihp-card"><div class="ihp-head">${this._esc(this._copy('plan_head'))}</div>
      <div class="ihp-scroll"><table class="ihp-table"><thead><tr>${cells(this._copy('plan_cols'), 'th')}</tr></thead><tbody>${rows}</tbody></table></div>
      <div class="ihp-note">${this._esc(this._copy('plan_note'))}</div></div>`;
  }
}
