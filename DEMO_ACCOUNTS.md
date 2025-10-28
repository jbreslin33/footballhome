# Football Home Demo Accounts

## Thunder FC Demo Team

This application includes a complete demo team setup with realistic users, events, and data stored in the PostgreSQL database.

### Demo Login Credentials

#### Coach Account
- **Email:** `coach@thunderfc.com`
- **Password:** `coach123`
- **Name:** Coach Sarah Martinez
- **Role:** Coach
- **Access:** Coach dashboard, event management, team notifications

#### Player Accounts

1. **Midfielder**
   - **Email:** `player@thunderfc.com`
   - **Password:** `player123`
   - **Name:** Alex Johnson
   - **Position:** Midfielder
   - **Jersey #:** 10

2. **Goalkeeper**
   - **Email:** `keeper@thunderfc.com`
   - **Password:** `keeper123`
   - **Name:** Maria Rodriguez
   - **Position:** Goalkeeper
   - **Jersey #:** 1

3. **Striker**
   - **Email:** `striker@thunderfc.com`
   - **Password:** `striker123`
   - **Name:** David Kim
   - **Position:** Forward
   - **Jersey #:** 9

4. **Defender**
   - **Email:** `defender@thunderfc.com`
   - **Password:** `defender123`
   - **Name:** Emma Thompson
   - **Position:** Defender
   - **Jersey #:** 4

#### General Demo Account
- **Email:** `demo@footballhome.org`
- **Password:** `demo`
- **Name:** Demo User
- **Position:** Forward
- **Jersey #:** 11

## Demo Team Events

The Thunder FC Demo team has three sample events:

1. **Weekly Training Session** (Training)
   - Date: Oct 30, 2025 at 6:00 PM
   - Location: Thunder FC Training Ground
   - Duration: 90 minutes

2. **Match vs Lightning United** (Match)
   - Date: Nov 2, 2025 at 3:00 PM
   - Location: Thunder FC Stadium
   - Duration: 120 minutes

3. **Team Strategy Meeting** (Meeting)
   - Date: Oct 29, 2025 at 7:00 PM
   - Location: Thunder FC Clubhouse
   - Duration: 60 minutes

## Database Integration

All demo data is stored in the PostgreSQL database:
- **Teams:** Thunder FC Demo
- **Users:** All accounts with full profile data
- **Events:** Sample training, match, and meeting events
- **Team Memberships:** All users are properly assigned to the team

## Features You Can Test

### Coach Features
- View and manage all team events
- Send SMS/Email notifications to team members
- Access coach dashboard with event overview

### Player Features
- View personal profile with editable fields
- Edit profile information (name, phone, position, jersey number)
- Profile changes persist in database
- Access player-specific views

### Profile Editing
- All profile changes are saved to the PostgreSQL database
- Changes persist across login sessions
- Real-time validation and error handling
- Support for phone numbers, positions, and jersey numbers

## Technical Notes

- Authentication uses database lookups (no more hardcoded demo users)
- All data persistence through PostgreSQL
- Session management with database integration
- Fixed API response handling for profile data display
- Proper error handling and user data extraction