#include "JwtRS256.h"
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <memory>
#include <stdexcept>
#include <vector>

namespace {

// RAII for OpenSSL handles.  Avoids hand-coded EVP_*_free in every branch.
struct BioFreer    { void operator()(BIO*       b) const { if (b) BIO_free(b); } };
struct PkeyFreer   { void operator()(EVP_PKEY*  k) const { if (k) EVP_PKEY_free(k); } };
struct MdCtxFreer  { void operator()(EVP_MD_CTX*c) const { if (c) EVP_MD_CTX_free(c); } };

using BioPtr   = std::unique_ptr<BIO,        BioFreer>;
using PkeyPtr  = std::unique_ptr<EVP_PKEY,   PkeyFreer>;
using MdCtxPtr = std::unique_ptr<EVP_MD_CTX, MdCtxFreer>;

// Plain base64 (with +/ and padding) into a string.
std::string base64StdEncode(const unsigned char* data, size_t len) {
    BioPtr b64(BIO_new(BIO_f_base64()));
    BioPtr mem(BIO_new(BIO_s_mem()));
    if (!b64 || !mem) throw std::runtime_error("BIO_new failed");
    BIO_set_flags(b64.get(), BIO_FLAGS_BASE64_NO_NL);
    // BIO_push transfers ownership of mem into the chain — release ours.
    BIO* chain = BIO_push(b64.get(), mem.release());
    BIO_write(chain, data, static_cast<int>(len));
    (void)BIO_flush(chain);

    BUF_MEM* mptr = nullptr;
    BIO_get_mem_ptr(chain, &mptr);
    std::string out(mptr->data, mptr->length);
    // b64's destructor frees the whole chain (b64 owns the mem BIO now).
    return out;
}

// Convert standard base64 to base64url (+/= → -_, then strip padding).
std::string toBase64Url(std::string s) {
    for (auto& c : s) {
        if      (c == '+') c = '-';
        else if (c == '/') c = '_';
    }
    while (!s.empty() && s.back() == '=') s.pop_back();
    return s;
}

PkeyPtr loadPrivateKey(const std::string& pem) {
    if (pem.empty()) throw std::runtime_error("JwtRS256: empty PEM");
    BioPtr bio(BIO_new_mem_buf(pem.data(), static_cast<int>(pem.size())));
    if (!bio) throw std::runtime_error("JwtRS256: BIO_new_mem_buf failed");
    EVP_PKEY* raw = PEM_read_bio_PrivateKey(bio.get(), nullptr, nullptr, nullptr);
    if (!raw) throw std::runtime_error("JwtRS256: PEM_read_bio_PrivateKey failed");
    return PkeyPtr(raw);
}

std::vector<unsigned char> signRs256(EVP_PKEY* key, const std::string& signingInput) {
    MdCtxPtr ctx(EVP_MD_CTX_new());
    if (!ctx) throw std::runtime_error("JwtRS256: EVP_MD_CTX_new failed");

    if (EVP_DigestSignInit(ctx.get(), nullptr, EVP_sha256(), nullptr, key) != 1) {
        throw std::runtime_error("JwtRS256: EVP_DigestSignInit failed");
    }
    if (EVP_DigestSignUpdate(ctx.get(), signingInput.data(), signingInput.size()) != 1) {
        throw std::runtime_error("JwtRS256: EVP_DigestSignUpdate failed");
    }
    size_t sigLen = 0;
    if (EVP_DigestSignFinal(ctx.get(), nullptr, &sigLen) != 1) {
        throw std::runtime_error("JwtRS256: EVP_DigestSignFinal (size) failed");
    }
    std::vector<unsigned char> sig(sigLen);
    if (EVP_DigestSignFinal(ctx.get(), sig.data(), &sigLen) != 1) {
        throw std::runtime_error("JwtRS256: EVP_DigestSignFinal (sign) failed");
    }
    sig.resize(sigLen);
    return sig;
}

} // namespace

std::string JwtRS256::base64UrlEncode(const std::string& bytes) {
    if (bytes.empty()) return {};
    return toBase64Url(base64StdEncode(
        reinterpret_cast<const unsigned char*>(bytes.data()), bytes.size()));
}

std::string JwtRS256::sign(const std::string& claimsJson,
                           const std::string& privateKeyPem) {
    if (claimsJson.empty()) throw std::runtime_error("JwtRS256: empty claims");

    // Fixed header: {"alg":"RS256","typ":"JWT"}.  Hard-coded so we don't
    // accidentally diverge between LA + future Google OAuth use sites.
    static const std::string kHeaderJson = R"({"alg":"RS256","typ":"JWT"})";

    const std::string headerB64  = base64UrlEncode(kHeaderJson);
    const std::string payloadB64 = base64UrlEncode(claimsJson);
    const std::string signingInput = headerB64 + "." + payloadB64;

    PkeyPtr key = loadPrivateKey(privateKeyPem);
    auto sigBytes = signRs256(key.get(), signingInput);
    const std::string sigB64 = toBase64Url(base64StdEncode(
        sigBytes.data(), sigBytes.size()));

    return signingInput + "." + sigB64;
}
