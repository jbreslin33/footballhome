# Football Home Backend

Express.js backend implementation for the Football Home application.

## Current Implementation

### Express.js Backend (`./express/`)
- **Framework**: Node.js with Express.js
- **Database**: PostgreSQL with pg library
- **Port**: 3000
- **Status**: Production ready
- **Container**: `footballhome_api`

## Backend Structure

```
backend/
├── express/          # Node.js/Express.js implementation
└── README.md         # This file
```

## Core API Endpoints

The Express.js backend implements:
- `GET /api/health` - Health check endpoint
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/login` - User authentication
- `POST /api/auth/logout` - User logout  
- `PUT /api/auth/update-profile` - Update user profile
- `GET /api/teams/:teamId/events` - Get team events
- `POST /api/events` - Create new event
- `POST /api/events/:eventId/rsvp` - RSVP to event
- `DELETE /api/events/:eventId/rsvp` - Remove RSVP

## Database Schema

The backend uses the PostgreSQL database schema defined in `/database/init.sql` with normalized tables for users, teams, events, and RSVPs.

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `PORT` - Server port (default: 3000)

## Development

```bash
# Start with Docker
docker compose up -d

# View logs
docker compose logs api

# Rebuild after changes
docker compose up -d --build
```