#pragma once

// ────────────────────────────────────────────────────────────────────────────
// LaSyncScheduler — keeps `persons` / `person_la_memberships` fresh from
// LeagueApps on a fixed clock, independent of anyone opening a roster
// screen.
//
// PRIOR BEHAVIOR (2026-08-30 audit): LaProgramSync::run() only ever fired
// on-demand — the STRICT rule in every *RosterController is "call
// LaProgramSync before serving," so the DB was only as fresh as the last
// time an admin happened to open Boys/Girls/Mens/Womens Roster or hit the
// manual "Sync Memberships" button (AdminLaBackfillController::
// handleSyncMemberships). There was no cron, no systemd timer, nothing —
// confirmed by inspecting the host directly. If nobody opened a given
// screen for days, that screen's LA data was days stale, even though LA is
// the source of truth for membership. Mirrors SocialController's
// scheduler-thread pattern (checks every 60s); this checks every 5
// minutes, which is the club's own stated freshness requirement.
//
// This does NOT touch team_persons / roster assignment — that stays a
// separate, manual step (see BoysRoster/YouthRoster). It only keeps LA
// membership state (persons.la_user_id, person_la_memberships, contact
// info) in sync with LeagueApps.
// ────────────────────────────────────────────────────────────────────────────
class LaSyncScheduler {
public:
    static LaSyncScheduler& getInstance();

    // Idempotent — a second call is a no-op.  Spawns one detached
    // background thread that runs until process exit (same lifetime
    // convention as SocialController::startScheduler() and
    // LineupNotificationHub — nothing in this codebase currently does a
    // graceful shutdown of these background loops).
    void start();

private:
    LaSyncScheduler()  = default;
    ~LaSyncScheduler() = default;
    LaSyncScheduler(const LaSyncScheduler&)            = delete;
    LaSyncScheduler& operator=(const LaSyncScheduler&) = delete;

    void loop();
    void syncAllPrograms();

    bool running_ = false;
};
