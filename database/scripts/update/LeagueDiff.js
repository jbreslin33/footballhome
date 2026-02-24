/**
 * LeagueDiff
 * 
 * Compares two LeagueSnapshot objects and produces a changeset:
 * - added: items in new but not in old
 * - removed: items in old but not in new
 * - updated: items in both but with changed values
 * 
 * Each entity type uses its _key field for identity matching.
 * Fields prefixed with _ are metadata and excluded from value comparison.
 */
class LeagueDiff {
  constructor(oldSnapshot, newSnapshot) {
    this.oldSnapshot = oldSnapshot;
    this.newSnapshot = newSnapshot;
    this.league = newSnapshot.league;
    this.timestamp = new Date().toISOString();
  }

  /**
   * Compute the full diff across all entity types
   * @returns {DiffResult}
   */
  compute() {
    return {
      league: this.league,
      timestamp: this.timestamp,
      oldScrapedAt: this.oldSnapshot.scrapedAt,
      newScrapedAt: this.newSnapshot.scrapedAt,
      teams: this._diffEntities(this.oldSnapshot.teams, this.newSnapshot.teams),
      matches: this._diffEntities(this.oldSnapshot.matches, this.newSnapshot.matches),
      standings: this._diffEntities(this.oldSnapshot.standings, this.newSnapshot.standings),
      players: this._diffEntities(this.oldSnapshot.players, this.newSnapshot.players)
    };
  }

  /**
   * Diff two arrays of entities using their _key field
   * @param {Object[]} oldItems
   * @param {Object[]} newItems
   * @returns {{ added: Object[], removed: Object[], updated: Object[] }}
   */
  _diffEntities(oldItems, newItems) {
    const oldMap = new Map();
    const newMap = new Map();

    for (const item of oldItems) {
      oldMap.set(item._key, item);
    }
    for (const item of newItems) {
      newMap.set(item._key, item);
    }

    const added = [];
    const removed = [];
    const updated = [];

    // Find added and updated
    for (const [key, newItem] of newMap) {
      const oldItem = oldMap.get(key);
      if (!oldItem) {
        added.push(newItem);
      } else {
        // Compare non-metadata fields
        const changes = this._getChanges(oldItem, newItem);
        if (changes.length > 0) {
          updated.push({
            _key: key,
            old: oldItem,
            new: newItem,
            changes
          });
        }
      }
    }

    // Find removed
    for (const [key, oldItem] of oldMap) {
      if (!newMap.has(key)) {
        removed.push(oldItem);
      }
    }

    return { added, removed, updated };
  }

  /**
   * Get list of changed fields between two items
   * Ignores fields starting with _
   * @returns {Array<{field: string, from: any, to: any}>}
   */
  _getChanges(oldItem, newItem) {
    const changes = [];
    const allKeys = new Set([...Object.keys(oldItem), ...Object.keys(newItem)]);

    for (const key of allKeys) {
      if (key.startsWith('_')) continue; // Skip metadata
      const oldVal = oldItem[key];
      const newVal = newItem[key];
      if (oldVal !== newVal && JSON.stringify(oldVal) !== JSON.stringify(newVal)) {
        changes.push({ field: key, from: oldVal, to: newVal });
      }
    }

    return changes;
  }

  /**
   * Print a human-readable summary of the diff
   * @param {DiffResult} diff
   */
  static summarize(diff) {
    const lines = [];
    lines.push(`\n📊 League Update Diff: ${diff.league.toUpperCase()}`);
    lines.push(`   Old: ${diff.oldScrapedAt}`);
    lines.push(`   New: ${diff.newScrapedAt}`);
    lines.push('');

    for (const entityType of ['teams', 'matches', 'standings', 'players']) {
      const d = diff[entityType];
      if (d.added.length === 0 && d.removed.length === 0 && d.updated.length === 0) {
        lines.push(`   ${entityType}: no changes`);
        continue;
      }
      lines.push(`   ${entityType}:`);
      if (d.added.length > 0) {
        lines.push(`     + ${d.added.length} added`);
        for (const item of d.added) {
          lines.push(`       + ${item._key}`);
        }
      }
      if (d.removed.length > 0) {
        lines.push(`     - ${d.removed.length} removed`);
        for (const item of d.removed) {
          lines.push(`       - ${item._key}`);
        }
      }
      if (d.updated.length > 0) {
        lines.push(`     ~ ${d.updated.length} updated`);
        for (const item of d.updated) {
          const changeDesc = item.changes.map(c => `${c.field}: ${c.from} → ${c.to}`).join(', ');
          lines.push(`       ~ ${item._key}: ${changeDesc}`);
        }
      }
    }

    return lines.join('\n');
  }

  /**
   * Check if a diff has any changes at all
   * @param {DiffResult} diff
   * @returns {boolean}
   */
  static isEmpty(diff) {
    for (const entityType of ['teams', 'matches', 'standings', 'players']) {
      const d = diff[entityType];
      if (d.added.length > 0 || d.removed.length > 0 || d.updated.length > 0) {
        return false;
      }
    }
    return true;
  }
}

module.exports = LeagueDiff;
