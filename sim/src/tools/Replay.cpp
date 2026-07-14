// footballhome sim - Replay driver implementation
//
// See Replay.hpp for the contract + the M0 profile limitation note.

#include "tools/Replay.hpp"

#include "common/IdTypes.hpp"
#include "common/M0Attributes.hpp"
#include "controller/Intent.hpp"
#include "match/CanonicalHash.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "math/Vec3.hpp"
#include "net/InputFrame.hpp"
#include "physics/StubPhysics.hpp"
#include "profile/PlayerProfile.hpp"
#include "scenario/BallOnPitchScenario.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "scenario/HalfPitchScenario.hpp"
#include "scenario/SoftDrillScenario.hpp"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <utility>

namespace fh::sim::tools {

namespace {

// Scenario-id → Scenario factory. IDs are hand-managed per §22.9; each
// new scenario adds a DB row via a migration AND a branch here.
// Assignments:
//   0 = EmptyPitchScenario    (M0 baseline; migrations 200 + 204)
//   1 = BallOnPitchScenario   (M1 Slice 15 demo; migration 207)
//   2 = HalfPitchScenario     (M1 Slice 17.4 demo; migration 212)
//   3 = SoftDrillScenario     (M1 Slice 17.5 demo; migration 213)
// Anything else is unknown — throw loudly rather than silently
// substituting a scenario, because a hash mismatch after replay would
// be nearly impossible to debug from the outside.
std::unique_ptr<scenario::Scenario> makeScenario(std::int16_t scenario_id)
{
    if (scenario_id == 0) {
        return std::make_unique<scenario::EmptyPitchScenario>();
    }
    if (scenario_id == 1) {
        return std::make_unique<scenario::BallOnPitchScenario>();
    }
    if (scenario_id == 2) {
        return std::make_unique<scenario::HalfPitchScenario>();
    }
    if (scenario_id == 3) {
        return std::make_unique<scenario::SoftDrillScenario>();
    }
    throw std::runtime_error(
        "replayMatch: unknown scenario_id=" + std::to_string(scenario_id) +
        " (known: 0=EmptyPitchScenario, 1=BallOnPitchScenario, "
        "2=HalfPitchScenario, 3=SoftDrillScenario)");
}

// M0 default profile — see M0 limitation note in Replay.hpp.
profile::PlayerProfile makeDefaultProfile()
{
    profile::PlayerProfile p;
    p.physical = m0::defaultPhysical();
    p.concepts = m0::defaultConcepts();
    // technical / mental / recognition default-constructed (M0 has no
    // gameplay code reading them yet; ProfileStore leaves them empty
    // for first-touch profiles too — see test_profile_store.cpp).
    return p;
}

// Convert a wire InputFrame payload back into a controller::Intent, using
// the exact same conversion the live SimServer does (see SimServer.cpp
// INPUT handler). f32 → Fixed64 happens right here at the wire boundary
// per §7 — after this call the value is Fixed64 for the rest of the tick.
std::optional<controller::Intent>
decodePayloadToIntent(const std::vector<std::byte>& payload)
{
    // Payload is the full 20-byte wire frame the live server received
    // (header + 16-byte body). std::span<const uint8_t> is what
    // decodeInputFrame wants.
    std::span<const std::uint8_t> u8span{
        reinterpret_cast<const std::uint8_t*>(payload.data()),
        payload.size()};
    const auto di = net::decodeInputFrame(u8span);
    if (!di) { return std::nullopt; }

    controller::Intent intent;
    intent.desired_direction = math::Vec3{
        math::Fixed64::fromFloat(di->desired_dir_x),
        math::Fixed64::fromFloat(di->desired_dir_y),
        math::Fixed64::zero()
    };
    intent.wants_sprint  = di->wants_sprint;
    intent.wants_walk    = di->wants_walk;
    intent.wants_dribble = di->wants_dribble;   // Slice 16.2
    intent.wants_release = di->wants_release;   // Slice 16.4
    return intent;
}

} // namespace

ReplayResult replayMatch(persistence::IPgClient& db,
                         MatchId                 match_id,
                         const ReplayOptions&    opts)
{
    // 1. Match row --------------------------------------------------------
    const auto mrow_opt = db.getMatch(match_id);
    if (!mrow_opt.has_value()) {
        throw std::runtime_error(
            "replayMatch: match_id=" + std::to_string(match_id) +
            " not found in sim_matches");
    }
    const auto& mrow = *mrow_opt;

    // 2. Resolve target tick ---------------------------------------------
    TickNum target_tick;
    if (opts.up_to_tick.has_value()) {
        target_tick = *opts.up_to_tick;
    } else {
        const auto end = db.loadMatchEnd(match_id);
        if (!end.has_value()) {
            throw std::runtime_error(
                "replayMatch: no MatchEnd event for match_id=" +
                std::to_string(match_id) +
                " and no explicit up_to_tick — cannot determine target");
        }
        target_tick = end->tick_num;
    }

    // 3. Load ordered input log up to target -----------------------------
    const auto inputs = db.loadInputsForMatch(match_id, target_tick);

    // 4. Construct a fresh Match with the same scenario + seed the live
    //    server used. clock ticks at the stored tick_hz — the replay
    //    doesn't care about wall-clock cadence but MatchClock's dt
    //    factors into physics, so it MUST match live.
    match::MatchConfig cfg;
    cfg.id             = mrow.id;
    cfg.seed           = mrow.seed;
    cfg.server_version = mrow.server_version;
    cfg.physics        = std::make_unique<physics::StubPhysics>();
    cfg.scenario       = makeScenario(mrow.scenario_id);
    cfg.clock          = std::make_unique<match::RealtimeClock>(
        static_cast<std::uint32_t>(mrow.tick_hz));
    match::Match m{std::move(cfg)};

    // 5. Replay loop -----------------------------------------------------
    ReplayResult result;
    std::unordered_set<SlotId> claimed;
    const profile::PlayerProfile default_profile = makeDefaultProfile();
    std::size_t cursor = 0;
    const std::size_t input_count = inputs.size();

    for (TickNum t = 0; t < target_tick; ++t) {
        // Apply every input recorded at this tick, in the (slot_id ASC)
        // order the DB returned them. Iterating a sorted vector via a
        // cursor beats grouping into a map upfront for the common case
        // of small input volumes.
        while (cursor < input_count && inputs[cursor].tick_num == t) {
            const auto& in = inputs[cursor];

            // First input for this slot — synthesize a claim so the
            // slot has a HumanController that applyInput can find.
            // Uses (slot_id) as both ClientId and PersonId — the values
            // are internal-only in replay and never leave this scope.
            if (claimed.insert(in.slot_id).second) {
                m.claimSlot(SlotId{in.slot_id},
                            ClientId{static_cast<std::uint64_t>(in.slot_id)},
                            PersonId{static_cast<std::uint64_t>(in.slot_id)},
                            default_profile);
                ++result.slots_synthesized;
            }

            const auto intent = decodePayloadToIntent(in.payload);
            if (!intent.has_value()) {
                // Malformed row in the DB — should never happen because
                // the live server validated the frame before logging.
                // Loud failure > silent divergence.
                throw std::runtime_error(
                    "replayMatch: malformed InputRow payload at tick=" +
                    std::to_string(in.tick_num) + " slot=" +
                    std::to_string(in.slot_id));
            }
            m.applyInput(
                ClientId{static_cast<std::uint64_t>(in.slot_id)},
                *intent);
            ++result.inputs_applied;
            ++cursor;
        }

        // Advance simulation one tick. After this call tick_num() == t+1.
        m.tick();
    }

    // Skip past any inputs recorded AT target_tick that we didn't apply
    // (we stopped before ticking that iteration). These are inputs that
    // would've been eaten by tick #target_tick had we run one more step,
    // and they don't affect the snapshot we return — but count them so
    // the caller can detect trailing-input truncation via inputs_applied.
    // Intentionally left un-applied to match the "stop at target" contract.

    result.final_tick      = target_tick;
    result.canonical_hash  = match::canonicalMatchHash(m);
    if (opts.collect_dump) {
        result.canonical_dump = match::canonicalDump(m.snapshot());
    }
    return result;
}

} // namespace fh::sim::tools
