#include "Crypto.h"

#include <openssl/bio.h>
#include <openssl/buffer.h>
#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/rand.h>
#include <openssl/sha.h>

#include <array>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <vector>

namespace fh::crypto {

std::string sha256Hex(const std::string& value) {
    unsigned char digest[SHA256_DIGEST_LENGTH];
    unsigned int  digest_len = 0;

    EVP_MD_CTX* ctx = EVP_MD_CTX_new();
    if (!ctx) throw std::runtime_error("EVP_MD_CTX_new failed");

    if (EVP_DigestInit_ex(ctx, EVP_sha256(), nullptr) != 1 ||
        EVP_DigestUpdate(ctx, value.data(), value.size()) != 1 ||
        EVP_DigestFinal_ex(ctx, digest, &digest_len) != 1) {
        EVP_MD_CTX_free(ctx);
        throw std::runtime_error("SHA-256 hashing failed");
    }
    EVP_MD_CTX_free(ctx);

    std::ostringstream hex;
    hex << std::hex << std::setfill('0');
    for (unsigned int i = 0; i < digest_len; ++i) {
        hex << std::setw(2) << static_cast<int>(digest[i]);
    }
    return hex.str();
}

std::string base64UrlEncode(const std::string& raw) {
    // Map every 3 input bytes → 4 output chars using the URL-safe
    // alphabet (- and _ instead of + and /), no padding.  Done by hand
    // to avoid having to post-process an OpenSSL BIO result.
    static const char kAlphabet[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    std::string out;
    out.reserve(((raw.size() + 2) / 3) * 4);

    std::size_t i = 0;
    const std::size_t n = raw.size();
    while (i + 3 <= n) {
        unsigned a = static_cast<unsigned char>(raw[i]);
        unsigned b = static_cast<unsigned char>(raw[i + 1]);
        unsigned c = static_cast<unsigned char>(raw[i + 2]);
        out.push_back(kAlphabet[(a >> 2) & 0x3F]);
        out.push_back(kAlphabet[((a << 4) | (b >> 4)) & 0x3F]);
        out.push_back(kAlphabet[((b << 2) | (c >> 6)) & 0x3F]);
        out.push_back(kAlphabet[c & 0x3F]);
        i += 3;
    }
    if (i < n) {
        unsigned a = static_cast<unsigned char>(raw[i]);
        unsigned b = (i + 1 < n) ? static_cast<unsigned char>(raw[i + 1]) : 0u;
        out.push_back(kAlphabet[(a >> 2) & 0x3F]);
        out.push_back(kAlphabet[((a << 4) | (b >> 4)) & 0x3F]);
        if (i + 1 < n) {
            out.push_back(kAlphabet[(b << 2) & 0x3F]);
        }
    }
    return out;
}

std::string randomTokenB64Url(std::size_t bytes) {
    std::vector<unsigned char> buf(bytes);
    if (RAND_bytes(buf.data(), static_cast<int>(bytes)) != 1) {
        throw std::runtime_error("RAND_bytes failed");
    }
    std::string raw(reinterpret_cast<const char*>(buf.data()), buf.size());
    return base64UrlEncode(raw);
}

std::string urlEncode(const std::string& raw) {
    static const char kHex[] = "0123456789ABCDEF";
    std::string out;
    out.reserve(raw.size());
    for (unsigned char c : raw) {
        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') ||
            c == '-' || c == '_' || c == '.' || c == '~') {
            out.push_back(static_cast<char>(c));
        } else {
            out.push_back('%');
            out.push_back(kHex[c >> 4]);
            out.push_back(kHex[c & 0x0F]);
        }
    }
    return out;
}

std::string base64UrlDecode(const std::string& encoded) {
    // Translate URL-safe alphabet back to canonical base64 and re-add
    // the padding stripped by base64UrlEncode.  Then hand off to OpenSSL's
    // BIO chain to do the actual decode.
    std::string b64 = encoded;
    for (char& c : b64) {
        if      (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    while (b64.size() % 4 != 0) b64.push_back('=');

    BIO* mem = BIO_new_mem_buf(b64.data(), static_cast<int>(b64.size()));
    BIO* b64f = BIO_new(BIO_f_base64());
    BIO_set_flags(b64f, BIO_FLAGS_BASE64_NO_NL);
    BIO* chain = BIO_push(b64f, mem);

    std::vector<char> buf(b64.size());
    const int n = BIO_read(chain, buf.data(), static_cast<int>(buf.size()));
    BIO_free_all(chain);

    if (n <= 0) return {};
    return std::string(buf.data(), static_cast<std::size_t>(n));
}

// ──────────────────────────────────────────────────────────────────────
// JWT (HS256)
// ──────────────────────────────────────────────────────────────────────

const std::string& jwtSecret() {
    // Function-local static so the secret is resolved exactly once per
    // process.  If JWT_SECRET is set in the environment we use it as-is
    // (byte-for-byte, no transforms — supports pre-shared random binary
    // via base64 or plain ASCII strings equally).  If it's missing we
    // generate 32 random bytes and warn LOUDLY: valid enough for local
    // dev but every restart invalidates every session, which nobody
    // wants in production.
    static std::once_flag once;
    static std::string cached;
    std::call_once(once, []() {
        const char* fromEnv = std::getenv("JWT_SECRET");
        if (fromEnv && *fromEnv) {
            cached.assign(fromEnv);
            std::cout << "[crypto] JWT_SECRET loaded from environment ("
                      << cached.size() << " bytes)" << std::endl;
        } else {
            // Fall back to a random per-process secret.  Base64url-encode
            // for readability in the warning; the raw bytes are what we
            // actually sign with.
            std::vector<unsigned char> raw(32);
            if (RAND_bytes(raw.data(), 32) != 1) {
                throw std::runtime_error("RAND_bytes failed generating fallback JWT secret");
            }
            cached.assign(reinterpret_cast<const char*>(raw.data()), raw.size());
            std::cerr << "[crypto] ⚠️  JWT_SECRET not set — generated an ephemeral "
                      << "32-byte secret.  ALL SESSIONS WILL BE INVALIDATED ON "
                      << "THE NEXT BACKEND RESTART.  Set JWT_SECRET in env for "
                      << "production." << std::endl;
        }
    });
    return cached;
}

std::string hmacSha256(const std::string& key, const std::string& data) {
    unsigned char out[EVP_MAX_MD_SIZE];
    unsigned int outLen = 0;
    if (!HMAC(EVP_sha256(),
              key.data(), static_cast<int>(key.size()),
              reinterpret_cast<const unsigned char*>(data.data()),
              data.size(),
              out, &outLen)) {
        throw std::runtime_error("HMAC-SHA256 failed");
    }
    return std::string(reinterpret_cast<const char*>(out), outLen);
}

std::string signJwtHS256(const std::string& payloadJson) {
    // Fixed header literal.  Kept as a constant (not built at runtime) so
    // there is exactly one issued header byte-sequence across the process.
    static const std::string kHeaderJson = R"({"alg":"HS256","typ":"JWT"})";

    const std::string headerB64  = base64UrlEncode(kHeaderJson);
    const std::string payloadB64 = base64UrlEncode(payloadJson);
    const std::string signingInput = headerB64 + "." + payloadB64;

    const std::string sigRaw = hmacSha256(jwtSecret(), signingInput);
    const std::string sigB64 = base64UrlEncode(sigRaw);

    return signingInput + "." + sigB64;
}

bool verifyJwtHS256(const std::string& token, std::string* outPayloadJson) {
    // Split on the two '.'s.  Reject anything that isn't exactly 3 parts.
    const std::size_t dot1 = token.find('.');
    if (dot1 == std::string::npos) return false;
    const std::size_t dot2 = token.find('.', dot1 + 1);
    if (dot2 == std::string::npos) return false;
    if (token.find('.', dot2 + 1) != std::string::npos) return false;

    const std::string headerB64  = token.substr(0, dot1);
    const std::string payloadB64 = token.substr(dot1 + 1, dot2 - dot1 - 1);
    const std::string sigB64     = token.substr(dot2 + 1);
    if (headerB64.empty() || payloadB64.empty() || sigB64.empty()) return false;

    // Header check — must be HS256.  We don't allow "none" here on
    // purpose; the whole point of this rewrite is that unsigned tokens
    // are no longer accepted anywhere.
    const std::string headerJson = base64UrlDecode(headerB64);
    if (headerJson.find("\"alg\"") == std::string::npos) return false;
    if (headerJson.find("\"HS256\"") == std::string::npos) return false;

    // Recompute signature over the raw base64url header.payload bytes
    // (NOT the decoded JSON — signing is done over the encoded form).
    const std::string expectedSigRaw = hmacSha256(jwtSecret(),
                                                  headerB64 + "." + payloadB64);
    const std::string providedSigRaw = base64UrlDecode(sigB64);
    if (expectedSigRaw.size() != providedSigRaw.size()) return false;
    if (CRYPTO_memcmp(expectedSigRaw.data(),
                      providedSigRaw.data(),
                      expectedSigRaw.size()) != 0) {
        return false;
    }

    // Payload decode + exp check.  We only look for "exp" as a plain
    // integer claim; that matches how signJwtHS256's callers emit it.
    const std::string payloadJson = base64UrlDecode(payloadB64);
    if (payloadJson.empty()) return false;

    static const std::regex kExpRe(R"("exp"\s*:\s*(\d+))");
    std::smatch m;
    if (std::regex_search(payloadJson, m, kExpRe)) {
        const std::time_t now = std::time(nullptr);
        try {
            const long long exp = std::stoll(m[1].str());
            if (exp < static_cast<long long>(now)) return false;
        } catch (...) {
            return false;
        }
    }

    if (outPayloadJson) *outPayloadJson = payloadJson;
    return true;
}

}  // namespace fh::crypto
