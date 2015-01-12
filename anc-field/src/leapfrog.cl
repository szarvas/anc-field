/*
 * Copyright 2014 Attila Szarvas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef CLH_SIZES
#define	size_p_0	128
#define	size_p_1	128
#define	size_p_2	128
#define	size_p_d1_0	128
#define	size_p_d1_1	128
#define	size_p_d1_2	128
#define	size_p_d2_0	128
#define	size_p_d2_1	128
#define	size_p_d2_2	128

#define	ix_p(x,y,z)		((z)*size_p_1*size_p_0+(y)*size_p_0+(x))
#define	ix_p_d1(x,y,z)	((z)*size_p_d1_1*size_p_d1_0+(y)*size_p_d1_0+(x))
#define	ix_p_d2(x,y,z)	((z)*size_p_d2_1*size_p_d2_0+(y)*size_p_d2_0+(x))
#endif

__kernel void leapfrog(__global float* p, __global float* p_d1, __global float* p_d2, float lambda2)
{
	size_t x = get_global_id(0);
	size_t y = get_global_id(1);
	size_t z = get_global_id(2);

	if (x > 0 && x < get_global_size(0)-1 && y > 0 && y < get_global_size(1)-1 && z > 0 && z < get_global_size(2)-1) {
		p[ix_p(x,y,z)] =

			lambda2 * (
				  p_d1[ ix_p_d1(x+1,	y,		z)	 ]
				+ p_d1[ ix_p_d1(x-1,	y,		z)	 ]
				+ p_d1[ ix_p_d1(x,		y+1,	z)	 ]
				+ p_d1[ ix_p_d1(x,		y-1,	z)	 ]
				+ p_d1[ ix_p_d1(x,		y,		z+1) ]
				+ p_d1[ ix_p_d1(x,		y,		z-1) ]
			)
			+ 2.0f*(1.0f - 3.0f*lambda2)*p_d1[ix_p_d1(x,y,z)]
			- p_d2[ix_p_d2(x,y,z)]
		;
	}
}
