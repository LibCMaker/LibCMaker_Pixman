# Copyright (c) 2019, NikitaFeodonit. All rights reserved.
#
## Pixman build file for CMake build tools

# Based on the code from
# https://github.com/solvespace/pixman/tree/0.34+cmake

project(pixman C ASM)

if(MSVC)
  cmake_minimum_required(VERSION 3.4)
else()
  cmake_minimum_required(VERSION 3.1)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(AutoconfHelper)
include(PixmanHelper)


# ========================================================================
# Options
#
option(PIXMAN_BUILD_TESTS "Build and run regression tests" ON)
option(PIXMAN_BUILD_DEMOS "Build demo code" ON)

option(PIXMAN_ENABLE_OPENMP                                 "Enable OpenMP" ON)
option(PIXMAN_ENABLE_LOONGSON_MMI          "Enable Loongson MMI fast paths" ON)
option(PIXMAN_ENABLE_MMX                        "Enable x86 MMX fast paths" ON)
option(PIXMAN_ENABLE_SSE2                          "Enable SSE2 fast paths" ON)
option(PIXMAN_ENABLE_SSSE3                        "Enable SSSE3 fast paths" ON)
option(PIXMAN_ENABLE_VMX                            "Enable VMX fast paths" ON)
option(PIXMAN_ENABLE_ARM_SIMD                  "Enable ARM SIMD fast paths" ON)
option(PIXMAN_ENABLE_ARM_NEON                  "Enable ARM NEON fast paths" ON)
option(PIXMAN_ENABLE_ARM_IWMMXT              "Enable ARM IWMMXT fast paths" ON)
option(PIXMAN_ENABLE_ARM_IWMMXT2
  "Build ARM IWMMXT fast paths with -march=iwmmxt instead of -march=iwmmxt2"
  ON
)
option(PIXMAN_ENABLE_MIPS_DSPR2              "Enable MIPS DSPr2 fast paths" ON)
option(PIXMAN_ENABLE_GCC_INLINE_ASM     "Enable GNU-style inline assembler" ON)
option(PIXMAN_ENABLE_STATIC_TESTPROGS
  "Build test programs as static binaries"
  OFF
)
option(PIXMAN_ENABLE_TIMERS       "Enable TIMER_BEGIN and TIMER_END macros" OFF)
option(PIXMAN_ENABLE_GNUPLOT
  "Enable output of filters that can be piped to gnuplot"
  OFF
)
option(PIXMAN_ENABLE_GTK                          "Enable tests using GTK+" ON)
option(PIXMAN_ENABLE_LIBPNG                      "Build support for libpng" ON)


# ========================================================================
# Versioning
#
file(READ "${CMAKE_CURRENT_LIST_DIR}/configure.ac" configure_ac)
string(REGEX REPLACE ".*m4_define\\(\\[pixman_major\\], ([0-9]+)\\).*" "\\1"
  PIXMAN_VERSION_MAJOR ${configure_ac}
)
string(REGEX REPLACE ".*m4_define\\(\\[pixman_minor\\], ([0-9]+)\\).*" "\\1"
  PIXMAN_VERSION_MINOR ${configure_ac}
)
string(REGEX REPLACE ".*m4_define\\(\\[pixman_micro\\], ([0-9]+)\\).*" "\\1"
  PIXMAN_VERSION_MICRO ${configure_ac}
)
set(PIXMAN_VERSION
  "${PIXMAN_VERSION_MAJOR}.${PIXMAN_VERSION_MINOR}.${PIXMAN_VERSION_MICRO}"
)
message(STATUS "Building pixman version ${PIXMAN_VERSION}")


ac_init("pixman" ${PIXMAN_VERSION} "pixman@lists.freedesktop.org" "pixman")
ac_check_symbol("getisax" "sys/auxv.h" HAVE_GETISAX)
ac_c_bigendian()
ac_c_inline()

ac_check_sizeof("long")

# Find a -Werror for catching warnings.
pixman_check_werror_c_flag()  # Set PIXMAN_WERROR_C_FLAG

# Check for dependencies

if(NOT MSVC)
  pixman_check_c_flag(-Wall)
  pixman_check_c_flag(-Wdeclaration-after-statement)
  pixman_check_c_flag(-Wno-unused-local-typedefs)
  pixman_check_c_flag(-fno-strict-aliasing)
endif()


# ========================================================================
# OpenMP for the test suite?
#
if(PIXMAN_ENABLE_OPENMP)
  if(NOT MSVC)
    # Currently, OpenMP code cannot be built with MSVC; it fails with
    # "utils.h:23: 'threadprivate' is only valid for global or static data items"
    find_package(OpenMP)
    if(OpenMP_FOUND)
      set(USE_OPENMP "1" CACHE BOOL "Use OpenMP in the test suite")
    endif()
  endif()
endif()


# ========================================================================
# -fvisibility stuff
#
#pixman_check_c_flag("-fvisibility=hidden"
#"
##if defined(__GNUC__) && (__GNUC__ >= 4)
##ifdef _WIN32
##error Have -fvisibility but it is ignored and generates a warning
##endif
##else
##error Need GCC 4.0 for visibility
##endif
#"
#)


pixman_check_c_flag("-xldscope=hidden"
"
#if defined(__SUNPRO_C) && (__SUNPRO_C >= 0x550)
#else
#error Need Sun Studio 8 for visibility
#endif
"
)


# ========================================================================
# Check for Loongson Multimedia Instructions
#
if(PIXMAN_ENABLE_LOONGSON_MMI)
  set(LOONGSON_MMI_FLAGS "-march=loongson2f")
  pixman_check_target_feature(
"
#ifndef __mips_loongson_vector_rev
#error Loongson Multimedia Instructions are only available on Loongson
#endif
#if defined(__GNUC__) && (__GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 4))
#error Need GCC >= 4.4 for Loongson MMI compilation
#endif
#include <pixman/loongson-mmintrin.h>
int main () {
    union {
        __m64 v;
        char c[8];
    } a = { .c = {1, 2, 3, 4, 5, 6, 7, 8} };
    int b = 4;
    __m64 c = _mm_srli_pi16 (a.v, b);
    return 0;
}
"
    "${LOONGSON_MMI_FLAGS} -I${CMAKE_CURRENT_SOURCE_DIR}"
    USE_LOONGSON_MMI "Enable Loongson MMI fast paths"
    "whether to use Loongson MMI assembler"
    MSVC OFF
  )
  #if(NOT USE_LOONGSON_MMI)
  #  ac_msg_error("Loongson MMI not detected")
  #endif()
endif()


# ========================================================================
# Check for MMX
#
if(PIXMAN_ENABLE_MMX)
  if(MSVC)
    set(X86_MMX_FLAGS "-w14710 -w14714")
  else()
    set(X86_MMX_FLAGS "-mmmx -Winline")
  endif()

  # TODO:
  if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    set(USE_X86_MMX_MSVC ON)
  else()
    set(USE_X86_MMX_MSVC OFF)
  endif()
  pixman_check_target_feature(
"
#if defined(__GNUC__) && (__GNUC__ < 3 || (__GNUC__ == 3 && __GNUC_MINOR__ < 4))
#error Need GCC >= 3.4 for MMX intrinsics
#endif
#include <mmintrin.h>
#include <stdint.h>

/* Check support for block expressions */
#define _mm_shuffle_pi16(A, N)                      \\\\
    ({                                              \\\\
    __m64 ret;                                      \\\\
                                                    \\\\
    /* Some versions of clang will choke on K */    \\\\
    asm (\"pshufw %2, %1, %0\\\\n\\\\t\"            \\\\
         : \"=y\" (ret)                             \\\\
         : \"y\" (A), \"K\" ((const int8_t)N)       \\\\
    );                                              \\\\
                                                    \\\\
    ret;                                            \\\\
    })

int main () {
    __m64 v = _mm_cvtsi32_si64 (1);
    __m64 w;

    w = _mm_shuffle_pi16(v, 5);

    /* Some versions of clang will choke on this */
    asm (\"pmulhuw %1, %0\\\\n\\\\t\"
    : \"+y\" (w)
    : \"y\" (v)
    );

    return _mm_cvtsi64_si32 (v);
}
"
    "${X86_MMX_FLAGS}"
    USE_X86_MMX "Use x86 MMX compiler intrinsics"
    "whether to use MMX intrinsics"
    MSVC ${USE_X86_MMX_MSVC}
  )
  #if(NOT USE_X86_MMX)
  #  ac_msg_error("x86 MMX intrinsics not detected")
  #endif()
  # TODO: MMX_LDFLAGS
endif()


# ========================================================================
# Check for SSE2
#
if(PIXMAN_ENABLE_SSE2)
  if(MSVC)
    set(SSE2_FLAGS "")
  else()
    set(SSE2_FLAGS "-msse2 -Winline")
  endif()
  pixman_check_target_feature(
"
#if defined(__GNUC__) && (__GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 2))
#   if !defined(__amd64__) && !defined(__x86_64__)
#      error Need GCC >= 4.2 for SSE2 intrinsics on x86
#   endif
#endif
#include <mmintrin.h>
#include <xmmintrin.h>
#include <emmintrin.h>
int param;
int main () {
    __m128i a = _mm_set1_epi32 (param), b = _mm_set1_epi32 (param + 1), c;
    c = _mm_xor_si128 (a, b);
    return _mm_cvtsi128_si32(c);
}
"
    "${SSE2_FLAGS}"
    USE_SSE2 "Use SSE2 compiler intrinsics"
    "whether to use SSE2 intrinsics"
    MSVC ON
  )
  #if(NOT USE_SSE2)
  #  ac_msg_error("SSE2 intrinsics not detected")
  #endif()
  # TODO: SSE2_LDFLAGS
endif()


# ========================================================================
# Check for SSSE3
#
if(PIXMAN_ENABLE_SSSE3)
  if(MSVC)
    set(SSSE3_FLAGS "")
  else()
    set(SSSE3_FLAGS "-mssse3 -Winline")
  endif()
  pixman_check_target_feature(
"
#include <mmintrin.h>
#include <xmmintrin.h>
#include <emmintrin.h>
#include <tmmintrin.h>
int param;
int main () {
    __m128i a = _mm_set1_epi32 (param), b = _mm_set1_epi32 (param + 1), c;
    c = _mm_maddubs_epi16 (a, b);
    return _mm_cvtsi128_si32(c);
}
"
    "${SSSE3_FLAGS}"
    USE_SSSE3 "Use SSSE3 compiler intrinsics"
    "whether to use SSSE3 intrinsics"
    MSVC ON
  )
  #if(NOT USE_SSSE3)
  #  ac_msg_error("SSSE3 intrinsics not detected")
  #endif()
endif()


# ========================================================================
# Check for VMX/Altivec
#
if(PIXMAN_ENABLE_VMX)
  if(APPLE)
    set(VMX_FLAGS "-faltivec")
  else()
    set(VMX_FLAGS "-maltivec -mabi=altivec")
  endif()
  pixman_check_target_feature(
"
#if defined(__GNUC__) && (__GNUC__ < 3 || (__GNUC__ == 3 && __GNUC_MINOR__ < 4))
#error Need GCC >= 3.4 for sane altivec support
#endif
#include <altivec.h>
int main () {
    vector unsigned int v = vec_splat_u32 (1);
    v = vec_sub (v, v);
    return 0;
}
"
    "${VMX_FLAGS}"
    USE_VMX "Use VMX compiler intrinsics"
    "whether to use VMX/Altivec intrinsics"
    MSVC OFF
  )
  #if(NOT USE_VMX)
  #  ac_msg_error("VMX intrinsics not detected")
  #endif()
endif()


# ========================================================================
# Check if assembler is gas compatible and supports ARM SIMD instructions
#
if(PIXMAN_ENABLE_ARM_SIMD)
  set(ARM_SIMD_FLAGS "-x assembler-with-cpp")
  if(ANDROID)
    set(ARM_SIMD_FLAGS "${ARM_SIMD_FLAGS} -fno-integrated-as")
  endif()
  pixman_check_target_feature(
"
.text
.arch armv6
.object_arch armv4
.arm
.altmacro
#ifndef __ARM_EABI__
#error EABI is required (to be sure that calling conventions are compatible)
#endif
.globl main
main:
pld [r0]
uqadd8 r0, r0, r0
"
    "${ARM_SIMD_FLAGS}"
    USE_ARM_SIMD "Use ARM SIMD assembly optimizations"
    "whether to use ARM SIMD assembler"
    MSVC OFF
  )
  #if(NOT USE_ARM_SIMD)
  #  ac_msg_error("ARM SIMD intrinsics not detected")
  #endif()
endif()


# ========================================================================
# Check if assembler is gas compatible and supports NEON instructions
#
if(PIXMAN_ENABLE_ARM_NEON)
  set(ARM_NEON_FLAGS "-x assembler-with-cpp")
  if(ANDROID)
    set(ARM_NEON_FLAGS "${ARM_NEON_FLAGS} -fno-integrated-as")
  endif()
  pixman_check_target_feature(
"
.text
.fpu neon
.arch armv7a
.object_arch armv4
.eabi_attribute 10, 0
.arm
.altmacro
#ifndef __ARM_EABI__
#error EABI is required (to be sure that calling conventions are compatible)
#endif
.globl main
main:
pld [r0]
vmovn.u16 d0, q0
"
    "${ARM_NEON_FLAGS}"
    USE_ARM_NEON "Use ARM NEON assembly optimizations"
    "whether to use ARM NEON assembler"
    MSVC OFF
  )
  #if(NOT USE_ARM_NEON)
  #  ac_msg_error("ARM NEON intrinsics not detected")
  #endif()
endif()


# ========================================================================
# Check for IWMMXT
#
if(PIXMAN_ENABLE_ARM_IWMMXT)
  set(IWMMXT_FLAGS "-flax-vector-conversions -Winline -march=iwmmxt")
  if(PIXMAN_ENABLE_ARM_IWMMXT2)
    set(IWMMXT_FLAGS "${IWMMXT_FLAGS}2")
  endif()
  pixman_check_target_feature(
"
#ifndef __arm__
#error IWMMXT is only available on ARM
#endif
#ifndef __IWMMXT__
#error IWMMXT not enabled (with -march=iwmmxt)
#endif
#if defined(__GNUC__) && (__GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 8))
#error Need GCC >= 4.8 for IWMMXT intrinsics
#endif
#include <mmintrin.h>
int main () {
    union {
        __m64 v;
        char c[8];
    } a = { .c = {1, 2, 3, 4, 5, 6, 7, 8} };
    int b = 4;
    __m64 c = _mm_srli_si64 (a.v, b);
}
"
    "${IWMMXT_FLAGS}"
    USE_ARM_IWMMXT "Use ARM IWMMXT compiler intrinsics"
    "whether to use ARM IWMMXT intrinsics"
    MSVC OFF
  )
  #if(NOT USE_ARM_IWMMXT)
  #  ac_msg_error("IWMMXT intrinsics not detected")
  #endif()
endif()


# ========================================================================
# Check if assembler is gas compatible and supports MIPS DSPr2 instructions
#
if(PIXMAN_ENABLE_MIPS_DSPR2)
  set(MIPS_DSPR2_FLAGS "-mdspr2")
  pixman_check_target_feature(
"
#if !(defined(__mips__) &&  __mips_isa_rev >= 2)
#error MIPS DSPr2 is currently only available on MIPS32r2 platforms.
#endif
int
main ()
{
    int c = 0, a = 0, b = 0;
    __asm__ __volatile__ (
        \"precr.qb.ph %[c], %[a], %[b]          \\\\n\\\\t\"
        : [c] \"=r\" (c)
        : [a] \"r\" (a), [b] \"r\" (b)
    );
    return c;
}
"
    "${MIPS_DSPR2_FLAGS}"
    USE_MIPS_DSPR2 "Enable MIPS DSPr2 fast paths"
    "whether to use MIPS DSPr2 assembler"
    MSVC OFF
  )
  #if(NOT USE_MIPS_DSPR2)
  #  ac_msg_error("MIPS DSPr2 instructions not detected")
  #endif()
endif()


# ========================================================================
# Check for GNU-style inline assembly support
#
if(PIXMAN_ENABLE_GCC_INLINE_ASM)
  pixman_check_target_feature(
"int main () {
    /* Most modern architectures have a NOP instruction, so this is a fairly generic test. */
    asm volatile ( \"\\\\tnop\\\\n\" : : : \"cc\", \"memory\" );
    return 0;
}
"
    " "  #  TODO: or ""
    USE_GCC_INLINE_ASM "Use GNU-style inline assembler"
    "whether to use GNU-style inline assembler"
  )
  #if(NOT USE_MIPS_DSPR2)
  #  ac_msg_error("GNU-style inline assembler not detected")
  #endif()
endif()


# ========================================================================
# Static test programs
#
if(PIXMAN_ENABLE_STATIC_TESTPROGS)
  # TODO:
  #set(TESTPROGS_EXTRA_LDFLAGS "-all-static")
endif()


# ========================================================================
# Timers
#
if(PIXMAN_ENABLE_TIMERS AND NOT ANDROID)
  set(PIXMAN_TIMERS "1" CACHE STRING "Enable TIMER_BEGIN/TIMER_END macros")
endif()


# ========================================================================
# gnuplot
#
if(PIXMAN_ENABLE_GNUPLOT)
  set(PIXMAN_GNUPLOT "1" CACHE STRING
    "Enable output that can be piped to gnuplot"
  )
endif()


# ========================================================================
# GTK+
#
if(PIXMAN_ENABLE_GTK AND NOT ANDROID AND NOT IOS)
  find_package(PkgConfig)
  if(PKGCONFIG_FOUND)
    pkg_check_modules(GTK gtk+-2.0>=2.16)
  endif()
endif()


# ========================================================================
# posix_memalign, sigaction, alarm, gettimeofday
#
ac_check_symbol("posix_memalign" "stdlib.h"      HAVE_POSIX_MEMALIGN)
ac_check_symbol("sigaction"      "signal.h"      HAVE_SIGACTION)
ac_check_symbol("alarm"          "unistd.h"      HAVE_ALARM)
ac_check_header("sys/mman.h"                     HAVE_SYS_MMAN_H)
ac_check_symbol("mmap"           "sys/mman.h"    HAVE_MMAP)
ac_check_symbol("mprotect"       "sys/mman.h"    HAVE_MPROTECT)
ac_check_symbol("getpagesize"    "getpagesize"   HAVE_GETPAGESIZE)
ac_check_header("fenv.h"                         HAVE_FENV_H)
ac_check_lib   ("m"  "feenableexcept"  "fenv.h"  HAVE_FEENABLEEXCEPT)
ac_check_symbol("FE_DIVBYZERO"   "fenv.h"        HAVE_FEDIVBYZERO)

ac_check_symbol("gettimeofday"   "sys/time.h"    _HAVE_GETTIMEOFDAY)
ac_check_header("sys/time.h"                     HAVE_SYS_TIME_H)
if(_HAVE_GETTIMEOFDAY AND HAVE_SYS_TIME_H)
  set(HAVE_GETTIMEOFDAY "1")
endif()


# ========================================================================
# Check for missing sqrtf() as, e.g., for Solaris 9
#
#ac_search_libs("sqrtf" "m" "math.h" HAVE_SQRTF)
#if(NOT HAVE_SQRTF)
#  # Define to sqrt if you do not have the `sqrtf' function.
#  set(sqrtf "sqrt")
#endif()

find_library(LIBM_LIBRARY "m")
if(LIBM_LIBRARY)
  set(CMAKE_REQUIRED_LIBRARIES ${LIBM_LIBRARY})
endif()
check_c_source_compiles(
"#include <math.h>
int main() {sqrtf(0.0); return 0;}"
  HAVE_SQRTF
)
unset(CMAKE_REQUIRED_LIBRARIES)
if(NOT HAVE_SQRTF)
  set(sqrtf sqrt)
endif()


# ========================================================================
# Thread local storage
#
foreach(keyword "__thread" "__declspec(thread)")
  check_c_source_compiles(
"#if defined(__MINGW32__) && !(__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 5))
#error This MinGW version has broken __thread support
#endif
#ifdef __OpenBSD__
#error OpenBSD has broken __thread support
#endif

int ${keyword} test;
int main() { return 0; }"
    HAVE_TLS_${keyword}
  )
  if(HAVE_TLS_${keyword})
    set(TLS ${keyword})
    break()
  endif()
endforeach()
ac_msg_checking("for thread local storage (TLS) support" ${TLS})

#
# posix tls
#
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads)
set(HAVE_PTHREADS ${CMAKE_USE_PTHREADS_INIT})
ac_msg_checking("for pthreads" ${HAVE_PTHREADS})


# ========================================================================
# __attribute__((constructor))
#
check_c_source_compiles(
"#if defined(__GNUC__) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7))
/* attribute 'constructor' is supported since gcc 2.7, but some compilers
 * may only pretend to be gcc, so let's try to actually use it
 */
static int x = 1;
static void __attribute__((constructor)) constructor_function () { x = 0; }
int main (void) { return x; }
#else
#error not gcc or gcc version is older than 2.7
#endif"
  TOOLCHAIN_SUPPORTS_ATTRIBUTE_CONSTRUCTOR
)
ac_msg_checking("for __attribute__((constructor))"
  ${TOOLCHAIN_SUPPORTS_ATTRIBUTE_CONSTRUCTOR}
)


# ========================================================================
# __float128
#
check_c_source_compiles(
"__float128 a = 1.0Q, b = 2.0Q; int main (void) { return a + b; }"
  HAVE_FLOAT128
)
ac_msg_checking("for __float128" ${HAVE_FLOAT128})


# ========================================================================
# __builtin_clz
#
check_c_source_compiles(
"unsigned int x = 11; int main (void) { return __builtin_clz(x); }"
  HAVE_BUILTIN_CLZ
)
ac_msg_checking("for __builtin_clz" ${HAVE_BUILTIN_CLZ})


# ========================================================================
# GCC vector extensions
#
check_c_source_compiles(
"unsigned int __attribute__ ((vector_size(16))) e, a, b;
int main (void) { e = a - ((b << 27) + (b >> (32 - 27))) + 1; return e[0]; }"
  HAVE_GCC_VECTOR_EXTENSIONS
)
ac_msg_checking("for GCC vector extensions" ${HAVE_GCC_VECTOR_EXTENSIONS})


# ========================================================================
# libpng
#
if(PIXMAN_ENABLE_LIBPNG)
  find_package(PNG)
  if(PNG_FOUND)
    set(HAVE_LIBPNG ON)
  endif()
endif()


# ========================================================================
# config.h
#
configure_file(
  cmake/config.h.in.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/pixman/config.h
)


# ========================================================================
# Components
#
add_subdirectory(pixman)
if(PIXMAN_BUILD_TESTS)
  enable_testing()
  add_subdirectory(test)
endif()
if(PIXMAN_BUILD_DEMOS AND GTK_FOUND)
  add_subdirectory(demos)
endif()
