# Copyright (c) 2019, NikitaFeodonit. All rights reserved.
#
## Pixman build file for CMake build tools

# Based on the code from
# https://github.com/solvespace/pixman/tree/0.34+cmake

set(TESTPROGRAMS
  oob-test
  infinite-loop
  trap-crasher
  fence-image-self-test
  region-translate-test
  fetch-test
  a1-trap-test
  prng-test
  radial-invalid
  pdf-op-test
  region-test
  combiner-test
  scaling-crash-test
  alpha-loop
  scaling-helpers-test
  thread-test
  rotate-test
  alphamap
  gradient-crash-test
  pixel-test
  matrix-test
  filter-reduction-test
  composite-traps-test
  region-contains-test
  glyph-test
  solid-test
  stress-test
  cover-test
  blitters-test
  affine-test
  scaling-test
  composite
  tolerance-test
)

set(OTHERPROGRAMS
  lowlevel-blt-bench
  radial-perf-test
  check-formats
  scaling-bench
  affine-bench
)

add_library(pixman_test_utils STATIC
  utils.c
  utils-prng.c
  utils.h
  utils-prng.h
)

if(OpenMP_FOUND)
  target_compile_options(pixman_test_utils PUBLIC ${OpenMP_C_FLAGS})
  target_link_libraries(pixman_test_utils PUBLIC ${OpenMP_C_FLAGS})
endif()
target_link_libraries(pixman_test_utils PUBLIC pixman)
if(PNG_FOUND)
  target_compile_definitions(pixman_test_utils PUBLIC ${PNG_DEFINITIONS})
  target_include_directories(pixman_test_utils PUBLIC ${PNG_INCLUDE_DIRS})
  target_link_libraries(pixman_test_utils PUBLIC ${PNG_LIBRARIES})
endif()

foreach(program ${TESTPROGRAMS} ${OTHERPROGRAMS})
  add_executable(pixman_${program} ${program}.c)
  target_link_libraries(pixman_${program} PRIVATE pixman_test_utils)
  set_target_properties(pixman_${program} PROPERTIES
    OUTPUT_NAME ${program}
  )
endforeach()

foreach(program ${TESTPROGRAMS})
  add_test(NAME ${program} COMMAND pixman_${program})
  set_tests_properties(${program} PROPERTIES SKIP_RETURN_CODE 77)
endforeach()
