// TrainingAttendanceScreen - Weekly training attendance grid for lineup decisions
class TrainingAttendanceScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events = [];
    this.players = [];
    this._listenersAttached = false;
  }

  render() {
    this._listenersAttached = false;

    const div = document.createElement('div');
    div.className = 'screen screen-training-attendance';
    div.innerHTML = `
      <div class="screen-header">
        <button id="ta-back-btn" class="btn btn-secondary">← Back</button>
        <h1>📋 Training Attendance</h1>
        <p id="ta-subtitle" class="subtitle">This week's training & pickup</p>
      </div>
      <div style="padding: 8px; overflow-x: auto;">
        <div id="ta-loading"><div class="spinner"></div><p>Loading...</p></div>
        <div id="ta-content" style="display: none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    if (this._listenersAttached) return;
    this._listenersAttached = true;

    this.element.addEventListener('click', (e) => {
      if (e.target.id === 'ta-back-btn' || e.target.closest('#ta-back-btn')) {
        this.navigation.goBack();
        return;
      }

      // Handle attendance cell toggle
      const cell = e.target.closest('.att-cell');
      if (cell) {
        this.toggleAttendance(cell);
        return;
      }
    });

    this.loadData();
  }

  async loadData() {
    const teamId = this.navigation.context.team?.id;
    if (!teamId) {
      this.find('#ta-loading').innerHTML = '<p>No team selected</p>';
      return;
    }

    try {
      const response = await this.auth.fetch(`/api/groupme/training-week/${teamId}`);
      const result = await response.json();
      if (!result.success) {
        this.find('#ta-loading').innerHTML = `<p>Error: ${result.message}</p>`;
        return;
      }

      this.events = result.data.events;
      this.players = result.data.players;
      this.renderTable();

      this.find('#ta-loading').style.display = 'none';
      this.find('#ta-content').style.display = 'block';
    } catch (err) {
      console.error('Training attendance load error:', err);
      this.find('#ta-loading').innerHTML = '<p>Failed to load data</p>';
    }
  }

  renderTable() {
    // Sort: players with attendance first (by count desc), then alphabetically
    const sorted = [...this.players].sort((a, b) => {
      const aCount = this.attendanceCount(a);
      const bCount = this.attendanceCount(b);
      if (aCount !== bCount) return bCount - aCount;
      const aName = this.playerName(a);
      const bName = this.playerName(b);
      return aName.localeCompare(bName);
    });

    // Build day columns from events - group by date
    const dayMap = new Map();
    for (const evt of this.events) {
      const dayKey = evt.eventDate;
      if (!dayMap.has(dayKey)) {
        dayMap.set(dayKey, []);
      }
      dayMap.get(dayKey).push(evt);
    }

    // Day labels
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    let headerCells = '<th class="ta-name-col">Player</th><th class="ta-teams-col">Rosters</th>';
    const dayEntries = [...dayMap.entries()];
    for (const [dateStr, evts] of dayEntries) {
      const d = new Date(dateStr + 'T12:00:00');
      const dayLabel = dayNames[d.getDay()];
      const shortDate = `${d.getMonth() + 1}/${d.getDate()}`;
      // Show short title if multiple events on same day
      if (evts.length === 1) {
        headerCells += `<th class="ta-day-col" title="${evts[0].title}">${dayLabel}<br>${shortDate}</th>`;
      } else {
        for (const evt of evts) {
          const shortTitle = evt.title.length > 10 ? evt.title.substring(0, 10) + '…' : evt.title;
          headerCells += `<th class="ta-day-col" title="${evt.title}">${dayLabel}<br>${shortTitle}</th>`;
        }
      }
    }
    headerCells += '<th class="ta-tally-col">Total</th>';

    let rows = '';
    for (const player of sorted) {
      const name = this.playerName(player);
      const teams = (player.teams || []).map(t => this.teamBadge(t)).join(' ');
      const sourceClass = player.source === 'roster_only' ? ' ta-roster-only' : '';

      let cells = '';
      for (const [dateStr, evts] of dayEntries) {
        if (evts.length === 1) {
          cells += this.renderAttCell(player, evts[0]);
        } else {
          for (const evt of evts) {
            cells += this.renderAttCell(player, evt);
          }
        }
      }

      const count = this.attendanceCount(player);
      const tallyClass = count >= 4 ? 'ta-tally-high' : count >= 2 ? 'ta-tally-mid' : count > 0 ? 'ta-tally-low' : '';

      rows += `<tr class="${sourceClass}">
        <td class="ta-name-col">${this.escapeHtml(name)}</td>
        <td class="ta-teams-col">${teams}</td>
        ${cells}
        <td class="ta-tally-col ${tallyClass}">${count}</td>
      </tr>`;
    }

    this.find('#ta-content').innerHTML = `
      <table class="ta-table">
        <thead><tr>${headerCells}</tr></thead>
        <tbody>${rows}</tbody>
      </table>
    `;
  }

  renderAttCell(player, event) {
    const att = player.attendance?.[event.id];
    if (!att) {
      // No data — clickable to add manual attendance
      if (!player.personId) return '<td class="ta-day-col att-cell att-none" title="Not linked">—</td>';
      return `<td class="ta-day-col att-cell att-none" 
                  data-person-id="${player.personId}" 
                  data-event-id="${event.id}" 
                  data-attended="false"
                  title="Click to mark attended"></td>`;
    }

    const isRsvp = att.source === 'rsvp';
    const classes = att.attended ? (isRsvp ? 'att-rsvp' : 'att-yes') : 'att-no';
    const symbol = att.attended ? '✓' : '✗';
    const title = att.attended
      ? (isRsvp ? 'RSVP Yes' : 'Manual: attended')
      : 'Manual: not attended';

    if (!player.personId) {
      return `<td class="ta-day-col att-cell ${classes}" title="${title}">${symbol}</td>`;
    }

    return `<td class="ta-day-col att-cell ${classes}" 
                data-person-id="${player.personId}"
                data-event-id="${event.id}" 
                data-attended="${att.attended}"
                title="${title} — Click to toggle">${symbol}</td>`;
  }

  async toggleAttendance(cell) {
    const personId = cell.dataset.personId;
    const eventId = cell.dataset.eventId;
    if (!personId || !eventId) return;

    const wasAttended = cell.dataset.attended === 'true';
    const newAttended = !wasAttended;

    // Optimistic update
    cell.dataset.attended = String(newAttended);
    cell.textContent = newAttended ? '✓' : '✗';
    cell.className = `ta-day-col att-cell ${newAttended ? 'att-yes' : 'att-no'}`;
    cell.title = newAttended ? 'Manual: attended — Click to toggle' : 'Manual: not attended — Click to toggle';

    // Update tally
    this.updateTally(cell.closest('tr'));

    try {
      const response = await this.auth.fetch('/api/groupme/training-attendance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          personId: parseInt(personId),
          chatEventId: parseInt(eventId),
          attended: newAttended
        })
      });
      const result = await response.json();
      if (!result.success) {
        console.error('Toggle failed:', result.message);
        // Revert
        cell.dataset.attended = String(wasAttended);
        cell.textContent = wasAttended ? '✓' : '';
        cell.className = `ta-day-col att-cell ${wasAttended ? 'att-yes' : 'att-none'}`;
      }
    } catch (err) {
      console.error('Toggle error:', err);
    }
  }

  updateTally(row) {
    if (!row) return;
    const cells = row.querySelectorAll('.att-cell');
    let count = 0;
    cells.forEach(c => { if (c.dataset.attended === 'true') count++; });
    const tallyCell = row.querySelector('.ta-tally-col');
    if (tallyCell) {
      tallyCell.textContent = count;
      tallyCell.className = 'ta-tally-col ' + (count >= 4 ? 'ta-tally-high' : count >= 2 ? 'ta-tally-mid' : count > 0 ? 'ta-tally-low' : '');
    }
  }

  attendanceCount(player) {
    let count = 0;
    for (const v of Object.values(player.attendance || {})) {
      if (v && v.attended) count++;
    }
    return count;
  }

  playerName(player) {
    if (player.firstName && player.lastName) {
      return `${player.firstName} ${player.lastName}`;
    }
    if (player.nickname) return player.nickname;
    return player.externalUserId || '?';
  }

  teamBadge(team) {
    const labels = {
      'Lighthouse 1893 SC': 'APSL',
      'Lighthouse Boys Club': 'L1',
      'Lighthouse Boys Club U23': 'L2'
    };
    const label = labels[team.teamName] || team.teamName;
    return `<span class="ta-badge">${this.escapeHtml(label)}</span>`;
  }

  escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }
}
