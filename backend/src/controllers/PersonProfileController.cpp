#include "PersonProfileController.h"
#include <cctype>
#include <iostream>
#include <regex>
#include <sstream>

PersonProfileController::PersonProfileController() {
    db_ = Database::getInstance();
}

void PersonProfileController::registerRoutes(Router& router, const std::string& prefix) {
    // GET /api/persons/la/:leagueAppsUserId
    //
    // Registered via laGet with the *dynamic* LaProgramsForRequest overload:
    // the profile page renders memberships across every LA program (mens,
    // womens, boys, girls + their pickup variants — set defined in
    // leagueapps_programs, not baked into C++).  The wrapper resolves the
    // program list at request time (via allLeagueAppsProgramIds()), fans
    // out LaProgramSync::run() in parallel, and then invokes the handler
    // with the resulting LaSyncMap.  The handler itself never touches LA —
    // it reads persons + person_la_memberships from the DB, which the
    // sync just refreshed.  Satisfies the STRICT LA→DB→render rule
    // (§ Membership Data Flow) at the framework layer.
    laGet(router, prefix + "/la/:leagueAppsUserId",
        [](const Request&) { return Controller::allLaProgramIds(); },
        [this](const Request& req, const LaSyncMap& sync) {
            return this->handleGetByLaUserId(req, sync);
        });

    // GET /api/persons/:personId — same bundle, keyed by persons.id
    // (used when a card only has personId, e.g. game-day lineup).
    laGet(router, prefix + "/:personId",
        [](const Request&) { return Controller::allLaProgramIds(); },
        [this](const Request& req, const LaSyncMap& sync) {
            return this->handleGetByPersonId(req, sync);
        });
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/la/:leagueAppsUserId
// ────────────────────────────────────────────────────────────────────────────
Response PersonProfileController::handleGetByLaUserId(const Request& request,
                                                     const LaSyncMap& sync) {
    (void)sync;  // LA fetch was executed by laGet(); handler reads DB only.
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    long long laUserId = 0;
    if (!extractLaUserId(request.getPath(), laUserId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "leagueAppsUserId must be a positive integer");
    }

    try {
        // ── Bridge: LA user id → persons.id ─────────────────────────
        pqxx::result aliasRes = db_->query(
            "SELECT person_id FROM external_person_aliases "
            "WHERE provider = 'leagueapps' AND external_user_id = $1 "
            "LIMIT 1",
            { std::to_string(laUserId) });

        if (aliasRes.empty()) {
            return errorResponse(HttpStatus::NOT_FOUND,
                "No person alias found for that LeagueApps user id");
        }
        const int personId = aliasRes[0]["person_id"].as<int>();
        return buildProfile(personId, laUserId);
    } catch (const std::exception& e) {
        std::cerr << "PersonProfileController::handleGetByLaUserId error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared profile bundle (personId + optional LA user id)
// ────────────────────────────────────────────────────────────────────────────
Response PersonProfileController::buildProfile(int personId, long long laUserId) {
    const std::string personIdStr = std::to_string(personId);
    try {
        // ── Person core ──────────────────────────────────────────────
        pqxx::result pRes = db_->query(
            "SELECT id, first_name, last_name, birth_date, "
            "       leagueapps_payment_status, parent_person_id, "
            "       fh_member_at, created_at, updated_at "
            "FROM persons WHERE id = $1",
            { personIdStr });
        if (pRes.empty()) {
            // Alias points at a person that no longer exists — treat as 404.
            return errorResponse(HttpStatus::NOT_FOUND,
                "Person referenced by alias no longer exists");
        }
        const auto& p = pRes[0];

        // ── Contact: emails + phones ─────────────────────────────────
        pqxx::result emailsRes = db_->query(
            "SELECT id, email, email_type_id, is_primary, is_verified, "
            "       verified_at, created_at "
            "FROM person_emails WHERE person_id = $1 "
            "ORDER BY is_primary DESC, is_verified DESC, id ASC",
            { personIdStr });

        pqxx::result phonesRes = db_->query(
            "SELECT id, phone_number, phone_type_id, is_primary, "
            "       is_verified, can_receive_sms, can_receive_calls, "
            "       verified_at, created_at "
            "FROM person_phones WHERE person_id = $1 "
            "ORDER BY is_primary DESC, is_verified DESC, id ASC",
            { personIdStr });

        // ── LA memberships (current + past) ──────────────────────────
        pqxx::result memRes = db_->query(
            "SELECT m.id, m.la_program_id, m.joined_at, m.ended_at, "
            "       m.created_at, m.updated_at, "
            "       lp.program_name, lp.category, lp.variant "
            "FROM person_la_memberships m "
            "LEFT JOIN leagueapps_programs lp "
            "       ON lp.program_id = m.la_program_id "
            "WHERE m.person_id = $1 "
            "ORDER BY (m.ended_at IS NULL) DESC, m.joined_at DESC",
            { personIdStr });

        // ── Upcoming bill (person_billing, keyed by LA user id) ──────
        pqxx::result billRes = db_->query(
            "SELECT leagueapps_user_id, next_bill_date, next_bill_amount, "
            "       updated_at, updated_by_user_id "
            "FROM person_billing WHERE leagueapps_user_id = $1",
            { std::to_string(laUserId) });

        // ── Open + recent charge flags (keyed by LA user id) ─────────
        pqxx::result flagsRes = db_->query(
            "SELECT f.id, f.la_program_id, f.amount_cents, f.reason, "
            "       f.status, f.created_at, f.created_by, "
            "       f.resolved_at, f.resolved_by, f.resolved_note, "
            "       lp.program_name, lp.category, lp.variant "
            "FROM person_charge_flags f "
            "LEFT JOIN leagueapps_programs lp "
            "       ON lp.program_id = f.la_program_id "
            "WHERE f.la_user_id = $1 "
            "ORDER BY (f.status = 'pending') DESC, f.created_at DESC "
            "LIMIT 100",
            { std::to_string(laUserId) });

        // ── Field-level overrides (data-quality tier) ────────────────
        pqxx::result overridesRes = db_->query(
            "SELECT id, field_name, value, source_was, original_value, "
            "       note, set_by_user_id, set_at, updated_at "
            "FROM person_field_overrides WHERE person_id = $1 "
            "ORDER BY updated_at DESC",
            { personIdStr });

        // ── Merge history (data-quality tier).  Include rows where
        // this person is either the kept or dropped side, so an admin
        // reviewing a merged record can see the audit trail. ─────────
        pqxx::result mergesRes = db_->query(
            "SELECT id, kept_person_id, dropped_person_id, merged_at, "
            "       merged_by_user_id, reversed_at, reversed_by_user_id "
            "FROM person_merges "
            "WHERE kept_person_id = $1 OR dropped_person_id = $1 "
            "ORDER BY merged_at DESC",
            { personIdStr });

        // ── FH account (users row linked to this person) ─────────────
        pqxx::result accountRes = db_->query(
            "SELECT id, is_active, last_login_at, last_seen_at, created_at "
            "FROM users WHERE person_id = $1 LIMIT 1",
            { personIdStr });

        // ── Roster / team assignments ────────────────────────────────
        // Legacy soccer roster rows (player_id keyed) PLUS current LA-era
        // roster_assignments (leagueapps_user_id).  Lighthouse mens/youth
        // boards write the latter; scraped opponents often only have the
        // former.  Merge both into the same `teams` array for the UI.
        pqxx::result teamsRes = db_->query(
            "SELECT * FROM ( "
            "SELECT r.id AS roster_id, r.team_id, r.jersey_number, "
            "       r.joined_at::timestamptz AS joined_at, "
            "       r.left_at::timestamptz AS left_at, "
            "       t.name AS team_name, t.slug AS team_slug, "
            "       t.gender_category, t.club_id, "
            "       c.name AS club_name, "
            "       d.name AS division_name, "
            "       'legacy'::text AS source "
            "FROM rosters r "
            "JOIN players pl ON pl.id = r.player_id "
            "JOIN teams t   ON t.id = r.team_id "
            "LEFT JOIN clubs c     ON c.id = t.club_id "
            "LEFT JOIN divisions d ON d.id = t.division_id "
            "WHERE pl.person_id = $1 "
            "UNION ALL "
            "SELECT ra.id AS roster_id, ra.team_id, NULL::int AS jersey_number, "
            "       ra.assigned_at AS joined_at, ra.removed_at AS left_at, "
            "       t.name AS team_name, t.slug AS team_slug, "
            "       t.gender_category, t.club_id, "
            "       c.name AS club_name, "
            "       d.name AS division_name, "
            "       'assignment'::text AS source "
            "FROM roster_assignments ra "
            "JOIN teams t ON t.id = ra.team_id "
            "LEFT JOIN clubs c     ON c.id = t.club_id "
            "LEFT JOIN divisions d ON d.id = t.division_id "
            "WHERE ra.leagueapps_user_id = $2::bigint "
            ") AS team_rows "
            "ORDER BY (left_at IS NULL) DESC, joined_at DESC NULLS LAST "
            "LIMIT 100",
            { personIdStr, std::to_string(laUserId) });

        // ── RSVP eligibility (per-team grants keyed by LA user id) ───
        // These are the teams a player is *allowed* to RSVP to; the
        // upcomingMatches list below is derived from this set.
        pqxx::result eligRes = db_->query(
            "SELECT pre.team_id, pre.granted_at, "
            "       t.name AS team_name, t.slug AS team_slug, "
            "       t.gender_category, "
            "       c.name AS club_name, "
            "       d.name AS division_name "
            "FROM player_rsvp_eligibility pre "
            "JOIN teams t     ON t.id = pre.team_id "
            "LEFT JOIN clubs c     ON c.id = t.club_id "
            "LEFT JOIN divisions d ON d.id = t.division_id "
            "WHERE pre.leagueapps_user_id = $1 "
            "ORDER BY pre.granted_at DESC",
            { std::to_string(laUserId) });

        // ── Upcoming matches this player can RSVP to.  Any future,
        // non-cancelled match where at least one side is a team the
        // player has RSVP eligibility for.  Capped at 20 rows so a
        // players-on-five-teams edge case doesn't balloon the payload.
        pqxx::result upcomingRes = db_->query(
            "SELECT m.id, m.match_date, m.match_time, m.title, "
            "       m.rsvp_opens_at, "
            "       m.home_team_id, m.away_team_id, "
            "       ht.name AS home_team_name, "
            "       at.name AS away_team_name, "
            "       v.name AS venue_name "
            "FROM matches m "
            "LEFT JOIN teams ht ON ht.id = m.home_team_id "
            "LEFT JOIN teams at ON at.id = m.away_team_id "
            "LEFT JOIN venues v ON v.id = m.venue_id "
            "WHERE m.cancelled_at IS NULL "
            "  AND m.match_date >= CURRENT_DATE "
            "  AND (m.home_team_id IN "
            "         (SELECT team_id FROM player_rsvp_eligibility "
            "          WHERE leagueapps_user_id = $1) "
            "    OR m.away_team_id IN "
            "         (SELECT team_id FROM player_rsvp_eligibility "
            "          WHERE leagueapps_user_id = $1)) "
            "ORDER BY m.match_date ASC, m.match_time ASC NULLS LAST "
            "LIMIT 20",
            { std::to_string(laUserId) });

        // ── Person's own recent RSVP responses (audit view: "what has
        // this person actually said yes/no to?").  Sourced from
        // fh_event_rsvps → fh_events → gcal_events; the legacy
        // player_rsvp_history table was dropped 2026-07-17 (migration
        // 123) when RSVPs moved onto the gcal-driven surface.
        pqxx::result rsvpsRes = db_->query(
            "SELECT r.id, r.fh_event_id AS event_id, "
            "       r.responded_at AS changed_at, "
            "       r.response AS status_name, "
            "       (ge.starts_at AT TIME ZONE 'America/New_York')::date AS match_date, "
            "       TO_CHAR(ge.starts_at AT TIME ZONE 'America/New_York', "
            "               'HH24:MI:SS') AS match_time, "
            "       COALESCE(NULLIF(ge.summary,''), 'Event') AS title, "
            "       NULL::text AS home_team_name, "
            "       NULL::text AS away_team_name "
            "FROM fh_event_rsvps r "
            "JOIN fh_events    fe ON fe.id = r.fh_event_id "
            "JOIN gcal_events  ge ON ge.id = fe.gcal_event_id "
            "WHERE r.person_id = $1::int "
            "ORDER BY r.responded_at DESC "
            "LIMIT 20",
            { personIdStr });

        // ── Assemble the JSON payload ────────────────────────────────
        std::ostringstream json;
        json << "{"
             << "\"leagueAppsUserId\":" << (laUserId > 0
                ? (std::string("\"") + std::to_string(laUserId) + "\"")
                : std::string("null"))
             << ",\"personId\":" << personId
             << ",\"person\":{"
             <<     "\"firstName\":\"" << jsonEscape(p["first_name"].c_str()) << "\""
             <<     ",\"lastName\":\""  << jsonEscape(p["last_name"].c_str())  << "\""
             <<     ",\"birthDate\":"   << strOrNull(p["birth_date"])
             <<     ",\"leagueAppsPaymentStatus\":" << strOrNull(p["leagueapps_payment_status"])
             <<     ",\"parentPersonId\":" << intOrNull(p["parent_person_id"])
             <<     ",\"fhMemberAt\":"  << strOrNull(p["fh_member_at"])
             <<     ",\"createdAt\":"   << strOrNull(p["created_at"])
             <<     ",\"updatedAt\":"   << strOrNull(p["updated_at"])
             << "}";

        // Contact section (emails + phones).
        json << ",\"contact\":{\"emails\":[";
        {
            bool first = true;
            for (const auto& row : emailsRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"email\":\"" << jsonEscape(row["email"].c_str()) << "\""
                     <<     ",\"emailTypeId\":" << intOrNull(row["email_type_id"])
                     <<     ",\"isPrimary\":"   << boolField(row["is_primary"])
                     <<     ",\"isVerified\":"  << boolField(row["is_verified"])
                     <<     ",\"verifiedAt\":"  << strOrNull(row["verified_at"])
                     <<     ",\"createdAt\":"   << strOrNull(row["created_at"])
                     << "}";
            }
        }
        json << "],\"phones\":[";
        {
            bool first = true;
            for (const auto& row : phonesRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"phone\":\"" << jsonEscape(row["phone_number"].c_str()) << "\""
                     <<     ",\"phoneTypeId\":" << intOrNull(row["phone_type_id"])
                     <<     ",\"isPrimary\":"     << boolField(row["is_primary"])
                     <<     ",\"isVerified\":"    << boolField(row["is_verified"])
                     <<     ",\"canReceiveSms\":" << boolField(row["can_receive_sms"])
                     <<     ",\"canReceiveCalls\":" << boolField(row["can_receive_calls"])
                     <<     ",\"verifiedAt\":"    << strOrNull(row["verified_at"])
                     <<     ",\"createdAt\":"     << strOrNull(row["created_at"])
                     << "}";
            }
        }
        json << "]}";

        // LA memberships.
        json << ",\"memberships\":[";
        {
            bool first = true;
            for (const auto& row : memRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"programId\":" << row["la_program_id"].as<long long>()
                     <<     ",\"programName\":" << strOrNull(row["program_name"])
                     <<     ",\"category\":"    << strOrNull(row["category"])
                     <<     ",\"variant\":"     << strOrNull(row["variant"])
                     <<     ",\"joinedAt\":"    << strOrNull(row["joined_at"])
                     <<     ",\"endedAt\":"     << strOrNull(row["ended_at"])
                     <<     ",\"createdAt\":"   << strOrNull(row["created_at"])
                     <<     ",\"updatedAt\":"   << strOrNull(row["updated_at"])
                     << "}";
            }
        }
        json << "]";

        // Upcoming bill (or null if no row).
        json << ",\"billing\":";
        if (billRes.empty()) {
            json << "null";
        } else {
            const auto& b = billRes[0];
            json << "{"
                 <<     "\"nextBillDate\":"   << strOrNull(b["next_bill_date"])
                 <<     ",\"nextBillAmount\":" << numOrNull(b["next_bill_amount"])
                 <<     ",\"updatedAt\":"    << strOrNull(b["updated_at"])
                 <<     ",\"updatedByUserId\":" << intOrNull(b["updated_by_user_id"])
                 << "}";
        }

        // Charge flags.
        json << ",\"chargeFlags\":[";
        {
            bool first = true;
            for (const auto& row : flagsRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<long long>()
                     <<     ",\"programId\":"   << row["la_program_id"].as<long long>()
                     <<     ",\"programName\":" << strOrNull(row["program_name"])
                     <<     ",\"category\":"    << strOrNull(row["category"])
                     <<     ",\"variant\":"     << strOrNull(row["variant"])
                     <<     ",\"amountCents\":" << row["amount_cents"].as<int>()
                     <<     ",\"reason\":"      << strOrNull(row["reason"])
                     <<     ",\"status\":\""    << jsonEscape(row["status"].c_str()) << "\""
                     <<     ",\"createdBy\":"   << intOrNull(row["created_by"])
                     <<     ",\"createdAt\":"   << strOrNull(row["created_at"])
                     <<     ",\"resolvedBy\":"  << intOrNull(row["resolved_by"])
                     <<     ",\"resolvedAt\":"  << strOrNull(row["resolved_at"])
                     <<     ",\"resolvedNote\":" << strOrNull(row["resolved_note"])
                     << "}";
            }
        }
        json << "]";

        // Field-level overrides.
        json << ",\"overrides\":[";
        {
            bool first = true;
            for (const auto& row : overridesRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"fieldName\":\"" << jsonEscape(row["field_name"].c_str()) << "\""
                     <<     ",\"value\":"          << strOrNull(row["value"])
                     <<     ",\"sourceWas\":"      << strOrNull(row["source_was"])
                     <<     ",\"originalValue\":"  << strOrNull(row["original_value"])
                     <<     ",\"note\":"           << strOrNull(row["note"])
                     <<     ",\"setByUserId\":"    << intOrNull(row["set_by_user_id"])
                     <<     ",\"setAt\":"          << strOrNull(row["set_at"])
                     <<     ",\"updatedAt\":"      << strOrNull(row["updated_at"])
                     << "}";
            }
        }
        json << "]";

        // Merge history (kept OR dropped side).
        json << ",\"merges\":[";
        {
            bool first = true;
            for (const auto& row : mergesRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"keptPersonId\":"    << row["kept_person_id"].as<int>()
                     <<     ",\"droppedPersonId\":" << row["dropped_person_id"].as<int>()
                     <<     ",\"mergedAt\":"        << strOrNull(row["merged_at"])
                     <<     ",\"mergedByUserId\":"  << intOrNull(row["merged_by_user_id"])
                     <<     ",\"reversedAt\":"      << strOrNull(row["reversed_at"])
                     <<     ",\"reversedByUserId\":" << intOrNull(row["reversed_by_user_id"])
                     << "}";
            }
        }
        json << "]";

        // FH login account (users row), or null when the person has none.
        json << ",\"account\":";
        if (accountRes.empty()) {
            json << "null";
        } else {
            const auto& a = accountRes[0];
            json << "{"
                 <<     "\"userId\":" << a["id"].as<int>()
                 <<     ",\"isActive\":" << boolField(a["is_active"])
                 <<     ",\"lastLoginAt\":" << strOrNull(a["last_login_at"])
                 <<     ",\"lastSeenAt\":" << strOrNull(a["last_seen_at"])
                 <<     ",\"createdAt\":" << strOrNull(a["created_at"])
                 << "}";
        }

        // Team assignments (current + historical roster rows).
        json << ",\"teams\":[";
        {
            bool first = true;
            for (const auto& row : teamsRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"rosterId\":"    << row["roster_id"].as<int>()
                     <<     ",\"teamId\":"     << row["team_id"].as<int>()
                     <<     ",\"teamName\":\"" << jsonEscape(row["team_name"].c_str()) << "\""
                     <<     ",\"teamSlug\":"   << strOrNull(row["team_slug"])
                     <<     ",\"genderCategory\":" << strOrNull(row["gender_category"])
                     <<     ",\"clubId\":"       << intOrNull(row["club_id"])
                     <<     ",\"clubName\":"     << strOrNull(row["club_name"])
                     <<     ",\"divisionName\":" << strOrNull(row["division_name"])
                     <<     ",\"jerseyNumber\":" << intOrNull(row["jersey_number"])
                     <<     ",\"joinedAt\":"     << strOrNull(row["joined_at"])
                     <<     ",\"leftAt\":"       << strOrNull(row["left_at"])
                     <<     ",\"source\":"       << strOrNull(row["source"])
                     << "}";
            }
        }
        json << "]";

        // RSVP eligibility (teams this LA user is granted access to).
        json << ",\"rsvpEligibility\":[";
        {
            bool first = true;
            for (const auto& row : eligRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"teamId\":"       << row["team_id"].as<int>()
                     <<     ",\"teamName\":\""  << jsonEscape(row["team_name"].c_str()) << "\""
                     <<     ",\"teamSlug\":"    << strOrNull(row["team_slug"])
                     <<     ",\"genderCategory\":" << strOrNull(row["gender_category"])
                     <<     ",\"clubName\":"      << strOrNull(row["club_name"])
                     <<     ",\"divisionName\":"  << strOrNull(row["division_name"])
                     <<     ",\"grantedAt\":"     << strOrNull(row["granted_at"])
                     << "}";
            }
        }
        json << "]";

        // Upcoming matches the player can RSVP to.
        json << ",\"upcomingMatches\":[";
        {
            bool first = true;
            for (const auto& row : upcomingRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":" << row["id"].as<int>()
                     <<     ",\"matchDate\":"    << strOrNull(row["match_date"])
                     <<     ",\"matchTime\":"    << strOrNull(row["match_time"])
                     <<     ",\"title\":"        << strOrNull(row["title"])
                     <<     ",\"rsvpOpensAt\":"  << strOrNull(row["rsvp_opens_at"])
                     <<     ",\"homeTeamId\":"   << intOrNull(row["home_team_id"])
                     <<     ",\"awayTeamId\":"   << intOrNull(row["away_team_id"])
                     <<     ",\"homeTeamName\":" << strOrNull(row["home_team_name"])
                     <<     ",\"awayTeamName\":" << strOrNull(row["away_team_name"])
                     <<     ",\"venueName\":"    << strOrNull(row["venue_name"])
                     << "}";
            }
        }
        json << "]";

        // Recent RSVP responses this player has actually made.
        json << ",\"recentRsvps\":[";
        {
            bool first = true;
            for (const auto& row : rsvpsRes) {
                if (!first) json << ",";
                first = false;
                json << "{"
                     <<     "\"id\":\""       << jsonEscape(row["id"].c_str()) << "\""
                     <<     ",\"eventId\":"   << row["event_id"].as<int>()
                     <<     ",\"changedAt\":" << strOrNull(row["changed_at"])
                     <<     ",\"status\":"    << strOrNull(row["status_name"])
                     <<     ",\"matchDate\":" << strOrNull(row["match_date"])
                     <<     ",\"matchTime\":" << strOrNull(row["match_time"])
                     <<     ",\"title\":"     << strOrNull(row["title"])
                     <<     ",\"homeTeamName\":" << strOrNull(row["home_team_name"])
                     <<     ",\"awayTeamName\":" << strOrNull(row["away_team_name"])
                     << "}";
            }
        }
        json << "]";

        json << "}";
        return Response(HttpStatus::OK, json.str());

    } catch (const std::exception& e) {
        std::cerr << "PersonProfileController::buildProfile error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GET /api/persons/:personId
// ────────────────────────────────────────────────────────────────────────────
Response PersonProfileController::handleGetByPersonId(const Request& request,
                                                      const LaSyncMap& sync) {
    (void)sync;
    if (!requireBearer(request)) {
        return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
    }

    int personId = 0;
    if (!extractPersonId(request.getPath(), personId)) {
        return errorResponse(HttpStatus::BAD_REQUEST,
            "personId must be a positive integer");
    }

    try {
        pqxx::result exists = db_->query(
            "SELECT id FROM persons WHERE id = $1 LIMIT 1",
            { std::to_string(personId) });
        if (exists.empty()) {
            return errorResponse(HttpStatus::NOT_FOUND, "Person not found");
        }

        long long laUserId = 0;
        pqxx::result aliasRes = db_->query(
            "SELECT external_user_id FROM external_person_aliases "
            "WHERE provider = 'leagueapps' AND person_id = $1 "
            "LIMIT 1",
            { std::to_string(personId) });
        if (!aliasRes.empty() && !aliasRes[0]["external_user_id"].is_null()) {
            try {
                laUserId = std::stoll(aliasRes[0]["external_user_id"].c_str());
            } catch (const std::exception&) {
                laUserId = 0;
            }
        }
        return buildProfile(personId, laUserId);
    } catch (const std::exception& e) {
        std::cerr << "PersonProfileController::handleGetByPersonId error: "
                  << e.what() << std::endl;
        return errorResponse(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Path parser
// ────────────────────────────────────────────────────────────────────────────
bool PersonProfileController::extractLaUserId(const std::string& path,
                                              long long& laUserId) const {
    static const std::regex re(R"(/api/persons/la/(\d+)/?$)");
    std::smatch m;
    if (!std::regex_search(path, m, re) || m.size() < 2) return false;
    try {
        laUserId = std::stoll(m[1].str());
    } catch (const std::exception&) {
        return false;
    }
    return laUserId > 0;
}

bool PersonProfileController::extractPersonId(const std::string& path,
                                              int& personId) const {
    // Exact /api/persons/:digits — not /la/, /merge, /overrides, etc.
    static const std::regex re(R"(/api/persons/(\d+)/?$)");
    std::smatch m;
    if (!std::regex_search(path, m, re) || m.size() < 2) return false;
    try {
        personId = std::stoi(m[1].str());
    } catch (const std::exception&) {
        return false;
    }
    return personId > 0;
}

// ────────────────────────────────────────────────────────────────────────────
// JSON helpers — manual string building, matching the other controllers.
// ────────────────────────────────────────────────────────────────────────────
std::string PersonProfileController::jsonEscape(const std::string& in) {
    std::string out;
    out.reserve(in.size() + 8);
    for (char c : in) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\b': out += "\\b";  break;
            case '\f': out += "\\f";  break;
            case '\n': out += "\\n";  break;
            case '\r': out += "\\r";  break;
            case '\t': out += "\\t";  break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x",
                                  static_cast<unsigned char>(c));
                    out += buf;
                } else {
                    out += c;
                }
        }
    }
    return out;
}

std::string PersonProfileController::strOrNull(const pqxx::field& f) {
    if (f.is_null()) return "null";
    return std::string("\"") + jsonEscape(f.c_str()) + "\"";
}

std::string PersonProfileController::boolField(const pqxx::field& f) {
    if (f.is_null()) return "false";
    return f.as<bool>() ? "true" : "false";
}

std::string PersonProfileController::intOrNull(const pqxx::field& f) {
    if (f.is_null()) return "null";
    // Emit as-is (pqxx exposes the numeric text).  Guard against
    // trailing garbage by validating with a quick check.
    std::string s = f.c_str();
    if (s.empty()) return "null";
    // Simple sign + digits check — anything else, quote as string.
    bool ok = true;
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (i == 0 && (c == '-' || c == '+')) continue;
        if (!std::isdigit(static_cast<unsigned char>(c))) { ok = false; break; }
    }
    if (!ok) return std::string("\"") + jsonEscape(s) + "\"";
    return s;
}

std::string PersonProfileController::numOrNull(const pqxx::field& f) {
    if (f.is_null()) return "null";
    // numeric(8,2) etc. — pqxx returns the canonical numeric text
    // ("35.00").  Safe to emit as a JSON number literal.
    return std::string(f.c_str());
}
