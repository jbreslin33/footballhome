# Football Home - Progress Notes

## 🎯 Current Status (Nov 26, 2025)

### Just Completed: RSVP History System (Normalized)

We converted the RSVP system from single-row updates to **append-only history tables** for full audit trail.

#### What Changed:

**New Lookup Table:**
- `rsvp_change_sources` - Tracks HOW RSVPs were submitted:
  - `app` - Mobile/Web App
  - `coach_entry` - Coach entered on behalf of player
  - `magic_link` - Email/SMS link
  - `bulk_import` - Admin bulk import
  - `parent_entry` - Parent entered for player

**New History Tables (Append-Only):**
- `player_rsvp_history` - All player RSVP changes
- `coach_rsvp_history` - All coach RSVP changes  
- `parent_rsvp_history` - All parent RSVP changes

Each tracks:
- `event_id`, `player_id/coach_id/parent_id`
- `rsvp_status_id` (yes/no/maybe from `rsvp_statuses` lookup)
- `changed_at` (timestamp of change)
- `changed_by` (who made change - could be coach on behalf of player)
- `change_source_id` (how it was submitted)
- `notes`

**New Views (For Easy Access to Current Status):**
- `player_rsvps_current` - Latest RSVP for each player/event
- `coach_rsvps_current` - Latest RSVP for each coach/event
- `parent_rsvps_current` - Latest RSVP for each parent/event

**Removed:**
- Old single-row `player_rsvps`, `coach_rsvps`, `parent_rsvps` tables
- Old unused generic `rsvps` table

#### Why This Design:
1. **Full audit trail** - See when RSVPs changed, by whom, how
2. **Analytics** - Identify flip-floppers, last-minute changers, reliability scores
3. **More normalized** - Append-only = no update anomalies
4. **Coach visibility** - Know when coach entered RSVP on behalf of player

### Next Steps (In Order):

1. **Test the schema** - Run scrape + start.sh, verify login works
2. **Update backend RSVP endpoints** - Use new history tables (INSERT not UPDATE)
3. **Add RSVP close-off logic** - Prevent changes after event ends
4. **Build attendance system** - Separate table for actual attendance (vs planned RSVP)

### Attendance System (Planned):

After RSVP is solid, we'll add:
- `attendance_statuses` lookup (present, late, absent, excused, etc.)
- `event_attendance` table - Records who actually showed up
- Auto-populate from RSVPs when event ends
- Coach can correct (mark no-shows, surprise attendees)
- Analytics: attendance rate, RSVP reliability score

---

## 🔧 Key Files Modified

### Schema Changes (Nov 26, 2025):
- `database/data/00-schema.sql` - New RSVP history tables and views
- `database/data/01-core-lookups.sql` - Added `rsvp_change_sources` data

### Previous Work:
- Match screens added (`match-options.js`, `match-list.js`, `team-dashboard.js`)
- EventController updated with match endpoints
- Database flat structure (all SQL in `database/data/`)

---

## 🧪 Test Credentials
- **Email**: jbreslin@footballhome.org
- **Password**: 1893Soccer!
- **Team**: Lighthouse 1893 SC

---

## 🚀 Quick Start
```bash
# Fresh rebuild (deletes volumes)
./start.sh

# Preserve data
./start.sh --volumes

# Use Docker cache
./start.sh --cache
```

---

**Last Updated**: November 26, 2025
**Status**: RSVP history schema complete, needs testing + backend update