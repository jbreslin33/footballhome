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
      sportDivisionId: 'd37eb44b-8e47-0005-9060-f0cbe96fe089', // Lighthouse 1893 SC division
      teamId: null, // No specific team - division-wide training
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
