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

    // Initialize data stores for new schema
    this.data.groupmeUsers = new Map();
    this.data.groupmeGroups = new Map();
    this.data.groupmeMemberships = new Map();
    this.data.groupmeMessages = new Map();
    this.data.teamGroupmeGroups = new Map(); // Junction table
    this.data.sportDivisionGroupmeGroups = new Map(); // Junction table
  }

  async initialize() {
    this.log(`Initializing ${this.chatName} scraper...`);
    this.log(`Group ID: ${this.groupId}`);
    
    // Create the group record immediately (without team_id/sport_division_id)
    const internalGroupId = IdGenerator.fromComponents('groupme', 'group', this.groupId);
    this.data.groupmeGroups.set(internalGroupId, {
      id: internalGroupId,
      groupme_group_id: this.groupId,
      name: this.chatName
    });
    
    // Create junction table records
    if (this.teamId) {
      const junctionId = IdGenerator.fromComponents('team_groupme', this.teamId, this.groupId);
      this.data.teamGroupmeGroups.set(junctionId, {
        id: junctionId,
        team_id: this.teamId,
        groupme_group_id: internalGroupId,
        is_primary: true
      });
    }
    
    if (this.sportDivisionId) {
      const junctionId = IdGenerator.fromComponents('division_groupme', this.sportDivisionId, this.groupId);
      this.data.sportDivisionGroupmeGroups.set(junctionId, {
        id: junctionId,
        sport_division_id: this.sportDivisionId,
        groupme_group_id: internalGroupId,
        is_primary: true
      });
    }
  }

  async fetchData() {
    // Fetch users (members)
    await this.fetchUsers();
    
    // Fetch messages (chat history)
    await this.fetchMessages();

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
      
      // Update group details if available
      const internalGroupId = IdGenerator.fromComponents('groupme', 'group', this.groupId);
      if (this.data.groupmeGroups.has(internalGroupId)) {
        const groupRecord = this.data.groupmeGroups.get(internalGroupId);
        groupRecord.name = group.name || this.chatName;
        groupRecord.description = group.description || null;
        groupRecord.image_url = group.image_url || null;
      }
      
      this.log(`   Found ${members.length} members`);
      
      for (const member of members) {
        const groupmeId = member.user_id;
        const name = member.nickname || member.name || 'Unknown';
        const { first, last } = this.splitName(name);
        
        // 1. Create/Update GroupMe User
        // We use the immutable groupme_id to generate our internal UUID
        const internalUserId = IdGenerator.fromComponents('groupme', 'user', groupmeId);
        
        if (!this.data.groupmeUsers.has(internalUserId)) {
            this.data.groupmeUsers.set(internalUserId, {
                id: internalUserId,
                groupme_id: groupmeId,
                name: member.name || name, // Prefer global name if available, else nickname
                avatar_url: member.image_url || null
            });
        }

        // 2. Create Membership Record
        // Links this user to this specific group with their specific nickname
        const membershipId = IdGenerator.fromComponents('groupme', 'membership', this.groupId, groupmeId);
        
        this.data.groupmeMemberships.set(membershipId, {
            id: membershipId,
            groupme_user_id: internalUserId,
            groupme_group_id: internalGroupId,
            nickname: member.nickname,
            role: member.roles ? (member.roles.includes('owner') ? 'owner' : (member.roles.includes('admin') ? 'admin' : 'member')) : 'member'
        });
      }
      
    } catch (error) {
      this.logError('Failed to fetch chat members', error);
    }
  }

  async fetchMessages() {
    this.log('\n💬 Fetching chat messages...');
    
    try {
      const internalGroupId = IdGenerator.fromComponents('groupme', 'group', this.groupId);
      let messageCount = 0;
      let beforeId = null;
      const limit = 100; // GroupMe max per page
      const maxMessages = 1000; // Limit total messages to avoid long scrapes
      
      while (messageCount < maxMessages) {
        let endpoint = `/groups/${this.groupId}/messages?limit=${limit}`;
        if (beforeId) {
          endpoint += `&before_id=${beforeId}`;
        }
        
        const apiResponse = await this.apiClient.fetch(endpoint);
        const response = apiResponse.response || apiResponse;
        const messages = response.messages || [];
        
        if (messages.length === 0) {
          break; // No more messages
        }
        
        for (const msg of messages) {
          const groupmeMessageId = msg.id;
          const groupmeUserId = msg.sender_id !== 'system' 
            ? IdGenerator.fromComponents('groupme', 'user', msg.user_id)
            : null;
          
          const messageId = IdGenerator.fromComponents('groupme', 'message', groupmeMessageId);
          
          this.data.groupmeMessages.set(messageId, {
            id: messageId,
            groupme_message_id: groupmeMessageId,
            groupme_group_id: internalGroupId,
            groupme_user_id: groupmeUserId,
            text: msg.text || null,
            attachments: msg.attachments ? JSON.stringify(msg.attachments) : null,
            favorited_by: msg.favorited_by ? JSON.stringify(msg.favorited_by) : null,
            is_system: msg.system || false,
            created_at: new Date(msg.created_at * 1000).toISOString()
          });
          
          messageCount++;
        }
        
        // Set beforeId to the last message ID for pagination
        beforeId = messages[messages.length - 1].id;
        
        this.log(`   Fetched ${messageCount} messages...`);
        
        // Small delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 200));
      }
      
      this.log(`   Total: ${messageCount} messages`);
      
    } catch (error) {
      this.logError('Failed to fetch chat messages', error);
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
      
      // Initialize groupmeEvents storage if needed
      if (!this.data.groupmeEvents) this.data.groupmeEvents = new Map();
      
      const internalGroupId = IdGenerator.fromComponents('groupme', 'group', this.groupId);
      
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
        
        // Store in groupme_events table (not main events table)
        this.data.groupmeEvents.set(eventId, {
          id: eventId,
          groupme_event_id: groupmeEventId,
          groupme_group_id: internalGroupId,
          name: name,
          description: evt.description || null,
          start_at: startTime.toISOString(),
          end_at: endTime.toISOString(),
          location: evt.location || null,
          is_cancelled: evt.is_cancelled || false,
          sync_status: 'pending' // Will be synced to events table later
        });
        
        // Store RSVPs for later processing
        if (evt.going && evt.going.length > 0) {
          if (!this.data.groupmeEventRsvps) this.data.groupmeEventRsvps = new Map();
          
          for (const rsvp of evt.going) {
            const groupmeUserId = IdGenerator.fromComponents('groupme', 'user', rsvp.user_id);
            const rsvpId = IdGenerator.fromComponents('groupme', 'rsvp', eventId, rsvp.user_id);
            
            this.data.groupmeEventRsvps.set(rsvpId, {
              id: rsvpId,
              groupme_event_id: eventId,
              groupme_user_id: groupmeUserId,
              status: 'going',
              responded_at: new Date().toISOString()
            });
          }
        }
      }
      
    } catch (error) {
      this.logError('Failed to fetch calendar events', error);
    }
  }

  async fetchRsvps() {
    // RSVPs are now handled inline in fetchSchedule()
    // This method is kept for compatibility but does nothing
  }

  async transformData() {
    // No transformation needed for GroupMe data
  }

  async generateOutput() {
    this.log('\n� Writing SQL files (GroupMe data)...');
    
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: `50-groupme-${this.getFilenameSuffix()}-users.sql`,
        data: this.data.groupmeUsers,
        options: {
          title: `${this.chatName} - GroupMe Users`,
          tableName: 'groupme_users',
          useInserts: true,
          conflictColumns: ['groupme_id'] // Upsert on groupme_id
        }
      },
      {
        filename: `51-groupme-${this.getFilenameSuffix()}-groups.sql`,
        data: this.data.groupmeGroups,
        options: {
          title: `${this.chatName} - GroupMe Groups`,
          tableName: 'groupme_groups',
          useInserts: true,
          conflictColumns: ['groupme_group_id']
        }
      },
      {
        filename: `52-groupme-${this.getFilenameSuffix()}-memberships.sql`,
        data: this.data.groupmeMemberships,
        options: {
          title: `${this.chatName} - GroupMe Memberships`,
          tableName: 'groupme_memberships',
          useInserts: true,
          conflictColumns: ['groupme_user_id', 'groupme_group_id']
        }
      },
      {
        filename: `53-groupme-${this.getFilenameSuffix()}-messages.sql`,
        data: this.data.groupmeMessages || new Map(),
        options: {
          title: `${this.chatName} - Messages`,
          tableName: 'groupme_messages',
          useInserts: true,
          conflictColumns: ['groupme_message_id']
        }
      },
      {
        filename: `54-groupme-${this.getFilenameSuffix()}-events.sql`,
        data: this.data.groupmeEvents || new Map(),
        options: {
          title: `${this.chatName} - Calendar Events`,
          tableName: 'groupme_events',
          useInserts: true,
          conflictColumns: ['groupme_event_id']
        }
      },
      {
        filename: `55-groupme-${this.getFilenameSuffix()}-event-rsvps.sql`,
        data: this.data.groupmeEventRsvps || new Map(),
        options: {
          title: `${this.chatName} - Event RSVPs`,
          tableName: 'groupme_event_rsvps',
          useInserts: true,
          conflictColumns: ['groupme_event_id', 'groupme_user_id']
        }
      },
      {
        filename: `56-groupme-${this.getFilenameSuffix()}-team-groups.sql`,
        data: this.data.teamGroupmeGroups || new Map(),
        options: {
          title: `${this.chatName} - Team GroupMe Groups (Junction)`,
          tableName: 'team_groupme_groups',
          useInserts: true,
          conflictColumns: ['team_id', 'groupme_group_id']
        }
      },
      {
        filename: `57-groupme-${this.getFilenameSuffix()}-division-groups.sql`,
        data: this.data.sportDivisionGroupmeGroups || new Map(),
        options: {
          title: `${this.chatName} - Sport Division GroupMe Groups (Junction)`,
          tableName: 'sport_division_groupme_groups',
          useInserts: true,
          conflictColumns: ['sport_division_id', 'groupme_group_id']
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
