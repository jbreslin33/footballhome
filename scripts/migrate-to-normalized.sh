#!/bin/bash

# Database Normalization Migration Script
# This script drops the existing database and recreates it with the normalized schema

echo "🔄 Starting database normalization migration..."

# Database connection details
DB_NAME="footballhome"
DB_USER="footballapp"
DB_HOST="localhost"
DB_PORT="5432"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  WARNING: This will DROP the existing database and recreate it!${NC}"
echo -e "${YELLOW}   All existing data will be LOST!${NC}"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Migration cancelled${NC}"
    exit 1
fi

echo -e "${YELLOW}🗄️  Stopping any running containers...${NC}"
podman-compose down || docker-compose down

echo -e "${YELLOW}🧹 Cleaning up database volumes...${NC}"
podman volume rm footballhome_db_data 2>/dev/null || docker volume rm footballhome_db_data 2>/dev/null || true

echo -e "${YELLOW}🚀 Starting database container...${NC}"
podman-compose up -d db || docker-compose up -d db

echo -e "${YELLOW}⏳ Waiting for database to be ready...${NC}"
sleep 10

# Check if database is ready
for i in {1..30}; do
    if PGPASSWORD=footballpass123 psql -h localhost -p 5432 -U footballapp -d footballhome -c "SELECT 1" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Database is ready${NC}"
        break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ Database connection timeout${NC}"
        exit 1
    fi
done

echo -e "${YELLOW}📊 Applying normalized schema...${NC}"
PGPASSWORD=footballpass123 psql -h localhost -p 5432 -U footballapp -d footballhome -f database/init.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database schema applied successfully${NC}"
else
    echo -e "${RED}❌ Failed to apply database schema${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Verifying normalized tables...${NC}"
PGPASSWORD=footballpass123 psql -h localhost -p 5432 -U footballapp -d footballhome -c "
SELECT 
    'sports' as table_name, count(*) as record_count FROM sports
UNION ALL SELECT 
    'user_roles' as table_name, count(*) as record_count FROM user_roles  
UNION ALL SELECT 
    'event_types' as table_name, count(*) as record_count FROM event_types
UNION ALL SELECT 
    'rsvp_statuses' as table_name, count(*) as record_count FROM rsvp_statuses
UNION ALL SELECT 
    'positions' as table_name, count(*) as record_count FROM positions
UNION ALL SELECT 
    'teams' as table_name, count(*) as record_count FROM teams
UNION ALL SELECT 
    'users' as table_name, count(*) as record_count FROM users
UNION ALL SELECT 
    'team_members' as table_name, count(*) as record_count FROM team_members
UNION ALL SELECT 
    'events' as table_name, count(*) as record_count FROM events
ORDER BY table_name;
"

echo -e "${YELLOW}🚀 Starting all services...${NC}"
podman-compose up -d || docker-compose up -d

echo ""
echo -e "${GREEN}🎉 Database normalization complete!${NC}"
echo ""
echo -e "${GREEN}✅ Normalized tables created:${NC}"
echo -e "   • sports (5 sports available)"
echo -e "   • user_roles (admin, coach, player)"  
echo -e "   • event_types (training, match, meeting, scrimmage)"
echo -e "   • rsvp_statuses (yes, maybe, no with colors)"
echo -e "   • positions (goalkeeper, defender, midfielder, forward)"
echo -e "   • teams (updated with sport_id foreign key)"
echo -e "   • users (updated with user_role_id foreign key)" 
echo -e "   • team_members (updated with position_id foreign key)"
echo -e "   • events (updated with event_type_id foreign key)"
echo -e "   • rsvps (updated with rsvp_status_id foreign key)"
echo ""
echo -e "${GREEN}🌐 Application should be available at: http://localhost${NC}"
echo -e "${GREEN}🔐 Demo credentials:${NC}"
echo -e "   Coach: coach@thunderfc.com / coach123"
echo -e "   Player: player@thunderfc.com / player123"
echo ""
echo -e "${YELLOW}📋 Key improvements:${NC}"
echo -e "   • Multi-sport support (not limited to soccer)"
echo -e "   • Flexible user roles and permissions"
echo -e "   • Sport-specific positions and event types"
echo -e "   • Colored RSVP statuses for better UX"
echo -e "   • Proper foreign key relationships"
echo -e "   • No more hardcoded constraint values"
echo ""