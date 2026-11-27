// WeatherScreen — #weather, ⛅ Weather at the top level (mig 1837).
//
// Owner 2026-11-24: "i need a weather page at top level" · "projected
// weather" · "temp, wind chill, rain or snow etc, lightning thunder etc if
// any are predicted and percent chances of all things. also it needs to
// have us soccer badge and zone the temp etc would be in".
//
// Everyone signed in sees it (menu_pages 'weather', audience everyone; a
// player's bar carries it too).  One facility at a time (pills):
//   • our next events there, each with its weather chip
//   • the forecast hour by hour, a day per block: sky, temperature, feels
//     like, chance of rain, chance of thunder, snow, wind, and the U.S.
//     Soccer level that hour falls in
//   • U.S. Soccer's alert levels themselves — heat (WBGT, the facility's
//     regional category) and cold (wind chill) — the lightning rule and a
//     link to their guidance
// Data + look: lib/event-weather.js (GET /api/weather).  All wording is
// message_templates kind 'weather'; zone text is weather_heat_zones /
// weather_cold_zones rows.
class WeatherScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.facilityId = null; this.err = '';
  }

  _copy(tier, tokens = {}) { return EventWeather._copy(tier, tokens); }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `
      <style>
        .wxp { padding:10px 12px 30px; max-width:980px; margin:0 auto; }
        .wxp h2 { margin:0 0 2px; font-size:1.2rem; }
        .wxp h3 { margin:18px 0 6px; font-size:0.95rem; }
        .wxp .src { font-size:0.78rem; opacity:0.7; margin-bottom:10px; }
        .wxp .pills { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:6px; }
        .wxp .pill { padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.9rem; min-height:0; min-width:0;
                     border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .wxp .pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .wxp .ev { display:flex; flex-wrap:wrap; align-items:center; gap:4px 12px; padding:7px 10px; border:1px solid var(--border-color); border-radius:10px; margin-bottom:6px; cursor:pointer; background:var(--bg-secondary); }
        .wxp .ev .when { font-weight:800; font-size:0.85rem; min-width:150px; }
        .wxp .day { border:1px solid var(--border-color); border-radius:12px; margin-bottom:10px; overflow:hidden; }
        .wxp .day > b { display:block; padding:6px 10px; background:var(--bg-secondary); font-size:0.9rem; }
        .wxp .scroll { overflow-x:auto; }
        .wxp table { width:100%; border-collapse:collapse; font-size:0.8rem; white-space:nowrap; }
        .wxp th { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.06em; opacity:0.6; text-align:left; padding:4px 8px; }
        .wxp td { padding:4px 8px; border-top:1px solid rgba(148,163,184,0.18); }
        .wxp tr.has-ev td { background:rgba(37,99,235,0.14); }
        .wxp .zones td { white-space:normal; vertical-align:top; }
        .wxp .note { font-size:0.85rem; margin:10px 0; line-height:1.4; }
        .wxp a { color:#93c5fd; font-weight:700; }
      </style>
      <div class="wxp"><div class="loading" style="padding-top:40px;">Loading…</div></div>`;
    this.element = el;
    el.addEventListener('click', (e) => {
      const p = e.target.closest('[data-wx-facility]');
      if (p) { this.facilityId = Number(p.dataset.wxFacility); this._draw(); return; }
      const ev = e.target.closest('[data-wx-open]');
      if (ev) this.navigation.goTo('event', { id: Number(ev.dataset.wxOpen) });
    });
    return el;
  }

  onEnter() {
    const copy = window.MessageCopy ? Promise.resolve(MessageCopy.load(this.auth)).catch(() => {}) : Promise.resolve();
    Promise.all([EventWeather.load(true), copy]).then(([d]) => {
      this.data = d; this.err = d ? '' : 'x';
      if (this.isMounted !== false) this._draw();
    });
  }

  _when(iso, tz, opts) { return new Date(iso).toLocaleString('en-US', { timeZone: tz || 'America/New_York', ...opts }); }

  _draw() {
    const box = this.find('.wxp');
    if (!box) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const d = this.data;
    const fs = (d && d.facilities) || [];
    if (!fs.length || !fs.some((f) => f.hours.length)) { box.innerHTML = `<h2>${esc(this._copy('title'))}</h2><div class="note">${esc(this._copy('none'))}</div>`; return; }
    // Opens on the facility with the most events in the forecast.
    const busy = (x) => (d.events || []).filter((e) => e.facility_id === x.id).length;
    const f = fs.find((x) => x.id === this.facilityId) || [...fs].sort((a, b) => busy(b) - busy(a))[0];
    this.facilityId = f.id;
    const tz = f.timezone;
    const n = (v) => (v == null ? '' : Math.round(Number(v)));
    const head = (this._copy('hours_head') || '').split('|').map((h) => `<th>${esc(h)}</th>`).join('');
    const events = (d.events || []).filter((e) => e.facility_id === f.id);
    const evHours = new Set(events.map((e) => e.at.slice(0, 13)));

    const evHtml = events.length ? events.map((e) => `
      <div class="ev" data-wx-open="${e.fh_event_id}">
        <span class="when">${esc(this._when(e.at, tz, { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }))}</span>
        <span>${esc(window.EventLabels ? EventLabels.title({ kind: e.kind }) : e.kind)}</span>
        ${EventWeather.chipHtml(e)}
      </div>`).join('') : `<div class="note">${esc(this._copy('events_none'))}</div>`;

    // A day per block, 6 AM – 11 PM local.
    const days = new Map();
    for (const h of f.hours) {
      const hr = Number(this._when(h.at, tz, { hour: 'numeric', hour12: false })) % 24;
      if (hr < 6) continue;
      const key = this._when(h.at, tz, { weekday: 'long', month: 'short', day: 'numeric' });
      (days.get(key) || days.set(key, []).get(key)).push(h);
    }
    const dayHtml = [...days].map(([day, hours]) => `
      <div class="day"><b>${esc(day)}</b><div class="scroll"><table><thead><tr>${head}</tr></thead><tbody>${hours.map((h) => `
        <tr class="${evHours.has(h.at.slice(0, 13)) ? 'has-ev' : ''}" title="${esc(EventWeather.words(h))}">
          <td>${esc(this._when(h.at, tz, { hour: 'numeric' }))}</td>
          <td>${EventWeather.sky(h)} ${esc(EventWeather.words(h))}</td>
          <td><b>${n(h.temp_f)}°</b></td>
          <td>${n(h.wind_chill_f != null ? h.wind_chill_f : h.feels_f)}°</td>
          <td>${h.precip_pct == null ? '' : `${n(h.precip_pct)}%`}${Number(h.rain_in) > 0 ? ` · ${Number(h.rain_in).toFixed(2)}″` : ''}</td>
          <td>${h.thunder_pct == null ? '' : `${n(h.thunder_pct)}%`}</td>
          <td>${Number(h.snow_in) > 0 ? `${Number(h.snow_in).toFixed(1)}″` : ''}</td>
          <td>${n(h.wind_mph)}${h.gust_mph && h.gust_mph - h.wind_mph >= 8 ? `–${n(h.gust_mph)}` : ''} mph</td>
          <td>${EventWeather.badgeHtml({ ...h, facility_id: f.id })}</td>
        </tr>`).join('')}</tbody></table></div></div>`).join('');

    const range = (z, unit) => (z.from == null ? `< ${z.below}${unit}` : z.below == null ? `≥ ${z.from}${unit}` : `${z.from} – ${z.below}${unit}`);
    const zoneRows = (zs) => zs.map((z) => {
      const l = EventWeather.level(z.level) || {};
      return `<tr><td><span class="wx-badge" style="background:${esc(l.color)}; color:${esc(l.ink)};">${esc(l.label)}</span></td><td>${esc(range(z, '°F'))}</td><td>${esc(z.conditions)}</td><td>${esc(z.action)}</td></tr>`;
    }).join('');
    const [gl, gu] = (this._copy('guide_link') || '').split('|');
    const guide = /^https:\/\//.test(gu || '') ? `<a href="${esc(gu)}" target="_blank" rel="noopener">${esc(gl)}</a>` : '';

    box.innerHTML = `
      <h2>${esc(this._copy('title'))}</h2>
      <div class="src">${esc(this._copy('source', { when: f.read_at ? this._when(f.read_at, tz, { weekday: 'short', hour: 'numeric', minute: '2-digit' }) : '—' }))}</div>
      <div class="pills">${fs.map((x) => `<button class="pill ${x.id === f.id ? 'on' : ''}" data-wx-facility="${x.id}">${esc(x.name)}</button>`).join('')}</div>
      <h3>${esc(this._copy('events'))}</h3>${evHtml}
      ${dayHtml}
      <h3>${esc(this._copy('zones'))}</h3>
      <div class="note">${esc(this._copy('lightning'))}</div>
      <div class="day zones"><b>${esc(this._copy('zones_heat', { category: f.heat_category }))}</b><div class="scroll"><table><tbody>${zoneRows((d.heat_zones || []).filter((z) => z.category === f.heat_category))}</tbody></table></div></div>
      <div class="day zones"><b>${esc(this._copy('zones_cold'))}</b><div class="scroll"><table><tbody>${zoneRows(d.cold_zones || [])}</tbody></table></div></div>
      <div class="note">${guide}</div>`;
  }
}
window.WeatherScreen = WeatherScreen;
