# GroupMe Calendar Scraper Setup

## Overview
The GroupMe calendar scraper uses Puppeteer (browser automation) to extract RSVP data from GroupMe calendar events. This is necessary because GroupMe's API doesn't provide access to calendar event RSVPs.

## Why This Matters
This is **critical for the GroupMe → Football Home migration strategy**:
- Players currently RSVP in GroupMe calendar
- We need to import this data to Football Home
- Over time, we'll transition players to RSVP directly in Football Home
- During transition, this keeps both systems in sync

## Setup Options

### Option 1: Automated Login (Recommended)
Add your GroupMe credentials to `.env`:

```bash
GROUPME_EMAIL=your-email@example.com
GROUPME_PASSWORD=your-password
```

**Pros:**
- Fully automated
- Works on headless servers
- No manual intervention needed

**Cons:**
- Stores password (use environment variables, not git)
- May break if GroupMe adds 2FA

### Option 2: Manual Login (More Secure)
Run the scraper on a machine with a display (your laptop, not the server):

```bash
# On your laptop with a display
node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd
```

Browser will open, you login manually, then cookies are saved to `.groupme-cookies.json`. Copy this file to the server:

```bash
scp .groupme-cookies.json your-server:~/sandbox/github/footballhome/
```

Now the server can use saved cookies (valid ~30 days).

## Usage

### Basic Usage
```bash
# Get event ID from: npm run groupme:events -- 108640377
node scripts/groupme-calendar-scraper.js <GROUP_ID> <EVENT_ID>

# Example for Lighthouse 1893 SC
node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd
```

### Using npm script
```bash
npm run groupme:calendar -- 108640377 05185f7920c14cb8825547ad4779afbd
```

### Output
The script will show:
- ✅ Going: List of names
- ❓ Maybe: List of names  
- ❌ Not Going: List of names
- ⏳ No Response: List of names

Plus saves:
- `/tmp/groupme-event.png` - Screenshot for debugging
- `/tmp/groupme-event.html` - Full HTML for inspection
- `.groupme-cookies.json` - Session for future runs

## Integration with Football Home

### Step 1: Scrape Event RSVPs
```bash
node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd
```

### Step 2: Match Names to Players
The output gives you names like "Christopher Fletcher", "Logan Bersani", etc.

### Step 3: Import to Database
Currently manual - you'll need to:
1. Match GroupMe names to Football Home player IDs
2. Insert RSVPs into `player_rsvp_history` table
3. Link to correct event ID

### Future: Automated Import Pipeline
TODO: Create `groupme-calendar-import.js` that:
1. Scrapes event RSVPs
2. Uses fuzzy matching (from `groupme-import.js`)
3. Automatically inserts into database
4. Handles conflicts/duplicates

## Troubleshooting

### No RSVPs Found
Check the saved files:
```bash
open /tmp/groupme-event.png      # Visual inspection
cat /tmp/groupme-event.html      # Check HTML structure
```

GroupMe may have changed their DOM structure. Update the selectors in the scraper:
- `.member-name` → whatever GroupMe now uses
- `.rsvp-section` → new class names
- `[data-rsvp-status]` → new attributes

### Session Expired
Delete `.groupme-cookies.json` and login again:
```bash
rm .groupme-cookies.json
node scripts/groupme-calendar-scraper.js 108640377 05185f7920c14cb8825547ad4779afbd
```

### Headless Mode Issues
If running on a server without display:
1. Run once on your laptop to save cookies
2. Copy `.groupme-cookies.json` to server
3. Server uses saved session (no login needed)

## Security Notes

- **Never commit `.groupme-cookies.json`** - Already in `.gitignore`
- **Never commit `.env` with passwords** - Already in `.gitignore`
- Cookies expire after ~30 days, will need re-login
- Consider using encrypted secrets for production deployments

## Migration Strategy Timeline

**Phase 1 (Current)**: Manual Scraping
- Coaches manually run scraper before practice
- Copy/paste RSVPs to Football Home
- Slow but proves concept

**Phase 2 (Next)**: Automated Import
- Scraper runs on schedule (cron job)
- Automatically imports to Football Home
- Players still RSVP in GroupMe
- Both systems stay in sync

**Phase 3 (Future)**: Native RSVPs
- Players RSVP directly in Football Home
- GroupMe becomes secondary/legacy
- Scraper only for historical data

**Phase 4 (End State)**: Full Migration
- GroupMe retired for team coordination
- All RSVPs in Football Home
- Scraper archived/removed

## Next Steps

1. **Test the scraper** on your machine with a display
2. **Verify it captures RSVPs** correctly
3. **Build automated import** (`groupme-calendar-import.js`)
4. **Schedule regular syncs** (every 6 hours?)
5. **Monitor accuracy** of name matching
6. **Gradually transition** players to native RSVPs
