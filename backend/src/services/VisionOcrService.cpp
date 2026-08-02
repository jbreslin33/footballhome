#include "VisionOcrService.h"

#include <cstdlib>

#include "../core/HttpClient.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string envOr(const char* name, const std::string& fallback = {}) {
    const char* v = std::getenv(name);
    return (v && *v) ? std::string{v} : fallback;
}
} // namespace

VisionOcrService& VisionOcrService::getInstance() {
    static VisionOcrService instance;
    return instance;
}

void VisionOcrService::ensureConfigured() {
    std::lock_guard<std::mutex> lk(mutex_);
    if (configured_) return;
    apiKey_ = envOr("ANTHROPIC_API_KEY");
    model_ = envOr("ANTHROPIC_VISION_MODEL", "claude-sonnet-5");
    if (!http_) http_ = std::make_unique<HttpClient>();
    configured_ = true;
}

std::string VisionOcrService::extractText(const std::string& base64Data, const std::string& mediaType) {
    ensureConfigured();
    if (apiKey_.empty()) {
        throw VisionOcrError("Missing ANTHROPIC_API_KEY configuration");
    }

    json body = {
        {"model", model_},
        {"max_tokens", 1024},
        {"messages", json::array({
            {
                {"role", "user"},
                {"content", json::array({
                    {
                        {"type", "image"},
                        {"source", {
                            {"type", "base64"},
                            {"media_type", mediaType},
                            {"data", base64Data}
                        }}
                    },
                    {
                        {"type", "text"},
                        {"text",
                            "Transcribe all text visible in this image verbatim, preserving line "
                            "breaks. Reply with only the transcribed text and nothing else -- no "
                            "preamble, no commentary, no markdown formatting."}
                    }
                })}
            }
        })}
    };

    HttpClient::Headers headers = {
        {"x-api-key", apiKey_},
        {"anthropic-version", kApiVersion}
    };

    auto resp = http_->postJson(kApiUrl, body.dump(), headers);
    if (!resp.error.empty()) {
        throw VisionOcrError("Vision request failed: " + resp.error);
    }

    json parsed;
    try {
        parsed = json::parse(resp.body);
    } catch (const std::exception& e) {
        throw VisionOcrError(std::string{"Anthropic returned malformed JSON: "} + e.what());
    }

    if (!resp.ok()) {
        std::string message = parsed.contains("error") && parsed["error"].is_object()
            ? parsed["error"].value("message", "Anthropic API error")
            : "Anthropic API error (status " + std::to_string(resp.status) + ")";
        throw VisionOcrError(message);
    }

    if (!parsed.contains("content") || !parsed["content"].is_array() || parsed["content"].empty()) {
        throw VisionOcrError("Anthropic response had no content");
    }
    const auto& first = parsed["content"][0];
    if (!first.contains("text") || !first["text"].is_string()) {
        throw VisionOcrError("Anthropic response had no text block");
    }
    return first["text"].get<std::string>();
}
