// footballhome sim - ProfileStore tests
//
// Exercises the loadOrCreate + save round-trip against InMemoryPgClient.
// See DESIGN.md §16.6, §22.11, §22.12.

#include "common/M0Attributes.hpp"
#include "common/M0Registry.generated.hpp"
#include "math/Fixed64.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "persistence/ProfileStore.hpp"
#include "profile/PlayerProfile.hpp"
#include "test_harness.hpp"

using fh::sim::AttrId;
using fh::sim::PersonId;
using fh::sim::math::Fixed64;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::ProfileStore;
using fh::sim::profile::AttributeSet;
using fh::sim::profile::PlayerProfile;

// ---------------------------------------------------------------------------
// First-touch: no DB row exists → materialise + persist M0 baseline.
// ---------------------------------------------------------------------------
FH_TEST(load_or_create_materialises_m0_baseline_on_first_touch)
{
    InMemoryPgClient db;
    ProfileStore store{db};

    const PersonId person{42};
    // Sanity: no row before.
    FH_EXPECT(!db.loadProfile(person).has_value());

    const PlayerProfile p = store.loadOrCreate(person);

    // Every physical AttrId from the M0 catalog is present and equals
    // the value produced by defaultPhysical(). We check three of the
    // ten — a full sweep is redundant given the encode/decode path is
    // exercised by the round-trip test below.
    const auto baseline = fh::sim::m0::defaultPhysical();
    FH_EXPECT_EQ(p.physical.get(fh::sim::m0::kMaxWalkSpeed).raw,
                 baseline.get(fh::sim::m0::kMaxWalkSpeed).raw);
    FH_EXPECT_EQ(p.physical.get(fh::sim::m0::kMaxSprintSpeed).raw,
                 baseline.get(fh::sim::m0::kMaxSprintSpeed).raw);
    FH_EXPECT_EQ(p.physical.get(fh::sim::m0::kStaminaRecoveryRate).raw,
                 baseline.get(fh::sim::m0::kStaminaRecoveryRate).raw);
    // Slice 16.1: dribble_efficiency landed at 0.85 (see M0Attributes.cpp).
    // Assert both that defaultPhysical() has it AND that first-touch
    // materialisation round-trips the value through the DB.
    FH_EXPECT_EQ(baseline.get(fh::sim::m0::kDribbleEfficiency).raw,
                 Fixed64::fromDouble(0.85).raw);
    FH_EXPECT_EQ(p.physical.get(fh::sim::m0::kDribbleEfficiency).raw,
                 baseline.get(fh::sim::m0::kDribbleEfficiency).raw);

    // First-touch must ALSO persist so subsequent loads read from DB,
    // not re-materialise from code.
    FH_EXPECT(db.loadProfile(person).has_value());
}

// ---------------------------------------------------------------------------
// Second load returns identical values, and DOES NOT force-rewrite the row
// (loadOrCreate on an existing row is read-only path).
// ---------------------------------------------------------------------------
FH_TEST(load_or_create_second_call_reads_from_db)
{
    InMemoryPgClient db;
    ProfileStore store{db};

    const PersonId person{100};
    (void)store.loadOrCreate(person);   // materialise + persist

    // Corrupt the DB row: overwrite via a direct upsert with our own bytes.
    // If loadOrCreate rebuilt-and-saved on second touch, this corruption
    // would be silently reverted; we want to prove it's not.
    PlayerProfile modified;
    modified.physical.set(fh::sim::m0::kMaxWalkSpeed, Fixed64::fromInt(99));
    store.save(person, modified);

    const PlayerProfile reloaded = store.loadOrCreate(person);
    FH_EXPECT_EQ(reloaded.physical.get(fh::sim::m0::kMaxWalkSpeed).raw,
                 Fixed64::fromInt(99).raw);
    // Other attributes are absent (modified was minimal) — that's proof
    // the DB round-trip round-tripped, not a re-materialisation.
    FH_EXPECT(!reloaded.physical.has(fh::sim::m0::kMaxSprintSpeed));
}

// ---------------------------------------------------------------------------
// save() round-trips small-integer Fixed64 values bit-exactly. Rows are
// stored as f32 in the DB (§8, ADR §22.18), so we use small integers whose
// f32 representation is exact.
// ---------------------------------------------------------------------------
FH_TEST(save_round_trips_small_integer_fixed64_bytes)
{
    InMemoryPgClient db;
    ProfileStore store{db};

    const PersonId person{7};
    PlayerProfile written;
    written.physical.set(fh::sim::m0::kMaxWalkSpeed,   Fixed64::fromInt(3));
    written.physical.set(fh::sim::m0::kMaxSprintSpeed, Fixed64::fromInt(9));
    written.physical.set(fh::sim::m0::kAgility,        Fixed64::fromInt(4));
    store.save(person, written);

    const PlayerProfile read = store.loadOrCreate(person);

    // ProfileStore encodes values via Fixed64::toFloat and decodes via
    // Fixed64::fromFloat (per ADR §22.18 — persistence layer converts at
    // the boundary). For small integers the f32 is exact so bit equality
    // is expected on the Fixed64 raw.
    FH_EXPECT_EQ(read.physical.get(fh::sim::m0::kMaxWalkSpeed).raw,
                 Fixed64::fromInt(3).raw);
    FH_EXPECT_EQ(read.physical.get(fh::sim::m0::kMaxSprintSpeed).raw,
                 Fixed64::fromInt(9).raw);
    FH_EXPECT_EQ(read.physical.get(fh::sim::m0::kAgility).raw,
                 Fixed64::fromInt(4).raw);
}

// ---------------------------------------------------------------------------
// Distinct persons get distinct rows.
// ---------------------------------------------------------------------------
FH_TEST(distinct_persons_kept_isolated)
{
    InMemoryPgClient db;
    ProfileStore store{db};

    PlayerProfile a;
    a.physical.set(fh::sim::m0::kMaxWalkSpeed, Fixed64::fromInt(1));
    store.save(PersonId{1}, a);

    PlayerProfile b;
    b.physical.set(fh::sim::m0::kMaxWalkSpeed, Fixed64::fromInt(2));
    store.save(PersonId{2}, b);

    const PlayerProfile ra = store.loadOrCreate(PersonId{1});
    const PlayerProfile rb = store.loadOrCreate(PersonId{2});

    FH_EXPECT_EQ(ra.physical.get(fh::sim::m0::kMaxWalkSpeed).raw,
                 Fixed64::fromInt(1).raw);
    FH_EXPECT_EQ(rb.physical.get(fh::sim::m0::kMaxWalkSpeed).raw,
                 Fixed64::fromInt(2).raw);
}

FH_TEST_MAIN()
