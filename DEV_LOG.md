# Football Home - Development Session Log

*A comprehensive log of development decisions, architecture choices, tools used, and workflow patterns.*

---

## Project Overview
**Repository**: footballhome  
**Owner**: jbreslin33  
**Environment**: Production server (192.168.1.90) used for development  
**Start Date**: November 1, 2025  

---

## Architecture Decisions

### Database Foundation
- **Database**: PostgreSQL 15 (Alpine Docker image)
- **Normalization**: 4NF compliant schema with 25 tables
- **Connection**: `postgresql://footballhome_user:footballhome_pass@localhost:5432/footballhome`
- **Port Exposure**: 5432 opened on production server for development access

### Development Environment
- **Containerization**: Docker Compose for local development
- **Database Management**: PostgreSQL + pgAdmin (when working)
- **Development Scripts**: Custom `dev.sh` for Docker management

---

## Session History

### Session 1: Clean Slate Rebuild (November 1, 2025)
**Context**: Moved from debugging existing authentication issues to complete rebuild approach

**Major Decisions**:
- ✅ **Repository Cleanup**: Deleted all existing files except database/ folder
- ✅ **Database First Approach**: Build normalized schema before backend/frontend
- ✅ **Docker Development**: Use containers for consistent development environment

**Tools & Technologies**:
- PostgreSQL 15 Alpine Docker image
- Docker Compose for orchestration
- Custom `dev.sh` script for environment management
- pgAdmin 4 for database visualization (with email configuration issues)

**Database Schema Enhancements**:
- Added notification preferences system
- Implemented recurring event patterns
- Enhanced session management
- Added audit logging capabilities
- Normalized to 4NF compliance (25 tables total)

**Key Files Created/Modified**:
```
/database/init.sql          # Complete normalized schema (563 lines)
/docker-compose.yml         # PostgreSQL + pgAdmin services
/.env                       # Environment configuration
/dev.sh                     # Development management script
/.gitignore                 # Clean exclusions
/README.md                  # Project documentation
```

**Sample Data Loaded**:
- 5 sports (soccer, basketball, baseball, hockey, volleyball)
- 2 soccer teams (Thunder FC Demo, Lightning FC Demo)
- Demo users and venues
- Complete relationship data

### Session 2: Database Verification & Visual Access (November 2, 2025)
**Context**: Verified database is live and planning visual access for schema review

**Status Verification**:
- ✅ PostgreSQL container: Up and healthy
- ✅ Database connection: Working perfectly
- ✅ Schema: All 25 tables created successfully
- ✅ Sample data: Loaded and verified
- ❓ pgAdmin: Restarting due to email validation issues

**Network Configuration**:
- Production server port 5432 opened for external database access
- Enables direct connection from desktop database tools

**Focus Shift**: Google Maps Integration for Venue Management
- Venue table structure confirmed with latitude/longitude fields
- Sample venues exist but missing coordinate data
- Need to enhance venues with proper Google Maps integration

---

## Tools & Workflow Patterns

### Development Script Usage
```bash
./dev.sh start    # Start Docker environment
./dev.sh stop     # Stop Docker environment  
./dev.sh status   # Check container health
./dev.sh connect  # Connect to database CLI
```

### Database Connection Testing
```bash
# Verify tables
docker compose exec -T db psql -U footballhome_user -d footballhome -c "\dt"

# Check sample data
docker compose exec -T db psql -U footballhome_user -d footballhome -c "SELECT s.name as sport, COUNT(t.id) as teams FROM sports s LEFT JOIN teams t ON s.id = t.sport_id GROUP BY s.id, s.name ORDER BY s.name;"
```

### Docker Management
- Use `docker compose` (v2) commands instead of `docker-compose`
- Health checks implemented for PostgreSQL container
- Volume persistence for database data

---

## Technology Stack

### Current Foundation
- **Database**: PostgreSQL 15
- **Containerization**: Docker Compose
- **Development Environment**: Linux (bash shell)

### Planned Stack
- **Backend**: Express.js + TypeScript
- **Frontend**: React + TypeScript + Material-UI
- **Authentication**: JWT-based system
- **API Architecture**: RESTful with proper error handling

---

## Database Schema Summary

### Core Tables (25 total)
- **Users & Auth**: users, user_sessions, magic_tokens
- **Sports & Teams**: sports, teams, team_members, team_member_roles
- **Events & Matches**: events, matches, event_types, event_recurrences
- **Venues & Locations**: venues, venue_types
- **Notifications**: notifications, notification_preferences, notification_log
- **RSVP System**: rsvps, rsvp_statuses
- **Messaging**: messages
- **Audit & Tracking**: Various tracking and status tables

### Key Relationships
- Many-to-many: users ↔ teams (via team_members)
- One-to-many: teams → events, events → matches
- Complex: notification system with preferences and logging

---

## Notes & Observations

### Workflow Patterns
1. **Database First**: Establish normalized schema before application layers
2. **Docker Consistency**: Use containers for predictable development environment
3. **Clean Architecture**: Separate concerns with clear boundaries
4. **Documentation**: Maintain comprehensive logs and README files

### Performance Considerations
- Database port exposed on production server (development only)
- Health checks ensure container reliability
- Sample data provides realistic testing scenarios

### Security Notes
- JWT secrets configured for development (need production rotation)
- Database credentials in .env file (excluded from git)
- Magic token system for passwordless authentication

---

## Future Sessions

### Immediate Next Steps
- [ ] Resolve database visual access (pgAdmin or desktop tools)
- [ ] Review schema relationships for additional normalization opportunities
- [ ] Begin Express.js + TypeScript backend development

### Backend Development Plan
- [ ] Set up TypeScript + Express.js project structure
- [ ] Implement database connection layer
- [ ] Build authentication middleware
- [ ] Create RESTful API endpoints
- [ ] Add proper error handling and validation

### Frontend Development Plan
- [ ] Set up React + TypeScript project
- [ ] Implement Material-UI design system
- [ ] Build authentication flow
- [ ] Create responsive layouts
- [ ] Add state management (Redux/Zustand)

---

*This log will be updated after each development session to maintain project continuity and decision tracking.*