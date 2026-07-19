// footballhome sim - process entrypoint
//
// M0 bootstrap:
//   * Reads JWT_SECRET, SIM_BIND_ADDRESS, SIM_PORT, SIM_MATCH_SEED,
//     SIM_MATCH_ID from the env (all with sensible defaults except
//     JWT_SECRET which is required).
//   * Reads POSTGRES_HOST/_PORT/_DB/_USER/_PASSWORD (same convention as
//     footballhome_backend). Connects, loads sim_attribute_registry /
//     sim_concept_registry / sim_pattern_registry, and runs the boot-
//     time drift check (§16.6, §22.9). Any DB failure aborts startup.
//   * Constructs JwtVerifier + WebSocketTransport + EmptyPitchScenario
//     + Match + BinaryV1Serializer + SimServer.
//   * Installs SIGINT/SIGTERM handlers that call SimServer::stop().
//   * Runs the sim loop forever (or until stop).
//
// No exceptions escape main(); every construction failure prints to
// stderr and exits with a non-zero code.

#include "admin/AdminHttpServer.hpp"
#include "auth/JwtVerifier.hpp"
#include "match/CanonicalHash.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "net/BinaryV1Serializer.hpp"
#include "net/WebSocketTransport.hpp"
#include "persistence/EventLog.hpp"
#include "persistence/EventTypes.hpp"
#include "persistence/IPgClient.hpp"
#include "persistence/InputLog.hpp"
#include "persistence/PgClient.hpp"
#include "persistence/ProfileStore.hpp"
#include "persistence/RegistryLoader.hpp"
#include "physics/BasicPhysics.hpp"
#include "registry/AttributeRegistry.hpp"
#include "registry/ConceptRegistry.hpp"
#include "registry/PatternRegistry.hpp"
#include "scenario/BallOnPitchScenario.hpp"
#include "scenario/BallOnPitch2v0Scenario.hpp"
#include "scenario/GoalDrillScenario.hpp"
#include "scenario/BallOnPitchWithDefenderScenario.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "scenario/HalfPitchScenario.hpp"
#include "scenario/SoftDrillScenario.hpp"
#include "server/SimServer.hpp"

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <csignal>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <vector>

// Populated by CMake at configure time (see sim/CMakeLists.txt).
// Falls back to "unknown" for non-git builds.
#ifndef FH_SIM_GIT_DESCRIBE
#define FH_SIM_GIT_DESCRIBE "unknown"
#endif

namespace {

// Global stop signal so signal handlers can reach the server without
// std::function or heap allocations. Set to non-null only while run()
// is executing.
std::atomic<fh::sim::server::SimServer*> g_server{nullptr};

// ---------------------------------------------------------------------
// §21.7 item 1 step 4A: warm-daemon match assignment gate.
//
// Two entry paths into the "hot phase" of this daemon:
//   (1) SIM_MATCH_ID env set at process start (pre-existing behaviour).
//       Env values feed straight through; the gate is never touched;
//       assign_match_handler is not even wired (endpoint returns 404).
//   (2) SIM_MATCH_ID env unset AND admin server enabled
//       (FH_SIM_ADMIN_TOKEN set). Boot completes registries + admin
//       server + then BLOCKS on the gate. The first successful
//       POST /admin/assign_match (contracted in AdminHttpServer.hpp)
//       flips the gate and unblocks main; the payload becomes
//       match_id / seed / scenario_id for the rest of boot. A second
//       assign_match on the same daemon returns kConflict — assignment
//       is single-shot per process.
//
// Motivation: eliminate the ~800 ms podman create+start round-trip
// from per-match boot latency by pre-spawning daemons that stall on
// the gate. See §16.7 (warm-daemon-pool design) and §21.7 item 1
// (M2 blocker: warm-image spawn floor).
// ---------------------------------------------------------------------
struct MatchAssignment {
    std::uint64_t match_id{0};
    std::uint64_t seed{0};
    std::int16_t  scenario_id{0};
};

class AssignmentGate {
public:
    // Called by AdminHttpServer's assign_match_handler on the admin
    // accept-loop thread. Returns true on first successful assignment,
    // false if an assignment was already recorded (handler maps that
    // to HTTP 409 Conflict per the AdminHttpServer.hpp contract).
    bool assign(const MatchAssignment& a) noexcept
    {
        std::lock_guard<std::mutex> lock(mu_);
        if (assigned_.has_value()) { return false; }
        assigned_ = a;
        cv_.notify_all();
        return true;
    }
    // Called by the main thread. Blocks until either (a) assign()
    // succeeds (returns the assignment) or (b) g_shutdown_requested
    // becomes true (returns nullopt). Polls the shutdown flag every
    // 100 ms because condition variables cannot be safely notified
    // from an async signal handler (::pthread_mutex_lock is not
    // async-signal-safe) — the handler just sets the atomic and this
    // wait period observes it. 100 ms is a compromise between idle
    // CPU (~10 wakeups/s per warm daemon) and observed SIGTERM
    // shutdown latency; well below the 10 s podman-stop grace window.
    std::optional<MatchAssignment> waitForAssign();
private:
    std::mutex                     mu_;
    std::condition_variable        cv_;
    std::optional<MatchAssignment> assigned_;
};

AssignmentGate g_assignment_gate;

// Snapshot of the resolved match_id, read by the admin tick_stats
// provider from the accept-loop thread while the main thread runs the
// tick loop. std::atomic sidesteps the data-race UB that a plain int
// would introduce when the assign path stores from main while the
// accept-loop thread reads. The tick_stats_provider only meaningfully
// dereferences this after g_server becomes non-null; between admin
// server start and g_server.store, the provider returns the "booting"
// placeholder body and never touches this value.
std::atomic<std::uint64_t> g_current_match_id{0};

// §21.7 item 1 step 4B: signal-driven shutdown flag for the pre-
// server-run boot windows (specifically the warm-boot gate wait).
// std::atomic<bool> is guaranteed lock-free on every target platform,
// so an atomic store is async-signal-safe — the extended handleSignal
// below sets it from signal context, and AssignmentGate::waitForAssign
// observes it via a 100 ms cv_.wait_for polling loop. The env-set path
// never reaches waitForAssign so this flag is irrelevant to it; that
// path continues to rely on the sigaction installed just before
// server.run() to catch SIGTERM.
std::atomic<bool> g_shutdown_requested{false};

extern "C" void handleSignal(int /*sig*/) noexcept
{
    // §21.7 item 1 step 4B: also flag warm-boot shutdown so any pre-
    // server-run wait (currently: AssignmentGate::waitForAssign) can
    // observe and unblock cleanly. Setting the atomic is safe from
    // async signal context; taking the gate's mutex to notify_all
    // would not be, hence the polling loop on the wait side.
    g_shutdown_requested.store(true, std::memory_order_relaxed);
    auto* srv = g_server.load(std::memory_order_relaxed);
    if (srv != nullptr) { srv->stop(); }
}

// Namespace-scope out-of-line definition (declaration inside
// AssignmentGate above). Uses g_shutdown_requested defined just above.
std::optional<MatchAssignment> AssignmentGate::waitForAssign()
{
    std::unique_lock<std::mutex> lock(mu_);
    for (;;) {
        if (assigned_.has_value()) { return *assigned_; }
        if (g_shutdown_requested.load(std::memory_order_relaxed)) {
            return std::nullopt;
        }
        cv_.wait_for(lock, std::chrono::milliseconds(100));
    }
}

const char* envOr(const char* name, const char* fallback) noexcept
{
    const char* v = std::getenv(name);
    return (v != nullptr && v[0] != '\0') ? v : fallback;
}

std::uint16_t parsePort(const char* s) noexcept
{
    if (s == nullptr) { return 0; }
    const long v = std::strtol(s, nullptr, 10);
    if (v < 0 || v > 0xFFFF) { return 0; }
    return static_cast<std::uint16_t>(v);
}

std::uint64_t parseU64(const char* s, std::uint64_t fallback) noexcept
{
    if (s == nullptr || s[0] == '\0') { return fallback; }
    char* end = nullptr;
    const unsigned long long v = std::strtoull(s, &end, 10);
    if (end == s) { return fallback; }
    return static_cast<std::uint64_t>(v);
}

std::int64_t nowSecs() noexcept
{
    using namespace std::chrono;
    return duration_cast<seconds>(
        system_clock::now().time_since_epoch()).count();
}

} // namespace

int main(int /*argc*/, char** /*argv*/)
{
    // ------------------------------------------------------------------
    // Config
    // ------------------------------------------------------------------
    const char* secret_c = std::getenv("JWT_SECRET");
    if (secret_c == nullptr || secret_c[0] == '\0') {
        std::fprintf(stderr, "footballhome_sim: JWT_SECRET is required\n");
        return 2;
    }
    const std::string jwt_secret{secret_c};

    const std::string  bind_addr{envOr("SIM_BIND_ADDRESS", "0.0.0.0")};
    const std::uint16_t port     = parsePort(envOr("SIM_PORT", "9100"));

    // §21.7 item 1 step 4A: capture whether SIM_MATCH_ID was
    // explicitly set. When unset AND admin server enabled, boot blocks
    // on the assignment gate below and these initial defaults are
    // overwritten by the assign_match payload. The default match_id=1
    // / seed=42 fallback is preserved for the admin-disabled path so
    // existing single-process dev runs keep working unchanged.
    const char* sim_match_id_c = std::getenv("SIM_MATCH_ID");
    const bool  sim_match_id_env_set =
        (sim_match_id_c != nullptr && sim_match_id_c[0] != '\0');
    std::uint64_t match_id = parseU64(sim_match_id_c, 1);
    std::uint64_t seed     = parseU64(std::getenv("SIM_MATCH_SEED"), 42);

    // Slice 15.5: scenario selection. Values map to sim_scenarios.code_id;
    // Replay.cpp::makeScenario is the single source of truth for the runtime
    // side of the id -> Scenario mapping — keep them in lock-step. Default
    // stays empty_pitch (M0 behaviour); switch to ball_on_pitch to demo the
    // Slice 15 ball trailer end-to-end.
    const std::string scenario_name{envOr("SIM_SCENARIO", "empty_pitch")};
    std::int16_t scenario_id = 0;
    if      (scenario_name == "empty_pitch")                { scenario_id = 0; }
    else if (scenario_name == "ball_on_pitch")              { scenario_id = 1; }
    else if (scenario_name == "half_pitch_hard")            { scenario_id = 2; }
    else if (scenario_name == "soft_drill")                 { scenario_id = 3; }
    else if (scenario_name == "ball_on_pitch_with_defender"){ scenario_id = 4; }
    else if (scenario_name == "ball_on_pitch_2v0")          { scenario_id = 5; }
    else if (scenario_name == "goal_drill")                 { scenario_id = 6; }
    else {
        std::fprintf(stderr,
                     "footballhome_sim: unknown SIM_SCENARIO=\"%s\" — "
                     "expected one of: empty_pitch, ball_on_pitch, "
                     "half_pitch_hard, soft_drill, ball_on_pitch_with_defender, "
                     "ball_on_pitch_2v0, goal_drill\n",
                     scenario_name.c_str());
        return 2;
    }

    // ------------------------------------------------------------------
    // Registry catalog: connect to Postgres, load the three sim registries,
    // and run the boot-time drift check against the compile-time M0 catalog
    // (§16.6, §22.9, §22.11, §22.12). Any failure aborts before the
    // network transport is opened — a mismatched catalog is a corruption-
    // class bug, not something to recover from at runtime.
    // ------------------------------------------------------------------
    fh::sim::persistence::ConnConfig db_cfg;
    db_cfg.host     = envOr("POSTGRES_HOST",     "db");
    db_cfg.port     = envOr("POSTGRES_PORT",     "5432");
    db_cfg.dbname   = envOr("POSTGRES_DB",       "footballhome");
    db_cfg.user     = envOr("POSTGRES_USER",     "footballhome_user");
    const char* db_pw = std::getenv("POSTGRES_PASSWORD");
    if (db_pw == nullptr || db_pw[0] == '\0') {
        std::fprintf(stderr,
                     "footballhome_sim: POSTGRES_PASSWORD is required\n");
        return 4;
    }
    db_cfg.password = db_pw;

    fh::sim::registry::AttributeRegistry attr_registry;
    fh::sim::registry::ConceptRegistry   concept_registry;
    fh::sim::registry::PatternRegistry   pattern_registry;

    // Hoisted so ProfileStore below keeps a live connection for the
    // duration of the sim process. This is the *request-thread*
    // connection (§22.12 decision #4) — registry bootstrap, profile
    // load/save on WS connect, first-tick + match-end updates. The
    // flush-thread connection (`log_db` below, added 2026-07-16 as the
    // Slice 26.4 hotfix) is a separate PgClient owned by the async
    // input/event log sinks so libpqxx never sees two `pqxx::work`s
    // on one connection from two threads (which throws
    // "Started new transaction while transaction was still active"
    // and downgrades the connecting client to a spectator — blocking
    // the two-human M2 test).
    std::unique_ptr<fh::sim::persistence::PgClient> db;
    try {
        db = std::make_unique<fh::sim::persistence::PgClient>(db_cfg);
        fh::sim::persistence::loadAttributeRegistryFromDb(attr_registry,    *db);
        fh::sim::persistence::loadConceptRegistryFromDb  (concept_registry, *db);
        fh::sim::persistence::loadPatternRegistryFromDb  (pattern_registry, *db);
        fh::sim::persistence::verifyM0RegistryConsistency(attr_registry,
                                                          concept_registry);
    } catch (const fh::sim::persistence::PgError& e) {
        std::fprintf(stderr,
                     "footballhome_sim: registry bootstrap failed: %s: %s\n",
                     e.context().c_str(),
                     e.what());
        return 5;
    }

    fh::sim::persistence::ProfileStore profile_store{*db};

    // ------------------------------------------------------------------
    // Admin HTTP server (§16.6 sub-slice 8.1, DESIGN §22.12).
    //
    // The admin endpoint (POST /admin/replay) executes cross-container
    // replay requests originating from `footballhome_backend`. It gets
    // its OWN Postgres connection ("admin_db") so it can query and
    // insert alongside the tick loop without contending on the primary
    // connection or the async log-drain connection.
    //
    // Disabled at runtime when FH_SIM_ADMIN_TOKEN is unset/empty. This
    // is *not* fatal — dev environments that don't need the endpoint
    // (or a compromised token being rotated) shouldn't take the sim
    // down. Missing DB, though, IS fatal (same tier as the main db
    // failure above).
    //
    // Bind is intentionally 0.0.0.0 inside the podman network; the
    // network segment itself is the security boundary. The bearer
    // token defence-in-depths against a rogue container.
    // ------------------------------------------------------------------
    std::unique_ptr<fh::sim::persistence::PgClient>   admin_db;
    std::unique_ptr<fh::sim::admin::AdminHttpServer>  admin_server;
    const char* admin_token_c = std::getenv("FH_SIM_ADMIN_TOKEN");
    const bool  admin_enabled =
        (admin_token_c != nullptr && admin_token_c[0] != '\0');
    if (admin_enabled) {
        try {
            admin_db = std::make_unique<fh::sim::persistence::PgClient>(db_cfg);
        } catch (const fh::sim::persistence::PgError& e) {
            std::fprintf(stderr,
                         "footballhome_sim: admin db connect failed: %s: %s\n",
                         e.context().c_str(),
                         e.what());
            return 7;
        }
        fh::sim::admin::AdminHttpServer::Config acfg;
        acfg.bind_address = envOr("SIM_ADMIN_BIND_ADDRESS", "0.0.0.0");
        acfg.port         = parsePort(envOr("SIM_ADMIN_PORT", "9101"));
        acfg.admin_token  = admin_token_c;
        // §21.7 item 2 diagnostic (2026-07-14): expose the tick-loop
        // health counters over GET /admin/tick_stats. The lambda reads
        // the SimServer through the g_server atomic populated below
        // just before server.run() — before that store completes (i.e.
        // during the small boot window between AdminHttpServer::start()
        // and g_server.store) the provider returns a placeholder body
        // rather than nullptr-derefing. Counters are std::atomic on the
        // sim side so this lambda is safe to invoke concurrently with
        // the tick loop.
        //
        // §21.7 item 1 step 4A: match_id now sourced from the atomic
        // g_current_match_id, populated below once assignment is
        // finalised (either from env or from POST /admin/assign_match).
        // A tick_stats call during the pre-assignment wait window
        // takes the g_server==nullptr branch above and never reads
        // g_current_match_id at all.
        acfg.tick_stats_provider = []() -> std::string {
            auto* srv = g_server.load(std::memory_order_relaxed);
            if (srv == nullptr) {
                return std::string{"{\"state\":\"booting\"}"};
            }
            char buf[256];
            const int n = std::snprintf(buf, sizeof(buf),
                "{\"match_id\":%llu,\"tick_hz\":20,"
                "\"ticks_executed\":%llu,"
                "\"catch_up_skips\":%u,"
                "\"sum_behind_ms\":%llu,"
                "\"max_behind_ms\":%u,"
                "\"active_clients\":%u}",
                static_cast<unsigned long long>(
                    g_current_match_id.load(std::memory_order_relaxed)),
                static_cast<unsigned long long>(srv->ticksExecuted()),
                static_cast<unsigned>(srv->catchUpSkips()),
                static_cast<unsigned long long>(srv->sumBehindMs()),
                static_cast<unsigned>(srv->maxBehindMs()),
                static_cast<unsigned>(srv->activeClientCount()));
            return std::string(buf, (n > 0 ? static_cast<std::size_t>(n) : 0));
        };

        // §21.7 item 1 step 4A: wire POST /admin/assign_match only
        // when SIM_MATCH_ID env is unset. On env-configured daemons
        // the endpoint stays hidden (404) so an accidentally-directed
        // assign_match call cannot mislead the orchestrator into
        // believing the daemon now serves the assigned match when it
        // is actually still serving its env-configured one. The
        // handler runs on the admin accept-loop thread; g_assignment_gate
        // synchronises with the main thread via mutex + condition
        // variable.
        if (!sim_match_id_env_set) {
            acfg.assign_match_handler =
                [](const fh::sim::admin::AssignMatchRequest& req)
                -> fh::sim::admin::AssignMatchResult {
                MatchAssignment a;
                a.match_id    = static_cast<std::uint64_t>(req.match_id);
                a.seed        = req.seed;
                a.scenario_id = req.scenario_id;
                fh::sim::admin::AssignMatchResult r;
                if (!g_assignment_gate.assign(a)) {
                    r.outcome = fh::sim::admin::AssignMatchOutcome::kConflict;
                    return r;
                }
                r.outcome = fh::sim::admin::AssignMatchOutcome::kOk;
                char buf[192];
                const int n = std::snprintf(buf, sizeof(buf),
                    "{\"assigned\":true,\"match_id\":%llu,"
                    "\"seed\":%llu,\"scenario_id\":%d}",
                    static_cast<unsigned long long>(a.match_id),
                    static_cast<unsigned long long>(a.seed),
                    static_cast<int>(a.scenario_id));
                r.body_json = std::string(
                    buf, (n > 0 ? static_cast<std::size_t>(n) : 0));
                return r;
            };
        }

        admin_server = std::make_unique<fh::sim::admin::AdminHttpServer>(
            acfg, *admin_db);
        if (!admin_server->start()) {
            std::fprintf(stderr,
                         "footballhome_sim: admin http server failed to "
                         "bind %s:%u\n",
                         acfg.bind_address.c_str(),
                         static_cast<unsigned>(acfg.port));
            return 8;
        }
    } else {
        std::fprintf(stderr,
                     "footballhome_sim: FH_SIM_ADMIN_TOKEN not set — "
                     "admin http server disabled\n");
    }

    // ------------------------------------------------------------------
    // Flush-thread PgClient (Slice 26.4, 2026-07-16).
    //
    // AsyncPgLog<Row> drains from a dedicated background thread
    // (InputLog + EventLog). libpqxx `pqxx::connection` is NOT
    // thread-safe: only one `pqxx::work` may exist per connection at
    // any time. The `db` connection above is owned by the transport
    // thread (WS-accept -> ProfileStore::loadOrCreate) and the tick
    // thread (first_tick_callback + match-end update); routing the
    // async batch inserts through the SAME connection races and
    // throws "Started new transaction while transaction was still
    // active" every time the drain fires mid-connect. The catch in
    // SimServer::handleConnect swallows the throw and degrades the
    // client to slot=0 (spectator) — which was the root cause of the
    // "tab 2 can watch but can't play" bug that blocked the M2 two-
    // human test on 2026-07-16.
    //
    // Fix: give the log sinks their own `pqxx::connection`. Failure
    // to connect is fatal on the same tier as `db` — without it we
    // can't persist inputs/events and the match would silently lose
    // its replay tape.
    // ------------------------------------------------------------------
    std::unique_ptr<fh::sim::persistence::PgClient> log_db;
    try {
        log_db = std::make_unique<fh::sim::persistence::PgClient>(db_cfg);
    } catch (const fh::sim::persistence::PgError& e) {
        std::fprintf(stderr,
                     "footballhome_sim: log db connect failed: %s: %s\n",
                     e.context().c_str(),
                     e.what());
        return 6;
    }

    // ------------------------------------------------------------------
    // §21.7 item 1 step 4A: warm-daemon assignment wait.
    //
    // If SIM_MATCH_ID was not set at process start AND the admin
    // server is up, block here until POST /admin/assign_match arrives.
    // The handler wired above fills g_assignment_gate; waitForAssign()
    // unblocks and yields the payload. match_id/seed/scenario_id are
    // overwritten with the assigned values before the drift check,
    // upsertMatch, WS bind, and SimServer construction below — those
    // consume the values by-plain-copy so they see the resolved ones.
    //
    // If the admin server is disabled OR SIM_MATCH_ID was set, this
    // block is a no-op and the env-derived match_id/seed/scenario_id
    // flow straight through — byte-identical to pre-4A behaviour.
    // ------------------------------------------------------------------
    if (admin_enabled && !sim_match_id_env_set) {
        // §21.7 item 1 step 4B: arm SIGINT/SIGTERM before the wait so
        // an orchestrator retiring an idle warm daemon (e.g. pool
        // shrink, host drain) can shut down cleanly instead of
        // relying on SIGKILL. The env-set path continues to install
        // sigaction just before server.run() further below — that
        // install is idempotent, so re-running it in the env-unset
        // path here is a harmless no-op re-registration.
        struct sigaction sa{};
        sa.sa_handler = handleSignal;
        ::sigemptyset(&sa.sa_mask);
        sa.sa_flags   = 0;
        ::sigaction(SIGINT,  &sa, nullptr);
        ::sigaction(SIGTERM, &sa, nullptr);

        std::fprintf(stderr,
                     "footballhome_sim: SIM_MATCH_ID unset — waiting for "
                     "POST /admin/assign_match on admin port %u...\n",
                     static_cast<unsigned>(
                         parsePort(envOr("SIM_ADMIN_PORT", "9101"))));
        const auto maybe_a = g_assignment_gate.waitForAssign();
        if (!maybe_a.has_value()) {
            // Shutdown signal beat the assignment. Tear down the admin
            // server (idempotent no-op if never started) and exit 0 —
            // no match was ever taken, so there is nothing DB-side to
            // finalise (no upsertMatch happened, no MatchStart event
            // was written, no WS transport was bound).
            std::fprintf(stderr,
                         "footballhome_sim: shutdown requested before "
                         "assignment — exiting cleanly\n");
            if (admin_server) { admin_server->stop(); }
            return 0;
        }
        const auto& a = *maybe_a;
        match_id    = a.match_id;
        seed        = a.seed;
        scenario_id = a.scenario_id;
        std::fprintf(stderr,
                     "footballhome_sim: assigned via admin — "
                     "match_id=%llu seed=%llu scenario_id=%d\n",
                     static_cast<unsigned long long>(match_id),
                     static_cast<unsigned long long>(seed),
                     static_cast<int>(scenario_id));
    }
    // Publish the resolved match_id for the admin tick_stats provider
    // (env path OR post-wait path — both land here).
    g_current_match_id.store(match_id, std::memory_order_relaxed);

    std::fprintf(stderr,
                 "footballhome_sim: loaded registries — "
                 "attrs=%zu concepts=%zu patterns=%zu\n",
                 attr_registry.size(),
                 concept_registry.size(),
                 pattern_registry.size());

    // ------------------------------------------------------------------
    // Match lifecycle boot (§16.6 task 7).
    //
    // upsertMatch is idempotent: a crash-restart of the same match_id
    // preserves any previously logged inputs/events but refreshes the
    // server_version so ops can see which build handled a given restart
    // window. scenario_id is 0 in M0 (only EmptyPitchScenario exists);
    // real scenario cataloguing lands with the drills work in M1.
    //
    // Before upserting we READ the existing row (if any) and refuse to
    // start if (scenario_id, seed, tick_hz) differ from what we're
    // about to write. Rationale: those three fields identify the
    // *deterministic replay contract* of the match — every input in
    // sim_match_inputs was recorded against them, and `fh-sim-replay`
    // will reproduce a divergent hash if they silently change under it.
    // `upsertMatch`'s `ON CONFLICT` clause (spec §16.6) only refreshes
    // server_version and NEVER overwrites config fields (both to
    // preserve replay coherence and because the DB is the source of
    // truth for recorded matches). So a divergence between "what env /
    // seed the daemon thinks it's serving" and "what the DB row says
    // this match was played with" is either an operator error (bumped
    // SIM_MATCH_SEED without cleaning the row) or a bug (someone hand-
    // edited the row). Either way, fail loud at boot — surfacing the
    // drift here is orders of magnitude cheaper than debugging a
    // divergent replay hash three days later. Closes DESIGN §16.5 note
    // added 2026-07-13.
    //
    // MatchStart is written after upsertMatch so any ORDER BY tick_num,
    // event_type observer sees a coherent "row exists, then it began".
    // ------------------------------------------------------------------
    try {
        // Slice 15.5: scenario_id now comes from SIM_SCENARIO (resolved above)
        // rather than being a hardcoded 0. Keep the drift check strict — the
        // deterministic replay contract still hinges on all three fields.
        constexpr std::int16_t kTickHz       = 20;

        const auto existing = db->getMatch(match_id);
        if (existing.has_value()) {
            const bool drift =
                existing->scenario_id != scenario_id
                || existing->seed     != seed
                || existing->tick_hz  != kTickHz;
            if (drift) {
                std::fprintf(stderr,
                    "footballhome_sim: refusing to start — sim_matches row "
                    "for match_id=%llu already exists with config that "
                    "differs from this daemon's intended write:\n"
                    "  DB  : scenario_id=%d seed=%llu tick_hz=%d "
                    "server_version=%s\n"
                    "  boot: scenario_id=%d seed=%llu tick_hz=%d\n"
                    "Recorded inputs are keyed against the DB row's "
                    "(scenario_id, seed, tick_hz); silently overwriting "
                    "them would corrupt every replay. Fix: either bump "
                    "SIM_MATCH_ID to a fresh id, or clean the existing "
                    "row (DELETE FROM sim_matches WHERE id=%llu — cascades "
                    "to sim_match_inputs + sim_match_events).\n",
                    static_cast<unsigned long long>(match_id),
                    static_cast<int>(existing->scenario_id),
                    static_cast<unsigned long long>(existing->seed),
                    static_cast<int>(existing->tick_hz),
                    existing->server_version.c_str(),
                    static_cast<int>(scenario_id),
                    static_cast<unsigned long long>(seed),
                    static_cast<int>(kTickHz),
                    static_cast<unsigned long long>(match_id));
                return 6;
            }
        }

        fh::sim::persistence::MatchRow mrow;
        mrow.id             = match_id;
        mrow.scenario_id    = scenario_id;
        mrow.seed           = seed;
        mrow.tick_hz        = kTickHz;
        mrow.server_version = FH_SIM_GIT_DESCRIBE;
        db->upsertMatch(mrow);

        fh::sim::persistence::EventRow start_ev;
        start_ev.match_id   = match_id;
        start_ev.tick_num   = 0;
        start_ev.event_type = fh::sim::persistence::EventType::MatchStart;
        // No payload: MatchStart is a bare lifecycle marker.
        db->insertEvent(start_ev);
    } catch (const fh::sim::persistence::PgError& e) {
        std::fprintf(stderr,
                     "footballhome_sim: match lifecycle boot failed: %s: %s\n",
                     e.context().c_str(),
                     e.what());
        return 6;
    }

    // ------------------------------------------------------------------
    // Dependencies
    // ------------------------------------------------------------------
    auto verifier = std::make_unique<fh::sim::auth::JwtVerifier>(
        jwt_secret, &nowSecs);

    fh::sim::net::ws::WebSocketTransport::Config tx_cfg;
    tx_cfg.bind_address = bind_addr;
    tx_cfg.port         = port;
    auto transport = std::make_unique<fh::sim::net::ws::WebSocketTransport>(
        tx_cfg, verifier.get());

    if (!transport->start()) {
        std::fprintf(stderr,
                     "footballhome_sim: failed to bind %s:%u\n",
                     bind_addr.c_str(),
                     static_cast<unsigned>(port));
        return 3;
    }

    // Match ------------------------------------------------------------
    fh::sim::match::MatchConfig mcfg;
    mcfg.id             = match_id;
    mcfg.seed           = seed;
    mcfg.server_version = FH_SIM_GIT_DESCRIBE;
    mcfg.physics  = std::make_unique<fh::sim::physics::BasicPhysics>();
    mcfg.pattern_registry = &pattern_registry;
    // Slice 15.5 + Slice 18.x + Slice 24.3a: pick the Scenario matching
    // the resolved scenario_id. Keep this switch in lock-step with
    // sim/src/tools/Replay.cpp::makeScenario and sim_scenarios.code_id
    // (see database/migrations/207/212/213/215).
    switch (scenario_id) {
        case 1:
            mcfg.scenario = std::make_unique<fh::sim::scenario::BallOnPitchScenario>();
            break;
        case 2:
            mcfg.scenario = std::make_unique<fh::sim::scenario::HalfPitchScenario>();
            break;
        case 3:
            mcfg.scenario = std::make_unique<fh::sim::scenario::SoftDrillScenario>();
            break;
        case 4:
            mcfg.scenario = std::make_unique<fh::sim::scenario::BallOnPitchWithDefenderScenario>();
            break;
        case 5:
            mcfg.scenario = std::make_unique<fh::sim::scenario::BallOnPitch2v0Scenario>();
            break;
        case 6:
            mcfg.scenario = std::make_unique<fh::sim::scenario::GoalDrillScenario>();
            break;
        case 0:
        default:
            mcfg.scenario = std::make_unique<fh::sim::scenario::EmptyPitchScenario>();
            break;
    }
    mcfg.clock    = std::make_unique<fh::sim::match::RealtimeClock>(20);
    auto match = std::make_unique<fh::sim::match::Match>(std::move(mcfg));

    auto serializer = std::make_unique<fh::sim::net::BinaryV1Serializer>();

    // Server -----------------------------------------------------------
    fh::sim::server::SimServer::Config scfg;
    scfg.tick_hz  = 20;
    scfg.match_id = match_id;
    // §21.7 item 2 remedy: fire updateMatchFirstTick from the tick
    // thread the instant the first tick body completes, so
    // sim_matches.first_tick_at anchors the load test's §5.5
    // effective-Hz denominator on the true "loop began ticking" wall
    // instant rather than on upsertMatch's boot-time started_at (which
    // includes ~1.5 s of pre-first-tick boot per §21.7 item 1). Captures
    // db.get() by value — the underlying PgClient outlives the SimServer
    // (see the input_log / event_log capture pattern below) so this is
    // safe. Exceptions inside the callback are swallowed by SimServer's
    // caller (main) unwind path — the callback itself only makes one
    // DB round-trip; a failure there is logged by PgClient's PgError
    // path but should not tear down the whole match (a missing
    // first_tick_at simply falls back to started_at via the COALESCE
    // in the effective-Hz SQL).
    scfg.first_tick_callback = [db_ptr = db.get(), match_id]() {
        try {
            db_ptr->updateMatchFirstTick(match_id);
        } catch (const fh::sim::persistence::PgError& e) {
            std::fprintf(stderr,
                         "footballhome_sim: updateMatchFirstTick failed: "
                         "%s: %s (continuing; effective-Hz will fall back "
                         "to started_at via COALESCE)\n",
                         e.context().c_str(),
                         e.what());
        }
    };

    // Async persistence logs (§16.6 task 8). Sinks capture log_db.get()
    // by value so the lambda lifetime is decoupled from the log's —
    // the underlying PgClient outlives both logs (both `.stop()` before
    // the `log_db` unique_ptr resets at scope exit). Capacity 256 per
    // spec: ~13 s of one-input-per-tick-per-slot at 20 Hz.
    //
    // Slice 26.4 (2026-07-16): sinks route through log_db, NOT db, so
    // the drain thread never contends with the transport thread's
    // ProfileStore::loadOrCreate call on the shared libpqxx
    // connection. See the `log_db` construction block above for the
    // full rationale.
    fh::sim::persistence::InputLog input_log(
        [db_ptr = log_db.get()](std::span<const fh::sim::persistence::InputRow> rows) {
            db_ptr->insertInputBatch(rows);
        });
    fh::sim::persistence::EventLog event_log(
        [db_ptr = log_db.get()](std::span<const fh::sim::persistence::EventRow> rows) {
            db_ptr->insertEventBatch(rows);
        });

    fh::sim::server::SimServer server(scfg,
                                      std::move(transport),
                                      std::move(serializer),
                                      std::move(match),
                                      &profile_store,
                                      &input_log,
                                      &event_log);

    // ------------------------------------------------------------------
    // Signals
    // ------------------------------------------------------------------
    g_server.store(&server, std::memory_order_relaxed);

    struct sigaction sa{};
    sa.sa_handler = handleSignal;
    ::sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;   // deliberately NOT SA_RESTART: poll() returning
                       // EINTR is fine and gives us a natural loop wake.
    ::sigaction(SIGINT,  &sa, nullptr);
    ::sigaction(SIGTERM, &sa, nullptr);

    // Broken-pipe on send() is handled by MSG_NOSIGNAL inside the
    // transport; still, ignore SIGPIPE globally to be safe.
    struct sigaction ign{};
    ign.sa_handler = SIG_IGN;
    ::sigaction(SIGPIPE, &ign, nullptr);

    std::fprintf(stderr,
                 "footballhome_sim: listening on %s:%u  match=%llu  seed=%llu\n",
                 bind_addr.c_str(),
                 static_cast<unsigned>(port),
                 static_cast<unsigned long long>(match_id),
                 static_cast<unsigned long long>(seed));

    server.run();

    g_server.store(nullptr, std::memory_order_relaxed);

    // Stop admin HTTP server first: no external client should be able
    // to trigger a replay or observe partial-shutdown state while we
    // drain the input/event logs and write MatchEnd. `stop()` is
    // idempotent and safe if the server was never started.
    if (admin_server) { admin_server->stop(); }

    // Stop async log drains BEFORE writing MatchEnd (§16.6 task 8).
    // Any queued input / event rows must land in Postgres before the
    // MatchEnd row so a "sort by tick_num, event_type" scan sees a
    // coherent sequence. `stop()` performs a best-effort final drain
    // and joins the thread; any sink errors during shutdown are
    // logged internally and counted as drops.
    input_log.stop();
    event_log.stop();

    const std::size_t input_dropped = input_log.dropped();
    const std::size_t event_dropped = event_log.dropped();
    if (input_dropped != 0u || event_dropped != 0u) {
        std::fprintf(stderr,
                     "footballhome_sim: async log dropped rows: "
                     "inputs=%zu events=%zu (see earlier warnings)\n",
                     input_dropped, event_dropped);
    }

    // ------------------------------------------------------------------
    // Match lifecycle shutdown (§16.6 task 7).
    //
    // Canonical FNV-1a-64 hash of the final snapshot is written twice:
    //   * as sim_match_events row event_type=MatchEnd (payload = 8-byte
    //     big-endian hash) so replay tools can verify per-tick reruns
    //     against the last-seen live hash without a separate result
    //     lookup;
    //   * as sim_matches.result via updateMatchEnded (same 8 bytes) so
    //     the lobby's `WHERE ended_at IS NULL` predicate hides the row
    //     and ops queries can join match+result without touching the
    //     event table.
    //
    // A failure here is logged but not fatal — the sim is already tearing
    // down and the process has to exit anyway. Ops will notice a match
    // without ended_at set and can rerun via the replay tool.
    // ------------------------------------------------------------------
    try {
        const std::uint64_t hash =
            fh::sim::match::canonicalMatchHash(server.match());
        const auto hash_bytes = fh::sim::match::hashToBytesBE(hash);
        std::vector<std::byte> payload(hash_bytes.begin(), hash_bytes.end());

        fh::sim::persistence::EventRow end_ev;
        end_ev.match_id   = match_id;
        end_ev.tick_num   = server.match().tick_num();
        end_ev.event_type = fh::sim::persistence::EventType::MatchEnd;
        end_ev.payload    = std::move(payload);
        db->insertEvent(end_ev);

        db->updateMatchEnded(match_id,
                             std::span<const std::byte>{hash_bytes});

        std::fprintf(stderr,
                     "footballhome_sim: match_end hash=0x%016lx tick=%u\n",
                     static_cast<unsigned long>(hash),
                     static_cast<unsigned>(server.match().tick_num()));
    } catch (const fh::sim::persistence::PgError& e) {
        std::fprintf(stderr,
                     "footballhome_sim: match lifecycle shutdown failed: %s: %s\n",
                     e.context().c_str(),
                     e.what());
        // Fall through to clean shutdown.
    }

    std::fprintf(stderr, "footballhome_sim: shutdown complete\n");
    return 0;
}
