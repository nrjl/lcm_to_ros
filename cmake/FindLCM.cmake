INCLUDE(FindPackageHandleStandardArgs)

SET(LCM_IncludeSearchPaths
  /usr/include/
  /usr/local/include/
  /opt/local/include
)

SET(LCM_LibrarySearchPaths
  /usr/lib/
  /usr/local/lib/
  /opt/local/lib/
)

FIND_PATH(LCM_INCLUDE_DIR lcm/lcm.h
  PATHS ${LCM_IncludeSearchPaths}
)
FIND_LIBRARY(LCM_LIBRARY
  NAMES lcm
  PATHS ${LCM_LibrarySearchPaths}
)

# Handle the REQUIRED argument and set the <UPPERCASED_NAME>_FOUND variable
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LCM "Could NOT find LCM library (LCM)"
  LCM_LIBRARY
  LCM_INCLUDE_DIR
)

MARK_AS_ADVANCED(
  LCM_LIBRARY
  LCM_INCLUDE_DIR
)
