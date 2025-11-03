# Football Home Database

This folder contains the complete database schema for the Football Home team management system.

## Files

- **`init.sql`** - Complete normalized database schema with sample data
- **`NORMALIZATION_GUIDE.md`** - Documentation about the normalization approach

## Quick Start

1. Start PostgreSQL database
2. Create database: `CREATE DATABASE footballhome;`
3. Run schema: `psql -d footballhome -f init.sql`

## Schema Overview

The database is fully normalized (4NF compliant) and includes:

### Core Tables
- **Users & Authentication** - Multi-role user system with JWT sessions
- **Teams & Sports** - Multi-sport team management 
- **Events & RSVP** - Comprehensive event system with practices/matches
- **Venues** - Detailed venue management with facilities

### Advanced Features
- **Notification System** - Granular notification preferences
- **Recurring Events** - Template-based recurring sessions
- **Audit Logging** - Complete activity tracking
- **Permission System** - Role-based access control

### Sample Data Included
- Thunder FC Demo team with players, coaches, and events
- Multiple venues with detailed information
- Complete role and permission setup
- Sample notification preferences

## Database Stats
- **25+ Tables** - Fully normalized structure
- **50+ Indexes** - Performance optimized
- **8 Lookup Tables** - No hardcoded values
- **4NF Compliant** - Enterprise-grade normalization

Ready for production deployment or development! 🚀