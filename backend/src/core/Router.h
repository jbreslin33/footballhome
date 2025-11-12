#pragma once
#include "Request.h"
#include "Response.h"
#include <functional>
#include <vector>
#include <memory>
#include <regex>
#include <iostream>

// Forward declarations
class Controller;

// Route handler function signature
using RouteHandler = std::function<Response(const Request&)>;

// Middleware function signature
using Middleware = std::function<bool(const Request&, Response&)>;

struct Route {
    HttpMethod method;
    std::string pattern;
    std::regex regex_pattern;
    RouteHandler handler;
    std::vector<Middleware> middlewares;
    
    Route(HttpMethod m, const std::string& p, RouteHandler h);
    bool matches(HttpMethod method, const std::string& path) const;
};

class Router {
private:
    std::vector<std::unique_ptr<Route>> routes_;
    std::vector<Middleware> global_middlewares_;
    
    std::string pathToRegex(const std::string& pattern);

public:
    Router() = default;
    
    // Route registration
    void get(const std::string& pattern, RouteHandler handler);
    void post(const std::string& pattern, RouteHandler handler);
    void put(const std::string& pattern, RouteHandler handler);
    void del(const std::string& pattern, RouteHandler handler);
    void options(const std::string& pattern, RouteHandler handler);
    
    // Middleware registration
    void use(Middleware middleware);
    void use(const std::string& pattern, Middleware middleware);
    
    // Controller registration  
    template<typename T>
    void useController(const std::string& prefix, std::shared_ptr<T> controller) {
        if (!controller) {
            std::cerr << "Cannot register null controller for prefix: " << prefix << std::endl;
            return;
        }
        controller->registerRoutes(*this, prefix);
    }
    
    // Route handling
    Response handle(const Request& request);
    
    // Route matching
    const Route* findRoute(HttpMethod method, const std::string& path) const;
    
    // Utility
    void addRoute(HttpMethod method, const std::string& pattern, RouteHandler handler);
    size_t getRouteCount() const { return routes_.size(); }
    
    // Debug
    void printRoutes() const;
};