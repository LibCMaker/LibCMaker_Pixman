# ****************************************************************************
#  Project:  LibCMaker_Pixman
#  Purpose:  A CMake build scripts for build libraries with CMake
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

# Part of "LibCMaker/cmake/cmr_find_package.cmake".

  #-----------------------------------------------------------------------
  # Library specific build arguments
  #-----------------------------------------------------------------------

## +++ Common part of the file 'cmr_find_package_<lib_name>' +++
  set(find_LIB_VARS
    COPY_PIXMAN_CMAKE_BUILD_SCRIPTS
    PIXMAN_BUILD_TESTS
    PIXMAN_BUILD_DEMOS
    PIXMAN_ENABLE_OPENMP
    PIXMAN_ENABLE_LOONGSON_MMI
    PIXMAN_ENABLE_MMX
    PIXMAN_ENABLE_SSE2
    PIXMAN_ENABLE_SSSE3
    PIXMAN_ENABLE_VMX
    PIXMAN_ENABLE_ARM_SIMD
    PIXMAN_ENABLE_ARM_NEON
    PIXMAN_ENABLE_ARM_IWMMXT
    PIXMAN_ENABLE_ARM_IWMMXT2
    PIXMAN_ENABLE_MIPS_DSPR2
    PIXMAN_ENABLE_GCC_INLINE_ASM
    PIXMAN_ENABLE_STATIC_TESTPROGS
    PIXMAN_ENABLE_TIMERS
    PIXMAN_ENABLE_GNUPLOT
    PIXMAN_ENABLE_GTK
    PIXMAN_ENABLE_LIBPNG
  )

  foreach(d ${find_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND find_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the file 'cmr_find_package_<lib_name>' ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

## +++ Common part of the file 'cmr_find_package_<lib_name>' +++
  cmr_lib_cmaker_main(
    LibCMaker_DIR ${find_LibCMaker_DIR}
    NAME          ${find_NAME}
    VERSION       ${find_VERSION}
    LANGUAGES     C ASM
    BASE_DIR      ${find_LIB_DIR}
    DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
    UNPACKED_DIR  ${cmr_UNPACKED_DIR}
    BUILD_DIR     ${lib_BUILD_DIR}
    CMAKE_ARGS    ${find_CMAKE_ARGS}
    INSTALL
  )
## --- Common part of the file 'cmr_find_package_<lib_name>' ---
