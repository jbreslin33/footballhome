// proposal-body.js — turns a proposal's text into HTML.  One renderer for
// the in-app page (#proposals/<code>, screens/proposals.js) and the
// standalone public page (/proposals/#<code>, proposals/index.html).
//
// Section body: a line starting "- " is a bullet; lines starting "|" are a
// table (first = header, cells split by |); anything else is a paragraph.
// Inside a line, **bold** and [text](https://…) work.
class ProposalBody {
  static esc(text) { const d = document.createElement('div'); d.textContent = text == null ? '' : String(text); return d.innerHTML; }

  static date(iso) {
    const d = new Date(`${iso}T12:00:00`);
    return isNaN(d) ? iso : d.toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' });
  }

  // **bold** and [text](https://…) inside one escaped line.
  static inline(text) {
    return ProposalBody.esc(text)
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
  }

  // Consecutive lines of one kind group into a list or a table.
  static html(text) {
    const out = [];
    let run = null;
    const flush = () => {
      if (!run) return;
      if (run.kind === 'ul') out.push(`<ul>${run.lines.map(l => `<li>${ProposalBody.inline(l.slice(2))}</li>`).join('')}</ul>`);
      else {
        const cells = (l, tag) => l.replace(/^\|/, '').split('|').map(c => `<${tag}>${ProposalBody.inline(c.trim())}</${tag}>`).join('');
        const [head, ...rows] = run.lines;
        out.push(`<div class="prp-scroll"><table class="prp-table"><thead><tr>${cells(head, 'th')}</tr></thead><tbody>${rows.map(r => `<tr>${cells(r, 'td')}</tr>`).join('')}</tbody></table></div>`);
      }
      run = null;
    };
    for (const line of String(text || '').split('\n')) {
      if (!line.trim()) { flush(); continue; }
      const kind = line.startsWith('- ') ? 'ul' : line.startsWith('|') ? 'table' : 'p';
      if (kind === 'p') { flush(); out.push(`<p>${ProposalBody.inline(line)}</p>`); continue; }
      if (!run || run.kind !== kind) { flush(); run = { kind, lines: [] }; }
      run.lines.push(line);
    }
    flush();
    return out.join('');
  }

  // The link anyone can open for a proposal flagged public.
  static publicUrl(code) { return `${location.origin}/proposals/#${encodeURIComponent(code)}`; }
}
window.ProposalBody = ProposalBody;
