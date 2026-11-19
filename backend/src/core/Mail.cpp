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

    // Reply-To: per-call override wins; otherwise MAIL_REPLY_TO from the
    // environment (so a no-reply style sender like reminders@ still routes
    // human replies to a real mailbox); otherwise none.
    const std::string replyTo = !opts.replyTo.empty() ? bareAddress(opts.replyTo)
                                                      : bareAddress(env("MAIL_REPLY_TO"));

    const std::string payload = buildMessage(mailFrom, fromName, toAddr,
                                             safeSubject, body, replyTo);

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

namespace {

std::string base64Lines(const std::string& in) {
    static const char* B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string out;
    out.reserve(((in.size() + 2) / 3) * 4 + in.size() / 57 * 2 + 4);
    size_t col = 0;
    for (size_t i = 0; i < in.size(); i += 3) {
        unsigned int v = 0; int n = 0;
        for (int j = 0; j < 3; ++j) { v <<= 8; if (i + j < in.size()) { v |= (unsigned char)in[i + j]; ++n; } }
        out.push_back(B64[(v >> 18) & 0x3f]);
        out.push_back(B64[(v >> 12) & 0x3f]);
        out.push_back(n >= 2 ? B64[(v >> 6) & 0x3f] : '=');
        out.push_back(n >= 3 ? B64[v & 0x3f] : '=');
        col += 4;
        if (col >= 76) { out += "\r\n"; col = 0; }
    }
    if (col) out += "\r\n";
    return out;
}

// Keep a filename header-safe: ASCII letters, digits, . _ - and spaces.
std::string safeFilename(const std::string& name) {
    std::string out;
    for (unsigned char c : name) {
        if (std::isalnum(c) || c == '.' || c == '_' || c == '-' || c == ' ') out.push_back(static_cast<char>(c));
        else if (c == '/' || c == '\\') out.push_back('_');
    }
    while (!out.empty() && (out.front() == '.' || out.front() == ' ')) out.erase(out.begin());
    if (out.empty()) out = "file";
    return out.substr(0, 120);
}

std::string headerSafe(const std::string& s) {
    std::string out;
    for (char c : s) if (c != '\r' && c != '\n') out.push_back(c);
    return out;
}

// The body as CRLF lines.  No dot-stuffing here: libcurl's SMTP upload
// escapes a leading '.' itself (Curl_smtp_escape_eob) — stuffing twice
// shows the recipient "..".
std::string crlfBody(const std::string& body) {
    std::string out;
    for (size_t i = 0; i < body.size(); ++i) {
        char c = body[i];
        if (c == '\r') continue;
        if (c == '\n') { out += "\r\n"; continue; }
        out.push_back(c);
    }
    out += "\r\n";
    return out;
}

// A header value: ASCII as is, anything else as one RFC 2047 UTF-8 word.
std::string encodeHeaderText(const std::string& text) {
    bool nonAscii = false;
    for (unsigned char c : text) if (c > 127) { nonAscii = true; break; }
    if (!nonAscii) return text;
    std::string q = encodeDisplayName(text);   // "=?UTF-8?B?…?=" for non-ASCII
    return q;
}

} // namespace

std::string composeMessage(const Message& msg, std::vector<std::string>* rcptOut) {
    const std::string mailFrom = bareAddress(env("MAIL_FROM").empty() ? env("SMTP_USER") : env("MAIL_FROM"));
    const std::string fromName = env("MAIL_FROM_NAME");
    const std::string toAddr = bareAddress(msg.to);
    if (toAddr.empty() || toAddr.find('@') == std::string::npos) return "";
    std::vector<std::string> cc;
    for (const auto& c : msg.cc) {
        const std::string a = bareAddress(headerSafe(c));
        if (!a.empty() && a.find('@') != std::string::npos && a != toAddr
            && std::find(cc.begin(), cc.end(), a) == cc.end()) cc.push_back(a);
    }
    const std::string replyTo = !msg.replyTo.empty() ? bareAddress(headerSafe(msg.replyTo)) : bareAddress(env("MAIL_REPLY_TO"));

    char dateBuf[64];
    { std::time_t now = std::time(nullptr); std::tm tm{}; gmtime_r(&now, &tm);
      std::strftime(dateBuf, sizeof dateBuf, "%a, %d %b %Y %H:%M:%S +0000", &tm); }
    std::ostringstream idss;
    idss << std::hex << std::time(nullptr) << "." << (unsigned)std::rand();
    const std::string boundary = "fh-" + idss.str() + "-mixed";
    const std::string enc = encodeDisplayName(fromName);

    std::ostringstream m;
    m << "Date: " << dateBuf << "\r\n"
      << "From: " << (enc.empty() ? mailFrom : enc + " <" + mailFrom + ">") << "\r\n"
      << "To: <" << toAddr << ">\r\n";
    if (!cc.empty()) {
        m << "Cc: ";
        for (size_t i = 0; i < cc.size(); ++i) m << (i ? ", " : "") << "<" << cc[i] << ">";
        m << "\r\n";
    }
    m << "Message-Id: <" << idss.str() << "@footballhome>\r\n"
      << "Subject: " << encodeHeaderText(headerSafe(msg.subject)) << "\r\n";
    if (!replyTo.empty()) m << "Reply-To: <" << replyTo << ">\r\n";
    m << "MIME-Version: 1.0\r\n"
      << "Content-Type: multipart/mixed; boundary=\"" << boundary << "\"\r\n\r\n"
      << "--" << boundary << "\r\n"
      << "Content-Type: text/plain; charset=utf-8\r\n"
      << "Content-Transfer-Encoding: 8bit\r\n\r\n"
      << crlfBody(msg.body);
    for (const auto& a : msg.attachments) {
        const std::string fn = safeFilename(a.filename);
        m << "--" << boundary << "\r\n"
          << "Content-Type: " << (a.mime.empty() ? "application/octet-stream" : headerSafe(a.mime)) << "; name=\"" << fn << "\"\r\n"
          << "Content-Transfer-Encoding: base64\r\n"
          << "Content-Disposition: attachment; filename=\"" << fn << "\"\r\n\r\n"
          << base64Lines(a.bytes);
    }
    m << "--" << boundary << "--\r\n";
    if (rcptOut) { rcptOut->clear(); rcptOut->push_back(toAddr); for (const auto& c : cc) rcptOut->push_back(c); }
    return m.str();
}


bool sendMessage(const Message& msg) {
    const std::string smtpHost = env("SMTP_HOST");
    const std::string smtpUser = env("SMTP_USER");
    const std::string smtpPass = env("SMTP_PASS");
    if (smtpHost.empty() || smtpUser.empty() || smtpPass.empty()) {
        std::cerr << "[mail] SMTP not configured — skipping message to " << msg.to << "\n";
        return false;
    }
    const std::string smtpPort = env("SMTP_PORT").empty() ? std::string("587") : env("SMTP_PORT");
    const std::string mailFrom = bareAddress(env("MAIL_FROM").empty() ? smtpUser : env("MAIL_FROM"));
    std::vector<std::string> rcpt;
    const std::string payload = composeMessage(msg, &rcpt);
    if (payload.empty()) { std::cerr << "[mail] invalid recipient: " << msg.to << "\n"; return false; }
    const std::string toAddr = rcpt[0];
    const std::vector<std::string> cc(rcpt.begin() + 1, rcpt.end());
    CURL* curl = curl_easy_init();
    if (!curl) { std::cerr << "[mail] curl_easy_init failed\n"; return false; }
    const bool implicitTls = (smtpPort == "465");
    const std::string url = (implicitTls ? std::string("smtps://") : std::string("smtp://")) + smtpHost + ":" + smtpPort;
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERNAME, smtpUser.c_str());
    curl_easy_setopt(curl, CURLOPT_PASSWORD, smtpPass.c_str());
    if (!implicitTls) curl_easy_setopt(curl, CURLOPT_USE_SSL, static_cast<long>(CURLUSESSL_ALL));
    curl_easy_setopt(curl, CURLOPT_MAIL_FROM, ("<" + mailFrom + ">").c_str());
    struct curl_slist* rcpts = curl_slist_append(nullptr, ("<" + toAddr + ">").c_str());
    for (const auto& c : cc) rcpts = curl_slist_append(rcpts, ("<" + c + ">").c_str());
    curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, rcpts);
    ReadContext rctx{&payload, 0};
    curl_easy_setopt(curl, CURLOPT_READFUNCTION, readCallback);
    curl_easy_setopt(curl, CURLOPT_READDATA, &rctx);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 15L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 90L);
    if (env("SMTP_DEBUG") == "1") curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
    CURLcode rc = curl_easy_perform(curl);
    long lastResp = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &lastResp);
    if (rc != CURLE_OK)
        std::cerr << "[mail] message to " << toAddr << " failed: " << curl_easy_strerror(rc) << " (last SMTP resp=" << lastResp << ")\n";
    else
        std::cerr << "[mail] message delivered to " << toAddr << " +" << cc.size() << " cc, "
                  << msg.attachments.size() << " attachment(s) (last SMTP resp=" << lastResp << ")\n";
    curl_slist_free_all(rcpts);
    curl_easy_cleanup(curl);
    return rc == CURLE_OK;
}

} // namespace fh::mail
