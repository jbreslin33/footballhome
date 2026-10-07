#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

// Contacts — the club's people as one list for #contacts (migration 541):
// adult players on the board teams, parents of youth players, coaches,
// club staff, leads and opponent contacts, each with every number and
// email on file.  Against contact_exports for one operator each row is
// 'new' (never exported by them), 'changed' (numbers/emails differ from
// what they exported) or 'done'.
class Contacts {
public:
    struct Row {
        std::string kind;        // person | lead | club_contact
        long long   refId = 0;
        std::vector<std::string> groups;   // members parents coaches staff leads opponents
        std::string first, last;
        std::string teams, kids, org, role, since;
        std::vector<std::string> phones, emails;
        std::string fingerprint;
        std::string state;       // new | changed | done
    };
    std::vector<Row> list(long long userId);

    // Records the rows as exported by this operator.
    void logExport(long long userId, const std::vector<Row>& rows);

    // {when, n} of the operator's last export, or null.
    nlohmann::json lastExport(long long userId);
};
