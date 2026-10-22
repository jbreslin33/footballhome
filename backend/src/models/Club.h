#pragma once
#include "Organization.h"

// ────────────────────────────────────────────────────────────────────────────
// Club — an organization that owns teams (clubs.organization_id).  Its
// public page adds the crest, the founding year, the contact mailbox and
// the sections with their active teams.
//
// club_sections has no club_id yet: today's four sections are
// Lighthouse's, and only a club's own teams (teams.club_id) are listed
// under them, so a second club shows just its own teams.  The column
// lands when a second club has sections of its own.
// ────────────────────────────────────────────────────────────────────────────
class Club : public Organization {
public:
    Club(Database* db, int organizationId, std::string slug, std::string name, int clubId);

    const char* kind() const override { return "club"; }
    int clubId() const { return clubId_; }

    nlohmann::json publicPage() const override;

private:
    int clubId_;
};
