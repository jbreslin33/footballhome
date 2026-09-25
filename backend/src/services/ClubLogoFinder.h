#pragma once
#include <memory>
#include <mutex>
#include <stdexcept>
#include <string>
#include "../third_party/json.hpp"

class HttpClient;

class ClubLogoFinderError : public std::runtime_error {
public:
    explicit ClubLogoFinderError(const std::string& m) : std::runtime_error(m) {}
};

// ────────────────────────────────────────────────────────────────────────────
// ClubLogoFinder — the part that looks on the internet (migration 432).
//
// Wraps the Anthropic Messages API (same upstream surface as
// VisionOcrService) for two questions:
//
//   search(opponent, context)  Claude, with web search + web fetch, works
//                              out which club the calendar text means and
//                              returns a direct crest image URL.
//   judge(bytes, mime, club)   Claude looks at the downloaded image and
//                              says whether it is a real crest (not a photo,
//                              placeholder, map pin, league logo …).
//
// The prompts are message_templates rows (kind = 'logo_search'); this
// class holds no wording.  Nothing here touches club tables — the
// scheduler owns the queue, ClubLogo owns the crest.
//
// Environment:  ANTHROPIC_API_KEY (required), ANTHROPIC_LOGO_MODEL
//               (optional, default claude-opus-5).
// ────────────────────────────────────────────────────────────────────────────
class ClubLogoFinder {
public:
    struct Candidate {
        std::string clubName, imageUrl, pageUrl, reason;
        double      confidence = 0;
        bool found() const { return !imageUrl.empty(); }
    };
    struct Verdict {
        bool        isCrest = false;
        double      confidence = 0;
        std::string note;
    };

    static ClubLogoFinder& getInstance();

    Candidate search(const std::string& opponentText, const std::string& context);
    Verdict   judge(const std::string& imageBytes, const std::string& mime, const std::string& clubName);
    std::string model();

private:
    ClubLogoFinder() = default;
    ClubLogoFinder(const ClubLogoFinder&) = delete;
    ClubLogoFinder& operator=(const ClubLogoFinder&) = delete;

    void ensureConfigured();
    // One Messages API call; follows pause_turn continuations for server
    // tools.  Returns the concatenated text of the final turn.
    std::string complete(nlohmann::json body);
    static constexpr const char* kApiUrl     = "https://api.anthropic.com/v1/messages";
    static constexpr const char* kApiVersion = "2023-06-01";
    static constexpr long        kTimeoutSec = 240;

    std::mutex  mutex_;
    bool        configured_ = false;
    std::string apiKey_, model_;
};
