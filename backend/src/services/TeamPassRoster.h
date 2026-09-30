#pragma once
#include <string>
#include "RosterFile.h"

// TeamPassRoster — pulls a team's official "Printable Roster" PDF from
// TeamPass (app.teampass.com, the APSL's league site), the sheet a referee
// checks players against.  Owner 2026-09-30: "it has to be the official
// exact roster from site … printed fresh for each game … to prove the
// roster is current to refs".
//
// The PDF link only exists for the team's staff, so every pull is a fresh
// sign-in:
//   1. GET  /reg/login/                 the form + its hidden fields
//   2. POST the form                    session cookies
//   3. GET  /<site>/Team/<id>           the staff view, which carries the
//                                       signed "Printable Roster" link
//   4. GET  that link                   the PDF (empty body without the session)
//
// TeamPass drops this server's IP on its dynamic pages (docs/SCRAPER_VPN.md),
// so the requests leave through the forward proxy in the scraper+VPN
// container: TEAMPASS_PROXY_URL, default http://footballhome_scraper:3128,
// "direct" for none.
//
// The login comes from the environment, named by the source row's
// credentials_key: <KEY>_EMAIL / <KEY>_PASSWORD (APSL_EMAIL, APSL_PASSWORD —
// the same names apsl-credentials.conf uses).
class TeamPassRoster {
public:
    using Result = RosterFile;

    // siteSlug "APSL", externalTeamId "165430", credentialsKey "APSL".
    static Result fetch(const std::string& siteSlug, const std::string& externalTeamId, const std::string& credentialsKey);
};
