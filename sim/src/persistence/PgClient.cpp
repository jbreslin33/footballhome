// footballhome sim - PgClient (libpqxx)
//
// Production Postgres client. All SQL for the sim daemon lives at the top
// of this file as prepared-statement definitions. Method bodies each open
// a short-lived `pqxx::work` transaction and delegate to the prepared
// statement. Every method translates libpqxx exceptions to PgError so
// callers see a uniform error type.
//
// See DESIGN.md §22.12 (persistence architecture ADR), §8 (schema).

#include "persistence/PgClient.hpp"

#include <pqxx/pqxx>

namespace pqxx {
argument_error::argument_error(std::string const& msg, std::source_location loc)
    : std::invalid_argument(msg), location(loc)
{}

conversion_error::conversion_error(std::string const& msg, std::source_location loc)
    : std::domain_error(msg), location(loc)
{}
} // namespace pqxx

#include <cstddef>
#include <cstring>
#include <exception>
#include <sstream>
#include <string>
#include <string_view>

namespace fh::sim::persistence {

namespace {

// Prepared-statement names. Kept short — they show up in server logs.
constexpr const char* PS_LOAD_ATTR              = "load_attribute_registry";
constexpr const char* PS_LOAD_CONCEPT           = "load_concept_registry";
constexpr const char* PS_LOAD_PATTERN           = "load_pattern_registry";
constexpr const char* PS_GET_MATCH              = "get_match";
constexpr const char* PS_UPSERT_MATCH           = "upsert_match";
constexpr const char* PS_UPDATE_MATCH_FIRST_TICK = "update_match_first_tick";
constexpr const char* PS_UPDATE_MATCH_ENDED     = "update_match_ended";
constexpr const char* PS_LOAD_PROFILE_EXISTS    = "load_profile_exists";
constexpr const char* PS_LOAD_PROFILE_ATTR      = "load_profile_attr";
constexpr const char* PS_LOAD_PROFILE_CONCEPT   = "load_profile_concept";
constexpr const char* PS_LOAD_PROFILE_RECOG     = "load_profile_recog";
constexpr const char* PS_UPSERT_PROFILE_PARENT  = "upsert_profile_parent";
constexpr const char* PS_DELETE_PROFILE_ATTR    = "delete_profile_attr";
constexpr const char* PS_DELETE_PROFILE_CONCEPT = "delete_profile_concept";
constexpr const char* PS_DELETE_PROFILE_RECOG   = "delete_profile_recog";
constexpr const char* PS_INSERT_PROFILE_ATTR    = "insert_profile_attr";
constexpr const char* PS_INSERT_PROFILE_CONCEPT = "insert_profile_concept";
constexpr const char* PS_INSERT_PROFILE_RECOG   = "insert_profile_recog";
constexpr const char* PS_INSERT_INPUT           = "insert_input";
constexpr const char* PS_LOAD_INPUTS_ALL        = "load_inputs_all";
constexpr const char* PS_LOAD_INPUTS_UPTO       = "load_inputs_upto";
constexpr const char* PS_INSERT_EVENT           = "insert_event";
constexpr const char* PS_LOAD_MATCH_END         = "load_match_end";

// libpqxx 7.x uses exec_prepared with prepared statement names registered
// on the connection. The older pqxx::prepped{...} helper is not available
// in this environment, so we execute the SQL by name instead.

// libpqxx 7.x accepts std::basic_string_view<std::byte> as a bytea
// parameter and returns std::basic_string<std::byte> when a column is
// read with .as<pqxx::bytes>(). We alias for readability.
using PgBytesView = std::basic_string_view<std::byte>;
using PgBytes     = std::basic_string<std::byte>;

PgBytesView viewOf(std::span<const std::byte> s) noexcept
{
    return PgBytesView{s.data(), s.size()};
}

std::vector<std::byte> toVector(const PgBytes& b)
{
    std::vector<std::byte> out;
    out.reserve(b.size());
    out.insert(out.end(), b.begin(), b.end());
    return out;
}

std::string buildConnString(const ConnConfig& c)
{
    // Fail-loud on missing required fields (Rule 4).
    if (c.host.empty())   throw PgError("PgClient", "host is empty");
    if (c.dbname.empty()) throw PgError("PgClient", "dbname is empty");
    if (c.user.empty())   throw PgError("PgClient", "user is empty");
    // Password may legitimately be empty (peer / trust auth) — no check.

    // libpq expects keyword=value pairs. All fields here are constrained
    // by env parsing before we get here (docker-compose supplies them),
    // so we don't quote — but keep the format consistent with libpq
    // parsing rules.
    std::ostringstream os;
    os << "host="             << c.host
       << " port="            << c.port
       << " dbname="          << c.dbname
       << " user="            << c.user
       << " application_name=" << c.application_name;
    if (!c.password.empty()) {
        os << " password=" << c.password;
    }
    return os.str();
}

// Read one bytea column into a std::vector<std::byte>. libpqxx 7.x
// returns bytea as pqxx::bytes when the field type is queried explicitly.
std::vector<std::byte> readBytea(const pqxx::row::reference& field)
{
    if (field.is_null()) {
        return {};
    }
    auto val = field.as<PgBytes>();
    return toVector(val);
}

} // namespace

// ---------------------------------------------------------------------------
// Impl: hides libpqxx from callers of the header.
// ---------------------------------------------------------------------------

struct PgClient::Impl {
    pqxx::connection conn;

    explicit Impl(const std::string& conninfo)
        : conn(conninfo) {}
};

// ---------------------------------------------------------------------------
// Construction / destruction
// ---------------------------------------------------------------------------

PgClient::PgClient(const ConnConfig& cfg)
{
    try {
        impl_ = std::make_unique<Impl>(buildConnString(cfg));

        auto& c = impl_->conn;

        c.prepare(PS_LOAD_ATTR,
            "SELECT id, key, category FROM sim_attribute_registry ORDER BY id ASC");
        c.prepare(PS_LOAD_CONCEPT,
            "SELECT id, key, category FROM sim_concept_registry ORDER BY id ASC");
        c.prepare(PS_LOAD_PATTERN,
            "SELECT id, key, category FROM sim_pattern_registry ORDER BY id ASC");

        c.prepare(PS_GET_MATCH,
            "SELECT id, scenario_id, seed, tick_hz, server_version, "
            "       created_by, visibility "
            "FROM sim_matches WHERE id = $1");

        c.prepare(PS_UPSERT_MATCH,
            "INSERT INTO sim_matches "
            "  (id, scenario_id, seed, tick_hz, server_version, "
            "   created_by, visibility) "
            "VALUES ($1, $2, $3, $4, $5, $6, $7) "
            "ON CONFLICT (id) DO UPDATE SET "
            "  server_version = EXCLUDED.server_version");

        // Idempotent under crash-restart: WHERE ended_at IS NULL means a
        // second call is a no-op (updated 0 rows).
        c.prepare(PS_UPDATE_MATCH_ENDED,
            "UPDATE sim_matches SET ended_at = NOW(), result = $2 "
            "WHERE id = $1 AND ended_at IS NULL");

        // §21.7 item 2 remedy: one-shot first-tick stamp. Guarded by
        // WHERE first_tick_at IS NULL so a crash-restart preserves the
        // original tick-start instant (mirrors updateMatchEnded's
        // idempotence pattern).
        c.prepare(PS_UPDATE_MATCH_FIRST_TICK,
            "UPDATE sim_matches SET first_tick_at = NOW() "
            "WHERE id = $1 AND first_tick_at IS NULL");

        c.prepare(PS_LOAD_PROFILE_EXISTS,
            "SELECT 1 FROM sim_player_profile WHERE person_id = $1");
        c.prepare(PS_LOAD_PROFILE_ATTR,
            "SELECT attr_id, value FROM sim_player_attribute "
            "WHERE person_id = $1 ORDER BY attr_id ASC");
        c.prepare(PS_LOAD_PROFILE_CONCEPT,
            "SELECT concept_id, mastery FROM sim_player_concept "
            "WHERE person_id = $1 ORDER BY concept_id ASC");
        c.prepare(PS_LOAD_PROFILE_RECOG,
            "SELECT pattern_id, skill FROM sim_player_recognition "
            "WHERE person_id = $1 ORDER BY pattern_id ASC");

        // Parent envelope. In M0 the ON CONFLICT branch never fires
        // (§22.14 write policy — one INSERT per person for the lifetime
        // of a match); post-M0, DO UPDATE bumps updated_at so ops can
        // spot rewrites in the DB.
        c.prepare(PS_UPSERT_PROFILE_PARENT,
            "INSERT INTO sim_player_profile (person_id) VALUES ($1) "
            "ON CONFLICT (person_id) DO UPDATE SET updated_at = NOW()");

        // Replace-whole-set semantics: DELETE all child rows for
        // person_id, then INSERT the incoming set. Runs inside the same
        // pqxx::work as the parent upsert, so the transition is atomic.
        c.prepare(PS_DELETE_PROFILE_ATTR,
            "DELETE FROM sim_player_attribute WHERE person_id = $1");
        c.prepare(PS_DELETE_PROFILE_CONCEPT,
            "DELETE FROM sim_player_concept WHERE person_id = $1");
        c.prepare(PS_DELETE_PROFILE_RECOG,
            "DELETE FROM sim_player_recognition WHERE person_id = $1");

        c.prepare(PS_INSERT_PROFILE_ATTR,
            "INSERT INTO sim_player_attribute (person_id, attr_id, value) "
            "VALUES ($1, $2, $3)");
        c.prepare(PS_INSERT_PROFILE_CONCEPT,
            "INSERT INTO sim_player_concept (person_id, concept_id, mastery) "
            "VALUES ($1, $2, $3)");
        c.prepare(PS_INSERT_PROFILE_RECOG,
            "INSERT INTO sim_player_recognition (person_id, pattern_id, skill) "
            "VALUES ($1, $2, $3)");

        c.prepare(PS_INSERT_INPUT,
            "INSERT INTO sim_match_inputs "
            "  (match_id, tick_num, slot_id, payload) "
            "VALUES ($1, $2, $3, $4) "
            "ON CONFLICT (match_id, tick_num, slot_id) DO UPDATE SET "
            "  payload = EXCLUDED.payload");

        // Replay reads (see fh-sim-replay). Sort key must be stable so
        // the replay driver applies inputs in the same order the live
        // server accepted them.
        c.prepare(PS_LOAD_INPUTS_ALL,
            "SELECT match_id, tick_num, slot_id, payload "
            "FROM sim_match_inputs WHERE match_id = $1 "
            "ORDER BY tick_num ASC, slot_id ASC");
        c.prepare(PS_LOAD_INPUTS_UPTO,
            "SELECT match_id, tick_num, slot_id, payload "
            "FROM sim_match_inputs "
            "WHERE match_id = $1 AND tick_num <= $2 "
            "ORDER BY tick_num ASC, slot_id ASC");

        c.prepare(PS_INSERT_EVENT,
            "INSERT INTO sim_match_events "
            "  (match_id, tick_num, event_type, payload) "
            "VALUES ($1, $2, $3, $4)");

        // Latest MatchEnd (event_type=2) row. Under crash-restart the
        // sim may write MatchEnd twice with slightly different snapshot
        // hashes; the last-written wins (matches
        // InMemoryPgClient::loadMatchEnd's reverse-scan semantics).
        c.prepare(PS_LOAD_MATCH_END,
            "SELECT tick_num, payload FROM sim_match_events "
            "WHERE match_id = $1 AND event_type = 2 "
            "ORDER BY id DESC LIMIT 1");
    } catch (const PgError&) {
        throw;
    } catch (const pqxx::sql_error& e) {
        throw PgError("PgClient", std::string{"SQL error: "} + e.what());
    } catch (const std::exception& e) {
        throw PgError("PgClient", e.what());
    }
}

PgClient::~PgClient() = default;

// ---------------------------------------------------------------------------
// Registry reads
// ---------------------------------------------------------------------------

std::vector<RegistryRow> PgClient::loadAttributeRegistry()
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res = tx.exec_prepared(PS_LOAD_ATTR);
        std::vector<RegistryRow> out;
        out.reserve(res.size());
        for (const auto& r : res) {
            RegistryRow row;
            row.id       = r[0].as<std::uint16_t>();
            row.key      = r[1].as<std::string>();
            row.category = r[2].as<std::string>();
            out.push_back(std::move(row));
        }
        tx.commit();
        return out;
    } catch (const std::exception& e) {
        throw PgError("loadAttributeRegistry", e.what());
    }
}

std::vector<RegistryRow> PgClient::loadConceptRegistry()
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res = tx.exec_prepared(PS_LOAD_CONCEPT);
        std::vector<RegistryRow> out;
        out.reserve(res.size());
        for (const auto& r : res) {
            RegistryRow row;
            row.id       = r[0].as<std::uint16_t>();
            row.key      = r[1].as<std::string>();
            row.category = r[2].as<std::string>();
            out.push_back(std::move(row));
        }
        tx.commit();
        return out;
    } catch (const std::exception& e) {
        throw PgError("loadConceptRegistry", e.what());
    }
}

std::vector<RegistryRow> PgClient::loadPatternRegistry()
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res = tx.exec_prepared(PS_LOAD_PATTERN);
        std::vector<RegistryRow> out;
        out.reserve(res.size());
        for (const auto& r : res) {
            RegistryRow row;
            row.id       = r[0].as<std::uint16_t>();
            row.key      = r[1].as<std::string>();
            row.category = r[2].as<std::string>();
            out.push_back(std::move(row));
        }
        tx.commit();
        return out;
    } catch (const std::exception& e) {
        throw PgError("loadPatternRegistry", e.what());
    }
}

// ---------------------------------------------------------------------------
// Match lifecycle
// ---------------------------------------------------------------------------

std::optional<MatchRow> PgClient::getMatch(MatchId id)
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res = tx.exec_prepared(PS_GET_MATCH, id);
        tx.commit();
        if (res.empty()) {
            return std::nullopt;
        }
        const auto& r = res[0];
        MatchRow out;
        out.id             = r[0].as<MatchId>();
        out.scenario_id    = r[1].as<std::int16_t>();
        out.seed           = r[2].as<std::uint64_t>();
        out.tick_hz        = r[3].as<std::int16_t>();
        out.server_version = r[4].as<std::string>();
        if (!r[5].is_null()) {
            out.created_by = r[5].as<PersonId>();
        }
        out.visibility     = r[6].as<std::int16_t>();
        return out;
    } catch (const std::exception& e) {
        throw PgError("getMatch", e.what());
    }
}

void PgClient::upsertMatch(const MatchRow& row)
{
    try {
        pqxx::work tx(impl_->conn);
        if (row.created_by.has_value()) {
            tx.exec_prepared(PS_UPSERT_MATCH,
                row.id, row.scenario_id, row.seed, row.tick_hz,
                row.server_version, *row.created_by, row.visibility);
        } else {
            tx.exec_prepared(PS_UPSERT_MATCH,
                row.id, row.scenario_id, row.seed, row.tick_hz,
                row.server_version, nullptr, row.visibility);
        }
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("upsertMatch", e.what());
    }
}

void PgClient::updateMatchFirstTick(MatchId id)
{
    try {
        pqxx::work tx(impl_->conn);
        tx.exec_prepared(PS_UPDATE_MATCH_FIRST_TICK, id);
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("updateMatchFirstTick", e.what());
    }
}

void PgClient::updateMatchEnded(MatchId id,
                                std::span<const std::byte> result_hash)
{
    if (result_hash.size() != 8) {
        throw PgError("updateMatchEnded",
            "result_hash must be exactly 8 bytes (got " +
                std::to_string(result_hash.size()) + ")");
    }
    try {
        pqxx::work tx(impl_->conn);
        tx.exec_prepared(PS_UPDATE_MATCH_ENDED, id, viewOf(result_hash));
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("updateMatchEnded", e.what());
    }
}

// ---------------------------------------------------------------------------
// Player profile
// ---------------------------------------------------------------------------

std::optional<ProfileRows> PgClient::loadProfile(PersonId person_id)
{
    try {
        pqxx::work tx(impl_->conn);

        // Existence check first — nullopt vs "row present but all child
        // tables empty" are semantically different (the latter means
        // save() was called with empty sets, a valid but weird state).
        const auto exists = tx.exec_prepared(PS_LOAD_PROFILE_EXISTS, person_id);
        if (exists.empty()) {
            tx.commit();
            return std::nullopt;
        }

        ProfileRows out;

        const auto attr_res = tx.exec_prepared(PS_LOAD_PROFILE_ATTR, person_id);
        out.attributes.reserve(attr_res.size());
        for (const auto& r : attr_res) {
            out.attributes.emplace_back(r[0].as<std::uint16_t>(),
                                        r[1].as<float>());
        }

        const auto concept_res = tx.exec_prepared(PS_LOAD_PROFILE_CONCEPT, person_id);
        out.concepts.reserve(concept_res.size());
        for (const auto& r : concept_res) {
            out.concepts.emplace_back(r[0].as<std::uint16_t>(),
                                      r[1].as<float>());
        }

        const auto recog_res = tx.exec_prepared(PS_LOAD_PROFILE_RECOG, person_id);
        out.recognition.reserve(recog_res.size());
        for (const auto& r : recog_res) {
            out.recognition.emplace_back(r[0].as<std::uint16_t>(),
                                         r[1].as<float>());
        }

        tx.commit();
        return out;
    } catch (const std::exception& e) {
        throw PgError("loadProfile", e.what());
    }
}

void PgClient::upsertProfile(PersonId person_id, const ProfileRows& rows)
{
    try {
        pqxx::work tx(impl_->conn);

        // 1) Parent envelope (see PS_UPSERT_PROFILE_PARENT for §22.14
        //    note about the DO UPDATE branch).
        tx.exec_prepared(PS_UPSERT_PROFILE_PARENT, person_id);

        // 2) Replace-whole-set: wipe then re-insert. Atomic inside the tx.
        //    In M0 the DELETE removes 0 rows (first touch); post-M0 this
        //    still preserves the previous bytea-column semantics of
        //    "the payload IS the set".
        tx.exec_prepared(PS_DELETE_PROFILE_ATTR, person_id);
        tx.exec_prepared(PS_DELETE_PROFILE_CONCEPT, person_id);
        tx.exec_prepared(PS_DELETE_PROFILE_RECOG, person_id);

        for (const auto& [attr_id, value] : rows.attributes) {
            tx.exec_prepared(PS_INSERT_PROFILE_ATTR, person_id, attr_id, value);
        }
        for (const auto& [concept_id, mastery] : rows.concepts) {
            tx.exec_prepared(PS_INSERT_PROFILE_CONCEPT, person_id, concept_id, mastery);
        }
        for (const auto& [pattern_id, skill] : rows.recognition) {
            tx.exec_prepared(PS_INSERT_PROFILE_RECOG, person_id, pattern_id, skill);
        }

        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("upsertProfile", e.what());
    }
}

// ---------------------------------------------------------------------------
// Input log
// ---------------------------------------------------------------------------

void PgClient::insertInput(const InputRow& row)
{
    try {
        pqxx::work tx(impl_->conn);
        tx.exec_prepared(PS_INSERT_INPUT,
            row.match_id, row.tick_num, row.slot_id,
            viewOf(std::span<const std::byte>{row.payload}));
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("insertInput", e.what());
    }
}

void PgClient::insertInputBatch(std::span<const InputRow> rows)
{
    if (rows.empty()) {
        return;
    }
    try {
        pqxx::work tx(impl_->conn);
        for (const auto& row : rows) {
            tx.exec_prepared(PS_INSERT_INPUT,
                row.match_id, row.tick_num, row.slot_id,
                viewOf(std::span<const std::byte>{row.payload}));
        }
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("insertInputBatch", e.what());
    }
}

std::vector<InputRow>
PgClient::loadInputsForMatch(MatchId id,
                             std::optional<TickNum> up_to_tick)
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res =
            up_to_tick.has_value()
                ? tx.exec_prepared(PS_LOAD_INPUTS_UPTO, id, *up_to_tick)
                : tx.exec_prepared(PS_LOAD_INPUTS_ALL, id);
        std::vector<InputRow> out;
        out.reserve(res.size());
        for (const auto& r : res) {
            InputRow row;
            row.match_id = r[0].as<MatchId>();
            row.tick_num = r[1].as<TickNum>();
            row.slot_id  = r[2].as<SlotId>();
            row.payload  = readBytea(r[3]);
            out.push_back(std::move(row));
        }
        tx.commit();
        return out;
    } catch (const std::exception& e) {
        throw PgError("loadInputsForMatch", e.what());
    }
}

// ---------------------------------------------------------------------------
// Event log
// ---------------------------------------------------------------------------

void PgClient::insertEvent(const EventRow& row)
{
    try {
        pqxx::work tx(impl_->conn);
        const std::int16_t event_type = static_cast<std::int16_t>(row.event_type);
        if (row.payload.has_value()) {
            tx.exec_prepared(PS_INSERT_EVENT,
                row.match_id, row.tick_num, event_type,
                viewOf(std::span<const std::byte>{*row.payload}));
        } else {
            tx.exec_prepared(PS_INSERT_EVENT,
                row.match_id, row.tick_num, event_type, nullptr);
        }
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("insertEvent", e.what());
    }
}

void PgClient::insertEventBatch(std::span<const EventRow> rows)
{
    if (rows.empty()) {
        return;
    }
    try {
        pqxx::work tx(impl_->conn);
        for (const auto& row : rows) {
            const std::int16_t event_type =
                static_cast<std::int16_t>(row.event_type);
            if (row.payload.has_value()) {
                tx.exec_prepared(PS_INSERT_EVENT,
                    row.match_id, row.tick_num, event_type,
                    viewOf(std::span<const std::byte>{*row.payload}));
            } else {
                tx.exec_prepared(PS_INSERT_EVENT,
                    row.match_id, row.tick_num, event_type, nullptr);
            }
        }
        tx.commit();
    } catch (const std::exception& e) {
        throw PgError("insertEventBatch", e.what());
    }
}

std::optional<IPgClient::MatchEndRecord>
PgClient::loadMatchEnd(MatchId id)
{
    try {
        pqxx::work tx(impl_->conn);
        const auto res = tx.exec_prepared(PS_LOAD_MATCH_END, id);
        tx.commit();
        if (res.empty()) {
            return std::nullopt;
        }
        const auto& r = res[0];
        MatchEndRecord rec;
        rec.tick_num = r[0].as<TickNum>();
        rec.payload  = readBytea(r[1]);
        return rec;
    } catch (const std::exception& e) {
        throw PgError("loadMatchEnd", e.what());
    }
}

} // namespace fh::sim::persistence
