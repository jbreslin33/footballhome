const GroupMeScraper = require('./GroupMeScraper');

/**
 * Lighthouse Old Timers Club Liga 2 Chat Scraper
 * Imports matches and members from Old Timers chat
 */
class OldTimersLiga2Scraper extends GroupMeScraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'Old Timers Liga 2',
      chatName: 'Lighthouse Old Timers Club Liga 2',
      groupId: '109786278',
      teamId: 'TBD', // Need actual team ID from CASA Liga 2
      sportDivisionId: null,
      mode: mode,
      includeSchedules: options.includeSchedules !== false
    });
  }

  getDefaultEventName() {
    return 'Match';
  }

  getEventTypeId() {
    return this.eventTypes.match;
  }

  getFilenameSuffix() {
    return 'old-timers-liga2';
  }
}

module.exports = OldTimersLiga2Scraper;
