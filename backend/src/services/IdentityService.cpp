#include "IdentityService.h"
#include <iostream>
#include <sstream>

IdentityService::IdentityService(Database* db) : db_(db) {}

std::string IdentityService::safeStr(const pqxx::field& f) {
    if (f.is_null()) return "";
    return f.c_str();
}

std::vector<IdentityService::IdentityDTO> IdentityService::getIdentities(const IdentityFilter& filter) {
    std::vector<IdentityDTO> identities;
    
    try {
        std::string sql = R"(
            SELECT 
                uei.id, uei.external_id, uei.external_username, uei.first_name, uei.last_name, 
                uei.provider_id, uei.team_id, uei.user_id,
                uei.external_data->>'source' as source,
                t.name as team_name,
                ep.name as provider_name,
                u.first_name as user_first, u.last_name as user_last, u.email as user_email
            FROM user_external_identities uei
            LEFT JOIN teams t ON uei.team_id = t.id
            LEFT JOIN external_providers ep ON uei.provider_id = ep.id
            LEFT JOIN users u ON uei.user_id = u.id
            LEFT JOIN sport_divisions sd ON t.sport_division_id = sd.id
            WHERE 1=1
        )";
        
        // Apply filters
        if (!filter.team_id.empty()) {
            sql += " AND uei.team_id = '" + filter.team_id + "'";
        }
        
        if (!filter.club_id.empty()) {
            // Filter by club via team -> sport_division -> club
            sql += " AND sd.club_id = '" + filter.club_id + "'";
        }
        
        if (!filter.provider_id.empty()) {
            sql += " AND uei.provider_id = '" + filter.provider_id + "'";
        }
        
        if (filter.only_unlinked) {
            sql += " AND uei.user_id IS NULL";
        } else if (filter.only_linked) {
            sql += " AND uei.user_id IS NOT NULL";
        }
        
        sql += " ORDER BY uei.user_id NULLS FIRST, uei.created_at DESC";
        
        auto result = db_->query(sql);
        
        for (const auto& row : result) {
            IdentityDTO dto;
            dto.id = safeStr(row["id"]);
            dto.external_id = safeStr(row["external_id"]);
            dto.external_username = safeStr(row["external_username"]);
            dto.first_name = safeStr(row["first_name"]);
            dto.last_name = safeStr(row["last_name"]);
            dto.provider_id = safeStr(row["provider_id"]);
            dto.provider_name = safeStr(row["provider_name"]);
            dto.team_id = safeStr(row["team_id"]);
            dto.team_name = safeStr(row["team_name"]);
            dto.user_id = safeStr(row["user_id"]);
            dto.user_first = safeStr(row["user_first"]);
            dto.user_last = safeStr(row["user_last"]);
            dto.user_email = safeStr(row["user_email"]);
            dto.source = safeStr(row["source"]);
            
            identities.push_back(dto);
        }
        
    } catch (const std::exception& e) {
        std::cerr << "Error in IdentityService::getIdentities: " << e.what() << std::endl;
        throw;
    }
    
    return identities;
}

bool IdentityService::linkIdentity(const std::string& identity_id, const std::string& user_id, const std::string& admin_id) {
    try {
        // 1. Update Database
        std::string sql = "UPDATE user_external_identities SET user_id = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2";
        std::vector<std::string> params = {user_id, identity_id};
        db_->query(sql, params);
        
        // 2. Log to Manual SQL File (Hybrid Persistence)
        // We need to fetch the external_id and provider_id to make a robust SQL statement
        // that doesn't rely on the UUID of the identity row (which might change if re-scraped)
        auto identity = db_->query("SELECT external_id, provider_id FROM user_external_identities WHERE id = '" + identity_id + "'");
        if (identity.size() > 0) {
            std::string ext_id = safeStr(identity[0]["external_id"]);
            std::string prov_id = safeStr(identity[0]["provider_id"]);
            
            // Construct a SQL statement that finds the identity by external_id + provider and links it
            std::stringstream fileSql;
            fileSql << "-- Manual Link by Admin " << admin_id << "\n";
            fileSql << "UPDATE user_external_identities SET user_id = '" << user_id << "', updated_at = CURRENT_TIMESTAMP ";
            fileSql << "WHERE external_id = '" << ext_id << "' AND provider_id = '" << prov_id << "';\n";
            
            SqlFileLogger::logToManualFile("80-link-external-identities-to-users.sql", fileSql.str());
        }
        
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Error linking identity: " << e.what() << std::endl;
        return false;
    }
}

bool IdentityService::unlinkIdentity(const std::string& identity_id, const std::string& admin_id) {
    try {
        // 1. Update Database
        std::string sql = "UPDATE user_external_identities SET user_id = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = $1";
        std::vector<std::string> params = {identity_id};
        db_->query(sql, params);
        
        // 2. Log to Manual SQL File
        auto identity = db_->query("SELECT external_id, provider_id FROM user_external_identities WHERE id = '" + identity_id + "'");
        if (identity.size() > 0) {
            std::string ext_id = safeStr(identity[0]["external_id"]);
            std::string prov_id = safeStr(identity[0]["provider_id"]);
            
            std::stringstream fileSql;
            fileSql << "-- Manual Unlink by Admin " << admin_id << "\n";
            fileSql << "UPDATE user_external_identities SET user_id = NULL, updated_at = CURRENT_TIMESTAMP ";
            fileSql << "WHERE external_id = '" << ext_id << "' AND provider_id = '" << prov_id << "';\n";
            
            SqlFileLogger::logToManualFile("80-link-external-identities-to-users.sql", fileSql.str());
        }
        
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Error unlinking identity: " << e.what() << std::endl;
        return false;
    }
}
