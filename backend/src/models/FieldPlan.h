#pragma once
#include <string>
#include "../third_party/json.hpp"

// FieldPlan — the game page's pitch planner layout per facility (migration
// 635): field_plan_layouts ('current' = live positions, 'default' = what
// ↺ DEFAULT restores) holding field_plan_items (the 11v11, the 7v7, named
// practice boxes), plus field_plan_spots (named positions saved with 💾).
// Items/spots are JSON objects { key, kind, name, length_yd, width_yd, x, z,
// rot } — site metres and yards, as pitch-planner.js draws them. Named
// saves (field_plan_saves + field_plan_save_items, migration 680) freeze a
// whole layout under a name; saving a name again adds a version.
class FieldPlan {
public:
    // Facility by id, or Lighthouse Sport Complex when id <= 0. 0 = unknown.
    long long facilityId(long long requested);

    // { current: {items, updated_at} | null, default: … | null, spots: [] }
    nlohmann::json get(long long facilityId);

    // Replaces the layout's items. kind: 'current' | 'default'.
    void putLayout(long long facilityId, const std::string& kind,
                   const nlohmann::json& items, long long byUserId);

    // Returns the new spot's id.
    long long addSpot(long long facilityId, const nlohmann::json& spot, long long byUserId);

    // False when no such spot at this facility.
    bool deleteSpot(long long facilityId, long long spotId);

    // Named whole-layout saves (migration 680): { id, name, created_at,
    // by, items: [...] } newest first.
    nlohmann::json saves(long long facilityId);
    // Copies items into a new save; returns its id.
    long long addSave(long long facilityId, const std::string& name, const nlohmann::json& items,
                      long long byUserId);
    // False when no such save at this facility.
    bool deleteSave(long long facilityId, long long saveId);
};
