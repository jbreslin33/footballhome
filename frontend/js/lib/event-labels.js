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

  // A game on the field we prep (mig 780: facilities.field_prep) →
  // "HOME-7v7" / "HOME-11v11", said in place of the address; '' anywhere
  // else, home or away.
  static homeSetup(ev) {
    if (!ev || !ev.home_setup) return '';
    return (window.MessageCopy && MessageCopy.block('event_center', 'home_setup', { setup: ev.home_setup }))
      || `HOME-${ev.home_setup}`;
  }

  // The banner: green, bold, impossible to miss.
  static homeSetupBadge(ev, esc) {
    const t = EventLabels.homeSetup(ev);
    return t ? `<span style="display:inline-block; background:#16a34a; color:#fff; border-radius:6px; padding:2px 8px; font-weight:900; letter-spacing:0.03em;">🏟 ${esc(t)}</span>` : '';
  }

  // Which Event Center kind an event is: match / practice / pickup, else
  // 'other' (a meeting, a camp…).
  static kindOf(ev) { return ['match', 'practice', 'pickup'].includes(ev.kind) ? ev.kind : 'other'; }

  // Over: its end (or start, when the calendar gives no end) has passed.
  static isPast(ev) {
    const end = new Date(ev.ends_at || ev.starts_at);
    return !isNaN(end.getTime()) && end.getTime() < Date.now();
  }

  // "Tue, Oct 27 · 7:00 PM"
  static when(ev) {
    return [EventLabels.dateStr(ev.starts_at), EventLabels.timeStr(ev.starts_at)].filter(Boolean).join(' · ');
  }

  // Arrival · Warmup · Kickoff for EVERY event (owner 2026-11-05: "we
  // need arrival time, warmup time and kickoff time on my and event center
  // for all events! if its practice just time of event as arrival is
  // fine").  Games (match / intrasquad): the event's times — the gcal tag,
  // else the league's default offsets (mig 395) — and kickoff falls back
  // to the start.  Anything else: Arrival = its start.  Words: kind
  // event_times (mig 1091).  [[label, time], …]
  static times(ev) {
    if (!ev) return [];
    const tags = EventLabels.parseDescTags(ev.description);
    const start = EventLabels.timeStr(ev.starts_at);
    const kind = String(ev.kind || '').toLowerCase();
    const w = (tier, fb, time) => (window.MessageCopy && MessageCopy.block && MessageCopy.block('event_times', tier, { time })) || `${fb} ${time}`;
    if (kind === 'match' || kind === 'intrasquad') {
      const arrival = ev.arrival_label || tags.arrival || '';
      const warmup  = ev.warmup_label  || tags.warmup  || '';
      const kickoff = ev.kickoff_label || tags.kickoff || start;
      return [['arrival', 'Arrival', arrival], ['warmup', 'Warmup', warmup], ['kickoff', 'Kickoff', kickoff]]
        .filter(([, , t]) => t).map(([tier, fb, t]) => w(tier, fb, t));
    }
    const arrival = ev.arrival_label || tags.arrival || start;
    return arrival ? [w('arrival', 'Arrival', arrival)] : [];
  }

  static timesLine(ev) { return EventLabels.times(ev).join(' · '); }

  static dateStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  static mapsUrl(location) {
    return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(location)}`;
  }

  static timeStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
  }
}

window.EventLabels = EventLabels;
