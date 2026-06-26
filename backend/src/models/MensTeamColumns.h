#pragma once
#include <optional>
#include <string>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// MensTeamColumns — read-side model for `mens_team_columns` joined to
// `teams` (label falls back to teams.name when the column row leaves
// `label` NULL).
//
// loadAll() returns every configured column ordered by sort_order — that
// ordering is what the dashboard renders left-to-right.  findByTeamId() is
// used by the assign endpoint to look up the mutex_group for the target
// team and to confirm the team is actually rendered as a column (we 404
// otherwise so a stale UI never writes assignments for retired columns).
//
// `mutexGroup` empty string = no mutex constraint.
// `maxRoster` exposed via (`maxRoster`, `hasMaxRoster`) because 0 is a
// valid roster cap distinct from NULL.
// ────────────────────────────────────────────────────────────────────────────
class MensTeamColumns {
public:
    struct Column {
        int         teamId       = 0;
        std::string label;
        std::string shortLabel;   // falls back to label when short_label is NULL
        int         sortOrder    = 0;
        std::string color;
        std::string mutexGroup;   // "" = no mutex
        int         maxRoster    = 0;
        bool        hasMaxRoster = false;
    };

    MensTeamColumns();

    std::vector<Column> loadAll();

    std::optional<Column> findByTeamId(int teamId);

private:
    Database* db_;
};
