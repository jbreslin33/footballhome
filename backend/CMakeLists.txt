cmake_minimum_required(VERSION 3.16)
project(footballhome_backend)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(PQXX REQUIRED libpqxx)

# Include directories
include_directories(src)
include_directories(${PQXX_INCLUDE_DIRS})

# Source files
set(SOURCES
    src/main.cpp
    src/core/Request.cpp
    src/core/Response.cpp
    src/core/Router.cpp
    src/core/Controller.cpp
    src/core/HttpClient.cpp
    src/core/JwtRS256.cpp
    src/core/Crypto.cpp
    src/core/Mail.cpp
    src/core/TeamLabel.cpp
    src/database/Database.cpp
    src/database/Model.cpp
    src/database/SqlFileLogger.cpp
    src/database/SqlBuilder.cpp
    src/models/User.cpp
    src/models/Team.cpp
    src/models/TeamCoach.cpp
    src/models/TeamRoster.cpp
    src/models/PersonLinker.cpp
    src/models/TeamReconciliation.cpp
    src/models/PersonOverride.cpp
    src/models/PersonMerge.cpp
    src/models/LaPool.cpp
    src/models/PersonBilling.cpp
    src/models/PayReminderLog.cpp
    src/models/PersonPayments.cpp
    src/models/ChargeFlags.cpp
    src/models/BillingExpectations.cpp
    src/models/YouthAgeGroups.cpp
    src/models/YouthRoster.cpp
    src/models/MensTeamColumns.cpp
    src/models/MensTeamAssignments.cpp
    src/models/MensRoster.cpp
    src/models/BoysRoster.cpp
    src/models/Lead.cpp
    src/models/LeadContact.cpp
    src/services/UserService.cpp
    src/services/IdentityService.cpp
    src/services/LeagueAppsService.cpp
    src/services/LaProgramSync.cpp
    src/services/SessionService.cpp
    src/services/MetaLeadsService.cpp
    src/services/MetaAdsService.cpp
    src/services/LineupNotificationHub.cpp
    src/services/BillingProjector.cpp
    src/controllers/AuthController.cpp
    src/controllers/MagicLinkAuthController.cpp
    src/controllers/EventRsvpController.cpp
    src/controllers/TeamReconciliationController.cpp
    src/controllers/OAuthController.cpp
    src/controllers/TeamController.cpp
    src/controllers/TeamCoachController.cpp
    src/controllers/TeamRosterController.cpp
    src/controllers/PersonOverrideController.cpp
    src/controllers/PersonMergeController.cpp
    src/controllers/EventController.cpp
    src/controllers/DivisionController.cpp
    src/controllers/AvailabilityController.cpp
    src/controllers/SystemAdminController.cpp
    src/controllers/TacticalBoardController.cpp
    src/controllers/StatsController.cpp
    src/controllers/ClubController.cpp
    src/controllers/ClubLaPoolController.cpp
    src/controllers/YouthRosterController.cpp
    src/controllers/MensRosterController.cpp
    src/controllers/BoysRosterController.cpp
    src/controllers/PersonBillingController.cpp
    src/controllers/PayReminderLogController.cpp
    src/controllers/PaymentsController.cpp
    src/controllers/ChargeFlagsController.cpp
    src/controllers/BillingController.cpp
    src/controllers/AdminLaBackfillController.cpp
    src/controllers/LeadsController.cpp
    src/controllers/LeadsWebhookController.cpp
    src/controllers/AdsController.cpp
    src/controllers/StreamController.cpp
    src/controllers/EligibilityController.cpp
    src/controllers/SocialController.cpp
    src/controllers/InternalRosterController.cpp
    src/controllers/PublicController.cpp
    src/controllers/MatchSeriesController.cpp
    src/controllers/MyController.cpp
    src/controllers/EventReminderController.cpp
    src/controllers/SimLobbyController.cpp
    src/controllers/SimDebugController.cpp
    src/controllers/TrailTestController.cpp
    src/services/RsvpMaterialization.cpp)

# Create executable
add_executable(server ${SOURCES})

# Link libraries
target_link_libraries(server 
    ${PQXX_LIBRARIES}
    pthread
    curl
    ssl
    crypto
)

# Compiler flags
target_compile_options(server PRIVATE ${PQXX_CFLAGS_OTHER})

# Set output directory
set_target_properties(server PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Debug information
set(CMAKE_BUILD_TYPE Release)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(server PRIVATE DEBUG=1)
endif()