const GroupMeScraper = require('./GroupMeScraper');

/**
 * Training Lighthouse Chat Scraper
 * Imports training events and members from Training Lighthouse chat
 */
class TrainingLighthouseScraper extends GroupMeScraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'Training Lighthouse',
      chatName: 'Training Lighthouse',
      groupId: '108640377',
      sportDivisionId: '46b8ef6e-b9f3-41b9-8c7c-525dd63d14f9', // Lighthouse 1893 SC Soccer
      teamId: '3ee933c4-3ecc-4478-8737-b5a148fcebc7', // Lighthouse Training Team
      mode: mode,
      includeSchedules: options.includeSchedules !== false
    });
  }

  getDefaultEventName() {
    return 'Training';
  }

  getEventTypeId() {
    return this.eventTypes.training;
  }

  getFilenameSuffix() {
    return 'training-lighthouse';
  }
}

module.exports = TrainingLighthouseScraper;
