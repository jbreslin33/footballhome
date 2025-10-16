# Football Home Backend Architecture

This directory contains backend implementations for the Football Home application. The architecture is designed to be flexible, allowing for multiple backend frameworks and languages as needed.

## Current Implementation

### Express.js Backend (`./express/`)
- **Framework**: Node.js with Express.js
- **Database**: PostgreSQL with pg library
- **Port**: 3000
- **Status**: Active (used in production)

## Backend Structure Philosophy

The backend is organized by framework/technology to allow easy switching and comparison:

```
backend/
├── express/          # Node.js/Express.js implementation
├── README.md         # This file
└── [future backends] # e.g., django/, drogon/, fastapi/, etc.
```

## Adding New Backend Implementations

When adding a new backend framework:

1. **Create Framework Directory**: 
   ```bash
   mkdir backend/[framework-name]
   ```

2. **Implement Core APIs**: Each backend should implement:
   - `GET /api/health` - Health check endpoint
   - `GET /api/teams/:teamId/events` - Get team events
   - `POST /api/events` - Create new event
   - `POST /api/events/:eventId/rsvp` - RSVP to event
   - Authentication and authorization endpoints

3. **Docker Configuration**: Include a `Dockerfile` for containerization

4. **Environment Variables**: Use standard environment variables:
   - `DATABASE_URL` - PostgreSQL connection string
   - `PORT` - Server port (default varies by framework)

5. **Update docker-compose.yml**: 
   - Comment out current backend service
   - Add new backend service configuration
   - Update port mappings as needed

## Database Schema

All backends should use the same PostgreSQL database schema defined in `/database/init.sql`.

## Framework Selection Guidelines

Choose backends based on:
- **Express.js**: Rapid development, JavaScript ecosystem
- **Drogon (C++)**: High performance, low latency requirements
- **Django**: Complex admin interfaces, ORM needs
- **FastAPI**: Python ecosystem, automatic API documentation

## Testing New Backends

1. Update `docker-compose.yml` to use the new backend
2. Run `./start.sh` to test the application
3. Verify all API endpoints work with the frontend
4. Check database connectivity and operations

## API Compatibility

All backend implementations must maintain API compatibility with the frontend. The API contract is defined by the current Express.js implementation.