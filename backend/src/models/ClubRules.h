#pragma once
#include "../third_party/json.hpp"

// ClubRules — 📋 rules in layers (mig 4002): 🏠 club → club section → team.
//
// forPerson(personId, everything) → { layers: [ { scope, key, sectionCode,
//   teamId, label, rules: [ { id, title, body } ] } ] }
//   club layer first, then the person's sections (club_sections order), then
//   their teams that have rules (team board order).  A person's teams = the
//   ones they play on, coach, or are a parent on (person_guardians).
//   everything = admins: every section, every team with rules.
class ClubRules {
public:
    static nlohmann::json forPerson(int personId, bool everything);
};
