#include "TeamLabel.h"
#include <algorithm>
#include <cctype>
#include <regex>
#include <sstream>
#include <vector>

namespace {

// Lowercase ASCII copy.
std::string toLower(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) out.push_back(static_cast<char>(std::tolower(static_cast<unsigned char>(c))));
    return out;
}

// Trim + collapse internal whitespace runs to a single ' '.
std::string collapseSpaces(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    bool prevSpace = true; // skip leading whitespace
    for (char c : s) {
        if (std::isspace(static_cast<unsigned char>(c))) {
            if (!prevSpace) { out.push_back(' '); prevSpace = true; }
        } else {
            out.push_back(c);
            prevSpace = false;
        }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

} // namespace

std::string TeamLabel::shortLabel(const std::string& name) {
    if (name.empty()) return "?";

    // Strip club-wide noise words.  Mirrors the JS regex:
    //   /lighthouse|1893|\bsc\b|\bclub\b/gi
    static const std::regex noise(R"((?:lighthouse|1893|\bsc\b|\bclub\b))",
                                  std::regex::icase);
    std::string cleaned = collapseSpaces(std::regex_replace(name, noise, std::string(" ")));
    const std::string lower = toLower(cleaned);

    auto contains = [&](const std::regex& re) {
        return std::regex_search(lower, re);
    };

    // Order matters — most specific first.  Patterns mirror the JS list.
    static const std::regex re_apsl       (R"(apsl)");
    static const std::regex re_liga1      (R"(liga\s*1)");
    static const std::regex re_liga2      (R"(liga\s*2)");
    static const std::regex re_u23w       (R"(u23\s*women|women.*u23)");
    static const std::regex re_u23m       (R"(u23\s*men|men.*u23|^u23$)");
    static const std::regex re_tricoW     (R"(tri\s*county.*women)");
    static const std::regex re_tricoM     (R"(tri\s*county.*men)");
    static const std::regex re_trico      (R"(tri\s*county)");
    static const std::regex re_brazil     (R"(brazil)");
    static const std::regex re_pr         (R"(puerto\s*rico)");
    static const std::regex re_pickup     (R"(pickup)");
    static const std::regex re_training   (R"(training)");

    if (contains(re_apsl))     return "APSL";
    if (contains(re_liga1))    return "Liga 1";
    if (contains(re_liga2))    return "Liga 2";
    if (contains(re_u23w))     return "U23 W";
    if (contains(re_u23m))     return "U23 M";
    if (contains(re_tricoW))   return "TriCo W";
    if (contains(re_tricoM))   return "TriCo M";
    if (contains(re_trico))    return "TriCo";
    if (contains(re_brazil))   return "Brazil";
    if (contains(re_pr))       return "PR";
    if (contains(re_pickup))   return "Pickup";
    if (contains(re_training)) return "Train";

    // Fallback: 2+ word names → initials, single-word → first 6 alnum chars.
    std::vector<std::string> words;
    {
        std::string cur;
        for (char c : cleaned) {
            if (c == ' ' || c == '-' || c == '_' || c == '/') {
                if (!cur.empty()) { words.push_back(cur); cur.clear(); }
            } else {
                cur.push_back(c);
            }
        }
        if (!cur.empty()) words.push_back(cur);
    }

    auto upper = [](char c) {
        return static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
    };

    if (words.size() >= 2) {
        std::string init;
        for (const auto& w : words) {
            if (init.size() >= 6) break;
            if (!w.empty()) init.push_back(upper(w[0]));
        }
        return init.empty() ? "?" : init;
    }

    std::string alnum;
    for (char c : cleaned) {
        if (std::isalnum(static_cast<unsigned char>(c))) {
            alnum.push_back(c);
            if (alnum.size() == 6) break;
        }
    }
    return alnum.empty() ? "?" : alnum;
}
