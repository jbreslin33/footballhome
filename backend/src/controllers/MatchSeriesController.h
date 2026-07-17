#pragma once

#include "../core/Controller.h"

// MatchSeriesController — admin surface for the recurring-event
// scheduling engine (migration 087).
//
// Routes registered under prefix "/api/match-series":
//
//   GET    /api/match-series
//       List every series row plus a rolling stats block: how many
//       materialised matches exist upcoming vs past, whether any are
//       overrides.
//
//   POST   /api/match-series
//       Create a new series.  Body: JSON with name, match_type_id,
//       day_of_week, start_time, starts_on, and optional
//       home/away/venue/end_time/duration/title/description/ends_on.
//
//   GET    /api/match-series/:id
//       Fetch a single series with its upcoming materialised matches.
//
//   PUT    /api/match-series/:id
//       Update the series row.  Body may include an `apply_to_future`
//       boolean; when true, non-override materialised matches with
//       match_date >= CURRENT_DATE are also updated to the new
//       time/title/team/venue.  Changing `day_of_week` while
//       `apply_to_future=true` is rejected (would require deleting +
//       re-materialising; do that via DELETE then POST).
//
//   DELETE /api/match-series/:id
//       Soft-delete the series (sets active=false).  Optional
//       `?cancel_future=true` query flag also sets cancelled_at on
//       every non-override materialised match with match_date >=
//       CURRENT_DATE.  RSVPs are preserved.
//
// All mutating endpoints require an Authorization: Bearer token.
class MatchSeriesController : public Controller {
public:
    MatchSeriesController();
    ~MatchSeriesController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleList    (const Request& request);
    Response handleCreate  (const Request& request);
    Response handleGet     (const Request& request);
    Response handleUpdate  (const Request& request);
    Response handleDelete  (const Request& request);
};
