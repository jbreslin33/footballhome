// event-weather.js — the forecast on every event (mig 1837).
//
// Owner 2026-11-24: "the weather should show on each practice" · "needs to
// be on all events" · "temp, wind chill, rain or snow etc, lightning
// thunder etc if any are predicted and percent chances of all things. also
// it needs to have us soccer badge and zone the temp etc would be in".
//
// One read of GET /api/weather (the National Weather Service forecast the
// server keeps per facility, each hour with its U.S. Soccer heat / cold
// level), cached ten minutes.  A screen only leaves a placeholder where the
// weather goes —
//     <span data-wx-event="<fh_event_id>"></span>
// — and this fills it, whenever it appears (a MutationObserver), for
// admins, coaches and players alike.  An event with no facility, or past
// the 7-day forecast, stays empty.
//
// chipHtml(hour) is the one look: sky, temperature (feels-like when it
// differs), chance of rain, of thunder, snow, wind — and the U.S. Soccer
// badge in its level's colour.  The Weather page (screens/weather.js) uses
// the same pieces.
const EventWeather = {
  _data: null, _at: 0, _loading: null,

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('weather', tier, tokens) : ''; },
  _esc(t) { const d = document.createElement('div'); d.textContent = t == null ? '' : String(t); return d.innerHTML; },

  load(force) {
    if (!force && this._data && Date.now() - this._at < 10 * 60 * 1000) return Promise.resolve(this._data);
    if (this._loading) return this._loading;
    this._loading = fetch('/api/weather').then((r) => (r.ok ? r.json() : null)).then((d) => {
      if (d && !d.error) {
        this._data = d; this._at = Date.now();
        this._byEvent = new Map((d.events || []).map((e) => [Number(e.fh_event_id), e]));
        this._level = new Map((d.levels || []).map((l) => [l.code, l]));
        // Empty-day placeholders (mig 1840): '<facility>|<local Y-M-D>|<local hour>' → its forecast hour.
        this._slot = new Map((d.day_slots || []).map((s) => [s.dow, s]));
        this._local = new Map();
        for (const f of d.facilities || []) {
          const fmt = new Intl.DateTimeFormat('en-CA', { timeZone: f.timezone || 'America/New_York', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', hour12: false });
          for (const h of f.hours || []) {
            const p = Object.fromEntries(fmt.formatToParts(new Date(h.at)).map((x) => [x.type, x.value]));
            this._local.set(`${f.id}|${p.year}-${p.month}-${p.day}|${Number(p.hour) % 24}`, { ...h, facility_id: f.id });
          }
        }
      }
      return this._data;
    }).catch(() => this._data).finally(() => { this._loading = null; });
    return this._loading;
  },

  level(code) { return (this._level && this._level.get(code)) || null; },

  // The sky in one sign, from the service's words, then the cloud cover.
  sky(h) {
    const w = (h.weather || '').toLowerCase();
    if (w.includes('thunder')) return '⛈';
    if (w.includes('snow') || w.includes('sleet') || w.includes('freezing')) return '🌨';
    if (w.includes('rain') || w.includes('drizzle')) return '🌧';
    if (w.includes('fog')) return '🌫';
    const c = h.sky_pct == null ? 0 : h.sky_pct;
    if (c >= 75) return '☁️';
    // Clear or part-cloudy: a moon after dark (6 PM – 6 AM at the club).
    const hr = h.at ? Number(new Date(h.at).toLocaleString('en-US', { timeZone: 'America/New_York', hour: 'numeric', hour12: false })) % 24 : 12;
    const night = hr >= 18 || hr < 6;
    return c >= 35 ? (night ? '☁️' : '⛅') : (night ? '🌙' : '☀️');
  },
  // 'slight_chance light rain_showers' → 'Slight chance light rain showers'
  words(h) {
    const t = (h.weather || '').replace(/_/g, ' ').trim();
    return t ? t[0].toUpperCase() + t.slice(1) : '';
  },

  // The U.S. Soccer badge for an hour / an event (its whole span's level).
  badgeHtml(h, levelCode) {
    const code = levelCode || h.span_level || h.level;
    const l = this.level(code);
    if (!l) return '';
    const d = this._data || {};
    const cold = h.level_for === 'cold';
    const z = cold ? (d.cold_zones || []).find((x) => x.level === code)
      : (d.heat_zones || []).find((x) => x.level === code && x.category === this._category(h));
    const tip = z ? this._copy(cold ? 'badge_cold' : 'badge_heat', { conditions: z.conditions, action: z.action }) : '';
    return `<span class="wx-badge" style="background:${this._esc(l.color)}; color:${this._esc(l.ink)};" title="${this._esc(tip)}">${this._esc(this._copy('badge', { level: l.label }))}</span>`;
  },
  _category(h) {
    const f = ((this._data && this._data.facilities) || []).find((x) => x.id === h.facility_id);
    return f ? f.heat_category : 2;
  },

  chipHtml(h) {
    const esc = (t) => this._esc(t);
    const n = (v) => Math.round(Number(v));
    const parts = [`${this.sky(h)} <b>${n(h.temp_f)}°</b>`];
    if (h.feels_f != null && Math.abs(n(h.feels_f) - n(h.temp_f)) >= 3) parts.push(esc(this._copy('feels', { t: n(h.feels_f) })));
    const pop = h.max_precip_pct != null ? h.max_precip_pct : h.precip_pct;
    const thunder = h.max_thunder_pct != null ? h.max_thunder_pct : h.thunder_pct;
    const snow = h.snow_in_total != null ? h.snow_in_total : h.snow_in;
    if (pop != null) parts.push(`💧 ${n(pop)}%`);
    if (thunder) parts.push(`⚡ ${n(thunder)}%`);
    if (snow && Number(snow) > 0) parts.push(`❄️ ${Number(snow).toFixed(1)}″`);
    if (h.wind_mph != null) parts.push(`💨 ${n(h.wind_mph)}${h.gust_mph && h.gust_mph - h.wind_mph >= 8 ? `–${n(h.gust_mph)}` : ''} mph`);
    return `<span class="wx-chip" title="${esc(this.words(h))}">${parts.join(' · ')} ${this.badgeHtml(h)}</span>`;
  },

  // Fill every empty placeholder under `root`.
  fill(root) {
    if (!this._byEvent) return;
    (root || document).querySelectorAll('[data-wx-event]:not([data-wx-done])').forEach((el) => {
      el.setAttribute('data-wx-done', '1');
      const h = this._byEvent.get(Number(el.dataset.wxEvent));
      if (h) el.innerHTML = this.chipHtml(h);
    });
    (root || document).querySelectorAll('[data-wx-day]:not([data-wx-done])').forEach((el) => {
      el.setAttribute('data-wx-done', '1');
      const html = this.dayHtml(el.dataset.wxDay);
      if (html) el.innerHTML = html;      // else the screen's own dash stays
    });
  },

  // A day with no event: the forecast at that weekday's standing hour
  // (weather_day_slots — weekdays 7 PM, the men's time).  '' when unknown.
  dayHtml(ymd) {
    if (!this._slot) return '';
    const [y, m, d] = ymd.split('-').map(Number);
    const slot = this._slot.get(new Date(y, m - 1, d).getDay());
    const h = slot && this._local.get(`${slot.facility_id}|${ymd}|${slot.local_hour}`);
    if (!h) return '';
    const time = new Date(2000, 0, 1, slot.local_hour).toLocaleTimeString('en-US', { hour: 'numeric' });
    return `<span class="wx-day"><span class="wx-time">${this._esc(time)}</span>${this.chipHtml(h)}</span>`;
  },

  start() {
    if (this._started) return;
    this._started = true;
    const css = document.createElement('style');
    css.textContent = `
      .wx-chip { display:inline-flex; flex-wrap:wrap; align-items:center; gap:2px 4px; font-size:0.75rem; font-weight:600; line-height:1.4; text-align:left; }
      .wx-chip b { font-weight:800; }
      .wx-badge { display:inline-block; padding:1px 8px; border-radius:999px; font-size:0.68rem; font-weight:800; white-space:nowrap; border:1px solid rgba(255,255,255,0.35); }
      [data-wx-event]:empty { display:none; }
      .wx-day { display:flex; flex-direction:column; align-items:flex-start; gap:2px; }
      [data-wx-day]:has(.wx-day) { opacity:1 !important; color:var(--text-primary, #e5e7eb) !important; text-align:left; padding:4px 2px; }
      .wx-time { font-size:0.7rem; font-weight:800; opacity:0.7; }`;
    document.head.appendChild(css);
    let queued = false;
    const run = () => {
      queued = false;
      if (!document.querySelector('[data-wx-event]:not([data-wx-done]), [data-wx-day]:not([data-wx-done])')) return;
      const copy = window.MessageCopy && window.app && app.auth ? Promise.resolve(MessageCopy.load(app.auth)).catch(() => {}) : Promise.resolve();
      Promise.all([this.load(), copy]).then(() => this.fill(document));
    };
    // Forecast already here → fill in the same frame a screen re-draws (no
    // flash of an empty chip); else fetch it, then fill.
    new MutationObserver(() => {
      if (this._byEvent && Date.now() - this._at < 10 * 60 * 1000) this.fill(document);
      else if (!queued) { queued = true; setTimeout(run, 150); }
    }).observe(document.body, { childList: true, subtree: true });
    run();
  },
};
window.EventWeather = EventWeather;
if (document.body) EventWeather.start(); else document.addEventListener('DOMContentLoaded', () => EventWeather.start());
