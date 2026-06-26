#include "LaProgramSync.h"

#include <cctype>
#include <iostream>

#include "../models/PersonLinker.h"
#include "LeagueAppsService.h"

namespace {

// Uppercase ASCII copy used to match LA registrationStatus.
std::string upperAscii(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) out.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(c))));
    return out;
}

// LA records use either `userId` (number/string) or, on older feeds,
// `memberId`.  Always normalise to a string so it can key external_person_
// aliases.external_user_id (TEXT).  Returns empty string when neither
// field is present.
std::string extractUserId(const nlohmann::json& rec) {
    auto take = [&](const char* key) -> std::string {
        auto it = rec.find(key);
        if (it == rec.end() || it->is_null()) return {};
        if (it->is_string())               return it->get<std::string>();
        if (it->is_number_integer())       return std::to_string(it->get<long long>());
        if (it->is_number_unsigned())      return std::to_string(it->get<unsigned long long>());
        if (it->is_number_float())         return std::to_string(static_cast<long long>(it->get<double>()));
        return {};
    };
    std::string uid = take("userId");
    if (uid.empty()) uid = take("memberId");
    return uid;
}

} // namespace

LaProgramSync::Result LaProgramSync::run(int programId) {
    Result out;

    auto recs = LeagueAppsService::getInstance().fetchProgramRegistrations(programId);

    PersonLinker linker;

    for (auto& rec : recs) {
        std::string statusRaw;
        if (auto it = rec.find("registrationStatus"); it != rec.end() && it->is_string()) {
            statusRaw = it->get<std::string>();
        }
        const std::string status = upperAscii(statusRaw);

        const std::string uid = extractUserId(rec);
        if (uid.empty()) {
            out.recs.push_back(std::move(rec));
            continue;
        }

        out.statusByUser[uid] = status;

        const bool isActive = (status == "SPOT_RESERVED" || status == "SPOT_PENDING");
        if (isActive) {
            out.activeUserIds.insert(uid);

            try {
                auto r = linker.linkLa(rec);
                if (!r.skipReason.empty()) {
                    std::cerr << "[la-sync program=" << programId
                              << "] linkLa skipped userId=" << uid
                              << ": " << r.skipReason << std::endl;
                }
            } catch (const std::exception& e) {
                std::cerr << "[la-sync program=" << programId
                          << "] linkLa failed userId=" << uid
                          << ": " << e.what() << std::endl;
            }
        }

        out.recs.push_back(std::move(rec));
    }

    return out;
}
