# Copyright (c) 2019, NikitaFeodonit. All rights reserved.
#
## Pixman build file for CMake build tools

# Based on the code from
# https://github.com/solvespace/pixman/tree/0.34+cmake

set(SOURCES
  pixman.c
  pixman-access.c
  pixman-access-accessors.c
  pixman-bits-image.c
  pixman-combine32.c
  pixman-combine-float.c
  pixman-conical-gradient.c
  pixman-filter.c
  pixman-x86.c
  pixman-mips.c
  pixman-arm.c
  pixman-ppc.c
  pixman-edge.c
  pixman-edge-accessors.c
  pixman-fast-path.c
  pixman-glyph.c
  pixman-general.c
  pixman-gradient-walker.c
  pixman-image.c
  pixman-implementation.c
  pixman-linear-gradient.c
  pixman-matrix.c
  pixman-noop.c
  pixman-radial-gradient.c
  pixman-region16.c
  pixman-region32.c
  pixman-solid-fill.c
  pixman-timer.c
  pixman-trap.c
  pixman-utils.c
)

if(ANDROID)
  list(APPEND SOURCES
    "${ANDROID_NDK}/sources/android/cpufeatures/cpu-features.c"
  )
endif()

set(HEADERS
  pixman.h
  pixman-accessor.h
  pixman-combine32.h
  pixman-compiler.h
  pixman-edge-imp.h
  pixman-inlines.h
  pixman-private.h
)

if(ANDROID)
  list(APPEND HEADERS
    "${ANDROID_NDK}/sources/android/cpufeatures/cpu-features.h"
  )
endif()

if(USE_X86_MMX)
  list(APPEND SOURCES
    pixman-mmx.c
  )
  set_source_files_properties(
    pixman-mmx.c
    PROPERTIES COMPILE_FLAGS "${X86_MMX_FLAGS}"
  )
endif()

if(USE_VMX)
  list(APPEND SOURCES
    pixman-vmx.c
  )
  list(APPEND HEADERS
    pixman-combine32.h
  )
  set_source_files_properties(
    pixman-vmx.c
    PROPERTIES COMPILE_FLAGS "${VMX_FLAGS}"
  )
endif()

if(USE_SSE2)
  list(APPEND SOURCES
    pixman-sse2.c
  )
  set_source_files_properties(
    pixman-sse2.c
    PROPERTIES COMPILE_FLAGS "${SSE2_FLAGS}"
  )
endif()

if(USE_SSSE3)
  list(APPEND SOURCES
    pixman-ssse3.c
  )
  set_source_files_properties(
    pixman-ssse3.c
    PROPERTIES COMPILE_FLAGS "${SSSE3_FLAGS}"
  )
endif()

if(USE_ARM_SIMD)
  list(APPEND SOURCES
    pixman-arm-simd.c
    pixman-arm-simd-asm.S
    pixman-arm-simd-asm-scaled.S
  )
  list(APPEND HEADERS
    pixman-arm-common.h
    pixman-arm-asm.h
    pixman-arm-simd-asm.h
  )
  if(ANDROID)
    set_source_files_properties(
      pixman-arm-simd-asm.S
      pixman-arm-simd-asm-scaled.S
      PROPERTIES COMPILE_FLAGS "-fno-integrated-as"
    )
  endif()
endif()

if(USE_ARM_NEON)
  list(APPEND SOURCES
    pixman-arm-neon.c
    pixman-arm-neon-asm.S
    pixman-arm-neon-asm-bilinear.S
  )
  list(APPEND HEADERS
    pixman-arm-common.h
    pixman-arm-asm.h
    pixman-arm-neon-asm.h
  )
  if(ANDROID)
    set_source_files_properties(
      pixman-arm-neon-asm.S
      pixman-arm-neon-asm-bilinear.S
      PROPERTIES COMPILE_FLAGS "-fno-integrated-as"
    )
  endif()
endif()

if(USE_ARM_IWMMXT)
  list(APPEND SOURCES
    pixman-mmx.c
  )
  set_source_files_properties(
    pixman-mmx.c
    PROPERTIES COMPILE_FLAGS "${IWMMXT_FLAGS}"
  )
endif()

if(USE_MIPS_DSPR2)
  list(APPEND SOURCES
    pixman-mips-dspr2.c
    pixman-mips-dspr2-asm.S
    pixman-mips-memcpy-asm.S
  )
  list(APPEND HEADERS
    pixman-mips-dspr2.h
    pixman-mips-dspr2-asm.h
  )
endif()

if(USE_LOONGSON_MMI)
  list(APPEND SOURCES
    pixman-mmx.c
  )
  list(APPEND HEADERS
    loongson-mmintrin.h
  )
  set_source_files_properties(
    pixman-mmx.c
    PROPERTIES COMPILE_FLAGS "${LOONGSON_MMI_FLAGS}"
  )
endif()

add_library(pixman ${SOURCES} ${HEADERS})
target_compile_definitions(pixman PUBLIC HAVE_CONFIG_H)
target_compile_options(pixman PUBLIC ${PIXMAN_C_FLAGS})

target_include_directories(pixman PUBLIC
  ${PROJECT_SOURCE_DIR}/pixman
  ${PROJECT_BINARY_DIR}/pixman
)
if(ANDROID)
  target_include_directories(pixman PUBLIC
    "${ANDROID_NDK}/sources/android/cpufeatures"
  )
endif()

if(Threads_FOUND)
  target_link_libraries(pixman PUBLIC Threads::Threads)
endif()

if(LIBM_LIBRARY)
  target_link_libraries(pixman PUBLIC ${LIBM_LIBRARY})
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  set_target_properties(pixman PROPERTIES
    WINDOWS_EXPORT_ALL_SYMBOLS ON
  )
endif()

set_target_properties(pixman PROPERTIES
  OUTPUT_NAME pixman-1
  CXX_VISIBILITY_PRESET hidden
)
install(TARGETS pixman
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
)

configure_file(
  pixman-version.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/pixman-version.h
)
install(FILES
  pixman.h
  ${CMAKE_CURRENT_BINARY_DIR}/pixman-version.h
  DESTINATION include/pixman-1
)
