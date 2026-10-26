// RegAsk — "You're set Going but not on the CASA roster yet" (mig 725;
// owner 2026-10-26: "a popup that says your set going but not on liga 1
// roster click here to fill out form so casa can put you on official
// roster so you can play").  The server decides (the Game Center gap
// check, only for a player answering for themselves) and hands back
// reg_ask = {url, waiting, copy} on the RSVP reply; this only draws it.
// The Going is already saved — Later just closes the card.
//
// Shared by #my, Game Center and the /rc roll call card, so it stands
// alone: plain DOM, no app imports.
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  function show(ask) {
    if (!ask || !ask.copy || document.getElementById('fh-reg-ask')) return;
    if (!ask.waiting && !ask.url) return;
    const w = ask.copy;
    const shade = document.createElement('div');
    shade.id = 'fh-reg-ask';
    shade.style.cssText = 'position:fixed; inset:0; z-index:10001; background:rgba(0,0,0,0.55);'
      + 'display:flex; align-items:center; justify-content:center; padding:16px;';
    const edge = ask.waiting ? '#d97706' : '#dc2626';
    const btn = 'border:0; border-radius:10px; padding:11px 16px; font-weight:800; font-size:0.98rem; cursor:pointer;';
    shade.innerHTML = `
      <div role="dialog" aria-modal="true" style="max-width:440px; width:100%; padding:16px 18px; border-radius:14px;
           background:#0f172a; color:#f8fafc; border:2px solid ${edge}; box-shadow:0 10px 30px rgba(0,0,0,0.5); font-family:inherit;">
        <div style="font-weight:800; font-size:1.08rem; margin-bottom:6px;">${ask.waiting ? '⏳' : '⛔'} ${esc(w.title)}</div>
        <div style="font-size:0.92rem; opacity:0.92; line-height:1.4; margin-bottom:14px;">${esc(w.body)}</div>
        <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
          ${ask.waiting
            ? `<button type="button" data-close style="${btn} background:#334155; color:#fff;">${esc(w.ok)}</button>`
            : `<a data-close href="${esc(ask.url)}" target="_blank" rel="noopener"
                  style="${btn} background:#dc2626; color:#fff; text-decoration:none;">${esc(w.fill)}</a>
               <button type="button" data-close style="${btn} background:#334155; color:#fff;">${esc(w.later)}</button>`}
        </div>
      </div>`;
    shade.addEventListener('click', (e) => {
      if (e.target === shade || e.target.closest('[data-close]')) shade.remove();   // the form link still opens
    });
    document.body.appendChild(shade);
  }

  window.RegAsk = { show };
})();
