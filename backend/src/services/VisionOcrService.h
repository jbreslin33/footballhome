#pragma once
#include <memory>
#include <mutex>
#include <stdexcept>
#include <string>

class HttpClient;

// Thrown when the Anthropic API rejects the request or the response
// doesn't contain the expected text content. Lets the controller
// distinguish "upstream rejected us" (502) from unset configuration (500).
class VisionOcrError : public std::runtime_error {
public:
    explicit VisionOcrError(const std::string& m) : std::runtime_error(m) {}
};

// ────────────────────────────────────────────────────────────────────────────
// VisionOcrService — singleton wrapper around the Anthropic Messages API
// (https://api.anthropic.com/v1/messages) for reading text out of an
// uploaded photo (e.g. a whiteboard/notebook photo of an exercise
// description) so it can prefill a textarea for the coach to edit.
//
// Why a service: keeps the OOP layering consistent with MetaAdsService /
// LeagueAppsService (one network/state-owning class per upstream surface).
//
// Required environment (read at first use via ensureConfigured()):
//   ANTHROPIC_API_KEY     — required. No fallback; throws if unset.
//   ANTHROPIC_VISION_MODEL — optional, defaults to "claude-sonnet-5".
// ────────────────────────────────────────────────────────────────────────────
class VisionOcrService {
public:
    static VisionOcrService& getInstance();

    // `base64Data` is the raw base64 payload (no "data:...;base64," prefix).
    // `mediaType` is e.g. "image/png", "image/jpeg", "image/webp".
    // Returns the transcribed text. Throws VisionOcrError on any failure
    // (missing API key, transport error, non-2xx response, unexpected
    // response shape).
    std::string extractText(const std::string& base64Data, const std::string& mediaType);

private:
    VisionOcrService() = default;
    ~VisionOcrService() = default;
    VisionOcrService(const VisionOcrService&) = delete;
    VisionOcrService& operator=(const VisionOcrService&) = delete;

    void ensureConfigured();

    std::mutex mutex_;
    std::unique_ptr<HttpClient> http_;
    std::string apiKey_;
    std::string model_;
    bool configured_ = false;

    static constexpr const char* kApiUrl = "https://api.anthropic.com/v1/messages";
    static constexpr const char* kApiVersion = "2023-06-01";
};
