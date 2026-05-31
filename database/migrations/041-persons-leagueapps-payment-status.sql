-- 041-persons-leagueapps-payment-status.sql
-- Persist latest LeagueApps payment state on the person record for lineup visibility.
ALTER TABLE persons
ADD COLUMN IF NOT EXISTS leagueapps_payment_status TEXT;

COMMENT ON COLUMN persons.leagueapps_payment_status IS
'Latest LeagueApps payment status for membership/registration sync';
