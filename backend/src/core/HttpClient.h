#pragma once
#include <string>
#include <utility>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// HttpClient — thin OOP wrapper around libcurl easy-interface.
//
// Purpose: every outbound HTTP call from the C++ backend (external APIs,
// LeagueApps OAuth + REST, Google OAuth, etc.) goes through this single
// class so we have ONE place to manage timeouts, redirect policy, TLS
// settings, and User-Agent strings.
//
// Design rules:
//   • Stateless per call.  No global handle cache, no connection pool — each
//     request owns its CURL easy handle and tears it down via RAII.
//   • Never throws on HTTP-level errors (4xx/5xx).  Returns a Response with
//     `status` filled and the caller decides.  Transport-level failures
//     (DNS, connect, TLS, timeout) surface in Response.error with
//     status = 0.
//   • Thread-safe: libcurl's easy interface is safe to call from multiple
//     threads as long as no handle is shared between them; since we build
//     a fresh handle per call this is automatic.
// ────────────────────────────────────────────────────────────────────────────
class HttpClient {
public:
    using Headers = std::vector<std::pair<std::string, std::string>>;

    struct Response {
        long status = 0;          // HTTP status code; 0 if transport failed
        std::string body;         // raw response body, possibly empty
        std::string error;        // non-empty on transport / curl-level failure
        bool ok() const { return error.empty() && status >= 200 && status < 300; }
    };

    HttpClient();
    ~HttpClient() = default;

    HttpClient(const HttpClient&) = delete;
    HttpClient& operator=(const HttpClient&) = delete;

    // Plain GET.
    Response get(const std::string& url, const Headers& headers = {});

    // POST with explicit body + content-type.
    Response post(const std::string& url,
                  const std::string& body,
                  const std::string& contentType,
                  const Headers& headers = {});

    // application/x-www-form-urlencoded convenience.  Caller is responsible
    // for url-encoding the body (e.g. via urlEncode below).
    Response postForm(const std::string& url,
                      const std::string& formBody,
                      const Headers& headers = {});

    // application/json convenience.
    Response postJson(const std::string& url,
                      const std::string& jsonBody,
                      const Headers& headers = {});

    // RFC 3986 unreserved encoding.  Pure utility; doesn't touch the wire.
    static std::string urlEncode(const std::string& in);

private:
    // Single performer used by all of the public methods.  `method` is
    // "GET" or "POST"; pass empty body+contentType for GET.
    Response perform(const std::string& url,
                     const std::string& method,
                     const std::string& body,
                     const std::string& contentType,
                     const Headers& headers);

    // libcurl write callback — appends to a std::string passed via userp.
    static size_t writeCallback(void* contents, size_t size, size_t nmemb, void* userp);
};
