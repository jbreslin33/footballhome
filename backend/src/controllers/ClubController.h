#ifndef CLUB_CONTROLLER_H
#define CLUB_CONTROLLER_H

#include "../core/Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../database/Database.h"
#include <memory>
#include <pqxx/pqxx>

class ClubController : public Controller {
public:
    ClubController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;
    
    // Handlers
    Response handleGetAllClubs(const Request& request);
    Response handleGetClubDetail(const Request& request);
    Response handleGetClubGameModel(const Request& request);
    Response handleGetClubGameModelStructure(const Request& request);
    Response handleListGameModelAdminEntities(const Request& request, const std::string& entity);
    Response handleCreateGameModelAdminEntity(const Request& request, const std::string& entity);
    Response handleDeleteGameModelAdminEntity(const Request& request, const std::string& entity, int id);
    Response handleUploadExerciseImage(const Request& request);
    Response handleDeleteExerciseImage(const Request& request);
    Response handleExerciseDescriptionOcr(const Request& request);

    // Helper methods
    // Writes decoded image bytes to /app/images/exercises and records a row
    // in club_game_model_exercise_images. Throws std::runtime_error on failure.
    void saveExerciseImage(int exercise_id, const std::string& imageBytes, const std::string& ext,
                            const std::string& role,
                            long long& outId, std::string& outImageUrl, int& outSortOrder);
};

#endif
