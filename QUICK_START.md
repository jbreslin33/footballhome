# Football Home - Quick Setup Guide

## 🚀 Local Development Setup

### Prerequisites
- **Docker** with docker-compose
- **Git**

### Quick Start
```bash
# 1. Clone the repository
git clone https://github.com/jbreslin33/footballhome.git
cd footballhome

# 2. Start all services
docker compose up -d --build

# 3. Wait for services to start (about 30 seconds)
docker compose ps

# 4. Access the application
# - Web App: http://localhost:8080
# - API: http://localhost:3000
# - Database: localhost:5432
# - pgAdmin: http://localhost:5050
```

## 🎯 Common Commands

```bash
# View logs
docker compose logs -f

# Stop services
docker compose down

# Rebuild after changes
docker compose up -d --build

# Reset database (warning: deletes all data)
docker compose down -v
docker compose up -d --build
```

## 🔗 Service URLs (Local)
- **Main App**: http://localhost:8080
- **API Health**: http://localhost:3000/api/health
- **pgAdmin**: http://localhost:5050
  - Email: admin@footballhome.org
  - Password: admin123

## 📊 Database Connection (DBeaver/pgAdmin)
- **Host**: localhost
- **Port**: 5432
- **Database**: footballhome
- **Username**: footballapp
- **Password**: footballpass123

## 🎭 Demo Accounts
See `DEMO_ACCOUNTS.md` for test login credentials.