#pragma once
#include "../database/Model.h"
#include <string>

class Team : public Model {
private:
    std::string id_;
    std::string name_;
    std::string division_id_;
    std::string league_division_id_;

public:
    Team();
    
    // Core CRUD operations
    bool save() override;
    bool load(int id) override;
    bool remove() override;
    
    // Team-specific methods
    std::string getTeamRoster(const std::string& team_id);
    bool loadByUuid(const std::string& uuid);
    
    // Getters and setters
    const std::string& getId() const { return id_; }
    const std::string& getName() const { return name_; }
    const std::string& getDivisionId() const { return division_id_; }
    
    void setName(const std::string& name) { name_ = name; }
    void setDivisionId(const std::string& division_id) { division_id_ = division_id; }

private:
    void populateFromMap(const std::unordered_map<std::string, std::string>& data);
    std::string escapeJSON(const std::string& str);
};