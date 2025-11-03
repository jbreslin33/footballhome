# Football Home Production Notes

## 🚨 PRODUCTION ENVIRONMENT REMINDERS

### Domain & Environment
- **Production Domain:** `footballhome.org`
- **Always use HTTPS:** `https://footballhome.org`
- **This is a LIVE PRODUCTION site - be careful with changes!**

### Current Database Setup (Docker)
- **Container Runtime:** Docker (NOT Podman)
- **Database:** PostgreSQL 15-Alpine
- **Container Name:** `footballhome_db`
- **Port:** 5432
- **Database Name:** `footballhome`
- **Username:** `footballhome_user`
- **Password:** `footballhome_pass`

### Database Access Options

#### Option 1: Containerized pgAdmin (Recommended)
- **URL:** `http://localhost:5050`
- **Email:** `admin@example.com`
- **Password:** `admin123`
- **Status:** Already configured and running

#### Option 2: Direct Database Connection
- **Host:** `localhost` (or `footballhome.org` for remote access)
- **Port:** `5432`
- **Database:** `footballhome`
- **Username:** `footballhome_user`
- **Password:** `footballhome_pass`

### Quick Commands for Computer Switching

#### Check Container Status
```bash
cd /home/jbreslin/sandbox/footballhome
docker compose ps
```

#### Start Database & pgAdmin
```bash
cd /home/jbreslin/sandbox/footballhome
docker compose up db pgadmin -d
```

#### View Database Tables
```bash
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "\dt"
```

#### Stop All Services
```bash
cd /home/jbreslin/sandbox/footballhome
docker compose down
```

### Database Schema
- **Type:** Normalized schema with 25 tables
- **Key Tables:** users, teams, events, matches, practices, rsvps, roles, permissions
- **Schema Files:** 
  - `database/normalized_schema.sql`
  - `database/init.sql` (auto-loaded on container start)

### SSL Configuration
- **Certificates Location:** `ssl/`
- **Key File:** `ssl/footballhome.org.key`
- **Cert File:** `ssl/footballhome.org.crt`
- **Setup Script:** `scripts/setup-ssl.sh`

### Project Structure
```
footballhome/
├── backend/express/          # Node.js/Express API
├── frontend/                 # React TypeScript app
├── database/                 # PostgreSQL schemas and migrations
├── ssl/                      # SSL certificates
├── scripts/                  # Setup and utility scripts
└── docker-compose.yml        # Container orchestration
```

### Important Files
- `docker-compose.yml` - Container configuration
- `database/init.sql` - Database initialization
- `database/normalized_schema.sql` - Complete schema
- `SSL_SETUP.md` - SSL configuration guide
- `DEMO_ACCOUNTS.md` - Test account information

### Security Reminders
- Always use SSL/HTTPS in production
- Keep certificates up to date
- Regular database backups
- Monitor container logs for issues

### Troubleshooting

#### If containers won't start:
1. Check port conflicts: `sudo netstat -tlnp | grep :5432`
2. Clean up: `docker compose down && docker system prune`
3. Rebuild: `docker compose up --build -d`

#### If pgAdmin won't start:
- Check email format in docker-compose.yml (must be valid email)
- Remove container: `docker compose rm -f pgadmin`
- Restart: `docker compose up pgadmin -d`

---

**Last Updated:** November 1, 2025  
**Environment:** Production (footballhome.org)  
**Container Runtime:** Docker Compose