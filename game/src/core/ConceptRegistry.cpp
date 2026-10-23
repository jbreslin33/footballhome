// game/src/core/ConceptRegistry.cpp — see ConceptRegistry.hpp (G4.37).

#include "core/ConceptRegistry.hpp"

#include <utility>

namespace fh::game::core {

namespace {
ConceptRegistry& active() {
    static ConceptRegistry r = ConceptRegistry::builtin();
    return r;
}
const std::string kNoName;
}  // namespace

int levelRank(const std::string& level) {
    if (level == "u10") return 1;
    if (level == "u14") return 2;
    if (level == "amateur") return 3;
    if (level == "semipro") return 4;
    if (level == "pro") return 5;
    if (level == "world") return 6;
    return 0;
}

ConceptRegistry ConceptRegistry::builtin() {
    // Wire order, with the level each was a default from before the table
    // existed: the four every band knows (u10), the coached bundle that
    // amateur and up know, and the STYLE concepts no band knows by default.
    static const struct { const char* name; const char* from; } kSeed[] = {
        {"delay", "amateur"},        {"marking", "amateur"},
        {"cover", "u10"},            {"support", "u10"},
        {"outlet", "amateur"},       {"runs", "amateur"},
        {"over-top", "amateur"},     {"sweep", "amateur"},
        {"placement", "u10"},        {"line-hold", "u10"},
        {"jockey-angle", "amateur"}, {"recover", "amateur"},
        {"double-team", "amateur"},  {"width", "amateur"},
        {"give-and-go", "amateur"},  {"push-up", "amateur"},
        {"counter-press", "amateur"},{"balance", "amateur"},
        {"man-mark", ""},            {"verticality", ""},
        {"intercept", "amateur"},    {"restraint", "amateur"},
        {"tackle-timing", "amateur"},{"counter-attack", ""},
        {"safe-pass", "amateur"},    {"shot-selection", "amateur"},
        {"libero", ""},              {"cover-shadow", ""},
        {"line-step", ""},           {"pass-ladder", ""},
        {"blind-side-run", ""},
    };
    ConceptRegistry r;
    int id = 0;
    for (const auto& s : kSeed) r.add(id++, s.name, levelRank(s.from));
    return r;
}

void ConceptRegistry::add(int id, std::string name, int taught_from_rank) {
    if (id < 0 || id >= kMaxConcepts) return;
    if (id >= size()) {
        names_.resize(id + 1);
        taught_from_.resize(id + 1, 0);
    }
    names_[id] = std::move(name);
    taught_from_[id] = taught_from_rank;
}

int ConceptRegistry::find(const std::string& name) const {
    if (name.empty()) return -1;
    for (int i = 0; i < size(); ++i)
        if (names_[i] == name) return i;
    return -1;
}

const std::string& ConceptRegistry::name(int id) const {
    return id >= 0 && id < size() ? names_[id] : kNoName;
}

int ConceptRegistry::taughtFrom(int id) const {
    return id >= 0 && id < size() ? taught_from_[id] : 0;
}

const ConceptRegistry& concepts() { return active(); }

void setConcepts(ConceptRegistry r) { active() = std::move(r); }

}  // namespace fh::game::core
