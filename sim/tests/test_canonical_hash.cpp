// footballhome sim - CanonicalHash unit tests
//
// Direct tests of the FNV-1a-64 + big-endian byte encoding primitives.
// Snapshot round-trip is not tested here — that path is exercised (with
// a golden hash) by test_determinism. This file exists to lock down the
// hash algorithm itself so we can catch a regression in the primitive
// even if no scenario happens to have a snapshot that trips the golden
// hashes.

#include "match/CanonicalHash.hpp"
#include "test_harness.hpp"

#include <array>
#include <cstddef>
#include <cstdint>
#include <string>
#include <string_view>

using fh::sim::match::fnv1a64;
using fh::sim::match::hashToBytesBE;
using fh::sim::match::kFnvOffsetBasis64;
using fh::sim::match::kFnvPrime64;

FH_TEST(fnv1a64_empty_input_returns_offset_basis)
{
    FH_EXPECT_EQ(fnv1a64(std::string_view{""}), kFnvOffsetBasis64);
}

FH_TEST(fnv1a64_single_byte_a_matches_reference_vector)
{
    // Reference: (offset_basis ^ 'a') * prime, taken mod 2^64.
    const std::uint64_t expected =
        (kFnvOffsetBasis64 ^ static_cast<std::uint8_t>('a')) * kFnvPrime64;
    FH_EXPECT_EQ(fnv1a64(std::string_view{"a"}), expected);
}

FH_TEST(fnv1a64_foobar_matches_published_reference_vector)
{
    // RFC-style public test vector for FNV-1a-64:
    //   FNV-1a-64("foobar") = 0x85944171f73967e8
    FH_EXPECT_EQ(fnv1a64(std::string_view{"foobar"}),
                 0x85944171f73967e8ULL);
}

FH_TEST(fnv1a64_is_stable_for_same_input)
{
    const std::string s = "tick=42 time_ms=2100 count=3\n";
    FH_EXPECT_EQ(fnv1a64(s), fnv1a64(s));
}

FH_TEST(fnv1a64_differs_for_one_bit_change)
{
    FH_EXPECT(fnv1a64(std::string_view{"abc"})
              != fnv1a64(std::string_view{"abd"}));
}

FH_TEST(hash_to_bytes_be_zero_is_all_zero)
{
    const auto bytes = hashToBytesBE(0);
    for (std::size_t i = 0; i < 8; ++i) {
        FH_EXPECT_EQ(static_cast<std::uint8_t>(bytes[i]), 0u);
    }
}

FH_TEST(hash_to_bytes_be_puts_most_significant_byte_first)
{
    // 0x0123456789abcdef → bytes = {01, 23, 45, 67, 89, ab, cd, ef}.
    const auto bytes = hashToBytesBE(0x0123456789abcdefULL);
    const std::array<std::uint8_t, 8> expected{
        0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef,
    };
    for (std::size_t i = 0; i < 8; ++i) {
        FH_EXPECT_EQ(static_cast<std::uint8_t>(bytes[i]), expected[i]);
    }
}

FH_TEST(hash_to_bytes_be_all_ones_is_all_ff)
{
    const auto bytes = hashToBytesBE(0xffffffffffffffffULL);
    for (std::size_t i = 0; i < 8; ++i) {
        FH_EXPECT_EQ(static_cast<std::uint8_t>(bytes[i]), 0xffu);
    }
}

FH_TEST_MAIN()
