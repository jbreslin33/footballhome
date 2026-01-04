# Scraper Architecture - Domain-Driven Design

## Overview

This is a **clean OOP architecture** using Domain-Driven Design principles. Every component has a single responsibility and can be reused across different scrapers.

## Directory Structure

```
database/scripts/
├── domain/
│   ├── models/           # Pure domain objects (Country, Organization, League, Team, Player)
│   └── repositories/     # Database operations (CountryRepo, OrganizationRepo, etc.)
├── infrastructure/
│   ├── fetchers/         # Generic data fetching (ApiFetcher, HtmlFetcher)
│   └── parsers/          # Domain-specific parsing (RestCountriesParser, ApslParser)
├── application/
│   └── services/         # Business logic (ScrapeTargetService)
└── scrapers/             # Thin orchestrators (CountryScraperV2, ApslScraper)
```

## Key Principles

### 1. Domain Models (domain/models/)
- **Pure business objects** with validation
- NO database or external dependencies
- Contains `validate()` and `toDbRow()` methods
- Examples: `Country`, `Organization`, `League`, `Team`, `Player`

### 2. Repositories (domain/repositories/)
- **All database operations** for an entity
- Abstracts SQL from business logic
- Returns domain objects, not raw DB rows
- Handles FK lookups and cascade operations
- Examples: `CountryRepository`, `OrganizationRepository`, `LeagueRepository`

### 3. Fetchers (infrastructure/fetchers/)
- **Generic data fetching** - no domain knowledge
- `ApiFetcher` - REST APIs
- `HtmlFetcher` - Web pages (uses Puppeteer)
- Returns raw data (JSON, HTML)

### 4. Parsers (infrastructure/parsers/)
- **Domain-specific parsing** - transforms raw data into domain models
- `RestCountriesParser` - REST Countries API → Country models
- `ApslConferenceParser` - APSL HTML → Organization/League/Conference models
- Returns arrays of validated domain models

### 5. Services (application/services/)
- **Business logic and coordination**
- `ScrapeTargetService` - Manages scrape_targets table (URLs, state tracking)
- Can have other services as needed

### 6. Scrapers (scrapers/)
- **Thin orchestrators** - wire components together
- Use dependency injection (all components passed in constructor)
- Example workflow:
  1. Get URL from `ScrapeTargetService`
  2. Fetch data with `ApiFetcher` or `HtmlFetcher`
  3. Parse with domain-specific parser
  4. Save with repository
  5. Update scrape state

## Example: CountryScraperV2

```javascript
class CountryScraperV2 {
  constructor(fetcher, parser, countryRepo, continentRepo, targetService) {
    // Dependency injection - all components passed in
    this.fetcher = fetcher;
    this.parser = parser;
    this.countryRepo = countryRepo;
    this.continentRepo = continentRepo;
    this.targetService = targetService;
  }
  
  async run(mode) {
    // 1. Get scrape target (URL + state)
    const target = await this.targetService.getTarget(6, 17);
    
    // 2. Fetch raw data
    const rawData = await this.fetcher.fetch(target.url);
    
    // 3. Parse into domain models
    const countries = this.parser.parse(rawData);
    
    // 4. Get FK lookups from repository
    const continentMap = await this.continentRepo.getContinentMap();
    
    // 5. Save to database
    await this.countryRepo.upsertMany(countries, continentMap);
    
    // 6. Update scrape state
    await this.targetService.updateSyncTime(target.id);
  }
}
```

## Benefits

### ✅ Reusability
- `ApiFetcher` works for REST Countries, Google Places, any API
- `HtmlFetcher` works for APSL, CASA, any website
- Repositories handle all DB operations - never write raw SQL in scrapers

### ✅ Testability
- Test parsers with mock data (no network calls)
- Test repositories with test database
- Test scrapers with mock dependencies

### ✅ Separation of Concerns
- Fetchers don't know about domains
- Parsers don't know about databases
- Models don't know about external APIs
- Scrapers just coordinate

### ✅ Scalability to Soccer
Same pattern works for complex hierarchies:

```javascript
class ApslConferenceStructureScraper {
  constructor(
    htmlFetcher,
    apslParser,
    orgRepo,
    leagueRepo,
    seasonRepo,
    conferenceRepo,
    divisionRepo,
    targetService
  ) {
    // All dependencies injected
  }
  
  async run() {
    // 1. Get target URL
    const target = await this.targetService.getTarget(1, 1); // APSL conference structure
    
    // 2. Fetch HTML
    const html = await this.htmlFetcher.fetch(target.url);
    
    // 3. Parse into domain models
    const structure = await this.apslParser.parse(html);
    // Returns: { organization, leagues, seasons, conferences, divisions, teams }
    
    // 4. Save hierarchically (cascade through FKs)
    const orgId = await this.orgRepo.upsert(structure.organization);
    
    for (const league of structure.leagues) {
      league.organizationId = orgId;
      const leagueId = await this.leagueRepo.upsert(league);
      
      // Continue cascade: season → conference → division → team
    }
    
    // 5. Update scrape state
    await this.targetService.markInitialized(target.id);
  }
}
```

## Migration Path

1. ✅ **Phase 1**: Country scraper with OOP (DONE)
2. **Phase 2**: APSL conference structure scraper (soccer hierarchy)
3. **Phase 3**: APSL standings/schedules/rosters
4. **Phase 4**: CASA scrapers
5. **Phase 5**: GroupMe scrapers

Each new scraper reuses fetchers, repositories, and services from previous work.
