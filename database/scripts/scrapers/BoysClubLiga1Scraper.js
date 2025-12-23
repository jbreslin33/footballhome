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
      teamId: '57d88568-993d-4411-8aa3-6244ca7ff704', // Lighthouse Boys Club
      sportDivisionId: '105ab0d0-6d89-4e8b-8c4b-ce637c610e1c', // Lighthouse Boys Club Soccer
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
