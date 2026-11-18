#pragma once
#include <optional>

#include "Request.h"
#include "Response.h"

// 🎭 View-as = really that person (owner 2026-11-18: "view as should be
// really view as that person right?" / "so i can test right?").
//
// A club/super admin's SPA sends `X-View-As: <person_id>` on every API
// call while view-as is on.  Before routing, apply() checks the real
// caller is a club/super admin, then swaps the request's bearer for one
// minted for the viewed person's own users row — so every controller,
// gate and query downstream answers exactly as it would for them.
// Rules:
//   • Reads only.  Any non-GET is refused (403) — testing as someone can
//     never RSVP, pay, edit or send as them.
//   • The viewed person must have a users row (has signed in once);
//     otherwise 409 with a reason (view as their parent instead).
//   • `X-FH-View-As-Active: 1` marks the swapped request so the
//     last_seen_at heartbeat (Controller::requireBearer) never fakes the
//     viewed person's activity.
//   • A header from a non-admin is ignored (request runs as themselves).
namespace ViewAs {
    // nullopt = carry on (swapped or not); a Response = answer with it.
    std::optional<Response> apply(Request& request);
}
