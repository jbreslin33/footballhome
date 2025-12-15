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
      teamId: 'd37eb44b-8e47-0005-9060-f0cbe96fe089', // Lighthouse 1893 SC APSL team
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
