#include <iostream>
#include <thread>
#include <chrono>
#include <algorithm>
#include <curl/curl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#include "core/Router.h"
#include "core/Request.h"
#include "core/Response.h"
#include "database/Database.h"

#include "database/SqlFileLogger.h"
#include "controllers/AuthController.h"
#include "controllers/OAuthController.h"
#include "controllers/TeamController.h"
#include "controllers/TeamCoachController.h"
#include "controllers/TeamRosterController.h"
#include "controllers/TeamReconciliationController.h"
#include "controllers/MagicLinkAuthController.h"
#include "controllers/EventRsvpController.h"
#include "controllers/PersonOverrideController.h"
#include "controllers/PersonMergeController.h"
#include "controllers/PersonProfileController.h"
#include "controllers/EventController.h"
#include "controllers/DivisionController.h"
#include "controllers/AvailabilityController.h"
#include "controllers/SystemAdminController.h"
#include "controllers/TacticalBoardController.h"
#include "controllers/StatsController.h"
#include "controllers/ClubController.h"
#include "controllers/ClubLaPoolController.h"
#include "controllers/YouthRosterController.h"
#include "controllers/MensRosterController.h"
#include "controllers/BoysRosterController.h"
#include "controllers/PersonBillingController.h"
#include "controllers/PayReminderLogController.h"
#include "controllers/PaymentsController.h"
#include "controllers/ChargeFlagsController.h"
#include "controllers/AdminLaBackfillController.h"
#include "controllers/LeadsController.h"
#include "controllers/LeadsWebhookController.h"
#include "controllers/AdsController.h"
#include "controllers/StreamController.h"
#include "controllers/EligibilityController.h"
#include "controllers/SocialController.h"
#include "controllers/InternalRosterController.h"
#include "controllers/PublicController.h"
#include "controllers/MatchSeriesController.h"
#include "controllers/MyController.h"
#include "controllers/EventReminderController.h"
#include "controllers/CalendarController.h"
#include "controllers/SimLobbyController.h"
#include "controllers/SimDebugController.h"
#include "controllers/TrailTestController.h"
#include "orchestration/SimOrchestrator.h"
#include "orchestration/SimPool.h"
#include "orchestration/SimReaper.h"
#include "core/HttpClient.h"
#include "services/MetaLeadsService.h"
#include "services/LineupNotificationHub.h"

class HttpServer {
private:
    int server_fd_;
    int port_;
    Router router_;
    Database* db_;
    
    // Controllers
    std::shared_ptr<AuthController> auth_controller_;
    std::shared_ptr<MagicLinkAuthController> magic_link_auth_controller_;
    std::shared_ptr<EventRsvpController> event_rsvp_controller_;
    std::shared_ptr<OAuthController> oauth_controller_;
    std::shared_ptr<TeamController> team_controller_;
    std::shared_ptr<TeamCoachController> team_coach_controller_;
    std::shared_ptr<TeamRosterController> team_roster_controller_;
    std::shared_ptr<TeamReconciliationController> team_reconciliation_controller_;
    std::shared_ptr<PersonOverrideController> person_override_controller_;
    std::shared_ptr<PersonMergeController> person_merge_controller_;
    std::shared_ptr<PersonProfileController> person_profile_controller_;
    std::shared_ptr<EventController> event_controller_;
    std::shared_ptr<DivisionController> division_controller_;
    std::shared_ptr<AvailabilityController> availability_controller_;
    std::shared_ptr<SystemAdminController> system_admin_controller_;
    std::shared_ptr<TacticalBoardController> tactical_board_controller_;
    std::shared_ptr<StatsController> stats_controller_;
    std::shared_ptr<ClubController> club_controller_;
    std::shared_ptr<ClubLaPoolController> club_la_pool_controller_;
    std::shared_ptr<YouthRosterController> youth_roster_controller_;
    std::shared_ptr<MensRosterController> mens_roster_controller_;
    std::shared_ptr<BoysRosterController> boys_roster_controller_;
    std::shared_ptr<PersonBillingController> person_billing_controller_;
    std::shared_ptr<PayReminderLogController> pay_reminder_log_controller_;
    std::shared_ptr<PaymentsController> payments_controller_;
    std::shared_ptr<ChargeFlagsController> charge_flags_controller_;
    std::shared_ptr<AdminLaBackfillController> admin_la_backfill_controller_;
    std::shared_ptr<LeadsController> leads_controller_;
    std::shared_ptr<LeadsWebhookController> leads_webhook_controller_;
    std::shared_ptr<AdsController> ads_controller_;
    std::shared_ptr<StreamController> stream_controller_;
    std::shared_ptr<EligibilityController> eligibility_controller_;
    std::shared_ptr<SocialController> social_controller_;
    std::shared_ptr<InternalRosterController> internal_roster_controller_;
    std::shared_ptr<PublicController> public_controller_;
    std::shared_ptr<MatchSeriesController> match_series_controller_;
    std::shared_ptr<MyController> my_controller_;
    std::shared_ptr<EventReminderController> event_reminder_controller_;
    std::shared_ptr<CalendarController> calendar_controller_;
    std::shared_ptr<SimLobbyController> sim_lobby_controller_;
    std::shared_ptr<SimDebugController> sim_debug_controller_;
    std::shared_ptr<TrailTestController> trail_test_controller_;

    // §21.7 item 1 step 5E — warm-daemon pool bundle. Owns the
    // long-lived HttpClient + SimOrchestrator + SimPool trio needed
    // by the pool's background refill thread. Populated in
    // initialize() only when FH_SIM_ORCHESTRATOR_ENABLED=1 AND
    // FH_SIM_POOL_SIZE > 0; stays nullptr otherwise (default state,
    // matches pre-5E behavior). Ordered AFTER controllers so the
    // destructor tears the bundle down BEFORE the controllers so
    // sim_lobby_controller_->setSimPool(nullptr) fires while the
    // controller shared_ptr is still alive. The bundle's own dtor
    // runs pool.~SimPool() → SimPool::stop() → joins refill thread
    // before orch/http go out of scope, so refill's spawnWarm can't
    // dangle-deref the orchestrator's HttpClient reference.
    struct SimPoolBundle {
        HttpClient http;
        fh::orchestration::SimOrchestrator orch;
        fh::orchestration::SimPool pool;

        SimPoolBundle(fh::orchestration::SimOrchestratorConfig ocfg,
                      fh::orchestration::SimPoolConfig pcfg)
            : http()
            , orch(std::move(ocfg), http)
            , pool(std::move(pcfg), orch) {}
    };
    std::unique_ptr<SimPoolBundle> sim_pool_bundle_;

public:
    HttpServer(int port = 3001) : port_(port) {
        db_ = Database::getInstance();
        auth_controller_ = std::make_shared<AuthController>();
        magic_link_auth_controller_ = std::make_shared<MagicLinkAuthController>();
        event_rsvp_controller_ = std::make_shared<EventRsvpController>();
        oauth_controller_ = std::make_shared<OAuthController>();
        team_controller_ = std::make_shared<TeamController>();
        team_coach_controller_ = std::make_shared<TeamCoachController>();
        team_roster_controller_ = std::make_shared<TeamRosterController>();
        team_reconciliation_controller_ = std::make_shared<TeamReconciliationController>();
        person_override_controller_ = std::make_shared<PersonOverrideController>();
        person_merge_controller_ = std::make_shared<PersonMergeController>();
        person_profile_controller_ = std::make_shared<PersonProfileController>();
        event_controller_ = std::make_shared<EventController>();
        division_controller_ = std::make_shared<DivisionController>();
        availability_controller_ = std::make_shared<AvailabilityController>();
        system_admin_controller_ = std::make_shared<SystemAdminController>();
        tactical_board_controller_ = std::make_shared<TacticalBoardController>();
        stats_controller_ = std::make_shared<StatsController>();
        club_controller_ = std::make_shared<ClubController>();
        club_la_pool_controller_ = std::make_shared<ClubLaPoolController>();
        youth_roster_controller_ = std::make_shared<YouthRosterController>();
        mens_roster_controller_  = std::make_shared<MensRosterController>();
        boys_roster_controller_  = std::make_shared<BoysRosterController>();
        person_billing_controller_ = std::make_shared<PersonBillingController>();
        pay_reminder_log_controller_ = std::make_shared<PayReminderLogController>();
        payments_controller_ = std::make_shared<PaymentsController>();
        charge_flags_controller_ = std::make_shared<ChargeFlagsController>();
        admin_la_backfill_controller_ = std::make_shared<AdminLaBackfillController>();
        leads_controller_ = std::make_shared<LeadsController>();
        leads_webhook_controller_ = std::make_shared<LeadsWebhookController>();
        ads_controller_ = std::make_shared<AdsController>();
        stream_controller_ = std::make_shared<StreamController>();
        eligibility_controller_ = std::make_shared<EligibilityController>();
        social_controller_ = std::make_shared<SocialController>();
        internal_roster_controller_ = std::make_shared<InternalRosterController>();
        public_controller_ = std::make_shared<PublicController>();
        match_series_controller_ = std::make_shared<MatchSeriesController>();
        my_controller_ = std::make_shared<MyController>();
        event_reminder_controller_ = std::make_shared<EventReminderController>();
        calendar_controller_ = std::make_shared<CalendarController>();
        sim_lobby_controller_ = std::make_shared<SimLobbyController>();
        sim_debug_controller_ = std::make_shared<SimDebugController>();
        trail_test_controller_ = std::make_shared<TrailTestController>();
    }
    
    bool initialize() {
        std::cout << "🚀 Football Home Server Starting..." << std::endl;
        
        // Initialize SQL file logger
        SqlFileLogger::initialize();

        // Initialize database
        if (!db_->connect()) {
            std::cerr << "❌ Failed to connect to database" << std::endl;
            return false;
        }
        
        // Setup routes
        setupRoutes();
        
        // Start background schedulers
        social_controller_->startScheduler();

        // Phase 13 — start the LISTEN fh_lineups pump.  Spawns one thread
        // that owns a dedicated pqxx::connection and fans NOTIFY payloads
        // out to every /api/stream subscriber.  Reconnects with backoff on
        // any pqxx error.
        LineupNotificationHub::getInstance().start(
            LineupNotificationHub::defaultConnString());

        // Validate Meta Lead-Ads token in the background.  Failure leaves
        // /api/leads/sync in degraded mode (the controller still returns
        // 502 with per-form errors) but the rest of the server runs.
        std::thread([]() {
            try { MetaLeadsService::getInstance().validateToken(); }
            catch (const std::exception& e) {
                std::cerr << "MetaLeadsService::validateToken threw: "
                          << e.what() << std::endl;
            }
        }).detach();

        // Slice 14.1 — SimOrchestrator podman-surface boot smoke check.
        //
        // Non-fatal: if FH_SIM_ORCHESTRATOR_ENABLED is unset/0 we log a
        // one-liner and move on. If it's on but the podman socket isn't
        // reachable, we log a warning and continue booting — the
        // orchestrator's callers (SimLobbyController.handleCreateMatch,
        // coming in slice 14.3) are what actually gate on this. Boot
        // must never fail on orchestrator init because in a production
        // deploy the socket may be intentionally unmounted.
        //
        // Local scope: HttpClient is stateless-per-call and no
        // controller depends on SimOrchestrator yet (that comes with
        // 14.3), so we don't promote either to a HttpServer member here.
        {
            HttpClient probe;
            fh::orchestration::SimOrchestrator orchestrator(
                fh::orchestration::loadConfigFromEnv(), probe);
            auto ping = orchestrator.pingPodman();
            if (ping.ok) {
                std::cout << "[sim-orchestrator] podman ready — version "
                          << ping.podman_version
                          << " (api " << ping.api_version << ") via "
                          << orchestrator.config().podman_socket_path
                          << std::endl;
            } else if (!orchestrator.config().enabled) {
                std::cout << "[sim-orchestrator] disabled "
                             "(FH_SIM_ORCHESTRATOR_ENABLED=0)" << std::endl;
            } else {
                std::cerr << "[sim-orchestrator] WARNING podman probe failed: "
                          << ping.error
                          << " — multi-match orchestration will error at "
                             "match-create time. Socket path: "
                          << orchestrator.config().podman_socket_path
                          << std::endl;
            }
        }

        // Slice 14.6 — start the reaper. Runs a synchronous startup
        // sweep (cleaning up detritus from any previous backend crash)
        // BEFORE the socket accepts connections, then spawns the
        // 5-minute-interval background thread. No-op when the
        // orchestrator feature flag is off. See SimReaper.h for the
        // reconciliation contract.
        fh::orchestration::SimReaper::getInstance().start();

        // §21.7 item 1 step 5E — wire the warm-daemon pool.
        //
        // Sourced from FH_SIM_ORCHESTRATOR_ENABLED (must be true) +
        // FH_SIM_POOL_SIZE (int > 0). When either gate is off, no
        // bundle is constructed and SimLobbyController's pool_ stays
        // nullptr, so handleCreateMatch's pool-first branch is inert
        // and behavior is byte-equivalent to pre-5E.
        //
        // When on: constructs SimPoolBundle{HttpClient, SimOrchestrator,
        // SimPool}, starts the pool's refill thread, then attaches the
        // pool to sim_lobby_controller_ so incoming
        // POST /api/sim/matches requests try pool.take() first before
        // falling back to launchMatch (5D).
        //
        // NO orphan warm-container cleanup at boot in this slice —
        // if the previous backend left `footballhome_sim_warm_*`
        // containers around, spawnWarm collisions log-and-back-off
        // in the refill thread (SimPool.cpp) and the pool self-heals
        // within refill_wake_interval once ops manually reaps the
        // orphans OR the auto-bumped warm_id counter skips past
        // them. Explicit boot-time reap deferred to a follow-up
        // slice — the first-flip production deploy should verify
        // `sudo podman ps --filter name=footballhome_sim_warm_` is
        // empty before enabling FH_SIM_POOL_SIZE.
        {
            auto orch_cfg = fh::orchestration::loadConfigFromEnv();
            auto pool_cfg = fh::orchestration::loadSimPoolConfigFromEnv();
            if (orch_cfg.enabled && pool_cfg.target_size > 0) {
                sim_pool_bundle_ = std::make_unique<SimPoolBundle>(
                    std::move(orch_cfg), std::move(pool_cfg));
                sim_pool_bundle_->pool.start();
                sim_lobby_controller_->setSimPool(&sim_pool_bundle_->pool);
                std::cout << "[sim-pool] wired target_size="
                          << sim_pool_bundle_->pool.config().target_size
                          << " refill_wake_interval_ms="
                          << sim_pool_bundle_->pool.config()
                                 .refill_wake_interval.count()
                          << " refill_backoff_on_error_ms="
                          << sim_pool_bundle_->pool.config()
                                 .refill_backoff_on_error.count()
                          << " — refill thread started" << std::endl;
            } else if (!orch_cfg.enabled) {
                std::cout << "[sim-pool] disabled "
                             "(FH_SIM_ORCHESTRATOR_ENABLED unset)"
                          << std::endl;
            } else {
                std::cout << "[sim-pool] disabled "
                             "(FH_SIM_POOL_SIZE=0)"
                          << std::endl;
            }
        }

        // Create socket
        if (!createSocket()) {
            return false;
        }
        
        std::cout << "✅ Server initialized successfully on port " << port_ << std::endl;
        return true;
    }
    
    void run() {
        std::cout << "🎯 Server listening on http://localhost:" << port_ << std::endl;
        std::cout << "📋 Available endpoints:" << std::endl;
        router_.printRoutes();
        
        while (true) {
            handleClient();
        }
    }
    
    ~HttpServer() {
        // §21.7 item 1 step 5E — pool teardown.
        //
        // In production the socket loop in run() is infinite and
        // SIGTERM kills the process before this dtor fires — this
        // path is exercised by tests and clean-exit codepaths only.
        // For those cases we:
        //   1. Detach the pool from the controller FIRST so any
        //      in-flight handleCreateMatch reading pool_ observes
        //      nullptr (it treats that as "pool disabled" and takes
        //      the launchMatch fallback branch).
        //   2. Drain any warm slots the pool still holds via
        //      orch.stopMatch(). Skipping this leaves the containers
        //      running as orphans until the next backend boot's
        //      operator-driven cleanup — correct but sloppy.
        //   3. Let sim_pool_bundle_'s dtor run pool.~SimPool() which
        //      joins the refill thread; then orch + http go out of
        //      scope in the right order.
        if (sim_lobby_controller_) {
            sim_lobby_controller_->setSimPool(nullptr);
        }
        if (sim_pool_bundle_) {
            while (auto slot = sim_pool_bundle_->pool.take()) {
                fh::orchestration::StopOptions so;
                so.container_id = slot->container_id;
                so.grace_seconds = 5;
                (void)sim_pool_bundle_->orch.stopMatch(so);
            }
            sim_pool_bundle_->pool.stop();
        }

        if (server_fd_ >= 0) {
            close(server_fd_);
        }
        if (db_) {
            db_->disconnect();
        }
    }

private:
    void setupRoutes() {
        // Register controllers
        router_.useController("/api/auth/google", oauth_controller_);
        // Magic-link / cookie session controller registered BEFORE the
        // legacy AuthController so that /api/auth/me and /api/auth/logout
        // resolve to the FH-native cookie semantics (Phase 4) instead of
        // the older bearer/email-password handlers.  The legacy ones
        // (login, register, me/roles, user/teams, ...) stay reachable
        // because their paths don't collide.
        router_.useController("/api/auth", magic_link_auth_controller_);
        router_.useController("/api/auth", auth_controller_);
        router_.useController("/api/auth/google", oauth_controller_);
        router_.useController("/api/teams", team_controller_);
        router_.useController("/api/teams", team_coach_controller_);
        router_.useController("/api/teams", team_roster_controller_);
        router_.useController("/api/teams", team_reconciliation_controller_);
        router_.useController("/api/persons", person_override_controller_);
        router_.useController("/api/persons", person_merge_controller_);
        // GET /api/persons/la/:leagueAppsUserId — universal person profile
        // that powers the drill-down PersonScreen (2026-07-13).
        router_.useController("/api/persons", person_profile_controller_);
        // FH-native cookie-authed event + RSVP surface registered
        // BEFORE the legacy EventController so /api/events/:chatEventId
        // resolves here (chat_events table) instead of the older
        // /api/events/:eventId handler (deprecated internal `events`
        // table).  Also owns /api/rsvp.  Phase 5.
        router_.useController("/api", event_rsvp_controller_);
        router_.useController("/api/events", event_controller_);
        router_.useController("/api", division_controller_);
        router_.useController("/api", availability_controller_);
        router_.useController("/api/system-admin", system_admin_controller_);
        router_.useController("/api/tactical-boards", tactical_board_controller_);
        router_.useController("/api/stats", stats_controller_);
        // FH-native LA-pool list registered BEFORE the generic ClubController
        // so /api/clubs/:clubId/la-pool resolves here (Phase 6) instead of
        // the more generic club-detail handler.
        router_.useController("/api/clubs", club_la_pool_controller_);
        router_.useController("/api/clubs", club_controller_);
        // Phase 7 — youth-roster ported to C++.  Registered with the exact
        // path as prefix so there's no trailing-slash mismatch.
        router_.useController("/api/youth-roster", youth_roster_controller_);
        // Phase 8 — mens-roster (GET + /assign + /roster-status) ported to C++.
        router_.useController("/api/mens-roster", mens_roster_controller_);
        // Phase 2 boys-roster (2026-07-05) — same shape as mens, backed by
        // roster_columns / roster_assignments filtered to domain='boys'.
        // Pulls registrants from both Boys Club and Girls Club LA programs.
        router_.useController("/api/boys-roster", boys_roster_controller_);
        // Phase 9 — person-billing (POST upsert + /mark-billed) ported to C++.
        router_.useController("/api/person-billing", person_billing_controller_);

        // 2026-07-06 — PAY-reminder click logger (records SMS/Email button
        // clicks fired from the Mens/Boys roster PAY buttons so the coach
        // can see "last contact + method" on the card).
        router_.useController("/api/pay-reminder-log", pay_reminder_log_controller_);
        // Payments audit surface (Mens / Boys / Girls tabs on the
        // dedicated payments screen).
        router_.useController("/api/payments", payments_controller_);
        // Operator "run this card in LA" work queue (companion to the
        // payments Members view).  LA's payments API is read-only, so
        // this is a flag-and-track table + a queue UI.
        router_.useController("/api/charge-flags", charge_flags_controller_);
        // Phase 10 — admin glue.  POST /api/admin/leagueapps-link/backfill
        // (operator-driven persons sweep).
        router_.useController("/api/admin", admin_la_backfill_controller_);
        // Phase 11 — /api/leads* (Meta Lead-Ads triage surface).
        router_.useController("/api/leads", leads_controller_);
        // Phase 12 — /api/ads* (Meta Ads Marketing API surface).
        router_.useController("/api/ads", ads_controller_);
        // Phase 14 — /webhook/meta-leads (Meta lead-ads webhook receiver).
        // Replaces the deleted meta-leads-webhook Node service.
        router_.useController("/webhook", leads_webhook_controller_);
        // Phase 13 — /api/stream (long-lived SSE channel for /dashboard#lineups).
        // The LineupNotificationHub background thread (started in initialize())
        // owns the LISTEN fh_lineups socket and fans NOTIFY payloads out.
        router_.useController("/api", stream_controller_);
        router_.useController("/api/eligibility", eligibility_controller_);
        router_.useController("/api/social", social_controller_);
        router_.useController("/api/internal", internal_roster_controller_);
        router_.useController("/api/public", public_controller_);
        // Recurring event series admin surface (GET/POST/PUT/DELETE
        // CRUD).  The Sunday-8pm materialisation cron was retired
        // 2026-07-17 when RSVPs moved onto the gcal-driven
        // fh_events surface.
        router_.useController("/api/match-series", match_series_controller_);
        // Signed-in-player self-service surface: men's chat only.
        // RSVPs live on /api/calendar/* (fh_event_rsvps); standing
        // preferences live in fh_recurring_rsvps and are toggled via
        // the same calendar surface.
        router_.useController("/api/my", my_controller_);
        // Coach-triggered reminder nudges + magic-link verify.
        //   POST /api/events/:fhEventId/remind
        //   GET  /api/reminders/verify
        router_.useController("/api", event_reminder_controller_);

        // Google Calendar mirror read surface (Slice 4, see
        // docs/calendar-design.md). Reads from fh_events joined to
        // gcal_events populated by scripts/gcal-sync.js +
        // scripts/gcal-classify.js on the 5-min systemd timer.
        //   GET /api/calendar/upcoming?days=<int>
        router_.useController("/api", calendar_controller_);

        // Slice 12 — fh-sim lobby + JWT bridge.
        //   GET  /api/sim/matches
        //   POST /api/sim/matches
        //   POST /api/sim/matches/:matchId/join   (mints sim-side HS256 JWT)
        router_.useController("/api/sim", sim_lobby_controller_);

        // Slice 13 sub-slice 8 — fh-sim debug endpoints (admin-only,
        // gated on FH_ENABLE_SIM_DEBUG=1). Uses migration 201 decode
        // helpers for input/event visibility; /state defers to
        // sub-slice 8.1 (cross-container fh-sim-replay spawn).
        //   GET  /api/sim/debug/matches/:id/inputs
        //   GET  /api/sim/debug/matches/:id/events
        //   GET  /api/sim/debug/matches/:id/state    (501 today)
        router_.useController("/api/sim/debug", sim_debug_controller_);

        // Tactical Games — Learning Game 1 (Trail Test).  Pure client-
        // side canvas game; this controller is just the storage seam.
        //   POST /api/tactical/trail-test/results   (complete A+B session)
        //   POST /api/tactical/trail-test/attempts  (telemetry, incl. drop-outs)
        //   GET  /api/tactical/trail-test/results   (caller's history)
        router_.useController("/api/tactical", trail_test_controller_);

        // Add basic health check endpoint
        router_.get("/health", [](const Request& request) {
            return Response::json("{\"status\":\"healthy\",\"service\":\"footballhome-backend\"}");
        });
        
        // Add root endpoint
        router_.get("/", [](const Request& request) {
            return Response::json("{\"message\":\"Football Home API Server\",\"version\":\"1.0\"}");
        });
        
        std::cout << "✅ Routes configured successfully" << std::endl;
    }
    
    bool createSocket() {
        // Create socket
        server_fd_ = socket(AF_INET, SOCK_STREAM, 0);
        if (server_fd_ < 0) {
            std::cerr << "❌ Socket creation failed" << std::endl;
            return false;
        }
        
        // Set socket options
        int opt = 1;
        if (setsockopt(server_fd_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
            std::cerr << "❌ setsockopt failed" << std::endl;
            return false;
        }
        
        // Bind socket
        struct sockaddr_in address;
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port_);
        
        if (bind(server_fd_, (struct sockaddr*)&address, sizeof(address)) < 0) {
            std::cerr << "❌ Bind failed on port " << port_ << std::endl;
            return false;
        }
        
        // Listen. Backlog capped at SOMAXCONN (128 on modern Linux) so
        // a spawn-burst of 20+ concurrent clients doesn't see connections
        // dropped at the kernel level while accept() catches up. The old
        // value of 10 was fine for interactive traffic but the Slice 14.7
        // orchestrator load test showed the kernel silently ECONNREFUSING
        // requests past 10 in-flight — visible in the test as "curl (7)
        // Failed to connect" for the tail of a burst.
        if (listen(server_fd_, SOMAXCONN) < 0) {
            std::cerr << "❌ Listen failed" << std::endl;
            return false;
        }
        
        return true;
    }
    
    void handleClient() {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        
        int client_fd = accept(server_fd_, (struct sockaddr*)&client_addr, &client_len);
        if (client_fd < 0) {
            std::cerr << "❌ Accept failed" << std::endl;
            return;
        }
        
        // Handle request in separate thread for better concurrency.
        // The lambda MUST NOT let any exception escape — an unhandled
        // exception in a detached std::thread calls std::terminate and
        // takes the whole backend process down. processRequest() itself
        // has a top-level catch(std::exception&), but a non-std throw
        // (e.g. an ABI-level bad_cast) would slip past it. Belt-and-
        // braces catch(...) here guarantees no request-processing path
        // can crash the server. Discovered via the Slice 14.7 20-way
        // concurrent load test, which caused a compose auto-restart.
        std::thread([this, client_fd]() {
            try {
                this->processRequest(client_fd);
            } catch (const std::exception& e) {
                std::cerr << "❌ Uncaught std::exception in request thread: "
                          << e.what() << std::endl;
                ::close(client_fd);
            } catch (...) {
                std::cerr << "❌ Uncaught non-std exception in request thread"
                          << std::endl;
                ::close(client_fd);
            }
        }).detach();
    }
    
    void processRequest(int client_fd) {
        try {
            // Read request with support for large bodies (up to 10MB)
            static const size_t MAX_BODY_SIZE = 200 * 1024 * 1024;
            static const size_t CHUNK_SIZE = 65536;

            // Read initial chunk (headers + start of body)
            char initial_buf[CHUNK_SIZE];
            ssize_t bytes_read = read(client_fd, initial_buf, sizeof(initial_buf));

            if (bytes_read <= 0) {
                close(client_fd);
                return;
            }

            std::string raw_request(initial_buf, bytes_read);

            // Find end of headers to determine Content-Length
            size_t header_end = raw_request.find("\r\n\r\n");
            if (header_end != std::string::npos) {
                size_t body_start = header_end + 4;
                size_t body_received = raw_request.size() - body_start;

                // Parse Content-Length from headers
                size_t content_length = 0;
                std::string headers_section = raw_request.substr(0, header_end);
                size_t cl_pos = headers_section.find("Content-Length:");
                if (cl_pos == std::string::npos)
                    cl_pos = headers_section.find("content-length:");
                if (cl_pos != std::string::npos) {
                    size_t val_start = cl_pos + 15; // length of "Content-Length:"
                    while (val_start < headers_section.size() && headers_section[val_start] == ' ')
                        val_start++;
                    size_t val_end = headers_section.find("\r\n", val_start);
                    if (val_end == std::string::npos) val_end = headers_section.size();
                    content_length = std::stoull(headers_section.substr(val_start, val_end - val_start));
                }

                // Read remaining body if needed (cap at MAX_BODY_SIZE)
                if (content_length > MAX_BODY_SIZE) content_length = MAX_BODY_SIZE;
                if (content_length > 0 && body_received < content_length) {
                    size_t remaining = content_length - body_received;
                    raw_request.reserve(body_start + content_length);
                    char chunk[CHUNK_SIZE];
                    while (remaining > 0) {
                        size_t to_read = std::min(remaining, sizeof(chunk));
                        ssize_t n = read(client_fd, chunk, to_read);
                        if (n <= 0) break;
                        raw_request.append(chunk, n);
                        remaining -= n;
                    }
                }
            }
            
            // Parse request and route
            Request request(raw_request);
            std::cout << "📨 " << request.toString() << std::endl;
            
            Response response = router_.handle(request);

            // Streaming responses (SSE) take ownership of the socket: the
            // handler writes the HTTP preamble itself, registers with the
            // long-lived publisher, and is responsible for the eventual
            // close().  Skip the normal write + close path entirely.
            if (response.isStream()) {
                std::cout << "📤 stream takeover (fd " << client_fd << ")" << std::endl;
                response.streamHandler()(client_fd);
                return;
            }

            // Send response
            std::string http_response = response.toHttpString();
            send(client_fd, http_response.c_str(), http_response.length(), MSG_NOSIGNAL);
            
            std::cout << "📤 " << response.toString() << std::endl;
            
        } catch (const std::exception& e) {
            std::cerr << "❌ Request processing error: " << e.what() << std::endl;
            
            // Send error response
            Response error_response = Response::internalError("Internal server error");
            std::string http_response = error_response.toHttpString();
            send(client_fd, http_response.c_str(), http_response.length(), MSG_NOSIGNAL);
        } catch (...) {
            // Non-std::exception throws (rare, but possible from ABI
            // internals or legacy code) would otherwise propagate up
            // to the thread lambda's outer catch(...). Handle here so
            // the client at least sees a 500 instead of a dead socket.
            std::cerr << "❌ Request processing error: non-std exception"
                      << std::endl;
            Response error_response = Response::internalError("Internal server error");
            std::string http_response = error_response.toHttpString();
            send(client_fd, http_response.c_str(), http_response.length(), MSG_NOSIGNAL);
        }
        
        close(client_fd);
    }
};

int main() {
    // Initialize libcurl globally before any threads are created
    curl_global_init(CURL_GLOBAL_ALL);

    try {
        HttpServer server(3001);
        
        if (!server.initialize()) {
            std::cerr << "❌ Server initialization failed" << std::endl;
            curl_global_cleanup();
            return 1;
        }
        
        server.run();
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Server error: " << e.what() << std::endl;
        curl_global_cleanup();
        return 1;
    }
    
    curl_global_cleanup();
    return 0;
}