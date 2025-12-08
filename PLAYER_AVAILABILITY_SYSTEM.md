# Player Availability Tracking System

## Overview
Comprehensive system to track player availability for practices and games, handling both medical and academic restrictions.

## Features

### Medical Status Tracking
- **Status Types**: healthy, injured, recovering, ill, concussion_protocol
- **Injury Details**: type, severity (minor/moderate/severe)
- **Availability Granularity**: 
  - Can practice but not play games (e.g., minor ankle sprain)
  - No activity allowed (e.g., concussion protocol)
  - Fully cleared with monitoring notes
- **Medical Clearance**: Track when medical approval is required
- **Date Tracking**: injury_date, expected_return_date, actual_return_date
- **Scope**: Affects all teams or specific team only

### Academic Status Tracking
- **Status Types**: eligible, ineligible, probation, restricted
- **Academic Metrics**: GPA tracking, required GPA, credits enrolled
- **Availability Restrictions**: Similar granular control as medical
- **Review Periods**: Track academic term and review dates
- **School Information**: School name and academic term

### Key Design Principles
1. **Granular Control**: Separate flags for practices vs games
2. **Team Scope**: Issues can affect all teams or be team-specific
3. **Multiple Concurrent Issues**: Player can have multiple active medical/academic issues
4. **Audit Trail**: Complete history of all status changes
5. **Coach Management**: Coaches can create and update status for their players

## Database Schema

### Tables Created
- `player_medical_status` - Active medical issues and restrictions
- `player_academic_status` - Active academic eligibility issues
- `player_medical_status_history` - Audit trail for medical changes
- `player_academic_status_history` - Audit trail for academic changes

### Views Created
- `v_active_medical_issues` - All current medical problems
- `v_active_academic_issues` - All current academic problems
- `v_player_availability` - Division-level summary of all players
- `v_team_player_availability` - Team-specific availability (respects team scope)

## Usage Examples

### Check Division Roster Availability
```sql
SELECT first_name, last_name, 
       medical_status, academic_status,
       can_practice, can_play_games
FROM v_player_availability
WHERE can_play_games = false;
```

### View Active Medical Issues
```sql
SELECT first_name, last_name, injury_type, severity,
       available_for_practices, available_for_games,
       expected_return_date
FROM v_active_medical_issues;
```

### Team-Specific Availability Check
```sql
SELECT first_name, last_name, roster_status,
       medical_status, academic_status,
       can_practice, can_play_games
FROM v_team_player_availability
WHERE team_id = 'your-team-uuid-here';
```

## Sample Data

Created 4 test cases demonstrating:
1. **Ankle Sprain** (Hassane Abdellaoui)
   - Status: injured, minor severity
   - Can practice: YES, Can play games: NO
   - Expected return: 7 days from injury

2. **Concussion Protocol** (Mustafa Galas)
   - Status: concussion_protocol, moderate severity
   - Can practice: NO, Can play games: NO
   - Medical clearance required
   - Expected return: 10 days with protocol

3. **Recovering from Knee Injury** (Luis De Jesus)
   - Status: recovering, moderate severity
   - Can practice: YES, Can play games: YES
   - Fully cleared, monitoring workload

4. **Academic Probation** (Jemirkel Ornaque)
   - Status: probation, GPA 2.3 (needs 2.5)
   - Can practice: YES, Can play games: NO
   - Review date: 30 days out

## Integration Points

### Backend API (Future)
Will need endpoints for:
- GET `/api/divisions/:divisionId/availability` - Division summary
- GET `/api/teams/:teamId/availability` - Team-specific
- POST `/api/players/:playerId/medical-status` - Create medical issue
- PUT `/api/players/:playerId/medical-status/:id` - Update medical issue
- POST `/api/players/:playerId/academic-status` - Create academic issue
- PUT `/api/players/:playerId/academic-status/:id` - Update academic issue
- DELETE `/api/medical-status/:id/resolve` - Mark medical issue resolved
- DELETE `/api/academic-status/:id/resolve` - Mark academic issue resolved

### Frontend UI (Future)
Division Roster Screen enhancements:
- Show availability icons next to player names
- Filter by: Available for Games, Available for Practice, All Issues
- Click player → view detailed status information
- "Update Status" button → coach can add/edit medical or academic restrictions
- Color coding: Green (available), Yellow (practice only), Red (no activity)

### Permission System
- **Coaches**: Can view and update status for players on their teams
- **Division Managers**: Can view all division players, update any
- **Players/Guardians**: Can view their own status (read-only)

## Next Steps

1. **Backend Implementation**
   - Create AvailabilityController in C++
   - Add CRUD endpoints for medical and academic status
   - Implement permission checks (coach can only update their players)

2. **Frontend Updates**
   - Update DivisionRosterScreen to show availability icons
   - Create PlayerAvailabilityModal for detailed view
   - Create UpdateAvailabilityForm for coaches
   - Add filtering by availability status

3. **Notifications** (Future Phase)
   - Notify coaches when player status changes
   - Alert players when they're cleared to return
   - Remind about upcoming medical clearance deadlines

4. **Reports** (Future Phase)
   - Injury report (all current injuries by team)
   - Academic eligibility report
   - Historical injury data for player safety tracking
   - Return-to-play timeline forecasts

## File Locations
- Schema: `/database/data/02-schema-player-availability.sql`
- Views: `/database/data/03-views-player-availability.sql`
- Sample Data: `/database/data/51-sample-availability-data.sql`
