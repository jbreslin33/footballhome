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
    src/core/SQLFileWriter.cpp
    src/database/Database.cpp
    src/database/Model.cpp
    src/database/SqlFileLogger.cpp
    src/database/SqlBuilder.cpp
    src/models/User.cpp
    src/models/Team.cpp
    src/services/UserService.cpp
    src/controllers/AuthController.cpp
    src/controllers/TeamController.cpp
    src/controllers/EventController.cpp
    src/controllers/DivisionController.cpp
    src/controllers/AvailabilityController.cpp
    src/controllers/SystemAdminController.cpp)

# Create executable
add_executable(server ${SOURCES})

# Link libraries
target_link_libraries(server 
    ${PQXX_LIBRARIES}
    pthread
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