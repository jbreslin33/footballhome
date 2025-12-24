const Scraper = require('../base/Scraper');
const ApiClient = require('../fetchers/ApiClient');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const Player = require('../models/Player');
const Match = require('../models/Match');
const Practice = require('../models/Practice');

/**
 * Base GroupMe Scraper
 * Handles GroupMe API integration for chat imports (users, schedule, RSVPs)
 */
class GroupMeScraper extends Scraper {
  constructor(config) {
    super({
      name: config.name || 'GroupMe',
      mode: config.mode || 'full',
      includeSchedules: config.includeSchedules !== false, // Default true for GroupMe
      teamFilter: config.teamFilter || null
    });
    
    this.groupId = config.groupId;
    this.chatName = config.chatName;
    this.teamId = config.teamId; // Associated team ID
    this.sportDivisionId = config.sportDivisionId; // Or sport division ID
    
    // GroupMe API client
    const accessToken = process.env.GROUPME_ACCESS_TOKEN;
    if (!accessToken) {
      throw new Error('GROUPME_ACCESS_TOKEN environment variable not set');
    }
    
    this.apiClient = new ApiClient({
      baseUrl: 'https://api.groupme.com/v3',
      authType: 'query',
      apiKey: accessToken,
      apiKeyName: 'token',
      insecure: true // Bypass SSL verification for dev environment
    });
    
    this.sqlGenerator = new SqlGenerator();
    
    // Event types
    this.eventTypes = {
      training: '550e8400-e29b-41d4-a716-446655440401',
      match: '550e8400-e29b-41d4-a716-446655440402'
    };
    
    // RSVP status IDs
    this.rsvpStatuses = {
      yes: '550e8400-e29b-41d4-a716-446655440301',
      maybe: '550e8400-e29b-41d4-a716-446655440302',
      no: '550e8400-e29b-41d4-a716-446655440303'
    };
  }

  async initialize() {
    this.log(`Initializing ${this.chatName} scraper...`);
    this.log(`Group ID: ${this.groupId}`);
  }

  async fetchData() {
    // Fetch users (members)
    await this.fetchUsers();
    
    // Fetch schedule (events)
    if (this.shouldScrapeSchedules()) {
      await this.fetchSchedule();
      
      // Fetch RSVPs for events
      await this.fetchRsvps();
    }
  }

  async fetchUsers() {
    this.log('\n👥 Fetching chat members...');
    
    try {
      const apiResponse = await this.apiClient.fetch(`/groups/${this.groupId}`);
      const group = apiResponse.response || apiResponse;
      const members = group.members || [];
      
      this.log(`   Found ${members.length} members`);
      
      for (const member of members) {
        const groupmeId = member.user_id;
        const name = member.nickname || member.name || 'Unknown';
        const { first, last } = this.splitName(name);
        
        // Create external identity record
        const identityId = IdGenerator.fromComponents('groupme', 'identity', groupmeId);
        this.data.externalIdentities.set(identityId, {
          id: identityId,
          provider_id: '550e8400-e29b-41d4-a716-446655440a03', // GroupMe Provider ID
          external_id: groupmeId,
          external_username: name,
          first_name: first,
          last_name: last,
          team_id: this.teamId || null,
          sport_division_id: this.sportDivisionId || null
        });
      }
      
    } catch (error) {
      this.logError('Failed to fetch chat members', error);
    }
  }

  async fetchSchedule() {
    this.log('\n📅 Fetching calendar events...');
    
    try {
      const apiResponse = await this.apiClient.fetch(`/conversations/${this.groupId}/events/list`);
      const response = apiResponse.response || apiResponse;
      const events = response.events || [];
      
      if (events.length === 0) {
        this.log('   No events found');
        return;
      }
      
      this.log(`   Found ${events.length} events`);
      
      for (const evt of events) {
        const groupmeEventId = evt.id || evt.event_id;
        const name = evt.name || this.getDefaultEventName();
        
        let startTime;
        if (typeof evt.start_at === 'string') {
            startTime = new Date(evt.start_at);
        } else {
            startTime = new Date(evt.start_at * 1000);
        }

        let endTime;
        if (evt.end_at) {
             if (typeof evt.end_at === 'string') {
                endTime = new Date(evt.end_at);
            } else {
                endTime = new Date(evt.end_at * 1000);
            }
        } else {
            endTime = new Date(startTime.getTime() + 90 * 60000); // Default 90 min
        }
        
        const eventId = IdGenerator.fromComponents('groupme', 'event', groupmeEventId);
        const eventTypeId = this.getEventTypeId();
        const durationMinutes = Math.round((endTime - startTime) / 60000);
        
        let eventObj;
        
        if (eventTypeId === this.eventTypes.training) {
          eventObj = new Practice({
            event_id: eventId,
            title: name,
            event_type_id: eventTypeId,
            event_date: startTime.toISOString(),
            duration_minutes: durationMinutes,
            team_id: this.teamId || null,
            created_by: '77d77471-1250-47e0-81ab-d4626595d63c', // SYSTEM_USER_ID
            external_event_id: groupmeEventId
          });
        } else {
          eventObj = new Match({
            event_id: eventId,
            name: name,
            event_type_id: eventTypeId,
            start_time: startTime.toISOString(),
            end_time: endTime.toISOString(),
            duration_minutes: durationMinutes,
            team_id: this.teamId || null,
            created_by: '77d77471-1250-47e0-81ab-d4626595d63c', // SYSTEM_USER_ID
            source_app_id: '550e8400-e29b-41d4-a716-446655440311',
            external_source: 'groupme',
            external_event_id: groupmeEventId
          });
        }
        
        this.data.events.set(eventId, eventObj);
        
        // Store RSVPs for later processing
        if (evt.going) {
          if (!this.data.rsvps) this.data.rsvps = new Map();
          this.data.rsvps.set(eventId, evt.going);
        }
      }
      
    } catch (error) {
      this.logError('Failed to fetch calendar events', error);
    }
  }

  async fetchRsvps() {
    if (!this.data.rsvps || this.data.rsvps.size === 0) {
      return;
    }
    
    this.log('\n✅ Processing RSVPs...');
    
    let totalRsvps = 0;
    
    for (const [eventId, rsvps] of this.data.rsvps.entries()) {
      for (const rsvp of rsvps) {
        const groupmeUserId = rsvp.user_id;
        const status = this.mapRsvpStatus(rsvp.status || 'going');
        
        const rsvpId = IdGenerator.fromComponents('rsvp', eventId, groupmeUserId);
        
        if (!this.data.eventRsvps) this.data.eventRsvps = new Map();
        
        this.data.eventRsvps.set(rsvpId, {
          event_id: eventId,
          groupme_user_id: groupmeUserId,
          rsvp_status_id: status,
          responded_at: new Date().toISOString()
        });
        
        totalRsvps++;
      }
    }
    
    this.log(`   Processed ${totalRsvps} RSVPs`);
  }

  async transformData() {
    // No transformation needed for GroupMe data
  }

  async generateOutput() {
    this.log('\n💾 Generating SQL output...');
    
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: `50-groupme-${this.getFilenameSuffix()}-users.sql`,
        data: this.data.externalIdentities,
        options: {
          title: `${this.chatName} - External Identities`,
          tableName: 'user_external_identities',
          useInserts: true
        }
      },
      {
        filename: `25-groupme-${this.getFilenameSuffix()}-schedule.sql`,
        data: this.data.events,
        options: {
          title: `${this.chatName} - Schedule`,
          useInserts: true
        }
      },
      {
        filename: `26-groupme-${this.getFilenameSuffix()}-rsvps.sql`,
        data: this.data.eventRsvps || new Map(),
        options: {
          title: `${this.chatName} - RSVPs`,
          useInserts: true
        }
      }
    ]);
    
    for (const result of results) {
      if (result.count > 0) {
        this.logSuccess(`${result.filepath}: ${result.count} records`);
      }
    }
  }

  async cleanup() {
    // No cleanup needed
  }

  // Helper methods to be overridden by subclasses
  getDefaultEventName() {
    return 'Event';
  }

  getEventTypeId() {
    return this.eventTypes.training;
  }

  getFilenameSuffix() {
    return 'chat';
  }

  splitName(fullName) {
    const parts = fullName.trim().split(/\s+/);
    if (parts.length === 1) return { first: parts[0], last: '' };
    const first = parts[0];
    const last = parts.slice(1).join(' ');
    return { first, last };
  }

  mapRsvpStatus(status) {
    if (status === 'going') return this.rsvpStatuses.yes;
    if (status === 'not_going') return this.rsvpStatuses.no;
    return this.rsvpStatuses.maybe;
  }
}

module.exports = GroupMeScraper;
