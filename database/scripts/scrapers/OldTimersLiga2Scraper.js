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
      teamId: 'da5e129e-1d82-4c59-85f9-1f5efd3d6c11', // Lighthouse Old Timers Club
      sportDivisionId: '6362c82a-4383-4d2f-8ecc-8b0e87ab1788', // Lighthouse Old Timers Club Soccer
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
