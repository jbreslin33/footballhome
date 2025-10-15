cmake_minimum_required(VERSION 3.10)
project(footballhome_api)

set(CMAKE_CXX_STANDARD 17)

# Find required packages
find_package(Drogon REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

# Source files
file(GLOB_RECURSE SOURCES 
    "src/*.cpp"
    "src/*.cc"
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE 
    Drogon::Drogon
    ${JSONCPP_LIBRARIES}
)

# Compiler flags
target_compile_options(${PROJECT_NAME} PRIVATE ${JSONCPP_CFLAGS_OTHER})