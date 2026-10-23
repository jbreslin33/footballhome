// game/src/core/ConceptRegistry.hpp
//
// The concept registry IS the curriculum (G4.37). James: "the concepts are
// also the curriculum to teach" — every concept is a lesson a coach can
// rate and drill, so the list lives in the club DB (game_concepts, mig
// 650: name, lesson text, family, moment, the level it is taught from,
// prerequisites, sources) and grows by rows, not code. The engine loads it
// at boot; a concept with no ai::Concept class still exists — rated and
// taught, it just doesn't drive behavior yet.
//
// Ids are stable and wire format (append-only): the 31 that predate the
// table keep their old bit numbers, so ratings, presets and goldens are
// untouched. builtin() is that list, for tests and DB-down boots.

#pragma once

#include <string>
#include <vector>

namespace fh::game::core {

// Most concepts a rating vector can hold: the wire's u8 rating count
// (PROTOCOL 0x33/0x34).
inline constexpr int kMaxConcepts = 255;

// Level ladder ranks for "taught from" (u10 = 1 … world = 6; perfect = 7
// knows every taught concept): the lowest band whose players KNOW it
// (ability). 0 = nobody by default (a role skill such as the libero, or a
// lesson not yet placed on the ladder).
int levelRank(const std::string& level);

class ConceptRegistry {
public:
    // The 31 concepts that predate the table, in their wire order.
    static ConceptRegistry builtin();

    // style = a chosen identity (default demand 0: only a game model asks
    // for it); core = any good team does it (default demand 100).
    void add(int id, std::string name, int taught_from_rank, bool style = false);
    // Max id + 1 (ids may have holes; a hole has no name).
    int size() const { return static_cast<int>(names_.size()); }
    int find(const std::string& name) const;  // -1 when unknown
    const std::string& name(int id) const;
    int taughtFrom(int id) const;
    bool isStyle(int id) const;
    // What a team asks of a concept when its game model doesn't say.
    int defaultDemand(int id) const { return isStyle(id) ? 0 : 100; }
    // Lapses (G4.46, game_concept_links kind 'lapses-to'): what a player
    // drifts into when he fails his roll on `id` — a neighbour concept that
    // is right in another system, never a "bad" one.
    void addLapse(int id, int to);
    const std::vector<int>& lapses(int id) const;

private:
    std::vector<std::string> names_;
    std::vector<int> taught_from_;
    std::vector<char> style_;
    std::vector<std::vector<int>> lapses_;
};

// The registry in force (builtin until the daemon loads the DB at boot).
const ConceptRegistry& concepts();
void setConcepts(ConceptRegistry r);

}  // namespace fh::game::core
