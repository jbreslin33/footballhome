# Football Home - Soccer Team Management PWA

A Progressive Web Application for soccer coaches to create practice/match events and players to RSVP.

## Architecture

- **Frontend**: Vanilla JavaScript PWA (mobile-first, offline-capable)
- **Backend**: Node.js Express API + PostgreSQL
- **Deployment**: Podman/Docker containers
- **Domain**: footballhome.org (HTTP ready, HTTPS optional)

## Quick Start

### Prerequisites
- Podman or Docker with docker-compose
- Git

### Quick Setup (Automated)

1. **Clone and setup everything:**
```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
./setup.sh
```

The setup script will:
- Install Podman or Docker if needed
- Build and start all containers
- Verify everything works
- Show you access URLs

### Manual Setup

1. **Clone the repository:**
```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
```

2. **Start the complete stack:**
```bash
# Quick start (if Podman/Docker already installed)
./start.sh

# OR manually with Podman
podman-compose up -d --build

# OR manually with Docker
docker-compose up -d --build
```

3. **Access the application:**
- **Local development**: http://localhost
- **API directly**: http://localhost:3000
- **Database**: localhost:5432 (user: footballapp, db: footballhome)

The application will be fully functional locally with:
- Sample team data (Thunder FC)
- Sample events and RSVPs
- Full PWA features (works offline after first load)

### Project Structure

```
footballhome/
├── frontend/              # Vanilla JS PWA
│   ├── js/               # JavaScript modules (app.js, api.js)
│   ├── css/              # Stylesheets (main.css, components.css)
│   ├── index.html        # Main PWA interface
│   ├── manifest.json     # PWA manifest
│   ├── sw.js            # Service Worker
│   └── nginx-simple.conf # Nginx proxy config
├── backend/node/         # Node.js Express API
│   ├── server.js        # API server with all endpoints
│   ├── package.json     # Dependencies
│   └── Dockerfile       # Container build
├── database/            # PostgreSQL setup
│   └── init.sql        # Schema + sample data
├── docker-compose.yml   # Container orchestration
└── scripts/            # Setup utilities
```

### What You Get Locally

When you run `podman-compose up -d` (or `docker-compose up -d`), you get:

**3 Containers:**
- `footballhome_web` - Nginx serving the PWA (port 80)
- `footballhome_api` - Node.js API server (port 3000) 
- `footballhome_db` - PostgreSQL database (port 5432)

**Sample Data Included:**
- **Team**: Thunder FC
- **Users**: Coach Smith + 2 players (John Player, Jane Athlete)
- **Events**: 3 upcoming events (practice, match, meeting)
- **RSVPs**: Sample responses to events

**API Endpoints Available:**
- `GET /api/health` - Health check
- `GET /api/teams/{id}/events` - Team events
- `POST /api/events` - Create event
- `POST /api/events/{id}/rsvp` - RSVP to event

### Development Workflow

The API client automatically detects localhost and uses the correct endpoints:
- **Production**: `http://footballhome.org/api/...`
- **Local**: `http://localhost:3000/api/...`

### Troubleshooting

**If containers won't start:**
```bash
# Check what's running
podman ps -a
# OR
docker ps -a

# View logs
podman-compose logs
# OR
docker-compose logs

# Restart everything
./start.sh
```

**If localhost doesn't load:**
- Wait 30 seconds after starting (database needs to initialize)
- Check if port 80 is already in use: `sudo netstat -tulpn | grep :80`
- Try accessing API directly: `curl http://localhost:3000/api/health`

**Reset everything:**
```bash
# Stop and remove all containers/volumes
podman-compose down -v
# OR
docker-compose down -v

# Restart fresh
./start.sh
```

## Core Features

- Coach creates training/match events
- Players RSVP to events
- Mobile-first responsive design
- Offline capability (PWA)
- Push notifications for new events

## Development Workflow

1. Make changes to frontend/backend
2. Rebuild containers: `podman-compose build`
3. Test locally, then externally via footballhome.org
4. Check logs: `podman logs footballhome_api`