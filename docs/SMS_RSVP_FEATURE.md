# SMS RSVP Feature - Future Implementation

## Goal
Enable coach to easily send RSVP requests to players via SMS directly from browser/phone without Twilio.

## Approach
Use `sms:` URI scheme to open native messaging app with pre-filled message.

### Technical Details
- **Mobile**: `sms:` links open native SMS app automatically
- **Desktop Android**: Use messages.google.com (syncs with phone)
- **Desktop iOS**: Works from Mac Messages app, or use phone directly

### Implementation Tasks
1. Add clickable SMS links to player list in admin-system.js
2. Create RSVP page in footballhome with unique links per practice/event
3. Add "Send RSVP Request" button for bulk messaging non-RSVP'd players
4. Pre-fill message template: "Hi {player_name}! Please RSVP for practice: https://footballhome.app/rsvp/{practice_id}"

### Example Code
```javascript
// Phone number becomes clickable SMS link
<a href="sms:${player.phone}?body=Hi%20${encodeURIComponent(player.first_name)}!%20Please%20RSVP%20for%20practice:%20https://footballhome.app/rsvp/${practice_id}">
  📱 ${player.phone}
</a>
```

### Benefits
- Free (uses coach's phone plan)
- No backend service needed
- Instant delivery
- Works on all devices
- No setup required

## Status
**On hold** - Complete APSL, CASA, and GroupMe data modeling first.
