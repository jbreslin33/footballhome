#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

// OpponentsController — /api/opponents, behind the #opponents page and the
// "Contact <club>" panel in Game Center (mig 483, owner 2026-09-28: "a
// messaging system for opponents … easy to text or email them same way we
// do rsvp reminders … a contact page but also right on the game center").
//
//   GET    /api/opponents/board               competitions (league › division › club) + contacts + message tiers
//   GET    /api/opponents/for-match/:matchId  the opponent club of one game, its contacts, tiers
//   POST   /api/opponents/contact             { id?, club_id, competition_id?, name, role, phone, email, note }
//   DELETE /api/opponents/contact?id=
//   POST   /api/opponents/competition         { id, lead_name?, last_contacted?, notes?, status?, home_field? }
//                                             or { club_id | club_name, league_label, division_label, season?, status? } to add one
//   POST   /api/opponents/alias               { club_id, alias }   link an opponent spelling to a club
//   POST   /api/opponents/message             { contact_id, channel, tier, match_id?, kind? } → compose hrefs, logged
//                                             kind 'casa' renders message_templates kind='casa' and logs the league address as sender
//   GET    /api/opponents/league?label=CASA   the commissioner view (mig 486): that league's competitions + contacts,
//                                             its correspondence email, kind='casa' tiers, our schedule links, recent sends
//   POST   /api/opponents/group-message       { league_label, division_label?, tier } → { subject, body, contacts[], clubs, skipped }
//                                             one BCC draft to every club in the scope; logged per contact with a group_key
//   GET    /api/opponents/league-fixtures?label=CASA   every game of the league season (mig 488): pulls the league's
//                                             SportsEngine feed into league_fixtures first, then reads it — the owner
//                                             wants it "in db and refreshed on every access"; /league does the same
//                                             pull so the hub tile's count is current too
//
// The page is for club admins.  The per-game endpoints also open to the
// coaches of either team in that game (canManageTeam), so a coach can
// reach the opponent from Game Center without the whole directory.
class OpponentsController : public Controller {
public:
    OpponentsController();
    ~OpponentsController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    bool adminGate(const Request& request, Response* error);
    bool matchGate(const Request& request, long long matchId, Response* error);

    Response handleBoard(const Request& request);
    Response handleForMatch(const Request& request);
    Response handleContact(const Request& request);
    Response handleDeleteContact(const Request& request);
    Response handleCompetition(const Request& request);
    Response handleAlias(const Request& request);
    Response handleMessage(const Request& request);
    Response handleLeague(const Request& request);
    Response handleGroupMessage(const Request& request);
    Response handleLeagueFixtures(const Request& request);
};
