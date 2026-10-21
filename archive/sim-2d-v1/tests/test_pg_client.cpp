// footballhome sim - PgClient constructor error-path tests
//
// This test verifies the fail-loud policy (Rule 4) for PgClient's
// constructor without needing a live Postgres. Full round-trip tests
// against a real DB run out-of-band (docker-compose up + a shell script
// invocation) — see sim/scripts/test_pgclient_live.sh (forthcoming).

#include "persistence/PgClient.hpp"

#include "test_harness.hpp"

#include <string>

using fh::sim::persistence::ConnConfig;
using fh::sim::persistence::PgClient;
using fh::sim::persistence::PgError;

FH_TEST(pgclient_missing_host_throws)
{
    ConnConfig cfg;
    cfg.dbname = "footballhome";
    cfg.user   = "footballhome_user";
    // host deliberately empty
    bool threw = false;
    try {
        PgClient c{cfg};
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"PgClient"});
    }
    FH_EXPECT(threw);
}

FH_TEST(pgclient_missing_dbname_throws)
{
    ConnConfig cfg;
    cfg.host = "127.0.0.1";
    cfg.user = "footballhome_user";
    bool threw = false;
    try {
        PgClient c{cfg};
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"PgClient"});
    }
    FH_EXPECT(threw);
}

FH_TEST(pgclient_missing_user_throws)
{
    ConnConfig cfg;
    cfg.host   = "127.0.0.1";
    cfg.dbname = "footballhome";
    bool threw = false;
    try {
        PgClient c{cfg};
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"PgClient"});
    }
    FH_EXPECT(threw);
}

FH_TEST(pgclient_unreachable_host_throws)
{
    // 127.0.0.1:1 is a reserved / almost-certainly-closed port; libpq
    // must reject connection with an error, and PgClient must translate
    // that to PgError.
    ConnConfig cfg;
    cfg.host   = "127.0.0.1";
    cfg.port   = "1";
    cfg.dbname = "footballhome";
    cfg.user   = "footballhome_user";
    bool threw = false;
    try {
        PgClient c{cfg};
    } catch (const PgError& e) {
        threw = true;
        FH_EXPECT_EQ(e.context(), std::string{"PgClient"});
    }
    FH_EXPECT(threw);
}

FH_TEST_MAIN()
