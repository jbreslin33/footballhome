#include "Crypto.h"

#include <openssl/bio.h>
#include <openssl/buffer.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/sha.h>

#include <array>
#include <cctype>
#include <cstdio>
#include <iomanip>
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

}  // namespace fh::crypto
