#include "FieldPlan.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {

json itemJson(const pqxx::row& r) {
    return {{"key", r["item_key"].as<std::string>()},
            {"kind", r["kind"].as<std::string>()},
            {"name", r["name"].is_null() ? json(nullptr) : json(r["name"].as<std::string>())},
            {"length_yd", r["length_yd"].as<double>()},
            {"width_yd", r["width_yd"].as<double>()},
            {"x", r["x_m"].as<double>()},
            {"z", r["z_m"].as<double>()},
            {"rot", r["rot_deg"].as<double>()}};
}

}  // namespace

long long FieldPlan::facilityId(long long requested) {
    auto* db = Database::getInstance();
    auto rows = requested > 0
        ? db->query("SELECT id FROM facilities WHERE id = $1::int", {std::to_string(requested)})
        : db->query("SELECT id FROM facilities WHERE name = 'Lighthouse Sport Complex'");
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

json FieldPlan::get(long long facilityId) {
    auto* db = Database::getInstance();
    const std::string fid = std::to_string(facilityId);
    json out = {{"facility_id", facilityId}, {"current", nullptr}, {"default", nullptr},
                {"spots", json::array()}};

    auto layouts = db->query(
        "SELECT id, kind, to_char(updated_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS updated_at "
        "  FROM field_plan_layouts WHERE facility_id = $1::int", {fid});
    for (const auto& l : layouts) {
        json items = json::array();
        for (const auto& r : db->query(
                 "SELECT item_key, kind, name, length_yd, width_yd, x_m, z_m, rot_deg "
                 "  FROM field_plan_items WHERE layout_id = $1::int ORDER BY kind, item_key",
                 {l["id"].as<std::string>()}))
            items.push_back(itemJson(r));
        out[l["kind"].as<std::string>()] = {{"items", items},
                                            {"updated_at", l["updated_at"].as<std::string>()}};
    }
    for (const auto& r : db->query(
             "SELECT id, pitch_key, name, length_yd, width_yd, x_m, z_m, rot_deg "
             "  FROM field_plan_spots WHERE facility_id = $1::int ORDER BY created_at, id", {fid}))
        out["spots"].push_back({{"id", r["id"].as<long long>()},
                                {"pitch", r["pitch_key"].as<std::string>()},
                                {"name", r["name"].as<std::string>()},
                                {"length_yd", r["length_yd"].as<double>()},
                                {"width_yd", r["width_yd"].as<double>()},
                                {"x", r["x_m"].as<double>()},
                                {"z", r["z_m"].as<double>()},
                                {"rot", r["rot_deg"].as<double>()}});
    out["saves"] = saves(facilityId);
    return out;
}

json FieldPlan::saves(long long facilityId) {
    auto* db = Database::getInstance();
    json out = json::array();
    for (const auto& s : db->query(
             "SELECT s.id, s.name, "
             "       to_char(s.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
             "       NULLIF(btrim(concat_ws(' ', p.first_name, p.last_name)), '') AS by_name "
             "  FROM field_plan_saves s "
             "  LEFT JOIN users u ON u.id = s.created_by "
             "  LEFT JOIN persons p ON p.id = u.person_id "
             " WHERE s.facility_id = $1::int ORDER BY s.created_at DESC, s.id DESC",
             {std::to_string(facilityId)})) {
        json items = json::array();
        for (const auto& r : db->query(
                 "SELECT item_key, kind, name, length_yd, width_yd, x_m, z_m, rot_deg "
                 "  FROM field_plan_save_items WHERE save_id = $1::int ORDER BY kind, item_key",
                 {s["id"].as<std::string>()}))
            items.push_back(itemJson(r));
        out.push_back({{"id", s["id"].as<long long>()},
                       {"name", s["name"].as<std::string>()},
                       {"created_at", s["created_at"].as<std::string>()},
                       {"by", s["by_name"].is_null() ? json(nullptr) : json(s["by_name"].as<std::string>())},
                       {"items", items}});
    }
    return out;
}

long long FieldPlan::addSave(long long facilityId, const std::string& name, const json& items,
                             long long byUserId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto sv = tx->exec_params(
            "INSERT INTO field_plan_saves (facility_id, name, created_by) VALUES ($1, btrim($2), $3) RETURNING id",
            facilityId, name, byUserId);
        const long long saveId = sv[0]["id"].as<long long>();
        for (const auto& it : items) {
            const bool box = it.value("kind", "pitch") == "practice_box";
            tx->exec_params(
                "INSERT INTO field_plan_save_items (save_id, item_key, kind, name, length_yd, width_yd, x_m, z_m, rot_deg) "
                "VALUES ($1, $2, $3, NULLIF($4, ''), $5, $6, $7, $8, $9)",
                saveId, it.at("key").get<std::string>(), box ? "practice_box" : "pitch",
                it.contains("name") && it["name"].is_string() ? it["name"].get<std::string>() : std::string(),
                it.at("length_yd").get<double>(), it.at("width_yd").get<double>(),
                it.at("x").get<double>(), it.at("z").get<double>(), it.at("rot").get<double>());
        }
        db->commit(tx);
        return saveId;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

bool FieldPlan::deleteSave(long long facilityId, long long saveId) {
    auto rows = Database::getInstance()->query(
        "DELETE FROM field_plan_saves WHERE id = $1::int AND facility_id = $2::int RETURNING id",
        {std::to_string(saveId), std::to_string(facilityId)});
    return !rows.empty();
}

void FieldPlan::putLayout(long long facilityId, const std::string& kind, const json& items,
                          long long byUserId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto lay = tx->exec_params(
            "INSERT INTO field_plan_layouts (facility_id, kind, updated_by) VALUES ($1, $2, $3) "
            "ON CONFLICT (facility_id, kind) DO UPDATE SET updated_at = now(), updated_by = EXCLUDED.updated_by "
            "RETURNING id",
            facilityId, kind, byUserId);
        const long long layoutId = lay[0]["id"].as<long long>();
        tx->exec_params("DELETE FROM field_plan_items WHERE layout_id = $1", layoutId);
        for (const auto& it : items) {
            const bool box = it.value("kind", "pitch") == "practice_box";
            tx->exec_params(
                "INSERT INTO field_plan_items (layout_id, item_key, kind, name, length_yd, width_yd, x_m, z_m, rot_deg) "
                "VALUES ($1, $2, $3, NULLIF($4, ''), $5, $6, $7, $8, $9)",
                layoutId, it.at("key").get<std::string>(), box ? "practice_box" : "pitch",
                it.contains("name") && it["name"].is_string() ? it["name"].get<std::string>() : std::string(),
                it.at("length_yd").get<double>(), it.at("width_yd").get<double>(),
                it.at("x").get<double>(), it.at("z").get<double>(), it.at("rot").get<double>());
        }
        db->commit(tx);
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}

long long FieldPlan::addSpot(long long facilityId, const json& s, long long byUserId) {
    auto* db = Database::getInstance();
    auto rows = db->query(
        "INSERT INTO field_plan_spots (facility_id, pitch_key, name, length_yd, width_yd, x_m, z_m, rot_deg, created_by) "
        "VALUES ($1::int, $2, $3, $4::numeric, $5::numeric, $6::numeric, $7::numeric, $8::numeric, $9::int) RETURNING id",
        {std::to_string(facilityId), s.at("pitch").get<std::string>(), s.at("name").get<std::string>(),
         std::to_string(s.at("length_yd").get<double>()), std::to_string(s.at("width_yd").get<double>()),
         std::to_string(s.at("x").get<double>()), std::to_string(s.at("z").get<double>()),
         std::to_string(s.at("rot").get<double>()), std::to_string(byUserId)});
    return rows[0]["id"].as<long long>();
}

bool FieldPlan::deleteSpot(long long facilityId, long long spotId) {
    auto rows = Database::getInstance()->query(
        "DELETE FROM field_plan_spots WHERE id = $1::int AND facility_id = $2::int RETURNING id",
        {std::to_string(spotId), std::to_string(facilityId)});
    return !rows.empty();
}
