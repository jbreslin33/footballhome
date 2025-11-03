# 🚀 Football Home - Complete Deployment Guide

## 100% Reproducible Clean Rebuild

This guide ensures you can rebuild Football Home from scratch on any new server with complete data consistency.

## ✅ **REPRODUCTION GUARANTEE**

Your Football Home system is now **fully reproducible**:
- ✅ All migrations integrated into single init schema
- ✅ Migration tracking system for future changes  
- ✅ Google Places integration included
- ✅ All dependencies documented
- ✅ Automated setup scripts
- ✅ Docker containerization

---

## �� **Quick Start (New Server)**

### 1. Clone and Setup
```bash
# Clone the repository
git clone <your-repo-url> footballhome
cd footballhome

# Run automated setup (installs everything)
chmod +x setup.sh
./setup.sh
```

### 2. Configure Environment
```bash
# Edit your environment variables
cp .env.example .env
nano .env
```

**Required Variables:**
```bash
# Google Maps API Key (REQUIRED)
GOOGLE_MAPS_API_KEY=your_actual_api_key_here

# Database (already configured for Docker)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=footballhome
DB_USER=footballhome_user
DB_PASSWORD=footballhome_pass

# API Configuration
API_PORT=3001
NODE_ENV=development
```

### 3. Start Services
```bash
# Start database and pgAdmin
docker compose up -d

# Start backend API
cd backend
node server.js
```

### 4. Verify Setup
```bash
# Check database
curl http://localhost:3001/health

# Check venues
curl http://localhost:3001/api/venues/stats
```

---

## 📋 **Manual Setup (Step by Step)**

### Prerequisites Check
```bash
# Required software
docker --version          # Docker 20.x+
node --version            # Node.js 18.x+
git --version             # Git 2.x+
psql --version            # PostgreSQL client 15.x+
```

### 1. System Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin nodejs npm git postgresql-client jq curl
sudo usermod -aG docker $USER
# Log out and back in for Docker permissions
```

**macOS:**
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install docker docker-compose node@18 git postgresql jq curl
```

### 2. Project Setup
```bash
# Create project directory
mkdir -p ~/footballhome
cd ~/footballhome

# Clone repository
git clone <your-repo-url> .

# Copy environment
cp .env.example .env
```

### 3. Database Setup
```bash
# Start database container
docker compose up -d db pgadmin

# Wait for database to be ready
sleep 15

# Verify database
docker exec footballhome_db pg_isready -U footballhome_user
```

### 4. Backend Setup
```bash
# Install Node.js dependencies
cd backend
npm install

# Verify installation
npm list
```

### 5. Test the System
```bash
# Start backend (in background for testing)
node server.js &
SERVER_PID=$!

# Test health endpoint
curl http://localhost:3001/health

# Test venues endpoint  
curl http://localhost:3001/api/venues/stats

# Stop test server
kill $SERVER_PID
```

---

## 🗄️ **Database Management**

### Database Schema
- **Complete Schema:** `database/init.sql` (production-ready baseline)
- **Migration System:** `database/migrate.sh` for future changes
- **Tracking:** `schema_migrations` table tracks applied changes
- **Archived Migrations:** Old migrations moved to `database/archived_migrations/`

### Run Migrations (Future Changes)
```bash
# Apply any new migrations
cd database
./migrate.sh
```

### Database Access
```bash
# Via Docker
docker exec -it footballhome_db psql -U footballhome_user -d footballhome

# Via pgAdmin
# http://localhost:5050
# Email: admin@example.com
# Password: admin123
```

### Backup & Restore
```bash
# Create backup
docker exec footballhome_db pg_dump -U footballhome_user footballhome > backup.sql

# Restore backup
docker exec -i footballhome_db psql -U footballhome_user -d footballhome < backup.sql
```

---

## 🌐 **Google Maps API Setup**

### 1. Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API

### 2. Create API Key
1. Go to "Credentials" → "Create Credentials" → "API Key"
2. Copy the API key
3. Restrict the key (recommended):
   - Application restrictions: HTTP referrers
   - API restrictions: Select the 3 APIs above

### 3. Configure Application
```bash
# Add to .env file
GOOGLE_MAPS_API_KEY=AIza...your_key_here
```

### 4. Test Google Integration
```bash
# Start the API server first
cd backend && node server.js &

# Wait a moment, then populate venues
sleep 3
./scripts/populate-google-venues.sh

# Or manually import from specific location
curl -X POST "http://localhost:3001/api/venues/import/google-places" \
  -H "Content-Type: application/json" \
  -d '{"location": "Denver, CO", "radius": 10000}'
```

---

## 🔧 **Development Workflow**

### Daily Development
```bash
# Start development environment
docker compose up -d          # Database & pgAdmin

# In separate terminal
cd backend && node server.js  # API server
```

### Making Database Changes
```bash
# Create new migration file
touch database/migrations/004_new_feature.sql

# Write your SQL changes in the file
# Then apply migrations
cd database && ./migrate.sh
```

### Testing Changes
```bash
# Run health check
curl http://localhost:3001/health

# Test specific endpoint
curl http://localhost:3001/api/venues/stats

# Check database
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "SELECT COUNT(*) FROM venues;"
```

---

## 🌍 **Production Deployment**

### Server Requirements
- **OS:** Ubuntu 20.04+ or RHEL 8+
- **RAM:** 2GB minimum, 4GB recommended
- **Storage:** 20GB minimum
- **Network:** Ports 80, 443, 5432, 3001

### Production Setup
```bash
# On production server
git clone <your-repo-url> /opt/footballhome
cd /opt/footballhome

# Set production environment
cp .env.example .env
nano .env  # Set NODE_ENV=production

# Install and start
./setup.sh
docker compose up -d
```

### SSL Configuration
```bash
# Generate SSL certificates
./scripts/setup-ssl.sh

# Update nginx configuration for HTTPS
# Edit nginx/nginx.conf for your domain
```

### Service Management
```bash
# Create systemd service for auto-start
sudo systemctl enable docker
sudo systemctl start docker

# Use Docker restart policies
docker compose up -d --restart=unless-stopped
```

---

## 🔍 **Troubleshooting**

### Database Issues
```bash
# Container won't start
docker compose logs db

# Permission errors
sudo chown -R 999:999 database/  # PostgreSQL UID

# Port conflicts
sudo netstat -tlnp | grep :5432
```

### API Issues  
```bash
# Check logs
cd backend && node server.js

# Verify dependencies
npm install && npm audit

# Test database connection
docker exec footballhome_db pg_isready -U footballhome_user
```

### Google Maps Issues
```bash
# Verify API key
echo $GOOGLE_MAPS_API_KEY

# Test geocoding
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Denver&key=$GOOGLE_MAPS_API_KEY"

# Check API quotas in Google Cloud Console
```

---

## 🎯 **Verification Checklist**

After deployment, verify these components:

**✅ Database**
- [ ] PostgreSQL container running
- [ ] Database accessible via pgAdmin
- [ ] All tables created (25+ tables)
- [ ] Sample data loaded
- [ ] Migrations tracking works

**✅ Backend API**
- [ ] Node.js server starts without errors
- [ ] Health endpoint responds: `curl http://localhost:3001/health`
- [ ] Venues endpoint works: `curl http://localhost:3001/api/venues/stats`
- [ ] Database connections successful

**✅ Google Integration**
- [ ] API key configured in .env
- [ ] Geocoding works
- [ ] Places import successful
- [ ] Venue data includes Google ratings

**✅ Docker Services**
- [ ] Database container: `footballhome_db`
- [ ] pgAdmin container: `footballhome_pgadmin`
- [ ] Containers auto-restart
- [ ] Data persists across restarts

---

## 📊 **Current System Status**

### Database Schema
- **Tables:** 25+ normalized tables (4NF compliant)
- **Indexes:** Optimized for performance
- **Constraints:** Full referential integrity
- **Migrations:** Tracking system implemented

### API Endpoints
- **Health Check:** `GET /health`
- **Venues:** Full CRUD + Google integration
- **Statistics:** `GET /api/venues/stats`
- **Import:** `POST /api/venues/import/google-places`

### Google Places Integration
- **Geocoding Service:** Rate limiting, caching
- **Places Search:** Import venues by location
- **Data Enrichment:** Ratings, reviews, hours
- **Field Alignment:** Database matches Google standards

---

## 🔗 **Useful Links**

- **pgAdmin:** http://localhost:5050
- **API Health:** http://localhost:3001/health
- **API Docs:** http://localhost:3001/api/venues/stats
- **Google Cloud Console:** https://console.cloud.google.com/

---

## 🎯 **Google Venue Data Strategy**

### Fresh Deployments
- **Base Schema:** Includes 3 sample venues (Thunder FC facilities)
- **Google Population:** Optional - run `./scripts/populate-google-venues.sh` after API startup
- **On-Demand Import:** Use API endpoints to import venues from specific locations

### Data Persistence Strategy
1. **Development:** Populate venues as needed during development
2. **Staging:** Use script to populate realistic test data  
3. **Production:** Import venues specific to your geographic area

### Commands for Venue Population
```bash
# Populate from multiple Colorado locations (example)
./scripts/populate-google-venues.sh

# Import specific location manually
curl -X POST "http://localhost:3001/api/venues/import/google-places" \
  -H "Content-Type: application/json" \
  -d '{"location": "Your City, State", "radius": 15000}'
```

---

## 📝 **Notes**

- This system is designed for **clean rebuilds** - no hacky solutions
- All database changes go through the migration system  
- Google Places data is populated on-demand, not during schema initialization
- Docker ensures consistency across environments
- The `setup.sh` script handles all dependencies
- Previous migrations are archived in `database/archived_migrations/`

**Last Updated:** November 3, 2025  
**Version:** 2.1 (Consolidated Schema + Google Venue Strategy)  
**Deployment Status:** ✅ Production Ready
