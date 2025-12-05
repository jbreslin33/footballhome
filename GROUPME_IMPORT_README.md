# GroupMe RSVP Import Guide

## Overview
Import RSVPs from GroupMe team chats into Football Home database using fuzzy name matching.

## Quick Start

### 1. Dry Run (recommended first)
```bash
npm run groupme:import:dry
```

This shows:
- Which GroupMe users match Football Home players
- Match confidence scores (60-100%)
- Players that couldn't be matched

### 2. Run Actual Import
```bash
node scripts/groupme-import.js 108640377
```

Or for a specific group:
```bash
npm run groupme:import -- 108640377
```

## How It Works

### Fuzzy Name Matching
The script uses intelligent name matching to handle variations:

| GroupMe Name | Database Name | Match Score | Result |
|--------------|---------------|-------------|--------|
| James Breslin | James Breslin | 100% | ✅ Exact match |
| James | James Breslin | 90% | ✅ First name match |
| Breslin | James Breslin | 90% | ✅ Last name match |
| J. Breslin | James Breslin | 60% | ✅ Initial + last |
| Jimmy B | James Breslin | 0% | ❌ No match |

**Minimum confidence:** 60% required to auto-match

### RSVP Detection
Messages are scanned for these patterns:

**YES** (status: `yes`)
- "yes", "in", "attending", "I'm in", "count me in"
- "I'll be there", "coming", "going"

**NO** (status: `no`)
- "no", "out", "can't make it", "won't make it"
- "not coming", "can't come", "not going"

**MAYBE** (status: `maybe`)
- "maybe", "might", "possibly", "not sure", "tentative"

### Import Behavior
- **Fetches last 100 messages** from GroupMe
- **Most recent RSVP wins** (if player RSVPs multiple times)
- **Links to next upcoming practice** automatically
- **Stores original message** in notes field
- **Marks source** as `bulk_import` in change tracking

## Example Output

```
🚀 GroupMe RSVP Importer

🔌 Connecting to database...
✅ Connected

📨 Fetching RSVPs from GroupMe...
✅ Found 5 RSVP(s)

🔍 Matching GroupMe users to Football Home users...

✅ Matched: James Breslin → Luke Breslin (70% confidence)
✅ Matched: John Smith → John Smith (100% confidence)
✅ Matched: Mike → Michael Johnson (90% confidence)
❌ No match: JB
❌ No match: GroupMe

📊 Match Summary:
   ✅ Matched: 3
   ❌ Unmatched: 2

🎯 Linking RSVPs to: Saturday Practice (12/6/2025, 9:00:00 AM)

💾 Importing RSVPs...
  ✅ Luke Breslin: yes
  ✅ John Smith: yes
  ✅ Michael Johnson: maybe

✨ Successfully imported 3 RSVP(s)!

⚠️  2 player(s) could not be matched:
   - JB
   - GroupMe

💡 Tip: Add these players to the roster, then re-run the import.
```

## Handling Unmatched Players

### Strategy 1: Add Players to Roster
1. Create user account in Football Home
2. Add to team roster
3. Re-run import

### Strategy 2: Manual Mapping (Future Enhancement)
Create a mapping file to handle known aliases:
```json
{
  "JB": "James Breslin",
  "Mike D": "Michael Davis"
}
```

### Strategy 3: Name Standardization
Ask players to update their GroupMe display names to match roster.

## Database Schema

RSVPs are stored in `player_rsvp_history`:

| Field | Description |
|-------|-------------|
| `event_id` | Links to practice/event |
| `player_id` | Links to user |
| `rsvp_status_id` | yes/no/maybe |
| `changed_at` | Timestamp from GroupMe message |
| `change_source_id` | Set to `bulk_import` |
| `notes` | Original GroupMe message text |

## Troubleshooting

### No RSVPs Found
- Check last 100 messages contain RSVP keywords
- Try expanding RSVP patterns in script
- Verify GroupMe access token is valid

### All Players Unmatched
- Check team_id in script matches your team
- Verify players are active on roster (`is_active = true`)
- Check name spelling in database

### Duplicate Imports
- Script allows duplicate history entries (by design)
- Each import creates new history row
- Most recent RSVP is displayed in UI

### Wrong Practice Selected
- Script picks next upcoming practice
- If multiple practices on same day, picks earliest
- Manually specify event_id in script if needed

## npm Scripts

```bash
# List all GroupMe groups
npm run groupme:list

# View recent messages
npm run groupme:messages -- 108640377

# Check RSVP patterns
npm run groupme:rsvp -- 108640377

# Dry run import (safe)
npm run groupme:import:dry

# Actual import
npm run groupme:import -- 108640377
```

## Future Enhancements

1. **Custom Name Mapping File** - JSON config for known aliases
2. **Event Date Matching** - Match GroupMe events to practices by date
3. **Multi-Event Import** - Import RSVPs for all upcoming practices
4. **Interactive Mode** - Prompt for uncertain matches
5. **Incremental Updates** - Track last import, only process new messages
6. **Webhook Integration** - Auto-import when new GroupMe messages arrive

## Notes

- GroupMe API returns max 100 messages per request
- System messages (user_id: "system") are automatically filtered
- Import is idempotent - safe to run multiple times
- Original message text preserved for audit trail
- Match confidence displayed for manual review
