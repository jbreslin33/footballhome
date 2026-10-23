// game/src/core/ModelParams.hpp
//
// Game-model numbers from the club DB (G4.33, migration 642:
// game_model_params). James: "remember no hard code. all comes from db and
// oop". Every Skill and Concept class reads its distances, radii, gains and
// limits from here by key ("<owner>.<code>.<param>", e.g.
// "concept.libero.depth_min_m"); the class's own fallback is used only when
// the DB has no row (tests, DB-down boots — the sandbox must always boot).
//
// Values are held as integer MILLI-units (2.5 m = 2500): the loader rounds
// in SQL, so no float ever enters the sim (scripts/check_no_floats.sh) and
// the same rows give the same Fixed64, every run.

#pragma once

#include "math/Fixed64.hpp"

#include <cstdint>
#include <string>
#include <unordered_map>

namespace fh::game::core {

class ModelParams {
public:
    void setMilli(const std::string& key, std::int64_t milli) { values_[key] = milli; }
    bool has(const std::string& key) const { return values_.count(key) != 0; }
    std::size_t size() const { return values_.size(); }

    std::int64_t milli(const std::string& key, std::int64_t fallback_milli) const {
        auto it = values_.find(key);
        return it == values_.end() ? fallback_milli : it->second;
    }
    // Whole units, rounded half away from zero.
    std::int32_t integer(const std::string& key, std::int32_t fallback) const {
        const std::int64_t m = milli(key, std::int64_t{fallback} * 1000);
        return static_cast<std::int32_t>(m >= 0 ? (m + 500) / 1000 : (m - 500) / 1000);
    }
    math::Fixed64 fixed(const std::string& key, std::int64_t fallback_milli) const {
        return math::Fixed64::fromFraction(static_cast<std::int32_t>(milli(key, fallback_milli)), 1000);
    }

private:
    std::unordered_map<std::string, std::int64_t> values_;
};

}  // namespace fh::game::core
