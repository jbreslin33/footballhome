#ifndef MESSAGE_TEMPLATE_CONTROLLER_H
#define MESSAGE_TEMPLATE_CONTROLLER_H

#include "../core/Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../database/Database.h"
#include <memory>
#include <pqxx/pqxx>

class MessageTemplateController : public Controller {
public:
    MessageTemplateController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;

    Response handleList(const Request& request);
};

#endif
