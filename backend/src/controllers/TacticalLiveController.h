#pragma once
#include <string>
#include "../core/Controller.h"

// TacticalLiveController — the live meeting board (mig 606).  Owner
// 2026-10-19: "how quick can we get one up that the players can use during
// tonights meeting. the feature we need is for them to control thier own
// piece via drag" / "name on piece coudl defulat to their last name unless
// they over ride."
//
//   GET  /api/tactical-live/board[?id=N]
//     { success, board: {id, teamId, teamName, title, closedAt} | null,
//       pieces: [{id, personId, label, kind, x, y}],
//       viewer: {personId, isStaff}, teams: [{id, name}] }   // teams: staff only
//   POST /api/tactical-live/boards            { team_id, title? }   — staff
//   POST /api/tactical-live/boards/:id/close                        — staff
//   POST /api/tactical-live/pieces/:id/move   { x, y }   — own piece, the
//        ball, or staff; 0..1 pitch fractions, clamped
//   POST /api/tactical-live/pieces/:id/label  { label }  — own piece or staff
//
// "Staff" here = live coach of any team, or a club/super admin.  Every
// accepted move/rename UPDATE fires fn_tactical_live_notify → pg_notify
// 'fh_lineups' → LineupNotificationHub → GET /api/stream, so every open
// screen applies the move live; the screen also polls as a fallback.
class TacticalLiveController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleGetBoard(const Request& request);
    Response handleCreateBoard(const Request& request);
    Response handleCloseBoard(const Request& request);
    Response handleMove(const Request& request);
    Response handleLabel(const Request& request);
};
