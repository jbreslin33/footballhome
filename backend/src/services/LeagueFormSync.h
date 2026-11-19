#pragma once
#include <string>

// LeagueFormSync — mirrors a league's registration form responses sheet
// (mig 1540, league_form_sheets) into league_form_responses →
// league_registrations source 'league_form'.
//
// Owner 2026-11-19: "this file needs to be read on load of admin of teams
// page, rosters page, game event pages … if we see him … we flag their
// card with label docs uploaded" → "once on offical apsl roster we can
// take down flag".
//
// The sheet is private: shared (Viewer) with the service account in
// GCAL_SA_JSON and read through the Sheets API (spreadsheets.readonly).
// Only Timestamp / First Name / Last Name are read — never the photo or
// ID links.
//
// refreshIfStale(minutes) is called by GET /api/payments/standing, the
// one endpoint every admin player card loads (#teams, Game Center, Event
// Center, the ⋯ sheet).  One read at a time (try_lock: a second caller
// just renders what the DB has); a failed read records last_fetch_ok =
// false so the cards can say so, and retries on the same cadence.
class LeagueFormSync {
public:
    static void refreshIfStale(int maxAgeMinutes = 5);
    static void run(int sheetId, const std::string& spreadsheetId, const std::string& sheetTitle);
};
