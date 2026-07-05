#include "Mail.h"

#include <curl/curl.h>

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>

namespace fh::mail {

namespace {

// Read env var, or empty string if unset.
std::string env(const char* name) {
    const char* v = std::getenv(name);
    return v ? std::string{v} : std::string{};
}

// Strip enclosing angle brackets and trim.  We accept either
// "jbreslin@foo.org" or "<jbreslin@foo.org>" in env.
std::string bareAddress(std::string s) {
    while (!s.empty() && (s.front() == ' ' || s.front() == '<')) s.erase(s.begin());
    while (!s.empty() && (s.back()  == ' ' || s.back()  == '>')) s.pop_back();
    return s;
}

// Header-encode any non-ASCII characters in a display name using
// RFC 2047 "encoded-word" syntax.  Keeps ASCII names byte-for-byte
// (so "Football Home" stays readable) and only escapes when needed.
// Also always wraps in quotes so commas and special chars are safe.
std::string encodeDisplayName(const std::string& name) {
    if (name.empty()) return "";
    bool nonAscii = false;
    for (unsigned char c : name) {
        if (c > 127) { nonAscii = true; break; }
    }
    if (!nonAscii) {
        // Quote-escape any embedded quotes and backslashes.
        std::string out;
        out.reserve(name.size() + 2);
        out.push_back('"');
        for (char c : name) {
            if (c == '"' || c == '\\') out.push_back('\\');
            out.push_back(c);
        }
        out.push_back('"');
        return out;
    }
    // RFC 2047 UTF-8 base64.  Simple encode is fine here — display names
    // are short.
    static const char* B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string enc;
    enc.reserve(((name.size() + 2) / 3) * 4);
    for (size_t i = 0; i < name.size(); i += 3) {
        unsigned int v = 0;
        int n = 0;
        for (int j = 0; j < 3; ++j) {
            v <<= 8;
            if (i + j < name.size()) { v |= (unsigned char)name[i + j]; ++n; }
        }
        enc.push_back(B64[(v >> 18) & 0x3f]);
        enc.push_back(B64[(v >> 12) & 0x3f]);
        enc.push_back(n >= 2 ? B64[(v >> 6) & 0x3f] : '=');
        enc.push_back(n >= 3 ? B64[v & 0x3f]        : '=');
    }
    return "=?UTF-8?B?" + enc + "?=";
}

// Build the full RFC 5322 message payload, ending each line with CRLF
// and ending the payload with a trailing CRLF.  libcurl's SMTP path
// expects exactly this.
std::string buildMessage(const std::string& fromAddr,
                         const std::string& fromName,
                         const std::string& toAddr,
                         const std::string& subject,
                         const std::string& body,
                         const std::string& replyTo)
{
    // Build a compliant Date: header — RFC 5322 format, GMT.
    std::string dateStr;
    {
        std::time_t now = std::time(nullptr);
        std::tm tm{};
        gmtime_r(&now, &tm);
        char buf[64];
        // %a, %d %b %Y %H:%M:%S +0000
        std::strftime(buf, sizeof buf, "%a, %d %b %Y %H:%M:%S +0000", &tm);
        dateStr = buf;
    }

    // Message-Id: random suffix keyed off timestamp is enough for
    // uniqueness; we don't loop-detect against ourselves.
    std::string messageId;
    {
        std::ostringstream oss;
        oss << "<" << std::hex << std::time(nullptr) << "."
            << std::hex << (unsigned)std::rand() << "@footballhome>";
        messageId = oss.str();
    }

    std::string fromHeader;
    {
        std::string enc = encodeDisplayName(fromName);
        if (enc.empty()) fromHeader = fromAddr;
        else             fromHeader = enc + " <" + fromAddr + ">";
    }

    std::ostringstream m;
    m << "Date: "         << dateStr    << "\r\n"
      << "From: "         << fromHeader << "\r\n"
      << "To: "           << "<" << toAddr << ">\r\n"
      << "Message-Id: "   << messageId  << "\r\n"
      << "Subject: "      << subject    << "\r\n";
    if (!replyTo.empty()) {
        m << "Reply-To: <" << replyTo << ">\r\n";
    }
    m << "MIME-Version: 1.0\r\n"
      << "Content-Type: text/plain; charset=utf-8\r\n"
      << "Content-Transfer-Encoding: 8bit\r\n"
      << "\r\n";  // header/body separator

    // Body: normalise line endings to CRLF and dot-stuff any line that
    // starts with '.' so SMTP does not misread it as end-of-data.
    for (size_t i = 0; i < body.size();) {
        // Consume optional \r
        bool sawCR = false;
        if (body[i] == '\r') { sawCR = true; ++i; if (i >= body.size()) break; }
        if (body[i] == '\n' || sawCR) {
            m << "\r\n";
            if (body[i] == '\n') ++i;
            continue;
        }
        // Copy up to next \r or \n
        size_t start = i;
        while (i < body.size() && body[i] != '\r' && body[i] != '\n') ++i;
        // Dot-stuff on line start
        if (body[start] == '.') m << '.';
        m.write(body.data() + start, static_cast<std::streamsize>(i - start));
    }
    m << "\r\n";
    return m.str();
}

// Read buffer used by libcurl's CURLOPT_READFUNCTION.
struct ReadContext {
    const std::string* payload;
    size_t offset;
};

size_t readCallback(char* buffer, size_t size, size_t nitems, void* userdata) {
    auto* ctx = static_cast<ReadContext*>(userdata);
    if (!ctx || !ctx->payload) return 0;
    size_t remaining = ctx->payload->size() - ctx->offset;
    if (remaining == 0) return 0;
    size_t want = size * nitems;
    size_t give = remaining < want ? remaining : want;
    std::memcpy(buffer, ctx->payload->data() + ctx->offset, give);
    ctx->offset += give;
    return give;
}

} // namespace

bool isConfigured() {
    return !env("SMTP_HOST").empty()
        && !env("SMTP_USER").empty()
        && !env("SMTP_PASS").empty();
}

bool send(const std::string& toEmail,
          const std::string& subject,
          const std::string& body,
          const Options& opts)
{
    // Guard: never crash the caller on missing config — return false so
    // callers can degrade gracefully (still ack the request, just don't
    // deliver mail).
    const std::string smtpHost = env("SMTP_HOST");
    const std::string smtpUser = env("SMTP_USER");
    const std::string smtpPass = env("SMTP_PASS");
    if (smtpHost.empty() || smtpUser.empty() || smtpPass.empty()) {
        std::cerr << "[mail] SMTP not configured — skipping send to "
                  << toEmail << " (subject: " << subject << ")\n";
        return false;
    }

    const std::string smtpPort   = env("SMTP_PORT").empty() ? std::string("587") : env("SMTP_PORT");
    const std::string mailFrom   = bareAddress(env("MAIL_FROM").empty() ? smtpUser : env("MAIL_FROM"));
    const std::string fromName   = env("MAIL_FROM_NAME");
    const std::string toAddr     = bareAddress(toEmail);

    if (toAddr.empty() || toAddr.find('@') == std::string::npos) {
        std::cerr << "[mail] invalid recipient: " << toEmail << "\n";
        return false;
    }

    // Sanitize subject — strip CR/LF to prevent header injection.
    std::string safeSubject;
    safeSubject.reserve(subject.size());
    for (char c : subject) {
        if (c != '\r' && c != '\n') safeSubject.push_back(c);
    }

    const std::string payload = buildMessage(mailFrom, fromName, toAddr,
                                             safeSubject, body, opts.replyTo);

    CURL* curl = curl_easy_init();
    if (!curl) {
        std::cerr << "[mail] curl_easy_init failed\n";
        return false;
    }

    // Use smtps://host:port for implicit TLS on 465; smtp://host:port
    // with STARTTLS for 587.  Gmail supports both; we key off the port.
    const bool implicitTls = (smtpPort == "465");
    const std::string url =
        (implicitTls ? std::string("smtps://") : std::string("smtp://"))
        + smtpHost + ":" + smtpPort;

    curl_easy_setopt(curl, CURLOPT_URL,          url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERNAME,     smtpUser.c_str());
    curl_easy_setopt(curl, CURLOPT_PASSWORD,     smtpPass.c_str());
    if (!implicitTls) {
        curl_easy_setopt(curl, CURLOPT_USE_SSL, static_cast<long>(CURLUSESSL_ALL));
    }
    curl_easy_setopt(curl, CURLOPT_MAIL_FROM,    ("<" + mailFrom + ">").c_str());

    // Add single recipient.  curl_slist owns its strings; free at end.
    struct curl_slist* rcpts = nullptr;
    rcpts = curl_slist_append(rcpts, ("<" + toAddr + ">").c_str());
    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, rcpts);

    ReadContext rctx{&payload, 0};
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, readCallback);
    curl_easy_setopt(curl, CURLOPT_READDATA,     &rctx);
    curl_easy_setopt(curl, CURLOPT_UPLOAD,       1L);

    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 15L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT,        30L);

    // Enable verbose logging when SMTP_DEBUG=1 — useful during rollout,
    // silent by default.
    if (env("SMTP_DEBUG") == "1") {
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
    }

    CURLcode rc = curl_easy_perform(curl);
    long lastResp = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &lastResp);

    if (rc != CURLE_OK) {
        std::cerr << "[mail] send to " << toAddr << " failed: "
                  << curl_easy_strerror(rc)
                  << " (last SMTP resp=" << lastResp << ")\n";
    } else {
        std::cerr << "[mail] delivered to " << toAddr
                  << " (last SMTP resp=" << lastResp << ")\n";
    }

    curl_slist_free_all(rcpts);
    curl_easy_cleanup(curl);
    return rc == CURLE_OK;
}

} // namespace fh::mail
