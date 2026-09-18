// EventLabels — how a calendar event is named on screen, shared by #my and
// #event-center so the two can never disagree.
//
// The title is built from the event's classification (kind + category) and
// the Club:/Kind:/Opponent: tags in its description — never the raw gcal
// title, which is the admins' own shorthand.
class EventLabels {
  // Description DSL tags (the same ones migration 271 stores as
  // fh_events.arrival_at / warmup_at / kickoff_at), parsed straight off the
  // raw description since the feed already carries it.
  static parseDescTags(description) {
    const tags = {};
    if (!description) return tags;
    for (const line of description.split(/\r?\n/)) {
      const m = line.match(/^\s*(Club|Team|Kind|Type|Opponent|Arrival|Warmup|Kickoff|Notes)\s*:\s*(.+?)\s*$/i);
      if (m) tags[m[1].toLowerCase()] = m[2];
    }
    return tags;
  }

  static title(ev) {
    const kind = ev.kind || '';
    const category = ev.category || '';
    const tags = EventLabels.parseDescTags(ev.description);

    const kindLabels = { pickup: 'Pickup', practice: 'Practice', match: 'Game',
                         meeting: 'Meeting', camp: 'Camp', 'barn night': 'Barn Night',
                         intrasquad: 'Intra Squad' };
    const catLabels  = { mens: 'Mens', womens: 'Womens', boys: 'Boys', girls: 'Girls', staff: 'Staff' };
    // Prefer the raw tag value straight off the calendar description
    // (handles multi-club tags like "Boys, Girls" and the real Kind:
    // value like "Match" instead of our friendlier "Game" synonym);
    // fall back to the backend's classified kind/category if untagged.
    const kindLabel  = tags.kind || tags.type || kindLabels[kind] || (kind ? kind[0].toUpperCase() + kind.slice(1) : '');
    const catLabel   = tags.club || catLabels[category] || category || '';
    const opponent   = ev.opponent || tags.opponent || '';

    const base = (kindLabel && catLabel) ? `${catLabel} ${kindLabel}` : (kindLabel || catLabel);
    if (kind === 'match' && opponent) {
      return base ? `${base} vs ${opponent}` : `vs ${opponent}`;
    }
    if (base) return base;

    // Fall back to the tagged team names if classification is missing.
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const teamNames = teams
      .map(t => (t && (t.name || t.display_name)) || '')
      .filter(Boolean);
    if (teamNames.length) return teamNames.join(' · ');

    return 'Event';
  }

  static dateStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  static timeStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
  }
}

window.EventLabels = EventLabels;
