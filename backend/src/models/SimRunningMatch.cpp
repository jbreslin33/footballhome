#include "SimRunningMatch.h"

#include "../database/Database.h"

#include <exception>
#include <iostream>
#include <string>

namespace fh::orchestration {
namespace SimRunningMatchRepo {

bool insertPending(long long match_id,
                   const std::string& container_name) {
    try {
        auto* db = Database::getInstance();
        // ON CONFLICT DO NOTHING — if a stale row already exists for
        // this match_id (previous crash, or someone else racing us),
        // we do NOT overwrite it; caller is expected to notice the
        // "already there" case and abort the launch rather than
        // spawn a duplicate container with a colliding name.
        // pqxx::result::affected_rows() lets us distinguish inserted
        // vs. skipped, but a bool suffices for the M1 slice callers.
        db->query(
            "INSERT INTO sim_running_matches "
            "  (match_id, container_id, container_name) "
            "VALUES ($1::bigint, NULL, $2) "
            "ON CONFLICT (match_id) DO NOTHING",
            {std::to_string(match_id), container_name});
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[sim-running-match] insertPending(" << match_id
                  << ") failed: " << e.what() << std::endl;
        return false;
    }
}

bool setContainerId(long long match_id,
                    const std::string& container_id) {
    try {
        auto* db = Database::getInstance();
        auto rows = db->query(
            "UPDATE sim_running_matches "
            "   SET container_id = $2 "
            " WHERE match_id = $1::bigint "
            " RETURNING match_id",
            {std::to_string(match_id), container_id});
        if (rows.empty()) {
            std::cerr << "[sim-running-match] setContainerId(" << match_id
                      << "): row missing (reaped between insert and update?)"
                      << std::endl;
            return false;
        }
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[sim-running-match] setContainerId(" << match_id
                  << ") failed: " << e.what() << std::endl;
        return false;
    }
}

bool deleteFor(long long match_id) {
    try {
        auto* db = Database::getInstance();
        // Idempotent — no error if the row is already gone.
        db->query(
            "DELETE FROM sim_running_matches WHERE match_id = $1::bigint",
            {std::to_string(match_id)});
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[sim-running-match] deleteFor(" << match_id
                  << ") failed: " << e.what() << std::endl;
        return false;
    }
}

} // namespace SimRunningMatchRepo
} // namespace fh::orchestration
