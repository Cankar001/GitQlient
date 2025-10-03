# FindQt6.cmake — findet Qt 6.9.2 exakt und lädt erst dann Qt6Config.cmake
# Setzt: Qt6_FOUND, Qt6_DIR, Qt6_VERSION

include_guard(GLOBAL)
include(FindPackageHandleStandardArgs)

set(_Qt6_REQUIRED_VERSION "6.9.2")

# 1) Bereits bekannte Qt6_DIR?
if(DEFINED Qt6_DIR AND EXISTS "${Qt6_DIR}/Qt6Config.cmake")
  set(_Qt6_CONFIG_FILE "${Qt6_DIR}/Qt6Config.cmake")
endif()

# 2) Standardpfade durchsuchen
if(NOT _Qt6_CONFIG_FILE)
  set(_Qt6_HINT_ROOTS
    "$ENV{Qt6_DIR}" "$ENV{Qt6_ROOT}" "$ENV{QT_DIR}" "$ENV{QTDIR}" "$ENV{QtDir}"
    "$ENV{HOME}/Qt/6.9.2"
    "C:/Qt/6.9.2" "C:/Qt/6.9.2/msvc2022_64" "C:/Qt/6.9.2/msvc2019_64" "C:/Qt/6.9.2/mingw_64"
    "/opt/homebrew/opt/qt@6" "/usr/local/opt/qt@6" "/usr/local/opt/qt" "/usr/local" "/usr" "/opt/local"
  )
  set(_Qt6_PATH_SUFFIXES "lib/cmake/Qt6" "lib64/cmake/Qt6" "cmake/Qt6" "Qt6/lib/cmake/Qt6")

  find_file(_Qt6_CONFIG_FILE
    NAMES Qt6Config.cmake
    HINTS ${_Qt6_HINT_ROOTS}
    PATH_SUFFIXES ${_Qt6_PATH_SUFFIXES}
  )
endif()

# 3) Version sicher bestimmen
set(Qt6_VERSION "0.0.0")
if(_Qt6_CONFIG_FILE)
  get_filename_component(_Qt6_CONFIG_DIR "${_Qt6_CONFIG_FILE}" DIRECTORY)
  set(_Qt6_VERSION_FILE "${_Qt6_CONFIG_DIR}/Qt6ConfigVersion.cmake")

  if(EXISTS "${_Qt6_VERSION_FILE}")
    # a) Versuche, die Datei zu includen, um PACKAGE_VERSION zu bekommen
    include("${_Qt6_VERSION_FILE}" OPTIONAL RESULT_VARIABLE _qt6_ver_inc)
    if(DEFINED PACKAGE_VERSION)
      set(Qt6_VERSION "${PACKAGE_VERSION}")
    else()
      # b) Fallback: Aus der Datei parsen
      file(STRINGS "${_Qt6_VERSION_FILE}" _qt6_ver_line
           REGEX "^[ \t]*set\\([ \t]*PACKAGE_VERSION[ \t]*\"[^\"]+\"[ \t]*\\)")
      if(_qt6_ver_line)
        string(REGEX REPLACE ".*PACKAGE_VERSION[ \t]*\"([^\"]+)\".*" "\\1"
               Qt6_VERSION "${_qt6_ver_line}")
      endif()
    endif()
  endif()

  set(Qt6_DIR "${_Qt6_CONFIG_DIR}")
endif()

# 4) Standard-Handle (meldet Pfad/Version schön an find_package)
find_package_handle_standard_args(Qt6
  REQUIRED_VARS Qt6_DIR _Qt6_CONFIG_FILE
  VERSION_VAR  Qt6_VERSION
)

# 5) Exakte Versionsprüfung
if(Qt6_FOUND)
  if(NOT Qt6_VERSION VERSION_EQUAL "${_Qt6_REQUIRED_VERSION}")
    if(NOT Qt6_FIND_QUIETLY)
      message(STATUS "Qt6 gefunden in: ${Qt6_DIR}, aber Version '${Qt6_VERSION}' != gefordert '${_Qt6_REQUIRED_VERSION}'.")
    endif()
    set(Qt6_FOUND FALSE)
  endif()
endif()

# 6) Erst jetzt Targets laden (damit qt_add_executable verfügbar ist)
if(Qt6_FOUND)
  include("${_Qt6_CONFIG_FILE}")
endif()

# Aufräumen
unset(_Qt6_CONFIG_FILE CACHE)
unset(_Qt6_CONFIG_DIR)
unset(_Qt6_VERSION_FILE)
unset(_Qt6_HINT_ROOTS)
unset(_Qt6_PATH_SUFFIXES)
unset(_qt6_ver_line)
unset(_qt6_ver_inc)
