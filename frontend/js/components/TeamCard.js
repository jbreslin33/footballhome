// TeamCard / CoachTeamCard / AdminTeamCard — role-layered capability for
// the roster board's per-player card.
//
// Scope note: the bulk of a player card (name, DOB, dues, contact links) is
// identical across every role and lives in RosterScreenBase.renderCompactCard
// / each screen's renderPlayer() — that markup doesn't vary by who's
// looking. The part that DOES vary by role is the team-assignment control
// (the "move to team" dropdown + whether the card is draggable at all), so
// that's what this hierarchy owns. RosterScreenBase.renderCompactCard asks
// this hierarchy for that control instead of branching on role itself.
//
//   TeamCard        — view only. No move control, not draggable.
//   CoachTeamCard    — move control lists only teams in context.coachedTeamIds;
//                      draggable only when the card's own column is coached.
//   AdminTeamCard    — same as CoachTeamCard, but the host screen passes
//                      every configured column's teamId as coachedTeamIds,
//                      so no override is needed — full-club access falls
//                      out of the constructor args, not new code.
//
// context: { coachedTeamIds: number[], renderMoveDropdown(player, columns, currentTeamId) }
//   renderMoveDropdown is threaded in from RosterScreenBase so the actual
//   dropdown markup (styling, click targets) stays defined once, not
//   duplicated into this file. currentTeamId is the ONE team_persons row
//   this specific card represents (0 for Unassigned) — see
//   RosterScreenBase.renderMoveDropdown's 2026-08-16 multi-assign doc.
class TeamCard extends Card {
  // data: { player, columns, col }
  renderMoveControl() {
    return '';
  }

  canDrag() {
    return false;
  }
}

class CoachTeamCard extends TeamCard {
  // Only offer a move control on cards that are actionable without a
  // dead-end click: either the card is already on one of the coach's own
  // teams (move to another of their teams, or Unassign), or it's already
  // Unassigned (add to one of their teams). A card sitting on a team the
  // coach doesn't coach gets no control at all — the backend's
  // Controller::canManageTeam would 403 an "Unassign" click there anyway
  // (the ownership check is per-team, and removing requires coaching the
  // player's CURRENT team), so hiding it avoids a dead button rather than
  // relying on the error alert to explain why it failed.
  renderMoveControl() {
    const { player, columns, col } = this.data;
    const coachedTeamIds = this.context.coachedTeamIds || [];
    if (coachedTeamIds.length === 0) return '';
    const currentTeamId = col && col.teamId ? col.teamId : 0;
    const currentIsCoachedOrUnassigned = currentTeamId === 0 || coachedTeamIds.includes(currentTeamId);
    if (!currentIsCoachedOrUnassigned) return '';
    const allowedColumns = (columns || []).filter((c) => coachedTeamIds.includes(c.teamId));
    return this.context.renderMoveDropdown(player, allowedColumns, currentTeamId);
  }

  canDrag() {
    const { col } = this.data;
    const coachedTeamIds = this.context.coachedTeamIds || [];
    return !!(col && col.teamId && coachedTeamIds.includes(col.teamId));
  }
}

class AdminTeamCard extends CoachTeamCard {}
