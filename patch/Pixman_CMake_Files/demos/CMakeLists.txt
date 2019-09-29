set(DEMOS
  clip-test
  clip-in
  composite-test
  gradient-test
  radial-test
  linear-gradient
  conical-test
  alpha-test
  screen-test
  convolution-test
  trap-test
  tri-test
  quad2quad
  checkerboard
  srgb-trap-test
  srgb-test
  scale
)

add_library(pixman_gtk_utils STATIC
  gtk-utils.c
  gtk-utils.h
)
target_compile_options(pixman_gtk_utils PUBLIC ${GTK_CFLAGS})
target_include_directories(pixman_gtk_utils PUBLIC ${GTK_INCLUDE_DIRS})
target_link_libraries(pixman_gtk_utils PUBLIC
  pixman_test_utils
  ${GTK_LDFLAGS} ${GTK_LIBRARY_DIRS} ${GTK_LIBRARIES}
)

foreach(program ${DEMOS})
  add_executable(pixman_${program} ${program}.c)
  target_link_libraries(pixman_${program} PRIVATE pixman_gtk_utils)
  set_target_properties(pixman_${program} PROPERTIES
    OUTPUT_NAME ${program}
  )
endforeach()
