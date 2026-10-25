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
const std::vector<int> kNoLapses;
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
    // Wire order, with the level whose players know each (mig 650/652):
    // the four every band knows (u10), the coached bundle amateur and up
    // know, the STYLE concepts (S) learnable from amateur but only asked
    // for by a game model, and the two role skills nobody knows by default.
    static const struct { const char* name; const char* from; bool style; } kSeed[] = {
        {"delay", "amateur", false},        {"marking", "amateur", false},
        {"cover", "u10", false},            {"support", "u10", false},
        {"outlet", "amateur", false},       {"runs", "amateur", false},
        {"over-top", "amateur", false},     {"sweep", "amateur", false},
        {"placement", "u10", false},        {"line-hold", "u10", false},
        {"jockey-angle", "amateur", false}, {"recover", "amateur", false},
        {"double-team", "amateur", false},  {"width", "amateur", false},
        {"give-and-go", "amateur", false},  {"push-up", "amateur", false},
        {"counter-press", "amateur", false},{"balance", "amateur", false},
        {"man-mark", "amateur", true},      {"verticality", "amateur", true},
        {"intercept", "amateur", false},    {"restraint", "amateur", false},
        {"tackle-timing", "amateur", false},{"counter-attack", "amateur", true},
        {"safe-pass", "amateur", false},    {"shot-selection", "amateur", false},
        {"libero", "", true},               {"cover-shadow", "", true},
        {"line-step", "amateur", true},     {"pass-ladder", "amateur", true},
        {"blind-side-run", "amateur", true},
    };
    ConceptRegistry r;
    int id = 0;
    for (const auto& s : kSeed) r.add(id++, s.name, levelRank(s.from), s.style);
    // Later core lessons (G4.53): DB-less boots — the calibration harness,
    // the tests — play them too. Until now the harness never ran
    // meet-the-pass (153) at all.
    r.add(153, "meet-the-pass", levelRank("u10"), false);
    r.add(154, "face-the-play", levelRank("u10"), false);
    r.add(155, "side-on-jockey", levelRank("u14"), false);
    r.add(156, "drop-step", levelRank("u14"), false);
    r.add(157, "engage-or-contain", levelRank("u14"), false);
    return r;
}

void ConceptRegistry::add(int id, std::string name, int taught_from_rank, bool style) {
    if (id < 0 || id >= kMaxConcepts) return;
    if (id >= size()) {
        names_.resize(id + 1);
        taught_from_.resize(id + 1, 0);
        style_.resize(id + 1, 0);
    }
    names_[id] = std::move(name);
    taught_from_[id] = taught_from_rank;
    style_[id] = style ? 1 : 0;
}

void ConceptRegistry::addLapse(int id, int to) {
    if (id < 0 || id >= size() || to < 0 || to >= size() || id == to) return;
    if (lapses_.size() < names_.size()) lapses_.resize(names_.size());
    lapses_[id].push_back(to);
}

const std::vector<int>& ConceptRegistry::lapses(int id) const {
    return id >= 0 && id < static_cast<int>(lapses_.size()) ? lapses_[id] : kNoLapses;
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

bool ConceptRegistry::isStyle(int id) const {
    return id >= 0 && id < size() && style_[id] != 0;
}

const ConceptRegistry& concepts() { return active(); }

void setConcepts(ConceptRegistry r) { active() = std::move(r); }

}  // namespace fh::game::core
