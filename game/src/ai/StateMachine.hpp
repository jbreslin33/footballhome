// game/src/ai/StateMachine.hpp
//
// G5.21 (DESIGN §8.119): the finite state machine every agent runs — after
// [Buckland] "Programming Game AI by Example" ch. 2 (State / StateMachine,
// current + previous + global state, enter / execute / exit) and his Simple
// Soccer, where the team and each player each run one.
//
// States are stateless singletons: everything a state needs lives on the
// entity (its agent) or in the context it is handed. Transitions happen
// ONLY in update() (Brain::think, once per tick), never while orders are
// read, so a probe call (dead-ball set-up, the harness) can't move a
// machine. Deterministic: no clock, no RNG — the tick comes in the context.

#pragma once

#include <cstdint>

namespace fh::game::ai {

template <class Entity, class Ctx>
class State {
public:
    virtual ~State() = default;
    // Stable small id (overlay, harness, hashing) and a name for people.
    virtual std::uint8_t id() const = 0;
    virtual const char* name() const = 0;
    virtual void enter(Entity&, const Ctx&) const {}
    // Look at the world; change state through the machine if it asks.
    virtual void execute(Entity&, const Ctx&) const = 0;
    virtual void exit(Entity&, const Ctx&) const {}
};

template <class Entity, class Ctx>
class StateMachine {
public:
    using S = State<Entity, Ctx>;

    void init(const S* start, const S* global, std::uint64_t tick) {
        current_ = start; previous_ = nullptr; global_ = global; entered_ = tick;
    }
    // The global state first (it may change the current one), then the current.
    void update(Entity& e, const Ctx& c) {
        if (global_) global_->execute(e, c);
        if (current_) current_->execute(e, c);
    }
    void change(Entity& e, const Ctx& c, const S* next, std::uint64_t tick) {
        if (next == current_) return;
        if (current_) current_->exit(e, c);
        previous_ = current_; current_ = next; entered_ = tick;
        if (current_) current_->enter(e, c);
    }
    void revert(Entity& e, const Ctx& c, std::uint64_t tick) { if (previous_) change(e, c, previous_, tick); }

    const S* current() const { return current_; }
    const S* previous() const { return previous_; }
    bool in(const S* s) const { return current_ == s; }
    std::uint64_t enteredTick() const { return entered_; }
    std::uint64_t ticksIn(std::uint64_t now) const { return now >= entered_ ? now - entered_ : 0; }

private:
    const S* current_ = nullptr;
    const S* previous_ = nullptr;
    const S* global_ = nullptr;
    std::uint64_t entered_ = 0;
};

}  // namespace fh::game::ai
