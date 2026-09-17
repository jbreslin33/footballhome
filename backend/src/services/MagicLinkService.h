#pragma once
#include <string>

// MagicLinkService — mints a person-scoped magic sign-in token and
// returns the verify URL that carries it.
//
// Extracted from MagicLinkAuthController::handleMint (2026-09-06) so the
// welcome message (WelcomeController) and the plain LINK buttons share
// ONE token-minting path: same TTL (SessionService::kMagicLinkTtl), same
// hashing, same magic_link_tokens row shape, same verify endpoint.
// Owner rule (2026-09-05): "any time we send the footballhome link we
// should send an auth code in the url for that person".
class MagicLinkService {
public:
    struct Minted {
        std::string url;        // https://footballhome.org/api/auth/magic-link/verify?token=…
        std::string expiresIso; // "YYYY-MM-DDTHH:MM:SS.mmmZ" (UTC)
    };

    // Public origin the verify URL is built on — PUBLIC_BASE_URL env,
    // else https://footballhome.org, never with a trailing slash.
    static const std::string& publicBaseUrl();

    // Appended to every SMS body that carries the verify URL.  iOS
    // Messages / Google Messages render links from a sender who isn't in
    // the recipient's contacts as dead plain text until the recipient
    // replies (owner 2026-09-17: "people cant click them").  Wording is
    // kept in lock-step with Screen.SMS_LINK_HINT (frontend/js/screen-base.js).
    static std::string withSmsLinkHint(const std::string& smsBody) {
        return smsBody + "\n\nLink not tappable? Reply YES, then reopen this text.";
    }

    // Inserts the token row and returns the URL.  chatEventId <= 0 and
    // adminUserId <= 0 store NULL.  Throws on DB failure.
    static Minted mint(long long          personId,
                       const std::string& channel,      // "email" | "sms"
                       const std::string& contact,
                       long long          adminUserId,
                       long long          chatEventId = 0);
};
