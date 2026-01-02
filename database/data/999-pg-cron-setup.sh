#!/bin/bash
# This script runs after the database is fully initialized
# It sets up the pg_cron extension and schedules the attendance job

set -e

# Wait a moment for pg_cron background worker to start
sleep 2

# Create pg_cron extension and schedule the job
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Enable pg_cron extension
    CREATE EXTENSION IF NOT EXISTS pg_cron;

    -- Create a simple wrapper function that pg_cron can call
    CREATE OR REPLACE FUNCTION run_attendance_cron()
    RETURNS void AS \$\$
    DECLARE
        result RECORD;
        total_events INT := 0;
        total_rows INT := 0;
    BEGIN
        FOR result IN SELECT * FROM process_attendance_snapshots()
        LOOP
            total_events := total_events + 1;
            total_rows := total_rows + result.rows_created;
        END LOOP;
        
        -- Log the run if anything was processed
        IF total_events > 0 THEN
            INSERT INTO attendance_cron_log (events_processed, details)
            VALUES (total_events, jsonb_build_object('total_rows', total_rows));
        END IF;
    END;
    \$\$ LANGUAGE plpgsql;

    -- Remove existing job if it exists (for idempotency)
    SELECT cron.unschedule('attendance-snapshot') WHERE EXISTS (
        SELECT 1 FROM cron.job WHERE jobname = 'attendance-snapshot'
    );

    -- Schedule the attendance snapshot job to run every minute
    SELECT cron.schedule(
        'attendance-snapshot',
        '* * * * *',
        'SELECT run_attendance_cron()'
    );
    
    -- Show result
    SELECT jobid, schedule, command, jobname FROM cron.job;
EOSQL

echo "pg_cron attendance job scheduled successfully"
