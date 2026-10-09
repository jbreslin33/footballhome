#pragma once
#include <string>
#include "../core/Controller.h"

// DashboardController — the #dashboard page (migration 548): the admin's
// front page.  Owner 2026-10-09: "a live dashboard … cells with important
// information. like quick dash for rsvps to games and practices to identify
// trouble spots. payments how many are up to date and late and total
// collected that month. rosters. how many roster spots out of max are
// filled. how many uniforms assigned out of players on rosters. leads if
// any leads not contacted" — "then i could click any cell and go to that
// page that is already working" — "that would be my front page".
//
// Nothing is stored.  Every cell is the same number its own page shows,
// read through the same models (RsvpBoard::weekEvents, PaymentsOverview)
// or the same tables, so the dashboard never disagrees with the page a
// cell opens.
//
//   GET /api/dashboard
//     { rsvps:    { sections: [{ code, key, label, events, games, practices,
//                                expected, answered, unanswered, trouble: [...] }],
//                  expected, answered, unanswered },
//       payments: { paying, paid_up, behind, blocked, owed, sections: [...],
//                   collected: { month_label, total, by_section: [...] } },
//       rosters:  { teams: [{ id, label, section, players, max, full }],
//                   capped_players, capped_max, full_teams },
//       kit:      { players, numbered, sections: [{ code, players, numbered }] },
//       leads:    { new_total, new_on_active, oldest_new_hours, needs_followup },
//       home_games: { days, games: [{ fh_event_id, match_id, starts_at, day, day_text,
//                                     time_text, teams, opponent, format, facility }] },
//       game_center: { days, games: [{ match_id, teams, opponent, when_text, field_size,
//                                      everyone_plays, roster, going, can_start, on_track,
//                                      starters_set, bench_set, lineup_not_going }] },
//       generated_at }
class DashboardController : public Controller {
public:
    DashboardController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    int mensProgramId_, womensProgramId_, boysProgramId_, girlsProgramId_;
    bool gate(const Request& request, Response* error);
    Response handleGet(const Request& request);
};
