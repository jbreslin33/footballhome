#include "AdsController.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <ctime>
#include <cstdio>
#include <future>
#include <iostream>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "../core/HttpClient.h"
#include "../services/MetaAdsService.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {

// ── JSON-byte helpers (mirror LeadsController.cpp; same project convention)
std::string jsEsc(const std::string& s)  { return json(s).dump(); }
std::string jsStr(const std::string& s)  { return jsEsc(s); }
std::string jsInt(long long v)           { return std::to_string(v); }
std::string jsBool(bool v)               { return v ? "true" : "false"; }

// JSON number for a `double` that matches JS `JSON.stringify` semantics:
// integer-valued doubles render without a trailing ".0".
std::string jsNumber(double v) {
    if (std::isnan(v) || std::isinf(v)) return "null";
    double rounded = std::round(v);
    if (v == rounded && std::abs(v) < 1e15) {
        long long iv = static_cast<long long>(rounded);
        return std::to_string(iv);
    }
    // Trim trailing zeros after the decimal point (JS shortest-form).
    std::ostringstream os;
    os.precision(15);
    os << v;
    std::string s = os.str();
    if (s.find('.') != std::string::npos) {
        size_t last = s.find_last_not_of('0');
        if (s[last] == '.') --last;
        s = s.substr(0, last + 1);
    }
    return s;
}

// Helpers for safely projecting nested json without exceptions.
const json* dig(const json& root, std::initializer_list<const char*> path) {
    const json* p = &root;
    for (auto* k : path) {
        if (!p || !p->is_object() || !p->contains(k)) return nullptr;
        p = &(*p)[k];
    }
    return p;
}

std::string strOrEmpty(const json* j) {
    return (j && j->is_string()) ? j->get<std::string>() : std::string{};
}

// Optional-string helper: returns "null" if absent/empty, else escaped string.
// Matches Node's `field || null` idiom in /preview projection.
std::string jsStrOrNull(const std::string& s) {
    if (s.empty()) return "null";
    return jsEsc(s);
}

// Pick the first non-empty of two strings; "" if both empty.  Mirrors
// Node `a || b` for string fields.
std::string firstNonEmpty(const std::string& a, const std::string& b) {
    return !a.empty() ? a : b;
}

// Parse Meta's ISO 8601 created_time / start_time to epoch ms.  Handles
// trailing `Z` (UTC) and `±HHMM` numeric offsets — matches JS
// `new Date(iso).getTime()` rather than naive sscanf, which would treat
// "...T17:30:00-0700" as UTC instead of subtracting the offset.
// Returns 0 on parse failure (mirrors `Date.parse(null) → NaN`, which
// the comparator/arithmetic then treats as 0).
long long parseIsoMs(const std::string& iso) {
    if (iso.empty()) return 0;
    int Y = 0, M = 0, D = 0, h = 0, m = 0, s = 0;
    if (std::sscanf(iso.c_str(), "%4d-%2d-%2dT%2d:%2d:%2d",
                    &Y, &M, &D, &h, &m, &s) < 6) {
        return 0;
    }
    std::tm tm{};
    tm.tm_year = Y - 1900;
    tm.tm_mon  = M - 1;
    tm.tm_mday = D;
    tm.tm_hour = h;
    tm.tm_min  = m;
    tm.tm_sec  = s;
    time_t t = timegm(&tm);
    if (t == static_cast<time_t>(-1)) return 0;

    // Scan past all 14 date/time digits (YYYY MM DD HH MM SS) to find
    // the timezone marker.  Accept any of: "Z", "+HHMM", "+HH:MM",
    // "-HHMM", "-HH:MM".  Absent → assume UTC (same as JS for ISO
    // strings without offset).
    size_t i = 0; int matched = 0;
    while (i < iso.size() && matched < 14) {
        if (iso[i] >= '0' && iso[i] <= '9') ++matched;
        ++i;
    }
    // Skip optional fractional `.NNN` part.
    if (i < iso.size() && iso[i] == '.') {
        ++i;
        while (i < iso.size() && iso[i] >= '0' && iso[i] <= '9') ++i;
    }
    long long offsetSec = 0;
    if (i < iso.size() && (iso[i] == '+' || iso[i] == '-')) {
        char sign = iso[i++];
        int oh = 0, om = 0;
        // Allow "+HHMM" or "+HH:MM".
        if (std::sscanf(iso.c_str() + i, "%2d:%2d", &oh, &om) == 2
         || std::sscanf(iso.c_str() + i, "%2d%2d",  &oh, &om) == 2) {
            offsetSec = (oh * 3600LL + om * 60LL) * (sign == '-' ? -1 : 1);
        }
    }
    // Subtract the offset to convert wall-clock (already-parsed-as-UTC) to
    // true UTC.  e.g. "17:30:00-0700" wall = 17:30 PDT = 00:30 UTC next
    // day → subtract -7h × -1 = add 7h.
    return (static_cast<long long>(t) - offsetSec) * 1000;
}

// ── Error responses ────────────────────────────────────────────────────────
Response errJson(HttpStatus code, const std::string& msg) {
    std::ostringstream b;
    b << "{\"error\":" << jsEsc(msg) << "}";
    Response r(code, b.str());
    r.setHeader("Content-Type", "application/json");
    return r;
}

// ── /api/ads/preview projection ────────────────────────────────────────────
struct PreviewAd {
    std::string id;
    std::string name;
    std::string status;       // PAUSED / ACTIVE / etc
    std::string createdTime;  // ISO 8601 from Meta
    std::string headline;
    std::string body;
    std::string imageUrl;
    std::string cta;
    std::string link;
};

// Build a single preview row from Meta's `data[i]`.
PreviewAd projectPreview(const json& ad,
                         const std::unordered_map<std::string, std::string>& hashToUrl) {
    PreviewAd p;
    p.id          = strOrEmpty(dig(ad, {"id"}));
    p.name        = strOrEmpty(dig(ad, {"name"}));
    p.status      = strOrEmpty(dig(ad, {"status"}));
    p.createdTime = strOrEmpty(dig(ad, {"created_time"}));

    const json* creative = dig(ad, {"creative"});
    const json* linkData = dig(ad, {"creative", "object_story_spec", "link_data"});

    // Headline: creative.title || link_data.name
    std::string title = creative ? strOrEmpty(dig(*creative, {"title"})) : std::string{};
    std::string spec_name = linkData ? strOrEmpty(dig(*linkData, {"name"})) : std::string{};
    p.headline = firstNonEmpty(title, spec_name);

    // Body: creative.body || link_data.message
    std::string cbody = creative ? strOrEmpty(dig(*creative, {"body"})) : std::string{};
    std::string lmsg  = linkData ? strOrEmpty(dig(*linkData, {"message"})) : std::string{};
    p.body = firstNonEmpty(cbody, lmsg);

    // image_url: hashToUrl[image_hash] || creative.image_url
    std::string hash = linkData ? strOrEmpty(dig(*linkData, {"image_hash"})) : std::string{};
    std::string fullRes;
    if (!hash.empty()) {
        auto it = hashToUrl.find(hash);
        if (it != hashToUrl.end()) fullRes = it->second;
    }
    std::string cimg = creative ? strOrEmpty(dig(*creative, {"image_url"})) : std::string{};
    p.imageUrl = firstNonEmpty(fullRes, cimg);

    // CTA: link_data.call_to_action.type
    p.cta = linkData ? strOrEmpty(dig(*linkData, {"call_to_action", "type"})) : std::string{};

    // link: link_data.link
    p.link = linkData ? strOrEmpty(dig(*linkData, {"link"})) : std::string{};
    return p;
}

std::string serializePreviewAd(const PreviewAd& a) {
    std::ostringstream o;
    o << '{'
      <<  "\"id\":"           << jsStr(a.id)
      << ",\"name\":"         << jsStr(a.name)
      << ",\"status\":"       << jsStr(a.status)
      << ",\"created_time\":" << jsStrOrNull(a.createdTime)
      << ",\"headline\":"     << jsStrOrNull(a.headline)
      << ",\"body\":"         << jsStrOrNull(a.body)
      << ",\"image_url\":"    << jsStrOrNull(a.imageUrl)
      << ",\"cta\":"          << jsStrOrNull(a.cta)
      << ",\"link\":"         << jsStrOrNull(a.link)
      << '}';
    return o.str();
}

int statusPriority(const std::string& s) {
    if (s == "PAUSED") return 0;
    if (s == "ACTIVE") return 1;
    return 2;
}

// ── /api/ads/targeting projection ──────────────────────────────────────────
struct GeoSummary {
    // Discriminated union; only fields belonging to `kind` are serialized.
    std::string kind;   // "none" | "pin" | "zips" | "city" | "other"
    std::string label;
    // pin
    std::string address;
    double latitude  = 0;
    double longitude = 0;
    double radius    = 0;
    std::string unit;            // "mile" | "kilometer"
    bool hasLat = false, hasLng = false, hasRadius = false;
    // zips
    std::vector<std::string> zips;
    // city
    std::string city;
    // common
    std::vector<std::string> locationTypes;

    bool latLngPresent() const { return hasLat && hasLng; }
};

GeoSummary summarizeGeo(const json* g) {
    GeoSummary gs;
    if (!g || !g->is_object()) {
        gs.kind  = "none";
        gs.label = "(no geo)";
        return gs;
    }

    auto cls = dig(*g, {"custom_locations"});
    auto zips = dig(*g, {"zips"});
    auto cities = dig(*g, {"cities"});

    auto pickLocTypes = [&]() {
        if (auto* lt = dig(*g, {"location_types"}); lt && lt->is_array()) {
            for (const auto& v : *lt) {
                if (v.is_string()) gs.locationTypes.push_back(v.get<std::string>());
            }
        }
    };

    if (cls && cls->is_array() && !cls->empty()) {
        const auto& cl = (*cls)[0];
        gs.kind = "pin";
        gs.address = strOrEmpty(dig(cl, {"address_string"}));

        if (auto* la = dig(cl, {"latitude"});  la && la->is_number()) { gs.latitude  = la->get<double>(); gs.hasLat = true; }
        if (auto* lo = dig(cl, {"longitude"}); lo && lo->is_number()) { gs.longitude = lo->get<double>(); gs.hasLng = true; }
        if (auto* rd = dig(cl, {"radius"});    rd && rd->is_number()) { gs.radius    = rd->get<double>(); gs.hasRadius = true; }
        gs.unit = strOrEmpty(dig(cl, {"distance_unit"}));

        // Label: `${address_string || lat+","+lng} +${radius}${mi|km}`
        std::ostringstream lbl;
        if (!gs.address.empty()) lbl << gs.address;
        else if (gs.latLngPresent()) lbl << jsNumber(gs.latitude) << ',' << jsNumber(gs.longitude);
        lbl << " +" << jsNumber(gs.radius) << (gs.unit == "mile" ? "mi" : "km");
        gs.label = lbl.str();

        pickLocTypes();
        return gs;
    }

    if (zips && zips->is_array() && !zips->empty()) {
        gs.kind = "zips";
        std::unordered_set<std::string> states;
        for (const auto& z : *zips) {
            std::string k = strOrEmpty(dig(z, {"key"}));
            if (k.size() >= 4 && k.compare(0, 3, "US:") == 0) k.erase(0, 3);
            if (k.empty()) continue;
            gs.zips.push_back(k);
            char first = k[0];
            if (first == '0') states.insert("NJ");
            else if (first == '1') states.insert("PA");
            else states.insert("?");
        }
        // Label: `${count} ZIP allowlist (${states.sort().join("+")})`
        std::vector<std::string> stateList(states.begin(), states.end());
        std::sort(stateList.begin(), stateList.end());
        std::ostringstream lbl;
        lbl << gs.zips.size() << " ZIP allowlist (";
        for (size_t i = 0; i < stateList.size(); ++i) {
            if (i) lbl << '+';
            lbl << stateList[i];
        }
        lbl << ')';
        gs.label = lbl.str();
        pickLocTypes();
        return gs;
    }

    if (cities && cities->is_array() && !cities->empty()) {
        const auto& c = (*cities)[0];
        gs.kind = "city";
        std::string cname = strOrEmpty(dig(c, {"name"}));
        if (cname.empty()) cname = strOrEmpty(dig(c, {"key"}));
        gs.city = cname;
        if (auto* rd = dig(c, {"radius"}); rd && rd->is_number()) { gs.radius = rd->get<double>(); gs.hasRadius = true; }
        gs.unit = strOrEmpty(dig(c, {"distance_unit"}));

        std::ostringstream lbl;
        lbl << "City " << gs.city
            << " +" << jsNumber(gs.radius)
            << (gs.unit == "mile" ? "mi" : "km");
        gs.label = lbl.str();
        pickLocTypes();
        return gs;
    }

    gs.kind  = "other";
    gs.label = "(geo set but unparsed)";
    pickLocTypes();
    return gs;
}

std::string serializeStringArray(const std::vector<std::string>& xs) {
    std::ostringstream o;
    o << '[';
    for (size_t i = 0; i < xs.size(); ++i) {
        if (i) o << ',';
        o << jsEsc(xs[i]);
    }
    o << ']';
    return o.str();
}

std::string serializeGeo(const GeoSummary& g) {
    std::ostringstream o;
    o << '{' << "\"kind\":" << jsStr(g.kind)
             << ",\"label\":" << jsStr(g.label);
    if (g.kind == "pin") {
        o << ",\"address\":"   << (g.address.empty() ? "null" : jsEsc(g.address))
          << ",\"latitude\":"  << (g.hasLat ? jsNumber(g.latitude) : "null")
          << ",\"longitude\":" << (g.hasLng ? jsNumber(g.longitude) : "null")
          << ",\"radius\":"    << (g.hasRadius ? jsNumber(g.radius) : "null")
          << ",\"unit\":"      << (g.unit.empty() ? "null" : jsEsc(g.unit))
          << ",\"location_types\":" << serializeStringArray(g.locationTypes);
    } else if (g.kind == "zips") {
        o << ",\"zips\":" << serializeStringArray(g.zips)
          << ",\"location_types\":" << serializeStringArray(g.locationTypes);
    } else if (g.kind == "city") {
        o << ",\"city\":"   << (g.city.empty() ? "null" : jsEsc(g.city))
          << ",\"radius\":" << (g.hasRadius ? jsNumber(g.radius) : "null")
          << ",\"unit\":"   << (g.unit.empty() ? "null" : jsEsc(g.unit))
          << ",\"location_types\":" << serializeStringArray(g.locationTypes);
    } else if (g.kind == "other") {
        o << ",\"location_types\":" << serializeStringArray(g.locationTypes);
    }
    o << '}';
    return o.str();
}

struct RegionRow {
    std::string region;
    long long impressions = 0;
    long long clicks      = 0;
    long long leads       = 0;
};

struct TargetingAd {
    std::string ad_id;
    std::string ad_name;
    std::string form_id;        // may be empty → null
    std::string link_url;       // may be empty → null
    std::string status;
    std::string adset_id;       // may be empty → null
    std::string adset_status;
    double daily_budget_usd = 0.0;
    std::string start_time;     // may be empty → null
    GeoSummary  geo;
    int  age_min = 0; bool has_age_min = false;
    int  age_max = 0; bool has_age_max = false;
    std::vector<long long> genders; // empty → null
    bool has_genders = false;
    double spend = 0.0;
    long long impressions = 0;
    long long clicks      = 0;
    long long leads       = 0;
    std::vector<RegionRow> regions;
};

long long parseLong(const json* j, long long fallback = 0) {
    if (!j) return fallback;
    if (j->is_number_integer())  return j->get<long long>();
    if (j->is_number_unsigned()) return static_cast<long long>(j->get<unsigned long long>());
    if (j->is_number_float())    return static_cast<long long>(j->get<double>());
    if (j->is_string()) {
        try { return std::stoll(j->get<std::string>()); }
        catch (...) { return fallback; }
    }
    return fallback;
}

double parseFloat(const json* j, double fallback = 0.0) {
    if (!j) return fallback;
    if (j->is_number())  return j->get<double>();
    if (j->is_string())  {
        try { return std::stod(j->get<std::string>()); }
        catch (...) { return fallback; }
    }
    return fallback;
}

long long findLeadActionValue(const json* actions) {
    if (!actions || !actions->is_array()) return 0;
    for (const auto& a : *actions) {
        std::string t = strOrEmpty(dig(a, {"action_type"}));
        if (t == "lead" || t == "onsite_conversion.lead_grouped") {
            return parseLong(dig(a, {"value"}));
        }
    }
    return 0;
}

TargetingAd projectTargeting(const json& ad) {
    TargetingAd t;
    t.ad_id   = strOrEmpty(dig(ad, {"id"}));
    t.ad_name = strOrEmpty(dig(ad, {"name"}));
    t.status  = strOrEmpty(dig(ad, {"effective_status"}));

    const json* linkData = dig(ad, {"creative", "object_story_spec", "link_data"});
    const json* cta      = linkData ? dig(*linkData, {"call_to_action"}) : nullptr;
    t.form_id  = cta ? strOrEmpty(dig(*cta, {"value", "lead_gen_form_id"})) : std::string{};
    // link_url: link_data.link || cta.value.link
    std::string ldLink = linkData ? strOrEmpty(dig(*linkData, {"link"})) : std::string{};
    std::string ctaLink = cta ? strOrEmpty(dig(*cta, {"value", "link"})) : std::string{};
    t.link_url = firstNonEmpty(ldLink, ctaLink);

    const json* adset = dig(ad, {"adset"});
    if (adset) {
        t.adset_id     = strOrEmpty(dig(*adset, {"id"}));
        t.adset_status = strOrEmpty(dig(*adset, {"effective_status"}));
        if (auto* db = dig(*adset, {"daily_budget"}); db && !db->is_null()) {
            t.daily_budget_usd = static_cast<double>(parseLong(db, 0)) / 100.0;
        }
        t.start_time = strOrEmpty(dig(*adset, {"start_time"}));
    }

    const json* targeting = adset ? dig(*adset, {"targeting"}) : nullptr;
    t.geo = summarizeGeo(targeting ? dig(*targeting, {"geo_locations"}) : nullptr);

    if (targeting) {
        // Node: `t.age_min || null` — falsy 0 collapses to null, so only
        // emit numbers when strictly > 0.  Same for age_max.
        if (auto* a = dig(*targeting, {"age_min"}); a && a->is_number_integer()) {
            int v = a->get<int>();
            if (v > 0) { t.age_min = v; t.has_age_min = true; }
        }
        if (auto* a = dig(*targeting, {"age_max"}); a && a->is_number_integer()) {
            int v = a->get<int>();
            if (v > 0) { t.age_max = v; t.has_age_max = true; }
        }
        // Node: `t.genders || null` — `[]` is truthy in JS so any present
        // genders key (even empty array) serializes as an array.
        if (auto* g = dig(*targeting, {"genders"}); g && g->is_array()) {
            for (const auto& v : *g) {
                if (v.is_number()) t.genders.push_back(v.get<long long>());
            }
            t.has_genders = true;
        }
    }

    const json* ins = dig(ad, {"insights", "data"});
    const json* ins0 = (ins && ins->is_array() && !ins->empty()) ? &(*ins)[0] : nullptr;
    if (ins0) {
        t.spend       = parseFloat(dig(*ins0, {"spend"}));
        t.impressions = parseLong (dig(*ins0, {"impressions"}));
        t.clicks      = parseLong (dig(*ins0, {"clicks"}));
        t.leads       = findLeadActionValue(dig(*ins0, {"actions"}));
    }

    return t;
}

std::string serializeRegions(const std::vector<RegionRow>& rows) {
    std::ostringstream o;
    o << '[';
    for (size_t i = 0; i < rows.size(); ++i) {
        if (i) o << ',';
        const auto& r = rows[i];
        o << '{' << "\"region\":"      << jsStr(r.region)
                 << ",\"impressions\":" << jsInt(r.impressions)
                 << ",\"clicks\":"      << jsInt(r.clicks)
                 << ",\"leads\":"       << jsInt(r.leads)
          << '}';
    }
    o << ']';
    return o.str();
}

std::string serializeGenders(const TargetingAd& t) {
    if (!t.has_genders) return "null";
    std::ostringstream o;
    o << '[';
    for (size_t i = 0; i < t.genders.size(); ++i) {
        if (i) o << ',';
        o << jsInt(t.genders[i]);
    }
    o << ']';
    return o.str();
}

std::string serializeTargeting(const TargetingAd& t) {
    std::ostringstream o;
    o << '{'
      <<  "\"ad_id\":"            << jsStr(t.ad_id)
      << ",\"ad_name\":"          << jsStr(t.ad_name)
      << ",\"form_id\":"          << jsStrOrNull(t.form_id)
      << ",\"link_url\":"         << jsStrOrNull(t.link_url)
      << ",\"status\":"           << jsStr(t.status)
      << ",\"adset_id\":"         << jsStrOrNull(t.adset_id)
      << ",\"adset_status\":"     << jsStr(t.adset_status)
      << ",\"daily_budget_usd\":" << jsNumber(t.daily_budget_usd)
      << ",\"start_time\":"       << jsStrOrNull(t.start_time)
      << ",\"geo\":"              << serializeGeo(t.geo)
      << ",\"age_min\":"          << (t.has_age_min ? jsInt(t.age_min) : "null")
      << ",\"age_max\":"          << (t.has_age_max ? jsInt(t.age_max) : "null")
      << ",\"genders\":"          << serializeGenders(t)
      << ",\"spend\":"            << jsNumber(t.spend)
      << ",\"impressions\":"      << jsInt(t.impressions)
      << ",\"clicks\":"           << jsInt(t.clicks)
      << ",\"leads\":"            << jsInt(t.leads)
      << ",\"regions\":"          << serializeRegions(t.regions)
      << '}';
    return o.str();
}

// ── /api/ads/spend slot ────────────────────────────────────────────────────
struct SpendSlot {
    std::string form_id;
    double daily_budget_usd = 0.0;
    double total_spend_usd  = 0.0;
    long long days_running  = 0;
    bool ad_active          = false;
};

std::string serializeSpendSlot(const SpendSlot& s) {
    std::ostringstream o;
    o << '{'
      <<  "\"form_id\":"          << jsStr(s.form_id)
      << ",\"daily_budget_usd\":" << jsNumber(s.daily_budget_usd)
      << ",\"total_spend_usd\":"  << jsNumber(s.total_spend_usd)
      << ",\"days_running\":"     << jsInt(s.days_running)
      << ",\"ad_active\":"        << jsBool(s.ad_active)
      << '}';
    return o.str();
}

} // namespace

// ────────────────────────────────────────────────────────────────────────────
// AdsController — route registration
// ────────────────────────────────────────────────────────────────────────────
void AdsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/preview",
        [this](const Request& r) { return handlePreviewList(r); });
    router.get(prefix + "/targeting",
        [this](const Request& r) { return handleTargeting(r); });
    router.get(prefix + "/spend",
        [this](const Request& r) { return handleSpend(r); });
    // Param routes registered last so static paths win the prefix match.
    router.get(prefix + "/:adId/preview",
        [this](const Request& r) { return handleAdPreviewIframe(r); });
}

bool AdsController::requireBearer(const Request& request) {
    std::string h = request.getHeader("Authorization");
    if (h.empty()) h = request.getHeader("authorization");
    return h.size() > 7 && h.compare(0, 7, "Bearer ") == 0;
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/ads/preview
// ────────────────────────────────────────────────────────────────────────────
Response AdsController::handlePreviewList(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto raw = MetaAdsService::getInstance().fetchAdsForPreview();

        // Collect unique image hashes from `creative.object_story_spec.link_data.image_hash`.
        std::vector<std::string> hashes;
        std::unordered_set<std::string> seen;
        for (const auto& ad : raw) {
            std::string h = strOrEmpty(dig(ad, {"creative", "object_story_spec", "link_data", "image_hash"}));
            if (!h.empty() && seen.insert(h).second) hashes.push_back(h);
        }

        auto pairs = MetaAdsService::getInstance().fetchImageUrlsByHash(hashes);
        std::unordered_map<std::string, std::string> hashToUrl(pairs.begin(), pairs.end());

        std::vector<PreviewAd> ads;
        ads.reserve(raw.size());
        for (const auto& ad : raw) ads.push_back(projectPreview(ad, hashToUrl));

        // Sort: PAUSED, ACTIVE, OTHER; then newest created_time first.
        // stable_sort to mirror JS Array.sort (ES2019+ stable).
        std::stable_sort(ads.begin(), ads.end(),
            [](const PreviewAd& a, const PreviewAd& b) {
                int pa = statusPriority(a.status);
                int pb = statusPriority(b.status);
                if (pa != pb) return pa < pb;
                return parseIsoMs(a.createdTime) > parseIsoMs(b.createdTime);
            });

        std::ostringstream out;
        out << '[';
        for (size_t i = 0; i < ads.size(); ++i) {
            if (i) out << ',';
            out << serializePreviewAd(ads[i]);
        }
        out << ']';

        Response r(HttpStatus::OK, out.str());
        r.setHeader("Content-Type", "application/json");
        return r;
    } catch (const MetaApiError& e) {
        std::cerr << "Error fetching ad preview: " << e.what() << std::endl;
        return errJson(HttpStatus::BAD_GATEWAY, e.what());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching ad preview: " << e.what() << std::endl;
        const std::string msg = e.what();
        // Node: missing token returns its own message; any other thrown
        // error collapses to a generic "Failed to fetch ads" 500.
        if (msg.find("Missing META_ADS_TOKEN") != std::string::npos) {
            return errJson(HttpStatus::INTERNAL_SERVER_ERROR, msg);
        }
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch ads");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/ads/targeting
// ────────────────────────────────────────────────────────────────────────────
Response AdsController::handleTargeting(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto raw = MetaAdsService::getInstance().fetchAdsForTargeting();
        std::vector<TargetingAd> ads;
        ads.reserve(raw.size());
        for (const auto& ad : raw) ads.push_back(projectTargeting(ad));

        // Fan-out per-ACTIVE-ad region fetch in parallel (mirrors Node
        // Promise.all).  std::async with std::launch::async forces a
        // thread per task; HttpClient::perform allocates a private
        // curl_easy each call so this is safe to do concurrently.
        std::vector<std::pair<size_t, std::future<json>>> jobs;
        for (size_t i = 0; i < ads.size(); ++i) {
            if (ads[i].status != "ACTIVE" || ads[i].ad_id.empty()) continue;
            std::string id = ads[i].ad_id;
            jobs.emplace_back(i, std::async(std::launch::async,
                [id]() { return MetaAdsService::getInstance().fetchRegionInsights(id); }));
        }
        for (auto& [idx, fut] : jobs) {
            json rows;
            try { rows = fut.get(); }
            catch (...) { rows = json::array(); }
            if (!rows.is_array()) continue;
            std::vector<RegionRow> regs;
            regs.reserve(rows.size());
            for (const auto& row : rows) {
                RegionRow r;
                r.region      = strOrEmpty(dig(row, {"region"}));
                if (r.region.empty()) r.region = "Unknown";
                r.impressions = parseLong(dig(row, {"impressions"}));
                r.clicks      = parseLong(dig(row, {"clicks"}));
                r.leads       = findLeadActionValue(dig(row, {"actions"}));
                regs.push_back(r);
            }
            std::stable_sort(regs.begin(), regs.end(),
                [](const RegionRow& a, const RegionRow& b) {
                    return a.impressions > b.impressions;
                });
            ads[idx].regions = std::move(regs);
        }

        std::ostringstream out;
        out << '[';
        for (size_t i = 0; i < ads.size(); ++i) {
            if (i) out << ',';
            out << serializeTargeting(ads[i]);
        }
        out << ']';

        Response r(HttpStatus::OK, out.str());
        r.setHeader("Content-Type", "application/json");
        return r;
    } catch (const std::exception& e) {
        std::cerr << "Error fetching ad targeting: " << e.what() << std::endl;
        return errJson(HttpStatus::BAD_GATEWAY, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/ads/spend
// ────────────────────────────────────────────────────────────────────────────
Response AdsController::handleSpend(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    try {
        auto raw = MetaAdsService::getInstance().fetchAdsForSpend();

        // Preserve Node insertion order: bucket by form_id in the order
        // each ad appears in Meta's `data`.  Object.values(byForm) in JS
        // returns insertion-order keys.
        std::vector<std::string> formOrder;
        std::unordered_map<std::string, SpendSlot> byForm;
        const long long nowMs =
            std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count();

        for (const auto& ad : raw) {
            std::string formId = strOrEmpty(dig(ad, {"creative", "object_story_spec", "link_data", "call_to_action", "value", "lead_gen_form_id"}));
            if (formId.empty()) continue;

            const json* adset = dig(ad, {"adset"});
            double dailyBudgetUSD = 0.0;
            long long startMs = 0;
            std::string adsetStatus;
            if (adset) {
                if (auto* db = dig(*adset, {"daily_budget"}); db && !db->is_null()) {
                    dailyBudgetUSD = static_cast<double>(parseLong(db, 0)) / 100.0;
                }
                std::string st = strOrEmpty(dig(*adset, {"start_time"}));
                startMs = parseIsoMs(st);
                adsetStatus = strOrEmpty(dig(*adset, {"effective_status"}));
            }
            const json* ins = dig(ad, {"insights", "data"});
            double insightSpend = 0.0;
            if (ins && ins->is_array() && !ins->empty()) {
                insightSpend = parseFloat(dig((*ins)[0], {"spend"}));
            }

            auto it = byForm.find(formId);
            if (it == byForm.end()) {
                SpendSlot slot;
                slot.form_id = formId;
                byForm[formId] = slot;
                formOrder.push_back(formId);
                it = byForm.find(formId);
            }
            it->second.daily_budget_usd += dailyBudgetUSD;
            it->second.total_spend_usd  += insightSpend;
            if (startMs > 0) {
                long long days = (nowMs - startMs) / 86400000LL;
                if (days < 0) days = 0;
                if (days > it->second.days_running) it->second.days_running = days;
            }
            std::string adStatus = strOrEmpty(dig(ad, {"effective_status"}));
            if (adStatus == "ACTIVE" && adsetStatus == "ACTIVE") {
                it->second.ad_active = true;
            }
        }

        std::ostringstream out;
        out << '[';
        for (size_t i = 0; i < formOrder.size(); ++i) {
            if (i) out << ',';
            out << serializeSpendSlot(byForm[formOrder[i]]);
        }
        out << ']';

        Response r(HttpStatus::OK, out.str());
        r.setHeader("Content-Type", "application/json");
        return r;
    } catch (const MetaApiError& e) {
        std::cerr << "Error fetching ad spend: " << e.what() << std::endl;
        return errJson(HttpStatus::BAD_GATEWAY, e.what());
    } catch (const std::exception& e) {
        std::cerr << "Error fetching ad spend: " << e.what() << std::endl;
        const std::string msg = e.what();
        if (msg.find("Missing META_ADS_TOKEN") != std::string::npos) {
            return errJson(HttpStatus::INTERNAL_SERVER_ERROR, msg);
        }
        return errJson(HttpStatus::INTERNAL_SERVER_ERROR, "Failed to fetch spend");
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/ads/:adId/preview — 302 redirect to Meta-hosted iframe src
// ────────────────────────────────────────────────────────────────────────────
Response AdsController::htmlError(int status,
                                  const std::string& msg,
                                  const std::string& adId,
                                  const std::string& adFmt) {
    std::ostringstream body;
    body << "<!DOCTYPE html><html><head><title>Preview error</title>\n"
            "    <style>body{font-family:system-ui;background:#0f172a;color:#e5e7eb;padding:40px;}\n"
            "    h1{color:#f59e0b;}code{background:#1f2937;padding:2px 6px;border-radius:3px;}</style></head>\n"
            "    <body><h1>\u26a0 Ad preview failed</h1><p>" << msg << "</p>\n"
            "    <p style=\"opacity:0.7;font-size:0.85rem;\">ad_id: <code>" << adId
                << "</code> \u00b7 format: <code>" << adFmt << "</code></p>\n"
            "    </body></html>";

    HttpStatus code = HttpStatus::OK;
    switch (status) {
        case 404: code = HttpStatus::NOT_FOUND; break;
        case 500: code = HttpStatus::INTERNAL_SERVER_ERROR; break;
        case 502: code = HttpStatus::BAD_GATEWAY; break;
        default:  code = HttpStatus::INTERNAL_SERVER_ERROR;
    }
    Response r(code, body.str());
    r.setHeader("Content-Type", "text/html");
    return r;
}

Response AdsController::handleAdPreviewIframe(const Request& request) {
    if (!requireBearer(request)) return errJson(HttpStatus::UNAUTHORIZED, "Unauthorized");

    // Extract :adId from path.  Pattern is "/api/ads/:adId/preview".
    const std::string path = request.getPath();
    // Strip a trailing query if any (Request usually does this already; be safe).
    std::string p = path;
    auto qm = p.find('?');
    if (qm != std::string::npos) p = p.substr(0, qm);
    std::string adId;
    const std::string marker = "/api/ads/";
    auto pos = p.find(marker);
    if (pos != std::string::npos) {
        auto start = pos + marker.size();
        auto slash = p.find('/', start);
        if (slash != std::string::npos) adId = p.substr(start, slash - start);
    }
    if (adId.empty()) {
        return htmlError(500, "Missing ad id in path.", "(none)", "feed");
    }

    // Format alias resolution (mirrors Node FORMATS map).
    std::string fmtKey = request.getQueryParam("format");
    if (fmtKey.empty()) fmtKey = "feed";
    std::string fmtLower;
    fmtLower.reserve(fmtKey.size());
    for (char c : fmtKey) fmtLower += static_cast<char>(std::tolower(static_cast<unsigned char>(c)));

    std::string adFmt;
    if      (fmtLower == "feed")     adFmt = "MOBILE_FEED_STANDARD";
    else if (fmtLower == "fb")       adFmt = "FACEBOOK_STORY_MOBILE";
    else if (fmtLower == "ig")       adFmt = "INSTAGRAM_STANDARD";
    else if (fmtLower == "ig_story") adFmt = "INSTAGRAM_STORY";
    else if (fmtLower == "ig_reels") adFmt = "INSTAGRAM_REELS";
    else {
        // Allow raw Meta key passthrough — uppercased.
        adFmt.reserve(fmtKey.size());
        for (char c : fmtKey) adFmt += static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
    }

    try {
        std::string src = MetaAdsService::getInstance().fetchPreviewIframeSrc(adId, adFmt);
        // 302 redirect to the iframe URL.
        Response r(HttpStatus::FOUND, std::string{});
        r.setHeader("Location", src);
        r.setHeader("Content-Type", "text/html; charset=utf-8");
        return r;
    } catch (const std::exception& e) {
        const std::string msg = e.what();
        // Status mapping mirrors Node's switch:
        //   Missing token  → 500
        //   "Meta API:"    → 502
        //   "no preview"   → 404
        //   "Could not extract" or other → 500
        int code = 500;
        if (msg.find("Missing META_ADS_TOKEN") != std::string::npos) code = 500;
        else if (msg.find("Meta API:") != std::string::npos)         code = 502;
        else if (msg.find("no preview body") != std::string::npos)   code = 404;
        else if (msg.find("Could not extract") != std::string::npos) code = 500;
        return htmlError(code, msg, adId, adFmt);
    }
}
