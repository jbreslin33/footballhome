#include "LogoImage.h"

#include <sys/stat.h>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <iterator>

LogoImage::Sniffed LogoImage::sniff(const std::string& b) {
    Sniffed s;
    if (b.size() < 12) return s;
    if (b.compare(0, 8, "\x89PNG\r\n\x1a\n") == 0)                             { s = {"png",  "image/png",  true}; }
    else if (b.compare(0, 3, "\xFF\xD8\xFF") == 0)                             { s = {"jpg",  "image/jpeg", true}; }
    else if (b.compare(0, 4, "RIFF") == 0 && b.compare(8, 4, "WEBP") == 0)     { s = {"webp", "image/webp", true}; }
    else if (b.compare(0, 6, "GIF87a") == 0 || b.compare(0, 6, "GIF89a") == 0) { s = {"gif",  "image/gif",  true}; }
    else {
        const std::string head = b.substr(0, std::min<size_t>(b.size(), 1024));
        std::string lower = head;
        std::transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) { return std::tolower(c); });
        if (lower.find("<svg") != std::string::npos && lower.find("<script") == std::string::npos) {
            s = {"svg", "image/svg+xml", true};
        }
    }
    return s;
}

std::string LogoImage::slugify(const std::string& name) {
    std::string out;
    bool dash = false;
    for (unsigned char c : name) {
        if (std::isalnum(c)) { out.push_back(static_cast<char>(std::tolower(c))); dash = false; }
        else if (!dash && !out.empty()) { out.push_back('-'); dash = true; }
    }
    while (!out.empty() && out.back() == '-') out.pop_back();
    return out.empty() ? "logo" : out.substr(0, 60);
}

std::string LogoImage::hex(const std::string& bytes) {
    static const char* d = "0123456789abcdef";
    std::string out;
    out.reserve(bytes.size() * 2);
    for (unsigned char c : bytes) { out.push_back(d[c >> 4]); out.push_back(d[c & 15]); }
    return out;
}

std::string LogoImage::unhex(const std::string& h) {
    std::string out;
    size_t i = (h.size() >= 2 && h[0] == '\\' && h[1] == 'x') ? 2 : 0;
    out.reserve((h.size() - i) / 2);
    auto v = [](char c) -> int {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
        return 0;
    };
    for (; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>((v(h[i]) << 4) | v(h[i + 1])));
    return out;
}

bool LogoImage::writeFile(const char* dir, const char* urlPrefix, const std::string& filePath, const std::string& bytes) {
    const std::string prefix(urlPrefix);
    if (filePath.rfind(prefix, 0) != 0) return false;
    mkdir(dir, 0755);
    const std::string full = std::string(dir) + "/" + filePath.substr(prefix.size());
    std::ofstream f(full, std::ios::binary | std::ios::trunc);
    if (!f.is_open()) { std::cerr << "LogoImage: cannot write " << full << std::endl; return false; }
    f.write(bytes.data(), static_cast<std::streamsize>(bytes.size()));
    return f.good();
}

bool LogoImage::fileMissing(const char* dir, const char* urlPrefix, const std::string& filePath) {
    const std::string prefix(urlPrefix);
    if (filePath.rfind(prefix, 0) != 0) return false;
    const std::string full = std::string(dir) + "/" + filePath.substr(prefix.size());
    struct stat st{};
    return !(stat(full.c_str(), &st) == 0 && st.st_size > 0);
}

std::string LogoImage::readSiteFile(const std::string& imagesUrl) {
    if (imagesUrl.rfind("/images/", 0) != 0) return "";
    const std::string full = std::string(siteDir()) + imagesUrl.substr(std::string("/images").size());
    std::ifstream f(full, std::ios::binary);
    if (!f.is_open()) return "";
    return std::string((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
}
