cmake_minimum_required(VERSION 3.21)
project(GitQlient VERSION 2.0 LANGUAGES CXX)

option(EXCLUDE_TESTS "Exclude the tests from the build" OFF)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
#list(PREPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Vor allen Qt-Makros setzen:
set(QT_DEFAULT_MAJOR_VERSION 6)
set(QT_FORCE_CMP0156_TO_VALUE NEW)

# Nutze die Config-Suche von Qt (robuster) und erzwinge 6.9.2 falls gewünscht:
find_package(Qt6 6.9.2 EXACT CONFIG REQUIRED COMPONENTS Core Gui Test)

# Jetzt erst das Macro – kennt dank obiger Zeilen die Qt-Version
qt6_standard_project_setup()

add_subdirectory(app)

if(NOT EXCLUDE_TESTS)
    add_subdirectory(tests)
endif()
