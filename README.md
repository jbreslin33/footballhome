# Football Home ⚽

A comprehensive team management system for football/soccer teams, built with React, Node.js, and PostgreSQL.

## 🚀 Complete Setup from Scratch

Football Home is designed to be completely rebuildable from scratch. Follow these steps:

### Prerequisites
```bash
# Install Docker and Docker Compose (Ubuntu/Debian)
sudo apt update
sudo apt install docker.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

### One-Command Setup
```bash
# Clone and setup everything
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome
./setup-complete.sh
```

### Manual Setup
If you prefer manual control:

```bash
# 1. Create environment file
cp .env.example .env
# Edit .env with your settings

# 2. Build and start services
docker compose down --volumes  # Clean slate
docker compose up -d --build   # Build and start

# 3. Add to your hosts file (optional)
echo '127.0.0.1 footballhome.org' | sudo tee -a /etc/hosts
```

## 🏈 Features

### Core System
- **Multi-League Management**: APSL, CASA, TCWL with promotion/relegation
- **User Authentication**: JWT-based login/register with role management
- **Event Management**: Create and manage practices, games, meetings
- **RSVP System**: Players can respond to events, capacity management
- **Team Organization**: Role-based permissions (players, coaches, admins)

### League Structure
- **6 APSL Conferences**: Delaware River, Metropolitan NY/NJ, Southeast, Mid-Atlantic, Northeast, South Atlantic
- **CASA Divisions**: Liga 1, Liga 2, Over 30 with tier-based hierarchy
- **TCWL Structure**: Division 1, 2, 3 for women's leagues
- **Inter-league Promotion**: Geographic routing and complex relationships

## 🌐 Access Points

After running setup:

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://footballhome.org:3000 | Main application |
| **Backend API** | http://footballhome.org:3001/api | REST API |
| **pgAdmin** | http://footballhome.org:5050 | Database admin |
| **Database** | localhost:5432 | Direct DB access |

### Default Credentials
- **pgAdmin**: admin@footballhome.org / admin123
- **Database**: footballhome_user / footballhome_pass

## 🏗️ Architecture

### Tech Stack
- **Frontend**: React 18 + TypeScript + React Router
- **Backend**: Node.js + Express + JWT Authentication
- **Database**: PostgreSQL 15 with comprehensive schema
- **Infrastructure**: Docker + Docker Compose
- **Security**: Rate limiting, input validation, CORS

### Project Structure
```
footballhome/
├── backend/              # Node.js API server
│   ├── middleware/       # Auth, rate limiting
│   ├── routes/          # API endpoints
│   └── services/        # Business logic
├── frontend/            # React application
│   ├── src/components/  # React components
│   └── src/contexts/    # Auth context
├── database/            # SQL schema and data
├── ssl/                # SSL certificates
└── scripts/            # Utility scripts
```

## 🔧 Development

### Backend Development
```bash
cd backend
npm install
npm run dev  # Development with nodemon
```

### Frontend Development
```bash
cd frontend
npm install
npm start   # Development server
```

### Database Management
```bash
# Connect to database
docker exec -it footballhome_db psql -U footballhome_user -d footballhome

# View tables
\dt

# Run migrations
docker exec footballhome_db psql -U footballhome_user -d footballhome -f /docker-entrypoint-initdb.d/01-init.sql
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user

### Events
- `GET /api/events/team/:teamId` - Get team events
- `POST /api/events` - Create event (coaches only)
- `PUT /api/events/:eventId` - Update event
- `DELETE /api/events/:eventId` - Delete event

### RSVPs
- `POST /api/rsvps` - Create/update RSVP
- `GET /api/rsvps/my-rsvps` - Get user's RSVPs
- `GET /api/rsvps/event/:eventId/attendees` - Get event attendees

## 🔄 Rebuilding from Scratch

The entire system can be rebuilt at any time:

```bash
# Complete cleanup and rebuild
docker compose down --volumes --rmi all
docker system prune -f
./setup-complete.sh
```

This will:
1. Remove all containers and volumes
2. Delete all built images
3. Rebuild everything from source
4. Initialize fresh database
5. Start all services

## 🚢 Production Deployment

### Environment Variables
Key variables for production in `.env`:
```bash
# Security
JWT_SECRET=your-super-secret-production-key
NODE_ENV=production

# Database
POSTGRES_PASSWORD=strong-production-password

# Frontend
REACT_APP_API_URL=https://api.footballhome.org

# SSL (if using)
SSL_CERT_PATH=./ssl/footballhome.org.crt
SSL_KEY_PATH=./ssl/footballhome.org.key
```

### SSL Setup
```bash
# Place SSL certificates in ssl/ directory
./scripts/setup-ssl.sh
```

## 🧪 Testing

### Manual Testing
1. Register a new user at http://footballhome.org:3000/register
2. Login and view dashboard
3. Create events (if you have coach/admin role)
4. Test RSVP functionality

### Health Checks
```bash
# Check all services
curl http://footballhome.org:3000/health  # Frontend
curl http://footballhome.org:3001/health  # Backend
docker compose ps                          # All services
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature-name`
3. Make changes and test with `./setup-complete.sh`
4. Commit: `git commit -m "Add feature"`
5. Push: `git push origin feature-name`
6. Create Pull Request

## 📝 License

MIT License - see LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues

**"Docker not found"**
```bash
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Logout and login again
```

**"Port already in use"**
```bash
docker compose down
sudo lsof -i :3000 :3001 :5432  # Find conflicting processes
```

**"Database connection failed"**
```bash
docker compose logs db           # Check database logs
docker compose restart db       # Restart database
```

**"Frontend not loading"**
```bash
# Add to /etc/hosts if using footballhome.org locally
echo '127.0.0.1 footballhome.org' | sudo tee -a /etc/hosts
```

### Getting Help
- Check service logs: `docker compose logs [service-name]`
- View all services: `docker compose ps`
- Restart specific service: `docker compose restart [service-name]`
- Complete reset: `./setup-complete.sh`