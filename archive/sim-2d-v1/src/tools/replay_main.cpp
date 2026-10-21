// footballhome sim - fh-sim-replay CLI (§16.6 Slice 13 sub-slice 6)
//
// Standalone binary that reconstructs the final state of a persisted
// match from its input log and prints either the canonical hex dump,
// the FNV-1a-64 canonical hash, or a pass/fail verdict against the
// recorded MatchEnd hash. See tools/Replay.hpp for the replay contract
// and DESIGN.md §16.5 (exit criteria) + §22.13 (M0 profile limitation).
//
// Usage:
//
//   fh-sim-replay --match-id N [options]
//
//     --match-id N       (required)  Match id to replay.
//     --up-to-tick T                  Stop after T ticks. Default:
//                                     tick_num of the recorded MatchEnd
//                                     event (reproduces the exact final
//                                     state the live server hashed).
//     --emit-hash                     Print "hash=0x…" (16 hex chars).
//     --emit-hex                      Print full canonical dump to stdout.
//     --verify                        Compare computed hash against the
//                                     8-byte MatchEnd payload; exit 0 on
//                                     match, 1 on mismatch. This is the
//                                     default action when no --emit-*
//                                     flag is passed.
//
// DB connection uses the same POSTGRES_* env vars as footballhome_sim:
// POSTGRES_HOST / _PORT / _DB / _USER / _PASSWORD. Missing PASSWORD
// aborts with exit code 4 (matches main.cpp for consistency).
//
// Exit codes:
//   0  — success (replay ran; hash matched when --verify was in effect)
//   1  — hash mismatch under --verify
//   2  — CLI parse error
//   3  — DB error / match not found / other runtime error
//   4  — POSTGRES_PASSWORD missing

#include "match/CanonicalHash.hpp"
#include "persistence/IPgClient.hpp"
#include "persistence/PgClient.hpp"
#include "tools/Replay.hpp"

#include <charconv>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <optional>
#include <string>
#include <string_view>
#include <system_error>

#ifndef FH_SIM_GIT_DESCRIBE
#define FH_SIM_GIT_DESCRIBE "unknown"
#endif

namespace {

const char* envOr(const char* name, const char* fallback) noexcept
{
    const char* v = std::getenv(name);
    return (v != nullptr && v[0] != '\0') ? v : fallback;
}

std::optional<std::uint64_t> parseU64(std::string_view s) noexcept
{
    std::uint64_t out = 0;
    const char* begin = s.data();
    const char* end   = s.data() + s.size();
    auto [ptr, ec] = std::from_chars(begin, end, out);
    if (ec != std::errc{} || ptr != end) { return std::nullopt; }
    return out;
}

std::optional<std::uint32_t> parseU32(std::string_view s) noexcept
{
    std::uint32_t out = 0;
    const char* begin = s.data();
    const char* end   = s.data() + s.size();
    auto [ptr, ec] = std::from_chars(begin, end, out);
    if (ec != std::errc{} || ptr != end) { return std::nullopt; }
    return out;
}

void usage()
{
    std::fputs(
        "fh-sim-replay (" FH_SIM_GIT_DESCRIBE ")\n"
        "\n"
        "Usage: fh-sim-replay --match-id N [options]\n"
        "\n"
        "  --match-id N       required — match id to replay\n"
        "  --up-to-tick T     stop after T ticks (default: MatchEnd.tick_num)\n"
        "  --emit-hash        print computed hash to stdout\n"
        "  --emit-hex         print canonical dump to stdout\n"
        "  --verify           compare hash against recorded MatchEnd\n"
        "  --help             show this message and exit\n",
        stderr);
}

} // namespace

int main(int argc, char** argv)
{
    // ------------------------------------------------------------------
    // Arg parsing
    // ------------------------------------------------------------------
    std::optional<std::uint64_t> match_id;
    std::optional<std::uint32_t> up_to_tick;
    bool emit_hash = false;
    bool emit_hex  = false;
    bool verify    = false;

    for (int i = 1; i < argc; ++i) {
        const std::string_view arg{argv[i]};
        if (arg == "--help" || arg == "-h") {
            usage();
            return 0;
        }
        if (arg == "--emit-hash") { emit_hash = true; continue; }
        if (arg == "--emit-hex")  { emit_hex  = true; continue; }
        if (arg == "--verify")    { verify    = true; continue; }
        if (arg == "--match-id") {
            if (++i >= argc) {
                std::fputs("fh-sim-replay: --match-id needs a value\n", stderr);
                return 2;
            }
            match_id = parseU64(argv[i]);
            if (!match_id) {
                std::fprintf(stderr,
                    "fh-sim-replay: invalid --match-id '%s'\n", argv[i]);
                return 2;
            }
            continue;
        }
        if (arg == "--up-to-tick") {
            if (++i >= argc) {
                std::fputs("fh-sim-replay: --up-to-tick needs a value\n", stderr);
                return 2;
            }
            up_to_tick = parseU32(argv[i]);
            if (!up_to_tick) {
                std::fprintf(stderr,
                    "fh-sim-replay: invalid --up-to-tick '%s'\n", argv[i]);
                return 2;
            }
            continue;
        }
        std::fprintf(stderr, "fh-sim-replay: unknown arg '%.*s'\n",
            static_cast<int>(arg.size()), arg.data());
        usage();
        return 2;
    }

    if (!match_id) {
        std::fputs("fh-sim-replay: --match-id is required\n", stderr);
        usage();
        return 2;
    }

    // Default action if the caller didn't pick one: --verify. Rationale:
    // the primary use of this binary is CI cross-arch determinism proof,
    // which needs a pass/fail exit code.
    if (!emit_hash && !emit_hex && !verify) {
        verify = true;
    }

    // ------------------------------------------------------------------
    // DB connect
    // ------------------------------------------------------------------
    fh::sim::persistence::ConnConfig db_cfg;
    db_cfg.host             = envOr("POSTGRES_HOST",     "db");
    db_cfg.port             = envOr("POSTGRES_PORT",     "5432");
    db_cfg.dbname           = envOr("POSTGRES_DB",       "footballhome");
    db_cfg.user             = envOr("POSTGRES_USER",     "footballhome_user");
    db_cfg.application_name = "fh-sim-replay";
    const char* db_pw = std::getenv("POSTGRES_PASSWORD");
    if (db_pw == nullptr || db_pw[0] == '\0') {
        std::fputs("fh-sim-replay: POSTGRES_PASSWORD is required\n", stderr);
        return 4;
    }
    db_cfg.password = db_pw;

    std::unique_ptr<fh::sim::persistence::PgClient> db;
    try {
        db = std::make_unique<fh::sim::persistence::PgClient>(db_cfg);
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-sim-replay: DB connect failed: %s\n", e.what());
        return 3;
    }

    // ------------------------------------------------------------------
    // Replay
    // ------------------------------------------------------------------
    fh::sim::tools::ReplayOptions opts;
    opts.up_to_tick   = up_to_tick;
    opts.collect_dump = emit_hex;

    fh::sim::tools::ReplayResult result;
    try {
        result = fh::sim::tools::replayMatch(*db, *match_id, opts);
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-sim-replay: replay failed: %s\n", e.what());
        return 3;
    }

    // ------------------------------------------------------------------
    // Output
    // ------------------------------------------------------------------
    if (emit_hex) {
        std::fputs(result.canonical_dump.c_str(), stdout);
    }
    if (emit_hash) {
        std::fprintf(stdout,
            "hash=0x%016lx tick=%u inputs=%zu slots=%zu\n",
            static_cast<unsigned long>(result.canonical_hash),
            static_cast<unsigned>(result.final_tick),
            result.inputs_applied,
            result.slots_synthesized);
    }
    if (verify) {
        const auto end = db->loadMatchEnd(*match_id);
        if (!end) {
            std::fputs(
                "fh-sim-replay: --verify but no MatchEnd event recorded\n",
                stderr);
            return 3;
        }
        if (end->payload.size() != 8) {
            std::fprintf(stderr,
                "fh-sim-replay: MatchEnd payload is %zu bytes, expected 8\n",
                end->payload.size());
            return 3;
        }
        const auto expected_bytes = fh::sim::match::hashToBytesBE(
            result.canonical_hash);
        const bool ok =
            std::memcmp(expected_bytes.data(), end->payload.data(), 8) == 0;
        if (!ok) {
            // Reconstitute the recorded hash for a legible diagnostic.
            std::uint64_t recorded = 0;
            for (int i = 0; i < 8; ++i) {
                recorded = (recorded << 8) |
                    std::to_integer<std::uint64_t>(end->payload[i]);
            }
            std::fprintf(stderr,
                "fh-sim-replay: HASH MISMATCH\n"
                "  match_id      = %lu\n"
                "  target_tick   = %u\n"
                "  computed hash = 0x%016lx\n"
                "  recorded hash = 0x%016lx\n",
                static_cast<unsigned long>(*match_id),
                static_cast<unsigned>(result.final_tick),
                static_cast<unsigned long>(result.canonical_hash),
                static_cast<unsigned long>(recorded));
            return 1;
        }
        std::fprintf(stdout,
            "fh-sim-replay: OK match_id=%lu tick=%u hash=0x%016lx\n",
            static_cast<unsigned long>(*match_id),
            static_cast<unsigned>(result.final_tick),
            static_cast<unsigned long>(result.canonical_hash));
    }
    return 0;
}
