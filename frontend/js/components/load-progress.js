// LoadProgress — the one "still loading" line every screen shows while its
// data lands in parts (owner 2026-11-11: "#payments total looks low on load
// and goes up … this should be a universal rule on all loading pages for
// all things").  A screen that fills totals from several fetches must say
// so until the last one is in: a bar, the percent, "N of M <parts> in",
// and its numbers dimmed (LoadProgress.dim) so a partial sum never reads
// as the answer.
//
//   LoadProgress.html({ done: 2, total: 4, what: 'programs' })
//     → '' once done >= total, else the bar
//   LoadProgress.dim(loading) → inline style for numbers while partial
//
// Wording: message_templates kind=load_progress (mig 1246); the noun is
// the caller's (its own DB row where the screen has one).
class LoadProgress {
  static pct(done, total) {
    if (!total) return 100;
    return Math.max(0, Math.min(100, Math.round((done / total) * 100)));
  }

  static loading(done, total) { return !!total && done < total; }

  static html({ done = 0, total = 0, what = '' } = {}) {
    if (!LoadProgress.loading(done, total)) return '';
    const pct = LoadProgress.pct(done, total);
    const tokens = { pct: String(pct), done: String(done), total: String(total), what };
    const text = (window.MessageCopy && MessageCopy.has('load_progress', 'line'))
      ? MessageCopy.block('load_progress', 'line', tokens)
      : `⏳ Loading ${pct}% — ${done} of ${total} ${what} in · totals still adding up`;
    const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
    return `<div class="load-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${pct}"
                 style="margin:6px 0; font-size:0.78rem; font-weight:700; color:#fbbf24;">
        <div>${esc(text)}</div>
        <div style="height:6px; margin-top:4px; border-radius:999px; background:rgba(251,191,36,0.18); overflow:hidden;">
          <div style="height:100%; width:${Math.max(pct, 4)}%; background:#fbbf24; border-radius:999px; transition:width 0.3s;"></div>
        </div>
      </div>`;
  }

  static dim(loading) { return loading ? 'opacity:0.4;' : ''; }
}

window.LoadProgress = LoadProgress;
