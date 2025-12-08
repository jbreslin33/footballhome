#pragma once
#include "../core/Controller.h"
#include "../database/Database.h"
#include <memory>

class AvailabilityController : public Controller {
private:
    Database* db_;

public:
    AvailabilityController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Medical Status endpoints
    Response getMedicalStatus(const Request& req);
    Response createMedicalStatus(const Request& req);
    Response resolveMedicalStatus(const Request& req);
    
    // Academic Status endpoints
    Response getAcademicStatus(const Request& req);
    Response createAcademicStatus(const Request& req);
    Response resolveAcademicStatus(const Request& req);
    
    // Combined availability view
    Response getPlayerAvailability(const Request& req);
    
    // Helper
    std::string extractIdFromPath(const std::string& path, const std::string& paramName);
};
