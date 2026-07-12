// footballhome sim - InMemoryPgClient tests
//
// Exercises the semantics documented in InMemoryPgClient.hpp and
// implicitly on IPgClient. When PgClient (libpqxx) lands, an integration
// test will run this same test body against a live Postgres to prove
// behavioural parity.

#include "persistence/EventTypes.hpp"
#include "persistence/IPgClient.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "test_harness.hpp"

#include <cstddef>
#include <cstring>
#include <optional>
#include <string>
#include <vector>

using fh::sim::ClientId;
using fh::sim::MatchId;
using fh::sim::PersonId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::persistence::EventRow;
using fh::sim::persistence::EventType;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::InputRow;
using fh::sim::persistence::MatchRow;
using fh::sim::persistence::PgError;
using fh::sim::persistence::ProfileBlob;
using fh::sim::persistence::RegistryRow;

namespace {

std::vector<std::byte> bytesOf(std::initializer_list<int> vals)
{
    std::vector<std::byte> out;
    out.reserve(vals.size());
    for (int v : vals) {
        out.push_back(static_cast<std::byte>(v & 0xff));
    }
    return out;
}

MatchRow sampleMatch(MatchId id)
{
    MatchRow row;
    row.id             = id;
    row.scenario_id    = 1;
    row.seed           = 42;
    row.tick_hz        = 20;
    row.server_version = "m0-test";
    row.created_by     = std::nullopt;
    row.visibility     = 0;
    return row;
}

} // namespace

FH_TEST(registry_seed_and_load_round_trip)
{
    InMemoryPgClient db;
    db.seedAttributeRegistry({
        {1, "physical.max_walk_speed",   "physical"},
        {2, "physical.max_sprint_speed", "physical"},
    });
    db.seedConceptRegistry({{1, "run_to_point", "movement"}});
    db.seedPatternRegistry({});

    const auto attrs = db.loadAttributeRegistry();
    FH_EXPECT_EQ(attrs.size(), std::size_t{2});
    FH_EXPECT_EQ(attrs[0].id, std::uint16_t{1});
    FH_EXPECT_EQ(attrs[1].key, std::string{"physical.max_sprint_speed"});

    const auto concepts = db.loadConceptRegistry();
    FH_EXPECT_EQ(concepts.size(), std::size_t{1});
    FH_EXPECT_EQ(concepts[0].key, std::string{"run_to_point"});

    FH_EXPECT(db.loadPatternRegistry().empty());
}

FH_TEST(get_match_missing_returns_nullopt)
{
    InMemoryPgClient db;
    FH_EXPECT(!db.getMatch(999).has_value());
}

FH_TEST(upsert_match_and_read_back)
{
    InMemoryPgClient db;
    db.upsertMatch(sampleMatch(1));

    const auto row = db.getMatch(1);
    FH_EXPECT(row.has_value());
    FH_EXPECT_EQ(row->seed, std::uint64_t{42});
    FH_EXPECT_EQ(row->server_version, std::string{"m0-test"});
}

FH_TEST(upsert_match_replaces_row_on_id_collision)
{
    InMemoryPgClient db;
    db.upsertMatch(sampleMatch(1));
    auto refreshed          = sampleMatch(1);
    refreshed.server_version = "m0-slice-13";
    db.upsertMatch(refreshed);

    const auto row = db.getMatch(1);
    FH_EXPECT(row.has_value());
    FH_EXPECT_EQ(row->server_version, std::string{"m0-slice-13"});
    // ended state is separate; upsert must not resurrect an ended match.
    FH_EXPECT(!db.matchEnded(1));
}

FH_TEST(update_match_ended_writes_result_hash)
{
    InMemoryPgClient db;
    db.upsertMatch(sampleMatch(1));

    const auto hash = bytesOf({0xde, 0xad, 0xbe, 0xef, 0xca, 0xfe, 0xba, 0xbe});
    db.updateMatchEnded(1, hash);

    FH_EXPECT(db.matchEnded(1));
    const auto stored = db.matchResult(1);
    FH_EXPECT(stored.has_value());
    FH_EXPECT_EQ(stored->size(), std::size_t{8});
    FH_EXPECT(std::memcmp(stored->data(), hash.data(), 8) == 0);
}

FH_TEST(update_match_ended_rejects_wrong_hash_length)
{
    InMemoryPgClient db;
    db.upsertMatch(sampleMatch(1));

    bool threw = false;
    try {
        const auto short_hash = bytesOf({0x00, 0x01, 0x02});
        db.updateMatchEnded(1, short_hash);
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"updateMatchEnded"});
    }
    FH_EXPECT(threw);
    FH_EXPECT(!db.matchEnded(1));
}

FH_TEST(update_match_ended_on_missing_match_throws)
{
    InMemoryPgClient db;
    const auto hash = bytesOf({0, 0, 0, 0, 0, 0, 0, 0});

    bool threw = false;
    try {
        db.updateMatchEnded(999, hash);
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"updateMatchEnded"});
    }
    FH_EXPECT(threw);
}

FH_TEST(update_match_ended_is_idempotent)
{
    InMemoryPgClient db;
    db.upsertMatch(sampleMatch(1));

    const auto first_hash  = bytesOf({1, 1, 1, 1, 1, 1, 1, 1});
    const auto second_hash = bytesOf({2, 2, 2, 2, 2, 2, 2, 2});
    db.updateMatchEnded(1, first_hash);
    db.updateMatchEnded(1, second_hash);   // no-op; first hash wins.

    const auto stored = db.matchResult(1);
    FH_EXPECT(stored.has_value());
    FH_EXPECT_EQ((*stored)[0], std::byte{1});
}

FH_TEST(load_profile_missing_returns_nullopt)
{
    InMemoryPgClient db;
    FH_EXPECT(!db.loadProfile(PersonId{7}).has_value());
}

FH_TEST(upsert_profile_and_read_back)
{
    InMemoryPgClient db;
    ProfileBlob blob;
    blob.attributes  = bytesOf({0xaa, 0xbb});
    blob.concepts    = bytesOf({0xcc});
    blob.recognition = bytesOf({0xdd, 0xee, 0xff});

    db.upsertProfile(PersonId{42}, blob);
    const auto loaded = db.loadProfile(PersonId{42});
    FH_EXPECT(loaded.has_value());
    FH_EXPECT_EQ(loaded->attributes.size(), std::size_t{2});
    FH_EXPECT_EQ(loaded->concepts.size(), std::size_t{1});
    FH_EXPECT_EQ(loaded->recognition.size(), std::size_t{3});
    FH_EXPECT_EQ(loaded->attributes[0], std::byte{0xaa});
    FH_EXPECT_EQ(loaded->recognition[2], std::byte{0xff});
}

FH_TEST(input_insertion_preserves_order_across_single_and_batch)
{
    InMemoryPgClient db;

    InputRow a{MatchId{1}, TickNum{10}, SlotId{0}, bytesOf({0x11})};
    InputRow b{MatchId{1}, TickNum{11}, SlotId{1}, bytesOf({0x22})};
    db.insertInput(a);
    db.insertInput(b);

    std::vector<InputRow> batch{
        InputRow{MatchId{1}, TickNum{12}, SlotId{0}, bytesOf({0x33})},
        InputRow{MatchId{1}, TickNum{12}, SlotId{1}, bytesOf({0x44})},
    };
    db.insertInputBatch(batch);

    const auto stored = db.inputsForMatch(MatchId{1});
    FH_EXPECT_EQ(stored.size(), std::size_t{4});
    FH_EXPECT_EQ(stored[0].tick_num, TickNum{10});
    FH_EXPECT_EQ(stored[1].tick_num, TickNum{11});
    FH_EXPECT_EQ(stored[2].payload[0], std::byte{0x33});
    FH_EXPECT_EQ(stored[3].payload[0], std::byte{0x44});
}

FH_TEST(inputs_for_match_filters_by_match_id)
{
    InMemoryPgClient db;
    db.insertInput({MatchId{1}, TickNum{0}, SlotId{0}, bytesOf({0x01})});
    db.insertInput({MatchId{2}, TickNum{0}, SlotId{0}, bytesOf({0x02})});
    db.insertInput({MatchId{1}, TickNum{1}, SlotId{0}, bytesOf({0x03})});

    FH_EXPECT_EQ(db.inputsForMatch(MatchId{1}).size(), std::size_t{2});
    FH_EXPECT_EQ(db.inputsForMatch(MatchId{2}).size(), std::size_t{1});
    FH_EXPECT_EQ(db.inputsForMatch(MatchId{3}).size(), std::size_t{0});
}

FH_TEST(events_preserve_order_and_optional_payload)
{
    InMemoryPgClient db;

    EventRow start{};
    start.match_id   = MatchId{1};
    start.tick_num   = TickNum{0};
    start.event_type = EventType::MatchStart;
    start.payload    = std::nullopt;
    db.insertEvent(start);

    EventRow end{};
    end.match_id   = MatchId{1};
    end.tick_num   = TickNum{400};
    end.event_type = EventType::MatchEnd;
    end.payload    = bytesOf({0xa, 0xb, 0xc, 0xd, 0xe, 0xf, 0x0, 0x1});
    db.insertEvent(end);

    const auto stored = db.eventsForMatch(MatchId{1});
    FH_EXPECT_EQ(stored.size(), std::size_t{2});
    FH_EXPECT(stored[0].event_type == EventType::MatchStart);
    FH_EXPECT(!stored[0].payload.has_value());
    FH_EXPECT(stored[1].payload.has_value());
    FH_EXPECT_EQ(stored[1].payload->size(), std::size_t{8});
}

FH_TEST(event_type_names_are_stable)
{
    // Wire-visible enum: the string names are just for logs, but the
    // numeric values are contractual (see EventTypes.hpp).
    FH_EXPECT_EQ(static_cast<int>(EventType::MatchStart),       1);
    FH_EXPECT_EQ(static_cast<int>(EventType::MatchEnd),         2);
    FH_EXPECT_EQ(static_cast<int>(EventType::ClientConnect),    3);
    FH_EXPECT_EQ(static_cast<int>(EventType::ClientDisconnect), 4);
    FH_EXPECT_EQ(static_cast<int>(EventType::SlotClaim),        5);
    FH_EXPECT_EQ(static_cast<int>(EventType::SlotRelease),      6);
    FH_EXPECT_EQ(static_cast<int>(EventType::ScenarioSuccess),  7);
    FH_EXPECT_EQ(static_cast<int>(EventType::ScenarioReset),    8);
}

FH_TEST_MAIN()
