# AI Assistant Context - Football Home Production

## CRITICAL CONTEXT FOR AI ASSISTANT

This is a **DEVELOPMENT/STAGING ENVIRONMENT** for footballhome.org. When the user asks about deployment, domains, or URLs, always assume production context but note this is not user-facing yet.

### Production Environment Facts
- **Domain:** footballhome.org (ALWAYS use this domain, never localhost for production references)
- **Protocol:** HTTPS (production site uses SSL)
- **Environment:** Development/staging system - safe to experiment and rebuild
- **User Works Across Multiple Computers:** Expect context switching between machines

### Current Infrastructure Setup
- **Container System:** Docker Compose (NOT Podman - switched away from Podman)
- **Database:** PostgreSQL 15-Alpine in Docker container
- **Admin Tool:** pgAdmin4 in Docker container
- **Project Location:** `/home/jbreslin/sandbox/footballhome/`

### Database Configuration
```yaml
Container: footballhome_db
Port: 5432
Database: footballhome
Username: footballhome_user
Password: footballhome_pass
Schema: Normalized with 25 tables
Initialization: Always rebuild from database/init.sql (purge existing)
```

### pgAdmin Configuration
```yaml
Container: footballhome_pgladmin
Port: 5050 (http://localhost:5050)
Email: admin@example.com
Password: admin123
```

### Architecture Overview
- **Backend:** Node.js/Express API in `/backend/express/`
- **Frontend:** React TypeScript app in `/frontend/`
- **Database:** PostgreSQL with normalized schema in `/database/`
- **SSL:** Certificates in `/ssl/` directory
- **Containers:** Managed via `docker-compose.yml`

### Key Files to Check
- `docker-compose.yml` - Container orchestration
- `database/normalized_schema.sql` - Complete database schema
- `database/init.sql` - Database initialization
- `PRODUCTION_NOTES.md` - User reference guide
- `setup.sh` or `build.sh` - **REQUIRED:** Universal setup script for Ubuntu machines

### Setup Requirements
- **Universal Setup Script:** Must always have `setup.sh` or `build.sh` that:
  - Installs all dependencies on fresh Ubuntu machine
  - Sets up Docker/Docker Compose if needed
  - Builds and starts entire application stack
  - Handles SSL certificates and configuration
  - Should work on any clean Ubuntu installation
  - **ESSENTIAL:** Must be able to rebuild entire site from scratch (clean slate)
  - **DATABASE:** Always purge existing DB and rebuild from `database/init.sql`

### Common Scenarios
1. **"Setup on new machine"** = `./setup.sh` or `./build.sh`
2. **"Rebuild from scratch"** = `./setup.sh --clean` (purges DB, rebuilds from init.sql)
3. **"Rebuild the app"** = `docker compose up --build -d`
4. **"Get database running"** = `docker compose up db pgadmin -d`
5. **"Check status"** = `docker compose ps`
6. **Database access** = pgAdmin at localhost:5050 or direct PostgreSQL connection
7. **"Fresh database"** = Remove DB volume, restart containers (auto-loads init.sql)

### Important Behavioral Notes
- Always suggest footballhome.org for production URLs
- This is development/staging - safe to rebuild, restart, and experiment
- User switches computers frequently - don't assume previous context
- Docker is the container system (Podman was removed)
- Database schema is normalized (not the old denormalized version)
- **MUST HAVE:** Universal setup script that builds entire site on any Ubuntu machine
- **CRITICAL:** Must support complete rebuild from scratch (clean slate capability)
- **NO BACKUPS NEEDED:** Development stage - always rebuild from source, never preserve data

### Quick Status Check Commands
```bash
cd /home/jbreslin/sandbox/footballhome
docker compose ps                    # Check running containers
docker compose logs                  # Check logs
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "\dt"  # List tables

# Fresh database rebuild commands:
docker compose down -v              # Stop and remove volumes (purges DB)
docker compose up db pgadmin -d     # Restart with fresh DB (auto-loads init.sql)
```

### Red Flags That Indicate Context Loss
- User asks about "getting started" = They switched computers, provide full status
- References to Podman = Correct to Docker
- References to localhost in production context = Suggest footballhome.org
- Container not found errors = Need to start services

---
**Purpose:** This file provides essential context for AI assistants to immediately understand the Football Home production environment setup and user workflow patterns.

**Last Updated:** November 1, 2025