# Venue Scraper

Scrapes Google Maps for sports venue information in specified cities.

## What It Scrapes

- Venue names
- Addresses
- Coordinates (latitude/longitude)
- Venue types (soccer field, sports complex, park, etc.)
- Contact information

## Usage

**TODO**: This is a placeholder. The scraper needs to be implemented.

The scraper should:
1. Take a city/region as input
2. Search Google Maps for relevant sports venues
3. Extract venue data
4. Generate SQL INSERT statements
5. Output to `database/data/venues/XX-venues-[city].sql`

## Example Output

```sql
INSERT INTO venues (id, name, address, city, state, zip, latitude, longitude, venue_type, is_active)
VALUES (
  gen_random_uuid(),
  'Lighthouse Field',
  '123 Main St',
  'Philadelphia',
  'PA',
  '19123',
  39.9526,
  -75.1652,
  'soccer_field',
  true
)
ON CONFLICT (name, city, state) DO UPDATE SET
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude;
```

## Workflow

1. **Run the scraper**:
   ```bash
   cd database/scripts/venue-scraper
   node scrape-google-venues.js --city="Philadelphia, PA"
   ```

2. **Review changes**:
   ```bash
   git diff database/data/venues/
   ```

3. **Test locally**:
   ```bash
   ./start.sh
   # Test the app with new venue data
   ```

4. **Commit if happy**:
   ```bash
   git add database/data/venues/
   git commit -m "Add Philadelphia venues"
   git push
   ```

## Cities Already Scraped

Check `database/data/venues/` for existing venue files:
- Philadelphia, PA
- Lancaster, PA
- Harrisburg, PA
- Reading, PA
- Allentown, PA
- Scranton, PA
- Trenton, NJ
- Atlantic City, NJ
- Wilmington, DE

## Dependencies

TBD - likely needs:
```bash
npm install puppeteer  # or similar for web scraping
```

## Notes

- Google Maps may have rate limiting
- Consider caching results
- Use `ON CONFLICT` for idempotent imports
- May need Google Maps API key for better results
