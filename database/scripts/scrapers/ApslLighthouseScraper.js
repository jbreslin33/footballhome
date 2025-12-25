const GroupMeScraper = require('./GroupMeScraper');

/**
 * APSL Lighthouse Chat Scraper
 * Imports APSL matches and members from APSL Lighthouse chat
 */
class ApslLighthouseScraper extends GroupMeScraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'APSL Lighthouse',
      chatName: 'APSL Lighthouse',
      groupId: '109785985',
      teamId: 'a16e9445-9bed-4fe6-804d-e77c56258610', // Lighthouse 1893 SC APSL team
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
    return 'apsl-lighthouse';
  }
}

module.exports = ApslLighthouseScraper;
