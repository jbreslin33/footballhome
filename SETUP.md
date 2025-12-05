# Football Home - Setup Guide

Complete setup guide for deploying Football Home on a new server.

## Prerequisites

- Ubuntu/Debian Linux (or similar)
- Root or sudo access
- Internet connection

## Quick Setup (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/jbreslin33/footballhome/main/setup.sh | bash
```

## Manual Setup

### 1. Install Docker & Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose (if not included)
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### 2. Install Node.js (for GroupMe scraper)

```bash
# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 3. Clone Repository

```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
```

### 4. Install Node Dependencies

```bash
npm install
```

### 5. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env and add your GroupMe token (optional)
nano .env
```

### 6. Build and Start

```bash
# Build and start all containers
./dev.sh

# Or with test data
./dev.sh --test-data

# Or with APSL data
./dev.sh --apsl --test-data
```

## What Gets Installed

### System-Level (via setup.sh)
- Docker Engine
- Docker Compose
- Node.js 20.x
- npm
- Git

### Node Packages (via npm install)
- dotenv (for environment configuration)

### Docker Containers (via dev.sh)
- PostgreSQL 15 (with pg_cron)
- C++ Backend (libpqxx)
- Nginx Frontend (vanilla JavaScript)
- pgAdmin (database admin UI)

## Optional: GroupMe Integration

### 1. Get GroupMe Access Token

1. Go to https://dev.groupme.com/
2. Log in with your GroupMe account
3. Click "Access Token"
4. Copy the token

### 2. Add to .env

```bash
echo "GROUPME_ACCESS_TOKEN=your_token_here" >> .env
```

### 3. Test GroupMe Scraper

```bash
# List all groups
npm run groupme:list

# Fetch RSVPs from a specific group
node scripts/groupme-scraper.js rsvp <GROUP_ID>

# List events
node scripts/groupme-scraper.js events <GROUP_ID>
```

## Verification

### Check Docker Containers

```bash
docker ps
```

You should see:
- `footballhome_db` (PostgreSQL)
- `footballhome_simple_backend` (C++ API)
- `footballhome_frontend` (Nginx)
- `footballhome_pgadmin` (pgAdmin)

### Access Services

- **Frontend:** http://localhost:8080
- **Backend API:** http://localhost:3001
- **pgAdmin:** http://localhost:5050
  - Email: `admin@example.com`
  - Password: `admin123`

### Test API

```bash
curl http://localhost:3001/health
# Should return: {"status":"ok"}
```

## Troubleshooting

### Docker permission denied

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Port already in use

```bash
# Check what's using the port
sudo lsof -i :8080

# Kill the process or change ports in docker-compose.yml
```

### Database not initializing

```bash
# Check logs
docker logs footballhome_db

# Rebuild from scratch
docker compose down -v
./dev.sh
```

### GroupMe scraper not working

```bash
# Check if dotenv is installed
npm list dotenv

# Reinstall if needed
npm install dotenv

# Verify .env file exists and has token
cat .env | grep GROUPME_ACCESS_TOKEN
```

## Updating

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker compose down
docker compose up -d --build

# Update node packages if needed
npm install
```

## Production Deployment

For production:

1. **Change default passwords** in `docker-compose.yml`
2. **Use proper SSL/TLS** (setup nginx reverse proxy)
3. **Set environment to production** in `.env`
4. **Enable firewall** (ufw or iptables)
5. **Setup automated backups** for database
6. **Use docker compose** (not dev.sh) for production

## Backup & Restore

### Backup Database

```bash
docker exec footballhome_db pg_dump -U footballhome_user footballhome > backup.sql
```

### Restore Database

```bash
cat backup.sql | docker exec -i footballhome_db psql -U footballhome_user footballhome
```

## Support

For issues or questions:
- Check `PROGRESS_NOTE.md` for recent changes
- Review Docker logs: `docker logs <container_name>`
- Check backend logs: `docker logs footballhome_simple_backend`
