// sim/tests/test_harness.hpp
//
// Zero-dependency test macros. Prints a line per test, fails fast on first
// broken assertion, exits non-zero to trigger ctest failure.

#pragma once

#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace fh::sim::test {

inline int g_failures = 0;
inline const char* g_current_test = "?";

inline void report_failure(const char* file, int line, const char* expr) {
    ++g_failures;
    std::fprintf(stderr,
        "  FAIL %s @ %s:%d\n         %s\n",
        g_current_test, file, line, expr);
}

}  // namespace fh::sim::test

#define FH_TEST(name)                                                          \
    static void name();                                                        \
    struct name##_registrar {                                                  \
        name##_registrar() {                                                   \
            ::fh::sim::test::g_current_test = #name;                           \
            std::fprintf(stdout, "  RUN  %s\n", #name);                        \
            const int before = ::fh::sim::test::g_failures;                    \
            name();                                                            \
            if (::fh::sim::test::g_failures == before)                         \
                std::fprintf(stdout, "  OK   %s\n", #name);                    \
        }                                                                      \
    } g_##name##_registrar;                                                    \
    static void name()

#define FH_EXPECT(cond)                                                        \
    do {                                                                       \
        if (!(cond)) ::fh::sim::test::report_failure(__FILE__, __LINE__, #cond); \
    } while (0)

#define FH_EXPECT_EQ(a, b)   FH_EXPECT((a) == (b))
#define FH_EXPECT_NE(a, b)   FH_EXPECT((a) != (b))
#define FH_EXPECT_LT(a, b)   FH_EXPECT((a) <  (b))
#define FH_EXPECT_LE(a, b)   FH_EXPECT((a) <= (b))
#define FH_EXPECT_GT(a, b)   FH_EXPECT((a) >  (b))
#define FH_EXPECT_GE(a, b)   FH_EXPECT((a) >= (b))

// int main() reports total failures; declared inline so each test .cpp
// gets its own definition.
#define FH_TEST_MAIN()                                                         \
    int main() {                                                               \
        if (::fh::sim::test::g_failures != 0) {                                \
            std::fprintf(stderr, "\n%d assertion failure(s)\n",                \
                         ::fh::sim::test::g_failures);                         \
            return 1;                                                          \
        }                                                                      \
        std::fprintf(stdout, "\nall tests passed\n");                          \
        return 0;                                                              \
    }
