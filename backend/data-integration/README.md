# Football Home - External Data Integration System

This service handles importing and synchronizing data from external league websites and APIs into the Football Home system.

## Architecture Overview

The data integration system consists of several components:

1. **External Data Sources**: Configuration for different league websites/APIs
2. **Scrapers**: Service-specific data extraction modules
3. **Staging System**: Temporary storage and processing of external data
4. **Mapping System**: Links external entities to internal database records
5. **Conflict Resolution**: Handles data inconsistencies and duplicates

## Supported Data Sources

### APSL (Amateur Premier Soccer League)
- **Type**: Website scraping
- **URL**: https://www.apslsoccer.com
- **Data**: Standings tables for all 6 conferences
- **Update Frequency**: Daily at 6 AM
- **Status**: Active

### CASA (Central Atlantic Soccer Association)
- **Type**: REST API (when available)
- **Status**: Placeholder - not yet implemented

### TCWL (Tri-County Women's League)
- **Type**: Website scraping (when available)
- **Status**: Placeholder - not yet implemented

## Database Schema

### Core Tables

- `external_data_sources`: Configuration for each external system
- `data_source_endpoints`: Specific URLs and extraction rules
- `import_jobs`: Track data import operations
- `staging_external_data`: Temporary storage for raw external data
- `external_entity_mappings`: Link external IDs to internal records
- `import_conflicts`: Handle data conflicts requiring manual review
- `data_sync_history`: Audit trail of all changes

## API Endpoints

### Health Check
```
GET /health
```
Returns service health status.

### Manual Sync Operations
```
POST /sync/apsl
```
Trigger manual APSL sync for all conferences.

```
POST /sync/all
```
Trigger manual sync for all active data sources.

### Status and Monitoring
```
GET /sync/status
```
Get sync status for all configured sources.

```
GET /conflicts
```
Get unresolved import conflicts requiring manual review.

```
POST /conflicts/:conflictId/resolve
```
Resolve a specific import conflict.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Node environment |
| `DB_HOST` | `db` | Database host |
| `DB_PORT` | `5432` | Database port |
| `DB_NAME` | `footballhome` | Database name |
| `DB_USER` | `footballhome_user` | Database username |
| `DB_PASSWORD` | `footballhome_pass` | Database password |
| `PORT` | `3002` | Service port |

### Adding New Data Sources

1. **Database Configuration**: Add entry to `external_data_sources` table
2. **Endpoint Configuration**: Define extraction rules in `data_source_endpoints`
3. **Scraper Implementation**: Create scraper class in `scrapers/` directory
4. **Integration**: Wire up scraper in main service

## Usage Examples

### Running Manual Sync
```bash
# Sync just APSL data
docker exec footballhome_data_integration npm run sync-apsl

# Sync all configured sources
curl -X POST http://localhost:3002/sync/all
```

### Checking Sync Status
```bash
curl http://localhost:3002/sync/status
```

### Viewing Import Conflicts
```bash
curl http://localhost:3002/conflicts
```

## Data Flow

1. **Scheduled/Manual Trigger**: Cron job or API call initiates sync
2. **Data Extraction**: Scraper fetches data from external source
3. **Staging**: Raw data stored in `staging_external_data` table
4. **Entity Mapping**: External teams/entities mapped to internal records
5. **Conflict Detection**: Data conflicts identified and flagged
6. **Data Processing**: Valid data inserted/updated in main tables
7. **History Logging**: All changes recorded in sync history

## Entity Mapping Strategy

### Team Mapping
1. **Exact Match**: Look for existing mapping by external ID or name
2. **Fuzzy Match**: Use PostgreSQL similarity functions for close matches
3. **Auto-Create**: Create new team record if no match found (flagged for review)
4. **Manual Review**: Low-confidence matches require human verification

### Confidence Scoring
- `1.00`: Exact match or manually verified
- `0.60-0.99`: Fuzzy match based on name similarity
- `0.00`: Auto-created team requiring manual review

## Error Handling

### Rate Limiting
- Respectful scraping with delays between requests
- Configurable rate limits per data source

### Retry Logic
- Automatic retries with exponential backoff
- Graceful handling of temporary network issues

### Conflict Resolution
- Automatic resolution for simple conflicts
- Manual review queue for complex issues
- Audit trail for all resolution decisions

## Monitoring and Logging

### Log Levels
- **ERROR**: Failed operations, data conflicts
- **WARN**: Rate limiting, retry attempts
- **INFO**: Successful operations, sync completions
- **DEBUG**: Detailed extraction and processing info

### Metrics Tracked
- Import job success/failure rates
- Processing times per data source
- Entity mapping confidence scores
- Conflict resolution statistics

## Development

### Adding a New Scraper

1. Create scraper class in `scrapers/NewLeagueScraper.js`
2. Implement required methods:
   - `scrapeData()`: Extract data from external source
   - `testConnection()`: Verify connectivity
3. Register in main service and configure scheduling

### Testing

```bash
# Install dependencies
npm install

# Run tests
npm test

# Test specific scraper
node scripts/test-scraper.js apsl
```

## Deployment

The service is automatically deployed as part of the Docker Compose stack:

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f data-integration

# Scale if needed
docker-compose up -d --scale data-integration=2
```

## Security Considerations

- **Rate Limiting**: Respectful scraping to avoid being blocked
- **User Agent**: Identifies as legitimate data sync service
- **Authentication**: API key support for authenticated sources
- **Data Validation**: All external data validated before processing
- **Audit Trail**: Complete history of all data changes

## Future Enhancements

1. **Real-time APIs**: Support for webhook-based updates
2. **Machine Learning**: Improved entity matching using ML models
3. **Advanced Scheduling**: More sophisticated sync scheduling
4. **Data Quality**: Advanced validation and cleansing rules
5. **Multi-tenant**: Support for multiple football organizations