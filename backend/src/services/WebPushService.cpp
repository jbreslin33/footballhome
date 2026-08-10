#include "WebPushService.h"

#include "../core/Crypto.h"
#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

#include <openssl/bn.h>
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/obj_mac.h>
#include <openssl/rand.h>

#include <cstdlib>
#include <cstdint>
#include <ctime>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <vector>

using nlohmann::json;

namespace {

// ─── RAII wrappers ──────────────────────────────────────────────────
struct PkeyFreer  { void operator()(EVP_PKEY*   k) const { if (k) EVP_PKEY_free(k); } };
struct MdCtxFreer { void operator()(EVP_MD_CTX* c) const { if (c) EVP_MD_CTX_free(c); } };
struct CipherCtxFreer { void operator()(EVP_CIPHER_CTX* c) const { if (c) EVP_CIPHER_CTX_free(c); } };
using PkeyPtr      = std::unique_ptr<EVP_PKEY, PkeyFreer>;
using MdCtxPtr      = std::unique_ptr<EVP_MD_CTX, MdCtxFreer>;
using CipherCtxPtr  = std::unique_ptr<EVP_CIPHER_CTX, CipherCtxFreer>;

// ─── EC (P-256) key construction ────────────────────────────────────
// Web Push keys travel as raw uncompressed points / scalars (not PEM),
// so we build EVP_PKEYs from raw bytes via the legacy EC_KEY API —
// still fully supported in OpenSSL 3.0, just not the newest
// provider-based idiom. Every EC_KEY here is explicitly set to
// uncompressed-point encoding so EVP_PKEY_get1_encoded_public_key
// always returns the 65-byte 0x04||X||Y form the spec expects.

PkeyPtr ecFromRawPrivate(const std::string& raw32) {
    if (raw32.size() != 32) throw std::runtime_error("WebPushService: private scalar must be 32 bytes");
    EC_KEY* ec = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
    if (!ec) throw std::runtime_error("EC_KEY_new_by_curve_name failed");
    EC_KEY_set_conv_form(ec, POINT_CONVERSION_UNCOMPRESSED);
    BIGNUM* bn = BN_bin2bn(reinterpret_cast<const unsigned char*>(raw32.data()), 32, nullptr);
    if (!bn || !EC_KEY_set_private_key(ec, bn)) {
        if (bn) BN_free(bn);
        EC_KEY_free(ec);
        throw std::runtime_error("EC_KEY_set_private_key failed");
    }
    const EC_GROUP* group = EC_KEY_get0_group(ec);
    EC_POINT* pub = EC_POINT_new(group);
    if (!pub || !EC_POINT_mul(group, pub, bn, nullptr, nullptr, nullptr) ||
        !EC_KEY_set_public_key(ec, pub)) {
        if (pub) EC_POINT_free(pub);
        BN_free(bn);
        EC_KEY_free(ec);
        throw std::runtime_error("EC public-key derivation failed");
    }
    EC_POINT_free(pub);
    BN_free(bn);
    EVP_PKEY* pkey = EVP_PKEY_new();
    EVP_PKEY_assign_EC_KEY(pkey, ec);  // pkey now owns ec
    return PkeyPtr(pkey);
}

PkeyPtr ecFromRawPublic(const std::string& raw65) {
    if (raw65.size() != 65 || static_cast<unsigned char>(raw65[0]) != 0x04) {
        throw std::runtime_error("WebPushService: expected 65-byte uncompressed EC point");
    }
    EC_KEY* ec = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
    if (!ec) throw std::runtime_error("EC_KEY_new_by_curve_name failed");
    EC_KEY_set_conv_form(ec, POINT_CONVERSION_UNCOMPRESSED);
    const EC_GROUP* group = EC_KEY_get0_group(ec);
    EC_POINT* pt = EC_POINT_new(group);
    if (!pt || !EC_POINT_oct2point(group, pt,
                                    reinterpret_cast<const unsigned char*>(raw65.data()),
                                    raw65.size(), nullptr) ||
        !EC_KEY_set_public_key(ec, pt)) {
        if (pt) EC_POINT_free(pt);
        EC_KEY_free(ec);
        throw std::runtime_error("WebPushService: malformed subscriber public key");
    }
    EC_POINT_free(pt);
    EVP_PKEY* pkey = EVP_PKEY_new();
    EVP_PKEY_assign_EC_KEY(pkey, ec);
    return PkeyPtr(pkey);
}

PkeyPtr ecGenerateEphemeral() {
    EC_KEY* ec = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
    if (!ec) throw std::runtime_error("EC_KEY_new_by_curve_name failed");
    EC_KEY_set_conv_form(ec, POINT_CONVERSION_UNCOMPRESSED);
    if (!EC_KEY_generate_key(ec)) {
        EC_KEY_free(ec);
        throw std::runtime_error("EC_KEY_generate_key failed");
    }
    EVP_PKEY* pkey = EVP_PKEY_new();
    EVP_PKEY_assign_EC_KEY(pkey, ec);
    return PkeyPtr(pkey);
}

std::string ecPublicKeyBytes(EVP_PKEY* pkey) {
    unsigned char* buf = nullptr;
    size_t len = EVP_PKEY_get1_encoded_public_key(pkey, &buf);
    if (len == 0 || !buf) throw std::runtime_error("EVP_PKEY_get1_encoded_public_key failed");
    std::string out(reinterpret_cast<char*>(buf), len);
    OPENSSL_free(buf);
    return out;
}

std::string ecdhSharedSecret(EVP_PKEY* priv, EVP_PKEY* peerPub) {
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new(priv, nullptr);
    if (!ctx) throw std::runtime_error("EVP_PKEY_CTX_new failed");
    std::string out;
    if (EVP_PKEY_derive_init(ctx) <= 0 ||
        EVP_PKEY_derive_set_peer(ctx, peerPub) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        throw std::runtime_error("ECDH derive init failed");
    }
    size_t len = 0;
    EVP_PKEY_derive(ctx, nullptr, &len);
    out.resize(len);
    if (EVP_PKEY_derive(ctx, reinterpret_cast<unsigned char*>(&out[0]), &len) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        throw std::runtime_error("ECDH derive failed");
    }
    out.resize(len);
    EVP_PKEY_CTX_free(ctx);
    return out;
}

std::string randomBytes(size_t n) {
    std::string out(n, '\0');
    if (RAND_bytes(reinterpret_cast<unsigned char*>(&out[0]), static_cast<int>(n)) != 1) {
        throw std::runtime_error("RAND_bytes failed");
    }
    return out;
}

// ─── HKDF (RFC 5869), built from Crypto.h's HMAC-SHA256 ────────────
// Every derivation in RFC 8291/8188 needs at most 32 output bytes —
// one HMAC block — so the general multi-block Expand loop isn't
// needed; Extract is literally HMAC(salt, ikm), which is exactly
// fh::crypto::hmacSha256's (key, data) signature already.
std::string hkdfExtract(const std::string& salt, const std::string& ikm) {
    return fh::crypto::hmacSha256(salt, ikm);
}
std::string hkdfExpandOneBlock(const std::string& prk, const std::string& info, size_t len) {
    std::string t = fh::crypto::hmacSha256(prk, info + std::string(1, '\x01'));
    if (len > t.size()) throw std::runtime_error("hkdfExpandOneBlock: len exceeds one HMAC block");
    return t.substr(0, len);
}

std::string aes128GcmEncrypt(const std::string& key16, const std::string& nonce12,
                              const std::string& plaintext) {
    CipherCtxPtr ctx(EVP_CIPHER_CTX_new());
    if (!ctx) throw std::runtime_error("EVP_CIPHER_CTX_new failed");
    if (EVP_EncryptInit_ex(ctx.get(), EVP_aes_128_gcm(), nullptr, nullptr, nullptr) != 1 ||
        EVP_CIPHER_CTX_ctrl(ctx.get(), EVP_CTRL_GCM_SET_IVLEN, static_cast<int>(nonce12.size()), nullptr) != 1 ||
        EVP_EncryptInit_ex(ctx.get(), nullptr, nullptr,
                            reinterpret_cast<const unsigned char*>(key16.data()),
                            reinterpret_cast<const unsigned char*>(nonce12.data())) != 1) {
        throw std::runtime_error("AES-GCM init failed");
    }
    std::string out(plaintext.size(), '\0');
    int outLen = 0;
    if (EVP_EncryptUpdate(ctx.get(), reinterpret_cast<unsigned char*>(&out[0]), &outLen,
                           reinterpret_cast<const unsigned char*>(plaintext.data()),
                           static_cast<int>(plaintext.size())) != 1) {
        throw std::runtime_error("AES-GCM encrypt failed");
    }
    int finalLen = 0;
    unsigned char finalBuf[16];
    if (EVP_EncryptFinal_ex(ctx.get(), finalBuf, &finalLen) != 1) {
        throw std::runtime_error("AES-GCM finalize failed");
    }
    out.resize(outLen);
    out.append(reinterpret_cast<char*>(finalBuf), finalLen);
    unsigned char tag[16];
    if (EVP_CIPHER_CTX_ctrl(ctx.get(), EVP_CTRL_GCM_GET_TAG, 16, tag) != 1) {
        throw std::runtime_error("AES-GCM get-tag failed");
    }
    out.append(reinterpret_cast<char*>(tag), 16);
    return out;
}

std::string signEs256Raw(EVP_PKEY* key, const std::string& signingInput) {
    MdCtxPtr ctx(EVP_MD_CTX_new());
    if (!ctx) throw std::runtime_error("EVP_MD_CTX_new failed");
    if (EVP_DigestSignInit(ctx.get(), nullptr, EVP_sha256(), nullptr, key) != 1) {
        throw std::runtime_error("EVP_DigestSignInit (ES256) failed");
    }
    if (EVP_DigestSignUpdate(ctx.get(), signingInput.data(), signingInput.size()) != 1) {
        throw std::runtime_error("EVP_DigestSignUpdate (ES256) failed");
    }
    size_t derLen = 0;
    if (EVP_DigestSignFinal(ctx.get(), nullptr, &derLen) != 1) {
        throw std::runtime_error("EVP_DigestSignFinal size (ES256) failed");
    }
    std::string der(derLen, '\0');
    if (EVP_DigestSignFinal(ctx.get(), reinterpret_cast<unsigned char*>(&der[0]), &derLen) != 1) {
        throw std::runtime_error("EVP_DigestSignFinal (ES256) failed");
    }
    der.resize(derLen);

    // JOSE ES256 wants raw r||s (32+32 bytes, zero-padded), not the
    // DER SEQUENCE{INTEGER r, INTEGER s} that EVP_DigestSignFinal
    // produces for an EC key — convert.
    const unsigned char* p = reinterpret_cast<const unsigned char*>(der.data());
    ECDSA_SIG* sig = d2i_ECDSA_SIG(nullptr, &p, static_cast<long>(der.size()));
    if (!sig) throw std::runtime_error("d2i_ECDSA_SIG failed");
    const BIGNUM* r = nullptr;
    const BIGNUM* s = nullptr;
    ECDSA_SIG_get0(sig, &r, &s);
    std::string out(64, '\0');
    BN_bn2binpad(r, reinterpret_cast<unsigned char*>(&out[0]), 32);
    BN_bn2binpad(s, reinterpret_cast<unsigned char*>(&out[0]) + 32, 32);
    ECDSA_SIG_free(sig);
    return out;
}

void putU32BE(std::string& out, uint32_t v) {
    out.push_back(static_cast<char>((v >> 24) & 0xFF));
    out.push_back(static_cast<char>((v >> 16) & 0xFF));
    out.push_back(static_cast<char>((v >> 8) & 0xFF));
    out.push_back(static_cast<char>(v & 0xFF));
}

// Origin ("scheme://host[:port]") of a push endpoint URL — the VAPID
// JWT's "aud" claim, per RFC 8292 §2.
std::string originFromUrl(const std::string& url) {
    auto schemeEnd = url.find("://");
    if (schemeEnd == std::string::npos) return url;
    auto hostStart = schemeEnd + 3;
    auto pathStart = url.find('/', hostStart);
    return pathStart == std::string::npos ? url : url.substr(0, pathStart);
}

const std::string& vapidPrivateKeyRaw() {
    static const std::string key = [] {
        const char* v = std::getenv("VAPID_PRIVATE_KEY");
        if (!v || !*v) {
            std::cerr << "[WebPushService] VAPID_PRIVATE_KEY not set — push sends will fail" << std::endl;
            return std::string{};
        }
        return fh::crypto::base64UrlDecode(v);
    }();
    return key;
}

const std::string& vapidSubject() {
    static const std::string sub = [] {
        const char* v = std::getenv("VAPID_SUBJECT");
        return std::string(v && *v ? v : "mailto:soccer@lighthouse1893.org");
    }();
    return sub;
}

}  // namespace

WebPushService& WebPushService::getInstance() {
    static WebPushService instance;
    return instance;
}

std::string WebPushService::vapidPublicKeyB64Url() {
    PkeyPtr key = ecFromRawPrivate(vapidPrivateKeyRaw());
    return fh::crypto::base64UrlEncode(ecPublicKeyBytes(key.get()));
}

std::string WebPushService::vapidAuthHeader(const std::string& audienceOrigin) {
    const long long now = static_cast<long long>(std::time(nullptr));
    const long long exp = now + 12 * 3600;  // RFC 8292 recommends <= 24h

    json payload = {
        {"aud", audienceOrigin},
        {"exp", exp},
        {"sub", vapidSubject()},
    };
    static const std::string kHeaderJson = R"({"typ":"JWT","alg":"ES256"})";
    const std::string headerB64  = fh::crypto::base64UrlEncode(kHeaderJson);
    const std::string payloadB64 = fh::crypto::base64UrlEncode(payload.dump());
    const std::string signingInput = headerB64 + "." + payloadB64;

    PkeyPtr key = ecFromRawPrivate(vapidPrivateKeyRaw());
    const std::string sigB64 = fh::crypto::base64UrlEncode(signEs256Raw(key.get(), signingInput));
    const std::string jwt = signingInput + "." + sigB64;

    return "vapid t=" + jwt + ", k=" + fh::crypto::base64UrlEncode(ecPublicKeyBytes(key.get()));
}

std::string WebPushService::encryptPayload(const std::string& plaintext,
                                            const std::string& p256dhKeyB64Url,
                                            const std::string& authKeyB64Url) {
    const std::string uaPublicRaw = fh::crypto::base64UrlDecode(p256dhKeyB64Url);  // subscriber's 65-byte point
    const std::string authSecret  = fh::crypto::base64UrlDecode(authKeyB64Url);    // 16 bytes

    PkeyPtr uaPub = ecFromRawPublic(uaPublicRaw);
    PkeyPtr as    = ecGenerateEphemeral();
    const std::string asPublicRaw = ecPublicKeyBytes(as.get());

    // Stage 1 (RFC 8291 §3.3): combine the ECDH secret with the
    // subscription's auth secret into a 32-byte IKM for stage 2.
    const std::string ecdhSecret = ecdhSharedSecret(as.get(), uaPub.get());
    const std::string keyInfo = std::string("WebPush: info") + '\0' + uaPublicRaw + asPublicRaw;
    const std::string prkCombine = hkdfExtract(/*salt=*/authSecret, /*ikm=*/ecdhSecret);
    const std::string ikm = hkdfExpandOneBlock(prkCombine, keyInfo, 32);

    // Stage 2 (RFC 8188 aes128gcm): fresh random salt per message.
    const std::string salt = randomBytes(16);
    const std::string prk  = hkdfExtract(salt, ikm);
    const std::string cek  = hkdfExpandOneBlock(prk, std::string("Content-Encoding: aes128gcm") + '\0', 16);
    const std::string nonce = hkdfExpandOneBlock(prk, std::string("Content-Encoding: nonce") + '\0', 12);

    // Single record: plaintext + 0x02 "last record" delimiter, no
    // extra padding.
    const std::string padded = plaintext + std::string(1, '\x02');
    const std::string sealed = aes128GcmEncrypt(cek, nonce, padded);

    std::string out;
    out.reserve(16 + 4 + 1 + asPublicRaw.size() + sealed.size());
    out += salt;
    putU32BE(out, 4096);  // record size — fixed; we always send exactly one record
    out.push_back(static_cast<char>(asPublicRaw.size()));
    out += asPublicRaw;
    out += sealed;
    return out;
}

bool WebPushService::sendToSubscription(const Subscription& sub, const std::string& payloadJson) {
    try {
        const std::string body = encryptPayload(payloadJson, sub.p256dhKeyB64Url, sub.authKeyB64Url);
        const std::string auth = vapidAuthHeader(originFromUrl(sub.endpoint));

        HttpClient http;
        HttpClient::Headers headers = {
            {"Content-Encoding", "aes128gcm"},
            {"TTL", "86400"},
            {"Authorization", auth},
        };
        auto resp = http.post(sub.endpoint, body, "application/octet-stream", headers);

        if (resp.status == 404 || resp.status == 410) {
            Database::getInstance()->query(
                "DELETE FROM push_subscriptions WHERE id = $1::bigint",
                {std::to_string(sub.id)});
            std::cout << "[WebPushService] pruned dead subscription id=" << sub.id
                      << " status=" << resp.status << std::endl;
            return false;
        }
        if (!resp.ok()) {
            std::cerr << "[WebPushService] send failed id=" << sub.id
                      << " status=" << resp.status << " body=" << resp.body
                      << " error=" << resp.error << std::endl;
            return false;
        }
        std::cout << "[WebPushService] sent id=" << sub.id << " status=" << resp.status << std::endl;
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[WebPushService] send exception id=" << sub.id << ": " << e.what() << std::endl;
        return false;
    }
}

int WebPushService::sendToPerson(long long personId,
                                  const std::string& title,
                                  const std::string& body,
                                  const std::string& url) {
    json payload = {{"title", title}, {"body", body}};
    if (!url.empty()) payload["url"] = url;
    const std::string payloadJson = payload.dump();

    std::vector<Subscription> subs;
    try {
        auto* db = Database::getInstance();
        auto rows = db->query(
            "SELECT id, endpoint, p256dh_key, auth_key FROM push_subscriptions "
            " WHERE person_id = $1::int",
            {std::to_string(personId)});
        subs.reserve(rows.size());
        for (const auto& row : rows) {
            subs.push_back(Subscription{
                row["id"].as<long long>(),
                row["endpoint"].as<std::string>(),
                row["p256dh_key"].as<std::string>(),
                row["auth_key"].as<std::string>(),
            });
        }
    } catch (const std::exception& e) {
        std::cerr << "[WebPushService] lookup failed for person " << personId << ": " << e.what() << std::endl;
        return 0;
    }

    int sent = 0;
    for (const auto& sub : subs) {
        if (sendToSubscription(sub, payloadJson)) sent++;
    }
    return sent;
}
