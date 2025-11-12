#include "Router.h"
#include <iostream>
#include <algorithm>

Route::Route(HttpMethod m, const std::string& p, RouteHandler h) 
    : method(m), pattern(p), handler(h) {
    // Convert path pattern to regex
    std::string regex_str = p;
    
    // Replace :param with ([^/]+) for parameter matching
    std::regex param_regex(R"(:([^/]+))");
    regex_str = std::regex_replace(regex_str, param_regex, "([^/]+)");
    
    // Escape other regex special characters if needed
    // For now, we'll keep it simple
    
    // Anchor the pattern
    regex_str = "^" + regex_str + "$";
    
    try {
        regex_pattern = std::regex(regex_str);
    } catch (const std::exception& e) {
        std::cerr << "Invalid route pattern: " << p << " - " << e.what() << std::endl;
        // Fallback to exact match
        regex_pattern = std::regex("^" + std::regex_replace(p, std::regex(R"([.*+?^${}()|[\]\\])"), R"(\$&)") + "$");
    }
}

bool Route::matches(HttpMethod method_to_match, const std::string& path) const {
    if (method != method_to_match) {
        return false;
    }
    
    return std::regex_match(path, regex_pattern);
}

void Router::get(const std::string& pattern, RouteHandler handler) {
    addRoute(HttpMethod::GET, pattern, handler);
}

void Router::post(const std::string& pattern, RouteHandler handler) {
    addRoute(HttpMethod::POST, pattern, handler);
}

void Router::put(const std::string& pattern, RouteHandler handler) {
    addRoute(HttpMethod::PUT, pattern, handler);
}

void Router::del(const std::string& pattern, RouteHandler handler) {
    addRoute(HttpMethod::DELETE, pattern, handler);
}

void Router::options(const std::string& pattern, RouteHandler handler) {
    addRoute(HttpMethod::OPTIONS, pattern, handler);
}

void Router::use(Middleware middleware) {
    global_middlewares_.push_back(middleware);
}

void Router::use(const std::string& pattern, Middleware middleware) {
    // For now, we'll implement this as a route-specific middleware
    // This could be enhanced to support pattern-based middleware
    // For simplicity, we'll add it to all routes that match the pattern
    std::cout << "Pattern-specific middleware not yet fully implemented for: " << pattern << std::endl;
}



Response Router::handle(const Request& request) {
    // Apply global middlewares first
    Response response;
    for (const auto& middleware : global_middlewares_) {
        if (!middleware(request, response)) {
            // Middleware rejected the request
            return response;
        }
    }
    
    // Handle OPTIONS requests for CORS
    if (request.isMethod(HttpMethod::OPTIONS)) {
        Response cors_response = Response::ok();
        cors_response.setCorsHeaders();
        return cors_response;
    }
    
    // Find matching route
    const Route* route = findRoute(request.getMethod(), request.getPath());
    if (!route) {
        Response not_found = Response::notFound("Route not found: " + request.getPath());
        not_found.setCorsHeaders();
        return not_found;
    }
    
    // Apply route-specific middlewares
    for (const auto& middleware : route->middlewares) {
        if (!middleware(request, response)) {
            response.setCorsHeaders();
            return response;
        }
    }
    
    try {
        // Execute route handler
        Response handler_response = route->handler(request);
        handler_response.setCorsHeaders();
        return handler_response;
    } catch (const std::exception& e) {
        std::cerr << "Route handler error: " << e.what() << std::endl;
        Response error_response = Response::internalError("Internal server error");
        error_response.setCorsHeaders();
        return error_response;
    }
}

const Route* Router::findRoute(HttpMethod method, const std::string& path) const {
    for (const auto& route : routes_) {
        if (route->matches(method, path)) {
            return route.get();
        }
    }
    return nullptr;
}

void Router::addRoute(HttpMethod method, const std::string& pattern, RouteHandler handler) {
    routes_.push_back(std::make_unique<Route>(method, pattern, handler));
    
    std::cout << "Added route: ";
    switch (method) {
        case HttpMethod::GET: std::cout << "GET"; break;
        case HttpMethod::POST: std::cout << "POST"; break;
        case HttpMethod::PUT: std::cout << "PUT"; break;
        case HttpMethod::DELETE: std::cout << "DELETE"; break;
        case HttpMethod::OPTIONS: std::cout << "OPTIONS"; break;
        default: std::cout << "UNKNOWN"; break;
    }
    std::cout << " " << pattern << std::endl;
}

void Router::printRoutes() const {
    std::cout << "\n=== Registered Routes ===" << std::endl;
    for (const auto& route : routes_) {
        std::cout << "  ";
        switch (route->method) {
            case HttpMethod::GET: std::cout << "GET    "; break;
            case HttpMethod::POST: std::cout << "POST   "; break;
            case HttpMethod::PUT: std::cout << "PUT    "; break;
            case HttpMethod::DELETE: std::cout << "DELETE "; break;
            case HttpMethod::OPTIONS: std::cout << "OPTIONS"; break;
            default: std::cout << "UNKNOWN"; break;
        }
        std::cout << " " << route->pattern << std::endl;
    }
    std::cout << "Total routes: " << routes_.size() << std::endl;
    std::cout << "========================\n" << std::endl;
}