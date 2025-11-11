# Simple C++ Backend - No Frameworks!

Minimal C++ HTTP server for FootballHome RSVP app.

## What it does:
- Handles POST /api/auth/login 
- Connects to PostgreSQL database
- Returns JSON responses
- Zero external frameworks (just standard libs + basics)

## Dependencies:
- Standard C++ libraries
- libpqxx (PostgreSQL client)
- Basic HTTP parsing

## Build & Run:
```bash
g++ -std=c++17 main.cpp -lpqxx -lpq -o server
./server
```