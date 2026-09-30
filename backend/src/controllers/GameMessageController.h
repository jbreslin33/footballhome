#pragma once
#include <string>
#include "../core/Controller.h"

// GameMessageController — who a message about one game goes to, for the
// bulk ✉ / 💬 buttons on #game-center (mig 506).  Owner 2026-09-30: "email
// in bulk everyone from a game. diff buttons for those going, going and
// undecided, then an all button. for every game women too … example use
// case is game changed to diff day so i need to email all parents of just
// u8".
//
//   GET /api/game-message/:matchId/recipients
//     { success, people: [{ personId, name, rsvp: 'yes'|'no'|'maybe'|'none',
//                           email, phone, viaParent }] }
//
// Everyone on the rosters of the game's teams, with the RSVP they gave the
// game and the contact a message reaches them by: the parent's for a
// youth player (persons.parent_person_id), their own otherwise — the same
// rule as the RSVP board.  The page groups them (going / going +
// undecided / everyone) and hands the list to the shared composer, so
// nothing is sent from here.  For the game's coaches and club admins;
// a signed-in caller who is neither gets 403, never 401.
class GameMessageController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleRecipients(const Request& request);
};
