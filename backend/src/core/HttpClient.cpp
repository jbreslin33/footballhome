#include "HttpClient.h"
#include <curl/curl.h>
#include <cctype>
#include <iomanip>
#include <iostream>
#include <sstream>

namespace {

// Reasonable defaults.  Tweak via env later if any LA endpoint proves slow.
constexpr long kConnectTimeoutSec = 10;
constexpr long kTotalTimeoutSec   = 30;
constexpr const char* kUserAgent  = "footballhome-cpp/1.0";

} // namespace

HttpClient::HttpClient() {
    // No global init/cleanup here — libcurl tolerates multiple easy handles
    // without curl_global_init when libcurl was built with thread-safe init
    // (the OpenSSL-backed Debian package is).
}

size_t HttpClient::writeCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    const size_t total = size * nmemb;
    static_cast<std::string*>(userp)->append(static_cast<char*>(contents), total);
    return total;
}

std::string HttpClient::urlEncode(const std::string& in) {
    std::ostringstream out;
    out.fill('0');
    out << std::hex;
    for (unsigned char c : in) {
        if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            out << static_cast<char>(c);
        } else {
            out << std::uppercase
                << '%' << std::setw(2) << static_cast<int>(c)
                << std::nouppercase;
        }
    }
    return out.str();
}

HttpClient::Response HttpClient::get(const std::string& url,
                                     const Headers& headers,
                                     const std::string& unixSocketPath) {
    return perform(url, "GET", {}, {}, headers, unixSocketPath);
}

HttpClient::Response HttpClient::post(const std::string& url,
                                      const std::string& body,
                                      const std::string& contentType,
                                      const Headers& headers,
                                      const std::string& unixSocketPath) {
    return perform(url, "POST", body, contentType, headers, unixSocketPath);
}

HttpClient::Response HttpClient::postForm(const std::string& url,
                                          const std::string& formBody,
                                          const Headers& headers,
                                          const std::string& unixSocketPath) {
    return perform(url, "POST", formBody,
                   "application/x-www-form-urlencoded", headers, unixSocketPath);
}

HttpClient::Response HttpClient::postJson(const std::string& url,
                                          const std::string& jsonBody,
                                          const Headers& headers,
                                          const std::string& unixSocketPath) {
    return perform(url, "POST", jsonBody, "application/json", headers, unixSocketPath);
}

HttpClient::Response HttpClient::del(const std::string& url,
                                     const Headers& headers,
                                     const std::string& unixSocketPath) {
    return perform(url, "DELETE", {}, {}, headers, unixSocketPath);
}

HttpClient::Response HttpClient::perform(const std::string& url,
                                         const std::string& method,
                                         const std::string& body,
                                         const std::string& contentType,
                                         const Headers& headers,
                                         const std::string& unixSocketPath) {
    Response resp;
    CURL* curl = curl_easy_init();
    if (!curl) {
        resp.error = "curl_easy_init failed";
        return resp;
    }

    // Build the header list (RAII-managed via the cleanup at the bottom).
    struct curl_slist* slist = nullptr;
    if (!contentType.empty()) {
        slist = curl_slist_append(slist, ("Content-Type: " + contentType).c_str());
    }
    for (const auto& [name, value] : headers) {
        slist = curl_slist_append(slist, (name + ": " + value).c_str());
    }

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERAGENT, kUserAgent);
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, kConnectTimeoutSec);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, kTotalTimeoutSec);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 5L);
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);          // signal-safe under threads
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &resp.body);

    if (!unixSocketPath.empty()) {
        curl_easy_setopt(curl, CURLOPT_UNIX_SOCKET_PATH, unixSocketPath.c_str());
    }

    if (slist) {
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, slist);
    }

    if (method == "POST") {
        curl_easy_setopt(curl, CURLOPT_POST, 1L);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, static_cast<long>(body.size()));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body.data());
    } else if (method == "DELETE") {
        // libcurl's CURLOPT_CUSTOMREQUEST lets any method name ride on
        // the same code path. No body — DELETE requests over the podman
        // API use query-string parameters (`?force=true`, etc.).
        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
    }
    // GET is curl's default; no extra setup needed.

    const CURLcode rc = curl_easy_perform(curl);
    if (rc != CURLE_OK) {
        resp.error  = curl_easy_strerror(rc);
        resp.status = 0;
        std::cerr << "[HttpClient] " << method << ' ' << url
                  << " transport error: " << resp.error << std::endl;
    } else {
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &resp.status);
    }

    if (slist) curl_slist_free_all(slist);
    curl_easy_cleanup(curl);
    return resp;
}
