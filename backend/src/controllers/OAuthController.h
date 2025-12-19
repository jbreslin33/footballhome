#ifndef OAUTH_CONTROLLER_H
#define OAUTH_CONTROLLER_H

#include "../core/Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../core/Router.h"
#include <string>
#include <map>

class OAuthController : public Controller {
public:
    OAuthController();
    ~OAuthController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGoogleLogin(const Request& request);
    Response handleGoogleCallback(const Request& request);
    
    std::string getGoogleAuthUrl();
    std::map<std::string, std::string> exchangeCodeForToken(const std::string& code);
    std::map<std::string, std::string> getUserInfo(const std::string& accessToken);
    std::string findOrCreateUser(const std::map<std::string, std::string>& userInfo);
    std::string generateJWT(const std::string& userId, const std::string& email);
    
    std::string clientId_;
    std::string clientSecret_;
    std::string redirectUri_;
};

#endif // OAUTH_CONTROLLER_H
