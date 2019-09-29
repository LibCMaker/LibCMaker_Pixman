# ****************************************************************************
#  Project:  LibCMaker_Pixman
#  Purpose:  A CMake build script for Pixman library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
#
#    This file is part of the LibCMaker_Pixman project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(PIXMAN_lib_NAME      "Pixman")
set(PIXMAN_lib_VERSION   "0.38.4")
set(PIXMAN_lib_DIR       "${CMAKE_CURRENT_LIST_DIR}")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${PIXMAN_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

set(COPY_PIXMAN_CMAKE_BUILD_SCRIPTS ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

option(PIXMAN_BUILD_TESTS "Build and run regression tests" OFF)
option(PIXMAN_BUILD_DEMOS "Build demo code" OFF)

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
option(PIXMAN_ENABLE_GTK                          "Enable tests using GTK+" OFF)
option(PIXMAN_ENABLE_LIBPNG                      "Build support for libpng" OFF)


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${PIXMAN_lib_NAME}
  VERSION         ${PIXMAN_lib_VERSION}
  LIB_DIR         ${PIXMAN_lib_DIR}
  REQUIRED
)
