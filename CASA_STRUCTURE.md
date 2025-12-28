# CASA League Structure

## Organizations
- **CASA Soccer** (ID: 2)

## Leagues under CASA
1. **CASA Select** (US Soccer affiliated)
   - Affiliation: US Soccer
   - Has promotion/relegation agreement with APSL
   
2. **CASA Traditional** (Unaffiliated)
   - Affiliation: Unaffiliated
   - Houses unaffiliated 11v11 leagues

## CASA Select - Conferences & Divisions

### Philadelphia Conference (2 divisions)
- **Liga 1** - URL: [Pending]
- **Liga 2** - URL: [Pending]

### Lancaster Conference (1 division)
- **Liga 1** - URL: [Pending]

### Boston Conference (1 division)
- **Liga 1** - URL: [Pending]

### South New Jersey Conference (1 division) [PLACEHOLDER - Launching Spring]
- **Liga 1** - URL: [Pending]

### Central New Jersey Conference (1 division)
- **Liga 1** - URL: [Pending]

### North New Jersey Conference (1 division) [PLACEHOLDER - Launching Spring]
- **Liga 1** - URL: [Pending]

**Total**: 6 conferences, 8 divisions

---

## CASA Traditional - Conferences & Divisions

### Philadelphia Conference (7 divisions)
- **Primera** - URL: [Pending]
- **Segunda** - URL: [Pending]
- **Tercera** - URL: [Pending]
- **Cuarta** - URL: [Pending]
- **Quinta** - URL: [Pending]
- **Sexta** - URL: [Pending]
- **Septima** - URL: [Pending]

### Boston Conference (4 divisions + 2 sub-divisions)
- **Primera** - URL: [Pending]
- **Segunda** - URL: [Pending]
- **Tercera** - URL: [Pending]
- **Cuarta Roja** (4th Red) - URL: [Pending]
- **Cuarta Azul** (4th Blue) - URL: [Pending]

**Total**: 2 conferences, 12 divisions

---

## Current Scraper Configuration (needs update)

The CasaScraper currently has hardcoded configuration for:
- Philadelphia Liga 1 & Liga 2
- Boston Liga 1
- Lancaster Liga 1
- Central NJ Liga 1

**This only covers CASA Traditional Philadelphia!** 

We need to update the scraper with:
1. All CASA Select standings/schedule URLs
2. All CASA Traditional standings/schedule URLs
3. Proper league/conference/division IDs
4. Spanish division names (Primera, Segunda, etc. for Traditional; Liga 1, Liga 2, etc. for Select)

---

## Next Steps

1. **Get all CASA Select URLs** (standings + schedules for each division)
2. **Get all CASA Traditional URLs** (standings + schedules for each division)
3. **Update CasaScraper.js** configuration with proper structure:
   ```javascript
   this.leagues = {
     select: {
       name: 'CASA Select',
       organization_id: 2,
       affiliation: 'US Soccer',
       conferences: {
         philadelphia: {
           name: 'Philadelphia',
           divisions: {
             liga1: { name: 'Liga 1', standings: '...', schedule: '...', rosterSheet: '...' },
             liga2: { name: 'Liga 2', standings: '...', schedule: '...', rosterSheet: '...' }
           }
         },
         // ... other conferences
       }
     },
     traditional: {
       name: 'CASA Traditional',
       organization_id: 2,
       affiliation: 'Unaffiliated',
       conferences: {
         philadelphia: {
           name: 'Philadelphia',
           divisions: {
             primera: { name: 'Primera', standings: '...', schedule: '...', rosterSheet: '...' },
             segunda: { name: 'Segunda', standings: '...', schedule: '...', rosterSheet: '...' },
             // ... all 7 divisions
           }
         },
         boston: {
           name: 'Boston',
           divisions: {
             primera: { name: 'Primera', standings: '...', schedule: '...', rosterSheet: '...' },
             segunda: { name: 'Segunda', standings: '...', schedule: '...', rosterSheet: '...' },
             tercera: { name: 'Tercera', standings: '...', schedule: '...', rosterSheet: '...' },
             cuarta_roja: { name: 'Cuarta Roja', standings: '...', schedule: '...', rosterSheet: '...' },
             cuarta_azul: { name: 'Cuarta Azul', standings: '...', schedule: '...', rosterSheet: '...' }
           }
         }
       }
     }
   };
   ```
4. **Generate SQL files per league**:
   - `11b-casa-select-*.sql` (leagues, conferences, divisions, teams, matches)
   - `11c-casa-traditional-*.sql` (leagues, conferences, divisions, teams, matches)
