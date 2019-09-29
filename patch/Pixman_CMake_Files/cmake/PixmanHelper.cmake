include(AutoconfHelper)
include(CMakeParseArguments)
include(CheckCSourceCompiles)


# Find a -Werror for catching warnings.
function(pixman_check_werror_c_flag)
  set(program_src
    "int main(int argc, char **argv) { (void)argc; (void)argv; return 0; }"
  )

  foreach(FLAG "-Werror" "-errwarn")
    string(REPLACE "-" "_" ESCAPED_FLAG ${FLAG})
    set(CMAKE_REQUIRED_FLAGS ${FLAG})
    check_c_source_compiles("${program_src}" HAS${ESCAPED_FLAG})
    ac_msg_checking("whether the compiler supports ${FLAG}" ${HAS${ESCAPED_FLAG}})
    if(HAS${ESCAPED_FLAG})
      set(PIXMAN_WERROR_C_FLAG "${FLAG}" PARENT_SCOPE)
      break()
    endif()
  endforeach()
endfunction()


# pixman_check_c_flag(flag, [program])
# Adds flag to PIXMAN_C_FLAGS if the given program links
# without warnings or errors.
function(pixman_check_c_flag FLAG)
  set(program_src
    "int main(int argc, char **argv) { (void)argc; (void)argv; return 0; }"
  )
  if(ARGC GREATER 1)
    set(program_src "${ARGV1}\n${program_src}")
  endif()

  string(REPLACE "-" "_" ESCAPED_FLAG ${FLAG})
  string(REPLACE "=" "_" ESCAPED_FLAG ${ESCAPED_FLAG})

  set(CMAKE_REQUIRED_FLAGS "${PIXMAN_WERROR_C_FLAG} ${FLAG}")
  check_c_source_compiles("${program_src}" HAS${ESCAPED_FLAG})
  ac_msg_checking("whether the compiler supports ${FLAG}" ${HAS${ESCAPED_FLAG}})
  if(HAS${ESCAPED_FLAG})
    list(APPEND PIXMAN_C_FLAGS ${FLAG})
    set(PIXMAN_C_FLAGS ${PIXMAN_C_FLAGS} PARENT_SCOPE)
  endif()
endfunction()


function(pixman_check_target_feature SOURCE FLAGS RESULT_VAR DESCRIPTION MESSAGE)
  cmake_parse_arguments("ctf" "" "MSVC" "" ${ARGN})
  # -> ctf_MSVC

  if(DEFINED ${RESULT_VAR})
    # We got a -D${RESULT_VAR}=... on command line; just put it into the cache.
  elseif(MSVC AND DEFINED ctf_MSVC)
    # Win32 has hardcoded default values
    if(${ctf_MSVC})
      set(${RESULT_VAR} ON)
    else()
      set(${RESULT_VAR} OFF)
    endif()
  else()
    # Autodetect the feature (and then put it into cache).
    if(FLAGS MATCHES -x)
      # Only pass -x to compiler, not linker.
      set(CMAKE_REQUIRED_DEFINITIONS "${FLAGS}")
    else()
      set(CMAKE_REQUIRED_FLAGS "${FLAGS}")
    endif()
    check_c_source_compiles("${SOURCE}" ${RESULT_VAR})
  endif()
  if(${RESULT_VAR})
    set(${RESULT_VAR} "1" CACHE STRING ${DESCRIPTION})
  endif()
  ac_msg_checking(${MESSAGE} ${${RESULT_VAR}})
endfunction()
