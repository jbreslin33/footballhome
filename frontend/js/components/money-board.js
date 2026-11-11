// MoneyBoard — the parts #payments (Tuition) and #fines share, so the two
// pages look and work the same (owner 2026-11-11: "i want consistency on
// the tuition and fines page" / "act JUST like tuition … same format").
//
//   MoneyBoard.SECTION_PILLS              the one section pill row (FilterBar chips)
//   MoneyBoard.sectionPills(screen, host, selected, onSelect)
//                                         draws it (screen._moneyPills keeps the FilterBar)
//   MoneyBoard.STATS_STYLE                the stats box's own style (its host div)
//   MoneyBoard.statsHtml({ title, loading, progress, rows: [{ title, cells: [{ label, value, color, title }] }] })
//                                         progress = { done, total, what }: the universal LoadProgress
//                                         line (mig 1246) + numbers dimmed until the last part is in
//   MoneyBoard.viewTabsHtml(views, active, cls)   [{ id, label }] → buttons (cls + data-view)
//   MoneyBoard.paintViewTabs(root, cls, active)   recolour after a switch
//   MoneyBoard.sectionBar(meta, count)    full-width status bar { icon, label, fg, bg, border }
//   MoneyBoard.section(meta, count, cardsHtml, note)   bar + card grid
//   MoneyBoard.cardOpen(key) / cardClose  the player card's frame
//
// Labels are display copy: Boys shows Boys + Girls (club rule,
// Screen.sectionIncludes), so its pill says so; Girls is girls only.
(function () {
  const esc = (s) => String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  const SECTION_PILLS = [
    { id: 'all',    label: '💰 All'          },
    { id: 'mens',   label: '👨 Mens'         },
    { id: 'womens', label: '👩 Womens'       },
    { id: 'boys',   label: '👦 Boys + Girls' },
    { id: 'girls',  label: '👧 Girls'        },
  ];

  function sectionPills(screen, host, selected, onSelect) {
    if (!host || !window.FilterBar) return;
    // FilterBar keeps its host node; a re-entered screen has a new one.
    if (!screen._moneyPills || screen._moneyPillsHost !== host) {
      screen._moneyPills = new FilterBar({ host });
      screen._moneyPillsHost = host;
    }
    screen._moneyPills.setRows([{
      name: 'category',
      chips: SECTION_PILLS,
      selected: selected || 'all',
      onSelect: (id) => onSelect((id == null || id === 'all') ? 'all' : id),
    }]);
  }

  const STATS_STYLE = `padding: var(--space-3); background: var(--bg-tertiary, #1f2937);
    border: 1px solid var(--border-color, #374151); border-radius: 6px; margin-bottom: var(--space-3); font-size: 0.85rem;`;

  function statsHtml({ title, loading, progress, rows }) {
    const stat = (c) =>
      `<div${c.title ? ` title="${esc(c.title)}"` : ''} style="min-width:110px;">
         <div style="opacity:0.65; font-size:0.72rem; text-transform:uppercase; letter-spacing:0.03em;">${c.label}</div>
         <div style="font-weight:800; font-size:1.05rem;${c.color ? ` color:${c.color};` : ''}">${c.value}</div>
       </div>`;
    // ⏳ LoadProgress (mig 1246): partial sums never read as the answer.
    const partial = !!(progress && (window.LoadProgress ? LoadProgress.loading(progress.done, progress.total) : progress.done < progress.total));
    const row = (r) => `
      <div style="margin-top:var(--space-3);">
        <div style="opacity:0.55; font-size:0.72rem; font-weight:700; margin-bottom:4px;">${esc(r.title)}</div>
        <div style="display:flex; gap:var(--space-4); flex-wrap:wrap;">${(r.cells || []).map(stat).join('')}</div>
      </div>`;
    return `
      <div style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center;">
        <span style="font-weight:800; margin-right:4px;">${esc(title)}</span>${loading ? `<span style="opacity:0.6; font-size:0.75rem;">${esc(loading)}</span>` : ''}
      </div>
      ${progress && window.LoadProgress ? LoadProgress.html(progress) : ''}
      <div style="${partial ? 'opacity:0.4;' : ''} transition:opacity 0.3s;">${(rows || []).map(row).join('')}</div>`;
  }

  const tabStyle = (on) => `padding:6px 14px; border-radius:6px; cursor:pointer; font-weight:700; font-size:0.85rem;
    background:${on ? '#0ea5e9' : 'transparent'}; color:${on ? '#fff' : 'var(--fg, #e5e7eb)'};
    border:${on ? '1px solid #0ea5e9' : '1px solid var(--border-color, #374151)'};`;

  function viewTabsHtml(views, active, cls) {
    return views.map(v => `<button type="button" id="view-${esc(v.id)}" class="${esc(cls)}" data-view="${esc(v.id)}"
      style="${tabStyle(v.id === active)}">${esc(v.label)}</button>`).join('');
  }

  function paintViewTabs(root, cls, active) {
    if (!root) return;
    root.querySelectorAll(`.${cls}`).forEach(b => { b.style.cssText = tabStyle(b.dataset.view === active); });
  }

  function sectionBar(meta, count) {
    return `
      <div style="display:flex; align-items:center; justify-content:space-between; gap:var(--space-3);
                  background:${meta.bg}; color:${meta.fg}; border-left:6px solid ${meta.border};
                  border-radius: var(--radius-md, 8px); padding: var(--space-3) var(--space-4);
                  margin: var(--space-4) 0 var(--space-3); box-shadow: 0 1px 2px rgba(0,0,0,0.04);">
        <div style="display:flex; align-items:center; gap:var(--space-2); font-weight:800; font-size:1.05rem; letter-spacing:0.06em;">
          <span style="font-size:1.25rem; line-height:1;">${meta.icon}</span>
          <span>${meta.label}</span>
        </div>
        <span style="background:${meta.border}; color:#fff; padding: 2px 10px; border-radius: 999px; font-weight:700; font-size:0.85rem;">${count}</span>
      </div>`;
  }

  function section(meta, count, cardsHtml, note) {
    return `
      <section style="margin-bottom: var(--space-5);">
        ${sectionBar(meta, count)}
        ${note ? `<div style="font-size:0.8rem; opacity:0.75; margin:-6px 0 8px;">${esc(note)}</div>` : ''}
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: var(--space-3);">
          ${cardsHtml}
        </div>
      </section>`;
  }

  function cardOpen(key, extraAttrs) {
    return `<div class="pay-member-card" data-player-key="${esc(key)}" ${extraAttrs || ''}
      style="background: var(--bg-secondary, #111827); border:1px solid var(--border-color, #374151);
             border-radius:8px; padding:12px 14px; display:flex; flex-direction:column; gap:8px; cursor:pointer;">`;
  }
  const cardClose = '</div>';

  window.MoneyBoard = { SECTION_PILLS, sectionPills, STATS_STYLE, statsHtml, viewTabsHtml, paintViewTabs,
                        sectionBar, section, cardOpen, cardClose };
})();
