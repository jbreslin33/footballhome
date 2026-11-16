// EventPosts — 📷 Instagram post / 🖨️ flyer started from one event (admin).
//
// Was the pop-up a tap opened on the old #calendar screen (calendar.js,
// deleted 2026-11-16: a tap on the one 📅 Calendar opens the event, so the
// post / flyer doors moved onto the event itself — EventScreen's 👀 bar,
// every kind, Game Center too).  A game's announcement and result posts are
// Game Center's own pills; here a game gets the flyer only.
//
// Public-safe: never the raw Google title (admin-only text) — kind,
// category, teams, opponent, date, time and place only.
const EventPosts = {
  _title(s) { return String(s || '').split(/\s+/).filter(Boolean).map(p => p[0].toUpperCase() + p.slice(1)).join(' '); },

  summary(ev) {
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const kind = ev.kind || 'other';
    let scope = ev.category || [...new Set(teams.map(t => t.gender_category).filter(Boolean))].join(' + ') || 'Club';
    scope = EventPosts._title(String(scope).replaceAll('_', ' '));
    const opponent = ev.opponent || (window.EventLabels && EventLabels.parseDescTags ? EventLabels.parseDescTags(ev.description).opponent : '') || '';
    const start = new Date(ev.starts_at);
    const dateStr = start.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
    const timeStr = ev.all_day ? '' : start.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    // One squad → its name; several on one game → the club-wide name.
    const teamName = teams.length === 1 ? teams[0].name : (teams.length ? 'Lighthouse' : '');
    const withLogo = teams.find(t => t.logo_url);
    let title, subtitle;
    if (kind === 'match') {
      title = ev.is_home === false ? 'AWAY MATCH' : 'GAME DAY';
      subtitle = opponent ? `vs ${opponent}` : teamName;
    } else {
      title = EventPosts._title(kind).toUpperCase();
      subtitle = teamName;
    }
    return {
      kind, title, subtitle, badge: teamName || scope, dateStr, timeStr,
      location: ev.location || '', teamName, teamLogo: withLogo ? (withLogo.logo_url || '') : '',
      opponent, opponentLogo: ev.opponent_logo_url || '',
    };
  },

  // 📷 → #content-posts with the caption (and a match graphic) filled in.
  post(navigation, ev) {
    const s = EventPosts.summary(ev);
    const lines = [`⚽ ${s.title}!`, ''];
    if (s.subtitle) lines.push(s.subtitle);
    lines.push(`📅 ${s.dateStr}`);
    if (s.timeStr) lines.push(`⏰ ${s.timeStr}`);
    if (s.location) lines.push(`📍 ${s.location}`);
    lines.push('', '#Lighthouse1893 #PhillySoccer');
    navigation.context.contentPrefill = {
      title: `${s.title}${s.subtitle ? ' - ' + s.subtitle : ''}`,
      caption: lines.join('\n'),
      matchGraphic: s.kind === 'match' ? {
        eyebrow: s.title, ourName: s.teamName || 'Lighthouse', ourLogo: s.teamLogo,
        opponent: s.opponent || 'Opponent', opponentLogo: s.opponentLogo,
        dateStr: s.dateStr, timeStr: s.timeStr, location: s.location,
      } : null,
    };
    navigation.goTo('content-posts', {});
  },

  // 🖨️ → #flyers filled in.
  flyer(navigation, ev) {
    const s = EventPosts.summary(ev);
    const pills = [{ icon: '📅', label: 'Date', value: s.dateStr }];
    if (s.timeStr) pills.push({ icon: '🕒', label: 'Time', value: s.timeStr });
    if (s.location) pills.push({ icon: '📍', label: 'Location', value: s.location });
    navigation.context.flyerPrefill = {
      badge: s.badge,
      eyebrow: s.kind === 'match' ? (s.title === 'AWAY MATCH' ? 'Away Match' : 'Game Day') : EventPosts._title(s.kind),
      title: s.title, subtitle: s.subtitle, pills,
    };
    navigation.goTo('flyers', {});
  },
};

window.EventPosts = EventPosts;
