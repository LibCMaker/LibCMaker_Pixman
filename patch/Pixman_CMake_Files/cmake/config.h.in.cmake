#define PACKAGE "pixman"
#define PACKAGE_BUGREPORT "pixman@lists.freedesktop.org"
#define PACKAGE_NAME "pixman"
#define PACKAGE_STRING "pixman @PIXMAN_VERSION@"
#define PACKAGE_TARNAME "pixman"
#define PACKAGE_URL ""
#define PACKAGE_VERSION "@PIXMAN_VERSION@"

#ifndef __cplusplus
#cmakedefine inline @inline@
#endif

#if defined __BIG_ENDIAN__
#define WORDS_BIGENDIAN 1
#else
#cmakedefine WORDS_BIGENDIAN @WORDS_BIGENDIAN@
#endif

#cmakedefine HAVE_GETISAX @HAVE_GETISAX@

#cmakedefine SIZEOF_LONG @SIZEOF_LONG@

#cmakedefine USE_OPENMP @USE_OPENMP@

#cmakedefine USE_LOONGSON_MMI @USE_LOONGSON_MMI@
#cmakedefine USE_X86_MMX @USE_X86_MMX@
#cmakedefine USE_SSE2 @USE_SSE2@
#cmakedefine USE_SSSE3 @USE_SSSE3@
#cmakedefine USE_VMX @USE_VMX@
#cmakedefine USE_ARM_SIMD @USE_ARM_SIMD@
#cmakedefine USE_ARM_NEON @USE_ARM_NEON@
#cmakedefine USE_ARM_IWMMXT @USE_ARM_IWMMXT@
#cmakedefine USE_MIPS_DSPR2 @USE_MIPS_DSPR2@
#cmakedefine USE_GCC_INLINE_ASM @USE_GCC_INLINE_ASM@

#cmakedefine PIXMAN_TIMERS @PIXMAN_TIMERS@

#cmakedefine PIXMAN_GNUPLOT @PIXMAN_GNUPLOT@

#cmakedefine HAVE_POSIX_MEMALIGN @HAVE_POSIX_MEMALIGN@
#cmakedefine HAVE_SIGACTION @HAVE_SIGACTION@
#cmakedefine HAVE_ALARM @HAVE_ALARM@
#cmakedefine HAVE_SYS_MMAN_H @HAVE_SYS_MMAN_H@
#cmakedefine HAVE_MMAP @HAVE_MMAP@
#cmakedefine HAVE_MPROTECT @HAVE_MPROTECT@
#cmakedefine HAVE_GETPAGESIZE @HAVE_GETPAGESIZE@
#cmakedefine HAVE_FENV_H @HAVE_FENV_H@
#cmakedefine HAVE_FEENABLEEXCEPT @HAVE_FEENABLEEXCEPT@
#cmakedefine HAVE_FEDIVBYZERO @HAVE_FEDIVBYZERO@
#cmakedefine HAVE_GETTIMEOFDAY @HAVE_GETTIMEOFDAY@

#cmakedefine sqrtf @sqrtf@

#cmakedefine TLS @TLS@

#cmakedefine HAVE_PTHREADS

#cmakedefine TOOLCHAIN_SUPPORTS_ATTRIBUTE_CONSTRUCTOR

#cmakedefine HAVE_FLOAT128

#cmakedefine HAVE_BUILTIN_CLZ

#cmakedefine HAVE_GCC_VECTOR_EXTENSIONS

#cmakedefine HAVE_LIBPNG
