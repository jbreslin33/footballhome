./setup.sh

# Export user data (attendance overrides, lineups) BEFORE destroying the DB
echo "📦 Exporting user data before rebuild..."
make export-user-data 2>&1 | tee export-user-data.log || echo "⚠️  No DB to export from (first run)"

make rebuild 2>&1 | tee rebuild.log 
make sync 2>&1 | tee sync.log 

# Restore user data AFTER sync (needs league data loaded first)
echo "📥 Loading user data after sync..."
make load-user-data 2>&1 | tee load-user-data.log
