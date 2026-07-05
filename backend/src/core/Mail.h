#pragma once

#include <string>

// Mail — minimal libcurl-backed SMTP send helper.
//
// Reads all connection config from the process environment:
//
//     SMTP_HOST       e.g. smtp.gmail.com
//     SMTP_PORT       e.g. 587   (defaults to 587 if unset)
//     SMTP_USER       full mailbox address, e.g. jbreslin@footballhome.org
//     SMTP_PASS       app password (Gmail: myaccount.google.com/apppasswords)
//     MAIL_FROM       envelope + header From address (falls back to SMTP_USER)
//     MAIL_FROM_NAME  optional display name, e.g. "Football Home"
//
// When SMTP_HOST or SMTP_USER is unset send() returns false without ever
// touching the network — callers can treat this as "email not configured"
// and log/degrade gracefully (e.g. still return ok:true from the API to
// avoid leaking account existence via response timing).
namespace fh::mail {

struct Options {
    // Optional per-call override for the reply-to header.  Rarely used;
    // most transactional mail leaves this empty and lets recipients reply
    // to MAIL_FROM.  When set, adds `Reply-To: <value>` to the message.
    std::string replyTo;
};

// Sends a single plaintext email through the configured SMTP relay.
// Body is the raw plaintext body (UTF-8).  Subject is header-safe (no
// CR/LF).  Returns true on RFC-conformant success (250 accepted).  On
// failure logs the error to stderr and returns false.
bool send(const std::string& toEmail,
          const std::string& subject,
          const std::string& body,
          const Options& opts = {});

// True when SMTP_HOST + SMTP_USER + SMTP_PASS are all set.  Cheap; safe
// to call on every request path.
bool isConfigured();

} // namespace fh::mail
