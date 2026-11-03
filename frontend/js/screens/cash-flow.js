// cash-flow.js — #cash-flow, kept so old links and tiles still work.  The page
// itself is #finances "Money in & out" now (mig 977, owner 2026-11-03: one
// page, not both): this screen shows the same MoneyView.
class CashFlowScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.money = null; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>${window.MoneyView ? MoneyView.css() : ''}</style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cf-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="cf-title">💵 Money In & Out</h1><div id="cf-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" style="max-width:1000px; margin:0 auto;">
        <div id="cf-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#cf-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => { if (this.money && this.money.handleClick(e)) this._renderBody(); });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('cash_flow', tier, tokens) : ''; }

  async load() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    const title = this.find('#cf-title'); if (title) title.textContent = this._copy('title') || '💵 Money In & Out';
    const sub = this.find('#cf-sub'); if (sub) sub.textContent = this._copy('subtitle');
    this.money = new MoneyView(this);
    await this.money.load();
    this._renderBody();
  }

  _renderBody() { const body = this.find('#cf-body'); if (body) body.innerHTML = this.money ? this.money.html() : '<div class="loading">Loading…</div>'; }
}
window.CashFlowScreen = CashFlowScreen;
