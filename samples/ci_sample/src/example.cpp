/*****************************************************************************
 * Project:  LibCMaker_Pixman
 * Purpose:  A CMake build script for Pixman library
 * Author:   NikitaFeodonit, nfeodonit@yandex.com
 *****************************************************************************
 *   Copyright (c) 2017-2019 NikitaFeodonit
 *
 *    This file is part of the LibCMaker_Pixman project.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published
 *    by the Free Software Foundation, either version 3 of the License,
 *    or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program. If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

// The code is from
// <Pixman-sources>/demos/gradient-test.c

#include <stdio.h>
#include <stdlib.h>
#include "pixman.h"
//#include "gtk-utils.h"

int
main (int argc, char **argv)
{
#define WIDTH 400
#define HEIGHT 200

    uint32_t *dest = (uint32_t*) malloc (WIDTH * HEIGHT * 4);
    pixman_image_t *src_img;
    pixman_image_t *dest_img;
    int i;
    pixman_gradient_stop_t stops[2] =
  {
      { pixman_int_to_fixed (0), { 0x0000, 0x0000, 0xffff, 0xffff } },
      { pixman_int_to_fixed (1), { 0xffff, 0x1111, 0x1111, 0xffff } }
  };
    pixman_point_fixed_t p1 = { pixman_double_to_fixed (50), 0 };
    pixman_point_fixed_t p2 = { pixman_double_to_fixed (200), 0 };
#if 0
    pixman_transform_t trans = {
  { { pixman_double_to_fixed (2), pixman_double_to_fixed (0.5), pixman_double_to_fixed (-100), },
    { pixman_double_to_fixed (0), pixman_double_to_fixed (3), pixman_double_to_fixed (0), },
    { pixman_double_to_fixed (0), pixman_double_to_fixed (0.000), pixman_double_to_fixed (1.0) }
  }
    };
#else
    pixman_transform_t trans = {
  { { pixman_fixed_1, 0, 0 },
    { 0, pixman_fixed_1, 0 },
    { 0, 0, pixman_fixed_1 } }
    };
#endif

#if 0
    pixman_point_fixed_t c_inner;
    pixman_point_fixed_t c_outer;
    pixman_fixed_t r_inner;
    pixman_fixed_t r_outer;
#endif

    for (i = 0; i < WIDTH * HEIGHT; ++i)
  dest[i] = 0xff00ff00;

    dest_img = pixman_image_create_bits (PIXMAN_a8r8g8b8,
           WIDTH, HEIGHT,
           dest,
           WIDTH * 4);

#if 0
    c_inner.x = pixman_double_to_fixed (50.0);
    c_inner.y = pixman_double_to_fixed (50.0);
    c_outer.x = pixman_double_to_fixed (50.0);
    c_outer.y = pixman_double_to_fixed (50.0);
    r_inner = 0;
    r_outer = pixman_double_to_fixed (50.0);

    src_img = pixman_image_create_conical_gradient (&c_inner, r_inner,
                stops, 2);
#endif
#if 0
    src_img = pixman_image_create_conical_gradient (&c_inner, r_inner,
                stops, 2);
    src_img = pixman_image_create_linear_gradient (&c_inner, &c_outer,
               r_inner, r_outer,
               stops, 2);
#endif

    src_img = pixman_image_create_linear_gradient  (&p1, &p2,
                stops, 2);

    pixman_image_set_transform (src_img, &trans);
    pixman_image_set_repeat (src_img, PIXMAN_REPEAT_NONE);

    pixman_image_composite (PIXMAN_OP_OVER, src_img, NULL, dest_img,
          0, 0, 0, 0, 0, 0, 10 * WIDTH, HEIGHT);

    printf ("0, 0: %x\n", dest[0]);
    printf ("10, 10: %x\n", dest[10 * 10 + 10]);
    printf ("w, h: %x\n", dest[(HEIGHT - 1) * 100 + (WIDTH - 1)]);

//    show_image (dest_img);

    pixman_image_unref (src_img);
    pixman_image_unref (dest_img);
    free (dest);

    return 0;
}
