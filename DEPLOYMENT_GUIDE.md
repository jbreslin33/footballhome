# Football Home - Complete Deployment Guide

## 🚀 Rebuilding from Scratch on a New Server

This guide will help you recreate the entire Football Home Google Maps system on a fresh server.

---

## 📋 Prerequisites & System Requirements

### Operating System
- **Linux** (Ubuntu 20.04+ recommended)
- **macOS** (10.15+ with Homebrew)
- **Windows** (with WSL2 + Docker Desktop)

### Required Software Stack

#### 1. **Docker & Docker Compose**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in

# macOS
brew install docker docker-compose

# Verify installation
docker --version
docker compose --version
```

#### 2. **Node.js & npm**
```bash
# Using NodeSource repository (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18

# Verify installation
node --version  # Should be v18.x.x
npm --version
```

#### 3. **Git**
```bash
# Ubuntu/Debian
sudo apt install git

# macOS
brew install git

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 4. **PostgreSQL Client Tools** (for database management)
```bash
# Ubuntu/Debian
sudo apt install postgresql-client

# macOS
brew install postgresql
```

#### 5. **jq** (for JSON parsing in terminal)
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

---

## 🗃️ Project Setup

### Step 1: Clone Repository
```bash
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
```

### Step 2: Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit the .env file with your specific values
nano .env  # or vim/code
```

**Required Environment Variables:**
```bash
# Database Configuration
POSTGRES_DB=footballhome
POSTGRES_USER=footballhome_user
POSTGRES_PASSWORD=footballhome_pass

# Google Maps API Configuration
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
GEOCODING_RATE_LIMIT=50
GEOCODING_DAILY_LIMIT=1000
GEOCODING_CACHE_TTL=86400

# Application Configuration
NODE_ENV=production  # or development
API_PORT=3001
```

### Step 3: Google Maps API Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing one
3. Enable **Geocoding API**
4. Enable **Maps JavaScript API** (for future frontend)
5. Create API Key:
   - Go to "Credentials" → "Create Credentials" → "API Key"
   - Restrict the key to your domain/IP for security
   - Copy key to `.env` file

---

## 🐳 Database Setup

### Start PostgreSQL Database
```bash
# Start the database containers
docker compose up -d footballhome_db footballhome_pgadmin

# Verify containers are running
docker ps
```

### Database Schema
The database schema is automatically created from `database/init.sql`. It includes:
- 25+ normalized tables
- Venues table with latitude/longitude fields
- Proper indexes and constraints
- UUID primary keys

### Access Database
```bash
# Via Docker
docker exec -it footballhome_db psql -U footballhome_user -d footballhome

# Via pgAdmin (web interface)
# Open: http://localhost:5050
# Email: admin@example.com
# Password: admin123
```

---

## 🖥️ Backend Setup

### Install Dependencies
```bash
cd backend
npm install
```

**Key Dependencies Installed:**
- `express` - Web framework
- `pg` - PostgreSQL client
- `axios` - HTTP client for Google Maps API
- `node-cache` - In-memory caching
- `cors` - Cross-origin resource sharing
- `helmet` - Security headers
- `morgan` - HTTP request logging
- `dotenv` - Environment variable management

### Backend Structure
```
backend/
├── server.js              # Main server file
├── package.json           # Dependencies & scripts
├── services/
│   ├── GeocodingService.js # Google Maps integration
│   └── VenueService.js     # Venue management
└── routes/
    └── venues.js           # API endpoints
```

### Start Backend Server
```bash
# Development mode
npm run dev

# Production mode
npm start

# Or directly
node server.js
```

---

## 🔧 System Services & Architecture

### Docker Services
```yaml
# docker-compose.yml includes:
services:
  footballhome_db:      # PostgreSQL 15-Alpine
  footballhome_pgadmin: # Database admin interface
```

### Backend Services Architecture
```
📡 API Layer (Express.js)
├── 🏟️  Venue Routes (/api/venues)
├── 📊 Statistics (/api/venues/stats)
└── 🔍 Nearby Search (/api/venues/nearby/:lat/:lng)

⚙️ Service Layer
├── 🗺️  GeocodingService (Google Maps API)
│   ├── Rate limiting (50/min, 1000/day)
│   ├── Response caching (24hr TTL)
│   └── Address parsing & validation
└── 🏟️  VenueService (Database operations)
    ├── CRUD operations
    ├── Duplicate detection
    ├── Nearby venue search
    └── Batch geocoding

🗄️ Data Layer (PostgreSQL)
└── 25+ normalized tables with proper relationships
```

---

## 🧪 Testing & Verification

### 1. Health Check
```bash
curl http://localhost:3001/health
```

### 2. Test Google Maps Integration
```bash
# Test geocoding service
node -e "
require('dotenv').config({ path: '../.env' });
const GeocodingService = require('./services/GeocodingService');
const service = new GeocodingService();
service.geocode('1600 Amphitheatre Parkway, Mountain View, CA').then(console.log);
"
```

### 3. Test Venue Creation
```bash
curl -X POST http://localhost:3001/api/venues \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Stadium",
    "venue_type": "stadium",
    "address": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip_code": "12345"
  }'
```

### 4. Test Nearby Venues
```bash
curl "http://localhost:3001/api/venues/nearby/37.4221/-122.0841?radius=10"
```

---

## 🚀 Production Deployment

### Environment Setup
```bash
# Set production environment
export NODE_ENV=production

# Use process manager
npm install -g pm2
pm2 start server.js --name footballhome-api
pm2 startup  # Auto-start on boot
pm2 save
```

### Reverse Proxy (Nginx)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Security Considerations
1. **API Key Security**: Restrict Google Maps API key to your domain
2. **Database**: Use strong passwords, limit connections
3. **CORS**: Configure proper origins in production
4. **Rate Limiting**: Monitor API usage
5. **SSL**: Use HTTPS in production

---

## 📁 Complete File Structure

```
footballhome/
├── .env                    # Environment variables (create from .env.example)
├── .env.example           # Environment template
├── docker-compose.yml     # Container orchestration
├── DEPLOYMENT_GUIDE.md    # This file
├── database/
│   └── init.sql          # Database schema
├── backend/
│   ├── server.js         # Main server
│   ├── package.json      # Node.js dependencies
│   ├── services/
│   │   ├── GeocodingService.js
│   │   └── VenueService.js
│   └── routes/
│       └── venues.js
└── frontend/             # Future frontend files
    ├── index.html
    └── js/
        ├── app.js
        └── api.js
```

---

## 🎯 API Endpoints Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/api/venues` | List venues (paginated) |
| `GET` | `/api/venues/:id` | Get venue by ID |
| `POST` | `/api/venues` | Create venue (with duplicate detection) |
| `POST` | `/api/venues/force` | Force create venue |
| `GET` | `/api/venues/nearby/:lat/:lng` | Find nearby venues |
| `PUT` | `/api/venues/:id/geocode` | Update venue coordinates |
| `POST` | `/api/venues/batch-geocode` | Batch geocode venues |
| `GET` | `/api/venues/stats` | System statistics |

---

## 🔍 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   sudo lsof -i :3001
   kill -9 <PID>
   ```

2. **Database connection failed**
   ```bash
   docker compose logs footballhome_db
   ```

3. **Google Maps API errors**
   - Check API key is valid
   - Verify Geocoding API is enabled
   - Check rate limits and billing

4. **Environment variables not loaded**
   - Ensure `.env` file exists in project root
   - Check file permissions (`chmod 644 .env`)

### Logs & Monitoring
```bash
# Backend logs
pm2 logs footballhome-api

# Database logs
docker compose logs footballhome_db

# System resources
docker stats
```

---

## ✅ Success Verification

After deployment, you should have:
- ✅ PostgreSQL database running with 25+ tables
- ✅ Backend API server responding on port 3001
- ✅ Google Maps geocoding working
- ✅ Venue creation with coordinate storage
- ✅ Nearby venue search functionality
- ✅ API endpoints returning proper JSON

**Test with a real venue:**
```bash
curl -X POST http://localhost:3001/api/venues \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MetLife Stadium",
    "venue_type": "stadium", 
    "address": "1 MetLife Stadium Dr",
    "city": "East Rutherford",
    "state": "NJ",
    "zip_code": "07073"
  }' | jq
```

Should return coordinates: `40.8137, -74.0735` ✅

---

## 🆘 Support

If you encounter issues:
1. Check this deployment guide
2. Review logs for error messages
3. Verify all prerequisites are installed
4. Test each component individually
5. Check environment variables are set correctly

The system is designed to be fully reproducible on any server with the above prerequisites!
