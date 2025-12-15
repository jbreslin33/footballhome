const GroupMeScraper = require('./GroupMeScraper');

/**
 * Lighthouse Boys Club Liga 1 Chat Scraper
 * Imports matches and members from Boys Club chat
 */
class BoysClubLiga1Scraper extends GroupMeScraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'Boys Club Liga 1',
      chatName: 'Lighthouse Boys Club Liga 1',
      groupId: '109786182',
      teamId: 'TBD', // Need actual team ID from CASA Liga 1
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
    return 'boys-club-liga1';
  }
}

module.exports = BoysClubLiga1Scraper;
