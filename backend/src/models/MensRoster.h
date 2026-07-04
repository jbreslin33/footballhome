#pragma once
#include <memory>
#include <string>
#include "../third_party/json.hpp"

class MensTeamColumns;
class MensTeamAssignments;
class PersonBilling;
class PersonPayments;

// ────────────────────────────────────────────────────────────────────────────
// MensRoster — model behind GET /api/mens-roster.
//
// Live LA fetch of the Mens program crossed with `mens_team_columns` and
// `mens_team_assignments` to produce the column-wise payload the dashboard
// renders.  One column per row in mens_team_columns; one bucket per column.
// Players appear in every column they're assigned to (no implicit
// uniqueness — that's enforced server-side only inside mutex_groups by
// the assign endpoint).  Players with no assignment fall into
// `unassigned`.  Within each column, on-roster first (alpha last-name),
// then off-roster (alpha last-name).
//
// Billing (next bill date + amount) is projected onto every row via
// PersonBilling::resolve so the dashboard never has to issue a second
// roundtrip.
//
// Failure modes via Result:
//   • noColumns = true → controller returns 409.
//   • error not empty  → controller returns 502 (LA fetch or DB blip).
// ────────────────────────────────────────────────────────────────────────────
class MensRoster {
public:
    struct Result {
        nlohmann::json body;
        bool           noColumns = false;
        std::string    error;
    };

    MensRoster();
    ~MensRoster();

    Result run(bool includeAll);

private:
    std::unique_ptr<MensTeamColumns>     columns_;
    std::unique_ptr<MensTeamAssignments> assignments_;
    std::unique_ptr<PersonBilling>       billing_;
    std::unique_ptr<PersonPayments>      payments_;
    int mensProgramId_;

    static int envInt(const char* name, int fallback);
    static nlohmann::json shapeMensPlayer(const nlohmann::json& rec);
};
