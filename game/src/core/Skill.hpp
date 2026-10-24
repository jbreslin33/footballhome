// game/src/core/Skill.hpp
//
// Skills — one class per player attribute (G4.33). James: "each skill a
// skill extended from skills … no hard code. all comes from db and oop".
//
// A Skill knows its registry code (game_attributes, mig 636) and how its
// 0-100 rating bends the team's level band into this player's level
// (50 = the band exactly, -1 = unrated). Its numbers come from
// game_model_params ("skill.<code>.<param>", mig 642); the constructor
// defaults are the fallback when the DB has no row, and equal the seeded
// rows — so a DB-less test and the live daemon play the same match.
//
// Integer math only: a player's level is config, but it drives the
// deterministic sim, so the same rows must give the same numbers.

#pragma once

#include "core/Levels.hpp"
#include "core/ModelParams.hpp"

#include <memory>
#include <string>
#include <vector>

namespace fh::game::core {

class Skill {
public:
    explicit Skill(std::string code) : code_(std::move(code)) {}
    virtual ~Skill() = default;
    const std::string& code() const { return code_; }
    // Read this skill's numbers ("skill.<code>.<param>").
    virtual void configure(const ModelParams&) {}
    // Bend `out` (a copy of the band) by this player's rating (0-100).
    virtual void apply(LevelParams& out, const LevelParams& band, int rating) const = 0;

protected:
    std::string key(const char* param) const { return "skill." + code_ + "." + param; }
    // Linear multiplier from at0 % (rating 0) to at100 % (rating 100),
    // 100 % at 50 when symmetric; rounded integer.
    static std::int32_t scaled(std::int32_t v, int rating, std::int32_t at0, std::int32_t at100) {
        const std::int32_t m2 = 2 * at0 + 2 * (at100 - at0) * rating / 100;
        return (v * m2 + 100) / 200;
    }

private:
    std::string code_;
};

// A skill that scales "error" numbers: worse rating, bigger error.
class ErrorSkill : public Skill {
public:
    using Skill::Skill;
    void configure(const ModelParams& p) override {
        at0_ = p.integer(key("at0_pct"), 150);
        at100_ = p.integer(key("at100_pct"), 50);
    }

protected:
    std::int32_t err(std::int32_t v, int r) const { return scaled(v, r, at0_, at100_); }
    std::int32_t at0_ = 150, at100_ = 50;
};

class Pace : public Skill {
public:
    Pace() : Skill("pace") {}
    void configure(const ModelParams& p) override {
        base_cms_ = p.integer(key("base_cms"), 540);
        per_point_cms_ = p.integer(key("per_point_cms"), 2);
    }
    void apply(LevelParams&, const LevelParams&, int) const override {}  // speed, not noise
    std::int32_t speedCms(int rating) const { return base_cms_ + per_point_cms_ * rating; }

private:
    std::int32_t base_cms_ = 540, per_point_cms_ = 2;
};

class Passing : public ErrorSkill {
public:
    Passing() : ErrorSkill("passing") {}
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.kick_angle_err_deg = err(b.kick_angle_err_deg, r);
        o.kick_power_err_pct = err(b.kick_power_err_pct, r);
        // Range (G4.48): 80% of the band's at 0 → 120% at 100.
        o.kick_range_m = scaled(b.kick_range_m, r, range_at0_, range_at100_);
    }
    void configure(const ModelParams& p) override {
        ErrorSkill::configure(p);
        range_at0_ = p.integer(key("range_at0_pct"), 80);
        range_at100_ = p.integer(key("range_at100_pct"), 120);
    }

private:
    std::int32_t range_at0_ = 80, range_at100_ = 120;
};

class Shooting : public ErrorSkill {
public:
    Shooting() : ErrorSkill("shooting") {}
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.shot_angle_err_deg = err(b.kick_angle_err_deg, r);
        o.shot_power_err_pct = err(b.kick_power_err_pct, r);
    }
};

class FirstTouch : public Skill {
public:
    FirstTouch() : Skill("first_touch") {}
    void configure(const ModelParams& p) override {
        at0_ = p.integer(key("at0_pct"), 75);
        at100_ = p.integer(key("at100_pct"), 125);
    }
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.control_speed_mps = scaled(b.control_speed_mps, r, at0_, at100_);
    }

private:
    std::int32_t at0_ = 75, at100_ = 125;
};

class Tackling : public Skill {
public:
    Tackling() : Skill("tackling") {}
    void configure(const ModelParams& p) override {
        spread_ = p.integer(key("spread_points"), 30);
        min_ = p.integer(key("min_pct"), 5);
        max_ = p.integer(key("max_pct"), 95);
    }
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        if (b.tackle_success_pct <= 0) return;   // a band without dives stays without
        const std::int32_t t = b.tackle_success_pct + (r - 50) * spread_ / 50;
        o.tackle_success_pct = t < min_ ? min_ : (t > max_ ? max_ : t);
    }

private:
    std::int32_t spread_ = 30, min_ = 5, max_ = 95;
};

class Anticipation : public ErrorSkill {
public:
    Anticipation() : ErrorSkill("anticipation") {}
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.perception_delay_ticks = err(b.perception_delay_ticks, r);
    }
};

class Decisions : public ErrorSkill {
public:
    Decisions() : ErrorSkill("decisions") {}
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.decision_jitter_pct = err(b.decision_jitter_pct, r);
    }
};

class Goalkeeping : public ErrorSkill {
public:
    Goalkeeping() : ErrorSkill("goalkeeping") {}
    void apply(LevelParams& o, const LevelParams& b, int r) const override {
        o.keeper_reaction_ticks = err(b.keeper_reaction_ticks, r);
        o.keeper_fumble_pct = err(b.keeper_fumble_pct, r);
    }
};

// The registry, in game_attributes order (= PlayerAttributes / wire 0x37).
class SkillSet {
public:
    explicit SkillSet(const ModelParams& p = ModelParams{}) {
        pace_ = new Pace();
        skills_.emplace_back(pace_);
        skills_.emplace_back(new Passing());
        skills_.emplace_back(new Shooting());
        skills_.emplace_back(new FirstTouch());
        skills_.emplace_back(new Tackling());
        skills_.emplace_back(new Anticipation());
        skills_.emplace_back(new Decisions());
        skills_.emplace_back(new Goalkeeping());
        for (auto& s : skills_) s->configure(p);
    }
    // The band bent by one player's attributes; all -1 = the band itself.
    LevelParams apply(const LevelParams& band, const PlayerAttributes& a) const {
        LevelParams out = band;
        PlayerAttributes copy = a;
        for (int i = 0; i < kAttributeCount && i < static_cast<int>(skills_.size()); ++i) {
            const std::int16_t r = *attributeAt(copy, i);
            if (r >= 0) skills_[i]->apply(out, band, r);
        }
        return out;
    }
    std::int32_t speedCms(std::int16_t pace) const { return pace_->speedCms(pace); }
    const std::vector<std::unique_ptr<Skill>>& skills() const { return skills_; }

private:
    std::vector<std::unique_ptr<Skill>> skills_;
    Pace* pace_ = nullptr;
};

// Back-compat helpers: the default (DB-less) skill set.
inline LevelParams levelForPlayer(const LevelParams& band, const PlayerAttributes& a) {
    static const SkillSet defaults;
    return defaults.apply(band, a);
}
inline std::int32_t paceSpeedCms(std::int16_t pace) {
    static const SkillSet defaults;
    return defaults.speedCms(pace);
}

}  // namespace fh::game::core
