// HolidayTheme — 🎉 the app dresses for each holiday (migration 1951).
//
// Owner 2026-11-26: "can we get a holiday theme for each holiday for fh?
// like its thanks giving now then shift to christmas and jewish and muslim
// holidays and new year valentine saint patrick etc".
//
// Everything comes from the DB (holiday_themes + holiday_theme_dates) via
// GET /api/public/holiday-theme — no holiday, colour or greeting lives here.
// On a holiday:
//   • --accent (lighthouse yellow) becomes the holiday's colour everywhere
//   • a thin two-colour band + the greeting(s) sit at the foot of the
//     #top-banners stack (✕ hides the greeting for that holiday; colours stay)
//   • the holiday's emoji drift down on every page load (owner 2026-11-27;
//     was once per tab) — skipped on solemn days,
//     whose decor is {}, and under prefers-reduced-motion)
// Several holidays on one day (Christmas + Hanukkah 2027): the first —
// shortest window — gives the colours, every greeting is shown.
//
// Preview any theme: ?holiday=<code>  or a day: ?holiday_on=YYYY-MM-DD
(function () {
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const COLOR = /^#[0-9a-fA-F]{3,8}$/;

  function hexToRgba(hex, a) {
    let h = hex.replace('#', '');
    if (h.length === 3) h = h.split('').map(c => c + c).join('');
    const n = parseInt(h.slice(0, 6), 16);
    return `rgba(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255},${a})`;
  }

  function applyColours(t) {
    if (!COLOR.test(t.accent || '')) return;
    const root = document.documentElement.style;
    root.setProperty('--accent', t.accent);
    root.setProperty('--accent-dim', hexToRgba(t.accent, 0.15));
    root.setProperty('--holiday-accent2', COLOR.test(t.accent2 || '') ? t.accent2 : t.accent);
    document.documentElement.dataset.holiday = t.code;
  }

  function drawBand(themes) {
    const stack = document.getElementById('top-banners');
    if (!stack) return;
    const first = themes[0];
    const a1 = first.accent, a2 = COLOR.test(first.accent2 || '') ? first.accent2 : a1;
    const hideKey = 'fh_holiday_hidden_' + themes.map(t => t.code).join('+') + '_' + new Date().getFullYear();
    const hidden = localStorage.getItem(hideKey) === '1';
    let band = document.getElementById('holiday-band');
    if (!band) { band = document.createElement('div'); band.id = 'holiday-band'; stack.appendChild(band); }
    const stripe = `<div style="height:3px;background:linear-gradient(90deg,${a1},${a2},${a1});"></div>`;
    if (hidden) { band.innerHTML = stripe; return; }
    const words = themes.map(t => `${esc(t.emoji)} ${esc(t.greeting)}`).join('<span style="opacity:.5;margin:0 8px;">·</span>');
    band.innerHTML = stripe + `
      <div style="display:flex;align-items:center;justify-content:center;gap:10px;
                  padding:5px 36px 5px 12px;position:relative;font-size:var(--text-sm,14px);font-weight:600;
                  color:var(--text-primary,#e8f0ff);
                  background:linear-gradient(90deg,${hexToRgba(a1, 0.18)},${hexToRgba(a2, 0.12)},${hexToRgba(a1, 0.18)});
                  text-align:center;">
        <span>${words}</span>
        <button type="button" aria-label="Hide greeting" title="Hide greeting"
                style="position:absolute;right:8px;top:50%;transform:translateY(-50%);background:none;border:0;
                       color:inherit;opacity:.6;cursor:pointer;font-size:14px;padding:4px;">✕</button>
      </div>`;
    band.querySelector('button').addEventListener('click', () => {
      localStorage.setItem(hideKey, '1');
      drawBand(themes);
    });
  }

  function drift(t) {
    const decor = Array.isArray(t.decor) ? t.decor.filter(Boolean) : [];
    if (!decor.length) return;
    if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    if (!document.getElementById('holiday-drift-style')) {
      const st = document.createElement('style');
      st.id = 'holiday-drift-style';
      st.textContent = `@keyframes fh-holiday-fall {
          0%   { transform: translate3d(0,-10vh,0) rotate(0deg); opacity: 0; }
          10%  { opacity: .9; }
          100% { transform: translate3d(var(--dx),105vh,0) rotate(var(--rot)); opacity: 0; } }
        .fh-holiday-flake { position: fixed; top: 0; pointer-events: none; z-index: 10001;
          animation: fh-holiday-fall linear forwards; will-change: transform; }`;
      document.head.appendChild(st);
    }
    const layer = document.createElement('div');
    layer.setAttribute('aria-hidden', 'true');
    const N = 16;
    for (let i = 0; i < N; i++) {
      const f = document.createElement('span');
      f.className = 'fh-holiday-flake';
      f.textContent = decor[i % decor.length];
      f.style.left = (Math.random() * 100) + 'vw';
      f.style.fontSize = (16 + Math.random() * 16) + 'px';
      f.style.setProperty('--dx', ((Math.random() - 0.5) * 30) + 'vw');
      f.style.setProperty('--rot', ((Math.random() - 0.5) * 540) + 'deg');
      f.style.animationDuration = (5 + Math.random() * 4) + 's';
      f.style.animationDelay = (Math.random() * 3) + 's';
      layer.appendChild(f);
    }
    document.body.appendChild(layer);
    setTimeout(() => layer.remove(), 13000);
  }

  async function load() {
    try {
      const qs = new URLSearchParams(location.search);
      const q = new URLSearchParams();
      if (qs.get('holiday')) q.set('code', qs.get('holiday'));
      else if (qs.get('holiday_on')) q.set('on', qs.get('holiday_on'));
      const res = await fetch('/api/public/holiday-theme' + (q.toString() ? '?' + q : ''));
      if (!res.ok) return;
      const payload = await res.json();
      const themes = ((payload && payload.data && payload.data.themes) || []).filter(t => t && COLOR.test(t.accent || ''));
      if (!themes.length) return;
      applyColours(themes[0]);
      drawBand(themes);
      drift(themes[0]);
    } catch (err) {
      console.warn('holiday theme unavailable:', err);
    }
  }

  window.HolidayTheme = { load };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', load);
  else load();
})();
