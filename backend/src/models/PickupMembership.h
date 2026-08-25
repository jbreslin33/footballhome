#pragma once
#include <unordered_map>
#include <vector>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// PickupMembership — batch lookup of the CURRENT pickup-variant LeagueApps
// registration for a set of person ids.
//
// Members and Pickup are two independent LA sub-programs per category (see
// MensRoster.cpp's "Pickup exclusion REMOVED" block): a person can hold one,
// the other, both, or neither, and which board they appear on is decided
// purely by the Members sub-program. Holding both is not supposed to happen
// — owner 2026-08-25: "i try to only move and not copy from member to pickup
// member … nobody should be in both" — but LA is the system of record and it
// does report three such people today, so the boards flag it rather than
// hiding it or overriding LA.
//
// Deliberately NOT read from team_persons: team 909 "Pickup" is an FH mirror
// that has drifted badly (82 rows against 44 real pickup registrations, only
// 26 overlapping) because MensRosterController auto-adds a 909 row on every
// APSL/Liga 1 assignment. person_la_memberships is the source of truth.
// ────────────────────────────────────────────────────────────────────────────
namespace PickupMembership {

// Returns personId -> {category, registeredAt, paymentStatus} for every person
// with an OPEN pickup-variant membership. A person id with no pickup
// registration is simply absent — callers should default to "no flag".
// Non-positive ids are ignored. Never throws — a DB error yields an empty map,
// so the board degrades to "no flag" rather than failing outright.
std::unordered_map<long long, nlohmann::json> loadForPersons(
    const std::vector<long long>& personIds);

}  // namespace PickupMembership
